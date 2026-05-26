package com.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("kg_relation")
public class KgRelation {

    @TableId(value = "id", type = IdType.AUTO)
    private Integer id;
    private Integer sourceId;
    private Integer targetId;
    private String relationType;
    private BigDecimal weight;
    private LocalDateTime createTime;

}