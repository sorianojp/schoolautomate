<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTsuneishi" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Performance Evaluation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	String strInfoIndex = WI.fillTextValue("info_index");
	if(strInfoIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Reference reference is not found.</p>
		<%return;
	}
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Performance Evaluation","hr_personnel_perf_appraisal_tun_nontechnical_print.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	Vector vEmpRec = null;
	Vector vEditInfo = null;
	
	double dTotalRating = 0;
	double dTotalWeight = 0;
	double dTemp = 0;
	
	HRTsuneishi tun = new HRTsuneishi();
	enrollment.Authentication authentication = new enrollment.Authentication();
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	vEditInfo = tun.operateOnPerfEvaluation(dbOP, request,3);
	
	double dSum = 0d;
	for(int i = 7; i < 17; i++){
		dSum += Double.parseDouble((String)vEditInfo.elementAt(i));
	}
%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="20" align="center"><font size="+1">TSUNEISHI TECHNICAL SERVICES (PHILS.) INC </font></td>
		</tr>
		<tr> 
			<td height="20" align="center">West Cebu Industrial Park-Special Economic Zone </td>
		</tr>
		<tr> 
			<td height="20" align="center">Buanoy, Balamban, Cebu </td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
		</tr>
		<tr>
			<td height="20">PREFORMANCE EVALUATION REPORT (NON-TECHNICAL)</td>
		</tr>
	</table>

<%if(vEmpRec != null && vEmpRec.size() > 0){
	strTemp = 
		" select team_code from ac_tun_team_member "+
		" join ac_tun_team on (ac_tun_team_member.team_index = ac_tun_team.team_index) "+
		" where ac_tun_team_member.is_valid = 1 and ac_tun_team.is_valid = 1 "+
		" and member_index = "+(String)vEmpRec.elementAt(0);
	String strTeam = dbOP.getResultOfAQuery(strTemp, 0);
%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="5" align="right">page 1/3</td>
		</tr>
		<tr>
			<td height="20" width="10%">Name:</td>
		    <td width="30%" class="thinborderBOTTOM"><%=WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
			<td width="40%" align="right">Period Covered:&nbsp;</td>
			<td width="20%" class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(2)%></td>
		</tr>
		<tr>
			<td height="20" width="10%">Position:</td>
		    <td width="30%" class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(15)%></td>
			<td width="40%" align="right">Date Prepared:&nbsp;</td>
			<td width="20%" class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(6)%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="25%">Department/Group/Team: </td>
		    <td width="30%" class="thinborderBOTTOM">
				<%
					if((String)vEmpRec.elementAt(11)== null || (String)vEmpRec.elementAt(12)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>      		
	   			<%=WI.getStrValue((String)vEmpRec.elementAt(13),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vEmpRec.elementAt(14),"")%>
				<%=WI.getStrValue(strTeam, "/", "", "")%></td>
			<td width="25%" align="right">Employment start:&nbsp;</td>
			<td width="20%" class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(6)%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  	<td height="15">&nbsp;</td>
		</tr>
		<tr>
		  	<td ><div align="justify"><font style="font-size:11px">
				Instructions: The rating that approximates the employee's level of performance is equal to the 
				weighted percentage multiplied by equivalent earned points. In rating the employee, consider 
				only the performance during the period under review. </font></div></td>
      	</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="20" colspan="5" align="center" class="thinborder"><strong>EVALUATION FACTORS</strong></td>
			<td align="center" class="thinborder"><strong>RATING</strong></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder" width="3%">1</td>
			<td class="thinborder" width="67%">&nbsp;CONTRIBUTION TO ATTAINMENT OF OBJECTIVES </td>
			<td align="center" class="thinborderBOTTOM" width="5%">40%</td>
			<td align="center" class="thinborderBOTTOM" width="5%">&nbsp;</td>
			<td align="center" class="thinborder" width="10%">Points</td>
			<td align="center" class="thinborder" width="10%">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Attendance Ratio</td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">20%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(7)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(17)%></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Achieved the aligned objectives with the team</td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">20%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(8)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(18)%></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">2</td>
			<td class="thinborder">&nbsp;QUALITY &amp; QUANTITY OF WORK </td>
			<td align="center" class="thinborderBOTTOM">30%</td>
			<td align="center" class="thinborderBOTTOM">&nbsp;</td>
			<td align="center" class="thinborder">Points</td>
			<td align="center" class="thinborder">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Quality level of outputs </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">15%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(9)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(19)%></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Timeliness in submission of outputs </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">10%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(10)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(20)%></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Initiative of providing extra outputs </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">10%</td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(11)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(21)%></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">3</td>
			<td class="thinborder">&nbsp;JOB KNOWLEDGE &amp; SKILLS </td>
			<td align="center" class="thinborderBOTTOM">5%</td>
			<td align="center" class="thinborderBOTTOM">&nbsp;</td>
			<td align="center" class="thinborder">Points</td>
			<td align="center" class="thinborder">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Applies appropriate skills in carrying out tasks </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(12)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(22)%></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">4</td>
			<td class="thinborder">&nbsp;ATTITUDE</td>
			<td align="center" class="thinborderBOTTOM">25%</td>
			<td align="center" class="thinborderBOTTOM">&nbsp;</td>
			<td align="center" class="thinborder">Points</td>
			<td align="center" class="thinborder">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Compliance with company rules &amp; work attitude </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">10%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(13)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(23)%></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Supports team, group, company activities and undertakings </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(14)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(24)%></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Punctuality</td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(15)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(25)%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" width="75%" align="right">100%</td>
			<td width="15%" align="center">Overall Rating</td>
			<td width="10%" class="thinborderBOTTOM" align="center"><%=WI.getStrValue((String)vEditInfo.elementAt(27), "&nbsp;")%></td>
		</tr>
	</table>
	
	<table width="30%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="2"><strong>Table of Earned Points</strong></td>
		</tr>
	</table>
	
	<table width="40%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="20" align="right" width="20%" class="thinborder">S&nbsp;</td>
			<td width="80%" class="thinborder">&nbsp;Excellent (100 pts) </td>
		</tr>
		<tr>
			<td height="20" align="right" class="thinborder">A&nbsp;</td>
			<td class="thinborder">&nbsp;Very Good (95 pts) </td>
		</tr>
		<tr>
			<td height="20" align="right" class="thinborder">B+&nbsp;</td>
			<td class="thinborder">&nbsp;Commendable (90 pts) </td>
		</tr>
		<tr>
			<td height="20" align="right" class="thinborder">B&nbsp;</td>
			<td class="thinborder">&nbsp;Satisfactory (80 pts) </td>
		</tr>
		<tr>
			<td height="20" align="right" class="thinborder">B-&nbsp;</td>
			<td class="thinborder">&nbsp;Marginal Satisfactory (70 pts) </td>
		</tr>
		<tr>
			<td height="20" align="right" class="thinborder">C&nbsp;</td>
			<td class="thinborder">&nbsp;Needs improvement (50 pts) </td>
		</tr>
		<tr>
			<td height="20" align="right" class="thinborder">D&nbsp;</td>
			<td class="thinborder">&nbsp;Poor (30 pts) </td>
		</tr>
	</table>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>