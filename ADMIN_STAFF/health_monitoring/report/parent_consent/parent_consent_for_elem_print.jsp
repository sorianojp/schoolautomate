<%@ page language="java" import="utility.*, health.HealthExamination ,java.util.Vector " %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 13px;
}



</style>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
 	String strErrMsg = null;
	String strTemp = null;
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Report","parent_consent_for_elem_print.jsp");		
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
														"Health Monitoring","Report",request.getRemoteAddr(),
														"parent_consent_for_elem_print.jsp");
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


enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();


Vector vBasicInfo = null;
String strParentname = null;
boolean bolIsBasic = false;
vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("id_number"));	
if(vBasicInfo == null)
	strErrMsg = OAdm.getErrMsg();
else{

	if(vBasicInfo.elementAt(7) == null)
			bolIsBasic = true;
	
	strTemp = 
		" select f_name, m_name, con_per_name "+
		" from INFO_PARENT "+
		" left join INFO_CONTACT on (INFO_CONTACT.USER_INDEX = INFO_PARENT.USER_INDEX) "+
		" where INFO_PARENT.USER_INDEX = "+(String)vBasicInfo.elementAt(12);
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	if(rs.next()){
		if(rs.getString(1) != null)
			strParentname = rs.getString(1);
		else if(rs.getString(2) != null)
			strParentname = rs.getString(2);
		else
			strParentname = rs.getString(3);
	}rs.close();
}	
	
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,false);
 
%>
<body <%if(strErrMsg == null){%>onLoad="window.print();"<%}%>>
<%if(strErrMsg == null){
	strErrMsg = Integer.toString( 180 - strSchoolName.length() * 2 );
%>
<div style="position:absolute; left:<%=strErrMsg%>px;"><img src="../../../../images/logo/<%=strSchCode%>.gif" width="70" height="70"></div>
<table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr bgcolor="#FFFFFF">
      <td width="5%" height="25" valign="top">
          <p ALIGN="CENTER">&nbsp;</p>        </td>
      <td height="25" valign="top"><p ALIGN="CENTER"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
      BASIC EDUCATION DEPARTMENT</strong><br>
       <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>Tel. No. 295-1454</p><br>
	   <p align="center"><strong>SCHOOL CLINIC</strong></p><br><strong><p align="center"><font size="3">PARENT'S CONSENT</font><br>
		  <font size="2">PRESCHOOL/ELEMENTARY DEPARTMENT</font></p></strong><br><br>
        <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		<td width="7%"></td>
		<td width="65%" align="center" valign="bottom">&nbsp;</td>
		<td width="28%" height="20" align="center" valign="bottom"><u><%=WI.getTodaysDate(6)%></u></td>
		</tr>
		<tr>
		<td width="7%"></td>
		<td height="20" align="center" valign="bottom">&nbsp;</td>
		<td height="20" align="center" valign="bottom"> Date</td>	   
		</tr>
	<tr>
		<td height="70" colspan="3">&nbsp;</td>
	</tr>
	
	<tr><td colspan="3"><strong>Dear PARENT/GUARDIAN,</strong></td></tr>
	<tr><td colspan="3" height="70"></td></tr>
	<tr>
		<td style="text-indent:40px; text-align:justify;" colspan="3">
			As part of the Enrollment Process the School Physician will do <strong>PHYSICAL EXAMINATION</strong> 
			on your SON/DAUGHTER and School Dentist will also do <strong>DENTAL EXAMINATION</strong> to your child.		</td>
	</tr>
	<tr><td colspan="3" height="70"></td></tr>
	<tr>
		<td style="text-indent:40px; text-align:justify;" colspan="3">
			Moreover, In case of Emergency wherein your <strong>SON/DAUGHTER</strong> 
			needs immediate Medical Attention, Parents and Guardians will be informed <strong>IMMEDIATELY</strong>.		</td>
	</tr>
	<tr><td colspan="3" height="70"></td></tr>
	<tr><td colspan="3">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
	<tr>
	<td valign="bottom" width="44%" align="left"><div style="border-bottom:solid 1px #000000; width:80%;"><%=WI.getStrValue(strParentname,"&nbsp;")%></div>	</td>
	<%
	strTemp = WebInterface.formatName((String)vBasicInfo.elementAt(0),(String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4);
	%>
	<td valign="bottom" width="33%" align="center"><div style="border-bottom:solid 1px #000000;"><%=strTemp%></div></td>
	<%
	if(bolIsBasic)
		strTemp = dbOP.getBasicEducationLevelNew(Integer.parseInt((String)vBasicInfo.elementAt(14)));
	else
		strTemp = (String)vBasicInfo.elementAt(14);
	%>
	<td width="23%" align="center"><div style="border-bottom:solid 1px #000000; width:80%;"><%=WI.getStrValue(strTemp,"N/A")%></div></td>
	</tr>
	<tr>
	<td align="left">Parent's/Guardian's Name and Signature</td>
	<td align="center">Name of Son/Daughter</td>
	<td align="center">Yr./Sec.</td>
	</tr>
	</table>
	</td></tr> 
	
	<tr><td colspan="3" height="70"></td></tr>
	<tr>
		<td valign="top"><strong>Note:</strong>		</td>
	   <td colspan="2" style="text-align:justify;"><strong>This Consent shall be effective until your SON/DAUGHTER graduates from SPC unless sooner terminated by your personal withdrawal of the same </strong></td>
	</tr>
	<tr><td colspan="3" height="70"></td></tr>
	<tr><td colspan="3">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
	<tr>
	<td width="37%" colspan="2" rowspan="2">&nbsp;</td>
	<td width="32%" align="center" valign="bottom">
		<div style="border-bottom:solid 1px #000000; width:80%;"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "School Nurse",7))%></div></td>
	</tr>
	<tr>
	<td align="center">SCHOOL NURSE</td>
	</tr>
	</table>
	</td></tr> 
	</table>
    </td>
      <td width="5%" height="25" valign="top">&nbsp;</td>
    </tr>
  </table>
  <%}else{%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center"><strong><font color="#FF0000" size="2"><%=WI.getStrValue(strErrMsg)%></font></strong></td></tr>
</table>
<%}%>
  </body>
  
<%
dbOP.cleanUP();
%>