<%@ page language="java" import="utility.*,health.HealthReport,java.util.Vector " %>
<%
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	//strColorScheme is never null. it has value always.
	
	boolean bolIsEdit = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
</style>

</head>


<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null; String strTemp2 = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Health Examination Record","health_exam_print.jsp");
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
															"Health Monitoring","Health Examination Record",request.getRemoteAddr(),
															"health_exam_print.jsp");
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

Vector vBasicInfo = new Vector();
Vector vEditInfo  = new Vector();

HealthReport HR = new HealthReport();

Vector vHistDetail = new Vector();
Vector vUrineTest  = new Vector();
Vector vHistLastTaken = new Vector();
String strCourse = "";

if(WI.fillTextValue("stud_id").length() > 0){
	vBasicInfo = HR.operateOnHealthRecord(dbOP, request, 5);
	if(vBasicInfo == null)
		strErrMsg = HR.getErrMsg();
	else{
		vEditInfo = HR.operateOnHealthRecord(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = HR.getErrMsg();
		else{
			vUrineTest = (Vector)vEditInfo.remove(0);
			vHistLastTaken = (Vector)vEditInfo.remove(0);		
			vHistDetail = (Vector)vEditInfo.remove(0);
		}
		
		
		strCourse = (String)vBasicInfo.elementAt(4);		
	}	
}
	
	
	
boolean bolShowAll = false;
boolean bolShowChest = false;
boolean bolShowHearing = false;
boolean bolShowHBSag = false;
boolean bolShowCBC = false;
boolean bolShowStool = false;
boolean bolShowIshihara = false;
boolean bolShowUrinalyisis = false;
boolean bolShowHepaB = false;
if(strCourse.equals("BSMT") || strCourse.equals("BSMarE"))
	bolShowAll = true;
if(strCourse.equals("SC/SC") || strCourse.equals("BSHRM")){
	bolShowChest = true;
	bolShowHearing = true;
	bolShowHBSag = true;
	bolShowCBC = true;
	bolShowStool = true;
	bolShowIshihara = false;
	bolShowUrinalyisis = true;
	bolShowHepaB = true;
}
if(!strCourse.equals("SC/SC") && !strCourse.equals("BSHRM") && !strCourse.equals("BSMT") && !strCourse.equals("BSMarE")){
	bolShowCBC = true;
	bolShowChest = true;
	bolShowStool = true;
	bolShowUrinalyisis = true;
}	
String[] strConvertLetter = {"","A","B","C","D","E","F","G","H","I","J","K","L"};
int iCount = 1;
%>

<%if(vBasicInfo != null && vBasicInfo.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr>
		<td width="3%">&nbsp;</td>
		<td height="20" width="17%">Student Name : </td>
		<td colspan="3"><%=vBasicInfo.elementAt(0)%></td>
	</tr>
	
	<tr>
		<td width="3%">&nbsp;</td>
		<td height="20">Address : </td>
		<td  colspan="3">
			<%=WI.getStrValue((String)vBasicInfo.elementAt(6))%> <%=WI.getStrValue((String)vBasicInfo.elementAt(7))%>
			<%=WI.getStrValue((String)vBasicInfo.elementAt(8))%> <%=WI.getStrValue((String)vBasicInfo.elementAt(9))%> <%=WI.getStrValue((String)vBasicInfo.elementAt(10))%>
		</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td>Course : <%=WI.getStrValue((String)vBasicInfo.elementAt(4))%></td>
		<td>Year : <%=WI.getStrValue((String)vBasicInfo.elementAt(5))%></td>
		<%
		//1 = temporary; 0 = enrolled
		strTemp = (String)vBasicInfo.elementAt(12);
		if(strTemp.equals("1"))
			strTemp = "Not Enrolled";
		else
			strTemp = "Enrolled";
		%>		
		<td colspan="2">Status : <%=strTemp%></td>
	</tr>
	
	<tr>
		<td height="20">&nbsp;</td>
		<td>Sex : <%=WI.getStrValue((String)vBasicInfo.elementAt(2))%></td>
		<td>Age : <%=WI.getStrValue((String)vBasicInfo.elementAt(1))%></td>
		<td>Civil Status : <%=WI.getStrValue((String)vBasicInfo.elementAt(3))%></td>
		<td>Tel. No. : <%=WI.getStrValue((String)vBasicInfo.elementAt(11))%></td>
	</tr>
	<tr><td colspan="10">&nbsp;</td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%">&nbsp;</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(1);
			else			
				strTemp = WI.fillTextValue("date_recorded");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td colspan="6">Date Recorded : <%=strTemp%></td>
	</tr>
	<tr><td colspan="10">&nbsp;</td></tr>
</table>
<%		
iCount = 1;	
//if(vHistDetail != null && vHistDetail.size() > 0 || vHistLastTaken != null && vHistLastTaken.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="10" height="20"><strong>I. MEDICAL HISTORY</strong></td></tr>
	
	<%
	
	String strEntryName = null;
	String strRemark    = null;
	if(vHistDetail != null && vHistDetail.size() > 0){
	
	while(vHistDetail.size() > 0){
		strEntryName = (String)vHistDetail.remove(0);
		strTemp = (String)vHistDetail.remove(0);
		strRemark = (String)vHistDetail.remove(0);
		
		if(strTemp.equals("1"))	
			strTemp = "Yes";	
		else
			strTemp = "No";
	%>	
	<tr>
		<td height="20" width="3%">&nbsp;</td>
		<td width="5%"><%=iCount++%>.</td>
		<td width="25%"><%=WI.getStrValue(strEntryName)%></td>
		<td width="10%"><%=strTemp%></td>
		<td><%=WI.getStrValue(strRemark)%></td>
	</tr>
	<%}
	}%>
	
	<%if(vHistLastTaken != null && vHistLastTaken.size() > 0){
	while(vHistLastTaken.size() > 0){
		strEntryName = (String)vHistLastTaken.remove(0);		
		strRemark = (String)vHistLastTaken.remove(0);		
	%>
	
	<tr>
		<td height="20" width="3%">&nbsp;</td>
		<td width="5%"><%=iCount++%>.</td>
		<td width="15%"><%=WI.getStrValue(strEntryName)%></td>		
		<td colspan="2"><%=WI.getStrValue(strRemark)%></td>
	</tr>
	
	<%}
	}%>
</table>
<%if(iCount > 20){%>
<div style="page-break-after:always">&nbsp;</div>	
<%}
iCount = 1;	
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr><td height="20" colspan="10"><strong> II. PHYSICAL EXAMINATION</strong></td></tr>
	
	<tr>
		<td height="20" width="3%">&nbsp;</td>
		<td width="20%">HEIGHT : </td>
		<%
		strTemp = WI.fillTextValue("field_1");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		%>
		<td width="12%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td width="20%">WEIGHT : </td>
		<%
		strTemp = WI.fillTextValue("field_2");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		%>
		<td width="12%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td width="20%">BLOOD PRESSURE : </td>
		<%
		strTemp = WI.fillTextValue("field_3");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);
		%>
		<td><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td height="20" width="3%">&nbsp;</td>
		<td width="">PULSE : </td>
		<%
		strTemp = WI.fillTextValue("field_4");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		%>
		<td><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td width="">RESPIRATION : </td>
		<%
		strTemp = WI.fillTextValue("field_5");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		%>
		<td><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td width="">BODY BUILT : </td>
		<%
		strTemp = WI.fillTextValue("field_6");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		%>
		<td><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td height="20" width="3%">&nbsp;</td>
		<td width="">VISUAL ACUITY : </td>
		<%
		strTemp = WI.fillTextValue("field_7");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);
		%>
		<td><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td width="">FAR VISION : </td>
		<%
		strTemp = WI.fillTextValue("field_8");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(9);
		%>
		<td><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td width="15%">NEAR VISION : </td>
		<%
		strTemp = WI.fillTextValue("field_9");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(10);
		%>
		<td><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td height="20" width="3%">&nbsp;</td>
		<td width="">ISHIHARA COLOR VISION : </td>
		<%
		strTemp = WI.fillTextValue("field_10");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		%>
		<td><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td width="">CLARITY OF SPEECH : </td>
		<%
		strTemp = WI.fillTextValue("field_11");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);
		%>
		<td colspan="3"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr><td colspan="8">&nbsp;</td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
	<tr>
		<td class="thinborder" height="20">&nbsp;</td>
		<td class="thinborder" colspan="2" align="center">Normal?</td>
		<td class="thinborder" align="center">Remarks</td>
		
		<td class="thinborder" align="center" height="20">&nbsp;</td>
		<td class="thinborder" align="center" colspan="2">Normal?</td>
		<td class="thinborder" align="center">Remarks</td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20">&nbsp;</td>
		<td class="thinborder" align="center">Yes</td>
		<td class="thinborder" align="center">No</td>
		<td class="thinborder">&nbsp;</td>
		
		<td class="thinborder" height="20">&nbsp;</td>
		<td class="thinborder" align="center">Yes</td>
		<td class="thinborder" align="center">No</td>
		<td class="thinborder">&nbsp;</td>
	</tr>
	<!---ENTRY HERE--->
	<tr>
		<td class="thinborder" height="20" width="20%">Skin</td>
		<%
		strTemp = WI.fillTextValue("field_12");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(13);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_13");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(14);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		
		<td class="thinborder" height="20" width="20%">Heart</td>
		<%
		strTemp = WI.fillTextValue("field_14");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";

		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_15");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(16);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20" width="20%">Head neck scalp</td>
		<%
		strTemp = WI.fillTextValue("field_16");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(17);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_17");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(18);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td class="thinborder" height="20" width="20%">Abdomen</td>
		<%
		strTemp = WI.fillTextValue("field_18");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(19);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_19");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(20);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20" width="20%">Eyes external</td>
		<%
		strTemp = WI.fillTextValue("field_20");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(21);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_21");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(22);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td class="thinborder" height="20" width="20%">Back</td>
		<%
		strTemp = WI.fillTextValue("field_22");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(23);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_23");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(24);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20" width="20%">Pupil Ophthalmoscopic</td>
		<%
		strTemp = WI.fillTextValue("field_24");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(25);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_25");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(26);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td class="thinborder" height="20" width="20%">Anus-Rectum</td>
		<%
		strTemp = WI.fillTextValue("field_26");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(27);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_27");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(28);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20" width="20%">Ears</td>
		<%
		strTemp = WI.fillTextValue("field_28");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(29);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_29");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(30);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td class="thinborder" height="20" width="20%">GU System</td>
		<%
		strTemp = WI.fillTextValue("field_30");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(31);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_31");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(32);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20" width="20%">Nose, Sinuses</td>
		<%
		strTemp = WI.fillTextValue("field_32");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(33);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_33");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(34);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td class="thinborder" height="20" width="20%">Inguinals, Genitals</td>
		<%
		strTemp = WI.fillTextValue("field_34");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(35);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_35");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(36);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20" width="20%">Mouth, Throat</td>
		<%
		strTemp = WI.fillTextValue("field_36");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(37);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_37");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(38);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td class="thinborder" height="20" width="20%">Reflexes</td>
		<%
		strTemp = WI.fillTextValue("field_38");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(39);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_39");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(40);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20" width="20%">Neck, L.N., Thyroid</td>
		<%
		strTemp = WI.fillTextValue("field_40");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(41);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_41");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(42);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td class="thinborder" height="20" width="20%">Extremities</td>
		<%
		strTemp = WI.fillTextValue("field_42");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(43);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_43");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(44);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20" width="20%">Chest-Breast-Axilla</td>
		<%
		strTemp = WI.fillTextValue("field_44");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(45);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_45");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(46);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td class="thinborder" height="20" width="20%">Dental(Teeth)</td>
		<%
		strTemp = WI.fillTextValue("field_46");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(47);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_47");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(48);
		%>
		<td class="thinborder" width="20%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td class="thinborder" height="20" width="20%">Lung LMP</td>
		<%
		strTemp = WI.fillTextValue("field_48");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(49);
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center" width="5%"><%=strErrMsg%></td>
		<%
		strTemp = WI.fillTextValue("field_49");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(50);
		%>
		<td height="20" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td colspan="4" class="thinborder">&nbsp;</td>
	</tr>	
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="8">&nbsp;</td></tr>
	<tr>
		<%
		strTemp = WI.fillTextValue("field_50");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(51);
		%>
		<td height="20" colspan="8">Other Remarks : <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr><td colspan="8">&nbsp;</td></tr>
