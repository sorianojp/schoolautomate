<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to remove this information."))
			return false;
	}
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;

}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.ICafeOtherService,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET OTHER SERVICES - Create service",
								"services.jsp");
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
														"Internet Cafe Management",
														"INTERNET OTHER SERVICES",request.getRemoteAddr(),
														"services.jsp");
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
ICafeOtherService othService = new ICafeOtherService();
Vector vEditInfo = null;
Vector vRetResult = null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(othService.operateOnService(dbOP, request, Integer.parseInt(strTemp)) == null) {
		strErrMsg = othService.getErrMsg();		
	}
	else {	
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}
//I have to get here information.
if(strPrepareToEdit.compareTo("0") != 0) {
	vEditInfo = othService.operateOnService(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = othService.getErrMsg();
}
//I have to get here the services created so far.
vRetResult = othService.operateOnService(dbOP, request, 4);
if(strErrMsg == null && vRetResult == null)
	strErrMsg = othService.getErrMsg();



%>
<form action="./services.jsp" method="post" name="form_">
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#A49A6A">
		<td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: INTERNET OTHER SERVICES - CREATE PAGE::::</strong></font></div></td>
	</tr>
	<tr >
		<td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
	</tr>
 </table>
 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
 	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="28%">Service Code</td>
      <td width="70%"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("service_code");
%>	  <input name="service_code" type="text" length="16" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Service Name</td>
      <td> 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("service_name");
%>	  <input name="service_name" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Fee Rate</td>
      <td valign="top">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("unit_price");
%>        <input name="unit_price" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Remarks </td>
      <td valign="top">
<%
//if(vEditInfo != null && vEditInfo.size() > 0)
	//strTemp = (String)vEditInfo.elementAt(6);
//else	
	//strTemp = WI.fillTextValue("remark");
%>	  <textarea name="remark" cols="40" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
-->
  </table>
	
<%if(iAccessLevel > 1){%>	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="30%" height="59">&nbsp;</td>
      <td width="70%" height="59">
	  <%if(strPrepareToEdit.compareTo("0") == 0) {%>
		<input type="submit" name="1_1" value="Save Information" style="font-size:11px; height:26px; background:#CCCCCC; border: 1px solid #FFFF00;" onClick="document.form_.prepareToEdit.value='';document.form_.page_action.value='1';">
	  <%}else{%>
		<input type="submit" name="1_1" value="Edit Information" style="font-size:11px; height:26px; background:#CCCCCC; border: 1px solid #FFFF00;" onClick="document.form_.page_action.value='2';document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>'">
	  <%}%>
	  <font size="1">click to save entries/changes 
	  <a href="./services.jsp"><img src="../../../images/cancel.gif" border="0"></a>Click to cancel/clear entries </font></td>
    </tr>
  </table>
<%}//if iAccessLevel > 1

if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF9F"> 
      <td height="23" colspan="5"><div align="center"><font color="#0000FF"><strong>LIST 
          OF INTERNET OTHER SERVICES</strong></font></div></td>
    </tr>
    <tr> 
      <td width="14%" height="23"><font size="1"><strong>Service Code </strong></font></td>
      <td width="22%"><font size="1"><strong>Service Name </strong></font></td>
      <td width="16%"><font size="1"><strong>Fee Rate Per Unit </strong></font></td>
      <td width="6%">&nbsp;</td>
      <td width="7%">&nbsp;</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size() ; i += 4){%>
   <tr> 
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 2)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3),true)%></font></td>
      <td>&nbsp;
<%if(iAccessLevel > 1){%>
		<input type="submit" name="1_1<%=i%>" value="Edit" style="font-size:11px; height:26px; background:#CCCCCC; border: 1px solid #FFFF00;" onClick="document.form_.page_action.value='';document.form_.prepareToEdit.value='1';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'">
<%}%>  </td>
      <td>&nbsp;
<%if(iAccessLevel == 2){%>
		<input type="submit" name="1_1" value="Delete" style="font-size:11px; height:26px; background:#CCCCCC; border: 1px solid #FFFF00;" onClick="PageAction('0','<%=vRetResult.elementAt(0)%>');">
<%}%>	  </td>
    </tr>
<%}//end of for loop%>
  </table>
<%}//end of if vRetResult is not null.%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>