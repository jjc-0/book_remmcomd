package com.example.springboot.neo4j.node;

import lombok.Data;
import org.springframework.data.neo4j.core.schema.Id;
import org.springframework.data.neo4j.core.schema.Node;
import org.springframework.data.neo4j.core.schema.Property;

@Data
@Node("Book")
public class BookNode {

    @Id
    private Long id;

    @Property("bookId")
    private Integer bookId;

    private String name;

    private Double price;

    private Integer sales;

    private Double rating;
}
