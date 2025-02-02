<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iTemp = 1;
	int iIndexOf = 0;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS","statistics_master_list_zipcode.jsp");
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
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function submitForm(){
	document.form_.proceed.value='1';	
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function ReloadPage()
{
	document.form_.proceed.value = "";
	document.form_.submit();
}

function PrintThisPage() {
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);	
	document.getElementById('myADTable4').deleteRow(0);	
	document.bgColor = "#FFFFFF";
	alert("Click OK to print this page");
	window.print();
}
function FocusField(){
	if(document.form_.sy_from.length == 0 || document.form_.sy_to.length == 0)
		document.form_.sy_from.focus();
	else
		document.form_.zip_code.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<%
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"statistics_master_list_zipcode.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
ReportEnrollment reportEnrl = new ReportEnrollment();
Vector vRetResult = null;

if(WI.fillTextValue("proceed").length() > 0){
	vRetResult = reportEnrl.getMasterListByZipCode(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();		
}

%>
<form name="form_" action="./statistics_master_list_zipcode.jsp" method="post">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><strong>STATISTICS - MASTERLIST - ZIP CODE</strong></div></td>
    </tr>
	<tr> 
      <td width="4%" height="25"></td>
      <td width="96%" colspan="3"><font size="2"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="12%" height="25">School year </td>
      <td width="12%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
      <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td width="5%">Term</td>
      <td width="29%" height="25"><select name="semester">
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
      <td width="38%">
	  <input type="button" name="Login" value="Generate Report" onClick="submitForm();">	  </td>
    </tr>
   <tr>
		<td height="25">&nbsp;</td>
		<td>Zip Code: </td>
		<td colspan="4"><input name="zip_code" type="text" size="16" value="<%=WI.fillTextValue("zip_code")%>" class="textbox"
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>College: </td>
		<td colspan="4"><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course: </td>
		<td colspan="4"><select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() > 0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+strTemp+" order by course_name asc",
		  		request.getParameter("course_index"), false)%> 
          <%}%>
        </select></td>
	</tr>
	<tr> 
      <td height="25"></td>
      <td>Major</td>
      <td colspan="4"><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){
int iRowCount = 0;
int iMaxRowCount = 40;
int iCount = 1;
int iTotal = 0;
boolean bolPageBreak = false;
String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester"};

%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable4">
	<tr><td colspan="2" align="right"><a href="javascript:PrintThisPage();"><img src="../../../../../images/print.gif" border="0"></a></td></tr>
</table>
<%for(int i = 0; i < vRetResult.size(); ){
	iRowCount = 0;	
	if(bolPageBreak){
		bolPageBreak = false;
	%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td align="center"><font style="font-size:12px;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
		<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>
		<br><br>STUDENT MASTERLIST of Zipcode : <%=WI.getStrValue(WI.fillTextValue("zip_code"),"( "," )","")%>
	</font></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top" height="830">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr>
					<td width="9%" class="thinborderTOPBOTTOM">SEQ</td>
					<td height="20" width="35%" align="center" class="thinborderTOPBOTTOM">Name</td>
					<td width="56%" align="center" class="thinborderTOPBOTTOM">Address</td>					
				</tr>
				<%
				for(; i < vRetResult.size(); i+=7){
				iRowCount++;
				%>
				<tr>
					<td><%=iCount++%>.</td>
					<%
					strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
					%>
					<td height="20"><%=strTemp.toUpperCase()%></td>
					<td><%=(String)vRetResult.elementAt(i+5)%><%=WI.getStrValue(((String)vRetResult.elementAt(i+6)),", ","","").toUpperCase()%></td>
				</tr>
				<%
				
				if(iRowCount >= iMaxRowCount){
					i+=7;
					bolPageBreak = true;
					break;
				}
				}//end inner loop%>
				
			</table>
		</td>
	</tr>
	<tr><td colspan="3" align="right">Page <%=iTemp++%></td></tr>
</table>

<%}//end outer loop


}//end of vRetResult != null%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
<tr bgcolor="#A49A6A"><td height="25" colspan="3">&nbsp;</td></tr>
</table>
<input type="hidden" name="proceed">

</form>
<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>
</body>
</html>
<%
dbOP.cleanUP();
%>
