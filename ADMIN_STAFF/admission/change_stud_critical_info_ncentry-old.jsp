<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
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
	document.offlineRegd.editClicked.value = "1";
	document.offlineRegd.submit();
}
function EditRecord()
{
	document.offlineRegd.page_action.value = "2";
	document.offlineRegd.submit();
}
function AddRecord()
{
	document.offlineRegd.page_action.value = "1";
	document.offlineRegd.submit();
}
function CancelRecord()
{
	location = "./change_stud_critical_info_ncentry.jsp?stud_id="+document.offlineRegd.stud_id.value;
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,student.ChangeCriticalInfo,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	Vector vStudInfo = null;
	Vector vEditInfo = null;
	boolean bolUseEditValue = false;
	if(WI.fillTextValue("editClicked").compareTo("1") ==0)
		bolUseEditValue = true;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
	
	int i = 0; int j = 0; 
	
	Vector vTemp = new Vector();
	String strCYTo = null;
	String strDegreeType = null;
	
	String strTemp = null;String strTemp2 = null;
	
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
Vector vYrLevelInfo = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
strTemp = WI.fillTextValue("page_action");

ChangeCriticalInfo changeInfo = new ChangeCriticalInfo();
SubjectSection SS 	= new SubjectSection();
vStudInfo = changeInfo.getStudentEntryInfo(dbOP,WI.fillTextValue("stud_id"));
if(vStudInfo == null)
	strErrMsg  = changeInfo.getErrMsg();

if(strErrMsg == null && strTemp.length() > 0 && vStudInfo != null && vStudInfo.size() > 0)//edit/delete.
{
	if(changeInfo.operateOnStudCurriculumHist(dbOP,request,(String)vStudInfo.elementAt(0),Integer.parseInt(strTemp)) == null)
		strErrMsg = changeInfo.getErrMsg();
	else
	{
		strErrMsg = "Operation successful";
		strPrepareToEdit = "";
	}
}

if(vStudInfo != null)
{
	vYrLevelInfo =changeInfo.operateOnStudCurriculumHist(dbOP,request,(String)vStudInfo.elementAt(0),4);
	if(vYrLevelInfo == null)
		strErrMsg = changeInfo.getErrMsg();
}
if(strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = changeInfo.operateOnStudCurriculumHist(dbOP,request,(String)vStudInfo.elementAt(0),3);
	if(vEditInfo == null)
	{
		strErrMsg = changeInfo.getErrMsg();
		bolUseEditValue = false;
	}
}
String[] astrConvertToSem={"Summer","1st Sem","2nd Sem","3rd Sem"};
String[] astrConvertToYr = {"","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};
if(bolUseEditValue)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("course_index");
strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",strTemp,"DEGREE_TYPE", " and is_valid=1 and is_del=0");
%>
<form action="./change_stud_critical_info_ncentry.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENT COURSE INFORMATION UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" > <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" >Student ID :</td>
      <td width="23%" ><input type="text" name="stud_id" size="18" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="62%" height="25"><input type="image" src="../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td height="25" colspan="2" >NOTE : If student is enrolled thru' system, 
        only curriculum year can be changed in this page.</td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
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
        (<%=(String)vStudInfo.elementAt(11)%> - <%=(String)vStudInfo.elementAt(12)%>)      </td>
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
      <td ><strong>SCHOOL YEAR - TERM</strong></td>
      <td colspan="2" align="center"><strong>COURSE/MAJOR(CURRICULUM YR)</strong></td>
      <td width="25%"><strong>EDIT / DELETE</strong></td>
    </tr>
    <%
if(vYrLevelInfo != null)
	for(i = 0; i< vYrLevelInfo.size() ;i +=15){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td ><%=(String)vYrLevelInfo.elementAt(i+1)%> - <%=(String)vYrLevelInfo.elementAt(i+2)%> 
        - <%=astrConvertToSem[Integer.parseInt((String)vYrLevelInfo.elementAt(i+3))]%></td>
      <td colspan="2"><%=(String)vYrLevelInfo.elementAt(i+7)%> 
	  <%
	  if(vYrLevelInfo.elementAt(i+8) != null){%>
	  - <%=(String)vYrLevelInfo.elementAt(i+8)%>
	  <%}%> 
        (<%=(String)vYrLevelInfo.elementAt(i+9)%> - <%=(String)vYrLevelInfo.elementAt(i+10)%>)</td>
      <td>
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vYrLevelInfo.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a> 
        &nbsp;&nbsp; &nbsp; 
	  <%}if(iAccessLevel ==2){%>
	  <a href='javascript:PageAction("<%=(String)vYrLevelInfo.elementAt(i)%>","0");'><img src="../../images/delete.gif" border="0"></a> 
      <%}else{%>
	  N/A<%}%></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"><div align="right">Student Status :</div></td>
      <td>
<%
	
	if(bolUseEditValue) strTemp = (String)vEditInfo.elementAt(11);
	else strTemp = WI.fillTextValue("status_index");
	
   if (strSchCode.startsWith("CPU")){
		strTemp2 =" and status <>'balik-aral' and status <>'semi regular'";
	  }else{
	  	strTemp2 = "";
	  }

%>
	  <select name="status_index">
          <%=dbOP.loadCombo("status_index","status",
		  			" from user_status where is_for_student = 1 "+ strTemp2 +" order by status asc", 
					strTemp, false)%> </select></td>
    <tr> 
      <td height="25"><div align="right">School Year - Term: </div></td>
      <td> 
        <%
	  if(bolUseEditValue) strTemp = (String)vEditInfo.elementAt(1);
	  else strTemp = WI.fillTextValue("sy_from");
	  %>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("offlineRegd","sy_from","sy_to")'> 
        <%
	  if(bolUseEditValue) strTemp = (String)vEditInfo.elementAt(2);
	  else strTemp = WI.fillTextValue("sy_to");
	  %>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
        &nbsp;&nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
          <%
if(bolUseEditValue)
	strTemp = (String)vEditInfo.elementAt(3);
else strTemp = WI.fillTextValue("semester");
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
		  }%>
        </select> </td>
<%
if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
    <tr>
      <td height="25" align="right">Year Level: </td>
      <td><select name="year_level">
          <option value="1">1st</option>
          <%
if(bolUseEditValue)
	strTemp = WI.getStrValue(vEditInfo.elementAt(4));
else strTemp = WI.fillTextValue("year_level");

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
        </select>
<%
if(strDegreeType != null && strDegreeType.compareTo("3") ==0){%>
        - 
        <select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
if(bolUseEditValue)
	strTemp = WI.getStrValue(vEditInfo.elementAt(14));
else strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select>
<%}%>		</td>
    </tr>
<%}//only if year level and proper is allowed -- for masteral / care giver, it is not necessary.
%>
    <tr> 
      <td height="25" align="right">Course</td>
      <td><select name="course_index" onChange="ReloadPage();">
          <%
