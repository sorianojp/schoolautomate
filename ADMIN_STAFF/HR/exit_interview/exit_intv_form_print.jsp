<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);		
	String strExitIntvIndex = WI.fillTextValue("exit_intv_index");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Exit Interview Form</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/td.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	
	
	if(strExitIntvIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Resignation reference is not found. Please close this window and click update link again..</p>
		<%return;
	}

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-EXIT INTERVIEW MANAGEMENT"),"0"));
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
			"my_home","update_exit_intv_main.jsp");
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
	
	String strLocation = null;
	Vector vRetResult = null;	
	HRLighthouse hrl = new HRLighthouse();
	
	if(WI.fillTextValue("update_exit_intv_form").length() > 0){
		if(hrl.operateOnExitInterviewData(dbOP, request, 2) == null)
			strErrMsg = hrl.getErrMsg();
		else
			strErrMsg = "Exit Interview Form updated successfully.";
	}
	
	vRetResult =  hrl.operateOnExitInterviewData(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = hrl.getErrMsg();
%>
<body onLoad="window.print();">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="2" align="center">
				<strong>:::: EMPLOYEE EXIT INTERVIEW FORM ::::</strong></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="20%">Name: </td>
			<td width="30%" class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(0)%></strong></td>
			<td width="45%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Position:</td>
			<td class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(1)%></strong></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Division:</td>
			<td class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(2)%></strong></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department:</td>
			<td class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(3)%></strong></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Length of Service: </td>
			<td class="thinborderBOTTOM">
				<%
					strTemp = (String)vRetResult.elementAt(4);
					if(strTemp.equals("0"))
						strTemp = "";
					else
						strTemp = strTemp + "years ";
						
					strTemp += (String)vRetResult.elementAt(5) + " months ";
				%>
				<strong><%=strTemp%></strong></td>
			<td>&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="20" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td width="5%" height="25">&nbsp;</td>
			<td colspan="2">
				1.) State at least two (2) reasons why you accepted the job offer at Lighthouse.</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(7)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				2.) When you first started, what were your expectations?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(8)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Were these expectations met? Why or why not?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(9)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				3.) In your stint with LSCI, are you generally satisfied with your work (in terms of nature of work, 
				career path, relationship with peers and immediate superior, etc)? Why or why not?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(10)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				4.) Looking at your own team, what could be its strengths? Weaknesses?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(11)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				5.) In a scale of 1 to 5 (with 5 as the highest), how would you rate the LSCI organization
				as a whole? Explain your rating.</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Rating: <strong><%=(String)vRetResult.elementAt(13)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(12)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				6.) In a scale of 1 to 5 (with 5 as the highest), rate your satisfaction level of the following:</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="40%">Cash Compensation: <strong><%=(String)vRetResult.elementAt(14)%></strong></td>
		    <td width="65%">Employee Relations & Communications Program: <strong><%=(String)vRetResult.elementAt(19)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="40%">Policies and Procedures: <strong><%=(String)vRetResult.elementAt(15)%></strong></td>
		    <td width="65%">Benefit Package: <strong><%=(String)vRetResult.elementAt(20)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="40%">Management Style: <strong><%=(String)vRetResult.elementAt(16)%></strong></td>
		    <td width="65%">Career Opportunity: <strong><%=(String)vRetResult.elementAt(21)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="40%">Performance Review/ Appraisal: <strong><%=(String)vRetResult.elementAt(17)%></strong></td>
		    <td width="65%">Rewards & Recognition Program: <strong><%=(String)vRetResult.elementAt(22)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">Work Environment / Culture: <strong><%=(String)vRetResult.elementAt(18)%></strong></td>
	    </tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				7.) What  would you recommend to LSCI, or the HR Department, or your own  department for its  improvement?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(23)%></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				8.) Would you consider working for LSCI again? 
				<%
					strTemp = (String)vRetResult.elementAt(25);
					if(strTemp.equals("1"))
						strTemp = "YES";
					else
						strTemp = "NO";
				%>
				<strong><%=strTemp%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
				Why?</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><%=(String)vRetResult.elementAt(24)%></strong></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
	<%
	strTemp = "";
	if(hrl.isExitInterviewDataCompleted(dbOP, request, WI.fillTextValue("exit_intv_index")))
		strTemp = "1";
	
	if(strTemp.length() == 0){%>
		<tr>
			<td height="15" colspan="3"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong>Exit Interview Form Not Yet Reviewed. </strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	<%}else{
		Vector vHRDetails = hrl.getExitIntvHRDetails(dbOP, request, strExitIntvIndex);%>
		<tr>
			<td height="15" colspan="3"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<%
				strTemp = (String)vHRDetails.elementAt(0);
				if(strTemp.equals("0"))
					strErrMsg = (String)vHRDetails.elementAt(1);
				else{
					strTemp = (String)vHRDetails.elementAt(1);
					if(strTemp.equals("0"))
						strErrMsg = "NO.";
					else
						strErrMsg = "YES.";
				}
			%>
		    <td height="25" colspan="2">Qualified for Re-hire? <strong><%=strErrMsg%></strong>		</td>
		<tr>
			<td height="25">&nbsp;</td>
		    <td height="25" colspan="2">Remarks:</td>
	    </tr>
		<tr>
			<td height="40">&nbsp;</td>
	      	<td colspan="2" valign="top"><strong><%=WI.getStrValue((String)vHRDetails.elementAt(2), "&nbsp;")%></strong></td>
	    </tr>
	<%}%>
	</table>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>