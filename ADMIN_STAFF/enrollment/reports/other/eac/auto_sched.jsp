<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript">	
	function PageAction(strAction) {		
		document.form_.page_action.value = strAction;
		if(strAction == '0') {
			if(confirm("Are you sure you want to delete this record?")){
				document.form_.page_action.value ='0';								
			}	
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
	if(strTemp.equals("1")) {
		EES.createAutoSched(dbOP, request);
		strErrMsg = EES.getErrMsg();
	}
	else {//check.. 
		String strSQLQuery = "select count(*) from EAC_EXAM_ASSIGNMENT where is_valid = 1 and SY_FROM = "+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester")+ 
							" and PMT_SCH_INDEX = "+WI.fillTextValue("pmt_schedule");
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery == null || strSQLQuery.equals("0")) 
			strErrMsg = "Schedule not created.";
		else {
			strErrMsg = "Total Schedule: "+strSQLQuery;
			strSQLQuery = "select count(*) from EAC_EXAM_ASSIGNMENT where is_valid = 1 and SY_FROM = "+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester")+ 
								" and PMT_SCH_INDEX = "+WI.fillTextValue("pmt_schedule")+" and ROOM_REF is null and is_valid = 1";
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null && !strSQLQuery.equals("0")) 
				strErrMsg += ". ROOMs not assigned : "+strSQLQuery+". Please manually create the schedules.";
			else
				strErrMsg += ". All rooms assigned. No Error found.";
		}
	}
}

vRetResult = EES.operateOnAllowedRoom(dbOP, request, 4);
%>
<body>
<form name="form_" method="post" action="auto_sched.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=5"></jsp:include>
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" size="2"><strong>:::: AUTO CREATE SCHEDULE PAGE ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="25" style="font-weight:bold; font-size:16px; color:#FF0000">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>	
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	<tr>
	  <td width="2%" height="25">&nbsp;</td>
	  <td width="17%" >SY From/Term </td>
	  <td width="81%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
			<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("oth_miscfee","sy_from","sy_to")'>
	  - 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%> <select name="semester">
   <option value="0">Summer</option>
<%
if(strTemp.compareTo("1") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.compareTo("2") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.compareTo("3") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
        </select>			
      <input type="button" name="chk_" value=" Check Schedule " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2');" />
		</td>
	</tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >Exam Name  </td>
	  <td ><select name="pmt_schedule" >
        <%=dbOP.loadCombo("pmt_sch_index","exam_name"," from fa_pmt_schedule where is_valid=1 order by exam_period_order", WI.fillTextValue("pmt_schedule"), false)%>
      </select></td>
	</tr>
		
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >
      <input type="button" name="update" value=" Create Schedule " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1');" />
      </td>
	  </tr>
  </table>
	<input type="hidden" name="page_action">
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

