// ========================================
// 补齐 Neo4j 计算机/科技类节点与关系
// 复制到 Neo4j Browser 逐段执行
// ========================================

// ===== 第一步：创建科技分类节点 =====
CREATE (:Category { entityId: 69, name: '科技', description: '科学与技术类图书' });
CREATE (:Category { entityId: 70, name: '计算机科学', description: '计算机与编程类图书' });
CREATE (:Category { entityId: 71, name: '人工智能', description: '人工智能与数据科学类图书' });

// ===== 第二步：建立分类间关联关系 =====
MATCH (c1:Category {entityId: 69}), (c2:Category {entityId: 70})
CREATE (c1)-[:RELATED_TO {weight: 1.0}]->(c2);

MATCH (c1:Category {entityId: 70}), (c2:Category {entityId: 71})
CREATE (c1)-[:RELATED_TO {weight: 1.0}]->(c2);

// AI 主题关联
MATCH (c:Category {entityId: 71}), (t:Theme {entityId: 10})
CREATE (c)-[:RELATED_TO {weight: 0.8}]->(t);

MATCH (c:Category {entityId: 71}), (t:Theme {entityId: 11})
CREATE (c)-[:RELATED_TO {weight: 0.8}]->(t);

// ===== 第三步：AI类书 BELONGS_TO 人工智能(71) =====
MATCH (b:Book {bookId: 7}),  (c:Category {entityId: 71}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 8}),  (c:Category {entityId: 71}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 47}), (c:Category {entityId: 71}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 48}), (c:Category {entityId: 71}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 49}), (c:Category {entityId: 71}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 50}), (c:Category {entityId: 71}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 51}), (c:Category {entityId: 71}) CREATE (b)-[:BELONGS_TO]->(c);

// ===== 第四步：计算机类书 BELONGS_TO 计算机科学(70) =====
MATCH (b:Book {bookId: 35}), (c:Category {entityId: 70}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 36}), (c:Category {entityId: 70}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 37}), (c:Category {entityId: 70}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 38}), (c:Category {entityId: 70}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 39}), (c:Category {entityId: 70}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 40}), (c:Category {entityId: 70}) CREATE (b)-[:BELONGS_TO]->(c);

// ===== 第五步：科普类书 BELONGS_TO 科技(69) =====
MATCH (b:Book {bookId: 29}), (c:Category {entityId: 69}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 30}), (c:Category {entityId: 69}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 31}), (c:Category {entityId: 69}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 32}), (c:Category {entityId: 69}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 33}), (c:Category {entityId: 69}) CREATE (b)-[:BELONGS_TO]->(c);
MATCH (b:Book {bookId: 34}), (c:Category {entityId: 69}) CREATE (b)-[:BELONGS_TO]->(c);

// ===== 验证 =====
MATCH (b:Book)-[:BELONGS_TO]->(c:Category)
WHERE c.entityId IN [69, 70, 71]
RETURN b.bookId, b.name, c.entityId, c.name ORDER BY c.entityId, b.bookId;
