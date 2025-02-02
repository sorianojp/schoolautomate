<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SSS monthly loans remittance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }
    TD.noBorder{
 		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }		
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./sss_monthly_loan_print.jsp">
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
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal =0d;		
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font size="2"><strong>
        <%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);
					strTemp += "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";
				%>
        <%=strTemp%><br>
        <%}else{%>
        <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%}%>
      </font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5"><div align="center"><strong>SSS <%=(WI.getStrValue(strLoanName,"")).toUpperCase()%> LOANS<br>
            <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="5%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td width="39%" class="thinborderBOTTOM">&nbsp;<strong>EMPLOYEE 
        NAME</strong> 
        <div align="center"></div></td>
			<%if(bolShowSSS){%>
      <td width="14%" align="center" class="thinborderBOTTOM"><strong>SSS NUMBER </strong></td>
			<%}%>
			<%if(bolShowIssue){%>
      <td width="14%" align="center" class="thinborderBOTTOM"><strong>DATE ISSUED </strong></td>
			<%}%>
			<%if(bolShowStart){%>
      <td width="14%" align="center" class="thinborderBOTTOM"><strong>START OF DEDUCTION </strong></td>
			<%}%>
      <td width="14%" align="center" class="thinborderBOTTOM"><strong>AMOUNT</strong></td>
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
	%>
    <tr> 
      <td align="right" class="noBorder"><%=iIncr%>&nbsp;</td>
      <td height="20" class="noBorder">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%>
        <div align="left"></div></td>
			<%if(bolShowSSS){%>
      <td class="noBorder"><span class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+12))%></span></td>
			<%}%>
			<%if(bolShowIssue){%>
      <td class="noBorder"><span class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%></span></td>
			<%}%>
			<%if(bolShowStart){%>
      <td class="noBorder"><span class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+15))%></span></td>
			<%}%>
      <% 
		strTemp = (String)vRetResult.elementAt(i+10);
		dPageTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		dGrandTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
	  %>
      <td align="right" class="noBorder"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%>&nbsp;&nbsp;</td>
    </tr>
    <%} // end for loop%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <%if (iNumRec >= vRetResult.size()) {%>
    <tr>
      <td colspan="6" class="thinborder"><hr size="1" color="#000000"></td>
    </tr>
    <tr> 
      <td width="10%"  class="noBorder">&nbsp;</td>
      <td colspan="4" align="right"  class="noBorder">Page 
      Total&nbsp;: </td>
      <td width="14%"  class="noBorder"><div align="right"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;&nbsp;</div></td>
    </tr>
    <tr>
      <td class="noBorder">&nbsp;</td>
      <td colspan="4" align="right" class="noBorder">&nbsp;</td>
      <td class="noBorder">&nbsp;</td>
    </tr>
    <tr> 
      <td  class="noBorder">&nbsp;</td>
      <td colspan="4" align="right"  class="noBorder">Grand Total&nbsp;:</td>
      <td  class="noBorder"><div align="right"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;&nbsp;</div></td>
    </tr>
    <tr> 
      <td  class="noBorder">&nbsp;</td>
      <td colspan="4" align="right"  class="noBorder">Number of Payees : </td>
      <td  class="noBorder"><div align="right"><%=iIncr-1%>&nbsp;&nbsp;</div></td>
    </tr>
    <tr> 
      <td colspan="6"  class="noBorder"><div align="center">*** 
          NOTHING FOLLOWS ***</div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td  class="noBorder">&nbsp;</td>
      <td colspan="4" align="right"  class="noBorder">Page Total&nbsp;: </td>
      <td  class="noBorder"><div align="right"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;&nbsp;</div></td>
    </tr>
    <tr> 
      <td colspan="6"  class="noBorder"><div align="center">*** 
          CONTINUED ON NEXT PAGE ***</div></td>
    </tr>
    <%}//end else%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>
	<%if(WI.fillTextValue("prepared_by").length() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>Prepared by : </td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="27%" height="31" align="center" valign="bottom" class="thinborderBOTTOM"><%=WI.fillTextValue("prepared_by")%></td>
    <td width="73%">&nbsp;</td>
  </tr>
  <tr>
    <td align="center">&nbsp;HR/Payroll Officer</td>
    <td>&nbsp;</td>
  </tr>
</table>
 <%}%>
<%} //end end upper most if (vRetResult !=null)%>
 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>