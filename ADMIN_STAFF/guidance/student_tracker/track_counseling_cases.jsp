<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function ViewDetails(strInfoIndex, strStudIndex)
{
	var pgLoc = "../counseling_cases/view_dtls_counseling_cases.jsp?stud_id="+strStudIndex+"&info_index="+strInfoIndex+"&counsel_res_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
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
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
<!--
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CounselSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.counsel_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReferralSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.ref_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID()
{
	document.form_.stud_id.focus();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +"&opner_form_name=form_";
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	}
-->
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDCounseling, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Student Tracker-Counseling Status","track_counseling_cases.jsp");
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
														"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
														"track_counseling_cases.jsp");
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
	GDCounseling GDCounsel = new GDCounseling();
	vRetResult = GDCounsel.operateOnCounselingCase(dbOP, request, 4);
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = GDCounsel.getErrMsg();
%>
<body bgcolor="#663300" onload="FocusID()">
<form action="./track_counseling_cases.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: COUNSELING RECORD (ANECDOTAL) ENTRY PAGE 
          ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="4" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="5%"><p>&nbsp;</p></td>
      <td width="17%">School Year</td>
      <td width="78%" colspan="2"> <%strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
/
<select name="semester">
  <%strTemp = WI.fillTextValue("semester");
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
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student ID</td>
      <td height="25"> <%strTemp = WI.fillTextValue("stud_id");%>
     <input name="stud_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      <a href="javascript:StudSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for student ID</font></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25">&nbsp;</td>
    </tr>
	<%if (vRetResult !=null && vRetResult.size()> 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#A9C0CD"> 
      <td height="25" colspan="10" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>SUMMARY OF COUNSELING 
          CASES </strong></font></div></td>
    </tr>
    <tr> 
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>SY/ TERM </strong></font></div></td>
      <td width="13%" height="25" class="thinborder"><div align="center"><font size="1"><strong>COUNSELED 
          BY </strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>REFERRED BY</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>COUNSELING DATE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>FOLLOW UP</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>CONCLUSIONS AND RECOMMNEDATIONS </strong></font></div></td>
      <td width="21%" colspan="3" class="thinborder"><div align="center"><strong><font size="1">OPTIONS </font></strong></div></td>
    </tr>
     <%for (int i = 0; i< vRetResult.size(); i+=19){%>
    <tr> 
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;-&nbsp;<%=(String)vRetResult.elementAt(i+2)%><br><%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></font></td>
      <td height="25" class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12),7)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+6), (String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8),7)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+13)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+14)%></font></td>
      <td class="thinborder"><font size="1"><%strTemp = (String)vRetResult.elementAt(i+18);
      if (strTemp.length()>20){%>
      <%=strTemp.substring(0,20)%>...more<%}else{%><%=strTemp%><%}%></font></td>
      <td width="21%" class="thinborder" colspan="3"><div align="center"><a href='javascript:ViewDetails(<%=((String)vRetResult.elementAt(i))%>, "<%=((String)vRetResult.elementAt(i+4))%>")'>
	  <img src="../../../images/view.gif" width="40" height="31" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>