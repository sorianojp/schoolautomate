<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	document.dtr_op.submit();
}

function ViewRecordDetail(index){
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.SummaryDetail.value="1";
	document.dtr_op.emp_id.value=index;
	document.dtr_op.emp_type.value ="";
	document.dtr_op.c_index.value ="";
	document.dtr_op.d_index.value ="";
	document.dtr_op.submit();
}
function ViewRecords()
{
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}
function PrintPage()
{
	document.dtr_op.print_page.value = "1";
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").compareTo("1") ==0)
{ %>
	<jsp:forward page="./late_timein_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Employees with Late Time-in Record",
								"emp_late_timein_records.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"emp_late_timein_records.jsp");	
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

vRetResult = RE.searchLateTimeIn(dbOP);

%>
<form action="./emp_late_timein_records.jsp" name="dtr_op" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LATE TIMEIN EMPLOYEE LIST ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
	</table>
<table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td><strong>Date</strong> &nbsp;&nbsp;&nbsp;&nbsp;:: &nbsp;From: 
          <input name="from_date" type="text"  id="from_date" size="12" readonly="true"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("from_date")%>">
          <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
          : 
          <input name="to_date" type="text"  id="to_date" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("to_date")%>">
          <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp; 
          <input name="image" type="image" onClick="ViewRecords()" src="../../../images/form_proceed.gif" width="81" height="21">
        
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#FFFFFF"> 
            <td>&nbsp;</td>
            <td height="25">Employee ID</td>
            <td height="25"><input name="emp_id" type="text"  id="emp_id" size="12" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>"></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td width="4%">&nbsp;</td>
            <td width="17%" height="25">Employment Type</td>
            <td width="79%" height="25"><strong> 
              <%strTemp2 = WI.fillTextValue("emp_type");%>
              <select name="emp_type">
                <option value="">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%> 
              </select>
              </strong></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td>&nbsp;</td>
            <td height="25">College </td>
            <td height="25"><select name="c_index" onChange="ReloadPage();">
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
          <tr bgcolor="#FFFFFF"> 
            <td>&nbsp;</td>
            <td height="25"><%=strTemp2%></td>
            <td height="25"> <select name="d_index">
                <% if(strTemp.compareTo("") ==0){//only if from non college.%>
                <option value="">All</option>
                <%}else{%>
                <option value="">All</option>
                <%} strTemp3 = WI.fillTextValue("d_index");%>
                <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> </select> </td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td>&nbsp;</td>
            <td height="25"><input name="proceed" type="image" id="proceed2" onClick="ViewRecords();" src="../../../images/form_proceed.gif"></td>
            <td height="25">&nbsp;</td>
          </tr>
        </table>
      </td>
  </tr>
  <tr> 
      <td><strong><%=WI.getStrValue(RE.getErrMsg(),"")%></strong></td>
  </tr>

</table>
<% if (vRetResult !=null){
			iSearchResult = RE.getSearchCount();
			iPageCount = iSearchResult/RE.defSearchSize;
			if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="58%">&nbsp;</td>
      <td width="39%">&nbsp;</td>
      <td width="3%"><input name="image2" type="image" onClick="PrintPage()" src="../../../images/print.gif" align="right" width="58" height="26"></td>
    </tr>
    <tr> 
      <td colspan="3"><table width="100%" border="1" cellpadding="3" cellspacing="0">
          <tr bgcolor="#006A6A"> 
            <% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
            <td  colspan="5"><div align="center"><font color="#FFFFFF"><strong>LIST 
                OF EMPLOYEE WITH LATE TIMEIN (<%=strTemp%>)</strong></font></div></td>
          </tr>
          <tr> 
            <td width="17%" height="30" bgcolor="#EBEBEB"><strong><font size="1">EMPLOYEE 
              ID</font></strong></td>
            <td width="16%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>DATE</strong></font></td>
            <td width="17%" height="30" bgcolor="#EBEBEB"><font size="1"><strong>REQUIRED 
              TIME IN</strong></font></td>
            <td width="21%" bgcolor="#EBEBEB"><strong><font size="1">ACTUAL TIME 
              IN </font></strong></td>
            <td width="13%" height="30" bgcolor="#EBEBEB"><strong><font size="1">MINUTES 
              LATE</font></strong></td>
          </tr>
          <%  strTemp2 = "";
	for ( int i = 0 ; i< vRetResult.size(); i+=5){ 
	
	strTemp = (String)vRetResult.elementAt(i);
	if (strTemp2.compareTo(strTemp) == 0){
		strTemp = "&nbsp;";
	}else{
		strTemp2 = strTemp;
	}
%>
          <tr> 
            <td><%=strTemp%></td>
            <td><%=(String)vRetResult.elementAt(i+1)%></td>
            <td><%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+2)),2)%></td>
            <td><%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+3)),2)%></td>
            <td><%=(String)vRetResult.elementAt(i+4)%> &nbsp;</td>
          </tr>
          <%} // end for loop%>
        </table>
        <hr size="1"> <img src="../../../images/print.gif" width="58" height="26" align="right"></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
   <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
	</table>
  <input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
  <input type=hidden name="viewRecords" value="0">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>