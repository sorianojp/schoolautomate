<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>

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
								"lms-Administration-CIRCULATION","fine_implementation.jsp");
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
														"fine_implementation.jsp");
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
		if(mgmtBP.operateOnFineImplementation(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtBP.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Fine implementation set up information successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Fine implementation set up information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Fine implementation set up information successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = mgmtBP.operateOnFineImplementation(dbOP, request,4);	
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtBP.operateOnFineImplementation(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtBP.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC">
<form action="./fine_implementation.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION MANAGEMENT - FINE IMPLEMENTATION SETUP PAGE ::::</strong></font></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"><a href="fines.htm"><img src="../../images/go_back.gif" width="48" height="28" border="0"></a> 
        &nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font> 
      </td>
    </tr>
<!--	  
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%">SY/TERM</td>
      <td width="31%">
<%
strTemp = WI.fillTextValue("sy_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("stud_ledg","sy_from","sy_to")'>
        - 
<%
strTemp = WI.fillTextValue("sy_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
		<option value="">ALL</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select></td>
      <td width="52%"><a href="fines.htm"><img src="../../images/form_proceed.gif"border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1" color="#00CCFF"></td>
    </tr>
-->  </table> 
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("CAL_OD_FINE");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
%>	  <input type="checkbox" name="CAL_OD_FINE" value="1"<%=strTemp%>>
        Calculate Overdue Fines&nbsp;&nbsp; </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="94%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("INCLUDE_GD");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="INCLUDE_GD" value="1"<%=strTemp%>>
        Include Grace Days in Calculation</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("INCLUDE_CD");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="INCLUDE_CD" value="1"<%=strTemp%>>
        Include Closed Days in Calculation</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("USE_MAX_FINE");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="checkbox" name="USE_MAX_FINE" value="1"<%=strTemp%>>
        Use Max. Fine Set in the Borrowing Parameter if Cost of Item is 
        not specified</td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="50">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./fine_implementation.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
<%}%>	
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="26" colspan="5" class="thinborder"> <div align="center"><font color="#FF0000"><strong>LIST 
          OF FINE IMPLEMENTATION SETUP PARAMETERS </strong></font></div></td>
    </tr>
    <tr> 
      <td width="21%" height="27" class="thinborder"><div align="center"><strong><font size="1">CALCULATE 
          OVERDUE FINES </font></strong></div></td>
      <td width="19%" class="thinborder"><div align="center"><strong><font size="1">GRACE 
          DAYS INCLUDED</font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>CLOSED 
          DAYS INCLUDED</strong></font></div></td>
      <td width="17%" class="thinborder"><div align="center"><font size="1"><strong>MAX. 
          FINE SET USE</strong></font></div></td>
      <td width="23%" class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 8){%>
    <tr> 
      <td height="25" class="thinborder" align="center">
	  <%if( ((String)vRetResult.elementAt(i + 4)).compareTo("1") ==0){%>
	  <img src="../../../images/tick.gif" border="1"><%}else{%>
	  <img src="../../../images/x_small.gif" border="1"><%}%>
	  </td>
      <td class="thinborder" align="center">
	  <%if( ((String)vRetResult.elementAt(i + 5)).compareTo("1") ==0){%>
	  <img src="../../../images/tick.gif" border="1"><%}else{%>
	  <img src="../../../images/x_small.gif" border="1"><%}%>
	  </td>
      <td class="thinborder" align="center">
	  <%if( ((String)vRetResult.elementAt(i + 6)).compareTo("1") ==0){%>
	  <img src="../../../images/tick.gif" border="1"><%}else{%>
	  <img src="../../../images/x_small.gif" border="1"><%}%>
	  </td>
      <td class="thinborder" align="center">
	  <%if( ((String)vRetResult.elementAt(i + 7)).compareTo("1") ==0){%>
	  <img src="../../../images/tick.gif" border="1"><%}else{%>
	  <img src="../../../images/x_small.gif" border="1"><%}%>
	  </td>
      <td class="thinborder" align="center">
        <%
if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a> 
        <%}if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a> 
        <%}%>
        </td>
    </tr>
<%}//end of for loop%>
  </table>
<%}//vretResult is not null.%>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  </form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>