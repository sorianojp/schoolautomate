<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportMultipleWH, java.util.Date" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(7);
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0){
		bolMyHome = true;
		strColorScheme = CommonUtil.getColorScheme(9);
	}		
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.bgDynamic {
		background-color:<%=strColorScheme[1]%>
	}

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
    }
 
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
	
	  TD.thinborder12 {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
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
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));


//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","faculty_sched_detail.jsp");

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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(),
														"faculty_sched_detail.jsp");
strTemp = (String)request.getSession(false).getAttribute("userId");

if (strTemp != null ){
	if(bolMyHome){
		iAccessLevel = 1;
		request.setAttribute("emp_id",strTemp);
	}
}

if (strTemp == null)
	strTemp = "";
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

ReportMultipleWH TInTOut = new ReportMultipleWH();
Vector vRetResult = null;
Vector vFacultyRate = null;
String[] astrSubjType = {"Lec", "Lab", "RLE", "NSTP","GRAD"};
String[] astrWeekday = {"SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"};
double[] adSubjTotal = new double[5];
double[] adSubjRendered = new double[5];
double[] adFacultyRate = new double[5];
double dDuration = 0d;
double dDeducted = 0d;
String strSubjType = "0";
String strDateFr = WI.fillTextValue("login_fr");
String strDateTo = WI.fillTextValue("login_to");
int iSubjType = 0;
boolean bolShowEquivalent = false;
int iCols = 0;

  String[] astrConverAMPM = {"AM","PM"};

	if(bolMyHome)
		strTemp = strUserID;
	else
		strTemp = WI.fillTextValue("emp_id");

	vRetResult = TInTOut.viewFacultyDtrDetails(dbOP, request);
	
	if (vRetResult == null || vRetResult.size() == 0){
		strErrMsg  = TInTOut.getErrMsg();
	}else{
		vFacultyRate = TInTOut.getFacultyRateDetails(dbOP, strTemp, strDateFr, strDateTo);
 		if(vFacultyRate != null && vFacultyRate.size() > 0){
			adFacultyRate[0] = Double.parseDouble((String)vFacultyRate.elementAt(10));
			adFacultyRate[1] = Double.parseDouble((String)vFacultyRate.elementAt(11));
			adFacultyRate[2] = Double.parseDouble((String)vFacultyRate.elementAt(12));
			adFacultyRate[3] = Double.parseDouble((String)vFacultyRate.elementAt(13));
			adFacultyRate[4] = Double.parseDouble((String)vFacultyRate.elementAt(14));
		}else{
			strErrMsg  = TInTOut.getErrMsg();
		}
	}
%>

