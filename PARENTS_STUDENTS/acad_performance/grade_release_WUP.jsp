<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="javascript"  src ="../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	SetFields();
	document.grelease.submit();
}
function SetFields()
{
	document.grelease.grade_name.value= document.grelease.grade_for[document.grelease.grade_for.selectedIndex].text;
	document.grelease.semester_name.value= document.grelease.semester[document.grelease.semester.selectedIndex].text;
}
</script>
<body bgcolor="#578EAC">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	

//add security here.
	try	{
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
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";

GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

String strUserIndex   = null;


//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, strStudID);
boolean bolIsBasic = false;

Vector vGradeDetail = null;
if(vStudInfo == null) {
	pmtUtil.setIsBasic(true);
	vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, strStudID);
	if(vStudInfo != null) {
		dbOP.cleanUP();
		response.sendRedirect("./basic_report_card.jsp?stud_id="+strStudID);
		return;
	}
}
if(vStudInfo == null) {
	strErrMsg = "Information not available.";//pmtUtil.getErrMsg();
}
else
{
	//get grade sheet release information.
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),request.getParameter("sy_from"),
		request.getParameter("sy_to"),request.getParameter("semester"),true,true,true);//get all information.
	strUserIndex = (String)vStudInfo.elementAt(0);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";//System.out.println(vGradeDetail);

String strGradeCGH = null;
java.sql.PreparedStatement pstmtGetPercentGrade = dbOP.getPreparedStatement("select grade_cgh from g_sheet_final where gs_index = ?");
%>

<form name="grelease" action="./grade_release_WUP.jsp" method="post">
<input type="hidden" name="grade_name" value="0">
<input type="hidden" name="semester_name" value="0">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#86AEC4">
      <td height="25" colspan="3" align="center"><font color="#FFFFFF"><strong>::::
        Grade Per Exam Period ::::</strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="2" ><strong><%=strErrMsg%></strong></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Student ID : <strong><%=strStudID%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Course/Major : <strong><%=(String)vStudInfo.elementAt(2)%>
        <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td width="30%" height="25" >Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong></td>
      <td width="68%" >
	  <%//check here if it is printed arleady.. 
	  enrollment.ReportRegistrar RR = new enrollment.ReportRegistrar();
	  Vector vTemp = null;
	  if(strSchCode.startsWith("UDMC") && WI.fillTextValue("sy_from").length() > 0) {
		  	vTemp = RR.operateOnGradeReleasePrint(dbOP, request, 4);
		  strTemp = null;
	  	if(vTemp != null && vTemp.size() > 0)
	  		strTemp = "<font color='red'><u>Printed on "+vTemp.elementAt(0)+" by : "+vTemp.elementAt(1)+"</u></font>"; 
		  else	
		  	strTemp = "<font color='red'><u>Printing information not found.</u></font>";
	  }
	  %><%=WI.getStrValue(strTemp)%>	  </td>
    </tr>
    <tr>
      <td colspan="3" height="25" ><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" width="2%" >&nbsp;</td>
	  <% strTemp = " from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 ";
		//   if (strSchCode.startsWith("AUF")){
			// strTemp += " and exam_name like 'final%'";
		// }

	  	strTemp +="order by EXAM_PERIOD_ORDER asc"; %>
	  
      <td width="51%" height="25" > Show&nbsp; 
        <select name="grade_for" onChange="ReloadPage();">
          <%=dbOP.loadCombo("EXAM_NAME","EXAM_NAME",strTemp, 
		  							request.getParameter("grade_for"), false)%>
      </select>        grades for term &nbsp;
      <select name="semester" onChange="ReloadPage();">
        <option value="1">1st Semester</option>
        <%
