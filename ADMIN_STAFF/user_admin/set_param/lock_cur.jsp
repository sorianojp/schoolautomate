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
function PageAction(strAction, strIndex)
{
	document.form_.info_index.value = strIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function ChageCourse() {
	document.form_.major_index.selectedIndex = 0;
	document.form_.cy_from.value = "";
	ReloadPage();
}
function ChageMajor() {
	document.form_.cy_from.value = "";
	ReloadPage();
}
function ChangeCurYR() {
	var iSelIndex = document.form_.cy_from1.selectedIndex;
	document.form_.cy_from.value = eval('document.form_.cy_from1'+iSelIndex+'.value');
	document.form_.cy_to.value = eval('document.form_.cy_to1'+iSelIndex+'.value');
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameter","lock_cur.jsp");

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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"lock_cur.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
Vector vCurYrInfo = null; String strCYFrom = null; String strCYTo = null;

SetParameter paramGS = new SetParameter();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//add/ delete.
	if(paramGS.operateOnLockCur(dbOP, request, Integer.parseInt(strTemp) ) == null) 
		strErrMsg = paramGS.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
//get detail.
//if(request.getParameter("course_index") != null) {
	vRetResult  = paramGS.operateOnLockCur(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null) {
		if(strErrMsg == null)
			strErrMsg = paramGS.getErrMsg();
	}
//}
//I have to get curriculum year information.
if(WI.fillTextValue("course_index").length() > 0 ){
	enrollment.SubjectSection SS = new enrollment.SubjectSection();
	vCurYrInfo = SS.getSchYear(dbOP,WI.fillTextValue("course_index"),WI.fillTextValue("major_index"));
	if(vCurYrInfo == null)
		strErrMsg = SS.getErrMsg();
}

%>
<form name="form_" action="./lock_cur.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LOCK CURRICULUM PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font>
      </td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="45%">Course Name</td>
      <td width="53%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"> <select name="course_index" style="font-size:10px" onChange="ChageCourse();">
          <option value="">Select a course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc",
WI.fillTextValue("course_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td>Curriculum year </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> <select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
		if(WI.fillTextValue("course_index").length()>0) {
			strTemp = " from major where is_del=0 and course_index="+WI.fillTextValue("course_index")+" order by major_name asc" ;
		%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, WI.fillTextValue("major_index"), false)%> 
          <%}%>
        </select></td>
      <td> <%if(vCurYrInfo != null && vCurYrInfo.size() > 0){%> <select name="cy_from1" onChange="ChangeCurYR();">
          <% for(int i = 0; i < vCurYrInfo.size(); i += 2) {
	  if(WI.fillTextValue("cy_from1").compareTo((String)vCurYrInfo.elementAt(i)) == 0){
	  	strCYFrom = (String)vCurYrInfo.elementAt(i); strCYTo = (String)vCurYrInfo.elementAt(i + 1); 
		%>
          <option selected value="<%=(String)vCurYrInfo.elementAt(i)%>"><%=(String)vCurYrInfo.elementAt(i)%> - <%=(String)vCurYrInfo.elementAt(i + 1)%></option>
          <%}else{%>
          <option value="<%=(String)vCurYrInfo.elementAt(i)%>"><%=(String)vCurYrInfo.elementAt(i)%> - <%=(String)vCurYrInfo.elementAt(i + 1)%></option>
          <%}
	  }//end of for
	  if(strCYFrom == null) {
	  	strCYFrom = (String)vCurYrInfo.elementAt(0); 
		strCYTo = (String)vCurYrInfo.elementAt(1); 	
	  }
	 }//only if vCurYrInfo is not null.%>
        </select> <input type="hidden" name="cy_from" value="<%=WI.getStrValue(strCYFrom)%>"> 
        <input type="hidden" name="cy_to" value="<%=WI.getStrValue(strCYTo)%>"> 
	<%
	//I have to insert all possible CY information.
	for(int i = 0,j = 0; vCurYrInfo != null && i < vCurYrInfo.size(); i += 2, ++j) {%>
	<input type="hidden" name="cy_from1<%=j%>" value="<%=(String)vCurYrInfo.elementAt(i)%>">
	<input type="hidden" name="cy_to1<%=j%>" value="<%=(String)vCurYrInfo.elementAt(i + 1)%>">
	<%}%>
	</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><div align="center"> 
	  <%if(iAccessLevel > 1 && strCYFrom != null){%>
	  <a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0"></a> 
          <font size="1" >click to save entries<br>
          <br>
          </font>
	  <%}%>
	  </div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() >0){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
    <tr bgcolor="#A49AAA"> 
      <td height="25" colspan="3" align="center" class="thinborder"> <strong>::: 
        LIST OF CURRICULUM LOCKED ::: </strong></td>
    </tr>
    <tr bgcolor="#FFFFBF"> 
      <td width="63%" height="25" class="thinborder"><div align="center"><font size="1"><strong>COURSE 
          ::: MAJOR</strong></font></div></td>
      <td width="23%" class="thinborder"><div align="center"><font size="1"><strong>CURRICULUM 
          YEAR</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>REMOVE 
          LOCK</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 7){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 6),(String)vRetResult.elementAt(i + 5)+" ::: ","",
	  (String)vRetResult.elementAt(i + 5) )%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)+" - "+
	  (String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">
	  <%if(iAccessLevel == 2) {%>
	  	<a href='javascript:PageAction(0,"<%=(String)vRetResult.elementAt(i)%>");'>
		<img src="../../../images/delete.gif" border="0">
	  <%}%></td>
    </tr>
<%}%>
  </table>
<%}//only if vRetResult is not null
%>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>