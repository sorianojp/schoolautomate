<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAG IBIG loans remittance</title>
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
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./hdmf_remittance_print2_uph.jsp">
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
	double dLineTotal  = 0d;
	double dEETotal = 0d;
	double dERTotal = 0d;
	double dEEGrandTotal = 0d;
	double dERGrandTotal = 0d;

	String strEmpType = "5";
	
	String[] astrMonth = {"January","February","March","April","May","June","July",
						  "August", "September","October","November","December"};
						  
	String[] astrPtFt = {"PART-TIME","FULL-TIME"};
	String[] astrRemarks = {"A", "B", "C", "D", "E", ""};
	String[] astrMeaning = {"Resigned/Separated", "Deceased", "Retired", "On Leave", "Others", ""};
	vRetResult = PRRemit.HDMFMonthlyPremium(dbOP);

	if(vRetResult != null && vRetResult.size() > 0){
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strEmpType = (String)vEmployerInfo.elementAt(2);
		
		int i = 0; 
		int iPage = 1; 
		int iCount = 0;
		int iRowCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			
		int iPageCount =0;
		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(16*iMaxRecPerPage);	
	    if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
		
		String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
		String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);
	 for (;iNumRec < vRetResult.size();iPage++){
	   dPageTotal = 0d;
	   dEETotal = 0d;
	   dERTotal = 0f;
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
		<td align="center">
		<strong><%=strSchName%><br>
		<%=strSchAddr%><br><br>
		PAG-IBIG CONTRIBUTION PREMIUM REMITTANCE<br>
		For the month of <u><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))].toUpperCase()%> <%=WI.fillTextValue("year_of")%></u>
		</strong>
		</td>
	</tr>
	<tr >
        <td height="20" colspan="5" align="right"><font size="1">Page <%=++iPageCount%> of <%=iTotalPages%></font></td>
    </tr>
  </table> 
  
  
  
    
      
  <table bgcolor="#FFFFFF" width="100%" class="thinborder" border="0" cellspacing="0" cellpadding="0">
  <tr>
		<td width="9%" height="20" align="center" class="thinborderBOTTOMLEFT">EMPLOYEE ID</td>
		<td width="11%" align="center" class="thinborderBOTTOMLEFT">HDMF ID</td>
		<td width="13%" align="center" class="thinborderBOTTOMLEFT">LAST NAME</td>
		<td width="12%" align="center" class="thinborderBOTTOMLEFT">FIRST NAME</td>
		<td width="14%" align="center" class="thinborderBOTTOMLEFT">MIDDLE NAME</td>
		<td width="10%" align="center" class="thinborderBOTTOMLEFT">BIRTH DATE</td>
		<td width="11%" align="center" class="thinborderBOTTOMLEFT">TIN #</td>
		<td width="6%" align="center" class="thinborderBOTTOMLEFT">EE</td>
		<td width="6%" align="center" class="thinborderBOTTOMLEFT">ER</td>
		<td width="8%" align="center" class="thinborderBOTTOMLEFT">TOTAL</td>
	</tr>
  
    <% 
		for(iCount = 1, iRowCount = 1; iNumRec<vRetResult.size(); iNumRec+=16,++iIncr, ++iCount, ++iRowCount){
		dLineTotal = 0d;
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
	<tr>
  	    <td height="20" align="" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+3)).toUpperCase()%></td>
		<%
		strTemp = "&nbsp;";
		if((String)vRetResult.elementAt(i+12) != null)
			strTemp = ((String)vRetResult.elementAt(i+12)).toUpperCase();
		%>
  	    <td align="" class="thinborderBOTTOMLEFT"><%=strTemp%></td>
  	    <td align="" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
  	    <td align="" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
  	    <td align="" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+5)).toUpperCase()%></td>
  	    <td align="" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+14)).toUpperCase()%></td>
		<%
		strTemp = "&nbsp;";
		if((String)vRetResult.elementAt(i+13) != null)
			strTemp = ((String)vRetResult.elementAt(i+13)).toUpperCase();
		%>
  	    <td align="" class="thinborderBOTTOMLEFT"><%=strTemp%></td>
		<% 
		strTemp = (String)vRetResult.elementAt(i+10);		
		%>
  	    <td class="thinborderBOTTOMLEFT" align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
		<% 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dEETotal += dTemp;
		dLineTotal += dTemp;		
	
		strTemp = (String)vRetResult.elementAt(i+11);
		%>	
  	    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strTemp,true)%></td>
		<% 
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+11),",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dERTotal += dTemp;
		dLineTotal += dTemp;
		dPageTotal += dLineTotal;
		%>	
  	    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
  	    </tr>
	<%}for(;iCount<iMaxRecPerPage; ++iCount){%>
	<!--<tr>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td height="18" colspan="3" class="thinborderBOTTOM">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
	</tr>-->	
   	<%}// inner for loop%>
    <!--<tr> 
      <td colspan="2" class="thinborderBOTTOMLEFT"><span class="thinborderNone">&nbsp;&nbsp;No. of Employees on this page</span></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=iRowCount-1%>&nbsp;&nbsp;</td>
      <td width="27%" height="24" class="thinborderBOTTOMLEFT">TOTAL FOR THIS PAGE ---------&gt; </td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dEETotal,true)%>&nbsp;</td>
	  <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dERTotal,true)%>&nbsp;</td>
	  <%
	  	dEEGrandTotal += dEETotal;
		dERGrandTotal += dERTotal;
	  	dGrandTotal += dPageTotal;
	  %>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;</td>
    </tr>-->
	<%if (iNumRec >= vRetResult.size()){%>		
    <tr>
      <td height="20" colspan="9" class="thinborderBOTTOMLEFT" align="right"><strong>GRAND TOTAL &nbsp;</strong></td>
	  <%strTemp = Integer.toString(iIncr-1);%>	  
      <% strTemp = CommonUtil.formatFloat(dEEGrandTotal,true); %>
	  <% strTemp = CommonUtil.formatFloat(dERGrandTotal,true); %>
      <% strTemp = CommonUtil.formatFloat(dGrandTotal,true); %>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%>&nbsp;</td>
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