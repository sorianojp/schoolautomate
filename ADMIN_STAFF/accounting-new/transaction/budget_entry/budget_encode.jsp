<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
///for searching COA
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
		
function MapCOAAjax(strIsBlur,strCoaFieldName, strParticularFieldName) {
		var objCOA=document.getElementById("coa_info");
		
		var objCOAInput = document.form_.coa_index;
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa_index.value+"&coa_field_name=coa_index";
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	document.getElementById("coa_info").innerHTML = "<b>"+strAccountName+"</b>";
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();
}
</script>
<%@ page language="java" import="utility.*,Accounting.Transaction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null; String strTemp2=null; String strTemp3=null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","budget_encode.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-Transaction"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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
Transaction trans = new Transaction();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(trans.operateBudgetEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = trans.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = trans.operateBudgetEntry(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = trans.getErrMsg();
}
	
if(strPreparedToEdit.equals("1")) {
	vEditInfo = trans.operateBudgetEntry(dbOP, request, 3);
	if(vEditInfo != null) {//remove 3 elements.. 
		vEditInfo.removeElementAt(0);vEditInfo.removeElementAt(0);vEditInfo.removeElementAt(0);
	}
}

boolean bolIsPrintCalled = false;
if(WI.fillTextValue("print_pg").equals("1"))
	bolIsPrintCalled = true;
%>
<body onLoad="<%if(bolIsPrintCalled){%>window.print();<%}%>">
<form action="./budget_encode.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<%if(!bolIsPrintCalled){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          BUDGET ENTRY - ENCODE BUDGET PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">
	  	<!--<a href="budget_entry_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>-->
	  <span style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></span></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td width="6%" height="27">&nbsp;</td>
      <td width="15%">School Year</td>
      <td width="79%">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
-
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp; &nbsp; &nbsp; &nbsp;
<input type="submit" name="1232" value=" Refresh " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.page_action.value=''; document.form_.preparedToEdit.value='';document.form_.budget_amount.value='';document.form_.remark.value=''"></td>
    </tr>
    <tr> 
      <td height="27" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td width="6%" height="25">&nbsp;</td>
      <td width="15%">College</td>
      <td width="79%">
<select name="c_index" onChange="document.form_.page_action.value='';document.form_.submit()">
        <option value="0"></option>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("c_index");

if(strTemp == null || strTemp.trim().length() == 0) 
	strTemp = "0";
if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
        <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%=strTemp2%></td>
      <td>
<select name="d_index" <%=strTemp2%>>
	<option value="">ALL</option>
<%
strTemp3 = "";
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp3 = (String)vEditInfo.elementAt(4);
else
	strTemp3 = WI.fillTextValue("d_index");
%>
        <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Budget</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = ((Double)vEditInfo.elementAt(9)).toString();
else
	strTemp = WI.fillTextValue("budget_amount");
%>	  <input name="budget_amount" type="text" size="10" maxlength="10" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','budget_amount');"
	  onKeypress="AllowOnlyInteger('form_','budget_amount');"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top"><br>Remarks</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(10);
else
	strTemp = WI.fillTextValue("remark");
%>	  <textarea name="remark" rows="4" cols="70" class="textbox" style="font-size:11px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Account Number </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("coa_index");
%>
	  <input name="coa_index" type="text" size="26" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('0','coa_index','document.form_.particular');">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
    <tr> 
      <td height="50">&nbsp;</td>
      <td>&nbsp;</td>
      <td><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="123" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="submit" name="123" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="123" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.budget_amount.value='';document.form_.remark.value=''"></td>
    </tr>
<%}//show only if print is not called.
if(vRetResult != null && vRetResult.size() > 0) {if(!bolIsPrintCalled){%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right"><font size="1">
	  	<a href="javascript:document.form_.print_pg.value='1';document.form_.submit();"><img src="../../../../images/print.gif" border="0"></a>
			click to print list</font></td>
    </tr>
<%}%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30" colspan="2"><strong><font color="#0000FF">TOTAL BUDGET FOR 
        THE YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> : 
		<%=(String)vRetResult.remove(0)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="8" class="thinborder" align="center"><font color="#FFFFFF"><strong>
	  :: COLLEGES BUDGET :: </strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="8" class="thinborder"><font size="1"><strong>TOTAL BUDGET :
	  	<%=(String)vRetResult.remove(0)%></strong></font></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="15%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">COLLEGE/DEPT</td>
      <td width="15%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">ACCOUNT #</td>
      <td width="24%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">ACCOUNT NAME</td>
      <td width="12%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">TOTAL BUDGET</td>
      <td width="12%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">BUDGET USED </td>
      <td width="12%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">BALANCE</td>
<%if(!bolIsPrintCalled){%>
      <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">&nbsp;</td>
      <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">&nbsp;</td>
<%}%>
    </tr>
<%
String strDeptTopBudget    = (String)vRetResult.remove(0);

for(int i = 0; i < vRetResult.size();i += 13){
if(vRetResult.elementAt(i + 3) == null)
	continue;
%>
    <tr> 
      <td class="thinborder" height="20"><%=(String)vRetResult.elementAt(i + 5)%>
	  	<%=WI.getStrValue((String)vRetResult.elementAt(i + 6)," :: ", "","")%> </td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder" align="right">
	  	<%=CommonUtil.formatFloat(	((Double)vRetResult.elementAt(i + 9)).doubleValue(), true)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 11)%></td>
      <td class="thinborder" align="right" style="color: #FF0000; font-weight:bold">
	  <%=CommonUtil.formatFloat(	((Double)vRetResult.elementAt(i + 12)).doubleValue(), true)%></td>
<%if(!bolIsPrintCalled){%>
      <td class="thinborder"><%if(iAccessLevel > 1) {%>
        <input type="submit" name="12" value="Edit" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
      <%}%></td>
      <td class="thinborder"><%if(iAccessLevel ==2 ) {%>
        <input type="submit" name="122" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
      <%}%></td>
<%}%>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
</table>
<%if(!strDeptTopBudget.equals("0.00")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: 
        OFFICES BUDGET :: </strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8" class="thinborder"><font size="1"><strong>TOTAL BUDGET :
	  <%=strDeptTopBudget%></strong></font></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="15%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">OFFICES </td>
      <td width="15%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">ACCOUNT #</td>
      <td width="24%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">ACCOUNT NAME</td>
      <td width="12%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">BUDGET APPROVED</td>
      <td width="12%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">BUDGET USED </td>
      <td width="12%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">BALANCE</td>
<%if(!bolIsPrintCalled){%>
      <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">&nbsp;</td>
      <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">&nbsp;</td>
<%}%>
    </tr>
<%
for(int i = 0; i < vRetResult.size();i += 13){
if(vRetResult.elementAt(i + 3) != null)
	continue;
%>
    <tr> 
      <td class="thinborder" height="20">
	  	<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> </td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder" align="right">
	  	<%=CommonUtil.formatFloat(	((Double)vRetResult.elementAt(i + 9)).doubleValue(), true)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 11)%></td>
      <td class="thinborder" align="right">
	  <%=CommonUtil.formatFloat(	((Double)vRetResult.elementAt(i + 12)).doubleValue(), true)%></td>
<%if(!bolIsPrintCalled){%>
      <td class="thinborder"><%if(iAccessLevel > 1) {%>
        <input type="submit" name="12" value="Edit" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">
      <%}%></td>
      <td class="thinborder"><%if(iAccessLevel ==2 ) {%>
        <input type="submit" name="122" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
      <%}%></td>
<%}%>
    </tr>
<%}//end of for loop.. 
}//only if strDeptTopBudget not equals 0.00%>

<%}//show only if vRetResult is not null..%> 
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="print_pg">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>