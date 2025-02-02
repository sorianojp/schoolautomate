<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ChangeCourseIndex() {
	document.cmaintenance.change_course_index.value = 1;
	this.ReloadPage();
}
function copyCurYr(strCYFrom, strCYTo) {
	document.cmaintenance.cy_from.value = strCYFrom;
	document.cmaintenance.cy_to.value   = strCYTo;
	this.ReloadPage();	
}
function ViewAll()
{
	var strCName = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].text;
	var strCIndex = document.cmaintenance.course_index[document.cmaintenance.course_index.selectedIndex].value;

	var strMName = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].text;
	var strMIndex = document.cmaintenance.major_index[document.cmaintenance.major_index.selectedIndex].value;

	var strSYFrom = document.cmaintenance.cy_from.value;
	var strSYTo = document.cmaintenance.cy_to.value;

	if(document.cmaintenance.course_index.selectedIndex <= 0)
	{
		alert("Please select a course.");
		return;
	}
	if(strSYFrom.length <2)
	{
		alert("Please enter <Curriculum year> to view detail course curriculum.");
		return;
	}
	if(strSYTo.length <2)
	{
		alert("Please enter <Curriculum year> to view detail course curriculum.");
		return;
	}

	if(document.cmaintenance.major_index.selectedIndex == 0) //major index is null
	{
		location = "./curriculum_maintenance_m_d_viewall.jsp?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo;
	}
	else
	{
		location = "./curriculum_maintenance_m_d_viewall.jsp?ci="+strCIndex+"&cname="+escape(strCName)+
			"&syf="+strSYFrom+"&syt="+strSYTo+"&mi="+strMIndex+"&mname="+escape(strMName);
	}
}
function PageAction(strAction, strInfoIndex) {
	document.cmaintenance.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.cmaintenance.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.cmaintenance.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('cmaintenance');
}
function PrepareToEdit(strInfoIndex) {
	document.cmaintenance.page_action.value = "";
	document.cmaintenance.prepareToEdit.value = "1";
	document.cmaintenance.info_index.value = strInfoIndex;
	this.SubmitOnce('cmaintenance');
}
function ReloadPage()
{
	document.cmaintenance.page_action.value = "";
	document.cmaintenance.reloadPage.value = 1;
	this.SubmitOnce('cmaintenance');
}
function Cancel() {
	document.cmaintenance.page_action.value = "";
	document.cmaintenance.prepareToEdit.value = "";
	document.cmaintenance.info_index.value = "";
	//document.cmaintenance.unit.value = "";
	this.SubmitOnce('cmaintenance');
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumMaintenance,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = new Vector();//this is added to store the subject descirption, category name and category index for Pre-requisite

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vCurInfo = null;

	boolean bolIsLocked = false;//check LOCK_CURRICULUM table.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Courses curriculum - medicine","curriculum_maintenance_m_d.jsp");
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
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"curriculum_maintenance_m_d.jsp");
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

