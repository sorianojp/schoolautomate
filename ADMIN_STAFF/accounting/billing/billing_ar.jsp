<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
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
<title>Accounts Receivable</title>
</head>

<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function SearchReceivables(){
		document.form_.search_receivables.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.search_receivables.value = "";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./billing_ar_print.jsp" />
	<% 
		return;}
	
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
								"ACCOUNTING-BILLING","billing_ar.jsp");
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
	
	int i = 0;
	int iSearchResult = 0;	
	String[] astrSortByName = {"Billing Date","Bill Number","Project Name"};
	String[] astrSortByVal  = {"billing_date","bill_number","project_name"};
	
	BillingTsuneishi billTsu = new BillingTsuneishi();
	Vector vRetResult = null;
	
	if(WI.fillTextValue("search_receivables").length() > 0){
		vRetResult = billTsu.getAccountsReceivable(dbOP, request);
		if(vRetResult == null)
			strErrMsg = billTsu.getErrMsg();
		else
			iSearchResult = billTsu.getSearchCount();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./billing_ar.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: ACCOUNTS RECEIVABLE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Project:</td>
			<td width="80%">
				<select name="proj_index">
          			<option value="">All Projects</option>
          			<%=dbOP.loadCombo("project_index","project_name", " from ac_tun_project where is_valid = 1", WI.fillTextValue("proj_index"),false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Billing Date: </td>
			<td>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
				%>
				<select name="date_type" onchange="ReloadPage();">
				<%if (strTemp.equals("1")){%>
					<option value="1" selected="selected">Specific Date</option>
				<%}else{%>
					<option value="1">Specific Date</option>
				<%}if (strTemp.equals("2")){%>
					<option value="2" selected="selected">Date Range</option>
				<%}else{%>
					<option value="2">Date Range</option>
				<%}%>
				</select>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" 
					value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0" /></a>
			<%if(strTemp.equals("2")){%>
			to
			<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("date_to")%>" onfocus="style.backgroundColor='#D3EBFF'" 
				onblur="style.backgroundColor='white'" />
			<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
				onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;">
			<img src="../../../images/calendar_new.gif" border="0" /></a>
			<%}%></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%"><strong><u>SORT BY: </u></strong></td>
			<td width="17%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=billTsu.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
				</select></td>
			<td width="17%">
				<select name="sort_by2">
					<option value="">N/A</option>
					<%=billTsu.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
				</select></td>
			<td width="46%">
				<select name="sort_by3">
					<option value="">N/A</option>
					<%=billTsu.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
				</select></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
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
			<td>
				<select name="sort_by3_con">
					<option value="asc">Ascending</option>
				<% if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
					<option value="desc" selected>Descending</option>
				<%}else{%>
					<option value="desc">Descending</option>
				<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="20%">&nbsp;</td>
		    <td width="80%">
				<a href="javascript:SearchReceivables();"><img src="../../../images/form_proceed.gif" border="0"/></a>
				<font size="1">Click to search for accounts receivable.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" align="right">
				<font size="2">Number of Rows Per Page :</font>
				<select name="num_rec_page">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
				for(i = 10; i <=40 ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select>
				&nbsp;
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print list of accounts receivable.</font></td>
		</tr>
	</table>

	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: ACCOUNTS RECEIVABLE ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOM" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(billTsu.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/billTsu.defSearchSize;		
				if(iSearchResult % billTsu.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+billTsu.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="SearchReceivables();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						i = Integer.parseInt(strTemp);
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
				<%}}%></td>
		</tr>
		<tr>
			<td height="25" width="7%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Project Name</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Billing Date</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Bill Number</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Bill Reference</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Bill Amount</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Receivable</strong></td>
		</tr>
	<%	int iCount = 1;
		for(i = 0; i < vRetResult.size(); i += 7, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">Php<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+5), true)%></td>
			<td class="thinborder">Php<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true)%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="search_receivables" />
	<input type="hidden" name="print_page" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>