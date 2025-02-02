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
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
TABLE.thinborder {
   border-top: solid 1px #000000;
   border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
}

TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
}

TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}




</style>


<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage(strShowList) {	
	if(strShowList == '1')
		document.form_.show_list.value = "1";
	else
		document.form_.show_list.value = "";
	document.form_.print_pg.value = '';
	document.form_.submit();
}
function PrintPg() {
	document.form_.print_pg.value = '1';
	document.form_.show_list.value = "1";
	document.form_.submit();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.stud_ledg.stud_id.value;
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
	document.stud_ledg.stud_id.value = strID;
	document.stud_ledg.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.stud_ledg.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_pg").equals("1")){
	%>
			<jsp:forward page="./student_list_add_drop_advised_print.jsp" />
	<%return;}
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","student_list_add_drop_advised.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"student_list_add_drop_advised.jsp");
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

ReportEnrollment reportEnrl = new ReportEnrollment();

String strCIndex = null;
String strCourseIndex = null;

String strSYFrom   = null;
String strSemester = null;

Vector vRetResult    = null;
Vector vDropHistList = new Vector();
if(WI.fillTextValue("show_list").length() > 0){
	vRetResult = reportEnrl.getStudAddDropAdvised(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
	else
		vDropHistList = (Vector)vRetResult.remove(0);
}

%>
<form action="./student_list_add_drop_advised.jsp" method="post" name="form_">

  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          REPORTS - STUDENT LIST ADD/DROPPED/ADVISED ::::
        
          </strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <strong><%=WI.getStrValue(strErrMsg)%></strong> </td>
    </tr>
    
    <tr>
      <td width="2%">&nbsp;</td>
      <td width="13%" height="25">SY/Term</td>
      <td width="85%" height="25">
<%
strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strSemester =WI.fillTextValue("semester");
if(strSemester.length() ==0) 
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
	
if(strSemester.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strSemester.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strSemester.compareTo("4") ==0){%>
  <option value="4" selected>4th Sem</option>
  <%}else{%>
  <option value="4">4th Sem</option>
  <%}if(strSemester.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="javascript:ReloadPage('1');"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">College</td>
      <td>
<%
strCIndex = WI.fillTextValue("c_index");
%>
	  <select name="c_index" onChange="ReloadPage('0')">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",strCIndex, false)%>
      </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Course</td>
      <td><select name="course_index" onChange="ReloadPage('0')">
        <option value="">ALL</option>
<%
strCourseIndex = WI.fillTextValue("course_index");
if(strCIndex.length() > 0) {
	strTemp = " from course_offered where is_del=0 and is_valid = 1 and is_offered =1 and c_index="+strCIndex ;
%>
        <%=dbOP.loadCombo("course_index","course_code, course_name ",strTemp, strCourseIndex, false)%>
<%}%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Student ID </td>
      <td>
	  <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
	  
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute"></label>
	  </td>
    </tr>
    
    
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="2">
<%
strErrMsg = "";
strTemp = WI.fillTextValue("show");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = " checked";
%>
	  <input type="radio" name="show" value="0" <%=strErrMsg%>> Show Advised &nbsp;&nbsp;
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show" value="1" <%=strErrMsg%>> Show Added &nbsp;&nbsp;

<%	if(strTemp.equals("2"))
		strErrMsg = " checked";
	else	
		strErrMsg = "";
	%>
		  <input type="radio" name="show" value="2" <%=strErrMsg%>> Show Dropped	  </td>
    </tr>
  </table>
  
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td align="right">
		
		Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 40;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 35; i < 70; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
		&nbsp; &nbsp; &nbsp;
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
		</td>
	</tr>
	<%
	if(WI.fillTextValue("show").equals("0"))
		strTemp = " ARE ADVISED";
	if(WI.fillTextValue("show").equals("1"))
		strTemp = " ADDED SUBJECT(S)";
	if(WI.fillTextValue("show").equals("2"))
		strTemp = " DROPPED SUBJECT(S)";
	%>
	<tr><td height="20" align="center" class="thinborderNONE"><strong>LIST OF STUDENTS WHO<%=strTemp%></strong></td></tr>
	<%if(WI.fillTextValue("c_index").length() > 0){
		strTemp = dbOP.mapOneToOther("college", "c_index", WI.fillTextValue("c_index"), "c_Code", " and is_del = 0");
	%>
	<tr><td height="20" align="center">
		<strong>PER COLLEGE <%if(WI.fillTextValue("course_index").length() > 0){%> AND COURSE <%}%> : <%=WI.getStrValue(strTemp)%>
		<%if(WI.fillTextValue("course_index").length() > 0){
			strTemp = dbOP.mapOneToOther("course_offered", "course_index", WI.fillTextValue("course_index"), "course_code", " and is_del = 0");
		%><%=WI.getStrValue(strTemp," - ","","")%><%}%>
		</strong>
	</td></tr>
	<%}%>
	<tr><td>&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="11%" height="22" class="thinborder"><strong>ID Number</strong></td>
		<td width="18%" class="thinborder"><strong>Student Name</strong></td>
		<td width="12%" class="thinborder"><strong>Course and Year Level</strong></td>
		<td width="12%" class="thinborder"><strong>Advised By</strong></td>
		<td width="13%" class="thinborder"><strong>Advised Date</strong></td>
		<td width="7%" class="thinborder"><strong>Subject Code</strong></td>
		<td width="8%" class="thinborder"><strong>Subject Status</strong></td>
	   <%
		if(WI.fillTextValue("show").equals("2")){%>
		<td width="10%" class="thinborder"><strong>Dropped By</strong></td>
	   <td width="9%" class="thinborder"><strong>Date Dropped</strong></td>
		<%}%>
	</tr>
	
<%
String strCCode = null;
String strPrevCCode = "";
String strEnrollIndex = null;

String strDroppedBy = null;
String strDroppedDate = null;
int iIndexOf = 0;
String[] astrSubStatus = {"Regular", "Added", "Dropped"}; 
for(int i = 0; i < vRetResult.size(); i += 19){
	strCCode = (String)vRetResult.elementAt(i+7);
	strEnrollIndex = (String)vRetResult.elementAt(i);
	if(!strPrevCCode.equals(strCCode)){
		strPrevCCode = strCCode;
%>	
	<tr><td colspan="9" height="18" class="thinborder"><strong><%=strCCode%></strong></td></tr>
	<%}%>
	
	<tr>
		<td height="18" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+4) + WI.getStrValue((String)vRetResult.elementAt(i+5), " / ", "", "") +
					WI.getStrValue((String)vRetResult.elementAt(i+6), " - ", "", "N/A");
		%>
		<td class="thinborder"><%=strTemp%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+9)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+10)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+13)%></td>
		<td class="thinborder"><%=astrSubStatus[Integer.parseInt((String)vRetResult.elementAt(i+11))]%></td>
	   <%if(WI.fillTextValue("show").equals("2")){
		
		iIndexOf = vDropHistList.indexOf(strEnrollIndex);
		if(iIndexOf > -1){
			strDroppedBy = (String)vDropHistList.elementAt(iIndexOf + 2);
			strDroppedDate = (String)vDropHistList.elementAt(iIndexOf + 3);
		}
			
		%>
		<td class="thinborder"><%=WI.getStrValue(strDroppedBy,"&nbsp;")%></td>
	   <td class="thinborder"><%=WI.getStrValue(strDroppedDate,"&nbsp;")%></td>
		<%}%>
	</tr>
	
<%}%>
</table>


<%}%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr bgcolor="#FFFFFF"><td height="25">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
<input type="hidden" name="show_list" value="">
<input type="hidden" name="print_pg"  value="">




</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
