<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "CIT";
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
	
	if(WI.fillTextValue("print_pg").equals("1")){
		if(bolIsCIT || strSchCode.startsWith("SWU")) {%>
			<jsp:forward page="./class_list_cit_print.jsp" />
		<%}
		else if(false && strSchCode.startsWith("SWU")){%>
			<jsp:forward page="./class_list_swu_print.jsp" />
		<%}
		else if(strSchCode.startsWith("UC")){%>
			<jsp:forward page="./class_list_uc_print.jsp" />
		<%}
		else if(strSchCode.startsWith("UB")){%>
			<jsp:forward page="./class_list_ub_print.jsp" />
		<%}
		else if(strSchCode.startsWith("NEU")){%>
			<jsp:forward page="./class_list_neu_cr_excel.jsp" />
		<%}
		else{%>
			<jsp:forward page="./class_list_uc_print.jsp" />
		<%}
		return;}
	
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
														"class_list_cit.jsp");
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
<form action="./class_list_cit.jsp" method="post" name="form_">
<%
enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();
Vector vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,WI.fillTextValue("section"));
if(vSecDetail != null && vSecDetail.size() > 0){%>
<div id="processing" class="processing">
<table width="100%" border="0" cellspacing="1" cellpadding="1">
    <tr>
        <td colspan="3" align="center">CLASS SCHEDULE</td>
     </tr>
	 <tr>
        <td valign="top">FACULTY : </td>
        <td colspan="2"><%=WI.getStrValue(vSecDetail.elementAt(0))%></td>
      </tr>
    <tr>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      </tr>
    <%}%>
    <tr>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      </tr>
  </table>
</div>
<%}%>



  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          REPORTS - CLASS LIST PER DEPARTMENT OFFERING PAGE ::::
        
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
      <td height="25">Faculty ID</td>
      <td>
	  <input name="emp_id" type="text" size="16" class="textbox" value="<%=WI.fillTextValue("emp_id")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
	  <label id="coa_info" style="position:absolute"></label>	  </td>
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
      <td height="25">Department&nbsp;&nbsp;&nbsp;</td>
      <td><select name="d_index" onChange="ReloadPage('0')">
        <option value="">ALL</option>
<%
strDIndex = WI.fillTextValue("d_index");
if(strCIndex.length() > 0) {
	strTemp = " from department where is_del=0 and c_index="+strCIndex ;
%>
        <%=dbOP.loadCombo("d_index","d_name",strTemp, strDIndex, false)%>
<%}%>
      </select></td>
    </tr>
<%
if(strSchCode.startsWith("SWU")){
%>	
	<tr> 
      <td>&nbsp;</td>
      <td valign="bottom">Subject Code : </td><td colspan="3"> <font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px"
		 onBlur="ReloadPage('0')" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');">
        (enter subject code to scroll the list)</font></td>
    </tr>
<%}%>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Subject Code </td>
      <td>
	  <select name="sub_index" onChange="ReloadPage('0')" style="font-size:11px;">
        <option value="">ALL</option>
<%if(false) {//now i have to load the default.. 
if(strCIndex.length() > 0) {
	strTemp = " from subject where is_del = 0 and exists (select * from e_sub_section where is_valid = 1 and offering_sy_from = "+WI.fillTextValue("sy_from")+
				" and subject.sub_index = e_sub_section.sub_index and offering_sem = "+WI.fillTextValue("semester")+" and offered_by_college = "+strCIndex; 
	if(strDIndex.length() > 0) 
		strTemp += " and offered_by_dept = "+strDIndex;
	strTemp += ") order by sub_code ";		

%>

        <%=dbOP.loadCombo("sub_index","sub_code, sub_name",strTemp, WI.fillTextValue("sub_index"), false)%>
<%}
}%>

