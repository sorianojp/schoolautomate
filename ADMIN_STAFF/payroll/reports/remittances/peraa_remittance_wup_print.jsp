<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PERAA Premium remittance</title>
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

TD.thinborderBOTTOMTOPLEFT {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderAll {
	border: solid 1px #000000;	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}


</style>

</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function printPage(){
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);	
	window.print();	
}

function setLabelText(strLabelName, strLabel){
	var strOld = document.getElementById(strLabelName).innerHTML;
	var strNewValue = prompt(strLabel, strOld);
	
	if (strNewValue != null && strNewValue.length > 0)
		document.getElementById(strLabelName).innerHTML = strNewValue;
}
</script>
<body bgcolor="#FFFFFF">
<form name="form_" 	method="post" action="./peraa_remittance_wup_print.jsp">
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
								"Admin/staff-PAYROLL-REPORTS-sss_monthlyLoanRemit","peraa_remittance_wup_print.jsp");
								
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
														"peraa_remittance_wup_print.jsp");
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
	double dLineTotal = 0d;
	
	double dTotalSalary = 0d;
	double dPastService = 0d;
	double dCurService = 0d;
	double dEmployerTotal = 0d;
	double dEmpTotal = 0d;
	double dGrandTotal = 0d;
	
	String[] astrMonth = {"January","February","March","April","May","June","July",
						  "August", "September","October","November","December"};
						  
	String[] astrPtFt = {"PART-TIME","FULL-TIME"};
	String[] astrRemarks = {"R", "", "", "L", "N", ""};
	vRetResult = PRRemit.PERAAMonthlyPremium(dbOP);
	if(vRetResult != null && vRetResult.size() > 0)
		vEmployerInfo = (Vector)vRetResult.elementAt(0);
	if (vRetResult != null) {
	
		int i = 0; int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			

		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(14*iMaxRecPerPage);	
	  if(vRetResult.size() % (14*iMaxRecPerPage) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dTotalSalary =0d;	
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr >
      <td height="25" colspan="7"><div align="center">
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td width="20%" class="thinborderNone" valign="bottom"><strong>PERAA FORM A-1</strong></td>
            <td width="60%" align="center" valign="top">
			<span>		
			<div style="position: relative; display: inline; top: 35px;">			
				<img src="../../../../images/logo/peraa_logo.png" width="50px"  height="50px" style="position:absolute; top:-40px"/>
				<span style="width: 200px; left: 50px; position: relative; top: -30px;" >
					<strong>PRIVATE EDUCATION RETIREMENT ANNUITY ASSOCIATION</strong>	
					<span style="display:block;padding-top:3px" >													 	
					 	<strong><u>&nbsp; PREMIUM REMITTANCE LIST (PRL)&nbsp;</u></strong>			
					</span>
				</span> 
			</div>
		</span>
			
				
				
			</td>
            <td width="20%">&nbsp;</td>
          </tr>
        </table>
      </div></td>
    </tr>
    <tr >
      <td height="25" colspan="7"><div align="center">
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td width="30%"><table width="92%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="39%" class="thinborderAll" height="18">&nbsp;&nbsp;PI CODE NO.</td>
							<%
								if(vEmployerInfo != null && vEmployerInfo.size() > 0)
									strTemp = (String)vEmployerInfo.elementAt(9);
								else
									strTemp = "";
							%>						
                <td width="61%" class="thinborderBOTTOMTOPRIGHT"><strong><%=WI.getStrValue(strTemp)%></strong></td>
                </tr>
            </table>
            <td width="60%">&nbsp;</td>
          </tr>
        </table>
      </div></td>
    </tr>
    <tr >
      <td height="18" colspan="2" class="thinborderNone">&nbsp;</td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td height="18" align="center" class="thinborderNone"><strong>Month</strong></td>
      <td align="center" class="thinborderNone"><strong>Year</strong></td>
      <td class="thinborderNone">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" class="thinborderNone"><strong>NAME OF INSTITUTION</strong></td>
        <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(12);
        else
	        strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
        %>			
      <td width="49%" height="25" class="thinborderNone"><u>&nbsp;<%=strTemp%>&nbsp;</u></td>
	  <td>&nbsp;</td>
      <td width="14%" height="25" class="thinborderNone" align="right"> REMITTANCE FOR &nbsp;&nbsp;&nbsp;</td>
      <td width="8%" height="25" align="center" class="thinborderBOTTOMTOPLEFT">      <strong><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%></strong></td>
      <td width="9%" align="center" class="thinborderBOTTOMTOPRIGHT"><strong><%=WI.fillTextValue("year_of")%></strong></td>
      <td width="5%" class="thinborderNone">&nbsp;</td>
    </tr>
    <tr >
      <td width="15%" height="18" class="thinborderNone"><strong>ADDRESS</strong></td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(3);
        else
	        strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
		  %>	
      <td height="18" colspan="2" class="thinborderNone"><u>&nbsp;<%=strTemp%>&nbsp;</u></td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
    </tr>
	 <tr >
      <td width="15%" height="18" class="thinborderNone"><strong>CONTACT NO.: (Tel. / Fax) &nbsp;</strong></td>
		  <%
				if(vEmployerInfo != null && vEmployerInfo.size() > 0)
					strTemp = (String) vEmployerInfo.elementAt(5);
        else
	        strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
		  %>	
      <td height="18" colspan="2" class="thinborderNone"><u>&nbsp;<%=strTemp%>&nbsp;</u></td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td height="18" class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
    </tr>
    <tr >
      <td height="19" colspan="7" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="19" colspan="5" align="center" class="thinborderBOTTOMLEFT"><strong>NAME OF MEMBER</strong></td>
    <td rowspan="4" align="center" class="thinborderBOTTOMLEFT"><strong>PERAA ID NO. </strong></td>
    <td rowspan="3" align="center" class="thinborderBOTTOMLEFT"><strong>CURRENT MONTHLY SALARY </strong></td>
    <td colspan="5" align="center" class="thinborderBOTTOMLEFT"><strong>C O N T R I B U T I O N S</strong></td>
    <td rowspan="3" align="center" class="thinborderBOTTOMLEFT"><strong>OTHERS </strong> <i>(e.g.:Insurance, etc.)</i></td>
    <td align="center" class="thinborderBOTTOMLEFTRIGHT"><strong>REMARKS</strong></td>
    </tr>    
  <tr>
    <td width="9%" rowspan="3" align="center" class="thinborderBOTTOMLEFT"><strong>FAMILY NAME </strong></td>
    <td colspan="3" rowspan="3" align="center" class="thinborderBOTTOMLEFT"><strong>FIRST NAME  </strong></td>
    <td rowspan="3" align="center" class="thinborderBOTTOMLEFT"><strong>MI</strong></td>
    <td rowspan="2" height="14" align="center" class="thinborderBOTTOMLEFT"><strong>EMPLOYER'S SHARE </strong></td>
	<td rowspan="2" height="14" align="center" class="thinborderBOTTOMLEFT"><strong>EMPLOYEE'S SHARE </strong></td>
	<td rowspan="2" height="14" align="center" class="thinborderBOTTOMLEFT"><strong>VOLUNTARY CONTRIBUTION </strong></td>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFT"><strong>RESERVE FUND </strong></td>
    <td rowspan="2" align="center" class="thinborderBOTTOMLEFT"><strong>TOTAL</strong></td>
    <td rowspan="2" valign="top" class="thinborderBOTTOMLEFTRIGHT">N-new member<br>
      R-Resigned<br>
      L-On Leave</td>
    </tr>
  <tr>
    <!--<td height="13" align="center" class="thinborderBOTTOMLEFT"><strong>&nbsp; </strong></td>
    <td align="center" class="thinborderBOTTOMLEFT"><strong>&nbsp;</strong></td>
    <td align="center" class="thinborderBOTTOMLEFT"><strong>&nbsp;</strong></td>-->
  </tr>
  <tr>
    <td height="19" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=14,++iIncr, ++iCount){
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
    <td height="18" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
    <td colspan="3" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
    <%
		strTemp = (String)vRetResult.elementAt(i+5);
		strTemp = WI.getStrValue(strTemp,"");
		
	%>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=(strTemp).toUpperCase()%> </td>
	<%
		strTemp = (String)vRetResult.elementAt(i+11);
	%>
    <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	dTemp= 0d;
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+12),",","");
		dTemp = Double.parseDouble(strTemp);		
		dTotalSalary += dTemp;
	%>
    <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	<%  dTemp = 0d;
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+10),",","");
		dTemp = Double.parseDouble(strTemp);
		dLineTotal += dTemp;
		dEmployerTotal += dTemp ;
		
	%>	
    <td class="thinborderBOTTOMLEFT" align="right"><%= CommonUtil.formatFloat(strTemp,true)%>&nbsp;</td>
	<%  
		//dTemp = 0d;
		//strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+10),",","");
		//dTemp = Double.parseDouble(strTemp);
		//dLineTotal += dTemp;
		//dCurService += dTemp;
		
		dLineTotal += dTemp;
		dEmpTotal += dTemp;
	%>
    <td width="8%" class="thinborderBOTTOMLEFT"><div align="right"><%= CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	<%
		//voluntary cont
	%>
    <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(0,true)%>&nbsp;</div></td>
	<% 
		//reserved fund
	%>	
    <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(0,true)%>&nbsp;</div></td>
	<%
		dGrandTotal += dLineTotal;
	%>	
    <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</div></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13),"5");
	%>
    <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;<font color="#FF0000"><label id="remarks<%=i%>" 
				onclick="setLabelText('remarks<%=i%>','Remarks')"><%=WI.getStrValue(astrRemarks[Integer.parseInt(strTemp)],"--")%></label>
    </font></td>  
    </tr>
    <%} // end for loop%>
    <%//if ( iNumRec >= vRetResult.size()) {%>
    	
    <tr> 
      <td height="24" colspan="6" align="right" class="thinborderBOTTOMLEFT"><strong>TOTALS&nbsp;*&nbsp;&nbsp;</strong></td>
      <td class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dTotalSalary,true)%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLEFT" align="right"><%=CommonUtil.formatFloat(dEmployerTotal,true)%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(dEmpTotal,true)%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">
        <%=CommonUtil.formatFloat(0,true)%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">
        <%=CommonUtil.formatFloat(0,true)%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT">
        <%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</td>
      <td  class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td  class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <tr>
      <td height="24" colspan="3" class="thinborderNone">FOR PERAA USE ONLY&nbsp;&nbsp;</td>
      <td height="24" colspan="3" class="thinborderNone">Premiums Due (6) + (7)  =</td>
      <td class="thinborderBOTTOM"><div align="right">&nbsp;</div></td>
      <td class="thinborderNone">&nbsp;</td>
      <td colspan="4" class="thinborderNone">FORM OF REMITTANCE</td>
      <td colspan="2"  class="thinborderNone">CERTIFIED CORRECT BY:</td>
    </tr>
    <tr>
      <td height="16" class="thinborderNone">Received :</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="3" class="thinborderNone">Add Under payments (If any)</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td colspan="2" class="thinborderNone">Bank Remittance with </td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td  class="thinborderNone"> Signature:</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr>
      <td height="16" class="thinborderNone">Checked:</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" class="thinborderNone">Deduct Contributions Deposits</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">Date</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td  class="thinborderNone"> Printed Name:</td>
      <td  class="thinborderBOTTOM"><div align="center"><strong><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Finance Manager ",7)),"").toUpperCase()%> </strong></div></td>
    </tr>
    <tr>
      <td height="16" class="thinborderNone">Posted:</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" class="thinborderNone"> on account of Repurchase</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td colspan="2" class="thinborderNone">Checked (Enclosed)</td>
      <td class="thinborderNone">&nbsp;</td>
      <td  class="thinborderNone"> Official Title: </td>
      <td class="thinborderBOTTOM"><div align="center">Finance Manager</div></td>
    </tr>
    <tr>
      <td height="16" class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td colspan="3" class="thinborderNone">and over payments (If any)</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td colspan="2" class="thinborderNone">Money Order (Enclosed)</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone"> Date:</td>
      <td  class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr>
      <td height="16" class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td colspan="3" class="thinborderNone">Amount of Remittance</td>
      <td class="thinborderBOTTOM"><div align="right">&nbsp;</div></td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td colspan="2" class="thinborderNone">Cash</td>
      <td class="thinborderNone">&nbsp;</td>
      <td  class="thinborderNone">&nbsp;</td>
      <td  class="thinborderNone">&nbsp;</td>
    </tr>
	<%//}%>
    <tr>
      <td height="24" class="thinborderNone">&nbsp;</td>
      <td height="24" colspan="5" class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td class="thinborderNone">&nbsp;</td>
      <td colspan="2"  class="thinborderNone">Page&nbsp;<%=iPage%> of <%=iTotalPages%></td>
    </tr>
    <tr>
      <td width="9%">&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="7%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="6%">&nbsp;</td>
    </tr>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>
<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" id="footer">
  <tr>
    <td><hr/></td>
  </tr>
  <tr>
    <td><div align="center">
	<a href="javascript:printPage()"><img src="../../../../images/print.gif" width="58" height="26" border="0" /></a><font size="1">print form </font></div></td>
  </tr>
  <tr>
    <td height="30"><font size="2"><strong>Note: 
	  <font style="font-size:11px">Items in <font color="#FF0000">RED</font> are editable for printing purposes only </font><br>Set Printer to black / white mode before printing</strong></font></td>
  </tr>
</table> 
<%} //end end upper most if (vRetResult !=null)%>

  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>