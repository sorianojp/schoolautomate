<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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
function UpdateCirType(strPatTypeIndex, strPatronName) {
	var pgLoc = "./circulation_type_param.jsp?patron_type_index="+strPatTypeIndex+
	"&patron_type="+escape(strPatronName);
	//pop up here. 
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.info_index.value = "";
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
								"lms-Administration-CIRCULATION","borrowing_param.jsp");
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
														"borrowing_param.jsp");
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
		if(mgmtBP.operateOnBorrowingParam(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtBP.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Borrowing parameter successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Borrowing parameter successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Borrowing parameter successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = mgmtBP.operateOnBorrowingParam(dbOP, request,4);	
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtBP.operateOnBorrowingParam(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtBP.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC">
<form action="./borrowing_param.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION MANAGEMENT - BORROWING PARAMETER SETUP PAGE ::::</strong></font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Patron Type</td>
      <td colspan="2">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("PATRON_TYPE_INDEX");
%>
	  <select name="PATRON_TYPE_INDEX">
          <option value="">General (for all)</option>
          <%=dbOP.loadCombo("PATRON_TYPE_INDEX","PATRON_TYPE"," from LMS_PATRON_TYPE order by PATRON_TYPE_INDEX asc",strTemp, false)%> </select></td>
      <td>
	  <a href='javascript:Help("../../../onlinehelp/lms_circulation_setting.htm");'><img src="../../../images/online_help.gif" border="0"> Help</a></td>
    </tr>
    <tr> 
      <td height="19" colspan="5"><hr size="1" color="#0000BB"></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%">Borrowing(Loan)</td>
      <td width="19%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("MAX_BORROW");
%><input type="text" name="MAX_BORROW" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> </td>
      <td width="16%">Maximum Fine</td>
      <td width="42%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("MAX_FINE");
%>	  <input type="text" name="MAX_FINE" size="8" maxlength="8" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress="if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Allowable Overdue</td>
      <td><%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("MAX_OVER_DUE");
%>
        <input type="text" name="MAX_OVER_DUE" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td>Reservation</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("MAX_RES");
%>	  <input type="text" name="MAX_RES" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fixed Borrowing Due</td>
      <td><%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("BORROWING_DUE");
%>
        <input name="BORROWING_DUE" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.getStrValue(strTemp)%>">
        <a href="javascript:show_calendar('form_.BORROWING_DUE');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>Reservation Priority</td>
      <td><select name="RES_PRIORITY">
		<option value="1" selected>High</option>
<%

if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("RES_PRIORITY");

if(strTemp.compareTo("2") == 0){%>
		<option value="2" selected>Medium</option>
<%}else{%>
		<option value="2">Medium</option>
<%}if(strTemp.compareTo("3") == 0){%>
		<option value="3" selected>Medium-Low</option>
<%}else{%>
		<option value="3">Medium-Low</option>
<%}if(strTemp.compareTo("4") ==0){%>
		<option value="4" selected>Low</option>
<%}else{%>
		<option value="4">Low</option>
<%}%>
	  </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Ceiling Due Date</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("OVER_RIDE_DD");
%>	  <input name="OVER_RIDE_DD" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.getStrValue(strTemp)%>"> 
        <a href="javascript:show_calendar('form_.OVER_RIDE_DD');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="50">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./borrowing_param.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
<%}%>	
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="26" colspan="10" class="thinborder"> <div align="center"><font color="#FF0000"><strong>LIST 
          OF PATRON TYPE MAX. BORROWING SETUP PARAMETERS </strong></font></div></td>
    </tr>
    <tr> 
      <td width="14%" height="25" class="thinborder"><div align="center"><strong><font size="1">PATRON 
          TYPE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">BORROWING(LOAN)</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">FIXED BORROWING 
          DUE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">ALLOWABLE OVERDUE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">OVERRIDE DUE 
          DATE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">FINES</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">MAX. 
          RESERVE</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">RES. PRIORITY</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>CIRCULATION TYPE 
          PARAM.</strong></font></div></td>
      <td width="10%" class="thinborder">&nbsp;</td>
    </tr>
<%
String[] astrConvertResPriority = {"","High","Medium","Medium-Low","Low"};
for(int i = 0; i < vRetResult.size(); i += 10){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"General(for all)")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 5))%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 8)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 9))%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=astrConvertResPriority[Integer.parseInt((String)vRetResult.elementAt(i + 7))]%></font></td>
      <td class="thinborder"><div align="center">
	  <a href='javascript:UpdateCirType("<%=WI.getStrValue(vRetResult.elementAt(i +1))%>",
	  	"<%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"General(for all)")%>");'>
	  <img src="../../images/update.gif" border="0"></a></div></td>
      <td align="center" class="thinborder">
<%
if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a>
<%}if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a>
<%}%>
	  </td>
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