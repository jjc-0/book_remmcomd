package com.example.springboot.controller;

import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONObject;
import com.example.springboot.common.Result;
import com.example.springboot.entity.*;
import com.example.springboot.service.*;
import jakarta.annotation.Resource;
import org.springframework.data.neo4j.core.Neo4jClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/echarts")
public class EchartsController {

    @Resource
    private IOrdersService ordersService;
    @Resource
    private IBookService bookService;
    @Resource
    private IBookCategoryService bookCategoryService;
    @Resource
    private IKgEntityService kgEntityService;
    @Resource
    private IKgRelationService kgRelationService;
    @Resource
    private IUserService userService;
    @Resource
    private IUserBehaviorService userBehaviorService;
    @Resource
    private Neo4jClient neo4jClient;

    @GetMapping("/dashboard")
    public Result dashboard() {
        JSONObject data = new JSONObject();
        data.set("bookCount", bookService.count());
        data.set("categoryCount", bookCategoryService.count());
        data.set("entityCount", kgEntityService.count());
        data.set("relationCount", kgRelationService.count());
        data.set("userCount", userService.count());
        data.set("orderCount", ordersService.count());
        data.set("behaviorCount", userBehaviorService.count());
        return Result.success(data);
    }

    @GetMapping("/categoryDistribution")
    public Result categoryDistribution() {
        Map<Integer, String> categoryMap = bookCategoryService.list().stream()
                .collect(Collectors.toMap(BookCategory::getId, BookCategory::getName));

        Map<Integer, List<Book>> categoryBookMap = bookService.list().stream()
                .collect(Collectors.groupingBy(Book::getCategoryId));

        JSONArray array = new JSONArray();
        for (Map.Entry<Integer, String> entry : categoryMap.entrySet()) {
            Integer categoryId = entry.getKey();
            String categoryName = entry.getValue();
            List<Book> bookList = categoryBookMap.getOrDefault(categoryId, Collections.emptyList());

            JSONObject object = new JSONObject();
            object.set("name", categoryName);
            object.set("value", bookList.size());
            array.add(object);
        }
        return Result.success(array);
    }

    @GetMapping("/entityDistribution")
    public Result entityDistribution() {
        List<KgEntity> entities = kgEntityService.list();
        Map<String, Long> typeCountMap = entities.stream()
                .collect(Collectors.groupingBy(KgEntity::getType, Collectors.counting()));

        JSONArray array = new JSONArray();
        for (Map.Entry<String, Long> entry : typeCountMap.entrySet()) {
            JSONObject object = new JSONObject();
            object.set("name", entry.getKey());
            object.set("value", entry.getValue());
            array.add(object);
        }
        return Result.success(array);
    }

    @GetMapping("/authorBookCount")
    public Result authorBookCount() {
        List<KgEntity> entities = kgEntityService.list();

        Map<String, Long> authorCountMap = new HashMap<>();
        for (KgEntity entity : entities) {
            if ("author".equals(entity.getType())) {
                authorCountMap.put(entity.getName(), 0L);
            }
        }

        List<Book> books = bookService.list();
        Map<String, Long> authorBookCount = new HashMap<>();
        for (Book book : books) {
            String author = book.getAuthor();
            if (author != null && authorCountMap.containsKey(author)) {
                authorBookCount.put(author, authorBookCount.getOrDefault(author, 0L) + 1);
            }
        }

        List<Map.Entry<String, Long>> sorted = authorBookCount.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .limit(10)
                .collect(Collectors.toList());

        JSONArray array = new JSONArray();
        for (Map.Entry<String, Long> entry : sorted) {
            JSONObject object = new JSONObject();
            object.set("name", entry.getKey());
            object.set("value", entry.getValue());
            array.add(object);
        }
        return Result.success(array);
    }

    @GetMapping("/count1")
    public Result count1() {
        return categoryDistribution();
    }

    @GetMapping("/count2")
    public Result count2() {
        return authorBookCount();
    }

    @GetMapping("/kgDistribution")
    public Result kgDistribution() {
        try {
            Collection<Map<String, Object>> rows = neo4jClient.query(
                "MATCH ()-[r]->() RETURN type(r) AS name, count(r) AS value ORDER BY value DESC"
            ).fetch().all();

            JSONArray array = new JSONArray();
            for (Map<String, Object> row : rows) {
                JSONObject obj = new JSONObject();
                obj.set("name", String.valueOf(row.get("name")));
                obj.set("value", ((Number) row.get("value")).intValue());
                array.add(obj);
            }
            return Result.success(array);
        } catch (Exception e) {
            return Result.success(new JSONArray());
        }
    }
}