strTemp = request.getParameter("semester");
if(strTemp == null) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp == null)
		strTemp = "";
}
if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>2nd Semester</option>
        <%}else{%>
        <option value="2">2nd Semester</option>
        <%}if(strTemp.compareTo("3") ==0){%>
        <option value="3" selected>3rd Semester</option>
        <%}else{%>
        <option value="3">3rd Semester</option>
        <%}if(strTemp.compareTo("0") ==0){%>
        <option value="0" selected>Summer</option>
        <%}else{%>
        <option value="0">Summer</option>
        <%}%>
      </select></td>
      <td width="32%" height="25" >School year :
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>

        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("grelease","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
      <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="15%" ><input type="image" src="../../images/form_proceed.gif"></td>
    </tr>
    <tr >
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
</table>
<script language="JavaScript">
document.grelease.grade_name.value = document.grelease.grade_for[document.grelease.grade_for.selectedIndex].text;
document.grelease.semester_name.value = document.grelease.semester[document.grelease.semester.selectedIndex].text;
</script>
<%
if(vGradeDetail != null && vGradeDetail.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="#B9B292"> 
      <td height="25" colspan="2" align="center"><strong> <%=WI.fillTextValue("grade_name")%></strong> GRADES FOR <strong><%=WI.fillTextValue("semester_name")%></strong> <strong><%=WI.fillTextValue("sy_from")%>- <%=WI.fillTextValue("sy_to")%></strong> </td>
    </tr>
  </table>
<%
boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
boolean bolIsCLDH  = strSchCode.startsWith("CLDH");
if(!bolIsFinal)
	bolIsCLDH = false;
%>

 <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="16%" height="25" align="center" class="thinborder" ><font size="1"><strong>Subject Code </strong></font></td>
      <td width="29%" align="center" class="thinborder" ><font size="1"><strong>Subject Name </strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>Credit</strong></font></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>Instructor</strong></font></td>
      <td width="8%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Grade<font size="1"><strong> </strong></font></td>
<%if(bolIsCLDH){%>
      <td width="8%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Grade %ge </td>
<%}%>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>Remarks</strong></font></td>
    </tr>
<%
String strTRCol = null;//red if faculty grade is not verified.
String strGradeReference = null;

//System.out.println(vGradeDetail);
String strDateSubmitted = null;
String strSubSecIndex = null;
String strGradeTableName = null;
if(bolIsFinal)
	strGradeTableName = "g_sheet_final";
else	
	strGradeTableName = "grade_sheet";
	
for(int i=0; i< vGradeDetail.size(); i += 8){
strGradeReference = (String)vGradeDetail.elementAt(i);


if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0) {
	strTRCol = " bgcolor=red";
	vGradeDetail.setElementAt("Unedited",i + 5);
	strSubSecIndex = "select sub_sec_index from "+strGradeTableName+" where gs_index = "+strGradeReference;
	strSubSecIndex = dbOP.getResultOfAQuery(strSubSecIndex, 0);
	strDateSubmitted = null;
	if(strSubSecIndex != null) {
		strDateSubmitted = "select DATE_SUBMITTED_WUP from faculty_load where is_valid = 1 and DATE_SUBMITTED_WUP is not null and is_valid = 1 and sub_sec_index = "+
							strSubSecIndex;
		strDateSubmitted = dbOP.getResultOfAQuery(strDateSubmitted, 0);
		if(strDateSubmitted != null)
			vGradeDetail.setElementAt("Submitted",i + 5);		
	}

}
else {	
	if(vGradeDetail.elementAt(i + 5) != null && ((String)vGradeDetail.elementAt(i + 5)).equals("Grade not encoded"))
		vGradeDetail.setElementAt("Unedited",i + 5);
		
	strTRCol = "";
}

if(vGradeDetail.elementAt(i) == null || strTRCol.length() > 0)
	strTemp = " colspan=2";
else	
	strTemp = "";
if(!bolIsFinal)
	strTRCol = "";

if(bolIsCLDH && vGradeDetail.elementAt(i) != null) {
	pstmtGetPercentGrade.setInt(1, Integer.parseInt((String)vGradeDetail.elementAt(i)));
	java.sql.ResultSet rs = pstmtGetPercentGrade.executeQuery();
	if(rs.next())
		strGradeCGH = rs.getString(1);
	else	
		strGradeCGH = "&nbsp;";
	rs.close();
}
else	
	strGradeCGH = "&nbsp;";
%>
    <tr>
      <td  height="25" class="thinborder" >&nbsp;<%=(String)vGradeDetail.elementAt(i + 1)%></td>
      <td class="thinborder" >&nbsp;<%=(String)vGradeDetail.elementAt(i+2)%></td>
      <td align="center" class="thinborder" ><%if(strTRCol.length() > 0) {%>&nbsp;<%}else{%><%=WI.getStrValue(vGradeDetail.elementAt(i+3),"&nbsp;")%><%}%></td>
      <td class="thinborder" >&nbsp;<%=WI.getStrValue((String)vGradeDetail.elementAt(i+4),"n/f")%></td>
      <td align="center" class="thinborder" <%=strTemp%>>
	  <%if(strGradeReference != null){%>
	  <a href="#" style="text-decoration:none" title="<%=strGradeReference%>"><font color="#000000"><%}%>
	  	<%=(String)vGradeDetail.elementAt(i+5)%>
	  <%if(strGradeReference != null){%></font></a><%}%>		</td>
<%if(bolIsCLDH){%>
      <td align="center" class="thinborder" <%=strTemp%>><%=WI.getStrValue(strGradeCGH, "&nbsp;")%></td>
<%}if(strTemp.length() == 0) {%>
      <td align="center" class="thinborder" ><%=WI.getStrValue(vGradeDetail.elementAt(i+6),"&nbsp;")%></td>
<%}%>
    </tr>
<%}%>
  </table>
<%
	}//if vGradeDetail size > 0
}//only if vStudInfo is not null.
%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#86AEC4">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
