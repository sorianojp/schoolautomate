<%@ page language="java" import="utility.*,health.SchoolSpecific,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other(Leave Absence)","leave_absence.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
SchoolSpecific SS = new SchoolSpecific();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(SS.operateOnStudLeaveApplication(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = SS.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = SS.operateOnStudLeaveApplication(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = SS.getErrMsg();
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg(strInfoIndex) {
	var pgLoc = "./print_leave_absence.jsp?info_index="+strInfoIndex+"&sy_from="+
		document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AjaxMapName() {
	var strCompleteName = document.form_.stud_id.value;

	if(strCompleteName.length < 2)
		return;
		
	var objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = strName;
}
</script>

<body>
<form action="./leave_absence.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          Application for Leave of Absence Page ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">SY-Term</td>
      <td width="80%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null) 
	strTemp = "";
%>	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' maxlength=4>
to
<%
if(strTemp.length() > 0)
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1);
%>
  <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
&nbsp;&nbsp;
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null) 
	strTemp = "";
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="3"<%=strErrMsg%>>3rd Sem</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="0"<%=strErrMsg%>>Summer</option>
</select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student ID </td>
      <td><input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" onKeyUp="AjaxMapName();">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<br>
		<label id="coa_info" style="color:#0000FF"></label>		</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Days Absent </td>
      <td>
<%
strTemp = WI.fillTextValue("absent_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="absent_fr" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true">
        <a href="javascript:show_calendar('form_.absent_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  &nbsp; to &nbsp; 
	  <input name="absent_to" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("absent_to")%>" size="12" maxlength="12" readonly="true">
        <a href="javascript:show_calendar('form_.absent_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Time Absent </td>
      <td>
	  	<select name="hour_fr"><option value=""></option>
		<%
		strTemp = WI.fillTextValue("hour_fr");
		int iDefVal = Integer.parseInt(WI.getStrValue(strTemp, "0"));
		for(int i = 6; i < 22; ++i){
			if(i == iDefVal)
				strTemp = " selected";
			else	
				strTemp = "";
		%><option value="<%=i%>"<%=strTemp%>><%=i%></option>
		<%}%>
		</select> - 
	  	<select name="min_fr"><option value=""></option>
		<%
		strTemp = WI.fillTextValue("min_fr");
		iDefVal = Integer.parseInt(WI.getStrValue(strTemp, "-1"));
		for(int i = 0; i < 61; i += 15){
			if(i == iDefVal)
				strTemp = " selected";
			else	
				strTemp = "";
		%><option value="<%=i%>"<%=strTemp%>><%=i%></option>
		<%}%>
		</select> to  
	  	<select name="hour_to"><option value=""></option>
		<%
		strTemp = WI.fillTextValue("hour_to");
		iDefVal = Integer.parseInt(WI.getStrValue(strTemp, "0"));
		for(int i = 6; i < 22; ++i){
			if(i == iDefVal)
				strTemp = " selected";
			else	
				strTemp = "";
		%><option value="<%=i%>"<%=strTemp%>><%=i%></option>
		<%}%>
		</select> - 
	  	<select name="min_to"><option value=""></option>
		<%
		strTemp = WI.fillTextValue("min_fr");
		iDefVal = Integer.parseInt(WI.getStrValue(strTemp, "-1"));
		for(int i = 0; i < 61; i += 15){
			if(i == iDefVal)
				strTemp = " selected";
			else	
				strTemp = "";
		%><option value="<%=i%>"<%=strTemp%>><%=i%></option>
		<%}%>
		</select> - 
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date Filed </td>
      <td>
	  	  <input name="date_filed" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_filed")%>" size="12" maxlength="12" readonly="true">
        <a href="javascript:show_calendar('form_.date_filed');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Remark</td>
      <td><input type="text" name="remark" value="<%=WI.fillTextValue("remark")%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="60" maxlength="75"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("is_excused");
if(strTemp.equals("1")) {
	strTemp = " checked";
	strErrMsg = "";
}
else {
	strTemp = "";
	strErrMsg = " checked";
}%>
	  <input name="is_excused" type="radio" value="1"<%=strTemp%>> Excused &nbsp;&nbsp;
	  <input name="is_excused" type="radio" value="0"<%=strErrMsg%>> Un-Excused	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Approved By </td>
      <td><input type="text" name="approved_by" value="<%=WI.fillTextValue("approved_by")%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12"></td>
    </tr>
    <tr bgcolor="#999999">
      <td height="20" class="thinborderTOP">&nbsp;</td>
      <td style="font-size:9px; color:blue; font-weight:bold" class="thinborderTOP">Search Condition</td>
      <td style="font-size:9px;" class="thinborderTOP">Days Absent : 
	  <input name="search_absentfr" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("search_absentfr")%>" size="12" maxlength="12" readonly="true" style="font-size:9px">
        <a href="javascript:show_calendar('form_.search_absentfr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  &nbsp; to &nbsp; 
	  <input name="search_absentto" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("search_absentto")%>" size="12" maxlength="12" readonly="true" style="font-size:9px">
        <a href="javascript:show_calendar('form_.search_absentto');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
      &nbsp;&nbsp;&nbsp;&nbsp;
	  <input type="submit" name="1" value="&nbsp;&nbsp;Search&nbsp;&nbsp;" style="font-size:11px; height:20px;border: 1px solid #FF0000;" onClick="document.form_.print_pg.value=''; document.form_.page_action.value='';">
	  </td>
    </tr>
    <tr bgcolor="#999999">
      <td height="20" class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td style="font-size:9px;" class="thinborderBOTTOM">Date Filed :
	  <input name="search_datefiled" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("search_datefiled")%>" size="12" maxlength="12" readonly="true" style="font-size:9px">
        <a href="javascript:show_calendar('form_.search_datefiled');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  Show 
      <input type="checkbox" name="search_excused" value="checkbox"> Excused
      <input type="checkbox" name="search_unexcused" value="checkbox"> Un-Excused
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="35%" height="25">&nbsp;</td>
      <td width="65%"><input type="submit" name="12" value="&nbsp;&nbsp;Save Information&nbsp;&nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.print_pg.value='';document.form_.page_action.value='1'"></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#dddddd"><div align="center"><strong>::: List of Application for Leave of Absence ::: </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student ID</td>
      <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student Name</td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Days Absent </td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Time Absent </td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Is Excused </td>
      <td width="20%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Remark</td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Approved By </td>
      <td width="7%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Print</td>
      <td width="8%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Delete</td>
    </tr>
    
    <%
for(int i=0; i<vRetResult.size(); i+=17){%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 13)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 14)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 2), " to ","","")%></td>
      <td class="thinborder">
	  	<%strTemp = "";
		if(vRetResult.elementAt(i + 3) != null)
			strTemp = (String)vRetResult.elementAt(i + 3) + ":"+WI.getStrValue(vRetResult.elementAt(i + 4),"00");
		if(vRetResult.elementAt(i + 5) != null)
			strTemp += " to "+(String)vRetResult.elementAt(i + 5) + ":"+WI.getStrValue(vRetResult.elementAt(i + 6),"00");
		%>
	  	<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder" align="center">&nbsp;
	  <%if(vRetResult.elementAt(i + 11).equals("1")){%><img src="../../../../images/tick.gif"><%}%>
	  </td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 10),"&nbsp;")%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder">
	  <a href="javascript:PrintPg('<%=vRetResult.elementAt(i)%>')"><img src="../../../../images/print.gif" border="0"></a></td>
      <td class="thinborder" align="center">
		<input type="submit" name="12" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.print_pg.value='';document.form_.page_action.value='0';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'">	  </td>
    </tr>
    <%}%>
  </table>
<%}//end of display. %>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
<input type="hidden" name="report_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>