if(bolUseEditValue)
	strTemp = (String)vEditInfo.elementAt(5);
else strTemp = WI.fillTextValue("course_index");
%>
          <option value="">Select a Course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where is_valid=1 and is_del=0 and is_visible = 1 order by course_name asc",
				strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" align="right">Major</td>
      <td><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
if(strTemp.length() > 0)
{
if(bolUseEditValue)
	strTemp2 = (String)vEditInfo.elementAt(6);
else strTemp2 = WI.fillTextValue("major_index");
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where is_del=0 and course_index="+strTemp+" order by major_name asc", 
		  		strTemp2, false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25" align="right">Curriculum Year</td>
      <td> <select name="cy_from" onChange="ReloadPage();">
          <%
//get here school year
vTemp = SS.getSchYear(dbOP, strTemp,strTemp2);//System.out.println(vEditInfo);
if(bolUseEditValue)
	strTemp = (String)vEditInfo.elementAt(9);
else strTemp = WI.fillTextValue("cy_from");
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
      <td width="17%">&nbsp; </td>
      <td width="83%"> 
        <%
	  if(strPrepareToEdit.compareTo("1") != 0 && iAccessLevel > 1){%>
        <font size="1"><!--<a href="javascript:AddRecord();"><img src="../../images/save.gif" border="0"></a>click 
        to add a new entry -->Save feature disabled.</font> 
        <%}else if(strPrepareToEdit.compareTo("1") ==0 && iAccessLevel > 1){%>
        <a href="javascript:EditRecord();"><img src="../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"><img src="../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel &amp; clear entries</font> 
        <%}%>
      </td>
    </tr>
  </table>
  
 <%}// outer most vStudInfo is not null%>
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
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
<input type="hidden" name="editClicked" value="">
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