<%@ page language="java" import="utility.*, bookstore.BookLogs, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>View/Delete Book Logs</title>
</head>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
	function DeleteLog(strLogIndex, strQuantity){
		if(!confirm("Are you sure you want to delete this log?"))
			return;
		document.form_.search_logs.value = "1";
		document.form_.delete_log.value = strLogIndex;
		document.form_.quantity.value = strQuantity;
		document.form_.submit();
	}
	
	function GoBack(){
		location = "./book_supply_log_main.jsp";
	}
	
	function SearchLogs(){
		document.form_.search_logs.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
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
								"BOOKSTORE-BOOK MANAGEMENT","view_delete_book_logs.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-BOOK MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-BOOK MANAGEMENT-SUPPLY LOG"),"0"));
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
		//iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	int iSearchResult = 0;
	BookLogs bl = new BookLogs();
	
	if(WI.fillTextValue("delete_log").length() > 0){
		if(bl.operateOnBookLogs(dbOP, request, 0) == null)
			strErrMsg = bl.getErrMsg();
		else
			strErrMsg = "Book log successfully deleted.";
	}
	
	Vector vRetResult = null;
	
	if(WI.fillTextValue("search_logs").length() > 0){
		vRetResult = bl.operateOnBookLogs(dbOP, request, 4);
		if(vRetResult == null){
			if(WI.fillTextValue("delete_log").length() == 0)
				strErrMsg = bl.getErrMsg();
		}
		else
			iSearchResult = bl.getSearchCount();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_delete_book_logs.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: VIEW/DELETE BOOK LOGS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="87%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right"><a href="javascript:GoBack();"><img src="../../images/go_back.gif" border="0" /></a></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Log Date: </td>
			<td width="80%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
				%>
				<select name="date_type" onchange="ReloadPage();">
                  	<%if (strTemp.equals("1")){%>
					<option value="1" selected>Specific Date</option>
                  	<%}else{%>
                  	<option value="1">Specific Date</option>
                  	<%}if (strTemp.equals("2")){%>
                  	<option value="2" selected>Date Range</option>
                  	<%}else{%>
                  	<option value="2">Date Range</option>
                  	<%}%>
                </select>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0"></a>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
					if(strTemp.equals("2")){
				%>
				to 
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0"></a>
				<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
				<a href="javascript:SearchLogs();"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to search logs.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(bl.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="5"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/bl.defSearchSize;		
				if(iSearchResult % bl.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+bl.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.submit();">
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
			<td width="14%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="16%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="8%"  align="center" class="thinborder"><strong>Log Qty</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Log Date</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Logged By</strong></td>
		  	<td width="5%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 13, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12), 4)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:DeleteLog('<%=(String)vRetResult.elementAt(i)%>', '<%=(String)vRetResult.elementAt(i+5)%>');">
				<img src="../../images/delete.gif" border="0" /></a></td>
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
	
	<input type="hidden" name="search_logs" />
	<input type="hidden" name="delete_log" />
	<input type="hidden" name="quantity" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>