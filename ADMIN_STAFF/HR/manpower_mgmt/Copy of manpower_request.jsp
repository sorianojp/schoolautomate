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
	document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{		
    document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	document.form_.pageReloaded.value = "1";
	document.form_.page_action.value = "1";	
	this.SubmitOnce('form_');
}

function PageAction(strAction,strInfoIndex, strText){
	document.form_.page_action.value = "";
	document.form_.forwardTo.value = "";
	document.form_.printPage.value = "";
	if(strAction == 0){
		var vProceed = confirm('Delete this request:'+strText+'?' );
		if(vProceed){
			document.form_.page_action.value = strAction;
			document.form_.info_index.value = strInfoIndex;
			this.SubmitOnce('form_');
		}
	}
	else{
		document.form_.page_action.value = strAction;
		document.form_.info_index.value = strInfoIndex;
		this.SubmitOnce('form_');	
	}
} 

function prepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value = "1";
	document.form_.page_action.value = 3;
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');	
}
function ForwardTo(){
	document.form_.forwardTo.value = "1";
	document.form_.page_action.value = "";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
    document.form_.forwardTo.value = "";
	document.form_.page_action.value = "";
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function OpenSearch(strSupply){
	document.form_.printPage.value = "";
	var pgLoc = "../requisition/requisition_view_search.jsp?opner_info=form_.req_no&nsupply="+strSupply+
				"&my_home="+document.form_.my_home.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageLoad(){
 	document.form_.req_no.focus();
}

function AjaxMapName() {
	var strCompleteName = document.form_.requested_by.value;
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
 	document.form_.requested_by.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function ClearFields(){
	location = "manpower_request.jsp";
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Info","manpower_request.jsp");
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
	Vector vEmpDetails = null;
	String strErrMsg = null;	
	String strTemp2 = null;
	String strPageAction = WI.fillTextValue("page_action");
	
	if(strPageAction.length() > 0 && !(WI.fillTextValue("prepareToEdit").equals("1"))){
		vRetResult = manpower.operateOnManpowerRequest(dbOP,request,Integer.parseInt(WI.fillTextValue("page_action")));	
		if(vRetResult == null)
			strErrMsg = manpower.getErrMsg();
		else
			strErrMsg = "Operation successful";								
	}
	
 	if(vRetResult != null && vRetResult.size() > 0)
		vReqInfo = manpower.operateOnManpowerRequest(dbOP, request, 3, (String)vRetResult.elementAt(0));
	else
		vReqInfo = manpower.operateOnManpowerRequest(dbOP, request, 3);
 
 	if(vReqInfo == null && WI.fillTextValue("req_no").length() > 0
						&& WI.fillTextValue("page_action").length() < 1)
		strErrMsg = manpower.getErrMsg();
		
	vRetResult = 	manpower.operateOnManpowerRequest(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = manpower.getErrMsg();
%>
<form name="form_" method="post" action="./manpower_request.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	  <tr bgcolor="#A49A6A">	  
	    <td height="25" colspan="2" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>:::: MANPOWER REQUEST PAGE ::::</strong></font></td>
	  </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="69%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%>        
        </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="18%">Requisition No.</td>
      <td width="79%"><strong>
	  <%if(vReqInfo != null && vReqInfo.size() > 0)
	  		strTemp = (String)vReqInfo.elementAt(1);
	    else 
				strTemp = "";
	  %>
    <input type="text" name="req_no" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		 size="16">
        </strong>&nbsp;(<font size="1">Request # will be machine generated if left blank)</font></td>
    </tr>
    
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="26">&nbsp;</td>
      <td width="19%">Date requested</td>
	   <%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
				strTemp = (String)vReqInfo.elementAt(9);
		  else
				strTemp = WI.fillTextValue("request_date");	  
			
			if(strTemp == null || strTemp.length() == 0)	
				strTemp = WI.getTodaysDate(1);
		%>			
      <td width="78%" colspan="3"><input name="request_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.request_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    
    <%if(!bolMyHome){%>
	<tr> 
      <td height="26">&nbsp;</td>
      <td>Requested By</td>
      <td colspan="3"> 
			<% 
			if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
	   	  	strTemp = (String)vReqInfo.elementAt(14);
		  else 
				strTemp = WI.fillTextValue("requested_by");
			%> 
			 <input name="requested_by" type="text" size="16" class="textbox" value="<%=strTemp%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			 onKeyUp="AjaxMapName();"><label id="coa_info"></label>			 </td>
    </tr>
    
	<%}%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td valign="top">Reason</td>
      <td colspan="3"> 
			<%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
	  		strTemp = (String)vReqInfo.elementAt(2);
	    else 
	  		strTemp = WI.fillTextValue("purpose");
	  	%> <textarea name="purpose" cols="40" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Position</td>
			<%
				if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
					strTemp = (String)vReqInfo.elementAt(15);
				else 
					strTemp = WI.fillTextValue("emp_position");
				strTemp = WI.getStrValue(strTemp);
			%>			
      <td colspan="3"><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Manpower requested </td>
      <td colspan="3">
		<%
			if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
	  		strTemp = (String)vReqInfo.elementAt(5);
	    else 
	  		strTemp = WI.fillTextValue("num_requested");
			strTemp = WI.getStrValue(strTemp);
  	%>
      <input name="num_requested" type="text" size="4" class="textbox" value="<%=strTemp%>"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Date Needed</td>
      <td colspan="3"> <%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))  	
			strTemp = WI.getStrValue((String)vReqInfo.elementAt(3));
	  	 else if(WI.fillTextValue("date_needed").length() > 0)
	  		strTemp = WI.fillTextValue("date_needed");
		 else
			strTemp = "";
	  %> <input name="date_needed" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_needed');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2"><hr size="1"></td>
    </tr>
    <%if(vReqInfo == null){%>
    <tr> 
      <td height="30" colspan="2"><div align="center"><a href="javascript:PageAction(1,0);"><img src="../../../images/save.gif" border="0"></a> 
          <font size="1" >click to save entry</font></div></td>
    </tr>
    <%}else{%>
    <tr> 
      <td width="85%" height="30" colspan="2" align="center"> <center>
        <a href="javascript:PageAction(2,<%=(String)vReqInfo.elementAt(0)%>)"> 
          <img src="../../../images/edit.gif" border="0"></a> <font size="1">click 
            to save changes</font> <a href="javascript:ClearFields();"> <img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel edit</font>
      </center>      </td>
    </tr>
    <%}%>
    <tr>
      <td height="30" colspan="2" align="center">&nbsp;</td>
    </tr>
  </table> 
  <%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="19" colspan="8" align="center" class="thinborderALL"><strong>MANPOWER REQUEST</strong></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr>
      <td width="6%" align="center" class="thinborder"><strong>REQ # </strong></td> 
      <td width="12%" height="25" align="center" class="thinborder"><strong>DATE REQUESTED </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>REQUESTED BY </strong></td>
      <td width="11%" align="center" class="thinborder"><strong># REQUESTED </strong></td>
      <td width="11%" align="center" class="thinborder"><strong>POSITION</strong></td>
      <td width="22%" align="center" class="thinborder"><strong>PURPOSE</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>DATE NEEDED </strong></td>
      <td width="5%" align="center" class="thinborder"><strong>EDIT</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <% int iCount = 1 ;
	for(int i = 0;i < vRetResult.size();i+=20, iCount++){%>
	<tr>
	  <td class="thinborder"><%=vRetResult.elementAt(i+1)%></td> 
      <td height="25" align="center" class="thinborder"><%=vRetResult.elementAt(i+9)%></td>
			<%
				strTemp = WI.formatName((String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12), (String)vRetResult.elementAt(i+13), 4);
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i+5)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+16);
				strTemp = WI.getStrValue(strTemp, "N/a");
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+3)%></td>
      <td class="thinborder"> 

		    <a href="javascript:prepareToEdit(<%=vRetResult.elementAt(i)%>);"> 
	        <img src="../../../images/edit.gif" border="0"></a> </td>
      <td class="thinborder"> 
	  <%if(iAccessLevel == 2){%>
	  <a href="javascript:PageAction(0,<%=vRetResult.elementAt(i)%>,'<%=vRetResult.elementAt(i+1)%>')">
	  <img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
		N/A
		<%}%>	  </td>
    </tr>
	<%} // end for loop%>
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
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <!-- all hidden fields go here
  <input type="hidden" name="is_supply" value="<%//=WI.fillTextValue("is_supply")%>">
  -->
  <input type="hidden" name="forwardTo" value="">
  <input type="hidden" name="pageReloaded" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="prepareToEdit">
	
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
