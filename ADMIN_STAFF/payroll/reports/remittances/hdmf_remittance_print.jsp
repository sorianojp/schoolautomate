<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAG IBIG loans remittance PRINT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTSmall {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
 <body onLoad="javascript:window.print();">
<form name="form_">
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
	boolean	showHeader = true;
	
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
	double dEEPageTotal = 0d;
	double dERPageTotal = 0d;
	double dGrandTotal = 0d;
	double dEEGrandTotal = 0d;
	double dERGrandTotal = 0d;
	double dLineTotal  = 0d;
	
	double dDeptEEPageTotal = 0d;
	double dDeptERPageTotal = 0d;
	double dDeptPageTotal = 0d;
	
	String strEmpType = "0";
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
		 dEEPageTotal = 0d;
		 dERPageTotal = 0d;
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    
    <tr>
      <td colspan="2" rowspan="4" align="center">&nbsp;</td>
      <td height="25" colspan="4"><div align="center"><strong><font size="+1">MEMBERSHIP REGISTRATION FORM</font></strong></div></td>
      <td>&nbsp;</td>
      <td><strong><font size="+1">HDMF</font></strong></td>
    </tr>
    <tr>
      <td colspan="4" rowspan="3" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
	      <tr>
			 <%
			 if(strEmpType.equals("1"))
				strTemp = "X";
			 else
				strTemp = "&nbsp;";
			 %>			  
	        <td height="18" class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
            <td class="thinborderNone">&nbsp;PRIVATE EMPLOYER </td>
			 <%
			 if(strEmpType.equals("3"))
				strTemp = "X";
			 else
				strTemp = "&nbsp;";
			 %>			  			
            <td class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
            <td class="thinborderNone"> &nbsp;GOVERNMENT CONTROLLED CORP. </td>
          </tr>
	      <tr>
	        <td colspan="4" height="18">&nbsp;</td>
          </tr>
	      <tr>
			 <%
			 if(strEmpType.equals("2"))
				strTemp = "X";
			 else
				strTemp = "&nbsp;";
			 %>			  		  
	        <td width="6%" height="18" class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
           <td width="43%" class="thinborderNone">&nbsp;LOCAL GOVERNMENT UNIT </td>
			 <%
			 if(strEmpType.equals("4"))
				strTemp = "X";
			 else
				strTemp = "&nbsp;";
			 %>			  			
            <td width="6%" class="thinborder"><div align="center"><strong><%=strTemp%></strong></div></td>
            <td width="45%" class="thinborderNone">&nbsp;NATIONAL GOVERNMENT AGENCY </td>
          </tr>
       </table></td>
      <td height="18">&nbsp;</td>      
      <td height="18"><div align="center"><strong>M1-1</strong></div></td>
    </tr>		
    <tr >
      <td height="18" class="thinborder"><strong>MONTH</strong></td>
      <td class="thinborderBOTTOMTOPRIGHT"><strong>YEAR</strong></td>
    </tr>
    <tr >
      <td height="18" align="center" class="thinborderBOTTOMLEFT"><strong><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%></strong></td>
      <td align="center" class="thinborderBOTTOMLEFTRIGHT"><strong><%=WI.fillTextValue("year_of")%></strong></td>
    </tr>
    <tr >
      <td width="8%" height="18">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td colspan="4" valign="top">&nbsp;</td>
      <td width="8%" >&nbsp;</td>
      <td width="8%" >&nbsp;</td>
    </tr>
    
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderNone">&nbsp;</td>
      <td width="14%" class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="3" valign="bottom" class="thinborderNone">NAME OF EMPLOYER</td>
      <td width="14%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">FOR PRIVATE<br>
      EMPLOYER</td>
      <td width="15%" class="thinborderLEFT">EMPLOYER SSS NO.</td>
      <td width="8%" rowspan="2" class="thinborderLEFT">&nbsp;</td>
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
      <td height="18" colspan="2" valign="bottom" class="thinborderBOTTOM"><strong>&nbsp;&nbsp;<%=strTemp%></strong></td>
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
      <td height="18" colspan="3" valign="bottom" class="thinborderNone">ADDRESS OF EMPLOYER</td>
      <td height="18" valign="bottom" class="thinborderNone">TIN</td>
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
      <td height="18" colspan="2" valign="bottom" class="thinborderBOTTOM">&nbsp;<strong><%=strTemp%></strong></td>
	<%
		if(vEmployerInfo != null && vEmployerInfo.size() > 0)
			strTemp = (String)vEmployerInfo.elementAt(7);
		else
			strTemp = "";
	%>		  
      <td height="18" valign="bottom" class="thinborderBOTTOM">&nbsp;<%=strTemp%></td>
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
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFT">TIN</td>
    <td rowspan="2" align="left" class="thinborderBOTTOMLEFT">DATE OF BIRTH / PAG-IBIG NO.</td>
    <td height="19" colspan="4" align="center" class="thinborderBOTTOMLEFT">NAME OF &nbsp;EMPLOYEES</td>
    <td colspan="3" align="center" class="thinborderBOTTOMLEFT">C O N T R I B U T I O N S</td>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong>REMARKS</strong></td>
    </tr>    
  <tr>
    <td height="27" colspan="2" align="center" class="thinborderBOTTOMLEFT">FAMILY NAME </td>
    <td align="center" class="thinborderBOTTOMLEFT">FIRST NAME  </td>
    <td align="center" class="thinborderBOTTOMLEFT">MIDDLE NAME </td>
    <td align="center" class="thinborderBOTTOMLEFT">EMPLOYEE</td>
    <td align="center" class="thinborderBOTTOMLEFT">EMPLOYER</td>
    <td align="center" class="thinborderBOTTOMLEFT">TOTAL</td>
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
	
	<%
		if(WI.fillTextValue("by_dept").length() > 0 ){
			if(showHeader){
				showHeader = false;
	%>
  	<tr>
		<td colspan="10" height="23" class="thinborderBOTTOMLEFTRIGHT">&nbsp;
			<font size="1">
				<strong><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","",(String)vRetResult.elementAt(i+8))%></strong>
			</font>
		</td>
	</tr>
			<%}   
		}%>
		
	<%
		if( i+16 < vRetResult.size() ){
			if( !((String)vRetResult.elementAt(i+1)).equals((String)vRetResult.elementAt(i+17))  
					|| !((String)vRetResult.elementAt(i+2)).equals((String)vRetResult.elementAt(i+18)) )
				showHeader = true;
		}			
	%>
	
<tr>
    <%
		strTemp = (String)vRetResult.elementAt(i+13);
	%>	
  <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%
		strTemp = (String)vRetResult.elementAt(i+12);
		if(strTemp == null || strTemp.length() == 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14),"");
	%>
  <td class="thinborderBOTTOMLEFTSmall">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <td class="thinborderBOTTOMLEFTRIGHT"><div align="right"><%=iIncr%></div></td>
    <td height="18" class="thinborderBOTTOM">&nbsp;<%=((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>	
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+5))).toUpperCase()%></td>
    <% 
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+10), true);		
	%>	
	<td class="thinborderBOTTOMLEFT"><div align="right"><%=strTemp%>&nbsp;</div></td>
	<% 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dLineTotal += dTemp;		
		dEEPageTotal += dTemp;
		dDeptEEPageTotal += dTemp;
	%>
	<% 
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+11), true);
	%>	
	<td width="9%" class="thinborderBOTTOMLEFT"><div align="right"><%=strTemp%>&nbsp;</div></td>
	<% 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dLineTotal += dTemp;
		dPageTotal += dLineTotal;
		dERPageTotal += dTemp;
		dDeptERPageTotal += dTemp;
		dDeptPageTotal += dPageTotal;
	%>		
    <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</div></td>
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15),"5");
	%>	
    <td class="thinborderBOTTOMLEFTRIGHT"><strong>&nbsp;</strong></td>  
    </tr>
	
	<%if(WI.fillTextValue("by_dept").length() > 0 ){%>
		<%if( showHeader || i+16 >= vRetResult.size() ){%>
		<tr>
			<td class="thinborderBOTTOMLEFT" colspan="4">&nbsp;</td>
			<td class="thinborderBOTTOMLEFT">DEPARTMENT TOTAL </td>
			<td class="thinborderBOTTOMLEFT">&nbsp;</td>  
			<td align="right" class="thinborderBOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dDeptEEPageTotal,true)%></strong>&nbsp;</td>
			<td align="right" class="thinborderBOTTOMLEFT"><strong><%=CommonUtil.formatFloat(dDeptERPageTotal,true)%></strong>&nbsp;</td>
			<td align="right" class="thinborderBOTTOMLEFT"><strong><%=CommonUtil.formatFloat((dDeptEEPageTotal+dDeptERPageTotal),true)%></strong>&nbsp;</td>
			<td class="thinborderBOTTOMLEFT">&nbsp;</td>
			<td class="thinborderBOTTOMLEFT">&nbsp;</td>
		</tr>
	<%	
			dDeptEEPageTotal = 0d;
			dDeptERPageTotal = 0d;
			dDeptPageTotal = 0d;
		}		
	}%>	
	
	 <%}%>
	 <%for(;iCount<iMaxRecPerPage; ++iCount){%>
	<tr>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td height="18" class="thinborderBOTTOM">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
   	<%}// inner for loop%>
    <tr> 
      <td colspan="4" rowspan="2" class="thinborderBOTTOMLEFT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="29%" class="thinborderNone">No. of Employees on this page</td>
          <td width="21%" class="thinborderNone">&nbsp;<%=iRowCount-1%></td>
          <td width="29%" class="thinborderNone">No. of Employees if last page</td>
		  <%
			if (iNumRec >= vRetResult.size())
				strTemp = Integer.toString(iIncr-1);
			else
				strTemp = "-";
		  %>		  
          <td width="21%" class="thinborderNone">&nbsp;<%=strTemp%></td>
        </tr>
      </table></td>
      <td height="24" class="thinborderBOTTOMLEFT">TOTAL FOR THIS PAGE </td>
      <td height="24" class="thinborderBOTTOMLEFT">&nbsp;</td>
	  <%
			dEEGrandTotal += dEEPageTotal;
	  %>
	  <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dEEPageTotal,true)%>&nbsp;</td>
	  <%
			dERGrandTotal += dERPageTotal; 
	  %>
	  <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dERPageTotal,true)%>&nbsp;</td>
	  <%
	  	dGrandTotal += dPageTotal;
	  %>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;</td>
      <td  class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td height="24" class="thinborderBOTTOMLEFT">GRAND TOTAL</td>
      <td height="24" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <%
	  	if (iNumRec >= vRetResult.size())
				strTemp = CommonUtil.formatFloat(dEEGrandTotal,true);
			else
				strTemp = "-";
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%
	  	if (iNumRec >= vRetResult.size())
				strTemp = CommonUtil.formatFloat(dERGrandTotal,true);
			else
				strTemp = "-";
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <%
	  	if (iNumRec >= vRetResult.size())
				strTemp = CommonUtil.formatFloat(dGrandTotal,true);
			else
				strTemp = "-";
			%>
      <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
      <td  class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="4" class="thinborderBOTTOMLEFT"><table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr class="thinborderBOTTOM">
          <td height="24" colspan="3" align="center" class="thinborderBOTTOM">FOR PAG-IBIG USE ONLY </td>
        </tr>
        <tr>
          <td width="12%" height="45" valign="top" class="thinborderBOTTOM">PFR NO.</td>
          <td width="14%" valign="top" class="thinborderBOTTOMLEFT">DATE</td>
          <td width="15%" valign="top" class="thinborderBOTTOMLEFT">AMOUNT</td>
        </tr>
        <tr>
          <td height="18" colspan="2" class="thinborderBOTTOM">COLLECTING BANK</td>
          <td class="thinborderBOTTOMLEFT">REMARKS</td>
        </tr>
        <tr>
          <td height="22" colspan="2" class="thinborderNone">&nbsp;</td>
          <td class="thinborderNone">&nbsp;</td>
        </tr>
      </table></td>
      <td height="24" colspan="5" class="thinborderBOTTOMLEFT"><table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="84%" height="24" colspan="5" align="center" class="thinborderBOTTOM"><strong>CERTIFIED CORRECT BY:</strong></td>
          </tr>
        <tr>
          <td height="17" colspan="5" class="thinborderBOTTOM">SIGNATURE OVER PRINTED NAME</td>
          </tr>
        <tr>
          <td height="46" colspan="5" valign="bottom" class="thinborderNone"><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td height="28" colspan="2" align="center" valign="bottom" class="thinborderBOTTOM"><strong>&nbsp;<%=WI.fillTextValue("signatory").toUpperCase()%> </strong></td>
              </tr>
              <tr>
                <td width="55%" height="18" class="thinborderNone">OFFICIAL DESIGNATION </td>
                <td width="45%">&nbsp;</td>
              </tr>
              <tr>	 
                <td height="22" colspan="2" align="center" class="thinborderNone"><strong><%=WI.fillTextValue("designation")%></strong></td>
              </tr>
          </table></td>
          </tr>
        
      </table></td>
      <td valign="top"  class="thinborderBOTTOMLEFTRIGHT"><table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr class="thinborderNone">
          <td height="24" class="thinborderBOTTOM">&nbsp;</td>
        </tr>
        <tr>
          <td height="17"  class="thinborderNone">DATE</td>
        </tr>
        <tr>
          <td height="28"  class="thinborderBOTTOM">&nbsp;</td>
        </tr>
        <tr>
          <td width="16%" height="18" class="thinborderNone">&nbsp;PAGE NO.</td>
        </tr>
        <tr>
          <td height="22" align="center" class="thinborderNone"><%=iPage%></td>
        </tr>
      </table></td>
    </tr>
    <tr>
      <td height="24" width="12%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="3%" >&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="16%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
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