<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

-->
</style>
</head>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;	
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","collection_letter_ub.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"collection_letter_ub.jsp");
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
%>

<body >


<%



String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);

String strStudInfoList = null;

if(WI.fillTextValue("stud_id_collection_print").length() > 0)
	strStudInfoList = WI.fillTextValue("stud_id_collection_print");
else	
	strStudInfoList = (String)request.getSession(false).getAttribute("stud_list_collection_print");
	

	

if(WI.getStrValue(strStudInfoList).length() == 0) 
	strErrMsg = "Student List not found.";
if(WI.fillTextValue("sy_from").length() == 0 || WI.fillTextValue("semester").length() == 0)
	strErrMsg = "SY-Term is missing.";	
if(strErrMsg != null)  {%>
<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold"><%=strErrMsg%></p>
<%
	return; 
}
Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);

strTemp = "select user_index, fname, mname, lname from user_table where id_number= ?";
java.sql.PreparedStatement pstmtGetName = dbOP.getPreparedStatement(strTemp);

strTemp = "select course_code from course_offered join stud_curriculum_hist on (stud_curriculum_hist.course_index = course_offered.course_index)  "+
 " where stud_curriculum_hist.is_valid =1 and sy_from = "+WI.fillTextValue("sy_from")+
 " and semester = "+WI.fillTextValue("semester")+
 " and user_index = ? ";
java.sql.PreparedStatement pstmtCCode = dbOP.getPreparedStatement(strTemp);
java.sql.ResultSet rs = null;

String strIDNumber = null;
String strBalance  = null;
String strCourseCode = null;
String strUserIndex = null;
String strStudName = null;
while(vStudList.size() > 0){
	strIDNumber = (String)vStudList.remove(0);
	strBalance = (String)vStudList.remove(0);
	
	strUserIndex = null;
	strStudName = null;
	
	pstmtGetName.setString(1, strIDNumber);
	rs= pstmtGetName.executeQuery();
	if(rs.next()){
		strUserIndex = rs.getString(1);
		strStudName = WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 5);
	}rs.close();
	
	if(strUserIndex == null)
		continue;
		
	pstmtCCode.setString(1, strUserIndex);
	rs= pstmtCCode.executeQuery();
	if(rs.next())
		strCourseCode = rs.getString(1);		
	rs.close();
	
String[] astrConvertSem = {"Summer","1st Semester", "2nd Semester", "3rd Semester", "4th Semester"};


int iSYTo = Integer.parseInt(WI.fillTextValue("sy_from")) + 1;
%>


<table bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="33%" align="right" style="padding-right:40px;">
		<img src="../../../images/logo/UB_BOHOL.gif" border="0" height="80">		</td>
	    <td width="67%" style="font-size:14px;">
		<%=strSchName%><BR>
			  <font style="font-size:12px;"><%=strSchAddr%><BR></font>		</td>
	</tr>
	<tr><td colspan="2" align="center" style="font-size:13px;"><strong>COLLECTION LETTER</strong></td> </tr>
	<tr>
	    <td colspan="2" align="center" style="font-size:13px;"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")%>-<%=iSYTo%></td>
    </tr>
	<tr>
	    <td colspan="2" align="center" style="font-size:13px;">&nbsp;</td>
    </tr>
	<tr>
	    <td colspan="2" style="font-size:12px; padding-left:40px;"><strong><%=strStudName%></strong></td>
    </tr>
	<tr>
	    <td colspan="2" style="font-size:12px; padding-left:40px;"><strong><%=strIDNumber%> &nbsp; &nbsp; &nbsp; <%=strCourseCode%></strong></td>
    </tr>
	<tr>
	    <td colspan="2" align="center" style="font-size:13px;">&nbsp;</td>
    </tr>
	<tr>
	    <td colspan="2" style="font-size:12px; padding-left:40px; text-indent:50px;">Good day!</td>
    </tr>
	<tr>
	    <td colspan="2" align="center" style="font-size:13px;">&nbsp;</td>
    </tr>
	<tr>
	    <td colspan="2" style="font-size:12px; padding-left:40px; text-indent:50px;">
			This is to remind you of your tuition fee balance 
			<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")%>-<%=iSYTo%>
			amounting <strong><%=CommonUtil.formatFloat(strBalance,true)%></strong> as of <strong><%=WI.getTodaysDate(6)%></strong>.		</td>
    </tr>
	<tr>
	    <td colspan="2" align="center" style="font-size:13px;">&nbsp;</td>
    </tr>
	<tr>
	   <td colspan="2" style="font-size:12px; padding-left:40px; text-indent:50px;">
	   	We appreciate if you can settle your account the soonest possible time.	   </td>
    </tr>
	<tr>
	    <td colspan="2" align="center" style="font-size:13px;">&nbsp;</td>
    </tr>
	<tr>
	   <td colspan="2" style="font-size:12px; padding-left:40px; text-indent:50px;">
	   	Please disregard this reminders if payment has been made. 	   </td>
    </tr>
	<tr>
	    <td colspan="2" style="font-size:12px; padding-left:40px; text-indent:50px;">&nbsp;</td>
    </tr>
	<tr>
	    <td colspan="2" style="font-size:12px; padding-left:40px; text-indent:50px;">&nbsp;</td>
    </tr>
	<tr>
	    <td height="18" colspan="2" align="right"><!--<strong>Dr. Maricel A. Tirol</strong>--></td>
    </tr>
	<tr>
	    <td height="18" colspan="2" align="right">Office of Treasurer</td>
    </tr>
	<tr>
	    <td height="18" colspan="2" align="right"><%=strSchName%></td>
    </tr>
</table>
<%
if(vStudList.size() > 0){
%>
<div style="page-break-after:always;">&nbsp;</div>
<%}%>

<%}
request.getSession(false).removeAttribute("stud_list_collection_print");
%>

<script language="JavaScript">
window.print();
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>