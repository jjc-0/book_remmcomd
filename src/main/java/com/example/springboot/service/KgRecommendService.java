package com.example.springboot.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.BookCategory;
import com.example.springboot.entity.UserBehavior;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.neo4j.core.Neo4jClient;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
public class KgRecommendService {

    @Value("${recommend.similar-user-count:20}")
    private int similarUserCount;

    @Value("${recommend.alpha:0.3}")
    private double defaultAlpha;

    private volatile double currentAlpha = -1;

    @Resource
    private Neo4jClient neo4jClient;
    @Resource
    private IUserBehaviorService userBehaviorService;
    @Resource
    private IBookService bookService;
    @Resource
    private IBookCategoryService bookCategoryService;

    public double getAlpha() {
        if (currentAlpha < 0) return defaultAlpha;
        return currentAlpha;
    }

    public void setAlpha(double alpha) {
        this.currentAlpha = Math.max(0.0, Math.min(1.0, alpha));
        log.info("全局Alpha已更新: {}", this.currentAlpha);
    }

    public List<Book> recommend(Integer userId, int limit) {
        Set<Integer> interacted = getUserInteractedBooks(userId);
        if (interacted.isEmpty()) {//数据稀疏
            log.info("推荐 userId={}: 无行为数据，返回随机", userId);
            return getRandomBooks(limit);
        }

        Map<Integer, Double> catPref = computeCategoryPreference(interacted);
        if (catPref.isEmpty()) {
            log.warn("推荐 userId={}: 所有交互图书的类别信息缺失，返回随机兜底", userId);
            return getRandomBooks(limit);
        }

        Set<Integer> preferredCatIds = catPref.keySet();
        double alpha = getAlpha();
        List<Candidate> candidates = buildCandidates(userId, interacted, catPref, preferredCatIds, alpha);

        List<Book> result = new ArrayList<>();
        Set<Integer> seen = new HashSet<>();
        for (Candidate c : candidates) {
            if (seen.contains(c.bookId)) continue;
            Book b = bookService.getById(c.bookId);
            if (b != null) {
                result.add(b);
                seen.add(c.bookId);
                if (result.size() >= limit) break;
            }
        }

        if (result.size() < limit) {
            Set<Integer> filled = new HashSet<>(seen);
            filled.addAll(interacted);
            List<Candidate> extra = buildCandidates(userId, interacted, catPref, preferredCatIds, alpha);
            for (Candidate c : extra) {
                if (filled.contains(c.bookId)) continue;
                Book b = bookService.getById(c.bookId);
                if (b != null) {
                    result.add(b);
                    filled.add(c.bookId);
                    if (result.size() >= limit) break;
                }
            }
        }

        if (result.size() < limit) {
            result.addAll(getRandomBooksExcluding(limit - result.size(),
                    new HashSet<>(interacted)));
        }

        log.info("推荐结果 userId={}: {}", userId,
                result.stream().map(b -> b.getId() + "-" + b.getName() + "(" + b.getCategoryId() + ")")
                        .collect(Collectors.toList()));
        return result;
    }

