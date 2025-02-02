<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
Vector vRetResultDtl = null;
Vector vStudList = null;
Vector vARStudents = null;
double dTotalAmount = 0d;
double dTotalRowAmount = 0d;
enrollment.FAFeeAdjustmentCPU fAdjust = new enrollment.FAFeeAdjustmentCPU();
String[] astrSemester = {"Summer", "1st Semester","2nd Semester", "3rd Semester",""};
String strJVNumber = null;


if (WI.fillTextValue("c_index").length() > 0){

		if ( strJVNumber== null){
			// check if JV Number already exists
			strJVNumber = fAdjust.getJVNumber(dbOP, request);
			if (strJVNumber== null){
				strErrMsg = fAdjust.getErrMsg();
			}
		}


		vRetResult = fAdjust.viewAllAccountWithTransOnDate(dbOP,request);
		if (vRetResult == null)
			strErrMsg= fAdjust.getErrMsg();
			
		vARStudents = fAdjust.calcARStudents(dbOP,request);
		if (vARStudents == null)
			strErrMsg= fAdjust.getErrMsg();
			
		vRetResultDtl = fAdjust.viewAccountWithTransOnDateDetail(dbOP,request);
		if (vRetResultDtl == null)
			strErrMsg = fAdjust.getErrMsg();
			
		if (vRetResultDtl != null){	
			for (int j = 0; j < vRetResultDtl.size();){
				dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(j+2),",",""),"0"));
				j += 3; 
				if ( vRetResultDtl.elementAt(j) != null) {
					break;
				}	
			}	
			vStudList = fAdjust.viewEnrolledStudentsOnDateDetail(dbOP,request);
			if (vStudList != null) 
				strErrMsg = fAdjust.getErrMsg();
		}
}

String[] astrConvSem ={"Summer", "1st Semester", "2nd Semester", "3rd Semester", ""};

int iGroupNo = 1;
int iCtr = 0;
int iLineCtr = 0;

if (strErrMsg != null) { 
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>", "</strong></font>","")%>
	  </td>
    </tr>
  </table>
  <%}else{ if (vRetResult != null && vRetResult.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
      <td width="73%" height="18">CENTRAL PHILIPPINE UNIVERSITY  </td>
      <td width="27%" height="18"><strong>Number  : <%=WI.getStrValue(strJVNumber,"&lt; To Generated After Saving &gt;")%> </strong></td>
    </tr>
      <tr>
        <td height="18">Iloilo City &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Philippines </td>
        <td height="18">&nbsp;</td>
      </tr>
      <tr>
        <td height="14">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Accounting Office </td>
        <td height="14">Date : <%=WI.formatDate(WI.fillTextValue("date_from"),6)%></td>
      </tr>
      <tr>
        <td height="14">&nbsp;</td>
        <td height="14">&nbsp;</td>
      </tr>
      <tr>
        <td height="14">&nbsp;</td>
        <td height="14">&nbsp;</td>
      </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" align="center"> <font size="3"><strong>JOURNAL VOUCHER </strong></font></td>
    </tr>
    <tr>
      <td height="18" colspan="3"><div align="center">===============================================================================</div></td>
    </tr>
    <tr>
      <td width="58%"><strong>DEBIT</strong></td>
      <td width="23%" height="25"><div align="center"></div></td>
      <td width="19%" align="center"><strong>Amount</strong></td>
    </tr>
<% if (vARStudents != null && vARStudents.size() > 0) {%> 
    <tr>
      <td>&nbsp;&nbsp;<%=iGroupNo%>. <%=(String)vARStudents.elementAt(0)%></td>
      <td height="20"><div align="center"><%=(String)vARStudents.elementAt(1)%></div></td>
      <td align="right"><%=(String)vARStudents.elementAt(2)%>&nbsp;&nbsp;</td>
    </tr>
<%}if (vARStudents != null && vARStudents.elementAt(16) != null){%>
    <tr>
      <td>&nbsp;&nbsp;<%=iGroupNo%>. <%=(String)vARStudents.elementAt(16)%></td>
      <td height="20"><div align="center"><%=(String)vARStudents.elementAt(17)%></div>				</td>
      <td align="right"><%=(String)vARStudents.elementAt(18)%>&nbsp;&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
    <tr>
      <td><strong>CREDIT </strong></td>
      <td height="25">&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
<% if (vARStudents != null && vARStudents.size() > 0){
	iGroupNo = 1;

%> 
    <tr>
      <td height="18">&nbsp;&nbsp;1. <%=(String)vARStudents.elementAt(4)%></td>
      <td height="18" align="center"><%=(String)vARStudents.elementAt(5)%></td>
      <td align="right"><%=(String)vARStudents.elementAt(6)%>&nbsp;&nbsp;</td>
    </tr>
<% if (vARStudents != null && vARStudents.size() > 0 && vARStudents.elementAt(8) != null) {%> 
    <tr>
      <td height="18">&nbsp; <%=(String)vARStudents.elementAt(8)%></td>
      <td height="18" align="center"><%=(String)vARStudents.elementAt(9)%></td>
      <td align="right"><%=(String)vARStudents.elementAt(10)%>&nbsp;&nbsp;</td>
    </tr>	
<%}
}%>
		
<%

for (int i =0 ; i < vRetResult.size(); i+=5) {
	dTotalAmount += 
		 Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""));
%> 
    <tr>
      <td height="18">&nbsp;
	  <%=(String)vRetResult.elementAt(i)%></td>
      <td height="18" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="right"><%=(String)vRetResult.elementAt(i+2)%>&nbsp;&nbsp;</td>
    </tr>
<%}
	if (vARStudents != null && vARStudents.elementAt(12) != null){
	iGroupNo++;
%> 

    <tr>
      <td height="18">&nbsp;&nbsp;2.&nbsp;<%=(String)vARStudents.elementAt(12)%></td>
      <td height="18" align="center"><%=(String)vARStudents.elementAt(13)%></td>
      <td align="right"><%=(String)vARStudents.elementAt(14)%>&nbsp;&nbsp;</td>
    </tr>
<%}
	iGroupNo = 1;

%> 	
    <tr>
      <td height="18" colspan="3"><hr size="1" width="100%"></td>
    </tr>
    <tr>
      <td height="18" colspan="3">EXPLANATION</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="top">&nbsp;
	  <%=iGroupNo++%>.To record Tuition and Fees Charges to <%=CommonUtil.formatFloat(dTotalRowAmount,false)%> <%=WI.fillTextValue("c_name")%> enrollee(s) for <%=astrSemester[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"4"))] +  " " + WI.fillTextValue("sy_from") + " -  " + WI.fillTextValue("sy_to") %> enrolled on <%=WI.formatDate(WI.fillTextValue("date_from"),6)%>	  </td>
    </tr>
