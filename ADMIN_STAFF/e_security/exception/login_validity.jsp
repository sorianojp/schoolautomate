<%@ page language="java" import="utility.*,eSC.CampusQuery,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null; Vector vEditInfo = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eSecurity Check-Exception-set login validity","login_validity.jsp");
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
														"eSecurity Check","NULL",request.getRemoteAddr(), 
														"login_validity.jsp");	
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
strTemp = WI.fillTextValue("page_action");
CampusQuery cQuery = new CampusQuery(null);
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
if(strTemp.length() > 0) {
	if(cQuery.operateOneSCLoginValidity(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cQuery.getErrMsg();
	else {
		strErrMsg = "Operation Successful";
		strPreparedToEdit = "0";
	}
}
if(strPreparedToEdit.equals("1")) 
	vEditInfo = cQuery.operateOneSCLoginValidity(dbOP, request, 3);

vRetResult = cQuery.operateOneSCLoginValidity(dbOP, request, 4);


%>	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.id_number.value;
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&is_faculty=ignore&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.id_number.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function RefineSearch() {
	document.form_.page_action.value='';
	document.form_.preparedToEdit.value='';
	document.form_.id_number.value='';
	document.form_.valid_from.value='';
	document.form_.valid_to.value='';
	
	document.form_.submit();
}
function DeleteCalled(strInfoIndex) {
	if(!confirm("Do you want to delete this information?"))
		return;
	document.form_.preparedToEdit.value='';
	document.form_.page_action.value='0';
	document.form_.info_index.value=strInfoIndex;
	document.form_.submit();
}
function CheckValid(strCheckBoxClicked) {
	if(strCheckBoxClicked == '2') {
		document.form_.valid_only.checked = false;
		document.form_.invalid_only.checked = false;
	}
	if(strCheckBoxClicked == '0')
		document.form_.valid_only.checked = false;
	else	
		document.form_.invalid_only.checked = false;
	
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.id_number.focus()">

<form action="./login_validity.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="88%" height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ALLOW USERS FOR A RANGE OF DATE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr valign="top"> 
      <td width="3%" height="33">&nbsp;</td>
      <td width="12%">ID Number </td>
      <td width="24%">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("id_number");
%>
        <input name="id_number" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';" value="<%=strTemp%>" size="24" onKeyUp="AjaxMapName();"></td>
      <td width="61%"><label id="coa_info"></label></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>DATE :</td>
      <td colspan="2"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("valid_from");
%>
	  <input name="valid_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.valid_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a> 
		to 

<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("valid_to");
%>
        <input name="valid_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
         <img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;<em><font color="#0000FF" size="1">NOTE: 
        Leave the date fileds empty to display record for entire term specified</font></em></td>
    </tr>

    <tr valign="top"> 
	
      <td height="30" class="thinborderBOTTOM">&nbsp;</td>
      <td colspan="3" align="center" class="thinborderBOTTOM">
<%if(iAccessLevel > 1 && vEditInfo == null) {%>
        <input type="button" name="1" value="Save Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.submit();">
<%}else if(iAccessLevel > 1){%>
        <input type="button" name="1" value="Edit Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2';document.form_.info_index.value=<%=vEditInfo.elementAt(0)%>;document.form_.submit();">
&nbsp;&nbsp;&nbsp;&nbsp;
<input type="submit" name="1" value="Cancel Edit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';document.form_.id_number.value='';document.form_.valid_from.value='';document.form_.valid_to.value='';">
<%}%>      </td>
    </tr>
    <tr > 
      <td height="10" colspan="2">&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td style="font-size:9px; color:#0000FF" valign="top"><br>Search Condition </td>
      <td colspan="2">
	  	<table width="80%" bgcolor="#DDDDDD" border="0" class="thinborderALL" cellpadding="0" cellspacing="0">
			<tr>
				<td width="50%" style="font-size:10px;">ID Number Starts With : 
				<input name="id_number_con" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF';" 
				onBlur="style.backgroundColor='white';" value="<%=WI.fillTextValue("id_number_con")%>" size="16" style="font-size:10px"></td>
			    <td width="50%" style="font-size:10px;">
				<input type="checkbox" name="show_deleted" value="checked" <%=WI.fillTextValue("show_deleted")%> onClick="CheckValid('2');">
		        Show Only Deleted Information </td>
			</tr>
			<tr>
			  <td colspan="2" style="font-size:10px;">Valid Date Range : 
			  <input name="date_range_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_range_fr")%>" class="textbox"	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
			  <a href="javascript:show_calendar('form_.date_range_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        		<img src="../../../images/calendar_new.gif" border="0"></a>			  
			  to
			  <input name="date_range_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_range_to")%>" class="textbox"	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
			  <a href="javascript:show_calendar('form_.date_range_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        		<img src="../../../images/calendar_new.gif" border="0"></a>			</td>
		  </tr>
			<tr>
			  <td style="font-size:10px;">
			  <input type="checkbox" name="invalid_only" value="checked" <%=WI.fillTextValue("invalid_only")%> onClick="CheckValid('0');"> Show Invalid records (validity expired) </td>
		      <td style="font-size:10px;">
			  <input type="checkbox" name="valid_only" value="checked" <%=WI.fillTextValue("valid_only")%> onClick="CheckValid('1');"> Show only valid records </td>
		  </tr>
			<tr>
			  <td style="font-size:10px;">&nbsp;</td>
			  <td style="font-size:10px;" align="right"><a href="javascript:RefineSearch();" style="text-decoration: none; font-size:12px;">Click to Search</a>&nbsp;</td>
		  </tr>
		</table>
	  </td>
    </tr>

  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" style="font-size:13px; font-weight:bold"><div align="center">::: LIST OF USERS WITH SPECIFIC LOGIN VALIDITY :::</div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="66%" height="25"><b> TOTAL RESULT : <%=vRetResult.size()/6%></b></td>
      <td width="34%">&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="15%" height="25" align="center" class="thinborder" style="font-weight:bold">ID Number </td>
      <td width="35%" align="center" class="thinborder" style="font-weight:bold">Name</td>
      <td width="30%" align="center" class="thinborder" style="font-weight:bold">Validity</td>
      <td width="10%" align="center" class="thinborder" style="font-weight:bold">Edit</td>
      <td width="10%" align="center" class="thinborder" style="font-weight:bold">Delete</td>
    </tr>
<%for(int i = 0; i< vRetResult.size(); i +=6){%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td align="center" class="thinborder"><%=vRetResult.elementAt(i + 1)%> - <%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" align="center">
        <input type="submit" name="12" value="Edit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.preparedToEdit.value='1';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'">	  
	  </td>
      <td class="thinborder" align="center">
        <input type="button" name="12" value="Delete" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="DeleteCalled('<%=vRetResult.elementAt(i)%>');">	  
	  </td>
    </tr>
<%}%>
  </table>
  <%}//only if vRetResult is not null %>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>