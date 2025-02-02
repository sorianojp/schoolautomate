<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.cutoff_time.page_action.vlaue ="";
	document.cutoff_time.submit();
}
function PrepareToEdit(strInfoIndex)
{
	document.cutoff_time.page_action.vlaue ="";
	document.cutoff_time.prepareToEdit.value = 1;
	document.cutoff_time.info_index.value = strInfoIndex;
	document.cutoff_time.submit();
}

function PageAction(strAction,strInfoIndex)
{
	document.cutoff_time.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.cutoff_time.info_index.value  = strInfoIndex;
	document.cutoff_time.submit();
}
function CancelRecord()
{
	location = "./setup_cutoff_time.jsp";
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.cutoff_time.emp_id.value;
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
	document.cutoff_time.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	this.viewInfo();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FADailyCashCollectionDtls,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit=WI.getStrValue(request.getParameter("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Daily cash collection mgmt-Set cutoff time","setup_cutoff_time.jsp");
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
														"Fee Assessment & Payments","DAILY CASH COLLECTION MGMT",request.getRemoteAddr(),
														"setup_cutoff_time.jsp");
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
FADailyCashCollectionDtls DCCDtls = new FADailyCashCollectionDtls();
Vector vRetResult = null;
Vector vEditInfo  = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(DCCDtls.operateOnSetCutoffTime(dbOP,request,Integer.parseInt(strTemp))== null)
		strErrMsg = DCCDtls.getErrMsg();
	else {
		strErrMsg = "Operation is successful.";	
		strPrepareToEdit = "0";
	}
}

//I have to get the information to view or edit. 
if(strPrepareToEdit.compareTo("1") ==0){
	vEditInfo = DCCDtls.operateOnSetCutoffTime(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = DCCDtls.getErrMsg();
}
//view all. 
vRetResult = DCCDtls.operateOnSetCutoffTime(dbOP, request,4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = DCCDtls.getErrMsg();


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<form name="cutoff_time" method="post" action="./setup_cutoff_time.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SET DAILY CASH COLLECTION CUT-OFF TIME ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Cut-off time</td>
      <td width="22%"> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("time_hr");
%> <input type="text" name="time_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("time_min");
%> <input type="text" name="time_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <select name="time_AMPM">
          <option selected value="1">PM</option>
          <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("time_AMPM");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>AM</option>
          <%}else{%>
          <option value="0">AM</option>
          <%}%>
        </select></td>
      <td width="62%"><a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" border="0"></a> 
        Click to refresh page.</td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>Effective date</td>
      <td colspan="2"> <%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp =WI.fillTextValue("date_remitted");
if(strTemp.length() ==0)
	strTemp =WI.getTodaysDate(1);
%> <input name="date_remitted" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp; <a href="javascript:show_calendar('cutoff_time.date_remitted');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
<%
if(strSchCode.startsWith("WNU") || strSchCode.startsWith("CSAB") || strSchCode.startsWith("NEU")){%>
    <tr valign="top">
      <td height="22">&nbsp;</td>
      <td>Teller Emp. ID </td>
      <td colspan="2"><input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"  onKeyUp="AjaxMapName(1);"
		onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>">
		<label id="coa_info"></label></td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"> <font color="#0000FF">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("next_day");
if(strTemp != null && strTemp.compareTo("1") == 0)
	strTemp = "checked";
else	
	strTemp = "";
%>        <input type="checkbox" name="next_day" value="1" <%=strTemp%>>

        <font size="3"><strong>Advance payment date (date paid is todays date + 1)</strong></font></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("is_sat_holiday");
if(strTemp != null && strTemp.compareTo("1") == 0)
	strTemp = "checked";
else	
	strTemp = "";
%>        <input type="checkbox" name="is_sat_holiday" value="1" <%=strTemp%>> Is Saturday Holiday

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("is_sun_holiday");
if(strTemp != null && strTemp.compareTo("1") == 0)
	strTemp = "checked";
else	
	strTemp = "";
%>        <input type="checkbox" name="is_sun_holiday" value="1" <%=strTemp%>> Is Sunday Holiday
	  
	  
	  
	  
	  </td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td colspan="2"> <%
if(strPrepareToEdit.compareTo("0") == 0 && iAccessLevel > 1)
{%> <a href='javascript:PageAction("1","");'><img src="../../../images/add.gif" border="0"></a><font size="1">click 
        to add</font> <%}else if(iAccessLevel > 1){%> <a href='javascript:PageAction("2","");'><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel or go previous</font> <%}%> </td>
    </tr>
    <%}//if iAccessLevel > 1%>
    <tr> 
      <td colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>
    <%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table  bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="6" bgcolor="#B9B292" class="thinborder"><div align="center">LIST OF EXISTING CUT-OFF TIME </div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>Specifi Teller</strong></font></td> 
      <td width="15%" height="25" align="center" class="thinborder"><font size="1"><strong>Cutoff Time </strong></font></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">Valid Date Range </font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">Is Advance Payment?</font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">Is Saturday Holiday</font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">Is Sunday Holiday</font></strong></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>Edit</strong></font></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1"><strong>Delete</strong></font></strong></div></td>
    </tr>
    <%
	String[] astrConvertAMPM={" AM"," PM"};
	String strFontColor = null;
	String strEveryDayMsg =null;
 for(int i = 0; i< vRetResult.size(); i += 11){
 	if(vRetResult.elementAt(i + 5) == null){
		strFontColor = "<font color = blue>";
		strEveryDayMsg ="Everyday at ";
	}
	else {
		strFontColor = "";
		strEveryDayMsg ="";
	}	%>
    <tr>
      <td align="center" class="thinborder">
	  <%
	  	if(vRetResult.elementAt(i + 7) == null)
	  		strTemp = "&nbsp;";
		else
			strTemp = vRetResult.elementAt(i + 8)+"("+vRetResult.elementAt(i + 7)+")";
	  %><%=strTemp%>	  </td> 
      <td height="25" align="center" class="thinborder"><%=strFontColor+strEveryDayMsg+(String)vRetResult.elementAt(i+1)+":"+CommonUtil.formatMinute((String)vRetResult.elementAt(i+2))+
	  										astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></font></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%> <%
	  if(vRetResult.elementAt(i + 5) != null){%>
        to <%=(String)vRetResult.elementAt(i + 5)%> <%}%></td>
      <td align="center" class="thinborder">
	  <%if( ((String)vRetResult.elementAt(i + 6)).compareTo("1") == 0){%>
	  <img src="../../../images/tick.gif"><%}else{%>
	  <img src="../../../images/x.gif"><%}%></td>
      <td align="center" class="thinborder"><%if( ((String)vRetResult.elementAt(i + 9)).compareTo("1") == 0){%>
	  <img src="../../../images/tick.gif"><%}else{%>
	  <img src="../../../images/x.gif"><%}%></td>
      <td align="center" class="thinborder"><%if( ((String)vRetResult.elementAt(i + 10)).compareTo("1") == 0){%>
	  <img src="../../../images/tick.gif"><%}else{%>
	  <img src="../../../images/x.gif"><%}%></td>
      <td align="center" class="thinborder"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%> </td>
      <td align="center" class="thinborder"> <%if(iAccessLevel==2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%> </td>
    </tr>
    <%}//end of for loop%>
  </table>
    <%}//end of display list of remittance.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
