<%@ page language="java" import="utility.*,hr.HRManpowerMgmt,java.util.Vector" %>
<%  
    WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolMyHome = false;	
	if (WI.fillTextValue("my_home").equals("1")) {
		bolMyHome = true;
		strColorScheme = CommonUtil.getColorScheme(9);
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.page_action.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage(){		
	document.form_.printPage.value = "";
	document.form_.pageReloaded.value = "1";
	document.form_.page_action.value = "1";	
	this.SubmitOnce('form_');
}

function PageAction(strAction,strInfoIndex, strText){
	document.form_.printPage.value = "";
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');	
} 

function PrintPage(){
	document.form_.page_action.value = "";
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
} 

function PageLoad(){
 	document.form_.req_no.focus();
}
 
function AjaxMapName() {
	var strCompleteName = document.form_.approved_by.value;
	var objCOAInput = document.getElementById("coa_info");

	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
 	document.form_.approved_by.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function searchRequest() {
	var strCompleteName = document.form_.req_no.value;
	var objCOAInput = document.getElementById("search_request");

	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=3007&req_no="+escape(strCompleteName);

	this.processRequest(strURL);
}
 
function copyReqNo(strReqNo) {
	document.form_.req_no.value = strReqNo;
	document.getElementById("search_request").innerHTML = "";
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";	
	document.form_.submit();
}

function closePopup() {
 	document.getElementById("search_request").innerHTML = "";
 }
function ClearFields(){
	location = "approve_request.jsp";
}
</script>
<body bgcolor="#D2AE72" onLoad="PageLoad()" class="bgDynamic">
<%	
	String strTemp = null;
 
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}

strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){//for my home, request items... i doubt someone will look at this anyway... hehehe
			iAccessLevel  = 2;	
	}
}	
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Info","approve_request.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	String strSchCode = dbOP.getSchoolIndex();	
							
	HRManpowerMgmt manpower = new HRManpowerMgmt();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vReqStat  = null;	
	String strErrMsg = null;	
	String strTemp2 = null;
	String strPageAction = WI.fillTextValue("page_action");
	String[] astrReqStatus = {"Disapproved","Approved","Pending"};	
	String strApprovalIndex = WI.fillTextValue("approval_index");
		
	if(strPageAction.length() > 0 && !(WI.fillTextValue("pageReloaded").equals("1"))){
		vRetResult = manpower.operateOnRequestStatus(dbOP,request,Integer.parseInt(WI.fillTextValue("page_action")));	
		if(vRetResult == null)
			strErrMsg = manpower.getErrMsg();
		else
			strErrMsg = "Operation successful";								
	}
	
	if(WI.fillTextValue("proceedClicked").length() > 0){
		vReqInfo = manpower.operateOnManpowerRequest(dbOP, request, 5);
		System.out.println("vReqInfo " + vReqInfo);
		if(vReqInfo != null){
			vReqStat = manpower.operateOnRequestStatus(dbOP, request, 3, (String)vReqInfo.elementAt(0));
			System.out.println("vReqStat " + vReqStat);
			if(vReqStat != null && vReqStat.size() > 0){
				strApprovalIndex = (String)vReqStat.elementAt(0);
				System.out.println("strApprovalIndex " + strApprovalIndex);
			}
			
		}
	}
	
	if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
						&& WI.fillTextValue("page_action").length() < 1)
		strErrMsg = manpower.getErrMsg();
