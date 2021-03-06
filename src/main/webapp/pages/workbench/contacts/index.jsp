<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
	<%@ include file="../../common/base_css_jquery.jsp"%>
<meta charset="UTF-8">

<link href="static/jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="static/jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="static/jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<link href="static/jquery/bs_pagination/jquery.bs_pagination.min.css" type="text/css" rel="stylesheet"/>
<script type="text/javascript" src="static/jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="static/jquery/bs_pagination/en.js"></script>
<link rel="stylesheet" type="text/css" href="static/jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css">
<script type="text/javascript" src="static/jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="static/jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<link href="static/jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="static/jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="static/jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="static/jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

<script type="text/javascript">

	$(function(){

		$(".timeBottom").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd', //显示格式
			autoclose: true,
			todayBtn: true,
			clearBtn: true,
			pickerPosition: "bottom-left"
		});

		$(".timeTop").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd', //显示格式
			autoclose: true,
			todayBtn: true,
			clearBtn: true,
			pickerPosition: "top-left"
		});

		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });

		//给控制总的复选框绑定单击事件
		$("input[name='checkbox-manager']").click(function () {

			$("input[name='checkbox-single']").prop("checked", this.checked);

		});

		//给单个的复选框绑定单击事件
		$("#showContactsTBody").on("click", $("input[name='checkbox-single']"), function () {
			$("input[name='checkbox-manager']").prop("checked", $("input[name='checkbox-single']:checked").length == $("input[name='checkbox-single']").length);
		});

		//页面加载完毕后调用分页方法
		pageList(1, 2);

		//自动补齐
		$("#create-customerName").typeahead({
			source: function (query, process) {
				$.get(
						"workbench/contacts/getCustomerName",
						{ "name" : query },
						function (data) {
							//alert(data);
							/*
								data
									[{"客户名1",...}]
							 */
							process(data);
						},
						"json"
				);
			},
			delay: 1500
		});

		$("#edit-customerName").typeahead({
			source: function (query, process) {
				$.get(
						"workbench/contacts/getCustomerName",
						{ "name" : query },
						function (data) {
							//alert(data);
							/*
								data
									[{"客户名1",...}]
							 */
							process(data);
						},
						"json"
				);
			},
			delay: 1500
		});

	});

	function searchContacts() {

		$("#hidden-owner").val($.trim($("#input-owner").val()));
		$("#hidden-fullname").val($.trim($("#input-fullname").val()));
		$("#hidden-customerId").val($.trim($("#input-customerId").val()));
		$("#hidden-source").val($.trim($("#source").val()));
		$("#hidden-birth").val($.trim($("#input-birth").val()));

		//查询操作后，刷新页面数据，回到第一页，每页显示数据数不变
		pageList(1
				,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));

	}

	function pageList(pageNo, pageSize) {

		//刷新后台数据之前取消总复选框的选中状态
		$("input[name='checkbox-manager']").prop("checked", false);

		//分页之前从隐藏域中取出文本框信息
		$("#input-owner").val($.trim($("#hidden-owner").val()));
		$("#input-fullname").val($.trim($("#hidden-fullname").val()));
		$("#input-customerId").val($.trim($("#hidden-customerId").val()));
		$("#source").val($.trim($("#hidden-source").val()));
		$("#input-birth").val($.trim($("#hidden-birth").val()));

		var owner = $("#input-owner").val();
		var fullname = $("#input-fullname").val();
		var customerId = $("#input-customerId").val();
		var source = $("#source").val();
		var birth = $("#input-birth").val();

				$.ajax({
			url : "workbench/contacts/pageList",
			data : {
				"pageNo" : pageNo,
				"pageSize" : pageSize,
				"owner" : owner,
				"fullname" : fullname,
				"customerId" : customerId,
				"source" : source,
				"birth" : birth
			},
			type : "get",
			dataType : "json",
			success : function (data) {
				/*
                    data
                        {"total":总记录数,"dataList":[{客户},{}...]}
                 */
				var html = "";
				$.each(data.dataList, function (i, obj) {
					var birth = obj.birth;
					if (birth == null) {
						birth = "";
					}
					var customerId = obj.customerId;
					if (customerId == null) {
						customerId = "";
					}
					html += '<tr>';
					html += '<td><input name="checkbox-single" type="checkbox" value="' + obj.id + '"/></td>';
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/contacts/detail?id=' + obj.id + '\';">' + obj.fullname + '</a></td>';
					html += '<td>' + customerId + '</td>';
					html += '<td>' + obj.owner + '</td>';
					html += '<td>'+ obj.source + '</td>';
					html += '<td>' + birth + '</td>';
					html += '</tr>';
				});
				$("#showContactsTBody").html(html);

				var totalPages = data.total % pageSize == 0 ? data.total / pageSize : Math.ceil(data.total / pageSize);

				//数据处理完毕后，结合分页插件展现每页数据
				$("#contactsPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					//该回调函数是在点击分页组件的时候触发的
					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);
					}
				});
			}
		});

	}

	//打开添加联系人模态窗口
	function addContacts() {

		$.ajax({
			url : "workbench/contacts/getUserList",
			type : "get",
			dataType : "json",
			success : function (data) {
				// [{用户},...]
				var html = "";
				$.each(data, function (i, obj) {
					if ("root" == obj.loginAct) {
						return true;
					}
					html += "<option value='" + obj.id + "'>" + obj.name + "</option>";
				});
				$("#create-owner").html(html);

				$("#create-owner").val("${sessionScope.user.id}");
			}
		});

		$("#createContactsModal").modal("show");

	}

	//保存联系人
	function saveContacts() {

		var owner = $.trim($("#create-owner").val());
		var source = $.trim($("#create-source").val());
		var fullname = $.trim($("#create-fullname").val());
		var appellation = $.trim($("#create-appellation").val());
		var job = $.trim($("#create-job").val());
		var mphone = $.trim($("#create-mphone").val());
		var email = $.trim($("#create-email").val());
		var birth = $.trim($("#create-birth").val());
		var customerName = $.trim($("#create-customerName").val());
		var description = $.trim($("#create-description").val());
		var contactSummary = $.trim($("#create-contactSummary").val());
		var nextContactTime = $.trim($("#create-nextContactTime").val());
		var address = $.trim($("#create-address").val());

		if (owner == "" || fullname == "") {
			alert("请填写2项相关信息");
		}  else if (customerName == "") {
			alert("请填写客户名称");
		} else {
			$.ajax({
				url : "workbench/contacts/saveContacts",
				data : {
					"owner" : owner,
					"source" : source,
					"fullname" : fullname,
					"appellation" : appellation,
					"job" : job,
					"mphone" : mphone,
					"email" : email,
					"birth" : birth,
					"customerName" : customerName,
					"description" : description,
					"contactSummary" : contactSummary,
					"nextContactTime" : nextContactTime,
					"address" : address
				},
				type : "post",
				dataType : "json",
				success : function (data) {
					// {"success":true/false,"errorMsg",错误信息}
					if (data.success) {
						//清空表单内容
						$("#createContactsForm")[0].reset();
						$("#createContactsModal").modal("hide");
						//保存数据后，刷新页面数据，回到第一页，每页显示数据数不变
						pageList(1,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						alert(data.errorMsg);
					}
				}
			});
		}

	}

	function openEditContactsModal() {

		var $checkbox = $("input[name='checkbox-single']:checked");
		//获取客户id
		var contactsId = $checkbox.val();

		if ($checkbox.length == 0) {
			alert("请选择要修改的客户信息");
		} else if ($checkbox.length > 1) {
			alert("最多只能修改一个客户信息");
		} else {
			$.ajax({
				url : "workbench/contacts/getUserListAndContactsById",
				data : {
					"contactsId" : contactsId
				},
				type : "get",
				dataType : "json",
				success : function (data) {
					// {"uList":[{用户},...],"contacts":{联系人}}
					var html = "";
					$.each(data.uList, function (i, obj) {
						html += "<option value='" + obj.id + "'>" + obj.name + "</option>"
					});
					$("#edit-owner").html(html);

					$("#edit-owner").val(data.contacts.owner);
					$("#edit-source").val(data.contacts.source);
					$("#edit-fullname").val(data.contacts.fullname);
					$("#edit-appellation").val(data.contacts.appellation);
					$("#edit-job").val(data.contacts.job);
					$("#edit-mphone").val(data.contacts.mphone);
					$("#edit-email").val(data.contacts.email);
					$("#edit-birth").val(data.contacts.birth);
					$("#edit-customerName").val(data.contacts.customerId);
					$("#edit-description").val(data.contacts.description);
					$("#edit-contactSummary").val(data.contacts.contactSummary);
					$("#edit-nextContactTime").val(data.contacts.nextContactTime);
					$("#edit-address").val(data.contacts.address);

					$("#editContactsModal").modal("show");
				}
			});
		}

	}

	function updateContacts() {

		var $checkbox = $("input[name='checkbox-single']:checked");
		//获取客户id
		var contactsId = $checkbox.val();
		$.ajax({
			url : "workbench/contacts/updateContacts",
			data : {
				"id" : contactsId,
				"owner" : $("#edit-owner").val(),
				"source" : $("#edit-source").val(),
				"fullname" : $("#edit-fullname").val(),
				"appellation" : $("#edit-appellation").val(),
				"job" : $("#edit-job").val(),
				"mphone" : $("#edit-mphone").val(),
				"email" : $("#edit-email").val(),
				"birth" : $("#edit-birth").val(),
				"customerId" : $("#edit-customerName").val(),
				"description" : $("#edit-description").val(),
				"contactSummary" : $("#edit-contactSummary").val(),
				"nextContactTime" : $("#edit-nextContactTime").val(),
				"address" : $("#edit-address").val()
			},
			type : "post",
			dataType : "json",
			success : function (data) {
				// {"success":true/false,"errorMsg":错误信息}
				if (data.success) {
					//关闭修改客户的模态窗口
					$("#editContactsModal").modal("hide");

					//修改数据后，刷新页面数据，留在当前页面，每页显示数据数不变
					pageList($("#contactsPage").bs_pagination('getOption', 'currentPage')
							,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));
				} else {
					alert(data.errorMsg);
				}
			}
		});

	}

	//删除联系人，可删除多条
	function deleteContacts() {

		var $checkbox = $("input[name='checkbox-single']:checked");
		if ($checkbox.length == 0) {
			alert("请选择要删除的联系人信息");
		} else if (confirm("你确定要删除所选联系人吗？")) {
			var param = "";
			for (var i = 0; i < $checkbox.length; i++) {
				var id = $($checkbox[i]).val();
				param += "id=" + id;
				if (i < $checkbox.length - 1) {
					param += "&";
				}
			}
			$.ajax({
				url : "workbench/contacts/deleteContacts",
				data : param,
				type : "post",
				dataType : "json",
				success : function (data) {
					// {"success":true/false,"errorMsg":错误信息}
					if (data.success) {
						//删除操作后，刷新页面数据，回到第一页，每页显示数据数不变
						pageList(1,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));
					} else {
						alert(data.errorMsg);
					}
				}
			});
		}

	}

