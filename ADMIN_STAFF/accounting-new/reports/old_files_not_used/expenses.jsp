<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Expense Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.report_expenses.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.Report.ReportIncome,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-REPORTS","income.jsp");
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
														"Accounting","REPORTS",request.getRemoteAddr(),
														"income.jsp");
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
Vector vSummary = null;

ReportIncome RI = new ReportIncome();
if(WI.fillTextValue("date_from").length() > 0)
{
	if(WI.fillTextValue("report_for").compareTo("1") ==0)
		vSummary = RI.summaryIncomeExpenseNonAcad(dbOP,request);
	else
		vSummary = RI.summaryIncomeExpenseAcademic(dbOP,request);
	if(vSummary == null)
	{
		strErrMsg = RI.getErrMsg();
	}
}

float fTotalIncome  = 0f;
float fTotalExpense = 0f;
%>
<form name="report_expenses" action="./expenses.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          EXPENSE REPORT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="12%">Show</td>
      <td><select name="report_for" onChange="ReloadPage();">
          <option value="0">Academic</option>
<%
if(WI.fillTextValue("report_for").compareTo("1") ==0){%>
          <option value="1" selected>Non Academic</option>
<%}else{%>
          <option value="1">Non Academic</option>
<%}%>
        </select> <select name="summary_specific_val" onChange="ReloadPage();">
          <option value="0">Summary</option>
<%if(WI.fillTextValue("summary_specific_val").compareTo("1") ==0){%>
          <option value="1" selected>Specific</option>
<%}else{%>
          <option value="1">Specific</option>
<%}%>
        </select> </td>
    </tr>
    <%
if(WI.fillTextValue("report_for").length() ==0 || WI.fillTextValue("report_for").compareTo("0") ==0){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>College</td>
      <td> <select name="c_index" onChange="ReloadPage();">
          <option value="0">All Colleges</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",WI.fillTextValue("c_index"), false)%>
        </select> </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Department</td>
      <td> <select name="d_index" onChange="ReloadPage();">
          <option value="0">ALL departments</option>
<%
if(WI.fillTextValue("c_index").length()> 0 && WI.fillTextValue("c_index").compareTo("0") != 0){%>
          <%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and c_index= "+WI.fillTextValue("c_index")+" order by d_name asc",WI.fillTextValue("d_index"), false)%>
          <%}%>
        </select> </td>
    </tr>
    <%}//only if report for is academic
else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Non Acad Dept</td>
      <td><select name="d_index" onChange="ReloadPage();">
          <option value="0">ALL non acad departments</option>
<%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and (c_index=0 or c_index is null) order by d_name asc",
					WI.fillTextValue("d_index"), false)%>
        </select></td>
    </tr>
<%}%>
    <tr>
      <td height="15" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" valign="bottom">Date Range : From
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('report_expenses.date_from');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;to
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('report_expenses.date_to');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="15" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Sort by</td>
      <td>&nbsp;</td>
      <td width="44%">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="4%">&nbsp; </td>
      <td width="24%"><select name="sort_by1">
          <option></option>
          <%
if(WI.fillTextValue("report_for").compareTo("1") != 0)
{
	if(WI.fillTextValue("sort_by1").compareTo("College") ==0){%>
          <option selected>College</option>
	<%}else{%>
		<option>College</option>
	<%}
}
if(WI.fillTextValue("sort_by1").compareTo("Department") == 0){%>
          <option selected>Department</option>
<%}else{%>
          <option>Department</option>
<%}
if(WI.fillTextValue("sort_by1").compareTo("Income") ==0){%>
          <option selected>Income</option>
<%}else{%>
          <option>Income</option>
<%}%>
        </select> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
<%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="25%"><select name="sort_by2">
          <option></option>
<%
if(WI.fillTextValue("report_for").compareTo("1") != 0)
{
	if(WI.fillTextValue("sort_by2").compareTo("College") ==0){%>
          <option selected>College</option>
	<%}else{%>
		<option>College</option>
	<%}
}
if(WI.fillTextValue("sort_by2").compareTo("Department") == 0){%>
          <option selected>Department</option>
<%}else{%>
          <option>Department</option>
<%}
if(WI.fillTextValue("sort_by2").compareTo("Income") ==0){%>
          <option selected>Income</option>
<%}else{%>
          <option>Income</option>
<%}%>
        </select> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
