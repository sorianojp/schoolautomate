<%@ page language="java" import="utility.*, osaGuidance.GDPsychologicalTest, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
	document.form_.print_pg.value = "";
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}
function SelALLSave() {
	var iMaxCount = document.form_.max_row_save.value;
	if(iMaxCount.length == 0) {
		alert('No list found.');
		return;
	}
	var bolIsChecked = document.form_.sel_all_save.checked;
	var obj;
	for(var i = 0; i < iMaxCount; ++i) {
		eval('obj=document.form_.user_'+i);
		if(!obj)
			continue;
		obj.checked = bolIsChecked;
	}
	
}
</script>
</head>
<%
	String strTemp = null; String strErrMsg = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"), "GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","schedule_stud.jsp");
	
	Vector vRetResult = null;  Vector vAdded = null; Vector vToAdd = null;
	GDPsychologicalTest psychTest = new GDPsychologicalTest();
	request.setAttribute("sched_idx",WI.fillTextValue("psy_index"));
	Vector vSchedInfo = psychTest.operateOnPsyTestSched(dbOP, request, 3);
	if(vSchedInfo == null)
		strErrMsg = psychTest.getErrMsg();
	else {
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0) {
			if(psychTest.operateOnTestSchedStud(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = psychTest.getErrMsg();
			else	
				strErrMsg = "Request processed successfully.";
		}
		if(WI.fillTextValue("sy_from").length() > 0) {
			vRetResult = psychTest.operateOnTestSchedStud(dbOP, request, 4);
			if(vRetResult == null)
				strErrMsg = psychTest.getErrMsg();
			else {
				vAdded = (Vector)vRetResult.remove(0);
				vToAdd = (Vector)vRetResult.remove(0);
			}
		}
	}
	
	
if(vSchedInfo == null) {%>
<p style="font-size:16px; color:#FF0000; font-weight:bold;"><%=psychTest.getErrMsg()%></p>
<%dbOP.cleanUP();
return;
}%>
<body bgcolor="#D2AE72">
<form name="form_" action="./schedule_stud.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING - SET PSYCHOLOGICAL INTERPRETATION PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td width="5%" height="24">&nbsp;</td>
      <td width="14%">Schedule Code</td>
      <td width="36%" style="font-weight:bold"><%=vSchedInfo.elementAt(6)%></td>
      <td width="45%">Test Name: <strong><%=vSchedInfo.elementAt(5)%></strong></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Date and Time </td>
      <td colspan="2" style="font-weight:bold">
	  <%
	  strTemp = (String)vSchedInfo.elementAt(11);
	  if(strTemp.equals("0"))
	  	strTemp = "AM";
	  else	
	  	strTemp = "PM";
	  %>
	  <%=vSchedInfo.elementAt(8)%> @ <%=vSchedInfo.elementAt(9)%>: <%=CommonUtil.formatMinute((String)vSchedInfo.elementAt(10))%> <%=strTemp%>
	  </td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>SY-Term</td>
      <td colspan="2">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); 
%> 
	<input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox" onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); 
%> 
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
	 - 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem"); 
%> 
      <select name="semester" style="font-size:11px">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected=>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
	  </td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Course</td>
      <td colspan="2">
		<select name="course_index" style="font-size:11px;">
          <option value="">Select a course</option>
		<%=dbOP.loadCombo("course_index","course_code + ' :: ' + course_name"," from course_offered where is_valid = 1 and is_offered = 1 order by course_code", 
				WI.fillTextValue("course_index"), false)%>
    </select>
	  </td>
    </tr>
      <tr> 
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="24" colspan="2">&nbsp;</td>
    </tr>
   
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25" colspan="2">
	  <input type="button" onClick="document.form_.page_action.value=''; document.form_.submit();" value="Show Student">  
		
	  </td>
    </tr>
  </table>
  <%if (vToAdd != null && vToAdd.size()>0) {%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#C78D8D"> 
      <td  height="25" colspan="9" align="center" class="thinborder" style="font-weight:bold; font-size:13px; color:#FFFFFF">::: List of Student to Schedule ::: </td>
    </tr>
    <tr style="font-weight:bold">
      <td width="5%" align="center" class="thinborder"><font size="1">SL #</font></td> 
      <td width="15%"  height="28" align="center" class="thinborder"><font size="1">Student ID</font></div></td>
      <td width="30%" align="center" class="thinborder"><font size="1">Student Name </font></td>
      <td width="10%" align="center" class="thinborder"><font size="1">College Code </font></td>
      <td width="10%" align="center" class="thinborder"><font size="1">Course Code </font></td>
      <td width="20%" align="center" class="thinborder"><font size="1">Student Status</font></td>
      <td width="5%" align="center" class="thinborder"><font size="1">Select <br>
	  <input type="checkbox" name="sel_all_save" onClick="SelALLSave();"></font></td>
    </tr>
    <%
	int iCount = 0;
	for(int i=0; i<vToAdd.size(); i+=6){%>
    <tr>
      <td class="thinborder"><%=++iCount%>.</td> 
      <td  height="26" class="thinborder"><%=vToAdd.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vToAdd.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vToAdd.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vToAdd.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vToAdd.elementAt(i + 5)%></td>
      <td class="thinborder" align="center"><input type="checkbox" name="user_<%=iCount-1%>" value="<%=vToAdd.elementAt(i)%>"></td>
    </tr>
    <%}%>
	<input type="hidden" name="max_row_save" value="<%=iCount%>">
  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="35" align="center"><input type="button" name="_" value="Schedule the selected students" onClick="document.form_.page_action.value='1'; document.form_.submit();"></td>
    </tr>
  </table>
  <%}

if (vAdded != null && vAdded.size()>0) {%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#C78D8D"> 
      <td  height="25" colspan="9" align="center" class="thinborder" style="font-weight:bold; font-size:13px; color:#FFFFFF">::: List of Student Already Scheduled ::: </td>
    </tr>
    <tr style="font-weight:bold">
      <td width="5%" align="center" class="thinborder"><font size="1">SL #</font></td> 
      <td width="15%"  height="28" align="center" class="thinborder"><font size="1">Student ID</font></div></td>
      <td width="30%" align="center" class="thinborder"><font size="1">Student Name </font></td>
      <td width="10%" align="center" class="thinborder"><font size="1">College Code </font></td>
      <td width="10%" align="center" class="thinborder"><font size="1">Course Code </font></td>
      <td width="20%" align="center" class="thinborder"><font size="1">Student Status</font></td>
      <td width="5%" align="center" class="thinborder"><font size="1">Select <br>
	  <input type="checkbox" name="sel_all_save" onClick="SelALLSave();"></font></td>
    </tr>
    <%
	int iCount = 0;
	for(int i=0; i<vAdded.size(); i+=6){%>
    <tr>
      <td class="thinborder"><%=++iCount%>.</td> 
      <td  height="26" class="thinborder"><%=vAdded.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vAdded.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vAdded.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vAdded.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vAdded.elementAt(i + 5)%></td>
      <td class="thinborder" align="center"><input type="checkbox" name="user_<%=iCount-1%>" value="<%=vAdded.elementAt(i)%>"></td>
    </tr>
    <%}%>
	<input type="hidden" name="max_row_del" value="<%=iCount%>">
  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="35" align="center"><input type="button" name="_" value="Delete selected students schedule" onClick="document.form_.page_action.value='0'; document.form_.submit();"></td>
    </tr>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="sched_idx" value="<%=WI.fillTextValue("psy_index")%>">
<input type="hidden" name="psy_index" value="<%=WI.fillTextValue("psy_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>