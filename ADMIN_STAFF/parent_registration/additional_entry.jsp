<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,enrollment.ParentRegistration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>

<script language="JavaScript">


var calledRef;
var strCalledCount;
function AjaxMapName(strCount) {
	//calledRef = strRef;
	var strCompleteName;
	strCalledCount = strCount
	strCompleteName = eval('document.form_.stud_name_'+strCount+'.value');
	if(strCompleteName.length <3)
		return;
		
	if(this.bolReturnStrEmpty && this.startsWith(this.strPrevEntry,strCompleteName, false) == 0)
		return;
	this.strPrevEntry = strCompleteName;
	
	var objCOAInput;
	objCOAInput = document.getElementById("coa_info_"+strCount);	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&name_format=5&complete_name="+escape(strCompleteName);	
	this.processRequest(strURL);
	
}

function UpdateID(strID, strUserIndex) {		
	var strTemp = eval('document.form_.stud_name_'+strCalledCount);		
	strTemp.value = strID;	
	document.form_.donot_call_close_wnd.value = "1";
	document.getElementById("coa_info_"+strCalledCount).innerHTML = "";
	//this.ReloadPage();
}
function UpdateName(strFName, strMName, strLName) {
	document.form_.donot_call_close_wnd.value = "1";
}
function UpdateNameFormat(strName) {
	document.form_.donot_call_close_wnd.value = "1";
}


function ReloadPage() {
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.submit();
}

function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length > 0)
		return;

	if(document.form_.close_wnd_called.value == "0") 
		window.opener.SearchParent();
}

function DisplayStud(){
	var oldvalue = document.form_.old_value.value;
	var newvalue = document.form_.no_of_children.value;
	
	if(oldvalue == newvalue)
		return;

	if(document.form_.no_of_children.value == '')
		return;
	
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.old_value.value = document.form_.no_of_children.value;
	document.form_.submit();
}

function PageAction(strAction){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function deleteStudent(strInfoIndex, validType){	
	document.form_.student_index.value = strInfoIndex;
	document.form_.delete_student.value = validType;//0 - delete :: 1 - restore
	document.form_.valid_type.value = validType;//0 - delete :: 1 - restore
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PARENT REGISTRATION"),"0"));		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

int iSearchResult = 0;

Vector vRetResult = new Vector();
Vector vParentDetail = new Vector();
ParentRegistration prSMS = new ParentRegistration();
Vector vStudList = new Vector();
Vector vStudListDeleted = new Vector();
String strInfoIndex = WI.fillTextValue("info_index");

boolean bolShowContent = false;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0 && strInfoIndex.length() > 0){	
	if(!prSMS.bolAdditionalEntry(dbOP, request, strInfoIndex, Integer.parseInt(strTemp)))
		strErrMsg = prSMS.getErrMsg();
	else
		strErrMsg = "Entry Successfully Added";
}

if(WI.fillTextValue("delete_student").length() > 0 && WI.fillTextValue("student_index").length() > 0 && strInfoIndex.length() > 0){
	if(!prSMS.deleteStudentRegistered(dbOP, request, WI.fillTextValue("student_index"), strInfoIndex))
		strErrMsg = prSMS.getErrMsg();
	else{
		if(WI.fillTextValue("delete_student").equals("0"))
			strErrMsg = "Student Successfully Deleted.";
		else
			strErrMsg = "Deleted Student successfully restored.";
	}
}

if(strInfoIndex.length() > 0){	
	vParentDetail = prSMS.getParentDetail(dbOP, request, strInfoIndex);
	if(vParentDetail == null)
		strErrMsg = prSMS.getErrMsg();
	else{
		vStudList = (Vector)vParentDetail.remove(0);
		vStudListDeleted = (Vector)vParentDetail.remove(0);
		bolShowContent = true;	
	}
	

}



String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSem    = (String)request.getSession(false).getAttribute("cur_sem");

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>
<form action="./additional_entry.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          PARENT REGISTRATION PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<%
if(bolShowContent){
%>
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Parent Name </td>
		<td><strong><%=WI.getStrValue((String)vParentDetail.elementAt(0))%></strong></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Contact No.</td>
		<td><strong><%=WI.getStrValue((String)vParentDetail.elementAt(1))%></strong></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Email Address</td>
		<td><strong><%=WI.getStrValue((String)vParentDetail.elementAt(2))%></strong></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Contact Address</td>
		<td><strong><%=WI.getStrValue((String)vParentDetail.elementAt(3))%> <%=WI.getStrValue((String)vParentDetail.elementAt(4))%></strong></td>
	</tr>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td height="15" colspan="4">&nbsp;</td></tr>
	
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<%
		int iNoOfChild = Integer.parseInt(WI.getStrValue(WI.fillTextValue("no_of_children"),"1"));
		%>
		<td colspan="3">No. of student to register <input type="text" name="no_of_children" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','no_of_children');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','no_of_children'); DisplayStud();" size="3" maxlength="5" value="<%=iNoOfChild%>"/>		</td>
	</tr>
	
	
	<%
	if(iNoOfChild > 0){	
	%>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td width="20%" valign="bottom">Student Name or ID</td>
		<td colspan="2" valign="bottom">Relation to Student</td>
	</tr>
	
	<%
	for(int i = 1; i <= iNoOfChild; i++){
	%>
	
	<tr>
		<td height="25" align="right"><%=i%>. &nbsp;</td>
		<td>
			<input type="text" name="stud_name_<%=i%>" value="<%=WI.fillTextValue("stud_name_"+i)%>" onKeyUp="AjaxMapName('<%=i%>');"
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';"/></td>
				
		<td width="10%"><select name="relationship_<%=i%>">
			<option value=""></option>
		<%
		strTemp = WI.fillTextValue("relationship_"+i);
		%>
			<%=dbOP.loadCombo("relation_name","relation_name"," from hr_preload_relation order by relation_name", strTemp, false)%>
		</select></td> 		
		
		<td valign="middle">
		<input type="button" name="1" value=" ADD ENTRY " 
			style="font-size:11px; height:20; border: 1px solid #FF0000;" 
			onClick="PageAction('<%=i%>')">	  
		&nbsp; &nbsp; 
		<label id="coa_info_<%=i%>" style="width:300px; position:absolute"></label>		</td>
	</tr>
	
	<%}%>
	
	
	
	<tr><td colspan="4">&nbsp;</td></tr>
	
	<%}%>
<%}%>	
	
  </table>

