package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("book_category")
public class BookCategory {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;
    private String name;
    private Integer parentId;
    private String description;
    private String img;
    private Boolean status;
    
    @TableField(exist = false)
    private List<Book> bookList;
}