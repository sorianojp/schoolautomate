<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function focusID() {
	if(document.course_requirement.stud_id)
		document.course_requirement.stud_id.focus()
}
function PageAction(strAction,strInfoIndex, objChkBox) {
	document.course_requirement.page_action.value = strAction;
	document.course_requirement.info_index.value = strInfoIndex;
	if(objChkBox && objChkBox.checked) 
		document.course_requirement.oth_req.value = '1';

	this.SubmitOnce("course_requirement");
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=course_requirement.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CloseWindow(){	
	eval("window.opener.document."+document.course_requirement.parent_wnd.value+".submit()");
	window.opener.focus();
	self.close();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.course_requirement.stud_id.value;
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
	document.course_requirement.stud_id.value = strID;
	document.course_requirement.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.course_requirement.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID()">
<%@ page language="java" import="utility.*,enrollment.CourseRequirement,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolReadOnly = false;
if(WI.fillTextValue("read_only").length() > 0)
	bolReadOnly = true;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar-admission(student) requirement","stud_admission_req.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","ADMISSION REQUIREMENTS",request.getRemoteAddr(),
							//							"stud_admission_req.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	bolReadOnly = true;
	/**dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;**/
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	bolReadOnly = true;/**
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;**/
}

//end of authenticaion code.

CourseRequirement cRequirement = new CourseRequirement();

Vector vRetResult = null;
Vector vStudInfo  = null;
Vector vCRStudInfo = null;
Vector vFirstEnrl = null;
Vector vPendingRequirement = null;
Vector vCompliedRequirement = null;
String strSYFrom = null; 
String strSYTo = null; 
String strSemester  = null;

boolean bolIsTempStud = false;
String strStudIndex   = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(cRequirement.operateOnStudentRequirement(dbOP,request,Integer.parseInt(strTemp)) ) {
		strErrMsg = "Operation successful";
	}
	else
		strErrMsg = cRequirement.getErrMsg();
}

enrollment.OfflineAdmission OA = new enrollment.OfflineAdmission();
if (WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = OA.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"));
	if (vStudInfo == null) 
		strErrMsg= OA.getErrMsg();
}

if(vStudInfo != null && vStudInfo.size() > 0) {


	if ((String)vStudInfo.elementAt(20) != null){
		vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),(String)vStudInfo.elementAt(7),
													(String)vStudInfo.elementAt(8));
	}

	if (vFirstEnrl != null) {
		strSYFrom = (String)vFirstEnrl.elementAt(0);
		strSYTo = (String)vFirstEnrl.elementAt(1);
		strSemester = (String)vFirstEnrl.elementAt(2);
	}else{
		strSYFrom = (String)vStudInfo.elementAt(10);
		strSYTo = (String)vStudInfo.elementAt(11);
		strSemester = (String)vStudInfo.elementAt(9);
	}
	vCRStudInfo = cRequirement.getStudInfo(dbOP, request.getParameter("stud_id"),strSYFrom,
									strSYTo,strSemester);
	if(vCRStudInfo != null) {
		if( ((String)vCRStudInfo.elementAt(10)).compareTo("1") == 0)
			bolIsTempStud = true;
		
		strStudIndex = (String)vCRStudInfo.elementAt(0);
		
		vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vCRStudInfo.elementAt(0),
											strSYFrom,strSYTo,strSemester,bolIsTempStud,true,true);//get both pending and complied list
											
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = cRequirement.getErrMsg();
		else {
			vPendingRequirement = (Vector)vRetResult.elementAt(0);
			vCompliedRequirement = (Vector)vRetResult.elementAt(1);
		}
	  }else strErrMsg = cRequirement.getErrMsg();
}
String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
String[] astrConvertToYr  = {"N/A","1ST YR","2ND YR","3RD YR","4TH YR","5TH YR","6TH YR","7TH YR"};
//String astrConvertToPrepPropStat
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsUC = strSchCode.startsWith("UC");

%>
<form name="course_requirement" action="./stud_admission_req.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENT ADMISSION REQUIREMENTS PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="6"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="90%"><font size="3">&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></font></td>
            <td width="10%"> <% if (WI.fillTextValue("parent_wnd").length() > 0){%> <a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a> 
              <%}%> <font size="1">&nbsp;</font></td>
          </tr>
        </table></td>
    </tr>
    <tr valign="top"> 
      <td width="2%" height="25"></td>
      <td width="16%">Student ID: </td>
      <td width="20%">
	<% if (WI.fillTextValue("parent_wnd").length() > 0) strTemp = "readonly = yes";
	   else strTemp = " onKeyUp='AjaxMapName();'";%>
	  
	  <input type="text" name="stud_id" size="20" maxlength="32" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strTemp%>></td>
      <td width="10%">
	<% if (WI.fillTextValue("parent_wnd").length() == 0){%>
		  <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
	 <%}%>&nbsp;	  </td>
      <td width="16%">
	<% if (WI.fillTextValue("parent_wnd").length() == 0){%>
		  <input name="image" type="image" src="../../../images/form_proceed.gif">
	 <%}%>&nbsp;	  </td>
      <td width="36%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr> 
      <td colspan="6"><hr size="1" noshade> </td>
    </tr>
  </table>
