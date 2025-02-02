<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../Ajax/ajax.js" type="text/javascript"></script>
<script language="JavaScript" src="../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript">
function ChangeCurYear() {
	var curYrTo = document.offlineRegd.cy_from.selectedIndex;
	curYrTo = eval('document.offlineRegd.cy_to'+curYrTo+'.value');
//	alert(curYrTo);
	document.offlineRegd.cy_to.value = curYrTo;
	this.ReloadPage();
}
function UpdateNationality(table,indexname,colname,labelname){
	var loadPg = "../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
		"&opner_form_name=offlineRegd";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AddRecord()
{
	if(document.offlineRegd.gender &&  document.offlineRegd.gender.selectedIndex == 0) {
		alert("Please select Gender");
		return;
	}
	if(document.offlineRegd.sch_index &&  document.offlineRegd.sch_index.selectedIndex == 0) {
		alert("Please select Previous School Information");
		return;
	}
	
	document.offlineRegd.addRecord.value = "1";
	document.offlineRegd.hide_save.src="../../images/blank.gif";
	document.offlineRegd.submit();
}
function ReloadPage()
{
	document.offlineRegd.reloadPage.value="1";
	document.offlineRegd.submit();
}

function ChangeOfStatus()
{
	document.offlineRegd.pullStudInfo.value= "";
	document.offlineRegd.reloadPage.value="1";
	this.SubmitOnce("offlineRegd");
}

function PullStudInfo()
{
	document.offlineRegd.addRecord.value = "";
	if (document.offlineRegd.old_stud_id) {
		if(document.offlineRegd.old_stud_id.value.length ==0) {
			alert("Please enter student ID.");
			document.offlineRegd.pullStudInfo.value = "";
			return;
		}
		else
		{
			document.offlineRegd.pullStudInfo.value= "1";
			document.offlineRegd.reloadPage.value="1";
		}
	}
	this.SubmitOnce("offlineRegd");
}




function OpenSearch() {
	var win=window.open("../../search/srch_stud.jsp?opner_info=offlineRegd.old_stud_id",
				"PrintWindow",
				'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

	document.offlineRegd.pullStudInfo.value= "1";
	document.offlineRegd.reloadPage.value="1";
}

//default form submit.
function ReloadCourseIndex()
{
	//course index is changed -- so reset all dynamic fields.
	if(document.offlineRegd.cy_from.selectedIndex > -1)
		document.offlineRegd.cy_from[document.offlineRegd.cy_from.selectedIndex].value = "";
	if(document.offlineRegd.major_index.selectedIndex > -1)
		document.offlineRegd.major_index[document.offlineRegd.major_index.selectedIndex].value = "";

	document.offlineRegd.submit();
}
function ClearEntry()
{
	location = "./admission_registration_new_com.jsp?stud_status=New";
}
function UpdateSchoolList()
{
	//pop up here.
	var pgLoc = "../registrar/sub_creditation/schools_accredited.jsp?parent_wnd=offlineRegd";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DisplaySYTo() {
	var strSYFrom = document.offlineRegd.sy_from.value;
	if(strSYFrom.length == 4)
		document.offlineRegd.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.offlineRegd.sy_to.value = "";
}

function viewAdmissionSlip(index){
	var pgLoc = "./entrance_admission_slip.jsp?temp_id="+index;
	var win=window.open(pgLoc,"AdmissionSlip",'width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewCredential(index){
	var pgLoc = "../registrar/admission_requirements/stud_admission_req.jsp?parent_wnd=form_&stud_id="+index;
	var win2=window.open(pgLoc,"AdmissionSlip2",'width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewAdmissionSlip2(index){
	var pgLoc = "./entrance_admission_slip_new_print.jsp?temp_id="+index;
	<%if(strSchCode.startsWith("CIT")){%>
		pgLoc = "./admission_registration_print_new_stud.jsp?temp_id="+index;	
	<%}%>
	var win=window.open(pgLoc,"AdmissionSlip",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function DeleteTempStud(strTempStud,strRemovePmt) {
	if(!confirm("Are you sure you want to permanently remove this student's information."))
		return;
	document.offlineRegd.del_info.value = strTempStud;
	document.offlineRegd.pullStudInfo.value = '';
	document.offlineRegd.submit();
}

var calledRef;
function AjaxMapName(strRef) {
	var strSearchCon = "&search_temp=2";

		calledRef = strRef;
		var strCompleteName;
		if(strRef == "0") {
			strSearchCon = "";

			if(document.offlineRegd.old_stud_id)
				strCompleteName = document.offlineRegd.old_stud_id.value;
			else
				strCompleteName = document.offlineRegd.stud_id.value;
			if(strCompleteName.length <3)
				return;
		}
		else {

			if(!document.offlineRegd.no_auto_disp || document.offlineRegd.no_auto_disp.checked)
				return;
			strCompleteName = document.offlineRegd.lname.value;
			if(strCompleteName.length == 0)
				return;
			if(document.offlineRegd.fname.value.length > 0)
				strCompleteName = strCompleteName+","+document.offlineRegd.fname.value;
		}

		/// this is the point i must check if i should call ajax or not..
		if(this.bolReturnStrEmpty && this.startsWith(this.strPrevEntry,strCompleteName, false) == 0)
			return;
		this.strPrevEntry = strCompleteName;

		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	if(calledRef == "0") {
		if(document.offlineRegd.old_stud_id)
			document.offlineRegd.old_stud_id.value = strID;
		else
			document.offlineRegd.stud_id.value = strID;

		document.getElementById("coa_info").innerHTML = "";
	}
	this.PullStudInfo();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,enrollment.NAApplicationForm,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTempId = null;
	String strTempIdPrev = null;
	String strCourseIndex = null;
	String strMajorIndex = null;
	boolean bolShowStudInfo = false; //when proceed is clicked.
	int i=0; int j=0;
	String strDegreeType = null;
	String[] astrSchYrInfo = null;
	String strSYTo = null; // this is used in


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Registration","admission_registration.jsp");
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
														"Admission","Registration",request.getRemoteAddr(),
														"admission_registration.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
//long lStartTime = new java.util.Date().getTime();

SubjectSection SS = new SubjectSection();
OfflineAdmission offlineAdm = new OfflineAdmission();
boolean bolClearEntry = false; // only if page is successful.
boolean bolAllowPrint = false;
boolean bolSeePrintImg = false;
Vector vStudBasicInfo  = null; boolean boolAllowAdvising = true;
String strStudStatus = WI.fillTextValue("stud_status");
if (strStudStatus.length() == 0) strStudStatus = "New";

Vector vTemp = null;
Vector vecRetResult = new Vector();

if(WI.fillTextValue("del_info").length() > 0 ) {
	enrollment.NAApplicationForm naApplForm = new enrollment.NAApplicationForm();
	if(naApplForm.removeTempStud(dbOP, WI.fillTextValue("del_info"), WI.fillTextValue("remove_payment")))
		strErrMsg = "Temp Student removed successfully.";
	else	
		strErrMsg = naApplForm.getErrMsg();
} 



if(request.getParameter("addRecord") != null && request.getParameter("addRecord").compareTo("1") ==0)
{//addrecord now.
	if(!offlineAdm.createApplicant(dbOP,request))
		strErrMsg = offlineAdm.getErrMsg();
	else
	{
		dbOP.forceAutoCommitToTrue();
		strErrMsg = "Student basic information for enrollment process is created successfully. reference ID = ";
		if(offlineAdm.strNewStudTempID != null)
			strTemp = offlineAdm.strNewStudTempID;//ID is different.
		else
			strTemp = request.getParameter("stud_id");
			
		if(strSchCode.startsWith("CIT")) {
			%>
			<script language="javascript">
			ViewAdmissionSlip2('<%=strTemp%>');
			viewCredential('<%=strTemp%>');
			</script>	
			
		<%
		//response.sendRedirect("../registrar/admission_requirements/stud_admission_req.jsp?parent_wnd=form_&stud_id="+strTemp);
		}
		

		/*Added code starts here May 4,2006 GTI-AL*/
		if(WI.fillTextValue("auto_sched").compareTo("1") == 0){
			if(!offlineAdm.autoScheduling(dbOP,request,strTemp,
			   " Student basic information for enrollment process is created. reference ID = "))
			   strErrMsg = offlineAdm.getErrMsg();
			else
			   bolSeePrintImg = true;
		}
		strTempIdPrev = strTemp;
		/*Added code ends here May 4,2006 GTI-AL*/

		bolAllowPrint = true;
		strErrMsg += strTemp;
		//strTempId = new NAApplicationForm().generateTempID(dbOP, null);
		bolClearEntry = true;
	}
}

if(WI.fillTextValue("pullStudInfo").equals("1"))
{

	vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, request.getParameter("old_stud_id"));
	//System.out.println(" strErrMsg : " + offlineAdm.getErrMsg());

	if(vStudBasicInfo == null)
	{
	 strErrMsg = offlineAdm.getErrMsg();
	 if(strStudStatus.equals("New (HS Grad)"))
	 {
		dbOP.cleanUP();
		%>
		<font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			Please create student information before enrolling student.</font>
		<%
		return;
	  }
	}
	else {//check if allowed to advise
		enrollment.SetParameter sParam = new enrollment.SetParameter();
		boolAllowAdvising = sParam.allowAdvising(dbOP, (String)vStudBasicInfo.elementAt(12), 0d, 
										WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
		if(!boolAllowAdvising)
			strErrMsg = sParam.getErrMsg();
		if(sParam.isStudLockedByDept(dbOP, (String)vStudBasicInfo.elementAt(12), WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), true)) {
			if(strErrMsg != null) 
				strErrMsg += "<br><br>"+sParam.getErrMsg();
			else 
				strErrMsg = sParam.getErrMsg();
			
			boolAllowAdvising = false;
		}
	}
}

astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)
{
	dbOP.cleanUP();
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		School year information not found.</font></p>
		<%
		return;
}
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

if(strDegreeType == null && WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("selany") != 0 && WI.fillTextValue("course_index").compareTo("0") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");


boolean bolIsHSGrad = false;
if(strSchCode.startsWith("CIT")) {
	if(strStudStatus.equals("New (HS Grad)"))
		bolIsHSGrad = true;
}
%>
<form action="./admission_registration_new_com.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          ADMISSION SLIP REGISTRATION::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25" rowspan="2"></td>
      <td width="88%" height="25" rowspan="2"> <strong><font size="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></strong> </td>
      <td width="10%"> <% if (bolAllowPrint) {%> <a href="javascript:viewAdmissionSlip('<%=strTemp%>')"><img src="../../images/update.gif" width="60" height="26" border="0"></a>
        <%}%>
        &nbsp; </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>
		  <%if(!(strTempIdPrev == null || strTempIdPrev.equals("1")) && (bolSeePrintImg || true)){%>
				<a href="javascript:ViewAdmissionSlip2('<%=strTempIdPrev%>');"><img src="../../images/print.gif" width="60" height="26" border="0"></a>
		  <%}%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="45" colspan="4" style="font-size:18px; font-weight:bold">SY-Term: 
        <%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[0];
	  %>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp=" DisplaySYTo('offlineRegd','sy_from','sy_to')" style="font-size:18px; font-weight:bold">
        <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) strTemp = astrSchYrInfo[1];
	  %>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes" style="font-size:18px; font-weight:bold">
      
	  &nbsp;&nbsp;
	  <select name="semester" style="font-size:18px; font-weight:bold">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = astrSchYrInfo[2];
if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}%>
        </select>		</td>
	  </tr>
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="8%" style="font-size:16px; font-weight:bold">Status: </td>
      <td width="25%"><select name="stud_status"  onChange="ChangeOfStatus();" style="font-size:16px; font-weight:bold; width: 190px;">
        <option value="New">New (Freshmen)</option>
        <%
strTemp = WI.fillTextValue("stud_status");
if (strTemp.equals("New (HS Grad)")) {%>
        <option value="New (HS Grad)" selected>New (From HS to College)</option>
<%}else{%>
        <option value="New (HS Grad)">New (From HS to College)</option>
<%}%>
      </select></td>
      <td width="12%" height="25" style="font-size:16px; font-weight:bold">Student ID:</td>
      <td width="53%">
	  <input type="hidden" name="stud_id" value="abcd<%//=//strTempId%>">
	  <% if (!WI.fillTextValue("stud_status").equals("New (HS Grad)")) {%>
		  (temporary will be given after saving information)
	  <%}else{%>
	  	<input type="text" name="old_stud_id" value="<%=WI.fillTextValue("old_stud_id")%>" class="textbox"
 		 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:16px; font-weight:bold" onKeyUp="AjaxMapName('0');">
		 <label id="coa_info"></label>
		<!--<a href="javascript:OpenSearch();"><img src="../../images/search.gif" width="30" height="24" border="0" ></a>
        &nbsp;&nbsp;
		<a href="javascript:PullStudInfo();"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a>-->
	  <%}%>      </td>
    </tr>
    <tr>
      <td height="35">&nbsp;</td>
      <td style="font-size:16px; font-weight:bold">Name:</td>
      <td height="25" colspan="3">
	  
	  		<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td width="33%">
						<%
						if(vStudBasicInfo != null && vStudBasicInfo.size() >0){%>
								<b><font style="font-size:18px; font-weight:bold"><%=(String)vStudBasicInfo.elementAt(2)%></font></b>
						<% if (strStudStatus.equals("New (HS Grad)")) {%>
							<input name="lname" type="hidden" value="<%=(String)vStudBasicInfo.elementAt(2)%>">
							<%}%>
						<%}else {
							if(bolClearEntry)
								strTemp = "";
							else
								strTemp = WI.fillTextValue("lname");
						%>
						<input name="lname" type="text" size="20" value="<%=strTemp%>" class="textbox"
						  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:18px; font-weight:bold">
						<%} // end if else%>				  </td>
					<td width="33%">
						<%if(vStudBasicInfo!= null && vStudBasicInfo.size() >0){%>
								<b><font style="font-size:18px; font-weight:bold"><%=(String)vStudBasicInfo.elementAt(0)%></font></b>
							<% if (strStudStatus.equals("New (HS Grad)")) {%>
							<input name="fname" type="hidden" value="<%=(String)vStudBasicInfo.elementAt(0)%>">
							<%}
						}else {
								if(bolClearEntry)
									strTemp = "";
								else
									strTemp = WI.fillTextValue("fname");
							%>
							<input name="fname" type="text" size="20" value="<%=strTemp%>" class="textbox"
							  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:18px; font-weight:bold">
						<%}%>				  </td>
					<td width="33%">
						<%
							if( vStudBasicInfo!= null && vStudBasicInfo.size() >0){%>
							<b><font style="font-size:18px; font-weight:bold"><%=WI.getStrValue(vStudBasicInfo.elementAt(1))%></font></b>
							<% if (strStudStatus.equals("New (HS Grad)")) {%>
							<input name="mname" type="hidden" value="<%=WI.getStrValue(vStudBasicInfo.elementAt(1))%>">
							<%}
							}else {
								if(bolClearEntry)
									strTemp = "";
								else
									strTemp = WI.fillTextValue("mname");
							%>
							<input name="mname" type="text" size="20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
							  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:18px; font-weight:bold">
						 <%}%>				  </td>
				</tr>
			</table>	  </td>
    </tr>
    <tr>
      <td height="35">&nbsp;</td>
      <td style="font-size:14px; font-weight:bold">Gender: </td>
      <td height="25" colspan="3">
		<%if(vStudBasicInfo != null && vStudBasicInfo.size() > 16 && vStudBasicInfo.elementAt(16) != null) {%>
			<strong><%=(String)vStudBasicInfo.elementAt(16)%></strong> 
			<input type="hidden" value="<%=(String)vStudBasicInfo.elementAt(16)%>" name="gender">
		<%}else{%>
				<select name="gender" style="font-size:14px; font-weight:bold">
			<option value=""></option>
			<%
			strTemp = WI.fillTextValue("gender");
			if(strTemp.equals("M"))
				strErrMsg = " selected";
			else	
				strErrMsg = "";
			%>
					  <option value="M" <%=strErrMsg%>>Male</option>
			<%if(strTemp.equals("F")){%>
					  <option value="F" selected>Female</option>
			<%}else{%>
					  <option value="F">Female</option>
			<%}%>
				</select>
		<%}%>
	  </td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="8%" style="font-size:14px; font-weight:bold">Course:</td>
      <td width="59%"><select name="course_index" onChange="ReloadCourseIndex();" style="font-size:14px; width:500px">
        <option value="0">Select Any</option>
        <%

	strCourseIndex = WI.fillTextValue("course_index");


if(WI.fillTextValue("cc_index").length()>0 && WI.fillTextValue("cc_index").compareTo("0") != 0)
{
	strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and is_visible = 1  " +
	 " and is_offered = 1 and cc_index="+request.getParameter("cc_index")+
  	" order by course_name asc" ;
}
else
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1  and is_visible = 1  " +
	 " and is_offered = 1 order by course_code asc";
%>
        <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name",strTemp,strCourseIndex, false)%>
      </select></td>
      <td width="31%" style="font-size:14px; font-weight:bold">Cur. Year :
        <select name="cy_from" onChange="ChangeCurYear();" style="font-size:14px;">
          <%
	vTemp = SS.getSchYear(dbOP, request, true);


	strTemp = WI.fillTextValue("cy_from");

for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%> - <%=(String)vTemp.elementAt(i + 1)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%> - <%=(String)vTemp.elementAt(i + 1)%></option>
          <%	}
	i = i+2;

}
if(vTemp.size() > 0) {
	strSYTo = (String)vTemp.elementAt(j+1);
}
else
	strSYTo = "";

%>
        </select>
        <!--to <b><%=strSYTo%></b>-->
        <input type="hidden" name="cy_to" value="<%=strSYTo%>">
        <%for(i = 0,j=0; i< vTemp.size(); i += 2, ++j) {%>
			<input type="hidden" name="cy_to<%=j%>" value="<%=(String)vTemp.elementAt(i + 1)%>">
        <%}%> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:14px; font-weight:bold">Major:</td>
      <td><select name="major_index" onChange="ReloadPage();" style="font-size:14px;">
        <option></option>
        <% 	strMajorIndex = WI.fillTextValue("major_index");

		if(strCourseIndex != null && strCourseIndex.compareTo("0") != 0 && strCourseIndex.length()>0){
			strTemp = " from major where is_del=0 and course_index="+strCourseIndex+" order by major_name asc" ;
	%>
        <%=dbOP.loadCombo("major_index","major_name",strTemp, strMajorIndex, false)%>
        <%}%>
      </select></td>
      <td>&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <% if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
    <tr>
      <td width="2%" height="24">&nbsp;</td>
      <td width="8%" style="font-size:14px; font-weight:bold"> Year:</td>
      <td width="90%" height="24" colspan="4">
<%
strTemp = WI.fillTextValue("stud_status");
if(strTemp.startsWith("N")){%>
	  <font color="#FF0000" style="font-size:14px; font-weight:bold">1</font>
        <input type="hidden" value="1" name="year_level"></td>
<%}else{%>
	  <select name="year_level">
          <option value="1">1st</option>
<%
strTemp = WI.fillTextValue("year_level");
if(strTemp.equals("2")){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.equals("4")){%>
          <option value="4" selected>4th</option>
<%}else{%>
          <option value="4">4th</option>
<%}if(strTemp.equals("5")){%>
          <option value="5" selected>5th</option>
<%}else{%>
          <option value="5">5th</option>
<%}if(strTemp.equals("6")){%>
          <option value="6" selected>6th</option>
<%}else{%>
          <option value="6">6th</option>
<%}%>
      </select>
<%}%>
    </tr>
    <%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25" colspan="3" valign="bottom" style="font-size:14px; font-weight:bold">Previous school: &nbsp;&nbsp;
<%if(!bolIsHSGrad) {%>
	  <font size="1">
      <input type="text" name="scroll_school"
	  onKeyUp="AutoScrollList('offlineRegd.scroll_school','offlineRegd.sch_index',true);"
	   class="textbox" style="font-size:14px;font-weight:bold" size="32">
      </font><a href="javascript:UpdateSchoolList();"><img src="../../images/update.gif" border="0"></a><font size="1">click
      to update schools' list</font>
<%}%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom">
<%
strTemp = WI.fillTextValue("sch_index");
if(bolIsHSGrad) 
	strTemp = "2";
%>
	  <select name="sch_index" <%if(bolIsHSGrad) {%> style="font-size:11px; border:hidden; background:#FFFFFF; font-weight:bold;color: #000000"  disabled="disabled"<%}else{%>style="font-size:14px; width:700px"<%}%>>
          <option></option>
     <%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME,sch_addr",
		  " from SCH_ACCREDITED where IS_DEL=0 and sch_name not like '%elem.%' " +
		  " and sch_name not like '%elementary%' order by SCH_NAME",strTemp,false)%> </select></td>
<%if(bolIsHSGrad){%>
	<input type="hidden" name="sch_index" value="<%=strTemp%>">
<%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    
<%if(boolAllowAdvising) {%>
    <tr>
      <td height="25" colspan="7"><div align="center"></div></td>
      <td width="26%" height="25"><a href="javascript:AddRecord();"> <img src="../../images/save.gif" border="0" name="hide_save"></a>
        <font size="1" >click to save entries</font></td>
      <td width="53%" height="25"><a href="javascript:ClearEntry();"><img src="../../images/clear.gif" width="55" height="19" border="0"></a>
        <font size="1" >click to clear entries</font></td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="degreeType" value="<%=WI.getStrValue(strDegreeType)%>">
<input type="hidden" name="pullStudInfo" value="<%=WI.fillTextValue("pullStudInfo")%>">

<input type="hidden" name="del_info">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
