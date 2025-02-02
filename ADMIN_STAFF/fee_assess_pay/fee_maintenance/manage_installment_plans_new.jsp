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
	
	Vector vRetResult = null; Vector vEditInfo = null; Vector vPmtSchDef = new Vector(); Vector vTemp = null;
	
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
	
	FAStudMinReqDP faMinDP = new FAStudMinReqDP(dbOP);
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(faMinDP.operateOnJoneltaPlan(dbOP, request, Integer.parseInt(strTemp))  == null)
			strErrMsg = faMinDP.getErrMsg();
		else	
			strErrMsg ="Operation Successful.";
	}
	
	vRetResult = faMinDP.operateOnJoneltaPlan(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		faMinDP.getErrMsg();
	
	
	
	
	
	if(strPreparedToEdit.equals("1")) 
		vEditInfo = faMinDP.operateOnJoneltaPlan(dbOP, request, 3);
		
String strSQLQuery = "select pmt_sch_index, exam_name from fa_pmt_schedule where is_valid = 1 order by exam_period_order";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
  vPmtSchDef.addElement(rs.getString(1));//[0] pmt_sch_index
  vPmtSchDef.addElement(rs.getString(2));//[1] exam_name
}
rs.close();
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./manage_installment_plans_new.jsp" method="post">
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
		  <td>Reqd. DP %ge </td>
		  <td width="25%"><input name="reqd_dp_percent" type="text" class="textbox" size="2" maxlength="2"
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("reqd_dp_percent")%>"
					onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','reqd_dp_percent')"></td>
		  <td width="55%" valign="top">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Reqd. DP Amount </td>
		  <td><input name="reqd_dp_amt" type="text" class="textbox" size="5" maxlength="5"
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("reqd_dp_amt")%>"
					onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','reqd_dp_amt')"></td>
		  <td valign="top">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td><strong>Installment Payments</strong></td>
		  <td>&nbsp;</td>
		  <td valign="top">&nbsp;</td>
	  </tr>
<%
int iMaxDisp = 0;
for(int i = 0; i < vPmtSchDef.size(); i += 2) {%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td><%=vPmtSchDef.elementAt(i + 1)%> %
		  <input type="hidden" name="pmt_sch_<%=iMaxDisp%>" value="<%=vPmtSchDef.elementAt(i)%>">
		  </td>
		  <td>
		  <input type="text" name="percent_<%=iMaxDisp++%>" class="textbox" size="5" maxlength="5"
					onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("percent_"+(iMaxDisp -1))%>"
					onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyFloat('form_','percent_<%=iMaxDisp - 1%>')">
		  </td>
		  <td valign="top">&nbsp;</td>
	  </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
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
		  	<td height="20" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: PLANS AVAILABLE ::: </strong></div></td>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td width="30%" height="25" align="center" class="thinborder"><strong>PLAN NAME </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Reqd Down </strong></td>
			<%for(int i = 0; i < vPmtSchDef.size(); i += 2) {%>
				<td width="10%" align="center" class="thinborder"><strong>
					<%=vPmtSchDef.elementAt(i + 1)%> %
			 	</strong></td>
			<%}%>
			<td width="10%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
		<%
		int iIndexOf = 0;
		for(int i = 0; i < vRetResult.size(); i += 5){
			vTemp = (Vector)vRetResult.elementAt(i + 4);
			
			strTemp = (String)vRetResult.elementAt(i+2);
			if(strTemp != null)
				strTemp = strTemp + " %";
			else	
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true);
		%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
			<%for(int p = 0; p < vPmtSchDef.size(); p += 2) {
			iIndexOf = vTemp.indexOf(vPmtSchDef.elementAt(p));
			if(iIndexOf == -1) 
				strTemp = "&nbsp;";
			else
				strTemp = vTemp.elementAt(iIndexOf + 2)+" %";
			%>
			<td class="thinborder">&nbsp;
				<%=strTemp%>
			</td>
			<%}%>
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