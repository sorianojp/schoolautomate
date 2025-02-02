<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Step Increment Setting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	var vProceed = confirm('Delete record?');
	if(vProceed){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce("form_");
	}
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./step_increment_set.jsp";
}

function ReloadPage()
{
	document.form_.page_reloaded.value = "1";
	document.form_.print_page.value= "";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="cola_ecola_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-COLA","step_increment_set.jsp");
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

//end of authenticaion code.
Vector vRetResult = null;
Vector vEditInfo = null;

PayrollConfig pr = new PayrollConfig();

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strTemp2 = null;
String[] astrUnit = {"day(s)", "week(s)", "month(s)", "year(s)"};
if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (pr.operateOnSalaryStepMgmt(dbOP,request,0) != null){
			strErrMsg = "Record removed successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (pr.operateOnSalaryStepMgmt(dbOP,request,1) != null){
			strErrMsg = "Record posted successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (pr.operateOnSalaryStepMgmt(dbOP,request,2) != null){
			strErrMsg = " Record updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}
}
if (strPrepareToEdit.length() > 0 && WI.fillTextValue("page_reloaded").equals("0")){
	vEditInfo = pr.operateOnSalaryStepMgmt(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = pr.getErrMsg();
}
vRetResult = pr.operateOnSalaryStepMgmt(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}


%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./step_increment_set.jsp" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: SETTING FOR STEP INCREMENT PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><font size="1"><a href="./step_increment_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="17%">Effectivity Date</td>
	  <%
	    if( vEditInfo!=null && vEditInfo.size() > 0) 
		  	strTemp= (String)vEditInfo.elementAt(2);
		else 
			strTemp= WI.fillTextValue("effective_date");
	  %> 
      <td width="79%"> 
	 <input name="effective_date" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly> 
      <a href="javascript:show_calendar('form_.effective_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" alt="Click to set " border="0"></a></td>
    </tr>    
    <tr>
      <td height="18">&nbsp;</td>
      <td>Condition Setting: </td>
	  <%
	    if( vEditInfo!=null && vEditInfo.size() > 0) 
		  	strTemp= (String)vEditInfo.elementAt(3);
		else 
		  	strTemp = WI.fillTextValue("condition_setting");
	  %>
      <td>
	  <select name="condition_setting" onChange="ReloadPage();">
        <option value="0">General Setting</option>
        <%if(strTemp.equals("1")){%>
        <option value="1" selected>Set One-by-one</option>
        <%}else{%>
        <option value="1">Set One-by-one</option>
        <%}%>
      </select>	  </td>
    </tr>
	<%if(WI.fillTextValue("condition_setting").equals("1")){%>
    <tr>
      <td height="18">&nbsp;</td>
	  <%
	    if( vEditInfo!=null && vEditInfo.size() > 0) 
		  	strTemp= (String)vEditInfo.elementAt(1);
		else 
			strTemp = WI.fillTextValue("step");
	  %>
      <td>Salary Step</td>
      <td><select name="step">
        <%for(int i = 2; i < 11;i++){%>
        <%if(strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected>Step <%=i%></option>
        <%}else{%>
        <option value="<%=i%>">Step <%=i%></option>
        <%}%>
        <%}%>
      </select></td>
    </tr>
	<%}%>
	<tr>
	  <td height="18">&nbsp;</td>
	  <td height="18" colspan="2">Condition for step increment: </td>
    </tr>
	<%
	 if(WI.fillTextValue("condition_setting").equals("1"))
	 	strTemp = "Length of service: ";
	 else
	 	strTemp = "Every ";
	%>
	<tr>
	  <td height="18">&nbsp;</td>
	  <td height="18" colspan="2">
	  	<%=strTemp%>
	  	&nbsp;
	    <%
	    if( vEditInfo!=null && vEditInfo.size() > 0) 
		  	strTemp= (String)vEditInfo.elementAt(4);
		else 
			strTemp = WI.fillTextValue("eligibility");
		%>
	  	<input name="eligibility" type= "text" class="textbox" value="<%=strTemp%>" size="10" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','eligibility');style.backgroundColor='white'"
		onKeyUp="AllowOnlyInteger('form_','eligibility')">
	  <%
	    if( vEditInfo!=null && vEditInfo.size() > 0) 
		  	strTemp= (String)vEditInfo.elementAt(5);
		else 
		  	strTemp = WI.fillTextValue("eligibility_unit");
	  %>		
	    <select name="eligibility_unit">
          <option value="0">day(s)</option>
          <%
		  if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>week(s)</option>
          <%}else{%>
          <option value="1">week(s)</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>month(s)</option>
          <%}else{%>
          <option value="2">month(s)</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>year(s)</option>
          <%}else{%>
          <option value="3">year(s)</option>
          <%}%>
      </select></td>
    </tr>
	<tr>
      <td height="18">&nbsp;</td>
      <td height="18">Apply Setting: </td>
      <td height="18">	
	  <%
	    if( vEditInfo!=null && vEditInfo.size() > 0) 
		  	strTemp= (String)vEditInfo.elementAt(6);
		else 
			strTemp = WI.getStrValue(WI.fillTextValue("apply_setting"),"0");
		if(strTemp.compareTo("1") == 0) 
			strTemp = " checked";
		else	
			strTemp = "";
	  %>
        <input type="radio" name="apply_setting" value="1" <%=strTemp%>>
