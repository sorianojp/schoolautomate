<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch(strIsStud) {
	var pgLoc = "";
	if(strIsStud == '1') 
		pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.user_id";
	else
		pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.user_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	if(document.form_.del_all.checked)
		document.form_.page_action.value = "5";
	document.form_.submit();
}
function RemoveMod(strInfoIndex, strModIndex) {
	if(!confirm("Do you want to remove message from this module."))
		return;
	
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.module_code_ref.value = strModIndex;
	document.form_.submit();
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.user_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length < 3) {
		objCOAInput.innerHTML = "<font color=blue size='1'>Please enter atleast 3 chars</font>";
		return;
	}
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);
	if(document.form_.searchID[0].checked)
		strURL = strURL + "&is_faculty=1";

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.user_id.value = strID;
	//alert(document.getElementById("coa_info").innerHTML);
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	
	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-Set System wide Message","set_msg_user.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("SYSTEM ADMINISTRATION-SET PARAMETERS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("SYSTEM ADMINISTRATION"),"0"));
		}
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments".toUpperCase()),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments-Reports".toUpperCase()),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Registrar Management".toUpperCase()),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Registrar Management-Reports".toUpperCase()),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR Management-REPORTS AND STATISTICS".toUpperCase()),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS-STUDENT TRACKER"),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS"),"0"));
	}
