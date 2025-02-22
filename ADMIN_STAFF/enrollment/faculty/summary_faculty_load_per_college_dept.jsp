<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsSWU = strSchCode.startsWith("SWU");
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
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function SearchPage() {
	document.form_.search_page.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage(){
	document.form_.search_page.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPg() {
	
	<%
	if(bolIsSWU){
	%>
	document.form_.print_page.value = "1";	
	document.form_.submit();
	<%}else{%>
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
	<%}%>
}
function GoToDetail() {
	if(document.form_.go_detail.checked) {
		location = "./summary_faculty_load_detailed_per_college_cit.jsp";
		return;
	}
}
</script>

<%
	

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	
	if(WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./summary_faculty_load_per_college_dept_print.jsp"></jsp:forward>
	<%return;}

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-SUMMARY LOAD"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-Summary Load","summary_faculty_load_per_college_dept.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"summary_faculty_load_per_college_dept.jsp");
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
**/
Vector vRetResult = null;
Vector vEmpRec = null;
utility.ConstructSearch conSearch = new utility.ConstructSearch(request);


if(WI.fillTextValue("search_page").length() > 0) {
	enrollment.FacultyManagementExtn fmExtn = new enrollment.FacultyManagementExtn();
	vRetResult = fmExtn.viewSummaryFacultyLoadPerCollege(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = fmExtn.getErrMsg();	
}
String[] astrSortByName    = {"Employee ID","Lastname","Firstname","Faculty Load"};
String[] astrSortByVal     = {"id_number","lname","fname","load_u"};

String[] astrConvertSem ={"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};





int iIndexOf = 0;
boolean bolShowAll    = (WI.fillTextValue("d_index").length() == 0 && WI.fillTextValue("c_index").length() == 0 &&  bolIsSWU);
boolean bolPerCollege = (WI.fillTextValue("d_index").length() == 0 && bolIsSWU);
Vector vCollegeFaculty = new Vector();

String strPTFT = null;
strTemp = "select pt_ft from INFO_FACULTY_BASIC where IS_VALID = 1 and USER_INDEX = (select USER_INDEX from USER_TABLE where ID_NUMBER =?) ";
java.sql.PreparedStatement pstmtPTFT = dbOP.getPreparedStatement(strTemp);
java.sql.ResultSet rs = null;
%>
<body bgcolor="#D2AE72">
<form action="./summary_faculty_load_per_college_dept.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          FACULTY : SUMMARY OF FACULTY LOAD PER COLLEGE/DEPARTMENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="12%" height="25">School Year</td>
      <td width="85%" height="25">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp; 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
		<select name="semester">
		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select>
<%if(strSchCode.startsWith("CIT")){%>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<font style="font-weight:bold; font-size:11px; color:#0000FF">
		<input type="checkbox" onClick="GoToDetail();" name="go_detail"> View Teaching Load Detail
	</font>

<%}%>	
	  &nbsp;&nbsp;&nbsp; 
<%
if(strSchCode.startsWith("EAC") && request.getParameter("sy_from") == null)
	strTemp = " checked";
else
	strTemp = WI.fillTextValue("inc_subname");
%>
	  <input type="checkbox" name="inc_subname" value="checked" <%=strTemp%>> Include Subject Description
		</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">College</td>
      <td height="25"><select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%
	strTemp = WI.fillTextValue("c_index");

if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";
if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25"><select name="d_index">
          <option value="">All</option>
          <%
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and ("+WI.getStrValue(strTemp, "c_index=",""," c_index = 0 or c_index is null")+") order by d_name asc",strTemp3, false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Emp. Status</td>
      <td height="25"><strong> 
        <select name="status">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",strTemp2, false)%> 
        </select>
        </strong></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="97%" height="25"><u>Sort</u></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><select name="sort_by1">
          <option value="">N/A</option>
          <%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> &nbsp; <select name="sort_by2">
          <option value="">N/A</option>
          <%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> &nbsp; <select name="sort_by3">
          <option value="">N/A</option>
          <%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> &nbsp; <select name="sort_by4">
          <option value="">N/A</option>
          <%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> &nbsp; &nbsp; <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> &nbsp; &nbsp; <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> &nbsp; &nbsp; <select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> &nbsp; </td>
    </tr>
    <tr> 
      <td height="39">&nbsp;</td>
      <td><a href="javascript:SearchPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print summary</font></div></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) { //System.out.println(vRetResult.size() + ":::"+vRetResult);%>  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr><td colspan="2"><div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div><br></td></tr>
	<tr><td height="20" align="center"><strong><font size="2"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>,  
	<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></font></strong> 
		
	</td></tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>SUMMARY OF FACULTY LOAD</strong></font></div></td>
    </tr>
    <tr> 
      <td width="13%" height="25" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE ID </strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME </strong></font></div></td>
	   <%if(bolIsSWU){%>
	   <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>EMP. STATUS</strong></font></div></td>
	  <%}
	  strTemp = "TOTAL LOAD UNITS";
	  if(bolIsSWU)
	  	strTemp = "MAXIMUM HOUR LOAD";
	  	
	  %>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong><%=strTemp%></strong></font></div></td>	  
      <td width="10%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">TOTAL LOAD HOUR </td>
      <%if(!bolIsSWU){%><td width="54%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECTS HANDLED</strong></font></div></td><%}%>
    </tr>
 <%

 String strCollegeName = null;
 for(int i = 0; i < vRetResult.size(); i += 6) {
 	
strTemp = (String)vRetResult.elementAt(i);
  if(bolShowAll && strTemp != null){
	
	iIndexOf = strTemp.indexOf(" :::");
	if(iIndexOf > -1)
		strTemp = strTemp.substring(0, iIndexOf);			
	strCollegeName = strTemp;
}

if(strCollegeName != null)
	strTemp = strCollegeName;

 %>
    <tr> 
      <td height="25" colspan="6" class="thinborder" bgcolor="#FFFFDF"> <strong><%=WI.getStrValue(strTemp)%></strong></td>
    </tr>
 <%
 

 
 vRetResult.setElementAt(null,i);
 for(; i < vRetResult.size(); i += 6) {
 	if(  vRetResult.elementAt(i) != null && (!bolPerCollege ||  bolShowAll) ) {
		iIndexOf = -1;
		if(bolShowAll){
			strTemp = (String)vRetResult.elementAt(i);
			
			if(strCollegeName != null)
				iIndexOf = strTemp.indexOf(strCollegeName);
		}
		
		if(iIndexOf == -1)		{
			i -= 6;
			break;
		}
	}
	
	
	
	if(bolPerCollege){
	
		if(vCollegeFaculty.indexOf((String)vRetResult.elementAt(i + 1)) > -1)
			continue;
		
		vCollegeFaculty.addElement((String)vRetResult.elementAt(i + 1));
	}
	
	strPTFT = null;
	pstmtPTFT.setString(1, (String)vRetResult.elementAt(i + 1));
	rs = pstmtPTFT.executeQuery();
	if(rs.next()){
		strPTFT = WI.getStrValue(rs.getString(1));
		if(strPTFT.equals("1"))
			strPTFT = "Full-Time";
		else if(strPTFT.equals("0"))
			strPTFT = "Part-Time";
		else
			strPTFT = "";			
	}rs.close();
	
	%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
	  <%if(bolIsSWU){%>
	   <td width="15%" class="thinborder"><div align="center"><%=WI.getStrValue(strPTFT,"&nbsp;")%></div></td>
	   <%}%>
      <td class="thinborder"><div align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), false)%></div></td>
      <td class="thinborder" align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 4), false)%></td>
      <%if(!bolIsSWU){%><td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td><%}%>
    </tr>
 <%
 
	 
 
 }//inner loop 
 
 }//outer loop.%>
  </table>
<%}//only if vRetResult is not null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="print_page" value="">
<input type="hidden" name="search_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>