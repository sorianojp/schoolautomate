<%@ page language="java" import="utility.*,enrollment.Authentication,java.util.Vector,java.util.StringTokenizer" %>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ShowHideUserType()
{
	if(document.page_auth.mem_type.selectedIndex ==0)
	{
		document.page_auth.oth_mem_type.disabled = false;
		showLayer('oth_');
		//document.page_auth.oth_mem_type.style ="font-family:Verdana, Arial, Helvetica, sans-serif;";
	}
	else
	{
		//document.page_auth.oth_mem_type.style ="border: 0;font-family:Verdana, Arial, Helvetica, sans-serif;";
		hideLayer('oth_');
		document.page_auth.oth_mem_type.disabled = true;
	}
}

function AddAuthentication() {
	document.page_auth.page_action.value = "1";
}
function DeleteAuthentication(strInfoIndex) {
	document.page_auth.info_index.value = strInfoIndex;
	document.page_auth.page_action.value = "2";
}
function ReloadPage() {
	document.page_auth.reloadPage.value="1";
	document.page_auth.submit();
}

//Ajax interface for toggle authentication :: 
function AjaxToggleAuthentication() {
	var strEmpID = document.page_auth.emp_id.value;
	if(strEmpID.length == 0) {
		alert("Please enter employee ID.");
		return;
	}

	var objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=202&userID="+strEmpID;

	this.processRequest(strURL);

}
function AjaxMapName() {
	//return;
		var strCompleteName = document.page_auth.emp_id.value;
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
	document.page_auth.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	
	document.page_auth.page_action.value = "";
	document.page_auth.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72" onLoad="document.page_auth.emp_id.focus()">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-User Management","authentication.jsp");

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
														"System Administration","User Management",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","User Management - Authentication",request.getRemoteAddr(),
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
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
Vector vAuthList = new Vector();
Authentication auth = new Authentication();

request.setAttribute("inc_nonemployee", "1");


String strInfoIndex = "";
boolean bolFatalErr = false;

	vRetResult = auth.operateOnBasicInfo(dbOP, request,"0");
	if(vRetResult == null)
	{
		strErrMsg = auth.getErrMsg();bolFatalErr= true;
	}
	else
	{
		strTemp = request.getParameter("page_action");
		if(strTemp != null && strTemp.trim().length() > 0)
		{
			if(auth.operateOnAuthentication(dbOP,(String)vRetResult.elementAt(0),request,strTemp) == null)
				strErrMsg = auth.getErrMsg();
			else
				strErrMsg = "Operation successful.";
		}
		vAuthList  = auth.operateOnAuthentication(dbOP,(String)vRetResult.elementAt(0), request,"0");
	}



if(strErrMsg == null) strErrMsg = "";

String[] astrConvertGender = {"Male","Female"};


String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
boolean bolIsWNURestrictedUser = false;//a restricted System admin
String strSQLQuery = "select MANAGE_USER_INDEX from SYSAD_MANAGE_USER where USER_INDEX_TO_MANAGE is not null and SYSAD_USER_INDEX = "+strAuthID;
if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null)
	bolIsWNURestrictedUser = true;


%>


<form name="page_auth" action="authentication.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
           AUTHENTICATION MANAGEMENT ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
<%if(bolIsWNURestrictedUser){%>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="12%">Employee ID</td>
      <td width="23%">
  	  <select name="emp_id" onChange="ReloadPage();">
	  	<option value="">Select An Employee to give Authentication</option>
		<%=dbOP.loadCombo("distinct user_table.id_number","lname, fname"," from SYSAD_MANAGE_USER  join user_table on (user_index = USER_INDEX_TO_MANAGE) where SYSAD_USER_INDEX = "+strAuthID+" order by lname, fname", WI.fillTextValue("emp_id"), false)%>
	  </select>
	  </td>
      <td width="9%"><input name="image" type="image" src="../../../images/form_proceed.gif" ></td>
      <td width="55%"></td>
    </tr>
<%}else{%>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="12%">Employee ID</td>
      <td width="23%"><input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();"></td>
      <td width="9%"><input name="image" type="image" src="../../../images/form_proceed.gif" ></td>
      <td width="55%"><label id="coa_info"></label></td>
    </tr>
<%}
if(vRetResult != null && bolIsSchool) {
strSQLQuery = "select BASIC_USER_INDEX from BASIC_USER_LIST where BASIC_USER_INDEX = "+vRetResult.elementAt(0);
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery == null) 
	strSQLQuery = "Authentication is not restricted.";	
