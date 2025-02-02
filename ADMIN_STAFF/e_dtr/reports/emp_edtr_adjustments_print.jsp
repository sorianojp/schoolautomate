<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of EDTR Adjustments</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>
</head>
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.TimeInTimeOut" %>
<%
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics - Employees with Adjustments",
								"emp_dtr_adjustments.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"dtr_view.jsp");	
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

ReportEDTR RE = new ReportEDTR(request);
TimeInTimeOut tRec = new TimeInTimeOut();


	vRetResult = RE.searchEDTRAdjustments(dbOP);
	if (vRetResult == null || vRetResult.size() == 0) {	
		strErrMsg = RE.getErrMsg();
	}else{
		iSearchResult = RE.getSearchCount();	
	}


if (strErrMsg != null) { 
%>

<table width="100%" border="0" cellspacing="0" cellpadding="3">
  <tr bgcolor="#FFFFFF">
    <td width="2%" height="25">&nbsp;</td>
    <td width="21" height="25" colspan="2"><font color="#FF0000" size="3"><strong>&nbsp;
        <%=WI.getStrValue(strErrMsg)%></strong></font></td>
  </tr>
</table>
<%} if (vRetResult!= null && vRetResult.size() > 0) { %>
<div align="center"> 
	<font size="2"> 
			<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            Human Resources Development Center<br> </font><br>
<br>

       
</div>

<table width="100%" border="0" cellpadding="1" cellspacing="0" class="thinborder">
          <tr bgcolor="#006A6A"> 
		  	<% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
            <td height="25"  colspan="9" align="center" bgcolor="#F8EFF7" class="thinborder"><strong>LIST 
            OF EMPLOYEE DTR ADJUSTMENTS (<%=strTemp%>)</strong></td>
          </tr>
          <tr> 
            <td width="24%" height="25" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE</font></strong></td>
            <td width="8%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>STATUS</strong></font></td>
            <td width="10%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ACTUAL DATE </strong></font></td>
            <td width="12%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ACTUAL TIME </strong></font></td>
            <td width="12%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ADJUSTED<br> 
            DATE</strong></font></td>
            <td width="12%" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ADJUSTED <br>
            TIME</strong></font></td>
            <td width="10%" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ADJ BY </strong></font></td>
            <td width="12%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>DATE </strong></font></td>
		<!-- no delete allowed heheheheh 
            <td width="9%" height="30" bgcolor="#EBEBEB" class="thinborder">&nbsp;</td>
		--> 
          </tr>
<% 
String strTempName = null;
String strEmpName = null;
String strCurrID = null;
long lTemp = 0l;
String strAdjBy = null;

for (int i = 0; i < vRetResult.size();  i+=22){
	if (strCurrID !=null && strCurrID.equals((String)vRetResult.elementAt(i+1))){
		strEmpName = "";
	}else{
		strCurrID = (String)vRetResult.elementAt(i+1);
		strEmpName = WI.formatName((String)vRetResult.elementAt(i+2),
									(String)vRetResult.elementAt(i+3),
									(String)vRetResult.elementAt(i+4),4);
	}
		strAdjBy = "";
		if ((String)vRetResult.elementAt(i+15) != null)
			strAdjBy += (((String)vRetResult.elementAt(i+15)).substring(0, 1)).toLowerCase();
		if ((String)vRetResult.elementAt(i+16) != null)
			strAdjBy += (((String)vRetResult.elementAt(i+16)).substring(0, 1)).toLowerCase();
		strAdjBy += (String)vRetResult.elementAt(i+17);		
%>
   <%if(strEmpName.length() > 0){%>
	 <tr>
     <td height="20" colspan="8" class="thinborder"><strong><%=strEmpName%></strong></td>
   </tr>
	 <%}%>
	<%
	lTemp = ((Long)vRetResult.elementAt(i+5)).longValue();	
	
	if (lTemp != 0){ 
		strTempName = "Time In"; // status
	//	strTemp2 = ; //  old date 
	//	strTemp4 = ;  // adjusted date
	
	
		if (((Long)vRetResult.elementAt(i+9)).longValue() != 0 )
			strTemp3 = WI.formatDateTime(((Long)vRetResult.elementAt(i+9)).longValue(),2);
		 else
			strTemp3 = "&nbsp;";
	
	%>

   <tr> 
    <td height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+18),"&nbsp;")%></td> 
	<td class="thinborder"><%=strTempName%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;")%></td>            
    <td class="thinborder"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.formatDateTime(lTemp,2)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(strAdjBy,"&nbsp;")%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
  </tr>	
  
<% 
	strEmpName = "";
} 

lTemp = ((Long)vRetResult.elementAt(i+6)).longValue();	

if (lTemp != 0){ 
	strTempName = "Time Out"; // status
//	strTemp3 = Long.toString(((Long)vRetResult.elementAt(i+10)).longValue()); //  old time out

	if (((Long)vRetResult.elementAt(i+10)).longValue() != 0 )
	 	strTemp3 = WI.formatDateTime(((Long)vRetResult.elementAt(i+10)).longValue(),2);
	 else
	 	strTemp3 = "&nbsp;";
%>
   <tr> 
    <td height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+18),"&nbsp;")%></td> 
	<td class="thinborder"><%=strTempName%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),"&nbsp;")%></td>            
    <td class="thinborder"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.formatDateTime(lTemp,2)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(strAdjBy,"&nbsp;")%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
  </tr>	
<% } // check if time out is needed.. 
} // end for loop
%>
  </table>
<%}%>		
</form>
</body>
</html>
<% dbOP.cleanUP(); %>