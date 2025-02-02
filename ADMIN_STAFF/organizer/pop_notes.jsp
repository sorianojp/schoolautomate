<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>To Do List</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../jscript/common.js" ></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if (strAction=="1")
	{
		if (document.form_.subject.value.length==0)
		{
			alert("No Subject Entered");
			return;
		}
	}
		
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function FocusStuff()
{
	document.form_.subject.focus();
}
//Allows user to click the ongoing todos..
function navRollOver(obj, state, iIndex) {
  	if(eval('document.form_.ongoing_stat'+iIndex+'.value') == 1)
		return;
	//change color only if it is not ongoing.
	//alert("I am here");
		
	document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function ToggleToDoOnGoing(obj,iIndex) {
	//alert(eval('document.form_.ongoing_stat'+iIndex+'.value'));
	if(eval('document.form_.ongoing_stat'+iIndex+'.value') == 1) {
		eval('document.form_.ongoing_stat'+iIndex+'.value = 0');
		document.getElementById(obj).className = 'nav';
	}
	else {
		eval('document.form_.ongoing_stat'+iIndex+'.value = 1');
		document.getElementById(obj).className = 'nav-ongoing';
	}
}

</script>
<style>
.nav {
     color: #000000;
     background-color: #FFFFFF;
}
.nav-highlight {
	 font-weight:bold;
     color: #000000;
     background-color: #FAFCDD;
}
.nav-ongoing {
     color: #000000;
     background-color: #78fc8c;
}

.textbox_header {
	font-family:Verdana, Arial, Helvetica, sans-serif;
	border: 0; 
	font-weight:bold;
	background-color: #DBEAF5;
	font-size: 8;
}
</style>

<%@ page language="java" import="utility.*, organizer.ToDo, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strErrMsg = null;
	String strTemp = null;
	String strFinCol = null;
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	if (strUserID != null) {
		request.getSession(false).setAttribute("userId2", strUserID);
	}
	else if(WI.fillTextValue("userID").length() > 0) {
		strUserID = WI.fillTextValue("userID");
		request.getSession(false).setAttribute("userId2", strUserID);
	}
				
		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-To Do","pop_notes.jsp");
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
	
	ToDo myToDo = new ToDo();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myToDo.operateOnToDoList(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			//strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myToDo.getErrMsg();
	}
			
	vRetResult = myToDo.operateOnToDoList(dbOP, request, 4);
	
	if (strErrMsg == null)
		strErrMsg = myToDo.getErrMsg();


%>
<body bgcolor="#8C9AAA" leftmargin="0" topmargin="0" rightmargin="0" onLoad="FocusStuff()">
<form action="./pop_notes.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="20"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          TO DO ::::</strong></font></div></td>
    </tr>
    <tr>
    <td height="10"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#DBEAF5">
		<td width="5%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
      <td width="85%"><font size="1"><strong>To Do List (Click to indicate ongoing..)</strong></font></td>
		<td width="5%">&nbsp;</td>
	</tr>
	<%if (vRetResult != null && vRetResult.size()>0){
	 for (int i= 0; i < vRetResult.size(); i+=9){
   		if (((String)vRetResult.elementAt(i+7)).compareTo("1")==0)
			strFinCol = " bgcolor = '#DDDDDD'";
		else if(WI.fillTextValue("ongoing_stat"+i).compareTo("1") == 0) 
			strFinCol = " bgcolor = '#78fc8c'";
		else 
			strFinCol = "";
		
   	%>
   <tr<%=strFinCol%><%if (((String)vRetResult.elementAt(i+7)).compareTo("1")!=0){%> onClick="javascript:ToggleToDoOnGoing('msg<%=i%>','<%=i%>');"
     id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on',<%=i%>)" onMouseOut="navRollOver('msg<%=i%>', 'off',<%=i%>)" <%}%>>
	<td><a href='javascript:PageAction(5,"<%=(String)vRetResult.elementAt(i)%>");'>
   	<%if( ((String)vRetResult.elementAt(i+7)).compareTo("1")==0){%>
   	<input type="checkbox" name="isFinished<%=(String)vRetResult.elementAt(i)%>" value="1" checked>
   	<%}else{%>
   	<input type="checkbox" name="isFinished<%=(String)vRetResult.elementAt(i)%>" value="1"><%}%></a></td>
	<td width="5%">
	<%if (((String)vRetResult.elementAt(i+2)).compareTo("1")==0){%><img src="../../images/prior_h.gif" border="0">
	<%}else{%><img src="../../images/prior_l.gif" border="0"><%}%></td>
	<td valign="middle"><font size="1">
	<%if (((String)vRetResult.elementAt(i+7)).compareTo("1")==0){%><strike><%}%>
	<%=(String)vRetResult.elementAt(i+1)%>
	<%if (((String)vRetResult.elementAt(i+7)).compareTo("1")==0){%></strike><%}%>
	</font></td>
	<td><div align="center"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'>
	<img src="../../images/x_small.gif" border="0"></a></div></td>
	<input type="hidden" name="ongoing_stat<%=i%>" value="<%=WI.getStrValue(WI.fillTextValue("ongoing_stat"+i),"0")%>">
	</tr>
	<%}//end of for looop
	}//end of IF.%>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
	<tr bgcolor="#DBEAF5">
		<td colspan="4" align="left" height="20" valign="middle"><font size="1"><strong>::: QUICK ADD <input type="text" name="ticker" size="3" class="textbox_header" readonly="readonly" >&nbsp;:::</strong></font></td>
	</tr>
	<tr>
		<td colspan="3" align="right"><font size="1">Priority:
		<input type="checkbox" name="priority" value="1">
		 </font></td>
		<td ><a href='javascript:PageAction(1,"");'><img src="../../images/add.gif" border="0" name="hide_save"></a></td>
	</tr>
	<td colspan="4" valign="top"><font size="1">&nbsp;
		<textarea name="subject" cols="27" rows="3" class="textbox" 
	  onfocus="CharTicker('form_','128','subject','ticker'); style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="CharTicker('form_','128','subject','ticker');"></textarea></font></td>
	</tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="userID" value="<%=strUserID%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>