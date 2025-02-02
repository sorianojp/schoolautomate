<%@ page language="java" import="utility.*,health.HealthReport,java.util.Vector " %>
<%
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	//strColorScheme is never null. it has value always.
	
	boolean bolIsEdit = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null; String strTemp2 = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Health Examination Record","health_exam_entry.jsp");
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
															"Health Monitoring","Health Examination Record",request.getRemoteAddr(),
															"health_exam_entry.jsp");
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
Vector vRetResult = new Vector();
Vector vBasicInfo = new Vector();
Vector vEditInfo  = new Vector();

HealthReport HR = new HealthReport();


if(WI.fillTextValue("stud_id").length() > 0){
	vBasicInfo = HR.operateOnHealthRecord(dbOP, request, 5);
	if(vBasicInfo == null)
		strErrMsg = HR.getErrMsg();
	else{
		vEditInfo = HR.operateOnHealthRecord(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = HR.getErrMsg();
	}	
}%>

<body <%if(strErrMsg == null){%> onLoad="window.print();"<%}%>>
<%if(vBasicInfo != null && vBasicInfo.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="3" height="22">&nbsp;School Year: </td></tr>
	<tr>
		<td height="22">&nbsp;Student ID: <strong><%=WI.fillTextValue("stud_id")%></strong></td>
		<td>Name: <strong><%=vBasicInfo.elementAt(0)%></strong></td>
		<td>Course/Year: <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(4))%><%=WI.getStrValue((String)vBasicInfo.elementAt(5),"-","","")%></strong></td>
	</tr>
	<tr><td colspan="3">
		<table width="100%">
			<tr>
				<td height="22" width="8%">Address</td>
				<td><strong>
					<%=WI.getStrValue((String)vBasicInfo.elementAt(6))%> <%=WI.getStrValue((String)vBasicInfo.elementAt(7))%>
					<%=WI.getStrValue((String)vBasicInfo.elementAt(8))%> <%=WI.getStrValue((String)vBasicInfo.elementAt(9))%> 
					<%=WI.getStrValue((String)vBasicInfo.elementAt(10))%>
					</strong>
				</td>
			</tr>
		</table>
	</td></tr>
	<tr><td height="22">&nbsp;Birthdate: <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(13))%></strong></td>
		<td>Age: <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(1))%></strong></td></tr>
	<tr>
		<td height="22" colspan="2">&nbsp;Parent's Name: <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14))%></strong></td>
		<td>Phone Number: <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(15))%></strong></td>
	</tr>
	<tr><td colspan="3">
		<table width="100%">
			<tr>
				<td height="22" width="8%">Address</td>
				<td>
					<strong><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"&nbsp;")%></strong>
				</td>
			</tr>
		</table>
	</td></tr>
	<tr><td height="22" colspan="2">&nbsp;Person to contact in case of emergency: <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(17))%></strong></td>
	<td>Phone Number: <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(18))%></strong></td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="10"></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
	<tr>
		<td colspan="3" class="thinborder" height="25"><strong>Medical History</strong></td>
		<td align="center" width="7%" class="thinborder"><strong>YES</strong></td>
		<td align="center" width="7%" class="thinborder"><strong>NO</strong></td>
		<td align="center" class="thinborder"><strong>Remarks</strong></td>
	</tr>
	<tr>
		<td height="22" width="3%" class="thinborder">&nbsp;</td>
		<td colspan="2" class="thinborderBOTTOM">1. Presently Taking Medications:</td>
		<%		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td align="center" class="thinborder"><%=strErrMsg%></td>
		<%				
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		
		<td align="center" class="thinborder"><%=strErrMsg%></td>
		<%		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" colspan="5">2. Medical Condition:</td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td width="23%" class="thinborderBOTTOM">Asthma</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td align="center" class="thinborder"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td align="center" class="thinborder"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">HPN</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">DM</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(9);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">CHD</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(10);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">PTB</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(13);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Measles</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(14);			
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%			
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Chicken Pox</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(16);			
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%			
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(17);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">German Measles</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(18);	
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%	
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(19);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Others (pls specify)</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(20);				
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%				
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(21);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" colspan="5">3. Allergies:</td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborder" width="23%">Food</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(22);			
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(23);
		%>
		<td><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Drug</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(24);				
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%				
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(25);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>	
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" colspan="5">4. Immunizations:</td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">BCG</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(26);		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%				
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(27);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">DPT</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(28);				
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%				
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(29);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Polio</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(30);				
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%				
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(31);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Hepa A</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(32);			
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%				
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(33);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Hepa B</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(34);				
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%				
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(35);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Measles</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(36);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(37);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Typhoid Fever</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(38);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(39);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Chicken Pox</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(40);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(41);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">HIB</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(42);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(43);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Mumps</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(44);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(45);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM" width="20%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="23%">Flu</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(46);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(47);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM">5. Past surgical operations:</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(48);
		%>
		<td class="thinborder" colspan="4"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM">6. Recent hospitalization:</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(49);
		%>
		<td class="thinborder" colspan="4"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="15"></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" colspan="2" height="25"><strong>Personal Habits</strong></td>
		<td class="thinborder" align="center" width="7%"><strong>YES</strong></td>
		<td class="thinborder" align="center" width="7%"><strong>NO</strong></td>
		<td class="thinborder" align="center"><strong>Remarks</strong></td>
	</tr>
	
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">1. Smoking</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(50);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(51);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">2. Alcohol</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(52);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(53);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">3. Non-Medical Drugs</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(54);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(55);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">4. Eating Disorders</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(56);		
		
		if(strTemp.equals("1"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(57);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>	
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="15"></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" colspan="4" height="25"><strong>Physical Examination</strong></td>		
	</tr>
	<tr>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(58);
		%>
		<td height="22" class="thinborder">Height: <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(59);
		%>
		<td height="22" class="thinborder">Weight: <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(60);
		%> 
		<td height="22" class="thinborder">Blood Pressure: <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(61);
		%>
		<td height="22" class="thinborder">Pulse: <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(62);
		%> 
		<td height="22" class="thinborder" colspan="2">RR: <%=WI.getStrValue(strTemp,"&nbsp;")%></td>		
	</tr>
	<tr>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(63);
		%>
		<td height="22" class="thinborder" colspan="3">Visual Acuity: Right: <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(64);
		%>
		<td height="22" class="thinborder" colspan="3" style="text-indent:88px;">Left: <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
</table>
<div style="page-break-after:always">&nbsp;</div>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="50">&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td  height="22"colspan="2" class="thinborder">&nbsp;</td>
		<td colspan="2" class="thinborderBOTTOM" align="center"><strong>Is Normal?</strong></td>
		<td align="center" class="thinborderBOTTOM">&nbsp;</td>
	</tr>
	<tr>
		<td height="22" colspan="2" class="thinborder">&nbsp;</td>
		<td class="thinborder" align="center" width="7%"><strong>YES</strong></td>
		<td class="thinborder" align="center" width="7%"><strong>NO</strong></td>
		<td class="thinborder" align="center"><strong>Remarks</strong></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">1. General Appearance</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(65);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(66);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">2. Skin</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(67);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>		
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(68);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">3. HEENT</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(69);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(70);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">4. Lungs</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(71);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(72);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">5. Heart</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(73);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(74);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">6. Abdomen</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(75);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(76);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">7. Musculoskeletal</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(77);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(78);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">8. Genitalia</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(79);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(80);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">9. Peripheral Pulses</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(81);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(82);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">10. Neurologic</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(83);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(84);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="3%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="43%">11. Mental Status</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(85);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(86);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="15"></td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
	<tr>
		<td class="thinborder" colspan="2" height="25"><strong>Laboratories/Diagnostic Test:</strong></td>
		<td class="thinborder" align="center" width="7%"><strong>YES</strong></td>
		<td class="thinborder" align="center" width="7%"><strong>NO</strong></td>
		<td class="thinborder" align="center"><strong>Remarks</strong></td>
	</tr>
	<tr>
		<td height="22" class="thinborder" width="5%">&nbsp;</td>
		<td class="thinborderBOTTOM" width="41%">CBC:</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(87);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(88);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM">U/A:</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(89);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(90);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM">F/E:</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(91);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(92);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM">HbS Antigen:</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(93);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(94);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM">X-Ray:</td>
		<%	
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(95);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(96);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr>
		<td height="22" class="thinborder">&nbsp;</td>
		<td class="thinborderBOTTOM">ECG:</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(97);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "<img src='../../../images/tick.gif' border='0'>";
		else
			strErrMsg = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strErrMsg%></td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(98);
		%>
		<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td height="30" colspan="6">&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="5%" height="35">&nbsp;</td>
		<td width="10%">Remarks : </td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(99);
		%>
		<td class="thinborderALL"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	<tr><td height="30" colspan="6">&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="22" width="5%">&nbsp;</td>
		<td width="15%">Examination Date</td>
		<%
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(1);			
		%>
		<td colspan="6"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>
	
	<tr>
		<td valign="bottom" height="40" width="5%">&nbsp;</td>
		<td valign="bottom" width="10%">Physician Name:</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(100);
		%>
	  	<td valign="bottom" width="40%"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
				
		<td valign="bottom" width="10%">License No.</td>
		<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(101);
		%>
		<td valign="bottom"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	</tr>


</table>





	







<%
}//end of vBasic not null%>






</body>
</html>
<%
dbOP.cleanUP();
%>
