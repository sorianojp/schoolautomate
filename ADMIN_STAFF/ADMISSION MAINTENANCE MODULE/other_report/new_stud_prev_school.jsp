<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {
	color: #FF0000;
	font-weight: bold;
}
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	document.getElementById('myADTable1').deleteRow(0);
	window.print();
}
</script>
<body>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"new_stud_prev_school.jsp");
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
ReportEnrollment reportEnrollment = new ReportEnrollment();
Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0) {
	vRetResult = reportEnrollment.getNewStudPrevSchoolDetail(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrollment.getErrMsg();
}

if(strErrMsg != null){%>
<font style="font-size:14px; color:#FF0000; font-weight:bold"><%=strErrMsg%></font>
<%dbOP.cleanUP();
return;}

%>
<form method="post" name="form_" action="./new_stud_prev_school.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="10%" style="font-size:10px;">SY/Term</td>
      <td width="87%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   readonly="yes"> 
        - 
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
        </select></td>
    </tr>
<!--    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2" style="font-size:10px;">
	  <input name="con_1" type="radio" value="1"> 
	  Show only students enrolled 
	  <input name="con_1" type="radio" value="2"> Show Students did not enroll 
	  <input name="con_1" type="radio" value="0"> Show All	  </td>
    </tr>
-->    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="2"><span style="font-size:10px;">Rows Per Page :
          <select name="rows_per_pg">
            <%
		int iDefVal = 0;
		strTemp = WI.fillTextValue("rows_per_pg");
		if(strTemp.length() == 0) 
			iDefVal = 30;
		else	
			iDefVal = Integer.parseInt(strTemp);
		for(int i =30; i < 100; ++i){
			if( i == iDefVal)
				strErrMsg = " selected";
			else	
				strErrMsg = "";%>
            <option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
            <%}%>
          </select>
&nbsp;&nbsp;&nbsp;
<input name="submit" type="submit" style="font-size:11px; height:20px;border: 1px solid #FF0000;" value=" Reload Page ">
      </span></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="1" cellpadding="1" id="myAdTable1">
	<tr>
		<td style="font-size:10px;" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>click to print this page
		
	  &nbsp;&nbsp;&nbsp;&nbsp;</td>
	</tr>
  </table>
<%
int iRowPerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"), "40"));
int iCount = 0;
int iPageOf   = 1;
int iTotalPages = vRetResult.size()/(5 * iRowPerPg);
if(vRetResult.size() % (5 * iRowPerPg) > 0)
	++iTotalPages;

for(int i = 0; i < vRetResult.size(); ++iPageOf){
if(i > 0) {%> 
	<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="2" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <u><%=WI.fillTextValue("report_title")%></u>
	 </td>
    </tr>
    <tr>
      <td width="37%" height="22" style="font-size:10px">Page <%=iPageOf%> of <%=iTotalPages%>&nbsp;</td>
      <td width="63%" align="right" style="font-size:10px">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <td width="4%" height="20" class="thinborder" align="center">SL # </td>
    <td width="11%" class="thinborder" align="center">Temp ID </td>
    <td width="18%" class="thinborder" align="center">Student Name </td>
    <td width="27%" class="thinborder" align="center">School Attended </td>
    <td width="40%" class="thinborder" align="center">School Address</td>
  </tr>
<%for(; i < vRetResult.size(); i += 5) {%>
  <tr>
    <td height="20" class="thinborder" style="font-size:10px;"><%=++iCount%>.</td>
    <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i)%></td>
    <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 3)%></td>
    <td class="thinborder" style="font-size:10px;"><%=WI.getStrValue(vRetResult.elementAt(i + 4),"&nbsp;")%></td>
  </tr>
<%
	if(iCount % iRowPerPg == 0) {
		i += 5;
		break;
	}
}%>
</table>
<%} //end of for(int i = 0; i < vRetResult.size(); ++iPageOf){ 

}//end of vRetResult != null%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>