<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_ed_.page_action.value =strAction;
	if(strAction == 1)
		document.form_ed_.hide_save.src = "../../../images/blank.gif";
	document.form_ed_.submit();
}
function ReloadPage() {
	document.form_ed_.page_action.value = "";
	document.form_ed_.submit();
}
function CancelRecord(strEmpID){
	location = "./entrance_data.jsp";
}

function FocusID() {
	document.form_ed_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_ed_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateSchoolList()
{
	//pop up here.
	var pgLoc = "../../registrar/sub_creditation/schools_accredited.jsp?parent_wnd=form_ed_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CloseWindow()
{
	eval("window.opener.document."+document.form_ed_.parent_wnd.value+".submit()");
	window.opener.focus();
	self.close();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	Vector vStudInfo = null;
	boolean bolShowEditInfo = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-ENTRANCE DATA","entrance_data.jsp");
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
														"Registrar Management","ENTRANCE DATA",request.getRemoteAddr(),
														"entrance_data.jsp");
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
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
EntranceNGraduationData entranceData = new EntranceNGraduationData();
Vector vRetResult = null;

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	int iAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_action"),"4"));//default = 4, view all.
	vRetResult = entranceData.operateOnEntranceData(dbOP, request,iAction);
	if(vRetResult == null || vRetResult.size() ==0) {
		vRetResult = entranceData.operateOnEntranceData(dbOP, request,4);
		strErrMsg = entranceData.getErrMsg();
	}
	else {
		if(iAction == 1) {
			strErrMsg = "Entrance Data saved successfully.";
		}
		else if(iAction == 2) {
			strErrMsg = "Entrance Data information changed successfully.";
		}
	}
}

strTemp = WI.getStrValue(WI.fillTextValue("new_id_entered"),"0");

if(vRetResult != null && vRetResult.size() > 0 && strTemp.compareTo(WI.fillTextValue("stud_id")) != 0)
	bolShowEditInfo = true;

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};

//if entrance data is not found. get information from GSPIS
Vector vTemp = null;
if( vStudInfo != null && vStudInfo.size() > 0 && (vRetResult == null || vRetResult.size() == 0) )
	vTemp = entranceData.getEduFrGSPIS(dbOP, (String)vStudInfo.elementAt(12));

%>

<form name="form_ed_" action="./entrance_data.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          ENTRANCE DATA PAGE ::::</strong></font></div></td>
    </tr>
<%
if(WI.fillTextValue("parent_wnd").length() > 0){%>
   <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a>
        <font size="1"><strong>Click to close window</strong></font></td>
    </tr>
<%}%>
    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td width="15%" height="25" >Student ID :</td>
      <td width="20%" > <input name="stud_id" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=WI.fillTextValue("stud_id")%>"></td>
      <td width="7%" >&nbsp; <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="54%" ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td colspan="5" height="25" ><hr size="1"></td>
    </tr>
    <% if(vStudInfo != null && vStudInfo.size() > 0){//outer loops%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" >Student name : <strong> 
	  <%=WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),
	  	(String)vStudInfo.elementAt(2),5)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="4" height="25" >Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="4" height="25" >Course /Major: <strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	  if(vStudInfo.elementAt(8) != null){%>
        / <%=WI.getStrValue(vStudInfo.elementAt(8))%>
        <%}%>
        </strong></td>
    </tr>
    <tr>
      <td colspan="5" height="25" ><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><u><strong>Educational Data</strong></u></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="11%" height="25" >Elementary</td>
      <td width="83%" height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" ><select name="elem_sch_index">
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(2);
else
	strTemp = WI.fillTextValue("elem_sch_index");
if(request.getParameter("elem_sch_index") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(1) != null)
	strTemp = (String)vTemp.elementAt(1);

%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Secondary</td>
      <td height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" ><select name="sec_sch_index">
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(4);
else
	strTemp = WI.fillTextValue("sec_sch_index");
if(request.getParameter("sec_sch_index") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(3) != null)
	strTemp = (String)vTemp.elementAt(3);
%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >College</td>
      <td height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" ><select name="college_index">
          <option value="">N/A</option>
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(6);
else
	strTemp = WI.fillTextValue("college_index");
if(request.getParameter("college_index") == null && vTemp != null && vTemp.size() > 0 && vTemp.elementAt(5) != null)
	strTemp = (String)vTemp.elementAt(5);
