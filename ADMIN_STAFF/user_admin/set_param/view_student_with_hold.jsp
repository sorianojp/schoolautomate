<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Hold-Unhold Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script src="../../../Ajax/ajax.js"></script>

<script language="JavaScript">

function PrintPg()
{	
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
			
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myTable3').deleteRow(0);
	document.getElementById('myTable3').deleteRow(0);
	
	window.print();
}


</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameters","view_student_with_hold.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"view_student_with_hold.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","Set Parameters",request.getRemoteAddr(),
															"view_student_with_hold.jsp");}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = new Vector();

SetParameter setParam = new SetParameter();


vRetResult = setParam.viewStudentOnHold(dbOP,request);
if(vRetResult == null)
	strErrMsg = setParam.getErrMsg();

String[] astrConverSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", "4th Sem", "5th Sem"};
boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) {
	bolIsBasic = true;
	astrConverSem[1] = "Regular";
}




%>
<form name="form_" action="./view_student_with_hold.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LIST OF STUDENT ON HOLD ::::</strong></font></div></td>
    </tr>
	<tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
</table>
  
<% if(vRetResult != null && vRetResult.size() > 0){%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable2">
	<tr><td align="right" valign="middle">	
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	</td></tr>
	<tr><td>&nbsp;</td></tr>
	<tr><td><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div></td></tr>
	<!--<tr>
		<td align="right"><font size="1"><strong></strong></font><font size="1">Date and Time Printed: <%=WI.getTodaysDateTime()%></font>&nbsp;</td>
	</tr>-->
</table>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td height="25" align="center" width="5%" class="thinborder"><strong>Count</strong></td>
		<td width="15%" align="" class="thinborder"><strong>Student ID</strong></td>
		<td width="25%" align="" class="thinborder"><strong>Student Name </strong></td>
		<td width="15%" align="center" class="thinborder"><strong>Gender</strong></td>
		<td width="20%" align="" class="thinborder"><strong><%if(bolIsBasic){%> Grade Level<%}else{%>Course<%}%></strong></td>
		<%if(!bolIsBasic) {%><td width="10%" align="center" class="thinborder"><strong>Year</strong></td><%}%>
		<td width="15%" align="" class="thinborder"><strong>SY/Term</strong></td>
	</tr>
	
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+= 9, iCount++){
	%>
	<tr>
		<td height="25" class="thinborder"><%=iCount%></td>		
		<td height="25" align="" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>		
		<td height="25" align="left" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+6);
		if(strTemp.equals("M"))
			strTemp = "Male";
		else
			strTemp = "Female";
		%>		
		<td height="25" align="center" class="thinborder"><%=strTemp%></td>
		<td height="25" align="left" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3))%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"- ","","")%></td>
		<%if(!bolIsBasic) {%><td height="25" align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"&nbsp;")%></td><%}%>
		<td height="25" align="" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;")%>
		<%=astrConverSem[Integer.parseInt((String)vRetResult.elementAt(i+8))]%>
		</td>
	</tr>
	<%}%>
	
</table>

<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable3">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
