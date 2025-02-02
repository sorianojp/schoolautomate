<%
String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
if (strAuthID == null) {%>	
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		You are logged out. Please login again.</font></p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">


function PrintPage(){

	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
	
	document.getElementById("myADTable2").deleteRow(0);
	
	document.getElementById("myADTable4").deleteRow(0);
	document.getElementById("myADTable4").deleteRow(0);

	window.print();
	
}
</script>



<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Additional Month Pay","upload_prev_salary.jsp");
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

Vector vRetResult = new Vector();
if(WI.fillTextValue("year_of").length() > 0){
	strTemp = " select id_number, fname, mname, lname, c_name, d_name, BASIC_SAL "+
			" from PR_PREV_SAL_DETAIL "+
			" join INFO_FACULTY_BASIC on (INFO_FACULTY_BASIC.USER_INDEX = PR_PREV_SAL_DETAIL.USER_INDEX) "+
			" join USER_TABLE on (USER_TABLE.USER_INDEX = PR_PREV_SAL_DETAIL.USER_INDEX) "+
			" left join DEPARTMENT on (DEPARTMENT.D_INDEX = INFO_FACULTY_BASIC.D_INDEX) "+
			" left join COLLEGE on (COLLEGE.C_INDEX = INFO_FACULTY_BASIC.C_INDEX ) "+
			" where PR_PREV_SAL_DETAIL.IS_VALID =1 "+
			" and INFO_FACULTY_BASIC.IS_VALID = 1 "+
			" and YEAR_OF = "+WI.fillTextValue("year_of")+
			" and IS_PREVIOUS =0 order by lname, fname";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vRetResult.addElement(rs.getString(1));
		vRetResult.addElement(WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4));
		
		strTemp = WI.getStrValue(rs.getString(5));
		strErrMsg = WI.getStrValue(rs.getString(6));
		if(strTemp.length() > 0 && strErrMsg.length() > 0)
			strTemp += " / ";
		strTemp += strErrMsg;
		vRetResult.addElement(strTemp);
		
		vRetResult.addElement(CommonUtil.formatFloat(rs.getDouble(7),true));
	}rs.close();
	strErrMsg = "";	
	if(vRetResult.size() == 0)
		strErrMsg = "No uploaded data found.";

		
	

}

%>
<body bgcolor="#D2AE72">
<form name="form_" action="view_uploaded_prev_salary.jsp" method="post" >
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF"><strong>::::
          VIEW UPLOADED PREVIOUS SALARY PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;<strong style="color:#FF0000">
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></strong></td>
    </tr>
    
    
    
	
	
	<tr>
		<td height="25" width="3%"></td>
	    <td height="25">Year Of&nbsp;&nbsp;	        <input name="year_of" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("year_of")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_of');style.backgroundColor='white'"	  
	  onKeyUp='AllowOnlyInteger("form_","year_of");'>
	  &nbsp;
	  <input type="image" name="_1" src="../../../../images/refresh.gif" border="0">
	  </td>
	    
	</tr>
</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">
	<tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>
	<font size="1">Click to print report</font></td></tr>
	<tr><td height="25" align="center"><strong style="font-size:13px;"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong><br>
	<%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br><br>
	<strong>LIST OF EMPLOYEE WITH UPLOADED PREVIOUS SALARY</strong><br>YEAR <%=WI.fillTextValue("year_of")%></td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold;">
	    <td width="7%" align="center" class="thinborder">COUNT</td>
		<td width="21%" height="22" align="center" class="thinborder">EMPLOYEE ID</td>
		<td width="24%" height="22" align="center" class="thinborder">EMPLOYEE NAME</td>
		<td width="35%" height="22" align="center" class="thinborder">DEPARTMENT</td>
		<td width="13%" height="22" align="center" class="thinborder">BASIC SALARY</td>
	</tr>
	
	<%
	int iCount = 0;
	for(int i =0 ; i < vRetResult.size(); i += 4){%>
	<tr>
	    <td align="right" class="thinborder"><%=++iCount%>.&nbsp;</td>
	    <td height="22" class="thinborder"><%=vRetResult.elementAt(i)%></td>
	    <td height="22" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
	    <td height="22" class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
	    <td height="22" align="right" class="thinborder"><%=vRetResult.elementAt(i+3)%></td>
	</tr>
	<%}%>
</table>
<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
