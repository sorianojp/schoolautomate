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
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function GoBack() {
	location = "./forum_cat_jump.jsp?subcat_index="+document.form_.subcat_index[document.form_.subcat_index.selectedIndex].value;
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
	Vector vEditInfo = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	int iSearchResult = 0;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	Vector vSubCatList = null;
		boolean bIsMod = false;
	String strUserIndex = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-FORUM","thread_maintenance.jsp");
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
														"thread_maintenance.jsp");
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
		if(myForum.operateOnThread(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myForum.getErrMsg();
	}
	
		
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = myForum.operateOnThread(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = myForum.getErrMsg();
	}

vRetResult = myForum.operateOnThread(dbOP, request, 4);
if (vRetResult == null) 
 strErrMsg = myForum.getErrMsg();
 else 
 iSearchResult = myForum.getSearchCount();

%>
<body bgcolor="#8C9AAA" >
<form action="./thread_maintenance.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="aliceblue">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="3" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MODERATOR - THREAD MAINTENANCE ::::</strong></font></div></td>
    </tr>
       <tr>
   <td colspan="3" height="10"><%=WI.getStrValue(strErrMsg)%></td>
   </tr>
	   <tr>
	     <td>&nbsp;</td>
	     <td valign="bottom">&nbsp;</td>
	     <td align="right"><a href="javascript:GoBack();"><font style="font-size:13px; color:#990000;">Go Back To Main</font></a></td>
    </tr>
    <tr>
		<td width="2%">&nbsp;</td>
	    <td width="20%" valign="bottom"><font size="1">Category/SubCategory :</font></td>
    	<td width="78%">
    <select name="subcat_index" style="font-size:10px" onChange="ReloadPage();">
        <%strTemp = WI.fillTextValue("subcat_index");
	  	vSubCatList = myForum.getSubCat(dbOP);
  	if(vSubCatList != null && vSubCatList.size() > 0) {
	  for(i = 0 ; i< vSubCatList.size(); i +=3){ 
		if( strTemp.compareTo((String)vSubCatList.elementAt(i)) == 0) {%>
        <option value="<%=(String)vSubCatList.elementAt(i)%>" selected><%=(String)vSubCatList.elementAt(i+1)%></option>
        <%}else{%>
        <option value="<%=(String)vSubCatList.elementAt(i)%>"><%=(String)vSubCatList.elementAt(i+1)%></option>
        <%} //else
			} //for loop
		   }%> //if
      </select><%if (bIsMod){%>
    	&nbsp;<a href="./subcategory_maintenance.jsp"><img src="../../images/update.gif" border="0"></a>
    	<font size="1">click to add categories <%}%>&nbsp;<a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  	<tr>
  		<td colspan="3">&nbsp;</td>
  	</tr>
</table>
<table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="3" bgcolor="#697A8F" valign="middle" align="left">
      <font color="#FFFFFF"><strong>&nbsp;Thread Details</strong></font></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
     <tr>
		<td width="2%">&nbsp;</td>
	    <td width="15%%">Subject:</td>
    	<td width="83%">
    	<%if (vEditInfo!=null && vEditInfo.size()>0) 
    	strTemp = (String)vEditInfo.elementAt(3);
    	else
    	strTemp = WI.fillTextValue("thread_subj");
    	%>
    	<input name="thread_subj" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
    <td>&nbsp;</td>
    <td>Message:</td>
    <td>
    <%if (vEditInfo!=null && vEditInfo.size()>0) 
    	strTemp = (String)vEditInfo.elementAt(4);
    	else
    	strTemp = WI.fillTextValue("thread_msg");
    	%>
    <textarea name="thread_msg" cols="33" rows="2" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
    <tr>
    	<td>&nbsp;</td>
    	<td>Lock : </td>
		<%if (vEditInfo!=null && vEditInfo.size()>0) 
    	strTemp = (String)vEditInfo.elementAt(5);
    	else
    	strTemp = WI.fillTextValue("lock");
    	%>
    	<td>
    	<%if (strTemp.length()>0 && strTemp.compareTo("1")==0) {%>
    		<input type="checkbox" name="isLocked" value="1" checked>
		<%}else{%>
    		<input type="checkbox" name="isLocked" value="1">
    	<%}%>
    	</td>
    </tr>
     <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="10" colspan="2" align="center"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../images/add.gif" border="0" name="hide_save"></a> 
        Create Thread 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Edit Thread <a href="javascript:Cancel();"><img src="../../images/cancel.gif" border="0"></a> 
        Discard Changes 
        <%}%></font></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
</table>
<%if (vRetResult != null && vRetResult.size()>0) {%>
<table  bgcolor="aliceblue" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td height="25" colspan="5" bgcolor="#697A8F" valign="middle" align="center">
      <font color="#FFFFFF"><strong>&nbsp;Thread List</strong></font></td>
    </tr>
    <tr>
		<td colspan="2" align="left" class="thinborder"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;TOTAL THREADS
        : <%=iSearchResult%></strong></font></td>
		<td colspan="3" align="right" class="thinborder"> <%
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
    <tr> 
      <td width="26.66%" height="26" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT</strong></font></div></td>
      <td width="26.66%" height="26" class="thinborder"><div align="center"><font size="1"><strong>AUTHOR / DATE</strong></font></div></td>
      <td width="26.66%" height="26" class="thinborder"><div align="center"><font size="1"><strong>STATUS</strong></font></div></td>
      <%if (bIsMod) {%>
      <td width="20%" colspan="2" class="thinborder">&nbsp;</td>
      <%}%>
    </tr>
<%for (i = 0; i < vRetResult.size(); i+=18) {%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
	  <td class="thinborder" align="right"><font size="1">
	  <%=WI.formatName((String)vRetResult.elementAt(i+12),(String)vRetResult.elementAt(i+13),(String)vRetResult.elementAt(i+14),7)%>
	  (<%=(String)vRetResult.elementAt(i+15)%>)
	  <br><%=(String)vRetResult.elementAt(i+16)%></font></td>
      <td class="thinborder" align="right"><font size="1"><%if (((String)vRetResult.elementAt(i+5)).compareTo("0")==0){%>Open<%}else{%>Locked<%}%></font></td>
      <%if (bIsMod){%>
      <td class="thinborder"><div align="center"><font size="1"> 
        <% if(iAccessLevel ==2 || iAccessLevel == 3){%>
<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a>
        <%}else{%>
        Not authorized to edit 
        <%}%>
        </font></div></td>
      <td class="thinborder"><div align="center"><font size="1"> 
        <% if(iAccessLevel ==2){%><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'>
<img src="../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized to delete 
        <%}%>
        </font></div></td>
        <%}%>
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
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>