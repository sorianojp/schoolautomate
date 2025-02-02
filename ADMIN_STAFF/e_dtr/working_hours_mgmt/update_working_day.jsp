<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function showLunchBreak(){
	if (document.dtr_op.one_tin_tout.checked){
		document.getElementById("lunch_br").innerHTML = 
		"<input name=\"lunch_break\" type=\"text\" size=\"3\" maxlength=\"3\"  "+ 
		"value=\"<%=WI.fillTextValue("lunch_break")%>\" class=\"textbox\" " +
		"onFocus=\"style.backgroundColor=\'#D3EBFF\'\" onBlur=\"style.backgroundColor=\'#FFFFFF\'\" " +
		" onKeypress=\" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;\"> Break (in Minutes)";

		document.getElementById("lbl_second_set").innerHTML = "Break Time <a href='javascript:showNote(1);'>NOTE</a>";
		
		document.dtr_op.logout_nextday.disabled = false;
//		document.dtr_op.pm_hr_fr.disabled = true;
//		document.dtr_op.pm_min_fr.disabled = true;
//		document.dtr_op.ampm_from1.disabled = true;
//		document.dtr_op.pm_hr_to.disabled = true;
//		document.dtr_op.pm_min_to.disabled = true;
//		document.dtr_op.ampm_to1.disabled = true;
	}else{
		document.getElementById("lunch_br").innerHTML = "";
		document.dtr_op.logout_nextday.disabled = true;
		document.getElementById("lbl_second_set").innerHTML = "Second Time In";
//		document.dtr_op.pm_hr_fr.disabled = false;
//		document.dtr_op.pm_min_fr.disabled = false;
//		document.dtr_op.ampm_from1.disabled = false;
//		document.dtr_op.pm_hr_to.disabled = false;
//		document.dtr_op.pm_min_to.disabled = false;
//		document.dtr_op.ampm_to1.disabled = false;
	}
}

function showNote(strShow){
	var iframe = document.getElementById('iframetop');
	var layer = document.getElementById("note_");
	
	if(strShow == '0'){		
		layer.style.visibility = "hidden";
		iframe.style.display = 'none';
		layer.style.display = 'none';	
	}else{
		layer.style.visibility = "visible";
		iframe.style.display = 'block';
		layer.style.display = 'block';	
		iframe.style.width = layer.offsetWidth-5;	
		iframe.style.left = layer.offsetLeft;
		iframe.style.top = layer.offsetTop;
		iframe.style.height = (layer.offsetHeight-5);
	}
}

function ViewRecord(){	
	document.dtr_op.page_action.value="1";
 	this.SubmitOnce("dtr_op");
}

function AddRecord(){
	document.dtr_op.page_action.value=2;
}

function DeleteRecord(index){
	document.dtr_op.page_action.value =3;
	document.dtr_op.info_index.value = index;
}

function PrepareToEdit(index){
	document.dtr_op.page_action.value = 4;
	document.dtr_op.prepareToEdit.value = 1;
}
function EditRecord(index){
	document.dtr_op.page_action.value = 5;
}
function CancelEdit()
{
	location = "./set_dtr_regular_wh.jsp";
}
function DeleteNonEDTR(strEmpIndex) {
	document.dtr_op.non_EDTR.value = strEmpIndex;
	document.dtr_op.info_index.value = "";
	document.dtr_op.page_action.value = "";
	document.dtr_op.prepareToEdit.value = "";
	
	this.SubmitOnce('dtr_op');
}

