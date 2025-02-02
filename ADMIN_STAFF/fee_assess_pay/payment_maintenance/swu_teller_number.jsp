<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Teller</title>
</head>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head><style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">
function AjaxMapName(strPos) {
	var strCompleteName;
	strCompleteName = document.form_.emp_id.value;
	if(strCompleteName.length < 2 )
		return;
	
	var objCOAInput;
	objCOAInput = document.getElementById("coa_info");
		
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&is_faculty=1&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.emp_id.value = strID;
	//document.form_.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
function PageAction(strAction, strinfo){
	document.form_.page_action.value = strAction;
	if(strAction=='3')
	{
	  document.form_.prepareToEdit.value = '1';
	  document.form_.page_action.value = "";
	}

	if(strinfo.length > 0)
	  document.form_.info_index.value = strinfo;
	
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp   = null;
    //add security here.

	try{
		dbOP = new DBOperation();
	}
	catch(Exception exp){
		exp.printStackTrace();
		%>
          <p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT MAINTENANCE",request.getRemoteAddr(),
														"swu_teller_number.jsp");
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


Vector vRetResult = null;
Vector vEditInfo = null;

FAPmtMaintenance faPmt = new FAPmtMaintenance();

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	
strTemp = WI.fillTextValue("page_action");

	if(strTemp.length() > 0){
		if(faPmt.operateOnTellerNumberSWU(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = faPmt.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Teller Information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Teller Information successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Teller Information successfully updated.";
			
			strPrepareToEdit = "0";
		}
	 }
     if(strPrepareToEdit.equals("1")){
		 vEditInfo = faPmt.operateOnTellerNumberSWU(dbOP, request,3);
		 if(vEditInfo == null)
			strErrMsg = faPmt.getErrMsg();
	 }
		
	 vRetResult = faPmt.operateOnTellerNumberSWU(dbOP, request,4);
	 if(vRetResult == null)
		strErrMsg = faPmt.getErrMsg();
			
%>
<form name="form_" action="swu_teller_number.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF"> :::: TELLER NUMBER SETUP ::::</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
     <tr>
     <td width="3%" height="25">&nbsp;</td>
      <td>Employee ID </td>
      <td width="86%" colspan="2">
	  <input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"  onKeyUp="AjaxMapName('1');">
      <label id="coa_info" style="font-size:11px; position:absolute; width:300px; font-weight:bold; color:#0000FF"></label></td>
  </tr>
   
	
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Teller No:</td>
	  <%  strTemp = "";
		  if(vEditInfo != null && vEditInfo.size() > 0)
		  {
			strTemp = (String)vEditInfo.elementAt(1);
		  }
      %>
      <td colspan="2">
	  <input name="teller_no" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="16"></td></tr>
	
	 <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Valid Date:</td>
      <td colspan="2">
	    <% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
		   else			
				strTemp = WI.fillTextValue("date_from");				
		   if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
		%>
		<input name="date_from" type="text" class="textbox" id="date_from" readonly="yes"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="10">
        <a href="javascript:show_calendar('form_.date_from');"> 
		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
		to
		<% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(3);
		   else			
				strTemp = WI.fillTextValue("date_from");				
		%>
		<input name="date_to" type="text" class="textbox" id="date_to"
	    onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" 
	    value="<%=strTemp%>" size="10" readonly="yes" />
		<a href="javascript:show_calendar('form_.date_to');"> 
		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0" /></a>      </td>
    </tr>
	<tr>
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
	  <td width="11%">&nbsp;</td>
      <td height="15" colspan="2"><div align="left">
<%		  if(strPrepareToEdit.equals("0")){%> 
		  <a href="javascript:PageAction('1','');">
		  <img src="../../../images/save.gif" border="0"></a> <font size="1">click to save entries </font>
<%        }else{%>
          <a href="javascript:PageAction('2','');">
		  <img src="../../../images/edit.gif" border="0"></a> <font size="1">click to edit entries </font>
<%        }%>
<a href="./swu_teller_number.jsp"><img src="../../../images/cancel.gif" border="0" /></a><font size="1">click to cancel/clear entries </font></div>	 </td>
    </tr>
    <tr>
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0 ) { %>
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
	  <div align="center"><strong>::: TELLER NUMBER LISTING ::: </strong></div></td>
    </tr>
    <tr>
      <td height="26" width="14%" class="thinborder"><strong>Teller No</strong></td>
	   <td height="26" width="12%" class="thinborder"><strong>Employee ID</strong></td>
	    <td height="26" width="32%" class="thinborder"><strong>Name</strong></td>
      <td width="12%"  class="thinborder"><strong>Valid From</strong><strong></strong></td>
	   <td width="12%"  class="thinborder"><strong>Valid To</strong><strong></strong></td>
      <td width="18%"  class="thinborder"><strong>Options</strong></td>
    </tr>
	<%
	
	strTemp = "select id_number, fname, mname, lname from user_table join FA_TELLER_NO on (FA_TELLER_NO.user_index = user_table.user_index) "+
		" where FA_TELLER_NO.is_valid =1 and FA_TELLER_NO.TELLER_INDEX=?";
	java.sql.PreparedStatement pstmtSelect = dbOP.getPreparedStatement(strTemp);
	
	java.sql.ResultSet rs = null;
	for(int i = 0; i < vRetResult.size(); i += 4){
		strErrMsg = null;
		strTemp = null;
		pstmtSelect.setString(1, (String)vRetResult.elementAt(i));
		rs = pstmtSelect.executeQuery();
		if(rs.next()){
			strErrMsg = rs.getString(1);
			strTemp = WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4);
		}rs.close();
	
	%>
    <tr>
      <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
	    <td height="25"  class="thinborder"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
		  <td height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
	   <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td  class="thinborder">
	  <a href="javascript:PageAction('3','<%=(String)vRetResult.elementAt(i)%>');"> 
	  <img src="../../../images/edit.gif" border="0" /></a> &nbsp;&nbsp; 
	
	  <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"> 
	  <img src="../../../images/delete.gif" border="0" /></a>
	 
    </tr>
    <%}// end of vRetResult loop%>
  </table>
  <%} // end of vRetResult != null && vRetResult.size() > 0%>
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
    <tr bgcolor="#FFFFFF">
      <td height="25"></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="show_data">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="info_index" value="<%= WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
