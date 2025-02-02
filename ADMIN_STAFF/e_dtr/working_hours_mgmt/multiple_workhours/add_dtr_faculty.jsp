<%@ page language="java" import="utility.*,java.util.Vector,eDTR.MultipleWorkingHour" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style type="text/css">
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function SaveData() {
	document.form_.page_action.value = "6";
	//document.form_.hide_save.src = "../../../../images/blank.gif";
	this.SubmitOnce('form_');
}
	function ViewRecords(){
		document.form_.page_action.value = 4;
		document.form_.prepareToEdit.value = 0;
		document.form_.show_list.value = 1;
	}  

	function CancelRecord(){
		location = "./add_dtr_faculty.jsp?emp_id=" + document.form_.emp_id.value + 
			"&login_date="+document.form_.login_date.value+
			"&show_list=1";
	}

	function DeleteRecord(){
		document.form_.page_action.value = "7";
		this.SubmitOnce('form_');
	}
  
	function focusID() {
		document.form_.emp_id.focus();
	}
	
	function OpenSearch() {
		var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function UpdateLateUT(strInfoIndex,strTinTout,iCtr){
	document.form_.info_index.value = strInfoIndex;
	document.form_.bTimeIn.value = strTinTout;
	eval('document.form_.late_under_time_val.value=document.form_.txtbox'+iCtr+'.value');
	document.form_.page_action.value="5";
	document.form_.submit();
}

-->
</script>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","add_dtr_faculty.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(),
														"add_dtr_faculty.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

///// exclusive for testers only.. 
String strUserID = (String)request.getSession(false).getAttribute("userId");
//////////////////



MultipleWorkingHour TInTOut = new MultipleWorkingHour();
Vector vRetResult = null;
Vector vPersonalDetails = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String[] astrConverAMPM = {"AM","PM"};

int iPageAction  = 0;

strTemp = WI.fillTextValue("page_action");

	if(strTemp.length() > 0){
		if(TInTOut.operateOnEmpMultipleLogs(dbOP, request, Integer.parseInt(strTemp)) == null){
			strErrMsg = TInTOut.getErrMsg();
		} else {
			if(strTemp.equals("6"))
				strErrMsg = "Successfully posted.";		
		}
	}

	vRetResult = TInTOut.operateOnEmpMultipleLogs(dbOP, request,5);
 	if (vRetResult == null || vRetResult.size() == 0){
		strErrMsg  = TInTOut.getErrMsg();
	}
%>

<form action="./add_dtr_faculty.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        DTR OPERATIONS - EDIT TIME-IN TIME-OUT PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp; <a href="./working_hour_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23">Employee ID </td>
      <td width="21%" height="23">
        <input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"
	   onKeyUp="AjaxMapName(1);">
        &nbsp; </td>
      <td width="19%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="63%" rowspan="3" valign="top">
<% if (WI.fillTextValue("emp_id").length() > 0) {

    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vPersonalDetails!=null){
%>
        <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
          <tr>
            <td> <table width="100%" border="0" cellspacing="0" cellpadding="3">
                <tr>
                  <td width="27%" rowspan="4">
                    <%strTemp = "<img src=\"../../../../upload_img/" + WI.fillTextValue("emp_id").toUpperCase() + 
								"."+strImgFileExt+"\" width=100 height=100>";%>
								
                    <%=strTemp%> </td>
					<% strTemp = WI.formatName((String)vPersonalDetails.elementAt(1), 
												(String)vPersonalDetails.elementAt(2),
												(String)vPersonalDetails.elementAt(3), 4); %>
												
                  <td width="73%" height="25"><strong><font size=1>Name : <%=WI.getStrValue(strTemp)%></font></strong></td>
                </tr>
                <tr>
                  <td height="25"><strong><font size=1>Position: <%=WI.getStrValue((String)vPersonalDetails.elementAt(15))%></font></strong></td>
                </tr>
                <tr>
                  <%
	   	 if((String)vPersonalDetails.elementAt(13) == null)
		    strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		else
			{
			strTemp =WI.getStrValue((String)vPersonalDetails.elementAt(13));
			if((String)vPersonalDetails.elementAt(14) != null)
		 	 strTemp += "/" + WI.getStrValue((String)vPersonalDetails.elementAt(14));
			}
%>
                  <td height="25"><strong><font size=1>Office/College : <%=WI.getStrValue(strTemp)%></font></strong></td>
                </tr>
                <tr>
                  <td height="25"><strong><font size=1>Status: <%=WI.getStrValue((String)vPersonalDetails.elementAt(16))%></font></strong></td>
                </tr>
              </table></td>
          </tr>
        </table>
        <%}else{%>
	<font size=2><strong><%=authentication.getErrMsg()%></strong></font>
<%}}%>	</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Date </td>
      <td height="20" colspan="2">
