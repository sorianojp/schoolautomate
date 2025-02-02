<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
<!--

function FocusStuff()
{
	document.form_.eq_entry.focus();
}

-->
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDEQ, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;

	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Emotional Intelligence Scale-EQ Dimension","eis_eq_dim_entry.jsp");
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
														"Guidance & Counseling","Emotional Intelligence Scale",request.getRemoteAddr(),
														"eis_eq_dim_entry.jsp");
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


	GDEQ GDEq = new GDEQ();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(GDEq.operateOnEQDimension(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = GDEq.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = GDEq.operateOnEQDimension(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = GDEq.getErrMsg();
	}

			
	vRetResult = GDEq.operateOnEQDimension(dbOP, request, 4);
	
	if (vRetResult == null)
		strErrMsg = GDEq.getErrMsg();

%>
<body bgcolor="#D2AE72" onload="FocusStuff()">
<form method="post" action="./eis_eq_dim_entry.jsp" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: EMOTIONAL INTELLIGENCE SCALE : EQ DIMENSION 
          ENTRIES PAGE ::::</strong></font></div></td>
    </tr>
	</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="middle"> 
      <td height="27" colspan="6"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
     <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" height="25">Entry Name </td>
      <td colspan="4" align="center"><div align="left">
          <%
          if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(1);
			else		
	          strTemp = WI.fillTextValue("eq_entry");%>
     <input name="eq_entry" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="32" maxlength="64">
        </div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Display Order</td>
      <td colspan="4" align="center"><div align="left"> 
          <%if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
			else		
				strTemp = WI.fillTextValue("order_no");%>
      <input name="order_no" type="text" size="4" class="textbox"  onKeyUp= 'AllowOnlyInteger("form_","order_no")' onfocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","order_no");style.backgroundColor="white"' value="<%=strTemp%>">
        </div></td>
    </tr>
    <tr> 
      <td height="37">&nbsp;</td>
      <td height="37">&nbsp;</td>
      <td colspan="4"><div align="left"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4" align="center">&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0){%>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#D8D569"> 
      <td height="24" colspan="3"><div align="center"><font color="#000000">LIST 
          OF EQ DIMENSION ENTRIES</font></div></td>
    </tr>
    <tr> 
      <td width="60%" height="25">&nbsp;</td>
      <td colspan="2"><div align="center"><strong><font size="1">OPTIONS</font></strong></div></td>
    </tr>
   <%for (int i = 0; i < vRetResult.size(); i+=3 ){%> 
    <tr> 
      <td height="20"><div align="center"><%=(String)vRetResult.elementAt(i+2)%>.&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+1)%></div></td>
      <td width="15%"><div align="center"><font size="1"><% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>Not authorized to edit<%}%></font></div></td>
      <td width="30%"><div align="center"><font size="1"><% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>Not authorized to delete<%}%></font></div></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>