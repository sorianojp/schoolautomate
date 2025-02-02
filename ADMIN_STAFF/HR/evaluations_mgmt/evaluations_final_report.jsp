<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String strPerfEvalMainIndex = WI.fillTextValue("perf_eval_main_index");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Performance Evaluation</title>
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
	String strSelfEvalMainIndex = null;
	
	HRLighthouse hrl = new HRLighthouse();
	
	if(strPerfEvalMainIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Reference index is missing. Please try again.</p>
		<%return;
	}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO"),"0"));
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
	
	if (bolMyHome)
		iAccessLevel = 1;
	
	if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Performance Evaluation Management-Update Performance Evaluation","update_perf_eval.jsp");
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
	
	if(bolMyHome && !hrl.isAllowedToViewPage(dbOP, request, strPerfEvalMainIndex)){%>
		<p style="font-size:16px; color:#FF0000;"><strong>Not allowed to view evaluation.</strong></p>
		<%return;
	}
	
	if(strPerfEvalMainIndex.equals("null")){
		strPerfEvalMainIndex = hrl.getPerfEvalMainIndex(dbOP, request);
		if(strPerfEvalMainIndex == null)
			strErrMsg = hrl.getErrMsg();
	}
	
	strSelfEvalMainIndex = hrl.getCorrespondingSEMI(dbOP, request, strPerfEvalMainIndex);
	if(strSelfEvalMainIndex == null)
		hrl.getErrMsg();
	
	Vector vRetResult = null;
	Vector vEmployeeInformation = null;
	Vector vRatings = null;
	Vector vPersonalEvaluation = null;
	
	vEmployeeInformation = hrl.getEmpEvaluatedInfo(dbOP, request, strPerfEvalMainIndex);
	if(vEmployeeInformation == null)
		strErrMsg = hrl.getErrMsg();
	else{
		vRetResult = hrl.getAllQuestions(dbOP, request, "", strPerfEvalMainIndex);
		if(vRetResult == null)
			strErrMsg = hrl.getErrMsg();
			
		vRatings = hrl.getRatings(dbOP, request);
		if(vRatings == null)
			strErrMsg = hrl.getErrMsg();

		vPersonalEvaluation = hrl.getAllQuestions(dbOP, request, strSelfEvalMainIndex, "");
		if(vPersonalEvaluation == null)
			strErrMsg = hrl.getErrMsg();
	}
	
%>
<body bgcolor="#FFFFFF">
<form name="form_" action="./update_perf_eval.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="center"><strong>:::: EVALUATION REPORT ::::</strong></td>
		</tr>
	</table>

<%if(vEmployeeInformation != null && vEmployeeInformation.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" width="5%">&nbsp;</td>
		    <td width="10%">&nbsp;</td>
		    <td width="5%">&nbsp; </td>
		    <td width="12%">&nbsp;</td>
		    <td width="12%">&nbsp;</td>
		    <td width="38%">&nbsp;</td>
		    <td width="18%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td><strong><font style="font-size:11px">Employee: </font></strong></td>
		    <td colspan="4" class="thinborderBOTTOM"><%=(String)vEmployeeInformation.elementAt(0)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="3"><strong><font style="font-size:11px">Date of Performance Review: </font></strong></td>
		    <td colspan="2" class="thinborderBOTTOM"><%=(String)vEmployeeInformation.elementAt(1)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="2"><strong><font style="font-size:11px">Review Period: </font></strong></td>
		    <td colspan="3" class="thinborderBOTTOM">
				<%=(String)vEmployeeInformation.elementAt(2)%> - <%=(String)vEmployeeInformation.elementAt(3)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25" >&nbsp;</td>
		    <td colspan="4"><strong><font style="font-size:11px">Person Conducting Performance Review: </font></strong></td>
		    <td class="thinborderBOTTOM"><%=(String)vEmployeeInformation.elementAt(4)%></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="7">&nbsp;</td>
		</tr>
	</table>
<%}

Vector vTemp = null;
if(vPersonalEvaluation != null && vPersonalEvaluation.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="2"><hr size="1"></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vPersonalEvaluation.size(); i += 2){
		vTemp = (Vector)vPersonalEvaluation.elementAt(i+1);
	%>	
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="95%"><strong><u><%=WI.getStrValue((String)vPersonalEvaluation.elementAt(i), "EMPLOYEE SELF-EVALUATION")%></u></strong></td>
		</tr>
		<%for(int j = 0; j < vTemp.size(); j += 4, iCount++){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><strong><font style="font-size:11px"><%=iCount%>.) <%=(String)vTemp.elementAt(j+1)%></font></strong></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><font style="font-size:11px"><%=WI.getStrValue((String)vTemp.elementAt(j+2), "&nbsp;")%></font></td>
		</tr>
		<%}%>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
	<%}%>
		<tr>
			<td height="15" colspan="2"><hr size="1"></td>
		</tr>
	</table>
<%}

if(vRatings != null && vRatings.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="20" width="5%">&nbsp;</td>
			<td width="95%"><strong>Rating: </strong></td>
		</tr>
		<%for(int i = 0; i < vRatings.size(); i += 2){%>
		<tr>
			<td height="20">&nbsp;</td>
			<td><strong><font style="font-size:11px">
				<%=(String)vRatings.elementAt(i)%>=<%=(String)vRatings.elementAt(i+1)%></font></strong></td>
		</tr>
		<%}%>
		<tr>
			<td height="20" colspan="2">&nbsp;</td>
		</tr>
	</table>
<%}

int iCount = 1;
Vector vQuestions = null;
if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%for(int i = 0; i < vRetResult.size(); i += 2){
		vQuestions = (Vector)vRetResult.elementAt(i+1);
	%>	
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="95%"><strong><u><%=WI.getStrValue((String)vRetResult.elementAt(i))%></u></strong></td>
		</tr>
	<%		
	for(int j = 0; j < vQuestions.size(); j += 5, iCount++){
		strTemp = WI.getStrValue((String)vQuestions.elementAt(j+4), "1");
	%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><strong><font style="font-size:11px"><%=(String)vQuestions.elementAt(j+1)%></font></strong>&nbsp;			
				
				<%if(((String)vQuestions.elementAt(j+3)).equals("1")){%>					
					<font style="font-size:11px">(Rating: <%=strTemp%>)</font>
				<%}%>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><%=(String)vQuestions.elementAt(j+2)%></td>
		</tr>
		<%}%>
		<tr>
			<td height="15"colspan="2">&nbsp;</td>
		</tr>
	<%}%>
	</table>
<%}%>

	<input type="hidden" name="perf_eval_main_index" value="<%=strPerfEvalMainIndex%>">
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>