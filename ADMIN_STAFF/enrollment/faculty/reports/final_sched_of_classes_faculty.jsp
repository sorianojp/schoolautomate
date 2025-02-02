<%@ page language="java" import="utility.*,enrollment.ReportFaculty,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-REPORTS"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-Reports","final_sched_of_classes.jsp");
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
														"final_sched_of_classes.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
**/
//end of authenticaion code.
Vector vRetResult = null;

if (WI.fillTextValue("showAll").length() >  0) {
	vRetResult = new ReportFaculty().getFinalSchedFacultyList(dbOP, request);

	if (vRetResult == null || vRetResult.size() == 0){
		strErrMsg = " No Record Found";
	}
}

	String[] astrConvSemester={"Summer "," 1st Semester ","2nd Semester " };
//System.out.println(vRetResult);


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
<!--
	function DisplayAll(){
		document.form_.showAll.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce('form_');
	}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

	function PrintPg(){
		//I have to remove unused tables.
		var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div>";

		var strInfo2 = "";



		if (document.form_.c_index[document.form_.c_index.selectedIndex].value.length != 0){
			strInfo2 =  "<div align='center'>" + document.form_.c_index[document.form_.c_index.selectedIndex].text +"</div>";
		}

		document.bgColor = "#FFFFFF";
		document.getElementById('myADTable').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable2').deleteRow(0);
		document.getElementById('myADTable3').deleteRow(0);
		document.getElementById('myADTable4').deleteRow(0);
		document.getElementById('myADTable4').deleteRow(0);

		this.insRow(0, 1, strInfo);
		this.insRow(1, 1, "&nbsp;");
		this.insRow(2, 1, "<div align='center'><strong>FACULTY ASSIGNMENT </strong></div>");
		this.insRow(3, 1, "<div align='center'><%=astrConvSemester[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"),"1"))]%> , <%=WI.fillTextValue("sy_from") + " - " + WI.fillTextValue("sy_to")%> </div>");
		this.insRow(4, 1, "&nbsp;");

		if (strInfo2.length > 0) {
			this.insRow(5, 1, strInfo2);
			this.insRow(6, 1, "&nbsp;");
		}





	    var vConfirm = confirm("Continue Printing of this page");
		if (vConfirm){
			window.print();
		}
	}

-->

</script>
<body bgcolor="#D2AE72">
<form name="form_" action="./final_sched_of_classes_faculty.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY/REPORTS PAGE - FINAL SCHEDULE OF CLASSES ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="3"><a href="../enrollment__faculty_reports.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td width="38%" valign="bottom">School year :
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4">
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; &nbsp;</td>
      <td width="22%" valign="bottom">Term :
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td width="38%" valign="bottom"><a href="javascript: DisplayAll()"><img src="../../../../images/form_proceed.gif"border="0"></a></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="30" colspan="3" valign="bottom">College :
        <select name="c_index">
          <option value="">All College</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del = 0",WI.fillTextValue("c_index"),false)%>
        </select>
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="30" colspan="3" valign="bottom"><table width="54%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="24%">Faculty ID: </td>
            <td width="24%"><input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"></td>
            <td width="52%"><a href="javascript:OpenSearch()"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></td>
          </tr>
        </table> </td>
    </tr>
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td width="60%" height="25">&nbsp;&nbsp;</td>
      <td width="40%"><div align="right"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print list</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="7" class="thinborder"><div align="center"><strong>FINAL
          SCHEDULE OF CLASSES OF FACULTY</strong></div></td>
    </tr>
    <tr style="font-weight:bold;" align="center">
      <td width="19%" height="25" class="thinborder"><font size="1">TEACHER</font></td>
      <td width="15%" class="thinborder"><font size="1">SUBJECT CODE </font></td>
      <td width="12%" class="thinborder"><font size="1">SECTION</font></td>
      <td width="23%" class="thinborder"><font size="1">TIME :: DAY </font></td>
      <td width="10%" class="thinborder"><font size="1">ROOM</font></td>
      <td width="6%" class="thinborder"><font size="1">HRS/WEEK</font></td>
      <td width="6%" class="thinborder"><font size="1">TOTAL NUMBER OF STUDENTS</font></td>
    </tr>
    <% 	String strRoomNumbers = null;
		String strClassScheduel = null;
		Vector vLecRoomSchedule = null;
		int k = 0;
		double dTotalHrsPerWeekPerFac = 0d; String strTeacher = null;
		for(int i = 0 ; i < vRetResult.size() ; i+=7){
			strRoomNumbers = "";
			strClassScheduel = "";
			vLecRoomSchedule = (Vector) vRetResult.elementAt(i+6);
			if (vLecRoomSchedule != null && vLecRoomSchedule.size() > 0){
				for(k=0; k < vLecRoomSchedule.size(); k+=2){
					if (k != 0) {
						strClassScheduel +=  "<br>&nbsp;";
						strRoomNumbers += "<br>&nbsp;";
					}
					strClassScheduel +=(String) vLecRoomSchedule.elementAt(k+1);
					strRoomNumbers +=(String) vLecRoomSchedule.elementAt(k);
				}
			}
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
	if(strTemp.equals("n/a"))
		strTemp = "-";

	if(strTeacher == null)
		strTeacher = WI.getStrValue((String)vRetResult.elementAt(i));

	try {
		if(strTeacher.equals(WI.getStrValue((String)vRetResult.elementAt(i))) )
			dTotalHrsPerWeekPerFac += Double.parseDouble(strTemp);
	}
	catch(Exception e) {		
	}
	%>
    <tr>
      <td height="18" valign="top" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i))%></td>
      <td valign="top" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td valign="top" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td valign="top" class="thinborder">&nbsp;<%=strClassScheduel%></td>
      <td valign="top" class="thinborder">&nbsp;<%=strRoomNumbers%></td>
      <td valign="top" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 3))%></td>
      <td valign="top" class="thinborder">&nbsp;<%=strTemp%></td>
    </tr>
	<%if(strSchCode.startsWith("VMA")){
		if(!strTeacher.equals(WI.getStrValue((String)vRetResult.elementAt(i))) ) {%>
		<tr>
		  <td height="18" valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;<%=CommonUtil.formatFloat(dTotalHrsPerWeekPerFac, false)%></td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		</tr>
		<%
		strTeacher = WI.getStrValue((String)vRetResult.elementAt(i));
		dTotalHrsPerWeekPerFac = 0d;
		}}%>
	
    <%}//end for loop 
	if(strSchCode.startsWith("VMA")){%>
		<tr>
		  <td height="18" valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		  <td valign="top" class="thinborder">&nbsp;<%=CommonUtil.formatFloat(dTotalHrsPerWeekPerFac, false)%></td>
		  <td valign="top" class="thinborder">&nbsp;</td>
		</tr>
	<%}%>
  </table>
<%} // if (vRetResult != null && vRetResult.size() > 0)%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable4">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="showAll">
<input type="hidden" name="print_page">

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
