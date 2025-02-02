<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>


<body>
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int j = 0 ; //count of students can't take exam. or stud with PN


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-LISTING FOR EXAMINATION","list_stud_take_exam_print.jsp");
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
														"Fee Assessment & Payments","LISTING FOR EXAMINATION",request.getRemoteAddr(),
														"list_stud_take_exam_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
String strSubSecIndex   = WI.fillTextValue("section");

GradeSystemExtn gSystemExtn = new GradeSystemExtn();
enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();

	Vector vRetResult = new Vector();//[0] = vStudNotAllowed, [1] = vStudWithPN, [2] = vStudPaidReqdAmt
    Vector vStudPaidReqdAmt = null;//students who paid required amount 
    Vector vStudWithPN      = null;//students with Promisory note and allowed to take exam
    Vector vStudNotAllowed  = null;//students not allowed to take exam because of less payment.

Vector vSecDetail = null;

if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

//Get here the list of stud in class can take exam.
if(vSecDetail != null && vSecDetail.size() > 0) {//get here student list can and can't take exam
	vRetResult = gSystemExtn.getStudCanOrCantTakeExam(dbOP, request);
	if(vRetResult == null || vRetResult.size() ==0) {
		strErrMsg = gSystemExtn.getErrMsg();
	}
	else {
		vStudNotAllowed  	= (Vector)vRetResult.elementAt(0);
    	vStudWithPN  		= (Vector)vRetResult.elementAt(1);	
    	vStudPaidReqdAmt  	= (Vector)vRetResult.elementAt(2);
	}
}
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="20" colspan="4" bgcolor="#cccccc"><div align="center"><strong><font size="2">::: 
        STUDENTS LISTING FOR EXAMINATION :::</font></strong></div></td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<% if(strErrMsg != null){%>
  <tr> 
    <td height="20" colspan="3">&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
  </tr>
<%}%>
  <tr> 
    <td width="2%" height="20">&nbsp;</td>
    <td width="38%" height="20" valign="bottom" >Examination Period</td>
    <td width="60%" valign="bottom" >School Year/Term</td>
  </tr>
  <tr> 
    <td height="20" valign="bottom" >&nbsp; </td>
    <td valign="bottom" ><strong><%=WI.fillTextValue("exam_period_name")%></strong></td>
    <td valign="bottom" ><strong><%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%> (<%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>)</strong></td>
  </tr>
</table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%"></td>
      <td width="38%" height="20" valign="bottom" >Section Handled</td>
      
    <td width="60%" valign="bottom" >Instructor Name</td>
    </tr>
    <tr> 
      <td></td>
      
    <td height="20" ><strong><%=WI.fillTextValue("section_name")%></strong></td>
      <td height="20" > <strong> 
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%> 
        <%}%>
        </strong> </td>
    </tr>
    <tr> 
      <td width="2%"></td>
      <td height="20">Subject Handled</td>
      <td>Subject Title </td>
    </tr>
    <tr> 
      <td width="2%"></td>
      
    <td height="20" ><strong><%=WI.fillTextValue("sub_code")%></strong></td>
      <td> <strong> 
        <%
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>
        <%=WI.getStrValue(strTemp)%></strong></td>
      <%}%>
    </tr>
  </table>
<%if(vSecDetail != null){%>
 <table width="100%" border="0" cellspacing="1" cellpadding="2" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%> 
	<tr>
	<td>&nbsp;</td>
	<td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
	<td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
	  <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
	<td>&nbsp;</td>
	</tr>  
	<%}%>  
	<tr>
	<td>&nbsp;</td>
	  <td align="center">&nbsp;</td>
	  <td colspan="3" align="right" valign="bottom">Date and Time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>   
</table>		
<%}if(vStudNotAllowed != null && vStudNotAllowed.size() > 0 && 
	(WI.fillTextValue("print_pg").compareTo("1") == 0 || WI.fillTextValue("print_pg").compareTo("2") == 0) ) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" colspan="3" bgcolor="#cccccc"><div align="center">:: LIST 
        OF STUDENTS <strong>NOT ALLOWED</strong> TO TAKE THE EXAM FOR SUBJECT 
        <strong><%=WI.fillTextValue("sub_code")%>(<%=WI.fillTextValue("section_name")%>) 
        :: </strong></div></td>
    </tr>
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td width="48%"><b>Total Students : <%=vStudNotAllowed.size()/8%></b> </td>
      <td width="50%" align="right">&nbsp; </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="14%" height="20"><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="19%"><div align="center"><strong><font size="1">STUDENT NAME 
          <br>
          (LNAME,FNAME,MI)</font></strong></div></td>
      <td width="48%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="4%"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
      <td width="9%"><div align="center"><strong><font size="1">REASON</font></strong></div></td>
    </tr>
    <%j=0;
