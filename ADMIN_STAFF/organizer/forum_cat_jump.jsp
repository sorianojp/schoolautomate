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
	var strTemp = document.form_.cat_jump[document.form_.cat_jump.selectedIndex].value;
	document.form_.subcat_index.value = strTemp;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	
	this.SubmitOnce('form_');
}
function ShowThread(strInfoIndex, strSubCatIndex)
{
	location= "./forum_thread.jsp?thread_index="+strInfoIndex+"&subcat_index="+strSubCatIndex;
}
function ShowThreadPg(strInfoIndex, strSubCatIndex, str)
{
	location= "./forum_thread.jsp?thread_index="+strInfoIndex+"&subcat_index="+strSubCatIndex;
}
function GoToNewForum(strSubCatgIndex) {
	location = "./forum_cat_jump.jsp?subcat_index="+strSubCatgIndex;
	
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
.mytabOff {
	FONT-WEIGHT: bold; FONT-SIZE: 11px; BACKGROUND-IMAGE: url("../../images/devicetab_top2.gif"); COLOR: #000000; TEXT-DECORATION: none
}

</style>
<%@ page language="java" import="utility.*, organizer.Forum, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	int iSearchResult = 0;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	Vector vSubCatList = null;
	Vector vLinkList = null;
	String strSubCatIndex = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-FORUM","forum_cat_jump.jsp");
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
							//							"forum_cat_jump.jsp");
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
	strSubCatIndex = WI.fillTextValue("subcat_index");
	
	
	if (strSubCatIndex != null && strSubCatIndex.length()>0)
	{                                                 
		vLinkList = myForum.getLinks(dbOP, strSubCatIndex);
	}
	vRetResult = myForum.operateOnThread(dbOP, request, 4);
		if (vRetResult == null) 
			 strErrMsg = myForum.getErrMsg();
		 else 
			 iSearchResult = myForum.getSearchCount();


%>
<body bgcolor="#8C9AAA" >
<form action="./forum_cat_jump.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="2" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SCHOOLBLIZ FORUM ::::</strong></font></div></td>
    </tr>
    </table>
<%if (vLinkList != null && vLinkList.size() > 0){%>
   <table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr align="right">
		<td>
		<table cellspacing="2" cellpadding="0" border="0">
		<tr>
		<%for (i = 0; i < vLinkList.size(); i+=2) {
		if (((String)vLinkList.elementAt(i)).compareTo(strSubCatIndex)==0){%>
		<td >
		<img src="../../images/devicetab_left.gif" border="0"><strong><%=(String)vLinkList.elementAt(i+1)%></strong><img src="../../images/devicetab_right.gif" border="0">
		</td>
		<%}else{%>
		<td bgcolor="#003399" onClick="GoToNewForum('<%=(String)vLinkList.elementAt(i)%>');">
		<img src="../../images/devicetab_leftOff.gif" border="0">
		<a href="./forum_cat_jump.jsp?subcat_index=<%=(String)vLinkList.elementAt(i)%>" target="organizermainFrame"><strong><font color="#FFFFFF"><%=(String)vLinkList.elementAt(i+1)%></font></strong></a><img src="../../images/devicetab_rightOff.gif" border="0">
		</td>
		<%}}%>
		</tr>
		</table>
		</td>
	</tr>
	</table>
	<%}%>

   <table bgcolor="aliceblue" width="100%">
<tr>
	<td width="50%">
	<%
	//do not show if not moderator 
	boolean bolIsModerator = false;
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	if(strUserIndex != null)
		strUserIndex = dbOP.mapOneToOther("FORUM_MOD_USER", "USER_INDEX", strUserIndex, "USER_INDEX","");
    if (strUserIndex == null)
    	bolIsModerator = false;
    else
    	bolIsModerator = true;
	if(bolIsModerator){%>
		<a href="./thread_maintenance.jsp?subcat_index=<%=WI.fillTextValue("subcat_index")%>">&nbsp;<img src="../../images/newthread.gif" border="0"></a>
	<%}%>
	</td>
	<td align="right" height="30" valign="bottom" width="50%"><font size="1">Forum Jump</font>&nbsp;
		<%strTemp = WI.fillTextValue("subcat_index");
	  	vSubCatList = myForum.getSubCat(dbOP);
	  	if(vSubCatList != null && vSubCatList.size() > 0) {
	  	%>
		<select name="cat_jump" style="font-size:10px">
        <%
	  for(i = 0 ; i< vSubCatList.size(); i +=3){ 
		if( strTemp.compareTo((String)vSubCatList.elementAt(i)) == 0) {%>
        <option value="<%=(String)vSubCatList.elementAt(i)%>" selected><%=(String)vSubCatList.elementAt(i+1)%></option>
        <%}else{%>
        <option value="<%=(String)vSubCatList.elementAt(i)%>"><%=(String)vSubCatList.elementAt(i+1)%></option>
        <%} //else
			} //for loop
		 %> 
      </select>
		&nbsp;<a href="javascript:ForumJump()"><img src="../../images/go-button_up.gif" border="0">&nbsp;</a>
		<%}//if%>
		</td>
	</tr>
</table>
<%if (vRetResult != null && vRetResult.size()>0) {%>
<table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td width="100%" align="right">
		<%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/myForum.defSearchSize;
		if(iSearchResult % myForum.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%><font size="1">Go to page </font>
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
	</table>
<table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">	
	<tr>
		<td height="25" colspan="5" bgcolor="#AAAAAA" class="thinborder"><font color="#FFFFFF" size="2"><strong><%=(String)vRetResult.elementAt(2)%></strong></font></td>
	</tr>
<%for (i = 0; i < vRetResult.size(); i+=18) {%>	
	<tr height="25">
		<td width="3%" valign="middle" align="center" class="thinborder">
		<%if (((String)vRetResult.elementAt(i+5)).compareTo("1")==0){%>
		<img src="../../images/thread_lock.gif" border="0"><%}else{%><img src="../../images/thread_new.gif" border="0"><%}%></td>
		<td width="50%" class="thinborder">&nbsp;
		<a href="javascript:ShowThread(<%=(String)vRetResult.elementAt(i)%>, <%=strSubCatIndex%>);"><font size="2"><%=(String)vRetResult.elementAt(i+3)%></font></a><br>
		<font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+17),"&nbsp;")%></font>
		</td>
		<td width="22.5%" class="thinborder" align="right"><font size="1">
	  <%=WI.formatName((String)vRetResult.elementAt(i+12),(String)vRetResult.elementAt(i+13),(String)vRetResult.elementAt(i+14),7)%>
	  (<%=(String)vRetResult.elementAt(i+15)%>)
	  <br><%=(String)vRetResult.elementAt(i+16)%></font></td>
		<td align="center" width="5%" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></td>
		<td width="22.5%" class="thinborder" align="right"><font size="1">Last Post by:
	  <%=WI.formatName((String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+8),(String)vRetResult.elementAt(i+9),7)%>
	  (<%=(String)vRetResult.elementAt(i+10)%>)
	  <br><%=(String)vRetResult.elementAt(i+11)%></font></td>
	</tr>
<%}%>
</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="subcat_index" value="<%=WI.fillTextValue("subcat_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>