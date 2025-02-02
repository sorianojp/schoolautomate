<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED BILLING - PRINT ONE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.CITChedBilling,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CHED Scholar-manage Scholarship Type","master_file_print.jsp");
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
														"Registrar Management","CHED SCHOLAR",request.getRemoteAddr(),
														"master_file.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

CITChedBilling CCB = new CITChedBilling();
Vector vRetResult = null; 
String[] astrConvertSem = {"Summer","First Semester","Second Semester"};

String strSYFrom = null;
String strSYTo   = null;
String strSem    = null;
    Vector vEnrolledInfo = new Vector();
    Vector vAssessment   = new Vector();

String strInfoIndex = WI.fillTextValue("info_i");
if(strInfoIndex.length() > 0) {
	vRetResult = CCB.printIndividualReport(dbOP, strInfoIndex);
	if(vRetResult == null)
		strErrMsg = CCB.getErrMsg();
	else {
		strSYFrom = (String)vRetResult.elementAt(3);
		strSYTo   = String.valueOf(Integer.parseInt((String)vRetResult.elementAt(3)) + 1);
		strSem    = (String)vRetResult.elementAt(4);
		
		vEnrolledInfo = (Vector)vRetResult.elementAt(17);
		vAssessment   = (Vector)vRetResult.elementAt(18);
	}
}

%>
<%if(strErrMsg != null) {%>
<%=strErrMsg%>
<%}%>

<%if(vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td height="25" colspan="2" align="center"><font size="3">
	  Republic of the Philippines<br>Office of the President<br>
	  COMMISSION ON HIGHER EDUCATION<br>
		3/F LDM Bldg., M.J. Cuenco Ave. cor. Legaspi Street<br>
		Cebu City<br><br>
		<strong>PRIVATE EDUCATION STUDENT'S ASSISTANCE PROGRAM</strong><br>(PESFA)</font>
		<br>
		&nbsp;	  </td>
    </tr>
	<tr>
	  <td height="25" colspan="2"><p>Congressional District/Party List :</p>
      <p>Congressman:</p></td>
    </tr>
	<tr>
	  <td colspan="2" align="center">&nbsp;</td>
    </tr>
	<tr>
	  <td width="47%">Name of Private College/University</td>
      <td width="53%" style="font-weight:bold">CEBU INSTITUTE OF TECHNOLOGY - UNIVERSITY</td>
	</tr>
	<tr>
	  <td>Address</td>
      <td>N. Bacalso Avenue, Cebu City</td>
	</tr>
	<tr>
	  <td colspan="2" align="center">&nbsp;</td>
    </tr>
	<tr>
	  <td colspan="2" align="center">&nbsp;</td>
    </tr>
	<tr>
	  <td colspan="2" align="center" style="font-weight:bold; font-size:15px;" class="thinborderBOTTOM">CERTIFICATE OF ENROLLMENT AND BILLING</td>
    </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td colspan="2" align="center">&nbsp;</td>
    </tr>
	<tr>
	  <td width="76%" height="20">Date: <strong><%=WI.getTodaysDate(1)%></strong></td>
      <td width="24%">Grant: <strong>Degree</strong> </td>
	</tr>
	<tr>
	  <td height="20">Grantee no.: <strong><%=(String)vRetResult.elementAt(5)%></strong></td>
	  <td>Sex: <strong><%=(String)vRetResult.elementAt(10)%></strong></td>
    </tr>
	<tr>
	  <td height="20">Student Name: <strong><%=(String)vRetResult.elementAt(9)%></strong></td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td height="20" colspan="2">Address: <strong><%=WI.getStrValue((String)vRetResult.elementAt(11))%></strong> </td>
    </tr>
	<tr>
	  <td height="20" colspan="2">Year Level/Course:<strong> <%=WI.getStrValue((String)vRetResult.elementAt(12))%> - 
	  <%=WI.getStrValue((String)vRetResult.elementAt(13))%> (<%=WI.getStrValue((String)vRetResult.elementAt(15))%>)</strong></td>
    </tr>
	<tr>
	  <td height="20">Semester/School Year: <strong><%=astrConvertSem[Integer.parseInt(strSem)]%> - School Year <%=strSYFrom%>-<%=strSYTo%></strong></td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td colspan="2">
	  	<table width="100%" cellpadding="0" cellspacing="0">
			<tr>
				<td width="50%">Subjects Enrolled: <br>&nbsp; </td>
				<td width="50%">&nbsp;</td>
			</tr>
			<tr>
				<td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td width="50%">Subject Code</td>
							<td width="50%">Units</td>
						</tr>
						<%for(int i = 0; i < vEnrolledInfo.size(); i += 2) {%>
							<tr>
								<td height="18"><%=(String)vEnrolledInfo.elementAt(i)%></td>
								<td><%=(String)vEnrolledInfo.elementAt(i + 1)%></td>
							</tr>
						<%}%>
					</table>				</td>
				<td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td width="45%"><strong>ASSESSMENT</strong></td>
							<td width="5%"></td>
						    <td width="23%"></td>
						    <td width="27%"></td>
						</tr>
						<%if(vAssessment != null && vAssessment.size() > 0) {%>
						  <tr>
							  <td height="20">a. Tuition (Total) </td>
							  <td>P</td>
						      <td align="right"><strong><%=vAssessment.elementAt(0)%></strong></td>
						      <td>&nbsp;</td>
						  </tr>
						  <tr>
							  <td height="20">b. Other Fees (Total) </td>
							  <td>P</td>
						      <td align="right"><strong><%=vAssessment.elementAt(1)%></strong></td>
						      <td>&nbsp;</td>
						  </tr>
						  <tr>
							  <td height="20">c. Gross Total </td>
							  <td>P</td>
						      <td align="right"><strong><%=vAssessment.elementAt(2)%></strong></td>
						      <td>&nbsp;</td>
						  </tr>
						<%}%>
					</table>				</td>
			</tr>
		</table>	  </td>
    </tr>
	<tr>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
	</table>
  <br>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	
	<tr valign="bottom">
	  <td width="50%" height="60">________________________________<br>
	    Name and Signature of Student/Grantee </td>
      <td width="50%">Prepared By: </td>
	</tr>
	<tr valign="bottom">
	  <td height="45" align="center">&nbsp;</td>
      <td height="45" align="center"> <u>&nbsp;&nbsp;&nbsp;&nbsp;<%=CommonUtil.getNameForAMemberType(dbOP, "Accountant",7)%>&nbsp;&nbsp;&nbsp;&nbsp;</u><br>Name and Signature of Accountant </td>
	</tr>
	<tr valign="top">
	  <td height="25"><strong>NOTED and RECORDED:</strong> </td>
      <td height="25">&nbsp;</td>
	</tr>
	<tr align="center" valign="bottom">
	  <td height="25"><u>&nbsp;&nbsp;&nbsp;&nbsp;<%=CommonUtil.getNameForAMemberType(dbOP, "Scholarship Coordinator",7)%>&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
	  <td height="25"><u>&nbsp;&nbsp;&nbsp;&nbsp;<%=CommonUtil.getNameForAMemberType(dbOP, "University Head",7)%>&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
    </tr>
	<tr align="center" valign="top">
	  <td height="25">Name and Signature of Scholarship Coordinator</td>
	  <td height="25">College/University Head </td>
    </tr>
</table>
  
<%
}
%>  
</body>
</html>
<%
dbOP.cleanUP();
%>
