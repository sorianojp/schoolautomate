<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,enrollment.NAApplicationForm,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
	String strStudStatus = WI.fillTextValue("stud_stat");
	String strAlreadyRegistered = WI.fillTextValue("already_registered");
	
	String strStudID = WI.fillTextValue("stud_id");
	
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSYTo   = WI.fillTextValue("sy_to");
	String strSem    = WI.fillTextValue("semester");

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=offlineRegd.stud_id";

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

	document.offlineRegd.pullStudInfo.value= "1";
	document.offlineRegd.reloadPage.value="1";
}
function AddRecord()
{
	if(document.offlineRegd.section_name_) {
		if(document.offlineRegd.section_name_.selectedIndex == 0) {
			alert("Please select a section of student.");
			return;
		}
	}
	document.offlineRegd.addRecord.value = "1";
	document.offlineRegd.hide_save.src="../../../images/blank.gif";
	this.SubmitOnce("offlineRegd");
}
function ReloadPage()
{
	document.offlineRegd.reloadPage.value="1";
	this.SubmitOnce("offlineRegd");
}
//default form submit.
function PullStudInfo()
{
	document.offlineRegd.addRecord.value = "";
	if (document.offlineRegd.stud_id) {
		if(document.offlineRegd.stud_id.value.length ==0) {
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

function DisplaySYTo() {
	var strSYFrom = document.offlineRegd.sy_from.value;
	if(strSYFrom.length == 4)
		document.offlineRegd.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.offlineRegd.sy_to.value = "";
}

var calledRef;
//all about ajax - to display student list with same name.
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
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

}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function alertSize() {
	<%
	if(WI.fillTextValue("win_width").length() > 0){%>
		return;
	<%}%>
  var myWidth = 0, myHeight = 0;
  if( typeof( window.innerWidth ) == 'number' ) {
    //Non-IE
    myWidth = window.innerWidth;
    myHeight = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
    //IE 6+ in 'standards compliant mode'
    myWidth = document.documentElement.clientWidth;
    myHeight = document.documentElement.clientHeight;
  } 
  else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    myWidth = document.body.clientWidth;
    myHeight = document.body.clientHeight;
  }
  //window.alert( 'Width = ' + myWidth );
  //window.alert( 'Height = ' + myHeight );
  	document.offlineRegd.win_width.value = myWidth - 35;
	//alert(document.form_.win_width.value);
}
function ShowHideBlockStudentView(iStat) {
	var obj = document.getElementById('show_hide1');
	var objC = document.getElementById('gs_info1');
	if(iStat == 2) {
		obj = document.getElementById('show_hide2');
		objC = document.getElementById('gs_info2');
	}
	var strInnerContent = obj.innerHTML;
	
	if(!obj || !objC)
		return;
	if(strInnerContent == '(Click to Hide Detail)') {
		objC.style.visibility='hidden';	
		obj.innerHTML = "(Click to Show Detail)";
	}
	else {	
		objC.style.visibility='visible';
		obj.innerHTML = "(Click to Hide Detail)";
	}
}

function UpdateSPCStudStat() {
	document.offlineRegd.update_spc_stud_stat.value = '1';
	document.offlineRegd.submit();
}
</script>

<body bgcolor="#D2AE72">
<%
	boolean boolAllowAdvising = true;
	String strUserMsg = null;
	boolean bolShowStudInfo = false; //when proceed is clicked.
	
	Vector vTemp = new Vector();
	int i=0; int j=0;

	String strDegreeType = null;

//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"advising_all_in_one_p2.jsp");
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
//long lStartTime = new java.util.Date().getTime();

OfflineAdmission offlineAdm = new OfflineAdmission();
String strCourseIndex = null;
String strMajorIndex = null;

String strCourseName = null;
String strMajorName  = null;

String strYrLevel    = null;
String strCYFrom     = null;
String strCYTo       = null;

String strStudName   = null;
String strGender     = null;

String strStudIndex  = null;

String strIsGraduating = WI.fillTextValue("is_graduating");
String strIsAttcNB     = WI.fillTextValue("is_attcnb");
String strIsRegular    = WI.fillTextValue("regularity_stat");

String strHoldReason = null;
String strSQLQuery = null;

if(request.getParameter("addRecord") != null && request.getParameter("addRecord").equals("1"))
{
	String strWindowWidth = WI.fillTextValue("win_width");
	strErrMsg = "./advising_old.jsp?is_forwarded=1&showList=1&stud_id="+strStudID+"&sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSem+"&win_width="+strWindowWidth;
	if(strAlreadyRegistered.equals("1")) {
		if(strSchCode.startsWith("UC") || strSchCode.startsWith("FATIMA"))
			strSQLQuery = "update na_old_stud set course_regularity_stat ="+
				WI.getStrValue(WI.fillTextValue("regularity_stat"), "0")+
				",is_graduating="+WI.getStrValue(WI.fillTextValue("is_graduating"), "0")+", is_attcnb_stud="+
			 	WI.getStrValue(WI.fillTextValue("is_attcnb"), "0")+" where user_index = "+dbOP.mapUIDToUIndex(strStudID)+" and sy_from = "+strSYFrom+" and semester = "+strSem+" and is_valid = 1";
		else	
			strSQLQuery = "update na_old_stud set year_level = "+WI.getStrValue(WI.fillTextValue("year_level"),null)+", course_regularity_stat ="+
				WI.getStrValue(WI.fillTextValue("regularity_stat"), "0")+
				",is_graduating="+WI.getStrValue(WI.fillTextValue("is_graduating"), "0")+", is_attcnb_stud="+
			 	WI.getStrValue(WI.fillTextValue("is_attcnb"), "0")+",section_name_ = "+WI.getInsertValueForDB(WI.fillTextValue("section_name_"), true, null)+" where user_index = "+dbOP.mapUIDToUIndex(strStudID)+" and sy_from = "+strSYFrom+" and semester = "+strSem+" and is_valid = 1";
		
		//System.out.println("Printing1 : "+strErrMsg);	
		if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) > -1) {
			dbOP.cleanUP();
			%>
				<jsp:forward page="<%=strErrMsg%>" />
			<%
		}
	}
	if(!offlineAdm.createApplicant(dbOP,request))
		strErrMsg = offlineAdm.getErrMsg();
	else
	{//System.out.println("Printing2 : "+strErrMsg);
		if(WI.fillTextValue("section_name_").length() > 0) {
			strSQLQuery = "update new_application set section_name_ = '"+WI.fillTextValue("section_name_")+"' where user_index = "+dbOP.mapUIDToUIndex(strStudID)+" and sy_from = "+strSYFrom+" and semester = "+strSem+" and is_valid = 1";
			dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		}	
		dbOP.cleanUP();
			%>
				<jsp:forward page="<%=strErrMsg%>" />
			<%
		strErrMsg = "Student basic information for enrollment process is created successfully. reference ID = ";
		if(offlineAdm.strNewStudTempID != null)
			strErrMsg += offlineAdm.strNewStudTempID;//ID is different.
		else
			strErrMsg += strStudID;
	}
}
else {
	if(WI.fillTextValue("pullStudInfo").equals("1"))
		bolShowStudInfo = true;

	if(bolShowStudInfo) {
		Vector vStudBasicInfo = null;
		if(strAlreadyRegistered.equals("1")) {
			enrollment.Advising adv = new enrollment.Advising();
			vStudBasicInfo = adv.getStudInfo(dbOP, strStudID);
			//System.out.println(adv.getErrMsg());
		}
		else	
			vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
		
		if(vStudBasicInfo == null) {
			%>
			<font face="Verdana, Arial, Helvetica, sans-serif" size="3">
				Please create student information before enrolling student.</font>
			<%
			return;
		}
		else {//get the old student index;;
			//set all Information here. 
			if(strAlreadyRegistered.equals("1")) {//System.out.println(vStudBasicInfo);
				strCourseIndex = (String)vStudBasicInfo.elementAt(2);
				strMajorIndex  = (String)vStudBasicInfo.elementAt(3);
				
				strCourseName  = (String)vStudBasicInfo.elementAt(7);
				strMajorName   = (String)vStudBasicInfo.elementAt(8);
				
				strYrLevel     = (String)vStudBasicInfo.elementAt(6);
				strCYFrom      = (String)vStudBasicInfo.elementAt(4);
				strCYTo        = (String)vStudBasicInfo.elementAt(5);
				
				strStudName    = (String)vStudBasicInfo.elementAt(1);
				strGender      = (String)vStudBasicInfo.elementAt(19);
				
				strStudIndex   = (String)vStudBasicInfo.elementAt(0);
				
				strIsGraduating = (String)vStudBasicInfo.elementAt(34);
				strIsAttcNB     = (String)vStudBasicInfo.elementAt(35);
				strIsRegular    = (String)vStudBasicInfo.elementAt(21);
			}
			else {
				strCourseIndex = (String)vStudBasicInfo.elementAt(5);
				strMajorIndex  = (String)vStudBasicInfo.elementAt(6);
				
				strCourseName  = (String)vStudBasicInfo.elementAt(7);
				strMajorName   = (String)vStudBasicInfo.elementAt(8);
				
				strYrLevel     =  null;//(String)vStudBasicInfo.elementAt(14);
				strCYFrom      = (String)vStudBasicInfo.elementAt(3);
				strCYTo        = (String)vStudBasicInfo.elementAt(4);
				
				strStudName    = WI.formatName((String)vStudBasicInfo.elementAt(0),(String)vStudBasicInfo.elementAt(1),(String)vStudBasicInfo.elementAt(2),4) ;
				strGender      = (String)vStudBasicInfo.elementAt(16);
								
				strStudIndex   = (String)vStudBasicInfo.elementAt(12);
			}
			strUserMsg = new utility.MessageSystem().getSystemMsg(dbOP, strStudIndex, 2);
			strHoldReason = new enrollment.SetParameter().bolStudentIsOnHold(dbOP, strStudIndex);
			if(strHoldReason != null)
				boolAllowAdvising = false;
		}
		
	}
}

