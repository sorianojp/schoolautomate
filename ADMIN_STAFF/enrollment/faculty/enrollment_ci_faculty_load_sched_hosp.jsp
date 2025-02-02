<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function AddRecord(){
	document.form_.page_action.value ="1";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value ="2";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex,strHospitalName){
	var delConfirm = confirm(" Delete : " + strHospitalName);
	if (delConfirm) {
		document.form_.page_action.value ="0";
		document.form_.info_index.value= strInfoIndex;
		this.SubmitOnce("form_");
	}
}

function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value="1";
	document.form_.info_index.value= strInfoIndex;
	this.SubmitOnce("form_");
}

function CancelRecord(){
	document.form_.prepareToEdit.value="";
	document.form_.hosp_name.value = "";
	document.form_.hosp_code.value = "";
	document.form_.hosp_address.value= "";
	document.form_.page_action.value="";
	this.SubmitOnce("form_");	
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,hr.HRManageList,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	Vector vFacultyInfo    = null;
	String strFacultyName  = null;

	int iAccessLevel = 0;
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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-LOADING(CLINICAL SCHEDULE)"),"0"));
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
								"Admin/staff-Enrollment-Faculty-load CI schedule","enrollment_ci_faculty_load_sched.jsp");
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
														"enrollment_faculty_ci_load_sched.jsp");
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


HRManageList hrList = new HRManageList();

Vector vRetEdit = null;
Vector vRetResult = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (WI.fillTextValue("page_action").equals("0")){	
	if (hrList.operateOnHospitals(dbOP,request,0) != null) 
		strErrMsg = "Hospital Record removed successfully.";
	else
		strErrMsg = hrList.getErrMsg();
}else if (WI.fillTextValue("page_action").equals("1")){
	if (hrList.operateOnHospitals(dbOP,request,1) != null) 
		strErrMsg = "Hospital Record saved successfully.";
	else
		strErrMsg = hrList.getErrMsg();

}else if (WI.fillTextValue("page_action").equals("2")){
	if (hrList.operateOnHospitals(dbOP,request,2) != null) 
		strErrMsg = "Hospital Record edited successfully.";
	else
		strErrMsg = hrList.getErrMsg();
}

if (strPrepareToEdit.compareTo("1") == 0){
	vRetEdit = hrList.operateOnHospitals(dbOP,request,3);
	if (vRetEdit == null) 
		strErrMsg = hrList.getErrMsg();
}

vRetResult = hrList.operateOnHospitals(dbOP,request,4);

%>

<form action="./enrollment_ci_faculty_load_sched_hosp.jsp" method="post" name="form_" id="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          FACULTY PAGE - CLINICAL INSTRUCTOR LOADING/SCHEDULING ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr  bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="30" colspan="2"><a href="./enrollment_ci_faculty_load_sched_new.jsp?emp_id=<%=WI.fillTextValue("emp_id")%>&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>">
	  				<img src="../../../images/go_back.gif" border="0"></a>
			<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","&nbsp;")%>
	   </td>
	  
    </tr>
	<tr> 
      <td width="1%" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="16%" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="83%" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Name of Hospital</td>
      <td bgcolor="#FFFFFF">
<%
	if (vRetEdit != null) strTemp = (String)vRetEdit.elementAt(1);
	else strTemp = WI.fillTextValue("hosp_name");
%>
	  	<input name="hosp_name" type="text" size="64" maxlength="64"  class="textbox"  value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Hospital Code</td>
      <td bgcolor="#FFFFFF">
  <%
	if (vRetEdit != null) strTemp = (String) vRetEdit.elementAt(2);
	else 	strTemp = WI.fillTextValue("hosp_code");	  	
  %> 
	  	<input name="hosp_code" type="text"  class="textbox"  value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	 size="8" maxlength="8" >
	   </td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Address</td>
      <td bgcolor="#FFFFFF">
<%
	if(vRetEdit != null) strTemp = (String)vRetEdit.elementAt(3);
	else strTemp = WI.fillTextValue("hosp_address");
%>
	  <input name="hosp_address" type="text"  class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	 size="64" maxlength="64"></td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF"><font size="1">
<% 
if (iAccessLevel > 1) {
	if (vRetEdit == null) {  %> 
		 <a href="javascript:AddRecord()"><img src="../../../images/save.gif" border="0"></a>click to save hospital record 
	<%}else{%>    
		<a href="javascript:EditRecord()"><img src="../../../images/edit.gif" border="0"></a>click to edit hospital record 
		<a href="javascript:CancelRecord()"><img src="../../../images/cancel.gif" border="0"></a>click to cancel edit
	<% } // vRetEdit == null
} //end iAccessLevel > 1%>  
	  </font></td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>	
  </table>

<% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EBD6E6"> 
      <td height="26" colspan="4" align="center" class="thinborder"><strong><font color="#0000FF">LIST 
        OF HOSPITALS</font></strong></td>
    </tr>
    <tr> 
      <td width="31%" align="center" class="thinborder"><strong>NAME OF HOSPITAL</strong></td>
      <td width="41%" align="center" class="thinborder"><strong>HOSPITAL/CLINIC 
        ADDRESS</strong></td>
      <td width="14%" align="center" class="thinborder"><strong>HOSPITAL CODE 
        </strong></td>
      <td width="14%" height="25" align="center" class="thinborder"><strong>OPTIONS</strong></td>
    </tr>
<% for (int i = 0; i < vRetResult.size(); i+=4) {%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td height="25" align="center" class="thinborder">
<% if (iAccessLevel > 1) {%>
	  <a href="javascript:PrepareToEdit('<%=vRetResult.elementAt(i)%>')">
	  		<img border="0" src="../../../images/edit.gif" width="40" height="26"></a>
<%} if (iAccessLevel == 2){%>
		<a href="javascript:DeleteRecord('<%=vRetResult.elementAt(i)%>','<%=vRetResult.elementAt(i+1)%>')"><img border="0" src="../../../images/delete.gif" width="55" height="28"></a> 
        <%} // if iaccesslevel ==2 %>
	  </td>
    </tr>
<%} // end for loop %>
  </table>
<%} //end if vRetResult != null %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" >&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
