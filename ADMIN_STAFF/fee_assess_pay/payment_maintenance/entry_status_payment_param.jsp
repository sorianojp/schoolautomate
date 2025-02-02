<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	if(strAction == "1") 
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Required Payment Parameter","entry_status_payment_param.jsp");
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
														"Fee Assessment & Payments","PAYMENT MAINTENANCE",request.getRemoteAddr(),
														"entry_status_payment_param.jsp");
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

FAPmtMaintenance FA = new FAPmtMaintenance();
Vector vRetResult = null;

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(FA.operateOnEntryStatPmt(dbOP, request,Integer.parseInt(strTemp)) == null)
		strErrMsg = FA.getErrMsg();
	else {	
		if(strTemp.compareTo("0") == 0)
			strErrMsg = "Information removed successfully.";
		else	
			strErrMsg = "Information added successfully.";
	}
}
//I have to get all information.
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = FA.operateOnEntryStatPmt(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = FA.getErrMsg();
}
%>
<form name="form_" action="./entry_status_payment_param.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ENTRY STATUS PAYMENT PARAMETER PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="12%">SY/TERM</td>
      <td width="42%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   readonly="yes">
        &nbsp;&nbsp;<select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
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
        </select></td>
      <td width="43%"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">click 
        to refresh the page display</font></td>
    </tr>
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("sy_to").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="24">&nbsp;</td>
      <td>Course</td>
      <td><select name="course">
	  <option value="">ALL</option>
<%=dbOP.loadCombo("course_index","course_name"," from course_offered where is_del=0 and is_valid=1 order by course_name asc", 
			WI.fillTextValue("course"), false)%> 
	  </select></td>
    </tr>
    <tr> 
      <td width="3%" height="24">&nbsp;</td>
      <td width="21%">Student Entry Status</td>
      <td width="76%"><select name="stud_stat">
          <option value="">ALL</option>
<%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=1 order by status asc", 
			WI.fillTextValue("course"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Misc/Other Fees</td>
      <td><font size="1"> 
        <select name="fee_name">
          <%=dbOP.loadCombo("distinct fee_name","fee_name",
		  " from fa_misc_fee join fa_schyr on (fa_schyr.sy_index = fa_misc_fee.sy_index) where is_del=0 and is_valid=1 and sy_from = "+
		  	WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
			" and is_handson=0 order by fa_misc_fee.fee_name asc", WI.fillTextValue("fee_name"), false)%> 
        </select>
        (except hands on)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Implementation Type </td>
      <td height="25"><font size="1"> 
        <select name="imp_type">
          <option value="0">Discount</option>
<%
strTemp = WI.fillTextValue("imp_type");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Charged</option>
<%}else{%>
          <option value="1">Charged</option>
<%}%>        </select>
        <input name="amt" type="text" size="8" value="<%=WI.fillTextValue("amt")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        <select name="amt_unit">
          <option value="0">specific amount</option>
<%
strTemp = WI.fillTextValue("amt_unit");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>percentage (%)</option>
<%}else{%>
          <option value="1">percentage (%)</option>
<%}%>          
        </select>
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td></td>
      <td>&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td></td>
      <td> <a href='javascript:PageAction("","1");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to add entry</font> 
		<a href='./entry_status_payment_param.jsp<%="?sy_from="+WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+
		"&semester="+WI.fillTextValue("semester")%>'> 
        <img src="../../../images/cancel.gif" border="0" name="hide_save"></a> 
        <font size="1">click to clear or cancel entry</font></td>
    </tr>
    <%}//if iAccessLevel > 1%>
  </table>
<%}//if(WI.fillTextValue("sy_to").length() > 0)

if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center"><strong><font color="#FFFFFF">::: 
          LIST OF ADDITIONAL PAYMENT/DISCOUNT DETAILS :::</font></strong></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr > 
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>COURSE</strong></font></div></td>
      <td width="3%" class="thinborder"><div align="center"><font size="1"><strong>SEM</strong></font></div></td>
      <td width="10%" height="26" class="thinborder"><div align="center"><font size="1"><strong>STUDENT 
          ENTRY STATUS </strong></font></div></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>FEE NAME</strong></font></div></td>
      <td width="20%" align="center" class="thinborder"><strong><font size="1">IMPLEMENTATION TYPE</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
      <!--      <td width="10%" align="center"><font size="1"><strong>DELETE</strong></font></td>-->
    </tr>
<%
for(int i = 0 ; i< vRetResult.size() ; i += 6)
{%>
    <tr > 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"ALL")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"ALL")%></td>
      <td height="25" class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"ALL")%> </div></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td align="center" class="thinborder"> 
        <%if(iAccessLevel == 2){%> 
	  <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a> 
      <%}else{%> <font size="1">Not authorized </font> <%}%> </td>
    </tr>
    <%
	}//end of displaying the entries in loop.
%>
  </table>
<%}//end of displaying the created exising payment schedule entries.
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="">
<input type="hidden" name="page_action" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>