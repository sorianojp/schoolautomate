<%@ page language="java" import="utility.*,Accounting.Budget,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Budget Flow</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function ReloadPage(){
		document.form_.view_budget_flow.value = "";
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
	
	function ViewBudgetFlow(){		
		document.form_.view_budget_flow.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPg(){
		if(document.form_.budget_period.value.length == 0){
			alert("Please provide budget period information.");
			return;
		}		
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./budget_flow_print.jsp" />
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
								"ACCOUNTING-BUDGET","budget_flow.jsp");
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
	
	Vector vTemp = null;
	Vector vRetResult = null;
	Budget budget = new Budget();	
	
	String strCollegeIndex = WI.fillTextValue("c_index");
	String strFiscalYear = WI.fillTextValue("year");
	if(strFiscalYear.length() == 0){
		strFiscalYear = budget.getCurrentFiscalYear(dbOP, request);
		strFiscalYear = WI.getStrValue(strFiscalYear, "");
	}
	
	if(WI.fillTextValue("view_budget_flow").length() > 0){
		vRetResult = budget.viewBudgetFlow(dbOP, request);
		if(vRetResult == null)
			strErrMsg = budget.getErrMsg();
	}
	
	Vector vAuthLevels = budget.operateOnAuthLevel(dbOP, request, 4);
	if(vAuthLevels == null){
		strErrMsg = budget.getErrMsg();
		vRetResult = null;
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./budget_flow.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: BUDGET FLOW ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Fiscal Year: </td>
			<td width="80%">
				<%
					strFiscalYear = WI.getStrValue(strFiscalYear, "-1");
				%>
				<select name="year" size="1" id="year" onChange="ReloadPage();">
					<option value="-1">Select fiscal year</option>
					<%=dbOP.loadComboYear(strFiscalYear, 1, 3)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Budget Period: </td>
			<td>
				<%
					strTemp = 
						" from ac_budget_period where is_valid = 1 "+
						" and fiscal_year = "+strFiscalYear;
				%>
				<select name="budget_period">
          			<option value="">Select budget period</option>
          			<%=dbOP.loadCombo("budget_period_index","period_name", strTemp, WI.fillTextValue("budget_period"),false)%> 
        		</select></td>
		</tr>
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
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:ViewBudgetFlow();"><img src="../../../images/view.gif" border="0"></a>
				<font size="1">Click to view budget flow.</font></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
				<font size="1">Click to print budget flow.</font></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="<%=(vAuthLevels.size()/5)+5%>" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF EXPENSES APPROVED BUDGET ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="21%" align="center" class="thinborder"><strong>Expense Name</strong></td>
			<td width="12%" align="center" class="thinborder"><strong><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/<br>Department</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Timetable</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Proposed<br>Budget</strong></td>
		<%for(int i = 0; i < vAuthLevels.size(); i += 5){%>
			<td width="<%=40/(vAuthLevels.size()/5)%>%" align="center" class="thinborder"><strong><%=(String)vAuthLevels.elementAt(i+1)%></strong></td>
		<%}%>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 8, iCount++){
			vTemp = (Vector)vRetResult.elementAt(i+5);
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">
				<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "ALL")%>/<br>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+7), "ALL")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%>-<br><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		<%for(int j = 0; j < vTemp.size(); j += 2){
			if((String)vTemp.elementAt(j) == null)
				strTemp = "&nbsp;";
			else
				strTemp = CommonUtil.formatFloat((String)vTemp.elementAt(j), false);
		%>
			<td class="thinborder"><%=strTemp%></td>
		<%}%>
		</tr>
	<%}%>
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
	
	<input type="hidden" name="view_budget_flow">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>