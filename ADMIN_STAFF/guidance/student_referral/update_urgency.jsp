<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
	document.form_.reload_parent.value = "0";
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.reload_parent.value = "0";
}
function ReloadParentWnd() {
	if(document.form_.reload_parent.value == "0")
		return;
	window.opener.document.form_.submit();
}
</script>
<body bgcolor="#663300" onLoad="document.form_.urgency_name.focus()" onUnload="ReloadParentWnd();">
<%@ page language="java" import="utility.*,osaGuidance.GDStudReferralFollowUp,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","update_urgency.jsp");
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
														"Guidance & Counseling","student referral",request.getRemoteAddr(),
														"update_urgency.jsp");
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


GDStudReferralFollowUp cmsNew = new GDStudReferralFollowUp();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cmsNew.operateOnUrgency(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cmsNew.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}

vRetResult = cmsNew.operateOnUrgency(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = cmsNew.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = cmsNew.operateOnUrgency(dbOP, request, 3);

Vector vUrgencyOrder = new Vector();
java.sql.ResultSet rs = dbOP.executeQuery("select URGENCY_ORDER from GD_REFERRAL_URGENCY");
while(rs.next())
	vUrgencyOrder.addElement(rs.getString(1));
rs.close();
%>
<form action="./update_urgency.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr>
     <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          URGENCY UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="22%" height="25">Urgency Name </td>
      <td width="73%" height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("urgency_name");
%>	  <input name="urgency_name" type="text"  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="64" size="32"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Urgency Order</td>
      <td>
	  <select name="order">
<%if(vEditInfo != null && vEditInfo.size() > 0){%>
		<option value="<%=vEditInfo.elementAt(2)%>"><%=vEditInfo.elementAt(2)%></option>
<%}
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = "0";
else
	strTemp = WI.fillTextValue("order");

int iDefVal = Integer.parseInt(WI.getStrValue(strTemp, "0"));
for(int i = 1; i < 255; ++i){
	if(vUrgencyOrder.indexOf(Integer.toString(i)) > -1)
		continue;
	if(i == iDefVal)
		strTemp = " selected";
	else	
		strTemp = "";
	%>
	<option value="<%=i%>"<%=strTemp%>><%=i%></option>
<%}%>
	  </select>
<font style="font-size:11px; font-weight:bold; color:#0000FF">(1 is highest)</font>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" align="center"><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="1" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="submit" name="2" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="3" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.urgency_name.value=''"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="4" class="thinborder">
	  <div align="center"><strong><font color="#0000FF">:: URGENCY LIST :: </font></strong></div></td>
    </tr>
    <tr> 
      <td width="9%" class="thinborder">ORDER #.</td>
      <td width="71%" class="thinborder" height="25" align="center">URGENCY NAME </td>
      <td width="10%" class="thinborder">&nbsp;</td>
      <td width="10%" class="thinborder">&nbsp;</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr> 
      <td class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">
        <%if(iAccessLevel > 1){%>
        <input type="submit" name="122" value=" Edit " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
        <%}else{%>&nbsp;<%}%>      </td>
      <td class="thinborder">
        <%if(iAccessLevel ==2 ){%>
        <input type="submit" name="123" value="Delete" style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
        <%}else{%>&nbsp;<%}%>      </td>
    </tr>
<%}%>
  </table>
<%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

<input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">

<input type="hidden" name="reload_parent">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>