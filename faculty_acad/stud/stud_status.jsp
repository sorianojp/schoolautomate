<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function PrintPage(strStudId)
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	var sT = "#";
	if(vProceed)
		sT = "./stud_cur_residency_eval_print.jsp?stud_id="+escape(strStudId);

	//print here
	if(vProceed)
	{
		var win=window.open(sT,"myfile",'dependent=no,width=850,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
</script>

<body bgcolor="#93B5BB">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,student.StudentEvaluation,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
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
														"Registrar Management","STUDENT CURRICULUM EVALUATION",request.getRemoteAddr(),
														"stud_cur_residency_eval.jsp");
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
														"stud_cur_residency_eval.jsp");
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

if(WI.fillTextValue("stud_id").length() > 0) {
	vTemp = GS.getResidencySummary(dbOP, WI.fillTextValue("stud_id"));
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
	dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));

}


%>
<form action="stud_status.jsp" method="post" name="stud_eval">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#6A99A2"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT STATUS/EVALUATION ::::</strong></font></div></td>
    </tr>
	</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
	  <td height="25" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>

    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="29%">Student ID
        <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
      <td width="69%"><input type="image" src="../../images/form_proceed.gif"></td>
    </tr>
    <tr>
      <td colspan="3" height="25"><hr size="1"></td>
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
      <td> <strong><%=astrConvertResStatus[Integer.parseInt((String)vTemp.elementAt(14))]%></strong></tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"  colspan="2">Total units required for this course : <strong><%=(String)vTemp.elementAt(12)%></strong></td>
      <td height="25"  colspan="2">Total units taken : <strong><%=WI.getStrValue(vTemp.elementAt(13))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">GWA :</td>
      <td height="25"><strong><%=CommonUtil.formatFloat(dGWA, true)%></strong></td>
    </tr>
  </table>
 <%}//only vTemp is not null -- having residency summary.
if(vRetResult != null){
String[] astrConvertToPrepProp = {""," (Preparatory)"," (Proper)"};
String strDegreeType = (String) vTemp.elementAt(11);
String strPrevYr  = null;
String strCurYr   = null;
int iPrevSem = 0;
int iCurSem  = 0;
float fTotalUnit = 0f;

float fSubjectUnit = 0f;
float fUnitCredited = 0f;//not same as fSubjectUnit when subject is credited less than its units - for transferee/from other course.

String strBGColor = null;

%>
  <table bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" width="100%">
    <tr bgcolor="#BDD5DF">
      <td colspan="6" height="25" align="center"> <strong>CURRICULUM
        RESIDENCY EVALUATION</strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4"><b><font size="1" color="#0000FF">NOTE: <img src="../../images/blue_box.gif">
        -&gt; COLOR INDICATES SUBJECTS HAVING PASSING GRADE.</font><br>
        <font size="1" color="#47768F"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <img src="../../images/gray_box.gif"> -&gt; COLOR INDICATES SUBJECTS
        HAVING CREDITED UNIT LESS THAN REQUIRED UNIT</font></b></td>
      <td><a href='javascript:PrintPage("<%=WI.fillTextValue("stud_id")%>");'>
        <img src="../../images/print.gif" width="58" height="26" border="0"></a>
        <font size="1">print this page</font></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%"><font size="1"><b>SUB CODE</b></font></td>
      <td width="41%"><font size="1"><b>SUB DESC</b></font></td>
      <td width="11%"><font size="1"><b>TOTAL UNIT</b></font></td>
      <td width="5%"><font size="1"><b>CREDIT EARNED</b></font></td>
      <td width="25%"><font size="1"><b>REMARK(GRADE)</b></font></td>
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
        <%=astrConvertYear[Integer.parseInt(strPrevYr)]%>, <%=astrConvertSem[iPrevSem]%>
        <%=astrConvertToPrepProp[Integer.parseInt((String)vRetResult.elementAt(i+2))]%>
        <%}%>
        </u></b></td>
    </tr>
    <%
for(; i< vRetResult.size();){
strCurYr = WI.getStrValue(vRetResult.elementAt(i),"0");
iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
if(strCurYr.compareTo(strPrevYr) !=0 || iCurSem != iPrevSem)
	break;

fSubjectUnit = Float.parseFloat((String)vRetResult.elementAt(i + 10));
fTotalUnit += fSubjectUnit;
fUnitCredited = Float.parseFloat(WI.getStrValue(vRetResult.elementAt(i + 13),"0"));

//if student has done the subject , change the color.
if( fUnitCredited > 0f) {
	if(fUnitCredited >= fSubjectUnit)
		strBGColor = " bgcolor=#CCECFF";
	else
		strBGColor = " bgcolor =#BECED3";
}else
	strBGColor = "";
strTemp = (String)vRetResult.elementAt(i+15);
if(strTemp != null && vRetResult.elementAt(i+14) != null)
	strTemp += "(" +(String)vRetResult.elementAt(i+14) + ")";
%>
    <tr<%=strBGColor%>>
      <td width="2%" height="25">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
      <td><%=(String)vRetResult.elementAt(i+10)%><%=(String)vRetResult.elementAt(i+11)%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+13))%></td>
      <td><%=WI.getStrValue(strTemp)%></td>
    </tr>
    <%
	i += 16;
	}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="5" align="center">
        <%if(strDegreeType.compareTo("1") != 0){%>
        <font size="1"><b><u>TOTAL REQUIRED UNITS : <%=fTotalUnit%></u></b></font>
        <%}%>
      </td>
    </tr>
    <%fTotalUnit = 0f;}//end of loop for year/sem display.%>
  </table>
<%}%>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
        <tr>

      <TD align="right"><a href='javascript:PrintPage("<%=WI.fillTextValue("stud_id")%>");'>
        <img src="../../images/print.gif" width="58" height="26" border="0"></a>
        <font size="1">click to print curriculum residency evaluation page</font></TD>
        </tr>
      </table>


<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#6A99A2">&nbsp;</td>
  </tr>
</table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