    public List<Candidate> buildCandidates(Integer userId, Set<Integer> interacted,//融合打分
                                           Map<Integer, Double> catPref,
                                           Set<Integer> preferredCatIds, double alpha) {
        List<Integer> likedIds = new ArrayList<>(getLikedBookIds(userId));

        Map<Integer, Double> kg = recommendByKG(likedIds, interacted, 30);
        double kgMax = kg.values().stream().max(Double::compare).orElse(1.0);
        Map<Integer, Double> cf = recommendCF(userId, interacted, 30);
        double cfMax = cf.values().stream().max(Double::compare).orElse(1.0);

        Set<Integer> allBookIds = new LinkedHashSet<>();
        allBookIds.addAll(kg.keySet());
        allBookIds.addAll(cf.keySet());

        List<Candidate> candidates = new ArrayList<>();
        for (Integer bid : allBookIds) {
            Book b = bookService.getById(bid);
            if (b == null) continue;
            double kgN = kgMax > 0 ? kg.getOrDefault(bid, 0.0) / kgMax : 0;
            double cfN = cfMax > 0 ? cf.getOrDefault(bid, 0.0) / cfMax : 0;
            double catFactor = catPref.getOrDefault(b.getCategoryId(), 0.0);
            boolean inKG = kg.containsKey(bid);
            boolean inCF = cf.containsKey(bid);

            double baseScore = alpha * cfN + (1.0 - alpha) * kgN;
            double score;
            String source;
            if (catFactor <= 0) {
                score = baseScore * 0.001;
                source = inKG && inCF ? "KG+CF(OFF)" : inKG ? "KG(OFF)" : "CF(OFF)";
            } else if (inKG && inCF) {
                score = baseScore * (1.0 + 2.0 * catFactor) / 3.0;
                source = "KG+CF";
            } else if (inKG) {
                score = baseScore * (0.6 + 0.4 * catFactor) / 3.0;
                source = "KG";
            } else {
                score = baseScore * (0.3 + 0.2 * catFactor) / 3.0;
                source = "CF";
            }
            candidates.add(new Candidate(bid, score, kgN, cfN, source, b.getCategoryId()));
        }

        candidates.sort((a, b) -> Double.compare(b.score, a.score));
        log.info("buildCandidates: 总数={}, 偏好类别={}, 最终候选前5: {}",
                candidates.size(), preferredCatIds.size(),
                candidates.stream().limit(5)
                        .map(c -> c.bookId + "(" + c.source + ":" + String.format("%.4f", c.score) + ")")
                        .collect(Collectors.toList()));
        return candidates;
    }

    public Map<Integer, Double> computeCategoryPreference(Set<Integer> interactedBookIds) {//计算类别偏好
        Map<Integer, Integer> count = new HashMap<>();
        int total = 0;
        for (Integer bid : interactedBookIds) {
            Book b = bookService.getById(bid);
            if (b != null && b.getCategoryId() != null) {
                count.merge(b.getCategoryId(), 1, Integer::sum);
                total++;
            }
        }
        Map<Integer, Double> pref = new HashMap<>();
        if (total == 0) return pref;
        for (Map.Entry<Integer, Integer> e : count.entrySet()) {
            double w = (double) e.getValue() / total;
            Integer cid = e.getKey();
            double f = 1.0;
            while (cid != null && cid > 0) {
                pref.merge(cid, w * f, Double::sum);
                BookCategory cat = bookCategoryService.getById(cid);
                cid = (cat != null && cat.getParentId() != null && cat.getParentId() > 0)
                        ? cat.getParentId() : null;
                f *= 0.5;
            }
        }
        return pref;
    }

