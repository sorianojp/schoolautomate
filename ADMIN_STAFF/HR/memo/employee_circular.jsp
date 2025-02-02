<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Circular</title>
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
<script src="../../../Ajax/ajax.js"></script>
<script src="../../../jscript/common.js"></script>
<script language="javascript">
	function ReloadPage(){
		document.form_.emp_id.value = "";
		document.form_.submit();
	}
	
	function ReadInfo(strMemoSentIndex){
		document.form_.memo_sent_index.value = strMemoSentIndex;
		document.form_.submit();
	}
	
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
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
		document.form_.emp_id.value = strID;
		document.getElementById("coa_info").innerHTML = "";
		document.form_.submit();
	}
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	function UpdateNameFormat(strName) {
		//do nothing.
	}	
	
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	
	//authentication here
	if(!bolMyHome) {
		int iAccessLevel = -1;
		java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
		
		if(svhAuth == null)
			iAccessLevel = -1; // user is logged out.
		else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
		else {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO MANAGEMENT"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
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
	}//check only if my home is set.. 
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Memo Management-Employee Circular","employee_circular.jsp");
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
	Vector vRetDetail = null;
	
	hr.HRMemoManagement  mt = new hr.HRMemoManagement();
	strTemp = WI.fillTextValue("emp_id");
	
	if (bolMyHome)
		strTemp = (String)request.getSession(false).getAttribute("userId");	
	
	if (strTemp.length() > 0) {
		vRetResult = mt.operateOnEmpMemo(dbOP, request,4);
		
		if (vRetResult == null)
			strErrMsg = mt.getErrMsg();
		
		if (WI.fillTextValue("memo_sent_index").length() > 0){
			vRetDetail = mt.operateOnEmpMemo(dbOP, request,3);
			if (vRetDetail == null)
				strErrMsg = mt.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./employee_circular.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic" align="center">
	  	<font color="#FFFFFF" ><strong>:::: EMPLOYEE MEMO MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="16%" height="25">EMPLOYEE ID </td>
 	  <td width="18%" height="25">
<% if (!bolMyHome){ %> 
	  	<input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AjaxMapName();" value="<%=strTemp%>"
		onBlur="style.backgroundColor='white'" size="16" >
<%}else{%> 
	<font size="3" color="#FF000"><strong>
			<%=(String)request.getSession(false).getAttribute("userId")%> </strong> </font>
<%}%>	  </td>
      <td width="14%">
	 <% if (!bolMyHome) {%> 
	  <a href="javascript:ReloadPage()"><img src="../../../images/cancel.gif" border="0"></a>
	  <%}%>	  </td>
      <td width="49%">&nbsp;
      <label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

<% if (WI.fillTextValue("memo_sent_index").length() > 0) {%>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <% if (vRetDetail !=null && vRetDetail.size() > 0) {%>
    <tr>
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="5%" height="23">&nbsp;</td>
      <td width="88%" class="thinborderALL"><pre style="font-size:11px; font-family:Verdana, Arial, Helvetica, sans-serif; margin-left:6px; margin-top:5px; margin-bottom:5px;"><%=(String)vRetDetail.elementAt(0)%></pre>
	  </td>
      <td width="7%">&nbsp;</td>
    </tr>
    <tr>
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
	<%}%>
  </table>
<%}
if (vRetResult != null) {
	if(vRetResult.size() == 1){%>
		<table bgcolor="#FFFFFF" width="100%">
			<%
			if(bolMyHome)
				strTemp = (String)request.getSession(false).getAttribute("userId");
			else
				strTemp = WI.fillTextValue("emp_id");
			%>
			<tr>
				<td width="3%">&nbsp;</td>
				<td><strong>No memos issued to employee id: <%=strTemp%>.</strong></td>
			</tr>
		</table>
	<%}else{%> 
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
      <td height="25" colspan="3" align="center" bgcolor="#F4F2F3" class="thinborder">
	  	<strong>LIST OF MEMO ADDRESSED TO EMPLOYEE</strong></td>
    </tr>
	<% for(int i = 1; i < vRetResult.size(); i+=5){
		String strColor = "#FFFFFF";
		if(((String)vRetResult.elementAt(i+4)).equals("1"))
			strColor = "#FFFF00";
	%> 
    <tr bgcolor="<%=strColor%>">
      <td width="6%" height="20" class="thinborder">&nbsp;</td>
      <td width="60%" class="thinborderBOTTOM">
	  	&nbsp;<%=(String)vRetResult.elementAt(i) + " :: " + (String)vRetResult.elementAt(i+1)%></td>
      <td width="34%" class="thinborder">&nbsp;
	  	<a href="javascript:ReadInfo('<%=(String)vRetResult.elementAt(i+3)%>')"><%=(String)vRetResult.elementAt(i+2)%></a></td>
    </tr>
	<%}%> 
  </table>
<%}}%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="memo_sent_index" value="">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>