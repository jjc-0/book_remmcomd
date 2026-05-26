package com.example.springboot.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.springboot.entity.KgEntity;
import com.example.springboot.mapper.KgEntityMapper;
import com.example.springboot.service.IKgEntityService;
import org.springframework.stereotype.Service;

@Service
public class KgEntityServiceImpl extends ServiceImpl<KgEntityMapper, KgEntity> implements IKgEntityService {
    
}