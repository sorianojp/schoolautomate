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
<title>Health Exam Print For High School</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
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
								"Admin/staff-Health Monitoring-Health Examination Record","health_exam_entry_spc_high_school.jsp");
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
					"Health Monitoring","Health Examination Record",request.getRemoteAddr(),"health_exam_entry_spc_high_school.jsp");
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
		else {
		
			vEditInfo = HR.operateOnHealthRecord(dbOP, request, 3);
			if(vEditInfo == null)
				strErrMsg = HR.getErrMsg();
		}
	}

String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,false);
			
%>

<body <%if(strErrMsg == null){%> onLoad="window.print();"<%}%>>
<%
	strErrMsg = Integer.toString( 180 - strSchoolName.length() * 2 );
%>
<div style="position:absolute; left:<%=strErrMsg%>px;"><img src="../../../images/logo/<%=strSchCode%>.gif" width="70" height="70"></div>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	   <td>	<p ALIGN="CENTER">
			   <strong><%=strSchoolName%>
			   <br>BASIC EDUCATION DEPARTMENT</strong>
			   <br><%=strSchoolAdd%>
			</p>
			<br>
			<p align="center"><strong>SCHOOL CLINIC</strong></p>
			<br>
			<p align="center">
			   <strong>HIGH SCHOOL STUDENT HEALTH RECORD</strong>
			   <br>( To be filled up by the parent/guardian)
			</p>
			<br>
			<br>
	   </td>
	</tr>
</table>

