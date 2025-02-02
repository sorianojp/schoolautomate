<%@ page language="java" import="utility.*, java.util.Vector, payroll.PayrollConfig" %>
<%
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll late conversion setting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
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
	if(!confirm("Continue deleting? "))
		return;
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./dtr_late_conversion.jsp";
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolForPeriod = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Late Conversion Setting","dtr_late_conversion.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolForPeriod = (readPropFile.getImageFileExtn("LATE_SETTING","5")).equals("5");
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
														"dtr_late_conversion.jsp");	
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

PayrollConfig pConfig = new PayrollConfig();
Vector vRetResult = null;
Vector vEditInfo = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
int i = 0;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(pConfig.operateOnLateConversion(dbOP, request, Integer.parseInt(strTemp)) != null){
		strErrMsg = "Operation Successful";
		strPrepareToEdit = "";
	}else
		strErrMsg = pConfig.getErrMsg();
 }
 
 if (strPrepareToEdit.length() > 0){
	vEditInfo = pConfig.operateOnLateConversion(dbOP, request, 3);
	if (vEditInfo == null)
		strErrMsg = pConfig.getErrMsg();
}
 
	vRetResult = pConfig.operateOnLateConversion(dbOP, request, 4);
%>
<form action="./dtr_late_conversion.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      LATE CONVERSION ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>Effective Date </strong></u></td>
      <td height="30">
			<%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(5);
				else
					strTemp = WI.fillTextValue("date_from");
			%>
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../images/calendar_new.gif" border="0"></a> <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"></a></td>
    </tr>
    <tr>
      <td height="12" colspan="3"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>Late TIME IN (in mins)</strong></u></td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(1);
				else
					strTemp = WI.fillTextValue("late_mins");
			%>
      <td><u><strong>
        <input name="late_mins" type="text" size="4" maxlength="3" 
				 value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </strong></u></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="21%" height="25"><u><strong>Minutes to deduct </strong></u></td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(2);
				else
					strTemp = WI.fillTextValue("conversion");
			%>
      <td width="75%">
			<input name="conversion" type="text" size="4" maxlength="3" 
	  	value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" 
			class="textbox" onBlur="style.backgroundColor='white'">			</td>
    </tr>
   	<%if(!bolForPeriod){%>
	  <tr>
      <td height="25">&nbsp;</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strTemp = (String)vEditInfo.elementAt(4);
				else
					strTemp = WI.fillTextValue("login_set");
			%>
      <td height="25"><u><strong>Login Set </strong></u></td>
      <td><select name="login_set">
        <option value="0">First Login</option>
        <%if(strTemp.equals("1")){%>
        <option value="1" selected>Second Login</option>
        <%}else{%>
        <option value="1">Second Login</option>
        <%}%>
      </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
	    <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" align="center">
			<%if(iAccessLevel > 1){%>
			<font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
Click to save entries
<%}else{%>
<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:EditRecord();">
Click to edit event
<%}%>
<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
Click to clear </font>
			<%}%>
			</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292" class="thinborder">&nbsp;</td>
    </tr>
    
    <tr>
      <td height="26" align="center" class="thinborder"><font size="1"><strong>EFFECTIVE DATE </strong></font></td>
      <td align="center" class="thinborder"><strong><font size="1">LATE DURATION </font></strong></td>
      <td align="center" class="thinborder"><strong><font size="1">LATE CONVERSION </font></strong></td>
      <td align="center" class="thinborder"><strong><font size="1">LOGIN SET </font></strong></td>
      <td align="center" class="thinborder"><strong><font size="1"><strong>OPTION</strong></font></strong></td>
    </tr>
    
    <% for(i =0; i < vRetResult.size(); i += 12){%>
    <tr> 
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
			%>		
      <td width="26%" height="25" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
			%>				
			<td width="19%" align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
			%>				
      <td width="19%" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+4);
				if(strTemp.equals("1"))
					strTemp = "2nd login";
				else if(strTemp.equals("2"))
					strTemp = "Whole Cut Off";
				else 
					strTemp = "1st Login";					
			%>
      <td width="19%" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
       <td width="17%" height="25" align="center" class="thinborder">&nbsp; 
	  <%if(iAccessLevel > 1){%>
		<input type="button" name="edit2" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
	  <%} 
		if(iAccessLevel == 2){%>
      <input type="button" name="delete" value="Delete" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>');">
      <%}%>    </td>
    </tr>
    <%}%>
  </table>	
	<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
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