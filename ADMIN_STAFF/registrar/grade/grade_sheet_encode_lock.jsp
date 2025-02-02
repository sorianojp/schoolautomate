<%
	WebInterface WI   = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";

	String strGradeForName = WI.fillTextValue("grade_name_");//strSchCode = "CLDH";
	if(strSchCode.startsWith("UL"))
		strSchCode = "CGH";

	boolean bolIsCGH = false; //for cldh - i must have finals to record in %ge.
	if(strSchCode.startsWith("CGH") || strSchCode.startsWith("UDMC") || (strSchCode.startsWith("CLDH") && strGradeForName.toLowerCase().startsWith("final")) )
		bolIsCGH = true;//bolIsCGH = true;

	String strTemp    = null;
	boolean bolIsCSA = strSchCode.startsWith("CSA");	
	
	boolean bolIsCIT = strSchCode.startsWith("CIT");
	
		
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
var imgWnd;


function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.page_action.value="";
	this.ShowProcessing();
}
function ShowProcessing() {

	if(document.form_.grade_for) {
		document.form_.grade_name_.value = document.form_.grade_for[document.form_.grade_for.selectedIndex].text;
	}

	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	this.SubmitOnce('form_');
	imgWnd.focus();
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}


//added new.
function encodeGrade(strSubSecIndex, strSubIndex, strSection) {
	location = "./grade_sheet.jsp?sub_sec_index="+strSubSecIndex+"&grade_for="+
	document.form_.grade_for[document.form_.grade_for.selectedIndex].value+"&prevent_fwd=1&sy_from="+
	document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&offering_sem="+
	document.form_.offering_sem[document.form_.offering_sem.selectedIndex].value+"&subject="+strSubIndex+
	"&section_name="+strSection;
}

function unlockGrade(strVerifyIndex) {
	if(!confirm("Are you sure you want to unlock this grade."))
		return;
		
	document.form_.info_index.value = strVerifyIndex;
	document.form_.page_action.value ='0';
	document.form_.submit();
}
function unlockGradeOne(strPmtSch, strSubSec) {
	var pgLoc = "./grade_sheet_encode_unlock_one.jsp?pmt_sch="+strPmtSch+"&section="+strSubSec;
	//alert(pgLoc);
	imgWnd= window.open(pgLoc,"PrintWindow",'width=700,height=600,top=20,left=20,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=1');
	imgWnd.focus();
}


//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
// end ajax
</script>


<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<form name="form_" action="./grade_sheet_encode_lock.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	Vector vSecDetail = null;



	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet_encode_lock.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),
									null);
}


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
GradeSystemExtn gsExtn     = new GradeSystemExtn();

String strEmployeeID    = WI.fillTextValue("emp_id");

String strEmployeeIndex = null;
String strSubSecIndex   = null;

if(strEmployeeID.length() > 0)
	strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);


Vector vRetResult    = null;
//get here necessary information.

//new code.. 
String strPmtSchIndex = null;
Vector vFacultyLoad   = null;
Vector vPmtSchedule   = null;
boolean bolEncodingAllowed = true;
Vector vExamSched     = null;
Vector vLockedInfo    = null;


String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSemester = WI.fillTextValue("offering_sem");
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");

if(strEmployeeIndex != null) {
	if(WI.fillTextValue("page_action").length() > 0) {
		String strSQLQuery = "update FACULTY_GRADE_VERIFY set IS_UNLOCKED = 1 where verify_index = "+WI.fillTextValue("info_index");
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		strSQLQuery = "insert into FACULTY_GRADE_VERIFY_UNLOCK (VERIFY_INDEX, UNLOCK_BY, UNLOCK_DATE) values ("+WI.fillTextValue("info_index")+", "+(String)request.getSession(false).getAttribute("userIndex")+",'"+WI.getTodaysDate()+"')";
		strErrMsg = "Grade Sheet Unlocked Successfully.";
		
		
		//if whole grade I have to re-set the locking as well. 
		strSQLQuery = "select s_s_index, pmt_sch_index from FACULTY_GRADE_VERIFY where verify_index = "+WI.fillTextValue("info_index");
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			if(rs.getString(2).equals("3"))
				strSQLQuery = "update g_sheet_final set FORCE_LOCK_STAT = null where sub_sec_index = "+rs.getString(1)+" and is_valid = 1";
			else	
				strSQLQuery = "update grade_sheet set FORCE_LOCK_STAT = null where sub_sec_index = "+rs.getString(1)+" and is_valid = 1";
			
			rs.close();
			dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		}
		///end of resetting individual unlocked Information.
	}
	

	vExamSched = gsExtn.getExamSchedulesAllowed(dbOP,strEmployeeIndex, strSYFrom, strSemester);
	if(vExamSched == null) {
		bolEncodingAllowed = false;
		strErrMsg = gsExtn.getErrMsg();
	} 
	vFacultyLoad = gsExtn.getFacultyGradeEncodingSectionList(dbOP,strEmployeeIndex, strSYFrom, strSemester, request);
	if(vFacultyLoad == null) {
		strErrMsg = gsExtn.getErrMsg();
		vFacultyLoad = new Vector();
	}
	vPmtSchedule = gsExtn.getAllowedGradePeriods(dbOP, strSYFrom, strSemester, strSchCode);
	if(vPmtSchedule == null) 
		strErrMsg = gsExtn.getErrMsg();
	
	vLockedInfo = gsExtn.getGSLockInfo(dbOP, strSYFrom, strSemester, strEmployeeIndex);
}
if(vFacultyLoad == null)
	vFacultyLoad   = new Vector();
