<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn,eDTR.eDTRUtil, payroll.PReDTRME" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View OverTime Requests</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style  type="text/css">
TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
</style>
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	String strHasWeekly = null;
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
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
								"Admin/staff-eDaily Time Record-View/Edit Overtime","ot_rendered.jsp");
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
											"eDaily Time Record","STATISTICS & REPORTS",
											request.getRemoteAddr(),"ot_rendered.jsp");

if(bolMyHome && iAccessLevel == 0) { 
	iAccessLevel = 1;	
}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
 
String[] astrMonth = {"January", "February","March", "April", "May","June","July",  
						"August", "September", "October", "November", "December"};
 
Vector vSalaryPeriod 		= null;//detail of salary period.
PReDTRME prEdtrME = new PReDTRME();

ReportEDTRExtn RE = new ReportEDTRExtn(request);
eDTR.OverTime ot = new eDTR.OverTime();
String strMonth = null;
String strYear = null;
Vector vRetResult = null;
Vector vOtTypes = new Vector();
Vector vUserOT = null;
int iOtTypeCount = 0;
int iIndexOf = 0;
Long lIndex = null;
double[] adHours = null;
double[] adAmount = null;
double[] adTotalHrs = null;
double[] adTotalAmt = null;

double dTemp = 0d;
double dRegOtHour = 0d;
double dHourlyRate = 0d;
int iWidth = 7;
String strAmount = null;
double dOtRate = 0d;
double dExcessRate = 0d;
double dExcessHr = 0d;