Apply when eligible &nbsp;&nbsp;
<%
if(strTemp.length() == 0) 
	strTemp = " checked";
else
	strTemp = "";
%>
<input type="radio" name="apply_setting" value="0" <%=strTemp%>>
Apply Manually</td>
	</tr>
    <tr>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="35">&nbsp;</td>
      <td height="35" colspan="2" align="center" valign="bottom"> 
        <% if (iAccessLevel > 1) {
	      if (strPrepareToEdit.length() == 0) {%>
        <a href="javascript:AddRecord()"><img src="../../../../images/save.gif" border="0"></a><font size="1">click 
          to save entries </font> 
        <%}else{%>
        <a href="javascript:EditRecord()"><img src="../../../../images/edit.gif" width="40" height="26"  border="0"></a><font size="1">click 
          to change entries </font> 
        <%} // end else if vEditInfo == null %>
        <a href="javascript:CancelRecord()"><img src="../../../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel/clear entries</font> 
        <%} // end iAccessLevel > 1%>      </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
 <% if (vRetResult != null) {%>
 
  <table width="100%" border="1" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <%if(false){%>
    <tr> 
      <td height="25" colspan="5" align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0" ></a>click 
          to print table</font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292"><strong>SETTING FOR SALARY STEP INCREMENT </strong></td>
    </tr>
    <tr> 
      <td width="15%" height="24" align="center"><font size="1"><strong>EFFECTIVITY 
      DATE</strong></font></td>
      <td width="51%" align="center"><font size="1"><strong>STEP INCREMENT CONDITION </strong></font></td>
      <td align="center"><strong><font size="1">APPLY SETTING</font> </strong></td>
      <td colspan="2" align="center"><strong><font size="1">OPTIONS</font></strong></td>
    </tr>
    <% 
	for (int i = 0; i< vRetResult.size() ; i+=7) {%>
    <tr> 
      <td height="30"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
	<%
		strTemp = (String)vRetResult.elementAt(i+3);
	 strTemp2 = "Increase ";
	 if(strTemp.equals("1"))
	 	strTemp2 += "to step "+ (String)vRetResult.elementAt(i+1) + " after ";
	 else
	 	strTemp2 += "every ";
		
		strTemp2 += (String)vRetResult.elementAt(i+4);
		strTemp = (String)vRetResult.elementAt(i+5);
		
		strTemp2 += "&nbsp;" + astrUnit[Integer.parseInt(strTemp)];	
	%>		  
      <td valign="top"><font size="1">&nbsp;<%=strTemp2%> </font></td>
	  <%
	  	strTemp = (String)vRetResult.elementAt(i+6);
	  	if(strTemp.equals("1"))
			strTemp = "Auto Apply";
		else
			strTemp = "Apply Manually";
	  %>
      <td width="16%">&nbsp;<font size="1"><%=strTemp%></font></td>
      <td width="9%" align="center">  
        <% if (iAccessLevel > 1) {%>
        <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <%}else{%>
        NA 
        <%}%>      </td>
      <td width="9%" align="center">  
        <% if (iAccessLevel == 2) {%>
        <a href='javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%>
        NA 
        <%}%>      </td>
    </tr>
    <%}// end for loop%>
  </table>
<%}//end vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_reloaded" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
