package com.example.springboot.utils;

import com.example.springboot.entity.*;
import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

public class KnowledgeGraphRecommender {
    
    public static List<Integer> recommend(Integer userId, List<Book> allBooks, 
                                         List<KgEntity> entities, 
                                         List<KgRelation> relations,
                                         List<UserBehavior> userBehaviors) {
        
        Map<String, Double> userProfile = buildUserProfile(userId, userBehaviors, entities, relations);
        
        Map<Integer, Double> bookScores = new HashMap<>();
        
        for (Book book : allBooks) {
            double score = calculateBookScore(book, userProfile, entities, relations);
            bookScores.put(book.getId(), score);
        }
        
        return bookScores.entrySet().stream()
                .sorted(Map.Entry.<Integer, Double>comparingByValue().reversed())
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }
    
    private static Map<String, Double> buildUserProfile(Integer userId, 
                                                       List<UserBehavior> behaviors,
                                                       List<KgEntity> entities,
                                                       List<KgRelation> relations) {
        
        Map<String, Double> userProfile = new HashMap<>();
        
        List<UserBehavior> userBehaviors = behaviors.stream()
                .filter(b -> b.getUserId().equals(userId))
                .collect(Collectors.toList());
        
        for (UserBehavior behavior : userBehaviors) {
            List<Integer> relatedEntities = getRelatedEntities(behavior.getBookId(), relations);
            
            for (Integer entityId : relatedEntities) {
                KgEntity entity = entities.stream()
                        .filter(e -> e.getId().equals(entityId))
                        .findFirst().orElse(null);
                
                if (entity != null) {
                    String key = entity.getType() + ":" + entity.getName();
                    double value = userProfile.getOrDefault(key, 0.0) + behavior.getBehaviorValue();
                    userProfile.put(key, value);
                }
            }
        }
        
        return userProfile;
    }
    
    private static double calculateBookScore(Book book, 
                                           Map<String, Double> userProfile,
                                           List<KgEntity> entities,
                                           List<KgRelation> relations) {
        
        double score = 0.0;
        
        List<Integer> relatedEntities = getRelatedEntities(book.getId(), relations);
        
        for (Integer entityId : relatedEntities) {
            KgEntity entity = entities.stream()
                    .filter(e -> e.getId().equals(entityId))
                    .findFirst().orElse(null);
            
            if (entity != null) {
                String key = entity.getType() + ":" + entity.getName();
                double userPreference = userProfile.getOrDefault(key, 0.0);
                
                BigDecimal relationWeight = getRelationWeight(book.getId(), entityId, relations);
                
                score += userPreference * relationWeight.doubleValue();
            }
        }
        
        return score;
    }
    
    private static List<Integer> getRelatedEntities(Integer bookId, List<KgRelation> relations) {
        return relations.stream()
                .filter(r -> r.getSourceId().equals(bookId) || r.getTargetId().equals(bookId))
                .map(r -> r.getSourceId().equals(bookId) ? r.getTargetId() : r.getSourceId())
                .distinct()
                .collect(Collectors.toList());
    }
    
    private static BigDecimal getRelationWeight(Integer bookId, Integer entityId, List<KgRelation> relations) {
        return relations.stream()
                .filter(r -> (r.getSourceId().equals(bookId) && r.getTargetId().equals(entityId)) ||
                           (r.getTargetId().equals(bookId) && r.getSourceId().equals(entityId)))
                .map(KgRelation::getWeight)
                .findFirst()
                .orElse(BigDecimal.ONE);
    }
}