<% if(vCRStudInfo != null){%>
<input type="hidden" name="stud_index" value="<%=(String)vCRStudInfo.elementAt(0)%>">
<input type="hidden" name="is_temp_stud" value="<%=(String)vCRStudInfo.elementAt(10)%>">
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="sy_to" value="<%=strSYTo%>">
<input type="hidden" name="semester" value="<%=strSemester%>">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">Student Name</td>
      <td width="33%"><strong><%=(String)vCRStudInfo.elementAt(1)%></strong></td>
      <td width="47%">ENROLLING STATUS : <font color="#9900FF"><strong>
        <%
	  if( ((String)vCRStudInfo.elementAt(9)).compareTo("0") ==0){%>
        ENROLLING
        <%}else{%>
        ENROLLED
        <%}%>
        </strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course/Major(cy)</td>
      <td colspan="2"><strong><%=(String)vCRStudInfo.elementAt(7)%>
        <%if(vCRStudInfo.elementAt(8) != null){%>
        /<%=(String)vCRStudInfo.elementAt(8)%>
        <%}%>
        (<%=(String)vCRStudInfo.elementAt(4)%> to <%=(String)vCRStudInfo.elementAt(5)%>
        )</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>YEAR LEVEL</td>
      <td><strong><%=astrConvertToYr[Integer.parseInt(WI.getStrValue(vCRStudInfo.elementAt(6),"0"))]%></strong></td>
      <td>SY (TERM ) &nbsp;&nbsp;: &nbsp;&nbsp;<%=strSYFrom + "-" +strSYTo%> (<%=astrConvertToSem[Integer.parseInt(strSemester)]%>)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Status</td>
      <td colspan="2"><strong><%=(String)vCRStudInfo.elementAt(11)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Foreign Student</td>
      <td colspan="2"><font color="#9900FF"><strong>
	  <%
	  if( ((String)vCRStudInfo.elementAt(16)).compareTo("1") ==0){%>
	  YES
	  <%}else{%>
	  NO<%}%></strong></font></td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%}if(vPendingRequirement != null && vPendingRequirement.size() > 0){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"> <div align="center"><strong>LIST
          OF NEEDED REQUIREMENTS</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <%for(int i = 0 ; i< vPendingRequirement.size(); i +=5){%>
    <tr>
      <td width="70%" height="25">&nbsp;&nbsp;&nbsp;<%=(String)vPendingRequirement.elementAt(i+1)%></td>
      <%if(bolIsUC) {%><td width="15%"><input type="checkbox" name="oth_req<%=i/5%>" value="1"> Other Requirement </td><%}%>
      <td width="15%">
        <%if(!bolReadOnly && iAccessLevel > 1){%>
        <a href='javascript:PageAction("1","<%=(String)vPendingRequirement.elementAt(i)%>",document.course_requirement.oth_req<%=i/5%>);'>
        <img src="../../../images/add.gif"  border="0"></a><font size="1"> click
        if complied</font>
        <%}%>
        &nbsp;</td>
      <%}%>
  </table>
<%}if(vCompliedRequirement != null && vCompliedRequirement.size() > 0){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#CCCCCC">
      <td height="25" colspan="4"><div align="center"><strong>LIST OF PASSED REQUIREMENTS</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <%
	Vector vIsOthFormat = new Vector();
	int iIndexOf = 0;
	if(bolIsTempStud)
		strTemp = "1";
	else	
		strTemp = "0";
	strTemp = "select req_sub_index from NA_REQ_SUBMITTED where stud_index= "+strStudIndex+" and is_temp_stud = "+strTemp+
				" and is_valid = 1 and is_other_data_uc = 1";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) 
		vIsOthFormat.addElement(rs.getString(1));
	rs.close();
 
	
	for(int i = 0 ; i< vCompliedRequirement.size() ; i +=3){%>
    <tr>
      <td width="74%" height="25">&nbsp;&nbsp;&nbsp;<%=(String)vCompliedRequirement.elementAt(i+1)%></td>
      <td width="18%"><%=(String)vCompliedRequirement.elementAt(i+2)%></td>
      <%if(bolIsUC) {
	  iIndexOf = vIsOthFormat.indexOf(vCompliedRequirement.elementAt(i));
	  if(iIndexOf > -1)
	  	strTemp = "Y";
	  else	
	  	strTemp = "&nbsp;";
	%>
	  <td width="8%" align="center" style="font-size:16px; font-weight:bold"><%=strTemp%></td><%}%>
      <td width="8%">
        <%if(!bolReadOnly && iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vCompliedRequirement.elementAt(i)%>");'>
        <img src="../../../images/delete.gif" border="0"></a>
        <%}%>      </td>
    </tr>
    <%}%>
  </table>
 <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="">
  <input type="hidden" name="oth_req">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="read_only" value="<%=WI.fillTextValue("read_only")%>">
<input type="hidden" value="<%=WI.fillTextValue("parent_wnd")%>" name="parent_wnd">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>