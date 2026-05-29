package com.example.springboot.controller;

import cn.hutool.core.collection.CollectionUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.springboot.common.Result;
import com.example.springboot.entity.Account;
import com.example.springboot.entity.Book;
import com.example.springboot.entity.Collect;
import com.example.springboot.entity.*;
import com.example.springboot.service.IBookService;
import com.example.springboot.service.ICollectService;
import com.example.springboot.service.IUserBehaviorService;
import com.example.springboot.service.IUserService;
import com.example.springboot.utils.TokenUtils;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * <p>
 * 前端控制器
 * </p>
 */
@RestController
@RequestMapping("/collect")
public class CollectController {

    @Resource
    private ICollectService collectService;
    @Resource
    private IUserBehaviorService userBehaviorService;
    @Resource
    private IBookService bookService;
    @Resource
    private IUserService userService;

    @PostMapping
    public Result save(@RequestBody Collect collect) {
        Account currentUser = TokenUtils.getCurrentUser();
        try {
            collect.setUserId(currentUser.getId());
            collectService.saveOrUpdate(collect);
            recordBehavior(currentUser.getId(), collect.getBookId(), "collect", 3);
        }catch (Exception e){
            LambdaQueryWrapper<Collect> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Collect::getUserId,currentUser.getId());
            wrapper.eq(Collect::getBookId,collect.getBookId());
            collectService.remove(wrapper);
            removeBehavior(currentUser.getId(), collect.getBookId(), "collect");
            return Result.error("605","已取消收藏");
        }
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result delete(@PathVariable Integer id) {
        Account currentUser = TokenUtils.getCurrentUser();
        LambdaQueryWrapper<Collect> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Collect::getUserId,currentUser.getId());
        wrapper.eq(Collect::getBookId,id);
        collectService.remove(wrapper);
        removeBehavior(currentUser.getId(), id, "collect");
        return Result.success();
    }

    @GetMapping("/check/{bookId}")
    public Result checkCollected(@PathVariable Integer bookId) {
        Account currentUser = TokenUtils.getCurrentUser();
        if (currentUser == null) {
            return Result.success(false);
        }
        LambdaQueryWrapper<Collect> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Collect::getUserId, currentUser.getId());
        wrapper.eq(Collect::getBookId, bookId);
        return Result.success(collectService.count(wrapper) > 0);
    }

    @PostMapping("/del/batch")
    public Result deleteBatch(@RequestBody List<Integer> ids) {
        return Result.success(collectService.removeByIds(ids));
    }

    @GetMapping("/page")
    public Result findPage(@RequestParam Integer pageNum,
                           @RequestParam Integer pageSize,
                           @RequestParam(defaultValue = "") String keyword) {

        Set<Integer> existingUserIds = userService.list().stream()
                .map(User::getId)
                .collect(Collectors.toSet());

        LambdaQueryWrapper<Collect> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.orderByDesc(Collect::getId);

        if (StrUtil.isNotBlank(keyword)) {
            List<Integer> matchedUserIds = userService.list().stream()
                    .filter(u -> u.getNickname() != null && u.getNickname().contains(keyword))
                    .map(User::getId)
                    .collect(Collectors.toList());
            if (matchedUserIds.isEmpty()) {
                Page<Collect> emptyPage = new Page<>(pageNum, pageSize);
                emptyPage.setRecords(new ArrayList<>());
                emptyPage.setTotal(0);
                return Result.success(emptyPage);
            }
            queryWrapper.in(Collect::getUserId, matchedUserIds);
        } else {
            queryWrapper.in(Collect::getUserId, existingUserIds);
        }

        Page<Collect> page = collectService.page(new Page<>(pageNum, pageSize), queryWrapper);
        List<Collect> records = page.getRecords();

        if (CollectionUtil.isNotEmpty(records)) {
            Map<Integer, String> userNameMap = new HashMap<>();
            for (Integer uid : records.stream().map(Collect::getUserId).distinct().collect(Collectors.toList())) {
                User user = userService.getById(uid);
                if (user != null) {
                    userNameMap.put(uid, user.getNickname());
                }
            }

            List<Integer> bookIds = records.stream().map(Collect::getBookId).collect(Collectors.toList());
            Map<Integer, Book> bookMap = bookService.listByIds(bookIds).stream()
                    .collect(Collectors.toMap(Book::getId, b -> b, (a, b) -> a));

            for (Collect collect : records) {
                collect.setUserName(userNameMap.getOrDefault(collect.getUserId(), "用户" + collect.getUserId()));
                Book book = bookMap.get(collect.getBookId());
                if (book != null) {
                    collect.setBookName(book.getName());
                    collect.setBookImg(book.getImg());
                    collect.setBookPrice(book.getPrice());
                }
            }
        }

        page.setRecords(records);
        return Result.success(page);
    }

    private void recordBehavior(Integer userId, Integer bookId, String behaviorType, Integer behaviorValue) {
        Account currentUser = TokenUtils.getCurrentUser();
        if (currentUser == null || !"ROLE_USER".equals(currentUser.getRole())) return;
        LambdaQueryWrapper<UserBehavior> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserBehavior::getUserId, userId)
               .eq(UserBehavior::getBookId, bookId)
               .eq(UserBehavior::getBehaviorType, behaviorType);
        UserBehavior existing = userBehaviorService.getOne(wrapper);

        if (existing != null) {
            existing.setBehaviorValue(existing.getBehaviorValue() + behaviorValue);
            userBehaviorService.updateById(existing);
        } else {
            UserBehavior behavior = new UserBehavior();
            behavior.setUserId(userId);
            behavior.setBookId(bookId);
            behavior.setBehaviorType(behaviorType);
            behavior.setBehaviorValue(behaviorValue);
            userBehaviorService.save(behavior);
        }
    }

    private void removeBehavior(Integer userId, Integer bookId, String behaviorType) {
        LambdaQueryWrapper<UserBehavior> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserBehavior::getUserId, userId)
               .eq(UserBehavior::getBookId, bookId)
               .eq(UserBehavior::getBehaviorType, behaviorType);
        userBehaviorService.remove(wrapper);
    }
}