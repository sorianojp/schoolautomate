<%@ page language="java" import="utility.*,enrollment.CertificationReport,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>

<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	SetFields();
	document.form_.submit();
}

function PrintPage(){
	document.form_.print_page.value = '1';
	document.form_.submit();
}

function SetFields()
{
	document.form_.grade_name.value= document.form_.grade_for[document.form_.grade_for.selectedIndex].text;
	document.form_.semester_name.value= document.form_.semester[document.form_.semester.selectedIndex].text;
}

function focusID() {
	document.form_.stud_id.focus();
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

//update grade unit.
function UpdateGradeUnit(strGSRef, strLabelID) {
	<%if(!strSchCode.startsWith("CIT")){%>
		return;
	<%}%>
	var strNewUnit = prompt('Please enter new unit');
	if(strNewUnit == null || strNewUnit.length == 0) {
		alert('Please enter new Unit.');
		return;
	}
	
	var objCOAInput;
	objCOAInput = document.getElementById(strLabelID);
		
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strIsFinal = "0";
	

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=215&new_gs="+strNewUnit+
				"&gs_ref="+strGSRef+"&is_final="+strIsFinal;

	this.processRequest(strURL);
}
</script>
<body bgcolor="#D2AE72" <%if(WI.fillTextValue("cert_catg").length() > 0){%> onLoad="focusID();"<%}%>>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strCertCatg = WI.fillTextValue("cert_catg");
	if(WI.fillTextValue("print_page").length() > 0){
		if(strCertCatg.length() > 0){
			if(strCertCatg.equals("1")){%>
				<!--<jsp:forward page="./cert_associate.jsp" />-->
			<%}else if(strCertCatg.equals("2")){%>
				<jsp:forward page="./certificate/cert_enrollment.jsp" />				
			<%}else if(strCertCatg.equals("3")){%>
				<jsp:forward page="./certificate/cert_good_moral_undergrad.jsp" />
			<%}else if(strCertCatg.equals("4")){%>
				<jsp:forward page="./certificate/cert_good_moral_grad.jsp" />
			<%}else if(strCertCatg.equals("5")){%>
				<jsp:forward page="./certificate/cert_grades.jsp" />
			<%}else if(strCertCatg.equals("6")){%>
				<jsp:forward page="./certificate/cert_grad.jsp" />
			<%}else if(strCertCatg.equals("7")){%>
				<jsp:forward page="./certificate/cert_gwa.jsp" />			
			<%}
		return;
		}
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Certificates","cert_main_uph.jsp");
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
														null);

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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

Vector vRetResult = new Vector();
CertificationReport certReport = new CertificationReport();
Vector vGradeList = new Vector();
if(WI.fillTextValue("stud_id").length() > 0){
	vRetResult = certReport.getStudDetailForCertificate(dbOP, request);
	if(vRetResult == null)
		strErrMsg = certReport.getErrMsg();
}

if(WI.fillTextValue("cert_catg").length() > 0 && WI.fillTextValue("stud_id").length() > 0){
	if( WI.fillTextValue("cert_catg").equals("5") && vRetResult != null && vRetResult.size() > 0)
		vGradeList = (Vector)vRetResult.remove(0);		
}

%>


<form name="form_" action="./cert_main_uph.jsp" method="post">

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7" align="center"><font color="#FFFFFF"><strong>::::
        CERTIFICATE RELEASING PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td height="25" colspan="5" ><strong><%=WI.getStrValue(strErrMsg)%></strong>	  </td>
    </tr>
	
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="15%">Certificates : &nbsp; </td>
		<td colspan="4">
		<select name="cert_catg" onChange="document.form_.print_page.value='';document.form_.submit();">
			<option value=""></option>
		<%
		strTemp = WI.fillTextValue("cert_catg");
		if(strTemp.equals("1"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><!--	<option value="1" <%//=strErrMsg%>>Certificate of Associate Graduate</option>-->
		<%		
		if(strTemp.equals("2"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>	<option value="2" <%=strErrMsg%>>Certificate of Enrollment</option>
		
		<%		
		if(strTemp.equals("3"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>	<option value="3" <%=strErrMsg%>>Certificate of Undergraduate Good Moral</option>
		
		<%		
		if(strTemp.equals("4"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>	<option value="4" <%=strErrMsg%>>Certificate of Graduate Good Moral</option>
		
		<%		
		if(strTemp.equals("5"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>	<option value="5" <%=strErrMsg%>>Certificate of Grades</option>
		
		<%		
		if(strTemp.equals("6"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>	<option value="6" <%=strErrMsg%>>Certificate of Graduate</option>
		
		<%		
		if(strTemp.equals("7"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>	<option value="7" <%=strErrMsg%>>Certificate of Grade Weighted Average</option>
		</select>		</td>
	</tr>
	
	<%if(WI.fillTextValue("cert_catg").length() > 0){%>
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="15%" height="25" >Student ID: &nbsp; </td>
	  <td width="15%" height="25" >
	  <input name="stud_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeyUp="AjaxMapName('1');" value="<%=WI.fillTextValue("stud_id")%>" size="16">      </td>
      <td width="5%" ><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" border="0"></a></td>
      <td width="11%" ><input type="image" src="../../../../images/form_proceed.gif" onClick="document.form_.print_page.value='';">      </td>
      <td colspan="2" ><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
   <%}%>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="6" height="25" ><hr size="1"></td></tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="">Student Name : <strong><%=WebInterface.formatName((String)vRetResult.elementAt(2),(String)vRetResult.elementAt(3),(String)vRetResult.elementAt(4),7)%></strong></td>		
	</tr>
	<tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Course/Major : <strong><%=(String)vRetResult.elementAt(14)%>
        <%=WI.getStrValue((String)vRetResult.elementAt(16),"/","","")%></strong></td>
    </tr>
	
	<tr>
      <td height="25" >&nbsp;</td>
	  <%
	  strTemp = (String)vRetResult.elementAt(5);
	  if(strTemp.equalsIgnoreCase("M"))
	  	strTemp = "Male";
	  else
		strTemp = "Female";		  			
	  %>
      <td height="25" colspan="2" >Gender : <strong><%=strTemp%></strong></td>
    </tr>		
	
	<tr><td colspan="2">&nbsp;</td></tr>
	
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td align="center"><a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a><font size="1">Click to print certificate</font></td>
	</tr>
</table>

<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td colspan="8" height="25">&nbsp;</td></tr>
<tr> <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
