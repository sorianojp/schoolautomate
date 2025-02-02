<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	
	this.SubmitOnce('form_');
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
	Vector vRetResult = null;
	int iSearchResult = 0;
	int i = 0;
	String strErrMsg = "";
	String strTemp = null;
	boolean bIsMod = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-FORUM","mod_list.jsp");
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
														"Organizer","FORUM",request.getRemoteAddr(),
														"mod_list.jsp");
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
    if(comUtil.IsSuperUser(dbOP,(String) request.getSession(false).getAttribute("userId")))
    bIsMod = true;
    else
    	bIsMod = false;


	Forum myForum = new Forum();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myForum.operateOnModerator(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myForum.getErrMsg();
	}

	vRetResult = myForum.operateOnModerator(dbOP, request, 4);
		if (vRetResult == null && strErrMsg.length()== 0) 
		 strErrMsg = myForum.getErrMsg();
		else 
		 iSearchResult = myForum.getSearchCount();

%>
<body bgcolor="#8C9AAA" >
<form action="./mod_list.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="aliceblue">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="3" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MODERATOR - MODERATOR MAINTENANCE ::::</strong></font></div></td>
    </tr>
       <tr>
   <td colspan="3" height="10"><%=WI.getStrValue(strErrMsg)%></td>
   </tr>
	<tr>
		<td width="2%">&nbsp;</td>
	    <td width="20%" valign="bottom"><font size="1">ID Number :</font></td>
    	<td width="78%">
    <input name="id_number" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="32" value="<%=WI.fillTextValue("id_number")%>">
    &nbsp; <a href='javascript:PageAction(1,"");'><img src="../../images/add.gif" border="0" name="hide_save"></a>
    </td>
    </tr>
  	<tr>
  		<td colspan="3">&nbsp;</td>
  	</tr>
</table>
<%if (vRetResult != null && vRetResult.size()>0) {%>
<table  bgcolor="aliceblue" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td bgcolor="#697A8F" colspan="4" align="center" height="25">
		<font color="#FFFFFF" face="Verdana, Arial, Helvetica, sans-serif"><strong>MODERATOR LIST</font></font></td>
	</tr>
    <tr>
		<td colspan="2" align="left" class="thinborder"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;TOTAL MODERATORS
        : <%=iSearchResult%></strong></font></td>
		<td colspan="2" align="right" class="thinborder"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/myForum.defSearchSize;
		if(iSearchResult % myForum.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
          <select name="jumpto" onChange="ReloadPage();" style="font-size:10px">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}
			%>
          </select>
          <%} else {%>&nbsp;<%}%>
          </font></td>
	</tr>
    <tr> 
      <td width="10%" height="26" >&nbsp;</td>
      <td width="43.32%" height="26" ><div align="center"><font size="1"><strong>MODERATOR NAME</strong></font></div></td>
      <td width="26.66%" height="26" >&nbsp;</td>
      <td width="20%" >&nbsp;</td>
    </tr>
<%for (i = 0; i < vRetResult.size(); i+=5) {%>
    <tr> 
      <td height="25" >&nbsp;</td>
	  <td align="center"><font size="1">
	  <%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),7)%>
	  (<%=(String)vRetResult.elementAt(i+4)%>)</font></td>
      <td align="right">
      <font size="1"> 
        <% if(iAccessLevel ==2){%><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'>
<img src="../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized to delete 
        <%}%>
        </font>
      </td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>