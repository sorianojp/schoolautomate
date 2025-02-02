<%@ page language="java" import="utility.*, citbookstore.BookOrders, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>For Releasing</title></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
	function checkAllOrders() {
		var maxDisp = document.form_.order_count.value;
		var bolIsSelAll = document.form_.selAllOrders.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function ForReleasing(){
		document.form_.for_releasing.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","for_releasing.jsp");
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
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-ORDERING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};
	BookOrders bo = new BookOrders();
	
	if(WI.fillTextValue("for_releasing").length() > 0){
		if(bo.operateOnOrdersForReleasing(dbOP, request, 1) == null)
			strErrMsg = bo.getErrMsg();
		else
			strErrMsg = "Operation successful.";
	}
	
	int iSearchResult = 0;
	Vector vRetResult = bo.operateOnOrdersForReleasing(dbOP, request, 4);
	if(vRetResult == null){
		if(WI.fillTextValue("for_releasing").length() == 0)
			strErrMsg = bo.getErrMsg();
	}
	else
		iSearchResult = bo.getSearchCount();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./for_releasing.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: FOR RELEASING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<input type="button" name="release_button" value=" For Releasing "
					onclick="javascript:ForReleasing();" style="font-size:11px; height:28px;border: 1px solid #FF0000;" />
				<font size="1">Click to make orders for releasing.</font></td>
		</tr>
	</table>

	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(bo.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="5"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/bo.defSearchSize;		
				if(iSearchResult % bo.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+bo.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="javascript:document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%> </td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Order Number </strong></td>
			<td width="22%" align="center" class="thinborder"><strong>Student Name </strong></td>
			<td width="18%" align="center" class="thinborder"><strong>SY/Term</strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Transaction Date &amp; Time </strong></td>			
			<td width="15%" align="center" class="thinborder"><strong>Payable Amt </strong></td>
			<td width="7%" align="center" class="thinborder"><strong>Select All<br /></strong>
              	<input type="checkbox" name="selAllOrders" value="0" onclick="checkAllOrders();" /></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=15, iCount++){
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
			<td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+12), (String)vRetResult.elementAt(i+13), (String)vRetResult.elementAt(i+14), 4)%></td>
			<td class="thinborder">&nbsp;<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+2))]%>/ <%=(String)vRetResult.elementAt(i+3)%>-<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+6)), 4)%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+10), true)%>&nbsp;</td>
			<td class="thinborder" align="center">
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1" /></td>			
		</tr>
	<%}%>
		<input type="hidden" name="order_count" value="<%=iCount%>" />
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
	
	<input type="hidden" name="for_releasing" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>