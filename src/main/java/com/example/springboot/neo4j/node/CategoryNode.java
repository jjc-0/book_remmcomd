package com.example.springboot.neo4j.node;

import lombok.Data;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;
import org.springframework.data.neo4j.core.schema.Property;

@Data
@Node("Category")
public class CategoryNode {

    @Id
    private Long id;

    @Property("entityId")
    private Integer entityId;

    private String name;

    private String description;
}