<%
strTemp = WI.fillTextValue("login_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>	  <input name="login_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.login_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
<!--
		&nbsp;&nbsp;<a href="javascript:ClearDate();"><img src="../../../../images/clear.gif" width="55" height="19" border="0" ></a><font size="1">
        clear the date</font> --></td>
    </tr>
    <tr>
      <td width="3%" height="35">&nbsp;</td>
      <td width="13%" height="25">&nbsp;</td>
      <td colspan="2"><input name="image" type="image" onClick="ViewRecords()"  src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
    <tr>
      <td valign="top">&nbsp;</td>
      <td height="25" colspan="4"><label id="coa_info"></label>
        <%
				if(WI.fillTextValue("is_manual").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input type="checkbox" name="is_manual" value="1"<%=strTemp%>>
        <font size="1">use manually entered late and undertime</font></td>
    </tr>
  </table>
 <% if (vPersonalDetails != null && WI.fillTextValue("emp_id").trim().length() > 0){ %>
 <%
	if ((vRetResult != null) && (vRetResult.size()>0)) { %>
 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
   <tr>
     <td height="25" colspan="8" align="center" bgcolor="#B9B292" class="thinborder">LIST OF 
       TIME RECORDED FOR ID : <%=WI.fillTextValue("emp_id")%></td>
   </tr>
   <tr>
     <td width="22%" height="26" align="center" class="thinborder"><strong>Scheduled Time </strong></td>
     <td width="22%" align="center" class="thinborder"><strong>Actual Time In </strong></td>
     <td width="8%" align="center" class="thinborder"><strong>ROOM</strong></td>
     <td colspan="2" align="center" class="thinborder"><strong>TIME</strong></td>
     <td width="9%" align="center" class="thinborder">&nbsp;</td>
     <td width="4%" align="center" class="thinborder">&nbsp;</td>
     <td width="10%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
     </strong>
         <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
     </font></td>
    </tr>
   <% int iCount = 1;
	  		for(int i = 0; i < vRetResult.size(); i += 25, iCount++){
	 %>
   <tr>
	 	<input type="hidden" name="info_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<input type="hidden" name="sched_login_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+13)%>">
		<input type="hidden" name="sched_logout_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+14)%>">
     <%
			strTemp = (String)vRetResult.elementAt(i + 3);		
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+4),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+5))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 6);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+7),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+8))];
			%>
     <td height="25" rowspan="2" class="thinborder">&nbsp;<%=strTemp%></td>
		 <input type="hidden"	 name="schedule_<%=iCount%>" value="<%=strTemp%>">
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11));			
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12), strTemp + " - ","", strTemp);
		 %>
     <td rowspan="2" class="thinborder">&nbsp;<%=strTemp%></td>
		 <%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+16));			
		 %>		 
     <td rowspan="2" class="thinborder"><%=strTemp%></td>
     <td width="5%" class="thinborder"> In</td>
     <td width="20%" class="thinborder">&nbsp;
       <input name="hr_from_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("hr_from_"+iCount)%>" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" 
		style="text-align : right" >
:
  <input name="min_from_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("min_from_"+iCount)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		style="text-align : right">
  <%
		strTemp = WI.fillTextValue("ampm_from_"+iCount);
		%>
  <select name="ampm_from_<%=iCount%>">
    <option value="0" >AM</option>
    <% if (strTemp.equals("1")) {%>
    <option value="1" selected>PM</option>
    <% }else {%>
    <option value="1">PM</option>
    <%}%>
  </select></td>
     <td align="right" class="thinborder">Late  </td>
     <td align="center" class="thinborder"><input name="tardiness_<%=iCount%>" type="text" size="3" maxlength="3" value="<%=WI.fillTextValue("tardiness_"+iCount)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" style="text-align : right"></td>
     <td rowspan="2" align="center" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1"></td>
   </tr>
   <tr>
     <td height="25" class="thinborder"> Out</td>
     <td class="thinborder">&nbsp;
       <input name="hr_to_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("hr_to_"+iCount)%>" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" style="text-align : right">
:
  <input name="min_to_<%=iCount%>" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("min_to_"+iCount)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" style="text-align : right">
  <%
		strTemp = WI.fillTextValue("ampm_to_"+iCount);
		%>
  <select name="ampm_to_<%=iCount%>">
    <option value="0" >AM</option>
    <% if (strTemp.equals("1")) {%>
    <option value="1" selected>PM</option>
    <% }else {%>
    <option value="1">PM</option>
    <%}%>
  </select></td>
     <td align="right" class="thinborder">Undertime </td>
     <td align="center" class="thinborder"><input name="undertime_<%=iCount%>" type="text" size="3" maxlength="3" value="<%=WI.fillTextValue("undertime_"+iCount)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" style="text-align : right"></td>
   </tr>
   <%}%>
	  <input type="hidden" name="emp_count" value="<%=iCount%>">
 </table>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="20">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" align="center"><font size="1">
        <input type="button" name="122" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
click to save entries
<input type="button" name="1222" value=" Delete " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
Click to delete selected
<input type="button" name="1223" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
click to cancel or go previous</font></td>
    </tr>
  </table>
 <%}} // end else (vRetResult == null)%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="prepareToEdit" value=" <%=WI.getStrValue(strPrepareToEdit,"0")%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="bTimeIn" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input name="noAdjustment" type="hidden" value="1">
<input type="hidden" name="info_logged" value="<%=WI.fillTextValue("info_logged")%>">
<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
<input type="hidden" name="late_under_time_val" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
