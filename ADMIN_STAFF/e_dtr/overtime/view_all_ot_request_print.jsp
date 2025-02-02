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
<body bgcolor="#FFFFFF" onLoad="window.print()">

<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.eDTRUtil" %>
<% 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	
	int i = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Edit Overtime","view_all_ot_request.jsp");
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
											"eDaily Time Record","OVERTIME MANAGEMENT",
											request.getRemoteAddr(),"view_all_ot_request.jsp");	
if(iAccessLevel == 0){
 iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","OVERTIME MANAGEMENT-View/Edit Overtime",
											request.getRemoteAddr(),"view_all_ot_request.jsp");	
}

if(iAccessLevel == 0){
 iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","STATISTICS & REPORTS",
											request.getRemoteAddr(),"view_all_ot_request.jsp");	
}
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


int iSearchResult = 0;

ReportEDTR RE = new ReportEDTR(request);
double dTotal = 0d;
int iTempMin = 0;
int iTempHr = 0;
double dTemp = 0d;
double dHoursOT = 0d;

String strSchName  = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddr1    = SchoolInformation.getAddressLine1(dbOP,false,false);
String strAddr2    = SchoolInformation.getAddressLine2(dbOP,false,false);
String strDateTime = WI.getTodaysDateTime();
String strTitle    = "Summary of OverTime";
if(WI.fillTextValue("DateFrom").length() > 0) {
	if(WI.fillTextValue("DateTo").length() > 0)
		strTitle += " for Duration " + WI.fillTextValue("DateFrom")+" to "+ WI.fillTextValue("DateTo");
	else
		strTitle += " for Date " + WI.fillTextValue("DateFrom");
}	
int iPageNo = 0;	
int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
int iCurRow = 0;

//this page is used by two pages. 1 print only the uncredited_ot, 2 normal printing of ot
Vector vRetResult = (WI.getStrValue(WI.fillTextValue("uncredited_only"),"0").equals("1") )?RE.searchUncreditedOvertime(dbOP, true):RE.searchOvertime(dbOP, true);
	if (vRetResult==null){
		strErrMsg =  RE.getErrMsg();
	}else{
		iSearchResult = RE.getSearchCount();
	}

