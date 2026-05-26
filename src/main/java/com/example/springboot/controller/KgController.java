package com.example.springboot.controller;

import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONObject;
import com.example.springboot.common.Result;
import com.example.springboot.config.interceptor.AuthAccess;
import com.example.springboot.entity.Account;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.User;
import com.example.springboot.entity.UserBehavior;
import com.example.springboot.service.IUserBehaviorService;
import com.example.springboot.service.IUserService;
import com.example.springboot.service.KgRecommendService;
import com.example.springboot.service.Neo4jMigrationService;
import com.example.springboot.utils.TokenUtils;
import jakarta.annotation.Resource;
import org.springframework.data.neo4j.core.Neo4jClient;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/kg")
public class KgController {

    @Resource
    private Neo4jMigrationService migrationService;
    @Resource
    private KgRecommendService recommendService;
    @Resource
    private Neo4jClient neo4jClient;
    @Resource
    private IUserBehaviorService userBehaviorService;
    @Resource
    private IUserService userService;

    @AuthAccess
    @GetMapping("/graph")
    public Result getGraph(@RequestParam(defaultValue = "0") Integer bookId) {
        try {
            Map<String, Object> graphData = migrationService.getGraphData(bookId);
            return Result.success(graphData);
        } catch (Exception e) {
            return Result.error("500", "获取图谱数据失败: " + e.getMessage());
        }
    }

    @AuthAccess
    @GetMapping("/recommend")
    public Result recommend() {
        Account currentUser = TokenUtils.getCurrentUser();
        if (currentUser == null) {
            return Result.success(recommendService.getRandomBooks(10));
        }
        return Result.success(recommendService.recommend(currentUser.getId(), 10));
    }

    @AuthAccess
    @GetMapping("/related/{bookId}")
    public Result getRelatedBooks(@PathVariable Integer bookId) {
        return Result.success(recommendService.findRelatedBooks(bookId, 10));
    }

    @AuthAccess
    @GetMapping("/stats")
    public Result getStats() {
        try {
            Map<String, Object> nodeCounts = neo4jClient.query(
                "MATCH (n) RETURN labels(n)[0] AS type, count(n) AS count ORDER BY type"
            ).fetch().all().stream()
            .collect(LinkedHashMap::new,
                (m, r) -> m.put(String.valueOf(r.get("type")),
                    ((Number) r.get("count")).intValue()),
                LinkedHashMap::putAll);

            Map<String, Object> relationCounts = neo4jClient.query(
                "MATCH ()-[r]->() RETURN type(r) AS type, count(r) AS count ORDER BY type"
            ).fetch().all().stream()
            .collect(LinkedHashMap::new,
                (m, r) -> m.put(String.valueOf(r.get("type")),
                    ((Number) r.get("count")).intValue()),
                LinkedHashMap::putAll);

            Map<String, Object> stats = new LinkedHashMap<>();
            stats.put("nodes", nodeCounts);
            stats.put("relations", relationCounts);
            return Result.success(stats);
        } catch (Exception e) {
            return Result.error("500", "获取Neo4j统计失败: " + e.getMessage());
        }
    }

    @AuthAccess
    @GetMapping("/analyze/similarity")
    public Result analyzeSimilarity(@RequestParam(defaultValue = "8") int topN) {
        List<UserBehavior> allBehaviors = userBehaviorService.list();
        if (allBehaviors.isEmpty()) {
            return Result.error("400", "无用户行为数据");
        }

        Map<Integer, String> nicknameMap = new HashMap<>();
        for (User u : userService.list()) {
            nicknameMap.put(u.getId(), u.getNickname() != null ? u.getNickname() : ("用户" + u.getId()));
        }

        Map<Integer, Set<Integer>> userBookMap = new HashMap<>();
        for (UserBehavior b : allBehaviors) {
            if (!nicknameMap.containsKey(b.getUserId())) continue;
            userBookMap.computeIfAbsent(b.getUserId(), k -> new HashSet<>()).add(b.getBookId());
        }

        List<Integer> allUserIds = new ArrayList<>(userBookMap.keySet());
        if (allUserIds.size() > topN) {
            Map<Integer, Integer> behaviorSumMap = new HashMap<>();
            for (UserBehavior b : allBehaviors) {
                if (!nicknameMap.containsKey(b.getUserId())) continue;
                behaviorSumMap.merge(b.getUserId(), b.getBehaviorValue(), Integer::sum);
            }
            allUserIds = behaviorSumMap.entrySet().stream()
                    .sorted(Map.Entry.<Integer, Integer>comparingByValue().reversed())
                    .limit(topN)
                    .map(Map.Entry::getKey)
                    .collect(Collectors.toList());
        }

        Set<Integer> allBookIds = new HashSet<>();
        for (Set<Integer> books : userBookMap.values()) {
            allBookIds.addAll(books);
        }

        JSONArray usersJson = new JSONArray();
        for (Integer uid : allUserIds) {
            usersJson.add(nicknameMap.getOrDefault(uid, "用户" + uid));
        }

        List<double[]> matrix = new ArrayList<>();
        for (Integer u1 : allUserIds) {
            double[] row = new double[allUserIds.size()];
            Set<Integer> books1 = userBookMap.getOrDefault(u1, Collections.emptySet());

            List<int[]> vec1 = new ArrayList<>();
            for (Integer bid : allBookIds) {
                vec1.add(new int[]{bid, books1.contains(bid) ? 1 : 0});
            }

            for (int j = 0; j < allUserIds.size(); j++) {
                Integer u2 = allUserIds.get(j);
                Set<Integer> books2 = userBookMap.getOrDefault(u2, Collections.emptySet());
                if (u1.equals(u2)) {
                    row[j] = 1.0;
                } else {
                    row[j] = cosineSimilarity(vec1, books2);
                }
            }
            matrix.add(row);
        }

        JSONArray matrixJson = new JSONArray();
        for (double[] row : matrix) {
            JSONArray rowJson = new JSONArray();
            for (double v : row) {
                rowJson.add(Math.round(v * 100.0) / 100.0);
            }
            matrixJson.add(rowJson);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("users", usersJson);
        result.put("matrix", matrixJson);
        return Result.success(result);
    }

    @AuthAccess
    @GetMapping("/analyze/scores")
    public Result analyzeScores(@RequestParam(defaultValue = "1") Integer userId,
                                @RequestParam(defaultValue = "0.6") Double alpha) {
        Set<Integer> interactedBookIds = userBehaviorService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<UserBehavior>()
                        .eq(UserBehavior::getUserId, userId)
        ).stream().map(UserBehavior::getBookId).collect(Collectors.toSet());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("alpha", alpha);
        result.put("cfWeight", Math.round(alpha * 100.0) / 100.0);
        result.put("kgWeight", Math.round((1.0 - alpha) * 100.0) / 100.0);

        if (interactedBookIds.isEmpty()) {
            result.put("items", new JSONArray());
            return Result.success(result);
        }

        Map<Integer, Double> catPref = recommendService.computeCategoryPreference(interactedBookIds);
        List<KgRecommendService.Candidate> candidates = recommendService.buildCandidates(userId, interactedBookIds, catPref, alpha);

        JSONArray items = new JSONArray();
        int count = 0;
        for (KgRecommendService.Candidate c : candidates) {
            if (count >= 10) break;
            com.example.springboot.entity.Book book = recommendService.getBookById(c.bookId);
            String bookName = book != null ? book.getName() : ("书" + c.bookId);

            JSONObject obj = new JSONObject();
            obj.set("bookId", c.bookId);
            obj.set("bookName", bookName);
            obj.set("cfScore", Math.round(c.cfNorm * 100.0) / 100.0);
            obj.set("kgScore", Math.round(c.kgNorm * 100.0) / 100.0);
            obj.set("fusedScore", Math.round(c.score * 100.0) / 100.0);
            obj.set("source", c.source);
            items.add(obj);
            count++;
        }

        result.put("items", items);
        return Result.success(result);
    }

