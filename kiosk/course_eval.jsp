<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.GradeSystem,student.StudentEvaluation,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	WebInterface WI  = new WebInterface(request);
	double dGWA      = 0d;

	String strStudID = (String)request.getSession(false).getAttribute("id_");
	if(strStudID == null){%>
		<font size="5" color="#0000FF">You are already logged out. Please login again.</font>
	<%
		return;
	}

	String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","","","",""};
	String[] astrConvertResStatus = {"Regular","Irregular"};

//add security here.
	try
	{
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

GradeSystem GS = new GradeSystem();
StudentEvaluation SE = new StudentEvaluation();
Vector vRetResult = null;
Vector vTemp = null;

	vTemp = GS.getResidencySummary(dbOP,strStudID);//System.out.println(vTemp);
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
	else {
		vRetResult = SE.getCurriculumResidencyEval(dbOP,(String)vTemp.elementAt(0),(String)vTemp.elementAt(15),
                                           (String)vTemp.elementAt(16),(String)vTemp.elementAt(8),(String)vTemp.elementAt(9),
                                           (String)vTemp.elementAt(11));
		if(vRetResult == null || vRetResult.size() ==0)
			strErrMsg = SE.getErrMsg();
	}
//I have to get the GWA for all the subjects completed so far.
	student.GWA gwa = new student.GWA();
	dGWA = gwa.computeGWAForResidency(dbOP,strStudID);

boolean bolShowGrade = false;
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CPU") || strSchCode.startsWith("AUF"))
	bolShowGrade = true;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4"><div align="center"><strong>::::
          STUDENT RESIDENCY EVALUATION ::::</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="28%">Student ID: &nbsp;&nbsp;
        <%
String strReadOnly = "";
if(WI.fillTextValue("online_advising").compareTo("1") == 0) {
	strTemp = "textbox_noborder";
	strReadOnly = "readonly";
}
else
	strTemp = "textbox";
%>
        <font size="3"><b><%=strStudID%></b></font>      </td>
      <td width="15%">&nbsp;</td>
      <td width="55%">&nbsp;</td>
    </tr>
  </table>

<%if(vTemp != null && vTemp.size()>0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="15%">Student name</td>
      <td width="45%"><strong><%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),1)%></strong></td>
      <td width="6%">Year</td>
      <td width="32%"><strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vTemp.elementAt(10),"0"))]%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Course/Major</td>
      <td><strong><%=(String)vTemp.elementAt(6)%>/<%=WI.getStrValue(vTemp.elementAt(7))%> (<%=(String)vTemp.elementAt(8)%>-<%=(String)vTemp.elementAt(9)%>)</strong></td>
      <td>Status</td>
      <td> <strong><%=astrConvertResStatus[Integer.parseInt(WI.getStrValue(vTemp.elementAt(14),"0"))]%></strong></tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"  colspan="2">Total units required for this course : <strong><%=(String)vTemp.elementAt(12)%></strong></td>
      <td height="25"  colspan="2">Total units taken : <strong><%=WI.getStrValue(vTemp.elementAt(13))%></strong></td>
    </tr>
<%if(!strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><% if (!((String)vTemp.elementAt(11)).equals("1") || !((String)vTemp.elementAt(11)).equals("2")){%>GWA :<%}%>&nbsp;</td>
      <td height="25"><% if (!((String)vTemp.elementAt(11)).equals("1") || !((String)vTemp.elementAt(11)).equals("2")){%><strong><%=CommonUtil.formatFloat(dGWA, true)%></strong><%}%>&nbsp;</td>
    </tr>
<%}%>
  </table>
 <%}//only vTemp is not null -- having residency summary.
