package com.example.springboot.controller;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.config.interceptor.AuthAccess;
import com.example.springboot.entity.Account;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.BookCategory;
import com.example.springboot.entity.UserBehavior;
import com.example.springboot.service.IBookCategoryService;
import com.example.springboot.service.IBookService;
import com.example.springboot.service.IUserBehaviorService;
import com.example.springboot.service.KgRecommendService;
import com.example.springboot.utils.TokenUtils;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/book")
public class BookController {

    @Resource
    private IBookService bookService;
    @Resource
    private IBookCategoryService bookCategoryService;
    @Resource
    private IUserBehaviorService userBehaviorService;
    @Resource
    private KgRecommendService kgRecommendService;

    @PostMapping
    public Result save(@RequestBody Book book) {
        return Result.success(bookService.saveOrUpdate(book));
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        return Result.success(bookService.removeById(id));
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(bookService.removeByIds(ids));
    }

    @AuthAccess
    @GetMapping
    public Result findAll() {
        return Result.success(bookService.list());
    }

    @AuthAccess
    @GetMapping("/{id}")
    public Result findOne(@PathVariable Integer id) {
        Book book = bookService.getById(id);
        recordBehavior(id, "view", 1);
        return Result.success(book);
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum,
                           @RequestParam Integer pageSize,
                           @RequestParam(defaultValue = "") String keyword) {

        LambdaQueryWrapper<Book> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Book::getId);

        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(Book::getName, keyword);
        }

        return Result.success(bookService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }

    @AuthAccess
    @GetMapping("/front/page")
    public Result findFrontPage(@RequestParam(defaultValue = "") String keyword,
                                @RequestParam(defaultValue = "0") Integer categoryId,
                                @RequestParam(defaultValue = "all") String sortBy,
                                @RequestParam Integer pageNum,
                                @RequestParam Integer pageSize) {

        LambdaQueryWrapper<Book> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Book::getStatus, true);
        
        if (StrUtil.equals(sortBy, "all")) {
            queryWrapper.orderByDesc(Book::getId);
        } else if (StrUtil.equals(sortBy, "new")) {
            queryWrapper.orderByDesc(Book::getCreateTime);
        } else if (StrUtil.equals(sortBy, "sales")) {
            queryWrapper.orderByDesc(Book::getSales);
        } else if (StrUtil.equals(sortBy, "rating")) {
            queryWrapper.orderByDesc(Book::getRating);
        }

        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(Book::getName, keyword);
        }

        if (categoryId != 0) {
            queryWrapper.eq(Book::getCategoryId, categoryId);
        }

        return Result.success(bookService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }

    @AuthAccess
    @GetMapping("/recommend")
    public Result recommend() {
        Account currentUser = TokenUtils.getCurrentUser();
        if (currentUser == null) {
            return Result.success(kgRecommendService.getRandomBooks(10));
        }
        return Result.success(kgRecommendService.recommend(currentUser.getId(), 10));
    }

    @AuthAccess
    @GetMapping("/category")
    public Result getCategories() {
        List<BookCategory> categories = bookCategoryService.list();
        
        // 为每个分类加载图书列表
        for (BookCategory category : categories) {
            LambdaQueryWrapper<Book> bookWrapper = new LambdaQueryWrapper<>();
            bookWrapper.eq(Book::getCategoryId, category.getId());
            bookWrapper.eq(Book::getStatus, true);
            bookWrapper.last("LIMIT 6");
            List<Book> books = bookService.list(bookWrapper);
            category.setBookList(books);
        }
        
        return Result.success(categories);
    }

    @AuthAccess
    @GetMapping("/category/{parentId}")
    public Result getCategoriesByParent(@PathVariable Integer parentId) {
        LambdaQueryWrapper<BookCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BookCategory::getParentId, parentId);
        return Result.success(bookCategoryService.list(wrapper));
    }

    @PostMapping("/category")
    public Result saveCategory(@RequestBody BookCategory category) {
        return Result.success(bookCategoryService.saveOrUpdate(category));
    }

    @DeleteMapping("/category/{id}")
    public Result deleteCategory(@PathVariable Integer id) {
        return Result.success(bookCategoryService.removeById(id));
    }

    @PostMapping("/category/del/batch")
    public Result deleteCategoryBatch(@RequestBody List<Integer> ids) {
        return Result.success(bookCategoryService.removeByIds(ids));
    }

    @GetMapping("/category/page")
    public Result findCategoryPage(@RequestParam Integer pageNum,
                                   @RequestParam Integer pageSize,
                                   @RequestParam(defaultValue = "") String keyword) {
        LambdaQueryWrapper<BookCategory> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(BookCategory::getId);
        if (StrUtil.isNotBlank(keyword)) {
            queryWrapper.like(BookCategory::getName, keyword);
        }
        return Result.success(bookCategoryService.page(new Page<>(pageNum, pageSize), queryWrapper));
    }

    private <T> List<T> getRandomItems(int num, List<T> items) {
        List<T> list = new ArrayList<>();
        Set<Integer> indexes = new HashSet<>();
        
        while (indexes.size() < num && indexes.size() < items.size()) {
            int index = new Random().nextInt(items.size());
            if (indexes.add(index)) {
                list.add(items.get(index));
            }
        }
        return list;
    }

    private List<Book> getRandomBooks(int num, List<Book> books) {
        return getRandomItems(num, books);
    }

    private void recordBehavior(Integer bookId, String behaviorType, Integer behaviorValue) {
        Account currentUser = TokenUtils.getCurrentUser();
        if (currentUser == null) return;

        LambdaQueryWrapper<UserBehavior> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserBehavior::getUserId, currentUser.getId())
               .eq(UserBehavior::getBookId, bookId)
               .eq(UserBehavior::getBehaviorType, behaviorType);
        UserBehavior existing = userBehaviorService.getOne(wrapper);

        if (existing != null) {
            existing.setBehaviorValue(existing.getBehaviorValue() + behaviorValue);
            userBehaviorService.updateById(existing);
        } else {
            UserBehavior behavior = new UserBehavior();
            behavior.setUserId(currentUser.getId());
            behavior.setBookId(bookId);
            behavior.setBehaviorType(behaviorType);
            behavior.setBehaviorValue(behaviorValue);
            userBehaviorService.save(behavior);
        }
    }
}