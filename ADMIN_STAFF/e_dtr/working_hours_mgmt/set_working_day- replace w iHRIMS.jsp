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

function DeleteRecord(index, strDate){
  var vProceed = confirm('Remove working schedule for '+strDate+'?');
  if(vProceed){
		document.dtr_op.page_action.value =3;
		document.dtr_op.info_index.value = index;
		this.SubmitOnce('dtr_op');
	}
	
}

 
function CancelEdit()
{
	location = "./set_dtr_regular_wh.jsp";
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
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","set_working_day.jsp");
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
														"set_working_day.jsp");	
														
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
	Vector vEmployeeWH = null;
	String[] astrConverAMPM = {"AM","PM"};
	double dTime = 0d;
	int iHour = 0;
	int iMinute = 0;	
	String strAMPM = " AM";
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode.startsWith("CIT")  || strSchCode.startsWith("TAMIYA") || 
		strSchCode.startsWith("FOODA") || (strUserID != null && strUserID.equals("bricks"))){
		bolAllowEdit = true;		
	}
	
	int iSearchResult = 0;
	int i = 0;

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}
	
 	if(WI.fillTextValue("page_action").equals("1")){
		vRetResult = wHour.operateOnDailyWH(dbOP, request,1);
		strErrMsg = wHour.getErrMsg();
	}else if(WI.fillTextValue("page_action").equals("2")){
		vRetResult = wHour.operateOnDailyWH(dbOP, request,2);
		strErrMsg = wHour.getErrMsg();
		if (strErrMsg == null)
			strErrMsg = "Working Hour added successfully.1" ;
	}else if(WI.fillTextValue("page_action").equals("3")){
		vRetResult = wHour.operateOnDailyWH(dbOP,request,3);
		strErrMsg = wHour.getErrMsg();
		if (strErrMsg == null)  
			strErrMsg = "Working Hour deleted successfully ." ;
	} 

	vEmployeeWH = wHour.getDailyWorkingHours(dbOP, request,false);
	if(vEmployeeWH != null)
		iSearchResult = wHour.getSearchCount();
