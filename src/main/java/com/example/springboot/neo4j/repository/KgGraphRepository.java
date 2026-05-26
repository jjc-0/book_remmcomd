package com.example.springboot.neo4j.repository;

import com.example.springboot.neo4j.node.BookNode;
import org.springframework.data.neo4j.repository.Neo4jRepository;
import org.springframework.data.neo4j.repository.query.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface KgGraphRepository extends Neo4jRepository<BookNode, Long> {

    Optional<BookNode> findByBookId(Integer bookId);

    @Query("MATCH (b:Book) WHERE b.bookId IN $bookIds RETURN count(b)")
    Long countBooksByIds(@Param("bookIds") List<Integer> bookIds);

    @Query("MATCH (b:Book) WHERE b.bookId IN $bookIds RETURN b.bookId")
    List<Integer> findExistingBookIds(@Param("bookIds") List<Integer> bookIds);

    @Query("""
        MATCH (liked:Book)-[:WRITTEN_BY|BELONGS_TO|ABOUT|PUBLISHED_BY|WRITTEN_IN]->(entity)<-[:WRITTEN_BY|BELONGS_TO|ABOUT|PUBLISHED_BY|WRITTEN_IN]-(rec:Book)
        WHERE liked.bookId IN $likedBookIds
          AND NOT rec.bookId IN $excludedBookIds
        RETURN DISTINCT rec.bookId AS bookId, rec.name AS name, count(DISTINCT entity) AS score
        ORDER BY score DESC
        LIMIT $limit
    """)
    List<Map<String, Object>> recommendDirect(
            @Param("likedBookIds") List<Integer> likedBookIds,
            @Param("excludedBookIds") List<Integer> excludedBookIds,
            @Param("limit") int limit
    );

    @Query("""
        MATCH (liked:Book)-[:WRITTEN_BY|BELONGS_TO|ABOUT]->(e1)-[r:SIMILAR_TO|RELATED_TO]-(e2)<-[:WRITTEN_BY|BELONGS_TO|ABOUT]-(rec:Book)
        WHERE liked.bookId IN $likedBookIds
          AND NOT rec.bookId IN $excludedBookIds
        RETURN DISTINCT rec.bookId AS bookId, rec.name AS name, count(DISTINCT e2) * 0.5 AS score
        ORDER BY score DESC
        LIMIT $limit
    """)
    List<Map<String, Object>> recommendPropagation(
            @Param("likedBookIds") List<Integer> likedBookIds,
            @Param("excludedBookIds") List<Integer> excludedBookIds,
            @Param("limit") int limit
    );

    @Query("""
        MATCH (b:Book {bookId: $bookId})-[:WRITTEN_BY|BELONGS_TO|ABOUT|PUBLISHED_BY|WRITTEN_IN]->(entity)<-[:WRITTEN_BY|BELONGS_TO|ABOUT|PUBLISHED_BY|WRITTEN_IN]-(rec:Book)
        WHERE rec.bookId <> $bookId
        RETURN DISTINCT rec.bookId AS bookId, rec.name AS name, count(DISTINCT entity) AS score
        ORDER BY score DESC
        LIMIT $limit
    """)
    List<Map<String, Object>> findRelatedBooks(
            @Param("bookId") Integer bookId,
            @Param("limit") int limit
    );

    @Query("""
        MATCH (n)-[r]->(m)
        RETURN labels(n)[0] AS sourceType,
               n.name AS sourceName,
               CASE WHEN n.bookId IS NOT NULL THEN n.bookId ELSE -1 END AS sourceBookId,
               type(r) AS relationType,
               r.weight AS weight,
               labels(m)[0] AS targetType,
               m.name AS targetName
        LIMIT 500
    """)
    List<Map<String, Object>> getFullGraph();

    @Query("""
        MATCH (b:Book {bookId: $bookId})-[r]->(m)
        RETURN labels(b)[0] AS sourceType, b.name AS sourceName, b.bookId AS sourceBookId,
               type(r) AS relationType, r.weight AS weight,
               labels(m)[0] AS targetType, m.name AS targetName
        UNION
        MATCH (b:Book {bookId: $bookId})-[r1]->(e)-[r2]->(m)
        WHERE labels(m)[0] IN ['Author', 'Category', 'Theme', 'Publisher', 'Era']
        RETURN labels(e)[0] AS sourceType, e.name AS sourceName, -1 AS sourceBookId,
               type(r2) AS relationType, r2.weight AS weight,
               labels(m)[0] AS targetType, m.name AS targetName
    """)
    List<Map<String, Object>> getBookGraph(@Param("bookId") Integer bookId);
}
