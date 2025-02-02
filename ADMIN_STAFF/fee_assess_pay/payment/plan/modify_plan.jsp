<%@ page language="java" import="utility.*,enrollment.FAStudMinReqDP,java.util.Vector" %>
<%
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchoolCode == null)
		strSchoolCode = "";

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Assessment-Modify Plan","modify_plan.jsp");
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
														"Fee Assessment & Payments","Assessment",request.getRemoteAddr(),
														null);

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
Vector vRetResult   = new Vector();
String strStudName  = null;
String strStudIndex = null;
boolean bolIsEnrolled = false;
FAStudMinReqDP faMinDP = new FAStudMinReqDP(dbOP);

if(WI.fillTextValue("stud_id").length() > 0) {
	String strSQLQuery = "select user_index, fname, mname, lname from user_table where id_number = '"+WI.fillTextValue("stud_id")+"' and is_valid = 1";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strStudName = WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4);
		strStudIndex = rs.getString(1);
	}
	else {
		strErrMsg = "ID Does not exist.";
	}
	rs.close();
	if(strStudIndex != null) {
		strSQLQuery = "select cur_hist_index from stud_curriculum_hist where user_index = "+strStudIndex+" and is_valid = 1 and sy_from = "+
			WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null) 
			strErrMsg = "Student is not enrolled in current sy/term.";
		else	
			bolIsEnrolled = true;
	}
}
if(bolIsEnrolled) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(faMinDP.updatePlanOfAEnrolledStudent(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = faMinDP.getErrMsg();
		else	
			strErrMsg = "Plan Information changed successfully.";
	}
	vRetResult = faMinDP.updatePlanOfAEnrolledStudent(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = faMinDP.getErrMsg();
	
}


if(strErrMsg == null)
	strErrMsg = "";
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_action.value="";
	document.form_.submit();
}
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud_enrolled.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
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
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus()">
<form name="form_" action="./modify_plan.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>:::: MODIFY PLAN ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="3"><%=strErrMsg%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term</td>
      <td>
	  <%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) 
	  	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	  %>
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) 
	  	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	  %>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = WI.getStrValue((String)request.getSession(false).getAttribute("cur_sem"));
if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>	  
	  
	  
	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="top">
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" height="25">Student ID &nbsp; </td>
      <td width="30%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox_bigfont"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="4%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="10%"><font size="1"> <a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0"></a>
        </font></td>
      <td width="39%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
  </table>
 <%if(strStudIndex != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" class="thinborderBOTTOM" align="center" style="font-weight:bold">PLAN INFORMATION </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Student name</td>
      <td width="82%"><strong><%=strStudName%></strong></td>
    </tr>
<%
if(vRetResult != null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Plan Subscribed  </td>
      <td><%=vRetResult.elementAt(0)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Installment Fee Charged </td>
      <td><%=WI.getStrValue(vRetResult.elementAt(1), "<font size='3'><b>Not Charged</b></font>")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td style="font-size:9px;"><a href="javascript:PageAction('0');"><img src="../../../../images/delete.gif" border="0"></a>Click to remove plan of student.</td>
    </tr>
<%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td style="font-size:12px; font-weight:bold; color:#FF0000">Student does not have any plan</td>
    </tr>
<%}%>
    <tr>
      <td colspan="3"><hr size="1" color="#0000FF"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>New Plan </td>
      <td><select name="new_plan" style="font-size:10px">
          <%=dbOP.loadCombo("plan_ref","PLAN_NAME,INSTALLMENT_FEE"," from FA_STUD_PLAN_FATIMA where is_valid = 1 order by PLAN_NAME", WI.fillTextValue("new_plan"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td style="font-size:9px;"><a href="javascript:PageAction('1');"><img src="../../../../images/update.gif" border="0"></a>Click to update plan of student.</td>
    </tr>
  </table>
<%}%>

   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	<td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="prev_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
