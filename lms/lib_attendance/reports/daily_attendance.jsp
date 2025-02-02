<%@ page language="java" import="utility.*,lms.LibraryAttendance,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Library Attendance-REPORTS","daily_attendance.jsp");
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
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){

	var libLoc = document.form_.loc_index[document.form_.loc_index.selectedIndex].text;
	
	if(libLoc == "ALL")
		libLoc = "";

	document.form_.lib_location.value = libLoc;
	document.form_.submit();
}


function PrintPg() {
	//var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
//	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
//	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div><br><br>";
//	this.insRowVarTableID('myADTable',0, 1, strInfo);

	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	
	document.getElementById('myADTable1').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();
}

function ViewDetailList(strTime, strHeader){
	var strIsTotal = 0;
	if(strTime.length == 0)
		strIsTotal = "1";
	var showFaculty = "";
	
	if(document.form_.show_faculty.checked)
		showFaculty = "1";
		
	var showBasicEd = "";
	if(document.form_.show_basic_ed.checked)	
		showBasicEd = "1";
		
	var strSYFrom = document.form_.sy_from.value;
	var strSYTo = document.form_.sy_to.value;
	var strSem = document.form_.semester.value;
	var strLocIndex = document.form_.loc_index.value;
	var strShowDate = document.form_.show_date.value;

	
	

	var pgLoc = "./view_attendance_detail.jsp?sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSem+"&loc_index="+strLocIndex+
		"&show_date="+strShowDate+"&iTime="+strTime+"&header_name="+strHeader+"&iAction=1&show_data=1&show_faculty="+showFaculty+
		"&show_basic_ed="+showBasicEd+"&is_total="+strIsTotal;		
	
	var win=window.open(pgLoc,"ViewStudentOrder",'width=1024,height=600,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#98A7B8">
<%
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Library Attendance","REPORTS",request.getRemoteAddr(),
														"daily_attendance.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
	LibraryAttendance libAtt = new LibraryAttendance();
	Vector vFinalResult[] = null;
	Vector vRowDetail     = null;
	Vector vColumnDetail  = null;
	Vector vRetResult     = null;
	
	if(WI.fillTextValue("sy_to").length() > 0) {
		vFinalResult = libAtt.getDailyAttendance(dbOP, request);
		if(vFinalResult == null)
			strErrMsg = libAtt.getErrMsg();
		else {
			vRowDetail    = vFinalResult[0];
			vColumnDetail = vFinalResult[1];
			vRetResult    = vFinalResult[2];
		}
		
	}



//variable used to format.
int iIndex = 0;
int iTime  = 0;
int iCountPerCell = 0;//every cell
int iRowTotal     = 0; 
int iGT           = 0;
int iColTotal[]   = null;  
if(vColumnDetail != null)
	iColTotal = new int[vColumnDetail.size()/2];
%>
<form action="./daily_attendance.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable">
    <tr bgcolor="#424255"> 
      <td height="25" colspan="4" class="thinborderTOPLEFTRIGHT" align="center"><font color="#FFFFFF" ><strong>:::: 
        LIBRARY DAILY ATTENDANCE REPORT ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="24" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr>
	<%
	strTemp = WI.fillTextValue("show_faculty");
	if(strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
	%>
      <td height="25" colspan="4">
		<input name="show_faculty" type="checkbox" value="1"  <%=strTemp%>>Show only Faculty Attendance
		<%
	strTemp = WI.fillTextValue("show_basic_ed");
	if(strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
	%>
	<input name="show_basic_ed" type="checkbox" value="1"  <%=strTemp%>>Show Basic Education		</td>
      </tr>
    <tr> 
      <td width="11%" height="25">SY/Term</td>
      <td width="30%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
      <td width="3%" >Date</td>
      <td width="56%" > <%
strTemp = WI.fillTextValue("show_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%> <input name="show_date" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('form_.show_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25"> Location</td>
      <td><select name="loc_index" 
			style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 13;">
			<option value="">ALL</option>
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%> </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">Time Range</td>
      <td> <select name="time_fr">
          <option value="6">6 AM</option>
          <%
strTemp = WI.fillTextValue("time_fr");
if(strTemp.length() == 0) 
	strTemp = "7";
if(strTemp.compareTo("7") == 0) {%>
          <option value="7" selected>7 AM</option>
          <%}else{%>
          <option value="7">7 AM</option>
          <%}if(strTemp.compareTo("8") == 0) {%>
          <option value="8" selected>8 AM</option>
          <%}else{%>
          <option value="8">8 AM</option>
          <%}if(strTemp.compareTo("9") == 0) {%>
          <option value="9" selected>9 AM</option>
          <%}else{%>
          <option value="9">9 AM</option>
          <%}if(strTemp.compareTo("10") == 0) {%>
          <option value="10" selected>10 AM</option>
          <%}else{%>
          <option value="10">10 AM</option>
          <%}if(strTemp.compareTo("11") == 0) {%>
          <option value="11" selected>11 AM</option>
          <%}else{%>
          <option value="11">11 AM</option>
          <%}%>
        </select>
        to 
        <select name="time_to">
          <option value="16">4 PM</option>
          <%
strTemp = WI.fillTextValue("time_to");
if(strTemp.length() == 0) 
	strTemp = "21";
if(strTemp.compareTo("17") == 0) {%>
          <option value="17" selected>5 PM</option>
          <%}else{%>
          <option value="17">5 PM</option>
          <%}if(strTemp.compareTo("18") == 0) {%>
          <option value="18" selected>6 PM</option>
          <%}else{%>
          <option value="18">6 PM</option>
          <%}if(strTemp.compareTo("19") == 0) {%>
          <option value="19" selected>7 PM</option>
          <%}else{%>
          <option value="19">7 PM</option>
          <%}if(strTemp.compareTo("20") == 0) {%>
          <option value="20" selected>8 PM</option>
          <%}else{%>
          <option value="20">8 PM</option>
          <%}if(strTemp.compareTo("21") == 0) {%>
          <option value="21" selected>9 PM</option>
          <%}else{%>
          <option value="21">9 PM</option>
          <%}%>
        </select> </td>
      <td colspan="2">&nbsp;<input type="image" src="../../../images/refresh.gif" border="1" onClick="ReloadPage();"><font size="1">Click to view Report.</font></td>
    </tr>
    <tr> 
      <td height="19" colspan="4"><hr size="1" color="#FFCC33"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
  	<tr>       
      <td align="right">
	  <a href="javascript:PrintPg();"><img src="../../images/print_lib_report.gif" border="0"></a>
	  <font size="1">click to print report</font></td>
    </tr>
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=WI.getStrValue(SchoolInformation.getInfo1(dbOP,false,false),"","<br>","")%>
		<%=WI.getStrValue(WI.fillTextValue("lib_location").toUpperCase(),"","<br>","")%>
          <u><b>
		  <%if(WI.fillTextValue("show_faculty").length() > 0) {%>
		  	Faculty - 
		  <%}%>
		  Daily Library Attendance for Date : <%=WI.fillTextValue("show_date")%></b></u><br>&nbsp;</div>
		  
	</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFCC33"> 
      <td width="10%" height="22" class="thinborder" align="center"><strong><font size="1">TIME</font></strong></td>
      <%
	  for(int i =0; i < vColumnDetail.size(); i += 2){%>
      <td class="thinborder" width="4" align="center"><strong><font size="1"><%=(String)vColumnDetail.elementAt(i)%></font></strong></td>
      <%}%>
      <td width="6%" class="thinborder" align="center"><strong><font size="1">GRAND 
          TOTAL</font></strong></td>
    </tr>
    <%
	 
 for(int i = 0; i < vRowDetail.size(); ++i) {
 	iTime = ((Integer)vRowDetail.elementAt(i)).intValue();%>
    <tr> 
      <td height="25" class="thinborder" align="center"><strong><font size="1"> 
          <%=libAtt.convertTimeInterval(iTime)%></font></strong></td>
      <%
	  for(int p =0; p < vColumnDetail.size(); p += 2){
	  iCountPerCell =0;
	  if( (iIndex = vRetResult.indexOf(vColumnDetail.elementAt(p))) != -1) {
	  	if( ((String)vRetResult.elementAt(iIndex + 1)).compareTo(Integer.toString(iTime)) == 0) {
			iCountPerCell = Integer.parseInt((String)vRetResult.elementAt(iIndex + 2));
			vRetResult.removeElementAt(iIndex);	vRetResult.removeElementAt(iIndex);	vRetResult.removeElementAt(iIndex);
		}
	  }
	  iRowTotal += iCountPerCell;
	  iGT += iCountPerCell;
	  iColTotal[p/2] += iCountPerCell;
	  %>
      <td class="thinborder" align="center"><%if(iCountPerCell > 0){%> <font size="1">
	  	<a href="javascript:ViewDetailList('<%=iTime%>','<%=(String)vColumnDetail.elementAt(p)%>')"><%=iCountPerCell%></a></font> <%}else{%> - <%}%></td>
      <%}//show count here.%>
      <td class="thinborder" align="center"> 
		<%if(iRowTotal > 0){%> 
			<font size="1"><a href="javascript:ViewDetailList('<%=iTime%>','Grand Total')"><%=iRowTotal%></a></font> 
		<%}else{%>-<%}
		iRowTotal = 0;%> </td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" class="thinborder" align="center"><strong><font size="1">TOTAL</font></strong></td>
      <%
	  for(int i =0; i < vColumnDetail.size(); i += 2){%>
      <td class="thinborder" align="center"><strong><font size="1">
			<%if(iColTotal[i/2] > 0){%>
			<a href="javascript:ViewDetailList('','<%=(String)vColumnDetail.elementAt(i)%>')"><%=iColTotal[i/2]%></a>
			<%}else{%><%=iColTotal[i/2]%><%}%>
		</font></strong></td>
      <%}//show totalcount here.%>
      <td class="thinborder" align="center"> <strong> 
        <%if(iGT > 0){%> <font size="1"><a href="javascript:ViewDetailList('','Grand Total')"><%=iGT%></a></font>  <%}else{%> - <%}%>
        </strong></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr><td align="left"><font size="1">Printed by : <%=(String)request.getSession(false).getAttribute("first_name")%></font></td>
	<td align="right"><font size="1">Printed date and time : <%=WI.getTodaysDateTime()%></font></td></tr>
  </table>
  
  <%}//only if vRetResult is not null
  %>
	<input type="hidden" name="lib_location" value="<%=WI.fillTextValue("lib_location")%>" >
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>