%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> 
        </select></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><u><strong>Entrance Data</strong></u></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Admission Date</td>
      <td >
<%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(23);
else
	strTemp = WI.fillTextValue("admission_date");
%>
	  <input name="admission_date" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="32" maxlength="32"></td>
    </tr>
    <tr> 
      <td width="4%" height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="11%" height="25" >Document </td>
      <td width="83%" > <select name="doc_type" onChange="ReloadPage();">
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(8);
else
	strTemp = WI.fillTextValue("doc_type");
%>
          <option value="0">Form 137-A</option>
          <%
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Transcript of Record</option>
          <%}else{%>
          <option value="1">Transcript of Record</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>C.E.A No.</option>
          <%}else{%>
          <option value="2">C.E.A No.</option>
          <%}%>
        </select> </td>
    </tr>
<% if(strTemp.compareTo("2") ==0) {//CEA NO, show all below  %>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" valign="middle" >&nbsp;</td>
      <td height="25" >C.E.A. No.</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(9);
else
	strTemp = WI.fillTextValue("cea_no");
%> <input name="cea_no" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=strTemp%>" size="24"> <font size="1">&nbsp;

        </font></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" valign="middle" >&nbsp;</td>
      <td height="25" >C.E.A. No. Date</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(10);
else
	strTemp = WI.fillTextValue("cea_no");
%> <input name="cea_issue_date" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=strTemp%>" size="32"> <font size="1">&nbsp; 
        </font></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" valign="middle" >&nbsp;</td>
      <td height="25" >Pre-Med. Course</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(11);
else
	strTemp = WI.fillTextValue("pre_med_course");
%> <input name="pre_med_course" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=strTemp%>" size="50"> <font size="1">&nbsp; 
        </font></td>
    </tr>
    <%}//only if C.E.A document type is selected.
%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" valign="middle" >&nbsp; </td>
      <td height="25" > Remarks :</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(12);
else
	strTemp = WI.fillTextValue("remarks");
%> <textarea name="remarks" cols="50" rows="2" class="textbox" onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
        <br>
        (Only for the latest course graduated Entrance Data Remarks)</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>FORM 
        17 DATA</strong></font></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" ><strong>SCHOOL</strong></td>
      <td height="25" colspan="2" ><div align="center"><strong>YEAR RANGE</strong></div></td>
      <td width="58%" ><strong>SCHOOL NAME</strong></td>
    </tr>
    <tr> 
      <td width="4%" height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="11%" height="25" >Primary</td>
      <td width="12%" height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(17);
else
	strTemp = WI.fillTextValue("primary_sy_from");
%> <input name="primary_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td width="13%" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(18);
else
	strTemp = WI.fillTextValue("primary_sy_to");
%> <input name="primary_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><select name="primary_sch_index">
          <option value="">N/A</option>
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(13);
else
	strTemp = WI.fillTextValue("primary_sch_index");
%>
          <%//=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_CODE+'('+SUBSTRING(SCH_NAME,1,4)+' ...)'"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_CODE",strTemp,false)%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Intermediate</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(19);
else
	strTemp = WI.fillTextValue("int_sy_from");
%> <input name="int_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(20);
else
	strTemp = WI.fillTextValue("int_sy_to");
%> <input name="int_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25" > <a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="4" ><select name="int_sch_index">
          <option value="">N/A</option>
          <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(15);
else
	strTemp = WI.fillTextValue("int_sch_index");
%>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Secondary</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(21);
else
	strTemp = WI.fillTextValue("sec_sy_from");
%> <input name="sec_sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vRetResult.elementAt(22);
else
	strTemp = WI.fillTextValue("sec_sy_to");
%> <input name="sec_sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td height="25" >&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td><div align="center"><font size="1">
          <% if (iAccessLevel > 1){
	if(vRetResult == null || vRetResult.size() == 0) {%>
          <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
          click to save entries
          <%}else{%>
          <a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a>
		  click to cancel and clear entries
		  <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif" border="0"></a>
          click to save changes
          <%}
		}%></font>
        </div></td>
      <td width="17%">&nbsp;</td>
    </tr>
  </table>
<%}//end if vStudInfo is not null%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="new_id_entered" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="parent_wnd" value="<%=WI.fillTextValue("parent_wnd")%>">
  </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
