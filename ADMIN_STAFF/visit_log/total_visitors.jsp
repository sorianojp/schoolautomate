<%@ page language="java" import="utility.*, visitor.VisitLog, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Total Visitors</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function ReloadPage(){
		document.form_.info_index.value = "";
		document.form_.submit();
	}
	
	function LogOut(strInfoIndex){
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Visitor Management-Total Visitors","total_visitors.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Visitor Management","Record Going In Out",request.getRemoteAddr(),
															"total_visitors.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	VisitLog visitLog = new VisitLog();
	Vector vRetResult = null;
	int iSearchResult = 0;
	
	if(visitLog.isTerminal(dbOP, request)){
		strTemp = WI.fillTextValue("info_index");
	
		if(WI.fillTextValue("rf_id").length() > 0){
			strTemp = visitLog.getRFIDNumberInformation(dbOP, request);
			if(strTemp == null)
				strErrMsg = visitLog.getErrMsg();
		}
		
		if(strTemp != null && strTemp.length() > 0){
			strTemp = "./record_going_out.jsp?total_visitors=2&going_out=1&info_index="+strTemp;
		%>
			<jsp:forward page="<%=strTemp%>" />
			<%
			return;
		}
	}
	else
		strErrMsg = visitLog.getErrMsg();
		
	vRetResult = visitLog.getVisitorLogInformation(dbOP, request);
	if(vRetResult == null)
		strErrMsg = visitLog.getErrMsg();
	else
		iSearchResult = visitLog.getSearchCount();
%>
<body bgcolor="#D2AE72" onLoad="document.form_.rf_id.focus();" topmargin="0">
<form name="form_" method="post" action="total_visitors.jsp">
<jsp:include page="./tabs.jsp?pgIndex=0"></jsp:include>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="15"><input name="rf_id" type="text" size="1" border="0" class="textbox_noborder" style="font-size:9px; color:#FFFFFF"></td>
		    <td height="15">
				<%
					strErrMsg = WI.getStrValue(WI.fillTextValue("show_in"), "1");
					if(strErrMsg.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="show_in" value="1" <%=strTemp%> onChange="javascript:ReloadPage();">Show Visitors in Campus&nbsp;&nbsp;
				<%
					if(strErrMsg.equals("2"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="show_in" value="2" <%=strTemp%> onChange="javascript:ReloadPage();">Show Visitors Already Out</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="11" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>::: TODAY'S LOGS ::: </strong></div></td>
		</tr>
		<tr> 
			<td height="25" colspan="11" class="thinborderBOTTOMLEFT">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(visitLog.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
		</tr>
		<tr>
			<td height="25" width="8%" align="center" class="thinborder"><strong>DATE</strong></td>
			<td width="6%" align="center" class="thinborder"><strong>TIME-IN</strong></td>
			<td width="6%" align="center" class="thinborder"><strong>TIME-OUT</strong></td>
			<td align="center" class="thinborder" width="9%"><strong> PICTURE </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>VISITOR'S RF CARD NO. </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>VISITOR'S NAME </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>IDs PRESENTED </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>VISITED </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>PURPOSE</strong></td>
		<%if(strErrMsg.equals("1")){%>
			<td width="10%" align="center" class="thinborder"><strong>OPTION</strong></td>
		<%}%>
			<td width="10%" align="center" class="thinborder"><strong>REMARK</strong></td>
		</tr>
	<%	int iCount = 1;
		double dTemp = 0d;
		//Vector vTemp = new Vector();
		//while(vRetResult.size() > 0){
			//vTemp = (Vector)vRetResult.remove(0);
			for(int i = 0; i < vRetResult.size(); i += 32, iCount++){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i+3)))%></td>
			<%
				dTemp = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+5), "0"));
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.convert24HRTo12Hr(dTemp);
			%>
			<td class="thinborder"><%=strTemp%></td>
			<%
				strTemp = "../../upload_img/visitor/"+(String)vRetResult.elementAt(i+20)+".jpg";
			%>
			<td class="thinborder" align="center"><img src="<%=strTemp%>" width="50" height="50" border="1"></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8), (String)vRetResult.elementAt(i+9), 4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+10)%></td>
			<%
			strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12), (String)vRetResult.elementAt(i+13), 4);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRetResult.elementAt(i+18);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRetResult.elementAt(i+30);
			%>
			<td class="thinborder"><%=strTemp%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+14)%></td>
		<%if(strErrMsg.equals("1")){%>
			<td class="thinborder" align="center">
				<%if((String)vRetResult.elementAt(i+5) == null){%>
					<a href="javascript:LogOut('<%=(String)vRetResult.elementAt(i)%>');"><font color="#0000FF"><strong>OUT</strong></font></a>
				<%}else{%>
					&nbsp;
				<%}%></td>
		<%}%>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+15), "&nbsp;")%></td>
		</tr>
	<%//}
	}%>
	</table>
<%}%>	

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="info_index">
	<input type="hidden" name="total_visitors" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>