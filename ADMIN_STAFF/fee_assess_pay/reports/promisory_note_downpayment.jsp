<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex, strDeleteInfo) {
	if(strAction == "0") {
		var bolProceed = confirm("Are you sure you want to remove PN of student ?");
		if(!bolProceed)
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.submit();
}
function Cancel()
{
	document.form_.page_action.value = "";
	//fill up empty information.
	document.form_.stud_id.value = "";
	document.form_.amt.value = "";
	document.form_.approve_date.value = "";
	document.form_.due_date.value = "";
	document.form_.approve_id.value = "";

	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud_enrolled.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch2() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_approve_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax.
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, enrollment.FAPromisoryNote ,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PAYMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
			if(iAccessLevel == 0)
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-ADVISING & SCHEDULING"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-OTHER EXCEPTION"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try	{
		dbOP = new DBOperation();
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments",
														"REPORTS",request.getRemoteAddr(),
														"promisory_note_downpayment.jsp");
**/


//end of authenticaion code.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsVMUF  = strSchCode.startsWith("VMUF");
if(strSchCode.startsWith("DBTC"))
	bolIsVMUF = true;

FAPromisoryNote FAPromi = new FAPromisoryNote();
Vector vEditInfo = null;
Vector vRetResult = null;
String strStudMsg = null;

strTemp = WI.fillTextValue("page_action");

String strPermStudID = null;

if(strTemp.length() > 0) {
	if(FAPromi.operateOnPNDP(dbOP, request, Integer.parseInt(strTemp)) != null) {
		strErrMsg = "PN recorded successfully.";
		//if CIT,, i will validate the ID..
		//System.out.println(strSchCode);
		if(strSchCode.startsWith("CIT")) {
			enrollment.RegAssignID regAssignID = new enrollment.RegAssignID();

			if(dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id")) == null) {
				strPermStudID = regAssignID.confirmTempStudEnrollment(dbOP, WI.fillTextValue("stud_id"), (String)request.getSession(false).getAttribute("userId"));
				//System.out.println("I am here: xx Student ID: "+strPermStudID);
			}
			else {
				if(!regAssignID.confirmOldStudEnrollment(dbOP, WI.fillTextValue("stud_id"),(String)request.getSession(false).getAttribute("userId")))
					strPermStudID = null;
				else
					strPermStudID = WI.fillTextValue("stud_id");

			}
			if(strPermStudID == null)
				strErrMsg = "PN is saved. But Enrollment is not validated. Please validate Enrollment manually.";
			else
				strErrMsg = "PN is saved and Enrollment is validated. ID of student after validation: "+strPermStudID;
		}
	}
	else
		strErrMsg = FAPromi.getErrMsg();
}

if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("stud_id").length()>0) {
	vRetResult = FAPromi.operateOnPNDP(dbOP, request, 4);
	if (vRetResult == null && strErrMsg == null )
		strErrMsg = FAPromi.getErrMsg();
}


boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
%>
<form action="./promisory_note_downpayment.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>::::
          PROMISORY NOTE FOR DOWNPAYMENT ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(bolIsVMUF) {
	strTemp = WI.fillTextValue("is_basic");
	if(strTemp.length() > 0)
		strTemp = " checked";
	%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="document.form_.page_action.value='';document.form_.prepareToEdit.value='';document.form_.submit();"> Process Promisory Note for Grade School	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="16%">SY/TERM</td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
<%if(bolIsBasic){%>
<input type="hidden" name="semester" value="1">
<%}else{%>
	  <select name="semester">
	<%
	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp.compareTo("0") ==0){%>
			  <option value="0" selected>Summer</option>
	<%}else{%>
			  <option value="0">Summer</option>
	<%}if(strTemp.compareTo("1") ==0){%>
			  <option value="1" selected>1st Term</option>
	<%}else{%>
			  <option value="1">1st Term</option>
	<%}if(strTemp.compareTo("2") == 0){%>
			  <option value="2" selected>2nd Term</option>
	<%}else{%>
			  <option value="2">2nd Term</option>
	<%}if(strTemp.compareTo("3") == 0){%>
			  <option value="3" selected>3rd Term</option>
	<%}else{%>
			  <option value="3">3rd Term</option>
	<%}%>
		   </select>
<%}//show only if not basic.. %></td>
    </tr>

   	<tr>
   		<td colspan="4" height="10"><hr size="1" color="#0000FF"></td>
   	</tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student ID</td>
      <td width="29%">
<%
	strTemp = WI.fillTextValue("stud_id");
%> <input name="stud_id" type="text" size="16" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
		
		<label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute"></label>
		
	  </td>
      <td width="53%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Amount</td>
      <td>
<%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(0);
else
	strTemp = WI.fillTextValue("amt");%>
      <input name="amt" type="text" class="textbox" value="<%=strTemp%>" size="15" maxlength="32"
	   onKeyUp= 'AllowOnlyFloat("form_","amt")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","amt");style.backgroundColor="white"'>      </td>
      <td>
      </a>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Approved Date</td>
      <td> <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue((String)vRetResult.elementAt(1),"");
else
	strTemp = WI.fillTextValue("approve_date");%>
	<input name="approve_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.approve_date');" title="Click to select date"
        onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
        <img src="../../../images/calendar_new.gif" border="0"></a>      </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>PN Remark </td>
<%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue((String)vRetResult.elementAt(2),"");
else
	strTemp = WI.fillTextValue("pn_remark");%>
	  <td colspan="2">
	  <input name="pn_remark" type="text" size="65" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
  </table>

<%if(iAccessLevel > 1 && WI.fillTextValue("stud_id").length()>0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">

    <tr>
      <td width="18%" height="59">&nbsp;</td>
      <td width="82%" >
	  <%if(vRetResult == null) {%>
	  <a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> <font size="1">click to record entries </font>
	  <%}else{%>
	  <a href='javascript:PageAction("2","");'><img src="../../../images/edit.gif" border="0"></a> <font size="1">click to record update entries </font>
	  &nbsp;&nbsp;&nbsp;
	  <a href='javascript:PageAction("0","");'><img src="../../../images/delete.gif" border="0"></a> <font size="1">click to remove PN </font>
	  <%}%>

	  </td>
    </tr>
  </table>
<%}//if iAccessLevel > 1%>


  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
