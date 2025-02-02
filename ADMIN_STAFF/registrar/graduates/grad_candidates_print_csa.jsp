<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td.subheader {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}	

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }
    TD.thinborderLRB {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }

</style>
<script language="javascript">
	function getDateInput() {
		strDateInput = prompt('Please enter date.','');
		if(strDateInput != null) {
			document.getElementById("date_info_").innerHTML = strDateInput;
			window.print();
		}
	}
</script>
<body onLoad="getDateInput();">
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolShowEditInfo = false;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_candidates_print.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_candidates_print.jsp");
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

Vector vRetResult = null;
EntranceNGraduationData eng = new EntranceNGraduationData();
String strCollegeName = null;
String strCollegeCode = null;

if(WI.fillTextValue("course_index").length() > 0) {
	vRetResult = eng.operateOnCandidatesList(dbOP,request, 5);
	if (vRetResult == null)
		strErrMsg = eng.getErrMsg();
	else {System.out.println(vRetResult);
		String strSQLQuery = "select c_code, c_name from college join course_offered on (course_offered.c_index = college.c_index) "+
							" where course_index = "+WI.fillTextValue("course_index");
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strCollegeCode = rs.getString(1);
			strCollegeName = rs.getString(2);
		}
		rs.close();
	}
}
else {
	strErrMsg = "Please select a course.";
}

String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
%>
<form>
<% if (vRetResult !=null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="2" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" colspan="5" align="right"><%=WI.getTodaysDate(6)%>
<div align="left">
The Dean<br>
<%=strCollegeName%><br>
Colegio San Agustin –Bacolod<br>
Bacolod City<br>
Sir/Madam:<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Please be informed that the following students from your department have applied for graduation and
will be recommended for Special Order with the Commission on Higher Education (CHED)provided they shall
have passed the subjects enrolled this <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, 
<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%> and shall have complied the deficiency/ies
indicated after each name on <label id="date_info_"></label>.	
</div>	
	<br><div align="center">
	<font style="font-weight:bold; font-size:18px;">
		<u><%=strCollegeName%> (<%=strCollegeCode%>)</u><br>&nbsp;&nbsp;
	</font>
	</div>
	</td>
</tr>
</table>
<%
int iMaxLines = 40; int iStudCount = 0;int iPageNo = 1; boolean bolBreakToBegin = false; boolean bolPrintPageNo = false;
String strGender = null;
while(vRetResult.size() > 0) {
strGender = (String)vRetResult.elementAt(2);
iStudCount = 0;
if(bolBreakToBegin) {bolBreakToBegin = false;%>
	<!--<DIV style="page-break-after:always" >&nbsp;</DIV>-->
<%}%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td colspan="2" style="font-weight:bold;" align="center">
			<%if(strGender.equals("M")){%>
				<u>MALE</u>
			<%}else{%>
				<u>FEMALE</u>
			<%}%>
			</td>
		</tr>
		<tr>
			<td style="font-weight:bold;"><u>NAME</u></td>
			<td width="50%" style="font-weight:bold;" align="center"><u>DEFICIENCIES</u></td>
		</tr>
	</table>
	<%while(vRetResult.size() > 0) {
		if(bolBreakToBegin)
			break;
			
		if(bolPrintPageNo) {%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<font style="font-weight:bold">
			<%=strCollegeCode%> - Page <%=iPageNo%>
		</font>
		<%bolPrintPageNo = false;}%>
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<%while(vRetResult.size() > 0) {%>		
				<tr>
					<td width="2%" height="22"><%=++iStudCount%>. </td>
					<td width="48%"><%=vRetResult.elementAt(1)%></td>
					<td width="50%"><%=WI.getStrValue(vRetResult.elementAt(4), "&nbsp;")%></td>
				</tr>
				<%
					vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
					if(vRetResult.size() == 0 || !strGender.equals(vRetResult.elementAt(2))) {
						bolBreakToBegin = true;
						break;
					}
					if(iStudCount % iMaxLines == 0) {
						++iPageNo;
						bolPrintPageNo = true;
						break;
					}
			}%>
		</table>
	<%}%>
	


<%}//while true.. %>
<Br><br>
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<tr>
			<td width="10%"></td>
			<td width="54%"></td>
			<td align="center" width="40%"> Truly Yours, <br><br><br>
				<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7), "FR. NOEL P. COGASA, O.S.A.")%>
				<br>
				Registrar
			</td>
		</tr>
		<tr>
			<td align="right" valign="top">NOTE: &nbsp;</td>
			<td>
			<font style="font-weight:bold">
				Please check with Record's Office for Any omission or correction of your name.
			</font>
			</td>
			<td></td>
		</tr>
	</table>



<%}else{ // end vRetResult = null%>
<font size="3">&nbsp; <%=strErrMsg%></font>
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
