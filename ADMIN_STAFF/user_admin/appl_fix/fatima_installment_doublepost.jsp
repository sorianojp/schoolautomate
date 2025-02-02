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
function ReloadPage()
{
	document.form_.submit();
}
function ShowResult() {
	document.form_.show_result.value = "1";
	this.ReloadPage();
}
function selAll() {
	var iMaxDisp = document.form_.max_disp.value;
	var bolIsChecked = document.form_.sel_all.checked;
	var obj;
	for(var i = 0; i < iMaxDisp; ++i) {
		eval('obj=document.form_.pmt_'+i);
		if(!obj)
			continue;
		obj.checked = bolIsChecked;
	}
}
function SetSYTerm(strSYFrom, strSYTo, strSemester) {
	document.form_.sy_from.value = strSYFrom;
	document.form_.sy_to.value = strSYTo;
	document.form_.semester[document.form_.semester.selectedIndex].value = strSemester;
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Program fix-Fix Missing Oth school Debit Entry",
								"fatima_installment_doublepost.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"fatima_installment_doublepost.jsp");
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
Vector vRetResult = null; Vector vSYTermSummary = null;
AllProgramFix progFix = new AllProgramFix();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(progFix.operateOnInstallmentFeeDoublePostFatima(dbOP, request, 1) == null)
		strErrMsg = progFix.getErrMsg();
}

//if(WI.fillTextValue("show_result").length() > 0) {
	vRetResult = progFix.operateOnInstallmentFeeDoublePostFatima(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = progFix.getErrMsg();
	else
		vSYTermSummary = (Vector)vRetResult.remove(0);
//}	

%>


<form name="form_" action="./fatima_installment_doublepost.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MISSING OTHER SCHOOL FEE DEBIT ENTRY ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">SY/Term</td>
      <td width="42%"> <%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else
	strTemp = WI.fillTextValue("sy_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
        <%
if(request.getParameter("sy_to") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
else
	strTemp = WI.fillTextValue("sy_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
		<select name="semester" onChange="ReloadPage();">
          <%
if(request.getParameter("semester") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
else
	strTemp = WI.fillTextValue("semester");

if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td width="44%">List of SY-Term having Double Posting: 
	  <%if(vSYTermSummary == null || vSYTermSummary.size() == 0) {%>
	  	NONE
	  <%}else{
	  	for(int i =0; i < vSYTermSummary.size(); i += 3) {%>
				<br>
			<a href="javascript:SetSYTerm('<%=vSYTermSummary.elementAt(i)%>','<%=Integer.parseInt((String)vSYTermSummary.elementAt(i)) + 1%>','<%=vSYTermSummary.elementAt(i + 1)%>');">[ <%=vSYTermSummary.elementAt(i)%> - <%=vSYTermSummary.elementAt(i + 1)%> (<%=vSYTermSummary.elementAt(i + 2)%>)]</a>
	  <%}
	  }%>
	  </td>
    </tr>
    
    <tr>
      <td height="25"></td>
      <td colspan="3"><label id="fee_selected"></label></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>&nbsp;</td>
      <td><a href="javascript:ShowResult();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
		<td align="right">
		Note: It does not Balance forward automatically. Please balance forward manually after clicking fix double posting.
		
		<input type="button" name="_" value="Click to Fix Double Posting" onClick="document.form_.page_action.value='1';document.form_.submit();"></td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="7" align="center" bgcolor="#3366FF" class="thinborder"><font color="#FFFFFF"><b> 
        ::: LIST OF OTHER SCHOOL FEE NOT HAVING DEBIT ENTRY ::: </b></font></td>
    </tr>
    <tr bgcolor="#FFFFAF" style="font-weight:bold;" align="center">
      <td width="5%" class="thinborder">Count</td>
      <td width="10%" class="thinborder">Student ID </td>
      <td width="20%" class="thinborder">Student Name </td> 
      <td width="35%" height="25"  class="thinborder">Fee Name</td>
      <td width="10%" class="thinborder">Plan Name</td>
      <td width="15%" class="thinborder">Amount Posted </td>
	  <td width="5%" class="thinborder">&nbsp;</td>
    </tr>
<%
int iMaxDisp = 0;
Vector vTemp = new Vector();
for(int i = 0; i < vRetResult.size(); i += 6) {%>
    <tr>
      <td class="thinborder"><%=i/6 + 1%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" align="center">
<%if(vTemp.indexOf(vRetResult.elementAt(i + 1)) > -1){%>
		  <input type="checkbox" name="pi_<%=iMaxDisp++%>" value="<%=vRetResult.elementAt(i)%>" checked="checked">	  
<%}else{%>
	&nbsp;
<%}
vTemp.addElement(vRetResult.elementAt(i + 1));
%>
	  </td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
  </table>
<%}//only if vRetResult is not null
%>
<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="show_result">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
