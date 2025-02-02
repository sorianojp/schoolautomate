<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:11px;
}	
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
	function ReloadPage() {
		document.form_.show_result.value='';
		document.form_.submit();
	}
	function ShowResult(){
		document.form_.payment_sched_name.value = document.form_.payment_sched[document.form_.payment_sched.selectedIndex].text;
		document.form_.show_result.value='1'; 
		document.form_.submit();
	}
	
	function PrintPage(){
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myADTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
			
	var obj1 = document.getElementById('myADTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
	obj1.deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);	
	document.getElementById('myADTable4').deleteRow(0);
	
	window.print();

}


</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}




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

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	 bolIsBasic = true;	

String strExamName = null;
String strExamPeriod = null;
String[] astrConvertSem = {"SUMMER","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER"};

Vector vRetResult  = null;
if(WI.fillTextValue("show_result").length() > 0) {
	enrollment.ReportFeeAssessment RFA = new enrollment.ReportFeeAssessment();
	vRetResult = RFA.admSlipPrintStatUB(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();
}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./exam_permit_statistics_UB.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ADMISSION SLIP STATUS ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:16px; font-weight:bold; color:#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="13%" height="25">SY/TERM</td>
      <td height="25"> 
<%
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
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
		  if(strTemp.equals("1")){
		  %>
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
		  <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="25">Exam Period</td>
      <td height="25">
	  <select name="payment_sched">
        <%if(bolIsBasic){%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 and bsc_grading_name is not null order by EXAM_PERIOD_ORDER asc", request.getParameter("payment_sched"), false)%>
        <%}else{%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("payment_sched"), false)%>
        <%}%>        
      </select>
	  
	  	<input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="ReloadPage();">
        <font color="#0000FF" size="1"><strong>Show For Grade School</strong></font>

	  </td>
    </tr>
	
	
	<tr> 
      <td width="2%">&nbsp;</td>
      <td height="25">Academic level</td>
      <td height="25">
	  <select name="year_level">
          <option value="">ALL</option>
<%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>1st</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
<%}else{%>
          <option value="4">4th</option>
<%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
<%}else{%>
          <option value="5">5th</option>
<%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
<%}else{%>
          <option value="6">6th</option>
<%}%>
        </select></td>
    </tr>
	
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"> 
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ShowResult();"></td>
    </tr>
  </table>
<%

if(vRetResult != null && vRetResult.size() > 0) {
System.out.println(vRetResult);
String dNoAdm = (String)vRetResult.remove(0);
String dPercent = (String)vRetResult.remove(0);
String dAdmIssued = (String)vRetResult.remove(0);
String dEnrlTot = (String)vRetResult.remove(0);

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
	<tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td><div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div><br><br></td></tr>
	<tr><td height="25" align="center"><strong><%=WI.fillTextValue("payment_sched_name").toUpperCase()%> EXAMINATION</strong></td></tr>
	<tr><td align="center" height="25"><strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%> 
		</strong><br><br></td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="22" width="30%"><strong>TOTAL ENROLLMENT</strong></td><td align="right" width="15%"><strong><%=dEnrlTot%></strong></td><td></td></tr>
	<tr><td height="22"><strong>ADMISSION NUMBER ISSUED</strong></td><td align="right"><strong><%=dAdmIssued%></strong></td><td></td></tr>
	<tr><td height="22"><strong>TOTAL ISSUED PERCENTAGE</strong></td><td align="right"><strong><%=dPercent%>%</strong></td><td></td></tr>
	<tr><td height="22"><strong>WITH NO ADMISSION NUMBER</strong></td><td align="right"><strong><%=dNoAdm%></strong></td><td></td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="2" valign="top" height="700px">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr><td colspan="10" height="25">&nbsp;</td></tr>
				<tr>
					<td class="thinborderTOPBOTTOM" width="" height="25"><strong>DEPARTMENT</strong></td>
					<td class="thinborderTOPBOTTOM" width="15%" align="center"><strong>ENROLLMENT</strong></td>
					<td class="thinborderTOPBOTTOM" width="15%" align="center"><strong>Admission Nbr Issued</strong></td>
					<td class="thinborderTOPBOTTOM" width="15%" align="center"><strong>Issued Percentage</strong></td>
					<td class="thinborderTOPBOTTOM" width="10%" align="center"><strong>RANK</strong></td>
					<td class="thinborderTOPBOTTOM" width="15%" align="center"><strong>With No Admission Nbr</strong></td>
				</tr>
				
				<%
				int iNoAdmission = 0;
				int iCount = 1;
				for(int i = 0; i < vRetResult.size(); i += 4){
				
					iNoAdmission = Integer.parseInt((String)vRetResult.elementAt(i + 1)) - Integer.parseInt((String)vRetResult.elementAt(i + 2));
					
				%>
				
				<tr>
					<td class="" height="20"><strong><%=(String)vRetResult.elementAt(i)%></strong></td>
					<td class="" align="right" style="padding-right:30px;"><strong><%=(String)vRetResult.elementAt(i + 1)%></strong></td>
					<td class="" width="15%" style="padding-right:30px;" align="right"><strong><%=(String)vRetResult.elementAt(i+2)%></strong></td>
					<td class="" width="15%" style="padding-right:30px;" align="right"><strong><%=(String)vRetResult.elementAt(i+3)%>%</strong></td>
					<td class="" width="10%" style="padding-right:30px;" align="right"><strong><%=iCount++%></strong></td>
					<td class="" width="15%" style="padding-right:30px;" align="right"><strong><%=iNoAdmission%></strong></td>
				</tr>
				
				<%}%>
				<tr>
					<td class="thinborderTOPBOTTOM" width="" height="25"><strong>TOTAL</strong></td>
					<td class="thinborderTOPBOTTOM" style="padding-right:30px;" width="15%" align="right"><strong><%=dEnrlTot%></strong></td>
					<td class="thinborderTOPBOTTOM" style="padding-right:30px;" width="15%" align="right"><strong><%=dAdmIssued%></strong></td>
					<td class="thinborderTOPBOTTOM" style="padding-right:30px;" width="15%" align="right"><strong><%=dPercent%>%</strong></td>
					<td class="thinborderTOPBOTTOM" style="padding-right:30px;" width="10%" align="right"><strong>&nbsp;</strong></td>
					<td class="thinborderTOPBOTTOM" style="padding-right:30px;" width="15%" align="right"><strong><%=dNoAdm%></strong></td>
				</tr>
				<tr><td colspan="6" height="3" valign="top" style="border-top:solid 1px #000000;"></td></tr>
			</table>
		</td>
	</tr>
	
	
	<tr>
		<td width="50%" class="thinborderTOP">Printed by : <%=request.getSession(false).getAttribute("first_name")%></td>
		<td width="50%" align="right" class="thinborderTOP">Date and Time Printed: <%=WI.getTodaysDateTime()%></td>
	</tr>
</table>



  
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
  <input type="hidden" name="show_result">
  <input type="hidden" name="payment_sched_name" value="<%=WI.fillTextValue("payment_sched_name")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>