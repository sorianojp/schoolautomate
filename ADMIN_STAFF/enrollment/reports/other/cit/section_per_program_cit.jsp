<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector,java.util.Calendar,java.text.*,java.util.Date " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
function submitForm() {
	document.form_.reloadPage.value='1';	
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
	
	document.getElementById('myID3').deleteRow(0);
	document.getElementById('myID3').deleteRow(0);
	
	document.getElementById('myID4').deleteRow(0);
	document.getElementById('myID4').deleteRow(0);
	
	//alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
}


</script>




<style type="text/css">
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>

<body bgcolor="#D2AE72">
<%
	String strTemp = null;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS-enrollment summary","section_per_program_cit.jsp");
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
														"section_per_program_cit.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
Vector vRetResult = null;

ReportEnrollment reportEnrl = new ReportEnrollment();
if(WI.fillTextValue("reloadPage").length()>0){
	vRetResult = reportEnrl.getRegAndOffSemSectionPerProgram(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();	
}	


String[] strConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
	
%>
<form action="./section_per_program_cit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          SECTION PER PROGRAM REPORT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID2">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">School year </td>
      <td width="22%" height="25"> <%
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
      <td width="22%" height="25"><select name="offering_sem">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
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
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  
<%
if(vRetResult != null && vRetResult.size() > 0){
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID3">
	<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a> 
		<font size="1">Click to print summary</font>		
	</td></tr>
	<td height="15">&nbsp;</td>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
		SECTIONS PER PROGRAM
		<br> <strong><%=strConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></strong>	
	</td></tr>	
	<tr><td height="15">&nbsp;</td></tr>			
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" align="center" width="20%" rowspan="2"><strong>PROGRAM</strong></td>
		<td class="thinborder" align="center" colspan="2" height="20"><strong>ASSIGNED SECTION</strong></td>
	</tr>
	<tr>
		<td class="thinborder" width="40%" align="center" height="20">REGULAR SEM OFFERINGS</td>
		<td class="thinborder" width="40%" align="center">OFF-SEM OFFERINGS</td>
	</tr>
	
	<%
	
	String strCurrCollege = null;
	String strPrevCollege = "";
	String strDepartment = null;
	Vector vTemp = new Vector();
	
	for(int i = 0 ; i < vRetResult.size(); i+=5){
		strCurrCollege = (String)vRetResult.elementAt(i+1);
		strDepartment = (String)vRetResult.elementAt(i+2);
		
		if(strDepartment == null)
			continue;
		
	if(!strPrevCollege.equals(strCurrCollege)){
		strPrevCollege = strCurrCollege;
	%>
	<tr>
		<td style="padding-left:30px;" colspan="3" class="thinborder"><strong><%=strCurrCollege%></strong></td>
	</tr>
	<%}%>
	
	
	<tr>
		<td class="thinborder" align="right" style="padding-right:15px"><%=strDepartment%></td>
		<td class="thinborder">
		<%	
		strTemp = null;
		vTemp = new Vector();
		vTemp = (Vector)vRetResult.elementAt(i+3);
		if(vTemp.size() > 0){
			for(int x = 0; x < vTemp.size(); x++){
				if(strTemp == null)
					strTemp = (String)vTemp.elementAt(x);
				else
					strTemp += ", "+(String)vTemp.elementAt(x);
			}
		}
		%><%=WI.getStrValue(strTemp,"&nbsp;")%>
		</td>
		<td class="thinborder">
		<%	
		strTemp = null;
		vTemp = new Vector();
		vTemp = (Vector)vRetResult.elementAt(i+4);
		if(vTemp.size() > 0){
			for(int x = 0; x < vTemp.size(); x++){
				if(strTemp == null)
					strTemp = (String)vTemp.elementAt(x);
				else
					strTemp += ", "+(String)vTemp.elementAt(x);
			}
		}
		%><%=WI.getStrValue(strTemp,"&nbsp;")%>
		</td>
	</tr>
	
	<%}%>
	
</table>


<%}//end vRetResult%>
	
	
	
  
  
  

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>

<input type="hidden" name="reloadPage">
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