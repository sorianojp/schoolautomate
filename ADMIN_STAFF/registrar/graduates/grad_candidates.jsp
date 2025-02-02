<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

if(strSchCode.startsWith("SWU")){
	response.sendRedirect("./grad_candidates_per_student.jsp");
	return;
}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function PageAction(strAction) {

	document.form_.page_action.value =strAction;
	document.form_.print_page.value="";
	if(strAction == 1)
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function ReloadPage() {

	document.form_.page_action.value = "-1";
	document.form_.print_page.value="";
	this.SubmitOnce('form_');
}

function DeleteRecord(strIndex){
	document.form_.page_action.value="0";
	document.form_.info_index.value= strIndex;
	document.form_.print_page.value="";
	this.SubmitOnce('form_');
}

function PrintPage(){
	document.form_.page_action.value="-1";
	document.form_.print_page.value="1";
	this.SubmitOnce('form_');
}

function checkAll(){
	var iCtr =  document.form_.iCount.value;

	if (document.form_.selectAll.checked)	{
		for (var i = 0; i < iCtr; i++)
			eval('document.form_.checkbox'+i+'.checked=true'); 
	}else{
		for (var i = 0; i < iCtr; i++)
			eval('document.form_.checkbox'+i+'.checked=false'); 
	}
}

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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=104&all=1&course_ref="+objCourseInput;
		this.processRequest(strURL);
}
function encodeCanGrad() {
	location = './grad_candidate_encode.jsp';
}
//end of ajax to finish loading.. 
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolShowEditInfo = false;
//add security here.
	if (WI.fillTextValue("print_page").length()>0){
		if(strSchCode.startsWith("CSA")){%>
				<jsp:forward page="grad_candidates_print_csa.jsp" />
		<%}else{%>
				<jsp:forward page="grad_candidates_print.jsp" />
		<%}
		return; 
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_candidates.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_candidates.jsp");
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

Vector vRetResult = null;
EntranceNGraduationData eng = new EntranceNGraduationData();
Vector vRetCandidates = null;

if (WI.fillTextValue("page_action").compareTo("1") == 0){
	vRetCandidates = eng.operateOnCandidatesList(dbOP,request,1);
	if (vRetResult != null){
		strErrMsg = "Student(s) added to the list of graduating students";
	}else{
		strErrMsg = eng.getErrMsg();
	}
	
}else if (WI.fillTextValue("page_action").compareTo("0") == 0) {
	vRetCandidates = eng.operateOnCandidatesList(dbOP,request,0);
	if (vRetCandidates != null)
		strErrMsg = "Student removed from the list of candidates for graduation";
	else
		strErrMsg = eng.getErrMsg();
}

vRetResult = eng.viewAllGraduatingStudents(dbOP,request);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = eng.getErrMsg();
	
vRetCandidates = eng.operateOnCandidatesList(dbOP,request,4);

if (vRetCandidates == null) 
	vRetCandidates = new Vector();
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};

boolean bolIsUDMC = strSchCode.startsWith("UDMC");

%>
<form name="form_" action="./grad_candidates.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CANDIDATES OF GRADUATION MANAGEMENT PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="97%" height="25" colspan="4" ><font size="2"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" ><font size="1"><strong>SY</strong></font></td>
      <td width="60%" height="25" >
<%
	if (WI.fillTextValue("sy_from").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}else{
		strTemp = WI.fillTextValue("sy_from");
	}
%>
	  <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
	if (WI.fillTextValue("sy_to").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}else{
		strTemp = WI.fillTextValue("sy_to");
	}
%>
        <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4">
        &nbsp;<strong><font size="1">&nbsp;SEMESTER : &nbsp;</font></strong>&nbsp; 
<%
	if (WI.fillTextValue("semester").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	}else{
		strTemp = WI.fillTextValue("semester");
	}
%>
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
<%
if(strTemp == null) strTemp = "";
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
      <td width="29%" align="right">
	  <!--<a href="javascript:encodeCanGrad();">Encode Graduating List</a>	  --></td>
    </tr>
	<tr>
	   <td height="25" >&nbsp;</td>
       <td><strong><font size="1">COLLEGE </font></strong></td>
       <td><% 	strTemp = WI.fillTextValue("college");%>
        <select name="college" onChange="ReloadPage();">
          <option value="">Select a College</option>
			<%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name", 
			request.getParameter("college"), false)%> 
        </select></td>
	</tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="8%" height="25" ><strong><font size="1">COURSE </font></strong></td>
      <td height="25" colspan="2" > 
<% 	
strTemp = WI.fillTextValue("course_index");

%> <select name="course_index" onChange="loadMajor();">
          <option value="">Select a Course</option>
      <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND (IS_VALID=1 or IS_VALID=2) "+
	   WI.getStrValue(WI.fillTextValue("college"),"and c_index=","","")+" order by course_name asc",	strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" ><strong><font size="1">MAJOR</font></strong></td>
      <td height="25" colspan="2" > 
<label id="load_major">
			<select name="major_index">
          <option value="">ALL</option>
		  <%if(strTemp.length() > 0) {%>
          	<%=dbOP.loadCombo("major_index","major_name"," from	 major where IS_DEL=0 and course_index = " + WI.fillTextValue("course_index") + " order by major_name asc",	WI.fillTextValue("major_index"), false)%> 
		  <%}%>
		  </select> 		  
