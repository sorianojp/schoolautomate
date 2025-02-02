<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
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
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=104&all=1&course_ref="+objCourseInput;
		this.processRequest(strURL);
}
//end of ajax to finish loading..

function showList(){
	document.form_.show_data.value="1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}
function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");	
} 
function ReloadPage(){
	document.form_.show_data.value="";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.OverideParameter,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//add security here.

	if (WI.fillTextValue("print_page").length()>0){%>
		<jsp:forward page="overload_student_report_print.jsp" />
		<%return; 
	}

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Override Parameters","overload_student_report.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
		<%return;
	}	
	
//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Override Parameters",request.getRemoteAddr(),
														null);
	if(iAccessLevel == 0)
		iAccessLevel = iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Reports",request.getRemoteAddr(),
														null);
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
		
	OverideParameter OP = new OverideParameter();
	
	Vector vRetResult = null;
	if(WI.fillTextValue("show_data").length() > 0){	
		vRetResult = OP.getStudentWithOverloadReport(dbOP,request);
		if(vRetResult == null)
			strErrMsg = OP.getErrMsg();	
	}	
	
%>
<form name="form_" action="./overload_student_report.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5" bgcolor="#A49A6A">
	  <div align="center"><font color="#FFFFFF"><strong>:::: REPORT ON STUDNET'S WITH OVERLOAD ::::</strong></font></div>
	  </td>
    </tr>
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="97%" height="25" colspan="4" ><font size="2"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="4%" height="25" ><font size="1"><strong>SY</strong></font></td>
      <td width="93%" height="25" >
<%	if (WI.fillTextValue("sy_from").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}else{
		strTemp = WI.fillTextValue("sy_from");
	}
%>
      <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
<%	if (WI.fillTextValue("sy_to").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}else{
		strTemp = WI.fillTextValue("sy_to");
	}
%>
      <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4">
        &nbsp;<strong><font size="1">&nbsp;SEMESTER : &nbsp;</font></strong>&nbsp;
<%	if (WI.fillTextValue("semester").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	}else{
		strTemp = WI.fillTextValue("semester");
	}
%>
        <select name="semester">
          <option value="1">1st Sem</option>
          <%if(strTemp == null) 
			 strTemp = "";
		    if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
    </tr>
	<tr>
	   <td width="3%" height="25" >&nbsp;</td>
       <td width="8%" height="25" ><strong><font size="1">COLLEGE </font></strong></td>
       <td width="89%" height="25" ><% 	strTemp = WI.fillTextValue("college");%>
        <select name="college" onChange="ReloadPage();">
          <option value="">Select a College</option>
			<%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name", 
			request.getParameter("college"), false)%> 
        </select></td>
	</tr>
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="8%" height="25" ><strong><font size="1">COURSE </font></strong></td>
      <td width="89%" height="25" >
	  <% strTemp = WI.fillTextValue("course_index");	  
	     strTemp2 = " from course_offered where IS_DEL=0 AND (IS_VALID=1 or IS_VALID=2)" 
		 + WI.getStrValue(WI.fillTextValue("college"),"and c_index=","","")
		 + "order by course_name asc";
		 
	  %>
        <select name="course_index">
          <option value="">Select a Course</option>
          <%=dbOP.loadCombo("course_index","course_name",strTemp2,	strTemp, false)%>
        </select></td>
    </tr>
	 <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" ><strong><font size="1">MAJOR</font></strong></td>
      <td height="25" > 
<label id="load_major">
			<select name="major_index">
          <option value="">ALL</option>
		  <%if(strTemp.length() > 0) {%>
          	<%=dbOP.loadCombo("major_index","major_name"," from	 major where IS_DEL=0 and course_index = " + WI.fillTextValue("course_index") + " order by major_name asc",	WI.fillTextValue("major_index"), false)%> 
		  <%}%>
		  </select> 		  
</label>		  
		</td>
    </tr>
	<tr>
		<td height="10" colspan="3">&nbsp;</td>
	</tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >
	  <a href="javascript:showList()"%><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a>
		</td>
    </tr>
    <tr>
      <td height="30" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <% int iCtr = 0;
	if (vRetResult!=null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="9%" align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="1" cellspacing="0" cellpadding="2" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" ><div align="center"><strong>REPORT ON STUDNET'S WITH OVERLOAD </strong></div></td>
    </tr>
    <tr>
      <td width="4%" align="center"><strong><font size="1">NO.</font></strong></td>
      <td width="24%"  align="center"><font size="1"><strong>NAME OF STUDENT</strong></font></td>
      <td width="11%"  align="center"><strong><font size="1">COURSE / YEAR</font></strong></td>
      <td width="12%" align="center"><strong><font size="1">MAX. UNITS ALLOWED</font></strong></td>
      <td width="12%"  align="center"><strong><font size="1">OVERLAOD UNITS</font></strong></td>
      <td width="11%"  align="center"><strong><font size="1">NEW TOTAL MAX UNITS ALLOWED</font></strong></td>
      <td width="15%"  align="center"><strong><font size="1">APPROVED BY</font></strong></td>
	  <td width="11%"  align="center"><strong><font size="1">APPROVED DATE</font></strong></td>
    </tr>
    <% 
	   for(int i =0; i < vRetResult.size() ; i+=9) {  %>
    <tr>
      <td><font size="1"><%=++iCtr%>)</font></td>
      <td height="25"><font size="1">
	  <%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+2)%> - <%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),""," units","")%> </font></td>
      <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),""," units","")%> </font></td>
	  <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),""," units","")%></font></td>
      <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+7))%></font></td>
      <td width="11%"><font size="1">
	  <%=(String)vRetResult.elementAt(i+8)%></font> </td>
    </tr>
    <%}//end for loop of candidates%>
  </table>
  <%} // end vRetResult!= null && vRetResult.size()>0%>
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
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_data"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
