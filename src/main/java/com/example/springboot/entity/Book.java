package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("book")
public class Book {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;
    private String name;
    private String author;
    private String publisher;
    private LocalDate publishDate;
    private String isbn;
    private BigDecimal price;
    private Integer categoryId;
    private String description;
    private String content;
    private String img;
    private String imgList;
    private Integer inventory;
    private Integer sales;
    private BigDecimal rating;
    private Boolean status;
    private LocalDateTime createTime;

}