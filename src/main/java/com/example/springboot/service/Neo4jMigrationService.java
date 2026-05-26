package com.example.springboot.service;

import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.neo4j.core.Neo4jClient;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
public class Neo4jMigrationService {

    @Resource
    private Neo4jClient neo4jClient;

    public Map<String, Object> getGraphData(Integer bookId) {
        if (bookId != null && bookId > 0) {
            return getBookGraphData(bookId);
        }
        return getFullGraphData();
    }

    private Map<String, Object> getFullGraphData() {
        Collection<Map<String, Object>> rawResults = neo4jClient.query(
                "MATCH (n)-[r]->(m) " +
                "RETURN n.name AS sourceName, labels(n)[0] AS sourceType, " +
                "type(r) AS relationType, r.weight AS weight, " +
                "m.name AS targetName, labels(m)[0] AS targetType"
        ).fetch().all();

        List<Map<String, Object>> rawLinks = rawResults.stream()
                .map(record -> (Map<String, Object>) record)
                .collect(Collectors.toList());

        return buildGraphResponse(rawLinks);
    }

    private Map<String, Object> getBookGraphData(Integer bookId) {
        Collection<Map<String, Object>> rawResults = neo4jClient.query(
                "MATCH (b:Book {bookId: $bookId})-[r]->(m) " +
                "RETURN b.name AS sourceName, labels(b)[0] AS sourceType, " +
                "type(r) AS relationType, r.weight AS weight, " +
                "m.name AS targetName, labels(m)[0] AS targetType"
        ).bind(bookId).to("bookId").fetch().all();

        List<Map<String, Object>> rawLinks = rawResults.stream()
                .map(record -> (Map<String, Object>) record)
                .collect(Collectors.toList());

        return buildGraphResponse(rawLinks);
    }

    private Map<String, Object> buildGraphResponse(List<Map<String, Object>> rawLinks) {
        Map<String, Integer> nodeMap = new LinkedHashMap<>();
        List<Map<String, Object>> nodes = new ArrayList<>();
        List<Map<String, Object>> links = new ArrayList<>();

        Map<String, Integer> categoryMap = new HashMap<>();
        categoryMap.put("Book", 0);
        categoryMap.put("Author", 1);
        categoryMap.put("Category", 2);
        categoryMap.put("Theme", 3);
        categoryMap.put("Publisher", 4);
        categoryMap.put("Era", 5);

        for (Map<String, Object> link : rawLinks) {
            String sourceName = String.valueOf(link.get("sourceName"));
            String sourceType = String.valueOf(link.get("sourceType"));
            String targetName = String.valueOf(link.get("targetName"));
            String targetType = String.valueOf(link.get("targetType"));
            String relationType = String.valueOf(link.get("relationType"));

            if (!nodeMap.containsKey(sourceName)) {
                nodeMap.put(sourceName, nodes.size());
                Map<String, Object> node = new HashMap<>();
                node.put("name", sourceName);
                node.put("category", categoryMap.getOrDefault(sourceType, 0));
                node.put("symbolSize", "Book".equals(sourceType) ? 40 : 30);
                nodes.add(node);
            }
            if (!nodeMap.containsKey(targetName)) {
                nodeMap.put(targetName, nodes.size());
                Map<String, Object> node = new HashMap<>();
                node.put("name", targetName);
                node.put("category", categoryMap.getOrDefault(targetType, 0));
                node.put("symbolSize", "Book".equals(targetType) ? 40 : 30);
                nodes.add(node);
            }

            Map<String, Object> edge = new HashMap<>();
            edge.put("source", sourceName);
            edge.put("target", targetName);
            edge.put("value", relationType);
            Object weight = link.get("weight");
            if (weight != null) {
                edge.put("weight", weight);
            }
            links.add(edge);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("nodes", nodes);
        result.put("links", links);
        return result;
    }
}
