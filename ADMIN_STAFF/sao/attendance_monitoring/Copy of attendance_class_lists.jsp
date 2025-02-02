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
<style type="text/css">
table#classgrid {
	font-family: verdana,arial,sans-serif;
	font-size:7pt;
	color:#333333;
	border: 1px solid #666666;
	border-collapse: collapse;
}
table#classgrid td {
	font-size:7pt;
	border: 1px solid #666666;
	background-color: #ffffff;
}
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.bgColor = "#FFFFFF";

	document.getElementById("idNumber1").deleteRow(0);
	document.getElementById("idNumber1").deleteRow(0);
	document.getElementById("idNumber1").deleteRow(0);
	document.getElementById("idNumber1").deleteRow(0);	
	document.getElementById("idNumber1").deleteRow(0);
	
	document.getElementById("idNumber2").deleteRow(0);
	document.getElementById("idNumber2").deleteRow(0);
	document.getElementById("idNumber2").deleteRow(0);	
	document.getElementById("idNumber2").deleteRow(0);
	document.getElementById("idNumber2").deleteRow(0);
	
	
	document.getElementById("idNumber3").deleteRow(0);
	document.getElementById("idNumber3").deleteRow(0);	
	document.getElementById("idNumber3").deleteRow(0);
	
	document.getElementById("idNumber4").deleteRow(0);
	document.getElementById("idNumber4").deleteRow(0);

	
	
	document.getElementById("idNumber6").deleteRow(0);
	
	

	window.print();
}
function ReloadPage()
{	
	document.form_.action ="./attendance_class_lists.jsp";
	document.form_.submit();
}
function ShowCList()
{
	document.form_.action ="./attendance_class_lists.jsp";
	document.form_.showCList.value="1";
	ReloadPage();
}
function ChangeCourse()
{
	document.form_.showCList.value="";
	ReloadPage();
}
function ChangeMajor()
{
	document.form_.showCList.value="";
	ReloadPage();
}
function ViewAll() {
	if(document.form_.view_all_sec.value.length == 0) 
		alert("No section list found.");
	else {
		document.form_.subject_name.value = document.form_.subject[document.form_.subject.selectedIndex].text;
		document.form_.section_name.value = document.form_.section[document.form_.section.selectedIndex].text;
		document.form_.view_all.value = "1";
		document.form_.target="_blank";
		document.form_.action ="./class_lists_showall.jsp";
		document.form_.submit();
	}	
}
function ChangeSubject() {
	document.form_.sub_code_.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	ReloadPage();
}
</script>

<body>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	String strDegreeType = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-class list","class_lists.jsp");	
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
														null);
iAccessLevel = 2;
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

Vector vSecList = null;
Vector vSubList = null;
Vector vSecDetail = null;
Vector vClassList = null;

ReportEnrollment reportEnrl= new ReportEnrollment();
String strSubSecIndex = null;

if (WI.fillTextValue("sub_sec_index").length() == 0 ){
	if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
		strSubSecIndex =
			dbOP.mapOneToOther("E_SUB_SECTION join faculty_load " +
					 " on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
					"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index",
					" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
					" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
					WI.fillTextValue("sy_from")+ " and e_sub_section.offering_sy_to = "+
					WI.fillTextValue("sy_to")+ " and e_sub_section.offering_sem="+
					WI.fillTextValue("offering_sem")+" and is_lec=0");
	}
}
else
	strSubSecIndex = WI.fillTextValue("sub_sec_index");

if(strSubSecIndex != null && strSubSecIndex.length() > 0) {//get here subject section detail.
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
	//vStudListWithDropSub = gsExtn.getStudListWithSubStatChanged(dbOP, strSubSecIndex);
}

if(vSecDetail != null && vSecDetail.size() > 0 && WI.fillTextValue("showCList").length() > 0 && WI.fillTextValue("month_of").length() > 0)
{
	vClassList = reportEnrl.getClassList(dbOP,request);
	if(vClassList == null)
		strErrMsg = reportEnrl.getErrMsg();
	
}
if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("course_index").compareTo("0") != 0)
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",WI.fillTextValue("course_index"),"DEGREE_TYPE", " and is_valid=1 and is_del=0");
if(strErrMsg == null) strErrMsg = "";


String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
%>
<form name="form_" method="post" action="attendance_class_lists.jsp">
	
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0" id="idNumber1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          REPORTS - ATTENDANCE SHEET PAGE ::::        
          </strong></font></div></td>
    </tr>
  

