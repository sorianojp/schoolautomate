<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	body{
	 font-size:11px;
	 font-family:Verdana, Arial, Helvetica, sans-serif;
	}
	td{
	 font-size:11px;
	 font-family:Verdana, Arial, Helvetica, sans-serif;
	}

</style>

</head>
<script language="JavaScript">
function UpadteActionPlan() {
	location = "./action_plan_org_update.jsp?organization_id="+
		escape(document.form_.organization_id.value)+
		"&sy_from="+ document.form_.sy_from.value+
		"&sy_to="+ document.form_.sy_to.value;
}

function UpadtePerformance() {
	location = "./performance_report_update.jsp?organization_id="+
		escape(document.form_.organization_id.value)+
		"&sy_from="+ document.form_.sy_from.value+
		"&sy_to="+ document.form_.sy_to.value;
}


function FocusID() {
	document.form_.organization_id.focus();
}
function OpenSearch() {
	var pgLoc = "../search/srch_org.jsp?opner_info=form_.organization_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","aciton_plan_org.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs",
														"ORGANIZATIONS",request.getRemoteAddr(),
														"action_plan_org.jsp");
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
Vector vRetResult = new Vector();
boolean bolNoRecord = false;
boolean bolRetainValue = false;//if it is true, use wi.fillTextValue(..);
String[] astrStatus ={"Regular", "Probationary","Failed", "(No Status)","Accredited"};

if(WI.fillTextValue("organization_id").length() > 0
	&& WI.fillTextValue("sy_from").length() > 0){
	Organization organization = new Organization();
	vRetResult = organization.operateOnOrganization(dbOP, request,4);
	if(vRetResult == null)
		strErrMsg = organization.getErrMsg();
}
%>
<body bgcolor="#D2AE72" onLoad="FocusID()">
<form action="./action_plan_org.jsp" method="post" name="form_">
<% String strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");%>	
<input type="hidden" name="sy_from"  value="<%=strTemp%>">
<%  strTemp = WI.fillTextValue("sy_to");
	if (strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");%>
<input type="hidden" name="sy_to"  value="<%=strTemp%>">
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
	  <% if (WI.fillTextValue("performance").equals("1"))
		  	strTemp = "PERFORMANCE REPORT";
		else
			strTemp = "ACTION PLAN"; %>
		
          ORGANIZATIONS - <%=strTemp%> PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%" >Organization ID :</td>
      <td width="27%"> <input name="organization_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=WI.fillTextValue("organization_id")%>" size="25"></td>
      <td width="53%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td><input type="image" src="../../../images/form_proceed.gif"></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="25%">Organization name : </td>
      <td colspan="3"><%=(String)vRetResult.elementAt(2)%></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>College/Department</td>
      <td><strong><%=WI.getStrValue(vRetResult.elementAt(5))%><%=WI.getStrValue((String)vRetResult.elementAt(7),"/","","")%></strong></td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization description : </td>
      <td colspan="3"><%=(String)vRetResult.elementAt(11)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization vision : </td>
      <td colspan="3"><%=(String)vRetResult.elementAt(12)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization mission : </td>
      <td colspan="3"><%=(String)vRetResult.elementAt(13)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization adviser(s): </td>
      <td colspan="3"><%=WI.getStrValue((String)vRetResult.elementAt(8))%></td>
    </tr>
<% if ((String)vRetResult.elementAt(14) != null){%>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><%=(String)vRetResult.elementAt(14)%> </td>
    </tr>
<%} if ((String)vRetResult.elementAt(15) != null){%>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><%=(String)vRetResult.elementAt(15)%> </td>
    </tr>
<%}%>  

    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization Status : </td>
      <td width="23%">
  	  <%=astrStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(16),"3"))]%>      </td>
      <td width="22%">Date of Status Update: </td>
      <td width="25%"><strong><%=WI.getStrValue((String)vRetResult.elementAt(3))%>&nbsp;</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td height="25">
<%
 if (WI.fillTextValue("performance").equals("1"))
		strTemp = "performance report";
	else
		strTemp = "action plan"; 

//	System.out.println((String)vRetResult.elementAt(16));

 if (((String)vRetResult.elementAt(16)) != null &&
		!(((String)vRetResult.elementAt(16)).equals("2"))) {
		
	 if (!WI.fillTextValue("performance").equals("1")){
%> 
	  <a href="javascript:UpadteActionPlan();">
<%}else{%> 
	  <a href="javascript:UpadtePerformance();">
<%}%> 
	  
	  
	  <img src="../../../images/update.gif" width="60" height="26" border="0"></a><font size="1">click
        to create or update 
		<%=strTemp%></font>
	<%}else{%> 
		<font size="1"> Creating of <%=strTemp%> is applicable only to regular or probationary  organizations </font>
	    <%}%> 
	</td>
    </tr>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="performance" 
			value="<%=WI.fillTextValue("performance")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
