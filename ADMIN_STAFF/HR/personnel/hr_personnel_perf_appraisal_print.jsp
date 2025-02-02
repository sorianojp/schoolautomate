<%@ page language="java" import="utility.*,java.util.Vector,hr.HRTamiya" %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Performance Appraisal</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	String strInfoIndex = WI.fillTextValue("info_index");
	if(strInfoIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Reference reference is not found.</p>
		<%return;
	}
		
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
	
	if(bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Notice of Action","hr_personnel_perf_appraisal_print.jsp");
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
	String strSupervisor = null;
	
	double dTotalRating = 0;
	double dTotalWeight = 0;
	double dTemp = 0;
	
	HRTamiya tamiya = new HRTamiya();
	enrollment.Authentication authentication = new enrollment.Authentication();
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	vEditInfo = tamiya.operateOnPerfAppraisal(dbOP, request,3);		
	strSupervisor = tamiya.getSupervisorName(dbOP, request, (String)vEmpRec.elementAt(0));
%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="20" align="center">TAMIYA PHILIPPINES, INC.</td>
		</tr>
		<tr> 
			<td height="20" align="center">PERFORMANCE APPRAISAL FORM(Non-Supervisory/Non-Managerial Employees)</td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>

<%if(vEmpRec != null && vEmpRec.size() > 0){%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="8%" height="20"><font style="font-size:11px">Name:</font></td>
		    <td width="36%" class="thinborderBOTTOM"><%=WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
			<td width="4%">&nbsp;</td>
			<td width="8%"><font style="font-size:11px">ID No: </font></td>
			<td width="44%" class="thinborderBOTTOM"><%=WI.fillTextValue("emp_id")%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="15%"><font style="font-size:11px">Position Title: </font></td>
		    <td width="29%" class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(15)%></td>
			<td width="4%">&nbsp;</td>
		    <td width="10%"><font style="font-size:11px">Sec./Dept.</font></td>
		    <td width="42%" class="thinborderBOTTOM">
				<%
					if((String)vEmpRec.elementAt(11)== null || (String)vEmpRec.elementAt(12)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>      		
	   			<%=WI.getStrValue((String)vEmpRec.elementAt(13),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vEmpRec.elementAt(14),"")%></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="15%"><font style="font-size:11px">Date of Hiring: </font></td>
		    <td width="29%" class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(6)%></td>
			<td width="4%">&nbsp;</td>
		    <td width="20%"><font style="font-size:11px">Employment Status: </font></td>
		    <td width="32%" class="thinborderBOTTOM"><%=(String)vEmpRec.elementAt(16)%></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  	<td height="20" width="24%"><font style="font-size:11px">Appraisal Period Covered </font></td>
	     	<td width="20%" class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(1)%> - <%=(String)vEditInfo.elementAt(2)%></td>
			<td width="4%">&nbsp;</td>
	     	<td width="15%"><font style="font-size:11px">Date of Appraisal: </font></td>
	      	<td width="37%" class="thinborderBOTTOM"><%=(String)vEditInfo.elementAt(3)%></td>
	  	</tr>
		<tr>
			<td height="20"><font style="font-size:11px">Purpose of Appraisal:</font></td>
			<td colspan="4" class="thinborderBOTTOM">Performance Record</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  	<td height="15">&nbsp;</td>
      	</tr>
		<tr>
		  	<td ><div align="justify"><font style="font-size:11px">
				Instructions: Please rate the employee according to given scale. 
				Refer at the back of the page for the specific definition of scale and its equivalent rating.</font></div></td>
      	</tr>
		<tr>
			<td height="15">&nbsp;</td>
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
  	  	  <td height="15" colspan="2" class="thinborder">&nbsp;</td>
		  	<td align="center" class="thinborder">&nbsp;</td>
		  	<td align="center" class="thinborder">&nbsp;</td>
		  	<td align="center" class="thinborder">&nbsp;</td>
		  	<td class="thinborder">&nbsp;</td>
	  	</tr>
		<tr>
			<td height="25" width="3%" class="thinborderBOTTOMLEFT">1.) </td>
			<td width="27%" class="thinborderBOTTOM">Job Knowledge</td>
			<td width="10%" class="thinborder">&nbsp;20</td>
			<td width="10%" class="thinborder">&nbsp;<%=(String)vEditInfo.elementAt(4)%></td>
			<td width="10%" class="thinborder">
			<%
					dTotalRating += Double.parseDouble((String)vEditInfo.elementAt(4));
					dTemp = 20 * Double.parseDouble((String)vEditInfo.elementAt(4));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td width="40%" class="thinborder"><%=WI.getStrValue((String)vEditInfo.elementAt(9), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">2.) </td>
			<td class="thinborderBOTTOM">Quality of Work</td>
			<td class="thinborder">&nbsp;15</td>
			<td class="thinborder">&nbsp;<%=(String)vEditInfo.elementAt(5)%></td>
			<td class="thinborder">
			<%
					dTotalRating += Double.parseDouble((String)vEditInfo.elementAt(5));
					dTemp = 15 * Double.parseDouble((String)vEditInfo.elementAt(5));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vEditInfo.elementAt(10), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">3.) </td>
			<td class="thinborderBOTTOM">Quantity of Work</td>
			<td class="thinborder">&nbsp;15</td>
			<td class="thinborder">&nbsp;<%=(String)vEditInfo.elementAt(6)%></td>
			<td class="thinborder">
			<%
					dTotalRating += Double.parseDouble((String)vEditInfo.elementAt(6));
					dTemp = 15 * Double.parseDouble((String)vEditInfo.elementAt(6));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vEditInfo.elementAt(11), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">4.) </td>
			<td class="thinborderBOTTOM">Attendance</td>
			<td class="thinborder">&nbsp;30</td>
			<td class="thinborder">&nbsp;<%=(String)vEditInfo.elementAt(7)%></td>
			<td class="thinborder">
			<%
					dTotalRating += Double.parseDouble((String)vEditInfo.elementAt(7));
					dTemp = 30 * Double.parseDouble((String)vEditInfo.elementAt(7));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vEditInfo.elementAt(12), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborderBOTTOMLEFT">5.) </td>
			<td class="thinborderBOTTOM">Attitude Toward Work and the Company</td>
			<td class="thinborder">&nbsp;20</td>
			<td class="thinborder">&nbsp;<%=(String)vEditInfo.elementAt(8)%></td>
			<td class="thinborder">
			<%
					dTotalRating += Double.parseDouble((String)vEditInfo.elementAt(8));
					dTemp = 20 * Double.parseDouble((String)vEditInfo.elementAt(8));
					
					dTotalWeight += dTemp;
				%>&nbsp;<%=dTemp%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vEditInfo.elementAt(13), "&nbsp;")%></td>
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
			<td height="25"><font style="font-size:11px"><strong><u>Performance Summary</u></strong></font></td>
		</tr>
		<tr>
			<td height="25"><font style="font-size:11px">¤Strengths</font></td>
		</tr>
		<tr>
			<td><font style="font-size:11px">
				<div align="justify"><%=WI.getStrValue((String)vEditInfo.elementAt(14), "-")%></div></font></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25"><font style="font-size:11px">¤Continuous Improvement</font></td>
		</tr>
		<tr>
			<td><font style="font-size:11px">
				<div align="justify"><%=WI.getStrValue((String)vEditInfo.elementAt(15), "-")%></div></font></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25"><font style="font-size:11px">¤Additional Comments</font></td>
		</tr>
		<tr>
			<td><font style="font-size:11px">
				<div align="justify"><%=WI.getStrValue((String)vEditInfo.elementAt(16), "-")%></div></font></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25"><font style="font-size:11px"><strong><u>Career Development Plan </u></strong></font></td>
		</tr>
		<tr>
			<td height="25"><font style="font-size:11px">¤Development and Actions</font></td>
		</tr>
		<tr>
			<td><font style="font-size:11px">
				<div align="justify"><%=WI.getStrValue((String)vEditInfo.elementAt(17), "-")%></div></font></td>
		</tr>
		<tr>
			<td height="15" colspan="2">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="3"><font style="font-size:11px">Rated By: </font></td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOM"><%=WI.getStrValue(strSupervisor, "&nbsp;")%></td>
		    <td width="25%" align="right"><font style="font-size:11px">Date: &nbsp;</font></td>
		    <td width="25%" class="thinborderBOTTOM">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="3" valign="top"><font style="font-size:11px">Immediate Supervisor</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3"><font style="font-size:11px">Reviewed By: </font></td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOM">&nbsp;</td>
		    <td width="25%" align="right"><font style="font-size:11px">Date: &nbsp;</font></td>
		    <td width="25%" class="thinborderBOTTOM">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="3" valign="top"><font style="font-size:11px">(Second Level)Superior</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3"><font style="font-size:11px">Noted/Approved By: </font></td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOM">&nbsp;</td>
		    <td width="25%" align="right"><font style="font-size:11px">Date: &nbsp;</font></td>
		    <td width="25%" class="thinborderBOTTOM">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="3" valign="top"><font style="font-size:11px">Managing Director(s)/Vice Pres./SVP </font></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="4" class="thinborderTOPLEFTRIGHT">
				This is to confirm that the above rating was discussed and explained to me by my immediate supervisor. </td>
		</tr>
		<tr>
			<td height="30" class="thinborderLEFT" width="50%">&nbsp;</td>
		    <td width="20%">&nbsp;</td>
			<td width="25%" class="thinborderBOTTOM">&nbsp;</td>
		    <td width="5%" class="thinborderRIGHT">&nbsp;</td>
		</tr>
		<tr>
			<td height="30" colspan="2" valign="top" class="thinborderBOTTOMLEFT">&nbsp;</td>
		    <td valign="top" class="thinborderBOTTOM" align="center">Employee's Signature </td>
		    <td valign="top" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3"><font style="font-size:11px">Received By: </font></td>
		</tr>
		<tr>
			<td height="30" width="50%" class="thinborderBOTTOM"><%=WI.getStrValue(strSupervisor, "&nbsp;")%></td>
		    <td width="25%" align="right"><font style="font-size:11px">Date: &nbsp;</font></td>
		    <td width="25%" class="thinborderBOTTOM">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="3" valign="top"><font style="font-size:11px">Immediate Supervisor</font></td>
		</tr>
	</table>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>