    public Map<Integer, Double> recommendCF(Integer userId, Set<Integer> interacted, int limit) {
        List<UserBehavior> all = userBehaviorService.list();
        Map<Integer, Set<Integer>> userBooks = new HashMap<>();
        for (UserBehavior b : all) {
            userBooks.computeIfAbsent(b.getUserId(), k -> new HashSet<>()).add(b.getBookId());
        }
        Set<Integer> allBooks = new HashSet<>();
        for (Set<Integer> s : userBooks.values()) allBooks.addAll(s);
        Set<Integer> mine = userBooks.getOrDefault(userId, Collections.emptySet());
        if (mine.isEmpty()) return new LinkedHashMap<>();

        List<int[]> vec = new ArrayList<>();
        for (Integer bid : allBooks) vec.add(new int[]{bid, mine.contains(bid) ? 1 : 0});

        Map<Integer, Double> simMap = new HashMap<>();
        for (Map.Entry<Integer, Set<Integer>> e : userBooks.entrySet()) {
            if (e.getKey().equals(userId)) continue;
            double s = cosine(vec, e.getValue());
            if (s > 0) simMap.put(e.getKey(), s);
        }
        if (simMap.isEmpty()) return new LinkedHashMap<>();

        List<Map.Entry<Integer, Double>> topSim = simMap.entrySet().stream()
                .sorted(Map.Entry.<Integer, Double>comparingByValue().reversed())
                .limit(similarUserCount).collect(Collectors.toList());

        Map<Integer, Double> scores = new LinkedHashMap<>();
        for (Integer bid : allBooks) {
            if (interacted.contains(bid)) continue;
            double num = 0, den = 0;
            for (Map.Entry<Integer, Double> se : topSim) {
                double sim = se.getValue();
                Set<Integer> sb = userBooks.get(se.getKey());
                if (sb != null && sb.contains(bid)) num += sim;
                den += Math.abs(sim);
            }
            if (den > 0 && num > 0) scores.put(bid, num / den);
        }
        return scores.entrySet().stream()
                .sorted(Map.Entry.<Integer, Double>comparingByValue().reversed())
                .limit(limit).collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue,
                        (a, b) -> a, LinkedHashMap::new));
    }

    public Map<Integer, Double> recommendByKG(List<Integer> likedIds, Set<Integer> exclude, int limit) {
        if (likedIds.isEmpty()) return new LinkedHashMap<>();
        String liked = likedIds.stream().map(String::valueOf).collect(Collectors.joining(","));
        String excl = exclude.isEmpty() ? "-1" : exclude.stream().map(String::valueOf).collect(Collectors.joining(","));

        Map<Integer, Double> all = new LinkedHashMap<>();

        try {
            String q = String.format(
                "MATCH (liked:Book)-[:BELONGS_TO]->(cat:Category)<-[:BELONGS_TO]-(rec:Book) " +
                "WHERE liked.bookId IN [%s] AND NOT rec.bookId IN [%s] " +
                "RETURN DISTINCT rec.bookId AS bookId, count(DISTINCT cat) AS score " +
                "ORDER BY score DESC LIMIT %d", liked, excl, limit);
            for (Map<String, Object> r : neo4jClient.query(q).fetch().all()) {
                all.merge(toInt(r.get("bookId")), toDouble(r.get("score")) * 3.0, Double::sum);
            }
            log.info("KG-BELONGS_TO: {}条", all.size());
        } catch (Exception e) {
            log.warn("KG-BELONGS_TO失败: {}", e.getMessage());
        }

        try {
            String q = String.format(
                "MATCH (liked:Book)-[:WRITTEN_BY|ABOUT|PUBLISHED_BY|WRITTEN_IN]->(e)" +
                       "<-[:WRITTEN_BY|ABOUT|PUBLISHED_BY|WRITTEN_IN]-(rec:Book) " +
                "WHERE liked.bookId IN [%s] AND NOT rec.bookId IN [%s] " +
                "RETURN DISTINCT rec.bookId AS bookId, count(DISTINCT e) AS score " +
                "ORDER BY score DESC LIMIT %d", liked, excl, limit);
            for (Map<String, Object> r : neo4jClient.query(q).fetch().all()) {
                all.merge(toInt(r.get("bookId")), toDouble(r.get("score")) * 1.0, Double::sum);
            }
            log.info("KG-实体关联: 累计{}条", all.size());
        } catch (Exception e) {
            log.warn("KG-实体关联失败: {}", e.getMessage());
        }

        try {
            String q = String.format(
                "MATCH (liked:Book)-[:WRITTEN_BY|BELONGS_TO|ABOUT]->(e1)" +
                       "-[r:SIMILAR_TO|RELATED_TO]-(e2)" +
                       "<-[:WRITTEN_BY|BELONGS_TO|ABOUT]-(rec:Book) " +
                "WHERE liked.bookId IN [%s] AND NOT rec.bookId IN [%s] " +
                "RETURN DISTINCT rec.bookId AS bookId, count(DISTINCT e2) AS score " +
                "ORDER BY score DESC LIMIT %d", liked, excl, limit);
            for (Map<String, Object> r : neo4jClient.query(q).fetch().all()) {
                all.merge(toInt(r.get("bookId")), toDouble(r.get("score")) * 0.5, Double::sum);
            }
            log.info("KG-传播: 累计{}条", all.size());
        } catch (Exception e) {
            log.warn("KG-传播失败: {}", e.getMessage());
        }

        return all;
    }

    public List<Book> findRelatedBooks(Integer bookId, int limit) {
        try {
            String q = String.format(
                "MATCH (b:Book {bookId: %d})-[:BELONGS_TO]->(cat:Category)<-[:BELONGS_TO]-(rec:Book) " +
                "WHERE rec.bookId <> %d " +
                "RETURN DISTINCT rec.bookId AS bookId, count(DISTINCT cat) AS score " +
                "ORDER BY score DESC LIMIT %d", bookId, bookId, limit);
            return neo4jClient.query(q).fetch().all().stream()
                    .map(r -> bookService.getById(toInt(r.get("bookId"))))
                    .filter(Objects::nonNull).collect(Collectors.toList());
        } catch (Exception e) {
            log.warn("关联图书查询失败: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    public Book getBookById(Integer bookId) {
        return bookService.getById(bookId);
    }

    public List<Book> getRandomBooks(int limit) {
        return getRandomBooksExcluding(limit, Collections.emptySet());
    }

    private Set<Integer> getUserInteractedBooks(Integer userId) {
        return userBehaviorService.list(
                new LambdaQueryWrapper<UserBehavior>().eq(UserBehavior::getUserId, userId)
        ).stream().map(UserBehavior::getBookId).collect(Collectors.toSet());
    }

    private Set<Integer> getLikedBookIds(Integer userId) {
        return userBehaviorService.list(
                new LambdaQueryWrapper<UserBehavior>()
                        .eq(UserBehavior::getUserId, userId)
                        .orderByDesc(UserBehavior::getBehaviorValue)
        ).stream().map(UserBehavior::getBookId)
                .collect(Collectors.toCollection(LinkedHashSet::new));
    }

    private List<Book> getRandomBooksExcluding(int limit, Set<Integer> excluded) {
        List<Book> all = bookService.list(new LambdaQueryWrapper<Book>().eq(Book::getStatus, true));
        List<Book> cand = all.stream().filter(b -> !excluded.contains(b.getId())).collect(Collectors.toList());
        Collections.shuffle(cand);
        return cand.stream().limit(limit).collect(Collectors.toList());
    }

    private double cosine(List<int[]> tv, Set<Integer> other) {
        double dot = 0, na = 0, nb = 0;
        for (int[] e : tv) {
            int a = e[1], b = other.contains(e[0]) ? 1 : 0;
            dot += a * b;
            na += a * a;
            nb += b * b;
        }
        if (na == 0 || nb == 0) return 0;
        return dot / (Math.sqrt(na) * Math.sqrt(nb));
    }

    private Integer toInt(Object obj) {
        if (obj instanceof Number) return ((Number) obj).intValue();
        return Integer.parseInt(String.valueOf(obj));
    }

    private Double toDouble(Object obj) {
        if (obj instanceof Number) return ((Number) obj).doubleValue();
        try { return Double.parseDouble(String.valueOf(obj)); } catch (Exception e) { return 0.0; }
    }

    public static class Candidate {
        public final Integer bookId;
        public final double score;
        public final double kgNorm;
        public final double cfNorm;
        public final String source;
        public final Integer categoryId;

        Candidate(Integer bookId, double score, double kgNorm, double cfNorm, String source, Integer categoryId) {
            this.bookId = bookId;
            this.score = score;
            this.kgNorm = kgNorm;
            this.cfNorm = cfNorm;
            this.source = source;
            this.categoryId = categoryId;
        }
    }
}
