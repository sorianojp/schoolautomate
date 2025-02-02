<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function checkAll()
{
	var maxDisp = document.form_.max_disp.value;
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i) {
		if(document.form_.selAll.checked)
			eval('document.form_.checkbox'+i+'.checked = true');
		else
			eval('document.form_.checkbox'+i+'.checked = false');
	}

}
function ReloadPage()
{
	this.SubmitOnce('form_');		
}
function UpdateLedgHist()
{
	document.form_.update_.value = "1";
	document.form_.show_result.value = "1";
	
	document.form_.info_index.value = ""
	this.ReloadPage();
}
function ShowResult() {
	document.form_.update_.value = "";
	document.form_.show_result.value = "1";
	
	document.form_.info_index.value = "";
	this.ReloadPage();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DeleteInfo(strInfoIndex) {
	//I have to first ask verification
	var vProceed = 
	confirm("Before removing outstanding balance information please check Installment payment if student is getting the displayed amount as extra amount. Click OK to remove information or Click Cancel to cancel operation");
	if(!vProceed)
		return;
		
	document.form_.info_index.value = strInfoIndex;

	document.form_.update_.value = "";
	document.form_.show_result.value = "1";
	this.ReloadPage();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Program fix-update back account fix",
								"insert_ledg_history_info.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = 2;
	//iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
		//												"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
			//											 null);
}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
AllProgramFix progFix = new AllProgramFix();
if(WI.fillTextValue("update_").length() > 0) {
	progFix.insertInLedgHistory(dbOP, request);
	strErrMsg = progFix.getErrMsg();
}
if(WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("show_result").length() > 0) {
	vRetResult = progFix.getLegdHistoryMissingInfo(dbOP, WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"), WI.fillTextValue("stud_id"),WI.fillTextValue("show_bk_actn"));
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = progFix.getErrMsg();
}	

int iMaxDisp = 0; 

%>


<form name="form_" action="./insert_ledg_history_info.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          BACK ACCOUNT FIX ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">NOTE: Enter school year information to check 
        if student has back account forwarded.</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%" height="25">SY/Term</td>
      <td width="42%"> <%
if(WI.fillTextValue("sy_from").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else
	strTemp = WI.fillTextValue("sy_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
        <%
if(WI.fillTextValue("sy_to").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
else
	strTemp = WI.fillTextValue("sy_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
if(WI.fillTextValue("semester").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
else
	strTemp = WI.fillTextValue("semester");

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td width="44%"><a href="javascript:ShowResult();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Stud. ID</td>
      <td colspan="2"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="30" height="22" border="0"></a>(Optional, 
        enter to check only one student)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="2"><input type="checkbox" name="show_bk_actn" value="1">
        Show back account information of first 25 entries (this will show down 
        the process)</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{
boolean bolShowBkActn = false;
if(WI.fillTextValue("show_bk_actn").compareTo("1") == 0) 
	bolShowBkActn = true;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" align="center" bgcolor="#3366FF" class="thinborder"><font color="#FFFFFF"><b> 
        ::: LIST OF STUDENT HAVING ERROR IN BALANCE FORWARDING ::: COUNT : <%=vRetResult.size()/6%></b></font></td>
    </tr>
    <tr> 
      <td width="27%" height="25" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>STUDENT 
          ID</strong></font></div></td>
      <td width="30%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>FROM SY</strong></font></div></td>
      <%if(bolShowBkActn){%>
	  <td width="21%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>BACK 
          ACCOUNT</strong> </font></div></td><%}%>
      <td width="22%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>UPDATE<br>
          SELECT ALL 
          <input type="checkbox" name="selAll" value="0" onClick="checkAll();">
          </strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 6, ++iMaxDisp) {%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%> - <%=(String)vRetResult.elementAt(i + 3)%> 
	  (<%=dbOP.getHETerm(Integer.parseInt((String)vRetResult.elementAt(i + 4)))%>)</td>
      <%if(bolShowBkActn){%><td class="thinborder"><div align="center">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></div></td><%}%>
      <td class="thinborder"><div align="center">
          <input type="checkbox" name="checkbox<%=iMaxDisp%>" value="1">
		  <input type="hidden" name="stud_index<%=iMaxDisp%>" value="<%=(String)vRetResult.elementAt(i)%>">
		  <input type="hidden" name="sy_from<%=iMaxDisp%>" value="<%=(String)vRetResult.elementAt(i + 2)%>">
		  <input type="hidden" name="sy_to<%=iMaxDisp%>" value="<%=(String)vRetResult.elementAt(i + 3)%>">
		  <input type="hidden" name="semester<%=iMaxDisp%>" value="<%=(String)vRetResult.elementAt(i + 4)%>">
        </div></td>
    </tr>
<%}%>
    <tr> 
      <td height="45" colspan="4" align="center" class="thinborder" valign="bottom">
	  <a href="javascript:UpdateLedgHist();"><img src="../../../images/save.gif" border="0"></a>Click to update ledger information.</td>
    </tr>
  </table>
<%}//only if vRetResult is not null

//get here ledg history information having advance insert. 
if(WI.fillTextValue("info_index").length() > 0) {
	vRetResult = progFix.operateOnLedgHistInfoInsInAdvance(dbOP, request, 0);
}
else
	vRetResult = progFix.operateOnLedgHistInfoInsInAdvance(dbOP, request, 4);

if(vRetResult != null && vRetResult.size() > 0) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr><td>&nbsp;</td></tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="3" align="center" bgcolor="#3366FF" class="thinborder"><font color="#FFFFFF"><b> 
        ::: LIST OF STUDENT HAVING ERROR IN BALANCE FORWARDING(advance forwarded) 
        ::: COUNT : <%=vRetResult.size()/3%></b></font></td>
    </tr>
    <tr> 
      <td width="34%" height="25" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>STUDENT 
          ID</strong></font></div></td>
      <td width="55%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT 
          FORWARDED </strong></font></div></td>
      <td width="11%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><strong>FIX</strong></div></td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 3) {%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><div align="center"><a href="javascript:DeleteInfo(<%=(String)vRetResult.elementAt(i)%>);">
	  <img src="../../../images/delete.gif" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
<%}%>

<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="show_result">
<input type="hidden" name="update_">
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
