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
function PrintPg(strStudId)
{
	//fill up the major name and course name,
}
function ReloadPage()
{
}
function ShowCList()
{
}
function ChangeCourse()
{
}
function ChangeMajor()
{
}
function ViewAll() {
}
function ChangeSubject() {
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	String strDegreeType = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-class list","class_lists.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"class_lists.jsp");
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

//end of authenticaion code.

Vector vSecList = null;
Vector vSubList = null;
Vector vSecDetail = null;

ReportEnrollment reportEnrl= new ReportEnrollment();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("show_list").length() > 0) {
	vSubList = reportEnrl.getSubList2(dbOP, request);
	if(vSubList == null)
		strErrMsg = reportEnrl.getErrMsg();
	
}
if(WI.fillTextValue("subject").length() > 0 && WI.fillTextValue("showCList").compareTo("0") != 0)
{
}
if(WI.fillTextValue("section").length() > 0 && WI.fillTextValue("showCList").compareTo("0") != 0)
{
}

if(vSecDetail != null && vSecDetail.size() > 0 && WI.fillTextValue("showCList").compareTo("0") != 0)
{
}

%>
<form action="./class_lists_other.jsp" method="post" name="form_">

  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          REPORTS - CLASS LISTS PAGE ::::
        
          </strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <strong><%=WI.getStrValue(strErrMsg)%></strong> </td>
    </tr>
    
    <tr> 
      <td width="1%">&nbsp;</td>
      <td height="25" colspan="2">Offered By College &nbsp; <select name="c_index" onChange="document.form_.show_list.value='';document.form_.submit();">
          <option value="">Select Any</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2">Offered By Dept &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <select name="d_index">
          <option></option>
          <%
strTemp = WI.fillTextValue("c_index");
if( strTemp.length() > 0) {
strTemp = " from department where is_del=0 and c_index="+strTemp ;
%>
          <%=dbOP.loadCombo("d_index","d_name",strTemp, request.getParameter("d_index"), false)%> 
<%}%>
        </select></td>
    </tr>
    
    <tr> 
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="50%" height="25">SY/Term &nbsp; <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="49%"><input type="image" src="../../../images/form_proceed.gif" border="0" onClick="document.form_.show_list.value='1';"></td>
    </tr>
  </table>

<%
if(vSubList != null && vSubList.size() > 0){%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr  >
      <td height="25" colspan="4"><div align="center">
          <hr size="1">
        </div></td>
    </tr>
    <tr >
      <td>&nbsp;</td>
      <td height="25" colspan="3">Subject Code
        <select name="subject">
		<option></option>
<%
strTemp = WI.fillTextValue("subject");
for(int i = 0; i < vSubList.size(); i += 4) {
	if(strTemp.equals(vSubList.elementAt(i)) )// || (strTemp.length() == 0 && i == 0) )   {
		vSecList = (Vector)vSubList.elementAt(i + 3);
		strErrMsg = "selected";
	}
	else	
		strErrMsg = "";
%>
		<option value="<%=vSubList.elementAt(i)%>" <%=strErrMsg%>><%=(String)vSubList.elementAt(i + 1) + " ("+(String)vSubList.elementAt(i + 2)+")"%></option>

<%}%>	
        </select> 

	  </td>
    </tr>
    <tr >
      <td width="1%">&nbsp;</td>
      <td height="25" colspan="3"></td>
    </tr>
    <tr >
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vSecList != null && vSecList.size() > 0){%>
	
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="0%">&nbsp;</td>
      <td height="25">Section 
        <select name="section" onChange="ReloadPage()" style="font-size:11px">
          <option value="">Select a section</option>
          <%
strTemp = WI.fillTextValue("section");
for(int i=0; i<vSecList.size();i +=2){
	if(strTemp.compareTo((String)vSecList.elementAt(i)) ==0){%>
          <option value="<%=(String)vSecList.elementAt(i)%>" selected><%=(String)vSecList.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vSecList.elementAt(i)%>"><%=(String)vSecList.elementAt(i+1)%></option>
          <%}
}%>
        </select>
        &nbsp;&nbsp;<font size="1">View student in all section.<a href="javascript:ViewAll();"><img src="../../../images/view.gif" border="0"></a></font> 
        <select name="no_of_stud" style="font-size:9px">
		<option value="35">35</option>
		<option value="40">40</option>
		<option value="41">41</option>
		<option value="42">42</option>
		<option value="43">43</option>
		<option value="44">44</option>
		<option value="45">45</option>
		<option value="46">46</option>
		<option value="47">47</option>
		<option value="48">48</option>
		<option value="49">49</option>
		<option value="50">50</option>
		</select>	  </td>
      <td width="39%" height="25">Instructor :
	  <%if(vSecDetail != null){%>
	  <%=WI.getStrValue(vSecDetail.elementAt(0))%>
	  <%}%></td>
    </tr>
</table>

<%
	}//if subject list is not null
}//only if sub section list is not null
%>
   <table width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%strTemp = "";
if(vSecList != null && vSecList.size() > 0) {
	for(int i=0; i<vSecList.size();i +=2){
		if(strTemp.length() == 0)
			strTemp = (String)vSecList.elementAt(i);
		else	
			strTemp += ","+(String)vSecList.elementAt(i);
	}
}
%>
<input type="hidden" name="sub_code_" value="<%=WI.fillTextValue("sub_code_")%>">
<input type="hidden" name="view_all_sec" value="<%=strTemp%>">
<input type="hidden" name="view_all">
<input type="hidden" name="show_list">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