</table>
<div style="page-break-after:always">&nbsp;</div>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="20" colspan="10"><strong>III. LABORATORY EXAMINATION</strong></td></tr>
	<tr><td colspan="8">&nbsp;</td></tr>
<%if(bolShowChest || bolShowAll){%>	
	<tr><td height="20" width="2%"><strong><%=strConvertLetter[iCount++]%>.</strong></td><td colspan="3"><strong>CHEST X-RAY</strong></td></tr>
	<tr><td colspan="8">&nbsp;</td></tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_51");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(52);
		%>
		<td>CHEST PA REMARKS : &nbsp; <%=WI.getStrValue(strTemp,"N/A")%></td>
		<%
		strTemp = WI.fillTextValue("field_52");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(53);
		%>
		<td>LORDOTIC VIEW REMARKS : &nbsp; <%=WI.getStrValue(strTemp,"N/A")%></td>
	</tr>
	<tr><td colspan="8">&nbsp;</td></tr>
<%}if(bolShowHearing || bolShowAll){%>
	<tr><td height="20" width="2%"><strong><%=strConvertLetter[iCount++]%>.</strong></td><td colspan="3"><strong>HEARING TEST</strong></td></tr>
	<tr><td colspan="8">&nbsp;</td></tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_53");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(54);
		%>
		<td>RIGHT EAR HTL : &nbsp; <%=WI.getStrValue(strTemp,"N/A")%></td>
		<%
		strTemp = WI.fillTextValue("field_54");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(55);
		%>
		<td>LEFT EAR HTL : &nbsp; <%=WI.getStrValue(strTemp,"N/A")%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_55");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(56);
		%>
		<td colspan="2">Remarks : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>
	<tr><td colspan="8">&nbsp;</td></tr>
<%}if(bolShowHBSag || bolShowAll){%>	
	<tr><td height="20" width="2%"><strong><%=strConvertLetter[iCount++]%>.</strong></td><td colspan="3"><strong>HBs AG (Qualitative)</strong></td></tr>
	<tr><td colspan="8">&nbsp;</td></tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_56");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(57);
		%>
		<td colspan="2">Method : &nbsp; <%=WI.getStrValue(strTemp,"N/A")%></td>		
	</tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_57");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(58);
		%>		
		<td colspan="2">Result : &nbsp; &nbsp; <%=WI.getStrValue(strTemp,"N/A")%></td></tr>
	<tr><td colspan="8">&nbsp;</td></tr>
<%}if(bolShowUrinalyisis || bolShowAll){%>		
	<tr><td height="20" width="2%"><strong><%=strConvertLetter[iCount++]%>.</strong></td><td colspan="3"><strong>URINE TEST</strong></td></tr>	
	<tr><td colspan="8">&nbsp;</td></tr>
<%}%>
</table>	

