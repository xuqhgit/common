<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<html>
<head>
    <title>角色管理</title>
    <%@include file="../../common.jsp" %>
    <link rel="stylesheet" href="/static/bootstrap/ext/treeview/bootstrap-treeview.css">
</head>
<body>


<div class="container-fluid ">
    <h3>角色列表</h3>

    <div class="row-fluid ">
        <div class="span12 search-form">
            <form id="form" class="form-inline" role="form">
                <div class="form-group">
                    <label >角色编码：</label>
                    <input class="form-control" id="code" name="code" type="text" placeholder="角色编码"/>
                </div>
                <div class="form-group">
                    <label  >状态：</label>
                    <select id="roleStatus" class="form-control" name="status"></select>
                </div>
                <div class="form-group">
                    <label >名称：</label>
                    <input class="form-control" id="name" name="name" type="text" placeholder="名称"/>
                </div>
                <div class="form-group" >
                    <button type="button" class="btn btn-primary" id="search"
                            data-toggle="button"><span class="glyphicon glyphicon-search"></span>搜索
                    </button>
                </div>
            </form>
        </div>
        <div class="span12">
            <div id="toolbar" class="btn-group">

                <a role="button" id="addRole" class="btn btn-default">
                    <i class="glyphicon glyphicon-plus"></i>添加角色
                </a>


                <shiro:hasPermission name="role:deleteBatch">
                    <a href="#addRoleModal" role="button" class="btn btn-default" id="deleteBatchButton">
                        <i class="glyphicon glyphicon-trash"></i>批量删除
                    </a>
                </shiro:hasPermission>
            </div>
            <table id="roleTable"></table>
        </div>
    </div>
</div>


