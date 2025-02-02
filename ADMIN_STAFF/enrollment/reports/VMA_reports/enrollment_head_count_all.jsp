<%@ page language="java" import="utility.*,enrollment.VMAEnrollmentReports,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage(){
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
			
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
	
	document.getElementById('myTable3').deleteRow(0);
	
	document.getElementById('myTable4').deleteRow(0);	
	document.getElementById('myTable4').deleteRow(0);
	
	window.print();

}

function Search(){
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.form_.search_.value = '1';
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

</script>
<body bgcolor="#D2AE72">
<%
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	int iElemSubTotal = 0;
	int iHSSubTotal = 0;
	int iPreElemSubTotal = 0;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS-VMA Reports","enrollment_head_count_all.jsp");
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
														"enrollment_head_count_all.jsp");
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


VMAEnrollmentReports enrlReport = new VMAEnrollmentReports();
Vector vRetResult = new Vector();
Vector vCourseCount = new Vector();

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = enrlReport.operateOnVMAEnrollmentReports(dbOP, request, 2);
	if(vRetResult == null)
		strErrMsg = enrlReport.getErrMsg();
	else
		vCourseCount = (Vector)vRetResult.remove(0);
}


String strSYFrom = null;
String strSemester = null;

String[] astrConverSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", "4th Sem", "5th Sem"};

%>
<form action="./enrollment_head_count_all.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
	<tr bgcolor="#A49A6A">	
		<td width="100%" height="25" bgcolor="#A49A6A"><div align="center">
		<font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: HEAD COUNT - ALL ::::</strong></font></div></td>
	</tr>
	<tr bgcolor="#FFFFFF"><td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term: </td>
		
		<td colspan="3">			
			<%
				strSYFrom = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strSYFrom%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
				
				
			<%
			strSemester = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
			<select name="offering_sem">
			<%if(strSemester.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strSemester.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strSemester.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strSemester.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>
			
			Rows Per Page: 
			<select name="iMaxRows">
	  <% 
	  int iMaxLineCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iMaxRows"),"50"));	
	  for (int k =35; k <= 60; ++k) { 
	  	if (k == iMaxLineCount)
			strTemp = " selected";
		else	
			strTemp = "";
	  	%> 
	  	<option value="<%=k%>" <%=strTemp%>> <%=k%></option>
	  <%}%> 
	  </select>
			
			
			
			
	  </td>
	</tr>
	
	
	
	
	
	
	
	
	
	
	
	<td><td colspan="3">&nbsp;</td></td>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td><a href="javascript:Search();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
	</tr>
	
</table>

<%
int iCount = 1;	
if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable3">

	<tr><td align="right" colspan="3">
		<a href="javascript:PrintPage();">
		<img src="../../../../images/print.gif" border="0"></a></td></tr>
</table>

<%
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,true);
int iPageCount = 1;
boolean bolIsPageBreak = false;
int iResultSize = 8;
int iLineCount = 0;

int i = 0;
//Vector vSubInfo = new Vector();
while(iResultSize <= vRetResult.size()){
	iLineCount = 0;
	
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr><td colspan="3"><div align="center"><strong><%=strSchoolName%></strong><br>
          <%=strSchoolAdd%><br><br>
		  </div></td></tr>
	<tr>
		<td width="28%">&nbsp;</td>
		<td colspan="" align="center" height="25"><strong>ENROLMENT HEADCOUNT</strong></td>
		<td rowspan="2" valign="top">
			<table class="thinborderALL" cellpadding="0" cellspacing="0">
			<tr>
				<td>
				<font size="1">
				Form ID: EDP 0014<br>
				Rev. No.: 01<br>
				Rev. Date: 06/15/06				</font>				</td>
			</tr>
			</table>		</td>

	</tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="" align="center" height="25">&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>		
		<td height="25" colspan="2"><strong>Course : ALL</strong></td>
		<td height="25" width="30%"><font size="1">Date Printed : <%=WI.getTodaysDateTime()%></font></td>
	</tr>
	<tr>		
		<td height="25" colspan="2">&nbsp;</td>
		<td height="25"><strong>School Year : <strong>
		<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>, 
		<%=astrConverSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></strong></strong></td>
	</tr>	
	
</table>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="25" width="5%" align="center" class="thinborder"><strong>REC. NO.</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>ID NUMBER</strong></td>
		<td width="25%" align="center" class="thinborder"><strong>STUDENT NAME</strong></td>	
		<td width="10%" align="center" class="thinborder"><strong>COURSE</strong></td>			
		<td width="10%" align="center" class="thinborder"><strong>YEAR LEVEL</strong></td>		
		<td width="10%" align="center" class="thinborder"><strong>RES</strong></td>			
		<td width="10%" align="center" class="thinborder"><strong>SECTION</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>UNITS</strong></td>	
		<td width="10%" align="center" class="thinborder"><strong>REMARKS</strong></td>			
	</tr>

	<% 			
		for(; i < vRetResult.size();){			
		iLineCount++;		
		iResultSize += 8;		
		//vSubInfo = (Vector)vRetResult.elementAt(i + 4);	
	%>
	
	<tr>
		<td height="25" class="thinborder"><%=iCount++%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>	
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>	
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
		<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"N/A")%></td>
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td align="center" class="thinborder">&nbsp;</td>
		
	</tr>
	
	
	
		<%
			i+=8;
			if(iLineCount >= iMaxLineCount){
				bolIsPageBreak = true;
				break;		
			}else
				bolIsPageBreak = false;	
		%>
	<%}//end of for loop%>

</table>
  <%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>
<%}//end while loop%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	
	<%	
	if(vCourseCount != null && vCourseCount.size() > 0){
		while(vCourseCount.size() > 0){
	%>
	<tr>
		<td height="25"><%if(vCourseCount.size() > 0){%><%=vCourseCount.remove(0)%><%=WI.getStrValue((String)vCourseCount.remove(0),"-","","")%> : 
			<%=vCourseCount.remove(0)%><%}else{%>&nbsp;<%}%></td>
		<td><%if(vCourseCount.size() > 0){%><%=vCourseCount.remove(0)%><%=WI.getStrValue((String)vCourseCount.remove(0),"-","","")%> : 
			<%=vCourseCount.remove(0)%><%}else{%>&nbsp;<%}%></td>
		<td><%if(vCourseCount.size() > 0){%><%=vCourseCount.remove(0)%><%=WI.getStrValue((String)vCourseCount.remove(0),"-","","")%> : 
			<%=vCourseCount.remove(0)%><%}else{%>&nbsp;<%}%></td>
		<td><%if(vCourseCount.size() > 0){%><%=vCourseCount.remove(0)%><%=WI.getStrValue((String)vCourseCount.remove(0),"-","","")%> : 
			<%=vCourseCount.remove(0)%><%}else{%>&nbsp;<%}%></td>
	</tr>
	<%}
	}%>
	<tr><td height="25"><strong>TOTAL : <%=iCount = iCount - 1%></strong></td></tr>
</table>

<%}//end vRetResult != null%>
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>" />
</form>

 <!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div> 

</body>
</html>
<%
dbOP.cleanUP();
%>