function viewHistory() {
	var pgLoc = "./set_working_history.jsp?emp_id=";
	
	if (document.dtr_op.emp_id) 
		pgLoc +=  escape(document.dtr_op.emp_id.value);
	
	pgLoc+="&my_home="+document.dtr_op.my_home.value+"&adhoc_only=1";

	var win=window.open(pgLoc,"view_history",'dependent=yes,width=600,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.dtr_op.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function ShowUpdate(strWHIndex, strEmpID) {
	var pgLoc = "./update_working_day.jsp?wh_index="+strWHIndex+"&emp_id="+strEmpID;
	var win=window.open(pgLoc,"UpdateWhour",'width=650,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateRecord(){
	document.dtr_op.update_record.value = "1";
	document.dtr_op.processsing.value = "1";	
}
-->
</script>
<body bgcolor="#D2AE72" 
<% if (!WI.fillTextValue("my_home").equals("1")){%>
	onLoad="document.dtr_op.emp_id.focus();"
<%}%> class="bgDynamic">
<%
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	
	boolean bolProceed = true;
	String strPrepareToEdit = null;
	boolean bolAllowEdit = false;
	String strUserID = (String)request.getSession(false).getAttribute("userId");
//add security here.
	try
	{
		dbOP = new DBOperation(strUserID,
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","update_working_day.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();								
		bolAllowEdit = readPropFile.getImageFileExtn("ALLOW_EDIT_DTR","0").equals("1");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"update_working_day.jsp");	
														
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");

if (strTemp == null) 
	strTemp = "";
//																					
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
	WorkingHour wHour = new WorkingHour(); 
	Vector vRetResult = null;
 	Vector vEditInfo  = null;
	boolean bolProcesssing = WI.fillTextValue("processsing").equals("1");
	String[] astrConverAMPM = {"AM","PM"};
	double dTime = 0d;
	int iHour = 0;
	int iMinute = 0;	
	String strAMPM = " AM";
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode.startsWith("CIT") || (strUserID != null && strUserID.equals("bricks")))
		bolAllowEdit = true;		
	int iSearchResult = 0;
	int i = 0;

strTemp = WI.fillTextValue("emp_id"); 
	if(WI.fillTextValue("update_record").equals("1")){
		if(!wHour.updateWHSchedule(dbOP, request, WI.fillTextValue("wh_index")))
			strErrMsg = wHour.getErrMsg();
		else
			strErrMsg = "Operation Successful";
	}
	vEditInfo = wHour.getDailyWorkingHours(dbOP, request, false, "3");
 %>	
<form action="./update_working_day.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      WORKING HOURS MGMT - SET WORKING HOURS PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25"><strong><font size=2>&nbsp;<%=WI.getStrValue(strErrMsg)%>&nbsp;</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top"> 
      <td width="2%" height="20" valign="top">&nbsp;</td>
      <td width="16%" height="20">Employee ID : </td>
      <td width="82%" height="20" valign="top"><strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr> 
  </table>
<% 

if (strTemp.length()  > 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
  vRetResult = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vRetResult !=null){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Employee Name</font></td>
      <td height="15"><font size="1">Employee Status</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = WI.formatName((String)vRetResult.elementAt(1), (String)vRetResult.elementAt(2),
									(String)vRetResult.elementAt(3),1); %>
      <td colspan="2" valign="top"><strong><%=strTemp%></strong></td>
      <td valign="top"><strong><%=WI.getStrValue((String)vRetResult.elementAt(16))%></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Position</font></td>
      <td height="15"><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = (String)vRetResult.elementAt(15);%>
      <td colspan="2" valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
      <%
				if((String)vRetResult.elementAt(13) == null)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(14));
			else
			{	
				strTemp =WI.getStrValue((String)vRetResult.elementAt(13));
				if((String)vRetResult.elementAt(14) != null)
					strTemp += "/" + WI.getStrValue((String)vRetResult.elementAt(14));
			}
%>
      <td valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><u>Working Hours</u></td>
      <td width="23%"><strong><%=(String)vEditInfo.elementAt(16)%></strong></td>
      <td width="56%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td width="19%">&nbsp; </td>
      <td colspan="2"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>First Time In</td>
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(1);
			else	
				strTemp = WI.fillTextValue("am_hr_fr");
			strTemp = WI.getStrValue(strTemp);
			%>				
      <td colspan="2"><input name="am_hr_fr" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
:
  <%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(2);
			else	
				strTemp = WI.fillTextValue("am_min_fr");
			%>
  <input name="am_min_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
  <%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(3);
			else	
				strTemp = WI.fillTextValue("ampm_from0");
			strTemp = WI.getStrValue(strTemp);
			%>
  <select name="ampm_from0">
    <option value="0" >AM</option>
    <% if (strTemp.equals("1") || strTemp.equals("PM")){ %>
    <option value="1" selected>PM</option>
    <% }else {%>
    <option value="1">PM</option>
    <%}%>
  </select>
to
<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(4);
			else	
				strTemp = WI.fillTextValue("am_hr_to");
			strTemp = WI.getStrValue(strTemp);
			%>
<input name="am_hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(5);
			else	
				strTemp = WI.fillTextValue("am_min_to");
			strTemp = WI.getStrValue(strTemp);
			%>
<input name="am_min_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(6);
			else	
				strTemp = WI.fillTextValue("ampm_to0");
			strTemp = WI.getStrValue(strTemp);			
			%>
<select name="ampm_to0" >
  <option value="0" >AM</option>
  <% if (strTemp.equals("1") || strTemp.equals("PM")){ %>
  <option value="1" selected>PM</option>
  <% }else{ %>
  <option value="1">PM</option>
  <%}%>
</select>
<br>
<%
				if(!bolProcesssing)
					strTemp = (String)vEditInfo.elementAt(7);
				else	
					strTemp = WI.fillTextValue("one_tin_tout");
				
				if(strTemp == null)
					strTemp = "checked";
				else
					strTemp = "";
				%>
<label for="one_chk_opt_">
<input name="one_tin_tout" type="checkbox"  value="1"  id="one_chk_opt_"
				onClick="showLunchBreak()" tabindex="-1" <%=strTemp%>>
<font size="1">employee has only one time in/time out </font> </label><br>
			<%
						strTemp = (String)vEditInfo.elementAt(i+18);
						strTemp2 = (String)vEditInfo.elementAt(i+19);
						if(strTemp != null && strTemp2 != null){
							dTime = Double.parseDouble(strTemp);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							}else{
								strAMPM = " AM";
							}
							
							iHour = (int)dTime;
							dTime = (dTime - iHour) * 60 + .02;
							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;
							
							strTemp = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
							
							dTime = Double.parseDouble(strTemp2);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							} else {
								strAMPM = " AM";
							}
							
							iHour = (int)dTime;
							dTime = ((dTime - iHour) * 60) + .02;
 							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;
							
							strTemp2 = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
							
							strTemp += " - " + strTemp2;
						}else {
							strTemp = WI.getStrValue((String)vEditInfo.elementAt(i+17), "0");
							if(Double.parseDouble(strTemp) == 0)	
								strTemp = "";
						}
					%>
					<%=WI.getStrValue(strTemp, "<font color='#FF0000'>Current Break Set : ","</font>","No Set Break time")%>
			</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><label id="lbl_second_set">Second Time In</label>
			<iframe width="0" scrolling="no" height="0" frameborder="0" id="iframetop" style="position:absolute;"> </iframe>
			<div id="note_" style="position:absolute;visibility:hidden; width:500px;">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFCC">
				<tr>
					<td width="90%">If you enter valid break time range, then the Break (in Minutes) will be disregarded</td>
					<td width="10%" align="center"><a href="javascript:showNote('0');">HIDE</a></td>
				</tr>
			</table>
			</div>			</td>
			<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(7);
			else	
				strTemp = WI.fillTextValue("pm_hr_fr");
			strTemp = WI.getStrValue(strTemp);
			%>				
      <td colspan="2"><input name="pm_hr_fr" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
  <%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(8);
			else	
				strTemp = WI.fillTextValue("pm_min_fr");
			strTemp = WI.getStrValue(strTemp);
			%>
  <input name="pm_min_fr" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
  <%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(9);
			else	
				strTemp = WI.fillTextValue("ampm_from1");
			strTemp = WI.getStrValue(strTemp);
			%>
  <select name="ampm_from1" >
    <option value="0">AM</option>
    <% if (strTemp.equals("1") || strTemp.equals("PM")){ %>
    <option value="1" selected>PM</option>
    <%}else{%>
    <option value="1">PM</option>
    <%}%>
  </select>
