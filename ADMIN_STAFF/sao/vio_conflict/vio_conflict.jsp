<%
String strPrintID = request.getParameter("print_id");
if(strPrintID == null)
	strPrintID = "";
if(strPrintID.equals("2")){%>
	<jsp:forward page="./print_violation_SACI.jsp"/>
<%return;}
boolean bolPrintPg = strPrintID.equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateViolation() {
	location = "./vio_conflict_update.jsp?parent_url=./vio_conflict.jsp&allowEdit=1";
}
function ViewDetail(strInfoIndex) {
	location =
		"./vio_conflict_update.jsp?parent_url=./vio_conflict.jsp&info_index="+strInfoIndex+
		"&allowEdit=1&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_from.value+
		"&semester="+document.form_.semester.value;
}
function SendEmail(strInfoIndex) {
	var pgLoc = "../../../commfile/send_mail_violation.jsp?info_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=650,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
//if printID = 1, print the same page, else forward the page to print_vio_SACI.jsp.
function PrintPg(strPrintID) {
	document.form_.print_id.value = strPrintID;
	document.form_.submit();
}
function PrintCalled() {
	document.bgColor = "#FFFFFF";
	
	var obj   = document.getElementById('myADTable1')
	var oRows = obj.getElementsByTagName('tr').length;
	for(i = 0; i < oRows; ++i)
		obj.deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();
}
</script>
<body bgcolor="#D2AE72" <%if(bolPrintPg){%> onLoad="PrintCalled();"<%}%>>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ViolationConflict"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-VIOLATIONS & CONFLICTS","vio_conflict.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
boolean bolIsStudent = WI.fillTextValue("is_student").equals("1");
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthTypeIndex != null && strAuthTypeIndex.equals("4")) {
	bolIsStudent = true;
	request.setAttribute("is_student", "1");
}

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 0;
if(bolIsStudent)
	iAccessLevel = 2;
else	
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","VIOLATIONS & CONFLICTS",request.getRemoteAddr(),
														"vio_conflict.jsp");
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
Vector vRetResult = new Vector();//It has all information.
boolean bolNoRecord = false;
String strInfoIndex = WI.fillTextValue("info_index");
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};
ViolationConflict VC = new ViolationConflict();
if(WI.fillTextValue("show_all_sem").equals("1"))
	request.setAttribute("show_all_sem","1");
	
if(WI.fillTextValue("sy_from").length() > 0  || WI.fillTextValue("show_all_sem").equals("1") ) {
	vRetResult = VC.operateOnViolation(dbOP, request,4);
	if(vRetResult == null)
		strErrMsg = VC.getErrMsg();
}
String strTRCol = "";
boolean bChk = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsSPC = false;
if(strSchCode.startsWith("SPC"))
	bolIsSPC = true;
	
%>
<form action="./vio_conflict.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>::::
          VIOLATIONS &amp; CONFLICTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="6%" height="25">&nbsp;</td>
      <td colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>SY/Term</td>
     <td> 
<%if(bolIsStudent) {%> Show for All Sem<%}else{%>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly>
        -
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>        <input type="image" src="../../../images/refresh.gif" onClick="document.form_.print_id.value=''">
<%}//end of show for all sem %></td>
    </tr>
    <tr >
      <td height="25" width="6%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="82%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="3"><strong>Other Search Conditions :</strong>
	  <input type="checkbox" name="include_cleared" value="checked" <%=WI.fillTextValue("include_cleared")%>> 
	  Include Cleared Cases.
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <a href="javascript:document.form_.print_id.value='';document.form_.submit();">Refresh page</a>	  </td>
    </tr>
    <tr>
      <td height="25" colspan="2" style="font-size:9px;" align="right">Charged Party(id/name) &nbsp;&nbsp;</td>
      <td>
<%
if(bolIsStudent)
	strTemp = "'"+(String)request.getSession(false).getAttribute("userId")+"' class='textbox_noborder' readonly ";
else	
	strTemp = "'"+WI.fillTextValue("stud_id")+"' class='textbox' ";
%>
	  <input name="stud_id" type="text" size="20" maxlength="32" value=<%=strTemp%> 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25" colspan="2" style="font-size:9px;" align="right">Incident Type &nbsp;&nbsp;</td>
      <td><select name="violation_type" style="font-size:9px; font-family:Verdana, Arial, Helvetica, sans-serif; width:760">
        <option value="">Show All Incident</option>
        <%if(!bolIsStudent){%><%=dbOP.loadCombo("VIOLATION_TYPE_INDEX","VIOLATION_NAME"," FROM OSA_PRELOAD_VIOL_TYPE ",WI.fillTextValue("violation_type"),false)%><%}%>
      </select></td>
    </tr>
    
    <tr >
      <td height="25">&nbsp;</td>
      <td style="font-size:9px;" align="right">Incident&nbsp;&nbsp;</td>
      <td><select name="incident_type" style="font-size:9px; font-family:Verdana, Arial, Helvetica, sans-serif">
        <option value="">Show All Incident</option>
        <%if(!bolIsStudent){%><%=dbOP.loadCombo("INCIDENT_INDEX","INCIDENT"," FROM OSA_PRELOAD_VIOL_INCIDENT",WI.fillTextValue("incident_type"),false)%><%}%>
      </select></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td style="font-size:9px;">Show Per SY </td>
      <td style="font-size:9px;">