String strRateType = null;
String strExcessType = null;
boolean bolPageBreak = false;
String strPeriod = null;

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
		
	strTemp = WI.fillTextValue("sal_period_index");
	if(strTemp.length() > 0){
		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
				strPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
				break;
			}
		}	
	}
	
	vRetResult = RE.generateOTRendered(dbOP);
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iPage = 1;
		vOtTypes = (Vector)vRetResult.remove(0);
		vRetResult.remove(0);// remove dates
		
		if(vOtTypes != null){
			iOtTypeCount = vOtTypes.size() / 7;
			if(WI.fillTextValue("show_division").length() > 0)
				iWidth = 80/(iOtTypeCount + 1);
			else
				iWidth = 80/ iOtTypeCount;

			adHours = new double[iOtTypeCount];
			adAmount = new double[iOtTypeCount];
			adTotalAmt = new double[iOtTypeCount];
			adTotalHrs = new double[iOtTypeCount];
		}
		int iTotalPages = vRetResult.size()/(20*iMaxRecPerPage);	
		if(vRetResult.size() % (20*iMaxRecPerPage) > 0)
			++iTotalPages;

		for (;iNumRec < vRetResult.size();iPage++){
%>
<form name="dtr_op">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td align="right">Page <%=iPage%> of <%=iTotalPages%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" colspan="6" align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong></td>
  </tr>
  <tr>
		<%
			//strPeriod
			if(WI.fillTextValue("sal_period_index").length() > 0)	
				strTemp = " FOR THE SALARY PERIOD ";
			else{
				
				strTemp = WI.fillTextValue("month_of");
				if(strTemp.length() > 0 && !strTemp.equals("0"))
					strTemp = astrMonth[Integer.parseInt(strTemp)] + " " + WI.fillTextValue("year_of");
				else
					strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date");
				strTemp = " FOR THE PERIOD " + strTemp;
			}
		%>
    <td width="57%" height="25" colspan="6" align="center"><font color="#000000"><strong>LIST 
      OF OVERTIME RENDERED <%=strTemp%><%=WI.getStrValue(strPeriod)%></strong></font></td>
  </tr>
  <tr>
    <td colspan="6"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <%if(WI.fillTextValue("show_division").length() > 0){%>
				<td align="center" class="thinborder"><strong>Department / Office</strong></td>
				<%}%>
        <td width="19%" height="26" align="center" class="thinborder"><strong>Employee name</strong></td>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>
				<%
					strTemp = (String)vOtTypes.elementAt(j+1);
				%>
        <td align="center" class="thinborder" width="<%=iWidth/2%>%"><strong><%=strTemp%></strong></td>
				<%if(WI.fillTextValue("show_cost").length() > 0){%>
				<td align="center" class="thinborder" width="<%=iWidth/2%>%"><strong>COST</strong></td>
				<%}%>
				<%}%>
      </tr>
    <%
 		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){		
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
			vUserOT = (Vector)vRetResult.elementAt(i+11);
			// initialize array
			for(j=0; j < adHours.length;j++)
				adHours[j] = 0d;				

			for(j=0; j < adAmount.length;j++)
				adAmount[j] = 0d;						
		%>		 
      <tr>
				<%if(WI.fillTextValue("show_division").length() > 0){%>
				<%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}
				%>				
        <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
				<%}%>
        <%
						strTemp = WI.formatName((String)vRetResult.elementAt(i+2), 
											(String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4);
						strTemp += "<br>(" + (String)vRetResult.elementAt(i+1) + ")";
				%>
        <td nowrap class="thinborder">&nbsp;<%=strTemp%></td>
        <%	
				for(j = 0; j < vOtTypes.size(); j+=7){
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
						dHourlyRate = Double.parseDouble((String)vUserOT.remove(iIndexOf));// 5remove hourly rate
						vUserOT.remove(iIndexOf);// 6 free
						vUserOT.remove(iIndexOf);// 7 free
												
						adHours[j/7] += dTemp;						
						dRegOtHour = dTemp;
						
						if (dTemp > 8) {
						  dExcessHr = dTemp - 8;
						  dRegOtHour = 8;
						}						
						
						if(strExcessType.equals("0")){ // percentage
							adAmount[j/7] += (dExcessRate / 100) * dHourlyRate * dExcessHr;		
						}else{ // specific rate
							adAmount[j/7] += dExcessHr * dHourlyRate;		
						}

						if(strRateType.equals("0")){ // percentage
							dTemp = (dOtRate / 100) * dHourlyRate;
							strTemp = CommonUtil.formatFloat(dTemp, 2);
							strTemp = ConversionTable.replaceString(strTemp, ",","");
							dTemp = Double.parseDouble(strTemp);
						
							adAmount[j/7] += dTemp * dRegOtHour;	
						}else if(strRateType.equals("1")){ // specific rate
							adAmount[j/7] += dRegOtHour * dHourlyRate;		
						}else{ // flat rate	
							adAmount[j/7] += dOtRate;		
						}
												
						iIndexOf = vUserOT.indexOf(lIndex);
					}//end of while..sul
										
					if(adHours[j/7] > 0d)
						strTemp = CommonUtil.formatFloat(adHours[j/7], false) + " hr(s)";
					else
						strTemp = "-";
					adTotalHrs[j/7] += adHours[j/7];
					
					if(adAmount[j/7] > 0d)
						strTemp2 = CommonUtil.formatFloat(adAmount[j/7], 2);
					else
						strTemp2 = "-";
					adTotalAmt[j/7] += Double.parseDouble(CommonUtil.formatFloat(adAmount[j/7], 2));
				%>
				<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
				<%if(WI.fillTextValue("show_cost").length() > 0){%>
					<td align="right" class="thinborder"><%=strTemp2%></td>
				<%}%>
				<%}%>
      </tr>	  
      <%}%>
			<%if(iNumRec >= vRetResult.size()){%>
			<tr>
        <%if(WI.fillTextValue("show_division").length() > 0){%>
				<td height="22" class="thinborder">&nbsp;</td>
				<%}%>
        <td align="right" nowrap class="thinborder"><strong>TOTAL : </strong></td>
				
				<%for(j = 0; j < vOtTypes.size(); j+=7){					
					strTemp = CommonUtil.formatFloat(adTotalHrs[j/7], 2);
					%>
        	<td align="right" class="thinborder"><%=strTemp%>&nbsp;hr(s)&nbsp;</td>
					<%if(WI.fillTextValue("show_cost").length() > 0){
					strTemp = CommonUtil.formatFloat(adTotalAmt[j/7], 2);
					%>				
			<td align="right" class="thinborder"><%=strTemp%></td>
					<%}%>
				<%}%>
      </tr>
      <%}%>			
    </table></td>
  </tr>
</table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>