<input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
<input type="hidden" name="prevent_fwd" value="<%=WI.fillTextValue("prevent_fwd")%>">
<input type="hidden" name="show_delete">
<input type="hidden" name="show_save">
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>

    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp; 

	  <strong><font color="blue">NOTE: Subject/Sections appear are the sections handled by the logged in faculty Employee ID: <%=strEmployeeID%></font></strong>	  </td>
    </tr>
    <tr>
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="27%" valign="bottom" >School Year</td>
      <td colspan="2" >&nbsp; </td>
      <td width="8%" >&nbsp;</td>
    </tr>
<%
String strTerm = WI.fillTextValue("offering_sem");
%>
    <tr>
      <td valign="bottom" >
	  <select name="offering_sem" onChange="ReloadPage();">
	  
          <option value="1">1st Sem</option>
          <%
if(strTerm.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTerm.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}if(strTerm.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select></td>
      <td valign="bottom" >
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes">      </td>
      <td colspan="2" >
	  	<a href="javascript:ShowCList();"><img src="../../../images/form_proceed.gif" border="0"></a>	  
		 &nbsp;&nbsp;&nbsp;
		 Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 25;
if(WI.fillTextValue("rows_per_pg").length() > 0) 
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i =25; i < 60; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	  <option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	 
		</td>
      <td width="8%" >&nbsp;</td>
    </tr>
</table>
  

<%
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0){
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="idNumber2">
    <tr>
      <td width="1%"></td>
      <td width="39%" height="25" valign="bottom" >Section Handled</td>
      <td valign="bottom" >Instructor (Name of logged in user)</td>
    </tr>
    <tr>
      <td></td>
      <td height="25" >
        <%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
			"faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and e_sub_section.OFFERING_SY_FROM ="+
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem")+" and faculty_load.user_index = "+
			strEmployeeIndex;
%>
        <select name="section_name" onChange="ReloadPage();">
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("distinct section","section",strTemp, request.getParameter("section_name"), false)%>
        </select> </td>
      <td height="25" > <strong>
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%>
        <%}%>
        </strong> </td>
    </tr>
    <tr>
      <td width="1%"></td>
      <td height="25">Subject Handled</td>
      <td>Subject Title </td>
    </tr>
    <tr>
      <td width="1%"></td>
      <td height="25" >
        <%
strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
			"join subject on (e_sub_section.sub_index = subject.sub_index) where faculty_load.user_index = "+
			strEmployeeIndex+" and e_sub_section.section = '"+WI.fillTextValue("section_name")+
			"' and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
			WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
			" and e_sub_section.offering_sem="+WI.fillTextValue("offering_sem");
			
//System.out.println(strTemp);%>
        <select name="subject" onChange="ReloadPage();" >
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("subject"), false)%>
        </select></td>
      <td> <strong>
        <%
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>
      <%=WI.getStrValue(strTemp)%></strong></td>
      <%}%>
    </tr>
    <tr>
        <td></td>
        <td height="25" >Month : 
		<select name="month_of">          
          <%=dbOP.loadComboMonth(null)%>
        </select>
		</td>
        <td>&nbsp;</td>
    </tr>
  </table>
<%
}

if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF" id="idNumber3">
    <tr>
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr>
      <td>&nbsp;</td>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>

  
  </table>
<%}
  

if(vClassList != null && vClassList.size()> 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="idNumber6">
	<tr >
        <td height="25">&nbsp;</td>
        <td width="50%" style="font-size:9px;"><div align="right">
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print list</font></div></td>
    </tr>
</table>
<%

String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAdd  = SchoolInformation.getAddressLine1(dbOP, true, false);

int iIndexOf = 0;
int k = 0;

boolean bolShowPageBreak = false;

int iNoOfStudPerPage = 26;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));

int iStudPrinted = 0;
int iTotalStud = Integer.parseInt( (String)vClassList.elementAt(0));
int iStudCount = 1;
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud %iNoOfStudPerPage > 0)
	++iTotalPageCount;
int iPageCount = 1;
String strDispPageNo = null;

