<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex, strAction) {
	if(strAction == '0'){
		if(!confirm('Do you want to delete faculty load setting.'))
			return;
	}
	else {
		var newLoad = prompt('Please enter new Load');
		if(newLoad == null || newLoad == '') {
			alert("Please enter valid load");
			return;
		}
		document.form_.maxload.value = newLoad;
		
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagementExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

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
				if(Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-ALLOW OVERLOAD"),"0")) == 0) 
					iAccessLevel = 0;
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
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-Enrollment-Faculty-update Max Load","faculty_subj_list_load_update_detail.jsp");
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
Vector vPersonalDetails = new Vector();
Vector vRetResult = new Vector();
Vector vSubResult = new Vector();

String strEmpID = WI.fillTextValue("emp_id");
String strPageAction= WI.fillTextValue("page_action");
FacultyManagementExtn fm = new FacultyManagementExtn();

boolean bolCreateDefault = true;

if(strPageAction.length() > 0) {
	if(fm.operateOnFacultyOverLoad(dbOP, request, Integer.parseInt(strPageAction)) == null)
		strErrMsg = fm.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
if (strEmpID.length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vPersonalDetails == null)
		strErrMsg = authentication.getErrMsg();
	else {
		vRetResult = fm.operateOnFacultyOverLoad(dbOP, request, 4); 
		if(vRetResult != null) {
			//I have to check if default is created.. 
			for(int i = 0; i < vRetResult.size(); i += 5) {
				if(vRetResult.elementAt(i) == null) {
					bolCreateDefault = false;
					break;
				}
			}
		}
	}
}

%>
<form name="form_" method="post" action="./faculty_subj_list_load_update_detail.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::Faculty load update page ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><strong>&nbsp;<%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
<%if(vPersonalDetails != null && vPersonalDetails.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(bolCreateDefault){%>
    <tr> 
      <td height="18"></td>
      <td height="18" colspan="3" style="font-weight:bold; font-size:9px; color:#0000FF">Note : Must create Default Load. Default load is set for SY and Semester is null. Set SY/Term load only if faculty is allowed for Overload or Underload.</td>
    </tr>
<%}else{%>
    <tr> 
      <td width="2%" height="25"></td>
      <td width="12%">SY-Term : </td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length()  == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp=" DisplaySYTo('form_','sy_from','sy_to')">
	  
	  - 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length()  == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
	
	  -
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
	  <select name="semester">
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
      </select>	  </td>
    </tr>
<%}//show only if default load is created.%>
    <tr> 
      <td width="2%" height="25"></td>
      <td>Max Load :</td>
      <td width="7%"> <input name="maxload" type="text" size="4" value="<%=WI.fillTextValue("maxload")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','maxload');style.backgroundColor='white'"
	  onKeypress="AllowOnlyFloat('form_','maxload')"></td>
      <td width="79%">
	  <input type="submit" name="_" value="Save Max Load" onClick="document.form_.page_action.value='1'">	  </td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Employee Name</td>
      <td width="36%"> &nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></td>
      <td width="18%">Employment Status</td>
      <td width="24%">&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(16),"N/A")%></td>
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
      <td colspan="3">&nbsp;<%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"N/A")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center">LOAD DETAILS </div></td>
    </tr>
    <tr bgcolor="#B9B292"> 
      <td width="1%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="1%" height="25" bgcolor="#FFFFFF"><div align="right"></div></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size()>0){%>  
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr style="font-weight:bold"> 
      <td width="13%" height="25"><div align="center"><font size="1">SY-TERM</font></div></td>
      <td width="12%" height="20"><div align="center"><font size="1">MAX ALLOWED LOAD</font></div></td>
      <td width="12%" align="center" style="font-size:9px;">LOAD ASSIGNED</td>
      <td width="34%"><div align="center"><font size="1">LOAD TYPE </font></div></td>
      <td width="5%"><div align="center"><font size="1">EDIT</font></div></td>
      <td width="5%"><div align="center"><font size="1">DELETE</font></div></td>
    </tr>
<%
String[] astrConvertTerm = {"Summer","1st sem","2nd sem","3rd sem"};
boolean bolIsDefault = false;
for (int i = 0; i< vRetResult.size() ; i+=5) {
strTemp = (String)vRetResult.elementAt(i + 1);
if(strTemp != null) 
	strTemp = ", "+astrConvertTerm[Integer.parseInt(strTemp)];
else	
	strTemp = "&nbsp;";
if(vRetResult.elementAt(i) == null)
	bolIsDefault = true;
else	
	bolIsDefault = false;%>
    <tr <%if(bolIsDefault){%> style="font-weight:bold; color:#0000FF"<%}%>> 

      <td height="25">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i))%><%=strTemp%></td>
      <td>&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 2), "&nbsp;")%></td>
      <td><%if(bolIsDefault){%>xxxx<%}else{%><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%><%}%></td>
      <td>&nbsp;<%if(vRetResult.elementAt(i) == null) {%>Default<%}%>&nbsp;</td>
      <td><a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i + 3)%>','2')"><img src="../../../images/edit.gif" border="0" ></a></td>
      <td align="center">
	  <%if(bolIsDefault) {%>Not Allowed<%}else{%>
	  <a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i + 3)%>','0')"><img src="../../../images/delete.gif" border="0" ></a>
	  <%}%>
	  </td>
    </tr>
<%}%>
  </table>
<%}//only if vRetResult is not null.. 

}//show only if vPersonalDetails is not null%>
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
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
