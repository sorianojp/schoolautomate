<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table +
	 "&indexname=" + indexname + "&colname=" + colname+"&label="+
	 labelname+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	document.form_.ip_addr.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,citbookstore.BookManagement,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-PROPERTY","login_terminal.jsp");
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
														"Bookstore","PROPERTY",request.getRemoteAddr(),
														"login_terminal.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
	BookManagement bm = new BookManagement();
	Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(bm.operateOnLoginTerminal(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = bm.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Distribution Location successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Distribution Location successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Distribution Location successfully edited.";
		}
	}

	vRetResult = bm.operateOnLoginTerminal(dbOP, request,4);	
	
%>
<form action="login_terminal.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderALL" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="3" class="thinborderBOTTOM"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          DISTRIBUTION CENTER - ASSIGN PC FOR USERS LOGIN ::::</strong></font></div></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp; </td>
      <td colspan="2"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>

    <tr> 
      <td width="6%">&nbsp;</td>
      <td width="15%"><strong><font size="1" >IP ADDRESS : </font></strong></td>
      <td width="79%">
        <input name="ip_addr" type="text" maxlength="15" value="<%=WI.fillTextValue("ip_addr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><font size="1" ><strong>LOCATION :</strong></font></td>
      <td> 
<select name="loc_index" 
			style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 13;">
<%=dbOP.loadCombo("DIST_LOC_INDEX","DIST_LOC_NAME"," from BS_BOOK_DIST_LOC order by DIST_LOC_NAME", WI.fillTextValue("loc_index"),false)%> </select>
       <!-- <font size="1" ><a href='javascript:viewList("BS_BOOK_DIST_LOC","DIST_LOC_INDEX","DIST_LOC_NAME","DISTRIBUTION LOCATION");'>
		<img src="../../../images/update.gif" border="0"></a></font> -->
      </td>
    </tr>
    <%
if(iAccessLevel > 1){%>
    <tr> 
      <td height="40" colspan="3"><div align="center"> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0"></a><font size="1" >click 
          to save entries/changes <a href="login_terminal.jsp"><img src="../../../images/cancel.gif" border="0"></a>click 
          to clear entries</font></div></td>
    </tr>
    <tr>
      <td height="28" colspan="3">&nbsp;</td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" > 
      <td height="25" colspan="3" class="thinborder"><div align="center"><font color="#ffffff"><strong>LIST 
          OF ASSIGNED PC FOR USERS LOGIN</strong></font></div></td>
    </tr>
    <tr > 
      <td width="29%" height="25" class="thinborder"><div align="center"><strong><font size="1" >IP 
          ADDRESS</font></strong></div></td>
      <td width="52%" class="thinborder"><div align="center"><font size="1" ><strong>LOCATION</strong></font></div></td>
      <td width="19%" class="thinborder">&nbsp;</td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 5){%>
    <tr > 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
    </tr>
    <%}%>
  </table>
<%}//if vRetResult not null
%>

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>