</label>		</td>
    </tr>
<%if(bolIsUDMC || true){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  	<a href="./grad_candidates_with_req_unit.jsp" style="text-decoration:none;">
			Click here to go to Graduate list (with # unit as parameter)		</a>	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="35" >&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2" ><a href="javascript:ReloadPage()"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click 
        to view list of students</font></td>
    </tr>
  </table>
<% int iCtr = 0;
	if (vRetResult != null && vRetResult.size() > 0){ 
	
	String strRemarks= "remarks";
	
%>
  <table width="100%" border="1" cellspacing="0" cellpadding="2" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6"> <div align="right"> 
          <% if (iAccessLevel > 1){ %>
          <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          <font size="1">click to save all entries</font> 
          <%}%>
        </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="6" bgcolor="#999966"><div align="center"><strong>LIST 
          OF TENTATIVE STUDENTS FOR GRADUATION</strong></div></td>
    </tr>
    <tr> 
      <td width="3%"><strong><font size="1">NO.</font></strong></td>
      <td width="12%" height="22"><font size="1"><strong>ID NUMBER </strong></font></td>
      <td width="23%"><font size="1"><strong>NAME</strong></font></td>
      <td width="7%"><div align="center"><strong><font size="1">SELECT <br>
          <input type="checkbox" name="selectAll" onClick="checkAll()">
          </font></strong></div></td>
      <td width="50%"><strong><font size="1">&nbsp;&nbsp;MISSING REQUIREMENTS/SUBJECTS (optional)</font></strong></td>
    </tr>
    <%  for(int i =0; i < vRetResult.size() ; i+=5,iCtr++) {  
		//if (vRetCandidates.indexOf((String)vRetResult.elementAt(i)) != -1){
		//--iCtr; continue;
		//} //wrong way to do index of - never use user_index to remove data , integrated in query using not exist
	%>
    <tr> 
      <td><font size="1"><%=iCtr+1%>)</font></td>
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td align="center"><input type="checkbox" name="checkbox<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i)%>"></td>
      <td><textarea name="<%=strRemarks+iCtr%>" class="textbox" rows="4" cols="45"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  style="font-size:11px"></textarea></td>
    </tr>
    <%} //end for loop i< vRetResult.size() %>
    <tr> 
      <td height="25" colspan="5"><div align="right"><font size="1"> 
          <% if (iAccessLevel > 1){ %>
          <a href="javascript:PageAction(1);"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          click to save entries 
          <%}%>
          </font></div></td>
    </tr>
  </table>
<input type="hidden" name="iCount" value="<%=iCtr%>">

<%}  // end vretResult list not null
	if (vRetCandidates !=null && vRetCandidates.size() > 0) {%>
  <table width="100%" border="1" cellspacing="0" cellpadding="2" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="6">
<hr size="1"></td>
    </tr>
    <tr bgcolor="#339999"> 
      <td height="25" colspan="6"><div align="center"><strong>CANDIDATES FOR GRADUATION 
          </strong></div></td>
    </tr>
    <tr> 
      <td width="5%"><strong><font size="1">NO.</font></strong></td>
      <td width="10%" height="22"><font size="1"><strong>ID NUMBER </strong></font></td>
      <td width="21%"><font size="1"><strong>NAME</strong></font></td>
      <td width="10%"><strong><font size="1">STATUS</font></strong></td>
      <td width="40%"><strong><font size="1">REMARKS</font></strong></td>
      <td width="14%">&nbsp;</td>
    </tr>
    <% iCtr = 1;
		 for(int i =0; i < vRetCandidates.size() ; i+=7) {  %>
    <tr> 
      <td><font size="1"><%=iCtr++%>)</font></td>
      <td height="25"><font size="1">&nbsp;<%=(String)vRetCandidates.elementAt(i+2)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetCandidates.elementAt(i+3)%></font></td>
      <td><font size="1"><%=(String)vRetCandidates.elementAt(i+4)%></font></td>
      <td><font size="1">
	  <%=ConversionTable.replaceString(WI.getStrValue((String)vRetCandidates.elementAt(i+5),"&nbsp"),"\n\r","<br>")%></font></td>
      <td>&nbsp; <% if(iAccessLevel == 2) { %> <a href="javascript:DeleteRecord('<%=(String)vRetCandidates.elementAt(i)%>')"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%>
        N/A 
        <%}%> </td>
    </tr>
    <%}//end for loop of candidates%>
	<tr>
		
      <td colspan="6" align="center" style="font-size:11px;">
	  <input name="print_stat" type="radio" value="0" checked="checked">Print All 
	  <input name="print_stat" type="radio" value="1">Print only Passed Student 
	  <input name="print_stat" type="radio" value="2">
	  Print student with Pending
	  
	  <a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">Print list</font></td>
	</tr>
  </table>
<%} // end vRetCandidates = null%>
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
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="print_page">
<input type="hidden" name="new_id_entered" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="parent_wnd" value="<%=WI.fillTextValue("parent_wnd")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
