<%@ page language="java" import="utility.*, health.Dental, java.util.Vector " %>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Dental Record Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript" src="../../../jscript/common.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","dental_record_details.jsp");
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
															"dental_record_details.jsp");
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
	
	boolean bolIsDeciduous = false;
	Vector vToothPos = null;
	Dental dental = new Dental();	
	Vector vRetResult = dental.operateOnDentalRecord(dbOP, request, 5);
	if(vRetResult == null)
		strErrMsg = dental.getErrMsg();
%>
<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="./dental_record_details.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F"> 
			<td height="25" class="footerDynamic" colspan="3"><div align="center"><font color="#FFFFFF">
				<strong>:::: DENTAL RECORD DETAILS ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
	<%if(vRetResult != null && vRetResult.size() > 0){
		bolIsDeciduous = ((String)vRetResult.elementAt(5)).equals("1");
		vToothPos = (Vector)vRetResult.elementAt(6);
	%>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Exam Date: </td>
			<td width="80%"><%=(String)vRetResult.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Attending Dentist :</td>
		    <td><%=WI.getStrValue((String)vRetResult.elementAt(4))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Diagnosis:</td>
		    <td><%=WI.getStrValue((String)vRetResult.elementAt(2))%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Treatment Plan: </td>
		    <td><%=WI.getStrValue((String)vRetResult.elementAt(3))%></td>
		</tr>
	<%if(!bolIsDeciduous){%>
		<tr>
			<td colspan="3"><div align="center"><img src="../../../images/teeth/permanent_teeth.jpg"></div></td>
		</tr>
		<tr>
			<td colspan="3" height="15">&nbsp;</td>
		</tr>
		<td colspan="3">
			<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
				<tr>
					<td height="25" align="right" class="thinborder" width="6%">&nbsp;</td>
					<td align="center" class="thinborder" width="6%"><strong>8</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>7</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>6</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>5</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>4</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>3</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>2</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>1</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>1</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>2</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>3</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>4</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>5</strong></td>
					<td align="center" class="thinborder" width="6%"><strong>6</strong></td>
					<td align="center" class="thinborder" width="5%"><strong>7</strong></td>
					<td align="center" class="thinborder" width="5%"><strong>8</strong></td>
				</tr>
				<tr>
					<td height="25" align="right" class="thinborder">UPPER&nbsp;</td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("1")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">						
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("2")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("3")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("4")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("5")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("6")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("7")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("8")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("9")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("10")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("11")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("12")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("13")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("14")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("15")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("16")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
				</tr>
				<tr>
					<td height="25" align="right" class="thinborder">LOWER&nbsp;</td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("17")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("18")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("19")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("20")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("21")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("22")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("23")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("24")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("25")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("26")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("27")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("28")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("29")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("30")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("31")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
					<td align="center" class="thinborder">
						<%
							strTemp = "&nbsp;";
							if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("32")) {
								vToothPos.remove(0);
								strTemp = (String)vToothPos.remove(0);
							}
						%><%=strTemp%></td>
				</tr>
			</table>
		</td>
	<%}else{%>
		<tr>
			<td colspan="3"><div align="center"><img src="../../../images/teeth/deciduous_teeth.jpg"></div></td>
		</tr>
		<tr>
			<td colspan="3" height="15">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="3">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
					<tr>
						<td height="25" align="center" class="thinborder">&nbsp;</td>
						<td align="center" class="thinborder"><strong>E</strong></td>
						<td align="center" class="thinborder"><strong>D</strong></td>
						<td align="center" class="thinborder"><strong>C</strong></td>
						<td align="center" class="thinborder"><strong>B</strong></td>
						<td align="center" class="thinborder"><strong>A</strong></td>
						<td align="center" class="thinborder"><strong>A</strong></td>
						<td align="center" class="thinborder"><strong>B</strong></td>
						<td align="center" class="thinborder"><strong>C</strong></td>
						<td align="center" class="thinborder"><strong>D</strong></td>
						<td align="center" class="thinborder"><strong>E</strong></td>
					</tr>
					<tr>
						<td width="10%" height="25" align="right" class="thinborder">UPPER&nbsp;&nbsp;&nbsp; </td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("1")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("2")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("3")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("4")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("5")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("6")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("7")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("8")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("9")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td width="9%" align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("10")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
					</tr>
					<tr>
						<td height="25" align="right" class="thinborder">LOWER&nbsp;&nbsp;&nbsp;</td>
						<td align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("11")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("12")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("13")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("14")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("15")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("16")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("17")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("18")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td align="center" class="thinborder">						
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("19")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
						<td align="center" class="thinborder">
							<%
								strTemp = "&nbsp;";
								if(vToothPos != null && vToothPos.size() > 0 && vToothPos.elementAt(0).equals("20")) {
									vToothPos.remove(0);
									strTemp = (String)vToothPos.remove(0);
								}
							%><%=strTemp%></td>
					</tr>
				</table>
			</td>
		</tr>
	<%}%>
	<%}%>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="dental_record_index" value="<%=WI.fillTextValue("dental_record_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>