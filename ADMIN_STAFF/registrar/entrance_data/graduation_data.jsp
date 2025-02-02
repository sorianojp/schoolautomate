<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == 0) {
		if(!confirm('Are you sure you want to delete this entry.'))
			return;
	}
	document.form_gd_.info_index.value = strInfoIndex;
	
	document.form_gd_.page_action.value =strAction;
	if(strAction == 1)
		document.form_gd_.hide_save.src = "../../../images/blank.gif";
	document.form_gd_.submit();
}
function PreparedToEdit(strInfoIndex) {
	document.form_gd_.page_action.value = '';
	document.form_gd_.preparedToEdit.value = '1';
	document.form_gd_.info_index.value = strInfoIndex;
	document.form_gd_.submit();
}
function ReloadPage() {
	document.form_gd_.page_action.value = "";
	document.form_gd_.preparedToEdit.value = "";
	document.form_gd_.submit();
}
function CancelRecord(strEmpID){
	location = "./graduation_data.jsp?stud_id="+document.form_gd_.stud_id.value+"&parent_wnd="+document.form_gd_.parent_wnd.value;
}

function FocusID() {
	document.form_gd_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_gd_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CloseWindow()
{
	eval("window.opener.document."+document.form_gd_.parent_wnd.value+".submit()");
	window.opener.focus();
	self.close();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	document.form_gd_.page_action.value = "";	
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_gd_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

///ajax here to load major..
function loadMajor() {
		var objCOA=document.getElementById("load_major");
 		var objCourseInput = document.form_gd_.course_index[document.form_gd_.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=104&course_ref="+objCourseInput+"&sel_name=major_index";
		//alert(strURL);
		this.processRequest(strURL);
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_gd_.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_gd_.stud_id.value = strID;
	document.form_gd_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_gd_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
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
								"Admin/staff-Registrar Management-ENTRANCE DATA","graduation_data.jsp");
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
														"graduation_data.jsp");
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

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
Vector vEditInfo = null;

//end of authenticaion code.
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
EntranceNGraduationData graduationData = new EntranceNGraduationData();
Vector vRetResult = null;
int iAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_action"),"4"));//default = 4, view all.

if(iAction == 0 && WI.fillTextValue("info_index").length() > 0) {
	dbOP.executeUpdateWithTrans("delete from GRADUATION_DATA where grad_data_index="+WI.fillTextValue("info_index"),
              (String)request.getSession(false). getAttribute("login_log_index"),"GRADUATION_DATA ", true);
	strErrMsg = "Graduation data removed successfully.";
	iAction = 4;
}

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
}

if(vStudInfo != null && vStudInfo.size() > 0 && iAction != 4) {
	if(graduationData.operateOnGraduationData(dbOP, request,iAction) == null)
		strErrMsg = graduationData.getErrMsg();
	else {
		if(iAction == 1)
			strErrMsg = "Graduation Data saved successfully.";
		else if(iAction == 2)
			strErrMsg = "Graduation Data information changed successfully.";
		strPreparedToEdit = "0";
	}
}
	vRetResult = graduationData.operateOnGraduationData(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = graduationData.getErrMsg();

	if(strPreparedToEdit.equals("1")) {
		vEditInfo = graduationData.operateOnGraduationData(dbOP, request, 3);
		if(vEditInfo == null) 
			strErrMsg = graduationData.getErrMsg();
	}


strTemp = WI.getStrValue(WI.fillTextValue("new_id_entered"),"0");

//if(vRetResult != null && vRetResult.size() > 0 && strTemp.compareTo(WI.fillTextValue("stud_id")) != 0)
if(vEditInfo != null && vEditInfo.size() > 0) 
	bolShowEditInfo = true;

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
%>

<form name="form_gd_" action="./graduation_data.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="6" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          GRADUATION DATA PAGE ::::</strong></font></div></td>
    </tr>
<%
if(WI.fillTextValue("parent_wnd").length() > 0){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="5" ><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a>
        <font size="1"><strong>Click to close window</strong></font></td>
    </tr>
<%}%>    <tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="5" ><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr valign="top">
      <td width="4%" height="25" >&nbsp;</td>
      <td width="15%" height="25" >Student ID :</td>
      <td width="20%" > <input name="stud_id" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.fillTextValue("stud_id")%>" onKeyUp="AjaxMapName('1');"></td>
      <td width="7%" >&nbsp; <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="10%" ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="44%" ><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td colspan="6" ><hr size="1"></td>
    </tr>
    <% if(vStudInfo != null && vStudInfo.size() > 0){//outer loops%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="5" >Student name : <strong> <%=WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),
	  	(String)vStudInfo.elementAt(2),4)%> 
		<input type="hidden" name="fname" value="<%=(String)vStudInfo.elementAt(0)%>">
		<input type="hidden" name="mname" value="<%=(String)vStudInfo.elementAt(1)%>">
		<input type="hidden" name="lname" value="<%=(String)vStudInfo.elementAt(2)%>">
		<%if(vStudInfo.elementAt(16) == null || ((String)vStudInfo.elementAt(16)).compareTo("M") == 0) {%>
		<input type="hidden" name="gender" value="0">
		<%}else{%>
		<input type="hidden" name="gender" value="1">
		<%}%>
		</strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="5" height="25" >Current Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="5" height="25" >Current Course /Major: <strong><%=(String)vStudInfo.elementAt(7)%>
        <%
		  if(vStudInfo.elementAt(8) != null){%>
        / <%=WI.getStrValue(vStudInfo.elementAt(8))%>
        <%}%>

        </strong></td>
    </tr>
    <tr>
      <td colspan="6" ><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3" >
<%
	if(bolShowEditInfo)
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(15));
	else
		strTemp = WI.fillTextValue("gwa");
		
	float fGWA = 0f;
	student.GWA gwa = new student.GWA();
	fGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));	

	if (strTemp.length() == 0 && fGWA > 1f)
		strTemp = CommonUtil.formatFloat((double)fGWA,true);
