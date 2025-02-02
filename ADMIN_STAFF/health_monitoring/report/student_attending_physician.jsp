<%@ page language="java" import="utility.*, health.ClinicVisitLog ,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">
<!--
function PageAction(strAction) {
	if(strAction == "0"){
		if(!confirm("Do  you want to delete this information?"))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.submit();
}
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function EmpSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String [] astrYN = {"No", "Yes"};
	int iSearchResult = 0;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","student_attending_physician.jsp");
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
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"visit_log.jsp");
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
Vector vBasicInfo = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();

String strIDNumber = WI.fillTextValue("stud_id");

health.HMReports hmReports = new health.HMReports();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if( hmReports.operateOnStudAttendingPhysician(dbOP, request, Integer.parseInt(strTemp), strIDNumber) == null )
		strErrMsg = hmReports.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Information successfully deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully updated.";
	}
}




//get all levels created.
if(strIDNumber.length() > 0) {
	if(bolIsSchool) {
		vBasicInfo = OAdm.getStudentBasicInfo(dbOP, strIDNumber);
		if(vBasicInfo == null) //may be it is the teacher/staff
		{
			request.setAttribute("emp_id",strIDNumber);
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vBasicInfo != null)
				bolIsStaff = true;
		}
		else {//check if student is currently enrolled
			Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP,strIDNumber,
			(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
			if(vTempBasicInfo != null)
				bolIsStudEnrolled = true;
		}
		if(vBasicInfo == null)
			strErrMsg = OAdm.getErrMsg();
	}
	else{//check faculty only if not school...
			request.setAttribute("emp_id",strIDNumber);
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vBasicInfo != null)
				bolIsStaff = true;
			if(vBasicInfo == null)
				strErrMsg = "Employee Information not found.";;
	}
}

	
	vRetResult = hmReports.operateOnStudAttendingPhysician(dbOP, request, 4, strIDNumber);

%>
<body bgcolor="#8C9AAA" class="bgDynamic" onLoad="document.form_.stud_id.focus()">

<form action="./student_attending_physician.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="28" colspan="4" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          ATTENDING PHYSICIAN MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="18" colspan="4"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td width="3%"  height="28">&nbsp;</td>
      <td width="15%" height="28">Enter ID No. :</td>
      <td width="25%" height="28">
      <%strTemp = WI.fillTextValue("stud_id");%>
      <input type="text" name="stud_id" class="textbox"
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> </td>
      <td width="57%" height="28"><font size="1">
      <a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a> Click to search for student
      <a href="javascript:EmpSearch();"><img src="../../../images/search.gif" border="0" ></a> Click to search for employee
      </font></td>
    </tr>
    <tr>
      <td height="28">&nbsp;</td>
      <td height="28">&nbsp;</td>
      <td height="28"><input type="image" src="../../../images/form_proceed.gif"></td>
      <td height="28">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <%
if(vBasicInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(!bolIsStaff){%>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="15%" >Student Name : </td>
      <td width="46%" ><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
      <td width="13%" >Status : </td>
      <td width="24%" > <%if(bolIsStudEnrolled){%>
        Currently Enrolled <%}else{%>
        Not Currently Enrolled <%}%></td>
    </tr>
    <tr>
      <td   height="25">&nbsp;</td>
      <td >Course/Major :</td>
      <td height="25" colspan="3" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Year :</td>
      <td ><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <%}//if not staff
else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Emp. Name :</td>
      <td ><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),
	  (String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></td>
      <td >Emp. Status :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >College/Office :</td>
      <td > <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/
	  <%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
      <td >Designation :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <%}//only if staff %>
   <tr>
      <td height="18" colspan="5"><hr size="1"></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Physician ID</td>
			<%
			strTemp = "";
			if(vRetResult != null && vRetResult.size()> 0)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(1));
			%>
			<td>
			<input type="text" name="physician_id_no" class="textbox" maxlength="32"
		      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
		</tr>
		<tr>
		    <td height="25">&nbsp;</td>
		    <td>First Name<sup style="color:#FF0000">*</sup><input type="hidden" name="mandatory_fname" value="1"></td>
			<%
			strTemp = "";
			if(vRetResult != null && vRetResult.size()> 0)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(2));
			%>

		    <td><input type="text" name="physician_fname" size="35" class="textbox" maxlength="32"
		      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
	    </tr>
		<tr>
		    <td height="25">&nbsp;</td>
		    <td>Middle Name</td>
			<%
			strTemp = "";
			if(vRetResult != null && vRetResult.size()> 0)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(3));
			%>
		    <td><input type="text" name="physician_mname" size="35" class="textbox" maxlength="32"
		      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
	    </tr>
		<tr>
		    <td height="25">&nbsp;</td>
		    <td>Last Name<sup style="color:#FF0000">*</sup><input type="hidden" name="mandatory_lname" value="1"></td>
			<%
			strTemp = "";
			if(vRetResult != null && vRetResult.size()> 0)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(4));
			%>
		    <td><input type="text" name="physician_lname" size="35" class="textbox" maxlength="32"
		      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
	    </tr>
		<tr>
		    <td height="25">&nbsp;</td>
		    <td>License No</td>
			<%
			strTemp = "";
			if(vRetResult != null && vRetResult.size()> 0)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
			%>
		    <td><input type="text" name="physician_license_no" size="35" class="textbox" maxlength="32"
		      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
	    </tr>
		<tr>
		    <td height="25">&nbsp;</td>
		    <td>Office Address<sup style="color:#FF0000">*</sup><input type="hidden" name="mandatory_office_addr" value="1"></td>
			<%
			strTemp = "";
			if(vRetResult != null && vRetResult.size()> 0)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(5));
			%>
		    <td><input type="text" name="office_addr" size="60" class="textbox" maxlength="128"
		      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
	    </tr>
		<tr>
		    <td height="25">&nbsp;</td>
		    <td>Telephone No.</td>
			<%
			strTemp = "";
			if(vRetResult != null && vRetResult.size()> 0)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(7));
			%>
		    <td><input type="text" name="physician_tel_no" size="35" class="textbox" maxlength="32"
		      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
	    </tr>
		<tr><td colspan="3" align="center">
		<a href="javascript:PageAction('1');"><img src="../../../images/update.gif" border="0"></a>
		<font size="1">Click to save/update information</font>
		<%if(vRetResult != null && vRetResult.size() > 0){%>
		<a href="javascript:PageAction('0');"><img src="../../../images/delete.gif" border="0"></a>
		<font size="1">Click to delete information</font>
		<%}%>
		</td></tr>
	</table>  
  <%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="page_action">
</form>
</body>
</html>
