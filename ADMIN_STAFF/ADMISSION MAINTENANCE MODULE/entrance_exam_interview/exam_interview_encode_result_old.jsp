<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
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
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.NewType.value=document.form_.exam_index[document.form_.exam_index.selectedIndex].text;
	document.form_.NewCode.value=document.form_.sch_code[document.form_.sch_code.selectedIndex].text;
	document.form_.page_action.value="";
	this.SubmitOnce('form_');
}
</script>
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,enrollment.Advising,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Advising adv = new Advising();
	
	Vector vStudInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo  = null;
	Vector vExamName = null;
	Vector vSchedData = null;
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = null;
	String strInfoIndex = WI.fillTextValue("info_index");
	String strSchedIndex = WI.fillTextValue("sched_index");

	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","exam_interview_encode_result.jsp");
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
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",request.getRemoteAddr(),
														"exam_interview_encode_result.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(appMgmt.operateOnStudExamResult(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = appMgmt.getErrMsg();
	}
	
		
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = appMgmt.operateOnStudExamResult(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = appMgmt.getErrMsg();
	}
	//view all 
	vRetResult = appMgmt.operateOnStudExamResult(dbOP, request, 4);
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./exam_interview_encode_result.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          RESULT ENCODING / VIEWING PAGE::::</font></strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>School Year / Term</td>
      <td width="28%"><%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
