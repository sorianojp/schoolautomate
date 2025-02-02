<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(this.checkIfSYChanged()) {
		alert("SY/Term information is changed. System will refresh first before any add/del operation");
		return;
	}

	if(strAction == '0') {//confirmation.. 
		if(!confirm("Do you want to delete"))
			return;
	}
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
}
function PreparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = '';
	document.form_.info_index.value = strInfoIndex;
}
function checkIfSYChanged() {
	if(document.form_.sy_from.value != document.form_.sy_from_prev.value)
		return true;
	if(document.form_.semester[document.form_.semester.selectedIndex].value != document.form_.sem_prev.value)
		return true;
	
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.RLEInformation,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Reports-Others","rle_manage_subject.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
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
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
RLEInformation rleInfo = new RLEInformation();
Vector vRetResult  = null;
Vector vEditInfo   = null;

String strPageAction = WI.fillTextValue("page_action");
if(strPageAction.length() > 0) {
	if(rleInfo.operateOnSubAffiliation(dbOP, request, Integer.parseInt(strPageAction)) == null) 
		strErrMsg = rleInfo.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
if(strPreparedToEdit.equals("1")) {
	vEditInfo = rleInfo.operateOnSubAffiliation(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = rleInfo.getErrMsg();
}

String strSYFrom = WI.fillTextValue("sy_from");
String strSem    = WI.fillTextValue("semester");
if(strSYFrom.length() ==0) {
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	request.setAttribute("sy_from",strSYFrom);
}
if(strSem.length() ==0) {
	strSem = (String)request.getSession(false).getAttribute("cur_sem");
	request.setAttribute("semester",strSem);
}
////view all. 
vRetResult = rleInfo.operateOnSubAffiliation(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = rleInfo.getErrMsg();

%>

<form name="form_" action="./rle_manage_subject.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>::::AFFILIATION SETTING ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold"><a href="./rle_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>&nbsp;&nbsp;
  	  <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td width="14%" style="font-size:11px;">SY/Term</td>
      <td width="85%" colspan="2" >
        <input type="text" name="sy_from" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_', 'sy_from');"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
      <input type="text" name="sy_to" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        - 
        <select name="semester">
          <%
strTemp = strSem;
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="submit" name="123" value=" Refresh " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.page_action.value='';"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">Subject </td>
      <td colspan="2" >
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("sub_index");
%>	
		<select name="sub_index">
<%=dbOP.loadCombo("distinct RLE_HR_DISTRIBUTION.SUB_INDEX","subject.sub_code"," from RLE_HR_DISTRIBUTION "+
	"join subject on (subject.sub_index = RLE_HR_DISTRIBUTION.sub_index) "+
	"where is_valid = 1", strTemp, false)%>		
		</select>
	
	</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">Affiliation</td>
      <td colspan="2" >
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("aff_index");
%>
		<select name="aff_index">
<%=dbOP.loadCombo("AFF_INDEX","AFF_NAME"," from RLE_AFFILIATION where is_valid = 1 and sy_from="+
		strSYFrom+" and semester="+strSem, strTemp, false)%>		
		</select>
	</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td colspan="2">
	  <%if(iAccessLevel > 1) {
			if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');"></td>
    </tr>
    <tr>
	  <td height="25" align="center">&nbsp;</td>
		<td colspan="3" align="center">&nbsp;</td>   
	</tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {
String[] astrConvertToTerm = {"Summer", "First Sem", "Second Sem"," Third Sem"};%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#6699FF">
	  <td height="25" colspan="4" class="thinborder"><div align="center"><strong><font color="#FFFFFF">:: SUBEJECT OFFERED BY AFFILIATED INST. :- 
	  <%=strSYFrom+" - "+Integer.toString(Integer.parseInt(strSYFrom) + 1) +", "+
	  	astrConvertToTerm[Integer.parseInt(strSem)]%> ::</font></strong></div></td>
	</tr>
	<tr>
	  <td width="25%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">SUBJECT</td>
	  <td width="65%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">AFFILIATION</td>
	  <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">EDIT</td>
	  <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">DELETE</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 5) {%>
	<tr>
	  <td height="25" class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%></td>
	  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 2)%></td>
	  <td class="thinborder" style="font-size:9px;"><%if(iAccessLevel > 1){%>
	  <input type="submit" name="122" value="Edit" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
	  <%}%>	  </td>
	  <td class="thinborder" align="center" style="font-size:9px; font-weight:bold">
	    <%if(iAccessLevel > 1){%>
        <input type="submit" name="1222" value="Delete" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PageAction('0', '<%=vRetResult.elementAt(i)%>');">
        <%}%>     	  </td>
    </tr>
<%}//end of ret result.%>
  </table>
<%}//end of vRetResult..%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

<input type="hidden" name="sy_from_prev" value="<%=strSYFrom%>">
<input type="hidden" name="sem_prev" value="<%=strSem%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
