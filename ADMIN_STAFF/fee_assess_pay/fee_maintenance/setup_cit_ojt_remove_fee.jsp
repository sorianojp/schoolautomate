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
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-setup ojt","setup_cit_ojt_remove_fee.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"setup_cit_ojt_remove_fee.jsp");
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

FAFeeMaintenance feeM = new FAFeeMaintenance();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(feeM.operateOnCITExcludeMiscFeeOJT(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = feeM.getErrMsg();
	else 
		strErrMsg = "Operation Successful.";		
}

Vector vRetResult = feeM.operateOnCITExcludeMiscFeeOJT(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = feeM.getErrMsg();

%>
<form name="form_" action="./setup_cit_ojt_remove_fee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: Define MiscellaneousFee to Exclude if Enrolled only in 1 OJT Subject ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">  
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%">SY-Term</td>
      <td width="87%">
	<%
String strSYFrom = WI.fillTextValue("sy_from");
	if(strSYFrom.length() ==0)
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
   <%
	strTemp = request.getParameter("sy_to");
	if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  
	  -
	  
<%
String strSemester = WI.fillTextValue("semester");

if(strSemester.length() == 0) 
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");	

if(strSemester == null)
	strSemester = "";
%>
	  <select name="semester">
          <option value="0">Summer</option>
<%
if(strSemester.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%
if(strSemester.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
        </select>
	  <input type="submit" name="122_" value="&nbsp;&nbsp;View Excluded Misc Fee&nbsp;&nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value=''">	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:11px; font-weight:bold; color:#0000FF">
<%
String strMiscOC = null;
if(WI.fillTextValue("is_misc").equals("1")) {//OC.
	strMiscOC = "1";

	strTemp = " checked";
	strErrMsg = "";
}
else {
	strMiscOC = "0";

	strTemp   = "";
	strErrMsg = " checked";
}
%>
	  <input type="radio" name="is_misc" value="0" <%=strErrMsg%> onChange="document.form_.page_action.value='';document.form_.submit()"> Show Misc Fee 
	  <input type="radio" name="is_misc" value="1" <%=strTemp%> onChange="document.form_.page_action.value='';document.form_.submit()"> Show OC 
	  </td>
    </tr>
    <tr>  
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%">Fee Name</td>
      <td width="87%">
	  	<select name="fee_name">
<%
strTemp = " from fa_misc_fee where is_valid = 1 and misc_other_charge = "+strMiscOC+
	" and not exists (select * from FA_STUD_ASSESSMENT_EXCLUDE_MISC_OJT where MISC_FEE_NAME = fee_name and is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester+") order by fa_misc_fee.fee_name";
%>					
<%=dbOP.loadCombo("distinct fa_misc_fee.fee_name","fa_misc_fee.fee_name",strTemp, WI.fillTextValue("fee_name"), false)%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(iAccessLevel > 1) {%>
	  <input type="submit" name="12" value="&nbsp;&nbsp;Save Information&nbsp;&nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
<%}%>	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#dddddd"><div align="center"><strong>::: List of YLFI Fee::: </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
    <tr> 
      <td width="88%" height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center">&nbsp;Fee Name </td>
      <td width="12%" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;Delete</td>
    </tr>
    
    <%
for(int i=0; i<vRetResult.size(); i+=2){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">
		<input type="submit" name="12" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'">	  </td>
    </tr>
    <%}%>
  </table>
<%}//end of display. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
