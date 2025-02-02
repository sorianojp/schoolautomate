<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.fix_floating_ra.value = "";
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}
function RemoveSection(strInfoIndex) {
	document.form_.fix_floating_ra.value = "";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = 0;
	this.SubmitOnce("form_");
}
function RemoveFloatingRA() {
	document.form_.fix_floating_ra.value = "1";
	document.form_.page_action.value = 0;
	this.SubmitOnce("form_");
}
function SelAll() {
	var bolIsSel = document.form_.sel_all.checked;
	var maxDisp = document.form_.max_disp.value;
	var objChkBox;
	for(var i = 0; i < maxDisp; ++i) {
		eval('objChkBox = document.form_.cur_hist_i'+i);
		if(!objChkBox)
			continue;
		objChkBox.checked = bolIsSel;
	}
}
</script>

<body>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	WebInterface WI  = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Application Fix","move_enrolled_subject.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"move_enrolled_subject.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
AllProgramFix apf = new AllProgramFix();
if(WI.fillTextValue("process").length() > 0) {
	vRetResult = apf.operateOnMoveEnrolledSubject(dbOP, request, 3);
	if(vRetResult == null)
		strErrMsg = apf.getErrMsg();//message set for successful removal.
}
if(WI.fillTextValue("page_action").length() > 0) {
	apf.operateOnMoveEnrolledSubject(dbOP, request, 1);
	strErrMsg = apf.getErrMsg();
}
%>


<form name="form_" action="./move_enrolled_subject.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: CHECK CLASSPROGRAM OFFERING ERROR ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course</td>
      <td><select name="course_index" style="font-size:11px;">
        <%=dbOP.loadCombo("course_index","course_code +' :: '+course_name"," from course_offered where is_valid = 1 and course_code = 'bsn' and degree_type not in (1,2) order by course_code",WI.fillTextValue("course_index"), false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="15%" height="25">SY / TERM</td>
      <td width="83%"> 
<%
strTemp = WI.fillTextValue("sy_from");
strTemp = "2009";
%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
<%
	strTemp = WI.fillTextValue("sy_to");
strTemp = "2010";
%> <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4" readonly> 
        &nbsp;&nbsp; <select name="semester">
          <option value="1">1st</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.equals("2")){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">ID Number (starts with) </td>
      <td><input name="id_" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  		value="<%=WI.fillTextValue("id_")%>" size="18">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">CY-From and To </td>
      <td>
		  <input name="cur_fr1" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		  value="2009" size="4" maxlength="4">
		  
		  - 
		  
		  <input name="cur_to1" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		  value="2010" size="4" maxlength="4">	  
	  </td>
    </tr>
    <tr>
      <td colspan="3"><hr size="1" color="#0000FF"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Subject to Move </td>
      <td>
	  <select name="sub_fr">
		<%=dbOP.loadCombo("sub_index","sub_code +' :: '+sub_name"," from subject where is_del=0 and sub_code in ('Comp 1','Eng 2','Hist 4','Soc Sci 1','Math 3','Pol Sci','S/A') order by sub_code",WI.fillTextValue("sub_fr"), false)%>	  
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">New Subject </td>
      <td>
	  <select name="sub_to" style="font-size:11px;">
<%=dbOP.loadCombo("sub_index","sub_code +' :: '+sub_name"," from subject where is_del=0 order by sub_code",WI.fillTextValue("sub_to"), false)%>	  
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Curriculum Year from-to </td>
      <td>
	  <input name="cur_fr" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("cur_fr")%>" size="4" maxlength="4">
	  
	  - 
	  
	  <input name="cur_to" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=WI.fillTextValue("cur_to")%>" size="4" maxlength="4">	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td><input type="image" src="../../../images/form_proceed.gif" border="0" onClick="document.form_.process.value='1';document.form_.page_action.value=''"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" style="font-size:14px; color:#0000FF; font-weight:bold">NOTE : Before moving make sure the wrong subject is encoded in &quot;Subject to Move&quot; and correct subject is selcted and correct new curriculum year information is encoded. Once moved, it is not possible to undo the action. </td>
    </tr>
  </table>
<%if (vRetResult!= null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="25" colspan="7" class="thinborder" align="center"><strong>::: List of student enrolled in wrong subject and having grade ::: </strong></td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td width="4%" class="thinborder" style="font-size:9px;">Count</td> 
      <td width="16%" height="25" class="thinborder" style="font-size:9px;">ID Number </td>
      <td width="40%" class="thinborder" style="font-size:9px;">Student Name </td>
      <!--<td width="20%" class="thinborder" style="font-size:9px;">Grade</td>-->
      <td width="12%" class="thinborder" style="font-size:9px;">SY-Term</td>
      <td width="12%" class="thinborder" style="font-size:9px;">Grade</td>
      <td width="8%" class="thinborder" style="font-size:9px;">Select<br>
	  <input type="checkbox" name="sel_all" onClick="SelAll();"></td>
    </tr>
<%
int j = 0;
for(int i = 0; i < vRetResult.size(); i += 9,++j) {%>
    <tr>
      <td class="thinborder"><%=j + 1%>.</td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <!--<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>-->
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%>-<%=(String)vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder">
	  <%if(vRetResult.elementAt(i + 4) == null) {%>
	  	Not encoded
	   <%}%>
	  &nbsp;
	  </td>
      <td class="thinborder" align="center"><input type="checkbox" name="cur_hist_i<%=j%>" value="<%=vRetResult.elementAt(i + 5)%>">
	  <input type="hidden" name="enroll_i<%=j%>" value="<%=vRetResult.elementAt(i + 3)%>">
	  <input type="hidden" name="gs_i<%=j%>" value="<%=vRetResult.elementAt(i + 4)%>">	  </td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=j%>">
  </table>
  <table width="100%" cellpadding="0" cellspacing="0">
  <tr>
  	<td height="40" align="center"><input type="submit" onClick="document.form_.page_action.value='1';" value="Move Student Subject"></td>
  </tr>
  </table>
<%}%>

<input type="hidden" name="page_action">
<input type="hidden" name="process">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
