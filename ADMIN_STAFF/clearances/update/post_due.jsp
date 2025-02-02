<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src ="../../../jscript/common.js" ></script>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script>

<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	if(eval(document.form_.req_index.selectedIndex) > 0)
	  document.form_.ctype.value=document.form_.req_index[document.form_.req_index.selectedIndex].text;
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../HR/hr_updatelist.jsp?opner_form_name=form_&tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

-->
</script>
<%@ page language="java" import="utility.*, clearance.ClearanceMain, clearance.ClearanceType, enrollment.OfflineAdmission, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	Vector vStudInfo = null;
	Vector vAuthClr = null;
	
	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strErrMsg2 = null;
	String strTemp = null;
	String strTemp2 = null;
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearances-Clearance Update-Posting of Due/Requirement","post_due.jsp");
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
														"Clearances","Clearance Update",request.getRemoteAddr(),
														"post_due.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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

	ClearanceMain clrMain = new ClearanceMain();
	ClearanceType clrType  = new ClearanceType();
	OfflineAdmission offAdm = new OfflineAdmission();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(clrMain.operateOnClearancePosting(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = clrMain.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = clrMain.operateOnClearancePosting(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = clrMain.getErrMsg();
	}

			
	vRetResult = clrMain.operateOnClearancePosting(dbOP, request, 4);
	
	if (strErrMsg == null && WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0 && WI.fillTextValue("semester").length()>0)
		strErrMsg = clrMain.getErrMsg();

%>

<body bgcolor="#D2AE72">
<form action="post_due.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CLEARANCE DUE POSTING PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td >School Year / Term</td>
      <td width="80%"> <% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %> <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> <input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        / 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
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
        </select> &nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="30%"><font size="1">Type - Signatory - Sub Signatory</font></td>
      <td> 
       <select name="req_index" onChange="ReloadPage();">
        <%
			strTemp = WI.fillTextValue("req_index");
	  	vAuthClr = clrMain.retreiveAuthClearance(dbOP, request,1);
	  	if(vAuthClr != null && vAuthClr.size() > 0) {
		  for(int i = 0 ; i< vAuthClr.size(); i +=4){ 
			if( strTemp.compareTo((String)vAuthClr.elementAt(i)) == 0) {%>
        <option value="<%=(String)vAuthClr.elementAt(i)%>" selected><%=(String)vAuthClr.elementAt(i+1)%>&nbsp;-&nbsp;<%=(String)vAuthClr.elementAt(i+2)%>&nbsp;-&nbsp;<%=WI.getStrValue((String)vAuthClr.elementAt(i+3),"")%></option>
        <%}else{%>
        <option value="<%=(String)vAuthClr.elementAt(i)%>"><%=(String)vAuthClr.elementAt(i+1)%>&nbsp;-&nbsp;<%=(String)vAuthClr.elementAt(i+2)%>&nbsp;-&nbsp;<%=WI.getStrValue((String)vAuthClr.elementAt(i+3),"")%></option>
        <%}
			}
		   }%>
    </select></td>
    </tr>
  </table>
<%//if (WI.fillTextValue("signatory").length() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="4"><hr size="1" noshade></td>
    </tr>
    <tr valign="top"> 
      <td width="3%">&nbsp;</td>
      <td width="17%">Student ID</td>
	<%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		else		
			strTemp = WI.fillTextValue("stud_id");
		%>
      <td width="21%" height="25"><input name="stud_id" type="text" size="16" maxlength="16" class="textbox"
       onfocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"' value="<%=strTemp%>" onKeyUp="AjaxMapName('1');"> 
      </td>
      <td width="59%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      &nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
      
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
	  </td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1" noshade></td>
    </tr>
    <tr> 
	<%if (strTemp != null && strTemp.length() > 0)
		vStudInfo = offAdm.getStudentBasicInfo(dbOP,strTemp,WI.fillTextValue("sy_from"),
	  									WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));

	if (vStudInfo != null) {%>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Student Name : <strong><%=((String)vStudInfo.elementAt(0)+' '+(String)vStudInfo.elementAt(1)+' '+(String)vStudInfo.elementAt(2))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Course / Major : <strong><%=WI.getStrValue((String)vStudInfo.elementAt(8),((String)vStudInfo.elementAt(7)) + "/","",
	  (String)vStudInfo.elementAt(7))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Year Level : <strong><%=WI.getStrValue((String)vStudInfo.elementAt(14),"","","N/A")%></strong></td>
    </tr>
     <%}
	else{ strErrMsg2 = offAdm.getErrMsg();	%>
	<tr>
	<td colspan="4"><strong><%=WI.getStrValue(strErrMsg2)%></strong></td>
	</tr>
	<%}%>
    <tr> 
      <td height="10" colspan="4"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Action Implemented</td>
      <td height="25" colspan="2"> 
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(14);
		else		
			strTemp = WI.fillTextValue("action_index");
		%>
       <select name="action_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("ACTION_INDEX","ACTION_NAME"," from CLE_ACTION  order by ACTION_NAME asc", strTemp, false)%>
        </select><a href='javascript:viewList("CLE_ACTION","ACTION_INDEX","ACTION_NAME","ACTION IMPLEMENTED")'><img src="../../../images/update.gif" border="0"></a><font size="1">(enter 
        action to be or is implemented - ex. not allowed to borrow books etc.)</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1" noshade></td>
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(0);
		else		
			strTemp = WI.fillTextValue("stud_id");
		%>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="3"><font size="1">
      	
      	 <%
      	 String strPayType = null;
      	 
      	 if(vEditInfo != null && vEditInfo.size() > 0)
      	 {
			if (vEditInfo.elementAt(8)==null && vEditInfo.elementAt(9)==null)
			strPayType = "";
			if (vEditInfo.elementAt(8)!=null && vEditInfo.elementAt(9)==null)
			strPayType = "0";
			if (vEditInfo.elementAt(8)==null && vEditInfo.elementAt(9)!=null)
			strPayType = "1";
			if (vEditInfo.elementAt(8)!=null && vEditInfo.elementAt(9)!=null)
			strPayType = "2";
		}
		else		
		{
			strPayType = WI.fillTextValue("pay_type");
		}
		if(strPayType.compareTo("0") == 0)
			strTemp = "checked";
		else
			strTemp = "";
		%> 
      	<input type="radio" name="pay_type" value="0" onClick="ReloadPage();" <%=strTemp%>>Refund Cost of Item&nbsp;
      	<%
		if(strPayType.compareTo("1") == 0)
			strTemp = "checked";
		else
			strTemp = "";
		%> 
      	<input type="radio" name="pay_type" value="1" onClick="ReloadPage();" <%=strTemp%>>Refund Quantity of Item&nbsp;
  	  	<%
		if(strPayType.compareTo("2") == 0)
			strTemp = "checked";
		else
			strTemp = "";
		%> 
  	  	<input type="radio" name="pay_type" value="2" onClick="ReloadPage();" <%=strTemp%>>Both
  	  	<%if(strPayType.length() == 0)
			strTemp = "checked";
		else
			strTemp = "";
		%> 
  	  	<input type="radio" name="pay_type" value="" onClick="ReloadPage();" <%=strTemp%>>None
      </font></td>
    </tr>
    <%if (strPayType.compareTo("0")==0 || strPayType.compareTo("2")==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Payable</td>
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);
		else		
			strTemp = WI.fillTextValue("amount");
		%>
      <td  colspan="2" height="25"><input name="amount" type="text" id="amount" size="12" maxlength="12" class="textbox"
        onKeyUp= 'AllowOnlyFloat("form_","amount")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","amount");style.backgroundColor="white"' value="<%=strTemp%>">
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp2 = (String)vEditInfo.elementAt(21);
		else		
			strTemp2 = WI.fillTextValue("isPosted");
		
		if(strTemp2.compareTo("1") == 0)
			strTemp = "checked";
		else
			strTemp = "";
		%>     
        <input name="isPosted" type="checkbox" value="1" <%=strTemp%>>
        <font size="1">Post to Student Ledger</font> </td>
    </tr>
    <%}%>
   <%if (strPayType.compareTo("1")==0 || strPayType.compareTo("2")==0){%>
    <tr> 
      <td height="25"></td>
      <td height="25">Quantity </td>
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(9);
		else		
			strTemp = WI.fillTextValue("qty");
		%>
      <td  colspan="2" height="25"><input name="qty" type="text" id="qty" size="12" maxlength="12" class="textbox"
        onKeyUp= 'AllowOnlyInteger("form_","qty")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","qty");style.backgroundColor="white"' value="<%=strTemp%>">
        <font color="#FF0000" size="1"> 
         <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		else		
			strTemp = WI.fillTextValue("unit_index");
		if (strTemp==null)
			strTemp = "";
		%>
        <select name="unit_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("QTY_UNIT_INDEX","QTY_UNIT"," from CLE_QTY_UNIT  order by QTY_UNIT asc", strTemp, false)%>
        </select>
        <a href='javascript:viewList("CLE_QTY_UNIT","QTY_UNIT_INDEX","QTY_UNIT","QUANTITY UNITS")'>
        <img src="../../../images/update.gif" border="0"></a><font color="#000000">click 
        to update list of units</font> </font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24">Requirement</td>
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(13);
		else		
			strTemp = WI.fillTextValue("required_item");
		%>
      <td  colspan="2" height="24"><input name="required_item" type="text" id="required_item" size="64" maxlength="256" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Date Posted </td>
      <%
       if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
		else		
			//strTemp = WI.fillTextValue("post_date");

		 //if (strTemp == null || strTemp.length()==0)
        	  	strTemp = WI.getTodaysDate(1);
		%>
      <td  colspan="2" height="25"><input name="post_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <!--<a href="javascript:show_calendar('form_.post_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> -->
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp; </td>
      <td height="25" valign="middle"> Remarks</td>
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = WI.getStrValue(((String)vEditInfo.elementAt(12)),"");
		else		
			strTemp = WI.fillTextValue("remarks");
		%>
      <td  colspan="2" height="25"><textarea name="remarks" cols="50" rows="3" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Last Date to Clear </td>
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(16);
		else		
			strTemp = WI.fillTextValue("clr_date");
		%>
      <td  colspan="2" height="25"><input name="clr_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.clr_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
  
      
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit event <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%> </td>
    </tr>
    <tr> 
      <td colspan="4"></tr></tr>
  </table>
<%if (vRetResult != null && vRetResult.size()>0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="1">
	<tr bgcolor="#ABA37C"> 
		<td height="25" colspan="9" bgcolor="#B9B292"  class = "thinborder">
			<div align="center">LIST OF 
				STUDENTS <strong>NOT CLEARED</strong> FROM CLEARANCE <strong><%=WI.getStrValue(request.getParameter("ctype"))%></strong></div>
		</td>
	</tr>
	<tr> 
	<td width="18%" class="thinborder"><div align="center"><font size="1"><strong>SIGNATORY/<br>SUB SIGNATORY</strong></font></div>
		</td>
		<td width="10%" height="25" class = "thinborder">
			<div align="center"><font size="1"><strong>STUDENT 
				ID </strong></font></div>
		</td>
		<td width="15%" class = "thinborder">
			<div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div>
		</td>
		<td width="10%" class = "thinborder">
			<div align="center"><strong><font size="1">COURSE<br>/MAJOR</font></strong></div>
		</td>
		<td width="4%" class = "thinborder">
			<div align="center"><strong><font size="1">YEAR</font></strong></div>
		</td>
		<td width="15%" class = "thinborder">
			<div align="center"><strong><font size="1">DUE</font></strong></div>
		</td>
		<td width="15%" class = "thinborder">
			<div align="center"><strong><font size="1">REMARKS</font></strong></div>
		</td>
		<td width="13%" class = "thinborder" colspan = "2">&nbsp;</td>
	</tr>
	<%for (int i = 0; i<vRetResult.size(); i+=25){%>
	<tr> 
		<td class="thinborder"><font size="1">
		<%=WI.getStrValue((String)vRetResult.elementAt(i+22),"")%>&nbsp;-&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+23),"")%></font></td>
		<td height="25" class = "thinborder"><font size="1">
		<%if (i>0 && WI.getStrValue(vRetResult.elementAt(i+1)).compareTo(WI.getStrValue(vRetResult.elementAt(i-24)))==0){%>
			&nbsp; 	<%}else{%><%=WI.getStrValue(vRetResult.elementAt(i+1), "&nbsp;")%><%}%></font></td>
		<td class = "thinborder"><font size="1">
		<%if (i>0 && WI.getStrValue(vRetResult.elementAt(i+1)).compareTo(WI.getStrValue(vRetResult.elementAt(i-24)))==0){%>
			&nbsp; 	<%}else{%><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),7)%><%}%></font></td>
		<td class = "thinborder"><font size="1">
		<%if (i>0 && WI.getStrValue(vRetResult.elementAt(i+1)).compareTo(WI.getStrValue(vRetResult.elementAt(i-24)))==0){%>
			&nbsp; 	<%}else{%><%=WI.getStrValue((String)vRetResult.elementAt(i+6),((String)vRetResult.elementAt(i+5)) + "/","",
	  (String)vRetResult.elementAt(i+5))%><%}%></font></td>
		<td class = "thinborder"><font size="1"><div align="center">
		<%if (i>0 && WI.getStrValue(vRetResult.elementAt(i+1)).compareTo(WI.getStrValue(vRetResult.elementAt(i-22)))==0){%>
			&nbsp; 	<%}else{%><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","","N/A")%><%}%></div></td>
		<td class = "thinborder"><font size="1">
		Amount: <%=WI.getStrValue((String)vRetResult.elementAt(i+8),"","","NONE")%><br>
		Quantity: <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"","","NONE")%><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;","","&nbsp;")%>
		</font></td>
		<td class = "thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),"","","NONE")%></font></td>
		<td class = "thinborder"><div align="left"><font size="1"> 
        <% if(WI.getStrValue(vRetResult.elementAt(i+24)).equals("1") && (iAccessLevel ==2 || iAccessLevel == 3)) {%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        Not authorized to edit 
        <%}%>
        </font></div></td>
		<td class = "thinborder"><div align="left"><font size="1"> 
        <% if(WI.getStrValue(vRetResult.elementAt(i+24)).equals("1") && (iAccessLevel ==2)) {%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        Not authorized to delete 
        <%}%>
        </font></div></td>
	</tr>
<%}%>
</table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
      </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="ctype">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>