<%@ page language="java" import="utility.*, Accounting.SalesPayment, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>Payment</title>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function EditOR(strInfoIndex, strInfoCount){
		document.form_.info_index.value = strInfoIndex;
		document.form_.info_count.value = strInfoCount;
		document.form_.page_action.value = "2";
		document.form_.submit();
	}
	
	function CancelOR(strInfoIndex){
		if(!confirm("Are you sure you want to cancel this OR?"))
			return;
		document.form_.info_index.value = strInfoIndex;
		document.form_.info_count.value = "";
		document.form_.page_action.value = "0";
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
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
								"ACCOUNTING-BILLING","OR_operations.jsp");
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
	
	String[] astrDropListEqual = {"Any Keywords","All Keywords","Equal to"};
	String[] astrDropListValEqual = {"any","all","equals"};
	String[] astrSortByName = {"OR Number","Date Paid"};
	String[] astrSortByVal = {"or_number","date_paid"};
	int iSearchResult = 0;
	Vector vRetResult = null;
	SalesPayment sp = new SalesPayment();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(sp.operateOnOR(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = sp.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "OR successfully cancelled.";
			if(strTemp.equals("2"))
				strErrMsg = "OR successfully edited.";
		}
	}
	
	vRetResult = sp.operateOnOR(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = sp.getErrMsg();
	else
		iSearchResult = sp.getSearchCount();
%>	
<body bgcolor="#D2AE72">
<form name="form_" action="OR_operations.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::::  OR OPERATIONS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="47%"><strong><u>View Options</u></strong></td>		    
		    <td width="50%"><strong><u>Sort Options</u></strong></td>
		</tr>
		<tr>
			<td colspan="2" valign="top">				
				<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td width="6%" height="25">&nbsp;</td>
						<td width="24%">Status: </td>		
					  	<td width="70%">
							<%
								strTemp = WI.fillTextValue("or_status");
							%>
							<select name="or_status">		
								<option value="">All</option>
								<%if (WI.fillTextValue("or_status").equals("1")){%>
									<option value="1" selected>Valid</option>
								<%}else{%>
									<option value="1">Valid</option>
								
								<%}if (WI.fillTextValue("or_status").equals("0")){%>
									<option value="0" selected>Cancelled</option>
								<%}else{%>
									<option value="0">Cancelled</option>
								<%}%>
							</select></td>
					</tr>						
					<tr>
						<td width="6%" height="25">&nbsp;</td>
						<td width="24%">OR Number: </td>		
					  	<td width="70%">
							<input type="text" name="or_number" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white'" size="24" maxlength="24" value="<%=WI.fillTextValue("or_number")%>"></td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<td>Date: </td>
						<td>
							<input name="date_option" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_option")%>" 
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							&nbsp; 
							<a href="javascript:show_calendar('form_.date_option');" title="Click to select date" 
								onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
								<img src="../../../images/calendar_new.gif" border="0"></a></td>
					</tr>
				</table>
			</td>
			<td valign="top">
				<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
					<tr> 
						<td height="25" width="40%">
							<select name="sort_by1">
								<option value="">N/A</option>
								<%=sp.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
							</select></td>
						<td width="60%">
							<select name="sort_by2">
								<option value="">N/A</option>
								<%=sp.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
							</select></td>
				    </tr>
					<tr> 
						<td height="25">
							<select name="sort_by1_con">
								<option value="asc">Ascending</option>
							<% if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
								<option value="desc" selected>Descending</option>
							<%}else{%>
								<option value="desc">Descending</option>
							<%}%>
						</select></td>
					<td>
						<select name="sort_by2_con">
							<option value="asc">Ascending</option>
						<% if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
							<option value="desc" selected>Descending</option>
						<%}else{%>
							<option value="desc">Descending</option>
						<%}%>
						</select></td>
				    </tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="40">&nbsp;</td>
			<td colspan="2" valign="middle">
				<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" /></a></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" class="thinborder">
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="5"><strong>Total Results: <%=iSearchResult%> - 
				Showing(<%=WI.getStrValue(sp.getDisplayRange(), ""+iSearchResult)%>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/sp.defSearchSize;		
				if(iSearchResult % sp.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+sp.getDisplayRange()+")";
				
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
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count </strong></td>
			<td width="14%" align="center" class="thinborder"><strong>OR # </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Date Paid </strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Charge To </strong></td>
			<td width="12%" align="center"  class="thinborder"><strong>Amount</strong></td>
			<td width="22%" align="center" class="thinborder"><strong>New OR#</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		boolean bolIsValid = false;
		for(int i = 0; i < vRetResult.size(); i += 8, iCount++){
			bolIsValid = ((String)vRetResult.elementAt(i+7)).equals("1");
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<%
				if(bolIsValid)
					strTemp = (String)vRetResult.elementAt(i+3);
				else
					strTemp = "-Cancelled-";
			%>
			<td class="thinborder"><%=strTemp%></td>
			<%
				if(bolIsValid)
					strTemp = (String)vRetResult.elementAt(i+5) + CommonUtil.formatFloat((String)vRetResult.elementAt(i+4), true);
				else
					strTemp = "-Cancelled-";
			%>
			<td class="thinborder" align="right"><%=strTemp%></td>
			<td class="thinborder" align="center">
			<%if(bolIsValid){%>
				<input name="or_number_<%=iCount%>" type="text" size="20" maxlength="24" class="textbox" 
					onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
			<%}else{%>
				-Cancelled-
			<%}%></td>
			<td class="thinborder" align="center">
			<%if(bolIsValid){
				if(iAccessLevel > 1){%>
					<a href="javascript:EditOR('<%=(String)vRetResult.elementAt(i)%>', '<%=iCount%>')">
						<img src="../../../images/edit.gif" border="0" /></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:CancelOR('<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/cancel.gif" border="0" /></a>
					<%}
				}else{%>
					Not authorized.
				<%}
			}else{%>
				Cancelled.
			<%}%></td>
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

	<input type="hidden" name="info_index" />
	<input type="hidden" name="info_count" />
	<input type="hidden" name="page_action" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>