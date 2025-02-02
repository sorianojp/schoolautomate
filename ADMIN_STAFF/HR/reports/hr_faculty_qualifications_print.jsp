<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoEducationExtn" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Qualifications</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	String strTemp = null;	
	String strErrMsg = null;	
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Awards",
								"hr_faculty_qualifications.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
												"HR Management","REPORTS AND STATISTICS",
												request.getRemoteAddr(),"hr_faculty_qualifications.jsp");
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

	String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};
	int[] iTotals =  new int[9];

	HRInfoEducationExtn hrEduExtn = new HRInfoEducationExtn();
	Vector vRetResult = hrEduExtn.getFacultyEducQualification(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hrEduExtn.getErrMsg();
		
	strTemp = "NTP";
	System.out.println(WI.fillTextValue("teaching_staff"));
	if(WI.fillTextValue("teaching_staff").equals("1"))
		strTemp = "FACULTY";
	if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="20" align="center"><strong><%=strTemp%> PROFILE BY EDUCATIONAL QUALIFICATIONS</strong></td>
		</tr>
		<tr>
			<td height="20" align="center">as of <%=astrSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> A.Y. <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
		</tr>
		<tr>
			<td height="20" align="center">&nbsp;</td>
		</tr>
	</table>
	
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong>UNIT</strong></td>
			<td height="20" colspan="2" align="center" class="thinborder"><strong>BS</strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>MA/MS/MD/L.l.B.</strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>Ph.D. / DD</strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>Total</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Total</strong></td>
		</tr>
		<tr>
			<td height="20" align="center" class="thinborder" width="10%"><strong>FT</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>PT</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>FT</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>PT</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>FT</strong></td>
		    <td align="center" class="thinborder "width="10%"><strong>PT</strong></td>
			<td align="center" class="thinborder" width="10%"><strong>FT</strong></td>
		    <td align="center" class="thinborder "width="10%"><strong>PT</strong></td>
		    <td align="center" class="thinborder"><strong>(per Unit) </strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 13){%>
		<tr>
			<%
				if((String)vRetResult.elementAt(i+1) != null && (String)vRetResult.elementAt(i+12) != null)
					strTemp = "/ ";
				else
					strTemp = "";
			%>
			<td height="20" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1))%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
				iTotals[0] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				iTotals[1] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+4);
				iTotals[2] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				iTotals[3] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+6);
				iTotals[4] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+7);
				iTotals[5] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+8);
				iTotals[6] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+9);
				iTotals[7] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+10);
				iTotals[8] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
		</tr>
	<%}%>
		<tr>
			<td height="20" class="thinborder">&nbsp;<strong>TOTAL</strong></td>
		    <td align="center" class="thinborder"><strong><%=iTotals[0]%></strong></td>
		    <td align="center" class="thinborder"><strong><%=iTotals[1]%></strong></td>
		    <td align="center" class="thinborder"><strong><%=iTotals[2]%></strong></td>
		    <td align="center" class="thinborder"><strong><%=iTotals[3]%></strong></td>
		    <td align="center" class="thinborder"><strong><%=iTotals[4]%></strong></td>
		    <td align="center" class="thinborder"><strong><%=iTotals[5]%></strong></td>
		    <td align="center" class="thinborder"><strong><%=iTotals[6]%></strong></td>
		    <td align="center" class="thinborder"><strong><%=iTotals[7]%></strong></td>
		    <td align="center" class="thinborder"><strong><%=iTotals[8]%></strong></td>
		</tr>
		<tr>
		  <td height="20" class="thinborder">&nbsp;</td>
		  <td colspan="2" align="center" class="thinborder"><strong><%=iTotals[0]+iTotals[1]%></strong></td>
		  <td colspan="2" align="center" class="thinborder"><strong><%=iTotals[2]+iTotals[3]%></strong></td>
		  <td colspan="2" align="center" class="thinborder"><strong><%=iTotals[4]+iTotals[5]%></strong></td>
		  <td colspan="2" align="center" class="thinborder"><strong><%=iTotals[6]+iTotals[7]%></strong></td>
		  <td align="center" class="thinborder"><strong><%=iTotals[8]%></strong></td>
	  </tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" width="35%"><font style="font-size:11px"><strong>Total Full Time Employees</strong></font></td>
		    <td width="10%"><font style="font-size:11px"><strong><%=iTotals[6]%></strong></font></td>
		    <td width="5%">&nbsp;</td>
		    <td width="35%"><font style="font-size:11px"><strong>Combined Full Time &amp; Part Time Employees</strong></font></td>
		    <td width="15%"><font style="font-size:11px"><strong><%=iTotals[8]%></strong></font></td>
		</tr>
		<tr>
			<td height="20"><font style="font-size:11px">Percentage of BS degree holder</font></td>
		    <td><font style="font-size:11px"><%=CommonUtil.formatFloat(((double)iTotals[0]/(double)iTotals[8])*100, true)%>%</font></td>
		    <td>&nbsp;</td>
		    <td><font style="font-size:11px">Percentage of BS degree holder</font></td>
		    <td><font style="font-size:11px"><%=CommonUtil.formatFloat((((double)iTotals[0]+(double)iTotals[1])/(double)iTotals[8])*100, true)%>%</font></td>
		</tr>
		<tr>
		  <td height="20"><font style="font-size:11px">Percentage of MA/MS/MD/ Ll.B degree holder </font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat(((double)iTotals[2]/(double)iTotals[8])*100, true)%>%</font></td>
		  <td>&nbsp;</td>
		  <td><font style="font-size:11px">Percentage of MA/MS/MD/ Ll.B degree holder </font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat((((double)iTotals[2]+(double)iTotals[3])/(double)iTotals[8])*100, true)%>%</font></td>
	  </tr>
		<tr>
		  <td height="20"><font style="font-size:11px">Percentage of Ph.D. degree holder</font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat(((double)iTotals[4]/(double)iTotals[8])*100, true)%>%</font></td>
		  <td>&nbsp;</td>
		  <td><font style="font-size:11px">Percentage of Ph.D. degree holder</font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat((((double)iTotals[4]+(double)iTotals[5])/(double)iTotals[8])*100, true)%>%</font></td>
	  </tr>
		<tr>
		  <td height="20"><font style="font-size:11px">Percentage of Combined MA/Ph.D. degree holder</font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat((((double)iTotals[2] + (double)iTotals[4])/(double)iTotals[8])*100, true)%>%</font></td>
		  <td>&nbsp;</td>
		  <td><font style="font-size:11px">Percentage of Combined MA/Ph.D. degree holder</font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat(((((double)iTotals[2]+(double)iTotals[3])/(double)iTotals[8])*100) + ((((double)iTotals[4]+(double)iTotals[5])/(double)iTotals[8])*100), true)%>%</font></td>
	  </tr>
		<tr>
		  <td height="20" colspan="5">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="20"><font style="font-size:11px"><strong>Total Part Time Employees</strong></font></td>
		  <td><font style="font-size:11px"><strong><%=iTotals[7]%></strong></font></td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
		  <td height="20"><font style="font-size:11px">Percentage of BS degree holder</font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat(((double)iTotals[1]/(double)iTotals[8])*100, true)%>%</font></td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
		  <td height="20"><font style="font-size:11px">Percentage of MA/MS/MD/ Ll.B degree holder </font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat(((double)iTotals[3]/(double)iTotals[8])*100, true)%>%</font></td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
		  <td height="20"><font style="font-size:11px">Percentage of Ph.D. degree holder</font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat(((double)iTotals[5]/(double)iTotals[8])*100, true)%>%</font></td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
		  <td height="20"><font style="font-size:11px">Percentage of Combined MA/Ph.D. degree holder</font></td>
		  <td><font style="font-size:11px"><%=CommonUtil.formatFloat((((double)iTotals[3] + (double)iTotals[5])/(double)iTotals[8])*100, true)%>%</font></td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
	</table>
<%}%>

</body>
</html>
<%
	dbOP.cleanUP();
%>