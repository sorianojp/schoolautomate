<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTamiya" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Notice of Personnel Action</title>
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
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Notice of Action","hr_personnel_perf_appraisal_view.jsp");
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
	
	double dTemp = 0;
	double dTotalRating = 0;
	double dTotalWeight = 0;
	
	Vector vRetResult = null;
	
	HRTamiya tamiya = new HRTamiya();
	vRetResult = tamiya.operateOnPerfAppraisal(dbOP, request, 3);
	if(vRetResult == null)
		strErrMsg = tamiya.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="hr_personnel_perf_appraisal_view.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="2" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: PERFORMANCE APPRAISAL ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
			<td>Appraisal Date: <%=(String)vRetResult.elementAt(3)%></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td>Appraisal Period Covered: <%=(String)vRetResult.elementAt(1)%> - <%=(String)vRetResult.elementAt(2)%></td>
	    </tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr valign="top">
			<td height="40" colspan="2" align="center" class="thinborder">Criteria / Factor</td>
		    <td align="center" class="thinborder">Weight/<br>(A)</td>
			<td align="center" class="thinborder">Rating/<br>(B)</td>
			<td align="center" class="thinborder">Weighted<br>Score<br>(AxB)</td>
			<td align="center" class="thinborder">Remarks</td>
		</tr>
		<tr>
			<td height="25" width="3%" class="thinborderBOTTOMLEFT">1.) </td>
			<td width="27%" class="thinborderBOTTOM">Job Knowledge</td>
			<td width="10%" class="thinborder">&nbsp;20</td>
			<td width="10%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(4)%></td>
			<td width="10%" class="thinborder">
				<%
					dTotalRating += Double.parseDouble((String)vRetResult.elementAt(4));
					dTemp = 20 * Double.parseDouble((String)vRetResult.elementAt(4));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td width="40%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(9), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">2.) </td>
			<td class="thinborderBOTTOM">Quality of Work</td>
			<td class="thinborder">&nbsp;15</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(5)%></td>
			<td class="thinborder">
				<%
					dTotalRating += Double.parseDouble((String)vRetResult.elementAt(5));
					dTemp = 15 * Double.parseDouble((String)vRetResult.elementAt(5));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(10), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">3.) </td>
			<td class="thinborderBOTTOM">Quantity of Work</td>
			<td class="thinborder">&nbsp;15</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(6)%></td>
			<td class="thinborder">
			<%
					dTotalRating += Double.parseDouble((String)vRetResult.elementAt(6));
					dTemp = 15 * Double.parseDouble((String)vRetResult.elementAt(6));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(11), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">4.) </td>
			<td class="thinborderBOTTOM">Attendance</td>
			<td class="thinborder">&nbsp;30</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(7)%></td>
			<td class="thinborder">
			<%
					dTotalRating += Double.parseDouble((String)vRetResult.elementAt(7));
					dTemp = 30 * Double.parseDouble((String)vRetResult.elementAt(7));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(12), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">5.) </td>
			<td class="thinborderBOTTOM">Attitude Toward Work and the Company</td>
			<td class="thinborder">&nbsp;20</td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(8)%></td>
			<td class="thinborder">
			<%
					dTotalRating += Double.parseDouble((String)vRetResult.elementAt(8));
					dTemp = 20 * Double.parseDouble((String)vRetResult.elementAt(8));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(13), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
			<td class="thinborderBOTTOM">Total</td>
			<td class="thinborder">&nbsp;100</td>
			<td class="thinborder">&nbsp;<%=dTotalRating%></td>
			<td class="thinborder">&nbsp;<%=dTotalWeight%></td>
			<td class="thinborder">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><strong><u>Performance Summary</u></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%">¤Strengths</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><div align="justify"><%=WI.getStrValue((String)vRetResult.elementAt(14), "-")%></div></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>¤Continuous Improvement</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><div align="justify"><%=WI.getStrValue((String)vRetResult.elementAt(15), "-")%></div></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>¤Additional Comments </td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><div align="justify"><%=WI.getStrValue((String)vRetResult.elementAt(16), "-")%></div></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><strong><u>Career Development Plan </u></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>¤Development and Actions </td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><div align="justify"><%=WI.getStrValue((String)vRetResult.elementAt(17), "-")%></div></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
<%}%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="is_view" value="1">
</form>
</body>
</html>
<%

dbOP.cleanUP();
%>