<form name="form_">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="white">
  
  <tr>
    <td width="4%" height="25">&nbsp;</td>
    <td width="15%" nowrap>Employee ID </td>
		<%
			if(bolMyHome)
				strTemp = strUserID;
			else
				strTemp = WI.fillTextValue("emp_id");		
		%>		
    <td width="81%"><strong><%=strTemp%></strong></td></tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>Date</td>
    <td><strong><%=WI.fillTextValue("login_fr")%></strong> to <strong><%=WI.fillTextValue("login_to")%></strong></td>
  </tr>
	</table>

  <%
	if ((vRetResult != null) && (vRetResult.size()>0)) { %>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
   <tr>
     <td width="14%" height="26" align="center" class="thinborder"><strong>Scheduled Time </strong></td>
     <td width="8%" align="center" class="thinborder"><strong>Time in </strong></td>
     <td width="7%" align="center" class="thinborder"><strong>Loc</strong></td>
     <td width="8%" align="center" class="thinborder"><strong>Time out </strong></td>
     <td width="7%" align="center" class="thinborder"><strong>Loc</strong></td>
     <td width="6%" align="center" class="thinborder"><strong>ACTUAL LATE</strong></td>
     <%if(bolShowEquivalent){%>
		 <td width="6%" align="center" class="thinborder"><strong>EQUIV.<br>
      LATE</strong></td>
		 <%}%>
     <td width="5%" align="center" class="thinborder"><strong>UT</strong></td>
     <td width="7%" align="center" class="thinborder"><strong>SUBJECT TYPE </strong></td>
     <td width="7%" align="center" class="thinborder"><strong>HOURS REQUIRED </strong></td>     
     <td width="7%" align="center" class="thinborder"><strong>HOURS RENDERED </strong></td>
		 <%if(WI.fillTextValue("show_amount").length() > 0){%>
     <td width="9%" align="center" class="thinborder"><strong>AMOUNT CREDIT</strong></td>
		 <td width="9%" align="center" class="thinborder"><strong>AMOUNT TO DEDUCT </strong></td>		 
		 <%}%>
		 <td width="9%" align="center" class="thinborder"><strong>LAST ADJUSTED </strong></td>
   </tr>
   <% int iCount = 1;
	 	String strLoginDate = null;
		String strCurrentDate = null;
		Date dtLoginDate = null;
		//for(int o = 0; o < 15; o++)
		//	System.out.println("" + WI.formatDate("11/25/2011", o));
 		for(int i = 0; i < vRetResult.size(); i += 35, iCount++){
	 %>
	 <%
	 	
		if((i == 0 || !((Date)vRetResult.elementAt(i+1)).equals(dtLoginDate)) && !WI.fillTextValue("group_option").equals("1")){
			strLoginDate = ConversionTable.convertMMDDYYYY((Date)vRetResult.elementAt(i+1));
		dtLoginDate = (Date)vRetResult.elementAt(i+1);
	 %>
   <tr>
	 		<%
			if(WI.fillTextValue("show_amount").length() > 0){
				iCols = 13;
			}else{
				iCols = 11;
			}
			if(bolShowEquivalent)
				iCols++;
			%>
     <td height="25" colspan="<%=iCols%>" class="thinborder">&nbsp;<strong><%=WI.formatDate(strLoginDate, 3)%></strong></td>
    </tr>
	 <%}%>
   <tr>
	 	<input type="hidden" name="info_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<input type="hidden" name="sched_login_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+3)%>">
		<input type="hidden" name="sched_logout_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+7)%>">
     <%
			strTemp = (String)vRetResult.elementAt(i + 4);		
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 8);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+9),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+10))];
			%>
     <td height="19" align="right" nowrap class="thinborder">&nbsp;<%=strTemp%></td>
		 <input type="hidden"	 name="schedule_<%=iCount%>" value="<%=strTemp%>">
		<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+25));
		%>	
     <td align="right" nowrap class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
		 <%
		 strTemp = WI.getStrValue((String)vRetResult.elementAt(i+30));
		 %>		 
		 <td class="thinborder">&nbsp;<%=strTemp%></td>
		 <%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+26));
		%>		 
		 <td align="right" nowrap class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
		 <%	
		 strTemp = WI.getStrValue((String)vRetResult.elementAt(i+31));
		 %>		 		 
		 <td class="thinborder">&nbsp;<%=strTemp%></td>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+20));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%if(bolShowEquivalent){%>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14));			
		 %>		 		 
		 <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%}%>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%
		 strSubjType = WI.getStrValue((String)vRetResult.elementAt(i + 24),"0");
		 iSubjType = Integer.parseInt(strSubjType);
		 %>
     <td class="thinborder">&nbsp;<%=astrSubjType[iSubjType]%></td>
		<%
				dDuration = Double.parseDouble((String)vRetResult.elementAt(i + 28));
				dDuration = dDuration/3600000;
				adSubjTotal[iSubjType] += dDuration;
				dDeducted = dDuration;
			%>		 
     <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dDuration, false)%> hrs</td>
		 <%
		 	strTemp = (String)vRetResult.elementAt(i+29);
			dDuration = Double.parseDouble(strTemp);
			strTemp = CommonUtil.formatFloat(strTemp, false);
			adSubjRendered[iSubjType] += dDuration;
			if(dDuration == 0d)
				strTemp = "";
			dDeducted -= dDuration;
			if(dDeducted < 0)
				dDeducted = 0;
		 %>
     <td align="right" class="thinborder"><%=WI.getStrValue(strTemp, ""," hr(s)","&nbsp;")%>&nbsp;</td>
		<%if(WI.fillTextValue("show_amount").length() > 0){%>
		<%
			strTemp = CommonUtil.formatFloat(dDuration * adFacultyRate[iSubjType], true);			
		%>
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 
		<%
			strTemp = CommonUtil.formatFloat(dDeducted * adFacultyRate[iSubjType], true);			
		%>		 
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>		 			
			<%}%>
			<%	
		 strTemp = WI.getStrValue((String)vRetResult.elementAt(i+32));
		 %>	
			<td class="thinborder">&nbsp;<%=strTemp%></td>
   </tr>
   
   <%}%>
	  <input type="hidden" name="emp_count" value="<%=iCount%>">
 </table>
	<br>

 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF"> 
  <tr>
    <td><strong>DTR SUMMARY FOR PERIOD <%=WI.fillTextValue("login_fr")%> </strong>to <strong><%=WI.fillTextValue("login_to")%></strong></td>
  </tr>
