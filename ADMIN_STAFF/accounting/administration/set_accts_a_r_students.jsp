<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
///for searching COA
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
	if(strAction.length == 0 && strInfoIndex.length == 0) {
		document.form_.year_fr.value = '';
		document.form_.year_to.value = '';
		document.form_.coa_index.value = '';		
	}

}
function PreparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
		
function MapCOAAjax(strIsBlur,strCoaFieldName, strParticularFieldName) {
		var objCOA=document.getElementById("coa_info");
		
		var objCOAInput = document.form_.coa_index;
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa_index.value+"&coa_field_name=coa_index";
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	document.getElementById("coa_info").innerHTML = "<b>"+strAccountName+"</b>";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","set_accts_a_r_students.jsp");
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
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Administration adm = new Administration();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adm.operateOnARStudentPmtCOAMapping(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = adm.operateOnARStudentPmtCOAMapping(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = adm.operateOnARStudentPmtCOAMapping(dbOP, request, 3);


%>
<form action="./set_accts_a_r_students.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          ACCOUNTING : ADMINISTRATION :SET ACCOUNTS FOR A/R STUDENTS PAGE ::::</strong></font></strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Effective Year </td>
      <td width="79%"><%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("year_fr");
%>
        <input name="year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_fr');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','year_fr');">
        to 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("year_to");
%>
        <input name="year_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_to');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','year_to');"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Transaction Type</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("is_debit");

if(strTemp.equals("1") || request.getParameter("is_debit") == null)
	strTemp = " checked";
else	
	strTemp = "";
%>

<input type="radio" name="is_debit" value="1"<%=strTemp%>>
        DEBIT &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%
if(strTemp.length() == 0) 
	strTemp = " checked";
else
	strTemp = "";
%>  <input type="radio" name="is_debit" value="0"<%=strTemp%>>
        CREDIT</td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="17%">Account #</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("coa_index");
%>
	  <input name="coa_index" type="text" size="26" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('0','coa_index','document.form_.particular');">
	  
	  </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
    <tr> 
      <td height="38"><div align="center"><font size="1"></font></div></td>
      <td height="38">&nbsp;</td>
      <td height="38" valign="bottom"><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="123" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="submit" name="123" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="123" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.year_fr.value='';document.form_.year_to.value=''"></td>
    </tr>
    <tr> 
      <td height="26" colspan="3"><div align="right"><font size="1"><img src="../../../images/print.gif" border="0">click 
          to PRINT list</font></div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: 
          LIST OF EXISTING ACCOUNTS FOR A/R STUDENT IN RECORD ::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="15%" height="25" align="center" style="font-size:9px; font-weight:bold" class="thinborder">EFFECTIVE YEAR</td>
      <td width="20%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">ACCOUNT NUMBER</td>
      <td width="35%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">ACCOUNT NAME</td>
      <td width="15%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">TRANSACTION TYPE</td>
      <td width="7%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">EDIT</td>
      <td width="8%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">DELETE</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size() ; i += 6){%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 3)%> to 
  	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "till date")%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%if(vRetResult.elementAt(i + 5).equals("1")){%><b>D</b>ebit<%}else{%><b>C</b>redit<%}%></td>
      <td class="thinborder"><%if(iAccessLevel > 1) {%>
        <input type="submit" name="12" value="Edit" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
      <%}%></td>
      <td class="thinborder"><%if(iAccessLevel ==2 ) {%>
        <input type="submit" name="122" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
      <%}%></td>
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
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>