<%if (vARStudents != null && vARStudents.elementAt(12) != null){%> 
    <tr>
      <td height="18" colspan="3" valign="top">&nbsp;
	 <%=iGroupNo%>. To record Tuition cash discounts granted to <%=WI.fillTextValue("c_name")%> enrollee(s)    </td>
    </tr>
<%}%>	
    <tr>
      <td height="18" colspan="3" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="top">&nbsp;</td>
    </tr>


<!--
    <tr>
      <td height="25" colspan="2" align="right"><strong>TOTAL</strong></td>
	  <td align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%>&nbsp;&nbsp;</strong></td>
    </tr>
-->
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <% if (vARStudents != null && vARStudents.size() > 0) {%>
    <%}if (vARStudents != null && vARStudents.elementAt(16) != null){%>
    <%}%>
    <% if (vARStudents != null && vARStudents.size() > 0){
	iGroupNo = 1;

%>
    <% if (vARStudents != null && vARStudents.size() > 0 && vARStudents.elementAt(8) != null) {%>
    <%}
}%>
    <%

for (int i =0 ; i < vRetResult.size(); i+=5) {
	dTotalAmount += 
		 Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+2),",",""));
%>
    <%}
	if (vARStudents != null && vARStudents.elementAt(12) != null){}
	iGroupNo = 1;

%>

    <tr>
      <td height="18" colspan="2" valign="top"><p align="center">===============================================================================</p></td>
    </tr>
    <tr>
      <td height="18" colspan="2" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td width="65%" height="18" valign="top">Prepared by : </td>
      <td height="18" valign="top">Correct _________________________ </td>
    </tr>
    <tr>
      <td height="18" valign="top">&nbsp;</td>
      <td height="18" valign="top"> <div align="center">Accountant </div></td>
    </tr>
    <tr>
      <td height="18" valign="top">APPROVED : _________________ </td>
      <td height="18" valign="top">Entered by ______________________</td>
    </tr>
    <tr>
      <td height="18" valign="top">&nbsp;</td>
      <td height="18" valign="top"><div align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bookkeeper</div></td>
    </tr>
    <tr>
      <td height="18" valign="top">&nbsp;</td>
      <td height="18" valign="top">Journal Page _____________ </td>
    </tr>
    <!--
    <tr>
      <td height="25" colspan="2" align="right"><strong>TOTAL</strong></td>
	  <td align="right"><strong><%=CommonUtil.formatFloat(dTotalAmount,true)%>&nbsp;&nbsp;</strong></td>
    </tr>
-->
  </table>
  <DIV style="page-break-after:always">&nbsp;</DIV>