%>	
<form action="./set_working_day.jsp" method="post" name="dtr_op">
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
      <td width="2%" height="30" valign="top">&nbsp;</td>
      <td width="14%" height="30">Employee ID</td>
      <td width="19%" height="30" valign="top"><input name="emp_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=WI.fillTextValue("emp_id")%>" size="16">      </td>
      <td width="5%" valign="top"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="14%" valign="top"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewRecord();"></td>
      <td width="46%" valign="top"><label id="coa_info"></label></td>
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
      <td width="23%">&nbsp;</td>
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
      <td colspan="2"><input name="am_hr_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
        : 
        <input name="am_min_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_from0">
          <option value="0" >AM</option>
          <% if (WI.fillTextValue("ampm_from0").equals("1")) {%>
          <option value="1" selected>PM</option>
          <% }else {%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
        <input name="am_hr_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_hr_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input name="am_min_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("am_min_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_to0" >
          <option value="0" >AM</option>
          <% if (WI.fillTextValue("ampm_to0").equals("1")){ %>
          <option value="1" selected>PM</option>
          <% }else{ %>
          <option value="1">PM</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp; <%
			strTemp = WI.fillTextValue("one_tin_tout");
			if(strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
			%>	
				<label for="one_chk_opt_">
				<input name="one_tin_tout" type="checkbox"  value="1"  id="one_chk_opt_"
				onClick="showLunchBreak()" tabindex="-1" <%=strTemp%>> 
        <font size="1">employee has only one time in/time out </font> 
				</label> </td>
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
			</div>	
			</td>
      <td colspan="2"><input name="pm_hr_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("pm_hr_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input name="pm_min_fr" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("pm_min_fr")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_from1" >
          <option value="0">AM</option>
          <%if(WI.fillTextValue("ampm_from1").equals("1")) {%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
        <input name="pm_hr_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("pm_hr_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input name="pm_min_to" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("pm_min_to")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="ampm_to1" >
          <option value="0" >AM</option>
          <% if (WI.fillTextValue("ampm_to1").equals("1")) {%>
          <option value="1" selected>PM</option>
          <% }else{ %>
          <option value="1">PM</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp; 
		<label id="lunch_br"> </label></td>
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
      <td>&nbsp;</td>
      <td height=30> Working Date : </td>
      <td height=30><input name="work_date" type="text" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" 
	   onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('dtr_op','work_date','/');"
	   onKeyUp= "AllowOnlyIntegerExtn('dtr_op','work_date','/')"
	    value="<%=WI.fillTextValue("work_date")%>" size="10" maxlength="10">
      <a href="javascript:show_calendar('dtr_op.work_date');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td height=30>&nbsp;</td>
    </tr>
		
    <tr>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><div align="center">
          <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
          <font size="1">click to save changes </font> &nbsp; </div></td>
    </tr>
<%} %>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr bgcolor="#B9B292"> 
        <td height="25" colspan="9" align="center" bgcolor="#B9B292">LIST OF 
          CURRENT WORKING HOURS FOR ID : <%=WI.fillTextValue("emp_id")%> (
          <input name="show_history" type="checkbox" value="1" onClick="javascript:viewHistory()">
			click to see history)
			<%if(bolAllowEdit){
					strTemp = WI.fillTextValue("view_all_wh");
					if(strTemp.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<br>
					<div align="left">
					<input name="view_all_wh" type="checkbox" value="1" <%=strTemp%> onClick="ViewRecord();">
					View all working hours					</div>
				<%}%>			</td>
      </tr>
<%		
	int iPageCount = iSearchResult/wHour.defSearchSize;		
	if(iSearchResult % wHour.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>			
      <tr bgcolor="#B9B292">
        <td height="25" colspan="9" align="right" bgcolor="#B9B292">

			<font size="2">Jump To page:
          <select name="jumpto" onChange="ViewRecord();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i ){
			if(i == Integer.parseInt(strTemp) ){%>
					<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%}else{%>
					<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
					<%
				}
			}
			%>
          </select>
		  </font>
						</td>
      </tr>
			<%}%>	
    <tr> 		
      <td height="25" colspan="9">
	  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
<% if (vEmployeeWH == null) {  %>
          <tr> 
            <td height="25" colspan=4 align="center" class="thinborder"><font size=2><strong> 
              No Record of Employee Working Hours</strong></font></td>
          </tr>
<% } // end if ( vRetResult == null)
    else{ // else if (vRetResult == null)%>
          <tr> 
            <td width="19%" height="25" align="center" class="thinborder"><strong>WORKING DATE </strong> </td>
            <td width="40%" align="center" class="thinborder"><strong>TIME / HOURS</strong></td>
            <td width="26%" align="center" class="thinborder"><strong>  BREAK </strong></td>
            <td width="15%" align="center" class="thinborder"><strong> OPTION </strong></td>			
          </tr>
			<%
 			for (i = 0; i < vEmployeeWH.size(); i+=25){%>
          <tr> 
            <td height="25" bgcolor="#FFFFFF"  class="thinborder">&nbsp;
					<%=WI.getStrValue((String)vEmployeeWH.elementAt(i+16))%></td>
         <%
					 strTemp = "";
						// first login time
						strTemp2 = (String)vEmployeeWH.elementAt(i+1) +  ":"  + 
							CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+2)) +
							" " + astrConverAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(i+3))] + 
							" - " + (String)vEmployeeWH.elementAt(i+4) +  
							":"  + 	CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+5)) + 
							" " + astrConverAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(i+6))];

						// second login time
						if ((String)vEmployeeWH.elementAt(i+7) != null)
								strTemp = " / " + (String)vEmployeeWH.elementAt(i+7) +  ":" + 
								CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+8)) +
								" " + astrConverAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(i+9))] + 
								" - " + (String)vEmployeeWH.elementAt(i+10) + ":"  + 
								CommonUtil.formatMinute((String)vEmployeeWH.elementAt(i+11)) +  
								" " + astrConverAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(i+12))];
										 
							if (((String)vEmployeeWH.elementAt(i + 15)).equals("1"))
								strTemp +="(next day)";
					%>
          <td bgcolor="#FFFFFF" class="thinborder"><strong>&nbsp;<%=strTemp2%><%=WI.getStrValue(strTemp)%></strong></td>
					<%
						strTemp = (String)vEmployeeWH.elementAt(i+18);
						strTemp2 = (String)vEmployeeWH.elementAt(i+19);
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
							strTemp = WI.getStrValue((String)vEmployeeWH.elementAt(i+17), "0");
							if(Double.parseDouble(strTemp) == 0)	
								strTemp = "";
						}
					%>
         <td bgcolor="#FFFFFF"  class="thinborder"><strong>&nbsp;<%=strTemp%></strong></td>
	       <td nowrap bgcolor="#FFFFFF"  class="thinborder">&nbsp;
					<%if(iAccessLevel > 1 && bolAllowEdit) {%>
						<a href='javascript:ShowUpdate("<%=vEmployeeWH.elementAt(i)%>", "<%=WI.fillTextValue("emp_id")%>");'><strong>EDIT</strong></a>
					<%}if(iAccessLevel ==2){%>
           <a href="javascript:DeleteRecord('<%=(String)vEmployeeWH.elementAt(i)%>', '<%=WI.getStrValue((String)vEmployeeWH.elementAt(i+16))%>')">
					 <img src="../../../images/delete.gif" width="55" height="28" border="0">
					 </a>					 
           <%} // end iAccessLevel == 2%>         </td>
          </tr>
    <%
   } // end for loop
 } // else if (vRetResult == null)
} %>
        </table></td>
    </tr>
</table>
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
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="">
<input type="hidden" name="prepareToEdit" value="">
<input type="hidden" name="iStatus" value="">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">

<!-- for non-EDTR set user_index if called for nonEDTR remove info-->
<input type="hidden" name="non_EDTR">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
