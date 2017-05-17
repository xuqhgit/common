package com.anchor.ms.auth.mapper;


import com.anchor.core.common.base.BaseMapper;
import com.anchor.ms.auth.model.User;


/**
 * @ClassName: UserMapper
 * @Description: 
 * @author anchor
 * @date 2017-05-14 19:25:09
 * @since version 1.0
 */
public interface UserMapper extends BaseMapper<User,Long> {


    public User findUserByUsername(String username);
}