<%}

 if (vRetResultDtl != null && vRetResultDtl.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <%strTemp = WI.fillTextValue("date_from");
  	if (strTemp.length() > 0) {
		strTemp = " on " +  WI.formatDate(strTemp,6);
	}
	
	
	if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) 
		strTemp +=  " - " +
			astrConvSem[Integer.parseInt(request.getParameter("semester"))] + 
			" " +  request.getParameter("sy_from") + " - " +  request.getParameter("sy_to");
		
  %>   
 
    <tr>
      <td height="25" colspan="7"><%=WI.fillTextValue("c_name")%> <br>
      Summary of Charges of 
      Enrolment  <%=strTemp%><br>
      <br></td>
    </tr>
    <tr>
      <td class="bottomBorder"><font size="1">&nbsp;NAME OF FEES</font></td>
      <td class="bottomBorder"><div align="center"><font size="1">First Year </font></div></td>
      <td class="bottomBorder"><div align="center"><font size="1">Second Year </font></div></td>
      <td class="bottomBorder"><div align="center"><font size="1">Third Year </font></div></td>
      <td class="bottomBorder"><div align="center"><font size="1">Fourth Year</font></div></td>
      <td height="20" class="bottomBorder"><div align="center"><font size="1">Fifth Year </font></div></td>
      <td align="center" class="bottomBorder"><font size="1">TOTAL</font></td>
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
<% 	

	boolean bolInfiniteLoop = true;
	boolean bolFormatFloat = false;
for (int i =0 ; i < vRetResultDtl.size();) {
	bolInfiniteLoop = true;
	dTotalRowAmount = 0d;
	if(i > 0) {
		bolFormatFloat = true;
	}
%> 
    <tr>
      <td height="20"><font size="1">&nbsp;
        <% if (i < vRetResultDtl.size() && vRetResultDtl.elementAt(i) != null){%>
   	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i),"--")%>
        <% vRetResultDtl.setElementAt(null, i);
	   
	   }%>
      </font></td>
      <td align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() &&  vRetResultDtl.elementAt(i) == null &&
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("1")){

			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <% i += 3;
	  
	  }else{%> 
	    0.00 
	    <%}%>	  
      </font></td>
      <td align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() &&  vRetResultDtl.elementAt(i) == null && 
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("2")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <%i += 3;}else{%> 
	    0.00
	    <%}%>	  
      </font></td>
      <td align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() && vRetResultDtl.elementAt(i) == null &&
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("3")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <%i += 3;}else{%> 
	    0.00 
	    <%}%>	  
      </font></td>
      <td align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() && vRetResultDtl.elementAt(i) == null &&
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("4")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <%i += 3;}else{%> 
	    0.00 
	    <%}%>	  
      </font></td>
      <td height="20" align="right">
	    <font size="1">
	    <% if (i < vRetResultDtl.size() && vRetResultDtl.elementAt(i) == null &&
	  		 ((String)vRetResultDtl.elementAt(i+1)).equals("5")){
			
			bolInfiniteLoop = false;
			dTotalRowAmount += 
					Double.parseDouble(WI.getStrValue(
					ConversionTable.replaceString((String)vRetResultDtl.elementAt(i+2),",",""),"0"));
	   %> 
	    <%=WI.getStrValue((String)vRetResultDtl.elementAt(i+2),"--")%>
	    <%i += 3;}else{%> 
	    0.00 
	    <%}%>	  
      </font></td>
      <td align="right">
	  		<font size="1"><strong><%=CommonUtil.formatFloat(dTotalRowAmount,bolFormatFloat)%></strong>&nbsp;	  </font></td>
    </tr>

<%
 if (bolInfiniteLoop) {
/**
 	System.out.println("specific_acct_cpu_details.jsp");
 	System.out.println("i : " + i);
	System.out.println("vRetResult.size() : " + vRetResultDtl.size());
	System.out.println("vRetResult.elementAt(i) : " + vRetResultDtl.elementAt(i));
	System.out.println("(String)vRetResult.elementAt(i+1) : " + (String)vRetResultDtl.elementAt(i+1));
**/	break;
 }
}%>
  </table>
  <DIV style="page-break-after:always">&nbsp;</DIV>  
 <% 
 	
 	if (vStudList != null && vStudList.size() > 0) {%> 
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
  <td colspan="9"><%=WI.fillTextValue("c_name")%> Enrolment Report <%=strTemp%></td>
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
<% 	iCtr = 1;
	for (int i =  0; i < vStudList.size() ; i+= 10) {%> 
  <tr>
    <td height="20" align="right"><font size="1"><%=iCtr++%>&nbsp;</font></td>
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
    <td class="topBorder">&nbsp;</td>
    <td class="topBorder">&nbsp;</td>
    <td class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
    <td align="right" class="topBorder">&nbsp;</td>
  </tr>
  </table>
<%  } // vStudList != null
  } // 
} 
%> 

<script language="javascript">
	window.setInterval("javascript:window.print()", 0);
</script>



</body>
</html>
<%
dbOP.cleanUP();
%>
