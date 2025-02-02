<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript">	
	function PageAction(strAction, strInfoIndex) {		
		document.form_.page_action.value = strAction;
		if(strAction == '0') {
			if(confirm("Are you sure you want to delete this record?")){
				document.form_.page_action.value ='0';								
			}
			else
				return;
			document.form_.info_index.value = strInfoIndex;	
		}
		document.form_.submit();
	}

</script>
<%@ page language="java" import="utility.*,java.util.Vector, enrollment.EACExamSchedule" %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg  = null;
	String strTemp    = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation();
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
	

EACExamSchedule EES = new EACExamSchedule();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(EES.setSubectsForExam(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = EES.getErrMsg();
	else	
		strErrMsg = "Operation successful.";

}

vRetResult = EES.setSubectsForExam(dbOP, request, 4);
%>
<body>
<form name="form_" method="post" action="create_subject.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=3"></jsp:include>
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" size="2"><strong>:::: ASSIGN SUBJECT ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>	
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	
	<tr>
	  <td width="2%" height="25">&nbsp;</td>
	  <td width="12%" >Subject</td>
	  <td width="86%" >
	  <select name="sub_index" style="font-size:9px;">
        <%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where is_del=0 and not exists (select * from EAC_EXAM_SUBJECTS where SUB_INDEX = subject.sub_index and is_valid = 1) order by sub_code", WI.fillTextValue("sub_index"), false)%>
      </select></td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >To be paired with  </td>
	  <td >
	  <select name="paired_with" style="font-size:9px;">
	  	<option value=""></option>
        <%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where is_del=0 and exists (select * from EAC_EXAM_SUBJECTS where SUB_INDEX = subject.sub_index and PARENT_SUB_INDEX is null and is_valid = 1) order by sub_code", WI.fillTextValue("paired_with"), false)%>
      </select></td>
    </tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >
      	<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1');" />
	  	<font size="1">click to create schedule</font>      </td>
	  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
		<td style="font-weight:bold;" align="center" class="thinborderNONE">List of Subject Created for Scheduling </td>
	</tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr>
		<td width="35%" class="thinborder">Subject Code </td>
		<td width="54%" class="thinborder">Subject Name </td>
		<td width="11%" class="thinborder">Delete</td>
	</tr>
<%
for(int i =0; i < vRetResult.size(); i += 5) {
strTemp = "bgcolor='#cccccc'";
if(vRetResult.elementAt(i + 1) == null)
	strTemp = "";

%>
  	<tr <%=strTemp%>>
  	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
  	  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
  	  <td class="thinborder"><a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
<%}%>
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

