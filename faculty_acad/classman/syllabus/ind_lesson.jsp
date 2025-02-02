<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	document.form_.close_wnd_called.value = "1";
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.clear_data.value = "1";
	}
}
function PreparedToEdit(strInfoIndex) {
	document.form_.close_wnd_called.value = "1";
	
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}

<!-- Reload parent window when closed -->
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	
	window.opener.document.form_.focus_field.value = "focusIndv";
	window.opener.document.form_.submit();
	window.opener.focus();
	
	window.close();
}
function ReloadParentWnd() {
	if(document.form_.close_wnd_called.value == "1")
		return;
	window.opener.document.form_.focus_field.value = "focusIndv";
	window.opener.document.form_.submit();
	window.opener.focus();
}
</script>
<body bgcolor="#93B5BB">
<%@ page language="java" import="utility.*,ClassMgmt.CMSyllabusNew,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-FacultyAcad-Syllabus","ind_lesson.jsp");
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
int iAccessLevel = 2;

CMSyllabusNew cmsNew = new CMSyllabusNew();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cmsNew.operateOnIndividualLesson(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cmsNew.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = cmsNew.operateOnIndividualLesson(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = cmsNew.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = cmsNew.operateOnIndividualLesson(dbOP, request, 3);

boolean bolClearData = false;
if(WI.fillTextValue("clear_data").length() > 0) 
	bolClearData = true;
%>
<form action="./ind_lesson.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#6A99A2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SYLLABUS MAINTENANCE - INDIVIDUAL LESSON PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;<a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a><font style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="7%" height="25">&nbsp; </td>
      <td width="13%">Part No.: </td>
      <td width="80%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("part_no");
if(bolClearData)
	strTemp = "";
%>	  <input name="part_no" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','part_no');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','part_no')"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lesson Title: </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("lesson_title");
if(bolClearData)
	strTemp = "";
%>	  <input name="lesson_title" type="text" size="64" maxlength="128" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Unit No. :</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("unit_no");
if(bolClearData)
	strTemp = "";
%>	  <input name="unit_no" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','unit_no');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','unit_no')"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Unit Title :</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("unit_title");
if(bolClearData)
	strTemp = "";
%>	  <input name="unit_title" type="text" size="64" maxlength="128" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Learning Objective :</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("learning_obj");
if(bolClearData)
	strTemp = "";
%>        <textarea name="learning_obj" cols="75" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Content/Topic :</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("content_topic");
if(bolClearData)
	strTemp = "";
%>        <textarea name="content_topic" cols="75" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Teaching Strategy :</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("teaching_strategy");
if(bolClearData)
	strTemp = "";
%>        <textarea name="teaching_strategy" cols="75" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Evaluation :</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("evaluation");
if(bolClearData)
	strTemp = "";
%>        <textarea name="evaluation" cols="75" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea>
      </td>
    </tr>
    <tr> 
      <td height="32">&nbsp;</td>
      <td height="32">Timeframe :</td>
      <td height="32">        
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("timeframe");
if(bolClearData)
	strTemp = "";
%>	  <input name="timeframe" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','timeframe');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','timeframe')">
      (in hours) </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">References :</td>
      <td height="25">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("reference");
if(bolClearData)
	strTemp = "";
%>        <textarea name="reference" cols="75" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea>
      </td>
    </tr>
    <tr> 
      <td height="46">&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">
        <%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');">
      </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="10" class="thinborder"><strong><font color="#0000FF">:: INDIVIDUAL 
        LESSON :: </font></strong></td>
    </tr>
    <tr> 
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>PART NO. / LESSON NAME </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">UNIT NO./UNIT NAME</font></strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>LEARNING OBJECTIVE</strong></font></div></td>
      <td width="16%" class="thinborder" height="25"><div align="center"><font size="1"><strong>CONTENT/TOPIC</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>TEACHING STRATEGY</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>EVALUATION</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>TIMEFRAME <br>(Hours) </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>REFERENCES</strong></font></div></td>
      <td width="5%" class="thinborder">&nbsp;</td>
      <td width="5%" class="thinborder">&nbsp;</td>
    </tr>
<%
boolean bolShow = true;
for(int i = 0 ; i< vRetResult.size(); i += 11){
if(i > 0 && vRetResult.elementAt(i + 1).equals(strTemp))
	bolShow = false;
else {	
	bolShow = true;
	strTemp = (String)vRetResult.elementAt(i + 1);
}
%>
    <tr>
      <td class="thinborder">&nbsp;
	  	<%if(bolShow){%><%=vRetResult.elementAt(i + 1)%>.<%=vRetResult.elementAt(i + 2)%><%}%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"",".","")%><%=WI.getStrValue(vRetResult.elementAt(i + 4))%></td>
      <td class="thinborder">&nbsp;<%=ConversionTable.replaceString(WI.getStrValue(vRetResult.elementAt(i + 5)),"\r\n","<br>")%></td>
      <td class="thinborder">&nbsp;<%=ConversionTable.replaceString(WI.getStrValue(vRetResult.elementAt(i + 6)),"\r\n","<br>")%></td>
      <td class="thinborder" height="25">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 7))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 8))%></td> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 9))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 10))%></td>
      <td class="thinborder">
        <input type="submit" name="122" value=" Edit " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');">      </td>
      <td class="thinborder">
        <input type="submit" name="123" value="Delete" style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">      </td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult.%>  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="44" valign="bottom"><div align="center"></div></td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#6A99A2">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

<input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">

<input type="hidden" name="clear_data">
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>