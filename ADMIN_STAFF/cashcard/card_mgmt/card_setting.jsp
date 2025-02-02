<%@ page language="java" import="utility.*,cashcard.CardManagement, java.util.Vector "%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Card Setting Page</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PageAction(strAction){
		document.form_.page_action.value = strAction;
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-CARD MANAGEMENT"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Card Management","card_setting.jsp");
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
	
	Vector vRetResult = null;
	
	CardManagement cm = new CardManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(cm.operateOnCardSetting(dbOP, request, Integer.parseInt(strTemp)) == null )
			strErrMsg = cm.getErrMsg();
		else {
			if(strTemp.equals("1"))
				strErrMsg = "Card setting successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Card setting successfully edited.";
		}
	}
	
	vRetResult = cm.operateOnCardSetting(dbOP, request, 4);
	if (vRetResult == null && strTemp.length() == 0)
		strErrMsg = cm.getErrMsg();
%>		
<body bgcolor="#D2AE72">
<form name="form_" action="./card_setting.jsp" method="post">

	<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" align="center">
				<font color="#FFFFFF"><strong>:::: CARD SETTING MANAGEMENT PAGE ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Fee Name:</td>
			<td width="80%">
				<%
					if(vRetResult != null && vRetResult.size() > 0) 
						strTemp = (String)vRetResult.elementAt(0);
					else	
						strTemp = WI.fillTextValue("fee_name");
				%>	  
				<select name="fee_name" style="font-size:11px; color:#0000FF">
					<%=dbOP.loadCombo("distinct FA_OTH_SCH_FEE.FEE_NAME","FA_OTH_SCH_FEE.FEE_NAME"," from FA_OTH_SCH_FEE where IS_VALID = 1 order by FA_OTH_SCH_FEE.FEE_NAME asc",strTemp, false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Max Usage/Day:</td>
			<td>
				<%
					if(vRetResult!= null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(1);//usage amount.
					else
						strTemp = WI.fillTextValue("max_usage_per_day");
						
					strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, true), ",", "");
					if(strTemp.equals("0"))
						strTemp = "";
				%>
				<input type="text" name="max_usage_per_day" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','max_usage_per_day');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','max_usage_per_day')" size="16" maxlength="16" 
					value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Alert Amount:</td>
			<td>
				<%
					if(vRetResult!= null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(2);//alert amount.
					else
						strTemp = WI.fillTextValue("alert_below");
						
					strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp, true), ",", "");
					if(strTemp.equals("0"))
						strTemp = "";
				%>
				<input type="text" name="alert_below" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="AllowOnlyFloat('form_','alert_below');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('form_','alert_below')" size="16" maxlength="16" 
					value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="40">&nbsp;</td>
			<td>&nbsp;</td>
			<td>
				<%if(vRetResult != null && vRetResult.size() > 0){%>
					<a href="javascript:PageAction('2')"><img src="../../../images/update.gif" border="0" /></a>
					<font size="1">Click to update card setting.</font>
				<%}else{%>
					<a href="javascript:PageAction('1')"><img src="../../../images/save.gif" border="0" /></a>
					<font size="1">Click to save card setting.</font>
				<%}%></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="3" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: CARD SETTING ::: </strong></div></td>
		</tr>
		<tr>  
			<td height="25" width="65%" align="center" class="thinborder"><strong>Fee Name</strong></td> 
			<td width="18%" align="center" class="thinborder"><strong>Max Usage/Day </strong></td> 
			<td width="17%" align="center" class="thinborder"><strong>Alert Amount </strong></td> 
		</tr>
		<tr>  
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(0)%></td> 
			<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(1), true)%></td> 
			<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(2), true)%></td> 
		</tr>
	</table>
<%}%>
			
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
		<tr bgcolor="#FFFFFF">
			<td height="25"></td>
		</tr> 
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="page_action">
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>