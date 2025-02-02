<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
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
function HideFine() {
	if(document.form_.CHECK_OUT.selectedIndex == 0) {//show
		showLayer('hide_1');
		showLayer('hide_2');
		showLayer('hide_3');
		showLayer('hide_4');
		showLayer('hide_5');		
	}
	else {//hide
		hideLayer('hide_1');
		hideLayer('hide_2');
		hideLayer('hide_3');
		hideLayer('hide_4');
		hideLayer('hide_5');			
	}
}
</script>

<%@ page language="java" import="utility.*,lms.MgmtCatalog,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-CATALOGING","circ_type.jsp");
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
														"LIB_Administration","CATALOGING",request.getRemoteAddr(),
														"circ_type.jsp");
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

	MgmtCatalog mgmtCirType = new MgmtCatalog();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtCirType.operateOnCirculationType(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtCirType.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Circulation type successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Circulation type successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Circulation type successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = mgmtCirType.operateOnCirculationType(dbOP, request,4);	
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtCirType.operateOnCirculationType(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtCirType.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC" onLoad="HideFine();">
<form action="./circ_type.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING MANAGEMENT - CIRCULATION TYPE PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr > 
      <td width="2%" height="25"></td>
      <td width="21%">Circulation Type Code</td>
      <td colspan="2"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("CTYPE_CODE");
%> <input name="CTYPE_CODE" type="text"  class="textbox" maxlength="16" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="16" value="<%=strTemp%>"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Description</td>
      <td height="25" colspan="2"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("DESCRIPTION");
%> <input name="DESCRIPTION" type="text"  class="textbox" maxlength="48" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="48" value="<%=strTemp%>"> 
      </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">For Check-out</td>
      <td height="25" colspan="2"> <select name="CHECK_OUT" onClick="HideFine();">
          <option value="1">Yes</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("CHECK_OUT");

if(strTemp.compareTo("0") == 0) {%>
          <option value="0" selected>No</option>
          <%}else{%>
          <option value="0">No</option>
          <%}%>
        </select></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Fine if overdue</td>
      <td height="25" colspan="2"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("FINE_OD");
%> <input name="FINE_OD" type="text" class="textbox" size="6"
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>" id="hide_1"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <%
if(strTemp == null || strTemp.length() == 0) 
	strTemp = " checked";
else
	strTemp = "";
%> <input type="checkbox" name="checkbox1" value="checkbox" id="hide_2"<%=strTemp%>>
        N/A </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Computation Parameter</td>
      <td height="25" colspan="2"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("COMPUTE_PARAM");
%> <input name="COMPUTE_PARAM" type="text" class="textbox" size="6"
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>" id="hide_3"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="PARAM_UNIT" id="hide_4">
          <option value="0">hour</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("PARAM_UNIT");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>day</option>
          <%}else{%>
          <option value="1">day</option>
          <%}%>
        </select> <input type="checkbox" name="checkbox2" value="checkbox" id="hide_5">
        N/A </td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr > 
      <td height="56">&nbsp;</td>
      <td height="56" colspan="2"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./circ_type.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries</font></td>
      <td width="25%" valign="bottom"><div align="right"><font size="1"><img src="../../images/print.gif" > 
          <font size="1">click to print list</font></font
        ></div></td>
    </tr>
<%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="7" bgcolor="#DDDDEE" class="thinborder"><div align="center">LIST 
          OF EXISTING CIRCULATION TYPE</div></td>
    </tr>
    <tr> 
      <td width="11%" height="25" class="thinborder"><div align="center"><font size="1"><strong>CIRCULATION 
          TYPE CODE</strong></font></div></td>
      <td width="31%" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>FOR 
          CHECK-OUT</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>FINE 
          IF OVERDUE</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>COMP. 
          PARAMETER</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>NO. 
          OF COPIES IN DATABASE</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
    <%
String[] astrConvertYESNO = {"<b>NO</b>","<b>YES</b>"};
String[] astrConvertUnit = {" HOUR(S)"," DAY(S)"};
for(int i = 0; i < vRetResult.size(); i += 8){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" align="center"><%=astrConvertYESNO[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 4))%></td>
      <td class="thinborder">&nbsp;
	  <%if(vRetResult.elementAt(i + 5) != null) {%>
	  <%=(String)vRetResult.elementAt(i + 5)%> 
	  <%=astrConvertUnit[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%>
	  <%}%>
	  </td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 7),"Not created")%></td>
      <td width="16%" class="thinborder"><div align="center">
          <%
if(iAccessLevel > 1){%>
          <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a> 
          <%}if(iAccessLevel == 2){%>
          <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a> 
          <%}%>
        </div></td>
    </tr>
    <%}%>
  </table>
<%}//if vRetResult != null%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  </form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>