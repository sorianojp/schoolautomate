<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value =strAction;
	if(strAction == 1)
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "-1";
	document.form_.submit();
}
function CancelRecord(){
	location = "./grad_mgt.jsp";
}

function FocusID() {
	document.form_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CloseWindow()
{
	eval("window.opener.document."+document.form_.parent_wnd.value+".submit()");
	window.opener.focus();
	self.close();
}

function ClearAll(){
	document.hide_save.src = "../../../images/blank.gif";
	document.form_.fname.value = "";
	document.form_.mname.value = "";
	document.form_.lname.value = "";
	document.form_.submit();
}

///ajax here to load major..
function loadMajor() {
		var objCOA=document.getElementById("load_major");
		
		var objCourseInput = document.form_.course_index[document.form_.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=104&course_ref="+objCourseInput;
		this.processRequest(strURL);
}
function PreparedToEdit(strInfoIndex) {
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.submit();
}
function DeleteInfo(strInfoIndex) {
	if(!confirm("Are you sure you want to remove the grad. data?"))
		return;
	document.form_.page_action.value = '0';
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
//end of ajax to finish loading.. 
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolShowEditInfo = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_mgt.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_mgt.jsp");
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

int iPageAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"-1"));
if(iPageAction == 0 && WI.fillTextValue("info_index").length() > 0) {
	iPageAction = -1;
	dbOP.executeUpdateWithTrans("delete from GRADUATION_DATA where GRAD_DATA_INDEX = "+WI.fillTextValue("info_index"),null, null, false);
}

//end of authenticaion code.
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
Vector vRetResult  = null;
//String strGender = null;
Vector vStudInfo   = null;

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size()==0){
		strErrMsg = offlineAdm.getErrMsg();
	}else{
		strTemp2 = "readonly=\"yes\"";
	}
}

String strInfoIndex = WI.fillTextValue("info_index");

EntranceNGraduationData egd = new EntranceNGraduationData();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (iPageAction == 1 || iPageAction == 2){
	vRetResult = egd.operateOnGraduationData(dbOP,request,iPageAction);
	if (vRetResult == null){
		strErrMsg = egd.getErrMsg();
	}else if (iPageAction == 1)
		strErrMsg = " Graduation Data recorded successfully";
	else if (iPageAction == 2) {
		strErrMsg = " Graduation Data edited successfully";
		strPrepareToEdit = "";
	}
}

if (strPrepareToEdit.length() > 0){
	vRetResult = egd.operateOnGraduationData(dbOP,request,3);

	if (vRetResult == null || vRetResult.size()==0){
		strErrMsg = egd.getErrMsg();
		strPrepareToEdit = "";
	}else
		bolShowEditInfo = true;
}

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
%>
<form name="form_" action="./grad_mgt.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
        GRADUATION DATA PAGE ::::</strong></font></div></td>
  </tr>
  <tr> 
    <td width="3%" height="25" >&nbsp;</td>
    <td height="25" colspan="4" ><font size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
  </tr>
  <tr> 
    <td width="3%" height="25" >&nbsp;</td>
    <td width="14%" height="25" >Student ID :</td>
    <td width="24%" >
<%
	if (bolShowEditInfo && strPrepareToEdit.length() > 0)
		strTemp = WI.getStrValue((String)vRetResult.elementAt(3),"");
	else
		strTemp = WI.fillTextValue("stud_id");
%>

	 <input name="stud_id" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white';"
		value="<%=strTemp%>"  onChange="ClearAll()">	</td>
    <td width="7%" >&nbsp; <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    <td width="52%" ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
  </tr>
<%
if(vStudInfo != null && vStudInfo.size() > 0) {
String strSQLQuery = "select GRAD_DATA_INDEX,Course_offered.course_code,major.course_code,GRAD_YEAR,GRAD_MONTH,SEMESTER from graduation_data "+
						"join course_offered on (course_offered.course_index = graduation_data.course_index) "+
						"left join major on (major.major_index = graduation_data.major_index) "+
						"where stud_index = "+(String)vStudInfo.elementAt(12)+" and graduation_data.is_valid =1 order by grad_year,grad_month";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);

