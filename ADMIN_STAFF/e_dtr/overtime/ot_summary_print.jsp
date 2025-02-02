<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date,eDTR.ReportEDTRExtn,eDTR.eDTRUtil, payroll.PReDTRME" %>
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
								"Admin/staff-eDaily Time Record-View/Edit Overtime","ot_summary.jsp");
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
											request.getRemoteAddr(),"ot_summary.jsp");

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

int iSearchResult = 0;
Vector vSalaryPeriod 		= null;//detail of salary period.
PReDTRME prEdtrME = new PReDTRME();

ReportEDTRExtn RE = new ReportEDTRExtn(request);
eDTR.OverTime ot = new eDTR.OverTime();
String strMonth = null;
String strYear = null;
Vector vRetResult = null;
Vector vOtTypes = new Vector();
Vector vUserOT = null;
Vector vDates = new Vector();
Date odTempDate = null;
int iOtTypeCount = 0;
int iIndexOf = 0;
Long lIndex = null;
double[] adHours = null;
double dTemp = 0d;
int iWidth = 7;
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
		vDates = (Vector)vRetResult.remove(0);// remove dates
		
		if(vOtTypes != null){
			iOtTypeCount = vOtTypes.size() / 7;
			if(WI.fillTextValue("show_division").length() > 0)
				iWidth = 80/(iOtTypeCount + 1);
			else
				iWidth = 80/ iOtTypeCount;

			adHours = new double[iOtTypeCount];
		}
		int iTotalPages = vRetResult.size()/(20*iMaxRecPerPage);	
		if(vRetResult.size() % (20*iMaxRecPerPage) > 0) 
			++iTotalPages;

		for (;iNumRec < vRetResult.size();iPage++){
%>
<form name="dtr_op">
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" colspan="3" align="right">Page <%=iPage%> of <%=iTotalPages%></td>
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
    <td width="57%" height="25" colspan="3" align="center"><font color="#000000"><strong>LIST 
      OF OVERTIME RENDERED <%=strTemp%><%=WI.getStrValue(strPeriod)%></strong></font></td>
  </tr>
  <tr>
    <td colspan="3"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <td width="9%" align="center" class="thinborder">ID # </td>
				<td width="23%" align="center" class="thinborder"><strong>Employee name</strong></td>
        <td width="19%" height="26" align="center" class="thinborder"><strong>Department / Office</strong></td>
				<% for(j = 0; j < vDates.size(); j++){
					strTemp = (String)vDates.elementAt(j);
					iIndexOf = strTemp.indexOf("/");
					if(iIndexOf != -1){
						strTemp = strTemp.substring(iIndexOf+1,strTemp.length() - 5);
					}else{
						strTemp = "  ";
					}
					if(strTemp.length() == 1)
						strTemp = "0" + strTemp;
					
				%>
				<td align="center" class="thinborder"><%=strTemp%></td>
				<%}%>
				
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>
				<%
					strTemp = (String)vOtTypes.elementAt(j+1);
				%>
        <td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
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
		%>
      <tr>
				<%
				strTemp = (String)vRetResult.elementAt(i+1);
				%>
        <td height="22" nowrap class="thinborder">&nbsp;<%=strTemp%></td>
        <%
						strTemp = WI.formatName((String)vRetResult.elementAt(i+2), 
											(String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4);						
				%>
        <td nowrap class="thinborder">&nbsp;<%=strTemp%></td>
				<%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}
				%>				
        <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 12),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 13),"")%> </td>
        <% for(j = 0; j < vDates.size(); j++){
					dTemp = 0d;
					//vUserOT
					odTempDate = ConversionTable.convertMMDDYYYYToDate((String)vDates.elementAt(j));
					iIndexOf = vUserOT.indexOf(odTempDate);
					while(iIndexOf != -1){
						dTemp +=  ((Double)vUserOT.elementAt(iIndexOf+1)).doubleValue();
						iIndexOf = vUserOT.indexOf(odTempDate, iIndexOf+1);
					}
					if(dTemp > 0d)
						strTemp = CommonUtil.formatFloat(dTemp, false);
					else
						strTemp = "&nbsp;";
				%>
				<td align="center" class="thinborder"><%=strTemp%></td>
				<%}%>
        <%
				for(j = 0; j < vOtTypes.size(); j+=7){
					lIndex = (Long)vOtTypes.elementAt(j);
					iIndexOf = vUserOT.indexOf(lIndex);
					while(iIndexOf != -1){
						iIndexOf = iIndexOf - 3;
						vUserOT.remove(iIndexOf);// remove user index
						vUserOT.remove(iIndexOf);// date
						dTemp = ((Double)vUserOT.remove(iIndexOf)).doubleValue();// remove hours
						vUserOT.remove(iIndexOf);// remove otTypeIndex
						adHours[j/7] += dTemp;
						
						iIndexOf = vUserOT.indexOf(lIndex);
					}
					strTemp = CommonUtil.formatFloat(adHours[j/7], 2);
				%>
				<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
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