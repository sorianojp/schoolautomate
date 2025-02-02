<%@ page language="java" import="utility.*, health.HMReports ,java.util.Vector " %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">

@page {
	size:8.50in 11in; 
	margin:.5in .5in .5in .5in; 
}

@media print {
	@page {
		size:8.50in 11in; 
		margin:.5in .5in .5in .5in; 
	}
	div.divFooter {
		text-align:center;
		position: fixed;
		bottom: 10px;
		width: 100%;				
	}
}
 

 
 H5:after {
	 font-weight:normal;
	 content: "In my honor, I hereby certify that the above information is true and correct.";
	 counter-increment: page;
}
 
</style>
</head>

<%	
	Vector vStudList = null;
	WebInterface WI = new WebInterface(request);
	String strIDNumber = WI.fillTextValue("id_number"); 
		
	if(strIDNumber.length() == 0){
		strIDNumber = (String)request.getSession(false).getAttribute("pe_spc_id_list");
		request.getSession(false).removeAttribute("pe_spc_id_list");
	}
		
	if(strIDNumber == null || strIDNumber.length() == 0){%>
	<div style="text-align:center; font-size:13px; color:#FF0000;">Student id not found.</div>
<%	return;}	
	
	vStudList = CommonUtil.convertCSVToVector(strIDNumber);

	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","medical_history.jsp");
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
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"medical_history.jsp");
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
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
HMReports hmReports = new HMReports();
Vector vRetResult = null; 
Vector vAttendingPhysician  = null;
Vector vFamilyHistory = null; 
Vector vAllergy = null; 
Vector vPreviousIllness = null; 
Vector vOperationUndergon = null; 
Vector vImmuneList = null; 
Vector vBasicInfo = null;
int iAge = 0;
Vector vAddInfo = new Vector();
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);
if(strSchAddr == null || strSchAddr.length() == 0){
	strTemp = "select SCHOOL_ADDRESS from SYS_INFO";
	strSchAddr = dbOP.getResultOfAQuery(strTemp,0);
}
java.sql.ResultSet rs = null;
while(vStudList.size() > 0){
strIDNumber = (String)vStudList.remove(0);

vAddInfo = new Vector();
if(strIDNumber.length() > 0){
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, strIDNumber);
	if(vBasicInfo == null)
		strErrMsg = OAdm.getErrMsg();
	else{
		vAttendingPhysician = hmReports.operateOnStudAttendingPhysician(dbOP, request, 4,strIDNumber );
		strTemp = " select dob, cityaddr_house_no , cityaddr_city, cityaddr_provience, RES_HOUSE_NO, RES_CITY, RES_PROVIENCE , "+
				" cityaddr_tel, CONTACT_MOB_NO, sch_name, "+
				" EMGN_PER_NAME, EMGN_PER_REL, EMGN_HOUSE_NO, EMGN_CITY, EMGN_TEL "+
				" from INFO_PERSONAL  "+
				" left join INFO_CONTACT on (INFO_CONTACT.USER_INDEX = INFO_PERSONAL.USER_INDEX)  "+
				" left join ENTRANCE_DATA on (INFO_PERSONAL.USER_INDEX = STUD_INDEX) "+
				" left join SCH_ACCREDITED on (SCH_ACCR_INDEX = SEC_SCH_INDEX) "+
				" where INFO_PERSONAL.USER_INDEX = "+(String)vBasicInfo.elementAt(12);
		rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			iAge = CommonUtil.calculateAGE(rs.getDate(1));
			
			vAddInfo.addElement(rs.getString(2));//[0]cityaddr_house_no
			vAddInfo.addElement(rs.getString(3));//[1]cityaddr_city
			vAddInfo.addElement(rs.getString(4));//[2]cityaddr_provience
			
			vAddInfo.addElement(rs.getString(5));//[3]RES_HOUSE_NO
			vAddInfo.addElement(rs.getString(6));//[4]RES_CITY
			vAddInfo.addElement(rs.getString(7));//[5]RES_PROVIENCE
			
			vAddInfo.addElement(rs.getString(8));//[6]cityaddr_tel
			vAddInfo.addElement(rs.getString(9));//[7]CONTACT_MOB_NO
			vAddInfo.addElement(rs.getString(10));//[8]sch_name
			
			vAddInfo.addElement(rs.getString(11));//[9]EMGN_PER_NAME
			vAddInfo.addElement(rs.getString(12));//[10]EMGN_PER_REL
			vAddInfo.addElement(rs.getString(13));//[11]EMGN_HOUSE_NO
			vAddInfo.addElement(rs.getString(14));//[12]EMGN_CITY
			vAddInfo.addElement(rs.getString(15));//[13]EMGN_TEL

		rs.close();
	
		vRetResult = hmReports.getStudPEReportSPC(dbOP, strIDNumber);
		if(vRetResult == null)
			strErrMsg = hmReports.getErrMsg();
		else{
			vFamilyHistory 	    = (Vector)vRetResult.remove(0);
			vAllergy 		    = (Vector)vRetResult.remove(0);
			vPreviousIllness    = (Vector)vRetResult.remove(0);
			vOperationUndergon  = (Vector)vRetResult.remove(0);
			vImmuneList 		= (Vector)vRetResult.remove(0);
		}		
	}
}
 


