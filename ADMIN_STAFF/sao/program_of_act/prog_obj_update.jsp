<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
boolean bolIsCIT = strSchoolCode.startsWith("CIT");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
function CloseWindow()
{
	window.opener.document.form_.submit()
	window.opener.focus();
	self.close();
}
function AddRecord() {
	document.form_.add_record.value = "1";
	document.form_.delete_record.value = "";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function DeleteRecord(strInfoIndex) {
	document.form_.add_record.value = "";
	document.form_.delete_record.value = "1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ProgramOfActivity"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-PROGRAM OF ACTIVTIES","prog_obj_update.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","PROGRAM OF ACTIVTIES",request.getRemoteAddr(),
														"prog_obj_update.jsp");
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
Vector vObjective = null;//It has all information.
ProgramOfActivity POA = new ProgramOfActivity();
//collect information for view.
if(WI.fillTextValue("add_record").compareTo("1") == 0){
	if(POA.operateOnObjective(dbOP, request, 1) == null)
		strErrMsg = POA.getErrMsg();
	else
		strErrMsg = "Objective added successfully.";
}
if(WI.fillTextValue("delete_record").compareTo("1") == 0){
	if(POA.operateOnObjective(dbOP, request, 0) == null)
		strErrMsg = POA.getErrMsg();
	else
		strErrMsg = "Objective removed successfully.";
}

	vObjective = POA.operateOnObjective(dbOP, request,4);

dbOP.cleanUP();


	  if(bolIsCIT)
	  	strTemp = "Theme";
	  else
	  	strTemp = "Objective";
	 
%>
<form action="./prog_obj_update.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          PROGRAM OF ACTIVITIES - UPDATE <%=strTemp.toUpperCase()%> PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="5%" height="25">&nbsp;</td>
      <td width="95%"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0"></a></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>	  
      <td width="16%"><%=strTemp%> Number </td>
      <td width="79%"><select name="obj_sl_no">
          <option>1</option>
<%
int iObjSlNo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("obj_sl_no"),"0"));
for(int i = 2; i< 50; ++i){
	if(iObjSlNo == i){%>
          <option selected><%=i%></option>
    <%}else{%>
	      <option><%=i%></option>
<%}
}%>        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"><%=strTemp%></td>
      <td valign="top"><textarea name="objective" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=WI.fillTextValue("objective")%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
  </table>



  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="21%" height="25">&nbsp;</td>
      <td width="79%" height="25"><a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click
        to save entries</font></td>
    </tr>
  </table>

<%if(vObjective != null && vObjective.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="24" colspan="2" bgcolor="#B9B292"><div align="center"><strong>LIST
          OF <%=strTemp.toUpperCase()%> FOR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></div></td>
    </tr>
    <%for(int i = 0 ; i < vObjective.size() ; i +=3){%>
    <tr>
      <td width="90%"><%=(String)vObjective.elementAt(i + 1)%>. <%=(String)vObjective.elementAt(i + 2)%></td>
      <td width="10%"><a href='javascript:DeleteRecord("<%=(String)vObjective.elementAt(i)%>");'>
	  	<img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>

 <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="add_record">
<input type="hidden" name="delete_record">
<input type="hidden" name="info_index">

<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
</form>
</body>
</html>
