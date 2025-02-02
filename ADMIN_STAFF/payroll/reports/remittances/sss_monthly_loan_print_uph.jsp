<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SSS monthly loans remittance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 

TABLE.thinborder {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMRIGHT {
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOPRIGHT {
	border-right: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLEFT {
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderRIGHT {
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderNone {	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOMTOPRIGHT {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOPLEFT {
	border-top: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborder{
	border-bottom: solid 1px #000000;   
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./sss_monthly_loan_print_uph.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolPageBreak = false;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PAYROLL-REPORTS-sss_monthlyLoanRemit","sss_monthly_loan_print.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"sss_monthly_loan_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
		
	Vector vRetResult = null;
	PRRemittance PRRemit = new PRRemittance(request);
	Vector vEmployerInfo = null;
	boolean bolShowSSS = WI.fillTextValue("sss_number").length() > 0;
	boolean bolShowIssue = WI.fillTextValue("date_issued").length() > 0;
	boolean bolShowStart = WI.fillTextValue("date_start").length() > 0;
	double dPageTotal = 0d;
	double dGrandTotal = 0d;
	String[] astrMonth = {"January","February","March","April","May","June","July",
						  "August", "September","October","November","December"};
						  
	String[] astrPtFt = {"PART-TIME","FULL-TIME"};
	String strCodeIndex = WI.fillTextValue("code_index");
	String strLoanName = null;
	  if(strCodeIndex.length() > 0){
		 strLoanName = dbOP.mapOneToOther("ret_loan_code","code_index",WI.fillTextValue("code_index"),
										 "loan_name","");
	  }
	int iIndexOf  = 0;
	String strEmpId = null;
	Vector vEmpAddlInfo = PRRemit.getAddlEmpInfo(dbOP, request);
	//Vector vEmpAddlInfo = new payroll.PRRemittanceExtn().getAddlEmpInfo(dbOP, request);

	if(vEmpAddlInfo == null)
		vEmpAddlInfo = new Vector();
	vRetResult = PRRemit.SSSMonthlyLoan(dbOP);
	if(vRetResult != null && vRetResult.size() > 0)
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
	
	if (vRetResult != null) {
	
		int i = 0; int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			
		
		int iNumRec = 3;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = (vRetResult.size()-3)/(22*iMaxRecPerPage);	
	    if((vRetResult.size()-3) % (22*iMaxRecPerPage) > 0) ++iTotalPages;
		String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
	  String strSchAddr = SchoolInformation.getAddressLine1(dbOP,false,false);
	  int iPageCount = 0;
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal =0d;		
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font size="2"><strong>        
        <%=strSchName%><br><%=strSchAddr%></strong><br><br>       
      </font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5"><div align="center"><strong>SSS SALARY LOAN REPORT<br>
            For the month of <u><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))].toUpperCase()%> <%=WI.fillTextValue("year_of")%></u></strong></div></td>
    </tr>
    <tr >
        <td height="20" colspan="5" align="right"><font size="1">Page <%=++iPageCount%> of <%=iTotalPages%></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" class="thinborder" cellpadding="0">
    <tr> 
      <td align="center" width="9%" height="20" class="thinborder">EMPLOYEE ID</td>
      <td align="center" width="13%" class="thinborder">SSS ID</td>
      <td align="center" width="10%" class="thinborder">LAST NAME</td>
		<td align="center" width="13%" class="thinborder">FIRST NAME</td>
		<td align="center" width="12%" class="thinborder">MIDDLE NAME</td>
			
      <td width="10%" align="center" class="thinborder">BIRTH DATE</td>			
      <td width="12%" align="center" class="thinborder">TIN #</td>			
      <td width="11%" align="center" class="thinborder">PERIOD COVERAGE</td>			
      <td width="10%" align="center" class="thinborder">AMORTIZATION</td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=22,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;	
			
		strEmpId = WI.getStrValue((String)vRetResult.elementAt(i+3));
	%>
    <tr> 
      <td class="thinborder"><%=strEmpId%></td>
	  <%
	  strEmpId = strEmpId+"_ID";
	  
		strTemp = "&nbsp;";
		if((String)vRetResult.elementAt(i+12) != null)
			strTemp = ((String)vRetResult.elementAt(i+12)).toUpperCase();
		%>
      <td class="thinborder"><%=strTemp%></td>
      <td height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
	  <td height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
	  <td height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5)).toUpperCase()%></td>
		<%
	strTemp = "&nbsp;";
	iIndexOf = vEmpAddlInfo.indexOf(strEmpId);
	if(iIndexOf > -1)
		strTemp = (String)vEmpAddlInfo.elementAt(iIndexOf + 9);
	%>	
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>			
	  <%
	strTemp = "&nbsp;";
	iIndexOf = vEmpAddlInfo.indexOf(strEmpId);
	if(iIndexOf > -1)
		strTemp = (String)vEmpAddlInfo.elementAt(iIndexOf + 22);
	%>	
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>			
      <td class="thinborder">&nbsp;<%//=WI.getStrValue((String)vRetResult.elementAt(i+15))%></td>			
      <% 
		strTemp = (String)vRetResult.elementAt(i+10);
		dPageTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		dGrandTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
	  %>
      <td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%>&nbsp;</td>
    </tr>
    
    <%} // end for loop
	
	if (iNumRec >= vRetResult.size()) {%>
	
	<tr>
        <td height="20" colspan="8" align="right" class="thinborder"><strong>GRAND TOTAL </strong>&nbsp;</td>
        <td align="right" class="thinborder"><strong><%=CommonUtil.formatFloat(dGrandTotal,true)%></strong>&nbsp;</td>
    </tr>
	<%}%>
  </table>
  
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>
	
<%} //end end upper most if (vRetResult !=null)%>
 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>