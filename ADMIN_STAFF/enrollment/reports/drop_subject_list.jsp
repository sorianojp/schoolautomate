<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg(){
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);	document.getElementById('myADTable4').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);	document.getElementById('myADTable2').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();
}
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS-ENROLLEES","statistics_enrollees.jsp");
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
						//								"Enrollment","STATISTICS",request.getRemoteAddr(),
							//							"statistics_enrollees.jsp");
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
ReportEnrollment RE = new ReportEnrollment();
Vector vRetResult = null;
if(WI.fillTextValue("reloadPage").length() > 0 && WI.fillTextValue("reloadPage").compareTo("1") !=0)
{
	vRetResult = RE.getDropStudentList(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RE.getErrMsg();
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
boolean bolCGHFormat = false;
if(strSchCode != null && strSchCode.startsWith("CGH"))
	bolCGHFormat = true;
%>
<form action="drop_subject_list.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LISTS OF STUDENTS WHO DROPPED SUBJECTS ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td height="25"></td>
      <td colspan="2" style="font-size:14px; color:#0000FF"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
      <td width="30%" align="right">&nbsp;&nbsp;<a href="./dissolved_subject_list.jsp"><font style="font-weight:bold; color:#FF0000">Go to Dissolved Subject Report</font></a></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td height="25" colspan="3" valign="bottom"> <%
strTemp = WI.fillTextValue("show_drop_all");
if(strTemp.length() > 0)
	strTemp = " checked";
else
	strTemp = "";
%> <input type="checkbox" name="show_drop_all" value="1"<%=strTemp%>>
        Only show students with all subjects dropped</td>
    </tr>
    <tr> 
      <td width="4%" height="25"></td>
      <td height="25" colspan="3" valign="bottom"><font size="2"><strong>Date 
        Range </strong></font><font size="1">&nbsp;(leave date range empty to 
        view for complete offering school year)</font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td height="25" colspan="3">From &nbsp;&nbsp; <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To &nbsp;&nbsp; <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td height="25" colspan="3"><strong>Offering School Year</strong></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td height="25" colspan="3"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
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
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td height="25" colspan="3" valign="bottom"><strong>Show By :</strong></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>Specific ID</td>
      <td colspan="2"><input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" height="25"></a></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="20%">College/School</td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Course</td>
      <td colspan="2"><select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() > 0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+strTemp+" order by course_name asc",
		  		request.getParameter("course_index"), false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Major</td>
      <td colspan="2"><select name="major_index" onChange="ReloadPage();">
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
    </tr>
    <tr> 
      <td height="25"></td>
      <td>Year Level</td>
      <td colspan="2"><select name="year_level">
          <option value="">All</option>
          <%
strTemp =WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>Student Status </td>
      <td colspan="2">
	  <select name="status_index">
          <option value=""></option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where is_for_student = 1 order by status asc",
					WI.fillTextValue("status_index"), false)%> </select>
	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>&nbsp;</td>
      <td colspan="2"><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td height="10"></td>
      <td></td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){//System.out.println(vRetResult);
	// I have to keep track of course programs, course, and major.
	String strCollegeName   = null;
	int iSubGrandTotal = 0;
	//get thse information only for CGH.
	Vector vStudIDList = null;
	Vector vStudInfo   = null;
	if(bolCGHFormat){
		vStudIDList = (Vector)vRetResult.remove(1);
		vStudInfo = (Vector)vRetResult.remove(1);
	}
	
	boolean bolShowDropReason = false;
	if(WI.fillTextValue("show_drop_all").length() > 0) 
		bolShowDropReason = true;
		
	int iIndexOf = 0; Vector vDropByInfo = null;
	String[] astrConvertSem = {"Summer","First Sem","Second Sem","Third Sem"};
	//System.out.println(vStudIDList);
	//System.out.println(vStudInfo);
	%>
  	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable3" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
        Click to print this page.</td>
    </tr>
    <%if(WI.fillTextValue("show_drop_all").length() > 0) {%>
	<tr>
      <td align="center"><b>DROPOUT LIST FOR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> (
	  <%=dbOP.getHETerm(Integer.parseInt(WI.fillTextValue("semester"))).toUpperCase()%>)</b><br><br></td>
    </tr>
	<%}//show the heading for drop out list.%>
  </table>
	<%
	for(int i = 1 ; i< vRetResult.size() ;){//outer loop for each course program.
	strCollegeName = (String)vRetResult.elementAt(i);
	iSubGrandTotal = 0;
	%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
<%if(!bolCGHFormat){%>
    <tr> 
      <td height="25" colspan="9" bgcolor="#DBD8C8" class="thinborder"><strong>COLLEGE 
        : <%=strCollegeName%></strong></td>
    </tr>
<%}%>
    <tr> 
      <td width="12%" height="25" class="thinborder"><div align="center"><strong><font size="1">STUDENT ID </font></strong></div></td>
      <td width="23%" height="25" class="thinborder"><div align="center"><strong><font size="1">STUDENT NAME </font></strong></div></td>
      <td width="8%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">STUDENT STATUS </td>
      <%if(!bolCGHFormat){%>
      <td width="25%" height="25" class="thinborder"><div align="center"><strong><font size="1">COURSE-YR </font></strong></div></td>
      <%if(bolShowDropReason) {%>
	  	<td width="25%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">DROP REASON </td>
	  <%}%>
      <%}else{%>
      <td width="6%" height="25" class="thinborder"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
      <td width="20%" class="thinborder" align="center"><b><font size="1">ADMITTED</font></b></td>
      <td width="20%" class="thinborder" align="center"><b><font size="1">LAST ATTENDANCE</font></b></td>
      <td width="20%" class="thinborder" align="center"><b><font size="1">DATE GRANTED TC</font></b></td>
<%}%>
    </tr>
    <%
for(int j = i; j< vRetResult.size();){//Inner loop for course/major for a course program.
	if(strCollegeName.compareTo((String)vRetResult.elementAt(j)) != 0)
		break; //go back to main loop.
		
		vDropByInfo = (Vector)vRetResult.elementAt(j + 7);
%>
    <tr> 
      <td height="20" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(j + 1)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(j + 2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(j + 6)%></font></td>
      <%if(!bolCGHFormat){%>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(j + 3)%> <%=WI.getStrValue((String)vRetResult.elementAt(j + 4),"/","","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(j + 5)," - ","","")%>
	  </font></td>
      <%if(bolShowDropReason) {
	  	strTemp = null;
		if(vDropByInfo != null && vDropByInfo.size() == 4) 
			strTemp = (String)vDropByInfo.elementAt(2);
	  %>
	      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
	  <%}%>
      <%}else{%>
      <td class="thinborder"><font size="1"><%=WI.getStrValue(vRetResult.elementAt(j + 5),"N/A")%></font></td>
<%
iIndexOf = vStudIDList.indexOf(vRetResult.elementAt(j + 1));%>
      <td class="thinborder">&nbsp;
	  <%if(iIndexOf != -1 && vStudInfo.elementAt(iIndexOf*7 + 4) != null){%>
	  <%=astrConvertSem[Integer.parseInt((String)vStudInfo.elementAt(iIndexOf*7 + 6))]%>
	  <%=(String)vStudInfo.elementAt(iIndexOf*7 + 4)%> <%=(String)vStudInfo.elementAt(iIndexOf*7 + 5)%>
	  <%}%></td>
      <td class="thinborder">&nbsp;
	  <%if(iIndexOf != -1 && vStudInfo.elementAt(iIndexOf*7 + 1) != null){%>
	  <%=astrConvertSem[Integer.parseInt((String)vStudInfo.elementAt(iIndexOf*7 + 3))]%>
	  <%=(String)vStudInfo.elementAt(iIndexOf*7 + 1)%> <%=(String)vStudInfo.elementAt(iIndexOf*7 + 2)%>
	  <%}%></td>
      <td class="thinborder">&nbsp;
	  <%if(iIndexOf != -1 && vStudInfo.elementAt(iIndexOf*7) != null){%>
	  <%=(String)vStudInfo.elementAt(iIndexOf*7)%>
	  <%}%>	  </td>
<%}%>
    </tr>
    <%++iSubGrandTotal;
 j += 8; 
 i = j;}//end of loop to display a college information.

%>
  </table>
<%if(!bolCGHFormat){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" align="right" class="thinborderBOTTOMLEFT">
	  <strong><font size="1">Sub Total : <%=iSubGrandTotal%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td width="6%" height="20" class="thinborderBOTTOMRIGHT">&nbsp;</td>
    </tr>
  </table>
<%}//do not show sub total incase of CGH.%>


  <%}//outer most loop%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" align="right" class="thinborderBOTTOMLEFT">
	  <strong><font size="1">Grand Total : <%=(String)vRetResult.elementAt(0)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td width="6%" height="20" class="thinborderBOTTOMRIGHT">&nbsp;</td>
    </tr>
  </table>
<%}//only if vRetResult is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
