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
	if(document.getElementById('myADTable2'))
		document.getElementById('myADTable2').deleteRow(0);
	if(document.getElementById('myADTable3'))
		document.getElementById('myADTable3').deleteRow(0);
		
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
														"enrolment_sum_prev_school_detail_v2.jsp");
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
Vector vSchoolInfo = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0) {
	request.setAttribute("detail_v2","1");
	vRetResult = reportEnrollment.getEnrolSumFromPrevSchoolDetail(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrollment.getErrMsg();
}
else 
	strErrMsg = "Please select SY/Term Information."; 
if(vRetResult == null && strErrMsg == null)
	strErrMsg = "Un-known Error.";

if(strErrMsg != null){%>
<font style="font-size:14px; color:#FF0000; font-weight:bold"><%=strErrMsg%></font>
<%dbOP.cleanUP();
return;}

vSchoolInfo = (Vector)vRetResult.remove(0);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

if(vSchoolInfo != null && vSchoolInfo.size() > 0) {
	int iIndexOf = 0;
	String strSQLQuery = "select sch_accr_index, sch_name, sch_addr from sch_accredited";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		iIndexOf = vSchoolInfo.indexOf(rs.getString(1));
		if(iIndexOf == -1)
			continue;
		
		vSchoolInfo.setElementAt(rs.getString(2) + WI.getStrValue(rs.getString(3), " - ", "",""), iIndexOf);
	}
	rs.close();
}

%>
<form method="post" name="form_" action="./enrolment_sum_prev_school_detail_v2.jsp" onSubmit="SubmitOnceButton(this);">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="1" cellpadding="1" id="myADTable1">
	<tr>
		<td style="font-size:10px;">
		<a href="./enrolment_sum_prev_school.jsp"><img src="../../../images/go_back.gif" border="0"></a> Go Back
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>click to print this page
		
		&nbsp;&nbsp;&nbsp;&nbsp;
		
		Rows Per Page : 
	  	<select name="rows_per_pg">
		<option value="100000">Show ALL</option>
	  	<%
		int iDefVal = 0;
		strTemp = WI.fillTextValue("rows_per_pg");
		if(strTemp.length() == 0) 
			iDefVal = 40;
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
		<input type="submit" value=" Reload Page " style="font-size:11px; height:20px;border: 1px solid #FF0000;">	
		<font  style="font-weight:bold; color:#0000FF; font-size:9px;">	
			<input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%>> Show Grade School Only
		</font>
		</td>
	</tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <td width="1%" height="25" align="right">&nbsp;</td>
      <td width="8%">Status </td>
      <td width="73%"><select name="status_index">
          <option value=""></option>
          <%=dbOP.loadCombo("status_index","status",
					" from user_status where is_for_student = 1 and (status='New'" +
					" or status like 'transfer%' or status like 'second%')" + 
					"order by status asc",
					WI.fillTextValue("status_index"), false)%>
      </select></td>
      <td width="9%" height="25" align="right">&nbsp;</td>
      <td width="9%" height="25">&nbsp;</td>
    </tr>
	</table>
<%if(strSchCode.startsWith("CGH")){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="1" cellpadding="1" id="myADTable2">
	<tr>
	  <td style="font-size:10px;">Year Level: 
	  <select name="yr_level">
	  <option value=""></option>
<%
iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("yr_level"), "0"));	  
	for(int i = 1; i < 5; ++i) {	
		if(i == iDefVal)
			strTemp = "selected";
		else	
			strTemp = "";
	%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	  
	  &nbsp;&nbsp;&nbsp;
	  Sort By: 
	  <select name="order_by">
	  <option value=""></option>
<%
strTemp = WI.fillTextValue("order_by");
if(strTemp.equals("lname"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="lname"<%=strErrMsg%>>Last Name</option>
<%
if(strTemp.equals("sch_name"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="sch_name"<%=strErrMsg%>>School Name</option>
	  </select>
	  
	  </td>
    </tr>
  </table>
<%}

int iRowPerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"), "40"));
int iCount = 0;
int iPageOf   = 1;
int iTotalPages = vRetResult.size()/(3 * iRowPerPg);
if(vRetResult.size() % (3 * iRowPerPg) > 0)
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
    <td width="2%" height="20" class="thinborder" align="center">SL # </td>
    <td width="8%" class="thinborder" align="center">Student ID </td>
    <td width="12%" class="thinborder" align="center">Student Name </td>
    <td width="8%" class="thinborder" align="center">Course-Year</td>
    <td width="45%" class="thinborder" align="center">Prev. School Attended </td>
    <td width="20%" class="thinborder" align="center">School Address </td>
  </tr>
<%for(; i < vRetResult.size(); i += 7) {%>
  <tr>
    <td height="20" class="thinborder" style="font-size:10px;"><%=++iCount%>.</td>
    <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i)%></td>
    <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 3)%>
	<%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "-", "","")%>
	<%=WI.getStrValue((String)vRetResult.elementAt(i + 5), "-", "","")%>	</td>
    <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder" style="font-size:10px;"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6), "", "","&nbsp;")%></td>
  </tr>
<%
	if(iCount % iRowPerPg == 0) {
		i += 7;
		break;
	}
}%>
</table>
<%} //end if vRetResult is not null %>
<br>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
     <td align="center" style="font-size:11px; font-weight:bold"><u>SUMMARY</u><br>&nbsp;</td>
  </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
		<td width="49%" valign="top">
  			  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
				<tr>
				    <td width="6%" height="20" class="thinborder" align="center">SL # </td>
				    <td width="80%" class="thinborder" align="center">School Name  </td>
				    <td width="14%" class="thinborder" align="center"># of Student </td>
			    </tr>
				<%for(int i = 0,iSL=1; i < vSchoolInfo.size(); i += 4, iSL += 2){%>
				<tr>
				    <td height="20" class="thinborder" style="font-size:10px;"><%=iSL%>.</td>
				    <td class="thinborder" style="font-size:10px;"><%=vSchoolInfo.elementAt(i)%></td>
				    <td class="thinborder" style="font-size:10px;"><%=vSchoolInfo.elementAt(i + 1)%></td>
			    </tr>
				<%}%>
			  </table>
		</td>
		<td width="2%">&nbsp;</td>
		<td width="49%" valign="top">
  			  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
				<tr>
				    <td width="6%" height="20" class="thinborder" align="center">SL # </td>
				    <td width="80%" class="thinborder" align="center">School Name  </td>
				    <td width="14%" class="thinborder" align="center"># of Student </td>
			    </tr>
				<%for(int i = 2,iSL=2; i < vSchoolInfo.size(); i += 4, iSL += 2){%>
				<tr>
				    <td height="20" class="thinborder" style="font-size:10px;"><%=iSL%>.</td>
				    <td class="thinborder" style="font-size:10px;"><%=vSchoolInfo.elementAt(i)%></td>
				    <td class="thinborder" style="font-size:10px;"><%=vSchoolInfo.elementAt(i + 1)%></td>
			    </tr>
				<%}%>
			  </table>
		</td>
	</tr>
  </table>
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>