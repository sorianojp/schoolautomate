<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.offlineRegd.page_action.value = "";
	document.offlineRegd.submit();
}
function PageAction(strInfoIndex,strPageAction)
{
	document.offlineRegd.page_action.value = strPageAction;
	document.offlineRegd.info_index.value = strInfoIndex;
	document.offlineRegd.submit();
}
function PrepareToEdit(strInfoIndex)
{
	document.offlineRegd.page_action.value = "";
	document.offlineRegd.info_index.value = strInfoIndex;
	document.offlineRegd.prepareToEdit.value = "1";
	document.offlineRegd.submit();
}
function EditRecord()
{
	document.offlineRegd.page_action.value = "2";
	document.offlineRegd.submit();
}
function CancelRecord()
{
	location = "./change_stud_critical_info_yrlevel.jsp?stud_id="+document.offlineRegd.stud_id.value;
}
function OpenSearch(strIDInfo) {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=offlineRegd.stud_id";
		
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.offlineRegd.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.offlineRegd.stud_id.value = strID;
	document.offlineRegd.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.offlineRegd.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>

<body bgcolor="#D2AE72" onLoad="document.offlineRegd.stud_id.focus()">
<%@ page language="java" import="utility.*,student.ChangeCriticalInfo,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	Vector vStudInfo = null;
	Vector vEditInfo = null;
	
	String strTemp = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code")); 
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","create_old_stud_basicinfo.jsp");
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
														"Admission","Student Info Mgmt",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Update Year Level",request.getRemoteAddr(),
														null);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vYrLevelInfo = null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
strTemp = WI.fillTextValue("page_action");

ChangeCriticalInfo changeInfo = new ChangeCriticalInfo();
boolean bolIsEnrolled = false;
String strEnrolledMsg = "Student is enrolled thru' normal enrollment procedure. Only Year level can be changed";

vStudInfo = changeInfo.getStudentEntryInfo(dbOP,WI.fillTextValue("stud_id"));
if(vStudInfo == null)
	strErrMsg  = changeInfo.getErrMsg();

if(strErrMsg == null && strTemp.length() > 0 && vStudInfo != null && vStudInfo.size() > 0)//edit/delete.
{
	if(changeInfo.operateOnYearLevel(dbOP,request,(String)vStudInfo.elementAt(0),Integer.parseInt(strTemp)) == null)
		strErrMsg = changeInfo.getErrMsg();
	else
	{
		strErrMsg = "Operation successful";
		strPrepareToEdit = "";
	}
}

if(vStudInfo != null)
{
	vYrLevelInfo =changeInfo.operateOnYearLevel(dbOP,request,(String)vStudInfo.elementAt(0),4);
	if(vYrLevelInfo == null)
		strErrMsg = changeInfo.getErrMsg();
}
if(strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = changeInfo.operateOnYearLevel(dbOP,request,(String)vStudInfo.elementAt(0),3);
	if(vEditInfo == null)
		strErrMsg = changeInfo.getErrMsg();
	//I have to check if the studnet is enrolled in the normal enrollment procedure.
	if( ((String)vEditInfo.elementAt(5)).compareTo("1") ==0)
	bolIsEnrolled = true;

}
String[] astrConvertToSem={"Summer","1st Sem","2nd Sem","3rd Sem"};
String[] astrConvertToYr = {"","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};

	Vector vLockInfo = new Vector();
	if(vStudInfo != null && vStudInfo.size() > 0) {
		enrollment.SetParameter paramGS = new enrollment.SetParameter();
		vLockInfo = paramGS.operateOnLockFeeLD(dbOP,request,5);
		if(vLockInfo == null)
			vLockInfo = new Vector();
	}


boolean bolIsSuperUser = false;
if(strSchCode.startsWith("DLSHSI")) {
	
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null) {//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
		if(iAccessLevel == 2)
			bolIsSuperUser = true;
	}
}


dbOP.cleanUP();

