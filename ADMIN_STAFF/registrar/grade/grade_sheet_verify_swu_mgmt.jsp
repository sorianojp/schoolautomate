<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Verify","grade_sheet_verify_swu_mgmt.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets Verification",request.getRemoteAddr(),
									null);

}

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

enrollment.GradeSystemExtn GSExtn = new enrollment.GradeSystemExtn();
Vector vRetResult = new Vector();


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(GSExtn.operateOnGradeVerificationMgmtSWU(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = GSExtn.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully saved.";
		if(strTemp.equals("0"))
			strErrMsg = "Information successfully removed.";
	}
}

vRetResult = GSExtn.operateOnGradeVerificationMgmtSWU(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = GSExtn.getErrMsg();


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
a{
	text-decoration: none;
}
.nav {
     /**color: #000000;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     background-color:#BCDEDB;
}
</style>
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this information?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	GetFacultyList();
}

function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.submit();
}
function GetFacultyList(){
	document.form_.get_faculty_list.value = "1";	
	document.form_.submit();
}	

function AjaxMapName(e) {
		if(e.keyCode == 13) {
			this.GetFacultyList();
			return;
		}
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
	document.getElementById("coa_info").innerHTML ="";
	GetFacultyList();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function SetFocus(){
	if(document.form_.emp_id)
		document.form_.emp_id.focus();
}

</script>
<body bgcolor="#D2AE72" onLoad="SetFocus();">
<form name="form_" action="grade_sheet_verify_swu_mgmt.jsp" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">    
<tr bgcolor="#A49A6A"><td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: GRADE SHEETS VERIFICATION MANAGEMENT PAGE ::::</strong></font></div></td></tr>
<tr><td height="25" style="padding-left:30px;"><strong><%=WI.getStrValue(strErrMsg)%></strong></td></tr>    
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">College</td>
		<td>
			<select name="c_index" style="width:400px;" onChange="ReloadPage();">
				<option value="">Select any</option>
				<%
				strTemp = " from college where is_del = 0  and is_college =1 order by c_name";
				
				%>
				<%=dbOP.loadCombo("c_index","c_name", strTemp, WI.fillTextValue("c_index"), false)%>
			</select>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Department</td>
	    <td>
		<select name="d_index" style=" width:400px;" onChange="ReloadPage();">
			<option value="">Select any</option>
			<%
			strTemp = " from department where IS_DEL = 0 and IS_COLLEGE_DEPT = 1 ";
			if(WI.fillTextValue("c_index").length() > 0)
				strTemp += " and c_index = "+WI.fillTextValue("c_index");
			strTemp += "order by d_name";			
			%><%=dbOP.loadCombo("d_index","d_name", strTemp, WI.fillTextValue("d_index"), false)%>
		</select>
		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>
		<a href="javascript:GetFacultyList();"><img src="../../../images/form_proceed.gif" border="0"></a>
		</td>
	    </tr>
</table>

<%
if(WI.fillTextValue("get_faculty_list").length() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	    <td>&nbsp;</td>
	    <td colspan="3">&nbsp;</td>
	    </tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="3"><font color="#FF0000"><strong>NOTE</strong></font> : For viewing purposes, you can either select college/department or leave it blank.</td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">ID Number</td>
		<td width="43%">
			<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event);">
	  &nbsp; &nbsp; <label id="coa_info" style="position:absolute; width:400px; left: 406px;"></label>		</td>
	    <td width="37%">
		<input type="checkbox" value="1" name="view_grade_verify_only">Check for viewing purpose only		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2">
			<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
			<font size="1">Click to save information</font>		</td>
	    </tr>
</table>

<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr><td align="center" height="22" colspan="6" class="thinborder"><strong>LIST OF EMPLOYEE</strong></td></tr>
	<tr>
		<td width="13%" height="22" class="thinborder"><strong>ID Number</strong></td>
		<td width="22%" class="thinborder"><strong>Employee Name</strong></td>
		<td width="22%" class="thinborder"><strong>College</strong></td>
		<td width="26%" class="thinborder"><strong>Department</strong></td>
		<td width="9%" class="thinborder" align="center"><strong>For Viewing</strong></td>
		<td width="8%" class="thinborder"><strong>Option</strong></td>
	</tr>
	<%
	for(int i = 0; i < vRetResult.size(); i+=8){
	%>
	<tr>
		<td class="thinborder" height="20"><%=WI.getStrValue(vRetResult.elementAt(i+1),"&nbsp;")%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
		<td class="thinborder" height="20"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td class="thinborder" height="20"><%=WI.getStrValue(vRetResult.elementAt(i+5),"&nbsp;")%></td>
		<td class="thinborder" height="20"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+7);
		if(strTemp.equals("1"))
			strTemp = "<img src='../../../images/tick.gif' border='0'>";
		else
			strTemp = "<img src='../../../images/x_small.gif' border='0'>";
		%>
		<td class="thinborder" align="center"><%=strTemp%></td>
		<td class="thinborder" height="20">
			<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
	</tr>
	<%}%>
</table>
<%}}%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr bgcolor="#FFFFFF"><td width="84%">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_pg">
<input type="hidden" name="get_faculty_list" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
