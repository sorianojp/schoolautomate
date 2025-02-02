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
	
	double dValAve = 0d;
	double dPAAve = 0d;
	double dWorkAve = 0d;
	double dTeamworkAve = 0d;
	
	Vector vValues = null;
	Vector vPA = null;
	Vector vWork = null;
	Vector vTeamwork = null;
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
		vRetResult = eval.getEvaluationValues(dbOP, request, (String)vEmpRec.elementAt(0));
		if(vRetResult == null)
			strErrMsg = eval.getErrMsg();
		else{
			vValues = (Vector)vRetResult.elementAt(0);
			vPA = (Vector)vRetResult.elementAt(1);
			vTeamwork = (Vector)vRetResult.elementAt(2);
			vWork = (Vector)vRetResult.elementAt(3);
		}
	}
	
	if(vEmpRec != null && vEmpRec.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" align="center"><font size="2"><strong>QUARTERLY PERFORMANCE EVALUATION SYSTEM</strong></font></td>
		</tr>
		<tr>
			<td height="20" align="center">Provincial Government of 
				<%=(SchoolInformation.getAddressLine1(dbOP,false,false)).toUpperCase()%></td>
		</tr>
		<tr>
		  <td height="20" align="center">Quarter: <u><%=astrQuarters[Integer.parseInt(WI.fillTextValue("quarter"))]%> Quarter</u></td>
	  </tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="33%">Name of Employee: <u><%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></u></td>
			<td height="25" width="33%">Position: <u><%=WI.getStrValue((String)vEmpRec.elementAt(15))%></u></td>
			<%
		  		if((String)vEmpRec.elementAt(13)== null || (String)vEmpRec.elementAt(14)== null)
					strTemp = " ";			
				else
					strTemp = " - ";
			%>
			<td height="25" width="33%">Department/Division: <u>
				<%=WI.getStrValue((String)vEmpRec.elementAt(13),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vEmpRec.elementAt(14),"")%></u></td>		  
		</tr>
	</table>
	<%}

	if(vWork != null && vWork.size() > 0){
		double dAve = 0d;
		double dOverall = 0d;
		double dEPS = 0d;
	%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="20"><font style="font-size:11px"><strong>PART I: WORK ACCOMPLISHMENT (50%) (to be rated by the supervisor) </strong></font></td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td rowspan="3" align="center" class="thinborder" width="6%"><strong>Weight</strong></td>
		    <td rowspan="3" align="center" class="thinborder" width="26%"><strong>WORK/ACTIVITIES</strong></td>
		    <td rowspan="3" align="center" class="thinborder" width="12%"><strong>Unit of Measure</strong></td>
		    <td height="15" colspan="4" align="center" class="thinborder"><strong>Target and Accomplishment</strong></td>
		    <td colspan="4" rowspan="2" align="center" class="thinborder"><strong>Supervisor's Rating (2,4,6,8,10) </strong></td>
		</tr>
		<tr>
			<td height="15" colspan="2" align="center" class="thinborder"><strong>Quantity</strong></td>
		    <td height="15" colspan="2" align="center" class="thinborder"><strong>Time</strong></td>
	    </tr>
		<tr>
			<td width="6%" height="15" align="center" class="thinborder"><strong>Target</strong></td>
			<td width="6%" align="center" class="thinborder"><strong>Accomp</strong></td>
			<td width="6%" align="center" class="thinborder"><strong>Target</strong></td>
			<td width="6%" align="center" class="thinborder"><strong>Accomp</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Quantity</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Time</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>APS</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>EPS</strong></td>
		</tr>
	<%	
		double dPercWeight = 0d;
		double dWeight = 0d;
		int iCount = 1;
		for(int i = 0; i < vWork.size(); i += 11, iCount++){
			dWeight = Double.parseDouble((String)vWork.elementAt(i+1)) / 100 ;
			dPercWeight += Double.parseDouble((String)vWork.elementAt(i+1));
	%>
		<tr>
			<td height="20" align="center" class="thinborder"><%=CommonUtil.formatFloat((String)vWork.elementAt(i+1), false)%>%</td>
		    <td class="thinborder">&nbsp;<%=(String)vWork.elementAt(i+2)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vWork.elementAt(i+3)%></td>
		    <td align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue((String)vWork.elementAt(i+4));
					if(strTemp.length() > 0)
						strTemp = CommonUtil.formatFloat(strTemp, false);
					else
						strTemp = "&nbsp;";
				%>
				<%=strTemp%></td>
		    <td align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue((String)vWork.elementAt(i+5));
					if(strTemp.length() > 0)
						strTemp = CommonUtil.formatFloat(strTemp, false);
					else
						strTemp = "&nbsp;";
				%>
				<%=strTemp%></td>
		    <td align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue((String)vWork.elementAt(i+6));
					if(strTemp.length() > 0)
						strTemp = CommonUtil.formatFloat(strTemp, false);
					else
						strTemp = "&nbsp;";
				%>
				<%=strTemp%></td>
		    <td align="center" class="thinborder">
				<%
					strTemp = WI.getStrValue((String)vWork.elementAt(i+7));
					if(strTemp.length() > 0)
						strTemp = CommonUtil.formatFloat(strTemp, false);
					else
						strTemp = "&nbsp;";
				%>
				<%=strTemp%></td>
			<%
				dAve = (Double.parseDouble(WI.getStrValue((String)vWork.elementAt(i+9), "0")) +
						Double.parseDouble(WI.getStrValue((String)vWork.elementAt(i+10), "0"))) / 2;
				strTemp = CommonUtil.formatFloat(dAve, false);
				dOverall += dAve;
			%>
		    <td align="center" class="thinborder"><%=WI.getStrValue((String)vWork.elementAt(i+9), "&nbsp;")%></td>
		    <td align="center" class="thinborder"><%=WI.getStrValue((String)vWork.elementAt(i+10), "&nbsp;")%></td>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				dWeight = dWeight * dAve;
				dEPS += dWeight;
				strTemp = CommonUtil.formatFloat(dWeight, false);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
	<%}%>
		<tr>
			<td rowspan="2" align="center" class="thinborder"><strong><%=CommonUtil.formatFloat(dPercWeight, false)%>%</strong></td>
		    <td colspan="6" rowspan="2" class="thinborder">&nbsp;</td>
		    <td height="20" colspan="2" class="thinborder">Total Equivalent Rating = </td>
			<%
				dOverall = dOverall / (vWork.size()/11);
				strTemp = CommonUtil.formatFloat(dOverall, false);
				dWorkAve = Double.parseDouble(strTemp);
			%>
		    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
			<%
				//dEPS = dEPS / (vWork.size()/11);
				strTemp = CommonUtil.formatFloat(dEPS, false);
			%>
		    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
		</tr>
		<tr>
			<td height="20" colspan="2" class="thinborder">Weight Average Rating (TEQ x 50%) = </td>
			<%
				dOverall = dWorkAve * 0.50;
				strTemp = CommonUtil.formatFloat(dOverall, false);
			%>
		    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
			<%
				dWorkAve = dEPS;
				dEPS = dEPS * 0.50;
				strTemp = CommonUtil.formatFloat(dEPS, false);
			%>
		    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
		</tr>
	</table>
<%}

