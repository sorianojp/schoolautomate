<%@ page language="java" import="utility.*, health.TsuneishiHealth, java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	boolean bolIsEdit = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Past Medical History</title>
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
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","past_medical_history_print.jsp");
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
															"past_medical_history_print.jsp");
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

	Vector vEditInfo = null;
	Vector vBasicInfo = null;
	TsuneishiHealth health = new TsuneishiHealth();
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("emp_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
		request.setAttribute("emp_id",request.getParameter("emp_id"));
		vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
	}
	
	vEditInfo = health.operateOnPastMedicalHistoryEntry(dbOP, request, 3);

%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="20" align="center" colspan="4"><strong>PAST MEDICAL HISTORY </strong></td>
		</tr>
		<tr> 
			<td width="3%" height="20">&nbsp;</td>
			<td width="97%" colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
<%if(vBasicInfo != null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="3%">&nbsp;</td>
		    <td width="17%">Effective Date: </td>
		    <td width="80%"><%=(String)vEditInfo.elementAt(1)%>	- <%=(String)vEditInfo.elementAt(2)%></td>
	    </tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Date Recorded: </td>
			<td><%=(String)vEditInfo.elementAt(0)%></td>
   		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="17%">Emp. Name :</td>
			<td width="45%"><strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></strong></td>
			<td width="12%">Emp. Status :</td>
			<td width="23%"><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Division:</td>
			<%
				if((String)vBasicInfo.elementAt(13)== null || (String)vBasicInfo.elementAt(14)== null)
					strTemp = " ";			
				else
					strTemp = " - ";
			%>
			<td><strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>
				<%=strTemp%><%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
			<td>Designation :</td>
			<td><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="9"><strong><u>PHYSICAL EXAMINATION</u></strong></td>
		</tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="11%">Height: </td>
			<td width="20%" class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(3)%></td>
			<td width="1%">&nbsp;</td>
			<td width="11%" align="right">Weight:&nbsp;</td>
			<td width="20%" class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(4)%></td>
			<td width="1%">&nbsp;</td>
			<td width="12%" align="right">Body Build:&nbsp;</td>
			<td width="20%" class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(5)%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20">&nbsp;</td>
			<td colspan="3">Visual Acuity: </td>
		    <td colspan="3">Vital Signs: </td>
	    </tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="17%"> Right:</td>
			<td width="27%" class="thinborderBOTTOM"><%=WI.getStrValue((String)vEditInfo.elementAt(7), "&nbsp;")%></td>
			<td width="3%">&nbsp;</td>
			<td width="20%">&nbsp;&nbsp;&nbsp;&nbsp;Temperature: </td>
			<td width="27%" class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(9)%></td>
		    <td width="3%">&nbsp;</td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Left: </td>
 	  	  	<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vEditInfo.elementAt(6), "&nbsp;")%></td>
			<td>&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;Blood Pressure: </td>
		  	<td class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(10)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Corrected</td>
		    <td>
				<%if(((String)vEditInfo.elementAt(8)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
			<%}%></td>
		    <td>&nbsp;</td>
		    <td>&nbsp;&nbsp;&nbsp;&nbsp;Pulse Rate : </td>
		    <td class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(11)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Uncorrected</td>
			<td>
				<%if(((String)vEditInfo.elementAt(8)).equals("0")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
			<%}%></td>
			<td>&nbsp;</td>
			<td>&nbsp;&nbsp;&nbsp;&nbsp;Respiratory Rate: </td>
			<td class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(12)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="7">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="32%">&nbsp;</td>
			<td width="10%" align="center" class="thinborderTOPLEFTRIGHT"><strong>NORMAL</strong></td>
			<td width="55%" align="center" class="thinborderTOPRIGHT"><strong>FINDINGS</strong></td>
		</tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td>General Appearance </td>
			<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(13)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
			<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(14), "&nbsp;")%></td>
		</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Skin</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(15)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(16), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Head and Scalp</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(17)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(18), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Eyes and Pupils</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(19)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(20), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Ears and Eardrums</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(21)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(22), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Nose, Throat and Sinuses</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(23)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(24), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Mouth and Teeth</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(25)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(26), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		 	<td>Neck and Thyroid</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(27)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(28), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Chest, Breast and Axilla</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(29)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(30), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Heart- Cardiovascular</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(31)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(32), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Lungs- Respiratory</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(33)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(34), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Abdomen</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(35)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		 	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(36), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Back</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(37)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		 	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(38), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Genito- urinary System</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(39)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		 	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(40), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Musculoskeletal</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(41)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		 	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(42), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Extremities</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(43)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		 	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(44), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Reflexes</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(45)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		 	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(46), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Neurologic System</td>
		  	<td align="center" class="thinborderALL">
				<%if(((String)vEditInfo.elementAt(47)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPBOTTOMRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(48), "&nbsp;")%></td>
	  	</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Others: </td>
			<td colspan="2"><%=WI.getStrValue((String)vEditInfo.elementAt(49))%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="4"><strong><u>RADIOLOGICAL AND LABORATORY EXAMINATIONS</u></strong></td>
		</tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="32%">&nbsp;</td>
			<td width="10%" align="center" class="thinborderTOPLEFTRIGHT"><strong>NORMAL</strong></td>
			<td width="55%" align="center" class="thinborderTOPRIGHT"><strong>FINDINGS</strong></td>
		</tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td>Complete Blood Count</td>
			<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(50)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
			<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(51), "&nbsp;")%></td></td>
		</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Urinalysis</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(52)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(53), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Fecalysis</td>
		  	<td align="center" class="thinborderALL">
				<%if(((String)vEditInfo.elementAt(54)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPBOTTOMRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(55), "&nbsp;")%></td>
	  	</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td colspan="3">Lipid Panel</td>
		</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;Cholestrol</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(56)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(57), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;HDL</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(58)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(59), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;LDL</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(60)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(61), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;VLDL</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(62)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(63), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		 	<td>Creatine</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(64)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(65), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>SGPT</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(66)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(67), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Blood Sugar Test</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(68)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(69), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>Chest Xray</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(70)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td class="thinborderTOPRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(71), "&nbsp;")%></td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>ECG</td>
		  	<td align="center" class="thinborderALL">
				<%if(((String)vEditInfo.elementAt(72)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		 	<td class="thinborderTOPBOTTOMRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(73), "&nbsp;")%></td>
	  	</tr>
	</table>
		
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" width="3%">&nbsp;</td>
			<td width="32%">&nbsp;</td>
			<td width="32%" align="center" class="thinborderTOPLEFTRIGHT"><strong>NEGATIVE</strong></td>
			<td width="33%" align="center" class="thinborderTOPRIGHT"><strong>POSITIVE</strong></td>
		</tr>
		<tr>
  	  	  	<td height="20">&nbsp;</td>
		  	<td>Hepatitis B Screening</td>
  	  	  	<td align="center" class="thinborderALL">
				<%if(((String)vEditInfo.elementAt(74)).equals("0")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td align="center" class="thinborderTOPBOTTOMRIGHT">
				<%if(((String)vEditInfo.elementAt(74)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td colspan="3">Drug Test </td>
	  	</tr>
		<tr>
		  	<td height="20">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;Methamphetamine</td>
		  	<td align="center" class="thinborderTOPLEFTRIGHT">
				<%if(((String)vEditInfo.elementAt(75)).equals("0")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td align="center" class="thinborderTOPRIGHT">
				<%if(((String)vEditInfo.elementAt(75)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
	  	</tr>
		<tr>
		 	<td height="20">&nbsp;</td>
		  	<td>&nbsp;&nbsp;&nbsp;&nbsp;Tetrahydrocannabinol</td>
		  	<td align="center" class="thinborderALL">
				<%if(((String)vEditInfo.elementAt(76)).equals("0")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
		  	<td align="center" class="thinborderTOPBOTTOMRIGHT">
				<%if(((String)vEditInfo.elementAt(76)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>
					&nbsp;
				<%}%></td>
	  	</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Others: </td>
			<td colspan="2"><%=WI.getStrValue((String)vEditInfo.elementAt(77), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td>Remarks/Recommendations: </td>
			<td colspan="2"><%=WI.getStrValue((String)vEditInfo.elementAt(78), "&nbsp;")%></td>
		</tr>
	</table>	
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
