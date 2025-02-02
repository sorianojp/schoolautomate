<%@ page language="java" import="utility.*,java.util.Vector,hr.PersonnelAssetManagement"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Issued Item Status</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script src="../../../../Ajax/ajax.js"></script>
<script src="../../../../jscript/date-picker.js"></script>
<script src="../../../../jscript/td.js"></script>
<script src="../../../../jscript/common.js"></script>
<script language="javascript">

function CancelOperation(){
	document.form_.page_action.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.prepareToEdit.value = "";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function PrintPg() {
	document.form_.print_page.value = "1";
	document.form_.submit()
}

function PrepareToEdit(strInfoIndex) {
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function checkAllSave() {
	var maxDisp = document.form_.item_count.value;
	var bolIsSelAll = document.form_.selAllSave.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function SearchEmployee(){	
	if(document.form_.emp_id.value == '') {
		alert("Please enter employee ID.");
		return;
	}
	document.form_.searchEmployee.value="1";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

var objCOA;
var objCOAInput;
function AjaxMapName(strFieldName, strLabelID) {
	objCOA=document.getElementById(strLabelID);
	var strCompleteName = eval("document.form_."+strFieldName+".value");
	eval('objCOAInput=document.form_.'+strFieldName);
	if(strCompleteName.length <= 2) {
		objCOA.innerHTML = "";
		return ;
	}		
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
	"&name_format=4&complete_name="+escape(strCompleteName);
	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	objCOAInput.value = strID;
	objCOA.innerHTML = "";
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete these items?'))
			return;
	}
	document.form_.page_action.value = strAction;
	if(strAction == '1') 
		document.form_.prepareToEdit.value='';
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.searchEmployee.value='1';
	document.form_.print_page.value = "";
	document.form_.submit();
}

</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	int i = 0;
	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./issued_asset_status_print.jsp" />
	<% 
		return;}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL ASSET MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel Asset Management-Issued Asset Status","issued_asset_status.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

	Vector vRetResult = null;
	Vector vEditInfo = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	PersonnelAssetManagement  pam = new PersonnelAssetManagement();
	
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0){
		if(pam.operateOnIssuedItemStatus(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = pam.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = " Items removed successfully.";
			if(strTemp.equals("10"))
				strErrMsg = " Items returned successfully.";
			if(strTemp.equals("2"))
				strErrMsg = " Item edited successfully.";
			strPrepareToEdit = "0";
		}
	}

	if(WI.fillTextValue("searchEmployee").length() > 0){
	    vRetResult = pam.operateOnIssuedItemStatus(dbOP, request, 4);
		if(vRetResult == null && strTemp.length() == 0)
			strErrMsg = pam.getErrMsg();
		else
			iSearchResult = pam.getSearchCount();
	}
	
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = pam.operateOnIssuedItemStatus(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = pam.getErrMsg();
	}	
	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="document.form_.emp_id.focus()">
<form action="./issued_asset_status.jsp" method="post" name="form_">
  <table width="100%"  border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A" class="footerDynamic" align="center"><font color="#FFFFFF" ><strong>:::: ISSUED ASSET STATUS PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td colspan="2"><a href="../pam_main.jsp" ><img src="../../../../images/go_back.gif" border="0" align="right"></a></td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td>
      <td height="43">EMPLOYEE ID </td>
      <td width="20%" height="43">
	  <input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onKeyUp="AjaxMapName('emp_id','coa_info');" value="<%=WI.fillTextValue("emp_id")%>"
		onBlur="style.backgroundColor='white'" size="16" ></td>
      <td width="4%" align="center"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" name="add_1" border="0"></a></td>
      <td width="54%">&nbsp;
          <label id="coa_info"></label></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:SearchEmployee();">
          <font size="1">click to display issued item list to print.</font></td>
    </tr>
    <tr>
      <td colspan="5" height="15"></td>
    </tr>

<%if(vEditInfo != null && vEditInfo.size() > 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Issued by: </td>
      <td ><input name="issued_by" type="text" size="16" value="<%=WI.getStrValue((String)vEditInfo.elementAt(7),"")%>" class="textbox"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName('issued_by','issued_by_');"></td>
		<td colspan="2"><label id="issued_by_"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date Issued: </td>
     	 <%
			strTemp = WI.fillTextValue("date_fr");
			if(strTemp.length() == 0) 
				strTemp = WI.getTodaysDate(1);
		%>
      <td colspan="3"><input name="date_fr" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp; <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
			<img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
	  <td height="25">&nbsp;</td>
      <td>Reason:</td>
      <td colspan="3"><textarea name="reason" style="font-size:12px" cols="65" rows="6" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue((String)vEditInfo.elementAt(11),"")%></textarea></td>
    </tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="3">
			<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');"><img src="../../../../images/edit.gif" border="0"></a>
			<a href="javascript:CancelOperation();"><img src="../../../../images/cancel.gif" border="0"></a>

		</td>
	</tr>
	<%}//end of vEditInfo%>
  </table>
 <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
 
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
	<%
			strTemp = WI.fillTextValue("returned_date");
			if(strTemp.length() == 0) 
				strTemp = WI.getTodaysDate(1);
	%>
	<tr>
		<td height="25" width="15%"><strong>Returned Date: </strong></td>
		<td width="66%">
			<input name="returned_date" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
       		&nbsp; <a href="javascript:show_calendar('form_.returned_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0"></a>		</td>
	    <td width="19%" align="right">
		<a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a>
		<font size="1">click to print</font></font></td>
	</tr>
	<tr>
		<td colspan="3">&nbsp;</td>
	</tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
		<%
			iSearchResult = pam.getSearchCount();
			int iPageCount = iSearchResult/pam.defSearchSize;		
			if(iSearchResult % pam.defSearchSize > 0) ++iPageCount;
		%>
			<td width="66%"><strong>TOTAL RESULT: <%=iSearchResult%> - Showing(<%=pam.getDisplayRange()%>)</strong></td>
		<%
			if(iPageCount > 1){
		%>
		    <td width="34%"><div align="right"><font size="2">Jump To page:
				<select name="jumpto" onChange="SearchEmployee();">
		<%
			strTemp = WI.fillTextValue("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) 
				strTemp = "0";
			i = Integer.parseInt(strTemp);
			if(i > iPageCount)
				strTemp = Integer.toString(--i);
			
			for(i =1; i<= iPageCount; ++i ){
				if(i == Integer.parseInt(strTemp) ){
		%>
			<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
		<%}else{%>
			<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
		<%}
	}%>
		</select>
		</font></div></td>
		</tr>
		<%}%>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<tr> 
	  	<td height="20" colspan="11" bgcolor="#B9B292" class="thinborder" align="center"><strong>LIST OF ITEMS </strong></td>
	</tr>
    <tr>
		<td width="9%"  height="23" class="thinborder">&nbsp;</td>
		<td width="18%" align="center" class="thinborder"><strong><font size="1">PROPERTY #. </font></strong></td>
		<td width="18%" align="center" class="thinborder"><strong><font size="1">DATE ISSUED </font></strong></td>
		<td width="18%" align="center" class="thinborder"><strong><font size="1">ISSUED TO </font></strong></td>
		<td width="18%" align="center" class="thinborder"><strong><font size="1">ISSUED BY </font></strong></td> 
		<td width="18%" align="center" class="thinborder"><strong><font size="1">RETURN STATUS</font></strong></td>
		<td width="8%" align="center" class="thinborder"><strong><font size="1">EDIT</font></strong></td>
		<td width="6%"  align="center" class="thinborder">
			<font size="1"><strong>SELECT ALL<br>
			</strong>
	      <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked></font>		  </td>
    </tr>
	<% 
		int iCount = 1;
	  		for (i = 0; i < vRetResult.size(); i+=14,iCount++){
	%>
    <tr>
    	<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
    	<td class="thinborder"><%=(String)vRetResult.elementAt(i+13)%></td>
     	<td class="thinborder"><%=vRetResult.elementAt(i+6)%></td>
      	<td class="thinborder">
		<%=WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%>
		</td>
      	<td class="thinborder">
		<%=WebInterface.formatName((String)vRetResult.elementAt(i+8),(String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10),7)%>
		</td> 
      	<td height="25" class="thinborder" align="center">
			<select name="return_status_<%=iCount%>">
			<%if (WI.fillTextValue("return_status_"+iCount).equals("1")){%>
				<option value="1" selected>OK</option>
				<option value="2">Damaged</option>
				<option value="3">Lost</option>
			<%}else if (WI.fillTextValue("return_status_"+iCount).equals("2")){%>
				<option value="1">OK</option>
				<option value="2" selected>Damaged</option>
				<option value="3">Lost</option>
			<%}else if (WI.fillTextValue("return_status_"+iCount).equals("3")){%>
				<option value="1">OK</option>
				<option value="2">Damaged</option>
				<option value="3" selected>Lost</option>
			<%}else{%>
				<option value="1" selected>OK</option>
				<option value="2">Damaged</option>
				<option value="3">Lost</option>
			<%}%>
		  </select>	
		</td>
		 <input type="hidden" name="issue_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		 <input type="hidden" name="item_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+5)%>">
		 <input type="hidden" name="to_be_returned_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+12)%>">
   		 <td class="thinborder" align="center">
		 	<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../../images/edit.gif" border="0"></a>		  </td>
     	<td align="center" class="thinborder">
			<input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">
		</td>
   	</tr>
    	<%} //end for loop%>
		<input type="hidden" name="item_count" value="<%=iCount%>">
</table>

<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" align="center"> 
        <% if (iAccessLevel > 1){%>        
        <a href="javascript:PageAction('0','');"><img src="../../../../images/delete.gif" border="0"></a> 
		<a href="javascript:PageAction('10','');"><img src="../../../../images/update.gif" border="0"></a> 
        <%} // end iAccessLevel  > 1%></td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp;</td>
    </tr>
  </table>
 <%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="searchEmployee" >
<input type="hidden" name="info_index">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="print_page">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>