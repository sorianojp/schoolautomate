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
	if(strAction == '0') {//confirmation.. 
		if(!confirm("Do you want to delete"))
			return;
	}
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
}

function ClearAll(){
	document.form_.page_action.value="";
	document.form_.page_action.value="";
	document.form_.preparedToEdit.value="";	
	document.form_.clear_all.value="1";
}


function PreparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = '';
	document.form_.info_index.value = strInfoIndex;
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.RLEInformation,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Reports-Others","rle_manage_affiliation.jsp");
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
	if(rleInfo.operateOnAffiliation(dbOP, request, Integer.parseInt(strPageAction)) == null) 
		strErrMsg = rleInfo.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
if(strPreparedToEdit.equals("1")) {
	vEditInfo = rleInfo.operateOnAffiliation(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = rleInfo.getErrMsg();
}

if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length()> 0) {
	vRetResult = rleInfo.operateOnAffiliation(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = rleInfo.getErrMsg();
}
boolean bolClearAll = WI.fillTextValue("clear_all").equals("1");

%>

<form name="form_" action="./rle_manage_affiliation.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>::::AFFILIATION SETTING ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold"><a href="./rle_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>&nbsp;&nbsp;&nbsp;
  	  <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
<% if (strSchCode.startsWith("CGH")) 
		strTemp ="Batch";
	  else
	  	strTemp = "SY/Term"; %>
      <td style="font-size:11px;"><%=strTemp%></td>
      <td width="87%" colspan="2" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
	   
       <input type="text" name="sy_from" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_', 'sy_from');"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
<%

if (!strSchCode.startsWith("CGH")) {

strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	
%>
      <input type="text" name="sy_to" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        - 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
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
        </select>
<%}else{	// for CGH.. 

strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
	<input type="hidden" name="sy_to" value="<%=strTemp%>">
	<input type="hidden" name="semester" value="1">
<%}%>		</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">Affiliation Name </td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("aff_name");
	
if (bolClearAll) 
	strTemp = "";	
%>	  
      <td colspan="2" >
	  <input type="text" name="aff_name" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="128"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">Address</td>
<%
if(vEditInfo != null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
else	
	strTemp = WI.fillTextValue("address");
%>	  
      <td colspan="2" >
	  <textarea name="address" rows="3" cols="75" class="textbox" style="font-size:11px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
<% if (!strSchCode.startsWith("CGH")) {%> 
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">Chief Nurse </td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("chief_nurse");
%>	  
      <td colspan="2" >
	  <input type="text" name="chief_nurse" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="64"></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td width="12%" style="font-size:11px;">Ward Info. </td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("ward_info");
%>	  
      <td colspan="2" >
	  <textarea name="ward_info" rows="3" cols="75" class="textbox" style="font-size:11px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
<%}else{%> 
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">Bed Capacity </td>

<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("bed_capacity");

if (bolClearAll) 
	strTemp = "";	
	
%>
	  
      <td colspan="2" ><input type="text" name="bed_capacity" size="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_', 'bed_capacity')"></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td width="12%" style="font-size:11px;">&nbsp;</td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("base_affiliation");

if (bolClearAll) 
	strTemp = "";	
	
	if (strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
%>
      <td colspan="2" >
        <input type="checkbox" name="base_affiliation" value="1" <%=strTemp%>>
		<font size="1">check if the base hospital</font></td>
    </tr>
<%}%> 
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
		 onClick="ClearAll();"></td>
    </tr>
    <tr>
	  <td height="25" align="center">&nbsp;</td>
		<td colspan="3" align="center">&nbsp;</td>   
	</tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {
String[] astrConvertToTerm = {"Summer", "First Sem", "Second Sem"," Third Sem"};


if (!strSchCode.startsWith("CGH")) {
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#6699FF">
	  <td height="25" colspan="6" class="thinborder"><div align="center"><strong><font color="#FFFFFF">:: LIST OF AFFILIATION FOR :  
	  <%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")+", "+
	  	astrConvertToTerm[Integer.parseInt(WI.fillTextValue("semester"))]%> ::</font></strong></div></td>
	</tr>
	<tr>
	  <td width="30%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">AFFILIATION</td>
	  <td width="25%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">ADDRESS</td>
	  <td width="15%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">WARD LIST </td>
	  <td width="20%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">CHIEF NURSE </td>
	  <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">EDIT</td>
	  <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">DELETE</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 8) {%>
	<tr>
	  <td height="25" class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%></td>
	  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 2)%></td>
	  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 4)%></td>
	  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 5)%></td>
	  <td class="thinborder" style="font-size:9px;"><%if(iAccessLevel > 1){%>
	  <input type="submit" name="122" value="Edit" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
	  <%}%>
	  </td>
	  <td class="thinborder" align="center" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px;">
	    <%if(iAccessLevel > 1){%>
        <input type="submit" name="1222" value="Delete" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PageAction('0', '<%=vRetResult.elementAt(i)%>');">
        <%}%>
      </span>	  </td>
    </tr>
<%}//end of ret result.%>
  </table>
<%}else{%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
<tr>
	<td>
<table width="75%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#6699FF">
	  <td height="25" colspan="5" align="center" class="thinborder">
	  <strong><font color="#FFFFFF">:: AREAS OF CLINICAL AFFILIATION FOR BATCH   
	  		 <%=WI.fillTextValue("sy_from")%> ::</font></strong></td>
	</tr>
	<tr>
	  <td height="25" colspan="2" align="center" class="thinborder" style="font-size:11px; font-weight:bold">AFFILIATION</td>
	  <td width="28%" class="thinborder" align="center" style="font-size:11px; font-weight:bold">BED CAPACITY </td>
	  <td width="6%" class="thinborder" align="center" style="font-size:11px; font-weight:bold">EDIT</td>
	  <td width="9%" class="thinborder" align="center" style="font-size:11px; font-weight:bold">DELETE</td>
    </tr>
<%
	String[] astrBaseName = {"Institutions of Affiliation","Base Hospital"};
	String strBaseHospital = "";
	for(int i = 0; i < vRetResult.size(); i += 8) {
	  if (!strBaseHospital.equals((String)vRetResult.elementAt(i+7))){
	  	strBaseHospital = (String)vRetResult.elementAt(i+7);
%>
	<tr>
	  <td height="18" colspan="2" class="thinborderLEFT" style="font-size:11px;"><em>
	  		&nbsp;<%=astrBaseName[Integer.parseInt(strBaseHospital)]%> :	   	</em></td>
      <td height="18" class="thinborderLEFT" style="font-size:11px;">&nbsp;</td>
      <td height="18" class="thinborderLEFT" style="font-size:11px;">&nbsp;</td>
      <td height="18" class="thinborderLEFT" style="font-size:11px;">&nbsp;</td>
	</tr>
<%  }%> 


	<tr>
	  <td width="5%" height="25" valign="top" class="thinborder" style="font-size:11px;">&nbsp;</td>
	  <td width="52%" class="thinborderBOTTOM" style="font-size:11px;"><span class="thinborderBOTTOM" style="font-size:11px;"><%=vRetResult.elementAt(i + 1)%></span></td>
	  <td class="thinborder" style="font-size:9px;" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"---")%></td>
	  <td class="thinborder" style="font-size:9px;"><%if(iAccessLevel > 1){%>
	  <input type="submit" name="2" value="  Edit  " style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
	  <%}%>	  </td>
	  <td align="center" class="thinborder" style="font-size:9px; font-weight:bold"><span class="thinborder" style="font-size:9px;">
	    <%if(iAccessLevel > 1){%>
        <input type="submit" name="1222" value="Delete" style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="PageAction('0', '<%=vRetResult.elementAt(i)%>');">
        <%}%>
      </span>	  </td>
    </tr>
<%}//end of ret result.%>
  </table>


	</td>
</tr>
</table>

<% } // cgh report
}//end of vRetResult..%>
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
<input type="hidden" name="clear_all">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
