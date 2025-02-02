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
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>

<%@ page language="java" import="utility.*,lms.MgmtCirculation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-CIRCULATION","reservation_param.jsp");
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
														"LIB_Administration","CIRCULATION",request.getRemoteAddr(),
														"reservation_param.jsp");
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

	MgmtCirculation mgmtBP = new MgmtCirculation();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtBP.operateOnReservationSetting(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtBP.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Reservation parameter successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Reservation parameter successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Reservation parameter successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = mgmtBP.operateOnReservationSetting(dbOP, request,4);	
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtBP.operateOnReservationSetting(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtBP.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC">
<form action="./reservation_param.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION MANAGEMENT - RESERVATION PARAMETER SETUP PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td>Reservation Status</td>
      <td width="68%"><select name="RES_STAT">
          <option value="0">Pre-reservation</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("RES_STAT");
if(strTemp.compareTo("1") == 0){%>
	      <option value="1" selected>Pending</option>
<%}else{%>
          <option value="1">Pending</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Ready</option>
<%}else{%>
          <option value="2">Ready</option>
<%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="19" colspan="3"><hr size="1" color="#00CCFF"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td width="26%">Status Expires After</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("STAT_EXPIRED");
%>	  
	<input type="text" name="STAT_EXPIRED" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="EXPIRE_UNIT">
          <option value="0">day(s)</option>
<!--
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("STAT_EXPIRED");
if(strTemp.compareTo("1") ==0){%>
	 <option value="1" selected>hour(s)</option>
<%}else{%>
	 <option value="1">hour(s)</option>
<%}%>
-->        </select> </td>
    </tr>
    <tr> 
      <td height="39">&nbsp;</td>
      <td colspan="2"> <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("auto_del");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else
	strTemp = "";
%> <input type="checkbox" name="auto_del" value="1" <%=strTemp%>>
        Automatically delete expired events after 
        <%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("auto_del_day");
%> <input type="text" name="auto_del_day" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.getStrValue(strTemp)%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        days </td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="50">&nbsp;</td>
      <td colspan="2"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./reservation_param.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
<%}%>	
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="26" colspan="4" class="thinborder"> <div align="center"><font color="#FF0000"><strong>LIST 
          OF RESERVATION STATUS SETUP PARAMETERS </strong></font></div></td>
    </tr>
    <tr> 
      <td width="27%" height="25" class="thinborder"><div align="center"><strong><font size="1">RESERVATION 
          STATUS </font></strong></div></td>
      <td width="35%" class="thinborder"><div align="center"><strong><font size="1">EXPIRES AFTER</font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1">DELETE EXPIRED 
          RESERVATION </font></strong></div></td>
      <td width="18%" class="thinborder">&nbsp;</td>
    </tr>
<%
String[] astrConvertResStat = {"Pre-reservation","Pending","Ready"};
String[] astrConvertDayHr = {" Day(s)"," Hour(s)"};
for(int i = 0; i < vRetResult.size(); i += 6){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;
	  <%=astrConvertResStat[Integer.parseInt((String)vRetResult.elementAt(i + 1))]%></font></td>
      <td class="thinborder"><font size="1">&nbsp;
	  <%=(String)vRetResult.elementAt(i + 2) + 
	  	astrConvertDayHr[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%>
	  </font></td>
      <td class="thinborder"><font size="1">&nbsp;
	  <%if(vRetResult.elementAt(i + 5) != null) {%>
        Auto del after <%=(String)vRetResult.elementAt(i + 5)%> day(s)
	  <%}%>
	  </font></td>
      <td class="thinborder"><font size="1">&nbsp;
        <%
if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a> 
        <%}if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a> 
        <%}%>
        </font></td>
    </tr>
<%}%>
  </table>
<%}//if vRetResult is not null
%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  </form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>