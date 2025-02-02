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
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
var loadPg = "../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond)+"&opner_form_name=form_" ;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	int iSearchResult = 0;
	String strErrMsg = null;
	String strTemp = null;
	Vector vSubCatList = null;
	boolean bIsMod = false;
	String strUserIndex = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-FORUM","subcategory_maintenance.jsp");
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
														"subcategory_maintenance.jsp");
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
	
	String strName = (String)request.getSession(false).getAttribute("first_name");
	if(strName == null) strName ="Anonymous";
	
	Forum myForum = new Forum();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myForum.operateOnSubCatMaintenance(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myForum.getErrMsg();
	}
	
		
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = myForum.operateOnSubCatMaintenance(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = myForum.getErrMsg();
	}


vRetResult = myForum.operateOnSubCatMaintenance(dbOP, request, 4);
if (vRetResult == null) 
 strErrMsg = myForum.getErrMsg();
%>
<body bgcolor="#8C9AAA" >
<form action="./subcategory_maintenance.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="2" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MODERATOR - CATEGORY MAINTENANCE ::::</strong></font></div></td>
    </tr>
</table>
<%if (bIsMod) {%>
<table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr> 
      <td height="25" colspan="3"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#697A8F" valign="middle" align="left">
      <font color="#FFFFFF"><strong>&nbsp;Category Details</strong></font></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
		<td width="2%"><%
		if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(1);
		else
			strTemp = WI.fillTextValue("frm_cat_index");%>&nbsp;</td>
	    <td width="15%">Category Name:</td>
    	<td width="55%">
    	<select name="frm_cat_index">
          <option value="">Select category</option>
			<%=dbOP.loadCombo("CATG_INDEX","CATEGORY"," FROM FORUM_CATG ORDER BY CATEGORY", strTemp, false)%>
        </select>
    	&nbsp;<a href='javascript:viewList("FORUM_CATG","CATG_INDEX","CATEGORY","CATEGORIES",
	"FORUM_SUB_CATG","CATG_INDEX"," AND SUB_CATG_INDEX IS NOT NULL ","")'><img src="../../images/update.gif" border="0"></a>
    	<font size="1">click to add categories</td>
    </tr>
     <tr>
		<td><%
		if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(3);
		else
			strTemp = WI.fillTextValue("subcat_name");
		%>&nbsp;</td>
	    <td>Sub Category Name:</td>
    	<td><input name="subcat_name" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
    <td><%
		if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(4),"&nbsp;");
		else
			strTemp = WI.fillTextValue("subcat_desc");
		%>&nbsp;</td>
    <td>Description:</td>
    <td >
    <textarea name="subcat_desc" cols="33" rows="2" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="10" colspan="2" align="center"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../images/add.gif" border="0" name="hide_save"></a> 
        Add Category 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Edit Category <a href="javascript:Cancel();"><img src="../../images/cancel.gif" border="0"></a> 
        Discard Changes 
        <%}%></font></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
</table>
<%if(vRetResult != null && vRetResult.size()>0) {%>
  <table  bgcolor="aliceblue" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td height="25" colspan="5" bgcolor="#697A8F" valign="middle" align="center">
      <font color="#FFFFFF"><strong>&nbsp;Category List</strong></font></td>
    </tr>
    <tr> 
      <td width="26.66%" height="26" class="thinborder"><div align="center"><font size="1"><strong>CATEGORY NAME</strong></font></div></td>
      <td width="26.66%" height="26" class="thinborder"><div align="center"><font size="1"><strong>SUB CATEGORY NAME</strong></font></div></td>
      <td width="26.66%" height="26" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="20%" colspan="2" class="thinborder">&nbsp;</td>
    </tr>
<%for (i = 0; i < vRetResult.size(); i+=5) {%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%if (i > 0 && 
      ((String)vRetResult.elementAt(i+1)).compareTo((String)vRetResult.elementAt(i-4))== 0){%>
      &nbsp;<%}else{%>
      <%=(String)vRetResult.elementAt(i+2)%><%}%></font></td>
	  <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td class="thinborder"><div align="center"><font size="1"> 
        <% if(iAccessLevel ==2 || iAccessLevel == 3){%><a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'>
<img src="../../images/edit.gif" border="0"></a>
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
    </tr>
    <%}%>
  </table>
  <%}} else {%>
  <table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25"><font color="red"><strong>Classified Information</strong><font></td>
    </tr>
  </table>
<%}%>
  <table bgcolor="aliceblue" width="100%" border="0" cellpadding="0" cellspacing="0">
	<%strTemp = WI.fillTextValue("cat_jump");
	vSubCatList = myForum.getSubCat(dbOP);
	if(vSubCatList != null && vSubCatList.size() > 0) {	%>
    <tr>
		<td align="right" height="30" valign="bottom"><font size="1">Forum Jump</font>&nbsp;
		<select name="cat_jump" style="font-size:10px">
        <%
	  for(i = 0 ; i< vSubCatList.size(); i +=3){ 
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
	<%}%>
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