</table>

 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td height="20" colspan="5" class="thinborder12"><strong>HOURS REQUIRED </strong></td>
    </tr>
  <tr>
    <td width="16%" height="18" align="center" class="thinborder12">Lecture</td>
    <td width="16%" align="center" class="thinborder12">Laboratory</td>
    <td width="16%" align="center" class="thinborder12">RLE</td>
    <td width="16%" align="center" class="thinborder12">NSTP</td>
    <td width="16%" align="center" class="thinborder12">Graduate</td>
    </tr>
   <tr>
		<%
		strTemp = null;
		if(adSubjTotal[0] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[0], true) + " hr(s)";
		%>
    <td align="right" class="thinborder12" height="18"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjTotal[1] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[1], true) + " hr(s)";
		%>
    <td align="right" class="thinborder12"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjTotal[2] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[2], true) + " hr(s)";
		%>
    <td align="right" class="thinborder12"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjTotal[3] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[3], true) + " hr(s)";
		%>
    <td align="right" class="thinborder12"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjTotal[4] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjTotal[4], true) + " hr(s)";
		%>
    <td align="right" class="thinborder12"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
    </tr>
 </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td height="17" colspan="5" class="thinborder12"><strong>HOURS RENDERED </strong></td>
    </tr>
  <tr>
    <td width="16%" align="center" class="thinborder12" height="18">Lecture</td>
    <td width="16%" align="center" class="thinborder12">Laboratory</td>
    <td width="16%" align="center" class="thinborder12">RLE</td>
    <td width="16%" align="center" class="thinborder12">NSTP</td>
    <td width="16%" align="center" class="thinborder12">Graduate</td>
    </tr>
   <tr>
		<%
		strTemp = null;
		if(adSubjRendered[0] > 0d)
			strTemp = CommonUtil.formatFloat(adSubjRendered[0], true);
		%>
    <td align="right" class="thinborder12" height="18"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjRendered[1] > 0d)		
			strTemp = CommonUtil.formatFloat(adSubjRendered[1], true);
		%>
    <td align="right" class="thinborder12"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjRendered[2] > 0d)			
			strTemp = CommonUtil.formatFloat(adSubjRendered[2], true);
		%>
    <td align="right" class="thinborder12"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjRendered[3] > 0d)			
			strTemp = CommonUtil.formatFloat(adSubjRendered[3], true);
		%>
    <td align="right" class="thinborder12"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
		<%
		strTemp = null;
		if(adSubjRendered[4] > 0d)			
			strTemp = CommonUtil.formatFloat(adSubjRendered[4], true);
		%>
    <td align="right" class="thinborder12"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
    </tr>
 </table>
   <%} // end else (vRetResult == null)%>
   <input type="hidden" name="page_action" value="">
 <input type="hidden" name="print_page">
 <input type="hidden" name="viewonly" value="<%=WI.fillTextValue("viewonly")%>">
 <input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
