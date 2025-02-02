<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Step Increment Table</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
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
function clearFields(){
	for(var i =1; i< 11; ++i)
	{
		eval('document.form_.step'+i+'.value =""');
	}
	return;
}
function CancelRecord(){
	location = "./step_increment_table.jsp";
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
								"Admin/staff-Payroll-Configuration-Step Increment Table Configuration","step_increment_table.jsp");
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
														"step_increment_table.jsp");
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prConfig.operateOnSalaryStep(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prConfig.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Step Increment table information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Step Increment table information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Step Increment table information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prConfig.operateOnSalaryStep(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = prConfig.getErrMsg();
}

	vRetResult  = prConfig.operateOnSalaryStep(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prConfig.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="step_increment_table.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: STEP INCREMENT TABLE PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><font size="1"><a href="./step_increment_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td>Effectivity Date</td>
      <td width="81%"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("effective_date");
if(strTemp.length() == 0 && vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(1);
%>
	 <input name="effective_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      <a href="javascript:show_calendar('form_.effective_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td width="15%">Salary Grade </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(2);
		else	
		  	strTemp= WI.fillTextValue("salary_grade");
	  %>
      <td height="24">        
		<select name="salary_grade">
		<% for(int i = 1;i < 41;i++){
		if(strTemp.equals(Integer.toString(i))){%>
		  <option value="<%=i%>" selected>Salary Grade <%=i%></option>
		<%}else{%>
		  <option value="<%=i%>">Salary Grade <%=i%></option>
		<%}%>
		<%}%>
        </select>	  </td>
    </tr>
    
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><a href="javascript:clearFields();">CLEAR ALL FIELDS</a></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 1 </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(3);
		else	
		  	strTemp= WI.fillTextValue("step1");
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";
	  %>		  
      <td height="10"><input name="step1" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step1');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step1');style.backgroundColor='white'">     </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 2 </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(4);
		else	
		  	strTemp= WI.fillTextValue("step2");	  	
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";
	  %>		  	  
      <td height="10"><input name="step2" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step2');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step2');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 3 </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(5);
		else	
		  	strTemp= WI.fillTextValue("step3");	  	
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";
	  %>		  	  
      <td height="10"><input name="step3" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step3');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step3');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 4 </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(6);
		else	
		  	strTemp= WI.fillTextValue("step4");	  	
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";
	  %>		  	  
      <td height="10"><input name="step4" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step4');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step4');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 5 </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(7);
		else	
		  	strTemp= WI.fillTextValue("step5");	  	
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";
	  %>		  	  
      <td height="10"><input name="step5" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step5');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step5');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 6 </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(8);
		else	
		  	strTemp= WI.fillTextValue("step6");	  	
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";			
	  %>	  
      <td height="10"><input name="step6" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step6');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step6');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 7 </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(9);
		else	
		  	strTemp= WI.fillTextValue("step7");	  	
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";			
	  %>	  
      <td height="10"><input name="step7" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step7');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step7');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 8 </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(10);
		else	
		  	strTemp= WI.fillTextValue("step8");	  	
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";			
	  %>	  
      <td height="10"><input name="step8" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step8');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step8');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 9 </td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(11);
		else	
		  	strTemp= WI.fillTextValue("step9");	  	
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";			
	  %>	  
      <td height="10"><input name="step9" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step9');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step9');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">STEP 10</td>
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(12);
		else	
		  	strTemp= WI.fillTextValue("step10");	  	
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		if(strTemp.equals("0"))
			strTemp = "";			
	  %>	  
      <td height="10"><input name="step10" type="text" size="10" maxlength="10" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>"
		  onKeyUp="AllowOnlyFloat('form_','step10');" style="text-align : right"
		  onBlur="AllowOnlyFloat('form_','step10');style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td height="35" colspan="2" valign="bottom">
			<%if(iAccessLevel > 1){%>
			<font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">				
        Click to save entries 
        <%}else{%>
        <!--
				<a href='javascript:PageAction(2, "");'><img src="../../../../images/edit.gif" border="0"></a> 
				-->
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '');">
        Click to edit event 
        <%}%>				
        <!--
				<a href="step_increment_table.jsp"><img src="../../../../images/cancel.gif" border="0"></a> 
				-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
        Click to clear </font>
				<%}%>
			</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
	  <td height="10" valign="bottom">&nbsp;</td>
      <!--
	  <td height="10" valign="bottom"><div align="right"><font size="1"><img src="../../../../images/print.gif" ><font size="1">click 
      to print</font></font></div></td>
	  -->
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="13" align="center" bgcolor="#B9B292" class="thinborder"><strong>STEP INCREMENT TABLE EFFECTIVE <%=WI.formatDate((String)vRetResult.elementAt(1),6)%></strong></td>
    </tr>
    
    <tr>
      <td height="26" align="center" class="thinborder"><font size="1"><strong>SALARY GRADE </strong></font></td>
      <td align="center" class="thinborder">STEP 1 </td>
      <td height="28" align="center" class="thinborder">STEP 2 </td>
      <td align="center" class="thinborder">STEP 3 </td>
      <td align="center" class="thinborder">STEP 4 </td>
      <td align="center" class="thinborder">STEP 5 </td>
      <td align="center" class="thinborder">STEP 6 </td>
      <td align="center" class="thinborder">STEP 7 </td>
      <td align="center" class="thinborder">STEP 8 </td>
      <td align="center" class="thinborder">STEP 9 </td>
      <td align="center" class="thinborder">STEP 10 </td>
      <td colspan="2" align="center" class="thinborder"><strong><font size="1"><strong>OPTIONS</strong></font></strong></td>
    </tr>
    <% for(int i = 0; i < vRetResult.size(); i += 13){%>
    <tr> 
      <td width="6%" height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+3);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
	  %>
	  <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+4);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
	  %>
      <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+5);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
	  %>
      <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+6);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
	  %>
      <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+7);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
	  %>
      <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+8);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
	  %>
      <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+9);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
	  %>
      <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
	  %>
      <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
		if(strTemp.equals("0"))
			strTemp = "";		
	  %>
      <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = CommonUtil.formatFloat(strTemp,true);
		strTemp = WI.getStrValue(strTemp,"");
		if(strTemp.equals("0"))
			strTemp = "";
	  %>
      <td width="8%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td width="7%" height="25" align="center" class="thinborder"> 
	  <%if(iAccessLevel > 1){%>
	  	<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" border="0"></a>
	    <%}else{%>
	  	&nbsp;
	    <%}%>        </td>
      <td width="7%" align="center" class="thinborder"> 
	  <%if(iAccessLevel == 2){%>
	  	<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" border="0"></a>
	    <%}else{%>
	  	&nbsp;
	    <%}%>        </td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
