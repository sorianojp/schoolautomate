<%@ page language="java" import="utility.*, docTracking.deped.DocReceiveRelease, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Release Document</title></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

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

		var objCOA=document.form_.responsible_personnel;
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

	function FocusField(){
		document.form_.barcode_id.focus();
	}
	
	function SearchBarcode(strKeyCode){
		if(strKeyCode == '13'){
			document.form_.release_transaction.value = "";
			document.form_.submit();	
		}
	}
	
	function releaseTransaction(){
		if(!confirm("Continue with forwarding this transaction to another office?"))
			return;
			
		document.form_.page_action.value = "1";
		document.form_.release_transaction.value = "1";
		document.form_.submit();
	}
	
	function closeTransaction(){
		if(!confirm("Continue with completing/closing this transaction?"))
			return;
	
		document.form_.page_action.value = "2";
		document.form_.release_transaction.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","transaction_release.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-RECEIVE RELEASE"),"0"));
	
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
	
	Vector vInfo = null;
	int iCurrentStep = 0;
	DocReceiveRelease drr = new DocReceiveRelease();
	
	if(WI.fillTextValue("barcode_id").length() > 0){
		vInfo = drr.getTransactionInformation(dbOP, request);
		if(vInfo == null)
			strErrMsg = drr.getErrMsg();
		else
			iCurrentStep = Integer.parseInt((String)vInfo.elementAt(19));
	}
	
	//check if already completed.
	if(vInfo != null){
		if(((String)vInfo.elementAt(14)).equals("1")){
			strErrMsg = "Document transaction already completed.";
			vInfo = null;
		}
	}
	
	if(vInfo != null){
		if(!drr.checkIfProperOffice(dbOP, request, (String)vInfo.elementAt(0))){
			vInfo = null;
			strErrMsg = drr.getErrMsg();
		}
	}
	
	//check rr status
	if(vInfo != null){
		int iRRStatus = drr.getRRStatus(dbOP, request, (String)vInfo.elementAt(0), iCurrentStep);
		if(iRRStatus == -1){
			strErrMsg = drr.getErrMsg();
			vInfo = null;
		}
		if(iRRStatus == 0){
			strErrMsg = "Document not yet received.";
			vInfo = null;
		}
		else if(iRRStatus == 2){
			strErrMsg = "Document already received.";
			vInfo = null;
		}
	}
	
	if(vInfo != null){
		if(WI.fillTextValue("release_transaction").length() > 0){
			if(!drr.releaseTransaction(dbOP, request, (String)vInfo.elementAt(0), Integer.parseInt(WI.fillTextValue("page_action"))))
				strErrMsg = drr.getErrMsg();
			else{
				vInfo = null;
				strErrMsg = "Document successfully released.";
			}
		}
	}
%>
<body bgcolor="#D2AE72" onload="FocusField();">
<form name="form_" action="transaction_release.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: RELEASE DOCUMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Barcode ID: </td>
			<td width="80%">
				<input type="text" name="barcode_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("barcode_id")%>"
					onkeyup="javascript:SearchBarcode(event.keyCode);"/></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:SearchBarcode('13');"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click here to search barcode.</font></td>
		</tr>
	</table>
	
<%if(vInfo != null && vInfo.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Origin/Owner:</td>
			<td width="80%"><%=(String)vInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Transaction Date: </td>
			<td><%=(String)vInfo.elementAt(16)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Document Name: </td>
			<td rowspan="2" valign="top"><%=(String)vInfo.elementAt(4)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="3"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Notes:</td>
		  	<td>
				<textarea name="note" style="font-size:12px" cols="60" rows="2" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("note")%></textarea></td>
		</tr>		
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong>Option 1 :: Forward to another office.</strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Forward to Dept: </td>
			<td>
				<%
					String strCollegeCon = WI.fillTextValue("search_college");
				%>
				<select name="search_college" onChange="loadSearchDept();" onblur="loadResponsiblePersonnel();">
          			<option value="0">ALL</option>
          			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 order by c_name", strCollegeCon, false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Forward to Office: </td>
			<td>
				<%
					strTemp = WI.fillTextValue("search_dept");
				%>
				<label id="load_search_dept">
				<select name="search_dept" onChange="loadResponsiblePersonnel();">
         			<option value="">ALL</option>
          		<%if ((strCollegeCon.length() == 0) || strCollegeCon.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null) order by d_name", strTemp, false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeCon + " order by d_name", strTemp, false)%> 
         		 <%}%>
  	   			</select></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Responsible Personnel: </td>
			<td>
				<input type="text" name="responsible_personnel" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="128" value="<%=WI.fillTextValue("responsible_personnel")%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td><a href="javascript:releaseTransaction();"><img src="../../images/save.gif" border="0" /></a>
				<font size="1">Click to forward document to another office.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong>Option 2 :: Complete/close this transaction.</strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td><a href="javascript:closeTransaction();"><img src="../../images/save.gif" border="0" /></a>
				<font size="1">Click to complete/close this transaction.</font></td>
		</tr>
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
	
	<input type="hidden" name="release_transaction" />
	<input type="hidden" name="page_action" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>