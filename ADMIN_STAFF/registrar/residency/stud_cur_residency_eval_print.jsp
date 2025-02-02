<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<body topmargin="5" onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,student.StudentEvaluation,java.util.Vector" %>
<%
WebInterface WI = new WebInterface(request);

boolean bolRemoveRemark = false;
boolean bolShowGrade = false;
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsNEU = strSchCode.startsWith("NEU");
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CPU") || strSchCode.startsWith("WNU") ||
	strSchCode.startsWith("AUF") || strSchCode.startsWith("PIT") || strSchCode.startsWith("UB")  || strSchCode.startsWith("SPC") || bolIsNEU)
	bolShowGrade = true;
//bolShowGrade = true;
if((strSchCode.startsWith("AUF") || strSchCode.startsWith("PIT")) && (String)request.getSession(false).getAttribute("advising") != null)
	bolShowGrade = false;

if(strSchCode.startsWith("UDMC")){
	//forward page to new print page.
	%><jsp:forward page="./stud_cur_residency_eval_print_UDMC.jsp" />

<%return ;}
if(strSchCode.startsWith("CIT")){
	//forward page to new print page.
	%><jsp:forward page="./stud_cur_residency_eval_print_CIT.jsp" />

<%return ;}
if(strSchCode.startsWith("AUF")){
	//forward page to new print page.
	%><jsp:forward page="./stud_cur_residency_eval_print_AUF.jsp" />

<%return ;}

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	double dGWA      = 0d;

	String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","","","",""};
	String[] astrConvertResStatus = {"Regular","Irregular"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT CURRICULUM EVALUATION","stud_cur_residency_eval.jsp");
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
														"Registrar Management","STUDENT COURSE EVALUATION",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),
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
	//adviser are allowed to check.
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"stud_cur_residency_eval_print.jsp");
	if(iAccessLevel == 0) {
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
}

//end of authenticaion code.
GradeSystem GS = new GradeSystem();
StudentEvaluation SE = new StudentEvaluation();
Vector vRetResult = null;
Vector vTemp = null;

boolean bolShowPreRequisite = false;
if(WI.fillTextValue("show_prereq").length() > 0) 
	bolShowPreRequisite = true;

if(WI.fillTextValue("stud_id").length() > 0) {
	vTemp = GS.getResidencySummary(dbOP, WI.fillTextValue("stud_id"));
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
	else {
		vRetResult = SE.getCurriculumResidencyEval(dbOP,(String)vTemp.elementAt(0),(String)vTemp.elementAt(15),
                                           (String)vTemp.elementAt(16),(String)vTemp.elementAt(8),(String)vTemp.elementAt(9),
                                           (String)vTemp.elementAt(11),bolShowPreRequisite);
		if(vRetResult == null || vRetResult.size() ==0)
			strErrMsg = SE.getErrMsg();
	}

	//I have to get the GWA for all the subjects completed so far.
	student.GWA gwa = new student.GWA();
	dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));
}


%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="20" colspan="4" bgcolor="#cccccc"><div align="center"><strong>::::
          STUDENT RESIDENCY EVALUATION ::::</strong></div></td>
    </tr>
</table>
<%if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="98%" height="20" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
<%}if(vTemp != null && vTemp.size()>0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="10">&nbsp;</td>
      <td>Student ID</td>
      <td><%=WI.fillTextValue("stud_id")%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td width="15%">Student name</td>
      <td width="45%"><strong><%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),1)%></strong></td>
      <td width="6%">Year</td>
      <td width="32%"><strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vTemp.elementAt(10),"0"))]%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td>Course/Major</td>
      <td><strong><%=(String)vTemp.elementAt(6)%>/<%=WI.getStrValue(vTemp.elementAt(7))%>
        (<%=(String)vTemp.elementAt(8)%>-<%=(String)vTemp.elementAt(9)%>)</strong></td>
      <td>Status</td>
      <td> <strong><%=astrConvertResStatus[Integer.parseInt(WI.getStrValue(vTemp.elementAt(14),"0"))]%></strong></tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20"  colspan="2">Total units required for this course : <strong><%=(String)vTemp.elementAt(12)%></strong></td>
      <td height="20"  colspan="2">Total units taken : <strong><%=WI.getStrValue(vTemp.elementAt(13))%></strong></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
	  <td><% if (!((String)vTemp.elementAt(11)).equals("1") || !((String)vTemp.elementAt(11)).equals("2")){%>GWA :<%}%>&nbsp;</td>
	  <td><% if (!((String)vTemp.elementAt(11)).equals("1") || !((String)vTemp.elementAt(11)).equals("2")){%><strong><%=CommonUtil.formatFloat(dGWA, true)%></strong><%}%>&nbsp;</td>
    </tr>
  </table>
 <%}//only vTemp is not null -- having residency summary.
