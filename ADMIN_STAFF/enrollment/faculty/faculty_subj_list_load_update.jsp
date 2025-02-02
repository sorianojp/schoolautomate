<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.sub_group.selectedIndex = 0;
	document.form_.sub_code.selectedIndex = 0;
	document.form_.submit();
}
function RefreshRecord(){
	document.form_.page_action.value = "";
	document.form_.sub_group[document.form_.sub_group.selectedIndex].value="";
	document.form_.sub_code[document.form_.sub_code.selectedIndex].value="";
	document.form_.submit();
}

function SaveRecord(index){
	document.form_.page_action.value = 1;
	document.form_.recordnum.value = index;
}

function DeleteRecord(index){
	document.form_.info_index.value = index;
	document.form_.page_action.value= 0;
	document.form_.submit();	
}
function UpdateSubject(){
	document.form_.page_action.value = "";
	document.form_.submit();
}

function UpdateSubjectGroup(){
	document.form_.page_action.value = "";
	document.form_.sub_code.selectedIndex=0;
	document.form_.submit();
}
function PrintPage(){
	location = "./faculty_subj_list_load_update_print.jsp?emp_id="+document.form_.emp_id.value +
	"&sy_from="+document.form_.sy_from.value+"&semester="+document.form_.semester.value;
}
function GoBack() {
	location = "./faculty_subj_list_load.jsp?emp_id="+document.form_.emp_id.value+
	"&semester="+document.form_.semester.value+"&sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value;
}
function updateFacultyLoad() {
	var pgLoc = "./faculty_subj_list_load_update_detail.jsp?emp_id="+document.form_.emp_id.value;
	var win=window.open(pgLoc,"EditWindow",'width=850,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagementExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String[]  astrConvertSem ={"Summer", "1st", "2nd", "3rd"};

	String strErrMsg = null;
	String strTemp = null;
	boolean[] bolConflict = {false}; // this is passed to getSubjectScheduleTime to check if the subject is conflict with the previous

	int iAccessLevel = 0;
	
	boolean bolAllowToOverLoad = true;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-CAN TEACH"),"0"));
			if(strSchCode.startsWith("EAC")) {
				if(Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-ALLOW OVERLOAD"),"0")) > 0) 
					bolAllowToOverLoad = true;
				else	
					bolAllowToOverLoad = false;
			}
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-schedule","faculty_sched.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"faculty_sched.jsp");
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
**/
//end of authenticaion code.
Vector vPersonalDetails = new Vector();
Vector vRetResult = new Vector();
Vector vSubResult = new Vector();

String strEmpID = WI.fillTextValue("emp_id");
String strSyFrom = WI.fillTextValue("sy_from");
int strSyTo = Integer.parseInt(strSyFrom) + 1;
String strSemester = WI.fillTextValue("semester");
String strPageAction= WI.fillTextValue("page_action");
FacultyManagementExtn fm = new FacultyManagementExtn();

if (strPageAction.compareTo("1")==0){
	if (WI.fillTextValue("recordnum").compareTo("1") == 0){
	}else{
		vRetResult = fm.operateOnFacCanTeach(dbOP,request,1);	
	}
	
	if (vRetResult != null){
		if (WI.fillTextValue("recordnum").compareTo("1") == 0){
			strErrMsg = "Illigal Operation.";
		}else{
			strErrMsg= " Subject(s) added successfully.";
		}
	}else{
		strErrMsg = fm.getErrMsg();
	}
}else{ if(strPageAction.compareTo("0") == 0){
		vRetResult = fm.operateOnFacCanTeach(dbOP,request,0);
		
		if(vRetResult != null){
			strErrMsg = " Subject removed successfully.";	
		}else{
			strErrMsg = fm.getErrMsg();
		}
	} //end if
	
}// end else if


if (strEmpID.length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
}

String strMaxLoad =  fm.getFacMaxLoad(dbOP,request);
if (strMaxLoad == null){
	strMaxLoad =  WI.fillTextValue("maxload");
}

String strSubCode = WI.fillTextValue("sub_code");
String strSubGroup = WI.fillTextValue("sub_group");

String strSubDescription = null;

if(strSubCode.length()!=0){
	vSubResult = fm.getSubjectInfo(dbOP,strSubCode);
	if (vSubResult==null){
		strErrMsg = fm.getErrMsg();
	}else{
		strSubGroup = (String)vSubResult.elementAt(1);
		strSubDescription = (String)vSubResult.elementAt(0);
	}
}

%>
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY PAGE - LIST OF SUBJECTS FACULTY CAN TEACH- UPDATE PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25"> 
<a href="javascript:GoBack()"><img src="../../../images/go_back.gif" hspace="15" border="0"></a><strong>&nbsp;<%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
    <tr> 
      <td height="18"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Employee Name</td>
      <td width="24%"> &nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></td>
      <td width="19%">Employment Status</td>
      <td width="35%">&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(16),"N/A")%></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>  
      <td>College</td>
      <td>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(13),"N/A")%></td>
      <td>Employment Type</td>
      <td>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(15),"N/A")%></td>
    </tr>
    <tr > 
      <td height="24">&nbsp;</td>
      <td>Department</td>
      <td>&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"N/A")%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr> 
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:10px;">Click here to manage faculty Load Detail :: 
	  &nbsp;&nbsp;&nbsp;
	  <%if(bolAllowToOverLoad){%>
	  	<a href="javascript:updateFacultyLoad();"><img src="../../../images/update.gif" border="0"></a>
	  <%}%>
	  	  </td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
