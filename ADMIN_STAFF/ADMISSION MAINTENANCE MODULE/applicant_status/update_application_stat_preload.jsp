<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

function Edit(strInfoIndex) {
	var strNewStat = prompt('Please enter new application status.','');
	if(strNewStat == null || strNewStat.length == 0) {
		alert("Please enter value for application status.");
		return;
	}
	document.form_.appl_stat.value = strNewStat;
	document.form_.page_action.value = '2';
	document.form_.info_index.value = strInfoIndex;
	
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg = null;
	String strTemp = null;	
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
	
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%	return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();

int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","APPLICATION STATUS",request.getRemoteAddr(),
														"update_application_stat_preload.jsp");
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
ApplicationMgmt applMgmt = new ApplicationMgmt();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(applMgmt.operateOnApplicationStatPreload(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = applMgmt.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
vRetResult = applMgmt.operateOnApplicationStatPreload(dbOP, request, 4);
if(vRetResult == null) {
	if(strErrMsg == null)
		strErrMsg = applMgmt.getErrMsg();
}
%>
<form name="form_" action ="./update_application_stat_preload.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="91%" height="25" colspan="8" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          APPLICATION STATUS MANAGEMENT PAGE::::</font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="27%">Application Status </td>
      <td width="21%"> <input name="appl_stat" type="text" class="textbox" value="<%=WI.fillTextValue("appl_stat")%>" onfocus="style.backgroundColor='#D3EBFF'"	onblur='style.backgroundColor="white"' >      </td>
      <td width="49%"><a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="3" class="thinborder" align="center"><strong>List of Application Status</strong></td>
    </tr>
    
    <tr> 
      <td width="56%" height="25" class="thinborder"><div align="center"><strong>
	  <font size="1">Status Name </font></strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong><font size="1">Edit</font></strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><b><font size="1">Delete</font></b></div></td>
      <b> </b>    </tr>

<%for(int i = 0 ; i< vRetResult.size(); i += 2){%>
    <tr> 
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="center"><a href="javascript:Edit('<%=vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a></td>
      <td class="thinborder"><a href="javascript:PageAction(0,'<%=vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult != null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#B5AB73">
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" >
<input type="hidden" name="page_action" >

</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>