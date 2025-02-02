<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strInfoIndex, strAction) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length == 0)
		document.form_.hide_save.src = "../../images/blank.gif";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}


</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-User Management","profile_add_more.jsp");
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
														"System Administration","User Management",request.getRemoteAddr(),
														"profile.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"HR Management"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
Vector vEmpInfo   = null;

Authentication auth = new Authentication();
vEmpInfo = auth.operateOnBasicInfo(dbOP,request,"0");
if(vEmpInfo == null)
	strErrMsg = "Employee information not found. Please create employee information.";
if(WI.fillTextValue("page_action").length() > 0) {
	if(auth.operateOnAddingMoreCollege(dbOP, request, Integer.parseInt(WI.fillTextValue("page_action"))) == null) 
		strErrMsg = auth.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
vRetResult = auth.operateOnAddingMoreCollege(dbOP, request, 4);
%>

<form action="./profile_add_more.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PROFILE - UPDATE EMPLOYEE COLLEGES ASSIGNED PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td width="2%" height="26">&nbsp;</td>
      <td width="98%">
	  <!--<a href="profile.jsp"><img src="../../images/go_back.gif" border="0" ></a>-->
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

<%
if(vEmpInfo != null && vEmpInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="24">&nbsp;</td>
      <td width="548" height="21">Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
      <td width="660" height="21">Employment Type : 
	  <strong><%=(String)vEmpInfo.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> Name : <strong><%=WebInterface.formatName((String)vEmpInfo.elementAt(1), 
	  (String)vEmpInfo.elementAt(2),(String)vEmpInfo.elementAt(3),4)%></strong></td>
      <td>Employment Status : <strong><%=(String)vEmpInfo.elementAt(16)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"> Primary College/Dept :<%=(String)vEmpInfo.elementAt(13)%>
	  <%=WI.getStrValue((String)vEmpInfo.elementAt(14), "/","","")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"> <font color="#0000FF"><strong>NOTE : While creating class 
        program, primary college is recored. But if employee is having more than 
        one college/dept assigned(shown below) , employee will be able to modify 
        class program of departments assigned to.</strong></font></td>
    </tr>
    <tr> 
      <td colspan="3" height="21"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="14%" height="24">&nbsp;</td>
      <td height="24">College<strong> </strong></td>
      <td height="24"><strong> 
  <select name="c_index" onChange="ReloadPage();">
   <option value="">ALL COLLEGE</option>
      <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", 
	  WI.fillTextValue("c_index"), false)%> 
    </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24">Department <strong> </strong></td>
      <td height="24"><strong> 
        <select name="d_index">
<%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+WI.getStrValue(WI.fillTextValue("c_index"),"-1")+" order by d_name asc",WI.fillTextValue("d_index"), false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="39">&nbsp;</td>
      <td width="9%" height="39">&nbsp;</td>
      <td width="77%" height="39">
	  <%
	  if(iAccessLevel > 1){%>
	  <a href='javascript:PageAction("",1);'><img src="../../images/add.gif" border="0" name="hide_save"></a>
	  <font size="1">click to add more college/dept </font>
	  <%}%>
	  </td>
    </tr>
  </table>
  <%
  if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td width="50%" height="25" colspan="9" bgcolor="#B9B292"><div align="center">LIST 
          OF COLLEGES/DEPARTMENTS</div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="13%" height="25"><div align="center"><strong><font size="1">COLLEGE</font></strong></div></td>
      <td width="12%"><div align="center"><strong><font size="1">DEPARTMENT</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">REMOVE</font></strong></div></td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i +=3){%>
    <tr> 
      <td height="25"><%=WI.getStrValue(vRetResult.elementAt(i + 1), "ALL")%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 2), "ALL")%></td>
      <td>&nbsp;<div align="center"><%
	  if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("<%=vRetResult.elementAt(i)%>","0");'><img src="../../images/delete.gif" border="0"></a>
	  <%}%></div></td>
    </tr>
<%}%>

  </table>
  <%}//end of display if vRetResult.size() > 0)

}//if vEmpInfo is not null.   
  %>
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
 <input type="hidden" name="page_action" value="">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
  </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
