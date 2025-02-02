
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/treelinkcss.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value =strInfoIndex;
	
	document.form_.prepareToEdit.value = "";	
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();	
}

function CancelOperation(){
	document.form_.info_index.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();	
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Term Management","manage_term_ess_htc.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"manage_term_ess_htc.jsp");
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
Vector vRetResult = null;
Vector vEditInfo = null;
int iElemCount = 0;

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

String strSYFrom   = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo     = WI.fillTextValue("sy_to");
if(strSYTo.length() ==0)
	strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSemester = WI.fillTextValue("semester");
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");

enrollment.SubjectSection ssExtn = new enrollment.SubjectSection();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(ssExtn.operateOnESSDurationHTC(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = ssExtn.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Information successfully deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Information successfully updated.";	
		strPrepareToEdit = "0";
	}
	
}

if(strPrepareToEdit.equals("1")){
	vEditInfo = ssExtn.operateOnESSDurationHTC(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = ssExtn.getErrMsg();
	else
		vEditInfo.remove(0);
}

vRetResult = ssExtn.operateOnESSDurationHTC(dbOP, request, 4);

String[] astrConvertSem = {"Summer","First Semester", "Second Semester", "Third Semester", "Fourth Semester"};
%>

<form name="form_" action="./manage_term_ess_htc.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          TERM MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="4" height="25"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" >School year : 
       <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strSYFrom%>" size="4" maxlength="4">
        to 
 <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strSYTo%>" size="4" maxlength="4"
	  readonly="yes">
 &nbsp;&nbsp;&nbsp; &nbsp;Term :
 <select name="semester">

 <%=CommonUtil.constructTermList(dbOP, request, strSemester)%>
      </select> 
	  
	  <input type="image" src="../../../images/refresh.gif" border="0">
	  </td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td width="15%" >Term No.</td>
		<%
		strTemp =WI.fillTextValue("term_no");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		%>
        <td width="66%" ><input name="term_no" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","term_no")' value="<%=strTemp%>" size="4" maxlength="4"></td>
        <td width="8%" >&nbsp;</td>
        <td width="8%" >&nbsp;</td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td >Duration From </td>
		<%
		strTemp =WI.fillTextValue("duration_from");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		%>
        <td >
		<input name="duration_from" type="text" size="10" value="<%=WI.getStrValue(strTemp)%>" class="textbox"	  
	  onfocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" readonly="yes">
	  <a href="javascript:show_calendar('form_.duration_from');" title="Click to select date" 
			onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0" /></a>		</td>
        <td >&nbsp;</td>
        <td >&nbsp;</td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td >Duration To</td>
		<%
		strTemp =WI.fillTextValue("duration_to");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		%>
        <td >
		<input name="duration_to" type="text" size="10" value="<%=WI.getStrValue(strTemp)%>" class="textbox"	  
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" readonly="yes">
	  
	  <a href="javascript:show_calendar('form_.duration_to');" title="Click to select date" 
			onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0" /></a>		</td>
        <td >&nbsp;</td>
        <td >&nbsp;</td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td >&nbsp;</td>
        <td >
		<%
		if(strPrepareToEdit.equals("0")){
		%>
		<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save information</font>
		<%}else{%>
		<a href="javascript:PageAction('2','');"><img src="../../../images/edit.gif" border="0"></a>
		<font size="1">Click to edit information</font>
		<%}%>
		<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
		<font size="1">Click to cancel operation</font>		</td>
        <td >&nbsp;</td>
        <td >&nbsp;</td>
    </tr>
  </table>

<%

if(vRetResult != null && vRetResult.size() > 0){
iElemCount = Integer.parseInt((String)vRetResult.remove(0));
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	<tr><td align="center" height="25"><strong>LIST OF TERMS FOR <%=astrConvertSem[Integer.parseInt(strSemester)]%> <%=strSYFrom+"-"+strSYTo%></strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="17%" height="22" align="center" class="thinborder"><strong>TERM NO</strong></td>
		<Td width="37%" align="center" class="thinborder"><strong>DURATION FROM</strong></Td>
		<Td width="29%" align="center" class="thinborder"><strong>DURATION TO</strong></Td>
		<Td width="17%" align="center" class="thinborder"><strong>OPTION</strong></Td>
	</tr>
	<%for(int i = 0; i < vRetResult.size(); i+=iElemCount){%>
	<tr>
	    <td height="22" align="center" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
	    <Td align="center" class="thinborder"><%=vRetResult.elementAt(i+2)%></Td>
	    <Td align="center" class="thinborder"><%=vRetResult.elementAt(i+3)%></Td>
	    <Td align="center" class="thinborder">
		<a href="javascript:PrepareToEdit('<%=vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a>
		&nbsp;
		<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
		</Td>
    </tr>
	<%}%>
</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25" >&nbsp;</td></tr>
</table>


<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