    @AuthAccess
    @GetMapping("/analyze/behavior")
    public Result analyzeBehavior(@RequestParam(defaultValue = "1") Integer userId) {
        List<UserBehavior> behaviors = userBehaviorService.list(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<UserBehavior>()
                        .eq(UserBehavior::getUserId, userId)
        );

        int viewCount = 0, collectCount = 0, orderCount = 0, totalValue = 0;
        JSONArray detailList = new JSONArray();

        for (UserBehavior b : behaviors) {
            if ("view".equals(b.getBehaviorType())) {
                viewCount++;
            } else if ("collect".equals(b.getBehaviorType())) {
                collectCount++;
            } else if ("order".equals(b.getBehaviorType())) {
                orderCount++;
            }
            totalValue += b.getBehaviorValue();

            JSONObject detail = new JSONObject();
            detail.set("bookId", b.getBookId());
            detail.set("behaviorType", b.getBehaviorType());
            detail.set("behaviorValue", b.getBehaviorValue());
            detailList.add(detail);
        }

        JSONArray distribution = new JSONArray();
        JSONObject viewItem = new JSONObject();
        viewItem.set("name", "浏览");
        viewItem.set("value", viewCount);
        distribution.add(viewItem);

        JSONObject collectItem = new JSONObject();
        collectItem.set("name", "收藏");
        collectItem.set("value", collectCount);
        distribution.add(collectItem);

        JSONObject orderItem = new JSONObject();
        orderItem.set("name", "购买");
        orderItem.set("value", orderCount);
        distribution.add(orderItem);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("distribution", distribution);
        result.put("detailList", detailList);
        result.put("total", behaviors.size());
        result.put("totalValue", totalValue);
        result.put("userId", userId);
        User u = userService.getById(userId);
        result.put("nickname", u != null && u.getNickname() != null ? u.getNickname() : ("用户" + userId));
        return Result.success(result);
    }

    @AuthAccess
    @GetMapping("/analyze/users")
    public Result analyzeUsers() {
        List<User> allUsers = userService.list();
        Map<Integer, String> nicknameMap = new HashMap<>();
        for (User u : allUsers) {
            nicknameMap.put(u.getId(), u.getNickname() != null ? u.getNickname() : ("用户" + u.getId()));
        }

        Map<Integer, Long> behaviorCountMap = userBehaviorService.list().stream()
                .collect(Collectors.groupingBy(UserBehavior::getUserId, Collectors.counting()));

        JSONArray userList = new JSONArray();
        for (Map.Entry<Integer, Long> entry : behaviorCountMap.entrySet()) {
            Integer uid = entry.getKey();
            if (!nicknameMap.containsKey(uid)) continue;
            JSONObject user = new JSONObject();
            user.set("userId", uid);
            user.set("name", nicknameMap.get(uid));
            user.set("behaviorCount", entry.getValue().intValue());
            userList.add(user);
        }
        return Result.success(userList);
    }

    private double cosineSimilarity(List<int[]> targetVector, Set<Integer> otherBooks) {
        double dotProduct = 0.0;
        double normA = 0.0;
        double normB = 0.0;
        for (int[] entry : targetVector) {
            int a = entry[1];
            int b = otherBooks.contains(entry[0]) ? 1 : 0;
            dotProduct += a * b;
            normA += a * a;
            normB += b * b;
        }
        if (normA == 0.0 || normB == 0.0) return 0.0;
        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }
}
