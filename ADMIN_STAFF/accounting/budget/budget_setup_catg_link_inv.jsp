<%@ page language="java" import="utility.*, Accounting.Budget, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Invoice Categories</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this category?'))
				return;
		}
		document.form_.page_action.value = strAction;
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function ReloadPage(strReset){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		
		if(strReset == 1) {
		
		}
		else if(strReset == 2) {
			document.form_.inv_cat_index.selectedIndex = 0;
			document.form_.inv_class_index.selectedIndex = 0;
		}
		else if (strReset == 3) {
			document.form_.inv_class_index.selectedIndex = 0;
		}
		document.form_.submit();
	}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-Budget","budget_setup_catg_link_inv.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}	

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	
	Budget budget = new Budget();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(budget.operateOnBudgetCatgLinkInvCatg(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = budget.getErrMsg();
		else
			strErrMsg = "Operation Successful.";
	}

	if(strPrepareToEdit.equals("1")){
		vEditInfo = budget.operateOnBudgetCatgLinkInvCatg(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = budget.getErrMsg();
	}
	vRetResult = budget.operateOnBudgetCatgLinkInvCatg(dbOP, request, 4);
	
	if(strErrMsg == null && vRetResult == null) 
		strErrMsg = budget.getErrMsg();
		
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./budget_setup_catg_link_inv.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::::  LINK BUDGET CATEGORY ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Budget Category </td>
			<td width="80%">
			<%
			strErrMsg = " from ac_budget_setup_catg where is_valid = 1 order by catg_code ";
			%>
			
			<select name="budget_catg_index" onChange="ReloadPage(1);">
          			<option value="">Select Category</option>
          			<%=dbOP.loadCombo("catg_index","catg_code, catg_name", strErrMsg, WI.fillTextValue("budget_catg_index"),false)%> 
        		</select>			</td>
		</tr>
		<tr>
		  <td colspan="3"><hr size="1"></td>
	  </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Inventory Type </td>
		  <td>
		  <%
			  String strInvType = WI.getStrValue(WI.fillTextValue("inventory_type"),"0");
		  %>
			<select name="inventory_type" onChange="ReloadPage(2);">
			  <option value="0" selected>Non-Supplies/Equipment</option>
			  <%if(strInvType.equals("1")){%>
			  <option value="1" selected>Supplies</option>
			  <%} else {%>
			  <option value="1">Supplies</option>
			  <%}if(strInvType.equals("2")){%>
			  <option value="2" selected>Chemical</option>
			  <%} else {%>
			  <option value="2">Chemical</option>
			  <%}if(strInvType.equals("3")){%>
			  <option value="3" selected>Computer/Parts</option>
			  <%} else {%>
			  <option value="3">Computer/Parts</option>
          <%}%>
        	</select>
		</td>
	  </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Item Category </td>
			<td>
				<select name="inv_cat_index" onChange="ReloadPage(3);">
					<option value="">Select category</option>
					  <%=dbOP.loadCombo("inv_cat_index","inv_category"," from inv_preload_category " +
						"where is_supply_cat = " + strInvType + 
						" order by is_default desc, inv_category", WI.fillTextValue("inv_cat_index"), false)%> 
				</select>	
		  	</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Item Classification </td>
		  <td>
				<select name="inv_class_index">
					<option value="">Select Class</option>
					<%=dbOP.loadCombo("inv_class_index","classification"," from inv_preload_class " +
										"where inv_cat_index = " + WI.getStrValue(WI.fillTextValue("inv_cat_index"),"0") + 
										" order by classification", WI.fillTextValue("inv_class_index"), false)%>
			  	</select>
	    </td>
	  </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save category information.</font>
				    <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit category information.</font>
					    <%}
				}%>
				<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>			</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: BUDGET CATEGORY LISTING ::: </strong></div></td>
		</tr>
		<tr style="font-weight:bold">
			<td height="25" width="3%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Budget Category</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Inventory Category </strong></td>
			<td width="30%" align="center" class="thinborder">Inventory Classificaiton </td>
			<td width="7%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=5, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%> - <%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;")%></td>
			<td align="center" class="thinborder">
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/delete.gif" border="0"></a>
					<%}else{%>
						Not authorized.
					<%}%>
			</td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>