if(vValues != null && vValues.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="20"><font style="font-size:11px">
				<strong>PART II: VALUES/BEHAVIOR/WORK ATTITUDE (30%)</strong></font></td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
	  	  <td width="30%" rowspan="2" align="center" class="thinborder"><strong>Values</strong></td>
		  	<td height="20" colspan="4" align="center" class="thinborder"><strong>Rating (2,4,6,8,10) </strong></td>
		  	<td width="14%" rowspan="2" align="center" class="thinborder"><strong>Average Rating </strong></td>
	  	</tr>
		<tr>
			<td width="14%" height="25" align="center" class="thinborder"><strong>Supervisor Rate</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Peer Rate</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Client Rater</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Subordinate Rater</strong></td>
		</tr>
	<%	
		double dSumAve = 0d;
		double dAverage = 0d;
		int iCount = 1;
		for(int i = 0; i < vValues.size(); i += 7, iCount++){
			dAverage = (Double.parseDouble(WI.getStrValue((String)vValues.elementAt(i+3), "0")) +
						Double.parseDouble(WI.getStrValue((String)vValues.elementAt(i+4), "0")) +
						Double.parseDouble(WI.getStrValue((String)vValues.elementAt(i+5), "0")) +
						Double.parseDouble(WI.getStrValue((String)vValues.elementAt(i+6), "0"))) / 4;
			strTemp = CommonUtil.formatFloat(dAverage, false);
			dSumAve += Double.parseDouble(strTemp);
		%>
		<tr>
			<td height="20" class="thinborder">&nbsp;<%=iCount%>. <%=(String)vValues.elementAt(i+2)%></td>
			<td align="center" class="thinborder"><%=WI.getStrValue((String)vValues.elementAt(i+3), "&nbsp;")%></td>
			<td align="center" class="thinborder"><%=WI.getStrValue((String)vValues.elementAt(i+4), "&nbsp;")%></td>
			<td align="center" class="thinborder"><%=WI.getStrValue((String)vValues.elementAt(i+5), "&nbsp;")%></td>
			<td align="center" class="thinborder"><%=WI.getStrValue((String)vValues.elementAt(i+6), "&nbsp;")%></td>
			<td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
	<%}%>
		<tr>
			<td height="20" class="thinborder">&nbsp;</td>
			<td colspan="4" class="thinborder" align="right"><strong>Average Rating = </strong></td>
			<%
				dSumAve = dSumAve / (vValues.size()/7);
				strTemp = CommonUtil.formatFloat(dSumAve, false);				
				dValAve = Double.parseDouble(strTemp);	
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
	</table>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//end of vValues != null

if(vPA != null && vPA.size() > 0){
	double dAve = 0d;
	double dOverall = 0d;
%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="20"><font style="font-size:11px">
				<strong>PART III: PUNCTUALITY &amp; ATTENDANCE (10%)</strong></font></td>
		</tr>
	</table>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
		  <td height="25" colspan="2" class="thinborder">&nbsp;</td>
		  <td colspan="3" align="center" class="thinborder"><strong>Rating (2,4,6,8,10) </strong></td>
	  </tr>
		<tr>
			<td height="25" colspan="2" class="thinborder">&nbsp;</td>
			<td align="center" class="thinborder"><strong>Punctuality</strong></td>
			<td align="center" class="thinborder"><strong>Attendance</strong></td>
			<td align="center" class="thinborder"><strong>Average</strong></td>
		</tr>
		<tr>
			<td height="25" width="2%" align="center" class="thinborder">1</td>
			<td width="53%" class="thinborder">&nbsp;Based on Records (DTR)</td>
			<td width="15%" align="center" class="thinborder"><%=WI.getStrValue((String)vPA.elementAt(1), "&nbsp;")%></td>
			<td width="15%" align="center" class="thinborder"><%=WI.getStrValue((String)vPA.elementAt(3), "&nbsp;")%></td>
			<%
				dAve = (Double.parseDouble(WI.getStrValue((String)vPA.elementAt(1), "0")) +
						Double.parseDouble(WI.getStrValue((String)vPA.elementAt(3), "0"))) / 2;
				dOverall += dAve;
			%>
			<td width="15%" align="center" class="thinborder"><%=CommonUtil.formatFloat(dAve, false)%></td>
		</tr>
		<tr>
		  	<td height="25" align="center" class="thinborder">2</td>
		  	<td class="thinborder">&nbsp;Based on Actual Punctuality &amp; Attendance in the work place </td>
		  	<td align="center" class="thinborder"><%=WI.getStrValue((String)vPA.elementAt(2), "&nbsp;")%></td>
		  	<td align="center" class="thinborder"><%=WI.getStrValue((String)vPA.elementAt(4), "&nbsp;")%></td>
			<%
				dAve = (Double.parseDouble(WI.getStrValue((String)vPA.elementAt(2), "0")) +
						Double.parseDouble(WI.getStrValue((String)vPA.elementAt(4), "0"))) / 2;
				dOverall += dAve;
			%>
		  	<td align="center" class="thinborder"><%=CommonUtil.formatFloat(dAve, false)%></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
		  	<td class="thinborder">&nbsp;</td>
		  	<td align="center" class="thinborder">&nbsp;</td>
		  	<td align="right" class="thinborder"><strong>Average Rating =&nbsp;</strong></td>
			<%
				dPAAve = dOverall / 2;
				strTemp = CommonUtil.formatFloat(dPAAve, false);
				dPAAve = Double.parseDouble(strTemp);
			%>
		  	<td align="center" class="thinborder"><%=strTemp%></td>
	  	</tr>
	</table>
<%}

if(vTeamwork != null && vTeamwork.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<%
				dTeamworkAve = Double.parseDouble(WI.getStrValue((String)vTeamwork.elementAt(1), "0"));
				strTemp = CommonUtil.formatFloat(dTeamworkAve, false);
				dTeamworkAve = Double.parseDouble(strTemp);
			%>
			<td height="20"><strong>PART IV: TEAMWORK (10%)</strong><u>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<%=WI.getStrValue((String)vTeamwork.elementAt(1), "&nbsp;")%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
		</tr>
	</table>
<%}

	double dAve = 0d;
	double dOverall = 0d;
%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="20"><font style="font-size:11px">
				<strong>SUMMARY:</strong></font></td>
		</tr>
	</table>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" colspan="2" class="thinborder">&nbsp;</td>
			<td align="center" class="thinborder"><strong>Average Rating </strong></td>
			<td align="center" class="thinborder"><strong>Weight (%) </strong></td>
			<td align="center" class="thinborder"><strong>Weighted Average Rating </strong></td>
		</tr>
		<tr>
			<td height="25" width="2%" align="center" class="thinborder">1</td>
			<td width="38%" class="thinborder">&nbsp;Work Accomplishment </td>
			<td width="20%" align="center" class="thinborder"><%=CommonUtil.formatFloat(dWorkAve, false)%></td>
			<td width="20%" align="center" class="thinborder">50%</td>
			<%
				dAve = dWorkAve * .50;
				strTemp = CommonUtil.formatFloat(dAve, true);
				dOverall += Double.parseDouble(strTemp);
			%>
			<td width="20%" align="center" class="thinborder"><%=strTemp%></td>
		</tr>
		<tr>
		  	<td height="25" align="center" class="thinborder">2</td>
		  	<td class="thinborder">&nbsp;Values/Behavior/Work Attitude </td>
		  	<td align="center" class="thinborder"><%=CommonUtil.formatFloat(dValAve, false)%></td>
		  	<td align="center" class="thinborder">30%</td>
			<%
				dAve = dValAve * .30;
				strTemp = CommonUtil.formatFloat(dAve, true);
				dOverall += Double.parseDouble(strTemp);
			%>
		  	<td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
		<tr>
		  <td height="25" align="center" class="thinborder">3</td>
		  	<td class="thinborder">&nbsp;Punctuality &amp; Attendance </td>
			<td align="center" class="thinborder"><%=CommonUtil.formatFloat(dPAAve, false)%></td>
		  	<td align="center" class="thinborder">10%</td>
		  	<%
				dAve = dPAAve * .10;
				strTemp = CommonUtil.formatFloat(dAve, true);
				dOverall += Double.parseDouble(strTemp);
			%>
		  <td align="center" class="thinborder"><%=strTemp%></td>
	  	</tr>
		<tr>
	  	  <td height="25" align="center" class="thinborder">4</td>
		  	<td class="thinborder">&nbsp;Teamwork</td>
		  	<td align="center" class="thinborder"><%=CommonUtil.formatFloat(dTeamworkAve, false)%></td>
		  	<td align="center" class="thinborder">10%</td>
			<%
				dAve = dTeamworkAve * .10;
				strTemp = CommonUtil.formatFloat(dAve, true);
				dOverall += Double.parseDouble(strTemp);
			%>
	  	  <td align="center" class="thinborder"><%=strTemp%></td>
	  	</tr>
		<tr>
	  	  <td height="25" colspan="4" align="center" class="thinborder">
  		  <font size="2"><strong>Overall Weighted Average Rating </strong></font></td>
		  	<td align="center" class="thinborder"><%=CommonUtil.formatFloat(dOverall, true)%></td>
	  </tr>
	</table>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="30" colspan="3" valign="middle">We discuss and agree on the above ratings</td>
		</tr>
		<tr>
			<td height="40" class="thinborderBOTTOM" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="33%" align="center">Name &amp; Signature of Employee (Ratee) </td>
		    <td width="33%" align="center">Name &amp; Signature of Supervisor (Rater) </td>
		    <td width="33%" align="center">Name &amp; Signature of Department Head </td>
		</tr>
		<tr>
			<td height="40" colspan="3" valign="middle"><strong>Note:</strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3" valign="middle">
			<font size="1">10 - (O - Outstanding) - Performance exceeding targets by 30% &amp; above of the planned targets </font></td>
		</tr>
		<tr>
		  	<td height="15" colspan="3" valign="middle"><font size="1">&nbsp;8  - (VS - Very Satisfactory) - Performance exceeding targets by 15% to 29% of the planned targets </font></td>
  	  </tr>
		<tr>
		  	<td height="15" colspan="3" valign="middle"><font size="1">&nbsp;6 - (S - Satisfactory) - Performance of 100% to 114% of the planned targets </font></td>
 	  </tr>
		<tr>
		  	<td height="15" colspan="3" valign="middle"><font size="1">&nbsp;4 - (US - Unsatisfactory) - Performance of 51% to 99% of the planned targets </font></td>
  	  </tr>
		<tr>
		  	<td height="15" colspan="3" valign="middle"><font size="1">&nbsp;2 - (P - Poor) - Performance failing to meet the targets of 50% or below </font></td>
  	  </tr>
	</table>
</body>
</html>
<%
dbOP.cleanUP();
%>