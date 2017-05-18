package com.anchor.ms.auth.controller;

import com.anchor.core.common.base.BaseController;
import com.anchor.core.common.dto.QueryFilter;
import com.anchor.core.common.dto.Result;
import com.anchor.core.common.dto.ResultGrid;
import com.anchor.core.common.dto.ResultObject;
import com.github.pagehelper.PageInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.anchor.ms.auth.service.IDictService;
import com.anchor.ms.auth.model.Dict;

/**
 * @ClassName: DictController
 * @Description: 
 * @author xuqh
 * @date 2017-05-18 14:36:19
 * @since version 1.0
 */
@Controller
@RequestMapping("dict")
public class DictController extends BaseController{

    @Autowired
	private IDictService dictService;

	public final static String PATH_INDEX="dict/index";
    public final static String PATH_ADD_INDEX="dict/add";
    public final static String PATH_EDIT_INDEX="dict/edit";

     /**
     * @return
     */
    @RequestMapping(value="",method = RequestMethod.GET)
    public String index(){
        return PATH_INDEX;
    }

    @RequestMapping(value="add",method = RequestMethod.GET)
    @ResponseBody
    public String add(){

        return PATH_ADD_INDEX;
    }
    @RequestMapping(value="add",method = RequestMethod.POST)
    @ResponseBody
    public Result add(Dict dict){
        try{
            dictService.insert(dict);
        }catch (Exception e){
            new Result().error("添加失败：" + e.getMessage());
        }
        return new Result().success("添加成功");
    }


    @RequestMapping(value="update/{id}",method = RequestMethod.GET)
    @ResponseBody
    public String edit(@PathVariable("id") long id){
        return PATH_EDIT_INDEX;
    }

    @RequestMapping(value="update/{id}",method = RequestMethod.POST)
    @ResponseBody
    public Result edit(Dict dict){
        try{
            dictService.update(dict);
        }catch (Exception e){
            new Result().error("修改失败：" + e.getMessage());
        }
        return new Result().success("修改成功");
    }

    @RequestMapping(value="get/{id}")
    @ResponseBody
    public Result get(@PathVariable("id") long id){
        try{
            return new ResultObject().setData(dictService.get(id));
        }catch (Exception e){
            e.printStackTrace();
            return new Result().error("获取失败：" + e.getMessage());
        }
    }

    @RequestMapping(value="list")
    @ResponseBody
    public Result list(){
        try{
            return new ResultObject().setData(dictService.getList());
        }catch (Exception e){
            return new Result().error("获取失败：" + e.getMessage());
        }
    }

    @RequestMapping(value="grid")
    @ResponseBody
    public Result grid(QueryFilter queryFilter){
        try{
            PageInfo<Dict> pageInfo = dictService.getPageInfo(queryFilter);
            ResultGrid resultGrid = new ResultGrid<Dict>();
            resultGrid.setRows(pageInfo.getList());
            resultGrid.setTotal(pageInfo.getTotal());
            return resultGrid;
        }catch (Exception e){
            return new Result().error("获取列表失败：" + e.getMessage());
        }
    }

}

