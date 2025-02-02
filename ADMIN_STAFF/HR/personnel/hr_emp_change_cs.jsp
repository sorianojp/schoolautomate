<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,enrollment.Authentication"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
%>	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
<!--
function viewInfo(){
	document.staff_profile.page_action.value = "0";
	this.SubmitOnce("staff_profile");
}
function CancelRecord(){
	location = "./hr_emp_change_cs.jsp?emp_id="+escape(document.staff_profile.emp_id.value);
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	this.SubmitOnce("staff_profile");
}
function PrepareToEdit(strInfoIndex){
	document.staff_profile.info_index.value = strInfoIndex;
	document.staff_profile.prepareToEdit.value ="1";
	this.SubmitOnce("staff_profile");
}
function EditRecord(){
	document.staff_profile.page_action.value ="2";
	this.SubmitOnce("staff_profile");
}

function DeleteRecord(strInfoIndex){
	document.staff_profile.page_action.value = "0";
	document.staff_profile.info_index.value = strInfoIndex;
	this.SubmitOnce("staff_profile");
}

function ReloadPage(){
	this.SubmitOnce("staff_profile");
}

-->
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Personal Data","hr_emp_change_cs.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_emp_change_cs.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

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
Vector vRetResult = null;
Vector vEmpRec = null;
Vector vEditInfo = null;

boolean bNoError = false;
boolean bolNoRecord = false;
boolean bolFatalErr = false;
String strInfoIndex = WI.fillTextValue("info_index");
String strPageAction = WI.fillTextValue("page_action");
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
Authentication auth = new Authentication();

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0) 	request.setAttribute("emp_id",strTemp);

if (strTemp.length()> 0){
	if (strPageAction.compareTo("0") == 0){
		if (hrPx.operateOnEmpCivilStatus(dbOP,request, 0) != null)
			strErrMsg = " Employee's change in civil Status removed successfully";
		else strErrMsg = hrPx.getErrMsg();		
	}else if (strPageAction.compareTo("1") == 0){
		if (hrPx.operateOnEmpCivilStatus(dbOP,request, 1) != null)
			strErrMsg =  "Employee's change in civil status recorded successfully";
		else strErrMsg = hrPx.getErrMsg();
	}else if (strPageAction.compareTo("2") == 0){
		if (hrPx.operateOnEmpCivilStatus(dbOP,request, 2) != null){
			strErrMsg =  "Employee's change in civil status updated successfully";
			strPrepareToEdit = "";
		}else strErrMsg = hrPx.getErrMsg();
	}
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
	vRetResult = hrPx.operateOnEmpCivilStatus(dbOP,request,4);
	
	if (strPrepareToEdit.compareTo("1") == 0){
		vEditInfo = hrPx.operateOnEmpCivilStatus(dbOP,request,3);
		if (vEditInfo == null) 
			strErrMsg = hrPx.getErrMsg();		
	}
}

String[] astrConvCS = {"","Single","Married","Divorced/Separated","Widow/Widower"};
%>
<body bgcolor="#FFFFFF" >
<form action="./hr_emp_change_cs.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"  bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CHANGE IN CIVIL STATUS RECORDS::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox_noborder" value="<%=strTemp%>" size="24" readonly="true"> </td>
    </tr>
  </table>
<% if (WI.getStrValue(strTemp,"").length() > 0 && vEmpRec != null && vEmpRec.size() > 0){%>
  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><strong><font size="1">Note : These should record 
        the name/status of the employee <font color="#FF0000">before</font> the 
        date of change.</font></strong></td>
    </tr>
    <tr> 
      <td height="25">Current Name</td>
      <td width="82%" colspan="2"><%=WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),1)%></td>
    </tr>
    <tr> 
      <td height="25">First Name </td>
      <td colspan="2"><%if(vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(1));
else strTemp = WI.fillTextValue("fname");%> <input type="text" name="fname" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">Middle Name</td>
      <td colspan="2"> <%if(vEditInfo != null) strTemp = (String)vEditInfo.elementAt(2);
else strTemp = WI.fillTextValue("mname");
%> <input type="text" name="mname" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">Last Name</td>
      <td colspan="2"> <%
if(vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(3));
else strTemp = WI.fillTextValue("lname");
%> <input type="text" name="lname" value="<%=strTemp%>" class="textbox"
  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td width="18%" height="25">Civil Status </td>
      <td colspan="2"><select name="cstatus">
          <option value="1">Single</option>
<% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(5);
   else strTemp = WI.fillTextValue("cstatus");%>		  
          <% if (strTemp.compareTo("2") == 0) {%>
          <option value="2" selected>Married</option>
          <%}else{%>
          <option value="2">Married</option>
          <%} if (strTemp.compareTo("3") == 0) {%>
          <option value="3" selected>Divorced/Separated</option>
          <%}else{%>
          <option value="3" >Divorced/Separated</option>
          <%} if (strTemp.compareTo("4") == 0) {%>
          <option value="4" selected>Widow/Widower</option>
          <%}else{%>
          <option value="4" >Widow/Widower</option>
          <%}
		 if(bolAUF){
		  if (strTemp.compareTo("5") == 0) {%>
          <option value="5" selected>Annuled</option>
          <%}else{%>
          <option value="5">Annuled</option>
          <%} if (strTemp.compareTo("6") == 0) {%>
          <option value="6" selected>Living Together</option>
          <%}else{%>
          <option value="6" >Living Together</option>
          <%}
		 }%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">Date of Change</td>
      <td colspan="2"> <%if(vEditInfo != null) strTemp = (String)vEditInfo.elementAt(4);
	else strTemp = WI.fillTextValue("date_change");%> <input name="date_change" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('staff_profile','date_change','/');" value="<%=strTemp%>" size="15" maxlength="15"> 
        <a href="javascript:show_calendar('staff_profile.date_change',<%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a><font size="1"> 
        (mm/dd/yyy)</font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3"> <% if (iAccessLevel > 1){
		if (vEditInfo  == null){%> <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
			<font size="1">click to save entries</font> 
		<%}else{ %> <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
			<font size="1">click to save changes</font>
			<a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click to cancel and clear entries</font> 
		<%}}%> </td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="95%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B0B08A"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF CHANGES IN STATUS</font></strong></div></td>
    </tr>
    <tr> 
      <td width="25%" height="25" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
      <td width="31%" class="thinborder"><strong><font size="1">OLD NAME</font></strong></td>
      <td width="24%" class="thinborder"><strong><font size="1">DATE OF CHANGE</font></strong></td>
      <td width="20%" colspan="2" class="thinborder"><div align="center"><strong><font size="1">OPTIONS 
          </font></strong></div></td>
    </tr>
    <% for(int i =0 ; i < vRetResult.size(); i+=6){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=astrConvCS[Integer.parseInt((String)vRetResult.elementAt(i+5))]%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),1)%></font>&nbsp;</td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td colspan="2" class="thinborder"> <% if (iAccessLevel > 1) {%> <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <% if (iAccessLevel == 2) {%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"> 
        </a> <%}}%> </td>
    </tr>
    <%}%>
  </table>
<%}// end if vRetResult == null)
} // if (WI.getStrValue(strTemp).lenght() == 0) %>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
