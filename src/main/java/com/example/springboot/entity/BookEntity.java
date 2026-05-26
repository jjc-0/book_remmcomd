package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("book_entity")
public class BookEntity {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;
    private Integer bookId;
    private Integer entityId;
    private String relationType;
    private LocalDateTime createTime;

}