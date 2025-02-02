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
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","print_slip_admission.jsp");
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
															"print_slip_admission.jsp");
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
	Vector vRetResult = hp.getDiagnosticSlipDetails(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hp.getErrMsg();
	
%>
<body onLoad="window.print();">
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td width="35%" rowspan="5" align="right">
				<img src="../../../images/logo/AUF_PAMPANGA.gif" border="0" height="95" width="95"></td>
			<td width="45%" height="20" align="center"><font style="font-size:14px"><strong>
				ANGELES UNIVERSITY FOUNDATION</strong></font></td>
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
			<td align="center"><u>AUTHORIZATION FOR DIAGNOSTIC WORK-UPS</u></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){	
	boolean bolIsDependent = ((String)vRetResult.elementAt(5)).equals("1");	
%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="20" colspan="2" align="right">Date: <u><%=ConversionTable.replaceString((String)vRetResult.remove(0), "/", "-")%></u></td>
		</tr>
		<tr>
			<td width="65%">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<tr>
						<td height="20" width="25%">Name of Patient: </td>
						<td width="70%" class="thinborderBOTTOM">&nbsp;<%=(String)vRetResult.elementAt(0)%></td>
						<td width="5%">&nbsp;</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td align="center"><font size="1"><i>Family Name, First Name M.I.</i></font></td>
						<td>&nbsp;</td>
					</tr>
				</table>			</td>
			<td width="35%">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<tr>
						<td height="40">&nbsp;</td>
					</tr>
				</table></td>
		</tr>
		<tr>
			<td height="20" colspan="2"><u>For Dependents:</u></td>
		</tr>
		<tr>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">					
					<tr>
						<td height="20" width="28%">Name of Employee: </td>
						<%
							if(bolIsDependent)
								strTemp = (String)vRetResult.elementAt(7);
							else
								strTemp = "&nbsp;";
						%>
						<td width="67%" class="thinborderBOTTOM">&nbsp;<%=strTemp%></td>
						<td width="5%">&nbsp;</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td align="center"><font size="1"><i>Family Name, First Name M.I.</i></font></td>
						<td>&nbsp;</td>
					</tr>
				</table></td>
			<td>
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<tr>
						<td height="20" width="48%">College/Unit : </td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
							strErrMsg = WI.getStrValue((String)vRetResult.elementAt(6));
							
							if(strTemp.length() > 0 && strErrMsg.length() > 0)
								strTemp = strTemp + "-" + strErrMsg;
							else
								strTemp += strErrMsg;
						%>
						<td width="52%" class="thinborderBOTTOM">&nbsp;<%=strTemp%></td>
					</tr>
					<tr>
						<td height="20" colspan="2">&nbsp;</td>
					</tr>					
				</table></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="2">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td width="49%">
							<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
								<tr>
									<td width="40%">Requesting Physician:</td>
									<td width="60%" class="thinborderBOTTOM"><%=WI.getStrValue((String)vRetResult.elementAt(2), "&nbsp;")%></td>
								</tr>
							</table>						</td>
						<td width="2%">&nbsp;</td>
						<td width="49%">
							<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
								<tr>
									<td width="25%" align="right">Diagnosis:&nbsp;</td>
									<td width="75%" class="thinborderBOTTOM">
										<%=WI.getStrValue((String)vRetResult.elementAt(1), "&nbsp;")%></td>
								</tr>
							</table></td>
					</tr>
				</table>			</td>
	    </tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="2">Requested Examination/s:</td>
		</tr>
		<tr>
			<td height="20" colspan="2" class="thinborderBOTTOM"><%=WI.getStrValue((String)vRetResult.elementAt(3), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="2">Note: Please attach official laboratory request</td>
		</tr>
		<tr>
		  	<td colspan="2">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
					<td height="20" width="45%">&nbsp;</td>
					<td width="20%">&nbsp;</td>
					<td width="35%">&nbsp;</td>
				    <tr>
				      <td height="20" class="thinborderBOTTOM">&nbsp;</td>
				      <td>&nbsp;</td>
				      <td>&nbsp;</td>
		            <tr>
		              <td height="20" align="center">Patient/Guardian&rsquo;s Signature over Printed Name</td>
		              <td>&nbsp;</td>
		              <td>&nbsp;</td>
                </table>
		  	</td>
	  </tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="2">Verified by: </td>
			<td colspan="2">Authorized by: </td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" width="25%" class="thinborderBOTTOM"><%=((String)request.getSession(false).getAttribute("first_name")).toUpperCase()%></td>
			<td width="35%">&nbsp;</td>
			<td width="25%" class="thinborderBOTTOM">&nbsp;VINCENT P. SARMIENTO, M.D.</td>
			<td width="15%">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" colspan="2">Nurse, University Health Services</td>
			<td colspan="2">Director, University Health Services</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="2"><font style="font-size:10px">AUF-Form-UHS-11 </td>

		</tr>
		<tr>
			<td height="15" colspan="2"><font style="font-size:10px">June 1, 2007-Rev.00 </td>

		</tr>
	</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>