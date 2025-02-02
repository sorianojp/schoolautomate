<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;

if(WI.fillTextValue("print_page").length() > 0) {
strTemp = WI.fillTextValue("print_option");
if(strTemp.equals("0")){%>
<jsp:forward page="./certificate_print.jsp"></jsp:forward>
<%}
else if(strTemp.equals("1")){%>
<jsp:forward page="./gwa_print.jsp"></jsp:forward>
<%}
else if(strTemp.equals("2")){%>
<jsp:forward page="./rank_print.jsp"></jsp:forward>
<%}
return;
}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../../jscript/td.js"></script>
<script language="javascript">
function StudSearch() {
	document.form_.print_page.value = '';

	var pgLoc = "../../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

var AjaxCalledPos;
function AjaxMapName(strPos) {
		document.form_.print_page.value = '';

		AjaxCalledPos = strPos;
		if(strPos == "1") {
			document.getElementById("stud_info1").innerHTML = "...";
			document.getElementById("stud_info2").innerHTML = "...";
		}

		var strCompleteName;
		if(strPos == "1")
			strCompleteName = document.form_.stud_id.value;
		else
			strCompleteName = document.form_.emp_id.value;

		if(strCompleteName.length == 0)
			return;

		var objCOAInput;
		if(strPos == "1")
			objCOAInput = document.getElementById("coa_info");
		else
			objCOAInput = document.getElementById("coa_info2");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
		if(strPos == "2")
			strURL += "&is_faculty=1";
		//if(document.form_.account_type[1].checked) //faculty
		//	strURL += "&is_faculty=1";
		//alert(strURL);
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.print_page.value = '';

	if(AjaxCalledPos == "2"){
		document.form_.emp_id.value = strID;
		return;
	}
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();

	document.getElementById("stud_info1").innerHTML = " == Press press enter to load information. == ";
	document.getElementById("stud_info2").innerHTML = " == Press press enter to load information. == ";
	//alert(strUserIndex);

	if(document.form_.rank_) {
		document.form_.rank_.value = '';
		document.form_.gwa_rank.value = '';
		document.form_.graduate.value = '';

		document.form_.gwa.value = '';
	}

	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	if(AjaxCalledPos == "1")
		document.getElementById("coa_info").innerHTML = strName;
	else
		document.getElementById("coa_info2").innerHTML = strName;
}

function PrintCertification() {
	document.form_.print_page.value = '1';
	document.form_.submit();
}
function ShowHideGWA() {
	if(document.form_.print_option[0].checked) {
		hideLayer('gwa_lbl');
		hideLayer('rank_lbl');
	}
	else if(document.form_.print_option[1].checked) {
		showLayer('gwa_lbl');
		hideLayer('rank_lbl');
	}
	else if(document.form_.print_option[2].checked) {
		hideLayer('gwa_lbl');
		showLayer('rank_lbl');
	}
	else {
		hideLayer('gwa_lbl');
		hideLayer('rank_lbl');
	}

}
function getNoOfGraduate() {
	document.form_.print_page.value='';
	document.form_.gwa.value='';
	document.form_.submit();
}
</script>
<body bgcolor="#663300" onLoad="ShowHideGWA();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","cgh_certificate_main.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					//									"Guidance & Counseling","GOOD MORAL CERTIFICATION",request.getRemoteAddr(),
					//									"cgh_certificate_main.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String strStudID    = WI.fillTextValue("stud_id");
String strStudIndex = null;
String strSQLQuery  = null;

Vector vRetResult   = null;

java.sql.ResultSet rs = null;
Vector vStudInfo      = new Vector();

String strCourseIndex = null; String strSYFrom = null; String strTerm = null;
String strMajorIndex  = null;

if(strStudID.length() > 0) {
	strSQLQuery = "select user_index, fname, mname, lname from user_table where id_number = '"+
		strStudID+"'";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		vStudInfo.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));
		strStudIndex = rs.getString(1);
	}
	rs.close();
	if(vStudInfo.size() > 0) {
		strSQLQuery = "select course_offered.course_code,major_name,sy_from,semester, year_level,course_offered.course_index, stud_curriculum_hist.major_index "+
			" from stud_curriculum_hist "+
			"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
			"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
			"join semester_sequence on (semester_val = semester)"+
			" where stud_curriculum_hist.is_valid = 1 and stud_curriculum_hist.user_index = "+strStudIndex+
			" order by sy_from desc, semester desc";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			if(rs.getString(2) != null)
				vStudInfo.addElement(rs.getString(1) +" :: "+rs.getString(2));
			else
				vStudInfo.addElement(rs.getString(1));

			strSYFrom = rs.getString(3);
			strTerm   = rs.getString(4);

			vStudInfo.addElement(strSYFrom+" - "+strTerm);

			strCourseIndex = rs.getString(6);
			strMajorIndex  = rs.getString(7);
		}
		rs.close();
		if(vStudInfo.size() == 1)
			strErrMsg = "Student enrollment information not found.";
	}
}


