package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;


/**
 * <p>
 * 实体类
 * </p>
 */

@Data
@TableName(value = "cart")
public class Cart {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private Integer bookId;

    private Integer num;

    private Integer userId;

    @TableField(exist = false)
    private String bookName;

    @TableField(exist = false)
    private BigDecimal bookPrice;

    @TableField(exist = false)
    private String bookImg;

    @TableField(exist = false)
    private String bookInfo;

    @TableField(exist = false)
    private Integer bookInventory;

}