<%@ page language="java" import="utility.*, payroll.PRCOAMapping, java.util.Vector"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
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
}
function PreparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}

///for ajax.. 
var objCOA;
function MapCOAAjax(strCoaFieldName, strParticularFieldName) {
		objCOA=document.getElementById(strParticularFieldName);
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var objCOAInput;
		eval('objCOAInput=document.form_.'+strCoaFieldName);
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strCoaFieldName;
		this.processRequest(strURL);
}

function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "<b>"+strAccountName+"</b>";
}

function UpdateHeader(){
	var pgLoc = "./coa_mapping_header.jsp";
	var win=window.open(pgLoc,"updateHeader",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function goToMain(){
	location = "./coa_main.jsp";
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-COA Config-COA Mapping","set_coa_mapping.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
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
PRCOAMapping prCOA = new PRCOAMapping();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(prCOA.operateOnAutoCOAMapping(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = prCOA.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = prCOA.operateOnAutoCOAMapping(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = prCOA.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = prCOA.operateOnAutoCOAMapping(dbOP, request, 3);
%>
<form action="./set_coa_mapping.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      CHART OF ACCOUNT - MAPPING ::::</strong></font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold"><a href="javascript:goToMain();">MAIN</a>&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td height="26">&nbsp;</td>
      <td>Mapping Header </td>
			<%
				strTemp = WI.fillTextValue("coa_map_main_index");
			%>
      <td><select name="coa_map_main_index">
        <option value="">Select mapping header</option>
        <%=dbOP.loadCombo("coa_map_main_index","map_header_name", " from pr_coa_map_main order by order_no",strTemp,false)%>
      </select> <a href="javascript:UpdateHeader();">UPDATE</a> click to add Mapping header name </font></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Debit Account # </td>
      <td width="79%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("debit_coa");
%>
        <input name="debit_coa" type="text" size="26" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('debit_coa', 'coa_info_d');"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td><label id="coa_info_d" style="font-size:11px;"></label></td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="17%">Credit Account #</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("credit_coa");
%>
	  <input name="credit_coa" type="text" size="26" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('credit_coa', 'coa_info_c');">	  </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td><label id="coa_info_c" style="font-size:11px;"></label></td>
    </tr>
    <tr> 
      <td height="38">&nbsp; </td>
      <td height="38">&nbsp;</td>
      <td height="38" valign="bottom">
<%if(iAccessLevel > 1) {
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
		 onClick="PageAction('','');document.form_.debit_coa.value='';document.form_.credit_coa.value=''"></td>
    </tr>
    <tr> 
      <td height="21" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="4" align="center" class="thinborder"><font color="#FFFFFF"><strong>:: 
      LIST OF EXISTING PAYROLL ACCOUNTS  IN RECORD ::</strong></font></td>
    </tr>
    <tr> 
      <td width="20%" height="25" align="center" style="font-size:9px; font-weight:bold" class="thinborder">MAPPING HEADER </td>
      <td width="35%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">DEBIT TO </td>
      <td width="37%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">CREDIT TO </td>
      <td width="8%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">DELETE</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size() ; i += 8){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder">&nbsp;
	  	<%if(vRetResult.elementAt(i+2) != null) {%>
			<%=vRetResult.elementAt(i+2)%><br><%=vRetResult.elementAt(i + 3)%>
			<%}%>
	  </td>
      <td class="thinborder">&nbsp;
	  	<%if(vRetResult.elementAt(i + 4) != null) {%>
			<%=vRetResult.elementAt(i + 4)%><br><%=vRetResult.elementAt(i + 5)%>
			<%}%>
	  </td>
      <td class="thinborder"><%if(iAccessLevel >= 2) {%>
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
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
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