<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.FAStudentLedgerExtn,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","list_stud_paid_full.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"list_stud_paid_full.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//end of authenticaion code.
boolean bolIsUC = strSchCode.startsWith("UC");


Vector vRetResult = null;
String[] astrConvertToSem = {"SUMMER, ","FIRST SEMESTER, ","SECOND SEMESTER, ",
						"THIRD SEMESTER, ","FOURTH SEMESTER, "};
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("reloadPage").length() ==0)
{
	enrollment.ReportFeeAssessment REA = new enrollment.ReportFeeAssessment();
	if(bolIsUC)
		vRetResult = REA.getStudListPaidFullUC(dbOP, request);
	else	
		vRetResult = REA.getStudListPaidFull(dbOP, request);

	if(vRetResult == null)
		strErrMsg = REA.getErrMsg();	
}
if(vRetResult == null || vRetResult.size() == 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="7%" height="20"></td>
    <td><font size="3"><b><%=strErrMsg%></b></font></td>
  </tr>
</table>
<%dbOP.cleanUP();
return;
}
boolean bolShowDiscAmount = false;
if(WI.fillTextValue("show_only_disc").length() > 0 && WI.fillTextValue("show_discount").length() > 0)
	bolShowDiscAmount = true;

if(bolIsUC)
	bolShowDiscAmount = true;

double dPerCollegePmt  = 0d;
double dPerCollegeDisc = 0d;	

double dTotalPmt       = 0d;
double dTotalDisc      = 0d;

double dTemp = 0d;
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20"><div align="center"><strong>::: LIST OF STUDENTS WHO PAID 
        IN FULL FOR <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]+ WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%> 
        ::: <br>
        <br>
        </strong></div></td>
    </tr>
  </table>
  
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td width="20%" height="20" class="thinborder"><strong>STUDENT ID</strong></td>
    <td width="42%" class="thinborder"><strong>NAME (LNAME,FNAME, MI)</strong></td>
    <td width="12%" class="thinborder"><strong>YEAR LEVEL</strong></td>
    <td width="24%" class="thinborder"><strong><%if(bolIsUC){%>DATE PAID<%}else{%>AMOUNT PAID<%}%></strong></td>
<%if(bolShowDiscAmount){%>
    <td width="24%" class="thinborder"><strong>DISCOUNT AMOUNT</strong></td>
<%}%>
  </tr>
  <%
for(int i = 0; i< vRetResult.size() ; i +=9){
if(vRetResult.elementAt(i + 1) != null) {if(i > 0) {%>
    <tr> 
      <td height="20" colspan="3" class="thinborder" align="right"><strong>SUB TOTAL&nbsp;&nbsp;</strong></td>
      <td height="20" class="thinborder" align="right"><%if(!bolIsUC){%><%=CommonUtil.formatFloat(dPerCollegePmt,true)%><%}%>&nbsp;&nbsp; </td>
<%if(bolShowDiscAmount){%>
      <td height="20" class="thinborder" align="right"><%=CommonUtil.formatFloat(dPerCollegeDisc,true)%></td>
<%}%>
    </tr><%dPerCollegePmt=0d;dPerCollegeDisc=0d;}%>
  <tr bgcolor="#EFEFEF"> 
    <td height="20" colspan="4" class="thinborderBOTTOMLEFT"><strong>COLLEGE : <%=(String)vRetResult.elementAt(i + 1)%></strong></td>
<%if(bolShowDiscAmount){%>
      <td height="20" class="thinborderBOTTOM">&nbsp;</td>
<%}%>
  </tr>
  <%}
	if(vRetResult.elementAt(i + 2) != null || vRetResult.elementAt(i + 3) != null) {%>
  <tr> 
    <td height="20" colspan="4" class="thinborderBOTTOMLEFT"><font size="1">::Course::Major: 
      <%=(String)vRetResult.elementAt(i + 2)%> <%=WI.getStrValue(vRetResult.elementAt(i + 3))%></font></td>
<%if(bolShowDiscAmount){%>
      <td height="24" class="thinborderBOTTOM">&nbsp;</td>
<%}%>
  </tr>
  <%}

if(!bolIsUC) {
	dTemp = Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 7),"0"));
	dPerCollegePmt += dTemp;
	dTotalPmt      += dTemp;
}

dTemp = Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 8),"0"));
dPerCollegeDisc += dTemp;
dTotalDisc      += dTemp;
  %>
  <tr> 
    <td width="21%" height="20" class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
    <td width="42%" class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
    <td width="15%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></td>
    <td width="12%" class="thinborder" align="right"> 
	  <%if(vRetResult.elementAt(i + 7) != null){
	  	if(bolIsUC){%> 
			<%=vRetResult.elementAt(i + 7)%>
		<%}else{%>
	  		<%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(i + 7)),true)%> 
	  <%}}
	  else{%> &nbsp;&nbsp; <%}//=WI.getStrValue(vRetResult.elementAt(i + 7),"&nbsp;")%> </td>
<%if(bolShowDiscAmount){%>
    <td width="10%" class="thinborder" align="right"> 
      <%if(vRetResult.elementAt(i + 8) != null){%>
      <%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 8)).doubleValue(),true)%> 
      <%}%></td>
<%}%>
  </tr>
  <%}//end of for loop%>
    <tr> 
      <td height="20" colspan="3" class="thinborder" align="right"><strong>SUB 
        TOTAL&nbsp;&nbsp;</strong></td>
      <td height="20" class="thinborder" align="right">&nbsp;<%if(!bolIsUC){%><%=CommonUtil.formatFloat(dPerCollegePmt,true)%><%}%></td>
<%if(bolShowDiscAmount){%>
      <td height="20" class="thinborder" align="right"><%=CommonUtil.formatFloat(dPerCollegeDisc,true)%></td>
<%}%>
    </tr>
</table>
   
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    
  <tr> 
    <td width="28%" height="20" align="right">Total No. of Student(s)&nbsp;: 
      &nbsp;</td>
      
    <td width="5%"><strong><%=vRetResult.size()/9%></strong></td>
    <td width="67%"><%if(!bolIsUC){%>&nbsp;Total Payment:<strong><%=CommonUtil.formatFloat(dTotalPmt,true)%></strong> &nbsp;&nbsp;&nbsp;<%}%>Total Discounted:<strong><%=CommonUtil.formatFloat(dTotalDisc,true)%></strong></td>
    </tr>
  </table>
<!-- print here. -->
<script language="JavaScript">
var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
if(vProceed)
	window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>