<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	
	this.SubmitOnce('form_');
}
function FocusID() {
	document.form_.stud_id.focus();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
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

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceVairable,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Payments-ASSESSMENT-set_tuition_per_student.","set_tuition_per_student.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"set_tuition_per_student.jsp");
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
Vector vRetResult = null;
Vector vStudInfo  = null;//current enrollment information.
	
FAFeeMaintenanceVairable ffmv = new FAFeeMaintenanceVairable();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(ffmv.operateOnTuitionFeePerStud(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = ffmv.getErrMsg();
	else	
		strErrMsg = "Operation is successful.";
}
if(WI.fillTextValue("stud_id").length() > 0) {
	vRetResult = ffmv.operateOnTuitionFeePerStud(dbOP, request, 4);
}
%>
<form action="./set_tuition_per_student.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENT ENTRY INFORMATION UPDATE PAGE (FOR FIXED TUTION FEE) ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" > <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" >Student ID :</td>
      <td width="21%" ><input type="text" name="stud_id" size="18" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:350px;"></label>	
	  
	  </td>
      <td width="64%" ><input type="button" name="_" value="Refresh Page" onClick="document.form_.page_action.value='';document.form_.submit();">
	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td>School Year/Term</td>
      <td colspan="2"> 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> 
		<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
<%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
  if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("1") ==0){%>
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
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Amount</td>
      <td colspan="2" style="font-weight:bold; color:#0000FF"><input name="new_amount" type="text" size="18" value="" autocomplete="off"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','new_amount');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','new_amount');" class="textbox_bigfont">
<%
strTemp = WI.fillTextValue("type_of_fee"); //System.out.println(strTemp);
if(strTemp.length() == 0 || strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = ""; 
%>	  
	  <input type="radio" name="type_of_fee" value="1"<%=strErrMsg%>>Total TF only &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="type_of_fee" value="2"<%=strErrMsg%>>Total TF(includes Misc and OC)
	  
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td><a href="javascript:PageAction('1','','');"><img src="../../../images/save.gif" border="0"></a></td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0) {%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFDF" style="font-weight:bold;" align="center"> 
      <td width="15%" height="25" class="thinborder">SY :: Term</td>
      <td width="9%" class="thinborder">Posted By</td>
      <td width="9%" class="thinborder">Amount</td>
      <td width="10%" class="thinborder">Type of Fee </td>
      <td width="10%" class="thinborder">Remove</td>
    </tr>
    <%
	String[] astrConvertTerm = {"SU","FS","SS","TS"};
	String[] astrConvertYr = {"N/A","1st","2nd","3rd","4th","5th","6th","7th","8th","9th"};
	String[] astrTypeOfFee = {"","TF","TF+MISC+OC"};
 for(int i = 0; i < vRetResult.size(); i += 7){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%> - <%=astrConvertTerm[Integer.parseInt((String)vRetResult.elementAt(i + 2))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=astrTypeOfFee[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%></td>
      <td class="thinborder">&nbsp;
	  <%if(iAccessLevel == 2) {%>
	  	<a href="javascript:PageAction(0,'<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
	  <%}%>	  </td>
    </tr>
    <%}%>
  </table>
<%}//if vRetResult != null
%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="79%" height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
