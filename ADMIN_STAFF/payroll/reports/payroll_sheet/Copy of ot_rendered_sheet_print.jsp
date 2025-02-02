<%@ page language="java" import="utility.*,java.util.Vector,java.util.Calendar,eDTR.ReportEDTRExtn,eDTR.eDTRUtil" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(7);
	WebInterface WI = new WebInterface(request);
	String strHeaderSize = WI.getStrValue(WI.fillTextValue("header_size"), "10");
	String strDetailSize = WI.getStrValue(WI.fillTextValue("detail_size"), "10");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of Overtime Rendered</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style  type="text/css">
TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}

	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=strDetailSize%>px;
	}	
	
	TD.thinborderHeader {
		border-left: solid 1px #000000;
		border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strHeaderSize%>px;
	}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script> 
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	int i = 0;	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Summary of OT Rendered","ot_rendered_sheet.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"PAYROLL","REPORTS",
											request.getRemoteAddr(),"ot_rendered_sheet.jsp");

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

int iSearchResult = 0;
ReportEDTRExtn RE = new ReportEDTRExtn(request);
eDTR.OverTime ot = new eDTR.OverTime();
Vector vRetResult = null;
Vector vOtTypes = new Vector();
Vector vUserOT = null;
int iOtTypeCount = 0;
int j = 0;
int iIndexOf = 0;
Long lIndex = null;
double[] adHours = null;
double[] adOTRates = null;
double[] adHourlyRates = null;
double[] adHourAmt = null;
double[] adMinAmt = null;
double dTotal = 0d;

double dTemp = 0d;
double dRegOtHour = 0d;
double dHourlyRate = 0d;
int iWidth = 7;
String strAmount = null;
double dOtRate = 0d;
double dExcessRate = 0d;
double dExcessHr = 0d;
double dHalfMonth = 0d;
double dGross = 0d;
double dTax = 0d;
double dNet = 0d;
double dGrandGross = 0d;
double dGrandTax = 0d;
double dGrandNet = 0d;

String strRateType = null;
String strExcessType = null;// included but not used... go figure

String[] astrMonth = {"January", "February","March", "April", "May","June","July",  
						"August", "September", "October", "November", "December"};

	int iHours = 0;
	int iMinutes = 0;
	double dHourAmt = 0d;
	double dMinAmt = 0d;
 String strMonth = WI.fillTextValue("month_of");
 String strYear = WI.fillTextValue("year_of");
 
 String strPeriod = null;

