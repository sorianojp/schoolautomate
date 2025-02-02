<%@ page language="java" import="utility.*,Accounting.COASetting,java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COA Country Code Setup</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	
	function CancelOperation(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this country code?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","coa_setup_country_code.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.	
	
	int iMaxValue = 0;
	boolean bolAllowOp = true;
	Vector vSegmentSetup = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strCCDigits = null;
	COASetting coa = new COASetting();
	
	strTemp = WI.fillTextValue("page_action");
	vSegmentSetup = coa.operateOnSegmentSetup(dbOP, request, 4);
	if(vSegmentSetup == null){
		bolAllowOp = false;
		strErrMsg = coa.getErrMsg();
	}
	else{
		strCCDigits = (String)vSegmentSetup.elementAt(0);
		if(strCCDigits == null){
			bolAllowOp = false;
			strErrMsg = "Country code not applicable.";
		}
		else{
			if(strCCDigits.equals("1"))
				iMaxValue = 9;
			else
				iMaxValue = 99;
				
			bolAllowOp = true;
		}
		
		if(bolAllowOp){
			if(strTemp.length() > 0){
				if(coa.operateOnCountryCodeSetup(dbOP, request, Integer.parseInt(strTemp)) == null)
					strErrMsg = coa.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "Country code information successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "Country code information successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "Country code information successfully edited.";
					
					strPrepareToEdit = "0";
				}
			}
			
			vRetResult = coa.operateOnCountryCodeSetup(dbOP, request, 4);
			
			if(strPrepareToEdit.equals("1")){
				vEditInfo = coa.operateOnCountryCodeSetup(dbOP, request, 3);
				if(vEditInfo == null)
					strErrMsg = coa.getErrMsg();
			}
		}
	}
%>
<body bgcolor="#D2AE72">
<form action="./coa_setup_country_code.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF">
			  	<strong>:::: COUNTRY CODE SETUP ::::</strong></font></div></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Country: </td>
			<td width="80%">
			<%	if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(0);
				else
					strTemp = WI.fillTextValue("country");
					
				if(strTemp == null || strTemp.length() == 0)
					strTemp = dbOP.mapOneToOther("country","country_name","'" + "philippines" + "'","country_index","");
			%>
				<select name="country">
					<%=dbOP.loadCombo("COUNTRY_INDEX","COUNTRY_NAME"," FROM COUNTRY", strTemp, false)%> </select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Order in display: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("disp_order");
				%>				
				<select name="disp_order">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(strTemp,"1"));
				for(int i = 1; i <= iMaxValue ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	<%if(bolAllowOp){%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../../images/save.gif" border="0"></a>
				<%}else {
					if(vEditInfo!=null){%>
					<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../../images/edit.gif" border="0"></a>
					<%}
				}%>
				<a href="javascript:CancelOperation();"><img src="../../../../images/cancel.gif" border="0"></a>
			<%}else{%>
				Not authorized to add/modify coa country code setup.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	<%}%>
  	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<%for(int i = 0; i < vRetResult.size(); i += 4){%>
		<tr>
			<td height="25" class="thinborder" width="25%" align="center"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder" width="50%" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder" width="25%" align="center">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				Not authorized.
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>