String[] astrConvertSem = {"Summer","1st Term","2nd Term","3rd Term", "4th Term","5th Term"};
if(strCourseIndex != null)
{
	request.setAttribute("course_index",strCourseIndex);
	request.setAttribute("major_index",strMajorIndex);
	strDegreeType = "select degree_type from course_offered where course_index = "+strCourseIndex;
	strDegreeType = dbOP.getResultOfAQuery(strDegreeType, 0);
	
	
}

enrollment.AdvisingExtn adv = new enrollment.AdvisingExtn();
if(WI.fillTextValue("update_spc_stud_stat").length() > 0) {
	if(adv.updateSPCAdvisingStudStatus(dbOP, strStudIndex, WI.fillTextValue("spc_stat"), strSYFrom, strSem, strCourseIndex, strMajorIndex, strYrLevel, 
			(String)request.getSession(false).getAttribute("userIndex")) != null) 
		strErrMsg = "Student Status is updated.";
	else	
		strErrMsg = adv.getErrMsg();
}

%>
<form action="./advising_all_in_one_p2.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          ADVISING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="1%"></td>
	  <td height="25">
<%if(strErrMsg != null){%>
	<strong><font size="3"><%=strErrMsg%></font></strong>
	&nbsp;
<%}%>	  </td>
    </tr>
  </table>

    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strUserMsg != null){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strUserMsg%></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%}%>
