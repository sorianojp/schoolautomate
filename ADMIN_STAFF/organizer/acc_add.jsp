<%
if(request.getSession(false).getAttribute("userId") == null){%>
<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
	Please login to access this link.
</font>
<%return;
}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../jscript/common.js" ></script>
<script language="javascript"  src ="../../jscript/date-picker.js" ></script>
</head>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function viewAccomp(strDate) 
{
	document.form_.date_acc.value = strDate;
	this.SubmitOnce("form_");
}
</script>
<style>
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
<%@ page language="java" import="utility.*, organizer.ToDo, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vLatest = null;

	String strErrMsg = null;
	String strTemp = null;

	String strPrepareToEdit = null;
	strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

//add security here.
	try
	{
				dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-To Do-Accomplishments","acc_add.jsp");
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
		if(myToDo.operateOnAccomplishments(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = myToDo.getErrMsg();
			if (strErrMsg == null)
				strErrMsg = "Operation Successful.";
		}
		else
			strErrMsg = myToDo.getErrMsg();
	}
	
	vLatest = myToDo.operateOnAccomplishments(dbOP, request, 4);
	
	vRetResult = myToDo.operateOnAccomplishments(dbOP, request, 3);
	if (vRetResult != null)
		strPrepareToEdit = "1";
%>
<body bgcolor="#8C9AAA">
<form action="./acc_add.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="6" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ADD ACCOMPLISHMENT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" colspan="6" bgcolor="#FFFFFF"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
   	<tr>
   	
		<td colspan="6" height="10" align="left"><font size="1">&nbsp;Recent Accomplishments: &nbsp;||
		<%
		if (vLatest != null && vLatest.size()>0) {
		for (int j = 0; j < vLatest.size(); ++j) {%><a href="javascript:viewAccomp('<%=(String)vLatest.elementAt(j)%>');">
		<%=WI.formatDate((String)vLatest.elementAt(j),9)%></a>&nbsp;&nbsp;||
		<%}}%></font></td>    
	</tr>
	<tr>
		<td colspan="6">&nbsp;</td>
	</tr>
    <tr>
    	<td width="5%">&nbsp;<%
    	if (vRetResult != null && vRetResult.size()>0)
    		strTemp = (String)vRetResult.elementAt(5);
   		else
	    	strTemp = WI.fillTextValue("date_acc");
    
    	if (strTemp.length()==0)
    		strTemp = WI.getTodaysDate(1);%></td>
    	<td width="22.5%"><div align="left"><strong>Date Accomplished: </strong></div></td>
		<td width="72.5%" colspan="4" align="left">
<input name="date_acc" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_acc');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		&nbsp;&nbsp;&nbsp;<a href="JavaScript:ReloadPage();"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
<%if (WI.fillTextValue("date_acc").length()>0) {%>	
	 <tr>
    	<td >&nbsp;<%
    	if (vRetResult != null && vRetResult.size()>0)
    		strTemp = (String)vRetResult.elementAt(1);
    	else
			strTemp = WI.fillTextValue("userlist");%></td>
    	<td ><div align="left"><strong>Main Subject: </strong></div></td>
		<td colspan="4"><div align="left">
		<input name="main_subject" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" value="<%=strTemp%>">
		</div></td>
    </tr>
   	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
    <tr>
    	<td><%
    	if (vRetResult != null && vRetResult.size()>0)
    		strTemp = (String)vRetResult.elementAt(2);
    	else
	    	strTemp = WI.fillTextValue("summary");%></td>
    	<td valign="top"><div align="left"><strong>Summary</strong></div></td>
    	<td colspan="4"><textarea name="summary" cols="64" rows="5" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> </td>
    </tr>
   	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
    <tr>
    	<td><%
    	if (vRetResult != null && vRetResult.size()>0)
    		strTemp = WI.getStrValue((String)vRetResult.elementAt(3),"&nbsp;");
    	else
	    	strTemp = WI.fillTextValue("comment");%></td>
    	<td valign="top"><div align="left"><strong>Comment</strong></div></td>
    	<td colspan="4"><textarea name="comment" cols="64" rows="5" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> </td>
    </tr>
   	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
	<tr>
    	<td><%
    	if (vRetResult != null && vRetResult.size()>0)
    		strTemp = (String)vRetResult.elementAt(4);
    	else
	    	strTemp = WI.fillTextValue("nxt_task");%></td>
    	<td valign="top"><div align="left"><strong>Next Task</strong></div></td>
    	<td colspan="4"><textarea name="nxt_task" cols="64" rows="5" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> </td>
    </tr>
    <tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
		<tr>
		<td colspan="6" align="center"><font size="1"><%if(vRetResult == null) {%> <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0" name="hide_save"></a> 
        Save accomplishment 
        <%}else if (vRetResult != null && ((String)vRetResult.elementAt(6)).compareTo("0")==0){%> <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Edit accomplishment<%}%></font></td>    
	</tr>
	<%}%>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>    
	</tr>
  </table>
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