boolean bolProceed = true;
strErrMsg = null; //if there is any message set -- show at the bottom of the page.
	CurriculumMaintenance CM = new CurriculumMaintenance();
	Vector vEditInfo  = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(CM.operateOnCurriculumMasters(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = CM.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Curriculum information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Curriculum information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Curriculum information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = CM.operateOnCurriculumMasters(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = CM.getErrMsg();
}

	vCurInfo  = CM.operateOnCurriculumMasters(dbOP, request,4);
	if(vCurInfo == null && strErrMsg == null)
		strErrMsg = CM.getErrMsg();
if(vCurInfo != null && vCurInfo.size() > 0) 
	bolIsLocked = new enrollment.SetParameter().isCurLocked(dbOP, WI.fillTextValue("course_index"),
		WI.fillTextValue("major_index"), WI.fillTextValue("cy_from"),WI.fillTextValue("cy_to"));

if(!bolProceed)
{
	dbOP.cleanUP();
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
	<%=CM.getErrMsg()%></font></p>
	<%
	return;
}

boolean bolIsReqOnlyChecked = false;
%>
<form name="cmaintenance" method="post" action="./curriculum_maintenance_m_d.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          COURSES CURRICULUM MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="0%" height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td height="25" colspan="3">
        <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr>
      <td width="0%" height="25">&nbsp;</td>
      <td width="2%">&nbsp;</td>
      <td width="37%">Course </td>
      <td width="25%">&nbsp;</td>
      <td width="36%">Curriculum year </td>
    </tr></tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><select name="course_index" onChange="ReloadPage();">
          <option value="selany">Select Any</option>
          <%//get course offerd for doctoral/masters.
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and cc_index in (select cc_index from cclassification "+
			"where is_del=0 and degree_type=1) order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%> 
        </select></td>

      <td><input name="cy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("cy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('cmaintenance','cy_from');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('cmaintenance','cy_from')">
        to
        <input name="cy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("cy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('cmaintenance','cy_to');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('cmaintenance','cy_to')">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">Major&nbsp;&nbsp; <select name="major_index">
          <option></option>
          <%
strTemp = request.getParameter("course_index");
if(strTemp != null && strTemp.compareTo("selany") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select> </td>
      <td>
        <%
Vector vCurYearInfo = null;
strTemp = null;
if(WI.fillTextValue("course_index").length() == 0 || WI.fillTextValue("course_index").compareTo("selany") == 0) 
	strTemp = null;
else	
	strTemp = WI.fillTextValue("major_index");

vCurYearInfo = new enrollment.SubjectSection().getSchYear(dbOP, request.getParameter("course_index"),strTemp);
if(vCurYearInfo != null) {
%>
        <strong><font color="#0000FF" size="1">Existing Cur Year:</font> </strong><br> 
        <%
		for(int i = 0; i < vCurYearInfo.size(); i += 2) {%>
        <a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);"> 
        <font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a> 
        <%i = i + 2;
		if(i < vCurYearInfo.size()){%>
        <a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);"> 
        <font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a> 
        <%}//show two in one line.%>
        <br> 
        <%}%>
        <%}//only if cur info is not null;
%>
      </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<!--    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><strong>To filter SUBJECT display enter subject code starts 
        with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="8" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:15px">
        and click REFRESH</strong></td>
    </tr>
 -->   <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="24%">&nbsp;</td>
      <td width="6%"><a href="javascript:ViewAll();" target="_self">
	  <img src="../../../images/view.gif" border="0"></a></td>
      <td width="68%" valign="bottom"><font size="1">click to view complete curriculum 
        OR click to reload page. <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></font></td>
    </tr>
    <tr valign="middle">
      <td height="25" colspan="4"><hr size="1"> </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="22%" height="25">Course Requirements </td>
      <td width="35%"><select name="req_index">
<%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(0);
else	
	strTemp = WI.fillTextValue("req_index");
%>
          <%=dbOP.loadCombo("req_index","requirement"," from CCULUM_MASTERS_REQ where is_del=0 ", strTemp, false)%>
        </select></td>
      <td width="41%" height="25">
	  Units Required :
 <%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("req_unit");
%>       <input type="text" name="req_unit" value="<%=strTemp%>" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('cmaintenance','req_unit');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('cmaintenance','req_unit')">
        (only needed for edit and first time entry)</td>

    </tr>
	    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Requirement display order</td>
      <td>
	  <select name="disp_order">
 <%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("disp_order");
	  for(int i=1; i<10; ++i){
	  if(strTemp.compareTo(Integer.toString(i)) ==0){
	  %>
	  <option value="<%=i%>" selected><%=i%></option>
	  <%}else{%>
	  <option value="<%=i%>"><%=i%></option>
	  <%}
	  }%>
	  </select>
	  </td>
      <td height="25">
        <%if(false) {//turn it off for now.. 
		
		
strTemp = WI.fillTextValue("req_only");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else	
	strTemp = "";
//I have to check if edit is called and it is for subject, i must not check this.
if(vEditInfo != null && ((String)vEditInfo.elementAt(4)).compareTo("0") == 0) 
	strTemp = " checked";
else if(vEditInfo != null)
	strTemp = "";

if(strTemp.length() > 0) 
	bolIsReqOnlyChecked = true;
%>
        <input type="checkbox" name="req_only" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font size="1">Add/Edit/Delete Requirement only (This option will ignore 
        the subject)</font>
		
<%}//end of false.. %>
		</td>
    </tr>

    <tr>
      <td height="25"><div align="center"> </div></td>
      <td height="25" colspan="2"> 
        <%if(iAccessLevel > 1){%>
	  <a href="curriculum_maintenance_m_d_update.jsp"><img src="../../../images/update.gif" border="0"></a><font size="1">click
        to update list of course requirements</font>
<%}%>		</td>

      <td height="25">
	<%if(bolIsReqOnlyChecked){%>
	  	<font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font>
	<%}//show only if req only is clicked.%>	
		</td>
    </tr>
  </table>
<%
//do not show if curriculum year is not selected. 
if(WI.fillTextValue("cy_from").length() >0 &&  WI.fillTextValue("cy_to").length() > 0 && !bolIsReqOnlyChecked) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="24">&nbsp;</td>
      <td width="33%"  height="24"><div align="left"><font size="1"><strong>SUBJECT 
          CODE</strong>
          <input type="text" name="scroll_sub" size="12" style="font-size:12px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'cmaintenance');">
          (scroll)</font></div></td>
      <td width="46%"><div align="left"><font size="1"><strong>SUBJECT TITLE 
          </strong></font></div></td>
      <td width="19%"><div align="left"><font size="1"><strong>UNITS </strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td colspan="2"> <%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("sub_index");
%> <select name="sub_index" onChange="ReloadPage();" style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size: 12px;width: 600px;">
          <option value="0">N/A</option>
          <%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where IS_DEL=0 "+
WI.getStrValue(WI.fillTextValue("starts_with")," and sub_code like '","%'","")+ " order by sub_code asc",strTemp, false)%> </select></td>
      <%
strErrMsg = null;
if(strTemp == null || strTemp.compareTo("selany") ==0)
	strTemp = "";
else
	vRetResult = CM.getSubjectInfo(dbOP,strTemp); 
if(vRetResult == null)
	strErrMsg = CM.getErrMsg();

if(vRetResult != null && vRetResult.size() > 0)
{%>
      <td > <%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strErrMsg = (String)vEditInfo.elementAt(5);
else {
	strErrMsg = WI.fillTextValue("unit");
	if(vRetResult.size() > 3 && ((String)vRetResult.elementAt(3)).length() > 0) 
		strTemp = (String)vRetResult.elementAt(3);//get if already created

}
%> <input name="unit" type="text" size="5" value="<%=strErrMsg%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('cmaintenance','unit');style.backgroundColor='white'"
	   onKeyUp="AllowOnlyFloat('cmaintenance','unit')"></td>
    </tr>
    <%}if(vRetResult != null && vRetResult.size() > 0)
{%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="3" ><strong><font size="1">SUBJECT GROUP&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></strong> 
        <select name="group_name">
          <%
if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("reloadPage").compareTo("0") == 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else {	

	if(strTemp.length() > 0 && strTemp.compareTo("0") != 0 && strTemp.compareTo("selany") != 0)
		strTemp = dbOP.mapOneToOther("SUBJECT","sub_index",strTemp,"GROUP_INDEX",null);
	else	
		strTemp = "";
}%>
          <%=dbOP.loadCombo("group_index","group_name"," from subject_group where IS_DEL=0 order by group_name asc", strTemp, false)%> </select> </td>
    </tr>
    <%}//show only main subject is selected.
if(vRetResult != null && vRetResult.size() > 0 ){
if(iAccessLevel > 1){%>
    <tr> 
      <td height="53" >&nbsp;</td>
      <td  height="53" colspan="3" ><div align="center"><font size="1"> 
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          Click to save entries 
          <%}else{%>
          <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
          Click to edit event 
          <%}%>
          <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
          Click to clear entries </font></div></td>
    </tr>
    <%	}//show save only if iAccessLevel > 1
}//end of if(WI.fillTextValue("req_only").compareTo("1") == 0 || (vRetResult != null && vRetResult.size() > 0) )
%>
  </table>

