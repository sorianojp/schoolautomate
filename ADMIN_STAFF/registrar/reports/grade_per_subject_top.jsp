<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	//this.SubmitOnce('form_');
}
function PrintPage() {
 	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function showHideGWA() {
	var iSelGwaCon = document.form_.gwa_con.selectedIndex;
	if(iSelGwaCon == 0) {
		hideLayer('gwa_fr_label');
		hideLayer('gwa_to_label');
	}
	else if(iSelGwaCon == 3) {
		showLayer('gwa_fr_label');
		showLayer('gwa_to_label');
	}
	else {
		showLayer('gwa_fr_label');
		hideLayer('gwa_to_label');
	}
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	//String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Grade per subject","grade_per_subject_top.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","REPORTS",request.getRemoteAddr(),
							//							"grade_per_subject_top.jsp");
if(request.getSession(false).getAttribute("userIndex") == null)
	iAccessLevel = -1;


if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
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
ReportRegistrarExtn RR = new ReportRegistrarExtn();
Vector vRetResult      = null;

if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = RR.getGradePerSubjectTopStud(dbOP, request);
	if(vRetResult == null) {
		strErrMsg = RR.getErrMsg();
	}
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsCGH = strSchCode.startsWith("CGH");
boolean bolShowPercent = false;
%>
<form action="./grade_per_subject_top.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: GRADE PER SUBJECT - TOP STUDENT ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="3"><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" style="font-size:11px; color:#0000FF; font-weight:bold">
	  <input type="checkbox" name="get_midterm" value="checked" <%=WI.fillTextValue("get_midterm")%>>
      Show Midterm grade </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="10%">SY-Term</td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
//System.out.println((String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
-
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strTemp.compareTo("4") ==0){%>
  <option value="4" selected>4th Sem</option>
  <%}else{%>
  <option value="4">4th Sem</option>
  <%}if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="image" src="../../../images/refresh.gif" onClick="ReloadPage();">
&nbsp;&nbsp;&nbsp; <a href="./grade_per_subject.jsp" style="text-decoration:none">
	  <font style="font-size:11px; font-weight:bold; color:#0000FF">Go to grade Per subject</font></a> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td width="21%">Year Level :
        <select name="year_level">
          <option value="1">1st</option>
<%
strTemp = WI.fillTextValue("year_level");
if(strTemp.equals("2")){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.equals("4")){%>
          <option value="4" selected>4th</option>
<%}else{%>
          <option value="4">4th</option>
<%}if(strTemp.equals("5")){%>
          <option value="5" selected>5th</option>
<%}else{%>
          <option value="5">5th</option>
<%}if(strTemp.equals("6")){%>
          <option value="6" selected>6th</option>
<%}else{%>
          <option value="6">6th</option>
<%}%>
        </select></td>
      <td width="67%"><font style="font-size:9px;">Exclude Subject Code :
      <input name="exclude_sub" type="text" size="48" maxlength="64" value="<%=WI.fillTextValue("exclude_sub")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:9px;">
      ex:subcode1,subcode2</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">
	  <select name="course_index" style="font-size:10px;font-weight:bold">
<%
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and degree_type = 0 order by course_code asc";
%>
        <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name",strTemp,WI.fillTextValue("course_index"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" align="left">
	  	<table bgcolor="#DDDDDD" class="thinborderALL" cellpadding="0" cellspacing="0" border="0" width="95%">

<%//if(bolIsCGH){
if(WI.fillTextValue("show_percent").length() > 0) {
	strTemp = " checked";
	bolShowPercent = true;
}
else
	strTemp = "";
%>
	  		<tr>
	  		  <td width="45%" class="thinborderRIGHT"><input type="checkbox" name="show_percent" value="1" <%=strTemp%>>
Show Grade Percentage </td>
	  		  <td width="55%" class="thinborderNONE">
			  Sort Grade
			  &nbsp;&nbsp;
			  <%strTemp = WI.fillTextValue("order");
			  if(strTemp.equals("asc") || strTemp.length() == 0)
			  	strTemp = " checked";
			  else
			  	strTemp = "";
			  %>
			  <input name="order" type="radio" value="asc"<%=strTemp%>> Asc
			  <%if(strTemp.length() == 0)
			  	strTemp = " checked";
			   else
				strTemp = "";
			   %>
			  <input name="order" type="radio" value="desc"<%=strTemp%>> Desc			  </td>
  		  </tr>
	  		<tr>
	  		  <td class="thinborderRIGHT">Show Top	:
			  	<select name="top_">
					<option value="1">1</option>
<%
strTemp = WI.fillTextValue("top_");
if(strTemp.length() == 0)
	strTemp = "3";
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
					<option value="2"<%=strErrMsg%>>2</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
					<option value="3"<%=strErrMsg%>>3</option>
<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
					<option value="4"<%=strErrMsg%>>4</option>
<%
if(strTemp.equals("5"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
					<option value="5"<%=strErrMsg%>>5</option>
				</select>			  </td>
	  		  <td class="thinborderNONE">Print
			    <select name="sub_per_page">
                  <option value="1">1</option>
                  <%
strTemp = WI.fillTextValue("sub_per_page");
if(strTemp.length() == 0)
	strTemp = "2";
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
                  <option value="2"<%=strErrMsg%>>2</option>
                  <%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
                  <option value="3"<%=strErrMsg%>>3</option>
                  <%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
                  <option value="4"<%=strErrMsg%>>4</option>
                  <%
if(strTemp.equals("5"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
                  <option value="5"<%=strErrMsg%>>5</option>
                </select>
		      Subjects per page. </td>
  		  </tr>
<%//}%>
	  	</table>	  </td>
    </tr>

    <tr>
      <td colspan="4" height="20"><hr size="1"></td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <TD>&nbsp;</TD>
      <TD align="right"><a href='javascript:PrintPage();'><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print</font></TD>
    </tr>
  </table>
<%
int iRowPerPg = Integer.parseInt(WI.fillTextValue("sub_per_page"));
int iCurPage  = 0;
Vector vFacultyInfo = (Vector)vRetResult.remove(0);
Vector vSubInfo     = (Vector)vRetResult.remove(0);

Vector vSubSecIndex = null;

String strGradeValue = null;
int p = 0;
java.sql.PreparedStatement pstmtGetSubName = dbOP.getPreparedStatement("select sub_name from subject where sub_index = ?");
java.sql.ResultSet rs = null;
String strSubName = null;
for(int a = 0 ; a < vRetResult.size(); iCurPage=0) {
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="2">
	  <div align="center"><strong>
	  <%=SchoolInformation.getSchoolName(dbOP,true,false)%> <br>
		TOP <%=WI.fillTextValue("top_")%> STUDENTS PER SUBJECT<br>
        <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>

	  </strong></div>	 </TD>
    </tr>
    <tr>
      <TD width="41%">&nbsp;</TD>
      <TD width="59%" align="right"><font size="1">Date and Time printied : <b><%=WI.getTodaysDateTime()%></b></font></TD>
    </tr>
    <tr>
      <TD colspan="2" align="center">LEVEL <%=WI.fillTextValue("year_level")%></TD>
    </tr>
  </table>
<%for(; p < vSubInfo.size(); p += 2) {
pstmtGetSubName.setString(1, (String)vSubInfo.elementAt(p));
rs = pstmtGetSubName.executeQuery();
if(rs.next())
	strSubName = rs.getString(1);
else
	strSubName = "";
rs.close();%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="33" colspan="2" valign="bottom">&nbsp;&nbsp;&nbsp;Subject : <%=strSubName%></TD>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="8%" class="thinborder" align="center"><strong><font size="1">RANK</font></strong></td>
<%if(!bolIsCGH){%>
      <td width="20%" height="25" class="thinborder" align="center"><font size="1"><strong>STUDENT ID</strong></font></td>
<%}%>
      <td width="32%" class="thinborder" align="center"><font size="1"><strong>STUDENT NAME</strong></font></td>
      <td width="20%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">SECTION</td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">GRADE</font></strong></td>
<%if(bolShowPercent){%>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">GEN. AVERAGE </font></strong></td>
<%}
vSubSecIndex = new Vector();
for(int i =0,iRank=0 ; i < vRetResult.size() && vSubInfo.size() > 0; i += 9){
	if(!vSubInfo.elementAt(p).equals(vRetResult.elementAt(i + 4)))//subject does not match.
		continue;

	if(vSubSecIndex.indexOf(vRetResult.elementAt(i + 5)) == -1)
		vSubSecIndex.addElement(vRetResult.elementAt(i + 5));

	strGradeValue = WI.getStrValue((String)vRetResult.elementAt(i + 2));
	if(bolIsCGH && strGradeValue != null && (strGradeValue.endsWith("0") || strGradeValue.length() == 3) && strGradeValue.length() > 1)
		strGradeValue = strGradeValue+"0";
	strTemp = (String)vRetResult.elementAt(i + 4);
	if(strTemp != null && bolIsCGH) {
		if(strTemp.endsWith(".00"))
			strTemp = strTemp.substring(0,strTemp.length() - 1);
		else if(strTemp.indexOf(".") == -1)
			strTemp = strTemp+".0";
	}
%>
    <tr>
      <td class="thinborder" align="center"><%=vRetResult.elementAt(i + 8)%></td>
<%if(!bolIsCGH){%>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
<%}%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
	  <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i + 6)%></td>
	  <td class="thinborder" align="center">&nbsp;<%=strGradeValue%></td>
<%if(bolShowPercent){%>
      <td class="thinborder" align="center">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 3))%></td>
 <%}%>
    </tr>
<%
vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
i = i - 9;

	}//end of for loop for(int i =0,iRank=0 ; i < vRetResult.size(); i += 6){.
%>
<!-- print here faculty information.-->
<%if(false){///////////////// cgh chaned here again ....... code below wasted - 1 day work wasted as well %>
    <tr>
      <td height="25" colspan="6" class="thinborder">Approved By : <br>
	  	<table width="90%" align="right" cellpadding="0" cellspacing="0">
		<%vFacultyInfo = RR.getFacultyNameTopStud(dbOP,vSubSecIndex);
		  if(vFacultyInfo == null)
		  	vFacultyInfo = new Vector();
		  while(vFacultyInfo.size() > 0) {%>
	  		<tr>
				<td width="46%" height="25" align="center">____________________</td>
				<td width="54%" align="center"><%if(vFacultyInfo.size() > 1){%>__________________<%}%></td>
			</tr>
			<tr>
			  <td height="25" align="center"><%=vFacultyInfo.remove(0)%></td>
			  <td align="center">
				<%if(vFacultyInfo.size() > 0) {%>
					<%=vFacultyInfo.remove(0)%>
				<%}else{%>&nbsp;<%}%>			  </td>
		  </tr>
		  <%}//end of priting faculty information while(vFacultyInfo.size() > 0)%>
	  </table>	  </td>
    </tr>
<%}//do not show the code block stated above
if(bolIsCGH){%>
    <tr>
      <td height="25" colspan="2" class="thinborderBOTTOMLEFT">Certified by : <br>
        <br><br>
	  <%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%>
		<br>Registrar      </td>
      <td height="25" colspan="4" class="thinborderBOTTOM">Noted by :<br>
        <br>
        <br>
	  IRIS CHUA-SO, RN, MAN<br>
	  Dean</td>
    </tr>
<%}%>
  </table>
<table bgcolor="#FFFFFF" width="100%"><tr><td height="40">&nbsp;&nbsp;</td></tr></table>
<%
++iCurPage;
	if(iRowPerPg == iCurPage) {
		p += 2;
		break;
	}
 }//for(int p = 0; p < vSubInfo.size(); p += 2) {
if( (a + 10) < vRetResult.size()){%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//insert page break;
//I have to insert here page break;
}//for(int a = 0 ; a < vRetResult.size(); iCurPage=0) {
%>

<%}//only if vRetResult not null%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
