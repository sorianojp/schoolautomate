<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

</head>
<script language="JavaScript">
function ReloadPage() {
	document.form_.submit();
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumSM,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);	

	String strErrMsg = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM","course_offering_sub.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"course_offering_sub.jsp");
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

CurriculumSM SM = new CurriculumSM();
Vector vRetResult  = new Vector();
ConstructSearch conSearch = new ConstructSearch(request);
if(WI.fillTextValue("sub_code").length() > 0 || WI.fillTextValue("sub_desc").length() > 0) {
	vRetResult = SM.viewCourseListOfferingSub(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SM.getErrMsg();
}
	

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains","Any key word","All key word"};
String[] astrDropListValEqual = {"equals","starts","ends","contains","any","all"};

%>

<form name="form_" method="post" action="./course_offering_sub.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF CURRICULUM OFFERING A SUBJECT ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">Subject Code</td>
      <td height="25">Subject Title</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="49%" height="25"> <select name="sub_code_con">
          <%=conSearch.constructGenericDropList(WI.fillTextValue("sub_code_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="sub_code" value="<%=WI.fillTextValue("sub_code")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="49%" height="25"><select name="sub_name_con">
          <%=conSearch.constructGenericDropList(WI.fillTextValue("sub_name_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input type="text" name="sub_name" value="<%=WI.fillTextValue("sub_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" align="center"> <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
        <font size="1">Click to refresh the search result</font></td>
    </tr>
  </table>

  <table width=100% border=0 bgcolor="#FFFFFF">

    <tr bgcolor="#B9B292">
      <td height="25" colspan="8" bgcolor="#B9B292"><div align="center">LIST
          OF EXISTING SUBJECTS BY SUBJECT TYPE<%=vRetResult.size()%></div></td>
    </tr>
  </table>
<%

if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="12%" height="25"><div align="center"><font size="1"><strong>SUBJECT CODE </strong></font></div></td>
      <td width="33%"><div align="center"><font size="1"><strong>SUBJECT NAME</strong></font></div></td>
      <td width="35%"><div align="center"><font size="1"><strong>COURSE (MAJOR)</strong></font></div></td>
      <td width="10%" align="center"><strong><font size="1">CURRICULUM YR LIST</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">YEAR-SEM OFFERED</font></strong></td>
    </tr>
<%
for(int i = 0 ; i< vRetResult.size(); i +=8)
{%>
    <tr> 
      <td><%=WI.getStrValue(vRetResult.elementAt(i))%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 1),"&nbsp;")%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 3)," (",")","")%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%> - <%=(String)vRetResult.elementAt(i + 5)%></td>
      <td>
	  <%if(vRetResult.elementAt(i + 4) != null) {%>
	  	<%=(String)vRetResult.elementAt(i + 6)%> - <%=(String)vRetResult.elementAt(i + 7)%>
	  <%}else{%>&nbsp;<%}%>
	  
	  </td>
    </tr>
    <%
}//end of loop %>
  </table>

<%}//end of displaying %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
