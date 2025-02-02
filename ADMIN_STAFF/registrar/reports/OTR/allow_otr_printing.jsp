<%	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5   = (String)request.getSession(false).getAttribute("info5");
%>
	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>

<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}


function ReloadPage(){
	document.form_.submit();
}

function FocusID(){
	document.form_.stud_id.focus();
}

function PageAction(strAction){
	document.form_.page_action.value = strAction;
	this.ReloadPage();
}



</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS","allow_otr_printing.jsp");
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"allow_otr_printing.jsp");
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
enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();
enrollment.OfflineAdmission OA = new enrollment.OfflineAdmission();
enrollment.ReportRegistrarExtn RPExtn = new enrollment.ReportRegistrarExtn();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(!RPExtn.allowOTRPrinting(dbOP, request))
		strErrMsg = RPExtn.getErrMsg();
	else
		strErrMsg = "Student OTR is now opened for printing.";
}


Vector vRetResult = null;
Vector vStudInfo  = null;
Vector vCRStudInfo = null;

String strSYFrom = null; 
String strSYTo = null; 
String strSemester  = null;
boolean bolIsTempStud = false;
if (WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = OA.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"));
	if (vStudInfo == null && strErrMsg == null) 
		strErrMsg= OA.getErrMsg();
}

if(vStudInfo != null && vStudInfo.size() > 0) {	
	strSYFrom = (String)vStudInfo.elementAt(10);
	strSYTo = (String)vStudInfo.elementAt(11);
	strSemester = (String)vStudInfo.elementAt(9);
	
	vCRStudInfo = cRequirement.getStudInfo(dbOP, request.getParameter("stud_id"),strSYFrom,
									strSYTo,strSemester);
	if(vCRStudInfo == null  && strErrMsg == null) 
		strErrMsg = cRequirement.getErrMsg();	
	else {
		if( ((String)vCRStudInfo.elementAt(10)).compareTo("1") == 0)
			bolIsTempStud = true;
	}
		
}
String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
String[] astrConvertToYr  = {"N/A","1ST YR","2ND YR","3RD YR","4TH YR","5TH YR","6TH YR","7TH YR"};

%>
<form action="./allow_otr_printing.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: OTR PRINTING MANAGEMENT PAGE ::::</strong></font></div></td>
	</tr>
	<tr bgcolor="#FFFFFF"><td width="3%" height="25">&nbsp;</td><td><font color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">ID Number</td>
		<td width="13%">
			<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
		</td>
		<td width="67%">
			<a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0" align="absmiddle"></a>
			<a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0" align="absmiddle"></a>
			  <label id="coa_info" style="font-size:11px; width:400px; position:absolute;"></label>
		</td>
		
	</tr>
</table>
<% if(vCRStudInfo != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="6"><hr size="1" noshade> </td>
    </tr>
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Student Name</td>
      <td width="33%"><strong><%=(String)vCRStudInfo.elementAt(1)%></strong></td>
      <td width="47%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course/Major(cy)</td>
      <td colspan="2"><strong><%=(String)vCRStudInfo.elementAt(7)%>
        <%if(vCRStudInfo.elementAt(8) != null){%>
        /<%=(String)vCRStudInfo.elementAt(8)%>
        <%}%>
        (<%=(String)vCRStudInfo.elementAt(4)%> to <%=(String)vCRStudInfo.elementAt(5)%>
        )</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>YEAR LEVEL</td>
      <td><strong><%=astrConvertToYr[Integer.parseInt(WI.getStrValue(vCRStudInfo.elementAt(6),"0"))]%></strong></td>
      <td>SY (TERM ) &nbsp;&nbsp;: &nbsp;&nbsp;<%=strSYFrom + "-" +strSYTo%> (<%=astrConvertToSem[Integer.parseInt(strSemester)]%>)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Status</td>
      <td colspan="2"><strong><%=(String)vCRStudInfo.elementAt(11)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Foreign Student</td>
      <td colspan="2"><font color="#9900FF"><strong>
	  <%
	  if( ((String)vCRStudInfo.elementAt(16)).compareTo("1") ==0){%>
	  YES
	  <%}else{%>
	  NO<%}%></strong></font></td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Allow Reason</td>
		<td colspan="3">
			<textarea cols="60" rows="3" name="allow_reason"><%=WI.fillTextValue("allow_reason")%></textarea>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="3"><a href="javascript:PageAction('1');"><img src="../../../../images/save.gif" border="0"></a>
			<font size="1">Click to allow otr printing</font></td>
	    </tr>
  </table>
  
  

<%}%>
<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="#FFFFFF"><td height="25">&nbsp;</td></tr>
	<tr><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
