<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
///for searching COA
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == '0') {
		if(!confirm("Are you sure you want to Delete."))
			return;
	}		
	document.form_.page_action.value = strAction;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrar,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
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

//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Map Otr can grad","otr_can_grad_exclude.jsp");
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

ReportRegistrar RR = new ReportRegistrar();
Vector vRetResult  = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(RR.operateOnExcludeSubjectForm19(dbOP, request, Integer.parseInt(strTemp), null) == null) 
		strErrMsg = RR.getErrMsg();
	else
		strErrMsg = "Operation Successful.";
}
//view all. 
vRetResult = RR.operateOnExcludeSubjectForm19(dbOP, request, 4, null);
if(vRetResult == null)
	strErrMsg = RR.getErrMsg();
%>
<form action="./otr_can_grad_exclude.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          Subject Group Exclude in Form 9::::</strong></font></strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="26">&nbsp;</td>
      <td width="19%">Student ID </td>
      <td width="79%" style="font-weight:bold; font-size:13px;"><%=WI.fillTextValue("stud_id")%><input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>"></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="11" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: Stujects with Grade ::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="4%" height="25" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Count</td>
      <td width="6%" align="center" style="font-size:9px; font-weight:bold" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">SY-Term</span></td>
      <td width="5%" align="center" style="font-size:9px; font-weight:bold" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Course</span></td>
      <td width="10%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Subject Code </td>
      <td width="30%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Subject Name </td>
      <td width="15%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Unmapped Group Name </td>
      <td width="15%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Mapped Group Name </td>
      <td width="5%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Credit Earned </td>
      <td width="5%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Is Credited </td>
      <td width="5%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Exclude</td>
      <td width="10%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Remove Exception </td>
    </tr>
<%
String strBGColor = null;
for(int i = 0; i < vRetResult.size() ; i += 12){
strTemp = (String)vRetResult.elementAt(i + 7);
if(strTemp.equals("1"))
	strTemp = "Credited";
else
	strTemp = "&nbsp;";
if(vRetResult.elementAt(i + 9) != null)
	strBGColor = "bgcolor='#FFCC66'";
else if(vRetResult.elementAt(i + 11) == null)
	strBGColor = "bgcolor='#CCCCCC'";
else	
	strBGColor = "";	
%>
    <tr <%=strBGColor%>> 
      <td height="20" class="thinborder" style="font-size:9px;"><%=i/10 + 1%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%> - <%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder" style="font-size:9px;"><%if(vRetResult.elementAt(i + 11) == null){%><%=vRetResult.elementAt(i + 10)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(vRetResult.elementAt(i + 11), "&nbsp;")%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder" style="font-size:9px;"><%=strTemp%></td>
      <td class="thinborder" align="center">
	  <%if(vRetResult.elementAt(i + 9) == null){%>
	  	<input type="submit" name="122" value="Exclude" style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 	onClick="PageAction('1','<%=vRetResult.elementAt(i + 8)%>');">
	  <%}else{%>&nbsp;<%}%>	  </td>
      <td class="thinborder" align="center">
	  <%if(vRetResult.elementAt(i + 9) != null){%>
	  	<input type="submit" name="1222" value="Remove Exception" style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i + 9)%>');">
	  <%}else{%>&nbsp;<%}%>  	 </td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult.. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="">
<input type="hidden" name="page_action" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>