if (strMonth.length() > 0){
	Calendar cal = Calendar.getInstance();
 	cal.set(Calendar.DAY_OF_MONTH,1);
	cal.set(Calendar.MONTH, Integer.parseInt(strMonth));
	cal.set(Calendar.YEAR, Integer.parseInt(strYear));	
	strPeriod = astrMonth[Integer.parseInt(strMonth)] + " 1-" + cal.getActualMaximum(Calendar.DAY_OF_MONTH) + ", " + cal.get(Calendar.YEAR);
} 
 
	vRetResult = RE.generateOTRendered(dbOP);
	if (vRetResult != null) {	
		vOtTypes = (Vector)vRetResult.remove(0);
		vRetResult.remove(0);// remove dates
		iSearchResult = RE.getSearchCount();
		
		if(vOtTypes != null){
			iOtTypeCount = vOtTypes.size() / 7;
			iWidth = 54/ (iOtTypeCount * 6);
 			adHours = new double[iOtTypeCount];
			adHourlyRates = new double[iOtTypeCount];
			adHourAmt = new double[iOtTypeCount];
			adMinAmt = new double[iOtTypeCount];
		}
	boolean bolPageBreak = false;
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(20*iMaxRecPerPage);	
	if((vRetResult.size() % (20*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
 %>
<form name="form_">
 <%if(iNumRec == 0){%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="57%" height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We hereby acknowledge to have received from Director IV Treasurer of DECS VII the sums herein <br>
      specified opposite our respective names, the same being full compensation for overtime services rendered during the period <%=strPeriod%><br>
      to the correctness of services </td>
  </tr>
	</table>
	<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="6"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <td width="2%" rowspan="2" align="center" class="thinborderHeader">N<br>
          O</td>
        <td width="10%" height="26" rowspan="2" align="center" class="thinborderHeader"><strong>NAMES</strong></td>
				<td width="3%" rowspan="2" align="center" class="thinborderHeader"><strong>MONTHLY RATE </strong></td>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>
				<%
					strTemp = (String)vOtTypes.elementAt(j+1);
				%>
        <td colspan="2" align="center" class="thinborderHeader"><strong><%=strTemp%></strong></td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){
					strTemp = (String)vOtTypes.elementAt(j+1);
				%>
				<td colspan="2" align="center" class="thinborderHeader"><strong><%=strTemp%></strong></td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){
					strTemp = (String)vOtTypes.elementAt(j+1);
				%>
				<td colspan="2" align="center" class="thinborderHeader"><strong><%=strTemp%></strong></td>
				<%}%>
				<td width="4%" rowspan="2" align="center" class="thinborderHeader"><strong>TOTAL</strong></td>
        <td width="4%" rowspan="2" align="center" class="thinborderHeader"><strong>50% mo. rate </strong></td>
        <td width="4%" rowspan="2" align="center" class="thinborderHeader"><strong>GROSS AMOUNT  </strong></td>
        <td width="4%" rowspan="2" align="center" class="thinborderHeader"><strong>WITH HOLDING TAX </strong></td>
        <td width="4%" rowspan="2" align="center" class="thinborderHeader"><strong>NET AMOUNT </strong></td>
        <td width="2%" rowspan="2" align="center" class="thinborderHeader"><strong>N<br>
          O<br>
          S</strong></td>
        <td width="4%" rowspan="2" align="center" class="thinborderHeader"><strong>SIGNATURE</strong></td>
      </tr>
      <tr>
			<%for(j = 0; j < vOtTypes.size(); j+=7){%>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader"><strong>No. Hrs </strong></td>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader"><strong>No. mins </strong></td>
			  <%}%>
			<%for(j = 0; j < vOtTypes.size(); j+=7){%>				
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader"><strong>Rate/ Hr</strong></td>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader"><strong>Rate/ Min.</strong></td>
			  <%}%>
			<%for(j = 0; j < vOtTypes.size(); j+=7){%>								
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader"><strong>Amount/ Hour</strong></td>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader"><strong>Amount/ Min</strong></td>								
				<%}%>
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

			
				vUserOT = (Vector)vRetResult.elementAt(i+11);
				strTemp = (String)vRetResult.elementAt(i+15);
				dHourlyRate = Double.parseDouble(strTemp);
				dTotal = 0d;
				// initialize array
				for(j=0; j < iOtTypeCount;j++){
					adHours[j] = 0d;				
					adHourAmt[j] = 0d;							
					adMinAmt[j] = 0d;
				}
		 %>
      <tr>
        <td nowrap class="thinborder"><%=iIncr%></td>
        <%
						strTemp = WI.formatName((String)vRetResult.elementAt(i+2), 
											(String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4);
						//strTemp += "<br>(" + (String)vRetResult.elementAt(i+1) + ")";
				%>
        <td height="19" nowrap class="thinborder">&nbsp;<%=strTemp%></td>
				<%
					strTemp = (String)vRetResult.elementAt(i+14);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dHalfMonth = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
					dHalfMonth = dHalfMonth/2;
				%>
        <td align="right" nowrap class="thinborder"><%=strTemp%>&nbsp;</td>
        <%				
				for(j = 0; j < vOtTypes.size(); j+=7){		
					iHours = 0;
					iMinutes = 0;
								
					dOtRate = Double.parseDouble((String)vOtTypes.elementAt(j+3));
					strRateType = (String)vOtTypes.elementAt(j+4);					
					
					dExcessRate = Double.parseDouble(WI.getStrValue((String)vOtTypes.elementAt(j+5), "0"));
					strExcessType = WI.getStrValue((String)vOtTypes.elementAt(j+6));
					
					lIndex = (Long)vOtTypes.elementAt(j);
					iIndexOf = vUserOT.indexOf(lIndex);					
					while(iIndexOf != -1){
						dExcessHr = 0d;
						iIndexOf = iIndexOf - 3;
						vUserOT.remove(iIndexOf);// 1remove user index
						vUserOT.remove(iIndexOf);// 2date
						dTemp = ((Double)vUserOT.remove(iIndexOf)).doubleValue();// 3remove hours
						vUserOT.remove(iIndexOf);// 4remove otTypeIndex
						vUserOT.remove(iIndexOf);// 5remove hourly rate
						vUserOT.remove(iIndexOf);// 6 free
						vUserOT.remove(iIndexOf);// 7 free
						
						adHours[j/7] += dTemp;
						
						dRegOtHour = dTemp;
            if (dTemp > 8) {
              dExcessHr = dTemp - 8;
              dRegOtHour = 8;
            }						
						
						//if(strExcessType.equals("0")){ // percentage
						//	adAmount[j/7] += (dExcessRate / 100) * dHourlyRate * dExcessHr;		
						//}else{ // specific rate
						//	adAmount[j/7] += dExcessHr * dHourlyRate;		
						//}

						iIndexOf = vUserOT.indexOf(lIndex);
					}
					
					if(adHours[j/7] > 0d){
						iHours = (int)adHours[j/7];
						dTemp = adHours[j/7] - iHours;
						iMinutes = (int)(dTemp*60);						
						//strTemp = CommonUtil.formatFloat(adHours[j/7], false) + " hr(s)";
					} else {
						strTemp = "-";
					}

					if(strRateType.equals("0")){ // percentage
						adHourlyRates[j/7] = dHourlyRate * (dOtRate / 100);
						strTemp = CommonUtil.formatFloat(adHourlyRates[j/7], 2);
						
						strTemp = ConversionTable.replaceString(strTemp, ",","");
						adHourlyRates[j/7] = Double.parseDouble(strTemp);
						
						adHourAmt[j/7] = adHourlyRates[j/7] * iHours;
						adMinAmt[j/7] = adHourlyRates[j/7]/60 * iMinutes;
					}else if(strRateType.equals("1")){ // specific rate
						adHourlyRates[j/7] = dHourlyRate;

						adHourAmt[j/7] = adHourlyRates[j/7] * iHours;						
						adMinAmt[j/7] = adHourlyRates[j/7]/60 * iMinutes;
					}else{ // flat rate	
						adHourlyRates[j/7] = dOtRate;
						adHourAmt[j/7] = dOtRate;
						adMinAmt[j/7] = 0d;
					}
						adHourAmt[j/7] = adHourlyRates[j/7] * iHours;					
 						strTemp = CommonUtil.formatFloat(adHourAmt[j/7], 2);
						strTemp = ConversionTable.replaceString(strTemp, ",","");
						adHourAmt[j/7] = Double.parseDouble(strTemp);
 						
						adMinAmt[j/7] = adHourlyRates[j/7]/60 * iMinutes;		
 						strTemp = CommonUtil.formatFloat(adMinAmt[j/7], 2);
						strTemp = ConversionTable.replaceString(strTemp, ",","");
						adMinAmt[j/7] = Double.parseDouble(strTemp);									
 							
					dTotal += adHourAmt[j/7] + adMinAmt[j/7];
				%>
				<%
					strTemp = Integer.toString(iHours);
					if(iHours == 0)
						strTemp = "&nbsp;";
				%>
				<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
				<%
					strTemp = Integer.toString(iMinutes);
					if(iMinutes == 0)
						strTemp = "&nbsp;";
				%>				
				<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){
					strTemp = CommonUtil.formatFloat(adHourlyRates[j/7], 2);
				%>
				<td align="right" class="thinborder">&nbsp;<%=strTemp%></td>
				<%
					strTemp = CommonUtil.formatFloat(adHourlyRates[j/7]/60, 2);
				%>
				<td align="right" class="thinborder">&nbsp;<%=strTemp%></td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>				
				<%
					strTemp = CommonUtil.formatFloat(adHourAmt[j/7], true);
					if(adHourAmt[j/7] == 0d)
						strTemp = "--";
				%>
				<td align="right" class="thinborder"><%=adHourAmt[j/7]%>&nbsp;</td>
				<%
					strTemp = CommonUtil.formatFloat(adMinAmt[j/7], true);
					if(adMinAmt[j/7] == 0d)
						strTemp = "--";
				%>				
				<td align="right" class="thinborder"><%=adMinAmt[j/7]%>&nbsp;</td>					
				<%}%>
				<%
					strTemp = CommonUtil.formatFloat(dTotal, true);
				%>
				<td align="right" class="thinborder"><%=strTemp%></td>
				<%
					strTemp = CommonUtil.formatFloat(dHalfMonth, true);
				%>				
        <td align="right" class="thinborder"><%=strTemp%></td>
				<%
					if(dTotal > dHalfMonth)
						dGross = dHalfMonth;
					else
						dGross = dTotal;
					strTemp = CommonUtil.formatFloat(dGross, true);
					dGrandGross += dGross;
					
				%>
        <td align="right" class="thinborder"><%=strTemp%></td>
				<%
					dGrandTax += dTax;
				%>
        <td align="right" class="thinborder"><%=dTax%></td>
				<%
				dNet =  dGross - dTax;
				strTemp = CommonUtil.formatFloat(dNet, true);
				dGrandNet += dNet;				
				%>
        <td align="right" class="thinborder"><%=strTemp%></td>
        <td align="center" class="thinborder"><%=iIncr%></td>
        <td align="right" class="thinborder">&nbsp;</td>
      </tr>
      <%}%>
			<%if (iNumRec >= vRetResult.size()) {%>
      <tr>
        <td nowrap class="thinborder">&nbsp;</td>
        <td height="19" nowrap class="thinborder">&nbsp;</td>
        <td align="right" nowrap class="thinborder">&nbsp;</td>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>				
        <td align="right" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder">&nbsp;</td>
				<%}%>
        <td align="right" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder"><%=dGrandGross%></td>
        <td align="right" class="thinborder"><%=dGrandTax%></td>
        <td align="right" class="thinborder"><%=dGrandNet%></td>
        <td align="center" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder">&nbsp;</td>
      </tr>
			<%}%>			
    </table></td>
  </tr>
</table>
<%if (iNumRec >= vRetResult.size()) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td height="36" align="center">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td width="2%" height="16" align="center" class="thinborderALL"><strong>A</strong></td>
    <td colspan="2">CERTIFIED : Services rendered as stated</td>
    <td width="7%">&nbsp;</td>
    <td width="2%" align="center" class="thinborderALL"><strong>C</strong></td>
    <td colspan="4">APPROVED FOR PAYMENT :</td>
    </tr>
  <tr>
    <td height="27">&nbsp;</td>
    <td width="24%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td width="9%">&nbsp;</td>
    <td width="23%">&nbsp;</td>
    <td width="6%">&nbsp;</td>
    <td width="20%">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td align="center"><%=WI.fillTextValue("certified_by_a"). toUpperCase()%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2" align="center"><%=WI.fillTextValue("certified_by_c"). toUpperCase()%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td align="center"><%=WI.fillTextValue("designation_a")%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2" align="center"><%=WI.fillTextValue("designation_c")%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="16" align="center" class="thinborderALL"><strong>B</strong></td>
    <td colspan="2" rowspan="2" valign="top">CERTIFIED : Supporting documents complete and proper, and cash available in the amount of 
		  <u><strong><%=new ConversionTable().convertAmoutToFigure(dGrandNet,"Pesos","Centavos")%> </strong></u></td>
    <td>&nbsp;</td>
    <td align="center" class="thinborderALL"><strong>D</strong></td>
    <td>CERTIFIED</td>
    <td rowspan="2">Each Employee whose name appears above has been paid the amount indicated opposite on his/her name. </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><p>ALOBS NO.<br>
      DATE : <br>
      JEV NOS.<br>
    DATE : </p>
      </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td align="center"><%=WI.fillTextValue("certified_by_b"). toUpperCase()%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2" align="center"><%=WI.fillTextValue("certified_by_d"). toUpperCase()%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td align="center"><%=WI.fillTextValue("designation_b")%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2" align="center"><%=WI.fillTextValue("designation_d")%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%}%>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
  <input type="hidden" name="print_page">
	<input type="hidden" name="viewAll" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>