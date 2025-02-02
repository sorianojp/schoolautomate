<%@ page language="java" import="utility.*,cashcard.ReportManagement,java.util.Vector"%>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Alert Level</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src="../../../jscript/common.js"></script>

<script language="javascript">
	function GenerateReport(){
		document.form_.print_page.value = "";
		document.form_.generate_report.value = "1";
		document.form_.submit();
	}
	function PrintPg(){
/*
	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
	document.getElementById("myADTable5").deleteRow(0);
	document.getElementById("myADTable5").deleteRow(0);
	document.getElementById("myADTable5").deleteRow(0);
	document.getElementById("myADTable5").deleteRow(0);
	document.getElementById("myADTable5").deleteRow(0);
	document.getElementById("myADTable5").deleteRow(0);
	
	document.getElementById("myADTable2").deleteRow(0);
	
	document.getElementById("myADTable4").deleteRow(0);
	document.getElementById("myADTable4").deleteRow(0);

	window.print();
*/
	document.form_.print_page.value = "1";
	document.form_.submit();
}


</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./alert_level_print.jsp"></jsp:forward>	
<%	return;}
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-REPORTS"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Reports","alert_level.jsp");	
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	
	String[] astrSortByName    = {"Item Code","Item Name","Department","Category"};
	String[] astrSortByVal     = {"item_code","item_name","dept_name","catg_name"};
	
	ReportManagement reportMgmt = new ReportManagement();
	Vector vRetResult = null;
	if(WI.fillTextValue("generate_report").length() > 0){
		vRetResult = reportMgmt.getItemOnAlertLevel(dbOP, request);
		if(vRetResult == null)
			strErrMsg = reportMgmt.getErrMsg();		
	}
%>		
<body bgcolor="#D2AE72">
<form name="form_" action="./alert_level.jsp" method="post">

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable1">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" align="center"><font color="#FFFFFF">
				<strong>:::: INVENTORY ALERT LEVEL REPORT ::::</strong></font></td>
		</tr>		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>	
		
		<tr>
			<td height="25" width="3%"></td>
			<td width="17%">Department Name:</td>
			<td width="80%">
				<%
					strTemp = WI.fillTextValue("terminal_dept_index");
				%>
				<select name="terminal_dept_index">
					<option value="">Select Department</option>
					<%=dbOP.loadCombo("terminal_dept_index","dept_name"," from cc_terminal_dept where is_valid = 1 order by dept_name",strTemp, false)%>
				</select>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td height="25">Category :</td>
			<td height="25">
				<select name="item_catg_index">
      <%strTemp= WI.fillTextValue("item_catg_index");%>
      <option value="">Select Category</option>
      <%=dbOP.loadCombo("item_catg_index","catg_name", " from hms_rest_item_catg " +
			" where exists(select * from hms_rest_item_inv_mf where catg_index = item_catg_index " +
			"		and is_valid = 1 and is_inv_item = 1) " + 
			" order by catg_name",strTemp,false)%>
    </select>
			  <font color="#000066"><a href="#"></a></font></td>
		</tr>
		
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="" id="myADTable5">
	<tr><td height="10" colspan="3"></td></tr>
	<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=reportMgmt.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=reportMgmt.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=reportMgmt.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
           	 </select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td>
				<select name="sort_by1_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select></td>
			<td>
				<select name="sort_by2_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
           	</select></td>
			<td>
				<select name="sort_by3_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
           	</select></td>
		</tr>
		<tr><td height="10" colspan="7"></td></tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="6"><a href="javascript:GenerateReport();"><img src="../../../images/form_proceed.gif" border="0" /></a></td>
		</tr>
		<tr>
			<td height="15" colspan="7">&nbsp;</td>
		</tr>
	</table>
	
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">
	<tr><td align="right">
	 Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 26;
if(WI.fillTextValue("rows_per_pg").length() > 0) 
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i =25; i < 60; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	  <option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	  &nbsp;&nbsp;&nbsp;
	<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
		<font size="1">Click to print report</font>
	</td></tr>
	<tr><td align="center"><strong>
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
		Item on Inventory Alert Level
	</strong></td></tr>
</table>
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
	<tr>
		<td width="15%" align="center" class="thinborder"><strong><font size="1">Department</font></strong></td>
		<td width="13%" align="center" class="thinborder"><strong><font size="1">Category Name</font></strong></td>
		<td width="15%" align="center" class="thinborder"><strong><font size="1">Item Code</font></strong></td>
		<td width="33%" align="center" class="thinborder"><strong><font size="1">Item Name</font></strong></td>
		<td width="9%" height="25" align="center" class="thinborder"><strong><font size="1">Selling Price</font></strong></td>		
		<td width="8%" align="center" class="thinborder"><strong><font size="1">Current Balance</font></strong></td>
		<td width="7%" height="25" align="center" class="thinborder"><strong><font size="1">Alert Level</font></strong></td>		
	</tr>
	<%	
	for(int i = 0; i < vRetResult.size(); i+=13){		
	%>
		<tr>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>								
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>		
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%> &nbsp; </td>
			<td class="thinborder" align="">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true)%>&nbsp;</td>
			<td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true)%></td>
			<td class="thinborder" align="right">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>	
		</tr>
		
	<%}%>	
</table>

<%}%>

	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4"> 
		<tr bgcolor="#FFFFFF">
			<td height="25"></td>
		</tr> 
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	<input type="hidden" name="generate_report" />
	<input type="hidden" name="update_floating_orders" value=""  />
	<input type="hidden" name="print_page" />
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>