<%if(strHoldReason != null){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL">Advising is Onhold: <%=strHoldReason%></td>
      <td width="2%">&nbsp;</td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%"height="25">&nbsp;</td>
      <td width="13%" height="25">Student Status: </td>
      <td width="20%" style="font-size:14px; font-weight:bold"><%=strStudStatus%>
	  <input type="hidden" name="stud_status" value="<%=strStudStatus%>">	  </td>
      <td width="12%" height="25">Student ID</td>
      <td width="53%" style="font-size:14px; font-weight:bold"> <%=strStudID%>
	  <input type="hidden" name="stud_id" value="<%=strStudID%>">	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td style="font-size:14px; font-weight:bold">&nbsp;</td>
      <td height="25">Student Name </td>
      <td style="font-size:14px; font-weight:bold">	<%=strStudName%></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">
<%

if(WI.getStrValue(strIsRegular).equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
	  <input type="checkbox" value="1" name="regularity_stat" <%=strTemp%>> Check if Student is Irregular</td>
    </tr>
<%if(strSchCode.startsWith("UC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">
<%
if(strIsAttcNB.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
	  <input type="checkbox" value="1" name="is_attcnb" <%=strTemp%>> Is ATTC/NB Student?</td>
    </tr>
<%}if(strSchCode.startsWith("FATIMA")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">
<%
if(strIsGraduating.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>
	  <input type="checkbox" value="1" name="is_graduating" <%=strTemp%>> Is Graduating Student?</td>
    </tr>
<%}if(strSchCode.startsWith("VMA") || strSchCode.startsWith("SPC")){
if(WI.fillTextValue("section_name_").length() > 0) 
	strTemp = WI.fillTextValue("section_name_");
else {
	strTemp = "select section_name_ from na_old_stud where user_index = "+strStudIndex+" and sy_from = "+strSYFrom+" and semester = "+strSem+" and is_valid = 1";
	//System.out.println("Print: "+strTemp);
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
}
String strVMASectionList = null;
if(strSchCode.startsWith("SPC")) 
	strVMASectionList = dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section"," from e_sub_section where is_valid = 1 order by e_sub_section.section asc", strTemp, false);
else if(strSchCode.startsWith("VMA")) 
	strVMASectionList = dbOP.loadCombo("vma_section.section_name","vma_section.section_name"," from vma_section order by vma_section.section_name asc", strTemp, false);
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:13px; font-weight:bold; color:#CC0033">Set Section of Student:
		<select name="section_name_">
			<option value=""></option>
          <%=strVMASectionList%>
		</select>
		</td>
    </tr>
<%}%>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="61%">Course</td>
      <td width="37%">Cur. Year: <font  style="font-size:14px; font-weight:bold"><%=strCYFrom%> - <%=strCYTo%></font>
      <input type="hidden" name="cy_from" value="<%=strCYFrom%>">
	  <input type="hidden" name="cy_to" value="<%=strCYTo%>">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:14px; font-weight:bold"><%=strCourseName%>
	  <input type="hidden" name="course_index" value="<%=strCourseIndex%>">	  </td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="61%">Major : <font  style="font-size:14px; font-weight:bold"><%=WI.getStrValue(strMajorName)%></font>
	  <input type="hidden" name="major_index" value="<%=WI.getStrValue(strMajorIndex)%>">	  </td>
      <td width="37%">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
	if(strSchCode.startsWith("UC") || strSchCode.startsWith("SPC") || strSchCode.startsWith("DLSHSI") || (strDegreeType != null && !strDegreeType.equals("4") && !strDegreeType.equals("1"))){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"> Year level entry</td>
      <td height="25">
<%
	strTemp = WI.fillTextValue("year_level");
	if(strYrLevel != null)
		strTemp = strYrLevel;
	else {
		if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UB")) {
			vTemp = offlineAdm.determineYrLevelOfStud(dbOP, request, strStudIndex, 
			strCourseIndex, strMajorIndex, strCYFrom, strCYTo, "0", strSYFrom, strSem, strYrLevel, strDegreeType);
			//System.out.println(vTemp);
		}
		else
			vTemp = offlineAdm.determineYrLevelOfStud(dbOP,WI.fillTextValue("stud_id"));
		if(vTemp != null && vTemp.size() > 0)
			strTemp = WI.getStrValue((String)vTemp.elementAt(0));
	}
	
if(strSchCode.startsWith("UB") && strTemp == null)
	strTemp = "1";
String strDisabled = "";
%>
	  <select name="year_level" <%if(strSchCode.startsWith("UC") || strSchCode.startsWith("FATIMA")){%> disabled="disabled"<%}%>>
<%
 if(strTemp.equals("1")) {
 	strErrMsg = " selected"; 
	strDisabled = "";
}else {
	strErrMsg = "";
	if(strSchCode.startsWith("UB"))
		strDisabled = "disabled='disabled'";
}%>
        <option value="1"<%=strErrMsg%><%=strDisabled%>>1st</option>
<%
 if(strTemp.equals("2")) {
 	strErrMsg = " selected"; 
	strDisabled = "";
}else {
	strErrMsg = "";
	if(strSchCode.startsWith("UB"))
		strDisabled = "disabled='disabled'";
}%>
        <option value="2"<%=strErrMsg%><%=strDisabled%>>2nd</option>
<%
 if(strTemp.equals("3")) {
 	strErrMsg = " selected"; 
	strDisabled = "";
}else {
	strErrMsg = "";
	if(strSchCode.startsWith("UB"))
		strDisabled = "disabled='disabled'";
}%>
        <option value="3"<%=strErrMsg%><%=strDisabled%>>3rd</option>
<%
 if(strTemp.equals("4")) {
 	strErrMsg = " selected"; 
	strDisabled = "";
}else {
	strErrMsg = "";
	if(strSchCode.startsWith("UB"))
		strDisabled = "disabled='disabled'";
}%>
        <option value="4"<%=strErrMsg%><%=strDisabled%>>4th</option>
<%
 if(strTemp.equals("5")) {
 	strErrMsg = " selected"; 
	strDisabled = "";
}else {
	strErrMsg = "";
	if(strSchCode.startsWith("UB"))
		strDisabled = "disabled='disabled'";
}%>
        <option value="5"<%=strErrMsg%><%=strDisabled%>>5th</option>
<%
 if(strTemp.equals("6")) {
 	strErrMsg = " selected"; 
	strDisabled = "";
}else {
	strErrMsg = "";
	if(strSchCode.startsWith("UB"))
		strDisabled = "disabled='disabled'";
}%>
        <option value="6"<%=strErrMsg%><%=strDisabled%>>6th</option>
        </select>
        <em><font color="#0066FF" size="1">
		<%if(strSchCode.startsWith("UC") || strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UB")){%>
			Go To Admission office to change year level outstanding if year level displayed is not correct
		<%}else{%>
			Change year level outstanding if year level displayed is not year level standing of student
		<%}%>
		</font></em></td>
    </tr>
    <%}
		if(strDegreeType != null && strDegreeType.compareTo("3") ==0  ){//System.out.println(vStudBasicInfo);%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Select Prep/Proper</td>
      <td height="25"><select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select></td>
      <td height="25">&nbsp;</td>
      <td colspan="2"></td>
    </tr>
    <%}%>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="16%"> School Year-Term: </td>
      <td style="font-size:14px; font-weight:bold">
	  <%=strSYFrom + " - "+strSYTo+", "+astrConvertSem[Integer.parseInt(strSem)]%>
	  <input type="hidden" name="sy_from" value="<%=strSYFrom%>">
	  <input type="hidden" name="sy_to" value="<%=strSYTo%>">
	  <input type="hidden" name="semester" value="<%=strSem%>">
	  
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
<%
boolean bolShow = false;
if(strSchCode.startsWith("CPU") || strSchCode.startsWith("CLDH"))
	bolShow = true;
	//bolShow = true;

if (bolShow &&
			(WI.fillTextValue("stud_status").compareToIgnoreCase("old") == 0  ||
			 WI.fillTextValue("stud_status").compareToIgnoreCase("change course") == 0)   &&
			strStudIndex != null ) {
		//long lStartTime = new java.util.Date().getTime();
		Vector vDropIncFail = adv.countFailDropCPU(dbOP, WI.fillTextValue("stud_id"));
		//System.out.println(new java.util.Date().getTime() - lStartTime);

%>
    <tr>
      <td height="23" colspan="9">&nbsp;
		<table width="60%" border="0" align="center"  cellpadding="0" cellspacing="0">
		<tr>
			<td width="27%">
				<img src="../../../upload_img/<%=WI.fillTextValue("stud_id")%>.jpg" width="125" height="125" />		</td>
			<td width="73%" valign="top">
			<% if (vDropIncFail!= null && vDropIncFail.size()>0)  {%>
	
			<table width="80%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
			  <tr>
				<td width="43%" height="25" class="thinborder"> &nbsp;REMARKS </td>
				<td width="57%" class="thinborder">&nbsp;NUMBER OF TIMES</td>
			  </tr>
		<% for ( i = 0; i < vDropIncFail.size(); i+=2) {%>
			  <tr>
				<td height="25" class="thinborder">&nbsp;<strong><%=(String)vDropIncFail.elementAt(i)%></strong> </td>
				<td class="thinborder">&nbsp;<%=(String)vDropIncFail.elementAt(i+1)%></td>
			  </tr>
		<% }%>
			</table>
		<%}else{%>
			<font size="2" color="#0000FF"> <strong> &nbsp;&nbsp;&nbsp;Student is of Good Standing</strong></font>
		<%}%>		</td>
			</tr>
		<tr>
			<td colspan=2>&nbsp;  </td>
		</tr>
	</table>
	  </td>
    </tr>
    <tr>
      <td height="23" colspan="9">&nbsp;</td>
    </tr>
<%}
	bolShow = false;
	String strSpcStudStat = null;
	Vector vSpcStudStat   = null;
	
if(strSchCode.startsWith("SPC"))
	bolShow = true;
if(strSchCode.startsWith("SPC")) {
	strSQLQuery = "select STATUS_ from SPC_ADVISING_STUD_STAT  "+
					" join SEMESTER_SEQUENCE on (semester_val= term_) where SPC_ADVISING_STUD_STAT.is_valid = 1 and stud_index = "+
					strStudIndex+" order by sy_fr desc, SEM_ORDER desc";
	strSpcStudStat = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSpcStudStat != null) 
		vSpcStudStat = adv.getSPCAdvisingStudStatusPerStud(dbOP, strStudIndex);
	//System.out.println(adv.getErrMsg());
}
if(bolShow) {
		Vector vDropIncFail = adv.countFailSubjectNew(dbOP, strStudIndex, strSchCode);
		
		if(vDropIncFail != null && vDropIncFail.size() > 1) {
			Vector vSummary = (Vector)vDropIncFail.remove(0);
		    %>
				<tr>
					<td height="23" colspan="9" align="center">
						<table width="80%" cellpadding="0" cellspacing="0"> 
							<tr>
								<td width="50%">
									<table width="95%" class="thinborder" cellpadding="0" cellspacing="0"> 
										<tr>
											<td bgcolor="#CCCCCC" class="thinborder" colspan="2" style="font-weight:bold" align="center">Summary Of Failure <label id="show_hide1" onClick="ShowHideBlockStudentView('1')" style="color:#0000FF; font-weight:bold">(Click to View Detail)</label></td>
										</tr>
										<%if(vSummary.size() == 1) {%>
										<tr>
											<td class="thinborder" colspan="2" style="font-weight:bold" align="center"><%=vSummary.elementAt(0)%></td>
										</tr>
										<%}else
											while(vSummary.size() > 0) {%>
											<tr>
												<td class="thinborder" width="75%" style="font-size:15px;"><%=vSummary.remove(0)%></td>
												<td class="thinborder" style="font-size:15px;"><%=vSummary.remove(0)%></td>
											</tr>
										<%}%>
									</table>
								</td>
								
								<td valign="top" style="font-size:11px;">
									<font style="font-size:19px;">Current Status: <strong><label id="spc_stud_stat"><%=WI.getStrValue(strSpcStudStat,"Not Set")%></label></strong></font>
									<%if(WI.getStrValue(strSpcStudStat,"").length() > 0 && vSpcStudStat != null && vSpcStudStat.size() > 0) {%>
										<label id="show_hide2" onClick="ShowHideBlockStudentView('2')" style="color:#0000FF; font-weight:bold">(Click to Show Detail)</label>
									<%}%>
									
									<br>
									<%//if(vSummary.size() == 0) {%>
										<strong>Set new Status</strong><br>
										<select name="spc_stat">
											<option value=""></option>
											<option value="P1">P1</option>
											<option value="P2">P2</option>
											<option value="Last Chance">Last Chance</option>
											<option value="OP">OP</option>
										</select>
										<a href="javascript:UpdateSPCStudStat();"><img src="../../../images/update.gif" border="0"></a>
									<%//}%>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td align="center">
						 <div id="gs_info1" style="position:absolute; width:95%; visibility:hidden">
							 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
								<tr bgcolor="#FFFFCC">
								  <td width="5%" class="thinborder" align="center"><div align="center"><strong><font size="1">Count</font></strong></div></td>
								  <td width="10%" height="20" class="thinborder"><div align="center"><strong><font size="1">SY-Term</font></strong></div></td>
								  <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>Course-Yr</strong></font></div></td>
								  <td width="15%" class="thinborder"><div align="center"><strong><font size="1">Subject Code</font></strong></font></div></td>
								  <td width="35%" class="thinborder"><div align="center"><font size="1"><strong>Subject Description</strong></font></div></td>
								  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">Remarks</font></strong></div></td>
								</tr>
								<%
								i = 0;
								while(vDropIncFail.size() > 0) {%>
									<tr>
										<td class="thinborder"><%=++i%></td>
										<td class="thinborder"><%=vDropIncFail.elementAt(0)%> - <%=vDropIncFail.elementAt(1)%></td>
										<td class="thinborder"><%=vDropIncFail.elementAt(2)%><%=WI.getStrValue((String)vDropIncFail.elementAt(3), " ", "", "")%><%//=WI.getStrValue((String)vDropIncFail.elementAt(4), " - ", "", "")%></td>
										<td class="thinborder"><%=vDropIncFail.elementAt(5)%></td>
										<td class="thinborder"><%=vDropIncFail.elementAt(6)%></td>
										<td class="thinborder"><%=vDropIncFail.elementAt(4)%></td>
									</tr>
							 	<%vDropIncFail.remove(0);vDropIncFail.remove(0);vDropIncFail.remove(0);vDropIncFail.remove(0);
								vDropIncFail.remove(0);vDropIncFail.remove(0);vDropIncFail.remove(0);vDropIncFail.remove(0);}%>
							 </table>
						 </div>
						 <%if(vSpcStudStat != null && vSpcStudStat.size() > 0) {%>
						 <div id="gs_info2" style="position:absolute; width:95%; visibility:hidden">
							 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
								<tr bgcolor="#FFFFCC">
								  <td width="5%" class="thinborder" align="center"><div align="center"><strong><font size="1">Count</font></strong></div></td>
								  <td width="10%" height="20" class="thinborder"><div align="center"><strong><font size="1">SY-Term</font></strong></div></td>
								  <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>Course</strong></font></div></td>
								  <td width="15%" class="thinborder"><div align="center"><strong><font size="1">Status</font></strong></font></div></td>
								</tr>
								<%
								i = 0;
								while(vSpcStudStat.size() > 0) {%>
									<tr>
										<td class="thinborder"><%=++i%></td>
										<td class="thinborder"><%=vSpcStudStat.elementAt(0)%> - <%=vSpcStudStat.elementAt(1)%></td>
										<td class="thinborder"><%=vSpcStudStat.elementAt(2)%><%=WI.getStrValue((String)vSpcStudStat.elementAt(3), " ", "", "")%><%//=WI.getStrValue((String)vDropIncFail.elementAt(4), " - ", "", "")%></td>
										<td class="thinborder"><%=vSpcStudStat.elementAt(5)%></td>
									</tr>
							 	<%vSpcStudStat.remove(0);vSpcStudStat.remove(0);vSpcStudStat.remove(0);vSpcStudStat.remove(0);
								vSpcStudStat.remove(0);vSpcStudStat.remove(0);}%>
							 </table>
						 </div>
						 <%}%>
					</td>
				</tr>
<%
		}
}



boolean bolShowSave = true;
if(!boolAllowAdvising)
	bolShowSave = false;
else {	
	if(strStudStatus.equals("Old") || strStudStatus.equals("Change Course") ||
		strStudStatus.equals("New (HS Grad)")) {
	
		if(!bolShowStudInfo || strStudIndex == null){
			bolShowSave = false;
			strErrMsg = "Please enter student ID and click proceed.";
		}
	}
}
if(bolShowSave){%>
    <tr>
      <td height="25" colspan="7">&nbsp;</td>
      <td width="26%" height="25"><a href="javascript:AddRecord();"> <img src="../../../images/save.gif" border="0" name="hide_save"></a>
        <font size="1" >click to save entries</font></td>
      <td width="53%" height="25">&nbsp;</td>
    </tr>
<%}else {%>
    <tr>
      <td height="25" colspan="7">&nbsp;</td>
      <td height="25" colspan="2"><%=strErrMsg%></td>
    </tr>
<%}%>
    <tr>
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" value="<%=strGender%>" name="gender">

<input type="hidden" name="pullStudInfo" value="<%=WI.fillTextValue("pullStudInfo")%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="degreeType" value="<%=WI.getStrValue(strDegreeType)%>">

<input type="hidden" name="reload_in_progress">

<input type="hidden" name="from_placement_exam" value="<%=WI.fillTextValue("from_placement_exam")%>">
<input type="hidden" name="remove_old" value="<%=WI.fillTextValue("remove_old")%>"><!-- Set for UDMC -->

<input type="hidden" name="already_registered" value="<%=WI.fillTextValue("already_registered")%>">


<input type="hidden" name="win_width" value="<%=WI.fillTextValue("win_width")%>">
<input type="hidden" name="update_spc_stud_stat" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