else	
	strSQLQuery = "Authentication is Exclusively for Basic Eduction.";
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:AjaxToggleAuthentication();"><img src="../../../images/update.gif" border="0"></a>
	  <font size="1">Click to Toggle</font></td>
      <td colspan="2"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"><%=strSQLQuery%></label></td>
    </tr>
<%}%>
    <tr>
      <td  colspan="5" height="10"><hr size="1"></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td><font size="1">&nbsp;</font></td>
      <td><font size="1">Name</font></td>
      <td><font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(1),(String)vRetResult.elementAt(2),(String)vRetResult.elementAt(3),1)%></strong></font></td>
      <td><font size="1">Gender</font></td>
      <td><font size="1"><strong><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(4))]%></strong></font></td>
    </tr>
    <tr>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">Date of Employment</font></td>
      <td><font size="1"><strong><%=(String)vRetResult.elementAt(6)%></strong></font></td>
      <td><font size="1">Date of Birth</font></td>
      <td><font size="1"><strong><%=(String)vRetResult.elementAt(5)%></strong>(mm/dd/yyyy)
        </font></td>
    </tr>
    <tr>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">Address</font></td>
      <td><font size="1"><strong><%=(String)vRetResult.elementAt(8)%></strong></font></td>
      <td><font size="1">Contact Nos.</font></td>
      <td><font size="1"><strong><%=(String)vRetResult.elementAt(7)%></strong></font></td>
    </tr>
    <tr>
      <td  colspan="5"height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="1%" height="25"><font size="1">&nbsp;</font></td>
      <td width="18%"><font size="1">Employment Type</font></td>
      <td width="34%"><font size="1"><strong><%=(String)vRetResult.elementAt(15)%></strong></font></td>
      <td width="14%"><font size="1">
      <%if(bolIsSchool){%>College<%}else{%>Division<%}%> </font></td>
      <td width="33%"><font size="1"><strong><%=WI.getStrValue(vRetResult.elementAt(13))%></strong></font></td>
    </tr>
    <tr>
      <td height="25"><font size="1">&nbsp;</font></td>
      <td height="25"><font size="1">Employment Status</font></td>
      <td height="25"><font size="1"><strong><%=WI.getStrValue((String)vRetResult.elementAt(16))%>
        </strong></font></td>
      <td height="25"><font size="1">Office/Department </font></td>
      <td height="25"><font size="1"><strong><%=WI.getStrValue((String)vRetResult.elementAt(14))%></strong></font></td>
    </tr>
    <tr>
      <td  colspan="5" height="25"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="41%">Access type :
	    <select name="auth_type">
<%
strTemp = WI.fillTextValue("auth_type");
if(strTemp.length() ==0)
{
	//get auth type index from user information.
	strTemp = WI.getStrValue(vRetResult.elementAt(19));
}%>

<%=dbOP.loadCombo("AUTH_TYPE_INDEX","AUTH_TYPE"," from AUTH_TYPE where IS_DEL=0 and auth_type_index <> 4 and auth_type_index <> 6 order by AUTH_TYPE_INDEX asc", strTemp, false)%>
        </select></td>
      <td width="58%">User type :
        <select name="mem_type" onChange="ShowHideUserType();">
 <%
strTemp = WI.fillTextValue("mem_type");
if(strTemp.length() ==0)
{
	//get auth type index from user information.
	strTemp = WI.getStrValue(vRetResult.elementAt(20));
}%>
         <option value="0">Others</option>
<%=dbOP.loadCombo("MEM_TYPE_INDEX","MEMBER_TYPE"," from SCHOOL_MEM_TYPE where is_valid=1 and is_student=0 order by MEMBER_TYPE asc",strTemp, false)%>
<%
strTemp2 = WI.fillTextValue("oth_mem_type");
if(WI.fillTextValue("reloadPage").compareTo("1") !=0)
	strTemp2 = "";