<%if(bolShowUrinalyisis || bolShowAll){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="">
		<tr bgcolor="#FFFFFF">
			<td height="20" colspan="2"><strong>Urine Test (Quantitative Analysis)</strong></td>
			<%			
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(0),"&nbsp;");							
			%>
			<td colspan="2">Date : <%=strTemp%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td width="20%">&nbsp;</td>
			<td width="15%" class="thinborderTOPLEFTBOTTOM"><div align="center"><strong>Normal/Negative<br><font size="1">(Specific Value)</font></strong></div></td>
			<td width="20%" class="thinborderALL"><div align="center"><strong>Not Normal/ Positive<br><font size="1">(Specific Value)</font></strong></div></td>
			<td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">Urobilinogen</td>
			<%			
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(1),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(2),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%>
			<td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">Glucose</td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(3),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(4),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%>
			<td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">Ketones</td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(5),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(6),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">Bilirubin</td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(7),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(8),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">Protein</td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(9),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(10),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">Nitrite</td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(11),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(12),"&nbsp;");
			%><td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">pH</td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(13),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(14),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">Blood</td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(15),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(16),"&nbsp;");			
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">Specific Gravity</td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(17),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(18),"&nbsp;");			
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="">Leukocytes</td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(19),"&nbsp;");	
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborder"><%=strTemp%></td>
			<%
			if(vUrineTest != null && vUrineTest.size() > 0)
				strTemp = WI.getStrValue((String)vUrineTest.elementAt(20),"&nbsp;");
			else
				strTemp = "&nbsp;";
			%><td align="center" class="thinborderBOTTOMLEFTRIGHT"><%=strTemp%></td><td>&nbsp;</td>
		</tr>
		<tr><td colspan="10" height="10">&nbsp;</td></tr>
