<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAG IBIG loans remittance printing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
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
TD.thinborderTOPLEFTRIGHT{
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<body  onLoad="javascript:window.print();">
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
	vRetResult = PRRemit.HDMFMonthlyLoan(dbOP);
	if(vRetResult != null && vRetResult.size() > 0){
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strEmpType = (String)vEmployerInfo.elementAt(0);
	
	int i = 0; int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		

	int iNumRec = 1;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size()-1)/(20*iMaxRecPerPage);	
	if((vRetResult.size()-1) % (20*iMaxRecPerPage) > 0) ++iTotalPages;
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
      <td><div align="center">
			<%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);
					strTemp += "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";
				%>
				<%=strTemp%>
				<%}else{%>
				<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
				<%}%>
    </div></td>
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
      <td><div align="center"><strong>PAGIBIG <%=(WI.getStrValue(strLoanName,"")).toUpperCase()%> LOAN</strong></div></td>
      <td>&nbsp;</td>
    </tr>		
    
    <tr>
      <td  width="15%" height="18" valign="bottom">&nbsp;</td>
      <td width="70%" height="18" valign="bottom">&nbsp;</td>
      <td width="15%" height="18" valign="bottom">Page: <%=iPage%> of <%=iTotalPages%>&nbsp;&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom"><div align="center"><strong><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%>, <%=WI.fillTextValue("year_of")%></strong></div></td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      
  <tr>
    <td height="27" colspan="2" align="center" class="thinborderBOTTOMLEFT">EMPLOYEE NAME </td>
    <td width="24%" align="center" class="thinborderBOTTOMLEFT">Amount Remitted </td>
    <td width="22%" align="center" class="thinborderBOTTOMLEFTRIGHT">Installment Number </td>
  </tr>

    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
<tr>
    <%
		strTemp = (String)vRetResult.elementAt(i+11);
	%>	
  <td height="18" colspan="2" class="thinborderLEFT">&nbsp;<font size="1">&nbsp;<%=iIncr%>. <%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></font></td>
    <%  dTemp = 0d;
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+10),",","");
		dTemp = Double.parseDouble(strTemp);
		dPageTotal += dTemp;
	%>
    <td align="right" class="thinborderLEFT"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
	<td align="right" class="thinborderLEFTRIGHT"><%=(String)vRetResult.elementAt(i+13)%>&nbsp;</td>
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"5");
	%>	
    </tr>
	 <%}%>    
    <tr> 
      <td height="24" colspan="2" align="center" class="thinborderTOPLEFT">P A G E &nbsp;&nbsp;&nbsp;T O T A L </td>
      <%
	  	dGrandTotal += dPageTotal;
	  %>
      <td align="right" class="thinborderTOPLEFT"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;</td>
      <td class="thinborderTOPLEFTRIGHT">&nbsp;</td>
    </tr>	
	<%if ( iNumRec >= vRetResult.size()) {%>    	
    <tr>
      <td height="24" colspan="2" align="center" class="thinborderTOPLEFT">G R A N D&nbsp; &nbsp;&nbsp;T O T A L </td>
      <td align="right" class="thinborderTOPLEFT"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</td>
      <td class="thinborderTOPLEFTRIGHT">&nbsp;</td>
    </tr>
	<%}%>
    <tr>
      <td height="24" colspan="2" class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">&nbsp;</td>
      <td class="thinborderTOP">CERTIFIED CORRECT BY: </td>
    </tr>
    <tr>
      <td height="24" colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOM"><strong>&nbsp;<%=WI.fillTextValue("signatory").toUpperCase()%> </strong></td>
    </tr>	
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