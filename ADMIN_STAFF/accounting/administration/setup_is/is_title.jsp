<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Income Statement Title.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>

</head>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to delete this record."))
			return;
	}
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>

<%@ page language="java" import="utility.*,Accounting.IncomeStatement,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-IncomeStatement-Set up Income Statement title","is_title.jsp");
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
														"Accounting","IncomeStatement",request.getRemoteAddr(), 
														"is_title.jsp");	
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

IncomeStatement IS = new IncomeStatement();
Vector vRetResult  = null;
Vector vEditInfo   = null;

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(IS.operateOnISTitle(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = IS.getErrMsg();
	else {
		strErrMsg = "Operation Successful.";
		strPrepareToEdit = "0";
	}
}


	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = IS.operateOnISTitle(dbOP, request,3);
	if(vEditInfo == null) {
		strErrMsg = IS.getErrMsg();
		strPrepareToEdit = "0";
	}
}
//view all. 
vRetResult = IS.operateOnISTitle(dbOP, request,4);
if(vRetResult == null && strErrMsg == null) 
	strErrMsg = IS.getErrMsg();

%>

<body bgcolor="#D2AE72">
<form action="./is_title.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#B5AB73">
    <tr>
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INCOME STATEMENT TITLE MANAGEMENT PAGE :::: </strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2"> <a href="ddc_main.htm"></a>&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="21%" height="25">&nbsp;&nbsp;Income Statement Title </td>
      <td width="79%"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("title");
%> <input type="text" name="title" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="256"></td>
    </tr>
    
    <%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="40">&nbsp;</td>
      <td><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "<%=(String)vEditInfo.elementAt(0)%>");'><img src="../../../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./is_title.jsp"><img src="../../../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
    <%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" bgcolor="#DDDDEE" class="thinborder"><div align="center"><font color="#FF0000"> 
          <strong>LIST OF EXISTING INCOME STATEMENT TITLE</strong></font></div></td>
    </tr>
    <tr style="font-weight:bold" align="center"> 
      <td width="55%" height="25" class="thinborder" style="font-size:9px;">Income Statement Title</td>
      <td width="15%" class="thinborder" style="font-size:9px;">Edit</td>
      <td class="thinborder" width="15%" style="font-size:9px;">Delete</td>
      <td class="thinborder" width="15%" style="font-size:9px;">Setup Income Statement</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 2){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="center">&nbsp;
<%if(iAccessLevel > 1 && !vRetResult.elementAt(i).equals("1")){%>
          <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" border="0"></a> 
<%}%>
	  </td>
      <td class="thinborder" align="center"> &nbsp;
<%if(iAccessLevel == 2 && !vRetResult.elementAt(i).equals("1")){%>
          <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" border="0"></a> 
<%}%>
          </td>
      <td class="thinborder" align="center"><a href="./is_page1.jsp?title_index=<%=(String)vRetResult.elementAt(i)%>">Set up</a></td>
    </tr>
<%}%>
  </table>
<%}//only if vRetResult is not null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    
    <tr>
      <td height="27" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="27" bgcolor="#B5AB73">&nbsp;</td>
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