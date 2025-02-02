<%
String strUserID = (String)request.getSession(false).getAttribute("userId");
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}

//if(!strUserID.toLowerCase().equals("sa-01")){%>
	<!--
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are not allowed to access this link.</p>
	-->
<%//return;}%>

<%@ page language="java" import="utility.*,sms.SystemSetup,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>ESC Allowed Year Level</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function PageAction(strPageAction, strInfoIndex) {
		if(strPageAction == '0'){
			if(!confirm("Are you sure you want to delete this year level?"))
				return;
		}
	
		document.form_.page_action.value = strPageAction;
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	try {
		dbOP = new DBOperation(strUserID,"SMS-Setting","esc_allowed_yrlevel.jsp");
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
	
	SystemSetup systemSetup = new SystemSetup();
	Vector vRetResult = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(systemSetup.operateOnAllowedYearLevel(dbOP, request, Integer.parseInt(strTemp)) == null) 
			strErrMsg = systemSetup.getErrMsg();
		else{
			if(strTemp.equals("1"))
				strErrMsg = "Grade level information recorded succssfully.";
			else if(strTemp.equals("0"))
				strErrMsg = "Grade level information removed successfully.";
		}
	}
	
	vRetResult = systemSetup.operateOnAllowedYearLevel(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = systemSetup.getErrMsg();
%>
<form action="./esc_allowed_yrlevel.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: COMPORT CONNECTED HAVING SIM ::::</strong></font></div></td>
		</tr>
	</table>
		
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Grade Level: </td>
			<td width="80%">
				<select name="year_level">
					<option value="">Select Grade Level</option>
					<%=dbOP.loadCombo("g_level","level_name"," from bed_level_info order by g_level", WI.fillTextValue("year_level"), false)%>
      			</select></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
				<font size="1">Click to save year level information.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	  
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">    
		<tr> 
			<td width="100%" height="20" colspan="2" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: ALLOWED YEAR LEVELS ::: </strong></div></td>
		</tr>
		<tr> 
			<td height="25" width="80%" align="center" class="thinborder"><strong>Grade Level</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
		<%for(int i=0; i<vRetResult.size(); i+=2){%>
		<tr> 
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
			<td align="center" class="thinborder"><a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
				<img src="../../../images/delete.gif" border="0"></a></td>
		</tr>
		<%}%>
	</table>
<%}%>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
			
	<input type="hidden" name="info_index">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>