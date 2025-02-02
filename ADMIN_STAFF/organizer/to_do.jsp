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
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel()
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function ChangeOrder(strField)
{
	document.form_.extrasort.value = ", "+strField;
	this.SubmitOnce('form_');
}
function FocusStuff()
{
	document.form_.subject.focus();
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
	Vector vEditInfo = null;

	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String strFinCol = null;

strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-To Do","to_do.jsp");
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
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = myToDo.getErrMsg();
	}

	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = myToDo.operateOnToDoList(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null )
			strErrMsg = myToDo.getErrMsg();
	}


	vRetResult = myToDo.operateOnToDoList(dbOP, request, 4);

	if (strErrMsg == null)
		strErrMsg = myToDo.getErrMsg();


%>
<body bgcolor="#8C9AAA" onLoad="FocusStuff();">
<form action="./to_do.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F">
      <td height="28" colspan="6" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>::::
          TO DO LIST ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" colspan="6" bgcolor="#FFFFFF"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
    	<td width="5%">&nbsp;</td>
    	<td width="15%"><div align="left"><strong>Subject</strong></div></td>
		<td width="45%" align="left">
		<%
        if (vEditInfo != null && vEditInfo.size()>0)
    	    strTemp = (String)vEditInfo.elementAt(1);
        else
	         strTemp = WI.fillTextValue("subject");%>
	         <input name="subject" type="text" class="textbox" value="<%=strTemp%>" onFocus="CharTicker('form_','128','subject','ticker'); style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32"
	         onkeyup="CharTicker('form_','128','subject','ticker');"><font size="1">
	         <input type="text" name="ticker" size="3" class="textbox_noborder" readonly="readonly"
	         style="font-size:9px"></font>
	         </td>
    	<td width="35%" colspan="3" align="left"><strong>Priority</strong>
    		<%
	        if (vEditInfo != null && vEditInfo.size()>0)
    		    strTemp = WI.getStrValue((String)vEditInfo.elementAt(2),"0");
        	else
	        	strTemp = WI.fillTextValue("priority");
	        	if (strTemp.equals("1")){%>
    		<input type="radio" name="priority" value="1" checked>High
    		<input type="radio" name="priority" value="0">Low
    		<%}else{%>
    		<input type="radio" name="priority" value="1">High
    		<input type="radio" name="priority" value="0" checked>Low
    		<%}%>
    	</td>
    </tr>
   	<tr>
		<td colspan="6" height="10">&nbsp;</td>
	</tr>
    <tr>
    	<td>&nbsp;</td>
    	<td><div align="left"><strong>Category</strong></div></td>
    	<td colspan="4">
    	<%
        if (vEditInfo != null && vEditInfo.size()>0)
    	    strTemp = (String)vEditInfo.elementAt(3);
        else
	         strTemp = WI.fillTextValue("cat_index");%>
	         <select name="cat_index">
		    <option value="">Select Category</option>
			<%=dbOP.loadCombo("ORG_CAT_INDEX","CATEGORY"," FROM ORG_CATEGORY ORDER BY CATEGORY", strTemp, false)%>
		    </select></td>
    </tr>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>
	</tr>
    <tr>
    	<td>&nbsp;</td>
    	<td><div align="left"><strong>Due Date</strong></div></td>
    	<td colspan="4">
    	<%
        if (vEditInfo != null && vEditInfo.size()>0)
      		strTemp = WI.getStrValue((String)vEditInfo.elementAt(5),"");
		else
        	strTemp = WI.fillTextValue("due_date");
		if(strTemp.length() == 0)
			strTemp = WI.getTodaysDate(1);%>
    	<input name="due_date" type="text" class="textbox" id="date" value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" maxlength="12" readonly="true">
        <a href="javascript:show_calendar('form_.due_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr>
		<td colspan="6" height="10">&nbsp;</td>
	</tr>
    <tr>
    	<td>&nbsp;</td>
    	<td><div align="left"><strong>Notes</strong></div></td>
    	<td colspan="4">
    	<%
        if (vEditInfo != null && vEditInfo.size()>0)
    	    strTemp = WI.getStrValue((String)vEditInfo.elementAt(6),"");
        else
	    	strTemp = WI.fillTextValue("notes");%>
    	<textarea name="notes" cols="35" rows="2" class="textbox"
	  onfocus="CharTicker('form_','256','notes','ticker2');style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onkeyup="CharTicker('form_','256','notes','ticker2');"><%=strTemp%></textarea><font size="1">
	  <input type="text" name="ticker2" size="3" class="textbox_noborder" readonly="readonly"
	  style="font-size:9px"></td>
    </tr>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>
	</tr>
		<tr>
		<td colspan="6"><div align="center"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../images/add.gif" border="0" name="hide_save"></a>
        Click to add entry
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a>
        Click to edit event <a href="javascript:Cancel();"><img src="../../images/cancel.gif" border="0"></a>
        Click to clear entries
        <%}%></font></div></td>
	</tr>
	<tr>
		<td colspan="6" height="10">&nbsp;</td>
	</tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   	<tr bgcolor="#DBEAF5">
   	<td width="7%"><div align="left"><strong><font size="1">Status</font></strong></div></td>
   	<td width="15%"><div align="left"><strong><font size="1"><a href="javascript:ChangeOrder('due_date')">Due Date</a></font></strong></div></td>
   	<td width="25%"><div align="left"><strong><font size="1"><a href="javascript:ChangeOrder('subject')">Subject</a></font></strong></div></td>
   	<td width="12%"><div align="left"><strong><font size="1"><a href="javascript:ChangeOrder('category')">Category</a></font></strong></div></td>
   	<td width="5%"><div align="left"><strong><font size="1">Priority</font></strong></div></td>
   	<td width="32%"><div align="left"><strong><font size="1">&nbsp;Notes</font></strong></div></td>
   	<td width="5%">&nbsp;</td>
   	</tr>
   	<%//System.out.println(vRetResult);
	for (int i= 0; i < vRetResult.size(); i+=9){
		strTemp = (String)vRetResult.elementAt(i+7);
		if (strTemp.equals("1"))
			strFinCol = " bgcolor = '#EEEEEE'";
		else if(strTemp.equals("2"))
			strFinCol = " bgcolor = '#FFBBBB'";
		else
			strFinCol = " bgcolor = '#FFFFFF'";
   	%>
   	<tr <%=strFinCol%>>
   	<td class="thinborderBOTTOM">
   	<%strTemp = (String)vRetResult.elementAt(i+7);%>
   	<a href='javascript:PageAction(5,"<%=(String)vRetResult.elementAt(i)%>");'>
   	<%if (strTemp.compareTo("1")==0){%>
   	<input type="checkbox" name="isFinished<%=(String)vRetResult.elementAt(i)%>" value="1" checked>
   	<%}else{%>
   	<input type="checkbox" name="isFinished<%=(String)vRetResult.elementAt(i)%>" value="1"><%}%></a>
   	</td>
   	<td class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),(String)vRetResult.elementAt(i+8))%></font> </td>
   	<td class="thinborderBOTTOM"><font size="1"><a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><%=(String)vRetResult.elementAt(i+1)%></a></font></td>
   	<td class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></font></td>
   	<td valign="middle" class="thinborderBOTTOM"><div align="center"><%if (((String)vRetResult.elementAt(i+2)).compareTo("1")==0){%>
   	<img src="../../images/prior_h.gif" border="0"><%}else{%>
   	<img src="../../images/prior_l.gif" border="0"><%}%></div></td>
   	<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
	<td valign="middle" class="thinborderBOTTOM"><div align="center"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../images/delete_2.gif" border="0"></a></div></td>
   	</tr>
   	<%}%>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<input name = "extrasort" type = "hidden"  value="<%=WI.fillTextValue("extrasort")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
