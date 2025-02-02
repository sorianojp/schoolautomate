<%@ page language="java" import="utility.*,hr.HRLighthouse,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Pending Performance Evaluations</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
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
<script language="javascript" src="../../../jscript/td.js"></script>
<script language="javascript">
		
	function UpdatePerfEval(strEmpIndex, strRPIndex){
		document.form_.emp_evaluated.value = strEmpIndex;
		document.form_.rp_index.value = strRPIndex;
		document.form_.update_perf_eval.value = "1";
		document.form_.submit();
	}
	
	function GoBack(){
		location = "../../../ess/update_notifications.jsp?my_home=1";
	}
	
	function ViewFinalizedEvaluations(){
		document.form_.view_perf_eval.value = "0";
		document.form_.submit();
	}

	function ViewPendingEvaluations(){
		document.form_.view_perf_eval.value = "1";
		document.form_.submit();
	}
	
	function PopUpReport(strPEMI){
		var loadPg = "./evaluations_final_report.jsp?my_home=1&perf_eval_main_index="+strPEMI;
		var win=window.open(loadPg,"PopUpReport",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
		
</script>
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../index.jsp");
		
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
			"Admin/staff-HR Management-Performance Evaluation Management-Pending Perf Eval","pending_perf_evluations.jsp");
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
	
	Vector vRetResult = null;
	Vector vFinalizedEval = null;
	
	String strLocation = null;
	String strPerfEvalMainIndex = null;
	String[] astrMonth = {"January", "February", "March", "April", "May", "June", "July", 
							"August", "September", "October", "November", "December"};
	
	HRLighthouse hrl = new HRLighthouse();
	
	if(WI.fillTextValue("update_perf_eval").length() > 0){
		strPerfEvalMainIndex = hrl.getPerfEvalMainIndex(dbOP, request);
		if(strPerfEvalMainIndex == null)
			strErrMsg = hrl.getErrMsg();
		else{%>
			<script language="javascript">
				location = "./update_perf_eval.jsp?my_home=1&perf_eval_main_index="+<%=strPerfEvalMainIndex%>;
			</script>
		<%}
	}
	
	strTemp = WI.getStrValue(WI.fillTextValue("view_perf_eval"), "1");
	if(strTemp.equals("1")){
		vRetResult = hrl.getPendingPerformanceEvaluations(dbOP, request);
		if(vRetResult == null)
			strErrMsg = hrl.getErrMsg();
	}
	else{
		vFinalizedEval = hrl.getSupervisorFinalizedEvaluations(dbOP, request);	
		if(vFinalizedEval == null)
			strErrMsg = hrl.getErrMsg();
	}
	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" action="./pending_perf_evaluations.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A" class="footerDynamic">
			<td height="25" colspan="2" align="center" bgcolor="#A49A6A" class="footerDynamic">
			<font color="#FFFFFF" ><strong>:::: PENDING PERFORMANCE EVALUATIONS ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25" width="80%">
				<%if(strTemp.equals("1")){%>
					<a href="javascript:ViewFinalizedEvaluations();">View Finalized Evaluations</a>
				<%}else{%>
					<a href="javascript:ViewPendingEvaluations();">View Pending Performance Evaluations</a>
				<%}%></td>
		    <td width="20%" align="right">
				<a href="javascript:GoBack()"><img src="../../../images/go_back.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		</tr>
	</table>
<%if(strTemp.equals("1")){
	if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="28" width="25%" align="center" class="thinborder"><strong>Review Period Title</strong></td>
			<td width="24%" align="center" class="thinborder"><strong>Employee Name</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Review Period</strong></td>
			<td width="16%" align="center" class="thinborder"><strong>Evaluation Date</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Update</strong></td>
		</tr>
		<%for(int i = 0; i < vRetResult.size(); i += 8){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%> - <%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">
				<%=astrMonth[Integer.parseInt((String)vRetResult.elementAt(i+6))]%> <%=(String)vRetResult.elementAt(i+7)%></td>
			<td align="center" class="thinborder">
				<a href="javascript:UpdatePerfEval('<%=(String)vRetResult.elementAt(i)%>', '<%=(String)vRetResult.elementAt(i+2)%>');">
					<img src="../../../images/update.gif" border="0"></a></td>
		</tr>
		<%}%>
	</table>
	<%}else{%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="95%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
		</tr>
	</table>
	<%}
}else{
	if(vFinalizedEval != null && vFinalizedEval.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="28" width="30%" align="center" class="thinborder"><strong>Review Period Title</strong></td>
			<td width="35%" align="center" class="thinborder"><strong>Employee Name</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Review Period</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>View</strong></td>
		</tr>
		<%for(int i = 0; i < vFinalizedEval.size(); i += 5){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vFinalizedEval.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vFinalizedEval.elementAt(i+4)%></td>
			<td class="thinborder"><%=(String)vFinalizedEval.elementAt(i+2)%> - <%=(String)vFinalizedEval.elementAt(i+3)%></td>
	  	  	<td align="center" class="thinborder">
				<a href="javascript:PopUpReport('<%=(String)vFinalizedEval.elementAt(i)%>')">
					<img src="../../../images/view.gif" border="0"></a></td>
		</tr>
		<%}%>
	</table>
	<%}else{%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="5%">&nbsp;</td>
			<td width="95%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
		</tr>
	</table>
	<%}
}%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A" class="footerDynamic"> 
			<td width="1%" height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="emp_evaluated">
	<input type="hidden" name="rp_index">
	<input type="hidden" name="update_perf_eval">
	<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="view_perf_eval" value="<%=WI.fillTextValue("view_perf_eval")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>