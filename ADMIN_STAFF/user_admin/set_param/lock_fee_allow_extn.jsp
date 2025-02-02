<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
<!--
function AddRecord(){
	document.form_.print_page.value="";
	document.form_.page_action.value = "1";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.page_action.value="0";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.prepareToEdit.value="1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.reloadPage.value ="1";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.print_page.value="";
	document.form_.page_action.value="2";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./lock_fee_allow_extn.jsp";
}

function ReloadPage()
{
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");
}
-->
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./lock_fee_allow_extn_print.jsp" />
<%	return;} 

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameters","lock_fee_allow_extn.jsp");
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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Set Parameters-Lock Fees",request.getRemoteAddr(),
														null);
}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vEditInfo = null;
Vector vRetResult = null;
SetParameter paramGS = new SetParameter();
strTemp = WI.fillTextValue("page_action");
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if(strTemp.compareTo("0") == 0)// delete.
{
	if(paramGS.operateOnLockFeeAE(dbOP,request,0) != null)
		strErrMsg = "Extension removed successfully.";
	else
		strErrMsg = paramGS.getErrMsg();

}else if (strTemp.compareTo("1")==0){
	if(paramGS.operateOnLockFeeAE(dbOP,request,1) != null)
		strErrMsg = "Extension added successfully.";
	else
		strErrMsg = paramGS.getErrMsg();

}else if (strTemp.compareTo("2")==0){
	if(paramGS.operateOnLockFeeAE(dbOP,request,2) != null){
		strErrMsg = "Extension edited successfully.";
		strPrepareToEdit ="";
	}else
		strErrMsg = paramGS.getErrMsg();
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo =paramGS.operateOnLockFeeAE(dbOP,request,3);
	if (vEditInfo == null) 
		strErrMsg = paramGS.getErrMsg();
}

if (WI.fillTextValue("sy_from").length() > 0){
	vRetResult = paramGS.operateOnLockFeeAE(dbOP,request,4);
	if(vRetResult == null)
	{
		if(strErrMsg == null)
			strErrMsg = paramGS.getErrMsg();
	}
}
String[] astrSemester = {"Summer","1st Sem","2nd Sem"," 3rd Sem"};
String[] astrFeeType =  {"ALL","Tuition","Misc / Other Charges"};

%>
<form name="form_" action="./lock_fee_allow_extn.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SET PARAMETERS - FEES AND ASSESSMENT LOCKING PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="13%"><p>SY - SEM</p></td>
      <td colspan="2"> <% strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
        - 
        <% strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4" readonly="true">
        - 
        <select name="semester">
          <% strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
        &nbsp;&nbsp;<a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" width="71" height="23" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course </td>
      <td colspan="2"> <select name="course_index">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND (IS_VALID=1 or IS_VALID=2) order by course_name asc",	WI.fillTextValue("course_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fee Type</td>
      <td colspan="2"> <select name="fee_type" onChange="ReloadPage()">
          <option value="0">ALL</option>
          <% if ( WI.fillTextValue("fee_type").compareTo("1") == 0){%>
          <option value="1" selected>Tuition</option>
          <%}else{%>
          <option value="1">Tuition</option>
          <%}if (WI.fillTextValue("fee_type").compareTo("2") == 0){%>
          <option value="2" selected>Misc / Other Charges</option>
          <%}else{%>
          <option value="2">Misc / Other Charges</option>
          <%}%>
        </select></td>
    </tr>
    <% if (WI.fillTextValue("fee_type").compareTo("2") == 0) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fee Name</td>
      <td colspan="2"><select name="fee_name">
          <option value=""> ALL </option>
          <%=dbOP.loadCombo("distinct FEE_NAME","fee_name"," from FA_MISC_FEE where IS_DEL=0 and is_valid=1 order by FA_MISC_FEE.fee_name asc", WI.fillTextValue("fee_name"), false)%> </select> </td>
    </tr>
    <%} // end if (WI.fillTextValue("fee_type")%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date To Edit</td>
      <td width="16%"><input name="last_date" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("last_date")%>" size="12" maxlength="12" readonly="yes"></td>
      <td width="66%"><a href="javascript:show_calendar('form_.last_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Requested by</td>
      <td><input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"> 
      </td>
      <td><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a><font size="1">(employee 
        ID only)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Reason </td>
      <td colspan="2"><textarea name="reason" cols="48" rows="3" class="textbox" id="reason" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%= WI.fillTextValue("reason")%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">
	  <% if (WI.fillTextValue("show_all").length() > 0) strTemp = "checked"; else strTemp="";%>
	  <input name="show_all" type="checkbox" id="show_all" value="1" onClick="ReloadPage()" <%=strTemp%>>
        check to show only expired dates</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"> <% if (iAccessLevel > 1) {%> <a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a><font size="1">click 
        to save</font> <%	}// end iAccessLelve%> &nbsp;</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" align="right" bgcolor="#FFFFFF"> &nbsp; <a href="javascript:PrintPg()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
        to print list </font></td>
    </tr>
    <tr bgcolor="#B9B292">
      <td height="25" bgcolor="#B9B292"><div align="center"><strong>DATES ALLOWED 
          TO EDIT FEE MAINTENANCE</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="12%"><div align="center"><strong><font size="1">COURSE </font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">FEE TYPE</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">FEE NAME </font></strong></div></td>
      <td width="12%"><div align="center"><strong><font size="1">REQUESTED BY 
          </font></strong></div></td>
      <td width="12%"><font size="1"><strong>ALLOW DATE EDIT</strong></font></td>
      <td width="31%"><div align="center"><strong><font size="1">REASON</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">DELETE</font></strong></div></td>
    </tr>
    <%for(int i =0;i< vRetResult.size(); i +=14){%>
    <tr> 
      <td align="center" height="25"><font size="1">&nbsp;</font><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"ALL") + WI.getStrValue((String)vRetResult.elementAt(i+5), " :: " ,"","")%></td>
      <td align="center"><font size="1">&nbsp;<%=astrFeeType[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></font></td>
      <td align="center"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8),"ALL")%></font></td>
      <td align="center"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></font></td>
      <td align="center"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"ALL")%></font></td>
      <td align="center"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11))%></font></td>
      <td align="center"><% if (vRetResult.elementAt(i+13) != null){%><a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a><%}%>&nbsp;
      </td>
    </tr>
    <%} // end for loop	%>
  </table>
<%}// end if vRetResult != null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="reloadPage" value="<%=WI.fillTextValue("reloadPage")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
