<%@ page language="java" import="utility.*, enrollment.DocRequestTracking, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">

</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="javascript">
	function CreateRequest(){
		document.form_.new_request.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPage(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.print_page.value = "";
		document.form_.page_action.value = "";
		document.form_.request_index.value = "";
		document.form_.delete_remark.value = "";
		document.form_.submit();	
	}
	
	function DeleteDocument(strInfoIndex){
		document.form_.delete_remark.value = prompt("Remarks to Delete");		
		document.form_.request_index.value = strInfoIndex;
		document.form_.print_page.value = "";
		document.form_.page_action.value = "1";
		document.form_.submit();
	}
	
	function RequestDocument(strInfoIndex){		
		document.form_.page_action.value = "2";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function ManageDocument(){
		var pgLoc = "document_management.jsp";
		var win=window.open(pgLoc,"ManageDocument",'width=900,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	
	var objCOA;
	var objCOAInput;
	function AjaxMapName() {
		var strCompleteName = document.form_.id_number.value;
		objCOAInput = document.getElementById("coa_info");
		
		eval('objCOA=document.form_.id_number');		
		if(strCompleteName.length < 2) {
			objCOAInput.innerHTML = "";
			return ;
		}
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}		
		
		if(document.form_.search_type.checked)
			var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);		
		else
			var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=40000&for_order=1&id_number="+escape(strCompleteName);

		this.processRequest(strURL);
	}
	function UpdateID(strID, strUserIndex) {		
		objCOA.value = strID;
		objCOAInput.innerHTML = "";
	}
	function UpdateName(strFName, strMName, strLName) {		
	}
	function UpdateNameFormat(strName) {
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function updateTransactionCode(strDocTrackIndex, strIDNumber, strTransactionNo){
		document.form_.print_page.value = "";
		document.form_.id_number.value = strIDNumber;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.doc_track_index.value = strDocTrackIndex;
		document.form_.transaction_no.value = strTransactionNo;
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./request_form_print.jsp"/>
	<%return;}
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Document Request Tracking","record_document_request.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp) {
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
														"Registrar Management","Document Request Tracking",request.getRemoteAddr(),
														"record_document_request.jsp");
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
	
	int iSearchResult = 0;
	
	DocRequestTracking docReq = new DocRequestTracking();
	Vector vRetResult = null;
	Vector vRequestItems = null;
	Vector vStudInfo = null;
	
		
	String strDocTrackIndex = WI.fillTextValue("doc_track_index");
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){		
		if(strTemp.equals("1")){
			if(!docReq.deleteRequestItems(dbOP,request))
				strErrMsg = docReq.getErrMsg();
			else
				strErrMsg = "Document Request successfully deleted.";
		}else{
			if(!docReq.addRequestItems(dbOP,request))
				strErrMsg = docReq.getErrMsg();
			else
				strErrMsg = "Document Request successfully added.";
		}
	}
	
	if(WI.fillTextValue("new_request").length() > 0){
		strDocTrackIndex = docReq.createNewRequest(dbOP, request);
		if(strDocTrackIndex == null){
			strErrMsg = docReq.getErrMsg();
			strDocTrackIndex = "";
		}		
	}
	
	if(strDocTrackIndex.length() > 0){
		vStudInfo = docReq.viewStudentInfo(dbOP, request, strDocTrackIndex);
		if(vStudInfo == null)
			strErrMsg = docReq.getErrMsg();
		else{
			vRequestItems = docReq.getRequestItems(dbOP, request, strDocTrackIndex);
			if(vRequestItems == null)
				strErrMsg = docReq.getErrMsg();					
		}
	}
	


%>
<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="record_document_request.jsp">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>::::
        DOCUMENT REQUEST TRACKING ::::</strong></font></td>
    </tr>
</table>
<jsp:include page="./tabs.jsp?pgIndex=1"></jsp:include>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td width="3%" height="25">&nbsp;</td>
	<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
</tr>		
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td height="25">&nbsp;</td>
		<td colspan="3">
			<input name="search_type" type="checkbox" value="1" checked onClick="javascript:AjaxMapName()">
			<font size="1">check to search students, uncheck to search student request</font></td>
	</tr>
	<tr>
		<td width="3%" height="23">&nbsp;</td>
		<td width="19%">Requester Type</td>
		<td width="78%">
		<select name="requester_type" onChange="document.form_.submit();">			
			<option value="1">Student/Faculty Request</option>
		<%
		strTemp = WI.getStrValue(WI.fillTextValue("requester_type"),"1");
		if(strTemp.equals("2"))
			strTemp = "selected";
		else
			strTemp = "";
		%>
		<option value="2" <%=strTemp%>>With Student/Faculty Permission</option>
	  </select></td>
	</tr>
	<%if(WI.fillTextValue("requester_type").length() > 0){
		if(WI.fillTextValue("requester_type").equals("2")){
	%>
	<tr>
		<td colspan="2">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("approval_");
		if(strTemp.equals("1"))
			strTemp = "checked";
		else
			strTemp = "";
		%>
		<td colspan="2"><input type="checkbox" name="approval_" value="1" <%=strTemp%>>
		<font size="1">Click if the requester has student approval.</font>
		</td>	
	</tr>
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td>Last Name:</td>
		<td><input type="text" name="req_lname" value="<%=WI.fillTextValue("req_lname")%>" class="textbox"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td>First Name:</td>
		<td><input type="text" name="req_fname" value="<%=WI.fillTextValue("req_fname")%>" class="textbox"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td>Middle Name:</td>
		<td><input type="text" name="req_mname" value="<%=WI.fillTextValue("req_mname")%>" class="textbox"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td>Relation to Student:</td>
		<td>
		<select name="req_relation_index">
			<option value=""></option>
          	<%=dbOP.loadCombo("relation_index","relation_name", " from HR_PRELOAD_RELATION", WI.fillTextValue("req_relation_index"), false)%>
        </select>
		</td>
	</tr>
	<tr><td colspan="3" height="11"></td>
	</tr>
	<%}
	}%>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>ID Number: </td>
		<td colspan="3">
			<input name="id_number" type="text" class="textbox"
	  			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  			onKeyUp="AjaxMapName();" value="<%=WI.fillTextValue("id_number")%>" size="16">	
			&nbsp;							
			<!--<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" align="absmiddle" height="28" width="37"></a>-->&nbsp;
			<label id="coa_info" style="width:300px; position:absolute"></label></td>
	</tr>
	<tr >
			<td height="25" >&nbsp;</td>
			<td>Transaction Date: </td>
			<%
				strTemp = WI.fillTextValue("transaction_date");
				if(strTemp.length() == 0) 
					strTemp = WI.getTodaysDate(1);
			%>
			<td>
				<input name="transaction_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.transaction_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
	</tr>
	<tr><td colspan="3" height="10"></td></tr>
	<tr><td colspan="2">&nbsp;</td><td><a href="javascript:CreateRequest();"><img src="../../../images/form_proceed.gif" border="0"></a></td></tr>
</table>
	
<%if(vStudInfo != null && vStudInfo.size() > 0){%>	
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="4" height="10"><hr size="1"></td></tr>
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td width="22%">Request Transaction No: </td>
		<td width="51%"><%=vStudInfo.elementAt(8)%></td>
	    <td width="24%"><div style="position:absolute"><img src="../../../upload_img/<%=WI.fillTextValue("id_number").toUpperCase()+"."+strImgFileExt%>" border="1" height="100" width="110"></div></td>
	</tr>
	
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td>Requester ID:</td>
		<td colspan="2"><%=WI.fillTextValue("id_number")%></td>
	</tr>
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td>Requester Name:</td>
		<td colspan="2"><%=vStudInfo.elementAt(0)%></td>
	</tr>

	<%
	if(((String)vStudInfo.elementAt(5)).equals("1")){%>
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td>Course & Year:</td>
		<td colspan="2"><%=vStudInfo.elementAt(6)%><%=WI.getStrValue((String)vStudInfo.elementAt(7),"-","","")%></td>
	</tr>
	
	<%}else{%>
	
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td>College:</td>
		<td colspan="2"><%=WI.getStrValue((String)vStudInfo.elementAt(9))%></td>
	</tr>
	<tr>
		<td height="23" width="3%">&nbsp;</td>
		<td>Department:</td>
		<td colspan="2"><%=WI.getStrValue((String)vStudInfo.elementAt(10))%></td>
	</tr>
	<%}%>
</table>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="3" height="10"></td></tr>
	<tr>
		<td width="3%" height="23">&nbsp;</td>
		<td width="17%"><strong>Select Document Here</strong></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td height="35">&nbsp;</td>
		<td>&nbsp;</td>
		<td>
		<select name="doc_index">
			<option value=""></option>
			<%=dbOP.loadCombo("doc_index","doc_type", " from doc_management where is_valid = 1", WI.fillTextValue("doc_index"), false)%>
		</select>
		&nbsp; 
		<a href="javascript:ManageDocument();"><img src="../../../images/update.gif" border="0" align="absbottom"></a>
		<font size="1">Click to update documents</font>
		</td>
	</tr>
	<tr>
		<td height="23">&nbsp;</td>
		<td>&nbsp;</td>
		<td>
		<a href="javascript:RequestDocument();">
		<img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save requested document</font>
		<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
		<font size="1">Click to refresh page</font>
		</td>
	</tr>
	<tr><td colspan="3" height="10"></td></tr>
</table>
	
	
<%if(vRequestItems != null && vRequestItems.size() > 0){%>	
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td class="thinborder" colspan="10" align="center" height="23"><strong>LIST OF REQUESTED DOCUMENT(S)</strong></td></tr>
	<tr>
		<td class="thinborder" height="23" width="20%"><strong>Document Type</strong></td>
		<td class="thinborder" width="15%"><strong>Release Date</strong></td>
		<td class="thinborder"><strong>Requirements</strong></td>
		<td class="thinborder" width="15%"><strong>Option</strong></td>
	</tr>
	<%
	
	String strCurrDoc = "";
	String strPrevDoc = "";
	String strReleaseDate = "";
	String strDocRequirement = "";
	int iIndexOf = 0;
	boolean bolDisplayData = false;
	String strReleased = null;
	
	for(int i = 0; i < vRequestItems.size(); i+=6){		
		strCurrDoc = (String)vRequestItems.elementAt(i+1);		
		strReleaseDate = (String)vRequestItems.elementAt(i+2);
		strReleased = (String)vRequestItems.elementAt(i+5);
		if((String)vRequestItems.elementAt(i+4) != null){
			if(strDocRequirement.length()==0)
				strDocRequirement = (String)vRequestItems.elementAt(i+4)+";";
			else
				strDocRequirement += "<br>"+(String)vRequestItems.elementAt(i+4)+";";
		}
		
		iIndexOf = i + 7;
		if(iIndexOf > vRequestItems.size())
			iIndexOf = iIndexOf - 7;
		
		strPrevDoc = (String)vRequestItems.elementAt(iIndexOf);
			
		if(!strPrevDoc.equals(strCurrDoc))
			bolDisplayData = true;
		else
			bolDisplayData = false;			
			
		if(bolDisplayData){				
			bolDisplayData = false;
			
	%>
	<tr>
		<td class="thinborder" height="23" width="20%"><%=strCurrDoc.toUpperCase()%></td>
		<td class="thinborder" width="15%"><%=strReleaseDate.toUpperCase()%></td>
		<td class="thinborder"><%=WI.getStrValue(strDocRequirement.toUpperCase(),"&nbsp;")%></td>
		<td class="thinborder" width="15%">
		<%if(strReleased.equals("0")){%>
			<a href="javascript:DeleteDocument('<%=(String)vRequestItems.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
		<%}else{%>
			RELEASED
		<%}%>
		</td>
	</tr>
		<%strDocRequirement = "";}
	}%>
	
</table>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td colspan="10" align="center">
	<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
	<font size="1">Click to print request document(s)</font>
</td></tr>
</table>

<%}%>
	
<%}%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>
	
	<input type="hidden" name="doc_track_index" value="<%=strDocTrackIndex%>"/>
	<input type="hidden" name="transaction_no" value="<%=WI.fillTextValue("transaction_no")%>"/>
	<input type="hidden" name="new_request" />
	
	
	<input type="hidden" name="delete_remark" value="<%=WI.fillTextValue("delete_remark")%>"/>
	<input type="hidden" name="request_index" value="<%=WI.fillTextValue("request_index")%>"/>
	<input type="hidden" name="page_action" value="" />
	<input type="hidden" name="print_page" value="" />
	
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>