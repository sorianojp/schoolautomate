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
	document.dtr_op.print_page.value ="";
	document.dtr_op.submit();
}	

function ViewRecords(){
	document.dtr_op.print_page.value ="";
	document.dtr_op.submit();
}

function PrintPage(){
	document.dtr_op.print_page.value ="1";
}
-->
</script>
<body bgcolor="#D2AE72">

<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").compareTo("1") ==0)
{ %>
	<jsp:forward page="./undertime_print.jsp" />
<%}

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
								"Admin/staff-eDaily Time Record-View/Print DTR","emp_undertime_records.jsp");
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
														"emp_undertime_records.jsp");	
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EMPLOYEE WITH UNDERTIME ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3"><strong>Date</strong> &nbsp;&nbsp;&nbsp;&nbsp;:: &nbsp;From: 
        <input name="from_date" type="text"  id="from_date" size="12" readonly="true"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("from_date")%>"> 
        <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
        : 
        <input name="to_date" type="text"  id="to_date" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("to_date")%>"> 
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp; 
        <a href="javascript:ViewRecords();"><img src="../../../images/form_proceed.gif" border="0"></a> 
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
      <td height="25" colspan="2"> <a href="javascript:ViewRecords();">
	  	<img src="../../../images/form_proceed.gif" border="0"></a> 
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
if (vRetResult != null && vRetResult.size() > 0){
	iSearchResult = RE.getSearchCount();
	int iPageCount = iSearchResult/RE.defSearchSize;
	if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
%>
  <table width="100%" border="0" cellpadding="2" cellspacing="5" bgcolor="#FFFFFF">
    <tr> 
      <td width="61%">&nbsp;</td>
      <td width="26%">&nbsp;</td>
      <td width="13%"><input type="image" src="../../../images/print.gif" onClick="PrintPage()"></td>
    </tr>
    <tr> 
      <td colspan="3"><table width="100%" border="1" cellpadding="5" cellspacing="0">
          <tr bgcolor="#006A6A"> 
            <td colspan="5"><div align="center"><font color="#FFFFFF"><strong>LIST 
                OF EMPLOYEE UNDERTIME RECORDS (<%=WI.getStrValue(request.getParameter("from_date"),"")%> - <%=WI.getStrValue(request.getParameter("to_date"),"")%>)</strong></font></div></td>
          </tr>
          <tr> 
            <td width="22%"><div align="center"><strong><font size="1">EMPLOYEE 
                ID</font></strong></div></td>
            <td width="19%"><div align="center"><font size="1"><strong>DATE</strong></font></div></td>
            <td width="24%"><div align="center"><font size="1"><strong>ACTUAL 
                TIME-IN/OUT</strong></font></div></td>
            <td width="24%"><font size="1"><strong>REQUIRED TIME-IN/OUT</strong></font></td>
            <td width="24%"><div align="center"><font size="1"><strong>MINUTES 
                UNDERTIME</strong></font></div></td>
          </tr>
          <% for (int iIndex= 0; iIndex < vRetResult.size() ; iIndex+=5) {%>
          <tr> 
            <td><%=(String)vRetResult.elementAt(iIndex)%></td>
            <td><%=(String)vRetResult.elementAt(iIndex+1)%></td>
            <td><%=(String)vRetResult.elementAt(iIndex+3)%></td>
            <td><%=(String)vRetResult.elementAt(iIndex+2)%></td>
            <td><%=(String)vRetResult.elementAt(iIndex+4)%></td>
          </tr>
          <%} //end for loop%>
        </table></td>
    </tr>
    <tr> 
      <td colspan="3" align="right">
	  <input type="image" onClick="PrintPage()" src="../../../images/print.gif" align="right"></td>
    </tr>
  </table>
<%}  // if vRetResult == null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
	</table>
<input type="hidden" name="print_page">
</form>
</body>
</html>
