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
	function DeleteDocument(strInfoIndex){
		document.form_.delete_remark.value = prompt("Remarks to Delete");		
		document.form_.request_index.value = strInfoIndex;
		document.form_.page_action.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		location = "./release_document.jsp";
	}
	
	function PrintForm(){
		var pgLoc = "release_form_print.jsp?id_number="+document.form_.id_number.value;
		var win=window.open(pgLoc,"PrintForm",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function ReleaseDocument(strInfoIndex){
		document.form_.release_remark.value = prompt("Remarks to Release");		
		document.form_.request_index.value = strInfoIndex;
		document.form_.page_action.value = "2";
		document.form_.submit();
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
		
		if(document.form_.search_type.value=='1')
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
		document.form_.id_number.value = strIDNumber;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.doc_track_index.value = strDocTrackIndex;
		document.form_.transaction_no.value = strTransactionNo;
		document.form_.get_ajax.value = '1';
		document.form_.submit();
	}
	
	function getRequestInfo(){				
		document.form_.get_ajax.value = '1';
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Document Request Tracking","release_document.jsp");		
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
														"release_document.jsp");
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
	String strTransactionNo = WI.fillTextValue("transaction_no");
	String strIDNumber = WI.fillTextValue("id_number");
	String strUserIndex = null;
	boolean bolShowData = false;
	
	if(strIDNumber.length() > 0){
		strUserIndex = dbOP.mapUIDToUIndex(strIDNumber);		
        if (strUserIndex == null)
            strErrMsg = "User does not exist or is invalidated.";            
        else{		
			strTemp = " select count(*) from doc_track_main where is_valid = 1 and user_index = "+strUserIndex;
			strTemp = dbOP.getResultOfAQuery(strTemp,0);
			if(strTemp.equals("0"))
				strErrMsg = "ID number "+strIDNumber+ " has no existing request.";				
			else{
				bolShowData = true;
				strTemp = WI.fillTextValue("page_action");
				if(strTemp.length() > 0){
					if(strTemp.equals("1")){
						if(!docReq.deleteRequestItems(dbOP,request))
							strErrMsg = docReq.getErrMsg();
						else
							strErrMsg = "Document Request successfully deleted.";
					}else{
						if(!docReq.releaseRequestItems(dbOP,request))
							strErrMsg = docReq.getErrMsg();
						else
							strErrMsg = "Document Request successfully released.";
					}
						
				}			
			
				
				//vRetResult = docReq.isReadyForReleasing(dbOP, request, strTransactionNo);
				vRetResult = docReq.isReadyForReleasing(dbOP, request, strUserIndex);
				if(vRetResult == null)
					strErrMsg = docReq.getErrMsg();		
				
			}		
		}
	}
	

	

%>
<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="release_document.jsp">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>::::
        DOCUMENT REQUEST TRACKING ::::</strong></font></td>
    </tr>
</table>
<jsp:include page="./tabs.jsp?pgIndex=2"></jsp:include>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td width="3%" height="25">&nbsp;</td>
	<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
</tr>		
</table>

<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	<tr>
		<td></td>
		<td colspan="10"><font size="1">Click to view</font> &nbsp;  &nbsp; 
			<%
			String strRelease = "";
			strTemp = WI.fillTextValue("release_unrelease");
			if(strTemp.length() == 0 || strTemp.equals("0")){
				strErrMsg = "checked";
				strRelease = "0";
			}else
				strErrMsg = "";
			%>
			<input type="radio" value="0" name="release_unrelease" <%=strErrMsg%> onClick="getRequestInfo()">
			<font size="1">unreleased document</font>
			<%
			if(strTemp.equals("1")){
				strErrMsg = "checked";
				strRelease = "1";
			}
			else
				strErrMsg = "";
			%>
			<input type="radio" value="1" name="release_unrelease" <%=strErrMsg%> onClick="getRequestInfo()">
			<font size="1">released document</font>
		</td>
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">ID Number: </td>
		<td width="80%">				
			<input name="id_number" type="text" class="textbox"
	  			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  			onKeyUp="AjaxMapName();" value="<%=WI.fillTextValue("id_number")%>" size="16">				
				&nbsp;&nbsp;<label id="coa_info" style="width:300px; position:absolute"></label></td>
	</tr>

	<tr><td height="10" colspan="3"></td></tr>
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
		<td><a href="javascript:getRequestInfo();"><img src="../../../images/form_proceed.gif" border="0" /></a>
		<font size="1">Click to get request information.</font></td>
	</tr>
</table>

<%
if(vRetResult != null && vRetResult.size() > 0){%>
<%if(strRelease.equals("1")){%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>		
		<%
		strTemp = WI.fillTextValue("released_today");
		if(strTemp.equals("1"))
			strTemp = "checked";
		else
			strTemp = "";
		%>
		<td>
			<input type="checkbox" name="released_today" value="1" <%=strTemp%> onClick="document.form_.submit();">
			Click to view released today
		</td>
	</tr>
</table>
<%}%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#B9B292" >
		<td class="thinborder" height="23" colspan="10" align="center"><strong>LIST OF DOCUMENT REQUESTED</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="23" width="20%"><strong>DOCUMENT NAME</strong></td>
		<%
		if(strRelease.equals("0"))
			strTemp = "EXPECTED RELEASE";
		else
			strTemp = "RELEASED";
		%>
		<td class="thinborder" width="15%"><strong><%=strTemp%> DATE</strong></td>
		<td class="thinborder"><strong>REQUIREMENTS</strong></td>
		<td class="thinborder" width="20%"><strong>REMARKS</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>OPTION</strong></td>
	</tr>
	<%
	
	
	
	String strDocRequirement = "";	
	String strReleased = null;
	String strRemarks = "";
	Vector vReqList = new Vector();
	for(int i = 0; i < vRetResult.size(); i+=6){		
		strReleased = (String)vRetResult.elementAt(i+5);
		strDocRequirement = "";
		vReqList = (Vector)vRetResult.elementAt(i+3);
		if(vReqList.size() > 0) {
			for(int x = 0; x < vReqList.size(); x++){
				if((String)vReqList.elementAt(x) != null){
					if(strDocRequirement.length() == 0)
						strDocRequirement = (String)vReqList.elementAt(x)+";";
					else
						strDocRequirement += "<br>"+(String)vReqList.elementAt(x)+";";						
				}				
			}
		}
		
		
	%>
	<tr>
		<td class="thinborder" height="23"><%=((String)vRetResult.elementAt(i+1)).toUpperCase()%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(strDocRequirement.toUpperCase(),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
		<td class="thinborder" align="center">			
			<%if(strReleased.equals("0")){%>
				<a href="javascript:DeleteDocument('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
				<a href="javascript:ReleaseDocument('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/release-02-55x18.gif" border="0"></a>
			<%}else{%>
				RELEASED
			<%}%>
		</td>
	</tr>	
		<%strDocRequirement = "";
	}%>
</table>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="10"></td></tr>
	<tr><td align="center">
		<a href="javascript:ReloadPage();">
		<img src="../../../images/cancel.gif" border="0"></a>
		<font size="1">Click to clear data</font>
		<%
		if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("released_today").length() > 0){
		%>
		<a href="javascript:PrintForm();">
		<img src="../../../images/print.gif" border="0"></a>
		<font size="1">Click to print release form</font>
		<%}%>
	</td></tr>
</table>
<%}%>	

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>
	
	<input type="hidden" name="doc_track_index" value="<%=WI.fillTextValue("doc_track_index")%>"/>
	<input type="hidden" name="transaction_no" value="<%=strTransactionNo%>"/>
	
	<input type="hidden" name="search_type"  value="1"/>
	<input type="hidden" name="delete_remark" value="<%=WI.fillTextValue("delete_remark")%>"/>
	<input type="hidden" name="release_remark" value="<%=WI.fillTextValue("release_remark")%>"/>
	<input type="hidden" name="request_index" value="<%=WI.fillTextValue("request_index")%>"/>
	<input type="hidden" name="page_action" value="" />
	<input type="hidden" name="get_ajax" value="<%=WI.fillTextValue("get_ajax")%>"  />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>