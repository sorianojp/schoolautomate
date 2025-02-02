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
function AddRecord()
{
	document.offlineRegd.addRecord.value = "1";
	document.offlineRegd.submit();
}
function ReloadPage()
{
	document.offlineRegd.addRecord.value = "";
	document.offlineRegd.submit();
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
	Vector vTemp = null;

	String strTemp = null;
	String strCYTo = null;
	String strDegreeType  = null;
	int i = 0;
	int j = 0;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");

	if (strSchCode == null) 
		strSchCode = "";
		
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
														"create_old_stud_basicinfo.jsp");
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

ChangeCriticalInfo changeInfo = new ChangeCriticalInfo();
SubjectSection SS = new SubjectSection();
if(WI.fillTextValue("addRecord").compareTo("1") ==0)
{
	if(!changeInfo.createChangeCourseInfo(dbOP,request) )
		strErrMsg = changeInfo.getErrMsg();
	else
		strErrMsg = "Student change course information successfully changed.";
}
vStudInfo = changeInfo.getStudentEntryInfo(dbOP,WI.fillTextValue("stud_id"));
if(vStudInfo == null)
	strErrMsg  = changeInfo.getErrMsg();

String[] astrConvertToSem={"Summer","1st Sem","2nd Sem","3rd Sem"};
String[] astrConvertToYr = {"","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};

if(WI.fillTextValue("course_index").length() > 0 && 
		WI.fillTextValue("course_index").compareTo("selany") != 0 && 
		WI.fillTextValue("course_index").compareTo("0") != 0)
		
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");
	

%>
<form action="./change_stud_critical_info_cc.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENT CHANGE COURSE INFORMATION UPDATE PAGE ::::</strong></font></div></td>
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
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
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
      <td width="19%" >Name: </td>
      <td ><%=(String)vStudInfo.elementAt(1)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Entry Status:</td>
      <td><%=(String)vStudInfo.elementAt(10)%></td>
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
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >School Year/Term: </td>
      <td><%=(String)vStudInfo.elementAt(6)%> - <%=(String)vStudInfo.elementAt(7)%>
        (<%=astrConvertToSem[Integer.parseInt((String)vStudInfo.elementAt(8))]%>)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Year Level: </td>
      <td><%=astrConvertToYr[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(9),"0"))]%></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >New Status</td>
      <td><select name="status_index">
          <%=dbOP.loadCombo("status_index","status"," from user_status where status = 'change course' and is_for_student = 1 order by status asc",
					WI.fillTextValue("entry_status"), false)%> </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Course</td>
      <td><select name="course_index" onChange="ReloadPage();">
          <option value="">Select a Course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where is_valid=1 and is_del=0 and is_visible = 1 order by course_name asc",
				WI.fillTextValue("course_index"), false)%> </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Major</td>
      <td><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
if(WI.fillTextValue("course_index").length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+WI.fillTextValue("course_index")+" order by major_name asc" ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, WI.fillTextValue("major_index"), false)%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Curriculum Year</td>
      <td> <select name="cy_from" onChange="ReloadPage();">
          <%
//get here school year
vTemp = SS.getSchYear(dbOP, request);
strTemp = WI.fillTextValue("cy_from");

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%></option>
          <%	}
	i = i+2;

}
if(vTemp.size() > 0)
	strCYTo = (String)vTemp.elementAt(j+1);
else
	strCYTo = "";

%>
        </select>
        to <b><%=strCYTo%></b> <input type="hidden" name="cy_to" value="<%=strCYTo%>">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >School Year/Term</td>
      <td> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("offlineRegd","sy_from","sy_to")'>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
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
		  }
		  %>
        </select> </td>
    </tr>
<%
if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
   <tr>
      <td height="25">&nbsp;</td>
      <td> Year level entry</td>
      <td><select name="year_level">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("year_level");
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
        </select> </td>
    </tr>
<%}
if(strDegreeType != null && strDegreeType.compareTo("3") ==0 && WI.fillTextValue("stud_status").compareTo("New") !=0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Select Prep/Proper</td>
      <td ><select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td>
        <%
	  if(iAccessLevel > 1){%>
        <a href="javascript:AddRecord();"><img src="../../images/save.gif" border="0"></a>
        <font size="1" >Click to change Student's Entry Status</font>
        <%}else{%>
        Not authorized to modify student's ID
        <%}%>
      </td>
    </tr>
  </table>
<%}%>
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
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
<input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
