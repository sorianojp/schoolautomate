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
								"Admin/staff-Accounting-Administration","map_coa_college.jsp");
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
	if(adm.operateOnCollegeTFCOAMappingNEW(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = adm.operateOnCollegeTFCOAMappingNEW(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = adm.operateOnCollegeTFCOAMappingNEW(dbOP, request, 3);

//0 = per course, 1 = per college.
boolean bolFatalErr = false;
String strMapRef = "select prop_val from read_property_file where prop_name = 'AR_MAPPING_PERCOLLEGE'";
strMapRef = dbOP.getResultOfAQuery(strMapRef, 0);
if(strMapRef == null) {
	strErrMsg = "Please set MAP PER COLLEGE or MAP PER COURSE information.";
	bolFatalErr = true;
}

%>
<form action="./map_coa_college.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CHART OF ACCOUNT - MAPPING ::::</strong></font></strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%if(!bolFatalErr){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strMapRef.equals("1")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>College</td>
      <td width="82%">
<%
	strTemp = " where not exists (select * from FA_COLLEGE_COA where college_index = c_index) " + 
		 " and is_del=0 order by c_code";
%>
	  <select name="college">
	  <%=dbOP.loadCombo("c_index","c_code", " from college " + strTemp,
	  		WI.fillTextValue("college"),false)%>
      </select>
  	  </td>
    </tr>
<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Course </td>
      <td width="82%">
<%
	strTemp = " where not exists (select * from FA_COLLEGE_COA where course_i = course_index) " + 
		 " and is_del=0 and is_offered = 1";
%>
	  <select name="course_index">
	  <%=dbOP.loadCombo("course_index","course_code, course_name", " from course_offered " + strTemp,
	  		WI.fillTextValue("course_index"),false)%>
      </select></td>
    </tr>
<%}%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Tuition Fee  Account # </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("tf_coa");
%>
        <input name="tf_coa" type="text" size="26" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('tf_coa', 'coa_info_d');"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td><label id="coa_info_d" style="font-size:11px;"></label></td>
    </tr>
<%if(false){%>
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="16%">TF Increment Account #</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("tfi_coa");
%>
	  <input name="tfi_coa" type="text" size="26" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('tfi_coa', 'coa_info_c');">	  </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
      <td><label id="coa_info_c" style="font-size:11px;"></label></td>
    </tr>
<%}%>
    <tr> 
      <td height="38"><div align="center"><font size="1"></font></div></td>
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
		 onClick="PageAction('','');document.form_.tf_coa.value='';document.form_.tfi_coa.value=''"></td>
    </tr>
    <tr> 
      <td height="26" colspan="3"><div align="right"></div></td>
    </tr>
  </table>
<%}
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: 
          LIST OF EXISTING ACCOUNTS FOR A/R STUDENT IN RECORD ::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
<%if(strMapRef.equals("1")){%>
      <td width="42%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">COLLEGE</td> 
<%}else{%>
      <td width="42%" height="25" align="center" style="font-size:9px; font-weight:bold" class="thinborder">COURSE CODE </td>
<%}%>
      <td width="27%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">TUITION FEE </td>
      <%if(false){%><td width="23%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">TUITION FEE INCREMENT </td><%}%>
      <td width="8%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">DELETE</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size() ; i += 10){%>
    <tr>
<%if(strMapRef.equals("1")){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td> 
<%}else{%>
      <td height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 1), "&nbsp;")%></td>
<%}%>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%><br><%=vRetResult.elementAt(i + 3)%></td>
      <%if(false){%><td class="thinborder">&nbsp;
	  	<%if(vRetResult.elementAt(i + 4) != null) {%>
			<%=vRetResult.elementAt(i + 4)%><br><%=vRetResult.elementAt(i + 5)%>
		<%}%>
	  </td>
	  <%}%>
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

<input type="hidden" name="is_debit" value="<%=WI.fillTextValue("is_debit")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>