%>
<form name="form_" method="post" action="./approve_request.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	  <tr bgcolor="#A49A6A">	  
	    <td height="25" colspan="2" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>:::: UPDATE MANPOWER REQUEST PAGE ::::</strong></font></td>
	  </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="69%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%>        
        </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="16%">Requisition No.</td>
      <td width="81%"><strong>
	  <%
	  		strTemp = WI.fillTextValue("req_no");	
	  %>
	  <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		 onKeyUp="searchRequest();" size="16">
	  <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ProceedClicked();">
     <label id="search_request" style="position:absolute;width:380;"></label></strong></td>
    </tr>
    
    <tr> 
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>
	<%if(vReqInfo != null && vReqInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="26">&nbsp;</td>
      <td width="16%"><strong>Requested By</strong></td>
			<%
				strTemp = WI.formatName((String)vReqInfo.elementAt(11), (String)vReqInfo.elementAt(12), 
																(String)vReqInfo.elementAt(13), 4);
			%>			
      <td width="35%">&nbsp;<%=strTemp%></td>
      <td width="16%"><strong>Date requested</strong></td>
	   <%		 
				strTemp = (String)vReqInfo.elementAt(9);
		  %>			
      <td width="31%">&nbsp;<%=strTemp%></td>
    </tr>
	 	<tr>
	 	  <td height="26">&nbsp;</td>
	 	  <td><strong>Manpower requested </strong></td>
		<%
	  		strTemp = (String)vReqInfo.elementAt(5);
  	%>
	 	  <td>&nbsp;<%=strTemp%></td>
 	    <td><strong>Date Needed</strong></td>
		<%
			strTemp = WI.getStrValue((String)vReqInfo.elementAt(3));
	  %>
 	    <td>&nbsp;<%=strTemp%></td>
    </tr>
	 	<tr>
	 	  <td height="26">&nbsp;</td>
	 	  <td><strong>Position</strong></td>
	 	  <td colspan="3">&nbsp;</td>
 	  </tr>
	 	<tr> 
      <td height="26">&nbsp;</td>
      <td><strong>Reason</strong></td>
			<%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
	  		strTemp = (String)vReqInfo.elementAt(2);
	    else 
	  		strTemp = WI.fillTextValue("purpose");
	  	%>			
      <td colspan="3" height="10">&nbsp;<%=strTemp%></td>
    </tr>
   </table>		 
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="3" height="10"><hr size="1"></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Request Status </td>
		<%
			strTemp = (String)vReqInfo.elementAt(4);				
			strTemp = WI.getStrValue(strTemp, "2");
		%>
    <td>
		<select name="request_stat">
      <%for(int i = 0;i < astrReqStatus.length; i++){%>
      <%if(strTemp.equals(Integer.toString(i))){%>
      <option value="<%=i%>" selected><%=astrReqStatus[i]%></option>
      <%}else{%>
      <option value="<%=i%>"><%=astrReqStatus[i]%></option>
      <%}%>
      <%}%>
    </select></td>
  </tr>
  <tr>
    <td width="2%">&nbsp;</td>
    <td width="16%">Updated  by </td>
		<%
			if(vReqStat != null && vReqStat.size() > 0)
				strTemp = (String)vReqStat.elementAt(9);
			else
				strTemp = WI.fillTextValue("approved_by");
		%>
    <td width="82%"><input name="approved_by" type="text" size="16" class="textbox" value="<%=strTemp%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			 onKeyUp="AjaxMapName();"><label id="coa_info"></label></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Approved Manpower</td>
		<%
			if(vReqStat != null && vReqStat.size() > 0)
				strTemp = (String)vReqStat.elementAt(3);
			else
				strTemp = WI.fillTextValue("num_approved");
			strTemp = WI.getStrValue(strTemp);
		%>		
    <td><input name="num_approved" type="text" size="4" class="textbox" value="<%=strTemp%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Remarks</td>
		<%
			if(vReqStat != null && vReqStat.size() > 0)
				strTemp = (String)vReqStat.elementAt(4);
			else
				strTemp = WI.fillTextValue("remarks");
		%>			
    <td><textarea name="remarks" cols="40" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Date Approved </td>
		<%
			if(vReqStat != null && vReqStat.size() > 0)
				strTemp = (String)vReqStat.elementAt(5);
			else
				strTemp = WI.fillTextValue("date_approved");
			strTemp = WI.getStrValue(strTemp);
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>			
    <td><input name="date_approved" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_approved');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
  </tr>
</table>

	 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="30" align="center">
			<%if(strApprovalIndex== null || strApprovalIndex.length() == 0){%>
				<a href="javascript:PageAction(1,0);"><img src="../../../images/save.gif" border="0"></a> 
			click to save
			<%}else{%>
				<a href="javascript:PageAction(1,0);"><img src="../../../images/edit.gif" border="0"></a> 
			<%}%>
      <font size="1" >click to update entry</font> <a href="javascript:ClearFields();"><img src="../../../images/cancel.gif" border="0"></a> <font size="1">click to clear entries</font></td>
     </tr>
  </table> 
	<%}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">   
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
  <input type="hidden" name="approval_index">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