if(vRetResult != null){
String[] astrConvertToPrepProp = {""," (Preparatory)"," (Proper)"};
String strDegreeType = (String) vTemp.elementAt(11);
String strPrevYr  = null;
String strCurYr   = null;
int iPrevSem = 0;
int iCurSem  = 0;
float fTotalUnit = 0f; double dTotalCreditUnit = 0d;

float fTotalHour = 0f;

float fSubjectUnit = 0f;
float fUnitCredited = 0f;//not same as fSubjectUnit when subject is credited less than its units - for transferee/from other course.

String strBGColor = null;

%>
  <table bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td height="25" colspan="6" align="center" bgcolor="#EEEECC"> <strong>CURRICULUM
        RESIDENCY EVALUATION</strong></td>
      <%if(bolShowGrade){%><td bgcolor="#EEEECC" height="25" align="center">&nbsp;</td><%}%>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4"><b><font size="1" color="#0000FF">NOTE: <img src="../images/blue_box.gif">
        -&gt; COLOR INDICATES SUBJECTS HAVING PASSING GRADE.</font><br>
        <font size="1" color="#47768F"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <img src="../images/gray_box.gif"> -&gt; COLOR INDICATES SUBJECTS
        HAVING CREDITED UNIT LESS THAN REQUIRED UNIT</font></b></td>
      <td>&nbsp;</td>
      <%if(bolShowGrade){%><td>&nbsp;</td><%}%>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%"><font size="1"><b>SUB CODE</b></font></td>
      <td width="44%"><font size="1"><b>SUB DESC</b></font></td>
      <td width="10%"><font size="1"><b>TOTAL UNIT</b></font></td>
      <td width="12%"><font size="1"><b>CREDIT EARNED</b></font></td>
      <td width="9%"><font size="1"><b>REMARK</b></font></td>
      <%if(bolShowGrade){%><td width="8%"><font size="1"><b>GRADE</b></font></td><%}%>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size();){
strPrevYr  = WI.getStrValue(vRetResult.elementAt(i),"0");
iPrevSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="5"><b><u>
        <%if(strDegreeType.compareTo("1") == 0){//do not parse, because it displays the requrement and the units.%>
        <%=strPrevYr%>
        <%}else{%>
        <%=astrConvertYear[Integer.parseInt(strPrevYr)]%>, <%=astrConvertSem[iPrevSem]%> <%=astrConvertToPrepProp[Integer.parseInt((String)vRetResult.elementAt(i+2))]%>
        <%}%>
        </u></b></td>
      <%if(bolShowGrade){%><td>&nbsp;</td><%}%>
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
if(strBGColor.length() == 0 && strTemp != null && strTemp.length () > 0 && fUnitCredited == 0f &&
		!strTemp.toLowerCase().startsWith("p"))
	strBGColor = " bgcolor=#FF6a6a";

//sometimes the subject unit is 0, but it is passed.
if(fSubjectUnit == 0 && strTemp != null && strTemp.startsWith("Pa"))
	strBGColor = " bgcolor=#CCECFF";

//if(strTemp != null && vRetResult.elementAt(i+14) != null)
//	strTemp += "(" +(String)vRetResult.elementAt(i+14) + ")";
%>
    <tr<%=strBGColor%>>
      <td width="2%" height="25">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
      <td><%=(String)vRetResult.elementAt(i+10)%><%=(String)vRetResult.elementAt(i+11)%></td>
      <td align="center"><%=WI.getStrValue(vRetResult.elementAt(i+13))%></td>
      <td><%=WI.getStrValue(strTemp)%></td>
      <%if(bolShowGrade){%><td><%=WI.getStrValue(vRetResult.elementAt(i+14))%> </td><%}%>
    </tr>
    <%
	i += 16;
	}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="5" align="center"><font size="1"><b>
        <%if(strDegreeType.compareTo("1") != 0){
			if(fTotalUnit > 0f){%>
        <u>TOTAL REQUIRED UNITS : <%=fTotalUnit%></u>
        <%}else if(fTotalHour > 0f){%>
        <u>TOTAL REQUIRED HOURS : <%=fTotalHour%></u>
        <%}
		}%>
        &nbsp;&nbsp;&nbsp;&nbsp;TOTAL UNITS CREDITED : <%=dTotalCreditUnit%> </b></font></td>
      <%if(bolShowGrade){%><td align="center">&nbsp;</td><%}%>
    </tr>
    <%fTotalUnit = 0f;fTotalHour = 0f;dTotalCreditUnit = 0d;}//end of loop for year/sem display.%>
  </table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
