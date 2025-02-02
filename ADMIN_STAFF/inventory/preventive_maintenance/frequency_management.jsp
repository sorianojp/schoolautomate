<%@ page language="java" import="utility.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>

function CancelOP(){
	document.freq_form_.info_index.value ="";	
	document.freq_form_.page_action.value = "";	
	document.freq_form_.prepareToEdit.value = "";	
	document.freq_form_.submit();
}

function PageAction(strAction, strInfoIndex){

	if(strAction == "0"){
		if(!confirm("Do you want to delete this information?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.freq_form_.info_index.value =strInfoIndex;
	
	document.freq_form_.page_action.value = strAction;	
	document.freq_form_.submit();
}

function PrepareToEdit(strInfoIndex){
	document.freq_form_.info_index.value =strInfoIndex;	
	document.freq_form_.page_action.value = "";	
	document.freq_form_.prepareToEdit.value = "1";	
	document.freq_form_.submit();
}


function CloseWindow(){
	document.freq_form_.close_wnd_called.value = "1";
	window.opener.document.form_.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {


	if(document.freq_form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.freq_form_.close_wnd_called.value == "0") {
		window.opener.document.form_.submit();

		window.opener.focus();
	}
}

function FocusID(){
	document.freq_form_.frequency_name.focus();
}
</script>
</head>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-PREVENTIVE_MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Inventory -PREVENTIVE MAINTENANCE","frequency_management.jsp");
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

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
inventory.InvPreventiveMaintenance prevMain = new inventory.InvPreventiveMaintenance();

Vector vEditInfo  = null;
Vector vRetResult = null;
	
	
strTemp = WI.fillTextValue("page_action");		
if(strTemp.length() > 0) {		
	if(prevMain.operateOnFrequencyMgmt(dbOP, request, Integer.parseInt(strTemp)) == null )
		strErrMsg = prevMain.getErrMsg();
	else{			
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully saved.";				
		if(strTemp.equals("0"))
			strErrMsg = "Information successfully deleted.";					
		if(strTemp.equals("2"))
			strErrMsg = "Information successfully updated.";	
		strPrepareToEdit = "0";		
	}
}	



String strPreload = null;
if(strPrepareToEdit.equals("1")){
	vEditInfo = prevMain.operateOnFrequencyMgmt(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = prevMain.getErrMsg();
	else{
		strPreload = (String)vEditInfo.elementAt(3);
	}
}

int iElemCount = 0;

vRetResult = prevMain.operateOnFrequencyMgmt(dbOP, request, 4);
if(vRetResult != null && vRetResult.size() > 0)
	iElemCount = prevMain.getElemCount();

			
		
		
String[] astrMaintenanceStart = {"at End", "at Beginning"};	
%>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();" onLoad="FocusID();">
<form name="freq_form_" action="frequency_management.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          FREQUENCY MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="76%" height="25"><font size="2"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
      <td width="24%"><a href="javascript:CloseWindow();">
	  <img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">Frequency Name</td>
		<%
		strPreload = "0";
		strTemp = WI.fillTextValue("frequency_name");
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(1);
			strPreload = (String)vEditInfo.elementAt(3);
		}
		%>
		<td>		
		<input name="frequency_name" type="text" class="textbox" size="40" maxlength="128"
			onblur='style.backgroundColor="white"' 
			onFocus="style.backgroundColor='#D3EBFF'"
			value="<%=WI.getStrValue(strTemp)%>">		</td>
	</tr>

  	<tr>
  	    <td height="25">&nbsp;</td>
  	    <td>No of Days</td>
		<%
		strTemp = WI.fillTextValue("no_of_days");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		%>
  	    <td> <input name="no_of_days" type="text" class="textbox" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>"
		onKeyUp="AllowOnlyInteger('freq_form_','no_of_days')" onBlur="AllowOnlyInteger('freq_form_','no_of_days')"> </td>
  	</tr>

  	<tr>
  	    <td height="25">&nbsp;</td>
  	    <td>&nbsp;</td>
  	    <td>
		<%if(strPrepareToEdit.equals("0")){%>
			<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
			<font size="1">Click to save information</font>
		<%}else{%>
			<a href="javascript:PageAction('2','');"><img src="../../../images/edit.gif" border="0"></a>
			<font size="1">Click to update information</font>
		<%}%>
		<a href="javascript:CancelOP();"><img src="../../../images/cancel.gif" border="0"></a>
			<font size="1">Click to cancel operation</font>
		</td>
  	    </tr>
  	<tr>
  	    <td height="25">&nbsp;</td>
  	    <td>&nbsp;</td>
  	    <td>&nbsp;</td>
  	    </tr>
  </table>  
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr><td height="25" align="center">FREQUENCY LIST</td></tr>
  </table>	
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  	<tr>
		<td width="30%" height="25" align="center" class="thinborder">FREQUENCY NAME</td>
		<td width="16%" align="center" class="thinborder">No. OF DAYS</td>		
		<td width="22%" align="center" class="thinborder">OPTION</td>
	</tr>
<%for(int i = 0; i < vRetResult.size(); i += iElemCount){
strPreload = WI.getStrValue((String)vRetResult.elementAt(i+3),"0");
%>
  	<tr>
  	    <td align="center" class="thinborder" height="25"><%=vRetResult.elementAt(i+1)%></td>		
  	    <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>		
  	    <td align="center" class="thinborder">
		<%
		if(strPreload.equals("0")){
		%>
		<a href="javascript:PrepareToEdit('<%=vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a>
		
		<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
		<%}else{%>NOT ALLOWED<%}%>
		</td>
    </tr>
<%}%>
  </table>
<%}%>
 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr> 
      <td width="76%" height="25">&nbsp;</td>
    </tr>
	<tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

  	<input type="hidden" name="info_index"  value="<%=WI.fillTextValue("info_index")%>">	
    <input type="hidden" name="page_action">

	<%
	strPreload = "0";
	if(vEditInfo != null && vEditInfo.size() > 0)
		strPreload = (String)vEditInfo.elementAt(3);
	%>
	<input type="hidden" name="is_preload" value="<%=strPreload%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">	
	
	  <input type="hidden" name="close_wnd_called" value="0">
	  <input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>