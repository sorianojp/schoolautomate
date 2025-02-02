<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	if(bolMyHome)
		strColorScheme = CommonUtil.getColorScheme(9);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Set working hours</title>
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
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
.style3 {font-weight: bold}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ViewRecord(){	
	document.form_.prepareToEdit.value = '';
	document.form_.page_action.value="";
 	document.form_.submit();
}
function AddRecord(){
	document.form_.page_action.value = '1';
}

function DeleteRecord(index){
	document.form_.page_action.value = '0';
	document.form_.info_index.value = index;
	document.form_.submit();
}

function PrepareToEdit(index){
	document.form_.page_action.value = '';
	document.form_.prepareToEdit.value = '1';
	document.form_.info_index.value=index;
	document.form_.submit();
}
function EditRecord(index){
	document.form_.page_action.value = '2';
	document.form_.info_index.value=index;
	document.form_.submit();
}
function CancelEdit()
{
	location = "./set_working_cebueasy.jsp?emp_id="+escape(document.form_.emp_id.value);
}
function ReloadPage() {
	document.form_.page_action.value='';
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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

///////////////////////////////////////// End of collapse and expand filter ////////////////////

function focusID() {
	if(document.form_.emp_id)
		document.form_.emp_id.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID()" class="bgDynamic">
<%
	String strErrMsg = "";
	String strTemp = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
	
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	
	boolean bolViewOnly = WI.fillTextValue("view_only").equals("1");
	if(bolViewOnly)
		bolMyHome = true;
//add security here.
	try
	{
		dbOP = new DBOperation(strUserID,
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","set_working_cebueasy.jsp");
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
														"set_working_cebueasy.jsp");	
														
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		iAccessLevel  = 1;
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

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
	WorkingHour whPersonal = new WorkingHour(); 
	enrollment.Authentication authentication = new enrollment.Authentication();

	Vector vEditInfo  = null;
	Vector vRetResult = null;
	Vector vEmpInfo   = null;
		
	String strEmpID = null;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

	strTemp = WI.fillTextValue("emp_id");
	if(strTemp.length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	
	strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0)
	request.setAttribute("emp_id",strTemp);

strEmpID = strTemp;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(whPersonal.operateOnWorkingHourCebuEasy(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = whPersonal.getErrMsg();
	else {
		strErrMsg = "Operation successful.";
		strPrepareToEdit = "0";
	}
}
if(strPrepareToEdit.equals("1")) {
	vEditInfo = whPersonal.operateOnWorkingHourCebuEasy(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = whPersonal.getErrMsg();
}
if(strEmpID != null && strEmpID.length() > 0) {
	vRetResult = whPersonal.operateOnWorkingHourCebuEasy(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = whPersonal.getErrMsg();

  vEmpInfo = authentication.operateOnBasicInfo(dbOP,request,"0");
  if(vEmpInfo == null)
  	strErrMsg = authentication.getErrMsg();
}	

%>	
<form action="./set_working_cebueasy.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      EMPLOYEE WORKING HOUR PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25"><strong><font size="2" >&nbsp;<%=WI.getStrValue(strErrMsg)%>&nbsp;</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<% if (!bolMyHome) {%>
    <tr valign="top"> 
      <td width="2%" height="30" valign="top">&nbsp;</td>
      <td width="14%" height="30">Employee ID</td>
      <td width="19%" height="30" valign="top"><input name="emp_id" type="text" class="textbox" 
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName(1);" value="<%=strEmpID%>" size="16">
	  </td>
      <td width="5%" valign="top"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="14%" valign="top"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewRecord();"></td>
      <td width="46%" valign="top"><label id="coa_info"></label></td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="6" height="25">&nbsp;Employee ID :<strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
      </td>
    </tr>
<%}%>	
  </table>
<% 
if(vEmpInfo !=null){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Employee Name</font></td>
      <td width="56%" height="15"><font size="1">Employee Status</font></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <% strTemp = WI.formatName((String)vEmpInfo.elementAt(1), (String)vEmpInfo.elementAt(2),
									(String)vEmpInfo.elementAt(3),1); %>
      <td colspan="2" valign="top"><strong><%=strTemp%></strong></td>
      <td valign="top"><strong><%=WI.getStrValue((String)vEmpInfo.elementAt(16))%></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td colspan="2"><font size="1">Position</font></td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</font></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <% strTemp = (String)vEmpInfo.elementAt(15);%>
      <td colspan="2" valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
      <%
				if((String)vEmpInfo.elementAt(13) == null)
				strTemp = WI.getStrValue((String)vEmpInfo.elementAt(14));
			else
			{	
				strTemp =WI.getStrValue((String)vEmpInfo.elementAt(13));
				if((String)vEmpInfo.elementAt(14) != null)
					strTemp += "/" + WI.getStrValue((String)vEmpInfo.elementAt(14));
			}
%>
      <td valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
<% if (!bolMyHome) {%> 
    
    <tr>
      <td>&nbsp;</td>
      <td height=20 valign="top"><br>Working Hour Note </td>
      <td height=20 colspan="2">
<%
if(vEditInfo!= null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(2));
else	
	strTemp = WI.fillTextValue("wh_note");
%>	  <textarea name="wh_note" class="textbox" rows="6" cols="75" style="font-size:10px; font-family:Verdana, Arial, Helvetica, sans-serif"><%=strTemp%></textarea>	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height=20 valign="top"><br>Other Note </td>
      <td colspan="2">
<%
if(vEditInfo!= null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(5));
else	
	strTemp = WI.fillTextValue("other_info");
%>	  <textarea name="other_info" class="textbox" rows="3" cols="75" style="font-size:10px; font-family:Verdana, Arial, Helvetica, sans-serif"><%=strTemp%></textarea>	  </td>
    </tr>
		
    <tr> 
      <td>&nbsp;</td>
      <td height=20>Effective Date From: </td>
      <td width="23%">
<%
if(vEditInfo!= null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(3));
else	
	strTemp = WI.fillTextValue("eff_fr");
%>
	  <input name="eff_fr" type="text" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" 
	   onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('form_','eff_fr','/');"
	   onKeyUp= "AllowOnlyIntegerExtn('form_','eff_fr','/')"
	    value="<%=strTemp%>" size="10" maxlength="10">
      <a href="javascript:show_calendar('form_.eff_fr');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td height=30>Effective Date To: 
<%
if(vEditInfo!= null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(4));
else	
	strTemp = WI.fillTextValue("eff_to");
%>
        <input name="eff_to" type="text" class="textbox"  
		onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','eff_to','/');"
		onKeyUP= "AllowOnlyIntegerExtn('form_','eff_to','/')"
		value="<%=WI.getStrValue(strTemp)%>" size="10" maxlength="10"> 
        <a href="javascript:show_calendar('form_.eff_to');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        <font size="1">(leave blank if still applicable)</font></td>
    </tr>
    <tr>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="4" align="center" style="font-weight:9px;">
<%if(iAccessLevel > 1) {%>

	<%if(strPrepareToEdit .equals("0")){%>
    	      <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">Click to save information
	<%}else {%>
    	      <a href="javascript:EditRecord('<%=vEditInfo.elementAt(0)%>');"><img src="../../../images/edit.gif" border="0"></a> Click to edit information &nbsp;&nbsp;
    	      <a href="javascript:CancelEdit();"><img src="../../../images/cancel.gif" border="0"></a> Click to cancel Edit &nbsp;&nbsp;
	<%}%> 
	         
<%}%>		  
          </td>
    </tr>
<%
 } // do not show if my home
%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr bgcolor="#B9B292"> 
        <td height="25" colspan="9" align="center" bgcolor="#B9B292">LIST OF WORKING HOURS FOR ID : <%=WI.fillTextValue("emp_id")%>
		</td>
      </tr>
 </table>
<% if (vRetResult == null) {  %>
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
	  <tr> 
		<td height="25" colspan=4 align="center" class="thinborder"><font size=2><strong> 
		  No Record of Employee Working Hours</strong></font></td>
	  </tr>
	</table>
<% }
else{%>
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
	  <tr style="font-weight:bold"> 
		<td height="22" align="center" class="thinborder" width="15%">Effective Date </td>
	    <td align="center" class="thinborder" width="40%">Working Hour Note </td>
	    <td align="center" class="thinborder" width="30%">Other Note </td>
	    <td align="center" class="thinborder" width="7%">Edit</td>
	    <td align="center" class="thinborder" width="8%">Delete</td>
	  </tr>
<%for(int i = 0; i < vRetResult.size(); i += 8) {%>
	  <tr>
	    <td height="22" align="center" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 3)%> - <%=WI.getStrValue(vRetResult.elementAt(i + 4), "till date")%></td>
	    <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
	    <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 5))%></td>
	    <td class="thinborder">&nbsp;<%if(!bolViewOnly && iAccessLevel > 1){%>
			<a href="javascript:PrepareToEdit('<%=vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a>
		<%}%>
		</td>
	    <td class="thinborder">&nbsp;<%if(!bolViewOnly && iAccessLevel == 2){%>
			<a href="javascript:DeleteRecord('<%=vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
		<%}%>
		</td>
      </tr>
<%}%>
	</table>
<%}

}//do not show if employee ID is missing.%>

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
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