<%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td>
<%
if(WI.fillTextValue("report_for").compareTo("1") !=0)
{%>
        <select name="sort_by3">
          <option></option>
	<%
	if(WI.fillTextValue("sort_by3").compareTo("College") == 0){%>
          <option selected>College</option>
	<%}else{%>
	      <option>College</option>
	<%}if(WI.fillTextValue("sort_by3").compareTo("Department") == 0){%>
			  <option selected>Department</option>
	<%}else{%>
			  <option>Department</option>
	<%
	}
	if(WI.fillTextValue("sort_by3").compareTo("Income") ==0){%>
			  <option selected>Income</option>
	<%}else{%>
			  <option>Income</option>
	<%}%>
			</select> <select name="sort_by3_con">
			  <option value="asc">Ascending</option>
	<%
	if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
			  <option value="desc" selected>Descending</option>
			  <%}else{%>
			  <option value="desc">Descending</option>
	<%}%>
			</select>
<%}//only if report for is academic%>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td><input type="image" src="../../../images/form_proceed.gif"></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vSummary != null && vSummary.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292" align="center"><font color="#FFFFFF">
        EXPENSE FOR <%=WI.fillTextValue("date_from")%>
		<%
		if(WI.fillTextValue("date_to").length() > 0)
		{%>
		to <%=WI.fillTextValue("date_to")%>
		<%}%>
		</font></td>
    </tr>
    <tr>
<%
strTemp = WI.fillTextValue("is_show_income");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
      <td width="24%" height="25"><input type="checkbox" name="is_show_income" value="1" <%=strTemp%> onClick="javascript:ReloadPage();">
        Show Income</td>
      <td width="51%"><strong>Note:</strong> <font color="#0000FF">Click VIEW
        button to see Expense details</font></td>
      <td width="25%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="24%"  height="25"><div align="center"><font size="1"><strong>COLLEGE</strong></font></div></td>
      <td width="28%"><div align="center"><font size="1"><strong>DEPARTMENT</strong></font></div></td>
      <td align="center"><font size="1"><strong> EXPENSE</strong></font></td>
<%
if(WI.fillTextValue("is_show_income").compareTo("1") ==0){%>
      <td align="center"><font size="1"><strong>GROSS INCOME</strong></font></td>
<%}%>
      <td width="5%" align="center"><font size="1">&nbsp;</font></td>
    </tr>
<%//System.out.println(vSummary);
for(int i=0; i<vSummary.size(); ++i){
fTotalIncome += Float.parseFloat((String)vSummary.elementAt(i+4));
fTotalExpense += Float.parseFloat((String)vSummary.elementAt(i+5));
%>
    <tr>
      <td  height="25"><font size="1">&nbsp;<%=WI.getStrValue((String)vSummary.elementAt(i+2))%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vSummary.elementAt(i+3))%></font></td>
      <td><font size="1">&nbsp;<%=CommonUtil.formatFloat((String)vSummary.elementAt(i+5),true)%></font></td>
<%
if(WI.fillTextValue("is_show_income").compareTo("1") ==0){%>
      <td><font size="1">&nbsp;<%=CommonUtil.formatFloat((String)vSummary.elementAt(i+4),true)%></font></td>
<%}%>
      <td><a href="expenses_detail.htm" target="_blank"><img src="../../../images/view.gif" border="0"></a></td>
    </tr>
<%
i = i+5;
}//end of for loop%>

    <tr>
      <td  height="25" colspan="2"><div align="right"><strong>TOTAL : &nbsp;&nbsp;&nbsp;&nbsp;</strong></div></td>
      <td><%=CommonUtil.formatFloat(fTotalExpense,true)%></td>
<%
if(WI.fillTextValue("is_show_income").compareTo("1") ==0){%>
      <td><%=CommonUtil.formatFloat(fTotalIncome,true)%></td>
<%}%>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8" align="center"><a href="expenses_print.htm" target="_blank"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print report</font></td>
    </tr>
  </table>
<%}//if vSummary is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
