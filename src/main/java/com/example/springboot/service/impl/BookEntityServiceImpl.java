package com.example.springboot.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.springboot.entity.BookEntity;
import com.example.springboot.mapper.BookEntityMapper;
import com.example.springboot.service.IBookEntityService;
import org.springframework.stereotype.Service;

@Service
public class BookEntityServiceImpl extends ServiceImpl<BookEntityMapper, BookEntity> implements IBookEntityService {
    
}