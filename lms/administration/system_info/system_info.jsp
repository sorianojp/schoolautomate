<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

</script>

<%@ page language="java" import="utility.*,lms.MgmtSysInfo,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-SYSTEM INFORMATION","system_info.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Administration","SYSTEM INFORMATION",request.getRemoteAddr(),
														"system_info.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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

//end of authenticaion code.
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	MgmtSysInfo mgmtSysInfo = new MgmtSysInfo();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() == 0) 
		strTemp = "4";
	if(strTemp.length() > 0) {
		vEditInfo = mgmtSysInfo.saveInfo(dbOP, request,Integer.parseInt(strTemp)); 
		if(vEditInfo == null) {
			strErrMsg = mgmtSysInfo.getErrMsg();
			if(strTemp.compareTo("1") == 0)
				vEditInfo = mgmtSysInfo.saveInfo(dbOP, request,4);
		}
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "System information successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "System information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "System information successfully edited.";

			strPrepareToEdit = "0";
		}
	}

%>

<body bgcolor="#DEC9CC">
<form action="./system_info.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SYSTEM INFORMATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="6%" height="32">&nbsp;</td>
      <td width="17%">MARC organization Code</td>
      <td width="77%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(0);
else	
	strTemp = WI.fillTextValue("MARC_CODE");
%>
        <input name="MARC_CODE" type="text"  class="textbox" maxlength="32" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Contact Person</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("CONTACT_PERSON");
%>
        <input name="CONTACT_PERSON" type="text"  class="textbox" maxlength="64" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="48" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Position</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("POSITION");
%>
        <input name="POSITION" type="text"  class="textbox" maxlength="64" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="48" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Street Name/No.</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("HOUSE_NO");
%>
        <input name="HOUSE_NO" type="text"  class="textbox" maxlength="128" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="48" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Municipality/City</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("CITY");
%>
        <input name="CITY" type="text"  class="textbox" maxlength="32" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Province</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("PROVIENCE");
%>
        <select name="PROVIENCE">
<%=dbOP.loadCombo("provience_index","provience_name",
	" from PRELOAD_PROVIENCE order by provience_name asc", strTemp, false)%>
        </select></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Country</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("COUNTRY");
%>
        <select name="COUNTRY">
<%=dbOP.loadCombo("country_index","country",
	" from HR_PRELOAD_COUNTRY order by country asc", strTemp, false)%>
        </select></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>ZIP Code</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("ZIP_CODE");
%>
        <input name="ZIP_CODE" type="text"  class="textbox" maxlength="10" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="12" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Email Address</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("EMAIL_ADDR");
%>
        <input name="EMAIL_ADDR" type="text"  class="textbox" maxlength="32" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Phone Nos.</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("TELEPHONE");
%>
        <input name="TELEPHONE" type="text"  class="textbox" maxlength="64" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="48" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Fax Nos.</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("FAX_NO");
%>
        <input name="FAX_NO" type="text"  class="textbox" maxlength="64" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="48" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="15" colspan="3"><hr size="1" color="#0000CC"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Classification Type</td>
      <td>

        <select name="CLASS_TYPE">
          <option value="0">Dewey</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("CLASS_TYPE");
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>LC</option>
<%}else{%>
          <option value="1">LC</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Statistical Year Starting Month</td>
      <td>
        <select name="STAT_MONTH">
          <option value="0">January</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(12);
else	
	strTemp = WI.fillTextValue("STAT_MONTH");
if(strTemp.compareTo("1")  == 0){%>          
		  <option value="1" selected>February</option>
<%}else{%>
		  <option value="1">February</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>March</option>
<%}else{%>
          <option value="2">March</option>
<%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>April</option>
<%}else{%>
          <option value="3">April</option>
<%}if(strTemp.compareTo("4") == 0){%>
          <option value="4" selected>May</option>
<%}else{%>
          <option value="4">May</option>
<%}if(strTemp.compareTo("5") == 0){%>
          <option value="5" selected>June</option>
<%}else{%>
          <option value="5">June</option>
<%}if(strTemp.compareTo("6") == 0){%>
          <option value="6" selected>July</option>
<%}else{%>
          <option value="6">July</option>
<%}if(strTemp.compareTo("7") == 0){%>
          <option value="7" selected>August</option>
<%}else{%>
          <option value="7">August</option>
<%}if(strTemp.compareTo("8") == 0){%>
          <option value="8" selected>September</option>
<%}else{%>
          <option value="8">September</option>
<%}if(strTemp.compareTo("9") == 0){%>
          <option value="9" selected>October</option>
<%}else{%>
          <option value="9">October</option>
<%}if(strTemp.compareTo("10") == 0){%>
          <option value="10" selected>November</option>
<%}else{%>
          <option value="10">November</option>
<%}if(strTemp.compareTo("11") == 0){%>
          <option value="11" selected>December</option>
<%}else{%>
          <option value="11">December</option>
<%}%>
        </select></td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="66">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="66" valign="bottom"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./system_info.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries</font></td>
    </tr>
<%}%>	
  </table>
<input type="hidden" name="page_action">
  </form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>