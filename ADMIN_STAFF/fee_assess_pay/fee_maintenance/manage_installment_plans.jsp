<%@ page language="java" import="utility.*,enrollment.FAStudMinReqDP, java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Staff Position</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to remove this plan information?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function FocusField(){
		if(document.form_.plan_name)
			document.form_.plan_name.focus();
	}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments-FEE MAINTENANCE".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments".toUpperCase()),"0"));
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
		dbOP = new DBOperation();
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
	
	FAStudMinReqDP faMinDP = new FAStudMinReqDP(dbOP);
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(faMinDP.operateOnFatimaPlan(dbOP, request, Integer.parseInt(strTemp))  == null)
			strErrMsg = faMinDP.getErrMsg();
		else	
			strErrMsg ="Operation Successful.";
	}
		
	vRetResult = faMinDP.operateOnFatimaPlan(dbOP, request, 4);
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./manage_installment_plans.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: PLAN MANAGEMENT PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Plan Name: </td>
			<td colspan="2">
				<input name="plan_name" type="text" class="textbox" size="75"  
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("plan_name")%>"
					onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Installment Amount: </td>
		  <td width="25%"><input name="install_fee" type="text" class="textbox" size="5" maxlength="4"
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("install_fee")%>"
					onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','install_fee')"></td>
		  <td width="55%" valign="top">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Prelim %ge </td>
		  <td><input name="prelim" type="text" class="textbox" size="2" maxlength="2"
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("prelim")%>"
					onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','prelim')"></td>
		  <td valign="top">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Midterm %ge </td>
		  <td><input name="mterm" type="text" class="textbox" size="2" maxlength="2"
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("mterm")%>"
					onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','mterm')"></td>
		  <td valign="top">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Finals %ge </td>
		  <td><input name="final" type="text" class="textbox" size="2" maxlength="2"
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("final")%>"
					onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','final')"></td>
		  <td valign="top">&nbsp;</td>
	  </tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save plan information..</font>
					&nbsp;
				    <%}else{%>
					Not authorized.
				<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: PLANS AVAILABLE ::: </strong></div></td>
		</tr>
		<tr>
			<td width="50%" height="25" align="center" class="thinborder"><strong>PLAN NAME </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>INSTALLMENT FEE </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>PRELIM </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>MIDTERM</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>FINALS</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
	<%
		for(int i = 0; i < vRetResult.size(); i += 7){
		%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel == 2){%>					
					<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/delete.gif" border="0"></a>					
				<%}else{%>
					Not authorized.
				<%}%></td>
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
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>