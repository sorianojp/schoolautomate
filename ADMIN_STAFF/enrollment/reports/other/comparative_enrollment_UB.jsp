<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";

	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
</script>
<body bgcolor="#D2AE72">
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
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Other report-Comparative Enrollment","comparative_enrollment_UB.jsp");
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
														"comparative_enrollment_UB.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
ReportEnrollment reportE = new ReportEnrollment();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_from2").length() > 0) {
	vRetResult = reportE.comparitiveEnrollmentDataUB(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportE.getErrMsg();
}
%>
<form action="./comparative_enrollment_UB.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" style="font-weight:bold; color:#FFFFFF">:::: COMPARATIVE ENROLLMENT SUMMARY ::::</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="5%" height="25"></td>
      <td width="45%">SY/Term From (Current) </td>
      <td width="50%">SY/Term To (Previous) </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_','sy_from')"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
        -     
<%
if(strTemp.length() > 0) 
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1);
%>
		<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strErrMsg =WI.fillTextValue("semester");
if(strErrMsg.length() ==0) 
	strErrMsg = (String)request.getSession(false).getAttribute("cur_sem");
if(strErrMsg.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strErrMsg.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}if(strErrMsg.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
<%}else{%>
          <option value="4">4th Sem</option>
<%}if(strErrMsg.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select>          
      <td><%
if(WI.fillTextValue("sy_from2").length() == 0) 
	strTemp = Integer.toString(Integer.parseInt(strTemp) - 2);
else
	strTemp = WI.fillTextValue("sy_from2");
%>
        <input name="sy_from2" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_','sy_from')"
	  onKeyUp='DisplaySYTo("form_","sy_from2","sy_to2")'>
-
<%
if(strTemp.length() > 0) 
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1);
%>
<input name="sy_to2" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
<select name="semester2">
  <option value="1">1st Sem</option>
  <%
if(WI.fillTextValue("semester2").length() > 0) 
	strErrMsg = WI.fillTextValue("semester2");
