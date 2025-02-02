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
	document.form_.submit();
}
function CheckAll()
{
	var iMaxDisp = document.form_.msgCtr.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp)-1;++i)
			eval('document.form_.msg'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp)-1;++i)
			eval('document.form_.msg'+i+'.checked=false');
		
}

function PerformTask()
{
	document.form_.page_action.value = document.form_.altAction[document.form_.altAction.selectedIndex].value;
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
	text-decoration: underline;

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
	Vector vEditInfo = null;
	int iMsgs = 1;
	int i = 0;
	int iSearchResult = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strAltAction = null;
	String strFinCol = null;
	boolean bIsMod = false;
	String strUserIndex = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-FORUM","forum_mod_messages.jsp");
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
														"forum_mod_messages.jsp");
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

	strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	strUserIndex = dbOP.mapOneToOther("FORUM_MOD_USER", "USER_INDEX", strUserIndex, "USER_INDEX","");
    if (strUserIndex == null)
    	bIsMod = false;
    else
    	bIsMod = true;

	Forum myForum = new Forum();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myForum.operateOnModMessage(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myForum.getErrMsg();
	}

	vRetResult = myForum.operateOnModMessage(dbOP, request, 4);

	if (vRetResult == null)
		strErrMsg = myForum.getErrMsg();
	else
		iSearchResult = myForum.getSearchCount();
%>
<body bgcolor="#8C9AAA" >
<form action="./forum_mod_messages.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SCHOOLBLIZ FORUM ::::</strong></font></div></td>
    </tr>
	<tr>
		<td height="25" bgcolor="#AAAAAA">
		<strong><font color="#FFFFFF">
		&nbsp;Administrator Messages</font>
		</strong>
		</td>
	</tr>
</table>
<%if (bIsMod) {%>
<%if (vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="aliceblue" class="thinborder">
	<tr> 
      <td colspan="2" height="25" class="thinborder"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;TOTAL MESSAGES
        : <%=iSearchResult%></strong></font></td>
	  <td class="thinborder" align="right">
	  <select name="altAction" style="font-size:10px">
	  <%strAltAction = WI.getStrValue(WI.fillTextValue("altAction"),"2");%>
	  <%if (strAltAction.compareTo("0")==0) {%>
	  <option value="0" selected>Delete</option>
	  <%}else{%>
  	  <option value="0">Delete</option>
  	  <%} if (strAltAction.compareTo("2")==0) {%>
	  <option value="2" selected>Mark as Read</option>
      <%} else {%>
  	  <option value="2">Mark as Read</option>
	  <%} if (strAltAction.compareTo("3")==0) {%>
	  <option value="3" selected>Mark as Unread</option>
		<%} else {%>
  	  <option value="3">Mark as Unread</option>
  	  <%}%>
	  </select><a href="javascript:PerformTask()">&nbsp;<img src="../../images/go-button_up.gif" border="0"></a>
	  </td>
      <td class="thinborder" align="right"><%
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
        </td>
    </tr>
   <tr bgcolor="#DBEAF5">
   <td width="2%" height="25" class="thinborder" align="center"><input type="checkbox" name="selAll" value="0" onClick="CheckAll();"></td>
   <td width="29%" class="thinborder"><div align="left"><strong><font size="1">&nbsp;From</font></strong></div></td>
   <td width="40%" class="thinborder"><div align="left"><strong><font size="1">&nbsp;Message</font></strong></div></td>
   <td width="29%" class="thinborder"><div align="left"><strong><font size="1">&nbsp;Date</font></strong></div></td>
   </tr>
<%for (i = 0; i < vRetResult.size(); i+=7, ++iMsgs){
if (((String)vRetResult.elementAt(i+6)).compareTo("1")==0)
	strFinCol = " bgcolor = '#EEEEEE'";
	else 
	strFinCol = " bgcolor = '#FFFFFF'";

%>   
   <tr <%=strFinCol%>>
   <td class="thinborder" height="25"><div align="center"><input type="checkbox" name="msg<%=iMsgs%>" value="<%=(String)vRetResult.elementAt(i)%>"></div></td>
   <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),(String)vRetResult.elementAt(i+3),7)%></td>
   <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
   <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
   </tr>
 <%}%>
  </table>
<%}} else {%>
<table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25"><font color="red"><strong>Moderator access level required</strong><font></td>
    </tr>
  </table>
<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="msgCtr" value ="<%=iMsgs%>">
  	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>