if(vRetResult != null){
String[] astrConvertToPrepProp = {"","(Preparatory)","(Proper)"};
String strDegreeType = (String) vTemp.elementAt(11);
String strPrevYr  = null;
String strCurYr   = null;
int iPrevSem = 0;
int iCurSem  = 0;

float fTotalHour = 0f;

float fTotalUnit    = 0f; double dTotalCreditUnit = 0d;
float fSubjectUnit  = 0f;
float fUnitCredited = 0f;//not same as fSubjectUnit when subject is credited less than its units - for transferee/from other course.

String strBGColor = null;

%>
<table bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" width="100%" class="thinborderALL">
  <tr>
    <td height="25" colspan="5" align="center" bgcolor="#EEEECC" class="thinborderBOTTOM"> <strong>CURRICULUM
      RESIDENCY EVALUATION</strong></td>
    <%if(!bolRemoveRemark){%>
    <td height="25" align="center" bgcolor="#EEEECC" class="thinborderBOTTOM">&nbsp;</td>
    <%}%>
      <%if(bolShowGrade){%><td bgcolor="#EEEECC" height="25" align="center" class="thinborderBOTTOM">&nbsp;</td><%}%>
      <%if(bolShowPreRequisite){%><td bgcolor="#EEEECC" align="center" class="thinborderBOTTOM">&nbsp;</td><%}%>
  </tr>
<%if(!bolShowGrade){%>  <tr>
    <td width="2%" height="25">&nbsp;</td>
    <td colspan="4"><b><font size="1" color="#0000FF">NOTE: <img src="../../../images/blue_box.gif">
      -&gt; COLOR INDICATES SUBJECTS HAVING PASSING GRADE.</font><br>
      <font size="1" color="#47768F"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <img src="../../../images/gray_box.gif"> -&gt; COLOR INDICATES SUBJECTS
      HAVING CREDITED UNIT LESS THAN REQUIRED UNIT</font></b></td>
    <%if(!bolRemoveRemark){%>
    <td>&nbsp;</td>
    <%}%>
      <%if(bolShowGrade){%><td>&nbsp;</td><%}%>
      <%if(bolShowPreRequisite){%><td>&nbsp;</td><%}%>
  </tr>
<%}%>
  <tr>
    <td width="2%" height="20">&nbsp;</td>
    <td width="15%"><font size="1"><b>SUB CODE</b></font></td>
    <td width="40%"><font size="1"><b>SUB DESC</b></font></td>
    <td width="10%"><font size="1"><b>TOTAL UNIT</b></font></td>
    <td width="5%"><font size="1"><b>CREDIT EARNED</b></font></td>
    <%if(bolShowGrade){%>
    	<td width="8%"><font size="1"><b>GRADE</b></font></td>
    <%}%>
    <%if(!bolRemoveRemark){%>
    	<td width="15%"><font size="1"><b>REMARK</b></font></td>
    <%}%>
<%if(bolShowPreRequisite){%>
      <td width="15%"><font size="1"><b>PRE-REQUISITE</b></font></td>
<%}%>
  </tr>
  <%
for(int i = 0 ; i< vRetResult.size();){
strPrevYr  = WI.getStrValue(vRetResult.elementAt(i),"0");
iPrevSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
%>
  <tr>
    <td width="2%" height="20">&nbsp;</td>
    <td colspan="4"><b><u>
      <%if(strDegreeType.compareTo("1") == 0){//do not parse, because it displays the requrement and the units.%>
      <%=strPrevYr%>
      <%}else{%>
      <%=astrConvertYear[Integer.parseInt(strPrevYr)]%>, <%=astrConvertSem[iPrevSem]%> <%=astrConvertToPrepProp[Integer.parseInt((String)vRetResult.elementAt(i+2))]%>
      <%}%>
      </u></b></td>
    <%if(!bolRemoveRemark){%>
    <td>&nbsp;</td>
    <%}%>
      <%if(bolShowGrade){%><td>&nbsp;</td><%}%>
      <%if(bolShowPreRequisite){%><td>&nbsp;</td><%}%>
  </tr>
  <%
for(; i< vRetResult.size();){
strCurYr = WI.getStrValue(vRetResult.elementAt(i),"0");
iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
if(strCurYr.compareTo(strPrevYr) !=0 || iCurSem != iPrevSem)
	break;

fSubjectUnit = Float.parseFloat((String)vRetResult.elementAt(i + 10));
if( ((String)vRetResult.elementAt(i+11)).indexOf("nit") != -1)
	fTotalUnit += fSubjectUnit;
else
	fTotalHour += fSubjectUnit;
fUnitCredited = Float.parseFloat(WI.getStrValue(vRetResult.elementAt(i + 13),"0"));

dTotalCreditUnit += fUnitCredited;
//if student has done the subject , change the color.
if( fUnitCredited > 0f) {
	if(fUnitCredited >= fSubjectUnit)
		strBGColor = " bgcolor=#CCECFF";
	else
		strBGColor = " bgcolor =#BECED3";
}else
	strBGColor = "";
strTemp = (String)vRetResult.elementAt(i+15);

//sometimes the subject unit is 0, but it is passed.
if(fSubjectUnit == 0 && strTemp != null && strTemp.startsWith("Pa"))
	strBGColor = " bgcolor=#CCECFF";

//if(strTemp != null && vRetResult.elementAt(i+14) != null)
//	strTemp += "(" +(String)vRetResult.elementAt(i+14) + ")";
%>
  <tr<%=strBGColor%>>
    <td width="2%" height="20">&nbsp;</td>
    <td><%=(String)vRetResult.elementAt(i+4)%></td>
    <td><%=(String)vRetResult.elementAt(i+5)%></td>
    <td><%=(String)vRetResult.elementAt(i+10)%><%=(String)vRetResult.elementAt(i+11)%></td>
    <td><%=WI.getStrValue(vRetResult.elementAt(i+13))%></td>
    <%if(bolShowGrade){
	strErrMsg = WI.getStrValue(vRetResult.elementAt(i+14));
	
	if( bolIsNEU && strTemp != null && (strTemp.endsWith(".0") || strTemp.length() == 3) && strTemp.indexOf(".") > -1)
		strErrMsg = strErrMsg+"0";
	%>
    	<td><%=strErrMsg%> </td>
    <%}%>
    <%if(!bolRemoveRemark){%>
    	<td><%=WI.getStrValue(strTemp)%></td>
    <%}%>
<%if(bolShowPreRequisite) {
	if(vRetResult.elementAt(i + 16) == null) {
		strTemp = null;
		vRetResult.remove(i + 16);
	}else{
		strTemp = (String)vRetResult.remove(i + 16);
		strTemp = strTemp.substring(1);
		strTemp = strTemp.substring(0, strTemp.length() - 1);
	}
%>
      <td style="font-size:9px"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
<%}%>
  </tr>
  <%
	i += 16;
	}%>
  <tr>
    <td width="2%" height="22">&nbsp;</td>
    <td colspan="4" align="center"><font size="1"><b>
      <%if(strDegreeType.compareTo("1") != 0){
			if(fTotalUnit > 0f){%>
      <u>TOTAL REQUIRED UNITS : <%=fTotalUnit%></u>
      <%}else if(fTotalHour > 0f){%>
      <u>TOTAL REQUIRED HOURS : <%=fTotalHour%></u>
      <%}
		}%>
      &nbsp;&nbsp;&nbsp;&nbsp;TOTAL UNITS CREDITED : <%=dTotalCreditUnit%> </b></font></td>
    <%if(!bolRemoveRemark){%><td align="center">&nbsp;</td><%}%>
      <%if(bolShowGrade){%><td align="center">&nbsp;</td><%}%>
      <%if(bolShowPreRequisite){%><td align="center">&nbsp;</td><%}%>
  </tr>
  <%fTotalUnit = 0f;fTotalHour = 0f;dTotalCreditUnit = 0d;}//end of loop for year/sem display.%>
</table>
<%}%><br>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td width="61%">Prepared by : <%=(CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1))%><br>
      Date and time printed : <%=WI.getTodaysDateTime()%> </td>
    <td width="39%"><div align="center"><br>
        Evaluated By :</div></td>
  </tr>
</table>
<%
dbOP.cleanUP();
}%>
</body>
</html>
