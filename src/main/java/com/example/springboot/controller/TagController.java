package com.example.springboot.controller;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.config.interceptor.AuthAccess;
import com.example.springboot.entity.Tag;
import com.example.springboot.service.ITagService;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * <p>
 * 前端控制器
 * </p>
 */
@RestController
@RequestMapping("/tag")
public class TagController {

    @Resource
    private ITagService tagService;

    @PostMapping
    public Result save(@RequestBody Tag tag) {
        return Result.success(tagService.saveOrUpdate(tag));
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        return Result.success(tagService.removeById(id));
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(tagService.removeByIds(ids));
    }

    @AuthAccess
    @GetMapping
    public Result findAll() {
        return Result.success(tagService.list());
    }

    @GetMapping("/{id}")
    public Result findOne(@PathVariable Integer id) {
        return Result.success(tagService.getById(id));
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum,
                           @RequestParam Integer pageSize,
                           @RequestParam(defaultValue = "") String keyword) {

        LambdaQueryWrapper<Tag> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Tag::getId);

        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(Tag::getName, keyword);
        }

        return Result.success(tagService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }

}