<%
//I have to get here faculty load information.. 
vRetResult = fm.operateOnFacultyOverLoad(dbOP, request, 4);
if(vRetResult == null){%>
	Error Message : <%=fm.getErrMsg()%>
<%}else{%>
	<table width="50%" align="center" cellpadding="0" cellspacing="0" class="thinborder">
	<tr bgcolor="#999966" style="font-weight:bold">
		<td width="25%" class="thinborder">SY-Term</td>
		<td width="20%" class="thinborder">Max Load</td>
		<td width="30%" class="thinborder">Load Assigned</td>
		<td width="25%" class="thinborder">Load Type</td>
	</tr>
<%
String[] astrConvertTerm = {"Summer","1st sem","2nd sem","3rd sem"};
for(int i = 0; i < vRetResult.size(); i += 5){
strTemp = (String)vRetResult.elementAt(i + 1);
if(strTemp != null) 
	strTemp = ", "+astrConvertTerm[Integer.parseInt(strTemp)];
else	
	strTemp = "&nbsp;";%>
	<tr bgcolor="#FFFFCC">
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i))%><%=strTemp%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2), "&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
		<td class="thinborder"><%if(vRetResult.elementAt(i) == null) {%>Default<%}%>&nbsp;</td>
	</tr>
<%}%>
	</table>
<%}%> 
	  </td>
    </tr>
<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Maximum Load (Units/Hours) : 
        <input name="maxload" type="text" size="4" value="<%=strMaxLoad%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25" colspan="2"><input type="image" src="../../../images/save.gif" onClick="SaveRecord(1);"> 
        <font size="1">click to save/edit units</font></td>
    </tr>
-->
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="3">Subject Group : 
        <select name="sub_group" onChange="UpdateSubjectGroup();">
          <option value="">Select Subject Group</option>
          <%=dbOP.loadCombo("group_index","group_name"," from subject_group where IS_DEL=0 order by group_name asc", strSubGroup, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Subject Code : 
        <select name="sub_code" style="width:600px">
          <option value="">ALL</option>
          <% if (WI.fillTextValue("sub_group").length()!=0){ %>
          <%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where IS_DEL=0 and GROUP_INDEX = " + strSubGroup + "order by sub_code asc", strSubCode, false)%> 
          <%}else{%>
          <%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where IS_DEL=0 order by sub_code asc", strSubCode, false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="39">&nbsp;</td>
      <td height="39" colspan="2"><input type="image" src="../../../images/save.gif" onClick="SaveRecord(2)"> 
        <font size="1">click to save/edit entries <a href="javascript:CancelRecord()"><img src="../../../images/cancel.gif" border="0" ></a><font size="1">click 
        to cancel/clear entries</font></font></td>
      <td width="33%" height="39"><div align="right"><font size="1"></font></div></td>
    </tr>
  </table>
<% vRetResult = fm.operateOnFacCanTeach(dbOP, request, 4); %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center">LIST OF 
          SUBJECTS FACULTY CAN TEACH FOR SEM <strong><%=astrConvertSem[Integer.parseInt(strSemester)]%></strong> , SY <strong><%=strSyFrom%> - <%=strSyTo%></strong></div></td>
    </tr>
    <tr bgcolor="#B9B292"> 
      <td width="1%" height="25" bgcolor="#FFFFFF">&nbsp;&nbsp;&nbsp;&nbsp;Maximum 
        Load Units : <strong><%=strMaxLoad%></strong></td>
      <td width="1%" height="25" bgcolor="#FFFFFF"><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0" ></a><font size="1">click 
          to print list</font></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="13%" height="25"><div align="center"><strong><font size="1">SUBJECT 
          GROUP</font></strong></div></td>
      <td width="12%" height="20"><div align="center"><strong><font size="1">SUBJECT 
          CODE</font></strong></div></td>
      <td width="34%"><div align="center"><strong><font size="1">SUBJECT TITLE </font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">OPTION</font></strong></div></td>
    </tr>
<% if (vRetResult != null && vRetResult.size()>0){
	for (int i = 0; i< vRetResult.size() ; i+=6) {
%> 
    <tr> 

      <td height="25">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp")%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td><div align="center"><a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" border="0" ></a></div></td>
    </tr>
<%} // end for loop
}else{ strErrMsg = fm.getErrMsg();  %>
    <tr> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <td width="12%"></tr>
    <tr>
      <td width="84%">&nbsp;</td>
      <td width="16%" height="25">&nbsp; </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="emp_id" value="<%=strEmpID%>">
  <input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
  <input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
  <input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
  <input type="hidden" name="recordnum">
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
