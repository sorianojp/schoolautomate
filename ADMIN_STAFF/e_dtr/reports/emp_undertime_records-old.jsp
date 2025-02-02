<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function goToNextSearchPage(){
	document.dtr_op.submit();
}

function ViewRecords(){
	document.dtr_op.submit();
}
-->
</script>
<body bgcolor="#D2AE72">

<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
    Vector vRetEDTR = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult =0;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","dtr_view.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"dtr_view.jsp");
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

ReportEDTR RE = new ReportEDTR(request);


vRetResult = RE.searchUndertime(dbOP);

%>
<form name="dtr_op" action="./emp_undertime_records.jsp" method="post">
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3"><strong>Date</strong> &nbsp;&nbsp;&nbsp;&nbsp;:: &nbsp;From:
        <input name="from_date" type="text"  id="from_date" size="12" readonly="true"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("from_date")%>">
        <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To
        :
        <input name="to_date" type="text"  id="to_date" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("to_date")%>">
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp;
        <input name="image" type="image" onClick="ViewRecords()" src="../../../images/form_proceed.gif" width="81" height="21">
      </td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="18%" height="25">Enter Employee ID </td>
      <td width="82%" height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td width="18%" height="25">Employment Type</td>
      <td width="82%" height="25"><strong>
        <%strTemp2 = WI.fillTextValue("emp_type");%>
        <select name="emp_type">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%>
        </select>
        </strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">College </td>
      <td height="25"><select name="c_index" onChange="ViewRecords();">
          <option value="">N/A</option>
          <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25"><select name="d_index">
          <% if(strTemp.compareTo("") ==0){//only if from non college.%>
          <option value="">All</option>
          <%}else{%>
          <option value="">All</option>
          <%} strTemp3 = WI.fillTextValue("d_index");%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="2"> <input name="image2" type="image" onClick="ViewRecords()" src="../../../images/form_proceed.gif" width="81" height="21">
      </td>
    </tr>
    <tr>
      <td colspan="3"> <hr size="1" noshade> </td>
    </tr>
    <tr>
      <td colspan="3"><font size=2><strong><%=WI.getStrValue(RE.getErrMsg(),"")%></strong></font></td>
    </tr>
  </table>

<%
if (vRetResult != null){
	iSearchResult = RE.getSearchCount();
	int iPageCount = iSearchResult/RE.defSearchSize;
	if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
%>
<table width="100%" border="0" cellpadding="5" cellspacing="5" bgcolor="#FFFFFF">
  <tr>
    <td width="61%"> <b>Total Requests: <%=iSearchResult%> - Showing(<%=RE.getDisplayRange()%>)</b><br>
    </td>
    <td width="26%">Jump To page:
      <select name="jumpto" onChange="goToNextSearchPage();">
        <%
	strTemp = request.getParameter("jumpto");
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
	for( int i =1; i<= iPageCount; ++i ){
	if(i == Integer.parseInt(strTemp) ){%>
        <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%}
	} // end for loop
%>
      </select></td>
    <td width="13%"><img src="../../../images/print.gif" width="58" height="26" align="right"></td>
  </tr>
  <tr>
    <td colspan="3"><table width="100%" border="1" cellpadding="5" cellspacing="0">
        <tr bgcolor="#006A6A">
          <td colspan="9"><div align="center"><font color="#FFFFFF"><strong>LIST
                OF EMPLOYEE UNDERTIME RECORDS ($datefrom - $dateto)</strong></font></div></td>
        </tr>
        <tr>
          <td width="14%"><strong><font size="1">EMPLOYEE ID</font></strong></td>
          <td width="11%"><font size="1"><strong>DATE</strong></font></td>
          <td width="10%"><font size="1"><strong>TIME IN</strong></font></td>
          <td width="10%"><font size="1"><strong>TIME OUT</strong></font></td>
          <td width="10%"><font size="1"><strong>TIME IN</strong></font></td>
          <td width="10%"><font size="1"><strong>TIME OUT</strong></font></td>
          <td width="10%"><font size="1"><strong>TOTAL NO OF HOURS</strong></font></td>
          <td width="10%"><font size="1"><strong>UNDERTIME</strong></font></td>
          <td width="15%">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp; </td>
          <td><img src="../../../images/edit.gif" width="40" height="26">
          </td>
        </tr>
      </table></td>
  </tr>
  <tr>
    <td colspan="3"><img src="../../../images/print.gif" width="58" height="26" align="right"></td>
  </tr>
</table>
<%}  // if vRetResult == null%>
</form>
</body>
</html>
