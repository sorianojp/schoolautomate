<%@ page language="java" import="utility.*,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-CHED REPORTS-Update Fund Source","completion_grade_encode_or.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar","CHED REPORTS",request.getRemoteAddr(),
														"completion_grade_encode_or.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

enrollment.SACIAddition saciA = new enrollment.SACIAddition();

Vector vRetResult = null; Vector vGradeInfo = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(saciA.operateOnCompletionOR(dbOP, request, Integer.parseInt(strTemp)) == null ) 
		strErrMsg = saciA.getErrMsg();
	else	
		strErrMsg = "Request processed succefully.";
}
vRetResult = saciA.operateOnCompletionOR(dbOP, request, 4);
if(strErrMsg == null && vRetResult == null)
	strErrMsg = saciA.getErrMsg();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED ICT REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../../../Ajax/ajax.js" ></script>
<script language="JavaScript"  src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateCheckBox(objORNum, objCheckBox) {
	if(objORNum.value.length > 0) 
		objCheckBox.checked = true;
	else
		objCheckBox.checked = false;
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
	var strCompleteName;
	strCompleteName = document.form_.id_.value;
	if(strCompleteName.length < 2)
		return;
	
	var objCOAInput;
	objCOAInput = document.getElementById("coa_info");
		
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.id_.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body>
<form name="form_" action="./completion_grade_encode_or.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" align="center" style="font-size:13px; font-weight:bold">::: Encode Completion Grade/OR Information ::: </td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <tr>
      <td height="25" class="body_font">SY/Term</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  &nbsp;&nbsp;&nbsp;
	  <select name="semester">
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	
		<option value="1"<%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	
		<option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>	
		<option value="0"<%=strErrMsg%>>Summer</option>
	  </select>	  </td>
    </tr>
    <tr> 
      <td width="15%" height="25" class="body_font">&nbsp;Enter Student ID </td>
      <td><input name="id_" value="<%=WI.fillTextValue("id_")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="32"
	  onKeyUp="AjaxMapName('1');"> &nbsp;&nbsp; &nbsp;
      <input type="submit" name="_122" value="ReloadPage" onClick="document.form_.page_action.value='';"></td>
    </tr>
    
    
    <tr> 
      <td>&nbsp;</td>
      <td><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
<%
strErrMsg = null;
if(WI.fillTextValue("id_").length() > 0) {
	vGradeInfo = saciA.operateOnCompletionOR(dbOP, request, 5);
	if(vGradeInfo == null) 
		strErrMsg = saciA.getErrMsg();
}
if(strErrMsg != null) {%>
    <tr> 
      <td colspan="2" style="font-size:13px; color:#FF0000">&nbsp;&nbsp;<%=strErrMsg%></td>
    </tr>
<%}else if(vGradeInfo != null && vGradeInfo.size() > 0) {
int j = 0; %>
<input type="hidden" name="stud_ref" value="<%=vGradeInfo.remove(0)%>">
    <tr> 
      <td style="font-size:13px;">&nbsp;Student Name</td>
      <td style="font-size:13px;"><%=vGradeInfo.remove(0)%></td>
    </tr>
    <tr> 
      <td style="font-size:13px;">&nbsp;Student Course</td>
      <td style="font-size:13px;"><%=vGradeInfo.remove(0)%><%=WI.getStrValue((String)vGradeInfo.remove(0)," ; Major : ", "")%><%vGradeInfo.remove(0);//remove yr Level%></td>
    </tr>
    <tr> 
      <td colspan="2">
		<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
			<tr bgcolor="#9DB6F4" style="font-weight:bold">
				<td width="15%" class="thinborder" height="22">Subject Code</td>
				<td width="25%" class="thinborder">Subject Name</td>
				<td width="15%" class="thinborder">OR Number</td>
				<td width="35%" class="thinborder">Note/Remark</td>
				<td width="10%" class="thinborder">Select</td>
			</tr>
			<%for(int i = 0; i < vGradeInfo.size(); i += 3, ++j){%>
			<tr bgcolor="#CCCCCC">
				<td class="thinborder"><%=vGradeInfo.elementAt(i + 1)%></td>
				<td class="thinborder"><%=vGradeInfo.elementAt(i + 2)%></td>
				<td class="thinborder"><input type="text" name="or_<%=j%>" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="UpdateCheckBox(document.form_.or_<%=j%>,document.form_.sub_i_<%=j%>);style.backgroundColor='white'" size="12" maxlength="16" class="textbox"></td>
				<td class="thinborder"><input type="text" name="remark_<%=j%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="24" maxlength="128" class="textbox"></td>
				<td class="thinborder"><input type="checkbox" name="sub_i_<%=j%>" value="<%=vGradeInfo.elementAt(i)%>" tabindex="-1"></td>
			</tr>
			<%}%>
			<tr bgcolor="#CCCCCC">
			  <td class="thinborder" colspan="5" align="center"><input type="submit" name="_12" value="Save Information" onClick="document.form_.page_action.value='1';"></td>
		  </tr>
		</table>
	<input type="hidden" name="max_disp" value="<%=j%>">	</td></tr>
<%}//show listing here.. %>
  </table>

<% if (vRetResult != null && vRetResult.size() > 0) {%>
  <br> <br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFF99" style="font-weight:bold"> 
      <td width="10%" height="25" class="thinborder" align="center">Student ID</td>
      <td width="15%" class="thinborder" align="center">Student Name</td>
      <td width="10%" class="thinborder" align="center">Subject Code </td>
      <td width="25%" class="thinborder" align="center">Subject Title </td>
      <td width="10%" class="thinborder" align="center">OR Number </td>
      <td width="25%" class="thinborder" align="center">Remarks</td>
      <td width="5%" class="thinborder" align="center"><b>Delete</b></td>
    </tr>
    <%while(vRetResult.size() > 0) {
	strTemp = (String)vRetResult.remove(0);%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.remove(0)%></td>
      <td class="thinborder"><%=vRetResult.remove(0)%></td>
      <td class="thinborder"><%=vRetResult.remove(0)%></td>
      <td class="thinborder"><%=vRetResult.remove(0)%></td>
      <td class="thinborder"><%=vRetResult.remove(0)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.remove(0), "&nbsp;")%></td>
      <td class="thinborder"><input type="submit" name="_12" value="Delete" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=strTemp%>'"> </td>
    </tr>
    <%}%>
  </table>
 <% } // end if vRetResult %>
  <input type="hidden" name="info_index" value="">
  <input type="hidden" name="page_action" value="">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
