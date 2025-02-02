<%@ page language="java" import="utility.*,java.util.Vector, hr.GovtEvaluation" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Work Evaluation Print Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();">
<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null; 
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Performance Evaluation Management-Create Review Period","values.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERFORMANCE EVALUATION MANAGEMENT"),"0"));
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
	
	Vector vRetResult = null;
	GovtEvaluation eval = new GovtEvaluation();
	
	String[] astrQuarters = {"", "1st", "2nd", "3rd", "4th"};
	
	enrollment.Authentication authentication = new enrollment.Authentication();
	Vector vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
		
	if(vEmpRec != null && vEmpRec.size() > 0){		
		vRetResult = eval.getEmployeeWorkEvaluation(dbOP, request, (String)vEmpRec.elementAt(0));
		if(vRetResult == null)
			strErrMsg = eval.getErrMsg();
	}

	if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" colspan="5" align="center">
				<strong><%=astrQuarters[Integer.parseInt(WI.fillTextValue("quarter"))]%> QUARTER PERFORMANCE</strong></td>
		</tr>
		<tr>
			<td height="25" colspan="5" align="center">(Simulation/Trial of PMS-OPES Points)</td>
		</tr>
		<tr>
			<td height="40" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="13%">Name of Employee: </td>
			<td width="25%" class="thinborderBOTTOM">
				<%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
			<td width="17%" align="right">Department:&nbsp;&nbsp;</td>
			<td width="25%" class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(14)%></td>
			<td width="20%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="5">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr bgcolor="#66FFCC">
			<td height="25" width="35%" align="center" class="thinborder" valign="top">Output</td>
			<td width="20%" align="center" class="thinborder" valign="top">Quantity of Output<br>(#Accomplished)</td>
			<td width="25%" align="center" class="thinborder" valign="top">Points per Unit of Output </td>
			<td width="20%" align="center" class="thinborder" valign="top">Total</td>
	  </tr>
	<%
		double dSum = 0d;
		double dSumQty = 0d;
		double dSumPPO = 0d;
		double dQuantity = 0d;
		double dPPO = 0d;//points per output
		double dTotal = 0d;
		for(int i = 0; i < vRetResult.size(); i += 11){%>
		<tr>
			<td height="20" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%> (<%=(String)vRetResult.elementAt(i+3)%>)</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				if(strTemp == null){
					strTemp = "&nbsp;";
					dQuantity = 0;
				}
				else{
					strTemp = CommonUtil.formatFloat(strTemp, false);
					dQuantity = Double.parseDouble(strTemp);
				}
				dSumQty += dQuantity;
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+8);
				if(strTemp == null){
					strTemp = "&nbsp;";
					dPPO = 0;
				}
				else{
					strTemp = CommonUtil.formatFloat(strTemp, false);
					dPPO = Double.parseDouble(strTemp);
				}
				dSumPPO += dPPO;
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
			<%
				dSum = dPPO * dQuantity;
				if(dSum == 0)
					strTemp = "&nbsp;";
				else{
					strTemp = CommonUtil.formatFloat(dSum, false);
					dTotal += dSum;
				}
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
	<%}
	
	int iTemp = vRetResult.size()/11;
	for(int i = iTemp; i <= 17; i++){%>
		<tr>
			<td height="20" class="thinborder">&nbsp;</td>
		    <td class="thinborder">&nbsp;</td>
		    <td class="thinborder">&nbsp;</td>
		    <td class="thinborder">&nbsp;</td>
		</tr>
	<%}%>
		<tr bgcolor="#66FFCC">
			<td height="20" class="thinborder">&nbsp;TOTAL POINTS for the QUARTER </td>
			<%
				if(dSumQty <= 0d)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSumQty, false);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(dSumPPO <= 0d)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSumPPO, false);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				if(dTotal <= 0d)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dTotal, false);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="20" width="5%">&nbsp;</td>
		    <td width="20%">&nbsp;</td>
		    <td width="35%">&nbsp;</td>
		    <td width="35%">&nbsp;</td>
		    <td width="5%">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="3">&nbsp;</td>
		    <td colspan="2">Noted:</td>
	    </tr>
		<tr>
			<td height="40">&nbsp;</td>
		    <td class="thinborderBOTTOM">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td class="thinborderBOTTOM">&nbsp;</td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
		    <td align="center">Signature of Employee</td>
		    <td>&nbsp;</td>
		    <td align="center">Name &amp; Signature of Department Head </td>
		    <td>&nbsp;</td>
		</tr>
	</table>
	<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>