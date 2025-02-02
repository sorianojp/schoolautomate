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
			

		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(16*iMaxRecPerPage);	
	    if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	   dPageTotal = 0d;
	   dEETotal = 0d;
	   dERTotal = 0f;
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    
    <tr>
      <td width="79%" height="16"><div align="center"><strong><font size="2">MONTHLY COLLECTION LIST </font></strong></div></td>
    </tr>
    <tr>
	 <%
	 if(strEmpType.equals("1"))
		strTemp = "FOR PRIVATE EMPLOYER";
	 else
		strTemp = "FOR GOVERNMENT EMPLOYER";
	 %>		
      <td height="18" valign="bottom"><div align="center"><%=strTemp%></div></td>
    </tr>
    <tr>
	  <%
		 if(strEmpType.equals("2"))
			strTemp = "LOCAL GOVERNMENT UNIT";
		 else if(strEmpType.equals("3"))
			strTemp = "GOVERNMENT CONTROLLED CORP.";
		 else if(strEmpType.equals("4"))
			strTemp = "NATIONAL GOVERNMENT AGENCY ";				
		 else
			strTemp = "";			 	
	  %>		
      <td height="18" valign="bottom"><div align="center"><%=WI.getStrValue(strTemp, "<<< "," >>>","&nbsp;")%></div></td>
    </tr>
  </table>   
   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderNone">&nbsp;</td>
      <td width="17%" height="18" align="center" class="thinborderTOPLEFT"><strong>MONTH</strong></td>
      <td width="15%" align="center" class="thinborderTOPRIGHT"><strong>YEAR</strong></td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
      <td height="18" class="thinborderBOTTOMLEFT"><div align="center"><strong><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%></strong></div></td>
      <td class="thinborderBOTTOMRIGHT"><div align="center"><strong class="thinborderRIGHT"><%=WI.fillTextValue("year_of")%></strong></div></td>
    </tr>
    <tr>
      <td width="3%" height="18" valign="bottom" class="thinborderLEFT">&nbsp;</td>
      <td height="18" colspan="2" valign="bottom" class="thinborderNone">NAME OF EMPLOYER</td>
      <td height="18" class="thinborderLEFT">&nbsp;&nbsp;AGENCY CODE </td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(10);
        else
	        strTemp = "";
		  %>				
      <td height="18" class="thinborderRIGHT">&nbsp;<%=WI.getStrValue(strTemp)%></td>
    </tr>
    <tr >
      <td valign="bottom" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td width="2%" valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
        <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(12);
        else
	        strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
        %>		
      <td width="63%" height="18" valign="bottom" class="thinborderBOTTOM">&nbsp;<strong>&nbsp;<%=strTemp%></strong></td>
	<%
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strTemp = (String)vEmployerInfo.elementAt(4);
		else
			strTemp = "";
	%>		  
      <td height="18" colspan="2" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
     </tr>
    <tr >
      <td height="18" valign="bottom" class="thinborderLEFT">&nbsp;</td>
      <td height="18" colspan="2" valign="bottom" class="thinborderNone">ADDRESS OF EMPLOYER</td>
      <td height="18" class="thinborderLEFT">&nbsp;&nbsp;REGION CODE </td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(11);
        else
	        strTemp = "";
		  %>		
      <td class="thinborderRIGHT">&nbsp;<%=WI.getStrValue(strTemp)%></td>
    </tr>
    <tr >
      <td valign="bottom" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(3);
        else
	        strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
		  %>	
      <td height="18" valign="bottom" class="thinborderBOTTOM">&nbsp;<strong>&nbsp;<%=strTemp%></strong></td>			  
      <td height="18" colspan="2" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
     </tr>
  </table>   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="4" rowspan="2" align="center" class="thinborderBOTTOMLEFT">NAME OF &nbsp;EMPLOYEES</td>
    <td height="19" colspan="3" align="center" class="thinborderBOTTOMLEFTRIGHT">C O N T R I B U T I O N S</td>
    </tr>    
  <tr>
    <td width="13%" height="27" align="center" class="thinborderBOTTOMLEFT">EMPLOYEE</td>
    <td width="13%" align="center" class="thinborderBOTTOMLEFT">EMPLOYER</td>
    <td width="13%" align="center" class="thinborderBOTTOMLEFTRIGHT">TOTAL</td>
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
  <%
		strTemp = (String)vRetResult.elementAt(i+14);
		strTemp += " --<br>" + WI.getStrValue((String)vRetResult.elementAt(i+12),"");
	%>  
  <td width="6%" class="thinborderBOTTOMLEFT"><div align="right"><%=iIncr%>. &nbsp;</div></td>
    <td height="18" colspan="3" class="thinborderBOTTOM">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%>&nbsp;&nbsp;</td>
    <% 
		strTemp = (String)vRetResult.elementAt(i+10);		
	%>	
	<td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	<% 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dEETotal += dTemp;
		dLineTotal += dTemp;		
	%>
	<% 
		strTemp = (String)vRetResult.elementAt(i+11);
	%>	
	<td width="13%" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	<% 
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+11),",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dERTotal += dTemp;
		dLineTotal += dTemp;
		dPageTotal += dLineTotal;
	%>		
    <td class="thinborderBOTTOMLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</div></td>
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15),"5");
	%>	
    </tr>
	<%}for(;iCount<iMaxRecPerPage; ++iCount){%>
	<tr>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td height="18" colspan="3" class="thinborderBOTTOM">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
	</tr>	
   	<%}// inner for loop%>
    <tr> 
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
    </tr>
	<%if (iNumRec >= vRetResult.size()){%>		
    <tr>
      <td colspan="2" class="thinborderBOTTOMLEFT"><span class="thinborderNone">&nbsp;&nbsp;Total Employees if last page</span></td>
	  <%strTemp = Integer.toString(iIncr-1);%>	  
      <td width="6%" align="right" class="thinborderBOTTOMLEFT"><span class="thinborderNone"><%=strTemp%></span>&nbsp;&nbsp;</td>
      <td height="24" class="thinborderBOTTOMLEFT">GRAND TOTAL -------------------&gt; </td>
      <% strTemp = CommonUtil.formatFloat(dEEGrandTotal,true); %>
	  <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
	  <% strTemp = CommonUtil.formatFloat(dERGrandTotal,true); %>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <% strTemp = CommonUtil.formatFloat(dGrandTotal,true); %>
      <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%>&nbsp;</td>
    </tr>
	<%}%>
    <tr>
      <td colspan="3">&nbsp;</td>
      <td height="58" colspan="4">
	   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td height="24" colspan="3" align="center"><strong>CERTIFIED CORRECT BY:</strong></td>
          </tr>
        <tr>
          <td height="24" align="center" valign="bottom">&nbsp;</td>
          <td height="24" align="center" valign="bottom" class="thinborderBOTTOM"><strong><%=WI.fillTextValue("signatory").toUpperCase()%></strong></td>
          <td height="24" align="center" valign="bottom">&nbsp;</td>
        </tr>
        <tr>
          <td width="20%" height="14" valign="bottom"><div align="center"></div></td>
          <td width="60%" height="14" align="center" valign="bottom">SIGNATURE OVER PRINTED NAME</td>
          <td width="20%" height="14" valign="bottom">&nbsp;</td>
        </tr>      
      </table></td>
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