%>
	  GWA : 
      <input name="gwa" type="text" size="5" maxlength="5" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><u><strong>Graduation Data</strong></u></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Graduating Course </td>
      <td height="25" >
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else {
	strTemp = WI.fillTextValue("course_index");
	if(strTemp.length() == 0 && vStudInfo != null) 
		strTemp = (String)vStudInfo.elementAt(5);
}
%>
	  <select name="course_index" onChange="loadMajor();">
          <%=dbOP.loadCombo("course_index","course_code + ' ::: ' + course_name"," from course_offered where is_valid = 1 order by course_code ",strTemp, false)%> 
        </select>
	 </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Graduating Major </td>
      <td height="25" >
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(5);
else {
	strTemp = WI.fillTextValue("major_index");
	if(strTemp.length() == 0 && vStudInfo != null) 
		strTemp = (String)vStudInfo.elementAt(6);
}
%>
	  <label id="load_major">
	  <select name="major_index">
          <%=dbOP.loadCombo("major_index","major_name"," from major where course_index="+WI.getStrValue(strTemp, "-1")+" order by major_name",strTemp, false)%> 
        </select>
	  </label>
	  </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="22%" height="25" >CHED Special Order No.</td>
      <td width="72%" height="25" > <%
if(bolShowEditInfo)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
else
	strTemp = WI.fillTextValue("ched_special_no");
%> <input name="ched_special_no" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Date Issued</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(7));
else
	strTemp = WI.fillTextValue("csn_issue_date");
%> <input name="csn_issue_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_gd_.csn_issue_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Date of Graduation</td>
      <td height="25" >
        <%
if(bolShowEditInfo)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(8));
else
	strTemp = WI.fillTextValue("grad_date");
%>
        <input name="grad_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_gd_.grad_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
	
	<tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Date of Graduation (MM - YYYY)</td>
      <td height="25" > 
	  <% 	if (bolShowEditInfo)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(10),"");
	else
	strTemp = WI.fillTextValue("grad_month"); %> <input name="grad_month" type="text" class="textbox" id="grad_month"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="2" maxlength="2">
        - 
<%	if (bolShowEditInfo)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(9),"");
	else
	strTemp = WI.fillTextValue("grad_yr");
%> <input name="grad_yr" type="text" class="textbox" id="grad_yr"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"></td>
    </tr>
	
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Date of Dismissal</td>
      <td height="25" >
        <%
if(bolShowEditInfo)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(14));
else
	strTemp = WI.fillTextValue("date_dismissal");
%>
        <input name="date_dismissal" type="text" size="10" maxlength="10" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyIntegerExtn('form_gd_','date_dismissal','/');style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_gd_','date_dismissal','/')">
        <a href="javascript:show_calendar('form_gd_.date_dismissal');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >SEMESTER</td>
      <td height="25" > <%
if(bolShowEditInfo)
	strTemp = (String)vEditInfo.elementAt(11);
else
	strTemp = WI.fillTextValue("semester");
if(strTemp == null)
	strTemp = "";