<%if(strSYFrom != null && strSYFrom.length() > 0) { 
	strTemp = " from subject where is_del = 0 and exists (select * from e_sub_section where is_valid = 1 and offering_sy_from = "+strSYFrom+
				" and subject.sub_index = e_sub_section.sub_index and offering_sem = "+strSemester;//System.out.println(strTemp);
	if(strCIndex.length() > 0)
		strTemp += " and offered_by_college = "+strCIndex; 
	if(strDIndex.length() > 0) 
		strTemp += " and offered_by_dept = "+strDIndex;
	strTemp += ") order by sub_code ";		

%>

        <%=dbOP.loadCombo("sub_index","sub_code, sub_name",strTemp, WI.fillTextValue("sub_index"), false)%>
<%}%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Section</td>
      <td>
	  <select name="section" style="font-size:11px;" <%if(strSchCode.startsWith("SWU")){%>onChange="ReloadPage('0')"<%}%>>
        <option value="">ALL</option>
<%
if(WI.fillTextValue("sub_index").length() > 0) {
	strTemp = " from e_sub_section where sub_index = "+WI.fillTextValue("sub_index")+" and is_valid = 1 and "+
				" offering_sy_from = "+WI.fillTextValue("sy_from") + 
				" and offering_sem = "+WI.fillTextValue("semester");
	if(strCIndex.length() > 0) 
		strTemp +=" and offered_by_college = "+strCIndex; 
	if(strDIndex.length() > 0) 
		strTemp += " and offered_by_dept = "+strDIndex;
	
	strTemp += " and is_lec = 0 and is_child_offering = 0 and exists (select * from enrl_final_cur_list where is_temp_stud = 0 and sy_from = offering_sy_from "+
				" and current_semester = offering_sem and enrl_final_cur_list.sub_sec_index = e_sub_section.sub_sec_index and is_valid = 1)  order by section ";		

%>

        <%=dbOP.loadCombo("sub_sec_index","section",strTemp, WI.fillTextValue("section"), false)%>
<%}%>
      </select>	  	  </td>
    </tr>
<%if(strSchCode.startsWith("NEU")){%>
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="2">
	   <input type="radio" name="show_1" value="3" checked> Print to EXCEL Official Class Record
	   </td>
    </tr>

<%}else{%>
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="2">
<%
strErrMsg = "";
strTemp = WI.fillTextValue("show_1");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = " checked";
%>
	  <input type="radio" name="show_1" value="0" <%=strErrMsg%>> Temp Class List &nbsp;&nbsp;
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_1" value="1" <%=strErrMsg%>> Final Class List &nbsp;&nbsp;
<%if(bolIsCIT){
	if(strTemp.equals("2"))
		strErrMsg = " checked";
	else	
		strErrMsg = "";
	%>
		  <input type="radio" name="show_1" value="2" <%=strErrMsg%>> Official Class Record	  
		  
<%}if(strSchCode.startsWith("UC") || bolIsCIT){
	if(strTemp.equals("3"))
		strErrMsg = " checked";
	else	
		strErrMsg = "";
	%>
		  <input type="radio" name="show_1" value="3" <%=strErrMsg%>> Print to EXCEL Official Class Record
<%}if(strSchCode.startsWith("UB")){%>
		  <br>
		  <input type="checkbox" name="show_graduating" value="checked" <%=WI.fillTextValue("show_graduating")%>> Show Graduating Student
		  &nbsp;&nbsp;&nbsp;
		  <input type="checkbox" name="show_adm_no" value="checked" <%=WI.fillTextValue("show_adm_no")%>> Show Admission Number
		  <select name="pmt_schedule">
			  <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
		  </select>
		  
<%}%>		
<%if(strSchCode.startsWith("CIT")){%>
		  <br>
		  <input type="checkbox" name="show_notvalidated" value="checked" <%=WI.fillTextValue("show_notvalidated")%>> Show Student Not Validated		  
		  &nbsp;&nbsp;
		  <input type="checkbox" name="show_advised_date" value="checked" <%=WI.fillTextValue("show_advised_date")%>> Show Advised Date		  
<%}%>		

</td>
    </tr>
<%}%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2" style="font-size:9px;" align="center">
	  
	  Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 50;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 45; i < 70; ++i) {
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
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