to
<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(10);
			else	
				strTemp = WI.fillTextValue("pm_hr_to");
			strTemp = WI.getStrValue(strTemp);
			%>
<input name="pm_hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(11);
			else	
				strTemp = WI.fillTextValue("pm_min_to");
			strTemp = WI.getStrValue(strTemp);
			%>
<input name="pm_min_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
<%
			if(!bolProcesssing)
				strTemp = (String)vEditInfo.elementAt(12);
			else	
				strTemp = WI.fillTextValue("ampm_to1");
			strTemp = WI.getStrValue(strTemp);
			%>
<select name="ampm_to1">
  <option value="0" >AM</option>
  <% if (strTemp.equals("1") || strTemp.equals("PM")){ %>
  <option value="1" selected>PM</option>
  <% }else{ %>
  <option value="1">PM</option>
  <%}%>
</select>
&nbsp;&nbsp;&nbsp;
 <label id="lunch_br"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input name="logout_nextday" type="checkbox" id="logout_nextday" value="1" disabled>
        <font size="1">employee logout is on the next day</font></td>
    </tr>
		<% if ((iAccessLevel > 1)){%>	
    <tr>
      <td>&nbsp;</td>
      <td height=20>&nbsp;</td>
      <td height=20>&nbsp;</td>
      <td height=20>&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="10" colspan="4"><div align="center">
        <input name="image" type="image" onClick="UpdateRecord();" src="../../../images/edit.gif" width="48" height="28">
        <font size="1">click to save changes</font></div></td>
    </tr>
<%} %>
  </table>
  <%} %>
<%}%>
<!-- here lies the great mysteries of and future-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25"s>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
	<input type="hidden" name="wh_index" value="<%=WI.fillTextValue("wh_index")%>">
 	<input type="hidden" name="processsing">
	<input type="hidden" name="update_record" value="">
	<input type="hidden" name="is_for_daily" value="1">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
