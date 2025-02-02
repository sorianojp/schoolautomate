<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script> 
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.MultipleWorkingHour" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
 
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","dtr_multiple_report.jsp");

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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"dtr_multiple_report.jsp");
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

///// exclusive for testers only.. 
String strUserID = (String)request.getSession(false).getAttribute("userId");
//////////////////
String[] astrWeekday = {"N/A", "S", "M", "T", "W", "TH", "F", "SAT"};

MultipleWorkingHour TInTOut = new MultipleWorkingHour();
Vector vRetResult = null;
  String[] astrConverAMPM = {"AM","PM"};

	vRetResult = TInTOut.getEmpLogsDateRange(dbOP, request);
	
	if (vRetResult == null || vRetResult.size() == 0){
		strErrMsg  = TInTOut.getErrMsg();
	}
%>

<form name="form_">
  <%
	if ((vRetResult != null) && (vRetResult.size()>0)) { %>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
   <tr>
     <td height="25" colspan="7" align="center" class="thinborder"><strong>LIST OF 
       TIME RECORDED FOR ID : <strong><%=WI.fillTextValue("emp_id").toUpperCase()%></strong></strong></td>
   </tr>
   <tr>
     <td width="28%" height="26" align="center" class="thinborder"><strong>Scheduled Time </strong></td>
     <td width="27%" align="center" class="thinborder"><strong>Actual Time </strong></td>
     <td width="15%" align="center" class="thinborder"><strong>ACTUAL LATE</strong></td>
     <td width="15%" align="center" class="thinborder"><strong>EQUIVALENT<br>
LATE</strong></td>
     <td width="15%" align="center" class="thinborder"><strong>UNDERTIME</strong></td>
     <!--
		 <td width="15%" align="center" class="thinborder"><strong>HOURS WORKED </strong></td>
		 -->
     <td width="15%" align="center" class="thinborder"><strong>POSTED</strong></td>
   </tr>
   <% int iCount = 1;
	 	String strLoginDate = null;
		String strCurrentDate = null;
 		for(int i = 0; i < vRetResult.size(); i += 25, iCount++){
	 %>
	 <%
	 	if(i == 0 || !((String)vRetResult.elementAt(i+2)).equals(strLoginDate)){
			strLoginDate = (String)vRetResult.elementAt(i+2);
	 %>
   <tr>
     <td height="25" colspan="7" class="thinborder">&nbsp;<%=strLoginDate%>&nbsp;<%=astrWeekday[eDTR.eDTRUtil.getWeekDay(strLoginDate)]%></td>
    </tr>
	 <%}%>
   <tr>
	 	<input type="hidden" name="info_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<input type="hidden" name="sched_login_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+13)%>">
		<input type="hidden" name="sched_logout_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+14)%>">
     <%
			strTemp = (String)vRetResult.elementAt(i + 3);		
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+4),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+5))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 6);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+7),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+8))];
			%>
     <td height="19" align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
		 <input type="hidden"	 name="schedule_<%=iCount%>" value="<%=strTemp%>">
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11));			
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12), strTemp + " - ","", strTemp);
		 %>
     <td align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+19));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+16));			
		 %>		 
		 <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <!--
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+17));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 -->
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+18));
			if(strTemp.equals("1"))
				strTemp = "Yes";
			else
				strTemp = "No";
		 %>		 
     <td align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
   </tr>
   
   <%}%>
  </table>
   <%} // end else (vRetResult == null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
