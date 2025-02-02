<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script language="JavaScript">
<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	
	this.SubmitOnce('form_');
}
-->
</script>
<%@ page language="java" import="utility.*,osaGuidance.GDAbsence ,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	
	String strErrMsg = null;
	String strTemp = null;
	String strInfoIndex = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Student Tracker-Absences","recommendation.jsp");
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
														"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"STUDENT AFFAIRS","Student Tracker",request.getRemoteAddr(), null);
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

	GDAbsence GDAbsent = new GDAbsence();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(GDAbsent.operateOnRecommendation(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
				}
		else
				
				strErrMsg = GDAbsent.getErrMsg();

	}
	
	vRetResult = GDAbsent.operateOnRecommendation(dbOP, request, 4);
	if (strErrMsg == null)
		strErrMsg = GDAbsent.getErrMsg();


%>
<body bgcolor="D2AE72">

<form action="./recommendation.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="4" bgcolor="A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EXCUSE SLIP - RECOMMENDATIONS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="18" colspan="4"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="3%"  height="28">&nbsp;</td>
      <td width="15%" height="28">Recommendation : </td>
      <%strTemp = WI.fillTextValue("REC");%>
      <td width="25%"><textarea name="REC" cols="40" rows="2" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
      <td width="57%" height="28"><div align="right"><a href="javascript:self.close();"><img src="../../../../images/close_window.gif" border="0"></a></div></td>
    </tr>
    <tr>
    	<td width="18%"  height="28" colspan="2">&nbsp;</td>
    	<td width="25%" height="28"><a href='javascript:PageAction(1,"");'><img src="../../../../images/add.gif" border="0" name="hide_save"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to add entry</font></td>
    	<td width="57%" height="28"></td>
    </tr>
   
    <tr> 
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0){%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="28" colspan="4" bgcolor="A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: RECOMMENDATIONS ::::</strong></font></div></td>
    </tr>
    <tr>
    <td width="14%">&nbsp;</td>
    <td width="64%" height="25"><div align="center"><font size="2"><strong>Recommendation</strong></font></div></td>
    <td width="10%">&nbsp;</td>
    <td width="12%">&nbsp;</td>
    </tr>
<%for(int i =0; i<vRetResult.size(); i+=2){%>
    <tr>
    <td>&nbsp;</td>
    <td><div align="center"><%=(String)vRetResult.elementAt(i+1)%></div></td>
    <td><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../../images/delete.gif" border="0"></a></td>
    <td>&nbsp;</td>
    </tr>
    <%}%>
</table>
<%}%>
<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="absent_index" value="<%=WI.fillTextValue("absent_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
