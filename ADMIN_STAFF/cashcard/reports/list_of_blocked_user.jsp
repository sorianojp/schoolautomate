<%@ page language="java" import="utility.*,cashcard.ReportManagement,java.util.Vector"%>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Blocked Users</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PrintPg(){
/*
	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
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
		<jsp:forward page="./list_of_blocked_user_print.jsp"></jsp:forward>	
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
								"Admin/staff-Cash Card-Reports","list_of_blocked_user.jsp");	
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
	
	ReportManagement reportMgt = new ReportManagement();
	Vector vRetResult = null;
	
	vRetResult = reportMgt.getBlockedUsers(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportMgt.getErrMsg();		

%>		
<body bgcolor="#D2AE72">
<form name="form_" action="./list_of_blocked_user.jsp" method="post">

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable1">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" align="center"><font color="#FFFFFF">
				<strong>:::: LIST OF BLOCKED USER ::::</strong></font></td>
		</tr>		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>			
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
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
		LIST OF BLOCKED USERS
	</strong></td></tr>
</table>
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
	<tr> 
		<td height="25" width="13%" align="center" class="thinborder"><strong>ID Number </strong></td> 
		<td width="22%" align="center" class="thinborder"><strong>Name</strong></td> 
		<td width="15%" align="center" class="thinborder"><strong>Course/Year Level/Department</strong></td> 
		<td width="24%" align="center" class="thinborder"><strong>Reason</strong></td> 
		<td width="14%" align="center" class="thinborder"><strong>Blocked by</strong></td>
		<td width="12%" align="center" class="thinborder"><strong>Blocked Date </strong></td>		
	</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 7){%>
		<tr> 
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%></td>
		 	<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>			
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
	<input type="hidden" name="print_page"  />
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>