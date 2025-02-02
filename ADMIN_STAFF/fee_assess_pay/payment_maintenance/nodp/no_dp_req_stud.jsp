<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function ReloadPage(){
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))	
			return;
	}
	
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_temp=2&search_id=1&name_format=4&complete_name="+
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

</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus()">
<%@ page language="java" import="utility.*,enrollment.FAStudMinReqDP,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester", "ALL"};


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT ","no_dp_req_stud.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"no_dp_req_stud.jsp");


if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


//end of security code.
FAStudMinReqDP faMinReq = new FAStudMinReqDP(dbOP);
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(faMinReq.waiveDPDuringEnrollment(dbOP, request, Integer.parseInt(strTemp)) == null)	
		strErrMsg = faMinReq.getErrMsg();
}


if(WI.fillTextValue("sy_from").length() > 0){
	vRetResult = faMinReq.waiveDPDuringEnrollment(dbOP, request, 4);	
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = faMinReq.getErrMsg();
}

%>
<form name="form_" action="./no_dp_req_stud.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
         AUTOMATIC WIVER OF DOWNPAYMENT DURING ENROLLMENT - SPECIFIC STUDENT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"> &nbsp; &nbsp; &nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%" height="25">School Year/Term</td>
      <td width="81%" height="25" colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp; 
        <select name="semester">
        	 <option value="">ALL</option>	
<%
strTemp = WI.fillTextValue("semester");

if(strTemp.equals("1"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="1" <%=strErrMsg%>>1st</option>
<%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="2" <%=strErrMsg%>>2nd</option>

<%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="3" <%=strErrMsg%>>3rd</option>

<%
if(strTemp.equals("0"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%>			<option value="0" <%=strErrMsg%>>Summer</option>
        </select>
        &nbsp; &nbsp; &nbsp;
        <a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
		
		<input type="checkbox" name="show_temp" value="checked" <%=WI.fillTextValue("show_temp")%>> Show Temp Student
		
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student ID </td>
      <td height="25" colspan="3">
	  <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">
	  
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:350px;"></label>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><a href="javascript:PageAction('1','')"><img src="../../../../images/save.gif" border="0"></a></td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="2" height="20" align="center"><strong>LIST OF STUDENT FOR SY <%=WI.fillTextValue("sy_from") + "-" +WI.fillTextValue("sy_to")%>
   	<%
		if(WI.fillTextValue("semester").length() > 0)
			strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))];
		else
			strTemp = " - ALL TERM";
		%><%=strTemp%></strong>
   </td>
	   <td width="0%" align="center">&nbsp;</td>
	</tr>
</table>

<table  bgcolor="#FFFFFF" class="thinborder" width="100%" border="0" cellspacing="0" cellpadding="0">
	
   <tr>
   	<td width="13%" height="20" class="thinborder"><strong>ID NUMBER</strong></td>
      <td width="33%" class="thinborder"><strong>STUDENT NAME</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>SY-TERM</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>DELETE</strong></td>
   </tr>
   <%
	for(int i = 0; i < vRetResult.size(); i+=7){%>
   <tr>
   	<td height="18" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td height="18" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>      
      <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+5)%> - <%=astrConvertSem[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+6),"4"))]%></td>
      
      <td class="thinborder" align="center"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a></td>
   </tr>
   <%}%>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="view_type" value="0">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
