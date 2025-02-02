<%@ page language="java" import="utility.*,Accounting.BudgetReports,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Budget Status</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
	a{
		text-decoration:none
	}
</style>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function ReloadPage(){
		document.form_.view_budget_status.value = "";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPg(){
		if(document.form_.year.value.length == 0){
			alert("Please provide fiscal year information.");
			return;
		}
	
		document.form_.view_budget_status.value = "";
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
	function ViewBudgetStatus(){
		document.form_.view_budget_status.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		this.processRequest(strURL);
	}
	
	function ViewDetails(strBudgetSetupIndex, strYear, strBudgetPeriod){		
		var pgLoc = "./view_budget_details.jsp?budget_setup_index="+strBudgetSetupIndex+"&year="+strYear;
		if(strBudgetPeriod.length > 0)
			pgLoc += "&budget_period="+strBudgetPeriod;
		var win=window.open(pgLoc,"ViewDetails",'width=700,height=420,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./budget_status_print.jsp" />
	<% 
		return;}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
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
								"ACCOUNTING-BUDGET","budget_status.jsp");
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
	
	Vector vValues = null;
	Vector vRetResult = null;
	BudgetReports budgetReports = new BudgetReports();
	
	if(WI.fillTextValue("view_budget_status").length() > 0){
		vRetResult = budgetReports.generateBudgetStatusReport(dbOP, request);
		if(vRetResult == null)
			strErrMsg = budgetReports.getErrMsg();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./budget_status.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><strong>
				<font color="#FFFFFF">:::: BUDGET STATUS ::::</font></strong></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Fiscal Year: </td>
			<td width="80%">
				<%
					strTemp = WI.fillTextValue("year");
					if(strTemp.length() == 0)
						strTemp = "-1";
				%>
				<select name="year" size="1" id="year" onChange="ReloadPage();">
					<option value="-1">Select fiscal year</option>
					<%=dbOP.loadComboYear(strTemp, 1, 3)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Budget Period: </td>
			<td>
				<%
					strTemp = 
						" from ac_budget_period where is_valid = 1 "+
						" and fiscal_year = "+WI.getStrValue(WI.fillTextValue("year"), "-1");
				%>
				<select name="budget_period">
          			<option value="">All Budget Periods</option>
          			<%=dbOP.loadCombo("budget_period_index","period_name", strTemp, WI.fillTextValue("budget_period"),false)%> 
        		</select></td>
		</tr>
		<%
			String strCollegeIndex = WI.fillTextValue("c_index");
		%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>:</td>
			<td colspan="2">
				<select name="c_index" onChange="loadDept();">
          			<option value="0">ALL</option>
          			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        		</select></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department: </td>
			<td colspan="2">
				<label id="load_dept">
				<select name="d_index">
         			<option value="">ALL</option>
          		<%if ((strCollegeIndex.length() == 0) || strCollegeIndex.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
         		 <%}%>
  	   			</select>
				</label></td>
        </tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td valign="middle"><a href="javascript:ViewBudgetStatus();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to view budget flow.</font></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<%	for(int i = 0; i < vRetResult.size(); i += 5){
			vValues = (Vector)vRetResult.elementAt(i+4);
	%>
	<tr>
		<td height="25" class="thinborderLEFT" colspan="4"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>: 
			<%=WI.getStrValue((String)vRetResult.elementAt(i+2), "ALL")%></td>
	</tr>
	<tr>
		<td height="25" class="thinborderBOTTOMLEFT" colspan="4">Department: 
			<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "ALL")%></td>
	</tr>
	<tr>
		<td height="25" width="40%" align="center" class="thinborder">EXPENSE NAME</td>
		<td width="20%" align="center" class="thinborder">APPROVED BUDGET </td>
		<td width="20%" align="center" class="thinborder">USED BUDGET </td>
		<td width="20%" align="center" class="thinborder">BALANCE</td>
	</tr>
	<%for(int j = 0; j < vValues.size(); j += 5){%>
	<tr>
		<td height="25" class="thinborder"><%=(String)vValues.elementAt(j+1)%></td>
		<td class="thinborder"><%=CommonUtil.formatFloat((String)vValues.elementAt(j+2), false)%></td>
		<td class="thinborder">
			<%if((String)vValues.elementAt(j+3) == null){%>
				&nbsp;
			<%}else{%>
				<a href="javascript:ViewDetails('<%=(String)vValues.elementAt(j)%>', '<%=WI.fillTextValue("year")%>', '<%=WI.fillTextValue("budget_period")%>');"><%=(String)vValues.elementAt(j+3)%></a>
			<%}%>
		</td>
		<td class="thinborder"><%=WI.getStrValue((String)vValues.elementAt(j+4), "&nbsp;")%></td>
	</tr>
	<%}}%>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a></td>
		</tr>
	</table>
<%}%>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="view_budget_status">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>