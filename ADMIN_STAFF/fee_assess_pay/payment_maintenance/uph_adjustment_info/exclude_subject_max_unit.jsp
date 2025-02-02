<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {font-size: 9px}
-->
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
	function PageAction(strAction,strInfoIndex){
		if(strAction == "0"){
			if(!confirm("Do you want to remove this entry?"))
				return;
		}	
		
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.page_action.value = strAction;			
		document.form_.submit();
	
	}
	
	function ReloadPage(){
		location = "./exclude_subject_max_unit.jsp";
	}
	
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PAYMENT MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}		
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation();
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


FAPmtMaintenance FAPmt = new FAPmtMaintenance();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(FAPmt.operateOnExcludeSubFromDiscountMaxUnit(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = FAPmt.getErrMsg();
	else{
		if(strTemp.equals("0"))	
			strErrMsg = "Subject removed from exclude list.";
		if(strTemp.equals("1"))	
			strErrMsg = "Subject added in exclude list.";
	}
}


	vRetResult = FAPmt.operateOnExcludeSubFromDiscountMaxUnit(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = FAPmt.getErrMsg();
	

%>

<form action="./exclude_subject_max_unit.jsp" method="post" name="form_">

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: EXCLUDE SUBJECT PAGE(FROM MAX UNIT DISCOUNT) ::::</strong></font></div></td>
</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="25" style="padding-left: 25px;"><font color="#FF0000" size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr> 
      <td colspan="5"><hr size="1"></td>
    </tr>
	<tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="4" valign="bottom">Subject Code : <font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');">
        (enter subject code to scroll the list)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom"><select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;width:400px;">
          <option value=""></option>
          <%=dbOP.loadCombo("sub_index","sub_code,sub_name"," from subject where is_del=0 and not exists (select * from FA_FEE_ADJ_EXC_SUB_MAXU where sub_index_ = subject.sub_index and is_valid = 1 "+
				") order by sub_code ",WI.fillTextValue("sub_index"), false)%> </select></td>
    </tr>
	<tr><td colspan="5" height="10"></td></tr>
	<tr>
		<td>&nbsp;</td>
		<td width="15" colspan="3">
			<a href="javascript:PageAction('1','');"><img src="../../../../images/save.gif" border="0"></a>
			<font size="1">click to exclude subject</font></td>
	</tr>
</table>


<%if(vRetResult != null && vRetResult.size() > 0){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="5" height="15"></td></tr>
	<tr><td height="25" align="center"><strong>LIST OF EXCLUDED SUBJECT FROM MAX ALLOWED UNIT</strong></td></tr>
</table>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborder" height="25" width="20%" align="center"><strong>SUBJECT CODE</strong></td>
		<td class="thinborder" align="center"><strong>SUBJECT NAME</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>OPTION</strong></td>
	</tr>
	
	<%
		for(int i = 0; i < vRetResult.size(); i+=4){
		
	%>
	
	<tr>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" height="25" align="center">
			<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../../images/delete.gif" border="0"></a>
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

<%=dbOP.constructAutoScrollHiddenField()%>

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
