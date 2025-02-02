<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../jscript/common.js" ></script>
<script>
function ForumJump() {
	location = "./forum_cat_jump.jsp?subcat_index="+document.form_.cat_jump[document.form_.cat_jump.selectedIndex].value;
}

function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	
	this.SubmitOnce('form_');
}
function ShowCat(strSubCatIndex)
{
	location= "./forum_cat_jump.jsp?subcat_index="+strSubCatIndex;
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
	Vector vThreadInfo = null;
	Vector vSubCatList = null;
	int i = 0;
	int iSearchResult = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strIsLocked = "";
	boolean bIsMod = false;
	String strUserIndex = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-FORUM","forum_thread.jsp");
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
							//							"forum_thread.jsp");
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
		strUserIndex = dbOP.mapUIDToUIndex((String)request.getSession(false).getAttribute("userId"));
	strUserIndex = dbOP.mapOneToOther("FORUM_MOD_USER", "USER_INDEX",strUserIndex, "USER_INDEX","");
    if (strUserIndex == null)
    	bIsMod = false;
    else
    	bIsMod = true;
	
	Forum myForum = new Forum();
	
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(myForum.operateOnPost(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
		{
			strErrMsg = myForum.getErrMsg();
		}
	}

	vThreadInfo = myForum.operateOnThread(dbOP, request, 5);
		if (vThreadInfo == null)
			strErrMsg = myForum.getErrMsg();
		else
			strIsLocked = (String)vThreadInfo.elementAt(2);

	vRetResult = myForum.operateOnPost(dbOP, request, 4);
		if (vRetResult == null && strErrMsg == null) 
			 strErrMsg = myForum.getErrMsg();
		else 
			 iSearchResult = myForum.getSearchCount();

%>
<body bgcolor="#8C9AAA" >
<form action="./forum_thread.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="2" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SCHOOLBLIZ FORUM ::::</strong></font></div></td>
    </tr>
  </table>
   <%if (vThreadInfo!= null && vThreadInfo.size() > 0) {%>
<table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0" >
<%strTemp = WI.fillTextValue("subcat_index");
	  	vSubCatList = myForum.getSubCat(dbOP);
	  	if(vSubCatList != null && vSubCatList.size() > 0) {
	  %>
	 <tr>
		<td align="right" height="30" valign="bottom" colspan="2"><font size="1">Forum Jump</font>&nbsp;
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
	<%}//if%>
	<tr>
		<td height="25" colspan="2" bgcolor="#AAAAAA">
		<strong>&nbsp;<font color="#FFFFFF" size="2"><%=(String)vThreadInfo.elementAt(0)%></font>
		</strong></td>
	</tr>
	<tr>
		<td width="3%">&nbsp;</td>
		<td height="25" width="97%">
		<font size="1"><br>Posted by:
		<%=WI.formatName((String)vThreadInfo.elementAt(3),(String)vThreadInfo.elementAt(4),(String)vThreadInfo.elementAt(5),7)%>
	  (<%=(String)vThreadInfo.elementAt(6)%>)&nbsp;on&nbsp;<%=(String)vThreadInfo.elementAt(7)%></font><br><br>
		&nbsp;<%=(String)vThreadInfo.elementAt(1)%><br>&nbsp;
		</td>
	</tr>
</table> 
<%}%>
<%if (vRetResult != null && vThreadInfo != null && vRetResult.size()>0) {%>
<table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="97%" align="right"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/myForum.defSearchSize;
		if(iSearchResult % myForum.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%><font size="1">Go to page </font>
          <select name="jumpto2" onChange="ReloadPage();" style="font-size:10px">
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
	<%for (i = 0; i < vRetResult.size(); i+=7) {%>
	<tr>
		<td valign="top" align="center"><font size="1"><strong><%=(i/7)+1%>&nbsp;</strong></font></td>
		<td>
			<table width="100%" bgcolor="aliceblue" border="0" cellspacing="0">
				<tr bgcolor="lightsteelblue">
				<td height="18"><font size="1">Posted by:
		<%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%>
	  (<%=(String)vRetResult.elementAt(i+5)%>)&nbsp;on&nbsp;<%=(String)vRetResult.elementAt(i+6)%></font>
				</td>
				<td>
					<%if (bIsMod) {%><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../images/delete_2.gif" border="0"></a>
					<%} else {%>&nbsp;<%}%>
				</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
				</tr>
				<tr>
					<td colspan="2" height="10">&nbsp;</td>
				</tr>
			</table>		
		</td>
	</tr>
	<%}%>
	<tr>
		<td height="10">&nbsp;</td>
		<td align="right" valign="bottom">&nbsp;</td>
	</tr>
</table>
<%}%>
  <table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="25" colspan="5" bgcolor="#AAAAAA"><font color="#FFFFFF" size="2"><strong>&nbsp;Quick Reply</strong></font></td>
	</tr>
	<tr>
		<td height="10" colspan="4">&nbsp;</td>
	</tr>
<%
if (strIsLocked.compareTo("0")==0) {%>
	<tr>
		<td width="3%">&nbsp;</td>
		<td width="10%">Message: </td>
		<td width="65%"><textarea name="forum_msg" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" cols="50"><%=WI.fillTextValue("forum_msg")%></textarea>
		<td width="22%" align="center" valign="middle">
		 <a href='javascript:PageAction(1,"");'><img src="../../images/send_email.gif" border="0">
		<font size="1">Post Reply</font>		</td>
	</tr>
<%}else{%>
	<tr>
		<td colspan="4" align="center" style="font-size:14px; font-weight:bold; color:#FF0000">---- Message Thread is already locked by System administrator ---- </td>
	</tr>
<%}%>
	<tr>
		<td height="10" colspan="4">&nbsp;</td>
	</tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="thread_index" value="<%=WI.fillTextValue("thread_index")%>">
  <input type="hidden" name="subcat_index" value="<%=WI.fillTextValue("subcat_index")%>">
  <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>