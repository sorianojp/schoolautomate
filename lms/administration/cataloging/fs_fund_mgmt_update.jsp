<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+
	"&label="+escape(labelname)+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
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
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.submit();
}
function ChangeLevel(strLabel,strLabel2) {
	document.form_.allo_type_label.value = strLabel;
	document.form_.allo_type_label2.value = strLabel2;
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
								"lms-Administration-CATALOGING","fs_fund_mgmt_update.jsp");
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
														"fs_fund_mgmt_update.jsp");
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

	MgmtCatalog mgmtLedg = new MgmtCatalog();
	Vector vEditInfo  = null;Vector vRetResult = null;
	Vector vFSInfo    = null;//Funding source information, -> code, name and status.
	
	request.setAttribute("funding_source_index",WI.fillTextValue("funding_source_index"));
	vFSInfo = mgmtLedg.operateOnFSProfile(dbOP, request,3);
	if(vFSInfo == null)
		strErrMsg = mgmtLedg.getErrMsg();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0 && strErrMsg == null) {
		if(mgmtLedg.operateOnFSLedger(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtLedg.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Funding source ledger information successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Funding source ledger information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Funding source ledger information successfully edited.";

			strPrepareToEdit = "0";
		}
	}

if(vFSInfo != null && vFSInfo.size() > 0){
	vRetResult = mgmtLedg.operateOnFSLedger(dbOP, request,4);	
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtLedg.operateOnFSLedger(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtLedg.getErrMsg();
	}
}//only if vFSInfo is not null.

int iEntryType = 0;
%>

<body bgcolor="#DEC9CC">
<form action="./fs_fund_mgmt_update.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING MANAGEMENT - FUNDING SOURCE - FUNDS MANAGEMENT - UPDATE PAGE 
          ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
  </table>
<%
//outmost loop
if(vFSInfo != null && vFSInfo.size() > 0){
	String[] astrFSStat = {"In-active","Active"};
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td width="3%" height="25"></td>
      <td width="10%">F S Code</td>
      <td width="28%"><font size="1"><strong><%=(String)vFSInfo.elementAt(1)%></strong></font
        ></td>
      <td width="59%">Status: <font size="1"><strong><%=astrFSStat[Integer.parseInt((String)vFSInfo.elementAt(3))]%></strong></font> </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">F S Name</td>
      <td height="25" colspan="2"><font size="1"><strong><%=(String)vFSInfo.elementAt(2)%></strong></font
        ></td>
    </tr>
    <tr > 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">School Year/Term</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
}
strTemp = WI.getStrValue(strTemp);
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ledger_old","sy_from","sy_to")'>
        to 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
}

strTemp = WI.getStrValue(strTemp);
%>        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        <select name="semester">
          <option value="1">1st Sem</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
}
strTemp = WI.getStrValue(strTemp);
if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3")==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> 
<%
strTemp = WI.fillTextValue("view_all");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>        <input type="checkbox" name="view_all" value="1"<%=strTemp%>>
        View complete ledger<font size="1"><a href='javascript:ReloadPage();'><img src="../../../images/refresh.gif" border="1"></a></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><u>NEW ALLOCATION/EXPENSE ENTRY</u></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Entry type</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("entry_type");
if(strTemp.length() == 0 || strTemp.compareTo("0") == 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input type="radio" name="entry_type" value="0"<%=strTemp%> onClick='ChangeLevel("Allocation Type","Allocation");'> Received(donation) 
<%
if(strTemp.length() == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>		<input type="radio" name="entry_type" value="1"<%=strTemp%> onClick='ChangeLevel("Expense Type","Expense");'> Spent (used in purchasing)</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">
<%
if(strTemp.length() == 0) {
	strTemp = "Allocation Type";
	iEntryType = 0;
}
else {	
	strTemp = "Expense Type";
	iEntryType = 1;
}
%>
	  <input type="text" name="allo_type_label" value="<%=strTemp%>" size="20" readonly="yes"
	  style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;font-size:12px;border=0px;background:#DEC9CC;color=#000080">
      </td>
      <td width="77%" height="25"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("ALLOC_TYPE_INDEX");
%>
 <select name="ALLOC_TYPE_INDEX">
   <%=dbOP.loadCombo("ALLOC_TYPE_INDEX","ALLOCATION_TYPE"," from LMS_FS_ALLOC_TYPE order by ALLOC_TYPE_INDEX asc",strTemp, false)%> 
  </select> 
  <font size="1"><a href='javascript:viewList("LMS_FS_ALLOC_TYPE","ALLOC_TYPE_INDEX","ALLOCATION_TYPE","ALLOCATION TYPE <br> Do not modify Cash or Book Allocation type");'><img src="../../images/update.gif" border="0"></a></font></td>
    </tr>
    <tr > 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="20%" height="25">
<%
if(iEntryType == 0) {
	strTemp = "Allocation";
}
else {	
	strTemp = "Expense";
}
%>	  <input type="text" name="allo_type_label2" value="<%=strTemp%>" size="20" readonly="yes"
	  style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;font-size:12px;border=0px;background:#DEC9CC;color=#000080"></td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("amount");
%>	  <input name="amount" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        (Foreign currency should be converted to local currency)</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Details (if any)</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("detail");
%>        <input name="detail" type="text"  class="textbox" maxlength="256" 
	  onFocus="style.backgroundColor='#D3EBFF'"onBlur="style.backgroundColor='white'" size="64" value="<%=strTemp%>">
        </td>
    </tr>
<% if(iAccessLevel > 1){%>
    <tr > 
      <td height="56">&nbsp;</td>
      <td height="56"><font size="1">&nbsp; </font> <div align="right"></div></td>
      <td height="56"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./fs_fund_mgmt_update.jsp?view_all=1&funding_source_index=<%=WI.fillTextValue("funding_source_index")%>"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries</font> </td>
    </tr>
    <%}%>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td height="25" colspan="6" bgcolor="#DDDDEE" class="thinborder"><div align="center">FUNDING 
          SOURCE DETAILS <strong></strong></div></td>
    </tr>
    <tr> 
      <td width="14%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SCHOOL 
          YEAR/TERM</strong></font></div></td>
      <td width="43%" height="25" class="thinborder"><div align="center"><font size="1"><strong> 
          TYPE (DESCRIPTION)</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>ALLOCATION</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>EXPENSE</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>BALANCE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
    <%
	String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	for(int i = 0; i < vRetResult.size(); i += 12){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%> - <%=(String)vRetResult.elementAt(i + 2)%><br>
      &nbsp;<%=astrConvertToSem[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%> 
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 8), "(",")","")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 9))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 10))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 11))%></td>
      <td class="thinborder"> <div align="center">
          <%
if(iAccessLevel > 1){%>
          <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a> 
          <%}if(iAccessLevel == 2){%>
          <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a> 
          <%}%>
        </div></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<%}//only if vRetResult is not null

}//only if if(vFSInfo != null && vFSInfo.size() > 0)//outer most loop.%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="funding_source_index" value="<%=WI.fillTextValue("funding_source_index")%>">
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>