if(strErrMsg != null)
	continue;
	
%>

<body>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td rowspan="2" width="10%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" style="border:solid 1px #000000;">
				<tr><td>PLEASE<br>USE<br>BLACK<br>BALLPEN</td></tr>
			</table>
		</td>
		<td align="center"><strong style="font-size:14px;"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong><br><%=strSchAddr%><br>
	<strong style="font-size:13px;">PHYSICAL EXAMINATION REPORT</strong></td>
		<td rowspan="2" width="10%">
			<table width="100%" border="0" height="60px" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" style="border:solid 1px #000000;">
				<tr><td align="center">1 x 1<br>PICTURE</td></tr>
			</table>
		</td>
	</tr>
	<tr>
	    <td align="center" height="30">&nbsp;</td>
    </tr>
</table>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="6%" height="25" valign="bottom">Name:</td>
		<td width="22%" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:95%"><%=vBasicInfo.elementAt(2)%></div></td>
		<td width="18%" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:95%"><%=vBasicInfo.elementAt(0)%></div></td>
		<%
		strTemp = WI.getStrValue(vBasicInfo.elementAt(1));
		if(strTemp.length() > 0)
			strTemp = strTemp.charAt(0)+"";
		%>
		<td width="30%" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:95%"><%=strTemp%></div></td>
		<td width="6%" valign="bottom">Age</td>
		<%
		strTemp = "&nbsp;";
		if(iAge > 0)
			strTemp = Integer.toString(iAge);
		
		%>
		<td width="18%" valign="bottom"><div style="border-bottom:solid 1px #000000;">&nbsp;<%=strTemp%></div></td>
	</tr>
	<tr>
	    <td height="" valign="bottom">&nbsp;</td>
	    <td align="center" valign="top">Last Name</td>
	    <td align="center" valign="top">First Name</td>
	    <td align="center" valign="top">M.I</td>
	    <td valign="bottom">&nbsp;</td>
	    <td valign="bottom">&nbsp;</td>
    </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="14%" height="25" valign="bottom">Course/Yr./Sec.</td>
		<td width="55%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:95%"><%=WI.getStrValue(vBasicInfo.elementAt(7))%> 
		<%=WI.getStrValue((String)vBasicInfo.elementAt(14)," / ","","")%></div></td>
		<td width="9%" valign="bottom">	ID No.</td>
		<td width="22%" valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=strIDNumber%></div></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="18%" height="25" valign="bottom">Date of Birth:</td>
		<td width="32%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:95%"><%=WI.getStrValue(vBasicInfo.elementAt(19))%> </div></td>
		<td width="7%" valign="bottom">Sex:</td>
		<%
		strTemp = WI.getStrValue(vBasicInfo.elementAt(16));
		if(strTemp.toLowerCase().startsWith("f"))
			strTemp = "FEMALE";
		else
			strTemp = "MALE";
		%>
		<td width="15%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:95%"><%=strTemp%> </div></td>
		<td width="7%" valign="bottom">Status:</td>
		<%
		strTemp = "";
		if(WI.getStrValue(vBasicInfo.elementAt(20)).length() > 0){
			strTemp  ="select STATUS from USER_STATUS where STATUS_INDEX = "+WI.getStrValue(vBasicInfo.elementAt(20));
			strTemp = dbOP.getResultOfAQuery(strTemp,0);
		}
		%>
		<td width="21%" valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp)%></div></td>
	</tr>
	<tr>
	    <td height="25" valign="bottom">City Address:</td>
		<%
		strTemp = WI.getStrValue(vAddInfo.elementAt(0));
		if(strTemp.length() > 0 && WI.getStrValue(vAddInfo.elementAt(1)).length() > 0)
			strTemp += ", "+ WI.getStrValue(vAddInfo.elementAt(1));
		if(strTemp.length() > 0 && WI.getStrValue(vAddInfo.elementAt(2)).length() > 0)
			strTemp += ", "+ WI.getStrValue(vAddInfo.elementAt(2));
		%>
	    <td colspan="5" valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=strTemp%></div></td>
    </tr>
	<tr>
	    <td height="25" valign="bottom">Provincial Address:</td>
		<%
		strTemp = WI.getStrValue(vAddInfo.elementAt(3));
		if(strTemp.length() > 0 && WI.getStrValue(vAddInfo.elementAt(4)).length() > 0)
			strTemp += ", "+ WI.getStrValue(vAddInfo.elementAt(4));
		if(strTemp.length() > 0 && WI.getStrValue(vAddInfo.elementAt(5)).length() > 0)
			strTemp += ", "+ WI.getStrValue(vAddInfo.elementAt(5));
		%>
	    <td colspan="5" valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=strTemp%></div></td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="13%" height="25" valign="bottom">Telephone No.:</td>
		<td width="45%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:95%"><%=WI.getStrValue(vAddInfo.elementAt(6))%></div></td>
		<td width="15%" valign="bottom">Cellphone No.:</td>
		<td width="27%" valign="bottom"><div style="border-bottom:solid 1px #000000; "><%=WI.getStrValue(vAddInfo.elementAt(7))%></div></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="21%" height="25" valign="bottom">High School Graduated:</td>
		<td valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(vAddInfo.elementAt(8))%></div></td>
		
		
	</tr>
