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

.leftBorder {
	border-left: dashed #000000 1px;
}
.style1 {font-size: 11px}
-->
</style>
</head>
<%@ page language="java" import="utility.*, clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	Vector vBasicInfo = null;

	String strErrMsg = null;
	String strTemp = null;

	//put in session - not using URL/post.	
	HttpSession curSession = request.getSession(false);
	String strStudID = (String)curSession.getAttribute("stud_id");

//add security here.
	try {
		dbOP = new DBOperation();
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
if(strStudID == null)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();
String strClearanceNo = null;

vBasicInfo = OAdm.getStudentBasicInfo(dbOP, strStudID);
String strOSBalance = null;

if(vBasicInfo == null)
	strErrMsg = OAdm.getErrMsg();
else{
	//strClearanceNo = SOA.autoGenClearanceNum(dbOP, (String)vBasicInfo.elementAt(12), 
    //                                (String)curSession.getAttribute("sy_from"),
	//								(String)curSession.getAttribute("semester"));
	double dOSBal = new enrollment.FAFeeOperation().calOutStandingOfPrevYearSem(dbOP, (String)vBasicInfo.elementAt(12),true, true);
	if(dOSBal > 1.0d)
		strOSBalance = CommonUtil.formatFloat(dOSBal,true);
}

boolean bolFinalClearance = WI.fillTextValue("print_credentials").equals("1");

String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"};
String[] astrConvertYear = {"","1st Year","2nd  Year","3rd  Year","4th Year","5th Year","6th Year","7th Year"};

boolean bolIsBasic = false;
if(vBasicInfo.elementAt(7) == null)
	bolIsBasic = true;

%>
<body <%if(strErrMsg == null){%> onLoad="window.print();"<%}%> topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">

<%if(strErrMsg != null || vBasicInfo == null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
<%dbOP.cleanUP(); return;}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" colspan="2" style="font-size:14px; font-weight:bold" align="center">CLEARANCE FOR FINAL EXAM</td>
    </tr>
    <tr>
      <td height="18" colspan="2" align="center"><%if(!bolIsBasic){%><%=astrConvertTerm[Integer.parseInt((String)curSession.getAttribute("semester"))]%>,<%}%> A Y <%=curSession.getAttribute("sy_from")+"-"+curSession.getAttribute("sy_to")%></td>
    </tr>
    <tr>
      <td height="18" colspan="2">Student #. <u><%=curSession.getAttribute("stud_id")%></u></td>
    </tr>
    <tr>
      <td height="18" colspan="2" style="font-size:14px; font-weight:bold">Name: <u><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),(String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></u></td>
    </tr>
<%if(bolIsBasic){
//I have to find section.
strTemp = "select section,count(*) as count_ from e_sub_section  join enrl_final_cur_list on (e_sub_section.sub_sec_index = enrl_final_cur_list.sub_sec_index) "+
		"where enrl_final_cur_list.is_valid = 1 and user_index = "+(String)vBasicInfo.elementAt(12)+
  		" and enrl_final_cur_list.sy_from = "+(String)vBasicInfo.elementAt(10)+" and current_semester = "+(String)vBasicInfo.elementAt(9)+
		" and is_temp_stud = 0 group by section order by count_ desc";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null)
	strTemp = "";
 %>
    <tr>
      <td height="18" colspan="2">Gr./Yr & Section: <u><%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vBasicInfo.elementAt(14)), false)%> - <%=strTemp%></u></td>
    </tr>
