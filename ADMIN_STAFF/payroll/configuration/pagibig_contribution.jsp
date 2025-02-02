<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Pag Ibig Contribution</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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

function CancelRecord(){
	location = "./pagibig_contribution.jsp";
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
								"Admin/staff-Payroll-CONFIGURATION-Pagibig Table","pagibig_contribution.jsp");
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
														"pagibig_contribution.jsp");
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION-OTHERS",request.getRemoteAddr(),
														"pagibig_contribution.jsp");
}

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
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prConfig.operateOnPBIGTable(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prConfig.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Pagibig contribution table information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Pagibig contribution table information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Pagibig contribution table information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prConfig.operateOnPBIGTable(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = prConfig.getErrMsg();
}

	vRetResult  = prConfig.operateOnPBIGTable(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prConfig.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./pagibig_contribution.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: PAG-IBIG CONTRIBUTION PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Effectivity Date : </td>
      <td width="74%"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("imp_date");
%> <input name="imp_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.imp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="5%" height="30">&nbsp;</td>
      <td height="30" colspan="2">PAG-IBIG Contribution </td>
      <td height="30"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("tot_contribution");
%> <input name="tot_contribution" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="con_unit">
          <option value="0">Percentage of</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("con_unit");
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Fixed Amount</option>
          <%}else{%>
          <option value="1">Fixed Amount</option>
          <%}%>
        </select> <select name="pecent_">
          <option value="0">N/A</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("pecent_");
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Basic Monthly Salary</option>
          <%}else{%>
          <option value="1">Basic Monthly Salary</option>
          <%}if(strTemp.compareTo("2") == 0) {%>
          <option value="2" selected>Gross Monthly Salary</option>
          <%}else{%>
          <option value="2">Gross Monthly Salary</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" valign="bottom"><strong><u>Contribution Share</u> 
        </strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="7%" height="25">&nbsp;</td>
      <td width="14%">Employer</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("share_e");
%> <input name="share_e" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <font color="#FF0000"><strong><font color="#FF0000" size="1"> 
        <select name="share_e_unit">
          <option value="0">Percentage</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("share_e_unit");
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Fixed Amount</option>
          <%}else{%>
          <option value="1">Fixed Amount</option>
          <%}%>
        </select>
        </font></strong></font></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24">Employee</td>
      <td height="24"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("share_self");
%> <input name="share_self" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="share_self_unit">
          <option value="0">Percentage</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("share_self_unit");
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Fixed Amount</option>
          <%}else{%>
          <option value="1">Fixed Amount</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><u><strong>Maximum Share</strong></u></td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">Employer</td>
      <td height="10"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("max_share_e");
%> <input name="max_share_e" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">Employee</td>
      <td height="10"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("max_share_self");
%> <input name="max_share_self" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="35" colspan="4" align="center"><font size="1"> 
				<%if(iAccessLevel > 1){%>
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
				<!--
          <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
					-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:PageAction('1','');">
        Click to save entries 
        <%}else{%>
        <!--
					<a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
					-->
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:PageAction('2', '');">
        Click to edit event 
        <%}%>
				<!--
          <a href="./pagibig_contribution.jsp"><img src="../../../images/cancel.gif" border="0"></a> 
					-->
			  <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">					
        Click to clear </font>
        <%}%>
			</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2" valign="bottom">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="8" align="center" bgcolor="#B9B292" class="thinborder">PAG-IBIG 
      CONTRIBUTIONS FOR EMPLOYED MEMBERS </td>
    </tr>
    <tr> 
      <td width="14%" height="25" align="center" class="thinborder"><font size="1"><strong>EFFECTIVITY 
      DATE </strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>PAG-IBIG 
      CONTRIBUTION </strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>EMPLOYER 
      SHARE OF CONTRIBUTION</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE 
      SHARE OF CONTRIBUTION</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>MAXIMUM 
      SHARE OF EMPLOYER</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>MAXIMUM 
      SHARE OF EMPLOYEE</strong></font></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">EDIT 
      </font> </strong> </td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <% for(int i =0; i < vRetResult.size(); i += 7){%>
    <tr> 
      <td height="25" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 2)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 5)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}%> &nbsp;</td>
      <td class="thinborder"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
     	<%}else{%>
	  	N/A
	    <%}%>	  </td>
    </tr>
    <%}//end of for loop%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
