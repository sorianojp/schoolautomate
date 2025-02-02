<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;
	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Verify","grade_sheet_verify.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets Verification",request.getRemoteAddr(),
									null);

}

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
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();
String strEmployeeIndex    = null;

String strEmployeeID = WI.fillTextValue("emp_id");
if(strEmployeeID.length() > 0)
	strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);

String strSubSecIndex   = null;

Vector vRetResult = null;
Vector vPendingGrade = new Vector();
Vector vEncodedGrade = new Vector();

strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("1") == 0) //save grade sheet.
{
	if(gsExtn.verifyGrade(dbOP, WI.fillTextValue("section"),1,
		(String)request.getSession(false).getAttribute("login_log_index")) )
		strErrMsg = "Grade sheet verified. Only registrar can modify grade.";
	else	
		strErrMsg = gsExtn.getErrMsg();
}
else if(strTemp.compareTo("0") == 0) { //call for delete.
	if(gsExtn.verifyGrade(dbOP, WI.fillTextValue("section"),0,
		(String)request.getSession(false).getAttribute("login_log_index")) )
		strErrMsg = "Grade sheet verification removed successfully. Faculty can modify this grade.";
	else	
		strErrMsg = gsExtn.getErrMsg();
}

//get here necessary information.
if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
						" and e_sub_section.offering_sem="+
						WI.fillTextValue("offering_sem")+" and is_lec=0");
						
}
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

//Get here the pending grade to be encoded list and list of grades encoded.
if(strSubSecIndex != null) {
	vEncodedGrade = gsExtn.getStudListForGradeSheetEncoding(dbOP, WI.fillTextValue("grade_for"),strSubSecIndex,true);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");
String[] astrConvSemester = {"SUMMER", "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER"};
%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" ><div align="center">
	  <font size="3"><b><%=SchoolInformation.getSchoolName(dbOP,true,false)%></b></font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div><br></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" colspan="3" align="center"><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> &nbsp;
	  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
    </tr>
  </table>
  <table border=0 cellpadding="0" cellspacing="0" width="100%">
    <tr>
<% if(WI.fillTextValue("subject").length() > 0)
		strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",WI.fillTextValue("subject"),"sub_code"," and is_del<>1");
	else
		strTemp = "";
%>
      <td width="12%" height="25" valign="bottom">Subject Code:</td>
      <td width="16%" valign="bottom" class="thinborderBottom"><strong>&nbsp;<%=strTemp%></strong></td>
      <%
if(WI.fillTextValue("subject").length() > 0)
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",WI.fillTextValue("subject"),"sub_name"," and is_del<>1");
else
	strTemp = "";
 %>
      <td width="13%" valign="bottom"><div align="right">Subject Title: </div></td>
      <td width="41%" valign="bottom" class="thinborderBottom"><strong>&nbsp;<%=strTemp%></strong></td>
      <td width="18%" valign="bottom">&nbsp;&nbsp;Units: <u><strong><%=GS.getLoadingForSubject(dbOP, request.getParameter("subject"))%></strong></u></td>
    </tr>
    <tr>
      <td height="25" valign="bottom">Schedule:</td>
      <td colspan="2" valign="bottom" class="thinborderNone">
	  <%if(vSecDetail != null){%>
          <%=WI.getStrValue(vSecDetail.elementAt(3)).toUpperCase()%> 
      <%}%>      <div align="right"></div></td>
      <td valign="bottom" class="thinborderNone" align="right">Section :</td>
      <td valign="bottom"><span class="thinborderNone"><strong><%=WI.fillTextValue("section_name")%></strong></span></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr> 
      <td width="60%"><div align="center"> <strong> 
          <%if(vSecDetail != null){%>
          <%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%> 
          <%}%>
          </strong></div></td>
      <td width="40%">&nbsp;</td>
    </tr>
    <tr> 
      <td><div align="center">NAME OF INSTRUCTOR(S)</div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td align="right" style="font-size:10px;">Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
<%
 if(vEncodedGrade != null && vEncodedGrade.size() > 0){%> 
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="4%" class="thinborder"><font size="1"><strong>SL. #</strong></font></td> 
      <td width="15%"  height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID </strong></font></div></td>
      <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME </strong></font></div></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>COURSE</strong></font></td>
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>YEAR</strong></font></td>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>CREDIT EARNED</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>GRADE</strong></font></td>
<%if(bolIsCGH){%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>%ge GRADE</strong></font></td>
      <%}%>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <%
j = 0;
int iIndexOf = 0; String strCGHGrade = null;
for(int i=0; i<vEncodedGrade.size(); i += 9,++j){
	iIndexOf = gsExtn.vCGHGrade.indexOf(vEncodedGrade.elementAt(i));
	if(iIndexOf > -1) {
		strCGHGrade = (String)gsExtn.vCGHGrade.elementAt(iIndexOf + 1);
		gsExtn.vCGHGrade.removeElementAt(iIndexOf);gsExtn.vCGHGrade.removeElementAt(iIndexOf);
	}
	else	
		strCGHGrade = null;%>
    <tr>
      <td class="thinborder"><%=j + 1%>.</td> 
      <td  height="25" class="thinborder"><font size="1"><%=(String)vEncodedGrade.elementAt(i+1)%></font> </td>
      <td class="thinborder"><font size="1"><%=(String)vEncodedGrade.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vEncodedGrade.elementAt(i+3)%> 
        <% if(vEncodedGrade.elementAt(i + 4) != null){%>
        :: <%=(String)vEncodedGrade.elementAt(i+4)%> 
        <%}%>
        </font></td>
      <td align="center" class="thinborder"><font size="1"><%=WI.getStrValue(vEncodedGrade.elementAt(i+5),"N/A")%></font></td>
      <td align="center" class="thinborder"><font size="1">
	  <%strTemp = (String)vEncodedGrade.elementAt(i+6);
	  if(bolIsCGH && strTemp != null && strTemp.endsWith(".0"))
	  	strTemp = strTemp + "0";
	  %>
	  <%=strTemp%></font></td>
      <td align="center" class="thinborder"><font size="1">
	  	  <%
		  strTemp = (String)vEncodedGrade.elementAt(i+7);
		  iIndexOf = -1;
		  if(bolIsCGH && strTemp != null)
		  	iIndexOf = strTemp.indexOf(".");
		  if(iIndexOf > -1 && strTemp.substring(iIndexOf).length() == 2)
		  	strTemp = strTemp + "0";
	  %>
	  <%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
<%if(bolIsCGH){%>
      <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue(strCGHGrade, "&nbsp;")%></td>
<%}%>
      <td align="center" class="thinborder"><font size="1"><%=(String)vEncodedGrade.elementAt(i+8)%></font></td>
    </tr>
    <%}%>
  </table>
<%}//end of showing encoded grade 
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