if (vRetResult != null && vRetResult.size()>0) { 

	for (i=0 ; i < vRetResult.size();){
		iCurRow = 0; 
		if(i > 0) {%>
			<DIV style="page-break-before:always" >&nbsp;</DIV>
		<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td align="center"><font size="2"><strong><%=strSchName%></strong></font><br>
		   <font size="1">
				<%=strAddr1%><br><%=strAddr2%><br><strong><%=strTitle%></strong>
				<div align="right">
					Date and Time Printed: <%=strDateTime%> &nbsp;&nbsp; &nbsp; &nbsp; Page# <%=++iPageNo%> <!--of <%//=iTotalPages%>-->
				</div>
		   </font></td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <%if(WI.fillTextValue("show_division").length() > 0){%>
				<td width="18%" align="center" class="thinborder"><strong><font size="1">Department / Office</font></strong></td>
        <%}if(WI.fillTextValue("remove_req_by").length() == 0){%>
        	<td width="17%" align="center" class="thinborder"><strong><font size="1">Requested by </font></strong></td>
		<%}%>
        <td width="17%" align="center" class="thinborder"><font size="1"><strong>Requested For</strong></font></td>
        <%if(WI.fillTextValue("remove_date_of_req").length() == 0){%>
        	<td width="10%" align="center" class="thinborder"><font size="1"><strong>Date of Request</strong></font></td>
        <%}%>
		<td width="10%" align="center" class="thinborder"><font size="1"><strong>OT Date</strong></font></td>
        <td width="12%" align="center" class="thinborder"><font size="1"><strong>Inclusive Time</strong></font></td>
        <td width="4%" align="center" class="thinborder"><font size="1"><strong>No. of Hours</strong></font></td>
        <%if(WI.fillTextValue("show_details").length() > 0 || WI.fillTextValue("show_reason").length() > 0){%>
				<td width="25%" align="center" class="thinborder"><font size="1"><strong>Details</strong></font></td>
        <%}if(WI.fillTextValue("remove_status").length() == 0){%>
        <td width="9%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>
		<%}if(WI.fillTextValue("show_cost").length() > 0){%>
				<td width="7%" align="center" class="thinborder"><font size="1"><strong>Cost</strong></font></td>
		<%}%>
      </tr>
        <%
			for (; i < vRetResult.size();i+=45){ 
		 %>
      <tr>
				<%if(WI.fillTextValue("show_division").length() > 0){%>
				<%if((String)vRetResult.elementAt(i + 21)== null || (String)vRetResult.elementAt(i + 23)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}
				%>					
        <td class="thinborder" height="20" style="font-size:9px;">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 22),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 23),"")%></td>
				<%}%>
				
				<%
					strTemp2 = WI.formatName((String)vRetResult.elementAt(i+15), 
										(String)vRetResult.elementAt(i+16), (String)vRetResult.elementAt(i+17), 4);
					strTemp = (String)vRetResult.elementAt(i);				
        if(WI.fillTextValue("remove_req_by").length() == 0){%>
        	<td class="thinborder" style="font-size:9px;">&nbsp;<%=WI.getStrValue(strTemp2, "", "<br>(" + strTemp + ")","")%></td>
        <%} if (strTemp.equals((String)vRetResult.elementAt(i+1)))
						strTemp = "&nbsp;";
					else{
						strTemp = WI.formatName((String)vRetResult.elementAt(i+18), 
											(String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), 4);
						strTemp += "(" + (String)vRetResult.elementAt(i+1) + ")";
					}
				%>
        <td class="thinborder" style="font-size:9px;">&nbsp;<%=strTemp%></td>
        <%if(WI.fillTextValue("remove_date_of_req").length() == 0){%>
        	<td class="thinborder" style="font-size:9px;">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
        <%} 
		   		strTemp = eDTRUtil.formatWeekDay((String)vRetResult.elementAt(i+6));
		   		if (strTemp  == null || strTemp.length() < 1){
		   			strTemp = (String)vRetResult.elementAt(i+4);
			    }else{
					strTemp = " every " + strTemp + "<br>(" + (String)vRetResult.elementAt(i+4) + 
							" - " +	(String)vRetResult.elementAt(i+5) + ")";
				}
			%>
        <td align="center" class="thinborder" style="font-size:9px;">          <%=strTemp%></td>
        <td align="center" class="thinborder" style="font-size:9px;">
					<%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
			                               (String)vRetResult.elementAt(i+8),
										   (String)vRetResult.elementAt(i+9))%> -
                  <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%></td>
				<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), false);
				if(WI.fillTextValue("show_actual").length() > 0){
					strTemp = ConversionTable.replaceString(strTemp, ",","");
					dHoursOT = Double.parseDouble(strTemp);
					iTempHr = (int)dHoursOT;
					dTemp = dHoursOT - iTempHr;
					iTempMin = (int)((dTemp * 60) + 0.2);
					strTemp = iTempHr + ":" + CommonUtil.formatMinute(Integer.toString(iTempMin));
				}				
				%>									 
        <td class="thinborder" style="font-size:9px;">&nbsp;<%=strTemp%></td>
        <%if(WI.fillTextValue("show_details").length() > 0 || WI.fillTextValue("show_reason").length() > 0){%>
				<%
					strTemp = (String)vRetResult.elementAt(i+29);	
					strTemp = WI.getStrValue(strTemp,"&nbsp;");
					if(WI.fillTextValue("show_reason").length() == 0) 
						strTemp += WI.getStrValue((String)vRetResult.elementAt(i+35), "<br>-<font color='#FF0000'>", "</font>","");
				%>
				<td class="thinborder"><font size="1"><%=strTemp%></font></td>
				<%}%>
        <%
				strTemp = (String)vRetResult.elementAt(i+13);
				if(strTemp.equals("1")){ 
					strTemp = "APPROVED ";
				}else if (strTemp.equals("0")){
					strTemp = "DISAPPROVED";
				}else
					strTemp = "PENDING";
        if(WI.fillTextValue("remove_status").length() == 0){%>
        	<td class="thinborder" style="font-size:9px;"><font size="1">&nbsp;<%=strTemp%></font></td>
        <%}if(WI.fillTextValue("show_cost").length() > 0){
					strTemp = (String)vRetResult.elementAt(i+28);
					strTemp = CommonUtil.formatFloat(strTemp, true);					
					dTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
				%>
				<td align="right" class="thinborder" style="font-size:9px;"><%=strTemp%></td>
				<%}%>		
      </tr>
	<%
	++iCurRow;
	if(iCurRow >= iMaxRecPerPage)
		break;
	}%>					
  </table>
<% }%>
  <%if(WI.fillTextValue("show_cost").length() > 0){%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td align="right"><strong>Total OT Cost :&nbsp; <%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</strong></td>
      </tr>
	</table>
  <%}%>	
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>