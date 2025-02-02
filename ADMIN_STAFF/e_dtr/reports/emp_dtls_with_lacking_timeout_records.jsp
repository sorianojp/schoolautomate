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
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::LACKING 
          TIME-OUT EMPLOYEE DETAILS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3" ><a href="summary_emp_with_lacking_timeout_records.htm"><img src="../../../images/go_back.gif" border="0" ></a></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
      <td ><table width="400" border="0" align="center" bgcolor="">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%> <%=WI.getStrValue(strTemp)%> <br> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%> <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%=new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> </td>
          </tr>
        </table></td>
      <td >&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;</td>
      <td ><hr size="1"></td>
      <td >&nbsp;</td>
    </tr>
  </table>
  <% if (vRetResult !=null){
			iSearchResult = RE.getSearchCount();
			iPageCount = iSearchResult/RE.defSearchSize;
			if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3"><div align="right"><img src="../../../images/print.gif" width="58" height="26"><font size="1">click 
          to print list </font></div></td>
    </tr>
    <tr> 
      <td width="58%">&nbsp;</td>
      <td width="39%">&nbsp;</td>
      <td width="3%">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3"> <table width="100%" border="1" cellpadding="5" cellspacing="0">
          <tr bgcolor="#006A6A"> 
            <td colspan="2"><div align="center"><font color="#FFFFFF"><strong> 
                LACKING TIME-OUT RECORDS (<%=WI.getStrValue(request.getParameter("from_date"),"")%> 
                - <%=WI.getStrValue(request.getParameter("to_date"),"")%>)</strong></font></div></td>
          </tr>
          <tr> 
            <td width="33%"><div align="center"><font size="1"><strong>DATE</strong></font></div></td>
            <td width="67%"><div align="left"><font size="1"><strong>TIME-IN</strong></font></div></td>
          </tr>
          <% for (int iIndex= 0; iIndex < vRetResult.size() ; iIndex+=5) {%>
          <tr> 
            <td><%=(String)vRetResult.elementAt(iIndex+1)%></td>
            <td><%=(String)vRetResult.elementAt(iIndex+4)%></td>
          </tr>
          <%} //end for loop%>
        </table>
        <hr size="1">
        <img src="../../../images/print.gif" width="58" height="26"><font size="1">click 
        to print list </font></td>
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