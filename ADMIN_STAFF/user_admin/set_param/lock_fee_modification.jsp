<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	this.SubmitOnce("form_");
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameters","lock_fee_modification.jsp");
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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Set Parameters-Lock Fees",request.getRemoteAddr(),
														null);
}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
SetParameter paramGS = new SetParameter();
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = paramGS.viewFeeModificationInfo(dbOP,request);
	if(vRetResult == null){
		if(strErrMsg == null)
			strErrMsg = paramGS.getErrMsg();
	}
}

%>
<form name="form_" action="./lock_fee_modification.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SET PARAMETERS - FEES AND ASSESSMENT LOCKING PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;</font> </td>
      <td height="25" colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="20%">Offering SY - Sem</td>
      <td> <% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
        - 
        <% strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly>
        - 
        <select name="semester">
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
        </select> &nbsp;&nbsp;<a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" width="71" height="23" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date modified</td>
      <td width="75%"><a href="javascript:show_calendar('form_.last_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <input name="last_date" type="text" class="textbox" id="last_date"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("last_date")%>" size="12" maxlength="12" readonly="yes">
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to <a href="javascript:show_calendar('form_.last_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <input name="last_date2" type="text" class="textbox" id="last_date2"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("last_date")%>" size="12" maxlength="12" readonly="yes">
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        (leave it empty to view for complete sy-term)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fee type</td>
      <td>
<%
strTemp = WI.fillTextValue("fee_type");
if(strTemp.compareTo("1") == 0 || request.getParameter("fee_type") == null)
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="radio" name="fee_type" value="1"<%=strTemp%>>Tuition &nbsp; 
<%
strTemp = WI.fillTextValue("fee_type");
if(strTemp.compareTo("2") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="radio" name="fee_type" value="2"<%=strTemp%>>Misc Fee (and oth charges) &nbsp; 
<%
strTemp = WI.fillTextValue("fee_type");
if(strTemp.compareTo("3") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="radio" name="fee_type" value="3"<%=strTemp%>>Other school fee</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.compareTo("1") == 0 || request.getParameter("show_con") == null)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="radio" name="show_con" value="1"<%=strTemp%>>Show Only deleted fees &nbsp; 
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.compareTo("2") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="radio" name="show_con" value="2"<%=strTemp%>>Show only edited fees &nbsp; 
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.compareTo("3") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="radio" name="show_con" value="3"<%=strTemp%>>Show both (edited and deleted)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" border='0'></a><font size="1">click 
        to show modification information.</font></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
     <tr bgcolor="#B9B292" class="thinborder">
      <td height="25" class="thinborder"><div align="center"><strong>FEE MODIFIED BY INFORMATION</strong></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="34%" height="25" class="thinborder"><div align="center"><font size="1"><strong>CORUSE/MAJOR</strong></font></div></td>
      <td width="39%" class="thinborder"><div align="center"><font size="1"><strong>FEE 
          NAME</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>DATE 
          MODIFIED</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>MODIFIED 
          BY ID</strong></font></div></td>
    </tr>
    <%
for(int i =0;i< vRetResult.size(); i +=4){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
