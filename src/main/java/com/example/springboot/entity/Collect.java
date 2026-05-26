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
@TableName(value = "collect")
public class Collect {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;

    private Integer userId;

    private Integer bookId;

    @TableField(exist = false)
    private String bookName;

    @TableField(exist = false)
    private String bookImg;

    @TableField(exist = false)
    private BigDecimal bookPrice;

    @TableField(exist = false)
    private String userName;

}