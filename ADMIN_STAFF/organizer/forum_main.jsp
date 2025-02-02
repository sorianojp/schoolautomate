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
	Vector vSubCatList = null;
	String strTempCat = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-FORUM","forum_main.jsp");
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
							//							"forum_main.jsp");
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
	Vector vUserData = null;
	vUserData = myForum.operateOnUserLogin(dbOP, (String)request.getSession(false).getAttribute("userId"));
	if (vUserData == null){
		strErrMsg = myForum.getErrMsg();
		}

	vRetResult = myForum.operateOnSubCatMaintenance(dbOP, request, 4);

	if (vRetResult == null)
		strErrMsg = myForum.getErrMsg();

%>
<body bgcolor="#8C9AAA" >
<form action="./forum_main.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="2" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SCHOOLBLIZ FORUM ::::</strong></font></div></td>
    </tr>
       <tr>
   <td colspan="2" bgcolor="aliceblue" height="10" align="right"><a href ="./forum_admin_contact.jsp"><font size="1">Contact the moderating team</font></a></td>
   </tr>
   <tr bgcolor="aliceblue"> 
   	<%
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	String strName = (String)request.getSession(false).getAttribute("first_name");
	if(strName == null) strName ="Anonymous";
   	int iNewMsgs = 0;
   	if (vRetResult!=null)
   		iNewMsgs = vRetResult.size()/12;
   	%>
      <td height="25" colspan="2">
      &nbsp;&nbsp;<strong>Welcome <%=strName%> !</strong><br>
      &nbsp;&nbsp;<font size="1">Your last visit was on: <%=(String)vUserData.elementAt(0)%><br>
      &nbsp;&nbsp;<%=(String)vUserData.elementAt(1)%> Posts<br>
      &nbsp;&nbsp;Today is: <%=WI.getTodaysDateTime()%></font></td>
    </tr>
        <tr>
   <td colspan="2" bgcolor="aliceblue" height="10">&nbsp;</td>
   </tr>
   </table>
<%if (vRetResult != null && vRetResult.size() > 0) {//System.out.println(vRetResult);%>
<table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0">
<% for (i = 0; i < vRetResult.size(); i+=5) {%>
<%if (i==0) {%>
	<tr>
		<td height="25" colspan="2" bgcolor="#AAAAAA" class="thinborderALL"><font color="#FFFFFF" size="2"><strong>&nbsp;<%=(String)vRetResult.elementAt(i+2)%>:::</strong></font></td>
	</tr>
	<tr height="30">
		<td width="3%" class="thinborderBOTTOMLEFT"><img src="../../images/forum_new.gif" border="0"></td>
		<td width="97%" class="thinborderBOTTOMRIGHT">&nbsp;<font size="2"><strong><br>
		<a href="javascript:ShowCat(<%=(String)vRetResult.elementAt(i)%>)"><%=(String)vRetResult.elementAt(i+3)%></a></strong></font><br>
		&nbsp;<font size="1"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></font></td>
	</tr>
<%} if (i > 0 && ((String)vRetResult.elementAt(i+1)).compareTo((String)vRetResult.elementAt(i-4))== 0) {%>
	<tr height="30">
		<td class="thinborderBOTTOMLEFT"><img src="../../images/forum_new.gif" border="0"></td>
		<td class="thinborderBOTTOMRIGHT">&nbsp;<font size="2"><strong><br><a href="javascript:ShowCat(<%=(String)vRetResult.elementAt(i)%>)">
		<%=(String)vRetResult.elementAt(i+3)%></a></strong></font><br>
		&nbsp;<font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
	</tr>
<%} if (i > 0 && ((String)vRetResult.elementAt(i+1)).compareTo((String)vRetResult.elementAt(i-4))!= 0) {%>
	<tr>
		<td height="10" colspan="2" class="thinborderLEFTRIGHT">&nbsp;</td>
	</tr>
	<tr>
		<td height="25" colspan="2" bgcolor="#AAAAAA" class="thinborderALL"><font color="#FFFFFF" size="2"><strong>&nbsp;<%=(String)vRetResult.elementAt(i+2)%>:::</strong></font></td>
	</tr>
	<tr height="30">
		<td class="thinborderBOTTOMLEFT"><img src="../../images/forum_new.gif" border="0"></td>
		<td class="thinborderBOTTOMRIGHT">&nbsp;<font size="2"><strong><br><a href="javascript:ShowCat(<%=(String)vRetResult.elementAt(i)%>)"><%=(String)vRetResult.elementAt(i+3)%></a></strong></font><br>
		&nbsp;<font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
	</tr>
<%}}%>	
</table>
<%}%>
<table bgcolor="aliceblue" width="100%">
	<tr>
		<td width="50%">&nbsp;</td>
		<td width="50%">&nbsp;</td>
	</tr>
	<%strTemp = WI.fillTextValue("cat_jump");
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
		   %> 
      </select>
		&nbsp;
		<a href="javascript:ForumJump()"><img src="../../images/go-button_up.gif" border="0">&nbsp;</a>
		</td>
	</tr>
<%}//if%>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="cat_jump_idx" value="<%=WI.fillTextValue("cat_jump_idx")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>