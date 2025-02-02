<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../jscript/common.js" ></script>
<script>
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	
	this.SubmitOnce('form_');
}
function ForumJump() {
	location = "./forum_cat_jump.jsp?subcat_index="+document.form_.cat_jump[document.form_.cat_jump.selectedIndex].value;
}
</script>
<style>
.nav {
     color: #000000;
     background-color: #FFFFFF;
}
.nav-highlight {
     color: #000000;
     background-color: #FAFCDD;
}

a:link {
	color: #000000;
	text-decoration: none;
}
a:visited {
	color: #000000;
	text-decoration: none;

}
a:hover {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
a:active {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
</style>
<%@ page language="java" import="utility.*, organizer.Forum, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vSubCatList = null;
	String strErrMsg = null;
	String strTemp = null;
	int i = 0;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-FORUM","forum_admin_contact.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Organizer","FORUM",request.getRemoteAddr(),
							//							"forum_admin_contact.jsp");
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
Forum myForum = new Forum();

	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myForum.operateOnModMessage(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			response.sendRedirect("./forum_main.jsp");
		}
		else
			strErrMsg = myForum.getErrMsg();
	}

%>
<body bgcolor="#8C9AAA" >
<form action="./forum_admin_contact.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="2" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SCHOOLBLIZ FORUM ::::</strong></font></div></td>
    </tr>
   </table>
   <%strTemp = WI.fillTextValue("cat_jump");
	  	vSubCatList = myForum.getSubCat(dbOP);
	  	if(vSubCatList != null && vSubCatList.size() > 0) {
	  %>
<table bgcolor="aliceblue" width="100%">

	<tr>
		<td align="right" height="30" valign="bottom"><font size="1">Forum Jump</font>&nbsp;
		<select name="cat_jump" style="font-size:10px">
        <%for(i = 0 ; i< vSubCatList.size(); i +=3){ 
		if( strTemp.compareTo((String)vSubCatList.elementAt(i)) == 0) {%>
        <option value="<%=(String)vSubCatList.elementAt(i)%>" selected><%=(String)vSubCatList.elementAt(i+1)%></option>
        <%}else{%>
        <option value="<%=(String)vSubCatList.elementAt(i)%>"><%=(String)vSubCatList.elementAt(i+1)%></option>
        <%} //else
			} //for loop
		   %> //if
      </select>
		&nbsp;<a href="javascript:ForumJump()"><img src="../../images/go-button_up.gif" border="0">&nbsp;</a>
		</td>
	</tr>
</table>
<%}%>
  <table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="25" colspan="5" bgcolor="#AAAAAA">
		<strong><font color="#FFFFFF">
		&nbsp;Administrator Message</font>
		</strong>
		</td>
	</tr>
	<tr>
		<td height="10" colspan="4">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%">&nbsp;</td>
		<td width="15%">Message: </td>
		<td width="60%">
		<textarea name="mod_msg" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" cols="50"><%=WI.fillTextValue("mod_msg")%></textarea></td>
		<td align="center" valign="middle" width="22%">
		<a href='javascript:PageAction(1);'><img src="../../images/send_email.gif" border="0"></a>
		<font size="1">Send Message</font></td>
	</tr>
	<tr>
		<td height="10" colspan="4">&nbsp;</td>
	</tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
  	<input type="hidden" name="page_action">
</form>
</body>
</html>
