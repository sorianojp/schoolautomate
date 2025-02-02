<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = '';
	document.form_.prepareToEdit.value = '1';

	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to delete this record?"))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function CancelRecord() {
	location = "./manage_cit_syrange.jsp";
}
function ReloadPage() {
	document.form_.page_action.value = '';
	document.form_.prepareToEdit.value = '';

	document.form_.info_index.value = '';
	document.form_.submit();
}

</script>


<body bgcolor="#D2AE72" onLoad="document.form_.range_fr.focus()">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	Vector vEditInfo = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-Manage SY Range","manage_cit_syrange.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"manage_cit_syrange.jsp");
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


FAFeeMaintenance fm = new FAFeeMaintenance();

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(fm.operateOnCITSYRange(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = fm.getErrMsg();
	else {
		strErrMsg = "Successful.";
		strPrepareToEdit="0";
	}
}
if(strPrepareToEdit.compareTo("1") ==0) {
	vEditInfo = fm.operateOnCITSYRange(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = fm.getErrMsg();
}

//get all levels created.
Vector vRetResult = fm.operateOnCITSYRange(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = fm.getErrMsg();

dbOP.cleanUP();
%>

<form name="form_" method="post" action="./manage_cit_syrange.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MANAGE SY RANGE INFORMATION ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Applicable School Year  </td>
      <td>
<%
strTemp = WI.fillTextValue("eff_fr_sy");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

%>	  <input name="eff_fr_sy" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	  
	  <strong><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">click 
        to refresh page</font></strong>
	  </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25" width="19%">SY Range From:        </td>
      <td width="78%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("range_fr");
%>	
		  <input name="range_fr" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">SY Range To <font size="1">&nbsp;</font> </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("range_to");
%>	
	  <input name="range_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2"> 
<%
if(strPrepareToEdit.compareTo("0") == 0) {%>
        <a href="javascript:PageAction('1','');"><img src="../../../images/add.gif" border="0"></a><font size="1">click 
        to add</font> 
<%}else{%>
        <a href="javascript:PageAction('2','<%=vEditInfo.elementAt(0)%>');"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel or go previous</font> 
        <%}%>      </td>
    </tr>
<%}%>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8"><div align="center">LIST OF EXISTING SY RANGE</div></td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td width="35%"><div align="center"><font size="1"><strong>SY RANGE FROM</strong></font></div></td>
      <td height="25" width="35%"><div align="center"><font size="1"><strong>SY RANGE TO</strong></font></div></td>
      <td width="18%"><font size="1">Applicable SY</font></td>
      <td align="center" width="6%"><font size="1"><strong>EDIT</strong></font></td>
      <td align="center" width="6%"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
<%
strTemp = "";
for(int i = 0 ; i< vRetResult.size() ; i += 5) {
if(strTemp.length() == 0 && vRetResult.elementAt(i +3).equals("0"))
	strTemp = " bgcolor='#cccccc'";%>
    <tr <%=strTemp%>>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td>
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
      <%}else{%>Not authorized<%}%></td>
	  <td>&nbsp;
	  <%if(iAccessLevel ==2 ){%>
	  	<%if(strTemp.length() == 0) {%>
		  	<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
    	<%}%>
	  <%}else{%>Not authorized<%}%></td>
    </tr>
    <%
	}//end of displaying levels
}//end of displaying existing question level
%>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0"></tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<!-- all hidden fields go here -->
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
</body>
</html>
