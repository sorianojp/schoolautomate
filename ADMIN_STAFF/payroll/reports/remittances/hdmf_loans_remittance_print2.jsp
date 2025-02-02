<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAG IBIG loans remittance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
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
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
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
			

		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = (vRetResult.size()-1)/(20*iMaxRecPerPage);
	  if((vRetResult.size()-1) % (20*iMaxRecPerPage) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){	   
	   dPageTotal = 0d;
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    
    <tr>
      <td width="7%" height="25">&nbsp;</td>
      <td width="9%" height="25">&nbsp;</td>
      <td height="25" colspan="4"><div align="center"><strong><font size="+1">MONTHLY REMITTANCE SCHEDULE</font></strong></div></td>
      <td width="8%" height="25">&nbsp;</td>
      <td width="8%" height="25"><strong><font size="+1">HDMF</font></strong></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="4"><div align="center"><strong>FOR <%=(WI.getStrValue(strLoanName,"")).toUpperCase()%> LOAN</strong></div></td>
      <td height="18">&nbsp;</td>      
      <td height="18"><div align="center"><strong>P2-4</strong></div></td>
    </tr>		
    <tr >
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4" rowspan="3">
	    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
		 <%
		 if(strEmpType.equals("1"))
			strTemp = "X";
		 else
			strTemp = "&nbsp;";
		 %>			
          <td height="20" class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
          <td class="thinborderNone">PRIVATE EMPLOYER </td>
		 <%
		 if(strEmpType.equals("3"))
			strTemp = "X";
		 else
			strTemp = "&nbsp;";
		 %>					  
          <td class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
          <td class="thinborderNone"> GOVERNMENT CONTROLLED CORP. </td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
		 <%
		 if(strEmpType.equals("2"))
			strTemp = "X";
		 else
			strTemp = "&nbsp;";
		 %>					
          <td width="6%" height="20" class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>		  
          <td width="43%" class="thinborderNone">LOCAL GOVERNMENT UNIT </td>
		 <%
		 if(strEmpType.equals("4"))
			strTemp = "X";
		 else
			strTemp = "&nbsp;";
		 %>			

          <td width="6%" class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
          <td width="45%" class="thinborderNone">NATIONAL GOVERNMENT AGENCY </td>
        </tr>
       </table>	  </td>
      <td height="20" class="thinborder"><strong>MONTH</strong></td>
      <td height="20" class="thinborderBOTTOMTOPRIGHT"><strong>YEAR</strong></td>
    </tr>
    <tr >
      <td height="18" colspan="2" class="thinborderNone">&nbsp;</td>
      <td rowspan="2" class="thinborderBOTTOMLEFT"><div align="center"><strong><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%></strong></div></td>
      <td rowspan="2" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><strong><%=WI.fillTextValue("year_of")%></strong></div></td>
    </tr>
    <tr >
      <td height="18" colspan="2" valign="bottom" class="thinborderNone">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderNone">&nbsp;</td>
      <td width="11%" class="thinborderBOTTOM"><div align="center">&nbsp;</div></td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td width="12%" class="thinborderBOTTOM"><div align="center">&nbsp;</div></td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderNone">NAME OF EMPLOYER</td>
      <td width="11%" rowspan="2" class="thinborderBOTTOMLEFT"><div align="center">FOR PRIVATE<br>
      EMPLOYER</div></td>
      <td width="14%" class="thinborderLEFT"><div align="left">EMPLOYER SSS NO.</div></td>
      <td width="12%" rowspan="2" class="thinborderBOTTOMLEFTRIGHT"><div align="center">FOR GOV'T <br>
      EMPLOYER</div></td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
    </tr>
    <tr >
      <td height="18" valign="bottom" class="thinborderNone">&nbsp;</td>
        <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(12);
        else
	        strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
        %>				
      <td height="18" colspan="2" valign="bottom" class="thinborderBOTTOM">&nbsp;<strong>&nbsp;<%=strTemp%></strong></td>
			<%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String)vEmployerInfo.elementAt(6);
				else
					strTemp = "";
			%>		  
      <td class="thinborderBOTTOMLEFT"><div align="left">&nbsp;<%=strTemp%></div></td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
    </tr>
    <tr >
      <td height="18" colspan="4" valign="bottom" class="thinborderNone">ADDRESS OF EMPLOYER</td>
      <td class="thinborderLEFT">ZIP CODE </td>
      <td height="18" colspan="2" class="thinborderLEFT">TELEPHONE NO/S.</td>
      <td class="thinborderNone">&nbsp;</td>
    </tr>
    <tr >
      <td height="18" valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(3);
        else
	        strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
		  %>	
      <td height="18" colspan="3" valign="bottom" class="thinborderBOTTOM">&nbsp;<strong><%=strTemp%></strong></td>
			<%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String)vEmployerInfo.elementAt(4);
				else
					strTemp = "";
			%>			  
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp%></td>
			<%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String)vEmployerInfo.elementAt(5);
				else
					strTemp = "";
			%>		    
      <td height="18" colspan="2" class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp%></td>
      <td class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="9%" rowspan="2" class="thinborderBOTTOMLEFT">Pag-IBIG ID No.</td>
    <td width="9%" rowspan="2" class="thinborderBOTTOMLEFT">Promissory Note </td>
    <td height="19" colspan="5" align="center" class="thinborderBOTTOMLEFT"><strong>NAME   &nbsp; OF &nbsp;   BORROWER </strong></td>
    <td width="12%" rowspan="2" align="center" class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOM"><strong>MONTHLY AMORTIZATION</strong></span></td>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFT"><strong>USE CODE </strong></td>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<strong>REMARKS</strong></td>
  </tr>    
  <tr>
    <td height="27" colspan="3" align="center" class="thinborderBOTTOMLEFT"><strong>FAMILY NAME </strong></td>
    <td width="20%" align="center" class="thinborderBOTTOMLEFT"><strong>FIRST NAME  </strong></td>
    <td width="13%" align="center" class="thinborderBOTTOMLEFT"><strong>MIDDLE NAME </strong></td>
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
	<% 	try{ %>
  <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
  <td class="thinborderBOTTOMLEFT"><div align="center">-</div></td>
    <td width="3%" class="thinborderBOTTOMLEFT"><%=iIncr%></td>
    <td height="18" colspan="2" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
	<%
		strTemp = (String)vRetResult.elementAt(i+5);
	%>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=(WI.getStrValue(strTemp)).toUpperCase()%></td>
	<%
		strTemp = (String)vRetResult.elementAt(i+11);
	%>
    <%  dTemp = 0d;
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+10),",","");
		dTemp = Double.parseDouble(strTemp);
		dPageTotal += dTemp;
	%>
    <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"5");
	%>	
    <td class="thinborderBOTTOMLEFT"><strong>&nbsp;<%=astrRemarks[Integer.parseInt(strTemp)]%></strong></td>
    <td class="thinborderBOTTOMLEFTRIGHT"><strong>&nbsp;<%=astrMeaning[Integer.parseInt(strTemp)]%></strong></td>  
	<% }catch( Exception e ){ e.printStackTrace(); } %>
    </tr>
	 <%}for(;iCount<iMaxRecPerPage; ++iCount){%>
	<tr>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td height="18" colspan="2" class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
	</tr>
   	<%}// inner for loop%>
    <%//if ( iNumRec >= vRetResult.size()) {%>    	
    <tr> 
      <td height="24" colspan="5" class="thinborderBOTTOMLEFT"><div align="right">&nbsp;</div></td>
      <td height="24" class="thinborderBOTTOMLEFT">TOTAL FOR THIS PAGE </td>
      <td height="24" class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <%
	  	dGrandTotal += dPageTotal;
	  %>
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;</div></td>
      <td colspan="2" rowspan="4"  class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td colspan="3"><div align="center"><strong>CODES</strong></div></td>
          </tr>
          <tr>
            <td width="20%" class="thinborderNone"><div align="center">A</div></td>
            <td width="12%" class="thinborderNone">-</td>
            <td width="68%" class="thinborderNone">Resigned/ Separated </td>
          </tr>
          <tr>
            <td class="thinborderNone"><div align="center">B</div></td>
            <td class="thinborderNone">-</td>
            <td class="thinborderNone">Deceased</td>
          </tr>
          <tr>
            <td class="thinborderNone"><div align="center">C</div></td>
            <td class="thinborderNone">-</td>
            <td class="thinborderNone">Retired</td>
          </tr>
          <tr>
            <td class="thinborderNone"><div align="center">D</div></td>
            <td class="thinborderNone">-</td>
            <td class="thinborderNone">Leave w/o pay </td>
          </tr>
          <tr>
            <td class="thinborderNone"><div align="center">E</div></td>
            <td class="thinborderNone">-</td>
            <td class="thinborderNone">Others</td>
          </tr>		  		  		  
      </table></td>
    </tr>    
	<%//}%>
    <tr>
      <td height="24" colspan="5" class="thinborderBOTTOMLEFT"><div align="center">FOR PAG-IBIG USE ONLY </div></td>
      <td height="24" class="thinborderBOTTOMLEFT">GRAND TOTAL (If last page) </td>
      <td height="24" class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <%
	  	if (iNumRec >= vRetResult.size())
			strTemp = CommonUtil.formatFloat(dGrandTotal,true);
		else
			strTemp = "-";
	  %>
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=strTemp%>&nbsp;</div></td>
    </tr>
    <tr>
      <td class="thinborderBOTTOMLEFT">PFR NO.</td>
      <td colspan="3" class="thinborderBOTTOMLEFT">DATE</td>
      <td width="9%" height="24" class="thinborderBOTTOMLEFT">AMOUNT</td>
      <td height="24" colspan="3" class="thinborderBOTTOMLEFT"><div align="center"><strong>CERTIFIED CORRECT BY:</strong></div></td>
    </tr>
    <tr>
      <td height="28" colspan="4" valign="top" class="thinborderBOTTOMLEFT">COLLECTING BANK</td>
      <td height="28" valign="top" class="thinborderBOTTOMLEFT">REMARKS</td>
      <td colspan="3" rowspan="3" valign="top" class="thinborderNone"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="55%" height="28" valign="bottom" class="thinborderBOTTOMLEFT">SIGNATURE OVER PRINTED NAME</td>
            <td width="45%" valign="bottom" class="thinborderBOTTOM"><strong>&nbsp;<%=WI.fillTextValue("signatory").toUpperCase()%>
            </strong></td>
          </tr>
          <tr>
            <td height="18" class="thinborderLEFT">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td height="22" class="thinborderBOTTOMLEFT">OFFICIAL DESIGNATION </td>
            <td class="thinborderBOTTOM">&nbsp;<strong><%=WI.fillTextValue("designation")%></strong></td>
          </tr>
        </table></td>
    </tr>
    <tr>
      <td colspan="5" rowspan="2" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td class="thinborderBOTTOMLEFT">PAGE NO </td>
      <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;NO OF PAGES</td>
    </tr>
    <tr>
      <td width="6%" class="thinborderBOTTOMLEFT"><%=iPage%></td>
      <td width="10%" class="thinborderBOTTOMLEFTRIGHT"><%=iTotalPages%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
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