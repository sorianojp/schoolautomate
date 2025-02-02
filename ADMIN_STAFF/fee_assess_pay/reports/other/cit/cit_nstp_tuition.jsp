<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg= null;
	String strTemp   = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - REPORTS","cit_nstp_tuition.jsp");
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
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"cit_nstp_tuition.jsp");
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

Vector vRetResult = new Vector();
Vector vCourseIndex = new Vector();
ReportFeeAssessment reportFA = new ReportFeeAssessment();

if(WI.fillTextValue("reloadPage").length() > 0){
	vRetResult = reportFA.getNSTPUnitRate(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportFA.getErrMsg();
	else
		vCourseIndex = (Vector)vRetResult.remove(1);	
	
}


%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function showList(){
	document.form_.reloadPage.value = "1";
	document.form_.print_page.value = "";
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintPage(){

	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);	

	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);
	document.getElementById("myADTable2").deleteRow(0);

	document.getElementById("myADTable3").deleteRow(0);
	
	document.getElementById("myADTable4").deleteRow(0);
	document.getElementById("myADTable4").deleteRow(0);


	window.print();
}

</script>
<body bgcolor="#D2AE72">
<form action="./cit_nstp_tuition.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: NSTP TUITION DETAIL  ::::</strong></font></strong></font></div></td>
    </tr>
	<tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">SY/Term:</td>
			
			<td width="80%" colspan="3">
				
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
				%>
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
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
				strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
				%>
				
				<select name="semester">
				<%if(strTemp.equals("1")){%>
					<option value="1" selected>1st Sem</option>
				<%}else{%>
					<option value="1">1st Sem</option>
				
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2nd Sem</option>
				<%}else{%>
					<option value="2">2nd Sem</option>
					
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>3rd Sem</option>
				<%}else{%>
					<option value="3">3rd Sem</option>
				
				<%}if(strTemp.equals("0")){%>
					<option value="0" selected>Summer</option>
				<%}else{%>
					<option value="0">Summer</option>
				<%}%>
				</select>					</td>
		</tr>
		

		<tr><td height="20" colspan="3">&nbsp;</td></tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="10"><a href="javascript:showList()"><img src="../../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr><td height="20" colspan="3">&nbsp;</td></tr>
  </table>

<%
String[] astrConvertSem = {"SU", "FS", "SS", "TS"};
if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../../../images/print.gif" border="0"></a></td></tr>
	<tr><td colspan="3"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br><br>
		  </div></td></tr>
	<tr><td align="center" height="25" bgcolor=""><strong>LIST OF NSTP TUITION DETAIL</strong></td></tr>
	<tr>
	  <td height="25" bgcolor="">GRAND TOTAL: <%=vRetResult.remove(0)%></td>
    </tr>
</table>



 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<%	
	
	String strCurrCoursCode = "";
	String strPrevCourseCode = "";
	int iCount = 1;
	String strTotAmt = null;
	int iIndexOf = 0 ;
	for(int i = 0; i < vRetResult.size(); i+=13){
		strCurrCoursCode = (String)vRetResult.elementAt(i+12);
		if(!strPrevCourseCode.equals(strCurrCoursCode)){
			iIndexOf = vCourseIndex.indexOf((String)vRetResult.elementAt(i+5));
			if(iIndexOf > -1)
				strTotAmt = CommonUtil.formatFloat((String)vCourseIndex.elementAt(iIndexOf + 1),true);
	%>
	
	<tr>
		<td colspan="5" class="thinborder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="">

				<tr>
					<td height="25" width="20%"><strong>Course Code : </strong><strong><%=(String)vRetResult.elementAt(i+3)%></strong></td>
					<td><strong>Course Name : </strong><strong><%=strCurrCoursCode%></strong></td>
					<td width="20%"><strong>Total Amount :</strong> <strong><%=WI.getStrValue(strTotAmt)%></strong></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>		
		<td class="thinborder" width="5%" height="20"><strong>Count</strong></td>
		<td class="thinborder" width="20%" height="20"><strong>Student ID</strong></td>
		<td class="thinborder" width="45%"><strong>Student Name</strong></td>		
		<td class="thinborder" width="15%"><strong>Year Level</strong></td>
		<td class="thinborder" width="15%"><strong>Amount</strong></td>
	</tr>
		<%}
		strPrevCourseCode = strCurrCoursCode;
		%>
	<tr>		
		<td class="thinborder" height="20"><%=iCount++%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" align=""><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</td>		
		<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+11),true)%>&nbsp;</td>		
	</tr>	
	<%}%>

</table>
 <%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable4">
<tr><td height="25" colspan="2">&nbsp;</td></tr>
<tr><td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="print_page">
</form>


 <!--- Processing Div --->

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