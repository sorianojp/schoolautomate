<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction,strIndex){
	if(strAction == 0){
		if(!confirm('Are you sure you want to remove this information.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strIndex;
	
	document.form_.reload_.value='1';
	document.form_.submit();
}

///for searching COA
var objCOA;
function MapCOAAjax() {
		objCOA=document.getElementById("coa_info");
		
		var objCOAInput = document.form_.coa_search;
		if(objCOAInput.value.length == 1)
			return;
			
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name=coa_search";
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "End of Processing..";
}
///use ajax to update voucher date and voucher number.
function UpdateInfo(strIndex) {
	//do nothing..
}
function AddToList() {
	var strNewCOA  = document.form_.coa_search.value;
	if(strNewCOA.length == 0) 
		return;
		
	var strCOAList = document.form_.coa_list.value;
	if(strCOAList.length == 0) 
		strCOAList = strNewCOA;
	else if(strCOAList.indexOf(strNewCOA) > -1)
		return;
	else 	
		strCOAList += ","+strNewCOA;
	
	document.form_.coa_list.value = strCOAList;
}
function ReloadOpner() {
	if(document.form_.reload_.value=='1')
		return;
	window.opener.document.form_.submit();
}
</script>
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration-Set up trial balance - setup_coa","page2.jsp");
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
														"Accounting","Administration",request.getRemoteAddr(), 
														"setup_coa.jsp");	
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
	
	Administration adminTB = new Administration();	
	Vector vRetResult        = null; Vector vEditInfo = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(adminTB.operateOnTBCOA(dbOP, request, Integer.parseInt(strTemp)) == null) 
			strErrMsg = adminTB.getErrMsg();
		else {
			strErrMsg = "Operation successful.";
		}
	}	
	vRetResult = adminTB.operateOnTBCOA(dbOP, request, 4);
	
	String strTBIndex = WI.fillTextValue("tb_ref");
	
	String strTBName = dbOP.getResultOfAQuery("select tb_name from AC_SET_TB where tb_index="+strTBIndex,0);
%>
<body onLoad="document.form_.coa_search.focus();" onUnload="ReloadOpner();">
<form name="form_" method="post" action="setup_coa.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0">
    <tr> 
      <td colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="20%" style="font-size:10px;">Trial Balance Name </td>
      <td width="78%" style="font-size:10px; font-weight:bold"><%=strTBName%></td>
    </tr>
<!--    <tr>
      <td>&nbsp;</td>
      <td valign="top" style="font-size:10px;"><br>List of Chart of Account</td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("coa_search");
%>
	  <textarea name="coa_list" class="textbox" rows="5" cols="70" onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>	  </td>
    </tr>
-->    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
	  
  <table width="100%" border="0">
    <tr valign="top"> 
      <td width="2%">&nbsp;</td>
      <td width="20%" style="font-size:10px;">Chart of Account Quick Search</td>
      <td width="78%"><input type="text" name="coa_search" class="textbox" size="16"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onkeyUP="MapCOAAjax();">&nbsp;&nbsp;&nbsp;<!--<a href="javascript:AddToList();">Add to List</a>--><br>
	  <label id="coa_info" style="font-size:11px;"></label>
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <%if(iAccessLevel > 1) {%>
        <input type="submit" name="12" value="Save Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'; document.form_.reload_.value='1'">
      <%}%>
	  </td>
    </tr>
    
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: LIST OF ACCOUNTS FOR TRIAL BALANCE :: </strong></font></div></td>
    </tr>
    <tr>
      <td width="55%" align="center" style="font-size:9px; font-weight:bold" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">CHART OF ACCOUNT</span></td> 
      <td width="35%" height="25" align="center" style="font-size:9px; font-weight:bold" class="thinborder">ACCOUNT # </td>
      <td width="10%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">&nbsp;</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">
		<%if(iAccessLevel == 2){%>
			<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');">Remove</a>
		 <%}else{%>&nbsp;<%}%>	  </td>
    </tr>
<%}%>
  </table>
<%}%>  


  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  
  <!-- page information -->
  <input type="hidden" name="tb_ref" value="<%=strTBIndex%>">
  
  <input name="reload_" type="hidden">
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>