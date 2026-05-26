package com.example.springboot.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.springboot.entity.KgRelation;
import com.example.springboot.mapper.KgRelationMapper;
import com.example.springboot.service.IKgRelationService;
import org.springframework.stereotype.Service;

@Service
public class KgRelationServiceImpl extends ServiceImpl<KgRelationMapper, KgRelation> implements IKgRelationService {
    
}