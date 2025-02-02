<%@ page language="java" import="utility.*,java.util.Vector, hr.GovtEvaluation" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Agency Performance Evaluation</title>
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
			"Admin/staff-HR Management-Performance Evaluation Management-Create Review Period","agency_perf_eval_print.jsp");
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
	
	double dSupWAS1 = 0d;
	double dSupWAS2 = 0d;
	double dEmpWAS1 = 0d;
	double dEmpWAS2 = 0d;
	double dSupWeight = 0d;
	double dEmpWeight = 0d;
	
	double dAddData = 0d;
	String strComments = null;
	
	Vector vRetResult = null;
	Vector vCF = null;
	Vector vPerf = null;
	Vector vCFOthers = null;
	Vector vWeights = null;
	Vector vOtherData = null;
	Vector vRPInfo = null;
	GovtEvaluation eval = new GovtEvaluation();
	
	enrollment.Authentication authentication = new enrollment.Authentication();
	Vector vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
		
	if(vEmpRec != null && vEmpRec.size() > 0){
		vRetResult = eval.getEmployeeAgencyEvaluationRecords(dbOP, request, (String)vEmpRec.elementAt(0));
		if(vRetResult == null)
			strErrMsg = eval.getErrMsg();
		else{
			vRPInfo = eval.getRatingPeriodInfo(dbOP, request);
		
			vPerf = (Vector)vRetResult.elementAt(2);
			vOtherData = (Vector)vRetResult.elementAt(3);
			if(vOtherData != null && vOtherData.size() > 0){
				dAddData = Double.parseDouble(WI.getStrValue((String)vOtherData.elementAt(2), "0"));
				strComments = WI.getStrValue((String)vOtherData.elementAt(1), "&nbsp;");
			}
			
			vCF = eval.getCriticalFactorsForPrinting(dbOP, request, (String)vEmpRec.elementAt(0));
			
			vWeights = eval.operateOnRaterWeights(dbOP, request, 4);
			if(vWeights != null && vWeights.size() > 0){
				dSupWeight = Double.parseDouble((String)vWeights.elementAt(0));
				dEmpWeight = Double.parseDouble((String)vWeights.elementAt(1));
			}
			
			vCFOthers = eval.getOtherRatesForPrinting(dbOP, request, (String)vEmpRec.elementAt(0));
		}		
	}
	
	if(vEmpRec != null && vEmpRec.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" align="center"><font size="2">Republic of the Philippines </font></td>
		</tr>
		<tr>
			<td height="20" align="center">PROVINCE OF 
			<%=(SchoolInformation.getAddressLine1(dbOP,false,false)).toUpperCase()%></td>
		</tr>
		<tr>
			<td height="20" align="center">AGENCY PERFORMANCE EVALUATION FORM </td>
		</tr>
		<tr>
			<td height="20" align="center">For the rating period from 
				<%if(vRPInfo != null && vRPInfo.size() > 0){%>
					<u><%=(String)vRPInfo.elementAt(2)%></u> to <u><%=(String)vRPInfo.elementAt(3)%></u>
				<%}%></td>
		</tr>
		<tr>
		  <td height="20" align="center">&nbsp;</td>
	  </tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td height="25" width="30%">EMPLOYEE: <u><%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></u></td>
			<%
		  		if((String)vEmpRec.elementAt(13)== null || (String)vEmpRec.elementAt(14)== null)
					strTemp = " ";			
				else
					strTemp = " - ";
			%>
			<td height="25" width="40%">OFFICE/DIVISION: <u>
				<%=WI.getStrValue((String)vEmpRec.elementAt(13),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vEmpRec.elementAt(14),"")%></u></td>
			<td height="25" width="30%">POSITION: <u><%=WI.getStrValue((String)vEmpRec.elementAt(15))%></u> </td>		  
		</tr>
	</table>
	
<%if(vPerf != null && vPerf.size() > 0){
	double dTemp = 0d;
	double dSupAPS = 0d;
	double dSupEPS = 0d;
	double dEmpAPS = 0d;
	double dEmpEPS = 0d;
	double dSumPerc = 0d;
%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" colspan="19" class="thinborder">&nbsp;<strong>PART I: PERFORMANCE</strong></td>
		</tr>
		<tr>
			<td rowspan="3" align="center" class="thinborder" width="6%">WEIGHT<br>(%)</td>
		  	<td rowspan="3" align="center" class="thinborder" width="23%">WORK/ACTIVITIES</td>
			<td rowspan="3" align="center" class="thinborder" width="23%">Unit of Measure</td>
		    <td height="15" colspan="6" align="center" class="thinborder">TARGET AND ACCOMPLISHMENT </td>
		    <td colspan="10" align="center" class="thinborder">RATINGS</td>
		</tr>
		<tr>
			<td height="15" colspan="2" align="center" class="thinborder">Quantity</td>
		    <td height="15" colspan="2" align="center" class="thinborder">Quality</td>
		    <td height="15" colspan="2" align="center" class="thinborder">Time</td>
	        <td colspan="5" align="center" class="thinborder">Supervisor</td>
		    <td colspan="5" align="center" class="thinborder">Employee</td>
		</tr>
		<tr>
			<td width="3%" height="15" align="center" class="thinborder"><font style="font-size:8px">TARGET</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">ACCOMP</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">TARGET</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">ACCOMP</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">TARGET</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">ACCOMP</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">QN</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">QL</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">T</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">APS</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">EPS</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">QN</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">QL</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">T</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">APS</font></td>
			<td width="3%" align="center" class="thinborder"><font style="font-size:8px">EPS</font></td>
		</tr>
	<%	double dWeight = 0d;
		double dSumWeight = 0d;
		int iCount = 1;
		for(int i = 0; i < vPerf.size(); i += 17, iCount++){
			dWeight = Double.parseDouble((String)vPerf.elementAt(i+3)) / 100;
			dSumWeight += dWeight;
			dSumPerc += Double.parseDouble((String)vPerf.elementAt(i+3));
	%>
		<tr>
		  	<td align="center" class="thinborderLEFT"><%=CommonUtil.formatFloat((String)vPerf.elementAt(i+3), false)%>%</td>
		  	<td class="thinborderLEFT">&nbsp;<%=(String)vPerf.elementAt(i+2)%></td>
			<td height="25" class="thinborderLEFT">&nbsp;<%=(String)vPerf.elementAt(i+4)%></td>
			<%
				strTemp = WI.getStrValue((String)vPerf.elementAt(i+5));
				if(strTemp.length() > 0)
					strTemp = CommonUtil.formatFloat(strTemp, false);
				else
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
			<%
				strTemp = WI.getStrValue((String)vPerf.elementAt(i+6));
				if(strTemp.length() > 0)
					strTemp = CommonUtil.formatFloat(strTemp, false);
				else
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
			<%
				strTemp = WI.getStrValue((String)vPerf.elementAt(i+7));
				if(strTemp.length() > 0)
					strTemp = CommonUtil.formatFloat(strTemp, false);
				else
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
			<%
				strTemp = WI.getStrValue((String)vPerf.elementAt(i+8));
				if(strTemp.length() > 0)
					strTemp = CommonUtil.formatFloat(strTemp, false);
				else
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
			<%
				strTemp = WI.getStrValue((String)vPerf.elementAt(i+9));
				if(strTemp.length() > 0)
					strTemp = CommonUtil.formatFloat(strTemp, false);
				else
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
			<%
				strTemp = WI.getStrValue((String)vPerf.elementAt(i+10));
				if(strTemp.length() > 0)
					strTemp = CommonUtil.formatFloat(strTemp, false);
				else
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
			<td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vPerf.elementAt(i+11), "&nbsp;")%></td>
		    <td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vPerf.elementAt(i+12), "&nbsp;")%></td>
		    <td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vPerf.elementAt(i+13), "&nbsp;")%></td>
			<%
				dTemp = (Double.parseDouble(WI.getStrValue((String)vPerf.elementAt(i+11), "0")) +
						Double.parseDouble(WI.getStrValue((String)vPerf.elementAt(i+12), "0")) +
						Double.parseDouble(WI.getStrValue((String)vPerf.elementAt(i+13), "0")))  / 3;
				dSupAPS += dTemp;
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dTemp, false);
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
			<%
				dTemp = dWeight * dTemp;
				dSupEPS += dTemp;
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dTemp, false);
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
		    <td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vPerf.elementAt(i+14), "&nbsp;")%></td>
		    <td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vPerf.elementAt(i+15), "&nbsp;")%></td>
		    <td align="center" class="thinborderLEFT"><%=WI.getStrValue((String)vPerf.elementAt(i+16), "&nbsp;")%></td>
			<%
				dTemp = (Double.parseDouble(WI.getStrValue((String)vPerf.elementAt(i+14), "0")) +
						Double.parseDouble(WI.getStrValue((String)vPerf.elementAt(i+15), "0")) +
						Double.parseDouble(WI.getStrValue((String)vPerf.elementAt(i+16), "0")))  / 3;
				dEmpAPS += dTemp;
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dTemp, false);
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
			<%
				dTemp = dWeight * dTemp;
				dEmpEPS += dTemp;
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dTemp, false);
			%>
		    <td align="center" class="thinborderLEFT"><%=strTemp%></td>
	    </tr>
	<%}%>
		<tr>
			<td rowspan="3" align="center" class="thinborderTOPLEFTBOTTOM"><%=CommonUtil.formatFloat(dSumPerc, false)%>%</td>
		    <td colspan="2" rowspan="3" class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
		    <td height="25" colspan="10" class="thinborderTOPLEFT">&nbsp;Total Equivalent Point Score</td>
			<%
				if(dSupEPS == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dSupEPS, false);
			%>
		    <td align="center" class="thinborderTOPLEFT"><%=strTemp%></td>
			<%
			%>
		    <td colspan="4" rowspan="3" class="thinborderTOPLEFTBOTTOM">&nbsp;</td>
			<%
				if(dEmpEPS == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dEmpEPS, false);
			%>
		    <td align="center" class="thinborderTOPLEFT"><%=strTemp%></td>
		</tr>
		<tr>
			<td height="25" colspan="10" class="thinborderLEFT">&nbsp;Multiply by Percentage Weight Allocation (70%)</td>
			<%
				dTemp = dSupEPS * 0.70;
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dTemp, false);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				dTemp = dEmpEPS * 0.70;
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dTemp, false);
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
		<tr>
			<td height="25" colspan="10" class="thinborder">&nbsp;Weighted Average Score (WAS)</td>
			<%
				dTemp = (dSupEPS * 0.70) / (vPerf.size() / 17);
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dTemp, false);
				
				dSupWAS1 = dTemp;
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				dTemp = (dEmpEPS * 0.70) / (vPerf.size() / 17);
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.formatFloat(dTemp, false);
					
				dEmpWAS1 = dTemp;
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
		<tr>
			<td colspan="7" rowspan="2" class="thinborder"><span class="thinborderLEFT">&nbsp;<font size="2"><strong>WE DISCUSS AND AGREE ON THE ABOVE TARGETS : </strong></font></span></td>
		    <td height="15" colspan="6" class="thinborderLEFT">&nbsp;<strong>Legend:</strong></td>
		    <td colspan="6" rowspan="2" class="thinborderLEFT">&nbsp;<font size="2"><strong>PERC ACTION: </strong></font></td>
	    </tr>
		<tr>
	  	  <td height="15" colspan="6" class="thinborderLEFT">&nbsp;QL - Quality</td>
        </tr>
		<tr>
	  	  <td colspan="7" rowspan="3" class="thinborder">&nbsp;</td>
			<td height="15" colspan="6" class="thinborderLEFT">&nbsp;QN - Quantity</td>
	        <td colspan="6" class="thinborderLEFT">&nbsp;</td>
		</tr>
		<tr>
		  <td height="15" colspan="6" class="thinborderLEFT">&nbsp;T - Timeliness</td>
	        <td colspan="6" class="thinborderLEFT">&nbsp;</td>
		</tr>
		<tr>
	  	  <td height="15" colspan="6" class="thinborderLEFT">&nbsp;APS - Average Point Score</td>
	        <td colspan="6" align="center" class="thinborderLEFT">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
					<tr>
						<td height="15" width="2%">&nbsp;</td>
						<td width="96%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="2%">&nbsp;</td>
					</tr>
			</table></td>
		</tr>
		<tr>
			<td colspan="7" rowspan="2" class="thinborder">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="15" width="1%">&nbsp;</td>
						<td width="32%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="1%">&nbsp;</td>
						<td width="32%" class="thinborderBOTTOM">&nbsp;</td>						
						<td width="1%">&nbsp;</td>
						<td width="32%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="1%">&nbsp;</td>
					</tr>
					<tr>
						<td height="15">&nbsp;</td>
						<td align="center">Rater</td>
						<td>&nbsp;</td>
						<td align="center">Ratee</td>
						<td>&nbsp;</td>
						<td align="center">Date</td>
						<td>&nbsp;</td>
					</tr>
			  	</table></td>
			<td height="15" colspan="6" class="thinborderLEFT">&nbsp;EPS - Equivalent Point Score</td>
	        <td colspan="6" align="center" class="thinborderLEFT">Provincial Administrator </td>
		</tr>
		<tr>
		  <td height="15" colspan="6" class="thinborderBOTTOMLEFT">&nbsp;</td>
	        <td colspan="6" class="thinborder">&nbsp;</td>
		</tr>
	</table>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}