</table>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top" width="45%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr><td>In case of emergency, please notify:</td></tr>				
			</table>
			
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="18%" height="25" valign="bottom">Name:</td>
					<td width="82%" valign="bottom"><div style="border-bottom:solid 1px #000000; "><%=WI.getStrValue(vAddInfo.elementAt(9))%></div></td>
				</tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="23%" height="25" valign="bottom">Relationship:</td>
					<td width="77%" valign="bottom"><div style="border-bottom:solid 1px #000000; "><%=WI.getStrValue(vAddInfo.elementAt(10))%></div></td>
				</tr>
			</table>
			
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
				<%
			strTemp = WI.getStrValue(vAddInfo.elementAt(11));
			if(strTemp.length() > 0 && WI.getStrValue(vAddInfo.elementAt(12)).length() > 0)
				strTemp += ", "+ WI.getStrValue(vAddInfo.elementAt(12));
			%>
					<td width="21%" height="25" valign="bottom">Address:</td>
					<td width="79%" valign="bottom"><div style="border-bottom:solid 1px #000000; "><%=strTemp%></div></td>
				</tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="18%" height="25" valign="bottom">Tel. No.:</td>
					<td width="82%" valign="bottom"><div style="border-bottom:solid 1px #000000; "><%=WI.getStrValue(vAddInfo.elementAt(13))%></div></td>
				</tr>
			</table>
		</td>
		<td>&nbsp;</td>
		<td valign="top" width="45%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr><td>Family / Attending Physicians</td></tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="14%" height="25" valign="bottom">Name:</td>
					
					<%
					strTemp = "";
					if(vAttendingPhysician != null && vAttendingPhysician.size() > 0)
						strTemp = WebInterface.formatName((String)vAttendingPhysician.elementAt(2),
							(String)vAttendingPhysician.elementAt(3),(String)vAttendingPhysician.elementAt(4),7);
					%>
					<td width="86%" valign="bottom"><div style="border-bottom:solid 1px #000000; "><%=strTemp%></div></td>
				</tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="21%" height="25" valign="bottom">Address:</td>
					<%
					strTemp = "";
					if(vAttendingPhysician != null && vAttendingPhysician.size() > 0)
						strTemp = WI.getStrValue((String)vAttendingPhysician.elementAt(5));
					%>
					<td width="79%" valign="bottom"><div style="border-bottom:solid 1px #000000; "><%=strTemp%></div></td>
				</tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td height="25" valign="bottom"><div style="border-bottom:solid 1px #000000; "></div></td>
				</tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="17%" height="25" valign="bottom">Tel. No.:</td>
					<%
					strTemp = "";
					if(vAttendingPhysician != null && vAttendingPhysician.size() > 0)
						strTemp = WI.getStrValue((String)vAttendingPhysician.elementAt(7));
					%>
					<td width="83%" valign="bottom"><div style="border-bottom:solid 1px #000000; "><%=strTemp%></div></td>
				</tr>
			</table>
		</td>

	</tr>
