<%@ page language="java" import="utility.*,enrollment.FAExternalPay,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - External Payments","external_payments.jsp");
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
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"external_payments.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
int iSearchResult = 0;
FAExternalPay fa = new FAExternalPay(request);


	vRetResult = fa.searchExtnPayments(dbOP);
	if (vRetResult == null)
		strErrMsg = fa.getErrMsg();
	else	
		iSearchResult = fa.getSearchCount();

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsWNU = strSchCode.startsWith("WNU");
//bolIsWNU = true;	
boolean	bolIsSearchInternal = false;
//if(WI.fillTextValue("search_option").equals("1")) 
	bolIsSearchInternal = true;

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>

<body bgcolor="#FFFFFF" onLoad="window.print();">
  <% 
  int iCount= 0;
  if (vRetResult != null) {
  
  int iRowsPerPage = 
  			Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"),"25"));
		
  if(WI.fillTextValue("remove_header").length() > 0) 
  	iRowsPerPage = 1000000;

  int iPageTotal = iSearchResult / iRowsPerPage;
  if(iSearchResult%iRowsPerPage > 0)
  	++iPageTotal;
	
  double dTotal = 0d; 
  double dCurrentAmount = 0d;
  double dGrandTotal = 0d;
  int iRowCount = 1;
  int iPageNumber = 1;
  
  for (int i= 0; i < vRetResult.size();) {
  	iRowCount = 1;
  
  %>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" >
    <tr> 
      <td height="25" colspan="2" ><div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
          <font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
          <font size ="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> 
        </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" align="right" valign="bottom">Date and Time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
    <tr> 
      <td width="76%" height="25" ><strong>&nbsp;TOTAL RESULT : <%=iSearchResult%> </strong></td>
      <td width="24%" align="right"><strong>PAGE : <%=iPageNumber++ + " of " + iPageTotal%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="7" class="thinborder"><div align="center"><strong><font size="2">LIST 
          OF <%
if(WI.fillTextValue("search_option").equals("1"))
	strTemp = "INTERNAL";
else	
	strTemp = "EXTERNAL";
%>          <%=strTemp%> PAYMENTS

<%
strTemp = WI.fillTextValue("semester");
if(strTemp.equals("0"))
	strTemp = "SUMMER";
else if(strTemp.equals("1"))
	strTemp = "FS";
else if(strTemp.equals("2"))
	strTemp = "SS";
else if(strTemp.equals("3"))
	strTemp = "TS";

if(WI.fillTextValue("sy_from").length() > 0) {
	strTemp = WI.fillTextValue("sy_from") + " - "+WI.fillTextValue("sy_to")+
", "+strTemp;%>
	<%if(WI.fillTextValue("ignore_sy").length() > 0) {//show only if not ignored sy// %>
	::: <%=strTemp%>
	<%}%>
<%}
strTemp = "";
if(WI.fillTextValue("date_from").length() > 0) {
	if(WI.fillTextValue("date_to").length() > 0)
		strTemp = " - Payment Date from "+WI.fillTextValue("date_from")+" to "+WI.fillTextValue("date_to");
	else	
		strTemp = " - Payment Date "+WI.fillTextValue("date_from");
}
%>
<%=strTemp%>
</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center">
      <td width="3%" class="thinborder" style="font-weight:bold; font-size:9px;">COUNT</td> 
      <td width="8%" height="25" class="thinborder" style="font-weight:bold; font-size:9px;">DATE</td>
      <td width="22%" class="thinborder" style="font-weight:bold; font-size:9px;">PAYEE NAME</td>
<%if(bolIsSearchInternal){%>
      <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">ID NUMBER</td>
      <td width="10%" class="thinborder" style="font-weight:bold; font-size:9px;">COURSE - YR </td>
<%}%>
      <td width="23%" class="thinborder" style="font-weight:bold; font-size:9px;">DESCRIPTION</td>
      <td width="8%" class="thinborder" style="font-weight:bold; font-size:9px;">AMOUNT </td>
      <td width="8%" class="thinborder" style="font-weight:bold; font-size:9px;">OR NUMBER</td>
      <td width="8%" class="thinborder" style="font-weight:bold; font-size:9px;">TELLER</td>
    </tr>
    <% dTotal = 0d; 
		for (; i < vRetResult.size() ; i+=10) {
			dCurrentAmount = Double.parseDouble((String)vRetResult.elementAt(i+4));
			dTotal +=dCurrentAmount;
	%>
    <tr>
      <td class="thinborder"><%=++iCount%>.</td> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td  class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
<%if(bolIsSearchInternal){%>
      <td  class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8),"&nbsp;")%></td>
      <td  class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%></td>
<%}%>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2) + WI.getStrValue((String)vRetResult.elementAt(i+3),"(",")","")%></td>
      <td class="thinborder" align="right"> <%=CommonUtil.formatFloat(dCurrentAmount,true)%></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+5)%></div></td>
      <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+6)%></td>
    </tr>
    <%
		iRowCount++;
		if (iRowCount == iRowsPerPage){
			 i+=10;
			break;
		}
	}
		dGrandTotal += dTotal;
	
	%>
    <tr>
      <td class="thinborder" align="right">&nbsp;</td> 
      <td height="25" colspan="6" class="thinborder" align="right">
	  <strong>Total Amount for this Page:&nbsp; <%=CommonUtil.formatFloat(dTotal,true)%></strong></td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
<% if (i<vRetResult.size()){%> 	
		<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}else{%>
	<br>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr> 
      <td height="25" colspan="4" align="right">
	  <strong>Grand Total for this Report:&nbsp; <%=CommonUtil.formatFloat(dGrandTotal,true)%></strong></td>
    </tr>
</table>
<%}%>  
  
<%} // end outer for loop 
 }%>
</body>
</html>
<%
dbOP.cleanUP();
%>