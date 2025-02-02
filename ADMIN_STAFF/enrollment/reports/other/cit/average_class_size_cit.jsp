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
								"Admin/staff-Enrollment-REPORTS","average_class_size_cit.jsp");
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
														"average_class_size_cit.jsp");
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


Vector vCollege = null;
Vector vCountTotal = null;
Vector vCountSubject = null;
Vector vCountStud = null;
Vector vRetResult = null;

ReportEnrollment reportEnrl = new ReportEnrollment();
if(WI.fillTextValue("reloadPage").length()>0){
	vRetResult = reportEnrl.getAverageClassCIT(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();	
}	


String[] strConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
	
%>
<form action="./average_class_size_cit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          AVERAGE CLASS SIZE REPORT ::::</strong></font></div></td>
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
		 
	vCollege = (Vector)vRetResult.remove(0);
	vCountTotal = (Vector)vRetResult.remove(0);
	vCountSubject = (Vector)vRetResult.remove(0);
	vCountStud = (Vector)vRetResult.remove(0);

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID3">
	<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a> 
		<font size="1">Click to print summary</font>		
	</td></tr>
	<td height="15">&nbsp;</td>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
		CLASS SIZE PER SUBJECT SERVED BY COLLEGE
		<br> <strong><%=strConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></strong>	
	</td></tr>	
	<tr><td height="15">&nbsp;</td></tr>			
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" height="23" width="30%" align="center"><strong>COLLEGE/DEPARTMENT</strong></td>
		<td class="thinborder" width="30%" align="center"><strong>NO. OF SUBJECTS OFFERED</strong></td>
		<td class="thinborder" width="30%" align="center"><strong>TOTAL STUDENT ENROLLED</strong></td>
		<td class="thinborder" width="30%" align="center"><strong>AVERAGE CLASS SIZE</strong></td>
	</tr>
	
	<%
	String strDepartment = null;
	String strCollege = null;
	String strAdvCollege = "";
	String strPrevCollege = "";
	int iIndexOf = 0;
	
	int iGrandTotSub = 0;
	int iGrandTotStud = 0;
	double dAveClass = 0d;
	int iTotStudCollege = 0;
	int iTotSubCollege = 0;
	int iCountStud = 0;
	int iCountSub = 0;
	
	for(int i = 0; i < vCollege.size(); i+=3){
		strCollege = (String)vCollege.elementAt(i + 1);	
		strDepartment = (String)vCollege.elementAt(i + 2);	
		
		iIndexOf = i + 4;
		if(iIndexOf >= vCollege.size()){}
		else
			strAdvCollege = (String)vCollege.elementAt(iIndexOf);	
			
	if(!strPrevCollege.equals(strCollege)){
		strPrevCollege = strCollege;
	if(i != 0){
	%>		
	<tr>
		<td class="thinborder" height="18">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	</tr>
	<%}%>
	<tr>
		<td align="center" class="thinborder" height="18"><strong><%=WI.getStrValue(strCollege,"&nbsp;")%></strong></td>
		<%
		iTotSubCollege = 0;
		iIndexOf = vCountTotal.indexOf(strCollege);
		if(iIndexOf > -1)
			iTotSubCollege = Integer.parseInt(WI.getStrValue((String)vCountTotal.elementAt(iIndexOf + 1),"0"));		
			
		strTemp = Integer.toString(iTotSubCollege);
		if(iTotSubCollege == 0)
			strTemp = "&nbsp;";
		%>
		<td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
		<%
		iTotStudCollege = 0;
		iIndexOf = vCountTotal.indexOf(strCollege);
		if(iIndexOf > -1)
			iTotStudCollege = Integer.parseInt(WI.getStrValue((String)vCountTotal.elementAt(iIndexOf + 2),"0"));
			
		strTemp = Integer.toString(iTotStudCollege);
		if(iTotStudCollege == 0)
			strTemp = "&nbsp;";
		%>
		<td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
		<%
		dAveClass = 0d;
		if(iTotSubCollege != 0 && iTotStudCollege != 0)
			dAveClass = Double.parseDouble(Integer.toString(iTotStudCollege)) / Double.parseDouble(Integer.toString(iTotSubCollege));
		%>
		<td align="center" class="thinborder"><strong><%=CommonUtil.formatFloat(dAveClass, true)%></strong></td>
	</tr>
	<%
	iGrandTotSub += iTotSubCollege;
	iGrandTotStud += iTotStudCollege;
	
	iTotSubCollege = 0;
	iTotStudCollege = 0;
	}%>
	
	<%
	if(strDepartment == null)
			continue;
	%>
	
	<tr>
		<td class="thinborder" height="18"><%=WI.getStrValue(strDepartment,"&nbsp;")%></td>
		<%
		iCountSub = 0;
		iIndexOf = vCountSubject.indexOf((String)vCollege.elementAt(i));
		if(iIndexOf > -1)
			iCountSub = Integer.parseInt(WI.getStrValue((String)vCountSubject.elementAt(iIndexOf + 3),"0"));
			
		strTemp = Integer.toString(iCountSub);
		if(iCountSub == 0)
			strTemp = "&nbsp;";
		
		%>
		<td class="thinborder" align="center"><%=strTemp%></td>
		<%
		iCountStud = 0;
		iIndexOf = vCountStud.indexOf((String)vCollege.elementAt(i));
		if(iIndexOf > -1)
			iCountStud = Integer.parseInt(WI.getStrValue((String)vCountStud.elementAt(iIndexOf + 3),"0"));
			
		strTemp = Integer.toString(iCountStud);
		if(iCountStud == 0)
			strTemp = "&nbsp;";
		
		%>
		<td class="thinborder" align="center"><%=strTemp%></td>
		<%
		dAveClass = 0d;
		if(iCountStud != 0 && iCountSub != 0)
			dAveClass = Double.parseDouble(Integer.toString(iCountStud)) / Double.parseDouble(Integer.toString(iCountSub));
		%>
		
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dAveClass, true)%></td>
	</tr>
	<%}//end college loop%>
	
	<tr>
		<td class="thinborder" height="18">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	</tr>
	<tr>
		<td align="right" class="thinborder"><strong>OVERALL</strong></td>
		<%
		strTemp = Integer.toString(iGrandTotSub);
		if(iGrandTotSub == 0)
			strTemp = "&nbsp;";
		%>
		<td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
		<%
		strTemp = Integer.toString(iGrandTotStud);
		if(iGrandTotStud == 0)
			strTemp = "&nbsp;";
		%>
		<td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
		<%
		dAveClass = 0d;
		if(iGrandTotStud != 0 && iGrandTotSub != 0)
			dAveClass = Double.parseDouble(Integer.toString(iGrandTotStud)) / Double.parseDouble(Integer.toString(iGrandTotSub));
		%>
		<td align="center" class="thinborder"><strong><%=CommonUtil.formatFloat(dAveClass, true)%></strong></td>
	</tr>
	
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