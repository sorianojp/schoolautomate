<%@ page language="java" import="utility.*,payroll.PReDTRME,java.util.Vector" buffer="16kb"%>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Absences","absences_encoding_print.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","DTR",request.getRemoteAddr(),
														"absences_encoding_print.jsp");
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ENCODE-FACULTY ABSENCES",request.getRemoteAddr(),
														null);
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
	PReDTRME prEdtrME = new PReDTRME();
	Vector vRetResult = null;

Vector vPersonalDetails = new Vector(); 
String strEmpID = WI.fillTextValue("emp_id");
if (strEmpID.length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	vRetResult  = prEdtrME.operateOnAbsenceEncoding(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prEdtrME.getErrMsg();

}//System.out.println(vPersonalDetails);

boolean bolPrintCheckList = false;
if(WI.fillTextValue("print_checklist").equals("1"))
	bolPrintCheckList = true;
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
 }
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
	TD.thinborderBOTTOM{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>

<body onLoad="<%if(strErrMsg == null){%>window.print()<%}%>">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25"><div align="center"><strong>:::: <%if(bolPrintCheckList){%>CHECK LIST<%}else{%>ABSENCES<%}%> <%if(bolIsSchool){%>FOR FACULTIES/<%}%>NON-DTR EMPLOYEES ::::</strong></div></td>
    </tr>
<%if(strErrMsg != null){%>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
<%}%>
</table>
  <%
if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Employee Name</td>
      <td width="36%"> <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
      <td width="17%">Employment Status</td>
      <td width="31%">&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(16),"")%></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>  
      
    <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</td>
      <td><strong>
	  <%if(vPersonalDetails.elementAt(13) != null){%>
	  <%=(String)vPersonalDetails.elementAt(13)%> ;
	  <%}if(vPersonalDetails.elementAt(14) != null){%>
	  <%=(String)vPersonalDetails.elementAt(14)%>
	  <%}%>
	  </strong></td>
      <td>Employment Type</td>
      <td>&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(15),"")%></strong></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="2" class="thinborderBOTTOM"><div align="center"><strong>LIST OF <%if(bolPrintCheckList){%>OFFENSES<%}else{%>ABSENCES<%}%></strong></div></td>
  </tr>
  <tr> 
    <td width="57%" height="26">TOTAL : <%=(String)vRetResult.remove(0)%> Min(s) </td>
    <td width="43%" height="26" align="right">Date and Time Printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>
<%if(bolPrintCheckList){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td width="10%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Date</td>
    <td width="20%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Time : Duration </td>
    <td width="10%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Room No. </td>
    <td width="10%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Subject</td>
    <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">On Post </td>
    <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Clean Board </td>
    <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">In-Uniform</td>
    <td width="35%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Reason</td>
    </tr>
  <%
String[] astrConvertAMPM = {"AM","PM"};
String[] astrConvertRemark = {"With leave application","Without leave application","Leave Application will be filed later"};	
String[] astrConvertSelection = {"No","Yes","N/A"};
for(int i = 0; i < vRetResult.size(); i += 20){%>
  <tr> 
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder"> <%if(vRetResult.elementAt(i + 3) != null && vRetResult.elementAt(i + 6) != null){%> <%=(String)vRetResult.elementAt(i + 3)+":"+CommonUtil.formatMinute((String)vRetResult.elementAt(i + 4))+" "+astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i + 5))]+ " to " +
	  (String)vRetResult.elementAt(i + 6)+":"+CommonUtil.formatMinute((String)vRetResult.elementAt(i + 7))+" "+astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i + 8))]+" ::: "%> <%}%> <%=(String)vRetResult.elementAt(i + 2)%> mins </td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 18), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 19), "&nbsp;")%></td>
    <td class="thinborder"><%=astrConvertSelection[Integer.parseInt((String)vRetResult.elementAt(i + 14))]%></td>
    <td class="thinborder"><%=astrConvertSelection[Integer.parseInt((String)vRetResult.elementAt(i + 15))]%></td>
    <td class="thinborder"><%=astrConvertSelection[Integer.parseInt((String)vRetResult.elementAt(i + 16))]%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 17), "&nbsp;")%></td>
    </tr>
  <%}%>
</table>
<%}else{%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td width="13%" height="25" class="thinborder"><div align="center"><font size="1"><strong><strong>DATE</strong></strong></font></div></td>
    <td width="36%" class="thinborder"><div align="center"><font size="1"><strong>TIME 
    ::: DURATION</strong></font></div></td>
    <td width="39%" class="thinborder"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
    <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>DEDUCTED 
    FROM SALARY </strong></font></div></td>
  </tr>
  <%
String[] astrConvertAMPM = {"AM","PM"};
String[] astrConvertRemark = {"With leave application","Without leave application","Leave Application will be filed later"};	
for(int i = 0; i < vRetResult.size(); i += 20){%>
  <tr> 
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder">&nbsp; <%if(vRetResult.elementAt(i + 3) != null && vRetResult.elementAt(i + 6) != null){%> <%=(String)vRetResult.elementAt(i + 3)+":"+CommonUtil.formatMinute((String)vRetResult.elementAt(i + 4))+" "+astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i + 5))]+ " to " +
	  (String)vRetResult.elementAt(i + 6)+":"+CommonUtil.formatMinute((String)vRetResult.elementAt(i + 7))+" "+astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i + 8))]+" ::: "%> <%}%> <%=(String)vRetResult.elementAt(i + 2)%> mins </td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 10);
				if(strTemp == null || strTemp.length() == 0){
					strTemp = "";
				}else{
					strTemp = WI.getStrValue(strTemp, "1");
					strTemp = astrConvertRemark[Integer.parseInt(strTemp)];
				}
			%>	
      <td class="thinborder">&nbsp;<%=strTemp%></td>
    <td class="thinborder" align="center">&nbsp; 		
		<%
		if(((String)vRetResult.elementAt(i+13)).equals("1")){%>
			<img src="../../../images/tick.gif">
		<%}else{%>
			<img src="../../../images/x.gif">
		<%}%>
	</td>
  </tr>
  <%}%>
</table>

<%}//end of printin if it is for checklist or not.. %>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="76%" height="25">Printed By : </td>
    <td width="24%"><%if(bolPrintCheckList){%>Verified By<%}%></td>
  </tr>
  <tr>
    <td height="25" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<u><%=(String)request.getSession(false).getAttribute("first_name")%></u></td>
    <td height="25" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%if(bolPrintCheckList){%><u>Monitoring Head</u><%}%> </td>
  </tr>
</table>


<%}//if vRetResult is not null. 
}//show only if personal detail is found."
%>  
</body>
</html>
<%
dbOP.cleanUP();
%>