<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTamiya" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Notice of Personnel Action</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
			"Admin/staff-HR Management-Personnel-Notice of Action","hr_personnel_notice_of_action_print.jsp");
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
	
	Vector vEmpRec = null;
	Vector vEditInfo = null;
	
	HRTamiya tamiya = new HRTamiya();	
	
	enrollment.Authentication authentication = new enrollment.Authentication();
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	vEditInfo = tamiya.operateOnPersonnelNotice(dbOP, request,3);		
%>
<body onLoad="window.print();">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="5" align="center">
				<strong><font size="2">NOTICE OF PERSONNEL ACTION</font></strong></td>
		</tr>
	</table>
	
<%if(vEmpRec != null && vEmpRec.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="20%" height="25"><font style="font-size:11px">Name of Employee: </font></td>
		    <td width="35%" class="thinborderBOTTOM"><font style="font-size:11px">
			  <%=WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></font></td>
		    <td width="5%">&nbsp;</td>
		    <td width="14%"><font style="font-size:11px">ID #: </font></td>
			<td width="20%" class="thinborderBOTTOM"><%=WI.fillTextValue("emp_id")%></td>
			<td width="6%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25"><font style="font-size:11px">Employment Status: </font></td>
			<td class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(16)%></td>
			<td>&nbsp;</td>
			<td><font style="font-size:11px">Date of Hiring: </font></td>
			<td class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(6)%></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25"><font style="font-size:11px">Division: </font></td>
			<td class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(13)%></td>
			<td>&nbsp;</td>
			<td><font style="font-size:11px">Group: </font></td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="6">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="20%" class="thinborderTOPLEFT">I. Nature of Action: </td>
			<td width="20%" align="center" class="thinborderTOPBOTTOM">
				<%if(Integer.parseInt((String)vEditInfo.elementAt(1)) > 0){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>&nbsp;<%}%></td>
			<td width="15%" class="thinborderTOP">Employment</td>
			<td width="5%" class="thinborderTOP">&nbsp;</td>
			<td align="center" class="thinborderTOPBOTTOM" width="14%">
				<%if(((String)vEditInfo.elementAt(1)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>&nbsp;<%}%></td>
		    <td width="26%" class="thinborderTOPRIGHT">Regular</td>
		</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td align="center" class="thinborderBOTTOM">
				<%if(((String)vEditInfo.elementAt(1)).equals("2")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>&nbsp;<%}%></td>
			<td class="thinborderRIGHT">Others</td>
	  	</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
		    <td align="center" class="thinborderBOTTOM">
				<%if(Integer.parseInt((String)vEditInfo.elementAt(2)) > 0){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>&nbsp;<%}%></td>
			<td><font style="font-size:11px">Promotion </font></td>
			<td>&nbsp;</td>
		    <td align="center" class="thinborderBOTTOM">
				<%if(Integer.parseInt((String)vEditInfo.elementAt(3)) > 0){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>&nbsp;<%}%></td>
		    <td class="thinborderRIGHT">Skill Level </td>
		</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
		    <td align="center" class="thinborderBOTTOM">
				<%if(((String)vEditInfo.elementAt(4)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>&nbsp;<%}%></td>
			<td><font style="font-size:11px">Demotion</font></td>
			<td colspan="3" class="thinborderRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
		    <td align="center" class="thinborderBOTTOM">
				<%if(Integer.parseInt((String)vEditInfo.elementAt(5)) > 0){%>
					<img src="../../../images/tick.gif" border="0">
				<%}else{%>&nbsp;<%}%></td>
			<td><font style="font-size:11px">Transfer</font></td>
			<td>&nbsp;</td>
		    <td align="center" class="thinborderBOTTOM">				
				<%if(((String)vEditInfo.elementAt(5)).equals("1")){%>
					<img src="../../../images/tick.gif" border="0">
			<%}else{%>&nbsp;<%}%></td>
		    <td class="thinborderRIGHT">Inter-division</td>
		</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
	      	<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		    <td align="center" class="thinborderBOTTOM">
				<%if(((String)vEditInfo.elementAt(5)).equals("2")){%>
					<img src="../../../images/tick.gif" border="0">
			<%}else{%>&nbsp;<%}%></td>
		    <td class="thinborderRIGHT">Inter-group</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="20%" class="thinborderLEFT">&nbsp;</td>
		    <td width="7%"><font style="font-size:11px">Others: </font></td>
		    <td width="28%" class="thinborderBOTTOM"><%=WI.getStrValue((String)vEditInfo.elementAt(6), "&nbsp;")%></td>
		    <td width="5%">&nbsp;</td>
		    <td width="8%"><font style="font-size:11px">Specify: </font></td>
		    <td width="26%" class="thinborderBOTTOM"><%=WI.getStrValue((String)vEditInfo.elementAt(7), "&nbsp;")%></td>
			<td width="6%" class="thinborderRIGHT">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="20%" class="thinborderLEFT">II. Date of Effectivity:  </td>
      	  <td width="35%" class="thinborderBOTTOM"><%=strTemp = (String)vEditInfo.elementAt(8)%></td>
			<td width="45%" class="thinborderRIGHT">&nbsp;</td>
	    </tr>
	</table>	
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="5" class="thinborderLEFTRIGHT">III.</td>
	    </tr>
		<tr>
			<td height="25" colspan="2" align="center" class="thinborderLEFT">&nbsp;</td>
		    <td align="center"><font style="font-size:11px">Current</font></td>
		    <td >&nbsp;</td>
	        <td align="center" class="thinborderRIGHT">New Status </td>
		</tr>
		<% 	
			String strCollegeIndex = WI.getStrValue((String)vEditInfo.elementAt(16), "");
		%>
		<tr>
			<td width="10%" height="25" class="thinborderLEFT">&nbsp;</td>
			<td width="20%"><font style="font-size:11px">Division</font></td>
			<td class="thinborderBOTTOM" width="30%"><%=WI.getStrValue((String)vEditInfo.elementAt(23), "&nbsp;")%></td>
		  	<td width="10%">&nbsp;</td>
		    <td width="30%" class="thinborderBOTTOMRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(27), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
			<td height="25"><font style="font-size:11px">Section</font></td>
			<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vEditInfo.elementAt(24), "&nbsp;")%></td>
			<td>&nbsp;</td>
	      	<td class="thinborderBOTTOMRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(28), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
			<td height="25"><font style="font-size:11px">Position</font></td>
			<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vEditInfo.elementAt(25), "&nbsp;")%></td>
			<td>&nbsp;</td>
		   	<td class="thinborderBOTTOMRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(29), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
			<td height="25"><font style="font-size:11px">Pay Class/Grade</font></td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td>&nbsp;</td>
		    <td class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
			<td height="25"><font style="font-size:11px">Salary</font></td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td>&nbsp;</td>
		    <td class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" class="thinborderLEFT">&nbsp;</td>
			<td height="25"><font style="font-size:11px">Allowance</font></td>
			<td class="thinborderBOTTOM">&nbsp;</td>
			<td>&nbsp;</td>
		    <td class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
	</table>
		
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
		<tr>
			<td height="25" class="thinborderLEFTRIGHT">IV. Reason for Action: </td>
	    </tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(21), "&nbsp;")%></td>
        </tr>
		<tr>
			<td height="25" class="thinborderLEFTRIGHT">V. Remarks or Other Conditions of this Personnel Action: </td>
	    </tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue((String)vEditInfo.elementAt(22), "&nbsp;")%></td>
        </tr>
		<tr>
			<td height="15" class="thinborderLEFTRIGHT"><hr size="1"></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="3" class="thinborderLEFTRIGHT">Recommended by: </td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOMLEFT">&nbsp;</td>
		    <td width="25%">&nbsp;</td>
		    <td width="25%" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" valign="top" class="thinborderLEFT">Immediate Supervisor</td>
			<td>&nbsp;</td>
			<td valign="top" class="thinborderRIGHT">Date</td>
		</tr>
		<tr>
			<td height="15" colspan="3" class="thinborderLEFTRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" class="thinborderLEFTRIGHT">Reviewed by: </td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOMLEFT">&nbsp;</td>
		    <td width="25%">&nbsp;</td>
		    <td width="25%" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" valign="top" class="thinborderLEFT">HR Supervisor</td>
			<td>&nbsp;</td>
			<td valign="top" class="thinborderRIGHT">Date</td>
		</tr>
		<tr>
			<td height="15" colspan="3" class="thinborderLEFTRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" class="thinborderLEFTRIGHT">Approved by: </td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOMLEFT">&nbsp;</td>
		    <td width="25%">&nbsp;</td>
		    <td width="25%" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" valign="top" class="thinborderLEFT">Managing Director-Prod'n. &amp; Mold Tooling </td>
			<td>&nbsp;</td>
			<td valign="top" class="thinborderRIGHT">Date</td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOMLEFT">&nbsp;</td>
		    <td width="25%">&nbsp;</td>
		    <td width="25%" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" valign="top" class="thinborderLEFT">Vice President </td>
			<td>&nbsp;</td>
			<td valign="top" class="thinborderRIGHT">Date</td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOMLEFT">&nbsp;</td>
		    <td width="25%">&nbsp;</td>
		    <td width="25%" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" valign="top" class="thinborderLEFT">Senior Vice President </td>
			<td>&nbsp;</td>
			<td valign="top" class="thinborderRIGHT">Date</td>
		</tr>
		<tr>
			<td height="25" colspan="3" class="thinborderLEFTRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" class="thinborderLEFTRIGHT">Conforme:</td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOMLEFT">&nbsp;</td>
		    <td width="25%">&nbsp;</td>
		    <td width="25%" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" valign="top" class="thinborderLEFT">Employee's Signature over Printed Name </td>
			<td>&nbsp;</td>
			<td valign="top" class="thinborderRIGHT">Date</td>
		</tr>
		<tr>
			<td height="15" colspan="3" class="thinborderLEFTRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" class="thinborderLEFTRIGHT">Noted by: </td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOMLEFT">&nbsp;</td>
		    <td width="25%">&nbsp;</td>
		    <td width="25%" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" valign="top" class="thinborderLEFT">Immediate Supervisor (of Receiving Section/Division) </td>
			<td>&nbsp;</td>
			<td valign="top" class="thinborderRIGHT">Date</td>
		</tr>
		<tr>
			<td height="15" colspan="3" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
		</tr>
	</table>
	<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>