for(int i=1; i<vClassList.size();){
strDispPageNo = Integer.toString(iPageCount)+" of "+Integer.toString(iTotalPageCount);
++iPageCount;
iStudPrinted = 0;

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
	<tr>
	<%
	String[] astrMonth = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
	%>
	<td colspan="2" align="center">
	<%=strSchName%><br>
	<%=strSchAdd%><br>
	<font size="3"><strong>ATTENDANCE SHEET</strong></font><br>
	MONTH : <strong><%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))].toUpperCase()%></strong>
	</td>
	</tr>
    <tr >
      <td >&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr >
      <td >Instructor:     <%if(vSecDetail != null){%>
        <strong><%=WI.getStrValue(vSecDetail.elementAt(0))%> </strong>
      <%}%></td>
      <td>Section: <strong><%=request.getParameter("section_name")%></strong></td>
    </tr>
    <tr >
      <td >Subject Code: <%
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_code"," and is_del=0");
%>
      <strong><%=WI.getStrValue(strTemp)%></strong>
      <%}%></td>
      <td >Subject Title: <%
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>
      <strong><%=WI.getStrValue(strTemp)%></strong>
      <%}%></td>
    </tr>
    <tr >
      <td >Total Students enroled: <strong><%=(String)vClassList.elementAt(0)%></strong></td>
      <td >&nbsp;</td>
    </tr>
    <tr >
      <td  width="50%">&nbsp;</td>
      <td width="50%">&nbsp;</td>
    </tr>
</table>


  <table width="100%" border="1" cellpadding="0" cellspacing="0" id="classgrid">
    <tr>
      <td  align="center">&nbsp;</td>
      <td  height="20" align="center"><strong>STUDENT
        ID</strong></td>
      <td  height="20" align="center"><strong>STUDENT
      NAME</strong></td>
      <td align="center"><strong>COURSE</strong></td>
      <td align="center">01</td>
      <td  align="center">02</td>
      <td align="center">03</td>
      <td  align="center">04</td>
      <td  align="center">05</td>
      <td align="center">06</td>
      <td align="center">07</td>
      <td align="center">08</td>
      <td align="center">09</td>
      <td  align="center">10</td>
      <td  align="center">11</td>
      <td  align="center">12</td>
      <td  align="center">13</td>
      <td align="center">14</td>
      <td  align="center">15</td>
      <td align="center">16</td>
      <td align="center">17</td>
      <td align="center">18</td>
      <td align="center">19</td>
      <td align="center">20</td>
      <td align="center">21</td>
      <td align="center">22</td>
      <td align="center">23</td>
      <td align="center">24</td>
      <td align="center">25</td>
      <td  align="center">26</td>
      <td align="center">27</td>
      <td align="center">28</td>
      <td align="center">29</td>      
      <td  align="center">30</td>
      <td  align="center">31</td>
    </tr>
<%





for(; i<vClassList.size(); i+=8){

if(iStudPrinted++ == iNoOfStudPerPage) {
	bolShowPageBreak = true;
	break;
}

strTemp = WI.getStrValue(vClassList.elementAt(i+3)," ");

if(strTemp.length() > 1 ) {
	iIndexOf = strTemp.indexOf(" ",1);
	if(iIndexOf > -1 && strTemp.length() > (iIndexOf + 1) )
		strTemp = String.valueOf(strTemp.charAt(0))+"."+strTemp.charAt(iIndexOf + 1);
	else	
		strTemp = String.valueOf(strTemp.charAt(0));
}
%>
    <tr>
      <td><%=++k%></td>
      <td height="25"><%=(String)vClassList.elementAt(i)%></td>
      <td><%=(String)vClassList.elementAt(i+1)%>, <%=(String)vClassList.elementAt(i+2)%> <%=strTemp%></td>
      <td><%=(String)vClassList.elementAt(i+4)%><!-- <%=WI.getStrValue(vClassList.elementAt(i+5),"&nbsp;")%>--> <%=WI.getStrValue(vClassList.elementAt(i+6),"N/A")%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%}%>
  </table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="3%" height="18">&nbsp;</td>
    <td width="73%" valign="top">&nbsp;</td>
    <td width="24%" valign="top"><div align="right">page <strong><%=strDispPageNo%></strong></div></td>
  </tr>
</table>
<!-- introduce page break here -->
<% if(bolShowPageBreak){
bolShowPageBreak = false;
%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//do not print for last page.

}%>
 

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="idNumber4">
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print list</font></div></td>
    </tr>
 </table>
<%		}//if vClassList is not null;

%>
  




<input type="hidden" name="is_firsttime" value="0" >
<input type="hidden" name="subject_name" >
<input type="hidden" name="section_name" >
<input type="hidden" name="course_name" >
<input type="hidden" name="showCList" value="" >

<input type="hidden" name="sub_code_" value="<%=WI.fillTextValue("sub_code_")%>" >
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