<%if(vBasicInfo != null && vBasicInfo.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td valign="bottom" height="17">Name:</td>
	   <td valign="bottom" height="17" colspan="3"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(0),"&nbsp;")%></div></td>
	   <td valign="bottom" height="17" style="padding-left:10px;">Sex:</td>
	<td valign="bottom" height="17"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(2),"&nbsp;")%></div></td>
	</tr>
	<tr>
		<td height="17" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="bottom" height="17" width="15%">Address:</td>
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
					<td valign="bottom" height="17" width="53%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div>				  </td>
					<td valign="bottom" height="17" width="16%" style="padding-left:10px;">Telephone No.:</td>
				   <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(11),"N/A")%></div></td>
				</tr>
			</table>		</td>
	</tr>
	<tr>
	  <td valign="bottom" height="17">Nationality:</td>
	  <td valign="bottom" height="17"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(34),"&nbsp;")%></div></td>
	  <td valign="bottom" height="17" style="padding-left:10px;">Birthday:</td>
	  <td valign="bottom" height="17"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(13),"N/A")%></div></td>
	  <td valign="bottom" height="17" style="padding-left:10px;">Religion:</td>
	  <td valign="bottom" height="17"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(35),"&nbsp;")%></div></td>
	</tr>
	<tr>
		<td valign="bottom" height="17">Father's Name:</td>
	  	<td valign="bottom" width="20%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></div></td>
	   <td valign="bottom" height="17"  style="padding-left:10px;" width="11%">Occupation:</td>
	   <td valign="bottom" width="22%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(23),"N/A")%></div></td>
	   <td valign="bottom" width="16%" style="padding-left:10px;" height="17">Contact Number:</td>
      <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(15),"N/A")%></div></td>
   </tr>
	  <tr>
	  <td height="17" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="17" width="7%">&nbsp;</td>
					<td valign="bottom" height="17" width="8%">Address:</td>
					<td valign="bottom" height="17" width="85%"><div style="border-bottom:solid 1px #000000;">
					<%=WI.getStrValue((String)vBasicInfo.elementAt(16),"N/A")%></div>				  </td>
				</tr>
			</table>		</td>
	  </tr>
	  <tr>
		<td valign="bottom" height="17" width="15%">Mother's Name:</td>
	   <td valign="bottom" width="20%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(24),"N/A")%></div></td>
	   <td valign="bottom" height="17" width="11%" style="padding-left:10px;">Occupation:</td>

	   <td valign="bottom" width="22%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(27),"N/A")%></div></td>
	   <td valign="bottom" width="16%" height="17" style="padding-left:10px;">Contact Number:</td>
      <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(25),"N/A")%></div></td>
    </tr>
	  <tr>
	  <td height="17" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="17" width="7%">&nbsp;</td>
					<td valign="bottom" height="17" width="8%">Address:</td>
					<td valign="bottom" height="17" width="85%">
						<div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(26),"N/A")%></div>				  </td>
				</tr>
			</table>		</td>
	 </tr>
	 <tr>
		<td valign="bottom" height="17">Guardian's Name:</td>
	   <td valign="bottom" height="17"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(28),"N/A")%></div></td>
	   <td valign="bottom" height="17" style="padding-left:10px;">Occupation:</td>
	   <td valign="bottom" height="17"><div style="border-bottom:solid 1px #000000;">N/A</div></td>
	   <td valign="bottom" height="17" style="padding-left:10px;">Contact Number:</td>
      <td valign="bottom" height="17"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(33),"N/A")%></div></td>
	 </tr>
	  <tr>
	  <td height="17" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="17" width="7%">&nbsp;</td>
					<td valign="bottom" height="17" width="8%">Address:</td>
					<%
					strTemp = WI.getStrValue((String)vBasicInfo.elementAt(30));
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(31));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(32));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					%>
					<td valign="bottom" height="17" width="85%">
						<div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div>						</td>
				</tr>
			</table>		</td>
   </tr>
		   <tr>
	  <td height="17" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="17" width="19%">Living with: </td>
					<%
					strTemp = WI.fillTextValue("field_176");		
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(177);		
					strTemp = WI.getStrValue(strTemp);
						
					if(strTemp.equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  <td height="17" width="16%"><input type="checkbox" disabled="disabled" <%=strErrMsg%>>Mother</td>
				  <%
					if(strTemp.equals("2"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  <td height="17" width="16%"><input type="checkbox" disabled="disabled" <%=strErrMsg%>>Father</td>
				  <%
					if(strTemp.equals("3"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  <td height="17" width="20%"><input type="checkbox" disabled="disabled" <%=strErrMsg%>>Both Parents</td>
				  <%
					if(strTemp.equals("0"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  <td height="17" width="29%"><input type="checkbox" disabled="disabled" <%=strErrMsg%>>Guardian please specify</td>
				</tr>
			</table>		</td>
	  </tr>
	  <tr>
	  <td height="17" colspan="6">In case of emergency please notify:</td></tr>
	  <tr>
	  <td height="17" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="17" width="7%">&nbsp;</td>
					<td valign="bottom" height="17" width="8%">Name:</td>
					<td valign="bottom" width="20%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(17),"N/A")%></div></td>
					<td valign="bottom" height="17" width="11%" style="padding-left:10px;">Relationship:</td>
					<td valign="bottom" width="22%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(19),"N/A")%></div></td>
					<td valign="bottom" height="17" width="16%" style="padding-left:10px;">Contact Number:</td>
				   <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(18),"N/A")%></div></td>
				</tr>
			</table>		</td>
   </tr>
		  <tr>
	  <td height="17" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="17" width="7%">&nbsp;</td>
					<td valign="bottom" height="17" width="8%">Address:</td>
					<%
					strTemp = WI.getStrValue((String)vBasicInfo.elementAt(20));
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(21));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(22));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					%>
					<td valign="bottom" height="17" width="85%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div></td>					
				</tr>
			</table>		</td>
	 	  </tr>
		  <tr>
	  <td valign="bottom" height="17" colspan="2">Hospital of choice for referral or admission:</td>
	  <%
	  strTemp = WI.fillTextValue("field_177");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(178);	
	  %>
	  <td valign="bottom" height="17" colspan="4"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div></td>
	  </tr>
	   <tr>
	  <td height="17" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="17" width="7%">&nbsp;</td>
					<td valign="bottom" height="17" width="16%">Contact Number :</td>
					<%
				  strTemp = WI.fillTextValue("field_178");		
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(179);	
				  %>
					<td valign="bottom" height="17" width="77%"><div style="border-bottom:solid 1px #000000; width:30%"><%=WI.getStrValue(strTemp)%></div></td>
				</tr>
			</table>		</td>
   </tr>
	 <tr>
	  <td height="17" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="17" width="7%">&nbsp;</td>
					<td valign="bottom" height="17" width="8%">Address:</td>
					<%
				  strTemp = WI.fillTextValue("field_179");		
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(180);	
				  %>
					<td valign="bottom" height="17" width="85%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp)%></div></td>
				</tr>
			</table>		</td>
   </tr>
</table>

<br>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >	
	<tr>
		<td colspan="12" height="17" valign="bottom"> A. MEDICAL HISTORY</td>
	</tr>
	
	<tr>
		<td height="17">&nbsp;</td>
		<td height="17" align="center" class="thinborderBOTTOM">YES</td>
		<td width="86" height="17" align="center" class="thinborderBOTTOM">NO</td>
		<td colspan="2" height="17" >&nbsp;</td>
		<td align="center" height="17" class="thinborderBOTTOM">YES</td>
		<td width="78" height="17" align="center" class="thinborderBOTTOM">NO</td>
		<td colspan="2" height="17" >&nbsp;</td>
		<td width="84" height="17" align="center" class="thinborderBOTTOM">YES</td>
		<td width="76" height="17" align="center" class="thinborderBOTTOM">NO</td>
		<td width="20" height="17" >&nbsp;</td>
	</tr>
	<tr>
		<td width="302" height="17" >Illness</td>
		<%	strTemp = WI.fillTextValue("field_1");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td width="88" height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" height="17" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td width="14" height="17" rowspan="12" class="thinborderLEFT">&nbsp;</td>
		<td width="256" height="17" >Dengue</td>
		<%	strTemp = WI.fillTextValue("field_2");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(3);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
      <td width="82" height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" height="17" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td width="22" rowspan="12" height="17" class="thinborderLEFT">&nbsp;</td>
		<td width="186" height="17" >Mumps</td>
		<%	strTemp = WI.fillTextValue("field_3");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(4);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td width="84" height="17"  class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" height="17" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td width="20" height="17" rowspan="9" class="thinborderLEFT">&nbsp;</td>
	</tr>
	<tr>
		<td width="302" height="17" >Allergy</td>
		<%	strTemp = WI.fillTextValue("field_4");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(5);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td width="88" class="thinborderBOTTOMLEFTRIGHT" height="17" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" class="thinborderBOTTOM" height="17"><%=strErrMsg%></td>
		<td height="17" >Epilepsy</td>
		<%	strTemp = WI.fillTextValue("field_5");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(6);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td width="82" height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" height="17" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td>Pneumonia</td>
		<%	strTemp = WI.fillTextValue("field_6");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(7);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td width="84" height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" height="17" class="thinborderBOTTOM"><%=strErrMsg%></td>
  	</tr>
	<tr>
		<td width="302" height="17" >Anemia</td>
		<%	strTemp = WI.fillTextValue("field_7");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(8);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
 	  <td width="88" height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" height="17" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17">Fainting</td>
		<%	strTemp = WI.fillTextValue("field_8");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(9);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17">Skin problem</td>
		<%	strTemp = WI.fillTextValue("field_9");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(10);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="84" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
  	</tr>
	<tr>
		<td height="17" width="302">Asthma</td>
		<%	strTemp = WI.fillTextValue("field_10");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(11);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Fracture</td>
		<%	strTemp = WI.fillTextValue("field_11");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(12);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17">Speech problem</td>
		<%	strTemp = WI.fillTextValue("field_12");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(13);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="84" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" width="302">Behavior problem</td>
		<%	strTemp = WI.fillTextValue("field_13");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(14);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Hearing problem</td>
		<%	strTemp = WI.fillTextValue("field_14");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(15);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Spine disorder</td>
		<%	strTemp = WI.fillTextValue("field_15");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(16);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="84" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" width="302">Bleeding problem</td>
		<%	strTemp = WI.fillTextValue("field_16");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(17);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Indigestion</td>
		<%	strTemp = WI.fillTextValue("field_17");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(18);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Tonsillitis</td>
		<%	strTemp = WI.fillTextValue("field_18");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(19);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="84" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" width="302">Chiken pox</td>
		<%	strTemp = WI.fillTextValue("field_19");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(20);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Insomnia</td>
		<%	strTemp = WI.fillTextValue("field_20");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(21);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Typhoid fever</td>
		<%	strTemp = WI.fillTextValue("field_21");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(22);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="84" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" width="302">Convulsion</td>
		<%	strTemp = WI.fillTextValue("field_22");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(23);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17">Intestinal worms</td>
		<%	strTemp = WI.fillTextValue("field_23");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(24);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Vision problem</td>
		<%	strTemp = WI.fillTextValue("field_24");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(25);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="84" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td width="302" height="17" >Diabetes</td>
		<%	strTemp = WI.fillTextValue("field_25");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(26);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td width="88" height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" height="17" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" valign="bottom">Kidney disease</td>
		<%	strTemp = WI.fillTextValue("field_26");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(27);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	 	<td width="82" height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" height="17" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17">others</td>
		<%	strTemp = WI.fillTextValue("field_27");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(28);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td width="84" height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" width="302">Ear problem</td>
		<%	strTemp = WI.fillTextValue("field_28");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(29);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td>Liver disease</td>
		<%	strTemp = WI.fillTextValue("field_29");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(30);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td width="82" height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td align="center" height="17" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td colspan="4" height="17" rowspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="302">Eating disorder</td>
		<%	strTemp = WI.fillTextValue("field_30");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(31);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Lung disease</td>
		<%	strTemp = WI.fillTextValue("field_31");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(32);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" width="302">Eye problem</td>
		<%	strTemp = WI.fillTextValue("field_32");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(33);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" class="thinborder"></td>
		<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
		<td height="17" align="center" class="thinborderBOTTOM">&nbsp;</td>
	</tr>
	
	<tr>
		<td colspan="12">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" >&nbsp;</td>
		<td  height="17" align="center" class="thinborderBOTTOM">YES</td>
		<td height="17" width="86" align="center" class="thinborderBOTTOM">NO</td>
		<td  height="17" colspan="2">&nbsp;</td>
		<td height="17" align="center" class="thinborderBOTTOM">YES</td>
		<td height="17" width="78" align="center" class="thinborderBOTTOM">NO</td>
		<td height="17" colspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td height="17"  width="302">Illness</td>
		<%	strTemp = WI.fillTextValue("field_33");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(34);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  <td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		<td height="17" class="thinborder"></td>
		<td height="17" width="256">Illness</td>
		<%	strTemp = WI.fillTextValue("field_34");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(35);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		<td height="17" colspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" colspan="4">&nbsp;</td>
		<td height="17" width="256">Measles</td>
		<%	strTemp = WI.fillTextValue("field_35");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(36);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		<td height="17" colspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" colspan="12"> B. FAMILY HISTORY</td>
 	</tr>
	
	<tr>
		<td height="17" >&nbsp;</td>
		<td height="17" align="center" class="thinborderBOTTOM">YES</td>
		<td height="17" width="86" align="center" class="thinborderBOTTOM">NO</td>
		<td height="17" colspan="2">&nbsp;</td>
		<td height="17" align="center" class="thinborderBOTTOM">YES</td>
		<td height="17" width="78" align="center" class="thinborderBOTTOM">NO</td>
		<td height="17" colspan="2">&nbsp;</td>
		<td height="17" width="84" align="center" class="thinborderBOTTOM">YES</td>
		<td height="17" width="76" align="center" class="thinborderBOTTOM">NO</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td width="302" height="17" >Disease</td>
		<%	strTemp = WI.fillTextValue("field_36");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(37);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
      <td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" width="14" rowspan="6" class="thinborderLEFT">&nbsp;</td>
		<td height="17" width="256">Hearth problem</td>
		<%	strTemp = WI.fillTextValue("field_37");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(38);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" width="22" rowspan="6" class="thinborderLEFT">&nbsp;</td>
		<td height="17" width="186">Tuberculosis</td>
		<%	strTemp = WI.fillTextValue("field_38");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(39);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="84" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" width="20" class="thinborderLEFT">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="302">Asthma</td>
		<%	strTemp = WI.fillTextValue("field_39");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(40);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Hypertension</td>
		<%	strTemp = WI.fillTextValue("field_40");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(41);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td><td colspan="5" rowspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="302">Cancer</td>
		<%	strTemp = WI.fillTextValue("field_41");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(42);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Kidney problem</td>
		<%	strTemp = WI.fillTextValue("field_42");	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(43);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" width="302">Bleeding problem</td>
		<%	strTemp = WI.fillTextValue("field_43");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(44);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Mental problem</td>
		<%	strTemp = WI.fillTextValue("field_44");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(45);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" width="302">Diabetes</td>
		<%	strTemp = WI.fillTextValue("field_45");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(46);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Obesity</td>
		<%	strTemp = WI.fillTextValue("field_46");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(47);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  <td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" width="302">Epilepsy</td>
		<%	strTemp = WI.fillTextValue("field_47");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(48);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
		<td height="17" >Stroke</td>
		<%	strTemp = WI.fillTextValue("field_48");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(49);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOM"><%=strErrMsg%></td>
	</tr>
	<tr>
		<td height="17" colspan="12">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" colspan="12">Has the student experienced:</td>
	</tr>
	<tr>
		<td height="17" >&nbsp;</td>
		<td height="17" align="center" class="thinborderBOTTOM">YES</td>
		<td height="17" width="86" align="center" class="thinborderBOTTOM">NO</td>
		<td height="17" colspan="2">&nbsp;</td>
		<td height="17" align="center" class="thinborderBOTTOM">YES</td>
		<td height="17" width="78" align="center" class="thinborderBOTTOM">NO</td>
		<td height="17" colspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="302">Hospitalization</td>
		<%	strTemp = WI.fillTextValue("field_49");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(50);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="88" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOMRIGHT"><%=strErrMsg%></td>
		<td height="17" width="14" class="thinborder"></td>
		<td height="17" width="256">Surgery/Operation</td>
		<%	strTemp = WI.fillTextValue("field_50");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(51);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
  	  <td height="17" width="82" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" align="center" class="thinborderBOTTOMRIGHT"><%=strErrMsg%></td>
		<td height="17" width="22">&nbsp;</td>
		<%	strTemp = WI.fillTextValue("field_51");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(52);
		%>
		<td height="17">If Yes, specify</td>
	   <td height="17" colspan="3" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
   </tr>
	
	<tr>
		<td height="17" colspan="12">For Boys:</td>
	</tr>
	<tr>
		<td height="17" align="right">Circumcision</td>
		<td height="17" width="88">&nbsp;</td>
		<%	strTemp = WI.fillTextValue("field_52");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(53);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" >[<%=strErrMsg%>]Done</td>
		<td height="17" >&nbsp;</td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" >[<%=strErrMsg%>] Not Done</td>
		<td height="17" colspan="7">&nbsp;</td>
	</tr>
	
	<tr><td height="17" colspan="12">For Girls: menstrual history</td>
	</tr>
	<tr>
		<%	strTemp = WI.fillTextValue("field_53");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(54);
		%>
		<td height="17" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Age of menarche:
		<%=WI.getStrValue(strTemp,"&nbsp;")%>		</td>
		<td height="17">&nbsp;</td>
		<td height="17">Last menstrual period</td>
		<%  strTemp = WI.fillTextValue("field_54");
			if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(55);
		%>
		<td height="17" colspan="7"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
		<%	strTemp = WI.fillTextValue("field_55");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(56);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	<tr>
		<td height="17" width="302" align="right" >Cycle:</td>
		
		<td height="17" class="thinborderTOPLEFTRIGHT" width="88">Regular</td>
		<td height="17" class="thinborderTOPRIGHT"align="center"><%=strErrMsg%></td>
		<td height="17" colspan="9">&nbsp; </td>
	</tr>	
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	<tr>
	   <td height="17" >&nbsp;</td>
		<td height="17" class="thinborderTOPLEFTRIGHT" width="88">Irregular</td>
		<td height="17" class="thinborderTOPRIGHT" align="center"><%=strErrMsg%></td>
		<td height="17" colspan="9">&nbsp; </td>
	</tr>
	<tr>
		<td height="17" width="302" align="right">&nbsp;</td>
		<td height="17" class="thinborderTOP">&nbsp;</td>
		<td height="17" class="thinborderTOP">&nbsp;</td>
		<td height="17" colspan="9">&nbsp;  </td>
	</tr>
	<tr>
		<td colspan="12" height="17" >&nbsp;</td>
	</tr>
	<%	strTemp = WI.fillTextValue("field_56");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(57);
		if(WI.getStrValue(strTemp).equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
	%>
	<tr>
		<td height="17"  width="302" align="right">Flow:</td>
		<td height="17" class="thinborderTOPLEFTBOTTOM" width="88">Minimal</td>
		<td height="17" class="thinborderALL"align="center"><%=strErrMsg%></td>
		<td height="17" colspan="9">&nbsp; </td>
	</tr>
	<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
	%>
	<tr>
	<td height="17">&nbsp;</td>
		<td height="17" class="thinborder" width="88">Moderate</td>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<td height="17" colspan="9">&nbsp; </td>
	</tr>
	<%	if(WI.getStrValue(strTemp).equals("2") || WI.getStrValue(strTemp).length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
	%>
	<tr>
	<td height="17">&nbsp; </td>
		<td height="17" class="thinborder">Profuse</td>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" align="center"><%=strErrMsg%></td>
		<td height="17" colspan="9">&nbsp; </td>
	</tr>
	
</table>

<div style="page-break-after:always">&nbsp;</div>
<br><br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
	<tr>
		<td colspan="6" height="17"> C. IMMUNIZATION</td>
 	</tr>
  	<tr>
		<td colspan="6" height="17">&nbsp;</td>
  	</tr>
   	<tr>
		<td width="20%" height="17">VACCINCE</td>
		<td width="13%" height="17" class="thinborderBOTTOM">DATES</td>
		<td height="17" colspan="2">&nbsp;</td>
		<td width="14%" height="17" class="thinborderBOTTOM">DATES</td>
  	   <td width="35%">&nbsp;</td>
  	</tr>
  	<tr>
		<td width="20%" height="17">BCG</td>
		<%	strTemp = WI.fillTextValue("field_57_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(58);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="13%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="17" width="3%">&nbsp;</td>
		<td height="17" width="15%">Measles</td>
		<%	strTemp = WI.fillTextValue("field_58_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(59);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="14%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	   <td width="35%">&nbsp;</td>
  	</tr>
	<tr>
		<td height="17"  width="20%">Chiken pox</td>
		<%	strTemp = WI.fillTextValue("field_59_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(60);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="13%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td height="17" >&nbsp;</td>
		<td height="17" >MMR</td>
		<%	strTemp = WI.fillTextValue("field_60_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(61);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="14%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	   <td width="35%">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="20%">DPT/OPV I-III</td>
		<%	strTemp = WI.fillTextValue("field_61_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(62);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="13%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td height="17" width="3%">&nbsp;</td>
		<td height="17" width="15%">Typhoid Fever</td>
		<%	strTemp = WI.fillTextValue("field_62_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(63);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="14%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	   <td width="35%">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="20%">DPT/OPV BOOSTER I-II</td>
		<%	strTemp = WI.fillTextValue("field_63_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(64);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="13%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		
		<td height="17" >&nbsp;</td>
		<td height="17">Cervical Cancer</td>
		<%	strTemp = WI.fillTextValue("field_64_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(65);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="14%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	   <td width="35%">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="20%">Hepatitis B I</td>
		<%	strTemp = WI.fillTextValue("field_65_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(66);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="13%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="17" width="3%">&nbsp;</td>
		<td height="17" width="15%">Hepatitis A I</td>
		<%	strTemp = WI.fillTextValue("field_66_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(67);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="14%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	   <td width="35%">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="20%">Hepatitis B II</td>
		<%	strTemp = WI.fillTextValue("field_67_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(68);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="13%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="17" >&nbsp;</td>
		<td height="17" >Hepatitis A II</td>
		<%	strTemp = WI.fillTextValue("field_68_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(69);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="14%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	   <td width="35%">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="20%">Hepatitis B III</td>
		<%	strTemp = WI.fillTextValue("field_69_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(70);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="13%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td height="17" >&nbsp;</td>
		<td height="17" >Hepatitis A III</td>
		<%	strTemp = WI.fillTextValue("field_70_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(71);			
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="14%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	   <td  width="35%">&nbsp;</td>
	</tr>
</table>
<br><br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="7" height="17" align="center"> <strong>PART 2</strong>(To be filled up by the school physician)</td>
  	</tr>
  	<tr>
		<td colspan="7" height="17" >&nbsp;</td>
  	</tr>
	<tr>
		<td colspan="7" height="17" >A. PSYCHOSOCIAL HISTORY</td>
	</tr>
	<tr>
		<td colspan="7" height="17" >&nbsp;</td>
	</tr>
   	<tr>
		<td width="34%" height="17" >&nbsp;</td>
		<td width="6%" height="17" class="thinborderBOTTOM" align="center">No</td>
		<td width="6%" height="17" class="thinborderBOTTOM" align="center">Yes</td>
		<td height="17">&nbsp;</td>
		<td width="7%" height="17">Details</td>
		<td width="28%" height="17">&nbsp;</td>
  </tr>
	 <tr>
		<td width="34%" height="17" >1. Do you have close friends?</td>
		<%	strTemp = WI.fillTextValue("field_71");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(72);
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_72");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(73);
		%>
		<td height="17" width="19%">&nbsp;&nbsp;Only 1? <%=WI.getStrValue(strTemp)%></td>
		<td height="17" width="7%">&nbsp;</td>
		<%	strTemp = WI.fillTextValue("field_73");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(74);
		%>
		<td height="17" width="28%">More than 1 <%=WI.getStrValue(strTemp)%></td>
  	</tr>
	<tr>
		<td height="17" width="34%">2. Do you drive?</td>
		<%	strTemp = WI.fillTextValue("field_74");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(75);
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		<td height="17">&nbsp;&nbsp;Regularly?</td>
		<%	strTemp = WI.fillTextValue("field_75");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(76);
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="7%">Yes [<%=strErrMsg%>]</td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="28%">No [<%=strErrMsg%>]</td>
	</tr>
	<tr>
		<td height="17" width="34%">3. Do you drink alcoholic beverages?</td>
		<%	strTemp = WI.fillTextValue("field_76");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(77);
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	   	<td  height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_77");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(78);
		%>
	   	<td height="17" colspan="2">&nbsp;&nbsp;How often? <%=WI.getStrValue(strTemp)%></td>
		<%	strTemp = WI.fillTextValue("field_78");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(79);
		%>
	   <td height="17" width="28%">How much? <%=WI.getStrValue(strTemp)%></td>
  	</tr>
	<tr>
		<td height="17" width="34%">4. Do you smoke?</td>
		<%	strTemp = WI.fillTextValue("field_79");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(80);
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_80");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(81);
		%>
		<td height="17" colspan="2">&nbsp;&nbsp;Sticks per day? <%=WI.getStrValue(strTemp)%></td>
		<%	strTemp = WI.fillTextValue("field_81_date");
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(82);			
		%>
	  <td height="17" width="28%">Since when? <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td width="34%" height="17" >5. Have you taken illicit drugs?</td>
		<%	strTemp = WI.fillTextValue("field_82");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(83);
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		<%	strTemp = WI.fillTextValue("field_83");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(84);
		%>
	  	<td height="17" colspan="2">&nbsp;&nbsp;Kind: <%=WI.getStrValue(strTemp)%></td>
		<td height="17" width="28%">&nbsp;</td>
 	</tr>
	<tr>
		<td height="17" width="34%">&nbsp;</td>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center">&nbsp;</td>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center">&nbsp;</td>
		<td height="17" >&nbsp;&nbsp;Regular use:</td>
		<%	strTemp = WI.fillTextValue("field_84");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(85);
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="7%">No [<%=strErrMsg%>]</td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" width="28%">Yes [<%=strErrMsg%>]</td>
	</tr>
	<tr>
		<td height="17" width="34%">6. Experienced abuse:</td>
		<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center">&nbsp;</td>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center">&nbsp;</td>
		
		<td height="17" >&nbsp;</td>
		<td height="17" width="7%">&nbsp;</td>
		<td height="17" width="28%">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="34%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Physical</td>
		<%	strTemp = WI.fillTextValue("field_85");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(86);
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	 	<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
	
		<td height="17" >&nbsp;</td>
		<td height="17" width="7%">&nbsp;</td>
		<td height="17" width="28%">&nbsp;</td>
	</tr>
	<tr>
		<td height="17" width="34%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sexual</td>
		<%	strTemp = WI.fillTextValue("field_86");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(87);
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		
		<td height="17" >&nbsp;</td>
		<td height="17" width="7%">&nbsp;</td>
		<td height="17" width="28%">&nbsp;</td>
	</tr>
	<tr>
		<td  height="17" width="34%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Verbal</td>
		<%	strTemp = WI.fillTextValue("field_87");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(88);
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
	  	<td height="17" class="thinborderBOTTOMLEFTRIGHT" width="6%" align="center"><%=strErrMsg%></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
			else
				strErrMsg = "&nbsp;";
		%>
		<td height="17" class="thinborderBOTTOMRIGHT" align="center"><%=strErrMsg%></td>
		<td height="17" >&nbsp;</td>
		<td height="17" width="7%">&nbsp;</td>
		<td height="17" width="28%">&nbsp;</td>
	</tr>
</table>
<br><br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="17" colspan="5">B. PHYSICAL EXAMINATION</td>
	</tr>
	<tr>
		<td height="17" colspan="5">&nbsp;</td>
	</tr>
</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">

	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;<strong>Date</strong></td>
	<%	strTemp = WI.fillTextValue("field_88_date");
		if(WI.getStrValue(strTemp).length() == 0)
			strTemp = WI.getTodaysDate(1);
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(89);			
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_89_date");
		if(WI.getStrValue(strTemp).length() == 0)
			strTemp = WI.getTodaysDate(1);
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(90);			
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_90_date");
		if(WI.getStrValue(strTemp).length() == 0)
			strTemp = WI.getTodaysDate(1);
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(91);			
	%>
		<td height="17" width="22%" class="thinborder" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_91_date");
		if(WI.getStrValue(strTemp).length() == 0)
			strTemp = WI.getTodaysDate(1);
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(92);			
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Weight</td>
	<%	strTemp = WI.fillTextValue("field_92");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(93);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_93");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(94);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_94");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(95);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_95");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(96);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Height</td>
	<%	strTemp = WI.fillTextValue("field_96");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(97);
	%>
		<td  height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_97");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(98);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_98");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(99);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_99");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(100);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td  height="17" width="20%" class="thinborder">&nbsp;&nbsp;BP</td>
	<%	strTemp = WI.fillTextValue("field_100");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(101);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_101");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(102);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_102");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(103);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_103");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(104);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Pulse</td>
	<%	strTemp = WI.fillTextValue("field_104");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(105);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_105");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(106);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_106");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(107);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_107");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(108);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Skin</td>
	<%	strTemp = WI.fillTextValue("field_108");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(109);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_109");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(110);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_110");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(111);
	%>
		<td height="17"  width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_111");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(112);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td width="20%" class="thinborder" height="17" >&nbsp;&nbsp;Head</td>
	<%	strTemp = WI.fillTextValue("field_112");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(113);
	%>
		<td width="22%" class="thinborder" height="17" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_113");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(114);
	%>
		<td width="22%"  class="thinborder" height="17" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_114");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(115);
	%>
		<td width="22%" class="thinborder" height="17" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_115");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(116);
	%>
		<td width="22%" class="thinborder" height="17" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td width="20%" class="thinborder" height="17" >&nbsp;&nbsp;Eyes</td>
	<%	strTemp = WI.fillTextValue("field_116");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(117);
	%>
		<td width="22%" class="thinborder" height="17" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_117");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(118);
	%>
		<td width="22%" class="thinborder" height="17" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_118");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(119);
	%>
		<td width="22%" class="thinborder" height="17"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_119");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(120);
	%>
		<td width="22%"  class="thinborder" height="17"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td width="20%" class="thinborder" height="17">&nbsp;&nbsp;Vision</td>
	<%	strTemp = WI.fillTextValue("field_120");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(121);
	%>
		<td width="22%" class="thinborder" height="17" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_121");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(122);
	%>
		<td width="22%"  class="thinborder" height="17" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_122");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(123);
	%>
		<td width="22%" class="thinborder" height="17" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_123");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(124);
	%>
		<td width="22%" class="thinborder" height="17"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td width="20%" class="thinborder" height="17">&nbsp;&nbsp;Ears</td>
	<%	strTemp = WI.fillTextValue("field_124");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(125);
	%>
		<td width="22%"  class="thinborder" height="17"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_125");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(126);
	%>
		<td width="22%"  class="thinborder" height="17"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_126");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(127);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_127");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(128);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Hearing</td>
	<%	strTemp = WI.fillTextValue("field_128");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(129);
	%>
		<td width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_129");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(130);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_130");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(131);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_131");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(132);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Nose</td>
	<%	strTemp = WI.fillTextValue("field_132");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(133);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_133");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(134);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_134");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(135);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_135");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(136);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Throat</td>
	<%	strTemp = WI.fillTextValue("field_136");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(137);
	%>
		<td height="17" width="22%"  class="thinborder" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_137");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(138);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_138");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(139);
	%>
		<td  height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_139");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(140);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Mouth</td>
	<%	strTemp = WI.fillTextValue("field_140");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(141);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_141");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(142);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_142");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(143);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_143");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(144);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Gums</td>
	<%	strTemp = WI.fillTextValue("field_144");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(145);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_145");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(146);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_146");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(147);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_147");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(148);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Neck</td>
	<%	strTemp = WI.fillTextValue("field_148");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(149);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_149");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(150);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_150");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(151);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_151");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(152);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Chest</td>
	<%	strTemp = WI.fillTextValue("field_152");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(153);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_153");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(154);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_154");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(155);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_155");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(156);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Lungs</td>
	<%	strTemp = WI.fillTextValue("field_156");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(157);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_157");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(158);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_158");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(159);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_159");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(160);
	%>
		<td  height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Abdomen</td>
	<%	strTemp = WI.fillTextValue("field_160");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(161);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_161");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(162);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_162");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(163);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_163");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(164);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Limbs</td>
	<%	strTemp = WI.fillTextValue("field_164");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(165);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_165");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(166);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_166");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(167);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_167");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(168);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Neuro</td>
	<%	strTemp = WI.fillTextValue("field_168");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(169);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_169");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(170);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_170");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(171);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_171");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(172);
	%>
		<td height="17" width="22%"  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="17" width="20%" class="thinborder">&nbsp;&nbsp;Tanner's</td>
	<%	strTemp = WI.fillTextValue("field_172");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(173);
	%>
		<td height="17" width="22%" class="thinborder" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_173");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(174);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_174");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(175);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	<%	strTemp = WI.fillTextValue("field_175");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(176);
	%>
		<td height="17" width="22%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
</table>
<%}//end of vBasic not null%>
</body>
</html>
<%
dbOP.cleanUP();
%>
