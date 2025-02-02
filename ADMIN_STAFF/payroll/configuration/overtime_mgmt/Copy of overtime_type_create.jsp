<%@ page language="java" import="utility.*,java.util.Vector,payroll.OvertimeMgmt" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script>
<!--

function PageAction(strAction, strInfoIndex, strCode) {
	if(strAction== 0){
		var vProceed = confirm('Delete '+strCode+' ?');
		if(!vProceed){			
			return;
		}
	}
	
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.submit();
}

function PrepareToEdit(strIndex){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}

function CancelRecord(){
	location = "./overtime_type_create.jsp";
}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit = null;
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-configuration-OT Rate","overtime_type_create.jsp");
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
Vector vEditInfo= null;
OvertimeMgmt OTMgmt = new OvertimeMgmt();
String[] astrRateType = {"%","Flat Rate", "Specific Rate"};
String[] astrOption = {"Regular","Rest Day"};

String strPageAction = WI.fillTextValue("page_action");
strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strCheck = null;

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (OTMgmt.operateOnOvertimeType(dbOP,request,0) != null){
			strErrMsg = " OT Type removed successfully ";
		}else{
			strErrMsg = OTMgmt.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (OTMgmt.operateOnOvertimeType(dbOP,request,1) != null){
			strErrMsg = " OT Type posted successfully ";
		}else{
			strErrMsg = OTMgmt.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (OTMgmt.operateOnOvertimeType(dbOP,request,2) != null){
			strErrMsg = " OT Type updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = OTMgmt.getErrMsg();
		}
	}
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = OTMgmt.operateOnOvertimeType(dbOP,request,3);

	if (vEditInfo == null)
		strErrMsg = OTMgmt.getErrMsg();	
}

vRetResult  = OTMgmt.operateOnOvertimeType(dbOP,request,4);
%>
<form action="overtime_type_create.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL - CONFIGURATION - OVERTIME TYPE MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25"><font size=3><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Overtime Type Code : </td>
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(1);
					else 
						strTemp = WI.fillTextValue("code"); 				
			%>
      <td height="26" valign="bottom"> 
			<input name="code" type="text" size="16" maxlength="16" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td width="34" height="26">&nbsp;&nbsp;<div align="center"></div></td>
      <td width="148">Overtime Type Name:</td>
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(2);
					else 
						strTemp = WI.fillTextValue("name"); 				
			%>			
      <td width="570" height="26">
			<input name="name" type="text" size="64" maxlength="64" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Overtime Type Rate :</td>
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(3);
					else 
						strTemp = WI.fillTextValue("rate"); 				
			%>			
      <td height="26">
			<input name="rate" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyFloat('form_','rate')" value="<%=strTemp%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','rate')">
        <select name="rate_type">
          <option value="0">Percentage</option>
          <%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(4);
					else 
						strTemp = WI.fillTextValue("rate_type"); 
						
						if (strTemp.compareTo("1") == 0) {
					%>
          <option value="1" selected>Specific Amount</option>
          <%}else{%>
          <option value="1">Specific Amount</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Option</td>
      <td height="26">
			<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		else	
			strTemp = WI.fillTextValue("is_restday");
		strTemp = WI.getStrValue(strTemp,"0");
		if(strTemp.compareTo("0") == 0) 
			strCheck = " checked";
		else	
			strCheck = "";	
	  %>
        <input type="radio" name="is_restday" value="0"<%=strCheck%>>
        For Regular days 
        <%
		if(strTemp.compareTo("1") == 0) 
			strCheck = " checked";
		else
			strCheck = "";
		%>
<input type="radio" name="is_restday" value="1"<%=strCheck%>>
For Rest Days</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
			<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		else	
			strTemp = WI.fillTextValue("night_diff");
		strTemp = WI.getStrValue(strTemp,"0");
		
		if(strTemp.compareTo("1") == 0) 
			strCheck = " checked";
		else	
			strCheck = "";	
	  %>			
      <td height="26"><input type="checkbox" name="night_diff" value="1"<%=strCheck%>>
        Night Differential </td>
    </tr>
    <tr> 
      <td height="36" colspan="3" align="center">  
        <% if(vEditInfo != null) {%>
        <a href='javascript:PageAction(2,<%=WI.fillTextValue("info_index")%>,"");'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a><font size="1">click 
          to save changes</font>
        <%}else{%>
        <font size="1"><a href='javascript:PageAction(1,"","");'><img src="../../../../images/save.gif" border="0" name="hide_save"></a></font><font size="1">click 
          to add</font> 
        <%}%>
          <a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" width="51" height="26" border="0"></a> <font size="1">click to cancel</font></td>
    </tr>
    <tr> 
      <td height="2" colspan="3"><hr size="1"></td>
    </tr>
  </table>

<%if (vRetResult!=null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" bgcolor="#B9B292" class="thinborder"><div align="center"><strong><font color="#FFFFFF">:: 
          LIST OF EXISTING OVERTIME TYPE IN RECORD ::</font></strong></div></td>
    </tr>
    <tr> 
      <td width="16%" align="center" class="thinborder"><font size="1"><strong>CODE</strong></font></td>
      <td width="32%" height="25" align="center" class="thinborder"><strong>NAME</strong></td>
      <td width="23%" align="center" class="thinborder"><strong>RATE</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>OPTION</strong></td>
      <td colspan="2" align="center" class="thinborder"><strong>OPTIONS</strong></td>
    </tr>
    <%
		//System.out.println("vRetResult " +vRetResult);
	for(int i = 0; i < vRetResult.size();i +=8){%>
    <tr> 
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%> <%=(String)vRetResult.elementAt(i+5)%></td>
      <td valign="top" class="thinborder"><%=astrOption[Integer.parseInt((String)vRetResult.elementAt(i+6))]%></td>
      <td width="6%" align="center" class="thinborder"> 
			<% if (iAccessLevel > 1) {%> 
				<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'>
				<img src="../../../../images/edit.gif" border="0"></a> 
      <%}else{%> &nbsp; <%}%> </td>
      <td width="8%" align="center" class="thinborder"> 
				<% if (iAccessLevel ==2) {%> 
					<a href='javascript:PageAction(0,"<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+1)%>")'>
					<img src="../../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        	N/A 
      	<%}%>			</td>
    </tr>
		<%}%>		
  </table>
<%} // if vRetResult != null%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="24"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>