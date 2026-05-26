package com.example.springboot.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.springboot.entity.BookCategory;
import com.example.springboot.mapper.BookCategoryMapper;
import com.example.springboot.service.IBookCategoryService;
import org.springframework.stereotype.Service;

@Service
public class BookCategoryServiceImpl extends ServiceImpl<BookCategoryMapper, BookCategory> implements IBookCategoryService {
    
}