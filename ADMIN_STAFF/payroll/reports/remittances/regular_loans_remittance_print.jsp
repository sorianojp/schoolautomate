<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAG IBIG loans remittance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
TD.thinborderLEFT {
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderLEFTRIGHT {
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderLEFT {
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOM{
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTRIGHT{
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLEFTRIGHT{
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOP{
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOPLEFT{
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOPBOTTOMLEFT{
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOPBOTTOMLEFTRIGHT{
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderLEFT{
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderTOPLEFTRIGHT{
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}


</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./hdmf_loans_remittance_print.jsp">
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
								"Admin/staff-PAYROLL-REPORTS-sss_monthlyLoanRemit","hdmf_loans_remittance_print.jsp");
								
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
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"hdmf_loans_remittance_print.jsp");
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
	Vector vEmployerInfo = null;
	PRRemittance PRRemit = new PRRemittance(request);
	double dTemp = 0d;	
	double dPageTotal = 0d;
	double dGrandTotal = 0d;
	String strEmpType = "5";
	boolean bolShowIssue = WI.fillTextValue("date_issued").length() > 0;
	boolean bolShowStart = WI.fillTextValue("date_start").length() > 0;
	
	String[] astrMonth = {"January","February","March","April","May","June","July",
						  "August", "September","October","November","December"};
						  
	String[] astrPtFt = {"PART-TIME","FULL-TIME"};
	String[] astrRemarks = {"A", "B", "C", "D", "E", ""};
	String[] astrMeaning = {"Resigned/Separated", "Deceased", "Retired", "On Leave", "Others", ""};
	String strSchCode = dbOP.getSchoolIndex();	
	String strCodeIndex = WI.fillTextValue("code_index");
	String strLoanName = null;
	  if(strCodeIndex.length() > 0){
		 strLoanName = dbOP.mapOneToOther("ret_loan_code","code_index",WI.fillTextValue("code_index"),
										 "loan_name","");
	  }		
	vRetResult = PRRemit.RegularMonthlyLoan(dbOP);
	vEmployerInfo = PRRemit.operateOnEmployerProfile(dbOP,4);
	if (vRetResult != null) {	
	if(vEmployerInfo != null && vEmployerInfo.size() > 0)
		strEmpType = (String)vEmployerInfo.elementAt(0);
	
	int i = 0; int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		
	
	String strSalPeriod = null;
	if(vRetResult != null && vRetResult.size() > 0) {
		//I have to now find salary period range. 
		String strSQLQuery    = "select period_from, period_to from pr_edtr_sal_period where sal_period_index = "+WI.fillTextValue("sal_period_index");
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next())
			strSalPeriod = ConversionTable.convertMMDDYYYY(rs.getDate(1)) + " - "+ConversionTable.convertMMDDYYYY(rs.getDate(2));
		rs.close();
	}



	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(15*iMaxRecPerPage);	
	if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){	   
	   dPageTotal = 0d;
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <%if(strSchCode.startsWith("LCP")){%>
    <tr>
      <td height="18">&nbsp;</td>
      <td align="center">Republic of the Philippines </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td align="center">Department of Health </td>
      <td>&nbsp;</td>      
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td align="center">LUNG CENTER OF THE PHILS. </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td align="center">LUNG CENTER OF THE PHILIPPINES</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td align="center">Quezon Avenue, Quezon City </td>
      <td>&nbsp;</td>
    </tr>
	<%}else{%>
    <tr>
      <td height="18">&nbsp;</td>
      <td align="center"></strong><br>
      <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
      <td>&nbsp;</td>
    </tr>
	<%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    
    <tr>
      <td height="18">&nbsp;</td>
      <td align="center"><strong><%=(WI.getStrValue(strLoanName,"")).toUpperCase()%> LOAN</strong></td>
      <td>&nbsp;</td>
    </tr>		
    
    <tr>
      <td  width="15%" height="18" valign="bottom">&nbsp;</td>
      <td width="70%" height="18" valign="bottom">&nbsp;</td>
      <td width="15%" height="18" valign="bottom">Page: <%=iPage%> of <%=iTotalPages%>&nbsp;&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom"><div align="center"><strong><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%>, <%=WI.fillTextValue("year_of")%>
	  <br>
	  <%=WI.getStrValue(strSalPeriod, "&nbsp;")%>
	  </strong></div></td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>   
  <%=SchoolInformation.getSchoolName(dbOP,true,false)%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      
  <tr>
  	<td height="" align="center" class="thinborderBOTTOMLEFT">&nbsp;</td>
  	<td height="" align="center" class="thinborderBOTTOMLEFT"><strong>LOAN NAME </strong></td>
    <td height="27" colspan="2" align="center" class="thinborderBOTTOMLEFT">EMPLOYEE NAME</td>
		<%if(bolShowIssue){%>
    <td width="10%" align="center" class="thinborderBOTTOMLEFT">DATE ISSUED</td>
		<%}%>
		<%if(bolShowStart){%>
    <td width="10%" align="center" class="thinborderBOTTOMLEFT">START OF DEDUCTION</td>
		<%}%>
    <td width="10%" align="center" class="thinborderBOTTOMLEFT">Amount Remitted</td>
    <td width="11%" align="center" class="thinborderBOTTOMLEFTRIGHT">Installment Number</td>
  </tr>

    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=15,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
<tr>
   	<td width="5%" height="23" class="thinborderLEFT">
		&nbsp;&nbsp;<%=iIncr%>. 
	</td>
	<td width="28%" height="23" class="thinborderLEFT">
		&nbsp;&nbsp; <%= vRetResult.elementAt(i+14).toString().toUpperCase() %>
	</td>
   <td height="18" colspan="2" class="thinborderLEFT">&nbsp;<font size="1">&nbsp; <%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></font></td>
		<%if(bolShowIssue){%>							
    <td align="right" class="thinborderLEFT"><span class="thinborderLEFTRIGHT"><%=(String)vRetResult.elementAt(i+12)%>&nbsp;</span></td>
		<%}%>
		<%if(bolShowStart){%>
    <td align="right" class="thinborderLEFT"><span class="thinborderLEFTRIGHT"><%=(String)vRetResult.elementAt(i+13)%>&nbsp;</span></td>
		<%}%>
    <%  dTemp = 0d;
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+10),",","");
		dTemp = Double.parseDouble(strTemp);
		dPageTotal += dTemp;
	%>
    <td align="right" class="thinborderLEFT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
	<td align="right" class="thinborderLEFTRIGHT"><%=(String)vRetResult.elementAt(i+11)%>&nbsp;</td>
    </tr>
	 <%}// end for%>   
  </table>   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	  
    <tr> 
      <td height="24" colspan="2" align="center" class="thinborderTOPBOTTOMLEFT">P A G E &nbsp;&nbsp;&nbsp;T O T A L </td>
      <%
	  	dGrandTotal += dPageTotal;
	  %>
      <td width="12%" align="right" class="thinborderTOPBOTTOMLEFT"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;</td>
      <td width="13%" class="thinborderTOPBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>	
	<%if ( iNumRec >= vRetResult.size()) {%>    	
    <tr>
      <td height="24" colspan="2" align="center" class="thinborderLEFT">G R A N D&nbsp; &nbsp;&nbsp;T O T A L </td>
      <td align="right" class="thinborderLEFT"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</td>
      <td class="thinborderLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td height="24" colspan="2" class="thinborderTOP">&nbsp;</td>
      <td colspan="2" class="thinborderTOP">CERTIFIED CORRECT BY: </td>
    </tr>
    <tr>
      <td height="24" colspan="2">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
	
	<%}%>
  </table>
  <%if (iNumRec < vRetResult.size()){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>

  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>