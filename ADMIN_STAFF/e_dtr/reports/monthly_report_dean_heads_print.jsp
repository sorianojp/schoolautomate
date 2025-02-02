<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Monthly Attendance Monitoring</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="window.print()">
<%@ page language="java" import="utility.*, eDTR.ReportEDTR,eDTR.eDTRUtil, eDTR.WorkingHour,java.util.Vector, java.util.Calendar" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;

	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Monthly Office Report ","monthly_report_dean_heads_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"monthly_report_dean_heads_print.jsp");	
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
int iSearchResult = 0;
ReportEDTR RE = new ReportEDTR(request);


String[] astrMonth={"","January", "February", "March", "April", "May", "June", "July",
					"August", "September","October", "November", "December"};
String[] astrWeekDays={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}; 

String strAllowedLate = dbOP.mapOneToOther("EDTR_ALLOWED_LATE_TIN", "is_del",
											"0","LATE_TIME_MIN","");
											
if (strAllowedLate == null) 
	strAllowedLate = "0";



Vector vRetResult = RE.getOfcDeptMonthlyReport(dbOP);
	
	if (vRetResult == null || vRetResult.size() == 0)
		strErrMsg = RE.getErrMsg();


	if (strErrMsg != null) { 
%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <%} else if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;
          <div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            Human Resources Development Center<br>
            EDTR Report for the month of </font>
		&nbsp;	<%=WI.fillTextValue("month_label")%>&nbsp;			
		<%=WI.fillTextValue("sy_")%>
		</div></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="12%" rowspan="2" class="thinborder"><font size="1" class="thinborder">Name of Employee </font></td>
      <td width="4%" rowspan="2" class="thinborder"><font size="1">No Abs/<br>
      Late /<br>
      Utime </font></td>
      <td width="3%" rowspan="2" class="thinborder"><font size="1">No<br> 
      Abs </font></td>
      <td width="3%" rowspan="2" class="thinborder"><font size="1">No<br> 
      Late </font></td>
	<% if (!strAllowedLate.equals("0")) {%> 
      <td width="3%" rowspan="2" class="thinborder"><font size="1"> &lt; <%=strAllowedLate%> <br> 
        min<br>
      Freq</font></td>
	<% }%> 	  
      <td width="3%" rowspan="2" class="thinborder"><font size="1">&gt;<%=strAllowedLate%> <br>
      Min <br>
      Freq </font></td>
      <td height="27" colspan="3" class="thinborder"><div align="center">
        <p><strong><font size="1">Summary of Lates / Undertime<br>
        </font></strong><strong><font size="1">of &gt; <%=strAllowedLate%> min </font></strong></p>
        </div></td>
      <td colspan="3" class="thinborder"><div align="center"><strong><font size="1">Filed Absences </font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong><font size="1">Filed OB/OT </font></strong></div></td>
      <td colspan="3" class="thinborder"><div align="center"><strong><font size="1">AWOL</font></strong></div></td>
      <td width="7%" rowspan="2" class="thinborder"><font size="1">Remarks</font></td>
      <td width="7%" rowspan="2" class="thinborder"><font size="1">Verified By </font></td>
    </tr>
    <tr>
      <td width="7%" height="12" class="thinborder"><font size="1">Dates/s</font></td>
      <td width="11%" class="thinborder"><font size="1">Time</font></td>
      <td width="3%" class="thinborder"><font size="1">Min</font></td>
      <td width="8%" class="thinborder"><font size="1">Date</font></td>
      <td width="3%" class="thinborder"><font size="1">Hour</font></td>
      <td width="3%" class="thinborder"><font size="1">Freq</font></td>
      <td width="7%" class="thinborder"><font size="1">Date</font></td>
      <td width="3%" class="thinborder"><font size="1">Freq</font></td>
      <td width="7%" class="thinborder"><font size="1">Date</font></td>
      <td width="3%" class="thinborder"><font size="1">Hour</font></td>
      <td width="3%" class="thinborder"><font size="1">Freq</font></td>
    </tr>
