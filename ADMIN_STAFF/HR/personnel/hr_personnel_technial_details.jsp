<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTsuneishi" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Performance Appraisal</title>
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
			"Admin/staff-HR Management-Personnel-Notice of Action","hr_personnel_technical_details.jsp");
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
	
	Vector vEditInfo = null;	
	HRTsuneishi tun = new HRTsuneishi();
	vEditInfo = tun.operateOnPerfEvaluation(dbOP, request,3);
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="FocusField()">
<form action="hr_personnel_technical_details.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: PERFORMANCE EVALUATION  ::::</strong></font></td>
		</tr>
	</table>

<%if(vEditInfo != null && vEditInfo.size() > 0){
	double dSum = 0d;
	for(int i = 7; i < 17; i++){
		dSum += Double.parseDouble((String)vEditInfo.elementAt(i));
	}
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Appraisal Date: </td>
		    <td width="80%"><%=(String)vEditInfo.elementAt(6)%></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td>Period Covered: </td>
          	<td>
				<%
					strTemp =
						" select rp_title from hr_lhs_review_period where is_valid = 1 and rp_index = "
						+ (String)vEditInfo.elementAt(1);
					strTemp = dbOP.getResultOfAQuery(strTemp, 0);
				%>
				<%=WI.getStrValue(strTemp)%></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td height="25">Skill Level (start of evaluation): <%=(String)vEditInfo.elementAt(3)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td height="25">Target skill  Level (end of evaluation): <%=(String)vEditInfo.elementAt(4)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td height="25">Actual Result: <%=(String)vEditInfo.elementAt(5)%></td>
	    </tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" colspan="5" align="center" class="thinborder"><strong>EVALUATION FACTORS</strong></td>
			<td align="center" class="thinborder"><strong>RATING</strong></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="3%">1</td>
			<td class="thinborder" width="67%">&nbsp;CONTRIBUTION TO ATTAINMENT OF OBJECTIVES </td>
			<td align="center" class="thinborderBOTTOM" width="5%">50%</td>
			<td align="center" class="thinborderBOTTOM" width="5%">&nbsp;</td>
			<td align="center" class="thinborder" width="10%">Points</td>
			<td align="center" class="thinborder" width="10%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Attendance Ratio</td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">20%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(7)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(17)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Direct Ratio </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(8)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(18)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Schedule keeping ratio </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">15%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(9)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(19)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Productive capacity ratio </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">10%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(10)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(20)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">2</td>
			<td class="thinborder">&nbsp;QUALITY &amp; QUANTITY OF WORK </td>
			<td align="center" class="thinborderBOTTOM">20%</td>
			<td align="center" class="thinborderBOTTOM">&nbsp;</td>
			<td align="center" class="thinborder">Points</td>
			<td align="center" class="thinborder">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Quality level of outputs </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">10%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(11)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(21)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Job volume ratio </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">10%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(12)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(22)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">3</td>
			<td class="thinborder">&nbsp;JOB KNOWLEDGE &amp; SKILLS </td>
			<td align="center" class="thinborderBOTTOM">5%</td>
			<td align="center" class="thinborderBOTTOM">&nbsp;</td>
			<td align="center" class="thinborder">Points</td>
			<td align="center" class="thinborder">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Attains target skill level </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(13)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(23)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">4</td>
			<td class="thinborder">&nbsp;ATTITUDE</td>
			<td align="center" class="thinborderBOTTOM">25%</td>
			<td align="center" class="thinborderBOTTOM">&nbsp;</td>
			<td align="center" class="thinborder">Points</td>
			<td align="center" class="thinborder">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Compliance with company rules &amp; work attitude </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">10%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(14)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(24)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Supports team, group, company activities and undertakings </td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">5%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(15)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(25)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Punctuality</td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td class="thinborderBOTTOM" align="right">10%</td>
			<td class="thinborder" align="center"><%=(String)vEditInfo.elementAt(16)%></td>
			<td align="center" class="thinborder"><%=(String)vEditInfo.elementAt(26)%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="75%" align="right">100%</td>
			<td width="15%" align="center">Overall Rating</td>
			<td width="10%" class="thinborderBOTTOM" align="center"><%=WI.getStrValue((String)vEditInfo.elementAt(27), "&nbsp;")%></td>
		</tr>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
	<input type="hidden" name="is_technical" value="1">
	<input type="hidden" name="is_view" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>