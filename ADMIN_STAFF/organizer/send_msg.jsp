<%
if(request.getSession(false).getAttribute("userId") == null){%>
<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
	Please login to access this link.
</font>
<%return;
}

String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
boolean bolIsStudent = false;
if(strAuthTypeIndex != null && strAuthTypeIndex.equals("4"))
	bolIsStudent = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../Ajax/ajax.js" ></script>
<script language="javascript"  src ="../../jscript/common.js" ></script>
<script language="javascript"  src ="../../jscript/date-picker.js" ></script>
</head>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function ClearAll()
{
	document.form_.userlist.value = "";
	document.form_.emaillist.value = "";
	document.form_.subject.value = "";
	document.form_.msg.value = "";
	
}
function Search(bolIsStud) {
	var pgLoc = "";
	if(bolIsStud == '1') 
		pgLoc = "../../search/srch_stud.jsp?opner_info=form_.userlist&multiple_entry=1";
	else
		pgLoc = "../../search/srch_emp.jsp?opner_info=form_.userlist&multiple_entry=1";

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
} 
//all about ajax.
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_idx.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&is_faculty=ignore&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	var strTemp = document.form_.userlist.value; 
	if(strTemp.indexOf(strID) == -1) {
	if(strTemp != "")
		strTemp = strTemp + ",";
		document.form_.userlist.value = strTemp + strID;
	}
	document.form_.stud_idx.value = '';
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}</script>
<style>
a:link {
	color: #000000;
	text-decoration: none;
}
a:visited {
	color: #000000;
	text-decoration: none;

}
a:hover {
	font-weight: bold;
	color: #000000;
	text-decoration: underline;

}
a:active {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
</style>
<%@ page language="java" import="utility.*, organizer.SBEmail, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vMsgDetail = null;

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strMsgIndex = null;
	strMsgIndex = WI.getStrValue(request.getParameter("info_index"),null);
	String strPassType = null;
	strPassType = WI.getStrValue(request.getParameter("pass_type"),null);
	//pass types: 0 - Reply; 1 - Forward; 2 - Resend
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Message Board","send_msg.jsp");
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
/** authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Organizer","Message Board",request.getRemoteAddr(),
														"send_msg.jsp");
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
**/
	SBEmail myMailBox = new SBEmail();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myMailBox.operateOnMailBox(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = myMailBox.getErrMsg();
			if (strErrMsg == null && strTemp.equals("1"))
				strErrMsg = "Mail sent successfully";
			else
				strErrMsg = "Mail saved successfully";
		}
		else
			strErrMsg = myMailBox.getErrMsg();
	}

	if (strMsgIndex != null && strMsgIndex.length()>0) {
		if (strPassType == null)
		{
			strErrMsg = "No pass Type";
		}
		else {
			vMsgDetail = myMailBox.operateOnMailBox(dbOP, request, 3);
		if (vMsgDetail == null)
			strErrMsg = myMailBox.getErrMsg();
		}
	}