</script>
</head>
<body>
	<input type="hidden" id="hidden-owner"/>
	<input type="hidden" id="hidden-fullname"/>
	<input type="hidden" id="hidden-customerId"/>
	<input type="hidden" id="hidden-source"/>
	<input type="hidden" id="hidden-birth"/>

	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form id="createContactsForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								</select>
							</div>
							<label for="create-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
								  <option></option>
								  <c:forEach items="${applicationScope.sourceList}" var="s">
									  <option value="${s.value}">${s.text}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
								  <c:forEach items="${applicationScope.appellationList}" var="a">
									  <option value="${a.value}">${a.text}</option>
								  </c:forEach>
								</select>
							</div>
							
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control timeBottom" id="create-birth">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control timeTop" id="create-nextContactTime">
								</div>
							</div>
						</div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" onclick="saveContacts()">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改联系人的模态窗口 -->
	<div class="modal fade" id="editContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
								</select>
							</div>
							<label for="edit-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
								  <option></option>
								  <c:forEach items="${applicationScope.sourceList}" var="s">
									  <option value="${s.value}">${s.text}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname">
							</div>
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
								  <option></option>
								  <c:forEach items="${applicationScope.appellationList}" var="a">
									  <option value="${a.value}">${a.text}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job">
							</div>
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email">
							</div>
							<label for="edit-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-birth">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control" id="edit-nextContactTime">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" onclick="updateContacts()">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>联系人列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="input-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">姓名</div>
				      <input class="form-control" type="text" id="input-fullname">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="input-customerId">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="source">
						  <option></option>
						  <c:forEach items="${applicationScope.sourceList}" var="s">
							  <option value="${s.value}">${s.text}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">生日</div>
				      <input class="form-control time" type="text" id="input-birth">
				    </div>
				  </div>
				  
				  <button type="button" onclick="searchContacts()" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" onclick="addContacts()"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" onclick="openEditContactsModal()"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" onclick="deleteContacts()"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 20px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input name="checkbox-manager" type="checkbox" /></td>
							<td>姓名</td>
							<td>客户名称</td>
							<td>所有者</td>
							<td>来源</td>
							<td>生日</td>
						</tr>
					</thead>
					<tbody id="showContactsTBody">
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 10px;">
				<div id="contactsPage"></div>
			</div>
			
		</div>
		
	</div>
</body>
</html>