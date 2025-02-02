<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strCollegeName = null; String strCourseName = null;
	String strDegreeType = null;
	
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);

	alert("Click OK to print this page");
	window.print();
}
function ShowList() {
	document.form_.show_list.value='1';
	if(document.form_.major_index) {
		if(document.form_.major_index.selectedIndex > -1)
			document.form_.major_name.value = document.form_.major_index[document.form_.major_index.selectedIndex].text;
	}
}
</script>

<%
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Enrollment list(Accreditation)","CLDH_accreditation.jsp");
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
if(WI.fillTextValue("course_index").length() > 0) {
	strTemp = "select degree_type, c_name, course_name from course_offered "+
			"join college on (college.c_index = course_offered.c_index) "+
			" where course_index = "+WI.fillTextValue("course_index");
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	rs.next();
	
	strDegreeType  = rs.getString(1);
	strCollegeName = rs.getString(2);
	strCourseName  = rs.getString(3);
	rs.close();
}
Vector vRetResult = null;
ReportEnrollment re = new ReportEnrollment();
if(WI.fillTextValue("show_list").length() > 0) {
	vRetResult = re.getCLDHAccreditation(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = re.getErrMsg();
}
%>
<body>
<form action="./CLDH_accreditation.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="25" colspan="4" align="center"><strong><u>:::: Enrollment Summary - Accreditation ::::</u></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td height="25" colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>School Year</td>
      <td>Term</td>
      <td> Remove Section from list
        <input name="remove_section" type="text" size="12" value="<%=WI.fillTextValue("remove_section")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px"> 
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td width="26%">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
      </td>
      <td width="18%"> 
       <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td width="53%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr > 
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="10">&nbsp;</td>
      <td>Course</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr > 
      <td height="20">&nbsp;</td>
      <td colspan="2">
	  <select name="course_index" onChange="document.form_.submit();" style="font-size:11px">
          <option value="">Select Any</option>
          <%=dbOP.loadCombo("course_index","course_code + ' :: ' + course_name",
		  	" from course_offered where degree_type = 0 and IS_DEL=0 and is_valid=1 and is_offered = 1 order by course_code asc", request.getParameter("course_index"), false)%> 
      </select></td>
      <td> <%
if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0 && 
   WI.fillTextValue("names_only").compareTo("1")!=0){%>
        Year : 
        <select name="year_level">
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>1st</option>
<%}else{%>
          <option value="1">1st</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
<%}else{%>
          <option value="2">2nd</option>
<%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
<%}else{%>
          <option value="3">3rd</option>
<%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
<%}else{%>
          <option value="4">4th</option>
<%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
<%}else{%>
          <option value="5">5th</option>
<%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
<%}else{%>
          <option value="6">6th</option>
<%}%>
        </select> <%}%> </td>
    </tr>
    <tr > 
      <td width="4%" height="25">&nbsp;</td>
      <td width="5%">Major </td>
      <td width="60%"><select name="major_index">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
      <td> <%if(strDegreeType != null && strDegreeType.compareTo("3") ==0 
	 && WI.fillTextValue("names_only").compareTo("1") != 0){%>
        Prep or Proper: 
        <select name="prep_prop_stat">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Preparatory</option>
<%}else{%>
          <option value="1">Preparatory</option>
<%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
<%}else{%>
          <option value="2">Proper</option>
<%}%>
        </select> <%}%> </td>
    </tr>
    <tr > 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td width="31%" height="26">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><input type="submit" name="-" value="Show List" onClick="ShowList();"></td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null) {
Vector vSubCode    = (Vector)vRetResult.remove(0);
Vector vSubSection = (Vector)vRetResult.remove(0);

//System.out.println(vSubCode);
//System.out.println(vSubSection);
//System.out.println(vRetResult);


String[] astrConvertToTerm = {"Summer", "1st Sem","2nd Sem","3rd Sem"};
String[] astrConvertToYear = {"", "1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
  <tr>
    <td height="20" colspan="2" align="right" style="font-size:9px;"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> Print Report</td>
  </tr>
  <tr>
    <td height="20" colspan="2" ><div align="center">
	<font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,true)%></font><br>
		SUMMARY OF ENROLMENT PER CLASS AND COURSE<br>
		<%=strCollegeName%><br>
		<%=astrConvertToTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, A Y : <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>		</font></div></td>
  </tr>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr style="font-weight:bold;">
    <td width="68%" height="25">Course/Major : <%=strCourseName%><%=WI.getStrValue(WI.fillTextValue("major_name"), "/","","")%></td>
    <td width="32%" align="right" >Year Level : <%=astrConvertToYear[Integer.parseInt(WI.fillTextValue("year_level"))]%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
	<td class="thinborder" style="font-weight:bold" width="12%">Section List</td>
	<%for(int i = 0; i < vSubCode.size(); i += 2){%>
		<td class="thinborder" width="7%" align="center" height="22"><%=vSubCode.elementAt(i)%></td>
	<%}%>
		<td class="thinborder" width="7%" align="center" height="22">TOTAL</td>
  </tr>
<%
int iCount = 0;
for(int i = 0; i < vSubSection.size(); i += 2){%>
  <tr>
    <td class="thinborder" style="font-weight:bold"><%=vSubSection.elementAt(i)%></td>
	<%for(int p = 0; p < vSubCode.size(); p += 2){
		if(vRetResult.size() > 0 && vRetResult.elementAt(0).equals(vSubCode.elementAt(p)) && vRetResult.elementAt(1).equals(vSubSection.elementAt(i)) ) {
			iCount = Integer.parseInt((String)vRetResult.remove(2));
			vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
		}
		else
			iCount = 0;
		%>
	    <td class="thinborder" align="center" height="22"><%=iCount%></td>
	<%}%>
    <td class="thinborder" align="center" height="22"><%=vSubSection.elementAt(i + 1)%></td>
  </tr>
 <%}%>
  <tr>
    <td class="thinborder" style="font-weight:bold">TOTAL</td>
	<%iCount = 0;
	for(int i = 0; i < vSubCode.size(); i += 2){
		iCount += Integer.parseInt((String)vSubCode.elementAt(i + 1));%>
	    <td class="thinborder" align="center" height="22"><%=vSubCode.elementAt(i + 1)%></td>
	<%}%>
    <td class="thinborder" align="center" height="22"><%=iCount%></td>
  </tr>
</table>
<%}%>
<input type="hidden" name="show_list">
<input type="hidden" name="major_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