String[] astrConvertMonth = {"","January","February","March","April","May","June","July","August","September","October","November","December"};
String[] astrConvertTerm  = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","&nbsp;"};
%>  <tr>
    <td height="25" >&nbsp;</td>
    <td height="25" colspan="4" >
		<table width="60%" class="thinborder" cellspacing="0" cellpadding="0" bgcolor="#AADDFF">
		<%boolean bolIsGraduated = false;
		while(rs.next()){bolIsGraduated = true;%>
			<tr>
				<td class="thinborder" height="20"><%=rs.getString(2)%><%=WI.getStrValue(rs.getString(3),"/","","")%></td>
				<td class="thinborder"><%=astrConvertMonth[Integer.parseInt(rs.getString(5))]%>, <%=rs.getString(4)%></td>
				<td class="thinborder"><%=astrConvertTerm[Integer.parseInt(WI.getStrValue(rs.getString(6),"5"))]%></td>
			    <td class="thinborder"><a href="javascript:DeleteInfo('<%=rs.getString(1)%>');">Delete</a></td>
			    <td class="thinborder"><a href="javascript:PreparedToEdit('<%=rs.getString(1)%>');">Edit</a></td>
			</tr>
		<%}if(bolIsGraduated){%>
			
		<%}%>
		</table>
	</td>
    </tr>
<%
rs.close();
}%>
  <tr> 
    <td colspan="5" height="25" ><hr size="1"></td>
  </tr>
</table>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <% if(vStudInfo == null && WI.fillTextValue("stud_id").length() > 0) {%>
    <tr> 
      <td height="18" >&nbsp;</td>
      <td height="18" colspan="4" ><input name="new_record" type="checkbox" id="new_record" value="1"> 
        <font color="#0000FF" size="1">Click to add ID number into the system</font></td>
    </tr>
    <%}%>
    <tr> 
      <td width="2%" height="18" >&nbsp;</td>
      <td width="21%" height="18" ><font size="1"><strong>FIRST NAME: </strong></font></td>
      <td width="23%" height="18" ><font size="1"><strong>MIDDLE NAME: </strong></font></td>
      <td width="26%" ><font size="1"><strong>LAST NAME: </strong></font></td>
      <td width="28%" height="18" ><font size="1"><strong>GENDER:</strong></font></td>
    </tr>
    <tr> 
      <td height="24" >&nbsp;</td>
      <td height="24" > 
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(0);
else if(vStudInfo != null && vStudInfo.size() > 0) 
	strTemp = (String)vStudInfo.elementAt(0);
else	
	strTemp = WI.fillTextValue("fname");
%>
	    <input name="fname" type="text" size="16" class="textbox"  value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strTemp2%>>
      </td>
      <td height="24" > 
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(1);
else if(vStudInfo != null && vStudInfo.size() > 0) 
	strTemp = (String)vStudInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("mname");
%>
        <input name="mname" type="text" size="16" class="textbox"  value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strTemp2%>>
      </td>
      <td >
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(2);
else if(vStudInfo != null && vStudInfo.size() > 0) 
	strTemp = (String)vStudInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("lname");
%>
        <input name="lname" type="text" size="16" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strTemp2%>>
      </td>
<%
if(vRetResult != null && vRetResult.size() > 0) 
	strTemp = (String)vRetResult.elementAt(12);
else if(vStudInfo != null && vStudInfo.size() > 0) 
	strTemp = (String)vStudInfo.elementAt(16);
else	
	strTemp = WI.fillTextValue("gender");
%>
      <td height="24" ><select name="gender">
	    <option value="0"> Male</option>