if(strErrMsg.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strErrMsg.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strErrMsg.compareTo("4") ==0){%>
  <option value="4" selected>4th Sem</option>
  <%}else{%>
  <option value="4">4th Sem</option>
  <%}if(strErrMsg.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select>    </tr>
    <tr> 
      <td height="10"></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="10"></td>
      <td align="right"><input name="submit" type="submit" value="Generate Report"></td>
      <td align="right">
	  <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>Print page
	  &nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){//System.out.println(vRetResult);
    Vector vCollege = (Vector)vRetResult.remove(0);
    Vector vSY1     = (Vector)vRetResult.remove(0);
    Vector vSY2     = (Vector)vRetResult.remove(0);
    Vector vSY1New  = (Vector)vRetResult.remove(0);
    Vector vSY2New  = (Vector)vRetResult.remove(0);
	
	String[] astrConvertTerm = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center"><b>COMPARATIVE ENROLLMENT SUMMARY</b> <br>
		<font  style="font-size:9px;">
		<%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%> SY 
		<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%> VS 
		<%=WI.fillTextValue("sy_from2")%>-<%=WI.fillTextValue("sy_to2")%> <br>
		Date and Time Generated : <%=WI.getTodaysDateTime()%></font>
		<br><br>
		<strong>OVERALL ENROLLMENT</strong>
		<br>		
		</td>
	</tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold">
		<td width="25%" rowspan="2" class="thinborder">COLLEGES/ACADEMIC DEPT</td>
		<td colspan="4" align="center" class="thinborder"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%> COMPARATIVE ENROLLMENT</td>
		<td width="10%" rowspan="2" class="thinborder">% to total enrollment <br>
		(<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>)</td>
	</tr>
	<tr style="font-weight:bold" align="center">
	  <td class="thinborder" width="15%">SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></td>
      <td class="thinborder" width="15%"><%=WI.fillTextValue("sy_from2")%>-<%=WI.fillTextValue("sy_to2")%></td>
      <td class="thinborder" width="15%">Difference</td>
      <td class="thinborder" width="15%">%ge</td>
	</tr>
<%
Double objDTemp = null;
int iIndexOf = 0; 
int iSYF  = 0;
int iSYT  = 0;
int iDiff = 0;

int iTotalSYF = ((Integer)vSY1.remove(0)).intValue();
int iTotalSYT = ((Integer)vSY2.remove(0)).intValue();

double dPercentDiff = 0d; double dPercentCur = 0d;

for(int i =0; i < vCollege.size(); i += 2) {
objDTemp = (Double)vCollege.elementAt(i);
//get sy from info
iIndexOf = vSY1.indexOf(objDTemp);
if(iIndexOf > -1) {
	iSYF = Integer.parseInt((String)vSY1.remove(iIndexOf + 1));
	vSY1.remove(iIndexOf);
}
else 
	iSYF = 0;
//get sy to info.. 
iIndexOf = vSY2.indexOf(objDTemp);
if(iIndexOf > -1) {
	iSYT = Integer.parseInt((String)vSY2.remove(iIndexOf + 1));
	vSY2.remove(iIndexOf);
}
else 
	iSYT = 0;

iDiff = iSYF - iSYT;
if(iSYT > 0)
	dPercentDiff = (iDiff * 100d/iSYT);
else	
	dPercentDiff = 0d;
	
if(iTotalSYF > 0)
	dPercentCur  = iSYF * 100d/iTotalSYF;
else	
	dPercentCur = 0d;
%>
	<tr>
	  <td class="thinborder" height="25"><%=vCollege.elementAt(i + 1)%></td>
	  <td class="thinborder" align="right"><%=iSYF%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%=iSYT%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%if(iDiff > 0){%><%=iDiff%><%}else{%>(<%=iDiff * -1%>)<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%if(dPercentDiff > 0){%><%=CommonUtil.formatFloat(dPercentDiff,false)%><%}else{%>(<%=CommonUtil.formatFloat(dPercentDiff * -1, false)%>)<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dPercentCur,false)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>  
<%}

iDiff = iTotalSYF - iTotalSYT;
dPercentDiff = (iDiff * 100d/iTotalSYT);
%>
	<tr style="font-weight:bold">
	  <td class="thinborder" height="25">TOTALS</td>
	  <td class="thinborder" align="right"><%=iTotalSYF%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%=iTotalSYT%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%if(iDiff > 0){%><%=iDiff%><%}else{%>(<%=iDiff * -1%>)<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%if(dPercentDiff > 0){%><%=CommonUtil.formatFloat(dPercentDiff,false)%><%}else{%>(<%=CommonUtil.formatFloat(dPercentDiff * -1, false)%>)<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right">100&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>  
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center"><b><BR>FRESHMEN ENROLLMENT</b> <br><br></td>
	</tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold">
		<td width="25%" rowspan="2" class="thinborder">COLLEGES/ACADEMIC DEPT</td>
		<td colspan="4" align="center" class="thinborder"> COMPARATIVE ENROLLMENT OF FRESHMEN </td>
		<td width="10%" rowspan="2" class="thinborder">% to total enrollment <br>
		(<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>)</td>
	</tr>
	<tr style="font-weight:bold" align="center">
	  <td class="thinborder" width="15%">SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></td>
      <td class="thinborder" width="15%"><%=WI.fillTextValue("sy_from2")%>-<%=WI.fillTextValue("sy_to2")%></td>
      <td class="thinborder" width="15%">Difference</td>
      <td class="thinborder" width="15%">%ge</td>
	</tr>
<%
iTotalSYF = ((Integer)vSY1New.remove(0)).intValue();
iTotalSYT = ((Integer)vSY2New.remove(0)).intValue();

dPercentDiff = 0d; dPercentCur = 0d;

for(int i =0; i < vCollege.size(); i += 2) {
objDTemp = (Double)vCollege.elementAt(i);
//get sy from info
iIndexOf = vSY1New.indexOf(objDTemp);
if(iIndexOf > -1) {
	iSYF = Integer.parseInt((String)vSY1New.remove(iIndexOf + 1));
	vSY1New.remove(iIndexOf);
}
else 
	iSYF = 0;
//get sy to info.. 
iIndexOf = vSY2New.indexOf(objDTemp);
if(iIndexOf > -1) {
	iSYT = Integer.parseInt((String)vSY2New.remove(iIndexOf + 1));
	vSY2New.remove(iIndexOf);
}
else 
	iSYT = 0;

iDiff = iSYF - iSYT;
if(iSYT > 0)
	dPercentDiff = (iDiff * 100d/iSYT);
else	
	dPercentDiff = 0d;
	
if(iTotalSYF > 0)
	dPercentCur  = iSYF * 100d/iTotalSYF;
else	
	dPercentCur = 0d;
%>
	<tr>
	  <td class="thinborder" height="25"><%=vCollege.elementAt(i + 1)%></td>
	  <td class="thinborder" align="right"><%=iSYF%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%=iSYT%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%if(iDiff > 0){%><%=iDiff%><%}else{%>(<%=iDiff * -1%>)<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%if(dPercentDiff > 0){%><%=CommonUtil.formatFloat(dPercentDiff,false)%><%}else{%>(<%=CommonUtil.formatFloat(dPercentDiff * -1, false)%>)<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dPercentCur,false)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>  
<%}
iDiff = iTotalSYF - iTotalSYT;
dPercentDiff = (iDiff * 100d/iTotalSYT);
%>
	<tr style="font-weight:bold">
	  <td class="thinborder" height="25">TOTALS</td>
	  <td class="thinborder" align="right"><%=iTotalSYF%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%=iTotalSYT%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%if(iDiff > 0){%><%=iDiff%><%}else{%>(<%=iDiff * -1%>)<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right"><%if(dPercentDiff > 0){%><%=CommonUtil.formatFloat(dPercentDiff,false)%><%}else{%>(<%=CommonUtil.formatFloat(dPercentDiff * -1, false)%>)<%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	  <td class="thinborder" align="right">100&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>  
</table>



<%}%>
<table width="100%">
<tr>
	<td style="font-size:9px;">Printed By : <%=(String)request.getSession(false).getAttribute("first_name")%></td>
</tr>
</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