</table>
<%}
if(bolShowStool || bolShowAll){
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr><td height="20" width="2%"><strong><%=strConvertLetter[iCount++]%>.</strong></td><td colspan="10"><strong>STOOL EXAMINATION</strong></td></tr>
	<tr><td colspan="8">&nbsp;</td></tr>
	
	
	<tr>
		<td>&nbsp;</td>
		<td colspan="2" height="22" class="thinborderTOPLEFTRIGHT">&nbsp; &nbsp; <u>MICROSCOPIC EXAMINATION</u></td>
		<td colspan="2" class="thinborderTOPRIGHT">&nbsp; &nbsp; <u>PARASITES</u></td>
		<td colspan="2" class="thinborderTOPRIGHT">&nbsp; &nbsp; <u>FLAGELLATES</u></td>
	</tr>
	
	<tr>
		<td width="2%">&nbsp;</td>
		<td width="15%" class="thinborderTOPLEFTBOTTOM">Color : </td>
		<%
		strTemp = WI.fillTextValue("field_58");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(59);
		%>
		<td width="17%" class="thinborderALL"><%=WI.getStrValue(strTemp,"N/A")%></td>
		<td width="15%" class="thinborderTOPBOTTOMRIGHT">Ascaris :</td>
		<%
		strTemp = WI.fillTextValue("field_59");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(60);
		%>
		<td width="17%" class="thinborderTOPBOTTOMRIGHT"><%=WI.getStrValue(strTemp,"N/A")%></td>
		<td width="15%" class="thinborderTOPBOTTOMRIGHT">G. Lambia :</td>
		<%
		strTemp = WI.fillTextValue("field_60");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(61);
		%>
		<td class="thinborderTOPBOTTOMRIGHT"><%=WI.getStrValue(strTemp,"N/A")%></td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td width="15%" class="thinborder">Consistency :</td>
		<%
		strTemp = WI.fillTextValue("field_61");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(62);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue(strTemp,"N/A")%></td>
		<td width="15%" class="thinborderBOTTOMRIGHT">Hookworm : </td>
		<%
		strTemp = WI.fillTextValue("field_62");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(63);
		%>
		<td class="thinborderBOTTOMRIGHT"><%=WI.getStrValue(strTemp,"N/A")%></td>
		<td width="15%" class="thinborderBOTTOMRIGHT">T. hominis :</td>
		<%
		strTemp = WI.fillTextValue("field_63");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(64);
		%>
		<td class="thinborderBOTTOMRIGHT"><%=WI.getStrValue(strTemp,"N/A")%></td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td width="15%" class="thinborder">Helminths :</td>
		<%
		strTemp = WI.fillTextValue("field_64");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(65);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue(strTemp,"N/A")%></td>
		<td width="15%" class="thinborderBOTTOMRIGHT">Trichuris :</td>
		<%
		strTemp = WI.fillTextValue("field_65");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(66);
		%>
		<td class="thinborderBOTTOMRIGHT"><%=WI.getStrValue(strTemp,"N/A")%></td>
		<td colspan="2" class="thinborderBOTTOMRIGHT">&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="2" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
		
		<td width="15%" class="thinborderBOTTOMRIGHT">Strongyloides :</td>
		<%
		strTemp = WI.fillTextValue("field_66");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(67);
		%>
		<td class="thinborderBOTTOMRIGHT"><%=WI.getStrValue(strTemp,"N/A")%></td>
		<td colspan="2" class="thinborderBOTTOMRIGHT">&nbsp;</td>
	</tr>
	
	<tr><td colspan="8">&nbsp;</td></tr>
	
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_67");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(68);
		%>
	  <td colspan="10">Remarks : <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_68");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(69);
		%>
		<td colspan="10">Nurse's Notes : <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr><td colspan="8">&nbsp;</td></tr>
</table>
<%}
if(bolShowIshihara || bolShowAll){
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20" width="2%"><strong><%=strConvertLetter[iCount++]%>.</strong></td>
		<td><strong>ISHIHARA TEST</strong></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_86");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(87);
		%>		
		<td colspan="2">Result : &nbsp; &nbsp; <%=WI.getStrValue(strTemp,"N/A")%></td></tr>
	<tr><td colspan="8">&nbsp;</td></tr>
</table>

<%}
if(bolShowHepaB  || bolShowAll){
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20" width="2%"><strong><%=strConvertLetter[iCount++]%>.</strong></td>
		<%
		strTemp = WI.fillTextValue("field_87");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(88);
		%>
		<td><strong>HEPA B VACCINE</strong>  &nbsp; &nbsp; Date : <%=strTemp%></td>
	</tr>
	<tr>
		<td>&nbsp;</td>			
		<td colspan="2">
			<table width="80%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
				<tr>
					<td width="24%" height="18" class="thinborder">Hepa B Vaccine</td>
					<td width="19%" class="thinborder">1<sup>st</sup> dose</td>
					<td width="19%" class="thinborder">2<sup>nd</sup> dose</td>
					<td width="19%" class="thinborder">3<sup>rd</sup> dose</td>
					<td width="19%" class="thinborder">Booster</td>
				</tr>
				<tr>
					<%
					strTemp = WI.fillTextValue("field_88");
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(89);
					%>
					<td class="thinborder"><%=WI.getStrValue(strTemp,"N/A")%></td>
					<%
					strTemp = WI.fillTextValue("field_89");
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(90);
					%>
					<td class="thinborder"><%=WI.getStrValue(strTemp,"N/A")%></td>
					<%
					strTemp = WI.fillTextValue("field_90");
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(91);
					%>
					<td class="thinborder"><%=WI.getStrValue(strTemp,"N/A")%></td>
					<%
					strTemp = WI.fillTextValue("field_91");
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(92);
					%>
					<td class="thinborder"><%=WI.getStrValue(strTemp,"N/A")%></td>
					<%
					strTemp = WI.fillTextValue("field_92");
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(93);
					%>
					<td class="thinborder"><%=WI.getStrValue(strTemp,"N/A")%></td>
				</tr>
			</table>
		</td></tr>
	<tr><td colspan="8">&nbsp;</td></tr>
</table>

<%}
if(bolShowCBC || bolShowAll){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20" width="2%"><strong><%=strConvertLetter[iCount++]%>.</strong></td>
		<td><strong>HEMATOLOGY</strong></td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr><td colspan="2"><u><strong>CBC Blood Count</strong></u></td></tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	
	<tr>
	<%
		strTemp = WI.fillTextValue("field_69");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(70);
		%>
		<td height="20" colspan="2">Hematocrit (Normal Count: Male: 0.40 � 0.54 L/L, Female: 0.37-0.47 L/L ) : 
		<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr><%
		strTemp = WI.fillTextValue("field_70");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(71);
		%>
		<td height="20" colspan="2">Hemoglobin (Normal Count: Male: 130 -180 g/L, Female: 120-160 g/L ) :
		<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr><%
		strTemp = WI.fillTextValue("field_71");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(72);
		%>
		<td height="20" colspan="2">RBC Count (Normal Count: 4.5 � 5.5 x 10 /L) : 
		<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr><%
		strTemp = WI.fillTextValue("field_72");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(73);
		%>
		<td height="20" colspan="2">WBC Count (Normal Count: 4.5 -11 x 10 /L) :
		<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr><%
		strTemp = WI.fillTextValue("field_73");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(74);
		%>
		<td height="20" colspan="2">Platelet Count (Normal Count: 150 -400 x 10 /L) :
		<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr><td colspan="2">&nbsp;</td></tr>
	
	<tr><td colspan="2"><u><strong>Differential Count</strong></u></td></tr>
	<tr><td colspan="2">&nbsp;</td></tr>	
<%
strTemp = WI.fillTextValue("field_74");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(75);
%>
	<tr><td height="20" colspan="2">Neutrophils (Normal: 50-70%) : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>	
	<%
strTemp = WI.fillTextValue("field_75");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(76);
%>
	<tr><td height="20" colspan="2">Lymphocytes (25-35%) : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>	
	<%
strTemp = WI.fillTextValue("field_76");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(77);
%>
	<tr><td height="20" colspan="2">Monocytes (4-8%) : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>	
	<%
strTemp = WI.fillTextValue("field_77");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(78);
%>
	<tr><td height="20" colspan="2">Eosinophils (1-5%) : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>	
	<%
strTemp = WI.fillTextValue("field_78");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(79);
%>
	<tr><td height="20" colspan="2">Basophils : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>	
	<%
strTemp = WI.fillTextValue("field_79");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(80);
%>
	<tr><td height="20" colspan="2">Metamyelocyte : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>	
	<%
strTemp = WI.fillTextValue("field_80");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(81);
%>
	<tr><td height="20" colspan="2">Myelocyte : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>	
	<%
strTemp = WI.fillTextValue("field_81");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(82);
%>
	<tr><td height="20" colspan="2">Blood Type : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>	
	<%
strTemp = WI.fillTextValue("field_82");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(83);
%>
	<tr><td height="20" colspan="2">Remarks : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>	
	<%
strTemp = WI.fillTextValue("field_83");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(84);
%>
	<tr><td height="20" colspan="2">Recommendations : <%=WI.getStrValue(strTemp,"&nbsp;")%></td></tr>
	
	<tr><td colspan="2" height="30">&nbsp;</td></tr>
</table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

	<tr>
		<td height="20" width="10%">&nbsp;</td>
		<td width="40%">Examining Physician</td>
		<td>Examining Nurse</td>
	</tr>
	
	<tr>
		<td height="20" width="10%">&nbsp;</td>
		<%
strTemp = WI.fillTextValue("field_84");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(85);
%>
		<td width="40%"><%=WI.getStrValue(strTemp.toUpperCase(),"&nbsp;")%></td>
		<%
strTemp = WI.fillTextValue("field_85");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(86);
%>
		<td><%=WI.getStrValue(strTemp.toUpperCase(),"&nbsp;")%></td>
	</tr>
	<tr><Td colspan="3">&nbsp;</Td></tr>
	
</table>
<%}//end of vBasic not null%>

</body>
</html>
<%
dbOP.cleanUP();
%>