%>
<form action="./change_stud_critical_info_yrlevel.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENT YEAR LEVEL INFORMATION UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" > <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top"> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" >Student ID :</td>
      <td width="23%" ><input type="text" name="stud_id" size="18" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="8%" height="25"><!--<a href="javascript:OpenSearch()">Search ID</a>&nbsp;-->
	  <input type="image" src="../../images/form_proceed.gif"></td>
      <td width="54%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" >Name: </td>
      <td colspan="3" ><%=(String)vStudInfo.elementAt(1)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Entry Status:</td>
      <td width="41%"><%=(String)vStudInfo.elementAt(10)%></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Course/Major: </td>
      <td><%=(String)vStudInfo.elementAt(2)%> 
        <%if(vStudInfo.elementAt(3) != null){%>
        <%=(String)vStudInfo.elementAt(3)%> 
        <%}%>
        (<%=(String)vStudInfo.elementAt(11)%> - <%=(String)vStudInfo.elementAt(12)%>) 
      </td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td><strong>SCHOOL YEAR - TERM</strong></td>
      <td width="10%"><strong>YEAR LEVEL</strong></td>
      <td width="32%"><strong>EDIT</strong></td>
    </tr>
<%
if(vYrLevelInfo != null) {
boolean bolIsFeeLocked = false;
//System.out.println(vYrLevelInfo);
	for(int i = 0; i< vYrLevelInfo.size() ;i +=5){
		strTemp = (String)vYrLevelInfo.elementAt(i+1)+" - "+(String)vYrLevelInfo.elementAt(i+3);
		if(vLockInfo.indexOf(strTemp) > -1)
			bolIsFeeLocked = true;
		else
			bolIsFeeLocked = false;
		
		if(bolIsSuperUser)
			bolIsFeeLocked = false;	
	%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td><%=(String)vYrLevelInfo.elementAt(i+1)%> - <%=(String)vYrLevelInfo.elementAt(i+2)%> - 
	  <%=astrConvertToSem[Integer.parseInt((String)vYrLevelInfo.elementAt(i+3))]%></td>
      <td><%=astrConvertToYr[Integer.parseInt(WI.getStrValue((String)vYrLevelInfo.elementAt(i+4),"0"))]%></td>
      <td><%if(!bolIsFeeLocked){%>
	  		<a href='javascript:PrepareToEdit("<%=(String)vYrLevelInfo.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a> 
        <%}else{%>
			Fee Locked
		<%}%>
		<!--&nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; 
		<a href='javascript:PageAction("<%=(String)vYrLevelInfo.elementAt(i)%>","0");'><img src="../../images/delete.gif" border="0"></a> 
		-->
      </td>
    </tr>
<%}
}%>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
 <%}//only if student information is not null. 
 
if(strPrepareToEdit.compareTo("1") == 0 && strErrMsg == null)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="right" width="17%">Year Level: </td>
      <td><select name="year_level">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.length() ==0 && vEditInfo != null)
	strTemp = WI.getStrValue(vEditInfo.elementAt(4));
strTemp = WI.getStrValue(strTemp);
if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select></td>
    </tr>
<%
if(!bolIsEnrolled){%>
    <tr> 
      <td height="25"><div align="right">School Year - Term: </div></td>
      <td> 
        <%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0 && vEditInfo != null) 
	  	strTemp = (String)vEditInfo.elementAt(1);
	  %>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("offlineRegd","sy_from","sy_to")' readonly="yes"> 
        <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0 && vEditInfo != null) 
	  	strTemp = (String)vEditInfo.elementAt(2);
	  %>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
        &nbsp;&nbsp;&nbsp; <select name="semester" readonly="yes">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
strTemp = WI.getStrValue(strTemp);
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  
		  if (!strSchCode.startsWith("CPU")) { 
 		    if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  } %>
        </select>
      </td>
    </tr>
<%}else{//If student enrolled thru' normal procedure do not display schoolyear/ sem and should not be changed.%>
    <tr> 
      <td height="25"><div align="right"></div></td>
      <td><strong><font color="#0000FF"><%=strEnrolledMsg%></font></strong> 
        <input type="hidden" name="sy_from" value="<%=(String)vEditInfo.elementAt(1)%>">
	  <input type="hidden" name="sy_to" value="<%=(String)vEditInfo.elementAt(2)%>">
	  <input type="hidden" name="semester" value="<%=(String)vEditInfo.elementAt(3)%>">
	  </td>
    </tr>
<%}%>
    <tr> 
      <td width="17%">&nbsp; </td>
      <td width="83%"> <a href="javascript:EditRecord();"><img src="../../images/save.gif" border="0"></a> 
        <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"><img src="../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel &amp; clear entries</font> </td>
    </tr>
  </table>
 <%}//if iAccessLevel > 1%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="79%" height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
<input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
<%}%>
</form>
</body>
</html>
