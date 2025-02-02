<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Schedule of deductions</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	if(document.form_.dType.selectedIndex == 4) {
		document.form_.reloaded.value = "1";
		document.form_.submit();
		return;
	}
	if(document.form_.reloaded.value == "1") {
		document.form_.reloaded.value = "";
		document.form_.submit();
		return;
	}
}
function CancelRecord(){
	location = "./schedule_deduction.jsp";
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Schedule deduction","schedule_deduction.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"schedule_deduction.jsp");
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vEditInfo  = null;
	Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prConfig.operateOnSchDeduction(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prConfig.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Schedule deduction information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Schedule deduction information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Schedule deduction information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prConfig.operateOnSchDeduction(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = prConfig.getErrMsg();
}

	vRetResult  = prConfig.operateOnSchDeduction(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prConfig.getErrMsg();

Vector vBenefitInfo = null;
if(WI.fillTextValue("dType").compareTo("5") == 0 ){
	prConfig.getBenefitInfo(dbOP, true);
	if(vBenefitInfo == null)
		strErrMsg = prConfig.getErrMsg();
}	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./schedule_deduction.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: SCHEDULE OF DEDUCTION PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>DEDUCTION TYPE</td>
      <td colspan="2"> <select name="dType" onChange="ReloadPage();">
          <option value="1">Tax</option>
<%
strTemp = WI.fillTextValue("dType");
if(strTemp.compareTo("2") == 0) {%>
          <option value="2" selected>SSS Contribution</option>
<%}else{%>
          <option value="2">SSS Contribution</option>
<%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>PAG-IBIG Contribution</option>
<%}else{%>
          <option value="3">PAG-IBIG Contribution</option>
<%}if(strTemp.compareTo("4") == 0){%>
          <option value="4" selected>Philhealth Contribution</option>
<%}else{%>
          <option value="4">Philhealth Contribution</option>
<%}if(strTemp.compareTo("5") == 0){%>
          <option value="5" selected>Benefits</option>
<%}else{%>
          <option value="5">Benefits</option>
<%}if(strTemp.compareTo("7") == 0){%>
          <option value="7" selected>GSIS</option>
<%}else{%>
          <option value="7">GSIS</option>
<%}%>        

<%if(bolIsSchool){
if(strTemp.compareTo("6") == 0){%>
          <option value="6" selected>PERAA</option>
<%}else{%>
          <option value="6">PERAA</option>
<%}
}%>
</select>
        <font size="1">&nbsp; </font></td>
    </tr>
<%
if(WI.fillTextValue("dType").compareTo("5") == 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>BENEFIT TYPE</td>
      <td colspan="2">
        <select name="b_index">
	<%=dbOP.loadCombo("BENEFIT_INDEX","BENEFIT_NAME +' ('+SUB_TYPE+')'",
	" from HR_BENEFIT_INCENTIVE join HR_PRELOAD_BENEFIT_TYPE on (HR_PRELOAD_BENEFIT_TYPE.BENEFIT_TYPE_INDEX = "+
     "HR_BENEFIT_INCENTIVE.BENEFIT_TYPE_INDEX) where IS_INCENTIVE = 0 and COVERAGE_UNIT=2"+
        " and IS_BENEFIT = 0 and BENEFIT_NAME not in ('loans','loan') and is_valid = 1 and is_del = 0 order by benefit_name",WI.fillTextValue("b_index"),false)%>
        </select>
		</td>
    </tr>
<%}%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%">Salary Period</td>
      <td  colspan="2"><select name="sal_p">
          <option value="0">Every Salary Period </option>
<%
strTemp = WI.fillTextValue("sal_p");
if(strTemp.equals("1")) {%>
      <option value="1" selected>1st</option>
<%}else{%>
     <option value="1">1st</option>
<%}if(strTemp.equals("2")) {%>
     <option value="2" selected>2nd (Last Period)</option>
<%}else{%>
     <option value="2">2nd (Last Period)</option>
<%}%>
     </select>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td width="64%" height="25">
				<%if(iAccessLevel > 1){%>
			<font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        Click to save entries 
        <%}else{%>
        <!--<a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> -->
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:PageAction('2', '');">				
        Click to edit event 
        <%}%>
        <!--
				<a href="./schedule_deduction.jsp"><img src="../../../images/cancel.gif" border="0"></a> 
				-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">				
        Click to clear </font>
				<%}%></td>
      <td width="19%" height="25">
	  <%if(false){%>
	  <font size="1"><img src="../../../images/print.gif">click to print</font>
	  <%}%>
	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="24" colspan="3" align="center" bgcolor="#B9B292" class="thinborder">LIST OF 
          SALARY DEDUCTION FOR TAX/CONTRIBUTION</td>
    </tr>
    <tr> 
      <td width="70%" height="25" align="center" class="thinborder"><font size="1"><strong>DEDUCTION 
      TYPE </strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>SALARY PERIOD</strong></font></td>
      <td width="13%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
<% for(int i =0; i < vRetResult.size(); i += 5){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%>
	  <%
	  if(vRetResult.elementAt(i + 2) != null){%>
	  ::: <%=(String)vRetResult.elementAt(i + 2) + " ("+(String)vRetResult.elementAt(i + 3)+")"%>
	  <%}%>	  </td>
      <td class="thinborder" align="center">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" align="center">&nbsp;
	  <%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
	  <%}else{%>
	  	N/A
	  <%}%>	  </td>
    </tr>
<%}%>	
  </table>
<%}%>	
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
   <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="reloaded" value="<%=WI.fillTextValue("reloaded")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
