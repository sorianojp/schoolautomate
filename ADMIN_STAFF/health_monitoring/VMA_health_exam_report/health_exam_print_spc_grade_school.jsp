<%@ page language="java" import="utility.*,health.HealthReport,java.util.Vector " %>
<%

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
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
<script language="javascript" src="../../../jscript/common.js"></script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null; String strTemp2 = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Health Examination Record","health_exam_entry_spc_grade_school.jsp");
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
				"Health Monitoring","Health Examination Record",request.getRemoteAddr(),"health_exam_entry_spc_grade_school.jsp");
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
	Vector vRetResult = new Vector();
	Vector vBasicInfo = new Vector();
	Vector vEditInfo  = new Vector();
	
	HealthReport HR = new HealthReport();
	
	
	if(WI.fillTextValue("stud_id").length() > 0){
		vBasicInfo = HR.operateOnHealthRecord(dbOP, request, 5);
		if(vBasicInfo == null)
			strErrMsg = HR.getErrMsg();
		else{
			vEditInfo = HR.operateOnHealthRecord(dbOP, request, 3);
			if(vEditInfo == null)
				strErrMsg = HR.getErrMsg();
		}	
	}
%>

<body <%if(strErrMsg == null){%> onLoad="window.print();"<%}%>>
<%
	String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,false);
	strErrMsg = Integer.toString( 180 - strSchoolName.length() * 2 );
%>
<div style="position:absolute; left:<%=strErrMsg%>px;"><img src="../../../images/logo/<%=strSchCode%>.gif" width="70" height="70"></div>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20">
			<p ALIGN="CENTER">
				<strong><%=strSchoolName%><br>BASIC EDUCATION DEPARTMENT</strong>
				<br><%=strSchoolAdd%>
			</p>
			<br>
		    <p align="center"><strong>SCHOOL CLINIC</strong></p><br>
		    <p align="center"><strong>GRADE SCHOOL STUDENT HEALTH RECORD</strong>
		    <br>( To be filled up by the parent/guardian)</p><br><br></td>
	</tr>
