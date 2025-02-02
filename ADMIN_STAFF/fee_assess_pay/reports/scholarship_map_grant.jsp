<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function DeleteMap(strInfoIndex) {
	if(!confirm('Do you want to delete this information.'))
		return;
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = '0';
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS(map_grant)","scholarship_map_grant.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"scholarship_map_grant.jsp");
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

//get different grant here.
FeeExtraction feeEx = new FeeExtraction();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(feeEx.operateOnMapGrant(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = feeEx.getErrMsg();
	else	
		strErrMsg = "Request processed successfully.";
}
Vector vRetResult    = feeEx.operateOnMapGrant(dbOP, request, 4);
Vector vToMap = feeEx.operateOnMapGrant(dbOP, request, 5);

if(vRetResult == null && strErrMsg == null)
	strErrMsg = feeEx.getErrMsg();
if(vToMap == null && strErrMsg == null)
	strErrMsg = feeEx.getErrMsg();
%>

<form name="form_" method="post" action="./scholarship_map_grant.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          MAP GRANT NAME::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%" height="25">School year /Term</td>
      <td width="78%" height="25"> <%
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
	  readonly="yes"> <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
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
        <input name="image" type="image" src="../../../images/refresh.gif">        </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Grant To Map </td>
      <td height="25">
<%if(vToMap != null && vToMap.size() > 0) {%>
		<select name="grant_name">
		<%while(vToMap.size() > 0) {%>
			<option value="<%=vToMap.elementAt(0)%>"><%=vToMap.remove(0)%></option>
		<%}%>
		</select>
<%}else{%>No data found for mapping.<%}%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Mapped Name</td>
      <td>
		<input name="map_name" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("map_name")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <input type="submit" name="Save" value="Save Information" onClick="document.form_.page_action.value='1'">
	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" align="center" style="font-size:11px; font-weight:bold;">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="3" align="center" style="font-size:11px; font-weight:bold;" bgcolor="#CCCCCC" class="thinborder">Grant Name Already Mapped</td>
    </tr>
    <tr style="font-weight:bold">
      <td width="45%" height="25" class="thinborder">Grant Name </td>
      <td width="41%" class="thinborder">Mapped Name </td>
      <td width="14%" class="thinborder">Delete</td>
    </tr>
<%while(vRetResult.size() > 0){%>
    <tr>
      <td height="25" class="thinborder"><%=vRetResult.remove(1)%></td>
      <td class="thinborder"><%=vRetResult.remove(1)%></td>
      <td class="thinborder"><a href="javascript:DeleteMap('<%=vRetResult.remove(0)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
<%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
