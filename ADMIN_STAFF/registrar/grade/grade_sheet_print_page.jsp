<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
	
boolean bolIsUB = strSchoolCode.startsWith("UB");
boolean bolIsNEU = strSchoolCode.startsWith("NEU");
if(bolIsUB){%>
	<jsp:forward page="./grade_sheet_final_report_print_UB.jsp"></jsp:forward>
<%return;}
	
boolean bolIsVMUF = strSchoolCode.startsWith("VMUF");	
boolean bolIsCSA = strSchoolCode.startsWith("CSA");	

String strFontSize = "9px";
if(bolIsNEU)
	strFontSize = "11px";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	<%if(bolIsNEU){%>
	width:100%;
	height:100%;
	position:relative;
	<%}%>
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
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
	font-size: 11px;
    }
-->
</style>
</head>

<body>

<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	
	boolean bolIsFinalCopy = (WI.fillTextValue("is_final_copy").equals("1"));
	
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheet Print","grade_sheet_print_page.jsp");
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
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(), null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(), null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Printing",request.getRemoteAddr(), null);
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
enrollment.SubjectSection SS = new enrollment.SubjectSection();

String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex");
String strSubSecIndex   = WI.fillTextValue("section");

Vector vEncodedGrade = null;

Vector vEmpRec = new enrollment.Authentication().getBasicInfo(dbOP,strEmployeeID,strEmployeeIndex,request);

//get here necessary information.
if(strSubSecIndex.length() > 0 && WI.fillTextValue("section_name").length() > 0 && 
		WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
						" and e_sub_section.offering_sem="+WI.fillTextValue("offering_sem")+" and is_lec=0");
						
}
if(strSubSecIndex != null && strSubSecIndex.length() == 0)
	strSubSecIndex = null;
	
String strUnit = null;
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
	else{
		strTemp = "select sub_index from e_sub_section where sub_sec_index = "+strSubSecIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null)
			strUnit = GS.getLoadingForSubject(dbOP, strTemp);
	}		
}

//Get here the pending grade to be encoded list and list of grades encoded.
if(strSubSecIndex != null) {
	vEncodedGrade = gsExtn.getStudListForGradeSheetEncoding(dbOP, WI.fillTextValue("grade_for"),strSubSecIndex,true);
	if(vEncodedGrade == null)
		strErrMsg = gsExtn.getErrMsg();
}
String strGradesFor = dbOP.mapOneToOther("FA_PMT_SCHEDULE","PMT_SCH_INDEX",WI.fillTextValue("grade_for"),
	  		"EXAM_NAME",null);
int iTemp = strGradesFor.toLowerCase().indexOf(" exam");
if(iTemp != -1)
	strGradesFor = strGradesFor.substring(0,iTemp);
	
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
if(bolIsUB || bolIsNEU){
	astrConvertToSem[0] = "SUMMER";
	astrConvertToSem[1] = "FIRST SEMESTER";
	astrConvertToSem[2] = "SECOND SEMESTER";
	astrConvertToSem[3] = "THIRD SEMESTER";
	astrConvertToSem[4] = "FOURTH SEMESTER";
}




//Vector vCollegeInfo = SS.getOfferedByCollegeInfo(dbOP, dbOP.mapOneToOther("faculty_load","sub_sec_index",WI.fillTextValue("section"),
//							"faculty_load.user_index",null));
String strCollegeName = null;
String strDeanName = null;
if(WI.fillTextValue("section").length() > 0) { 
	String strOfferedByCollege = dbOP.mapOneToOther("e_sub_section","sub_sec_index", strSubSecIndex, "OFFERED_BY_COLLEGE", "");
	if(strOfferedByCollege != null){
		strCollegeName = dbOP.mapOneToOther("COLLEGE","c_index",strOfferedByCollege,"c_name",null);
		strDeanName = dbOP.mapOneToOther("COLLEGE","c_index",strOfferedByCollege,"dean_name",null);
	}
}