<input name="sy_range_fr" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_range_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> - 
<%if(bolIsSPC){
	strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
%>
			<select name="offering_sem">
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
			</select>
<%}else{%>
<input name="sy_range_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_range_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
	  Note : Enter From value only to show voilation for whole SY. Enter both values to show for the range of SY
<%}%>	  </td>
    </tr>
 <%if(!bolIsStudent){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td style="font-size:9px;"># of Violations </td>
      <td style="font-size:9px;">
	  <select name="violation_count">
	  	<option value=""></option>
<%
strTemp = WI.fillTextValue("violation_count");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
	  	<option value="1" <%=strErrMsg%>>Only 1</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
	  	<option value="2" <%=strErrMsg%>>2 and more</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
	  	<option value="3" <%=strErrMsg%>>3 and more</option>
<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
	  	<option value="4" <%=strErrMsg%>>4 and more</option>
<%
if(strTemp.equals("5"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
	  	<option value="5" <%=strErrMsg%>>5 and more</option>
	  </select>
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td style="font-size:9px;">Date of Violation </td>
      <td style="font-size:9px;">
	  <input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("date_fr")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				
		-
		
		<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
	  
	  
	  </td>
    </tr>
<%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
String strReportName = null;
  if(WI.fillTextValue("sy_range_fr").length() > 0) {
	if(WI.fillTextValue("sy_range_to").length() > 0) {
		strReportName = WI.fillTextValue("sy_range_fr")+" to "+Integer.toString(Integer.parseInt(WI.fillTextValue("sy_range_to")) + 1);
	}
	else 
		strReportName = WI.fillTextValue("sy_range_fr")+" to "+Integer.toString(Integer.parseInt(WI.fillTextValue("sy_range_fr")) + 1);
	if(WI.fillTextValue("offering_sem").length() > 0) 
		strReportName += " - "+astrConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))];
  }
  else if(WI.fillTextValue("sy_from").length() > 0 || WI.fillTextValue("semester").length() > 0) {
	strReportName = WI.fillTextValue("sy_from");
	if(WI.fillTextValue("semester").length() > 0) 
		strReportName += " - "+astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))];
  }
  else
  	strReportName = "ALL";

//if(strSchCode.startsWith("UDMC")){%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td height="25" width="50%"><a href="javascript:PrintPg('1')"><img src="../../../images/print.gif" border="0"></a> Print this report show below as it is </td>
      <td><a href="javascript:PrintPg('2')"><img src="../../../images/print.gif" border="0"></a> Print report (show each Charge Party ID and Name) </td>
    </tr>
   </table>
<%//}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center">
          <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <!-- Pangasinan 2420 Philippines -->
          <br><br>
	  <strong>VIOLATIONS & CONFLICTS <%if(!bolIsStudent){%>FOR SCHOOL YEAR <%=strReportName%><%}%></strong></td>
    </tr>
 </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="5%" height="26" class="thinborder"><font size="1">DATE REPORTED</font></td>
      <td width="5%" class="thinborder"><font size="1">VIOLATION DATE</font></td>
      <td width="10%" class="thinborder"><font size="1">CASE #</font></td>
      <td width="10%" class="thinborder"><font size="1">INCIDENT TYPE </font></td>
      <td width="15%" class="thinborder"><font size="1">INCIDENT</font></td>
      <td width="20%" class="thinborder"><font size="1">OFFENSE DESCRIPTION</font></td>
      <td width="15%" class="thinborder"><font size="1">COMPLAINANT</font></td>
      <td width="15%" class="thinborder"><font size="1">CHARGED PARTY</font></td>
<%if(!bolIsStudent && !bolPrintPg){
		if(!bolIsSPC){%>
	      <td width="5%" class="thinborder"><font size="1"><strong>EMAIL SENT</strong></font></td>
    	  <td width="5%" class="thinborder"><font size="1"><strong>SEND EMAIL</strong></font></td>
		<%}%>
      <td width="5%" class="thinborder">&nbsp;</td>
<%}%>
    </tr>
    <%for(int i = 0 ; i< vRetResult.size(); i += 20){
	
    if (bChk){if (((String)vRetResult.elementAt(i+18)).equals("1")){
	    strTRCol = "bgcolor = '#DDDDDD'";
	    bChk = false;}}%>
    <tr <%=strTRCol%>>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 5)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 8)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 15)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 9)%></font></td>
   	  <%
		strTemp = (String)vRetResult.elementAt(i + 16);
	  	if(strTemp != null && strTemp.indexOf(",") > -1) 
		strTemp = ConversionTable.replaceString(strTemp, ",",", ");
	  %>

	  <td class="thinborder"><font size="1"><%=WI.getStrValue(strTemp, "&nbsp;")%></font></td>
	  <%
		strTemp = (String)vRetResult.elementAt(i + 13);
	  	if(strTemp != null && strTemp.indexOf(",") > -1) 
			strTemp = ConversionTable.replaceString(strTemp, ",",", ");
	  %>
	  
      <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
<%if(!bolIsStudent && !bolPrintPg){
		if(!bolIsSPC){%>
	      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 12)%></font></td>
    	  <td class="thinborder"><a href='javascript:SendEmail("<%=(String)vRetResult.elementAt(i)%>");'>
	  							<img src="../../../images/send_email.gif" border="0"></a></td>
		<%}%>
      <td class="thinborder"><a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i)%>");'>
	  						<img src="../../../images/view.gif" border="0"></a></td>
<%}%>
    </tr>
    <%}%>
  </table>
<%}//only if vRetResult is not null
if(!bolIsStudent){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td width="10%" height="25">&nbsp;</td>
      <td width="39%" height="25">&nbsp;</td>
      <td width="51%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
	  <a href="javascript:UpdateViolation();"><img src="../../../images/update.gif" border="0" ></a><font size="1">click to update/create entries</font>
	  </td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable4">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="is_student" value="<%=WI.fillTextValue("is_student")%>">
<input type="hidden" name="show_all_sem" value="<%=WI.fillTextValue("show_all_sem")%>">
<input type="hidden" name="print_id">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