<%}//if(WI.fillTextValue("cy_from").length()  >0 && WI.fillTextValue("cy_to").length() >0)


//print curriculum information created.
if(vCurInfo != null && vCurInfo.size() > 0) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFFFCC">
      <td height="25" colspan="6" class="thinborderLEFT"><div align="center"><strong>CURRICULUM CREATED 
          FOR CY (<%=WI.fillTextValue("cy_from")%> - <%=WI.fillTextValue("cy_to")%>) </strong></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="12%" height="25" class="thinborder"><div align="center"><font size="1"><strong>SUB 
          CODE</strong></font></div></td>
      <td width="30%" class="thinborder" align="center"><font size="1"><strong>SUB NAME</strong></font></td>
      <td width="15%" class="thinborder" align="center"><font size="1"><strong>SUB GROUP</strong></font></td>
      <td width="5%" class="thinborder" align="center"><font size="1"><strong>UNIT</strong></font></td>
      <td width="15%" class="thinborder" align="center"><font size="1"><strong>REQUIREMENT 
        ::: REQ UNITS</strong></font></td>
      <td width="8%" class="thinborder" align="center"><font size="1"><strong>DISPLAY ORDER</strong></font></td>
      <%if(!bolIsLocked){%><td width="15%" class="thinborder" align="center"><font size="1"><strong>EDIT/ 
        DELETE</strong></font></td><%}else{%>
      <td width="15%" class="thinborder" align="center">&nbsp;</td><%}%>
    </tr>
    <%
for(int i = 0; i < vCurInfo.size(); i += 15){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vCurInfo.elementAt(i + 11))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vCurInfo.elementAt(i + 12))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vCurInfo.elementAt(i + 13))%></td>
      <td class="thinborder">&nbsp;<%=(String)vCurInfo.elementAt(i + 5)%></td>
      <td class="thinborder">&nbsp;<%=(String)vCurInfo.elementAt(i + 10)%> ::: <%=(String)vCurInfo.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vCurInfo.elementAt(i + 8)%></td>
      <%if(!bolIsLocked){%><td class="thinborder"><font size="1">&nbsp; 
        <%
if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vCurInfo.elementAt(i + 14)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}if(iAccessLevel == 2){%>
        <a href='javascript:PageAction("0","<%=(String)vCurInfo.elementAt(i + 14)%>");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}%>
        </font></td><%}else{%>
    <td width="15%" class="thinborder" align="center"><font color="#0000FF">Locked</font></td><%}%>
    </tr>
    <%}//end of for loop.%>
  </table>

<%}%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="change_course_index"><!-- only when course index is changed. -->

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%dbOP.cleanUP();%>
