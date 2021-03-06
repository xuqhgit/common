package com.anchor.ms.auth.model;

import com.anchor.core.common.tree.ITree;

import java.util.LinkedList;
import java.util.List;

/**
 * @author xuqh
 * @ClassName: DictItemTree
 * @Description:
 * @date 2017/11/15 17:50
 * @since 1.0.1
 */
public class DictItemTree extends  DictItem implements ITree{
    private List<DictItemTree> children = new LinkedList<>();
    public List getChildren() {
        return children;
    }


    public void setChildren(List children) {
        this.children = children;
    }
}