/
<select name="semester">
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}if(strTemp.compareTo("1") ==0){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.compareTo("2") == 0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") == 0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}%>
</select></td>
      <td colspan="2"><a href="javascript:Cancel();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Scheduling Type/Sub-type</td>
      <td colspan="3"><select name="exam_index" onChange="ReloadPage();">
        <%
	   //if(vEditInfo != null && vEditInfo.size() > 0)
	//		strTemp = (String)vEditInfo.elementAt(4);
	//	else	
			strTemp = WI.fillTextValue("exam_index");
				
	  	vExamName = appMgmt.retreiveName(dbOP, request);
	  	if(vExamName != null && vExamName.size() > 0) {
		  for(int i = 0 ; i< vExamName.size(); i +=4){ 
			if( strTemp.compareTo((String)vExamName.elementAt(i)) == 0) {%>
        <option value="<%=(String)vExamName.elementAt(i)%>" selected><%=(String)vExamName.elementAt(i+3)%></option>
        <%}else{%>
        <option value="<%=(String)vExamName.elementAt(i)%>"><%=(String)vExamName.elementAt(i+3)%></option>
        <%}
			}
		   }%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Schedule Code</td>
      <td colspan="3"><select name="sch_code" onChange="ReloadPage();">
        <%
		String strTemp2 = null;
	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp2 = (String)vEditInfo.elementAt(1);
		else	
			strTemp2 = WI.fillTextValue("exam_index");
			
	if(WI.fillTextValue("exam_index").length() > 0)
	{
	strTemp = " FROM NA_EXAM_SCHED WHERE IS_DEL=0 AND IS_VALID=1 AND EXAM_NAME_INDEX ="+WI.fillTextValue("exam_index")+"AND SY_FROM ="+WI.fillTextValue("sy_from")+" AND SY_TO ="+WI.fillTextValue("sy_to")+"AND SEMESTER ="+WI.fillTextValue("semester")+" order by SCHEDULE_CODE asc" ;
	%>
        <%=dbOP.loadCombo("EXAM_SCHED_INDEX","SCHEDULE_CODE",strTemp, request.getParameter("sch_code"), false)%>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
	<% 
	request.setAttribute("info_index",WI.fillTextValue("sch_code"));
	vSchedData = appMgmt.operateOnExamSched(dbOP,request,5);
	String [] astrConvTime={" AM"," PM"};
	%>
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%">Date :  <strong>
      <%if(vSchedData != null && vSchedData.size() > 0)%><%=((String)vSchedData.elementAt(7))%></strong></td>
      <td>Start Time :<strong><%if(vSchedData != null && vSchedData.size() > 0)%><%=CommonUtil.formatMinute((String)vSchedData.elementAt(8))+':'+ CommonUtil.formatMinute((String)vSchedData.elementAt(9))+astrConvTime[Integer.parseInt((String)vSchedData.elementAt(10))]%></strong></td>
      <td width="20%">Duration (min):<strong>
      <%if(vSchedData != null && vSchedData.size() > 0)%><%=((String)vSchedData.elementAt(6))%></strong></td>
      <td width="31%">Venue : <strong>
      <%if(vSchedData != null && vSchedData.size() > 0)%><%=((String)vSchedData.elementAt(12))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contact Person</td>
      <td height="25" colspan="3"><strong><%if(vSchedData != null && vSchedData.size() > 0)%><%=((String)vSchedData.elementAt(13))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contact Info</td>
      <td height="25" colspan="3" valign="bottom"><strong><%if(vSchedData != null && vSchedData.size() > 0)%><%=((String)vSchedData.elementAt(14))%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25"><div align="right"></div></td>
      <td width="19%" height="25">Maximum Score/Rate :</td>
      <td width="12%" height="25"><strong>
      <%if(vSchedData != null && vSchedData.size() > 0)%><%=((String)vSchedData.elementAt(15))%></strong></td>
      <td width="66%" height="25">Passing Score/Rate : <strong>
      <%if(vSchedData != null && vSchedData.size() > 0)%><%=((String)vSchedData.elementAt(16))%></strong></td>
      <td width="1%" height="25">&nbsp;</td>
    </tr>
  <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <% 
    if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="23" align="right"> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">Print this page.</font></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="8"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF APPLICANTS TAKING FOR : <%=WI.getStrValue(request.getParameter("NewType")) + " / "+WI.getStrValue(request.getParameter("NewCode"))%></font></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><strong><font size="1">TOTAL APPLICANT(S) : <%=vRetResult.size()/9%>  </font></strong></td>
      <td height="25" colspan="3" class="thinborder"><div align="right"><font size="1">Jump to page 
          </font> 
          <select name="select3">
          </select>
        </div></td>
    </tr>
    <tr> 
      <td width="8%" class="thinborder"><div align="center" ><strong><font size="1">COUNT NO.</font></strong></div></td>
      <td width="16%" height="25" class="thinborder"><div align="center"><strong><font size="1">TEMPORARY 
          /APPLICANT ID</font></strong></div></td>
      <td width="29%" class="thinborder"><div align="center"><strong><font size="1">APPLICANT NAME</font></strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong><font size="1">SCORE/RATE</font></strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong><font size="1">MAXIMUM SCORE/ 
          RATE</font></strong></div></td>
      <td width="11%" class="thinborder"><div align="center"><b><font size="1">PASSING SCORE/RATE</font></b></div></td>
      <b> </b> 
      <td align="center" class="thinborder"><strong><font size="1">REMARKS</font></strong></td>
      <td align="center" class="thinborder">&nbsp;</td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
    <tr> 
      <td class="thinborder"><div align="center"><%if (i<8)%><%=i+1%><%else%><%=((i/8)+1)%></div></td>
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+5))%></div></td>
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+6)+' '+(String)vRetResult.elementAt(i+7)+' '+(String)vRetResult.elementAt(i+8))%></div></td>
      <td class="thinborder"><div align="center">
	  <%if (((String)vRetResult.elementAt(i+2) == null) && (WI.fillTextValue("prepareToEdit").compareTo("1") == 0)) {%>
	  <input name="textfield4" type="text" size="4" maxlength="4"><%}else{%>
	  <%=((String)vRetResult.elementAt(i+2))%><%}%>
        </div></td>
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+3))%></div></td>
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+4))%></div></td>
      <td width="9%" align="center" class="thinborder"><select name="select6">
        <option>PASSED</option>
        <option>FAILED</option>
        <option>RE-TAKE</option>
      </select></td>
      <td width="6%" align="center" class="thinborder"><%if ((String)vRetResult.elementAt(i+2) == null) {%><a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a></td>
    </tr>
	<%} else {%>
	<font size="1">Not Editable</font>
    <%}
	i = i+8;
}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="52"  colspan="3"><div align="center"><img src="../../../images/save.gif" width="48" height="28"><font size="1">click 
          to save entries <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> Click to clear entries<font size="1">click 
          to cancel/clear entries</font></font></div></td>
    </tr>
	<%}%>
  </table>
	  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 	  <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
 	  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
    <input type="hidden" name="page_action" >
    <input type="hidden" name="NewType">
    <input type="hidden" name="NewCode">
</form>
</body>
</html>
<% dbOP.cleanUP();
%>