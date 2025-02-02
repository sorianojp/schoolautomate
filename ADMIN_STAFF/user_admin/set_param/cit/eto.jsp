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
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to remove this record."))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	
	document.form_.submit();
}
//all about ajax - to display student list with same name.
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	this.viewInfo();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<body bgcolor="#D2AE72" onLoad="document.form_.emp_id.focus();">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","eto.jsp");
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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"eto.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

SetParameter SP = new SetParameter();
Vector vETO = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(SP.operateOnETO(dbOP,request, Integer.parseInt(strTemp)) != null )
		strErrMsg = "Successful";
	else
		strErrMsg = SP.getErrMsg();
}

Vector vRetResult = SP.operateOnETO(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) {
	strErrMsg = SP.getErrMsg();
}


dbOP.cleanUP();

if(strErrMsg == null) 
	strErrMsg = "";
%>
<form name="form_" action="./eto.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          ETO PERSONNEL ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="1%">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr valign="top">
      <td height="25" width="1%">&nbsp;</td>
      <td width="15%">Employee ID</td>
      <td width="22%"> </select> <input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  onKeyUp="AjaxMapName(1);"></td>
      <td width="8%">
	  	<%if( iAccessLevel >1){%><input type="image" onClick="PageAction('1','');" src="../../../../images/save.gif"><%}%>
	  </td>
      <td width="54%">
	  	<label id="coa_info"></label>
	  </td>
    </tr>
  </table>
 <%if(vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#CCCCCC">
      <td height="25" colspan="4" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">LIST OF ETO EMPLOYEES</td>
    </tr>
    <tr style="font-weight:bold" align="center" bgcolor="#FFFFCC">
      <td class="thinborder" height="25" style="font-size:9px;" width="25%">ID NUMBER</td>
      <td class="thinborder" style="font-size:9px;" width="60%">EMPLOYEE NAME</td>
      <td class="thinborder" style="font-size:9px;" width="15%">DELETE</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr>
      <td class="thinborder" height="25" style="font-size:9px;">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:9px;">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:9px;" align="center"><a href="javascript:PageAction('0', <%=vRetResult.elementAt(i)%>)"><img src="../../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>	
 <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" align="center">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="page_action">
 <input type="hidden" name="info_index">
</form>
</body>
</html>

