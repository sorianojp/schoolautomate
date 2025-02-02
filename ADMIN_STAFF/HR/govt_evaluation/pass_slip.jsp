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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
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
	
	GovtEvaluation eval = new GovtEvaluation();
	
	enrollment.Authentication authentication = new enrollment.Authentication();
	Vector vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
	
	if(vEmpRec != null && vEmpRec.size() > 0){%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15" align="center">Republic of the Philipines </td>
		</tr>
		<tr>
			<td height="15" align="center">Region X </td>
		</tr>
		<tr>
		  	<td height="15" align="center">PROVINCE OF LANAO DEL NORTE </td>
	  	</tr>
		<tr>
		  	<td height="15" align="center">Gov. A. A. Quibranza Provincial Government Center </td>
	  	</tr>
		<tr>
		  	<td height="15" align="center">Pigcarangan, Tubod, Lanao del Norte </td>
		</tr>
		<tr>
		  	<td height="20" align="center"><strong>OFFICE OF THE PROVINCIAL ADMINSTRATOR </strong></td>
	  	</tr>
		<tr>
		  	<td height="20" align="center"><strong>PASS SLIP </strong></td>
	  	</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td width="90%">
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20" width="75%">&nbsp;</td>
						<td width="25%" align="center" class="thinborderBOTTOM">&nbsp;</td>
					</tr>
					<tr>
						<td height="20">&nbsp;</td>
						<td align="center" valign="top">Date</td>
					</tr>
				</table>
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20" width="10%">Name:</td>
						<td width="90%" class="thinborderBOTTOM">&nbsp;<%=WebInterface.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
					</tr>
				</table>
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20" width="10%">Position:</td>
						<td width="90%" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue((String)vEmpRec.elementAt(15))%></td>
					</tr>
				</table>
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20" width="10%">Destination:</td>
						<%
							if((String)vEmpRec.elementAt(13)== null || (String)vEmpRec.elementAt(14)== null)
								strTemp = " ";			
							else
								strTemp = " - ";
						%>
						<td width="90%" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue((String)vEmpRec.elementAt(13),"")%>
							<%=strTemp%>
							<%=WI.getStrValue((String)vEmpRec.elementAt(14),"")%></td>
					</tr>
				</table>
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20" width="10%">Purpose:</td>
						<td width="90%" class="thinborderBOTTOM">&nbsp;</td>
					</tr>
					<tr>
						<td height="20" colspan="2" class="thinborderBOTTOM">&nbsp;</td>
					</tr>
				</table>
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20" width="30%">Date/Time of Departure :</td>
						<td width="70%" class="thinborderBOTTOM">&nbsp;</td>
					</tr>
				</table>
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20" width="30%">Date/Time back to station/office: </td>
						<td width="70%" class="thinborderBOTTOM">&nbsp;</td>
					</tr>
					<tr>
					  	<td height="20" colspan="2">&nbsp;</td>
				  	</tr>
					<tr>
					  	<td height="20" colspan="2">APPROVED: (Pls. Check) </td>
				  	</tr>
					<tr>
					  	<td height="20" colspan="2">____________ Official </td>
				  	</tr>
					<tr>
					  	<td height="20" colspan="2">____________ Personal </td>
				  	</tr>
				</table>
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20" width="50%">&nbsp;</td>
						<td width="50%">&nbsp;</td>
					</tr>
					<tr>
						<td height="20" width="50%">&nbsp;</td>
						<td width="50%" class="thinborderBOTTOM">&nbsp;</td>
					</tr>
					<tr>
					  	<td height="20">&nbsp;</td>
					  	<td align="center">Signature of Employee </td>
				  	</tr>
					<tr>
					  	<td height="20" colspan="2">Approved:</td>
				  	</tr>
					<tr>
					  	<td height="20" colspan="2">&nbsp;</td>
				  	</tr>
				</table>
				<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td height="20" width="70%" align="center"><strong>EUGENE P. PUSING </strong></td>
						<td width="30%">&nbsp;</td>
					</tr>
					<tr>
					  <td height="20" align="center">Acting HRMO IV </td>
					  <td>&nbsp;</td>
				  </tr>
					<tr>
					  <td height="20" align="center">Signature of Head of Office </td>
					  <td>&nbsp;</td>
				  </tr>
				</table>
			</td>
			<td width="10%">&nbsp;</td>
		</tr>
	</table>
<%}%>
	
</body>
</html>
<%
dbOP.cleanUP();
%>