%>
<body bgcolor="#8C9AAA">
<form action="./send_msg.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="6" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SEND MESSAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" colspan="6" bgcolor="#FFFFFF"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    	<tr>
		<td colspan="6" height="10">Send to: <font size="1">[enter fields separated by commas]</font></td>    
	</tr>
    	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
        <tr>
          <td>&nbsp;</td>
          <td style="font-size:9px; color:#FF0000; font-weight:bold">Search Employee/Student </td>
          <td colspan="4"><input name="stud_idx" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="" onKeyUp="AjaxMapName('1');">
		  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>		  </td>
        </tr>
        <tr>
          <td colspan="6"><hr size="1"></td>
        </tr>
    <tr>
    	<td width="5%" height="25">&nbsp;<%
    	if (vMsgDetail!=null && vMsgDetail.size()>0) 
    	{
			if (strPassType.compareTo("0")==0)	strTemp = WI.getStrValue(((String)vMsgDetail.elementAt(1)),"&nbsp;");
			if (strPassType.compareTo("1")==0)	strTemp = "&nbsp;";
			if (strPassType.compareTo("2")==0)	strTemp = WI.getStrValue(((String)vMsgDetail.elementAt(2)),"&nbsp;");
		}
		else
    		strTemp = WI.fillTextValue("userlist");%></td>
    	<td width="19%" style="font-size:9px;"><b>System Users:</b><br>
		<!--<a href="javascript:Search('1')">search-Student</a>
	  <br><a href="javascript:Search('0')">search-Employee</a></font>--></td>
		<td width="76%" colspan="4">
			<input name="userlist" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" value="<%=strTemp%>" onKeyUp="AjaxMapName('1');">	  			  </td>
    </tr>
	
	<tr>
    	<td height="25">&nbsp;<%
    	if (vMsgDetail!=null && vMsgDetail.size()>0) 
    	{
			if (strPassType.compareTo("0")==0)	strTemp = "&nbsp;";
			if (strPassType.compareTo("1")==0)	strTemp = "&nbsp;";
			if (strPassType.compareTo("2")==0)	strTemp = WI.getStrValue(((String)vMsgDetail.elementAt(3)),"&nbsp;");
		}
		else
	    	strTemp = WI.fillTextValue("emaillist");%></td>
    	<td><div align="left"><font size="1"><strong>External Email Address: </strong></font></div></td>
    	<td colspan="4"><div align="left"><input name="emaillist" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" value="<%=strTemp%>"></div></td>
    </tr>
   	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
    <tr>
    	<td>&nbsp;</td>
    	<td style="font-size:9px; font-weight:bold">Subject</td>
    	<td colspan="4">
    	<%
    	if (vMsgDetail!=null && vMsgDetail.size()>0) 
    	{
			if (strPassType.compareTo("0")==0)	strTemp = WI.getStrValue(((String)vMsgDetail.elementAt(4)),"Re: ","","&nbsp;");
			if (strPassType.compareTo("1")==0)	strTemp = WI.getStrValue(((String)vMsgDetail.elementAt(4)),"&nbsp;");
			if (strPassType.compareTo("2")==0)	strTemp = WI.getStrValue(((String)vMsgDetail.elementAt(4)),"Fwd: ","","&nbsp;");
		}
		else
	    	strTemp = WI.fillTextValue("subject");%>
    	<input name="subject" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" value="<%=strTemp%>"></td>
    </tr>
    <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
	<tr>
    	<td>&nbsp;</td>
    	<td style="font-size:9px; font-weight:bold">Priority </td>
    	<td colspan="4">
    	<%
			if (vMsgDetail!=null && vMsgDetail.size()>0) 
				strTemp = WI.getStrValue(((String)vMsgDetail.elementAt(5)),"0");
			else
		    	strTemp = WI.fillTextValue("priority");

		if(strTemp.compareTo("1") == 0) {
			strTemp = "checked";
			strTemp2 = "";
		} else {
			strTemp2 = "checked";
			strTemp = "";
		}
    	%>
    		<input type="radio" name="priority" value="1" <%=strTemp%>>High
    		<input type="radio" name="priority" value="0" <%=strTemp2%>>Low    	</td>
    </tr>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
   
    <tr>
    	<td>&nbsp;</td>
    	<td valign="top" style="font-size:9px; font-weight:bold">Message</td>
    	<td colspan="4">
    	<%
    	if (vMsgDetail!=null && vMsgDetail.size()>0) 
    	{
			if (strPassType.compareTo("0")==0)	strTemp = "&nbsp;";
			if (strPassType.compareTo("1")==0)	strTemp = WI.getStrValue(((String)vMsgDetail.elementAt(6)),"&nbsp;");
			if (strPassType.compareTo("2")==0)	strTemp = WI.getStrValue(((String)vMsgDetail.elementAt(6)),"&nbsp;");
		}
		else
    	strTemp = WI.fillTextValue("msg");%>
    	<textarea name="msg" cols="75" rows="15" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> </td>
    </tr>
	
    <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
		<tr>
		<td colspan="6" align="center"><font size="1">
		<a href='javascript:PageAction(8,"");'><img src="../../images/save.gif" border="0" ></a>Save Draft&nbsp;&nbsp;&nbsp;  
		<a href='javascript:PageAction(1,"");'><img src="../../images/send_email.gif" border="0" ></a>Send Message&nbsp;&nbsp;&nbsp;  
		<a href="javascript:ClearAll()"><img src="../../images/clear.gif" border="0"></a>Clear fields&nbsp;
		<a href= "./my_inbox.jsp?viewAll=0&box_type=1"><img src="../../images/go_back.gif" border="0"></a>back to Inbox</font></td>    
	</tr>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input name="pass_type" type="hidden" value="<%=WI.fillTextValue("pass_type")%>">
	<input name="viewAll" type="hidden" value="<%=WI.fillTextValue("viewAll")%>">
	<input name="box_type" type="hidden" value="<%=WI.fillTextValue("box_type")%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>