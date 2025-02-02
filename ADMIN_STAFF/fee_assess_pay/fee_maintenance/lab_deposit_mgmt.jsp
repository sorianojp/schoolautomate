<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function AddRecord() {
	document.form_.iAction.value = "1";
	document.form_.submit();
}
function DeleteRecord(strTargetIndex) {
	document.form_.iAction.value = "0";
	document.form_.info_index.value = strTargetIndex;
	document.form_.submit();
}
function ReloadPage(){
	document.form_.iAction.value = "";
	document.form_.submit();
}



</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FALabDepositExclude,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

	boolean bolHandsOn = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-misc fee","fm_misc_fee.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"fm_misc_fee.jsp");
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
Vector vRetResult = null;
FALabDepositExclude lde = new FALabDepositExclude();

if (WI.fillTextValue("iAction").compareTo("0") == 0){
	vRetResult = lde.operateOnLabDepositExcl(dbOP,request,0);
	if (vRetResult != null){
		strErrMsg = "Subject removed successfuly";
	}else{
		strErrMsg = lde.getErrMsg();
	}
}else  if (WI.fillTextValue("iAction").compareTo("1") == 0){
	vRetResult = lde.operateOnLabDepositExcl(dbOP,request,1);
	if (vRetResult != null){
		strErrMsg = "Subject added successfully";
	}else{
		strErrMsg = lde.getErrMsg();
	}
}

%>


<form action="./lab_deposit_mgmt.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LABORATORY DEPOSIT MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3">&nbsp; <strong>NOTE: Enter subjects not having 
        Laboratory deposit </strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">School year </td>
      <td width="84%"> 
<%	strTemp = request.getParameter("sy_from");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%	strTemp = request.getParameter("sy_to");
	if(strTemp == null || strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> 
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> 
<%
	strTemp = request.getParameter("semester");
	if (strTemp == null) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sem"); 
%> 
	<select name="semester">
          <option value="">ALL</option>
		<% if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
		<%}else{%>
          <option value="0">Summer</option>
		<%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
		<%}else{%>
          <option value="1">1st Sem</option>
		<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
	    <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course </td>
      <td> 
<% 
	strTemp = request.getParameter("course_index");
	if(strTemp == null || strTemp.length() == 0) strTemp = "";
%> 
	<select name="course_index" onChange="ReloadPage();">
          <option value="">Select Course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 " + 
							 "  and  (degree_type=0 or degree_type = 3) " + 
							 " order by course_name asc", strTemp, false)%> 
	 </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major </td>
      <td><select name="major_index" onChange="ReloadPage();">
          <option value =""></option>
<%
if(strTemp != null && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>	
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
<%}%>
        </select>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Subject</td>
      <td><select name="sub_index">
          <option value="">ALL</option>
<%
	strTemp = "";
	if (WI.fillTextValue("course_index").length() > 0) {
		strTemp = " and course_offered.course_index = " + WI.fillTextValue("course_index")  + 
					" and course_offered.is_del =0";

	if (WI.fillTextValue("major_index").length() > 0)
		strTemp += " and major.major_index = " + WI.fillTextValue("major_index")  + " and major.is_del=0";
	}
	
	
	strTemp = " from subject join curriculum on (subject.sub_index = curriculum.sub_index) " +
			  " join course_offered on (curriculum.course_index = course_offered.course_index) " +
			  " left join major on (curriculum.major_index = major.major_index) " +
			  " where subject.is_del= 0 " + strTemp + " and (lab_unit > 0 or hour_lab > 0) order by sub_code" ;
%>
          <%=dbOP.loadComboDISTINCT("SUBJECT.SUB_INDEX","SUB_CODE",strTemp, WI.fillTextValue("sub_index"), false)%> 
        </select></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%	if(iAccessLevel > 1){%>
    <tr> 
      <td width="20" height="50">&nbsp;</td>
      <td width="87">&nbsp;</td>
      <td width="571" valign="bottom"> 
 <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click 
        to add</font> <%}%>
        
		<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
		Click to refresh the page.
      </td>
    </tr>
<% if(strErrMsg != null){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><b><font size="3"><%=strErrMsg%></font></b></td>
    </tr>
<%}//this shows the edit/add/delete success info%>
  </table>
<%  vRetResult = lde.operateOnLabDepositExcl(dbOP,request,4);
	if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="4"><div align="center">LIST OF SUBJECT EXCLUDES 
          LABORATORY DEPOSIT</div></td>
    </tr>
    <tr> 
      <td width="45%" height="25"><div align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></div></td>
      <td width="42%"><div align="center"><font size="1"><strong>SUBJECT CODE 
          (DESCRIPTION) </strong></font></div></td>
      <td width="5%" align="center"><font size="1"><strong>SEM</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
<%
	for(int i = 0 ; i< vRetResult.size() ; i+=6) {
%>
    <tr> 
      <td height="25"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"/ ","","")%>
	  </td>
      <td><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"ALL")%></td>
      <td align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"ALL")%></td>
      <td align="center"> <%if(iAccessLevel ==2 ){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%>
        NA
        <%}%> </td>
    </tr>
<%} //end for loop %>
  </table>
 <%} // end if vRetResult != null %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->

<input type="hidden" name="info_index">
<input type="hidden" name="iAction">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
