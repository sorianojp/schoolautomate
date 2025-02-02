<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	TD{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
	TD.topBorder{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		border-top:dashed 1px  #000000;
		font-size:11px;
	}
	TD.bottomBorder{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		border-bottom:dashed 1px #000000; 
		font-size:11px;
	}	

</style>
</head>
<body>
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

	int iListCount = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","specific_acct.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"specific_acct.jsp");
**/
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult= null;
Vector vStudList = null;
double dTotalAmount = 0d;
enrollment.FAFeeAdjustmentCPU fAdjust = new enrollment.FAFeeAdjustmentCPU();



		vRetResult = fAdjust.viewAccountWithTransOnDateDetail(dbOP,request);
		if (vRetResult == null)
			strErrMsg = fAdjust.getErrMsg();
			
		if (vRetResult != null){
			vStudList = fAdjust.viewEnrolledStudentsOnDateDetail(dbOP,request);
			if (vStudList != null) 
				strErrMsg = fAdjust.getErrMsg();
		}


String[] astrConvSem ={"Summer", "1st Semester", "2nd Semester", "3rd Semester", ""};

if (strErrMsg != null) { 

%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>", "</strong></font>","")%>
	  </td>
    </tr>
  </table>
<%} else if (vRetResult != null && vRetResult.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
  <%strTemp = WI.fillTextValue("date_from");
  	if (strTemp.length() > 0) {
		strTemp = " on " +  WI.formatDate(strTemp,6);
	}
	
	
	if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) 
		strTemp +=  " - " +
			astrConvSem[Integer.parseInt(request.getParameter("semester"))] + 
			" " +  request.getParameter("sy_from") + " - " +  request.getParameter("sy_to");
		
  %>   
  	
      <td height="25" colspan="7" class="thinborder"><strong>CPU <%=WI.fillTextValue("c_name")%> <br>
      Summary of Charges of 
      Enrolment  <%=strTemp%><br>
      <br>
      </strong></td>
    </tr>
    <tr>
      <td width="27%" class="bottomBorder"><font size="1">&nbsp;NAME OF FEES</font></td>
      <td width="12%" class="bottomBorder"><div align="center"><font size="1">First Year </font></div></td>
      <td width="12%" class="bottomBorder"><div align="center"><font size="1">Second Year </font></div></td>
      <td width="12%" class="bottomBorder"><div align="center"><font size="1">Third Year </font></div></td>
      <td width="12%" class="bottomBorder"><div align="center"><font size="1">Fourth Year</font></div></td>
      <td width="12%" height="21" class="bottomBorder"><div align="center"><font size="1">Fifth Year </font></div></td>
      <td width="13%" align="center" class="bottomBorder"><font size="1">TOTAL</font></td>
    </tr>
    <tr>
      <td width="27%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td width="12%" height="18">&nbsp;</td>
      <td width="13%" align="center">&nbsp;</td>
    </tr>	
<% 	String strHandsOn = "0";
	double dTotalRowAmount = 0d;
	boolean bolInfiniteLoop = true;
	boolean bolFormatFloat = false;
for (int i =0 ; i < vRetResult.size();) {
	bolInfiniteLoop = true;
	dTotalRowAmount = 0d;
	if(i > 0) {
		bolFormatFloat = true;
	}
%> 
    <tr>
      <td height="20" class="thinborder">&nbsp;
	  <% if (i < vRetResult.size() && vRetResult.elementAt(i) != null){%>
	   	<%=WI.getStrValue((String)vRetResult.elementAt(i),"--")%>
      <% vRetResult.setElementAt(null, i);
	   
	   }%></td>
      <td align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() &&  vRetResult.elementAt(i) == null &&
	  		 ((String)vRetResult.elementAt(i+1)).equals("1")){

			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <% i += 3;
	  
	  }else{%> 0.00 <%}%>	  </td>
      <td align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() &&  vRetResult.elementAt(i) == null && 
	  		 ((String)vRetResult.elementAt(i+1)).equals("2")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <%i += 3;}else{%> 0.00<%}%>	  </td>
      <td align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() && vRetResult.elementAt(i) == null &&
	  		 ((String)vRetResult.elementAt(i+1)).equals("3")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <%i += 3;}else{%> 0.00 <%}%>	  </td>
      <td align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() && vRetResult.elementAt(i) == null &&
	  		 ((String)vRetResult.elementAt(i+1)).equals("4")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <%i += 3;}else{%> 0.00 
	  <%}%>	  </td>
      <td height="20" align="right" class="thinborderBOTTOM">
	  <% if (i < vRetResult.size() && vRetResult.elementAt(i) == null &&
	  		 ((String)vRetResult.elementAt(i+1)).equals("5")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""),"0"));
	   %> <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"--")%>
	  <%i += 3;}else{%> 0.00 
	  <%}%>	  </td>
      <td align="right" class="thinborder">
	  		<strong><%=CommonUtil.formatFloat(dTotalRowAmount,bolFormatFloat)%></strong>&nbsp;	  </td>
    </tr>

