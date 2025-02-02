<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
body{ 
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}

td{ 
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}

td.thinBorder{ 
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
	border-left:#000000 1px solid ;
	border-bottom:#000000 1px solid ;	
}

td.thinBorderBottom{ 
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
	border-bottom:#000000 1px solid ;	
}

td.thinBorderLeft{ 
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
	border-left:#000000 1px solid ;
}
table.thinBorder{
	border-top:#000000 1px solid ;
	border-right:#000000 1px solid ;
	border-bottom:#000000 1px solid ;
}

</style>
</head>

<body>
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strTemp    = null;
	
	if (strSchCode == null) 
		strSchCode = "";
	
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	Vector vSecDetail = null;

	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet.jsp");
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
									"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),
									null);

}

//I have to check if grade sheet is locked.. 
if(new enrollment.SetParameter().isGsLocked(dbOP))
	iAccessLevel = 0;

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
enrollment.SubjectSectionCPU   ssCPU = new enrollment.SubjectSectionCPU();
GradeSystemExtn gsExtn   = new GradeSystemExtn();


String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
String strSubSecIndex   = WI.fillTextValue("sub_sec_index");
String strSubject = null; 
Vector vRetResult = null;
Vector vPendingGrade = null;
Vector vEncodedGrade = null;
String strCollegeName = null;
String strTimeLab = null;
String strDaysLab = null;
String strRoomLab = null;
String strSubIndex = null;
//getLabSched

//get here necessary information.

if(strSubSecIndex != null && strSubSecIndex.length() > 0) {//get here subject section detail.

	
	

	vSecDetail = ssCPU.getOfferingPerCollege(dbOP, request, strSubSecIndex,null);
	if (vSecDetail == null)
		strErrMsg = ssCPU.getErrMsg();
	
	if (strErrMsg == null) {
		// get the offering college or department
		strCollegeName = (String)vSecDetail.elementAt(1);
		
		if (strCollegeName == null)
			strCollegeName = (String)vSecDetail.elementAt(3);
		else
			strCollegeName += WI.getStrValue((String)vSecDetail.elementAt(3), "/","","");
	}
	
		strSubject = (String)vSecDetail.elementAt(4) + " &nbsp;&nbsp;(" + (String)vSecDetail.elementAt(5)+")";
		
}else{
	strErrMsg = " Unable to get Stub Code. Please try again.";
}

//Get here the pending grade to be encoded list and list of grades encoded.
if(strSubSecIndex != null && strSubSecIndex.length() > 0) {
	vRetResult = gsExtn.getStudListForGradeSheetEncoding(dbOP, WI.fillTextValue("grade_for"),
												strSubSecIndex,false);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else {
		vEncodedGrade = (Vector)vRetResult.elementAt(0);
		vPendingGrade = (Vector)vRetResult.elementAt(1);
//		System.out.println(vRetResult);
	}	

}

String[] astrConvSemester = {"SUMMER", "1ST SEMESTER", "2ND SEMESTER", ""};

String strSemester = WI.fillTextValue("offering_sem");
String strSchoolYear = WI.fillTextValue("sy_to");

if (!strSemester.equals("0"))
	strSchoolYear = WI.fillTextValue("sy_from") + "-"+ strSchoolYear;


