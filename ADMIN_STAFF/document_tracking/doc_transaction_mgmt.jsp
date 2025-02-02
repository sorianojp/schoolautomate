<%@ page language="java" import="utility.*, docTracking.deped.TransactionManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Document Transaction Management</title></head>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
	function FocusField(){
		document.form_.origin.focus();
	}
	
	function ReloadPage(){
		document.form_.page_action.value   ='';
		document.form_.info_index.value    ='';
		document.form_.prepareToEdit.value ='';
		
		document.form_.submit();
	}
	
	function loadSearchDept() {
		var objCOA=document.getElementById("load_search_dept");
 		var objCollegeInput = document.form_.search_college[document.form_.search_college.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=search_dept&all=1&onchange=loadResponsiblePersonnel";
		this.processRequest(strURL);
	}

	function loadResponsiblePersonnel() {

		var objCOA=document.form_.referred_to;
 		var objCollegeInput = document.form_.search_college[document.form_.search_college.selectedIndex].value;
 		var objDeptInput = "";
		if(document.form_.search_dept)
			objDeptInput = document.form_.search_dept[document.form_.search_dept.selectedIndex].value;
		if(objCollegeInput.length == 0) 
			return;
		if(objCollegeInput == '0') 
			return;
		
		
		this.InitXmlHttpObject(objCOA, 1);//I want to get value.
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=127&col_ref="+objCollegeInput+"&dep_ref=";
		if(objDeptInput.length > 0)
			strURL += objDeptInput;
		
		//alert(strURL);
		this.processRequest(strURL);
	}

	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this doc transaction?'))
				return;
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
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
	
	function RefreshPage() {
		location = "./doc_transaction_mgmt.jsp";
	}
	
	function ShowHideInfo(strShow, strDivName){
		if(strShow == "1")
			document.getElementById(strDivName).style.visibility = "visible";		
		else
			document.getElementById(strDivName).style.visibility = "hidden";		
	}
	function copyComments() {
		document.form_.comments.value = document.form_.comment_preload[document.form_.comment_preload.selectedIndex].value;
		document.form_.comment_preload.selectedIndex = 0;
	}
		
</script>
<script language="JavaScript">
var openImg = new Image();
openImg.src = "../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","doc_transaction_mgmt.jsp");
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
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-MANAGE TRANSACTIONS"),"0"));
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	String strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	Vector vEditInfo = null;
	Vector vRetResult = null;
	
	TransactionManagement transMgmt = new TransactionManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(transMgmt.operateOnDocTransaction(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = transMgmt.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Document transaction removed successfully.";
			else if(strTemp.equals("1"))
				strErrMsg = "Document transaction recorded successfully.";
			else
				strErrMsg = "Document transaction edited successfully.";
		
			strPrepareToEdit = "0";
		}
	}
	
	int iSearchResult = 0;
	vRetResult = transMgmt.operateOnDocTransaction(dbOP, request, 4);
	if(vRetResult == null){
		if(strTemp.length() == 0)
			strErrMsg = transMgmt.getErrMsg();
	}
	else
		iSearchResult = transMgmt.getSearchCount();
		
	if(strPrepareToEdit.equals("1")){
		vEditInfo = transMgmt.operateOnDocTransaction(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = transMgmt.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="doc_transaction_mgmt.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: DOCUMENT TRANSACTION MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
<!--
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Transaction Date/Time </td>
		  <td>
<%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(21);
	else {
		strTemp = WI.fillTextValue("trans_date");
		if(strTemp.length() == 0)
			strTemp = WI.getTodaysDate(1);
	}
%>
		<input name="trans_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.trans_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>
		  
<%
String[] strTime = {"7 AM","7:15 AM", "7:30 AM","7:45 AM","8 AM", "8:15 AM", "8:30 AM", "8:45 AM","9 AM", "9:15 AM", "9:30 AM", "9:45 AM",
"10 AM", "10:15 AM", "10:30 AM", "10:45 AM","11 AM", "11:15 AM", "11:30 AM", "11:45 AM","12 PM", "12:15 PM", "12:30 PM", "12:45 PM",//24
"1 PM", "1:15 PM", "1:30 PM", "1:45 PM","2 PM", "2:15 PM", "2:30 PM", "2:45 PM","3 PM", "3:15 PM", "3:30 PM", "3:45 PM","4 PM", "4:15 PM", "4:30 PM", "4:45 PM",//40
"5 PM", "5:15 PM", "5:30 PM", "5:45 PM","6 PM", "6:15 PM", "6:30 PM", "6:45 PM","7 PM", "7:15 PM", "7:30 PM", "7:45 PM",//52
"8 PM", "8:15 PM", "8:30 PM", "8:45 PM","9 PM", "9:15 PM", "9:30 PM", "9:45 PM"};//60
double[] dTime = {7,7.25,7.5,7.45,8,8.25,8.5,8.45,9,9.25,9.5,9.45,10,10.25,10.5,10.45,11,11.25,11.5,11.45,12,12.25,12.5,12.45,13,13.25,13.5,13.45,
14,14.25,14.5,14.45,15,15.25,15.5,15.45,16,16.25,16.5,16.45,17,17.25,17.5,17.45,18,18.25,18.5,18.45,19,19.25,19.5,19.45,20,20.25,20.5,20.45,21,21.25,21.5,21.45};
%>		  Time : 
<%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(27);
	else {
		strTemp = WI.fillTextValue("trans_time");
	}
double dDefTime = 0d;
if(strTemp != null && strTemp.length() > 0) 
	dDefTime = Double.parseDouble(strTemp);
%>
		  <select name="trans_time">
		  <%for(int i = 0; i <60; ++i){
		  //System.out.println(" Print 1 : "+dDefTime);
		  //System.out.println(" Print 2 : "+dTime[i]);
		  if(dDefTime == dTime[i])
		  	strTemp = " selected";
		  else	
		  	strTemp = "";%>
		  	<option value="<%=dTime[i]%>" <%=strTemp%>><%=strTime[i]%></option>
		  <%}%> 
		  </select>		  </td>
	  </tr>

		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Document Date </td>
		  <td>
<%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(27);
	else {
		strTemp = WI.fillTextValue("doc_date");
		if(strTemp.length() == 0)
			strTemp = WI.getTodaysDate(1);
	}
%>
		<input name="doc_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.doc_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>
		  </td>
	  </tr>
-->
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Origin/Owner: </td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("origin");
				%>
				<input type="text" name="origin" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="256" value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Document Catg: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("catg_index");
				%>
				<select name="catg_index">
					<option value="">Select Category</option>
					<%=dbOP.loadCombo("catg_index", "catg_name", " from doc_deped_catg where is_valid = 1 order by catg_name", strTemp, false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Document Details: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("doc_name");
				%>
				<input type="text" name="doc_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="512" value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Barcode ID : </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("barcode_id");
				%>
				<input type="text" name="barcode_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Referred to Offce: </td>
			<td>
				<%
					String strCollegeCon = WI.fillTextValue("search_college");
					if(vEditInfo != null && vEditInfo.size() > 0)
						strCollegeCon = WI.getStrValue((String)vEditInfo.elementAt(14));
				%>
				<select name="search_college" onChange="loadSearchDept();" onblur="loadResponsiblePersonnel();">
					<option value="0">ALL</option>
					<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 order by c_name", strCollegeCon, false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Referred to Dept: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(15));
					else
						strTemp = WI.fillTextValue("search_dept");
				%>
				<label id="load_search_dept">
				<select name="search_dept" onChange="loadResponsiblePersonnel();">
         			<option value="">ALL</option>
          		<%if ((strCollegeCon.length() == 0) || strCollegeCon.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null) order by d_name", strTemp, false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeCon + " order by d_name ", strTemp, false)%> 
         		 <%}%>
  	   			</select></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Responsible Personnel: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(16);
					else
						strTemp = WI.fillTextValue("referred_to");
				%>
				<input type="text" name="referred_to" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="128" value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Comments:</td>
			<td>
			<select name="comment_preload" onChange="copyComments();" style="font-size:11px; color:#0000FF; font-weight:bold; width:500px;">
					<option value="">Copy Comment</option>
					<%=dbOP.loadCombo("distinct DOC_DEPED_TRANSACTION.Comments","DOC_DEPED_TRANSACTION.COMMENTS", " from DOC_DEPED_TRANSACTION where is_valid =1 order by COMMENTS", null, false)%> 
        		</select>
			<br />
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(13));
					else
						strTemp = WI.fillTextValue("comments");
				%>
				<textarea name="comments" class="textbox" cols="65" rows="2" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" style="font-size:12px"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td valign="middle">
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
					<font size="1">Click to save category.</font>
				    <%}else {
					if(vEditInfo!=null){%>
						<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../images/edit.gif" border="0"></a>
						<font size="1">Click to edit category.</font>
					    <%}
				}%>
				<a href="javascript:RefreshPage();"><img src="../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			<%}else{%>
				Not authorized to save document transaction information.
			<%}%></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		    <td height="15" colspan="2" align="center">
			<div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')" align="left"> <img src="../../images/box_with_plus.gif" border="0" id="folder1">
  				<strong>Search Conditions</strong></div>
				<span class="branch" id="branch1">  
				<table width="70%" border="0" cellpadding="0" cellspacing="0" bgcolor="#cccccc" class="thinborder">
						<tr>
							<td width="30%" class="thinborder">Document Category: </td>
							<td width="70%" class="thinborder">				
								<select name="catg_index_search">
									<option value="">Select Category</option>
									<%=dbOP.loadCombo("catg_index", "catg_name", " from doc_deped_catg where is_valid = 1 order by catg_name", WI.fillTextValue("catg_index_search"), false)%>
								</select></td>
						</tr>
						<tr>
							<td class="thinborder">Origin/Owner:</td>
							<td class="thinborder">
								<input type="text" name="origin_search" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
									onblur="style.backgroundColor='white'" size="48" maxlength="256" value="<%=WI.fillTextValue("origin_search")%>"/></td>
						</tr>
						<tr>
							<td class="thinborder">Document Name: </td>
							<td class="thinborder"><input type="text" name="doc_name_search" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
									onblur="style.backgroundColor='white'" size="48" maxlength="256" value="<%=WI.fillTextValue("doc_name_search")%>"/></td>
						</tr>
						<tr>
							<td class="thinborder">Responsible Personnel: </td>
							<td class="thinborder"><input type="text" name="resp_personnel_search" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
									onblur="style.backgroundColor='white'" size="48" maxlength="128" value="<%=WI.fillTextValue("resp_personnel_search")%>"/></td>
						</tr>
						<tr>
							<td class="thinborder">Barcode No.: </td>
							<td class="thinborder">
								<!--if this is filled up, then we will use the equals condition-->
								<input type="text" name="barcode_id_search" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
									onblur="style.backgroundColor='white'" size="48" maxlength="32" value="<%=WI.fillTextValue("barcode_id_search")%>"/></td>
						</tr>
						<tr>
							<td class="thinborder">Process Status:</td>
							<td class="thinborder">
								<select name="trans_status_search">
									<option value="">Select Status</option>
								<%strTemp = WI.fillTextValue("trans_status_search");
								if(strTemp.equals("0")){%>
									<option value="0" selected>Pending</option>
								<%}else{%>
									<option value="0">Pending</option>
								<%}if(strTemp.equals("1")){%>
									<option value="1" selected>Completed</option>
								<%}else{%>
									<option value="1">Completed</option>
								<%}%>
								</select></td>
						</tr>
						<tr>
							<td class="thinborder">Release Status:</td>
							<td class="thinborder">
								<select name="release_status_search">
									<option value="">Select Status</option>
								<%strTemp = WI.fillTextValue("release_status_search");
								if(strTemp.equals("0")){%>
									<option value="0" selected>Unreleased</option>
								<%}else{%>
									<option value="0">Unreleased</option>
									
								<%}if(strTemp.equals("1")){%>
									<option value="1" selected>Released</option>
								<%}else{%>
									<option value="1">Released</option>
								<%}%>
								</select></td>
						</tr>
						<tr>
							<td class="thinborder">Transaction Date: </td>
							<td class="thinborder">
								<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
									class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
								<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
									onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
								<img src="../../images/calendar_new.gif" border="0"></a>
								-  
								<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
									value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
								<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
									onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
								<img src="../../images/calendar_new.gif" border="0"></a></td>
						</tr>
						<tr>
							<td class="thinborder">&nbsp;</td>
							<td class="thinborder">
								<%
									strTemp = WI.fillTextValue("view_all");
									if(strTemp.length() > 0)
										strTemp = "checked";
								%>
								<input type="checkbox" name="view_all" value="1" <%=strTemp%> />View All</td>
						</tr>
						<tr>
						  <td class="thinborder">&nbsp;</td>
						  <td class="thinborder"><input type="button" name="_Search" value="Search Transaction" onclick="ReloadPage();">						  </td>
				  </tr>
					</table>	
				</span>			</td>
	    </tr>
		<tr>
			<td height="15">&nbsp;</td>
		    <td height="15" colspan="2">&nbsp;</td>
	    </tr>
		<tr>
		  <td height="15" colspan="3">&nbsp;</td>
	  </tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF EXISTING TRANSACTION(S) IN RECORD ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(transMgmt.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/transMgmt.defSearchSize;		
				if(iSearchResult % transMgmt.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+transMgmt.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ReloadPage();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}}%></td>
		</tr>
		<tr>
			<td height="25" width="25%" align="center" class="thinborder"><strong>Document Name </strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Origin/Owner</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Category</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Barcode ID</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Transaction Date </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		int iCurrentStep = 0;
		int iComplete = 0;
		
		//I have to check if max days exceeded.. 
		int iMaxDays   = 0;
		int iDaysTaken = 0;//days taken.. 
		String strRowColor = null;
		
		for(int i = 0; i < vRetResult.size(); i += 29, iCount++){
			iCurrentStep = Integer.parseInt((String)vRetResult.elementAt(i+17));
			iComplete = Integer.parseInt((String)vRetResult.elementAt(i+18));

			iDaysTaken = 0;strRowColor = "";
			if(vRetResult.elementAt(i + 21) != null)
				iDaysTaken = ConversionTable.differenceInDays((String)vRetResult.elementAt(i + 21), WI.getTodaysDate(1));
				
			//System.out.println(iDaysTaken);
			
			if(vRetResult.elementAt(i + 28) != null && iComplete != 1 && iDaysTaken > 0) {
				iMaxDays = Integer.parseInt((String)vRetResult.elementAt(i + 28));
				if(iMaxDays > 0) {
					if(iDaysTaken > iMaxDays)
						strRowColor =" bgcolor='#FF5555'";
				}
			}
			
	%>
		<tr <%=strRowColor%>>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				if(strTemp.length() > 27){
					strErrMsg = strTemp.substring(0, 27);
					if(strTemp.length() > 0)
						strErrMsg += "...";
						
					strTemp = "1";
				}
				else{
					strErrMsg = strTemp;
					strTemp = "";
				}
			%>
			<td class="thinborder">&nbsp;<%=strErrMsg%>
				<%if(strTemp.equals("1")){%>
					<a href="javascript:ShowHideInfo('1', 'info_<%=iCount%>');"><font color="#FF0000">[<u>more</u>]</font></a>
				<%}%>
				<div id="info_<%=iCount%>" style="position:absolute; visibility:hidden; width:600px; overflow:auto">
					<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
					<tr>
						<td width="88%"><strong><%=(String)vRetResult.elementAt(i+5)%></strong>&nbsp;</td>
						<td width="12%" align="center">
							<a href="javascript:ShowHideInfo('0', 'info_<%=iCount%>');">
							<strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
					</tr>
					</table>
				</div></td>
	  	  	<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>			
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+22)), 4)%></td>	
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){
				if(iComplete < 1){if(iCurrentStep > 0){%><font style="font-size:9px; font-weight:bold;color:#0000FF">In Progress</font><br /><%}%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../images/delete.gif" border="0" /></a>
					<%}
				}else{
					if(iComplete == 0)
						strTemp = "In Progress";
					else
						strTemp = "Completed";
				%>
					<%=strTemp%>
				<%}
			}else{%>
				N/A
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>