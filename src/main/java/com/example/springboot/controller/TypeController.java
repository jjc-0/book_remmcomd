package com.example.springboot.controller;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.config.interceptor.AuthAccess;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.Type;
import com.example.springboot.service.IBookService;
import com.example.springboot.service.ITypeService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * <p>
 * 前端控制器
 * </p>
 */
@RestController
@RequestMapping("/type")
public class TypeController {

    @Resource
    private ITypeService typeService;
    @Resource
    private IBookService bookService;

    @PostMapping
    public Result save(@RequestBody Type type) {
        return Result.success(typeService.saveOrUpdate(type));
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        return Result.success(typeService.removeById(id));
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(typeService.removeByIds(ids));
    }

    @AuthAccess
    @GetMapping("/front")
    public Result findFront() {
        return Result.success(typeService.list().stream().limit(6).collect(Collectors.toList()));
    }

    @AuthAccess
    @GetMapping("/praise")
    public Result findPraise() {
        LambdaQueryWrapper<Type> wrapper = new LambdaQueryWrapper<>();
        // 所有推荐的分类
        wrapper.eq(Type::getStatus, true);
        List<Type> typeList = typeService.list(wrapper);
        // 提取分类 ID
        List<Integer> typeIds = typeList.stream().map(Type::getId).collect(Collectors.toList());
        // 查询分类下上架图书
        LambdaQueryWrapper<Book> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Book::getStatus,true);
        queryWrapper.in(Book::getCategoryId, typeIds);
        Map<Integer, List<Book>> map = bookService.list(queryWrapper).stream().collect(Collectors.groupingBy(Book::getCategoryId));
        for (Type type : typeList) {
            if (map.containsKey(type.getId())){
                type.setBookList(map.get(type.getId()).stream().limit(4).collect(Collectors.toList()));
            }else {
                type.setBookList(new ArrayList<>());
            }
        }
        return Result.success(typeList);
    }

    @AuthAccess
    @GetMapping
    public Result findAll() {
        return Result.success(typeService.list());
    }

    @AuthAccess
    @GetMapping("/{id}")
    public Result findOne(@PathVariable Integer id) {
        return Result.success(typeService.getById(id));
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum,
                           @RequestParam Integer pageSize,
                           @RequestParam(defaultValue = "") String keyword) {

        LambdaQueryWrapper<Type> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Type::getId);

        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(Type::getName, keyword);
        }

        return Result.success(typeService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }

}