</table>
<%if(vBasicInfo != null && vBasicInfo.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td valign="bottom" height="20">Name:</td>
	   <td valign="bottom" height="20" colspan="3"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(0),"&nbsp;")%></div></td>
	   <td valign="bottom" height="20" style="padding-left:10px;">Sex:</td>
	<td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(2),"&nbsp;")%></div></td>
	</tr>
	<tr>
		<td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="bottom" height="20" width="15%">Address:</td>
					<%
					strTemp = WI.getStrValue((String)vBasicInfo.elementAt(6));
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(7));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(8));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(9));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(10));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					%>
					<td valign="bottom" height="20" width="53%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div>				  </td>
					<td valign="bottom" height="20" width="16%" style="padding-left:10px;">Telephone No.:</td>
				   <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(11),"N/A")%></div></td>
				</tr>
			</table>		</td>
	</tr>
	<tr>
	  <td valign="bottom" height="20">Nationality:</td>
	  <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(34),"&nbsp;")%></div></td>
	  <td valign="bottom" height="20" style="padding-left:10px;">Birthday:</td>
	  <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(13),"N/A")%></div></td>
	  <td valign="bottom" height="20" style="padding-left:10px;">Religion:</td>
	  <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(35),"&nbsp;")%></div></td>
	</tr>
	<tr>
		<td valign="bottom" height="20">Father's Name:</td>
	  	<td valign="bottom" width="20%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></div></td>
	   <td valign="bottom" height="20"  style="padding-left:10px;" width="11%">Occupation:</td>
	   <td valign="bottom" width="22%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(23),"N/A")%></div></td>
	   <td valign="bottom" width="16%" style="padding-left:10px;" height="20">Contact Number:</td>
      <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(15),"N/A")%></div></td>
   </tr>
	  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<td valign="bottom" height="20" width="85%"><div style="border-bottom:solid 1px #000000;">
					<%=WI.getStrValue((String)vBasicInfo.elementAt(16),"N/A")%></div>				  </td>
				</tr>
			</table>		</td>
	  </tr>
	  <tr>
		<td valign="bottom" height="20" width="15%">Mother's Name:</td>
	   <td valign="bottom" width="20%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(24),"N/A")%></div></td>
	   <td valign="bottom" height="20" width="11%" style="padding-left:10px;">Occupation:</td>
	   <td valign="bottom" width="22%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(27),"N/A")%></div></td>
	   <td valign="bottom" width="16%" height="20" style="padding-left:10px;">Contact Number:</td>
      <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(25),"N/A")%></div></td>
    </tr>
	  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<td valign="bottom" height="20" width="85%">
						<div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(26),"N/A")%></div>				  </td>
				</tr>
			</table>		</td>
	 </tr>
	 <tr>
		<td valign="bottom" height="20">Guardian's Name:</td>
	   <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(28),"N/A")%></div></td>
	   <td valign="bottom" height="20" style="padding-left:10px;">Occupation:</td>
	   <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;">N/A</div></td>
	   <td valign="bottom" height="20" style="padding-left:10px;">Contact Number:</td>
      <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(33),"N/A")%></div></td>
	 </tr>
	  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<%
					strTemp = WI.getStrValue((String)vBasicInfo.elementAt(30));
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(31));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(32));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					%>
					<td valign="bottom" height="20" width="85%">
						<div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div>						</td>
				</tr>
			</table>		</td>
   </tr>
		   <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="19%">Living with: </td>
					<%
					strTemp = WI.fillTextValue("field_105");		
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(106);		
					strTemp = WI.getStrValue(strTemp);
						
					if(strTemp.equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  <td height="20" width="16%"><input type="checkbox" disabled="disabled" <%=strErrMsg%>>Mother</td>
				  <%
					if(strTemp.equals("2"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  <td height="20" width="16%"><input type="checkbox" disabled="disabled" <%=strErrMsg%>>Father</td>
				  <%
					if(strTemp.equals("3"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  <td height="20" width="20%"><input type="checkbox" disabled="disabled" <%=strErrMsg%>>Both Parents</td>
				  <%
					if(strTemp.equals("0"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  <td height="20" width="29%"><input type="checkbox" disabled="disabled" <%=strErrMsg%>>Guardian please specify</td>
				</tr>
			</table>		</td>
	  </tr>
	  <tr>
	  <td height="20" colspan="6">In case of emergency please notify:</td></tr>
	  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Name:</td>
					<td valign="bottom" width="20%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(17),"N/A")%></div></td>
					<td valign="bottom" height="20" width="11%" style="padding-left:10px;">Relationship:</td>
					<td valign="bottom" width="22%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(19),"N/A")%></div></td>
					<td valign="bottom" height="20" width="16%" style="padding-left:10px;">Contact Number:</td>
				   <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(18),"N/A")%></div></td>
				</tr>
			</table>		</td>
   </tr>
		  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<%
					strTemp = WI.getStrValue((String)vBasicInfo.elementAt(20));
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(21));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(22));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					%>
					<td valign="bottom" height="20" width="85%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div></td>					
				</tr>
			</table>		</td>
	 	  </tr>
		  <tr>
	  <td valign="bottom" height="20" colspan="2">Hospital of choice for referral or admission:</td>
	  <%
	  strTemp = WI.fillTextValue("field_106");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(107);	
	  %>
	  <td valign="bottom" height="20" colspan="4"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div></td>
	  </tr>
	   <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="16%">Contact Number :</td>
					<%
				  strTemp = WI.fillTextValue("field_107");		
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(108);	
				  %>
					<td valign="bottom" height="20" width="77%"><div style="border-bottom:solid 1px #000000; width:30%"><%=WI.getStrValue(strTemp)%></div></td>
				</tr>
			</table>		</td>
   </tr>
	 <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<%
				  strTemp = WI.fillTextValue("field_108");		
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(109);	
				  %>
					<td valign="bottom" height="20" width="85%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp)%></div></td>
				</tr>
			</table>		</td>
   </tr>
</table>
<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20" colspan="4">&nbsp;A. Immunization Record</td>
	</tr>
</table>
<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20" width="211">&nbsp;</td>
		<td height="20" width="375">Vaccination Dates</td>
		<td height="20" width="208">&nbsp;</td>
		<td height="20" width="371">Vaccination Dates</td>
	</tr>
</table>
<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="20" width="272" class="thinborder">BCG</td>
		<%	strTemp = WI.fillTextValue("field_1_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">Hepatitis B I</td>
		<%	strTemp = WI.fillTextValue("field_2_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(3);			
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">DPT/OPV I</td>
		<%	strTemp = WI.fillTextValue("field_3_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(4);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">Hepatitis B II</td>
		<%	strTemp = WI.fillTextValue("field_4_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(5);			
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">DPT/OPV II</td>
		<%	strTemp = WI.fillTextValue("field_5_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(6);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">Hepatitis B III</td>
		<%	strTemp = WI.fillTextValue("field_6_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(7);			
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">DPT/OPV III</td>
		<%	strTemp = WI.fillTextValue("field_7_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(8);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">MMR</td>
		<%	strTemp = WI.fillTextValue("field_8_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(9);			
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">DPT/OPV booster 1</td>
		<%	strTemp = WI.fillTextValue("field_9_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(10);			
			%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">Chiken pox I</td>
		<%	strTemp = WI.fillTextValue("field_10_date");	
			if(WI.getStrValue(strTemp).length() == 0)
			strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(11);			
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">DPT/OPV booster 2</td>
		<%	strTemp = WI.fillTextValue("field_11_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(12);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">Chiken pox II</td>
		<%	strTemp = WI.fillTextValue("field_12_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(13);			
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">HiB I</td>
		<%	strTemp = WI.fillTextValue("field_13_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(14);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">Hepatitis A I</td>
		<%	strTemp = WI.fillTextValue("field_14_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(15);			
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">HiB II</td>
		<%	strTemp = WI.fillTextValue("field_15_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(16);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">Hepatitis A II</td>
		<%	strTemp = WI.fillTextValue("field_16_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(17);			
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">HiB III</td>
		<%	strTemp = WI.fillTextValue("field_17_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(18);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">Hepatitis A III</td>
		<%	strTemp = WI.fillTextValue("field_18_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(19);			
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">Measles</td>
		<%	strTemp = WI.fillTextValue("field_19_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(20);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">Others:</td>
		<%	strTemp = WI.fillTextValue("field_20");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(21);
		%>
		<td height="20" width="308" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="272" class="thinborder">Typhoid Fever</td>
		<%	strTemp = WI.fillTextValue("field_21_date");	
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(22);			
		%>
		<td height="20" width="313" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="20" width="271" class="thinborder">&nbsp;</td>
		<td height="20" width="308" class="thinborder">&nbsp;</td>
	</tr>
</table>

<br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20" colspan="6">&nbsp;B. MEDICAL HISTORY: <i>The child has suffered from: (please check NO or Yes)</i></td>
	</tr>
</table>
<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
	<tr>
		<td height="20" width="356" class="thinborder">Illness</td>
		<td height="20" width="114" class="thinborder" align="center">Yes</td>
		<td height="20" width="116" class="thinborder" align="center">&nbsp;No</td>
		<td height="20" width="348" class="thinborder">Illness</td>
		<td height="20" width="116" class="thinborder" align="center">&nbsp;Yes</td>
		<td height="20" width="115" class="thinborder" align="center">&nbsp;No</td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Allergy</td>
		<%	strTemp = WI.fillTextValue("field_22");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(23);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Heart disorder</td>
		<%	strTemp = WI.fillTextValue("field_23");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(24);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Anemia</td>
		<%	strTemp = WI.fillTextValue("field_24");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(25);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Hyperactivity</td>
	    <%	strTemp = WI.fillTextValue("field_25");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(26);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Asthma</td>
		<%	strTemp = WI.fillTextValue("field_26");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(27);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Indigestion</td>
	    <%	strTemp = WI.fillTextValue("field_27");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(28);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Behavioral problem</td>
		<%	strTemp = WI.fillTextValue("field_28");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(29);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Insomia</td>
		<%	strTemp = WI.fillTextValue("field_29");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(30);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Bleeding problem</td>
		<%	strTemp = WI.fillTextValue("field_30");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(31);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Kidney problem</td>
		<%	strTemp = WI.fillTextValue("field_31");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(32);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Blood Abnormality</td>
		<%	strTemp = WI.fillTextValue("field_32");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(33);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Liver Problem</td>
		<%	strTemp = WI.fillTextValue("field_33");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(34);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Chicken pox</td>
		<%	strTemp = WI.fillTextValue("field_34");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(35);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center" ><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Measles</td>
		<%	strTemp = WI.fillTextValue("field_35");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(36);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Convulsion</td>
		<%	strTemp = WI.fillTextValue("field_36");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(37);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Mumps</td>
		<%	strTemp = WI.fillTextValue("field_37");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(38);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Dengue</td>
	    <%	strTemp = WI.fillTextValue("field_38");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(39);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Parasitism</td>
		<%	strTemp = WI.fillTextValue("field_39");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(40);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Diabetes</td>
		<%	strTemp = WI.fillTextValue("field_40");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(41);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Pneumonia</td>
		<%	strTemp = WI.fillTextValue("field_41");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(42);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Ear problem</td>
		<%	strTemp = WI.fillTextValue("field_42");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(43);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Primary complex</td>
		<%	strTemp = WI.fillTextValue("field_43");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(44);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Eating disorder</td>
		<%	strTemp = WI.fillTextValue("field_44");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(45);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Scoliosis</td>
		<%	strTemp = WI.fillTextValue("field_45");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(46);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Epilepsy</td>
		<%	strTemp = WI.fillTextValue("field_46");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(47);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Skin problem</td>
		<%	strTemp = WI.fillTextValue("field_47");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(48);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Eye problem</td>
		<%	strTemp = WI.fillTextValue("field_48");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(49);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Tonsilitis</td>
		<%	strTemp = WI.fillTextValue("field_49");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(50);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Fracture</td>
		<%	strTemp = WI.fillTextValue("field_50");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(51);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Typhoid fever</td>
		<%	strTemp = WI.fillTextValue("field_51");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(52);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="20" width="356" class="thinborder">Hearing problem</td>
		<%	strTemp = WI.fillTextValue("field_52");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(53);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
			%>
		<td height="20" width="114" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<td height="20" width="348" class="thinborder">Vision defect</td>
		<%	strTemp = WI.fillTextValue("field_53");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(54);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="116" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="115" class="thinborder" align="center"><%=strErrMsg%></td>
	</tr>
</table>
<div style="page-break-after:always">&nbsp;</div>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20" colspan="4">&nbsp;C. <strong>FAMILY HISTORY</strong></td>
	</tr>
</table>
<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="352" align="center" height="20" class="thinborder">Disease</td>
		<td width="113" align="center" class="thinborder">Yes</td>
		<td width="118" align="center" class="thinborder">No</td>
		<td width="581" align="center" class="thinborder">Relation(s) to Child</td>
	</tr>
	<tr>
		<td width="352" height="20" class="thinborder">Asthma</td>
		<%	strTemp = WI.fillTextValue("field_54");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(55);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_55");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(56);
		%>
		<td width="581" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td width="352" height="20" class="thinborder">Bleeding Tendency</td>
		<%	strTemp = WI.fillTextValue("field_56");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(57);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_57");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(58);
		%>
		<td width="581" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">Cancer</td>
		<%	strTemp = WI.fillTextValue("field_58");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(59);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_59");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(60);
		%>
		<td width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">Diabetes</td>
		<%	strTemp = WI.fillTextValue("field_60");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(61);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_61");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(62);
		%>
		<td height="20" width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">Heart disorder</td>
		<%	strTemp = WI.fillTextValue("field_62");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(63);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_63");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(64);
		%>
		<td height="20" width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">High Blood pressure</td>
		<%	strTemp = WI.fillTextValue("field_64");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(65);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_65");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(66);
		%>
		<td height="20" width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">Kidney problem</td>
		<%	strTemp = WI.fillTextValue("field_66");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(67);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_67");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(68);
		%>
		<td height="20" width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">Mental disorder</td>
		<%	strTemp = WI.fillTextValue("field_68");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(69);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_69");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(70);
		%>
		<td height="20" width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">Obesity</td>
		<%	strTemp = WI.fillTextValue("field_70");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(71);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_71");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(72);
		%>
		<td height="20" width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">Seizure</td>
		<%	strTemp = WI.fillTextValue("field_72");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(73);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_73");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(74);
		%>
		<td height="20" width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">Stroke</td>
		<%	strTemp = WI.fillTextValue("field_74");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(75);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_75");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(76);
		%>
		<td height="20" width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="352" class="thinborder">Tuberculosis</td>
		<%	strTemp = WI.fillTextValue("field_76");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(77);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="118" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_77");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(78);
		%>
		<td height="20" width="581"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
</table>
<br>
<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="20" colspan="4" class="thinborder"><i>The child has a history of:</i></td>
	</tr>
	<tr>
		<td height="20" width="350" class="thinborder">&nbsp;</td>
		<td height="20" width="113" align="center" class="thinborder">Yes</td>
		<td height="20" width="119" align="center" class="thinborder">No</td>
		<td height="20" width="582" align="center" class="thinborder">Diagnosis / Operation done</td>
	</tr>
	<tr>
		<td height="20" width="350" class="thinborder"><i>Hospitalization</i></td>
	    <%	strTemp = WI.fillTextValue("field_78");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(79);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="119" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_79");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(80);
		%>
		<td height="20" width="582" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" width="350" class="thinborder"><i>Surgical Operation</i></td>
		<%	strTemp = WI.fillTextValue("field_80");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(81);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="113" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="20" width="119" class="thinborder" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_81");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(82);
		%>
		<td height="20" width="582" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
</table>
<br>
<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20" width="431"><strong>Physical Examination by the Physician</strong></td>
		<td height="20" width="43">&nbsp;</td>
		<td height="20" width="44">Date:</td>
		<%	
			strTemp = WI.fillTextValue("date_recorded");			
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(1);
				
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td height="20" width="161" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" colspan="4">&nbsp;</td>
	</tr>
</table>

<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
	<tr>
		<td height="20" colspan="2" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<%	strTemp = WI.fillTextValue("field_83");	
					if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(84);
				%>
				<td height="20" width="174" class="">&nbsp;Weight (kilogram):</td>
				<td width="175" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp)%></td>
				<%	strTemp = WI.fillTextValue("field_84");	
					if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(85);
				%>
				<td width="181" height="20" class="">&nbsp; &nbsp;Height (cm):</td>
				<td width="219" height="20" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp)%></td>
				<%	strTemp = WI.fillTextValue("field_85");	
					if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(86);
				%>
				<td height="20" width="115" class=""> &nbsp; &nbsp; BMI:</td>
			   <td width="115" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp)%></td>
			</tr>
			</table>		</td>
	</tr>
	<tr>
		<td height="20" width="186">&nbsp;Blood Pressure:</td>
		<%	strTemp = WI.fillTextValue("field_86");	
			if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(87);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Scalp:</td>
		<%	strTemp = WI.fillTextValue("field_87");	
			if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(88);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Skin and nails:</td>
		<%	strTemp = WI.fillTextValue("field_88");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(89);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Eyes: </td>
		<%	strTemp = WI.fillTextValue("field_89");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(90);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Visual Acuity: </td>
		<%	strTemp = WI.fillTextValue("field_90");	
			if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(91);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Ears:</td>
		<%	strTemp = WI.fillTextValue("field_91");	
			if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(92);
		%>
		<td height="20" width="726"class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Hearing Test: </td>
		<%	strTemp = WI.fillTextValue("field_92");	
			if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(93);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Nose:</td>
		<%	strTemp = WI.fillTextValue("field_93");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(94);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Throat:</td>
		<%	strTemp = WI.fillTextValue("field_94");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(95);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Mouth and tongue:</td>
		<%	strTemp = WI.fillTextValue("field_95");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(96);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Teeth and Gums:</td>
		<%	strTemp = WI.fillTextValue("field_96");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(97);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Chest, Breast:</td>
		<%	strTemp = WI.fillTextValue("field_97");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(98);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Heart:</td>
		<%	strTemp = WI.fillTextValue("field_98");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(99);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Lungs:</td>
		<%	strTemp = WI.fillTextValue("field_99");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(100);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Abdomen: </td>
		<%	strTemp = WI.fillTextValue("field_100");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(101);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Genitalia:</td>
		<%	strTemp = WI.fillTextValue("field_101");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(102);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Spine:</td>
		<%	strTemp = WI.fillTextValue("field_102");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(103);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20">&nbsp;Other Findings:</td>
		<%	strTemp = WI.fillTextValue("field_103");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(104);
		%>
		<td height="20" width="726" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="20" colspan="2" class="">&nbsp;</td>
		<td width="26" height="20" class="">&nbsp;</td>
	</tr>
</table>
<br>
<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="20" width="79%">Recommendation/ Endorsement:</td>
	</tr>

	<tr>
			<%	strTemp = WI.fillTextValue("field_104");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(105);
		%>
		<td height="20" width="1150" style="text-align:justify; padding-left:70px;"><u><%=WI.getStrValue(strTemp)%></u></td>
	</tr>
</table>

<%
}//end of vBasic not null%>






</body>
</html>
<%
dbOP.cleanUP();
%>