if(vCF != null && vCF.size() > 0){
	double dOverall = 0d;
	double dTemp = 0d;
	double dSumSup = 0d;
	double dSumEmp = 0d;
	int iEntriesSupervisor = Integer.parseInt((String)vCF.remove(0));
	int iEntriesEmployee = Integer.parseInt((String)vCF.remove(0));
%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td width="55%" valign="top" class="thinborder">
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="25" colspan="5" class="thinborderBOTTOM">&nbsp;<strong>PART II: CRITICAL FACTORS</strong></td>
					</tr>
					<tr>
					  	<td rowspan="2" align="center" class="thinborderBOTTOM">&nbsp;</td>
				        <td rowspan="2" colspan="2" align="center" class="thinborder">CRITICAL FACTORS </td>
				        <td height="20" colspan="2" align="center" class="thinborder">RATING</td>
					</tr>
					<tr>
					  	<td height="20" align="center" class="thinborder"><font style="font-size:9px">SUPERVISOR</font></td>
				      	<td height="20" align="center" class="thinborder"><font style="font-size:9px">EMPLOYEE</font></td>
				  	</tr>
				<%	boolean bolSupervisorOnly = false;
					int iCount = 1;
					for(int i = 0; i < vCF.size(); i += 7, iCount++){
						bolSupervisorOnly = ((String)vCF.elementAt(i+4)).equals("1");
				%>
					<tr>
						<td height="25" valign="top" class="thinborderBOTTOM">&nbsp;<%=iCount%>. <%=(String)vCF.elementAt(i+2)%>
							<%if(bolSupervisorOnly){%>
								<br>&nbsp;<font size="1">(For supervisors only)</font>
							<%}%></td>						
					    <td colspan="2" class="thinborder"><div align="left">&nbsp;<%=WI.getStrValue((String)vCF.elementAt(i+3), "&nbsp;")%></div></td>
						<%
							strTemp = WI.getStrValue((String)vCF.elementAt(i+5));
							if(strTemp.length() == 0)
								strTemp = "&nbsp;";
							else
								strTemp = CommonUtil.formatFloat(strTemp, false);
								
							dSumSup += Double.parseDouble(WI.getStrValue((String)vCF.elementAt(i+5),  "0"));
						%>
					    <td align="center" class="thinborder"><%=strTemp%></td>
						<%
							strTemp = WI.getStrValue((String)vCF.elementAt(i+6));
							if(strTemp.length() == 0)
								strTemp = "&nbsp;";
							else
								strTemp = CommonUtil.formatFloat(strTemp, false);
							
							dSumEmp += Double.parseDouble(WI.getStrValue((String)vCF.elementAt(i+6), "0"));
						%>
					    <td align="center" class="thinborder"><%=strTemp%></td>
					</tr>
				<%}%>
					<tr>
						<td height="20" width="20%" align="center">&nbsp;</td>
						<td width="10%" align="center">&nbsp;</td>
						<td width="40%" class="thinborder">&nbsp;Total Point Score</td>
						<td width="15%" align="center" class="thinborder"><%=CommonUtil.formatFloat(dSumSup, false)%></td>
						<td width="15%" align="center" class="thinborder"><%=CommonUtil.formatFloat(dSumEmp, false)%></td>
					</tr>
					<tr>
						<td colspan="2" rowspan="4" class="thinborderBOTTOM">&nbsp;</td>
					    <td height="20" class="thinborder">&nbsp;Divide by Entries</td>
					    <td height="20" align="center" class="thinborder"><%=iEntriesSupervisor%></td>
					    <td height="20" align="center" class="thinborder"><%=iEntriesEmployee%></td>
					</tr>
					<tr>
						<td height="20" class="thinborder">&nbsp;Average Point Scores</td>
						<%
							if(iEntriesSupervisor == 0)
								strTemp = "0";
							else{
								dTemp = dSumSup / (double)iEntriesSupervisor;
								strTemp = CommonUtil.formatFloat(dTemp, false);
							}
						%>
					    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
						<%
							if(iEntriesEmployee == 0)
								strTemp = "0";
							else{
								dTemp = dSumEmp / (double)iEntriesEmployee;
								strTemp = CommonUtil.formatFloat(dTemp, false);
							}
						%>
					    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
					</tr>
					<tr>
						<td height="20" class="thinborder">&nbsp;Multiply by Part II Weight (30%)</td>
						<%
							dTemp = dSumSup * 0.30;
							strTemp = CommonUtil.formatFloat(dTemp, false);
						%>
					    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
						<%
							dTemp = dSumEmp * 0.30;
							strTemp = CommonUtil.formatFloat(dTemp, false);
						%>
					    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
					</tr>
					<tr>
						<td height="20" class="thinborder">&nbsp;Weighted Average Score</td>
						<%
							if(iEntriesSupervisor == 0){
								strTemp = "0";
								dSupWAS2 = 0;
							}
							else{
								dTemp = dSumSup * 0.30;
								dTemp = dTemp / (double)iEntriesSupervisor;
								strTemp = CommonUtil.formatFloat(dTemp, false);
								dSupWAS2 = dTemp;
							}	
						%>
					    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
						<%
							if(iEntriesEmployee == 0){
								strTemp = "0";
								dEmpWAS2 = 0;
							}
							else{
								dTemp = dSumEmp * 0.30;
								dTemp = dTemp / (double)iEntriesEmployee;
								strTemp = CommonUtil.formatFloat(dTemp, false);
								dEmpWAS2 = dTemp;
							}							
						%>
					    <td height="20" align="center" class="thinborder"><%=strTemp%></td>
					</tr>
				</table>
			<td width="45%" valign="top" class="thinborder">
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="25" colspan="6" class="thinborderBOTTOM">&nbsp;</td>
					</tr>
					<tr>
						<td rowspan="2" class="thinborderBOTTOM">&nbsp;</td>
					    <td height="20" align="center" class="thinborder" colspan="5">SUMMARY OF RATINGS </td>
				    </tr>
					<tr>
						<td height="20" class="thinborder" colspan="5">&nbsp;</td>
				    </tr>
					<tr>
						<td width="20%" rowspan="2" align="center" class="thinborderBOTTOM">RATER</td>
				        <td height="25" colspan="2" align="center" class="thinborder">Weighted Average Scores </td>
				        <td height="25" colspan="3" align="center" class="thinborder">&nbsp;</td>
			        </tr>
					<tr>
						<td height="25" align="center" class="thinborder" width="16%">PART I </td>
				        <td height="25" align="center" class="thinborder" width="16%">PART II </td>
				        <td height="25" align="center" class="thinborder" width="16%">Overall Point Scores </td>
				        <td height="25" align="center" class="thinborder" width="16%">Weight % </td>
				        <td height="25" align="center" class="thinborder" width="16%">Overall Weighted Scores </td>
					</tr>
					<tr>
						<td height="25" class="thinborderBOTTOM">&nbsp;Supervisor Rater</td>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dSupWAS1, false)%></td>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dSupWAS2, false)%></td>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dSupWAS1 + dSupWAS2, false)%></td>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dSupWeight, false)%>%</td>
						<%
							dTemp = (dSupWAS1 + dSupWAS2) * (dSupWeight/100);
							dOverall += dTemp;
						%>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dTemp, false)%></td>
					</tr>
					<tr>
						<td height="25" class="thinborderBOTTOM">&nbsp;Self Rater</td>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dEmpWAS1, false)%></td>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dEmpWAS2, false)%></td>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dEmpWAS1 + dEmpWAS2, false)%></td>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dEmpWeight, false)%>%</td>
						<%
							dTemp = (dEmpWAS1 + dEmpWAS2) * (dEmpWeight/100);
							dOverall += dTemp;
						%>
				        <td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dTemp, false)%></td>
					</tr>
				<%for(int i = 0; i < vCFOthers.size(); i += 4){%>
					<tr>
						<td height="25" class="thinborderBOTTOM">&nbsp;<%=(String)vCFOthers.elementAt(i)%></td>					    
						<%
							strTemp = CommonUtil.formatFloat(WI.getStrValue((String)vCFOthers.elementAt(i+2), "0"), false);
						%>
					    <td align="center" class="thinborder"><%=strTemp%></td>
						<%
							strTemp = CommonUtil.formatFloat(WI.getStrValue((String)vCFOthers.elementAt(i+3), "0"), false);
						%>
					    <td align="center" class="thinborder"><%=strTemp%></td>
						<%
							dTemp = Double.parseDouble(WI.getStrValue((String)vCFOthers.elementAt(i+2), "0")) +
									Double.parseDouble(WI.getStrValue((String)vCFOthers.elementAt(i+3), "0"));
						%>
						<td align="center" class="thinborder"><%=CommonUtil.formatFloat(dTemp, false)%></td>
					    <td align="center" class="thinborder"><%=CommonUtil.formatFloat((String)vCFOthers.elementAt(i+1), false)%>%</td>
						<%
							dTemp = dTemp * (Double.parseDouble((String)vCFOthers.elementAt(i+1)) / 100);
							dOverall += dTemp;
						%>
					    <td align="center" class="thinborder"><%=CommonUtil.formatFloat(dTemp, false)%></td>
					</tr>
				<%}%>
					<tr>
						<td height="25" colspan="5" class="thinborderBOTTOM">&nbsp;Total Overall Score</td>
						<td height="25" align="center" class="thinborder"><%=CommonUtil.formatFloat(dOverall, false)%></td>
					</tr>
					<tr>
						<td height="25" colspan="5" class="thinborderBOTTOM">&nbsp;Add: Rating ca Intervening Task (if any)</td>
						<%
							if(dAddData == 0)
								strTemp = "&nbsp;";
							else
								strTemp = CommonUtil.formatFloat(dAddData, false);
						%>
						<td height="25" align="center" class="thinborder"><%=strTemp%></td>
					</tr>
					<tr>
						<td height="25" colspan="4">&nbsp;</td>
						<td height="25" class="thinborderLEFT">&nbsp;</td>
						<td height="25" align="center" class="thinborderLEFT">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" colspan="4">&nbsp;<font style="font-size:11px">FINAL NUMERICAL PERFORMANCE RATING</font></td>
						<td height="25" class="thinborderLEFT">&nbsp;</td>
						<td height="25" align="center" class="thinborderLEFT"><%=CommonUtil.formatFloat(dOverall + dAddData, false)%></td>
					</tr>
					<tr>
						<td height="25" colspan="4">&nbsp;</td>
						<td height="25" class="thinborder">&nbsp;</td>
						<td height="25" align="center" class="thinborderBOTTOMLEFT">&nbsp;</td>
					</tr>
					<tr>
					  <td height="25" colspan="4">&nbsp;<font style="font-size:11px">EQUIVALENT ADJECTIVAL RATING</font></td>
					  <td height="25" class="thinborder">&nbsp;</td>
					  <td height="25" align="center" class="thinborderBOTTOM">&nbsp;</td>
				  </tr>
					<tr>
					  <td height="15" colspan="4" class="thinborderBOTTOM">&nbsp;</td>
					  <td class="thinborder">&nbsp;</td>
					  <td align="center" class="thinborderBOTTOM">&nbsp;</td>
				  </tr>
				</table>
			</td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" width="45%" class="thinborderLEFT">COMMENTS AND RECOMMENDATIONS </td>
			<td width="55%" class="thinborderLEFT">&nbsp;WE DISCUSS AND AGREE ON THE ABOVE RATINGS:</td>
		</tr>
		<tr>
		  	<td rowspan="6" class="thinborder" valign="top"><div align="justify">&nbsp;<%=strComments%></div></td>
		  	<td height="25" class="thinborderLEFT">&nbsp;</td>
	  	</tr>		
		<tr>
		  	<td height="25" class="thinborderLEFT">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td width="1%">&nbsp;</td>
					    <td width="27%" class="thinborderBOTTOM">&nbsp;</td>
					    <td width="1%">&nbsp;</td>
					    <td width="27%" class="thinborderBOTTOM">&nbsp;</td>
					    <td width="1%">&nbsp;</td>
					    <td width="27%" class="thinborderBOTTOM">&nbsp;</td>
					    <td width="1%">&nbsp;</td>
					    <td width="14%" class="thinborderBOTTOM">&nbsp;</td>
					    <td width="1%">&nbsp;</td>
					</tr>
				</table>
			</td>
	  </tr>
	  <tr>
		  	<td height="25" class="thinborderLEFT">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td width="1%">&nbsp;</td>
					    <td width="27%" align="center"><font style="font-size:11px">Rater</font></td>
					    <td width="1%">&nbsp;</td>
					    <td width="27%" align="center"><font style="font-size:11px">Ratee</font></td>
					    <td width="1%">&nbsp;</td>
					    <td width="27%" align="center"><font style="font-size:8px">Confirmed by Next Higher Supervisor</font></td>
					    <td width="1%">&nbsp;</td>
					    <td width="14%" align="center"><font style="font-size:11px">Date</font></td>
					    <td width="1%">&nbsp;</td>
					</tr>
				</table>
			</td>
	  	</tr>
		<tr>
		  <td height="25" class="thinborderTOPLEFT">&nbsp;PERC ACTION:</td>
	  </tr>
		<tr>
		  <td height="25" class="thinborderLEFT">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
	  </tr>
	</table>
<%}
}%>
	
</body>
</html>
<%
dbOP.cleanUP();
%>