if(vPmtSchedule == null)
	vPmtSchedule   = new Vector();
if(vExamSched == null)
	vExamSched   = new Vector();
if(vLockedInfo == null)
	vLockedInfo   = new Vector();

//System.out.println(vLockedInfo);
int iIndexOf = 0;

%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

<input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
<input type="hidden" name="show_delete">
<input type="hidden" name="show_save">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          GRADE SHEETS UNLOCKING PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"Error Message: ","","")%></font></strong></td>
    </tr>
    <tr valign="top">
      <td height="25">&nbsp;&nbsp;&nbsp;</td>
      <td>Faculty ID:</td>
      <td><input name="emp_id" type="text" size="32" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"></td>
      <td width="59%"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="12%" height="25" >SY/Term</td>
      <td width="27%" valign="bottom" ><input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
-
  <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
  <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes">
  <select name="offering_sem" onChange="ReloadPage();">
        <option value="1">1st Sem</option>
        <%
if(strSemester.compareTo("2") ==0){%>
        <option value="2" selected>2nd Sem</option>
        <%}else{%>
        <option value="2">2nd Sem</option>
        <%}if(strSemester.compareTo("3") ==0){%>
        <option value="3" selected>3rd Sem</option>
        <%}else{%>
        <option value="3">3rd Sem</option>
        <%}if(strSemester.compareTo("0") ==0){%>
        <option value="0" selected>Summer</option>
        <%}else{%>
        <option value="0">Summer</option>
        <%}%>
      </select></td>
      <td ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a> </td>
    </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr align="center">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center">
      <td height="25" colspan="8" style="font-weight:bold; font-size:12px;" class="thinborder" bgcolor="#66CCFF">Faculty Load Listing</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center">
	  <td width="18%" class="thinborder"> Subject Code</td>
      <td width="25%" class="thinborder"> Subject Name</td>
      <td width="10%" class="thinborder"> Section</td>
<%for(int i = 0; i <vPmtSchedule.size(); i += 2) {%> 
      <td width="5%" class="thinborder"><%=vPmtSchedule.elementAt(i)%><br>UnLock ALL</td>
      <td width="5%" class="thinborder"><%=vPmtSchedule.elementAt(i)%><br>UnLock One</td>
<%}%>
    </tr>

<%
Vector vTemp = null;//System.out.println(vLockedInfo);
boolean bolIsUnlocked = false;

for(int i = 0; i < vFacultyLoad.size(); i += 7){
strTemp = (String)vFacultyLoad.elementAt(i + 3);//sub sec index
vTemp = new Vector();

iIndexOf = vLockedInfo.indexOf(new Integer(strTemp));
//System.out.println("strTemp : "+strTemp+" iIndexOf = "+iIndexOf);
while(iIndexOf > -1) {
	vTemp.addElement(vLockedInfo.elementAt(iIndexOf + 1));
	vTemp.addElement(new Integer((String)vLockedInfo.elementAt(iIndexOf - 1)));//verify index.
	
	iIndexOf = iIndexOf - 1;
	vLockedInfo.remove(iIndexOf);vLockedInfo.remove(iIndexOf);vLockedInfo.remove(iIndexOf);
	vLockedInfo.remove(iIndexOf);vLockedInfo.remove(iIndexOf);
	bolIsUnlocked = vLockedInfo.remove(iIndexOf).equals("1");
	if(bolIsUnlocked) {
		vTemp.remove(vTemp.size() - 1);
		vTemp.remove(vTemp.size() - 1);
	}
	iIndexOf = vLockedInfo.indexOf(new Integer(strTemp));
}
%>
    <tr>
      <td class="thinborder"><%=vFacultyLoad.elementAt(i)%></td>
      <td class="thinborder"><%=vFacultyLoad.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vFacultyLoad.elementAt(i + 2)%></td>
<%for(int p = 0; p <vPmtSchedule.size(); p += 2) {
	iIndexOf = vTemp.indexOf(vPmtSchedule.elementAt(p + 1));

%> 
      <td width="5%" class="thinborder">&nbsp;
	  	<%if(iIndexOf > -1) {%>
	  	<input type="button" value="UnLock" name="_" style="font-size:11px; height:24px; width:60px; border: 1px solid #FF0000;" onClick="unlockGrade('<%=vTemp.elementAt(iIndexOf + 1)%>');">
		<%}%>
	  </td>
      <td width="5%" class="thinborder">&nbsp;
	  	<input type="button" value="UnLock One" name="_" style="font-size:11px; height:24px; width:70px; border: 1px solid #FF0000; background:#bbbbbb" onClick="unlockGradeOne('<%=vPmtSchedule.elementAt(p + 1)%>','<%=strTemp%>');">
	  </td>
<%}%>
    </tr>
<%}%>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
