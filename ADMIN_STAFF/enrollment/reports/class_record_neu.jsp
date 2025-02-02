<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCIT = strSchCode.startsWith("CIT");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:8;
	top:8;
   
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage(strShowCList) {
	document.form_.showCList.value = strShowCList;
	document.form_.print_pg.value = '';
	document.form_.submit();
}
function PrintPg() {
	if(document.form_.emp_id.value.length == 0){
		alert("Please select a faculty.");
		return;
	}
	

	document.form_.print_pg.value = '1';
	document.form_.submit();
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
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	java.sql.ResultSet rs = null;
	if(WI.fillTextValue("print_pg").length() > 0){%>
	<jsp:forward page="./class_record_neu_print.jsp"></jsp:forward>
	<%return;}
	
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-class list","class_list_cit.jsp");
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
														"class_record_neu.jsp");
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


String strCIndex = null;
String strDIndex = null;

String strSYFrom   = null;
String strSemester = null;

%>
<form action="./class_record_neu.jsp" method="post" name="form_">
<%
enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();
Vector vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,WI.fillTextValue("section"));
%>



  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          REPORTS - CLASS RECORD PAGE ::::
        
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
  <%
strSemester =WI.fillTextValue("semester");
if(strSemester.length() ==0) 
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");	
%>
<%=CommonUtil.constructTermList(dbOP, request, strSemester)%>
</select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="javascript:ReloadPage('1');"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    
    <tr> 
      <td>&nbsp;</td>
      <td height="25">College</td>
	  <%
strCIndex = WI.fillTextValue("c_index");
%>
      <td>

	  <select name="c_index" onChange="ReloadPage('0')" style="width:300px;">
        <option value="">Select College</option>
        <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",strCIndex, false)%>
      </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25">Department&nbsp;&nbsp;&nbsp;</td>
      <td><select name="d_index" onChange="ReloadPage('0')" style="width:300px;">
        <option value="">Select Department</option>
<%
strDIndex = WI.fillTextValue("d_index");
if(strCIndex.length() > 0) {
	strTemp = " from department where is_del=0 and c_index="+strCIndex+" order by d_name";
%>
        <%=dbOP.loadCombo("d_index","d_name",strTemp, strDIndex, false)%>
<%}%>
      </select></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td height="25">Faculty</td>
        <td>
		<select name="emp_id"  onChange="ReloadPage('0')"  style="width:200px;">
			<option value="">Select Faculty</option>
<%
Vector vFacultyList = new Vector();
if(strCIndex.length() > 0) {

strTemp = 
	" select distinct user_table.user_index, id_number, fname, mname, lname  "+
	" from USER_TABLE "+
	" join FACULTY_LOAD on (FACULTY_LOAD.USER_INDEX = USER_TABLE.USER_INDEX) "+
	" join E_SUB_SECTION on (E_SUB_SECTION.SUB_SEC_INDEX = FACULTY_LOAD.SUB_SEC_INDEX) "+
	" where FACULTY_LOAD.IS_VALID =1 "+
	" and E_SUB_SECTION.IS_VALID = 1 "+
	" and OFFERING_SEM = "+strSemester+
	" and OFFERING_SY_FROM = "+strSYFrom+
	" and OFFERED_BY_COLLEGE = "+strCIndex;
if(WI.fillTextValue("d_index").length() > 0)
	strTemp += " and OFFERED_BY_DEPT = "+WI.fillTextValue("d_index");	
strTemp += 
	" order by lname, fname, mname";
 rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vFacultyList.addElement(rs.getString(1));
	vFacultyList.addElement(rs.getString(2));
	vFacultyList.addElement(rs.getString(3));
	vFacultyList.addElement(rs.getString(4));
	vFacultyList.addElement(rs.getString(5));
}rs.close();
}
strTemp = WI.fillTextValue("emp_id");
for(int i = 0; i < vFacultyList.size(); i+=5){
	if(strTemp.equals((String)vFacultyList.elementAt(i+1)))
		strErrMsg = "selected";
	else
		strErrMsg = "";	
%>	
	<option value="<%=(String)vFacultyList.elementAt(i+1)%>" <%=strErrMsg%>><%=WebInterface.formatName((String)vFacultyList.elementAt(i+2),(String)vFacultyList.elementAt(i+3),(String)vFacultyList.elementAt(i+4),4)%><%=WI.getStrValue((String)vFacultyList.elementAt(i+1)," (",")","")%></option>
<%}%>
		</select>		</td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td height="25">Subject</td>
        <td>
		<select name="sub_index"  onChange="ReloadPage('0')" style="width:200px;">
		<option value="">Select All</option>
<%
if(WI.fillTextValue("emp_id").length() > 0){
strTemp = " from e_sub_section join subject on (subject.sub_index = e_sub_section.sub_index) "+
	" where e_sub_section.is_valid =1 "+
	" and OFFERING_SEM = "+strSemester+
	" and OFFERING_SY_FROM = "+strSYFrom+
	" and exists(select * from faculty_load where is_valid = 1 "+
	"   	and sub_sec_index = e_sub_section.sub_sec_index and user_index = (select user_index from user_table where id_number='"+WI.fillTextValue("emp_id")+"'))"+
	" and OFFERED_BY_COLLEGE = "+strCIndex;
if(WI.fillTextValue("d_index").length() > 0)
	strTemp += " and OFFERED_BY_DEPT = "+WI.fillTextValue("d_index");	
strTemp += " order by sub_name ";
%>
		<%=dbOP.loadCombo("distinct e_sub_section.sub_index", "sub_code, sub_name", strTemp, WI.fillTextValue("sub_index"), false)%>
<%}%>		</select>
		</td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td height="25">Section</td>
        <td>
		<select name="section" style="width:200px;">
		<option value="">Select All</option>
<%
if(WI.fillTextValue("emp_id").length() > 0 && WI.fillTextValue("sub_index").length() > 0){
strTemp = " from e_sub_section "+
	" where e_sub_section.is_valid =1 "+
	" and OFFERING_SEM = "+strSemester+
	" and OFFERING_SY_FROM = "+strSYFrom+
	" and is_lec = 0 and is_child_offering = 0 "+
	" and exists(select * from faculty_load where is_valid = 1 "+
	"   	and sub_sec_index = e_sub_section.sub_sec_index and user_index = (select user_index from user_table where id_number='"+WI.fillTextValue("emp_id")+"'))"+
	" and OFFERED_BY_COLLEGE = "+strCIndex+
	" and e_sub_Section.sub_index = "+WI.fillTextValue("sub_index");
if(WI.fillTextValue("d_index").length() > 0)
	strTemp += " and OFFERED_BY_DEPT = "+WI.fillTextValue("d_index");
	
strTemp += " order by section ";
%>
		<%=dbOP.loadCombo("distinct e_sub_section.sub_sec_index", "section", strTemp, WI.fillTextValue("section"), false)%>
<%}%>		
		</select> 
		</td>
    </tr>

    
    
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2" style="font-size:9px;" align="center">
	  
	  Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 20;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 15; i < 70; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>Print Class List.	  </td>
    </tr>
  </table>

   <table width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="showCList" value="">
<input type="hidden" name="print_pg"  value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