</table>
<br><br>
<%
int iCount =0 ;
if(vFamilyHistory != null && vFamilyHistory.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>FAMILY HISTORY:(pls indicate if its Father's side or Mother's side)</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%	
	while(vFamilyHistory.size() > 0){
	iCount = 0;
	%>
	<tr>
		<%while(iCount <= 3){
			++iCount;%>
				<td width="3%" valign="bottom" align="center">
				<%
				if(vFamilyHistory.size() > 0){			
				vFamilyHistory.remove(0);
				%><div style="border-bottom:solid 1px #000000;"><%=vFamilyHistory.remove(1)%></div><%}%></td>
				<td height="20" valign="bottom" width="15%">&nbsp;&nbsp;
				<%if(vFamilyHistory.size() > 0){%><%=vFamilyHistory.remove(0)%><%}%></td>
			<%
			
		}%>
	</tr>
	<%}%>
</table>
<%}//end of vFamilyHistory
if(vPreviousIllness != null && vPreviousIllness.size() > 0){
%>
<br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>PREVIOUS ILLNESS:</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%	
	while(vPreviousIllness.size() > 0){
	iCount = 0;
	%>
	<tr>
		<%while(iCount < 3){
			++iCount;%>
				<td height="20" width="20%" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:80%">
				<%if(vPreviousIllness.size() > 0){			
				vPreviousIllness.remove(0);%>
					<%=vPreviousIllness.remove(0)%>
				<%vPreviousIllness.remove(0);}%>
				</div></td>				
			<%
			
		}%>
	</tr>
	<%}%>
</table>

<%}//end of vPreviousIllness

if(true || vAllergy != null && vAllergy.size() > 0){
%>
<br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>HISTORY OF ALLERGY:</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="14%" style="padding-left:50px;">Specify:</td>
		<%
		strTemp = "";
		if(vAllergy != null && vAllergy.size() > 0)
			strTemp = WI.getStrValue(vAllergy.elementAt(2));
		%>
		<td height="20" valign="bottom" width="86%"><div style="border-bottom:solid 1px #000000; width:85%"><%=strTemp%></div></td>			
	</tr>
</table>
<%}
if(vImmuneList != null && vImmuneList.size() > 0){
%>
<br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center"><strong>IMMUNIZATION RECORD</strong></td></tr>
</table>
<table width="30%" align="center" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
	<%
	while(vImmuneList.size() >0){
	vImmuneList.remove(0);
	%>
	<tr>
					<td valign="bottom" class="thinborder" height="20" width="50%"><%=vImmuneList.remove(0)%></td>
					<td valign="bottom" class="thinborder"><%=WI.getStrValue(vImmuneList.remove(0),"&nbsp;")%></td>
	</tr>
	<%}%>
</table>
<%}

if(vOperationUndergon != null && vOperationUndergon.size() > 0){
Vector vTemp = (Vector)vOperationUndergon.remove(0);
if(vTemp != null && vTemp.size() > 0){
%>
<br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>OPERATION UNDERGONE</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%	
	while(vTemp != null && vTemp.size() > 0){
	iCount = 0;
	%>
	<tr>
		<%while(iCount < 3){++iCount;%>
			<td height="20" valign="bottom" width="20%" align="center"><div style="border-bottom:solid 1px #000000; width:80%"><%if(vTemp.size() > 0){%><%=vTemp.remove(0)%><%}%></div></td>				
		<%}%>
	</tr>
	<%}%>
</table>
<%}}%>
<%--do not delete this--%>
<div class="divFooter"><em><H5></H5></em></div>
<%if(vStudList.size() > 0){%><div style="page-break-after:always">&nbsp;</div><%}%>
<%}%>
<script>window.print();</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