<%if(vStudList != null && vStudList.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td height="30">&nbsp;</td></tr>
	<tr><td align="center" height="25" style=" background-color:#A49A6A;"><strong>LIST OF STUDENT</strong></td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<%
	for(int i = 0 ; i < vStudList.size(); i+=8){
	%>
	<tr><td height="15" colspan="9"><hr size="1%"></td></tr>
	<tr><td align="center"  colspan="9"><a href="javascript:deleteStudent('<%=(String)vStudList.elementAt(i)%>', '0')">Delete Student</a></td></tr>
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="20%">Student ID</td>
		<td width="50%"><%=vStudList.elementAt(i+2)%></td>
		<td rowspan="5" valign="top"><img src="../../upload_img/<%=((String)vStudList.elementAt(i+2)).toUpperCase()%>.jpg" width="125" height="125" border="1" align="top"></td>
	</tr>
	
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="15%">Student Name</td>
		<td><%=vStudList.elementAt(i+3)%></td>
	</tr>
	
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="15%">Course/Grade Level</td>
		<td><%=vStudList.elementAt(i+5)%> <%=WI.getStrValue((String)vStudList.elementAt(i+6),"-","","")%></td>
	</tr>
	
	
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="15%">Gender</td>
		<td><%=vStudList.elementAt(i+4)%></td>
	</tr>
	
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="15%">Parent Relation</td>
		<td><%=vStudList.elementAt(i+7)%></td>
	</tr>
	
	
	<%}%>
</table>
<%}

if(vStudListDeleted != null && vStudListDeleted.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td height="30">&nbsp;</td></tr>
	<tr><td align="center" height="25" style=" background-color:#A49A6A;"><strong>LIST OF DELETED STUDENT</strong></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<%
	for(int i = 0 ; i < vStudListDeleted.size(); i+=8){
	%>
	<tr><td height="15" colspan="9"><hr size="1%"></td></tr>
	<tr><td align="center"  colspan="9"><a href="javascript:deleteStudent('<%=(String)vStudListDeleted.elementAt(i)%>','1')">Restore Deleted Student</a></td></tr>
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="20%">Student ID</td>
		<td width="50%"><%=vStudListDeleted.elementAt(i+2)%></td>
		<td rowspan="5" valign="top"><img src="../../upload_img/<%=((String)vStudListDeleted.elementAt(i+2)).toUpperCase()%>.jpg" width="125" height="125" border="1" align="top"></td>
	</tr>
	
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="15%">Student Name</td>
		<td><%=vStudListDeleted.elementAt(i+3)%></td>
	</tr>
	
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="15%">Course/Grade Level</td>
		<td><%=vStudListDeleted.elementAt(i+5)%> <%=WI.getStrValue((String)vStudListDeleted.elementAt(i+6),"-","","")%></td>
	</tr>
	
	
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="15%">Gender</td>
		<td><%=vStudListDeleted.elementAt(i+4)%></td>
	</tr>
	
	<tr>
		<td width="10%" height="25" colspan="6">&nbsp;</td>
		<td width="15%">Parent Relation</td>
		<td><%=vStudListDeleted.elementAt(i+7)%></td>
	</tr>
	
	
	<%}%>
</table>
<%}%>



<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="search_" value="">
<input type="hidden" name="page_action">

<input type="hidden" name="donot_call_close_wnd">
<input type="hidden" name="close_wnd_called" value="0">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" >

<input type="hidden" name="old_value" value="<%=WI.getStrValue(WI.fillTextValue("old_value"), "1")%>" />
<input type="hidden" name="delete_student" >
<input type="hidden" name="student_index" value="<%=WI.fillTextValue("student_index")%>" >
<input type="hidden" name="valid_type" value="<%=WI.fillTextValue("valid_type")%>" >
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>