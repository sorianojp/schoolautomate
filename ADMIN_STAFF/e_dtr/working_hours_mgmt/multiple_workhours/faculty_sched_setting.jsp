<%@ page language="java" import="utility.*, java.util.Vector, eDTR.MultipleWorkingHour" %>
<%
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll late conversion setting</title>
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
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	if(!confirm("Continue deleting? "))
		return;
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./faculty_sched_setting.jsp";
}

function UpdateProp(strInfoIndex){
	document.form_.update_info.value ="1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

	//add security here. 
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record-WORKING HOURS MGMT".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record".toUpperCase()),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Late Conversion Setting","faculty_sched_setting.jsp");
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

//end of authenticaion code.
MultipleWorkingHour whLateSetting = new MultipleWorkingHour();
Vector vRetResult = null;
Vector vEditInfo = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
int i = 0;
ReadPropertyFile rpf = new ReadPropertyFile();
Vector vProp = null;
if(WI.fillTextValue("update_info").compareTo("1") == 0){
	if (rpf.setSysProperty(dbOP, request,WI.fillTextValue("info_index")))
		strErrMsg = " Information updated successfully";
	else {
		strErrMsg = rpf.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = " Infomation not updated. Please refresh and try again";
	}
}

vProp = rpf.getAllSysProperty(dbOP);
int iIndex = -1;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(whLateSetting.operateOnFacultyLateConversion(dbOP, request, Integer.parseInt(strTemp)) != null){
		strErrMsg = "Operation Successful";
		strPrepareToEdit = "";
	}else
		strErrMsg = whLateSetting.getErrMsg();
 }

 if (strPrepareToEdit.length() > 0){
	vEditInfo = whLateSetting.operateOnFacultyLateConversion(dbOP, request, 3);
	if (vEditInfo == null)
		strErrMsg = whLateSetting.getErrMsg();
}

	vRetResult = whLateSetting.operateOnFacultyLateConversion(dbOP, request, 4);
%>
<form action="./faculty_sched_setting.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      LATE CONVERSION ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>Effective Date </strong></u></td>
      <td height="30">
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(5);
				else
					strTemp = WI.fillTextValue("date_from");
			%>
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date"
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0"></a> <a href="javascript:show_calendar('form_.date_to');" title="Click to select date"
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"></a></td>
    </tr>
    <tr>
      <td height="12" colspan="3"></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>Late TIME IN (in mins)</strong></u></td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(1);
				else
					strTemp = WI.fillTextValue("late_mins");
			%>
      <td><u><strong>
        <input name="late_mins" type="text" size="4" maxlength="3"
				 value="<%=WI.getStrValue(strTemp)%>" class="textbox"
			   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </strong></u></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="22%" height="25"><u><strong>Minutes to deduct </strong></u></td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(2);
				else
					strTemp = WI.fillTextValue("conversion");
			%>
      <td width="74%">
			<input name="conversion" type="text" size="4" maxlength="3"
	  	value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'"
			class="textbox" onBlur="style.backgroundColor='white'">			</td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
	    <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" align="center">
			<%if(iAccessLevel > 1){%>
			<font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
Click to save entries
<%}else{%>
<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:EditRecord();">
Click to edit event
<%}%>
<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;"
				onClick="javascript:CancelRecord();">
Click to clear </font>
			<%}%>
			</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="4" align="center" bgcolor="#B9B292" class="thinborder">&nbsp;</td>
    </tr>

    <tr>
      <td height="26" align="center" class="thinborder"><font size="1"><strong>EFFECTIVE DATE </strong></font></td>
      <td align="center" class="thinborder"><strong><font size="1">LATE DURATION </font></strong></td>
      <td align="center" class="thinborder"><strong><font size="1">LATE CONVERSION </font></strong></td>
      <td align="center" class="thinborder"><strong><font size="1"><strong>OPTION</strong></font></strong></td>
    </tr>

    <% for(i =0; i < vRetResult.size(); i += 12){%>
    <tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
			%>
      <td width="26%" height="25" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
			%>
			<td width="19%" align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
			%>
      <td width="19%" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
      <td width="17%" height="25" align="center" class="thinborder">&nbsp;
	  <%if(iAccessLevel > 1){%>
		<input type="button" name="edit2" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
	  <%}
		if(iAccessLevel == 2){%>
      <input type="button" name="delete" value="Delete" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>');">
      <%}%>    </td>
    </tr>
    <%}%>
  </table>
	<%}%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr bgcolor="#F2E9D7">
      <td height="25" class="thinborderBOTTOM"><strong>&nbsp;Access Password</strong></td>
    </tr>
    <tr>
      <td width="34%" height="25" style="font-size:11px"><strong>&nbsp;Password to Access</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;<input type="password" name="access_pwd" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="24"></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr bgcolor="#F2E9D7">
      <td height="25" colspan="3" class="thinborderALL"><strong>&nbsp;System Preference</strong></td>
    </tr>

    <tr>
      <td width="23%" height="25" class="thinborderLEFT">Grace Period </td>
      <td width="11%">
			<% if (vProp != null)
					iIndex= vProp.indexOf("FACULTY_GRACE");
			   else
				 	iIndex = -1;//System.out.println(vRetResult);
				 //System.out.println("iIndex " + iIndex);
				 if (iIndex != -1) {
					 strTemp = (String)vProp.elementAt(iIndex+1);
					 vProp.removeElementAt(iIndex);
					 vProp.removeElementAt(iIndex);
				 }else
				 	 strTemp = WI.fillTextValue("FACULTY_GRACE");
				//System.out.println("strTemp " + strTemp);
			%>
			<input name="FACULTY_GRACE" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="66%" height="25" class="thinborderRIGHT"> <font size="1"><a href='javascript:UpdateProp("FACULTY_GRACE")'><img src="../../../../images/update.gif" width="60" height="26" border="0"></a>(Number of minutes grace period per class for faculty)</font></td>
    </tr>
    <tr>
      <td height="25" colspan="3" class="thinborderBOTTOMLEFTRIGHT"><strong>Note : </strong>Faculty actual late will be recorded as 0(zero) if late is within the set grace period even if conflict with late conversion setting is found.</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="print_page">
	<input type="hidden" name="update_info" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
