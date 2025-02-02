<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAG IBIG loans remittance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 

Table.thinborder {
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

TD.thinborder{
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./hdmf_loans_remittance_print2_uph.jsp">
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
	String strCodeIndex = WI.fillTextValue("code_index");
	String strLoanName = null;
	  if(strCodeIndex.length() > 0){
		 strLoanName = dbOP.mapOneToOther("ret_loan_code","code_index",WI.fillTextValue("code_index"),
										 "loan_name","");
	  }	
	vRetResult = PRRemit.HDMFMonthlyLoan(dbOP);
	if (vRetResult != null) {	
		vEmployerInfo = (Vector)vRetResult.elementAt(0);	
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strEmpType = (String)vEmployerInfo.elementAt(2);
		
		int i = 0; int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			
		int iPageCount = 0;
		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = (vRetResult.size()-1)/(20*iMaxRecPerPage);
		
	  	if((vRetResult.size()-1) % (20*iMaxRecPerPage) > 0) ++iTotalPages;
	  
	  String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
	  String strSchAddr = SchoolInformation.getAddressLine1(dbOP,false,false);
	 for (;iNumRec < vRetResult.size();iPage++){	   
	   dPageTotal = 0d;
%>


	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font size="2"><strong>        
        <%=strSchName%><br><%=strSchAddr%></strong><br><br>       
      </font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5"><div align="center"><strong>PAG-IBIG SALARY LOAN REPORT<br>
            For the month of <u><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))].toUpperCase()%> <%=WI.fillTextValue("year_of")%></u></strong></div></td>
    </tr>
    <tr >
        <td height="20" colspan="5" align="right"><font size="1">Page <%=++iPageCount%> of <%=iTotalPages%></font></td>
    </tr>
  </table>
   
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	
	

  <tr>
		<td width="10%" height="20" align="center" class="thinborder">EMPLOYEE ID</td>
		<td width="11%" align="center" class="thinborder">HDMF ID</td>
		<td width="11%" align="center" class="thinborder">LAST NAME</td>
		<td width="11%" align="center" class="thinborder">FIRST NAME</td>
		<td width="12%" align="center" class="thinborder">MIDDLE NAME</td>
		<td width="12%" align="center" class="thinborder">BIRTH DATE</td>
		<td width="11%" align="center" class="thinborder">TIN #</td>
		<td width="13%" align="center" class="thinborder">PERIOD COVERAGE</td>
		<td width="9%" align="center" class="thinborder">AMORTIZATION</td>
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
	    <td class="thinborder" height="20"><%=((String)vRetResult.elementAt(i+3)).toUpperCase()%></td>
		<%
		strTemp = "&nbsp;";
		if((String)vRetResult.elementAt(i+11) != null)
			strTemp = ((String)vRetResult.elementAt(i+11)).toUpperCase();
		%>
	    <td class="thinborder"><%=strTemp%></td>
	    <td class="thinborder"><%=((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
	    <td class="thinborder"><%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
	    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5)).toUpperCase()%></td>
	    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+15)).toUpperCase()%></td>
	    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+14)).toUpperCase()%></td>
	    <td class="thinborder">&nbsp;</td>
		<%  
		dTemp = 0d;
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+10),",","");
		dTemp = Double.parseDouble(strTemp);
		dGrandTotal += dTemp;
		%>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(strTemp,true)%></td>
	    </tr>
<%

if (iNumRec + 20 >= vRetResult.size()){%>
	<tr>
	    <td class="thinborder" height="20" align="right" colspan="8"><strong>GRAND TOTAL </strong>&nbsp;</td>
	    <td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dGrandTotal,true)%></strong></td>
	    </tr>
<%}%>
	
	
	 <%}// inner for loop%>    
    
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