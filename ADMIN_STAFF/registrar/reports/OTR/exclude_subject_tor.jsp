<%@ page language="java" import="utility.*,enrollment.ReportRegistrar,java.util.Vector,java.util.Date " %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"), "");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student's Directory</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

	function checkAllSaveItems() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function checkAllSaveItems1() {
		var maxDisp = document.form_.item_count1.value;
		var bolIsSelAll = document.form_.selAllSaveItems1.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save1_'+i+'.checked='+bolIsSelAll);
	}
	
	function Exclude(){
		document.form_.exclude_subj.value = '1';
		document.form_.submit();
	}
	
	function Include(){
		document.form_.exclude_subj.value = '0';
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS","exclude_subject_tor.jsp");
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
															"Registrar Management","REPORTS",request.getRemoteAddr(),
															"exclude_subject_tor.jsp");
	
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_home_button_content.htm");
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
	
	Vector vListExcluded = new Vector();
	ReportRegistrar reportRegistrar = new ReportRegistrar();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(reportRegistrar.operateOnExcludedSubjectTOR(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = reportRegistrar.getErrMsg();
		else	
			strErrMsg = "Operation Successful.";
	}
	
	vListExcluded = reportRegistrar.operateOnExcludedSubjectTOR(dbOP, request, 4);

%>
<body bgcolor="#D2AE72">
<form name="form_" action="./exclude_subject_tor.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">	
			<td width="100%" colspan="2" height="25" bgcolor="#A49A6A"><div align="center">
			<font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: EXCLUDE/INCLUDE SUBJECT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td class="thinborderNONE" height="25" width="2%">&nbsp;</td>
		<td class="thinborderNONE" width="6%">Subject</td>
		<td width="64%" class="thinborderNONE">
		<select name="sub_index" style="width:500px;">
	    	<%=dbOP.loadCombo("sub_index","sub_code,sub_name"," from subject where IS_DEL=0 and is_excluded_tor = 0 order by sub_code",WI.fillTextValue("sub_index"),false)%> 
		</select>

	  </td>
	    <td width="28%" class="thinborderNONE">
	      <input type="submit" name="add2" value="Add to Exclude List" onClick="document.form_.page_action.value='1'" style="font-size:11px; height:25px;border: 1px solid #FF0000;" />
	    </td>
	</tr>
</table>

<%if(vListExcluded != null && vListExcluded.size() > 0){%>	
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">	
	<tr><td height="25" align="center"><strong>LIST OF SUBJECT EXCLUDED TO TOR</strong></td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#CCCCCC">
		<td class="thinborder" height="25" width="15%">Subject Code</td>
		<td class="thinborder" width="50%">Subject Name</td>
		<td class="thinborder">Remove From List </td>
	</tr>
	<%
	for(int i = 0; i < vListExcluded.size(); i+=3){
	%>
		<tr>
			<td class="thinborder" height="25"><%=(String)vListExcluded.elementAt(i+1)%></td>		
			<td class="thinborder" height="25"><%=(String)vListExcluded.elementAt(i+2)%></td>		
			<td class="thinborder" height="25"><input type="submit" name="add" value="Remove From List" 
				onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=(String)vListExcluded.elementAt(i)%>'"
				style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></td>		
		</tr>
	<%}%>
</table>
<%}%>	


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">							
	<tr><td height="25">&nbsp;</td></tr>
    <tr bgcolor="#B8CDD1"><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>	
	<input type="hidden" name="info_index">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
