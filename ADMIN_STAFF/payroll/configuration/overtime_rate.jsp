<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Set Overtime Rate</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script>
<!--

function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function PrepareToEdit(strIndex){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}

function CancelRecord(){
	location = "./overtime_rate.jsp";
}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
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
								"Admin/staff-Payroll-configuration-OT Rate","overtime_rate.jsp");
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
PayrollConfig Pconfig = new PayrollConfig();
boolean bolFatalErr = true;
String strPageAction = WI.fillTextValue("page_action");
strPrepareToEdit = WI.fillTextValue("prepareToEdit");

int iPageAction = Integer.parseInt(WI.getStrValue(strPageAction,"4"));

switch (iPageAction){
  case 1: {	if (Pconfig.operateOnOTRate(dbOP,request,iPageAction) != null) 
				strErrMsg = " Overtime Rate added successfully ";
			else strErrMsg = Pconfig.getErrMsg();
			
			break;
		  }
 case 2: {
			if (Pconfig.operateOnOTRate(dbOP,request,iPageAction) != null){
				strErrMsg = " Overtime rate edited successfully ";
				strPrepareToEdit = "";
			}else
				strErrMsg = Pconfig.getErrMsg();

			break;
		 }
 case 0:{
			if (Pconfig.operateOnOTRate(dbOP,request,iPageAction) != null)
							strErrMsg = " Overtime rate removed successfully ";
			else
				strErrMsg = Pconfig.getErrMsg();
			
			break;
		}
} // end switch

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = Pconfig.operateOnOTRate(dbOP,request,3);

	if (vEditInfo == null)
		strErrMsg = Pconfig.getErrMsg();	
}

vRetResult  = Pconfig.operateOnOTRate(dbOP,request,4);
%>
<form action="./overtime_rate.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      OVERTIME RATES MAINTENANCE PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25"><font size=3><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26" valign="bottom">&nbsp;</td>
      <td height="26" valign="bottom">Effectivity Date : </td>
      <td height="26" valign="bottom"> 
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0) 
			strTemp = (String)vEditInfo.elementAt(3);
		else	
			strTemp = WI.fillTextValue("imp_date");
	  %> 
	  <input name="imp_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.imp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="26" colspan="3" valign="bottom"><strong>Employee's regular workday</strong>      </td>
    </tr>
    <tr> 
      <td width="36" height="26"><div align="right">&nbsp;</div></td>
      <td width="145">Rate</td>
      <td width="589" height="26">&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <% if (vEditInfo != null)  
		      strTemp = WI.getStrValue((String)vEditInfo.elementAt(1));
	      else 
		  	  strTemp = WI.fillTextValue("RW_RU_VAL");
	    %> <input name="RW_RU_VAL" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" 
		onKeyUp="AllowOnlyInteger('form_','RW_RU_VAL')" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','RW_RU_VAL')"  
		value="<%=strTemp%>" size="6" maxlength="6">
        (Percent added to the hourly rate) </td>
    </tr>
    <tr> 
      <td height="25" colspan="3" valign="bottom"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" valign="bottom"><strong>Employee's rest day</strong>      </td>
    </tr>
    <tr> 
      <td height="25"><div align="right">&nbsp;&nbsp;&nbsp;</div></td>
      <td>Rate</td>
      <td height="25"><strong> </strong> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <% 
		if (vEditInfo != null)  strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
		  else strTemp = WI.fillTextValue("RD_RU_VAL");  %> <input name="RD_RU_VAL" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','RD_RU_VAL')" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','RD_RU_VAL')" value="<%=strTemp%>" size="6" maxlength="6">
        (Percent added to the hourly rate) </td>
    </tr>
    <tr> 
      <td height="43" colspan="3" align="center">  
				<%if(iAccessLevel > 1){%>
        <% if(vEditInfo == null) {%>
				<!--
				<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:PageAction('1','');">
				<font size="1">click to add</font> 
				<%}else{%>          
        <!--
				<a href='javascript:PageAction(2,<%=WI.fillTextValue("info_index")%>);'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
				-->
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '<%=WI.fillTextValue("info_index")%>');">
				<font size="1">click to save changes</font> 
				<%}%>
				<!--
				<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a>
				-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">				
        <font size="1">click to cancel </font>
				<%}%>
				</td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>

<%if (vRetResult!=null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF" ><strong> OVERTIME RATES</strong></font></td>
    </tr>
    <tr>
      <td width="35%" align="center" class="thinborder"><font size="1"><strong>EFFECTIVITY 
      DATE </strong></font></td>
      <td width="35%" height="25" align="center" class="thinborder"><strong>REGULAR 
      WORKDAY RATE</strong></td>
      <td width="35%" align="center" class="thinborder"><strong>REST DAY 
      RATE</strong></td>
      <td colspan="2" align="center" class="thinborder"><strong>OPTIONS</strong></td>
    </tr> 
    <%//System.out.println("vRetResult " +vRetResult);
	for(int i = 0; i < vRetResult.size();i +=4){%>
	<tr>
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td valign="top" class="thinborder">Hourly rate plus <%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%>%</td>      
      <td valign="top" class="thinborder">Hourly rate plus <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%>%</td>
      <td width="7%" class="thinborder"> <% if (iAccessLevel > 1) {%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%> &nbsp; <%}%> </td>
      <td width="8%" class="thinborder"> <% if (iAccessLevel ==2) {%> <a href='javascript:PageAction(0,"<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%> N/A <%}%> </td>
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