if (strErrMsg != null && strErrMsg.length() > 0) 
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>
</table>
<%
if(vSecDetail != null ){
%>

  <table width="98%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="14%" rowspan="6" valign="top"><div align="center">
	  <img src="../../../images/logo/CPU_LOGO.gif" width="100" height="95"></div></td>
      <td height="15" colspan="2" valign="bottom" ><strong>
	  <font size="2" face="Times New Roman, Times, serif">COLLEGIATE GRADE SHEET</font></strong> </td>
    </tr>
    <tr>
      <td height="18" colspan="2" ><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
        <tr>
          <td width="46%" height="18" >&nbsp;<%=astrConvSemester[Integer.parseInt(WI.getStrValue(strSemester,"1"))] + 
									" " + strSchoolYear%>		  </td>
          <td width="30%" height="18" ><%=strCollegeName%></td>
          <td width="24%" >&nbsp;Stubcode : <%=strSubSecIndex%></td>
        </tr>
      </table></td>
    </tr>
    <tr>
      <td height="18" colspan="2" >COURSE NO:  <%=WI.getStrValue(strSubject)%> </td>
    </tr>
    <tr>
      <td width="9%" height="18" >TEXTBOOK: </td>
      <td width="77%" height="18" class="thinBorderBottom" >&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="2" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="13%">INSTRUCTOR: </td>
            <td width="50%" class="thinBorderBottom">&nbsp;
			<%=WI.formatName((String)vSecDetail.elementAt(18),
				(String)vSecDetail.elementAt(19),
				(String)vSecDetail.elementAt(20),4)%> </td>
            <td width="18%">NO. HRS/WK &nbsp;LEC: </td>
            <td width="6%" class="thinBorderBottom">&nbsp;</td>
            <td width="7%">&nbsp;&nbsp;LAB: </td>
            <td width="6%" class="thinBorderBottom">&nbsp;</td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="18" colspan="2" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="5%">LEC: </td>
          <td width="13%" class="thinBorderBottom">&nbsp;</td>
          <td width="5%" align="right">DAY: </td>
          <td width="10%" class="thinBorderBottom">&nbsp;</td>
          <td width="6%" align="right">ROOM:</td>
          <td width="10%" class="thinBorderBottom">&nbsp;</td>
          <td width="5%" align="right">LAB: </td>
          <td width="12%" class="thinBorderBottom">&nbsp;</td>
          <td width="5%" align="right">DAY: </td>
          <td width="10%" class="thinBorderBottom">&nbsp;</td>
          <td width="7%" align="right">ROOM: </td>
          <td width="10%" class="thinBorderBottom">&nbsp;</td>
        </tr>
      </table></td>
    </tr>
  </table>
<% }

 if(vEncodedGrade != null && vEncodedGrade.size() > 0){
 
 %> 
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinBorder">
    <tr> 
      <td width="3%"  height="25" class="thinBorder" >&nbsp;NO.</td>
      <td width="11%"  height="25" align="center" class="thinBorder"><font size="1" face="Geneva, Arial, Helvetica, sans-serif">CLASSIFICA-<br>
        TION EX,<br>
      BSE2       </font></td>
      <td width="39%" class="thinBorder" ><div align="center"><font size="1" face="Geneva, Arial, Helvetica, sans-serif"><strong>NAMES</strong></font></div></td>
      <td width="5%" align="center" class="thinBorder"><strong><font size="1" face="Geneva, Arial, Helvetica, sans-serif"><strong>GRADE</strong></font></strong></td>
      <td width="6%" align="center" class="thinBorder"><strong><font size="1" face="Geneva, Arial, Helvetica, sans-serif">CREDIT</font></strong></td>
      <td width="7%" align="center" class="thinBorder"><font size="1" face="Geneva, Arial, Helvetica, sans-serif">GRADE REMARK</font></td>
      <td width="7%" align="center" class="thinBorder"><strong><font size="1" face="Geneva, Arial, Helvetica, sans-serif">ATTEN-<br>
DANCE<br>
S-<br>
P-</font></strong></td>
      <td width="15%" align="center" class="thinBorder"><font size="1" face="Geneva, Arial, Helvetica, sans-serif">FINAL REMARK </font></td>
     </tr>
<%
	j = 0;
	String strFontColor = null;
	int intMaxRows = 9; // final..
boolean bolFinal = false;
String strGradeName = dbOP.mapOneToOther("FA_PMT_SCHEDULE", "PMT_SCH_INDEX",
                                      WI.fillTextValue("grade_for"), "EXAM_NAME", null);

if (strGradeName.toLowerCase().startsWith("final")){
	intMaxRows = 11;
	bolFinal = true;
}
	
	
for(int i=0; i<vEncodedGrade.size(); i += intMaxRows,++j){
if( ((String)vEncodedGrade.elementAt(i+8)).toLowerCase().startsWith("f"))
	strFontColor = " color=red";
else	
	strFontColor = "";
%>
    <tr> 
      <td class="thinBorderLeft">&nbsp;<%=j + 1%></td>
      <td  height="18" class="thinBorderLeft" >&nbsp;<%=(String)vEncodedGrade.elementAt(i+3)%>
          <% if(vEncodedGrade.elementAt(i + 4) != null){%>
:: <%=(String)vEncodedGrade.elementAt(i+4)%>
<%}%>
      <%=WI.getStrValue(vEncodedGrade.elementAt(i+5))%></td>
      <td class="thinBorderLeft" >&nbsp;<%=(String)vEncodedGrade.elementAt(i+2)%></td>
      <td align="center" class="thinBorderLeft"><strong><%=WI.getStrValue(vEncodedGrade.elementAt(i+7),"&nbsp;")%></strong></td>
      <td align="center" class="thinBorderLeft"><%=(String)vEncodedGrade.elementAt(i+6)%></td>
      <td align="center" class="thinBorderLeft"><%=(String)vEncodedGrade.elementAt(i+8)%></td>
      <td align="center" class="thinBorderLeft">
	  <% if (bolFinal) {%> 
	  <%=WI.getStrValue((String)vEncodedGrade.elementAt(i+9),"&nbsp;")%>
	  
	  <%}else{%> &nbsp;<%}%> 
	  </td>
      <td align="center" class="thinBorderLeft">
	  <% if (bolFinal) {%> 	  
	  <%=WI.getStrValue((String)vEncodedGrade.elementAt(i+10),"&nbsp;")%>
  	  <%}else{%> &nbsp;<%}%> 
	  </td>
     </tr>
<%}%>
</table>
<font size="1"> Printed on : <%=WI.getTodaysDate(10)%> // <%=strEmployeeID%></font>
<%}//end of showing encoded grade  %>
</body>
</html>
<%
dbOP.cleanUP();
%>