<% 

	Vector vLateSummary = new Vector();
	Vector vFiledAbsences = null;
	Vector vFiledOBOT = null;
	Vector vAwol = new Vector();
	Vector vNoLoggedOut = null;
	int k = 0;
	int iMaxLines = 0;
	String strCurrentStatus = null;
	String[] astrPTFT = {"Part Time", "Full Time"};
	
	for (int i = 0; i < vRetResult.size(); i+= 15) {
		vLateSummary.clear();
		vAwol.clear();
		iMaxLines = 0;
		
		if (strCurrentStatus == null) 
		strCurrentStatus = 
			astrPTFT[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+12),"1"))] +
			", " + (String)vRetResult.elementAt(i+3);
		
		if ((Vector)vRetResult.elementAt(i+5) != null) 
			vLateSummary.addAll((Vector)vRetResult.elementAt(i+5));

		if ((Vector)vRetResult.elementAt(i+6) != null) 
			vLateSummary.addAll((Vector)vRetResult.elementAt(i+6));
		
		vFiledAbsences = (Vector)vRetResult.elementAt(i+7);
		vFiledOBOT = (Vector)vRetResult.elementAt(i+8);
		
		if ((Vector)vRetResult.elementAt(i+9) != null) 
			vAwol.addAll((Vector)vRetResult.elementAt(i+9));
			
		if ((Vector)vRetResult.elementAt(i+10) != null)
			vAwol.addAll((Vector)vRetResult.elementAt(i+10));		
			
		vNoLoggedOut = (Vector)vRetResult.elementAt(i+11);

	// get the max lines ;
		if (vLateSummary != null) 
			iMaxLines = vLateSummary.size() / 5;
		
		if (vFiledAbsences != null && vFiledAbsences.size()/2 > iMaxLines ) 
			iMaxLines = vFiledAbsences.size()/2;

		if (vFiledOBOT != null && vFiledOBOT.size() > iMaxLines ) 
			iMaxLines = vFiledOBOT.size();
	
		if (vAwol != null && vAwol.size()/2 > iMaxLines)
			iMaxLines = vAwol.size()/2;
		
		if (vNoLoggedOut != null && vNoLoggedOut.size() > iMaxLines)
			iMaxLines = vNoLoggedOut.size();
		

	if (iMaxLines == 0) 
		iMaxLines++;
	
	if (i == 0 || 
			!strCurrentStatus.equals(astrPTFT[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+12),"1"))] +
			", " + (String)vRetResult.elementAt(i+3))) {  
			
	strCurrentStatus = astrPTFT[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+12),"1"))] +
			", " + (String)vRetResult.elementAt(i+3);
%>
    <tr>
      <td height="18" colspan="19" class="thinborder"><strong>&nbsp;<%=strCurrentStatus%></strong></td>
    </tr>
