<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.RLEInformation,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null; String strTemp = null;
	boolean bolCallCopy = false;
	if(WI.fillTextValue("page_action").length() > 0) {
		bolCallCopy = true;
	}


//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
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
RLEInformation rleInfo = new RLEInformation();
Vector vRetResult = null;

if(bolCallCopy) {
	if(rleInfo.copyAffiliation(dbOP, request))
		strErrMsg = "Operation successful.<br>";
	else	
		strErrMsg = " Copy failed.<br>";
	strErrMsg = strErrMsg + rleInfo.getErrMsg();
}

if(WI.fillTextValue("sy_from_to").length() > 0 && WI.fillTextValue("sem_to").length() > 0) {
	request.setAttribute("sy_from", WI.fillTextValue("sy_from_to"));
	request.setAttribute("semester", WI.fillTextValue("sem_to"));
	vRetResult = rleInfo.operateOnAffiliation(dbOP, request, 4);
}
%>

<form name="form_" action="./rle_copy_affiliation.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>::::AFFILIATION SETTING ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold"><a href="./rle_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>&nbsp;&nbsp;&nbsp;
  	  <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
<%
strTemp = WI.fillTextValue("sy_from_fr");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td width="17%" style="font-size:11px;">SY/Term - FROM </td>
      <td width="82%" colspan="2" >
        <input type="text" name="sy_from_fr" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_', 'sy_from_fr');"
	  onKeyUp='DisplaySYTo("form_","sy_from_fr","sy_to_fr")'> 
<%
strTemp = WI.fillTextValue("sy_to_fr");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
      <input type="text" name="sy_to_fr" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        - 
        <select name="sem_fr">
<%
strTemp = WI.fillTextValue("sem_fr");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
        </select></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">SY/Term - TO </td>
      <td colspan="2" >
<%
strTemp = WI.fillTextValue("sy_from_to");
%>
	  <input type="text" name="sy_from_to" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_', 'sy_from_to');"
	  onKeyUp='DisplaySYTo("form_","sy_from_to","sy_to_to")'>
        <%
strTemp = WI.fillTextValue("sy_to_to");
%>
        <input type="text" name="sy_to_to" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
-
<select name="sem_to">
  <%
strTemp = WI.fillTextValue("sem_to");
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
</select>&nbsp;&nbsp;&nbsp;
<input type="submit" name="1223" value=" View Affilication " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.page_action.value=''">
</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">&nbsp;</td>
      <td colspan="2" style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">&nbsp;</td>
      <td colspan="2" style="font-size:11px;"><input type="submit" name="122" value=" Copy Affiliation " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.page_action.value='1'"></td>
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
	  <td height="25" colspan="6" class="thinborder"><div align="center"><strong><font color="#FFFFFF">:: LIST OF AFFILIATION FOR :- 
	  <%=WI.fillTextValue("sy_from_to")+" - "+WI.fillTextValue("sy_to_to")+", "+
	  	astrConvertToTerm[Integer.parseInt(WI.fillTextValue("sem_to"))]%> ::</font></strong></div></td>
	</tr>
	<tr>
	  <td width="30%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">AFFILIATION</td>
	  <td width="25%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">ADDRESS</td>
	  <td width="15%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">WARD LIST </td>
	  <td width="20%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">CHIEF NURSE </td>
<!--
	  <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">EDIT</td>
	  <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">DELETE</td>
-->
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 8) {%>
	<tr>
	  <td height="25" class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%></td>
	  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 2)%></td>
	  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 4)%></td>
	  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 5)%></td>
<!--
	  <td class="thinborder" style="font-size:9px;"><%if(iAccessLevel > 1){%>
	  <input type="submit" name="122" value="Edit" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
	  <%}%>
	  </td>
	  <td class="thinborder" align="center" style="font-size:9px; font-weight:bold">
	  <%if(iAccessLevel > 1){%>
        <input type="submit" name="1222" value="Delete" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PageAction('0', '<%=vRetResult.elementAt(i)%>');">
        <%}%>
       </td>-->
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

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
