<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
	Map<String, String> pMap = (Map<String, String>) application.getAttribute("possibility");
	Set<String> keySet = pMap.keySet();
%>
<!DOCTYPE html>
<html>
<head>
	<%@ include file="../../common/base_css_jquery.jsp"%>
	<link href="static/jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
	<script type="text/javascript" src="static/jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="static/jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<script type="text/javascript" src="static/jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
<meta charset="UTF-8">
<script type="text/javascript">

	//阶段和可能性对应关系的json串
	var possibilityJson = {
		<%
            for (String key : keySet) {
                String value = pMap.get(key);
        %>
		"<%=key%>" : <%=value%>,
		<%
            }
        %>
	};

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){

		$(".time").datetimepicker({
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd', //显示格式
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});

		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		//页面加载完毕获取客户备注信息
		getCustomerRemarkList();

		//给保存客户备注按钮绑定单击事件
		$("#saveCustomerRemarkBtn").click(function () {

			var noteContent = $.trim($("#remark").val());
			if (noteContent == "") {
				alert("请填写备注信息");
			} else {
				$.ajax({
					url : "workbench/customer/saveCustomerRemark",
					data : {
						"noteContent" : $.trim($("#remark").val()),
						"customerId" : "${requestScope.customer.id}"
					},
					type : "post",
					dataType : "json",
					success : function (data) {
                            // data
                            //     {"success":true/false,"customerRemark":{客户备注}}
						if (data.success) {
							var html = "";

							html += '<div id="' + data.customerRemark.id + '" class="remarkDiv" style="height: 60px;">';
							html += '<img src="static/image/user-thumbnail.png" style="width: 30px; height:30px;">';
							html += '<div style="position: relative; top: -40px; left: 40px;" >';
							html += '<h5 id="h' + data.customerRemark.id + '">' + data.customerRemark.noteContent + '</h5>';
							html += '<font color="gray">客户</font> <font color="gray">-</font> <b>${requestScope.customer.name}</b> <small style="color: gray;" id="s' + data.customerRemark.id +'"> ' + data.customerRemark.createTime + '由' + data.customerRemark.createBy + '</small>';
							html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
							html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\'' + data.customerRemark.id + '\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
							html += '&nbsp;&nbsp;&nbsp;&nbsp;';
							html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\'' + data.customerRemark.id + '\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
							html += '</div>';
							html += '</div>';
							html += '</div>';

							//在显示文本域的上方追加备注信息
							$("#remarkDiv").before(html);

							//清空文本域内容
							$("#remark").val("");
						} else {
							alert(data.errorMsg);
						}
					}
				});
			}

		});

		//使用on操控动态生成的备注的修改和删除按钮
		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})

		//给更新客户备注按钮绑定单击事件
		$("#updateRemarkBtn").click(function () {

			//从隐藏域中获取备注信息的id
			var id = $("#remarkId").val();

			$.ajax({
				url : "workbench/customer/updateCustomerRemark",
				data : {
					"id" : id,
					"noteContent" : $.trim($("#noteContent").val())
				},
				type : "post",
				dataType : "json",
				success : function (data) {
					/*
                        data
                            {"success":true/false,"customerRemark":{客户备注},"errorMsg":错误信息}
                     */
					if (data.success) {
						//修改成功
						//修改h标签内容
						$("#h" + id).html(data.customerRemark.noteContent);
						//修改small标签内容
						$("#s" + id).html(data.customerRemark.editTime + '由' + data.customerRemark.editBy);
						//关闭模态窗口
						$("#editRemarkModal").modal("hide");
					} else {
						//修改失败
						alert(data.errorMsg);
					}
				}
			});

		});

		//页面加载完毕，展示交易列表
		getTranList();

		//新建交易后，刷新交易列表
		window.onpageshow = function (event) {
			if (event.persisted || window.performance &&
					window.performance.navigation.type == 2) {
				window.location.reload();
			}
		}

		//页面加载完毕，展示联系人列表
		getContactsList();

		//自动补齐
		$("#create-customerName").typeahead({
			source: function (query, process) {
				$.get(
						"workbench/customer/getCustomerName",
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

	//获取客户备注信息
	function getCustomerRemarkList() {

		$.ajax({
			url : "workbench/customer/getCustomerRemarkList",
			data : {
				"id" : "${requestScope.customer.id}"
			},
			type : "get",
			dataType : "json",
			success : function (data) {
				/*
					data
						{"customerRemarkList":[{"客户备注1"},...]}
				 */
				var html = "";
				$.each(data.customerRemarkList, function (i, obj) {
					/*
                        javascript:void(0);
                            将超链接禁用，只能以触发事件的形式来操作
                     */
					html += '<div id="' + obj.id + '" class="remarkDiv" style="height: 60px;">';
					html += '<img src="static/image/user-thumbnail.png" style="width: 30px; height:30px;">';
					html += '<div style="position: relative; top: -40px; left: 40px;" >';
					html += '<h5 id="h' + obj.id + '">' + obj.noteContent +'</h5>';
					html += '<font color="gray">客户</font> <font color="gray">-</font> <b>${requestScope.customer.name}</b> <small style="color: gray;" id="s' + obj.id +'"> ' + (obj.editFlag == 0 ? obj.createTime : obj.editTime) + '由' + (obj.editFlag == 0 ? obj.createBy : obj.editBy) + '</small>';
					html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\'' + obj.id + '\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
					html += '&nbsp;&nbsp;&nbsp;&nbsp;';
					html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\'' + obj.id + '\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
					html += '</div>';
					html += '</div>';
					html += '</div>';
				});
				//在显示文本域的上方追加备注信息
				$("#remarkDiv").before(html);

			}
		});
	}

	function editRemark(id) {

		//从h标签中获取备注内容
		var noteContent = $("#h" + id).html();

		//将客户备注信息的id保存至隐藏域中
		$("#remarkId").val(id);

		//给修改备注信息的文本域填写原来的备注信息
		$("#noteContent").val(noteContent);

		//打开模态窗口
		$("#editRemarkModal").modal("show");

	}

	//删除线索备注
	function deleteRemark(id) {

		if (confirm("你确定要删除该备注吗？")) {

			$.ajax({
				url : "workbench/customer/deleteCustomerRemark",
				data : {
					"id" : id
				},
				type : "post",
				dataType : "json",
				success : function (data) {
					/*
                        data
                            {"success":true/false,"errorMsg":错误信息}
                     */
					if (data.success) {
						//删除成功
						//将删除的备注移除
						$("#"+id).remove();
					} else {
						alert(data.errorMsg);
					}
				}
			});

		}

	}

	//获取交易列表
	function getTranList() {

		$("#showTranTBody").html("");

		$.ajax({
			url : "workbench/customer/getTranListByCustomerId",
			data : {
				customerId: "${requestScope.customer.id}"
			},
			type : "get",
			dataType : "json",
			success : function (data) {
				//data
				//	[{交易},...]
				var html = "";
				$.each(data, function (i, obj) {

					var type = obj.type;
					if (type == null || type == "") {
						type = "";
					}
					var stage = obj.stage;
					var possibility = possibilityJson[stage];
					if (stage == null || stage == "") {
						possibility = "";
					}

					html += '<tr>';
					html += '<td><a href="workbench/transaction/detail?id=' + obj.id + '" style="text-decoration: none;">' + obj.name + '</a></td>';
					html += '<td>' + obj.money + '</td>';
					html += '<td>' + stage + '</td>';
					html += '<td>' + possibility + '</td>';
					html += '<td>' + obj.expectedDate + '</td>';
					html += '<td>' + type + '</td>';
					html += '<td><a href="javascript:void(0);" onclick="openRemoveTransactionModal(\'' + obj.id + '\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
					html += '</tr>';
				});
				$("#showTranTBody").html(html);
			}
		});

	}

	//打开删除交易模态窗口
	function openRemoveTransactionModal(id) {

		//给隐藏域赋id值
		$("#tranId").val(id);

		$("#removeTransactionModal").modal("show");

	}

	//删除交易
	function deleteTran() {
		//获取交易id
		var tranId = $("#tranId").val();

		$.ajax({
			url : "workbench/customer/deleteTran",
			data : {
				"id" : tranId
			},
			type : "post",
			dataType : "json",
			success : function (data) {
				// {"success":true/false,"errorMsg":错误信息}
				if (data.success) {
					getTranList();
				} else {
					alert(data.errorMsg);
				}
			}
		});

		//关闭模态窗口
		$("#removeTransactionModal").modal("hide");

	}

	//跳转至添加交易页面
	function addTran() {

		window.location.href= "workbench/transaction/add?intent=getCustomerName&customerId=${requestScope.customer.id}";

	}

	//获取联系人列表
	function getContactsList() {

		$.ajax({
			url : "workbench/customer/getContactsListByCustomerId",
			data : {
				"customerId" : "${requestScope.customer.id}"
			},
			type : "get",
			dataType : "json",
			success : function (data) {
				// [{联系人},...]
				var html = "";
				$.each(data, function (i, obj) {
					html += '<tr>';
					html += '<td><a href="workbench/contacts/detail?id=' + obj.id + '" style="text-decoration: none;">' + obj.fullname + '</a></td>';
					html += '<td>' + obj.email + '</td>';
					html += '<td>' + obj.mphone + '</td>';
					html += '<td><a href="javascript:void(0);" onclick="openRemoveContactsModal(\'' + obj.id + '\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
					html += '</tr>';
				});
				$("#showContactsTBody").html(html);
			}
		});

	}

	//打开删除联系人的模态窗口
	function openRemoveContactsModal(id) {

		//给隐藏域赋id值
		$("#contactsId").val(id);

		$("#removeContactsModal").modal("show");

	}

	//删除联系人
	function deleteContacts() {

		var id = $.trim($("#contactsId").val());

		$.ajax({
			url : "workbench/customer/deleteContacts",
			data : {
				"id" : id
			},
			type : "post",
			dataType : "json",
			success : function (data) {
				// {"success":true/false,"errorMsg":错误信息}
				if (data.success) {
					getContactsList();
				} else {
					alert(data.errorMsg);
				}
			}
		});

	}

	//打开添加联系人模态窗口
	function addContacts() {

		$.ajax({
			url : "workbench/customer/getUserList",
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
		} else if (customerName == "") {
			alert("请填写客户名称");
		} else {

			$.ajax({
				url : "workbench/customer/saveContacts",
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
						getContactsList();

						//清空表单内容
						$("#createContactsForm")[0].reset();

						$("#createContactsModal").modal("hide");
					} else {
						alert(data.errorMsg);
					}
				}
			});

		}

	}

	function deleteCustomer(id) {

		if (confirm("你确定要删除该客户吗？")) {

			$.ajax({
				url : "workbench/customer/deleteCustomerByIds",
				data : {
					"id" : id
				},
				type : "post",
				dataType : "json",
				success : function (data) {
					// {"success":true/false,"errorMsg",错误信息}
					if (data.success) {
						window.location.href = "pages/workbench/customer/index.jsp";
					} else {
						alert(data.errorMsg);
					}
				}
			});

		}

	}

	//打开编辑客户的模态窗口
	function openEditCustomerModal(customerId) {

		$.ajax({
			url : "workbench/customer/getUserListAndCustomerById",
			data : {
				"id" : customerId
			},
			type : "get",
			dataType : "json",
			success : function (data) {
				// {"uList":[{用户1}...],"customer":{客户}}
				var html = "";
				$.each(data.uList, function (i, obj) {
					if ("root" == obj.loginAct) {
						return true;
					}
					html += "<option value='" + obj.id + "'>" + obj.name + "</option>";
				});
				$("#edit-owner").html(html);

				$("#edit-owner").val(data.customer.owner);
				$("#edit-name").val(data.customer.name);
				$("#edit-website").val(data.customer.website);
				$("#edit-phone").val(data.customer.phone);
				$("#edit-contactSummary").val(data.customer.contactSummary);
				$("#edit-nextContactTime").val(data.customer.nextContactTime);
				$("#edit-description").val(data.customer.description);
				$("#edit-address").val(data.customer.address);
			}
		});

		$("#editCustomerModal").modal("show");

	}

	function updateCustomer(id) {

		var owner = $.trim($("#edit-owner").val());
		var name = $.trim($("#edit-name").val());
		var website = $.trim($("#edit-website").val());
		var phone = $.trim($("#edit-phone").val());
		var contactSummary = $.trim($("#edit-contactSummary").val());
		var nextContactTime = $.trim($("#edit-nextContactTime").val());
		var description = $.trim($("#edit-description").val());
		var address = $.trim($("#edit-address").val());

		$.ajax({
			url : "workbench/customer/updateCustomer",
			data : {
				"id" : id,
				"owner" : owner,
				"name" : name,
				"website" : website,
				"phone" : phone,
				"contactSummary" : contactSummary,
				"nextContactTime" : nextContactTime,
				"description" : description,
				"address" : address
			},
			type : "post",
			dataType : "json",
			success : function (data) {
				// {"success":true/false,"errorMsg":错误信息}
				if (data.success) {
					window.location.href = "workbench/customer/detail?id=" + id + "";
				} else {
					alert(data.errorMsg);
				}

			}
		});



	}

</script>

</head>
<body>

	<!-- 修改客户备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
		<div class="modal-dialog" role="document" style="width: 40%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="ActivityRemarkModalLabel">修改备注</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<div class="form-group">
							<label for="noteContent" class="col-sm-2 control-label">内容</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="noteContent"></textarea>
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 删除联系人的模态窗口 -->
	<div class="modal fade" id="removeContactsModal" role="dialog">
		<input type="hidden" id="contactsId">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">删除联系人</h4>
				</div>
				<div class="modal-body">
					<p>您确定要删除该联系人吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button onclick="deleteContacts()" type="button" class="btn btn-danger" data-dismiss="modal">删除</button>
				</div>
			</div>
		</div>
	</div>

    <!-- 删除交易的模态窗口 -->
    <div class="modal fade" id="removeTransactionModal" role="dialog">
		<input type="hidden" id="tranId">
        <div class="modal-dialog" role="document" style="width: 30%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title">删除交易</h4>
                </div>
                <div class="modal-body">
                    <p>您确定要删除该交易吗？</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                    <button onclick="deleteTran()" type="button" class="btn btn-danger">删除</button>
                </div>
            </div>
        </div>
    </div>
	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建联系人</h4>
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
								<input type="text" class="form-control" id="create-birth">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" value="${requestScope.customer.name}" placeholder="支持自动补全，输入客户不存在则新建">
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
                                    <input type="text" class="form-control time" id="create-nextContactTime" readonly>
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button onclick="saveContacts()" type="button" class="btn btn-primary">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改客户的模态窗口 -->
    <div class="modal fade" id="editCustomerModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改客户</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">

                        <div class="form-group">
                            <label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-owner">
                                </select>
                            </div>
                            <label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website">
                            </div>
                            <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-phone">
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
                                    <input type="text" class="form-control time" id="edit-nextContactTime" readonly>
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
                    <button onclick="updateCustomer('${requestScope.customer.id}')" type="button" class="btn btn-primary">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${requestScope.customer.name} <small><a href="${requestScope.customer.website}" target="_blank">${requestScope.customer.website}</a></small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button onclick="openEditCustomerModal('${requestScope.customer.id}')" type="button" class="btn btn-default"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button onclick="deleteCustomer('${requestScope.customer.id}')" type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.customer.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.website}&nbsp;</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${requestScope.customer.phone}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${requestScope.customer.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${requestScope.customer.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 40px;">
            <div style="width: 300px; color: gray;">联系纪要</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${requestScope.customer.contactSummary}&nbsp;
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
        <div style="position: relative; left: 40px; height: 30px; top: 50px;">
            <div style="width: 300px; color: gray;">下次联系时间</div>
            <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${requestScope.customer.nextContactTime}&nbsp;</b></div>
            <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
        </div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${requestScope.customer.description}&nbsp;
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 70px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${requestScope.customer.address}&nbsp;
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 10px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>

		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button id="saveCustomerRemarkBtn" type="button" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable2" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="showTranTBody">
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" onclick="addTran()" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>
		</div>
	</div>
	
	<!-- 联系人 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>联系人</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>邮箱</td>
							<td>手机</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="showContactsTBody">
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" onclick="addContacts()" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
			</div>
		</div>
	</div>
	
	<div style="height: 200px;"></div>
</body>
</html>