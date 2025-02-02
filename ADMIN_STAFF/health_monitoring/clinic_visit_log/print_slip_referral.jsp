<%@ page language="java" import="utility.*, health.AUFHealthProgram, java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Slip Referral</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript" src="../../../jscript/common.js"></script>
</head>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strDate = null;
	String strComplaints = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","print_slip_referral.jsp");
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
															"print_slip_referral.jsp");
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
	
	AUFHealthProgram hp = new AUFHealthProgram();
	Vector vRetResult = hp.getReferralSlipDetails(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hp.getErrMsg();
%>
<body onLoad="window.print();">
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td width="35%" rowspan="5" align="right">
				<img src="../../../images/logo/AUF_PAMPANGA.gif" border="0" height="95" width="95"></td>
			<td width="45%" height="20" align="center"><font style="font-size:14px">
				<strong>ANGELES UNIVERSITY FOUNDATION</strong></font></td>
			<td width="20%" rowspan="6">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" align="center"><i>Angeles City</i></td>
		</tr>
		<tr>
			<td height="20" align="center">UNIVERSITY HEALTH SERVICES</td>
		</tr>
		<tr>
			<td height="15" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" align="center">AUF HEALTH PROGRAM</td>
		</tr>
		<tr>
			<td height="20">&nbsp;</td>
			<td align="center"><u>REFERRAL SLIP </u></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){
	boolean bolIsDependent = ((String)vRetResult.remove(0)).equals("1");
	strDate = ConversionTable.replaceString((String)vRetResult.remove(0), "/", "-");
	strComplaints = (String)vRetResult.remove(0);
%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="20" colspan="2" align="right">Date: <u><%=strDate%></u></td>
		</tr>
		<tr>
			<td width="60%">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<tr>
						<td height="20" width="10%">To: </td>
						<td width="85%" class="thinborderBOTTOM">&nbsp;<%=(String)vRetResult.elementAt(0)%></td>
						<td width="5%">&nbsp;</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td align="center"><font size="1"><i>ACCREDITED AUFMC SPECIALIST</i></font></td>
						<td>&nbsp;</td>
					</tr>
				</table>
			</td>
			<td width="40%">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<tr>
						<td height="20" width="50%">Reason for Referral  : </td>
						<td width="50%" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strComplaints)%></td>
					</tr>
					<tr>
						<td height="20" colspan="2">&nbsp;</td>
					</tr>
				</table>
			</td>
		
		</tr>
		<tr>
			<td colspan="2">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="15%">Name of Patient: </td>
						<td width="50%" class="thinborderBOTTOM">&nbsp;<%=(String)vRetResult.elementAt(2)%></td>
						<td width="35%">&nbsp;</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td align="center"><font size="1"><i>Family Name, First Name, M.I.</i></font></td>
					  	<td>&nbsp;</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="5" colspan="6"><u>For Dependents:</u></td>
					</tr>
					<tr>
						<td height="25" width="18%">Name of Employee:</td>
						<%
							if(bolIsDependent)
								strTemp = (String)vRetResult.elementAt(7);
							else
								strTemp = "&nbsp;";
						%>
					    <td width="40%" class="thinborderBOTTOM">&nbsp;<%=strTemp%></td>
					    <td width="5%">&nbsp;</td>
					    <td width="10%">College/Unit:</td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
							strErrMsg = WI.getStrValue((String)vRetResult.elementAt(6));
							
							if(strTemp.length() > 0 && strErrMsg.length() > 0)
								strTemp = strTemp + "-" + strErrMsg;
							else
								strTemp += strErrMsg;
						%>
					    <td width="20%" class="thinborderBOTTOM">&nbsp;<%=strTemp%></td>
					    <td width="7%">&nbsp;</td>
					</tr>
					<tr>
						<td height="15" colspan="6">&nbsp;</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="20" colspan="2">Authorized by: </td>
			<td colspan="2">Approved by: </td>
		</tr>
		<tr>
			<td height="35" width="25%" valign="bottom" class="thinborderBOTTOM">&nbsp;VINCENT P. SARMIENTO, M.D.</td>
			<td width="35%">&nbsp;</td>
			<td width="25%" class="thinborderBOTTOM" valign="bottom">&nbsp;ANDREW L. ANGELES, M.D.</td>
			<td width="15%">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="2">Director, University Health Services</td>
			<td colspan="2">AUFHP Coordinator</td>
		</tr>
		<tr>
			<td height="20" colspan="4" class="thinborderBOTTOM">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="4" align="center">SPECIALIST&rsquo;S REMARKS</td>
		
	  	</tr>
		<tr>
		  	<td height="20" colspan="4" align="right">Date: <u><%=strDate%></u></td>
	  	</tr>
		<tr>
		  	<td colspan="4">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="20" width="20%">FINDINGS/DIAGNOSIS: </td>
						<td width="60%" class="thinborderBOTTOM">&nbsp;<%=(String)vRetResult.elementAt(3)%></td>
						<td width="20%">&nbsp;</td>
					</tr>
					<tr>
					  <td height="20">RECOMMENDATIONS:</td>
					  <td class="thinborderBOTTOM">&nbsp;<%=(String)vRetResult.elementAt(4)%></td>
					  <td>&nbsp;</td>
				  </tr>
				</table>			</td>
	  	</tr>
		<tr>
			<td colspan="4">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<tr>
						<td height="30" width="40%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="10%">&nbsp;</td>
						<td width="25%" class="thinborderBOTTOM">&nbsp;</td>
						<td width="25%">&nbsp;</td>
					</tr>
					<tr>
					  	<td height="25">Patient/Guardian&rsquo;s Signature over Printed Name</td>
					  	<td>&nbsp;</td>
					  	<td>Specialist&rsquo;s Signature</td>
					  	<td>&nbsp;</td>
					</tr>
					<tr>
						<td height="5" colspan="2">&nbsp;</td>
						<td colspan="2">&nbsp;</td>
					</tr>
					<tr>
					  	<td height="15" colspan="2"><font style="font-size:11px">Note: To be returned to the AUF Accounting Office</td>
					  	<td>&nbsp;</td>
					</tr>
					<tr>
						<td height="5" colspan="2">&nbsp;</td>
						<td colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font style="font-size:10px">AUF-Form-UHS-10 </td>
					</tr>
					<tr>
						<td height="15" colspan="2"><font style="font-size:10px">June 1, 2007-Rev.00 </td>
				  	</tr>
				</table>
			</td>
		</tr>
	</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>