if(iAccessLevel == -1) {//for fatal error.
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0) {//NOT AUTHORIZED.
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	MessageSystem msgSys = new MessageSystem();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(msgSys.operateOnSystemWideMsg(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = msgSys.getErrMsg();
	}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = msgSys.operateOnSystemWideMsg(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = msgSys.getErrMsg();
	}
	//view all 
	
	vRetResult = msgSys.operateOnSystemWideMsg(dbOP, request, 4);
	if (strErrMsg==null && vRetResult == null)
		strErrMsg=msgSys.getErrMsg();
	
String[] astrConvertModName = {"Show in ALL","Admission","Advising","Grade Sheet(ALL)",
			"Grade Releasing","Residency Status","Installment Payment","Student Ledger", "On Logon","Grade encoding",
			"TOR","Evaluation","In Attendance(eDTR and eSC) "};
%>


<body bgcolor="#D2AE72">
<form name="form_" action="./set_msg_user.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
           MESSAGE SYSTEM ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr valign="top">
      <td width="1%" height="25">&nbsp;</td>
      <td width="12%" class="thinborderNONE">User ID</td>
      <td width="44%">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.remove(0);
else	
	strTemp = WI.fillTextValue("user_id");
%>
	  <input name="user_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" style="font-size:11px"
	  onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" onKeyUp="AjaxMapName(1);" >
        <font size="1">
		<!--<a href="javascript:OpenSearch('0');"><img src="../../../images/search.gif" border="0"></a>-->
<%
strTemp = WI.fillTextValue("searchID");
if(strTemp.equals("0")) {
	strTemp = " checked";
	strErrMsg = "";
}
else {	
	strErrMsg = " checked";
	strTemp   = "";
}%>
		<input type="radio" name="searchID" value="0"<%=strTemp%>>Search Employee
		&nbsp;
		<!--<a href="javascript:OpenSearch('1');"><img src="../../../images/search.gif" border="0"></a>-->
<%if(bolIsSchool){%>
		<input type="radio" name="searchID" value="1"<%=strErrMsg%>> Student</font>		
<%}%>
		</td>
      <td width="43%"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">Effective Date </td>
      <td colspan="2" class="thinborderNONE">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.remove(1);
else	
	strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);

%>	  <input name="date_fr" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  	onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" readonly="yes">
	  <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  &nbsp;&nbsp; to &nbsp;&nbsp;
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.remove(1);
else	
	strTemp = WI.fillTextValue("date_to");

%>	  <input name="date_to" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  	onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" readonly="yes">
	  <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE"> Message </td>
      <td colspan="2">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.remove(0);
else	
	strTemp = WI.fillTextValue("message");
%>	  <textarea name="message" cols="50" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">Target</td>
      <td colspan="2" class="thinborderNONE">
<%
strTemp = "";
if(vEditInfo != null) {
	if(vEditInfo.indexOf("8") > -1)
		strTemp = " checked";
}
else if(WI.fillTextValue("target_8").length() > 0) 
	strTemp = " checked";
%>		<input name="target_8" type="checkbox" value="8"<%=strTemp%>>On Logon 
&nbsp;&nbsp;&nbsp;		
		<%if(!bolIsSchool){%>
			<%
			strTemp = "";
			if(vEditInfo != null) {
				if(vEditInfo.indexOf("12") > -1)
					strTemp = " checked";
			}
			else if(WI.fillTextValue("target_12").length() > 0) 
				strTemp = " checked";
			%>
		       	 <input name="target_12" type="checkbox" value="12"<%=strTemp%>>In Attendance (eDTR)
		<%}%>
	 </td>
    </tr>
<%if(bolIsSchool){%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td class="thinborderNONE">&nbsp;</td>
		  <td colspan="2" class="thinborderNONE">
	<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("1") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_1").length() > 0) 
		strTemp = " checked";
	%>
			<!--<input name="target_1" type="checkbox" value="1"<%=strTemp%>>Admission-->
	<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("2") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_2").length() > 0) 
		strTemp = " checked";
	%>	    <input name="target_2" type="checkbox" value="2"<%=strTemp%>>Advising      </td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td class="thinborderNONE">
	<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("0") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_0").length() > 0) 
		strTemp = " checked";
	%>	  <input type="checkbox" name="target_0" value="0"<%=strTemp%>><font style="font-size:10px; font-weight:bold;color:#0000FF">All Target</font></td>
		  <td colspan="2" class="thinborderNONE">
	<%
	strTemp = "";
	if(vEditInfo != null){
		if(vEditInfo.indexOf("4") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_4").length() > 0) 
		strTemp = " checked";
	%>	  	<input name="target_4" type="checkbox" value="4"<%=strTemp%>>
	Grade Releasing
	<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("5") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_5").length() > 0) 
		strTemp = " checked";
	%>		<input name="target_5" type="checkbox" value="5"<%=strTemp%>>Residency Status
			&nbsp;&nbsp;
			
	<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("9") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_9").length() > 0) 
		strTemp = " checked";
	%>		<input name="target_9" type="checkbox" value="9"<%=strTemp%>>
	Grade Encoding(old)&nbsp;&nbsp;
			<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("10") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_10").length() > 0) 
		strTemp = " checked";
	%>		<input name="target_10" type="checkbox" value="10"<%=strTemp%>>
			TOR
			&nbsp;&nbsp;
			<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("11") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_11").length() > 0) 
		strTemp = " checked";
	%>		<input name="target_11" type="checkbox" value="11"<%=strTemp%>>
			Course Evaluation 
	&nbsp;&nbsp;&nbsp;		</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
		<%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(0);
		else	
			strTemp = WI.fillTextValue("set_msg_user");
		%>
		  <td colspan="2" class="thinborderNONE">
	<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("6") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_6").length() > 0) 
		strTemp = " checked";
	%>        <input name="target_6" type="checkbox" value="6"<%=strTemp%>>
	Installment and other Payment Screen
	<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("7") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_7").length() > 0) 
		strTemp = " checked";
	%>		<input name="target_7" type="checkbox" value="7"<%=strTemp%>>Student Ledger</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="2" class="thinborderNONE">
	<%
	strTemp = "";
	if(vEditInfo != null) {
		if(vEditInfo.indexOf("12") > -1)
			strTemp = " checked";
	}
	else if(WI.fillTextValue("target_12").length() > 0) 
		strTemp = " checked";
	%>        <input name="target_12" type="checkbox" value="12"<%=strTemp%>>In Attendance (eSecurity and eDTR)	  </td>
		</tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a> Click to add entry
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> Click to edit event
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> Click to clear entries
        <%}%> </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#EEEEEE">
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">Search Filter</td>
      <td colspan="2" class="thinborderNONE">Show Max Result 
<%
strTemp = WI.fillTextValue("max_disp");
if(strTemp.equals("25"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		  <input name="max_disp" type="radio" value="25"<%=strErrMsg%>>25
<%
strTemp = WI.fillTextValue("max_disp");
if(strTemp.equals("50"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		  <input name="max_disp" type="radio" value="50"<%=strErrMsg%>>50
<%
strTemp = WI.fillTextValue("max_disp");
if(strTemp.equals("75"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		  <input name="max_disp" type="radio" value="75"<%=strErrMsg%>>75
<%
strTemp = WI.fillTextValue("max_disp");
if(strTemp.equals("100") || request.getParameter("max_disp") == null)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		  <input name="max_disp" type="radio" value="100"<%=strErrMsg%>>100	  </td>
    </tr>
    <tr bgcolor="#EEEEEE">
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td colspan="2" class="thinborderNONE"> ID Starts With : 
      <input name="user_id_starts" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("user_id_starts")%>" size="16"></td>
    </tr>
    <tr bgcolor="#EEEEEE">
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td colspan="2" class="thinborderNONE">
<%
strTemp = WI.fillTextValue("inc_invalid");
if(strTemp.length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input name="inc_invalid" type="checkbox" value="radiobutton"<%=strTemp%>>Include Invalid Msg 
<%
strTemp = WI.fillTextValue("only_invalid");
if(strTemp.length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>      <input name="only_invalid" type="checkbox" value="radiobutton"<%=strTemp%>>Show only invalid Msg 
<%
strTemp = WI.fillTextValue("del_all");
if(strTemp.length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>      <input name="del_all" type="checkbox" value="radiobutton"<%=strTemp%>>Delete all invalid Msg		</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" align="center">
	  <a href="#"><img src="../../../images/refresh.gif" border="0" onClick="ReloadPage();"></a>Click to reload this page. </td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0) {
        Vector vMsgIndex   = (Vector)vRetResult.remove(0);
        Vector vModuleList = (Vector)vRetResult.remove(0);
		int iIndexOf       = 0;
%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="23" colspan="8" class="thinborder"> <div align="center"> <strong><font size="2">MESSAGES</font></strong></div></td>
    </tr>
    <tr bgcolor="#DDDDDD"> 
      <td width="20%" height="23" class="thinborder"> <div align="center"><strong>ID Number (Name)</strong></div></td>
      <td width="40%" class="thinborder"> <div align="center"><strong>Message</strong></div></td>
      <td align="center" class="thinborder" width="12%"><strong>Effective Date</strong> </td>
      <td align="center" class="thinborder" width="18%"><strong>Target</strong></td>
      <td align="center" class="thinborder" width="5%">&nbsp;</td>
      <td align="center" class="thinborder" width="5%">&nbsp;</td>
    </tr>
    <%//System.out.println(vRetResult);System.out.println(vMsgIndex);System.out.println(vModuleList);
	
	Integer objInt = null;
    for (int i = 0; i<vRetResult.size(); i+=9) { %>
    <tr> 
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+5)%>(<%=(String)vRetResult.elementAt(i+6)%>)</td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%> to <%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">
	  <%iIndexOf = -1;
	  if(vMsgIndex.size() > 0)
		  iIndexOf = vMsgIndex.indexOf(vRetResult.elementAt(i));
	//System.out.println("iIndexOf :"+ iIndexOf);
	  if(iIndexOf > -1) {
	  	strTemp = (String)vMsgIndex.remove(iIndexOf);
		objInt = new Integer(strTemp);
		  
		while(true)  {
		iIndexOf = vModuleList.indexOf(objInt);	
		if(iIndexOf == -1)
			break;
		%>
			<a href="javascript:RemoveMod('<%=strTemp%>','<%=(String)vModuleList.elementAt(iIndexOf + 1)%>');" title="Click to remove Module">
				<%=astrConvertModName[Integer.parseInt((String)vModuleList.remove(iIndexOf + 1))]%></a>
			<%
			vModuleList.removeElementAt(iIndexOf);
			//if(vModuleList.size () <= (iIndexOf * 2))
			//	break;
			%><br><%
		}
	  }%>  
	  </td>
      <td class="thinborder"> <font size="1"> 
        <% if(iAccessLevel == 2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized 
        <%}%>
        </font></td>
      <td class="thinborder"><font size="1"> 
        <% if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized
        <%}%>
        </font></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<%}//show only if vRetResult is not null%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="module_code_ref">
</form>
</body>
</html>
