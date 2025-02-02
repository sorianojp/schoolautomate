<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 9px}
-->
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
	function PageAction(strAction,strInfoIndex){
		if(strAction == "0"){
			if(!confirm("Do you want to delete this sponsor?"))
				return;
		}	
		
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.page_action.value = strAction;	
			
		if(strAction == "3"){
			document.form_.prepareToEdit.value = "1";
			document.form_.page_action.value = "";
		}
		
		document.form_.submit();
	
	}
	
	function ReloadPage(){
		location = "./manage_sponsor.jsp";
	}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Sponsor,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments-SPONSOR".toUpperCase()),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments".toUpperCase()),"0"));
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Sponsor","manage_sponsor.jsp");
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

Sponsor sponsor = new Sponsor();

Vector vRetResult = null;
Vector vEditInfo = null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(sponsor.operateOnSponsor(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = sponsor.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Sponsor successfully saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Sponsor successfully updated.";
		if(strTemp.equals("0"))
			strErrMsg = "Sponsor successfully deleted.";	
	}	
	strPrepareToEdit = "0";
}

vRetResult = sponsor.operateOnSponsor(dbOP, request, 4);
//if(vRetResult == null)
//	strErrMsg = sponsor.getErrMsg();

if(strPrepareToEdit.equals("1")){
	vEditInfo = sponsor.operateOnSponsor(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = sponsor.getErrMsg();
}

	



%>

<form action="./manage_sponsor.jsp" method="post" name="form_">

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: MANAGE SPONSOR PAGE ::::</strong></font></div></td>
</tr>
</table>
  
  <jsp:include page="./tabs.jsp?pgIndex=0"></jsp:include>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="25" style="padding-left: 25px;"><font color="#FF0000" size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">Sponsor Name</td>
		<%
		strTemp = WI.fillTextValue("sponsor_name");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		%>
		<td>
			<input type="text" name="sponsor_name" class="textbox" value="<%=strTemp%>"
	  			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="50" >		</td>
	</tr>
	
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
			<%
			strTemp = WI.fillTextValue("is_active");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
			
			if(strTemp.length() == 0 || strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
			%>
		<td>
			<input type="checkbox" name="is_active" value="1" <%=strErrMsg%>> Is Active		</td>
	</tr>
	<tr><td colspan="3" height="10"></td></tr>
	<tr>
		<td colspan="2" height="25">&nbsp;</td>
		<td>
		<%if(strPrepareToEdit.equals("0")){%>
			<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
			<font size="1">Click to save sponsor</font>
		<%}else{%>
			<a href="javascript:PageAction('2','');"><img src="../../../images/edit.gif" border="0"></a>
			<font size="1">Click to update sponsor</font>
		<%}%>				
			<a href="javascript:ReloadPage()"><img src="../../../images/cancel.gif" border="0"></a>
			<font size="1">Click to reload page</font>
		</td>
	</tr>
</table>


<%if(vRetResult != null && vRetResult.size() > 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="15" colspan="3"></td></tr>
	<tr><td align="center" height="25"><strong>LIST OF SPONSORS</strong></td></tr>
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborder" height="25" width="" align="center"><strong>SPONSOR NAME</strong></td>
		<td class="thinborder" height="25" width="15%" align="center"><strong>IS ACTIVE</strong></td>
		<td class="thinborder" height="25" width="25%" align="center"><strong>OPTION</strong></td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=3){
	%>
	<tr>
		<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		
		<%
		strTemp = (String)vRetResult.elementAt(i+2);
		if(strTemp.equals("1"))
			strTemp = "<img src='../../../images/tick.gif' border='0' />";
		else
			strTemp = "<img src='../../../images/x.gif' border='0' />";
		%>
		
		<td height="25" class="thinborder" align="center"><%=strTemp%></td>
		
		<td class="thinborder" align="center">
			<a href="javascript:PageAction('3','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a>
			&nbsp; &nbsp;
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
		</td>
		
	</tr>
	
	<%}%>
</table>
<%}%>



<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" >
<input type="hidden" name="prepareToEdit"  value="<%=strPrepareToEdit%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