%>
<form action="./main.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr>
     <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>OTHER  CERTIFICATION</strong></font><font color="#FFFFFF"> <strong>PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="22%">Student ID</td>
      <td width="73%">
	  	<input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			onKeyUp="AjaxMapName('1');"><input type="image" src="../../../../../images/blank.gif" border="0">
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top"> Student Name</td>
      <td height="25"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"><%if(vStudInfo != null && vStudInfo.size() > 0){%><%=vStudInfo.elementAt(0)%><%}%></label></td>
    </tr>
    <tr>
      <td  width="5%"height="25">&nbsp;</td>
      <td width="18%" height="25">Course</td>
      <td height="25"><strong><label id="stud_info1"><%if(vStudInfo != null && vStudInfo.size() > 1){%><%=vStudInfo.elementAt(1)%><%}%></label></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term</td>
      <td width="77%" height="25"><strong><label id="stud_info2"><%if(vStudInfo != null && vStudInfo.size() > 1){%><%=vStudInfo.elementAt(2)%><%}%></label></strong></td>
    </tr>
<%if(vStudInfo.size() > 1) {
	String strNoOfGraduate = WI.fillTextValue("graduate");
	String strGWA = WI.fillTextValue("gwa");
	if(strGWA.length() == 0)
		strGWA = WI.fillTextValue("gwa_rank");
	if(strGWA.length() == 0) {
		double dGWA = 0d;
		student.GWA gwa = new student.GWA();
		dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));

		if (dGWA > 0d)
			strGWA = CommonUtil.formatFloat(dGWA,true);
	}
	if(strNoOfGraduate.length() == 0 && WI.fillTextValue("grad_yr").length() > 0 && strCourseIndex != null ) {
		strTemp = "select count(*) from GRADUATION_DATA where course_index = "+strCourseIndex+" and (major_index is null or major_index = "+strMajorIndex+
			 ") and is_valid = 1 and GRAD_YEAR = "+WI.fillTextValue("grad_yr")+" and semester = "+WI.fillTextValue("grad_sem");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null && !strTemp.equals("0"))
			strNoOfGraduate = strTemp;

	}

