<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_action.value="";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex)
{
	document.form_.page_action.value=strAction;
	if(strAction == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
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
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAReenrollment,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strStudID = WI.fillTextValue("stud_id");

	String[] astrSchYrInfo = {WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester")};
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CHANGE OF SUBJECTS","re_enrolment.jsp");
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
														"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
														"re_enrolment.jsp");
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
FAPaymentUtil pmtUtil = new FAPaymentUtil();
FAReenrollment reEnrolment = new FAReenrollment();
strTemp = WI.fillTextValue("page_action");

Vector vStudInfo = null;
Vector vRetResult = null;
if(WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP,strStudID);
	if(vStudInfo == null) {
		strErrMsg = pmtUtil.getErrMsg();
	}
}

if(strTemp.length() > 0 && vStudInfo != null) {
	if(reEnrolment.operateOnStudReEnrollment(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = reEnrolment.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
//I have to get the list of subjet re-enrolled. 
if(vStudInfo  != null) {
	vRetResult = reEnrolment.operateOnStudReEnrollment(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = reEnrolment.getErrMsg();
}


%>

<form action="./re_enrolment.jsp" method="post" name="form_">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: RE-ENROLLMENT 
          MAIN PAGE ::::</strong></font></strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Enter Student ID </td>
      <td width="18%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="53%" height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>      </td>
    </tr>
    <tr>
      <td></td>
      <td colspan="4"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">School Year/Term </td>
      <td height="25" colspan="3"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
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
        </select> </td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
    <tr > 
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Student name </td>
      <td width="40%"> <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
      <td width="14%">Year level</td>
      <td width="25%"><strong><%=(String)vStudInfo.elementAt(4)%></strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major</td>
      <td height="25" colspan="3"><strong><%=(String)vStudInfo.elementAt(2)%> 
        <%
		if(vStudInfo.elementAt(3) != null){%>
        / <%=(String)vStudInfo.elementAt(3)%> 
        <%}%>
        </strong></td>
    </tr>
    <tr > 
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">SUBJECTS 
          TO RE-ENROLL</div></td>
    </tr>
    <tr> 
      <td  height="25">&nbsp;</td>
      <td colspan="4" height="25">To filter SUBJECT displayed enter subject code 
        starts with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        and click REFRESH to reload the page <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
      </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25">Subject Code : 
        <select name="subject" onChange="ReloadPage();">
          <option value="0">Enter another sub/code</option>
          <%=dbOP.loadCombo("sub_index","sub_code"," from subject where is_del=0 and sub_code like '"+
		  	WI.fillTextValue("starts_with")+"%' order by sub_code asc",request.getParameter("subject"),false)%> 
        </select></td>
      <td  colspan="2" height="25">
<%
if(iAccessLevel > 1){%>
	  <a href='javascript:PageAction("1","");'><img src="../../../images/add.gif" border="0" name="hide_save"></a>Click 
        to re-enroll this subject.
<%}%>
	  </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25"><b> 
        <%
//strTemp = WI.fillTextValue("subject");
//if(WI.fillTextValue("addSubject").compareTo("1") ==0)
//	strTemp = null;
%>
        <%=WI.getStrValue(dbOP.mapOneToOther("SUBJECT","sub_index",WI.fillTextValue("subject"),"sub_name",null))%></b></td>
      <td  colspan="2" height="25">&nbsp;</td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#B9B292"><div align="center">SUBJECTS LIST RE-ENROLLED</div></td>
    </tr>
    <tr >
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#000000" width="100%" border="0" cellspacing="1" cellpadding="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="25" align="center"></td>
      <td width="33%" height="25" align="center"><font size="1"><strong>SUBJECT 
        CODE</strong></font></td>
      <td width="50%" align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>REMOVE</strong></font></td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 3) {%>
    <tr bgcolor="#FFFFFF"> 
      <td></td>
      <td height="25"><%=(String)vRetResult.elementAt(i +1)%></td>
      <td><%=(String)vRetResult.elementAt(i +2)%></td>
      <td align="center">
<%if(iAccessLevel == 2 ){%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a><%}%></td>
    </tr>
    <%}%>
  </table>

<%
	}//if vAdviseLIst is not null.
}//only if student information is not null
%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
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