%> <select name="semester" >
          <% if (strTemp.compareTo("0") == 0){%>
          <option  value="0" selected>Summer</option>
          <%}else {%>
          <option value="0">Summer</option>
          <%}if (strTemp.compareTo("1") == 0) {%>
          <option  value="1" selected>1st</option>
          <%}else {%>
          <option value="1">1st</option>
          <%}if (strTemp.compareTo("2") == 0) {%>
          <option  value="2" selected>2nd</option>
          <%}else {%>
          <option value="2">2nd</option>
          <%}if (strTemp.compareTo("3") == 0) {%>
          <option  value="3" selected>3rd</option>
          <%}else {%>
          <option value="3">3rd</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Academic Scholar Info </td>
      <td height="25" >
<%
if(bolShowEditInfo)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(19));
else
	strTemp = WI.fillTextValue("scholar_index");
%>
	  <select name="scholar_index" style="font-size:10px" >
        <option value=""></option>
<%=dbOP.loadCombo("SCHOLAR_INDEX","SCHOLAR_NAME"," from SCHOLAR_REF order by SCHOLAR_NAME", strTemp, false)%>
        </select>
		<a href='javascript:viewList("SCHOLAR_REF","SCHOLAR_INDEX","SCHOLAR_NAME","Scholar_Name",
				"GRADUATION_DATA","SCHOLAR_INDEX"," and GRADUATION_DATA.is_valid = 1","","scholar_index")'><img border="0" src="../../../images/update.gif"></a>	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td><div align="center"><font size="1">
<%if (iAccessLevel > 1){
	if(strPreparedToEdit.equals("0")) {%>
          <a href="javascript:PageAction(1,'');"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
          click to save entries
    <%}else{%>
          <a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a>
		  click to cancel and clear entries
		  <a href="javascript:PageAction(2,'<%=vEditInfo.elementAt(13)%>');"><img src="../../../images/edit.gif" border="0"></a>
          click to save changes &nbsp;&nbsp;
		  <a href="javascript:PageAction(0,'<%=vEditInfo.elementAt(13)%>');"><img src="../../../images/delete.gif" border="0"></a>
    <%}
}%></font>
        </div></td>
    </tr>
  </table>
<%}//end if vStudInfo is not null%>

<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#CCCCCC">
      <td height="25" colspan="11" align="center" class="thinborder" style="font-weight:bold"> ::: Graduation Data history ::: </td>
    </tr>
    <tr bgcolor="#FFFFCC">
      <td height="25" align="center" class="thinborder" style="font-weight:bold" width="15%">Course</td>
      <td align="center" style="font-weight:bold" class="thinborder" width="15%">Major</td>
      <td align="center" style="font-weight:bold" class="thinborder" width="5%">GWA</td>
      <td align="center" style="font-weight:bold" class="thinborder" width="10%">SO Number </td>
      <td align="center" style="font-weight:bold" class="thinborder" width="10%">Date Issued </td>
      <td align="center" style="font-weight:bold" class="thinborder" width="10%">Graduation Date </td>
      <td align="center" style="font-weight:bold" class="thinborder" width="10%">Dismissal Date </td>
      <td align="center" style="font-weight:bold" class="thinborder" width="5%">Semester</td>
      <td align="center" style="font-weight:bold" class="thinborder" width="10%">Acad Scholar </td>
      <td align="center" style="font-weight:bold" class="thinborder" width="7%">Edit</td>
      <td align="center" style="font-weight:bold" class="thinborder" width="8%">Delete</td>
    </tr>
    <%
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","","",""};
	for(int i = 0; i < vRetResult.size(); i += 20) {%>
	<tr bgcolor="#FFFFDD">
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 18)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 19), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 15), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 7), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 14), "&nbsp;")%></td>
      <td class="thinborder"><%=astrConvertTerm[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i + 11),"6"))]%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 16), "&nbsp;")%></td>
      <td align="center" class="thinborder"><input type="submit" name="_" value="Edit" onClick="document.form_gd_.page_action.value='';document.form_gd_.info_index.value='<%=vRetResult.elementAt(i + 13)%>';document.form_gd_.preparedToEdit.value='1'"></td>
      <td align="center" class="thinborder"><input type="submit" name="_2" value="Delete" onClick="document.form_gd_.page_action.value='0';document.form_gd_.info_index.value='<%=vRetResult.elementAt(i + 13)%>';document.form_gd_.preparedToEdit.value=''"></td>
    </tr>
	<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="new_id_entered" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="parent_wnd" value="<%=WI.fillTextValue("parent_wnd")%>">
<input type="hidden" name="info_index">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>
<%//System.out.println(vRetResult);
dbOP.cleanUP();
%>