<% if (strTemp.equals("1") || strTemp.equals("F")) { %>
    <option value="1" selected> Female</option>
<%}else{%>	
    <option value="1"> Female</option>
<%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="20" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25" >&nbsp;</td>
      <td width="8%" height="25" ><strong><font size="1">COURSE : </font></strong></td>
      <td width="88%" height="25" >
<% 	
	  strErrMsg = WI.fillTextValue("major_index");
	if(vRetResult != null && vRetResult.size() > 0) {
		strTemp   = (String)vRetResult.elementAt(4);
		strErrMsg = (String)vRetResult.elementAt(5);
	}
	else if(vStudInfo != null && vStudInfo.size() > 0) {
		strTemp   = (String)vStudInfo.elementAt(5);
		strErrMsg = (String)vStudInfo.elementAt(6);
	}
	else	
		strTemp = WI.fillTextValue("course_index");
	  
%> <select name="course_index" onChange="loadMajor();">
          <option value="">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND (IS_VALID=1 or IS_VALID=2) order by course_name asc",	strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" ><strong><font size="1">MAJOR : </font></strong></td>
      <td height="25" > 
<label id="load_major">
	<select name="major_index" >
    <%if(strTemp != null && strTemp.length() > 0){%>
	      <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index = " + strTemp + " order by major_name	 asc",	strErrMsg, false)%> 
	<%}%>
	</select> 
</label>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" height="25" ><hr size="1"></td>
    </tr>
    <tr> 
      <td width="4%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" ><u><strong>Graduation Data</strong></u></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="31%" height="25" >CHED Special Order No.</td>
      <td width="63%" height="25" > <%
	if (bolShowEditInfo && strPrepareToEdit.length()>0)
		strTemp =  WI.getStrValue((String)vRetResult.elementAt(6),"");
	else
		strTemp = WI.fillTextValue("ched_special_no");
%> <input name="ched_special_no" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Date Issued</td>
      <td height="25" > <%	if (bolShowEditInfo && strPrepareToEdit.length()>0)
		strTemp =  (String)vRetResult.elementAt(7);
	else
	strTemp = WI.fillTextValue("csn_issue_date");
%> <input name="csn_issue_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.csn_issue_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Date of Graduation (optional) </td>
      <td height="25" > <%	if (bolShowEditInfo && strPrepareToEdit.length()>0)
		strTemp =  (String)vRetResult.elementAt(8);
	else
	strTemp = WI.fillTextValue("grad_date");
%> <input name="grad_date" type="text" class="textbox" id="grad_date"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.grad_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Date of Graduation (MM - YYYY)</td>
      <td height="25" > 
	  <% 	if (bolShowEditInfo && strPrepareToEdit.length()>0)
	strTemp = WI.getStrValue((String)vRetResult.elementAt(10),"");
	else
	strTemp = WI.fillTextValue("grad_month"); %> <input name="grad_month" type="text" class="textbox" id="grad_month"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="2" maxlength="2">
        - 
<%	if (bolShowEditInfo && strPrepareToEdit.length()>0)
	strTemp = WI.getStrValue((String)vRetResult.elementAt(9),"");
	else
	strTemp = WI.fillTextValue("grad_yr");
%> <input name="grad_yr" type="text" class="textbox" id="grad_yr"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" >Semester</td>
<%
	if (bolShowEditInfo && strPrepareToEdit.length()>0)
		strTemp = WI.getStrValue((String)vRetResult.elementAt(11),"");
	else
		strTemp = WI.fillTextValue("semester");
%>
      <td height="25" ><select name="semester" id="semester">
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
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td><div align="center"><font size="1"> 
          <% if (iAccessLevel > 1){
		  	if (strPrepareToEdit.compareTo("1") !=0) {
		  %>
          <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          click to save entries</font>
		  <%}else{ %>
          <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif"  border="0" name="hide_save"></a> 
          <font size="1">click to save entries</font></font> <a href="javascript:CancelRecord()"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
          to clear entries </font> 
          <%}}%></div></td>
      <td width="17%">&nbsp;</td>
    </tr>
  </table>
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
<input type="hidden"  name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