%>
        </select> <input name="oth_mem_type" type="text" size="20" value="<%=strTemp2%>" id="oth_" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%
if(strTemp.compareTo("0") != 0){%>
<script language="JavaScript">
ShowHideUserType();
</script>
<%}%>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Modules to access :
<%
if(bolIsWNURestrictedUser)
	strTemp = " and exists (select * from SYSAD_MANAGE_MODSUBMOD where SYSAD_INDEX = "+strAuthID+" and mod_index = module_index) ";
else	
	strTemp = "";
%>
        <select name="main_module" onChange="ReloadPage();">
<%if(!bolIsWNURestrictedUser) {%>
          <option value="0">All</option>
<%}%>		  
          <%=dbOP.loadCombo("MODULE_INDEX","MODULE_NAME"," from MODULE where IS_DEL=0 "+strTemp+" order by MODULE_NAME asc", WI.fillTextValue("main_module"), false)%>
        </select></td>
      <td>Sub-modules :
        <select name="sub_module">
		<option value="0">All</option>
          <%
strTemp = WI.fillTextValue("main_module");
if(strTemp.length() ==0) strTemp = "0";
strTemp = " from SUB_MODULE where is_del=0 and module_index="+strTemp+" order by sub_mod_name";
%>
          <%=dbOP.loadCombo("SUB_MOD_INDEX","SUB_MOD_NAME",strTemp, request.getParameter("sub_module"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Access mode:
        <select name="access_mode">
          <option value="0">Read Only</option>
<%
strTemp = WI.fillTextValue("access_mode");
if(WI.fillTextValue("reloadPage").compareTo("1") !=0)
	strTemp = "";
if(strTemp.compareTo("1") ==0){
%>
          <option value="1" selected>Read/Write(full)</option>
<%}else{%>
          <option value="1">Read/Write(full)</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Read/Write(edit)</option>
<%}else{%>
          <option value="2">Read/Write(edit)</option>
<%}%>
        </select></td>
      <td>&nbsp;</td>
    </tr>
<%
if( iAccessLevel >1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"><input type="image" src="../../../images/save.gif" onClick="AddAuthentication();">
          <font size="1">click to save entries</font></div></td>
      <td>&nbsp;</td>
    </tr>
<%}%>
  </table>
<%if(vAuthList != null){%>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center">LIST OF
          MODULES THIS USER HAS ACCESS TO</div></td>
    </tr>
    <tr>
      <td height="25"><div align="center"><font size="1"><strong>MODULES</strong></font></div></td>
      <td><div align="center"><strong><font size="1">SUB-MODULES</font></strong></div></td>
      <td><div align="center"><font size="1"><strong>ACCESS MODE</strong></font></div></td>
      <td align="center"><font size="1"><b>DELETE</b></font></td>
    </tr>
<%//System.out.println(vAuthList);
String[] astrConvertAccesType = {"Read Only","Read/Write(full)","Read/Write(edit)"};
for(int i = 0; i< vAuthList.size(); ++i)
{
	strTemp = WI.getStrValue(vAuthList.elementAt(i+2));
	if(strTemp.compareTo("0") ==0) strTemp = "ALL";
	else	strTemp = WI.getStrValue(vAuthList.elementAt(i+4));

	strTemp2 = WI.getStrValue(vAuthList.elementAt(i+3));
	if(strTemp2.compareTo("0") ==0) strTemp2 = "ALL";
	else	strTemp2 = WI.getStrValue(vAuthList.elementAt(i+5));
%>
    <tr>
      <td width="33%" height="25" align="center"><%=strTemp%></td>
      <td width="39%" align="center"><%=strTemp2%></td>
      <td width="15%" align="center"><%=astrConvertAccesType[Integer.parseInt((String)vAuthList.elementAt(i+1))]%></td>
      <td width="13%" align="center">
	  <%
		if(iAccessLevel ==2){%>
		<input type="image" src="../../../images/delete.gif" onClick='DeleteAuthentication("<%=(String)vAuthList.elementAt(i)%>");'>
		<%}else{%>No delete privilege<%}%>
	  </td>
    </tr>
<%
i = i+5;
}%>
  </table>
<%
	}//if vAuthList != null;
}//if basic info not null%>
	 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>

<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