<%
 if (bolInfiniteLoop) {
 	System.out.println("specific_acct_cpu_details.jsp");
 	System.out.println("i : " + i);
	System.out.println("vRetResult.size() : " + vRetResult.size());
	System.out.println("vRetResult.elementAt(i) : " + vRetResult.elementAt(i));
	System.out.println("(String)vRetResult.elementAt(i+1) : " + (String)vRetResult.elementAt(i+1));
	break;
 }
}%><tr>
      <td height="20" colspan="7" class="topBorder">&nbsp;</td>
      </tr>
  </table>
<DIV style="page-break-before:always" >&nbsp;</DIV>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
  <%strTemp = WI.fillTextValue("date_from");
  	if (strTemp.length() > 0) {
		strTemp = " on " +  WI.formatDate(strTemp,6);
	}
	if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) 
		strTemp +=  " - " +
			astrConvSem[Integer.parseInt(request.getParameter("semester"))] + 
			" " +  request.getParameter("sy_from") + " - " +  request.getParameter("sy_to");
		
  %> 
  <td colspan="9"><strong><%=WI.fillTextValue("c_name")%> Enrolment Report <%=strTemp%></strong></td>
  </tr>
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="9">Supporting List </td>
  </tr>
  <tr>
    <td colspan="9">&nbsp;</td>
  </tr>
  <tr>
    <td width="4%" class="bottomBorder"><div align="center"><font size="1">Srl</font></div></td>
    <td width="14%" class="bottomBorder"><font size="1">ID Number </font></td>
    <td width="23%" class="bottomBorder"><font size="1">Student Name </font></td>
    <td width="11%" class="bottomBorder"><font size="1">Course-Yr </font></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Tuition &amp; NSTP </font></div></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Misc Fees </font></div></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Lab. Fees </font></div></td>
    <td width="10%" class="bottomBorder"><div align="center"><font size="1">Total Fee </font></div></td>
    <td width="8%" class="bottomBorder"><div align="center"><font size="1">Discount</font></div></td>
  </tr>
  <tr>
    <td width="4%">&nbsp;</td>
    <td width="14%">&nbsp;</td>
    <td width="23%">&nbsp;</td>
    <td width="11%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="8%">&nbsp;</td>
  </tr>  
<% 	int iCtr = 1;
	double dTotalTuition = 0d;
	double dTotalMisc = 0d;
	double dTotalLab = 0d;
	double dTotalFee = 0d;
	double dTotalDiscount = 0d;
	for (int i =  0; i < vStudList.size() ; i+= 10) {%> 
  <tr>
    <td align="right"><%=iCtr++%>&nbsp;</td>
    <td><font size="1">&nbsp;<%=(String)vStudList.elementAt(i)%></font></td>
    <td><font size="1"><%=(String)vStudList.elementAt(i+1)%></font></td>
    <td><font size="1">&nbsp;<%=(String)vStudList.elementAt(i+2) + 
								WI.getStrValue((String)vStudList.elementAt(i+3),"(",")","") + 
								WI.getStrValue((String)vStudList.elementAt(i+4),"-","","")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+5),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+6),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+7),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+8),"0.00")%></font></td>
    <td align="right"><font size="1"><%=WI.getStrValue((String)vStudList.elementAt(i+9),"0.00")%></font></td>
  </tr>

<%}%>   <tr>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
  </tr>
  </table>
  
<script language="javascript">
	window.setInterval("javascript:window.print()", 0);
</script>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