<%}else{%>
    <tr>
      <td height="18" colspan="2">Course/Major: <u><%=vBasicInfo.elementAt(24)%><%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%> - <%=astrConvertYear[Integer.parseInt(WI.getStrValue((String)vBasicInfo.elementAt(14),"0"))]%></u></td>
    </tr>
<%if(((String)vBasicInfo.elementAt(24)).toLowerCase().equals("bsn")){
//I have to find section.
strTemp = "select section,count(*) as count_ from e_sub_section  join enrl_final_cur_list on (e_sub_section.sub_sec_index = enrl_final_cur_list.sub_sec_index) "+
		"where enrl_final_cur_list.is_valid = 1 and user_index = "+(String)vBasicInfo.elementAt(12)+
  		" and enrl_final_cur_list.sy_from = "+(String)vBasicInfo.elementAt(10)+" and current_semester = "+(String)vBasicInfo.elementAt(9)+
		" and is_temp_stud = 0 group by section order by count_ desc";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null)
	strTemp = "";
%>
    <tr>
      <td height="18" colspan="2">Section: <%=strTemp%></td>
    </tr>
	
<%}//show only for BSN%>

<%}%>
    <tr>
      <td height="18" colspan="2"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="71%" height="18" valign="bottom">_____________________________</td>
      <td width="29%" valign="bottom">________________</td>
    </tr>
    <tr>
      <td height="18" valign="top"><%if(bolIsBasic){%>Principal<%}else{%>Dean/Head<%}%></td>
      <td valign="top">Date(mm/dd/yyyy)</td>
    </tr>
    <tr>
      <td width="71%" valign="bottom" height="25">_____________________________</td>
      <td width="29%" valign="bottom">________________</td>
    </tr>
    <tr>
      <td valign="top"><%if(bolIsBasic){%>Prefect of Discipline<%}else{%>Director, Student Affairs &amp; Financial Aid<%}%></td>
      <td valign="top">Date(mm/dd/yyyy)</td>
    </tr>
    <tr>
      <td width="71%" valign="bottom" height="25">_____________________________</td>
      <td width="29%" valign="bottom">________________</td>
    </tr>
    <tr>
      <td valign="top"><%if(bolIsBasic){%>Library<%}else{%>Director, University Library<%}%></td>
      <td valign="top">Date(mm/dd/yyyy)</td>
    </tr>
    <tr>
      <td width="71%" valign="bottom" height="25">_____________________________</td>
      <td width="29%" valign="bottom">________________</td>
    </tr>
    <tr>
      <td valign="top"><%if(bolIsBasic){%>Adviser<%}else{%>Director, University Registrar<%}%><br></td>
      <td valign="top">Date(mm/dd/yyyy)</td>
    </tr>
    <tr>
      <td valign="bottom" height="25">_____________________________</td>
      <td valign="bottom">________________</td>
    </tr>
    <tr>
      <td valign="top">Head, Accounts Management<br></td>
      <td valign="top">Date(mm/dd/yyyy)</td>
    </tr>
    <tr>
      <td valign="top" height="30">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
    
    <tr>
      <td valign="bottom" style="font-weight:bold"><u><%=WI.getStrValue(strOSBalance, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></u></td>
      <td valign="bottom"><u><%=(String)request.getSession(false).getAttribute("first_name")%></u></td>
    </tr>
    <tr>
      <td valign="top" height="20">Unpaid Accounts<br></td>
      <td valign="top">Prepared by</td>
    </tr>
    <tr>
      <td colspan="2" valign="bottom" style="font-weight:bold">Note: Only fresh Signatures of authorized signatories shall be honored</td>
    </tr>
    
    <tr>
      <td colspan="2" valign="bottom" height="28">AUF-FORM-AFO-17<%if(bolIsBasic){%>.1<%}%></td>
    </tr>
    <tr>
      <td colspan="2" valign="bottom" height="18"><%if(bolIsBasic){%>February 1, 2009- Rev. 00<%}else{%>Sept. 15, 2008-Rev.01<%}%></td>
    </tr>
  </table>
</body>
</html>

<%
//remove information from session.
		curSession.removeAttribute("stud_id");
		curSession.removeAttribute("sy_from");
		curSession.removeAttribute("sy_to");
		curSession.removeAttribute("semester");
		curSession.removeAttribute("type_index");
dbOP.cleanUP();
%>