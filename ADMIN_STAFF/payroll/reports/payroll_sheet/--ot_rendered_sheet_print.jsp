<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn,eDTR.eDTRUtil, payroll.PReDTRME" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
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

TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}

	TD.thinborderHeader {
		border-left: solid 1px #000000;
		border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 9px;
	}
</style>
</head>

 <script language="JavaScript" src="../../../../jscript/common.js"></script> 
<body>
<%
 	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	String strHasWeekly = null;
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
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");		
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
if(bolIsSchool)
	strTemp = "College";
else
	strTemp = "Division";

String[] astrSortByName    = {"Last Name(Requested for)","Department",strTemp};

String[] astrSortByVal     = {"lname","d_name","c_name"};

String[] astrMonth = {"January", "February","March", "April", "May","June","July",  
						"August", "September", "October", "November", "December"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};

int iSearchResult = 0;
PReDTRME prEdtrME = new PReDTRME();

ReportEDTRExtn RE = new ReportEDTRExtn(request);
eDTR.OverTime ot = new eDTR.OverTime();
String strMonth = null;
String strYear = null;
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

String strRateType = null;
String strExcessType = null;
boolean bolAllowOTCost = false;
String strSQLQuery = 
					"select restrict_index from edtr_restrictions where restriction_type = 1 " +
					" and user_index_ = " + (String)request.getSession(false).getAttribute("userIndex");
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
//if(strSQLQuery != null)
	bolAllowOTCost = true;
	int iHours = 0;
	int iMinutes = 0;
	double dHourAmt = 0d;
	double dMinAmt = 0d;

if (WI.fillTextValue("viewAll").equals("1")){

	vRetResult = RE.generateOTRendered(dbOP);
	if (vRetResult == null){
		strErrMsg =  RE.getErrMsg();
	}else{
		vOtTypes = (Vector)vRetResult.remove(0);
		vRetResult.remove(0);// remove dates
		iSearchResult = RE.getSearchCount();
		
		if(vOtTypes != null){
			iOtTypeCount = vOtTypes.size() / 7;
			iWidth = 80/ (iOtTypeCount * 4);
 			adHours = new double[iOtTypeCount];
			adHourlyRates = new double[iOtTypeCount];
			adHourAmt = new double[iOtTypeCount];
			adMinAmt = new double[iOtTypeCount];
		}
	}
}
%>
<form name="form_">
  <% if (vRetResult != null){ %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr bgcolor="#F4FBF5">
    <td width="57%" height="25" colspan="6" align="center"><font color="#000000"><strong>LIST 
      OF OVERTIME RENDERED
    </strong></font></td>
  </tr>
  <tr>
    <td colspan="6"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <td width="15%" height="26" rowspan="2" align="center" class="thinborderHeader"><strong>NAME</strong></td>
				<td width="5%" rowspan="2" align="center" class="thinborderHeader">&nbsp;</td>
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
				<td width="<%=iWidth%>%" rowspan="2" align="center" class="thinborderHeader"><strong>TOTAL</strong></td>
        <td width="<%=iWidth%>%" rowspan="2" align="center" class="thinborderHeader">50% mo. rate </td>
        <td width="<%=iWidth%>%" rowspan="2" align="center" class="thinborderHeader">GROSS AMOUNT  </td>
        <td width="<%=iWidth%>%" rowspan="2" align="center" class="thinborderHeader">WITHHOLDING TAX </td>
        <td width="<%=iWidth%>%" rowspan="2" align="center" class="thinborderHeader">NET AMOUNT </td>
        <td width="<%=iWidth%>%" rowspan="2" align="center" class="thinborderHeader">NOS.</td>
        <td width="<%=iWidth%>%" rowspan="2" align="center" class="thinborderHeader">SIGNATURE</td>
      </tr>
      <tr>
			<%for(j = 0; j < vOtTypes.size(); j+=7){%>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">No. Hrs </td>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">No. mins </td>
			  <%}%>
			<%for(j = 0; j < vOtTypes.size(); j+=7){%>				
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">Rate/ Hr</td>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">Rate/ Min.</td>
			  <%}%>
			<%for(j = 0; j < vOtTypes.size(); j+=7){%>								
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">Amount/ Hour</td>
        <td width="<%=iWidth%>%" align="center" class="thinborderHeader">Amount/ Min</td>								
				<%}%>
				</tr>
        <%
			int iCtr = 1;
			for (i=0 ; i < vRetResult.size(); i+=20, iCtr++){ 
				vUserOT = (Vector)vRetResult.elementAt(i+11);
				strTemp = (String)vRetResult.elementAt(i+13);
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
        <%
						strTemp = WI.formatName((String)vRetResult.elementAt(i+2), 
											(String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4);
						strTemp += "<br>(" + (String)vRetResult.elementAt(i+1) + ")";
				%>
        <td height="19" nowrap class="thinborder">&nbsp;<%=strTemp%></td>
				<%
					strTemp = (String)vRetResult.elementAt(i+12);
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
						dHourAmt = iHours * dHourlyRate;
						dMinAmt = iMinutes * dHourlyRate/60;					
						strTemp = CommonUtil.formatFloat(adHours[j/7], false) + " hr(s)";
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
					
					dTotal += adHourAmt[j/7] + adMinAmt[j/7];
				%>
				<td align="right" class="thinborder"><%=iHours%>  &nbsp;</td>
				<td align="right" class="thinborder"><%=iMinutes%>&nbsp;</td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>
				<td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloat(adHourlyRates[j/7], 2)%></td>
				<td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloat(adHourlyRates[j/7]/60, 2)%></td>
				<%}%>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>				
				<td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloat(adHourAmt[j/7], true)%></td>
				<td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloat(adMinAmt[j/7], true)%></td>				
				<%}%>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotal, true)%></td>
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dHalfMonth, true)%></td>
				<%
					if(dTotal > dHalfMonth)
						dGross = dHalfMonth;
					else
						dGross = dTotal;
				%>
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dGross, true)%></td>
				<%
					
				%>
        <td align="right" class="thinborder"><%=dTax%></td>
				<%
				dNet =  dGross - dTax;
				%>
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dNet, true)%></td>
        <td align="right" class="thinborder"><%=iCtr%></td>
        <td align="right" class="thinborder">&nbsp;</td>
      </tr>
      <%}%>
    </table></td>
  </tr>
</table>
<% }%>
  <input type="hidden" name="print_page">
	<input type="hidden" name="viewAll" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>