<%  
  }

	for (k = 0; k < iMaxLines;  k++){
	
%> 
    <tr>
	<% if (k == 0) {
			strTemp = (String)vRetResult.elementAt(i+2);
		}else{
			strTemp = "";
		}
	%> 
      <td class="thinborder" height="18"><font size="1">&nbsp;<%=strTemp%></font></td>
	 <% if (k == 0) 
	 		if ((vLateSummary == null || vLateSummary.size() ==0) 
				&& (vFiledAbsences == null || vFiledAbsences.size() ==0)
				&& (vFiledOBOT == null || vFiledOBOT.size() ==0)
				&& (vAwol == null || vAwol.size() ==0)
				&& (vNoLoggedOut == null || vNoLoggedOut.size() ==0))
		  		strTemp = "<img src=\"../../../images/tick.gif\"> ";
			else
				strTemp ="&nbsp;";
		else
			strTemp = "&nbsp;";
	 %>	  
      <!-- no record  -->	  
      <td class="thinborder"><font size="1"><%=strTemp%></font></td> 
	 <% if (k == 0) 
	 		if ((vFiledAbsences == null || vFiledAbsences.size() ==0)
				&& (vFiledOBOT == null || vFiledOBOT.size() ==0)
				&& (vAwol == null || vAwol.size() ==0))
		  		strTemp = "<img src=\"../../../images/tick.gif\"> ";
			else
				strTemp ="&nbsp;";
		else
			strTemp = "&nbsp;";
	 %>	  	  
	  
      <!-- no absents -->
      <td class="thinborder"><font size="1"><%=strTemp%></font></td> 

	 <% if (k == 0) 
	 		if ((String)vRetResult.elementAt(i+4) == null 
				&& (vLateSummary == null || vLateSummary.size() ==0) )
		  		strTemp = "<img src=\"../../../images/tick.gif\"> ";
			else
				strTemp ="&nbsp;";
		else
			strTemp = "&nbsp;";
	 %>	  		  
      <!-- no late -->
      <td class="thinborder"><font size="1"><%=strTemp%></font></td> 

 <% 
	 if (!strAllowedLate.equals("0")) { 
	 	if (k == 0){
	 		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;");
		 }else{
		 	strTemp =  "&nbsp;";
		 }
  %> 
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
  <% } 
	  	if (k == 0 && vLateSummary != null) {
			strTemp = Integer.toString(vLateSummary.size() / 5);
			if (strTemp.equals("0"))
				strTemp ="";
		}else{
			strTemp = "";
		}
	  %>
      <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
	<% if (vLateSummary != null &&  (k*5) < vLateSummary.size())
		strTemp = (String)vLateSummary.elementAt(k*5);
	   else
		strTemp = "&nbsp;";
	%>	
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	<% if (vLateSummary != null &&  (k*5) < vLateSummary.size())
		strTemp = (String)vLateSummary.elementAt(k*5 + 4) + " - " + 
				  (String)vLateSummary.elementAt(k*5 + 3);
	   else
		strTemp = "&nbsp;";
	%>	
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	<% if (vLateSummary != null &&  (k*5) < vLateSummary.size())
		strTemp = (String)vLateSummary.elementAt(k*5 + 1);
	   else
		strTemp = "&nbsp;";
	%>		  
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	<% if (vFiledAbsences != null &&  (k*2) < vFiledAbsences.size())
		strTemp = (String)vFiledAbsences.elementAt(k*2);
	   else
		strTemp = "&nbsp;";
	%>	
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	<% if (vFiledAbsences != null &&  (k*2) < vFiledAbsences.size())
		strTemp = (String)vFiledAbsences.elementAt(k*2 + 1);
	   else
		strTemp = "&nbsp;";
	%>		  
      <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
	  <%
	  	if (k == 0 && vFiledAbsences != null) {
			strTemp = Integer.toString(vFiledAbsences.size() / 2);
			if (strTemp.equals("0")) 
				strTemp = "&nbsp;";
		}else{
			strTemp = "&nbsp;";
		}
	  %>	  
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	<% if (vFiledOBOT != null &&  k < vFiledOBOT.size())
		strTemp = (String)vFiledOBOT.elementAt(k);
	   else
		strTemp = "&nbsp;";
	%>		  
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	  <%
	  	if (k == 0 && vFiledOBOT != null) {
			strTemp = Integer.toString(vFiledOBOT.size());
		}else{
			strTemp = "&nbsp;";
		}
	  %>		  
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	<% if (vAwol != null &&  k*2 < vAwol.size())
		strTemp = (String)vAwol.elementAt(k*2);
	   else
		strTemp = "&nbsp;";
	%>		  
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	<% if (vAwol != null &&  k*2 < vAwol.size())
		strTemp = (String)vAwol.elementAt(k*2 +1);
	   else
		strTemp = "&nbsp;";
	%>		   
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	  <%
	  	if (k == 0 && vAwol != null) {
			strTemp = Integer.toString(vAwol.size()/2);
			if (strTemp.equals("0")) 
				strTemp ="&nbsp;";
		}else{
			strTemp = "&nbsp;";
		}
	  %>	  
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
	<% if (vNoLoggedOut != null &&  k < vNoLoggedOut.size())
		strTemp = (String)vNoLoggedOut.elementAt(k) +  " no out";
	   else
		strTemp = "&nbsp;";
	%>			  
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
      <td class="thinborder"><font size="1">&nbsp;</font></td>
    </tr>
<%
 }// end employee.. 
}%>
  </table>
  <%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>