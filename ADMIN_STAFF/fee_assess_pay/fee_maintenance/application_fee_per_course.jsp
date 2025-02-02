<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
	location = "./application_fee_per_course.jsp";
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
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-Manage Application Fee","application_fee_per_course.jsp");
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
														"application_fee_per_course.jsp");
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
	if(fm.operateOnApplicationFee(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = fm.getErrMsg();
	else {
		strErrMsg = "Successful.";
		strPrepareToEdit="0";
	}
}
if(strPrepareToEdit.compareTo("1") ==0) {
	vEditInfo = fm.operateOnApplicationFee(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = fm.getErrMsg();
}

//get all levels created.
Vector vRetResult = fm.operateOnApplicationFee(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = fm.getErrMsg();

%>

<form name="form_" method="post" action="./application_fee_per_course.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MANAGE APPLICATION FEE INFORMATION ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25" width="13%">Course</td>
      <td width="84%">
	  <select name="course_index" style="font-size:11px;background:#DFDBD2;">
          <option value="">&lt;Select Any&gt;</option>
          <%=dbOP.loadCombo("course_index","course_name,course_code"," from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 order by course_name asc", WI.fillTextValue("course_index"), false)%> 
        </select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Amount</td>
      <td>
	  <input name="amount" type="text" size="16" value="<%=WI.fillTextValue("amount")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Name </td>
      <td>
	  <select name="fee_" style="font-size:11px;background:#DFDBD2;">
          <option value="">&lt;Select Any&gt;</option>
          <%=dbOP.loadCombo("distinct fa_oth_sch_fee.fee_name","fa_oth_sch_fee.fee_name"," from fa_oth_sch_fee where IS_VALID=1 and fee_name like 'application%' order by fa_oth_sch_fee.fee_name", WI.fillTextValue("fee_"), false)%> 
        </select>
	  </td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2"> 
        <a href="javascript:PageAction('1','');"><img src="../../../images/add.gif" border="0"></a><font size="1">click to add</font>	  </td>
    </tr>
<%}%>
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4" class="thinborder"><div align="center">LIST OF EXISTING APPLICATION FEE </div></td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td class="thinborder" width="50%"><font size="1"><strong>COURSE</strong></font></td>
      <td class="thinborder" width="20%">FEE NAME</td>
      <td height="25" class="thinborder" width="20%"><font size="1"><strong>AMOUNT</strong></font></td>
      <td class="thinborder" width="10%"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
<%
for(int i = 0 ; i< vRetResult.size() ; i += 6) {%>
    <tr>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"<b>ALL COURSES</b>")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<b>ALL</b>")%></td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">
	  <%if(iAccessLevel ==2 ){%>
		  	<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
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
<%
dbOP.cleanUP();
%>