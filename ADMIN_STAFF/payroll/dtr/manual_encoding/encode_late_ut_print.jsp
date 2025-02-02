<%@ page language="java" import="utility.*,java.util.Vector,payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>ENCODE FACULTY HOURS WORKED</title>
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
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script> 
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//add security here. 

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Encode Faculty Hours","encode_late_ut.jsp");
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
														"Payroll","DTR",request.getRemoteAddr(),
														"encode_late_ut.jsp");
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
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"encode_late_ut_print.jsp");
	if(iAccessLevel == 0){//NOT AUTHORIZED.
		dbOP.cleanUP();
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}	
}

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	int iSearchResult = 0;
	int i = 0;
	String strPayrollPeriod  = null;
	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");			
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
	  }//end of if condition.		  
	 }//end of for loop.		
	vRetResult = prEdtrME.operateOnManualLateUtEncoding(dbOP,request, 4);
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="10" align="center" class="thinborder"><strong>LIST OF EMPLOYEES WITH MANUAL ENCODED LATE/UNDERTIME FOR <%=strPayrollPeriod%></strong></td>
    </tr>
    <tr>
      <td width="3%" rowspan="2" class="thinborder">&nbsp;</td>
      <td width="3%" rowspan="2" class="thinborder">&nbsp;</td> 
      <td width="26%" height="23" rowspan="2" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="24%" rowspan="2" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
      <%if(WI.fillTextValue("viewOption").equals("1")){%>
			<td colspan="2" align="center" class="thinborder">			  <strong><font size="1">LATE</font></strong>		  </td>
      <td colspan="2" align="center" class="thinborder">        <strong><font size="1">UNDERTIME</font></strong>      </td>
			<%}else{%>
      <td colspan="2" align="center" class="thinborder">        <strong><font size="1">AMOUNT</font></strong>      </td>
			<%}%>
    </tr>
    <tr>
			<%if(WI.fillTextValue("viewOption").equals("1")){%>
      <td width="6%" align="center" class="thinborder">        <strong><font size="1">Hours</font></strong>      </td>
      <td width="6%" align="center" class="thinborder">        <strong><font size="1">Minutes</font></strong>      </td>
      <td width="6%" align="center" class="thinborder">        <strong><font size="1">Hours</font></strong>      </td>
      <td width="6%" align="center" class="thinborder">        <strong><font size="1">Minutes</font></strong>      </td>
			<%}else{%>
      <td width="7%" align="center" class="thinborder">        <strong><font size="1">LATE</font></strong>      </td>
      <td width="7%" align="center" class="thinborder">        <strong><font size="1">UNDERTIME</font></strong>      </td>
			<%}%>
    </tr>
    <% int iCount = 1;
		for (i = 0; i < vRetResult.size(); i+=20,iCount++){ %>
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="late_index_<%=iCount%>" value="<%=vRetResult.elementAt(i)%>">
			<input type="hidden" name="user_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">
			<input type="hidden" name="hourly_rate_<%=iCount%>" value="<%=vRetResult.elementAt(i+14)%>">			
      <%if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%> </td>
		<%if(WI.fillTextValue("viewOption").equals("1")){%>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 8);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
      <td align="center" class="thinborder"> <%=strTemp%></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
      <td align="center" class="thinborder"><%=strTemp%></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 10);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>						
      <td align="center" class="thinborder"><%=strTemp%></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 11);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>						
      <td align="center" class="thinborder"><%=strTemp%></td>
			<%}else{%>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 12);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>				
      <td align="center" class="thinborder"><%=strTemp%></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 13);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>				
      <td align="center" class="thinborder"><%=strTemp%></td>
			<%}%>
    </tr>
    <%} //end for loop%>
    
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
<% } // end vRetResult != null && vRetResult.size() > 0 %> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>