package com.example.springboot.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.springboot.entity.UserBehavior;
import com.example.springboot.mapper.UserBehaviorMapper;
import com.example.springboot.service.IUserBehaviorService;
import org.springframework.stereotype.Service;

@Service
public class UserBehaviorServiceImpl extends ServiceImpl<UserBehaviorMapper, UserBehavior> implements IUserBehaviorService {
    
}