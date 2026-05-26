// ========================================
// Neo4j 知识图谱数据导入脚本
// 使用方法：逐段复制到 Neo4j Browser 中执行
// CSV文件需复制到 Neo4j import 目录
// ========================================

// ===== 第一步：清空数据库 =====
MATCH (n) DETACH DELETE n;

// ===== 第二步：创建约束 =====
CREATE CONSTRAINT book_id FOR (b:Book) REQUIRE b.bookId IS UNIQUE;
CREATE CONSTRAINT author_id FOR (a:Author) REQUIRE a.entityId IS UNIQUE;
CREATE CONSTRAINT category_id FOR (c:Category) REQUIRE c.entityId IS UNIQUE;
CREATE CONSTRAINT theme_id FOR (t:Theme) REQUIRE t.entityId IS UNIQUE;
CREATE CONSTRAINT publisher_id FOR (p:Publisher) REQUIRE p.entityId IS UNIQUE;
CREATE CONSTRAINT era_id FOR (e:Era) REQUIRE e.entityId IS UNIQUE;

// ===== 第三步：导入节点 =====

// Book 节点
LOAD CSV WITH HEADERS FROM 'file:///books.csv' AS row
CREATE (:Book {
  bookId: toInteger(row.bookId),
  name: row.name,
  price: toFloat(row.price),
  sales: toInteger(row.sales),
  rating: toFloat(row.rating)
});

// Author 节点
LOAD CSV WITH HEADERS FROM 'file:///authors.csv' AS row
CREATE (:Author {
  entityId: toInteger(row.entityId),
  name: row.name,
  description: row.description
});

// Category 节点
LOAD CSV WITH HEADERS FROM 'file:///categories.csv' AS row
CREATE (:Category {
  entityId: toInteger(row.entityId),
  name: row.name,
  description: row.description
});

// Theme 节点
LOAD CSV WITH HEADERS FROM 'file:///themes.csv' AS row
CREATE (:Theme {
  entityId: toInteger(row.entityId),
  name: row.name,
  description: row.description
});

// Publisher 节点
LOAD CSV WITH HEADERS FROM 'file:///publishers.csv' AS row
CREATE (:Publisher {
  entityId: toInteger(row.entityId),
  name: row.name,
  description: row.description
});

// Era 节点
LOAD CSV WITH HEADERS FROM 'file:///eras.csv' AS row
CREATE (:Era {
  entityId: toInteger(row.entityId),
  name: row.name,
  description: row.description
});

// ===== 第四步：导入图书-实体关系 =====

// Book -[WRITTEN_BY]-> Author
LOAD CSV WITH HEADERS FROM 'file:///book_written_by.csv' AS row
MATCH (b:Book {bookId: toInteger(row.bookId)})
MATCH (a:Author {entityId: toInteger(row.entityId)})
CREATE (b)-[:WRITTEN_BY]->(a);

// Book -[BELONGS_TO]-> Category
LOAD CSV WITH HEADERS FROM 'file:///book_belongs_to.csv' AS row
MATCH (b:Book {bookId: toInteger(row.bookId)})
MATCH (c:Category {entityId: toInteger(row.entityId)})
CREATE (b)-[:BELONGS_TO]->(c);

// Book -[ABOUT]-> Theme
LOAD CSV WITH HEADERS FROM 'file:///book_about.csv' AS row
MATCH (b:Book {bookId: toInteger(row.bookId)})
MATCH (t:Theme {entityId: toInteger(row.entityId)})
CREATE (b)-[:ABOUT]->(t);

// Book -[PUBLISHED_BY]-> Publisher
LOAD CSV WITH HEADERS FROM 'file:///book_published_by.csv' AS row
MATCH (b:Book {bookId: toInteger(row.bookId)})
MATCH (p:Publisher {entityId: toInteger(row.entityId)})
CREATE (b)-[:PUBLISHED_BY]->(p);

// Book -[WRITTEN_IN]-> Era
LOAD CSV WITH HEADERS FROM 'file:///book_written_in.csv' AS row
MATCH (b:Book {bookId: toInteger(row.bookId)})
MATCH (e:Era {entityId: toInteger(row.entityId)})
CREATE (b)-[:WRITTEN_IN]->(e);

// ===== 第五步：导入实体间关系 =====

// Author -[SIMILAR_TO]-> Author
LOAD CSV WITH HEADERS FROM 'file:///author_similar.csv' AS row
MATCH (s:Author {entityId: toInteger(row.sourceId)})
MATCH (t:Author {entityId: toInteger(row.targetId)})
CREATE (s)-[:SIMILAR_TO {weight: toFloat(row.weight)}]->(t);

// Category -[RELATED_TO]-> Category
LOAD CSV WITH HEADERS FROM 'file:///category_related.csv' AS row
MATCH (s:Category {entityId: toInteger(row.sourceId)})
MATCH (t:Category {entityId: toInteger(row.targetId)})
CREATE (s)-[:RELATED_TO {weight: toFloat(row.weight)}]->(t);

// Theme -[RELATED_TO]-> Theme
LOAD CSV WITH HEADERS FROM 'file:///theme_related.csv' AS row
MATCH (s:Theme {entityId: toInteger(row.sourceId)})
MATCH (t:Theme {entityId: toInteger(row.targetId)})
CREATE (s)-[:RELATED_TO {weight: toFloat(row.weight)}]->(t);

// Publisher -[SIMILAR_TO]-> Publisher
LOAD CSV WITH HEADERS FROM 'file:///publisher_similar.csv' AS row
MATCH (s:Publisher {entityId: toInteger(row.sourceId)})
MATCH (t:Publisher {entityId: toInteger(row.targetId)})
CREATE (s)-[:SIMILAR_TO {weight: toFloat(row.weight)}]->(t);

// Era -[TIME_SEQUENCE]-> Era
LOAD CSV WITH HEADERS FROM 'file:///era_sequence.csv' AS row
MATCH (s:Era {entityId: toInteger(row.sourceId)})
MATCH (t:Era {entityId: toInteger(row.targetId)})
CREATE (s)-[:TIME_SEQUENCE {weight: toFloat(row.weight)}]->(t);


// ===== 第六步：验证导入结果 =====

// 统计节点数量
MATCH (n) RETURN labels(n)[0] AS 节点类型, count(n) AS 数量 ORDER BY 节点类型;

// 统计关系数量
MATCH ()-[r]->() RETURN type(r) AS 关系类型, count(r) AS 数量 ORDER BY 关系类型;
