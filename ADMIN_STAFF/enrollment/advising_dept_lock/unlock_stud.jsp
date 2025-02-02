<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script>
function ReloadPage() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();
}

//// - all about ajax.. 
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>
<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;


	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Registrar Management-LOCK ADVISING".toUpperCase()),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Registrar Management".toUpperCase()),"0"));
		
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Student Affairs-LOCK ADVISING".toUpperCase()),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Student Affairs".toUpperCase()),"0"));
		
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments-LOCK ADVISING".toUpperCase()),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Fee Assessment & Payments".toUpperCase()),"0"));
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administration-Advising Setting","unlock_stud.jsp");
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

//end of authenticaion code.
	enrollment.SetParameter sParam = new enrollment.SetParameter();
	
	if(WI.fillTextValue("sy_from").length() > 0) {
		vRetResult = sParam.operateOnDeptLocking(dbOP, request, 4);
		if (strErrMsg==null && vRetResult == null)
			strErrMsg = sParam.getErrMsg();
	}
	
%>


<body bgcolor="#D2AE72">
<form name="form_" action="./unlock_stud.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LIST OF UN BLOCKED STUDENT ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr valign="top">
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" class="thinborderNONE">SY-TERM</td>
      <td width="87%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress="if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
-
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes"> 
- 
<select name="semester" onChange="ReloadPage();">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select></td>
    </tr>
    

    <tr bgcolor="#EEEEEE">
      <td height="20">&nbsp;</td>
      <td class="thinborderNONE">Search </td>
      <td class="thinborderNONE"> ID/last name starts With : 
        <input name="id_name" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("id_name")%>" size="16">
      &nbsp;&nbsp;&nbsp;<input name="image" type="image" src="../../../images/refresh.gif" border="1"></td>
    </tr>
    
    <tr> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ABA37C"> 
      <td height="20" colspan="9" class="thinborder"> <div align="center"> <strong><font size="2">-: UnBlocked Student List :- </font></strong></div></td>
    </tr>
    <tr bgcolor="#DDDDDD"> 
      <td width="20%" height="20" class="thinborder"> <div align="center"><strong>Student ID  (Name)</strong></div></td>
      <td width="20%" class="thinborder"> <div align="center"><strong>Locked By </strong></div></td>
      <td align="center" class="thinborder" width="20%"><strong>Lock Reason </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>Date Locked</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UnLock By</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UnLock Reason</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>Date Unlocked</strong></td>
    </tr>
    <%
    for (int i = 0; i<vRetResult.size(); i+=12) { %>
    <tr> 
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+1)%>(<%=(String)vRetResult.elementAt(i+2)%>)</td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%>(<%=(String)vRetResult.elementAt(i+4)%>)</td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 10)%></td>
    </tr>
    <%}//end of for loop.%>
  </table>
<%}//show only if vRetResult is not null%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    
  </table>
	<input type="hidden" name="info_index">
	<input type="hidden" name="page_action">
	<input type="hidden" name="show_con" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>