Vector vGSEncodingInfo = gsExtn.getDateTimeGradeSheetEncoded(dbOP, strSubSecIndex ,WI.fillTextValue("grade_for"));

 	int iRowStartFr = Integer.parseInt(WI.fillTextValue("row_start_fr"));
	int iRowCount   = Integer.parseInt(WI.fillTextValue("row_count"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iFristPage  = Integer.parseInt(WI.fillTextValue("first_page"));


%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="83"><div align="center"><font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		<%if(!bolIsNEU){%>
		<br>
		<%}
		strTemp = SchoolInformation.getInfo1(dbOP,false,false);
		if(strTemp != null && strTemp.length() > 0){
		%>
		<%=strTemp%><br>
		<%}%>        
		<%if(bolIsNEU){%><%=WI.getStrValue(strCollegeName)%><br><br><%}
		if(!bolIsNEU)
			strTemp = "GRADE SHEET";
		else{
			if(bolIsFinalCopy)
				strTemp = "<font style='font-size:15px;'>OFFICIAL REPORT OF GRADES</font>";
			else
				strTemp = "<font style='font-size:15px;'>DRAFT REPORT OF GRADES</font>";
		}
		%>
        <strong><%=strTemp%></strong><br>		
        <%if(!bolIsNEU){%><%=WI.getStrValue(strCollegeName)%><br><%}
		
		strTemp = "";
		if(strSchoolCode.startsWith("LNU") && strGradesFor.toLowerCase().startsWith("final"))
			strTemp = "SEMESTRAL GRADE";
		else{
			if(!bolIsNEU)
				strTemp = "GRADES FOR "+strGradesFor.toUpperCase();
		}
		%><%=strTemp%>
		
		
		</font></div></td>
  </tr>
</table>
<%
if(iFristPage == 1){

if(!bolIsUB){

if(bolIsNEU){
%>
<table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr>
        <td height="18" colspan="2">&nbsp;&nbsp;Term: <strong f><%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></strong></td>
    </tr>
    <tr>
        <td  height="18"colspan="2">&nbsp;&nbsp;Academic Year: <strong><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></td>
    </tr>    
    <tr><td height="18" colspan="2">&nbsp;</td></tr>
<tr><td height="18" width="75%">&nbsp;&nbsp;Subject: <strong>
	<%=dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_code",null)%>
	(<%=dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name",null)%>)
</strong> </td>
</tr>
<tr> 
<td height="18">&nbsp;&nbsp;Class Section/Schedule: <strong><%=WI.fillTextValue("section_name")%>/ 
<%
for( int i = 1; i<vSecDetail.size(); i+=3){
if(i >1){%>
, 
<%}%>
<%=(String)vSecDetail.elementAt(i+2)%> 
<%}%>
</strong></td>
</tr>
<tr>
    <td height="18">&nbsp;&nbsp;Room No: 
	<%
	strTemp = "";
	if(vSecDetail != null){
		for(int i = 1; i<vSecDetail.size(); i+=3){
	  		if(i >1)
				strTemp += "<br>";		
			strTemp += (String)vSecDetail.elementAt(i);
		}
	}
	%><strong><%=strTemp%></strong>
	&nbsp; &nbsp;
	Units: <strong><%=WI.getStrValue(strUnit)%></strong>
	</td>
</tr>
</table>
<%}else{%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="12" colspan="2"><div align="left"><%if(bolIsVMUF){%>VMUF-FORM 10<br>
          Triplicate<br>
          GRADING SYSTEM
          <%}%>
          <br>
          </div></td>
      <td width="2%" valign="middle">&nbsp;</td>
      <td colspan="3" valign="middle"><div align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;School 
        Year <strong>: <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></div></td>
      
    <td colspan="2" valign="middle">&nbsp;Term <strong>: <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></strong></td>
    </tr>
    <tr>
      <td height="6" colspan="2" valign="top"><%if(bolIsVMUF){%><hr size="1"><%}%></td>
      <td valign="top">&nbsp;</td>
      <td width="9%">Subject Code </td>
      
    <td colspan="2">:<strong><%=dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_code",null)%></strong></td>
      <td width="8%">Section</td>
      
    <td width="38%">:<strong><%=WI.fillTextValue("section_name")%></strong></td>
    </tr>
    <tr>
      <td width="6%" height="18" valign="top"><div align="left"><%if(bolIsVMUF){%>Percentage<%}%></div></td>
      <td width="5%" valign="top"><div align="left"><%if(bolIsVMUF){%>Numerical<%}%></div></td>
      <td valign="top">&nbsp;</td>
      <td >Subject Title&nbsp; </td>
      
    <td colspan="2">:<strong><%=dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name",null)%></strong></td>
      <td>Room #</td>
      <td>:<strong>
	  <%for(int i = 1; i<vSecDetail.size(); i+=3){
	  if(i >1){%><%="<br>"%>
	  <%}%>
	  <%=(String)vSecDetail.elementAt(i+2)%>/<%=(String)vSecDetail.elementAt(i)%>
	  <%}//end of for loop.%>
	  
	  
	  </strong></td>
    </tr>
    <tr>
      <td height="19"><div align="left"><%if(bolIsVMUF){%>98 - 100<%}%></div></td>
      <td><div align="left"><%if(bolIsVMUF){%>1.0<%}%></div></td>
      <td valign="top">&nbsp;</td>
      <td>Units&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <%
	  strTemp = "&nbsp;";
	  if(vGSEncodingInfo != null)
	  	strTemp = (String)vGSEncodingInfo.elementAt(3);
		if(strSchoolCode.startsWith("DLSHSI"))
			strTemp = GS.getLoadingForSubject(dbOP, request.getParameter("subject"));
	  %>
    <td colspan="2">:<strong><%=WI.getStrValue(strTemp)%></strong></td>
      
    <td>Instructor</td>
      
    <td><strong>: 
      <%if(vSecDetail != null){%>
      <%=WI.getStrValue(vSecDetail.elementAt(0))%> 
      <%}%>
      </strong></td>
    </tr>
<%if(bolIsVMUF) {%>
    <tr>
      <td height="2"><div align="left"><%if(bolIsVMUF){%>95 - 97<%}%></div></td>
      <td><div align="left"><%if(bolIsVMUF){%>1.25<%}%></div></td>
      <td valign="top">&nbsp;</td>
      <td colspan="5" valign="top"><hr size="1"></td>
    </tr>
    <tr>
      <td><div align="left"><%if(bolIsVMUF){%>92 - 94<%}%></div></td>
      <td><div align="left"><%if(bolIsVMUF){%>1.5<%}%></div></td>
      <td valign="top">&nbsp;</td>
      <td colspan="2">Name of Examination </td>
      <td width="26%">:<strong> <%=strGradesFor%></strong></td>
      <td colspan="2" valign="top"><!--<strong>LEGEND</strong> : For Incomplete Grades (under REMARKS)--></td>
    </tr>
    <tr>
      <td height="17"><div align="left"><%if(bolIsVMUF){%>89 - 91<%}%></div></td>
      <td><div align="left"><%if(bolIsVMUF){%>1.75<%}%></div></td>
      <td valign="top">&nbsp;</td>
      <td colspan="2">Date of Examination</td>
      <td> : <strong><%if(vGSEncodingInfo!=null){%><%=(String)vGSEncodingInfo.elementAt(0)%><%}%></strong></td>
      <td colspan="2"><!--&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        &nbsp;&nbsp;&nbsp;&nbsp; Inc(A) - No Permit --></td>
    </tr>
    <tr>
      <td><div align="left"><%if(bolIsVMUF){%>86 - 88<%}%></div></td>
      <td valign="top"><div align="left"><%if(bolIsVMUF){%>2.0<%}%></div></td>
      <td valign="top">&nbsp;</td>
      <td colspan="2">Time of Examination</td>
      
    <td> : <strong> 
      <%if(vGSEncodingInfo!=null){%>
      <%=(String)vGSEncodingInfo.elementAt(1)%>
      <%}%>
      </strong></td>
      <td colspan="2"><!--&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        &nbsp;&nbsp;&nbsp; Inc(B) - Lack Quiz / Exam--></td>
    </tr>
    <tr>
      <td><div align="left"><%if(bolIsVMUF){%>83 - 85<%}%></div></td>
      <td valign="top"><div align="left"><%if(bolIsVMUF){%>2.25<%}%></div></td>
      <td valign="top">&nbsp;</td>
      <td colspan="2">Date Grades Encoded </td>
      
    <td>: <strong> 
      <%if(vGSEncodingInfo!=null){%>
      <%=(String)vGSEncodingInfo.elementAt(2)%>
      <%}%>
      </strong></td>
      
    <td colspan="2"><!--&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
      &nbsp;&nbsp;&nbsp; Inc(C) - No Project / Term Paper--></td>
    </tr>
    <tr>
      <td><div align="left"><%if(bolIsVMUF){%>80 - 82<%}%></div></td>
      <td valign="top"><div align="left"><%if(bolIsVMUF){%>2.5<%}%></div></td>
      <td valign="top">&nbsp;</td>
      
      <td colspan="2">Date Grade Printed</td>
    <td>: <strong><%=WI.getTodaysDate(4)%></strong> </td>
      <td colspan="2" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td><div align="left"><%if(bolIsVMUF){%>78 - 79<%}%></div></td>
      <td valign="top"><div align="left"><%if(bolIsVMUF){%>2.75<%}%></div></td>
      <td valign="top">&nbsp;</td>
      <td colspan="2">Received by:</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td><div align="left"><%if(bolIsVMUF){%>75 - 77<%}%></div></td>
      <td valign="top"><div align="left"><%if(bolIsVMUF){%>3.0<%}%></div></td>
      <td valign="top">&nbsp;</td>
      <td  colspan="5" valign="top">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__________________________</td>
    </tr>
    <tr>
      <td colspan="2"><%if(bolIsVMUF){%><hr size="1"><%}%></td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2" valign="top">&nbsp;</td>
    </tr>
<%}%>
  </table>
<%}//end not bolIsNEU

}//end not bolisUB

else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="3"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></div></td></tr>
	<tr><td colspan="3"><div align="center"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td></tr>
	<tr><td colspan="3"><div align="center"><strong>REPORT ON <%=strGradesFor.toUpperCase()%> GRADES</strong></div></td></tr>
</table>

<table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td width="75%">&nbsp;&nbsp;SUBJECT: <strong>
	<%=dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_code",null)%>
	(<%=dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name",null)%>)
</strong> </td>
<td width="25%">SEMESTER: <strong><%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></strong></td>
</tr>
<tr> 
<td>&nbsp;&nbsp;CLASS SECTION/SCHEDULE: <strong><%=WI.fillTextValue("section_name")%>/ 
<%
for( int i = 1; i<vSecDetail.size(); i+=3){
if(i >1){%>
, 
<%}%>
<%=(String)vSecDetail.elementAt(i+2)%> 
<%}%>
</strong></td>
<td>ACADEMIC YEAR: <strong><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></td>
</tr>
</table>
<%}//end if UB
}
if(vEncodedGrade != null && vEncodedGrade.size() > 0){
%>
<br>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr style="font-weight:bold" align="center"> 
  <%
  if(!bolIsNEU)
		strTemp = "COUNT";
	else
		strTemp = "NO.";
  %>
    <td width="3%"  class="thinborder" style="font-size:9px;" height="22"><%=strTemp%></td>
	<%
  if(!bolIsNEU)
		strTemp = "STUDENT ID";
	else
		strTemp = "STUDENT NO.";
  %>
    <td width="10%" class="thinborder" style="font-size:9px;"><%=strTemp%></td>
    <td width="31%" class="thinborder" style="font-size:9px;">STUDENT NAME</td>
    <td width="35%" class="thinborder" style="font-size:9px;">COURSE</td>
    <td width="4%"  class="thinborder" style="font-size:9px;">YEAR</td>
	<%
	if(!bolIsNEU)
		strTemp = "RATING (%)";
	else
		strTemp = "FINAL<br>GRADE";
	%>
    <td width="7%"  class="thinborder" style="font-size:9px;"><%=strTemp%></td>
    <td width="10%" class="thinborder" style="font-size:9px;">REMARKS</td>
  </tr>
<%
int j = 1;String strFontColor = null;
for(int i = 0 ; i < vEncodedGrade.size(); i += 9,++j){
if( j <= iRowStartFr) continue;
if( j > iRowEndsAt) break;

if( ((String)vEncodedGrade.elementAt(i+8)).toLowerCase().startsWith("f"))
	strFontColor = " color=red";
else	
	strFontColor = " color=black";
%>
  <tr> 
    <td <%if(bolIsFinalCopy){%> height="19"<%}%> align="center" class="thinborder"><font<%=strFontColor%>><%=j%>.</font></td>
    <td align="center" class="thinborder"><font<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+1)%></font></td>
    <td class="thinborder" style="padding-left:3px;"><font<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+2)%></font></td>
    <td class="thinborder" style="padding-left:3px;"><font<%=strFontColor%>><%=(String)vEncodedGrade.elementAt(i+3)%> 
      <% if(vEncodedGrade.elementAt(i + 4) != null){%>
      :: <%=(String)vEncodedGrade.elementAt(i+4)%> 
      <%}%></font>
    </td>
    <td align="center" class="thinborder"><font<%=strFontColor%>><%=WI.getStrValue(vEncodedGrade.elementAt(i+5),"N/A")%></font></td>
	<%
	strTemp = WI.getStrValue(vEncodedGrade.elementAt(i+7),"&nbsp;");
	
	try{
		Double.parseDouble(strTemp);//if it catch here, below code will not be exec.
		if(bolIsNEU){
			int iIndexOf = strTemp.indexOf(".");
			if(iIndexOf == -1)
				strTemp += ".00";
			else{
				if(strTemp.substring(iIndexOf+1).length() == 1)
					strTemp += "0";
			}
		}
	}catch(Exception e){
		
	}
	
	/*if(!strTemp.equals("&nbsp;") && bolIsNEU){
		int iIndexOf = strTemp.indexOf(".");
		if(iIndexOf == -1)
			strTemp += ".00";
		else{
			if(strTemp.substring(iIndexOf+1).length() == 1)
				strTemp += "0";
		}
	}*/
	%>
    <td class="thinborder" align="center"><font<%=strFontColor%>><%=strTemp%></font></td>
	
<% strTemp = (String)vEncodedGrade.elementAt(i+8);	
	if (strSchoolCode.startsWith("AUF") && strTemp.toLowerCase().startsWith("fail")) 
		strTemp = " Failed"; %>
    <td <%if(bolIsNEU){%>align="center"<%}%> class="thinborder"><font<%=strFontColor%>><%=strTemp%></font></td>
  </tr>
<%}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"><div align="center">&nbsp;
	  <%if(vEncodedGrade.size()/9-1 > j){%>- continued on next sheet -<%}else{%>***** NOTHING FOLLOWS *****<%}%></div>
	  </td>
    </tr>
</table>
<%if(!strSchoolCode.startsWith("UB")){
if(bolIsNEU){
%>
<div style="bottom:0px; position:absolute; width:100%;">
<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%
	if(bolIsNEU){
		if(bolIsFinalCopy){
%>
	<tr>
      <td height="25" valign="top" colspan="3">Submitted by:</td>
    </tr>
	<tr>
	<%
	strTemp = "&nbsp;";
	if(vSecDetail != null && vSecDetail.size() > 0)
    	strTemp = WI.getStrValue(vSecDetail.elementAt(0));
	%>
		<td height="35" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%; text-align:center"><strong><%=strTemp%></strong></div>
		<div style="text-align:center; width:80%;">Instructor's Name and Signature</div>
		</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>	
	<tr>
      <td height="25" valign="top" colspan="3">Submitted to:</td>
    </tr>
	<tr>
		<td height="35" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%; text-align:center"><strong><%=WI.getStrValue(strDeanName)%></strong></div>
		<div style="width:80%; text-align:center">Dean</div>
		</td>
		<td valign="bottom">
		<div style="border-bottom:solid 1px #000000; width:80%; text-align:center"><strong> 
							  <%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "university registrar",1)).toUpperCase()%> 
							  </strong></div>
		<div style="text-align:center; width:80%;">University Registrar</div>
		</td>
		<td valign="bottom">
		<div style="border-bottom:solid 1px #000000; width:80%; text-align:center"><%=WI.getTodaysDateTime()%></div>
		<div style="text-align:center; width:80%;">Date and Time Printed</div>
		</td>
	</tr>

<%}}else{%>
    <tr>
      <td height="25" valign="top" colspan="3">NOTED BY :</td>
    </tr>
    <tr>
      <td height="25" valign="bottom">________________________________________</td>
      <td width="40%"  height="25" valign="bottom">________________________________________</td>
      <td width="20%"  height="25">&nbsp;</td>
    </tr>
    <tr>
      <td  height="25" valign="top">Dean/Principal/Program
        Coordinator</td>
      <td  height="25" valign="top">Instructor's
        Signature </td>
      <td  height="25" valign="top">&nbsp;</td>
    </tr> 
<%}//end !bolIsNEU

%>
</table>
<%
if(bolIsNEU){
%>
</div><!-- the opening div at top -->
<%}
}

if(strSchoolCode.startsWith("UB")){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="32%">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr> 
				  <td width="35%">&nbsp;</td>
			    </tr>
				<tr> 
				  <td>SUBMITTED BY:</td>
			    </tr>
				<tr> 
				  <td>&nbsp;</td>
			    </tr>
				<tr> 
				  <td width="35%" valign="bottom"><div align="center"> <strong> </strong>
					  <table width="90%" border="0" cellspacing="0" cellpadding="0">
						<tr>
						  <td height="19" class="thinborderBottom"><div align="center"><strong> 
							  <%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4).toUpperCase()%> 
							  </strong></div></td>
						</tr>
					  </table>
				  </div></td>
			    </tr>
				<tr> 
				  <td><div align="center"><font size="1">INSTRUCTOR'S NAME AND SIGNATURE</font></div></td>
			    </tr>
				<tr> 
				  <td>Printed date : <%=WI.getTodaysDate(6)%></td>
			    </tr>
			</table>  
		</td>
		<td width="2%">&nbsp;</td>
		<td width="32%">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr> 
				  <td width="35%">&nbsp;</td>
			    </tr>
				<tr> 
				  <td>APPROVED BY:</td>
			    </tr>
				<tr> 
				  <td>&nbsp;</td>
			    </tr>
				<tr> 
				  <td width="35%" valign="bottom"><div align="center"> <strong> </strong>
					  <table width="90%" border="0" cellspacing="0" cellpadding="0">
						<tr>
						  <td height="19" class="thinborderBottom"><div align="center"><strong> 
							  <%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",(String)vEmpRec.elementAt(11),"DEAN_NAME"," and is_del = 0")).toUpperCase()%> 
							  </strong></div></td>
						</tr>
					  </table>
				  </div></td>
			    </tr>
				<tr> 
				  <td><div align="center"><font size="1">DEAN</font></div></td>
			    </tr>
				<tr> 
				  <td>&nbsp;</td>
			    </tr>
			</table>	
		</td>
		<td width="2%">&nbsp;</td>
		<td width="32%">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr> 
				  <td width="35%">&nbsp;</td>
			    </tr>
				<tr> 
				  <td>RECEIVED BY:</td>
			    </tr>
				<tr> 
				  <td>&nbsp;</td>
			    </tr>
				<tr> 
				  <td width="35%" valign="bottom"><div align="center"> <strong> </strong>
					  <table width="90%" border="0" cellspacing="0" cellpadding="0">
						<tr>
						  <td height="19" class="thinborderBottom"><div align="center"><strong> 
							  <%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "university registrar",1)).toUpperCase()%> 
							  </strong></div></td>
						</tr>
					  </table>
				  </div></td>
			    </tr>
				<tr> 
				  <td><div align="center"><font size="1">UNIVERSITY REGISTRAR </font></div></td>
			    </tr>
				<tr> 
				  <td>&nbsp;</td>
			    </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td colspan="3">Note: NG = No Grade, DR = Droppped, W = Withdrawn</td>
	</tr>
</table>
<%}%>
<%}//end of printing grade sheet%>
<script language="JavaScript">
window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>