<%@include file="../../common_script.jsp" %>
<script src="/static/bootstrap/ext/treeview/bootstrap-treeview.js"></script>
<script>

    var bt;
    var roleValidConfig = {

        code: {
            rule: {
                required: true,
                codeValid: true
            },
            message: {
                required: '请输入角色编码'
            }
        },
        name: {
            rule: {
                required: true,
                nameValid: true
            },
            message: {
                required: '请输入名称'
            }
        }
    };
    $(function () {

        jQuery.validator.addMethod("codeValid", function (value, element) {
            var p = /[a-zA-Z0-9_-]{1,16}$/;
            return p.test(value);
        }, "请输入英文大小写、数字、下划线、减号1到16位字符");
        jQuery.validator.addMethod("nameValid", function (value, element) {
            var p = /^.{1,16}$/;
            return p.test(value);
        }, "请输入1到16位字符");
        var statusDict = anchor.getDict("STATUS");
        anchor.createFromGroupSelect("roleStatus",statusDict,"",['','==选择状态==']);
        var params = {
            url: '/role/grid',
            queryParams: function (params) {
                var temp = {
                    pageSize: params.limit,   //页面大小
                    pageNum: params.offset / params.limit + 1,  //页码
                    sort: params.sort,  //排序列名
                    sortOrder: params.order//排位命令（desc，asc）
                };
                return $.extend(temp, $('#form').serializeObject());
            },
            columns: [
                {checkbox: true},
                {title: 'ID', field: 'id', align: 'center', width: '100',visible: false},
                {title: '角色编码', field: 'code', align: 'center', sortable: true, width: '100'},
                {title: '名称', field: 'name', align: 'center', width: '100'},
                {
                    title: '状态',
                    field: 'status',
                    align: 'center',
                    sortable: true,
                    width: '80',
                    formatter: function (index, row) {
                        return anchor.getDictItemTextByValue(statusDict.list, row.status);
                    }
                },
                {title: '创建时间', field: 'createTime', align: 'center', sortable: true, width: '100'},
                {title: '更新时间', field: 'updateTime', align: 'center', sortable: true, width: '100'},
                {
                    title: '操作', field: 'opt', align: 'center', width: '120', formatter: function (index, row) {
                    var opts = "";
                    <shiro:hasPermission name="auth:role:edit">
                    opts += "<a href='javascript:void(0);' class='btn btn-xs' onclick=\"editRole(\'" + row.id + "\')\">编辑</a>|";
                    </shiro:hasPermission>
                    <shiro:hasPermission name="auth:role:setPermission">
                    opts += "<a href='javascript:void(0);' class='btn btn-xs' onclick=\"setRolePermission(\'" + row.id + "\')\">权限设置</a>";
                    </shiro:hasPermission>
                    return opts;
                }
                }
            ]
        };
        bt = anchor.bootstrapTable("roleTable", params);
        $('#search').click(function () {
            bt.bootstrapTable('refresh');
        });
        //回车事件绑定
        document.onkeydown = function (event) {
            var e = event || window.event || arguments.callee.caller.arguments[0];
            if (e && e.keyCode == 13) {
                $('#search').click();
            }
        };

        $('#addRole').click(function () {
            var addFormId = "addRoleForm";
            var addDialog = $.dialog({
                title: '',
                content: 'url:/role/add',
                columnClass: 'medium',
                draggable: true,
                onContentReady: function () {
                    var validateConfig = anchor.validFieldConfig(roleValidConfig, anchor.formField(addFormId));
                    validateConfig['id'] = addFormId;
                    var valid = anchor.validate(validateConfig);
                    $('#saveRole').click(function () {
                        if (valid.form()) {

                            anchor.request("/role/add", $('#' + addFormId).serializeObject(), function (data) {
                                if (data.code == 1) {
                                    bt.bootstrapTable('refresh');
                                    anchor.alert("保存成功");
                                    addDialog.close();
                                }
                                else {
                                    anchor.alert(data.message);
                                }
                            }, null);


                        }
                    });
                }

            });
        });

        /**
         * 批量删除操作
         *
         */
        $('#deleteBatchButton').click(function () {

            var ids = $.map(bt.bootstrapTable('getSelections'), function (row) {
                return row.id;
            });
            if (ids.length == 0) {
                anchor.alert("请选择删除数据");
                return;
            }
            anchor.confirm("确定要删除【" + ids.length + "】条数据么？", function () {
                anchor.request("/role/deleteBatch", {ids: ids}, function (data) {
                    bt.bootstrapTable('refresh');
                }, null);
            });

        });

    });
    /**
     * 详情
     */
    function detailRole(roleId) {
        $.dialog({
            title: '',
            content: 'url:/role/edit/' + roleId,
            type: 'blue',
            columnClass: 'medium',
            draggable: true,
            onContentReady: function () {

            }
        });
    }
    /**
     * 删除
     */
    function deleteRole(roleId) {
        anchor.confirm("确认要删除该用户么?", function () {
            anchor.request("/role/delete/" + roleId, {}, function (data) {
                anchor.alert(data.message);
                bt.bootstrapTable('refresh');
            }, null);
        });
    }
    /**
     * 编辑
     */
    function editRole(roleId) {
        var editFormId = "editRoleForm";
        var dialog = $.dialog({
            title: '',
            content: 'url:/role/edit/' + roleId,
            columnClass: 'medium',
            draggable: true,
            onContentReady: function () {
                var validateConfig = anchor.validFieldConfig(roleValidConfig, anchor.formField(editFormId));
                validateConfig['id'] = editFormId;
                var valid = anchor.validate(validateConfig);
                $('#editRole').click(function () {
                    if (valid.form()) {
                        anchor.request("/role/edit", $('#' + editFormId).serializeObject(), function (data) {
                            bt.bootstrapTable('refresh');
                            anchor.alert("保存成功");
                            dialog.close();
                        }, null);
                    }
                });
            }
        });
    }

    function setRolePermission(roleId) {
        var dialog = $.dialog({
            title: '权限设置',
            content: 'url:/role/permission/' + roleId,
            columnClass: 'medium',
            draggable: true,
            onContentReady: function () {

            },
            buttons: {
                confirm: {
                    text:"确认",
                    btnClass: 'btn-blue',
                    action:function () {

                    }
                }
                ,
                cancel: {
                    text:"取消",
                    action:function () {
                    }
                }
            }
        });
    }
</script>
</body>
</html>