for(int i = 0 ; i< vStudNotAllowed.size(); i +=8,++j){%>
    <tr> 
      <td height="20"><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 1)%></font></td>
      <td><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 2)%></font></td>
      <td><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 3)%> 
        <%if(vStudNotAllowed.elementAt(i + 4) != null){%>
        /<%=(String)vStudNotAllowed.elementAt(i + 4)%>
        <%}%>
        </font></td>
      <td><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 5)%></font></td>
      <td><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 7)%>, No PN</font></td>
    </tr>
    <%}%>
    <input type="hidden" name="save_count" value="<%=j+1%>">
  </table>
<table bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0">
      <tr> 
      <td height="20" align="right">&nbsp; </td>
    </tr>
</table>
<%}//if vStudNotAllowed is not null 
if(vStudWithPN != null && vStudWithPN.size() > 0 && 
	(WI.fillTextValue("print_pg").compareTo("1") == 0 || WI.fillTextValue("print_pg").compareTo("3") == 0) ){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" colspan="3" bgcolor="#cccccc"><div align="center">:: LIST 
        OF STUDENTS <strong>ALLOWED</strong> TO TAKE THE EXAM <strong>WITH PROMISORY 
        NOTE </strong>FOR SUBJECT <strong><%=WI.fillTextValue("sub_code")%>(<%=WI.fillTextValue("section_name")%>) 
        :: </strong></div></td>
    </tr>
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td width="48%"><b>Total Students :</b> <b><%=vStudWithPN.size()/8%></b></td>
      <td width="50%" align="right">&nbsp; </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="13%" height="20"><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">STUDENT NAME 
          <br>
          (LNAME,FNAME,MI)</font></strong></div></td>
      <td width="52%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
    </tr>
    <%j = 0;
for(int i = 0 ; i< vStudWithPN.size(); i +=8,++j){%>
    <tr> 
      <td height="20"><font size="1"><%=(String)vStudWithPN.elementAt(i + 1)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vStudWithPN.elementAt(i + 2)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vStudWithPN.elementAt(i + 3)%> 
        <%if(vStudWithPN.elementAt(i + 4) != null){%>
        /<%=(String)vStudWithPN.elementAt(i + 4)%> 
        <%}%>
        </font></td>
      <td><font size="1"><%=(String)vStudWithPN.elementAt(i + 5)%></font></td>
    </tr>
    <%}%>
    <input type="hidden" name="delete_count" value="<%=j+1%>">
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
      <td height="20" align="right">&nbsp; </td>
  </tr>
</table>
<%}//vStudWithPN is not null 
if(vStudPaidReqdAmt != null && vStudPaidReqdAmt.size() > 0 && 
	(WI.fillTextValue("print_pg").compareTo("1") == 0 || WI.fillTextValue("print_pg").compareTo("4") == 0) ){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" colspan="3" bgcolor="#cccccc"><div align="center">LIST 
          OF STUDENTS WHO HAVE <strong>PAID REQUIRED AMOUNT</strong> AND <strong>ALLOWED</strong> 
          TO TAKE THE EXAM FOR SUBJECT <strong><%=WI.fillTextValue("sub_code")%>(<%=WI.fillTextValue("section_name")%>)</strong></div></td>
    </tr>
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td width="48%"><b>Total Students :</b> <b><%=vStudPaidReqdAmt.size()/8%></b></td>
      <td width="50%" align="right">&nbsp; </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="13%" height="20"><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">STUDENT NAME 
          <br>
          (LNAME,FNAME,MI)</font></strong></div></td>
      <td width="61%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="6%"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
    </tr>
<%
for(int i = 0 ; i< vStudPaidReqdAmt.size(); i +=8){%>
    <tr> 
      <td height="20"><font size="1"><%=(String)vStudPaidReqdAmt.elementAt(i + 1)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vStudPaidReqdAmt.elementAt(i + 2)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vStudPaidReqdAmt.elementAt(i + 3)%> 
        <%if(vStudPaidReqdAmt.elementAt(i + 4) != null){%>
        /<%=(String)vStudPaidReqdAmt.elementAt(i + 4)%> 
        <%}%>
        </font></td>
      <td><font size="1"><%=(String)vStudPaidReqdAmt.elementAt(i + 5)%></font></td>
    </tr>
<%}%>
  </table>
<%}//vStudPaidReqdAmt is not null
%>
<script language="JavaScript">
	window.print();
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>
