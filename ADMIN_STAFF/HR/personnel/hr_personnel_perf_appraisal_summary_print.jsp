<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTamiya" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
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
<body onLoad="window.print();">
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
	
	if (bolMyHome)
		iAccessLevel = 2;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Notice of Action","hr_personnel_perf_appraisal_summary_print.jsp");
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
	
	double dTemp = 0d;
	double dRowSum = 0d;
	Vector vValues = null;
	Vector vRetResult = null;
	HRTamiya tamiya = new HRTamiya();	
	vRetResult = tamiya.generateAppraisalSummary(dbOP, request);
	
	strTemp = " select rp_title from hr_lhs_review_period where is_valid = 1 and rp_index = "+WI.fillTextValue("rp_index");
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="5" align="center"><strong>PERFORMANCE APPRAISAL SUMMARY (<%=strTemp%>) </strong></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){
	for(int i = 0; i < vRetResult.size(); i+=7){
		double dSum[] = new double[5];
		double dOverall = 0d;
		int iCount1 = 0;
		int iCount2 = 0;
		int iCount3 = 0;
		int iCount4 = 0; 
		int iCount5 = 0;
		int iTotCount = 0;
		vValues = (Vector)vRetResult.elementAt(i+6);
	%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" class="thinborder" width="20%">
				<%=WI.getStrValue((String)vRetResult.elementAt(i+2), "DIV: ", "<br>", "")%>
			  	<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "DEPT: ", "", "")%>
			  	<%
					//if no dept head is assigned, then get division head
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5), (String)vRetResult.elementAt(i+4));
				%>
				<!--if theb-->
			  	<%=WI.getStrValue(strTemp, "<br>(",  ")", "")%></td>
	        <td align="center" class="thinborder" width="12%">JOB<br>KNOWLEDGE</td>
	        <td align="center" class="thinborder" width="12%">QUALITY<br>OF WORK </td>
	        <td align="center" class="thinborder" width="12%">QUANTITY<br>OF WORK </td>
	        <td align="center" class="thinborder" width="12%">ATTENDANCE</td>
	        <td align="center" class="thinborder" width="20%">ATTITUDE TOWARD<br>WORK &amp; THE COMPANY </td>
	        <td align="center" class="thinborder" width="12%">TOTAL/<br>AVERAGE</td>
		</tr>
		<%for(int j = 0; j < vValues.size(); j += 6){
			dRowSum = 0;
		%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vValues.elementAt(j)%></td>
			<%
				strTemp = (String)vValues.elementAt(j+1);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*20);
					dSum[0] += (dTemp*20);
					iCount1++;
					strTemp = CommonUtil.formatFloat(dTemp*20, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vValues.elementAt(j+2);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*15);
					dSum[1] += (dTemp*15);
					iCount2++;
					strTemp = CommonUtil.formatFloat(dTemp*15, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vValues.elementAt(j+3);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*15);
					dSum[2] += (dTemp*15);
					iCount3++;
					strTemp = CommonUtil.formatFloat(dTemp*15, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vValues.elementAt(j+4);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*30);
					dSum[3] += (dTemp*30);
					iCount4++;
					strTemp = CommonUtil.formatFloat(dTemp*30, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vValues.elementAt(j+5);
				if(strTemp == null)
					strTemp = "&nbsp;";
				else{
					dTemp = Double.parseDouble(strTemp);
					dRowSum += (dTemp*20);
					dSum[4] += (dTemp*20);
					iCount5++;
					strTemp = CommonUtil.formatFloat(dTemp*20, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(dRowSum == 0)
					strTemp = "&nbsp;";
				else{
					iTotCount++;
					dOverall += dRowSum/100;
					strTemp = CommonUtil.formatFloat(dRowSum/100, 1);
				}
			%>
	        <td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
		<%}%>
		<tr>
			<td height="25" class="thinborder">TOTAL</td>
			<%
				if(iCount1 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[0]/iCount1, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iCount2 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[1]/iCount2, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iCount3 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[2]/iCount3, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iCount4 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[3]/iCount4, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iCount5 == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSum[4]/iCount5, 1);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(iTotCount == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dOverall/iTotCount, 1);
			%>			
		    <td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
	</table>
	<%}
}%>

</body>
</html>
<%
dbOP.cleanUP();
%>