//only if student information exists... %>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><u>Please fill up the Information to be displayed in certificaiton</u> </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" valign="top">Date Printed </td>
      <td height="10" valign="top"><input type="text" name="date_" value="<%=WI.getTodaysDate(6)%>" class="textbox" size="32"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" valign="top">
	  	Address 1 : 	  </td>
      <td height="10" valign="top"><textarea name="address_1" style="font-size:10px; font-family:Verdana, Arial, Helvetica, sans-serif;" rows="3" cols="60"><%=WI.fillTextValue("address_1")%></textarea></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" valign="top">
	  	Address 1 :  	  </td>
      <td height="10" valign="top"><textarea name="address_2" style="font-size:10px; font-family:Verdana, Arial, Helvetica, sans-serif;" rows="3" cols="60"><%=WI.fillTextValue("address_2")%></textarea></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2" valign="top">
	  <input type="checkbox" name="_1">
	  Kindly send through mail.<br>
	  <input type="checkbox" name="_2">	   Please entrust  to the bearer.<br>
	  <input type="checkbox" name="_3"> Kindly indicate copy for "Chinese General Hospital College of Nursing".<br>
	  <hr width="90%" size="1" align="left">
	  <input type="checkbox" name="_4"> First Request.<br>
	  <input type="checkbox" name="_5"> Second Request.<br>
	  <input type="checkbox" name="_6"> Third Request.<br>	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10"><u>Printing Option</u></td>
      <td height="10">Grad Year and Term :
<%
strTemp = WI.fillTextValue("grad_yr");
if(strTemp.length() == 0 && strSYFrom != null)
	strTemp = strSYFrom;
%>	  <input type="text" name="grad_yr" value="<%=strTemp%>" size="4" maxlength="4" onKeyUp="AllowOnlyInteger('form_','grad_yr');">
	  <select name="grad_sem">
	  <option value="1">1st Sem</option>
<%
strTemp = WI.fillTextValue("grad_sem");
if(strTemp.length() == 0 && strTerm != null)
	strTemp = strTerm;
if(strTemp.equals("2"))
	strTemp = " selected";
else
	strTemp = "";
%>	  <option value="2"<%=strTemp%>>2nd Sem</option>
	  </select>
	  <a href="javascript:getNoOfGraduate();">Refresh to get # of grad</a></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">
	  <input name="print_option" type="radio" value="0" onClick="ShowHideGWA();"> Form 137	  </td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10"><input name="print_option" type="radio" value="1" onClick="ShowHideGWA();"> GWA</td>
      <td height="10"><label id="gwa_lbl"><input type="text" name="gwa" value="<%=strGWA%>"> (GWA)</label></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10"><input name="print_option" type="radio" value="2" onClick="ShowHideGWA();"> RANK</td>
      <td height="10"><label id="rank_lbl">Rank : <input type="text" name="rank_" value="<%=WI.fillTextValue("rank_")%>" size="12"> &nbsp;&nbsp;
	  No of Graduate : <input type="text" name="graduate" value="<%=strNoOfGraduate%>" size="4"> &nbsp;&nbsp;
	  Weighted Average : <input type="text" name="gwa_rank" value="<%=strGWA%>" size="4"> &nbsp;&nbsp;</label></td>
    </tr>
    <tr>
      <td height="30" colspan="3" valign="top" align="right">
	  <a href="javascript:PrintCertification();"><img src="../../../../../images/print.gif" border="0"></a>
	  	<font size="1">Print Certification</font>	  </td>
    </tr>
<%}//end of stud info..  %>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFCC99">
      <td height="25" colspan="5" class="thinborder">
	  <div align="center"><strong><font color="#0000FF">:: LIST OF OFFENSES :: </font></strong></div></td>
    </tr>
    <tr bgcolor="#FF6666">
      <td width="10%" height="20" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">SY/Term</td>
      <td width="22%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Violation Date  </td>
      <td width="24%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Violation Detail  </td>
      <td width="22%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Action Taken </td>
      <td width="22%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Incident Name </td>
    </tr>
<%
String[] astrConvertSem = {"SU","FS","SS","TS"};
for(int i = 0; i < vRetResult.size(); i += 20){%>
    <tr>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%> - <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><font color="#0000FF"><%=vRetResult.elementAt(i + 8)%></font><br><%=vRetResult.elementAt(i + 9)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 10)%></td>
      <td class="thinborder" style="font-size:9px"><%=vRetResult.elementAt(i + 15)%></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_page" value="">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>
