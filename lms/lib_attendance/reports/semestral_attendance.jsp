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
								"lms-Library Attendance-REPORTS","semestral_attendance.jsp");
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
	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div><br><br>";
	this.insRowVarTableID('myADTable',0, 1, strInfo);

	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable').deleteRow(2);
	document.getElementById('myADTable').deleteRow(2);
	document.getElementById('myADTable').deleteRow(2);
	document.getElementById('myADTable').deleteRow(2);
	document.getElementById('myADTable').deleteRow(2);
	document.getElementById('myADTable').deleteRow(2);
	document.getElementById('myADTable').deleteRow(2);
	alert("Click OK to print this page");
	window.print();
}


function ViewDetailList(strHeader){
	
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

	var pgLoc = "./view_attendance_detail.jsp?sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSem+"&loc_index="+strLocIndex+
		"&header_name="+strHeader+"&iAction=4&show_data=1&show_faculty="+showFaculty+
		"&show_basic_ed="+showBasicEd;		
	
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
														"semestral_attendance.jsp");
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
	Vector vColumnDetail  = null;
	Vector vRetResult     = null;
	
	if(WI.fillTextValue("sy_to").length() > 0) {
		vFinalResult = libAtt.getSemestralAttendance(dbOP, request);
		if(vFinalResult == null)
			strErrMsg = libAtt.getErrMsg();
		else {
			vColumnDetail = vFinalResult[0];
			vRetResult    = vFinalResult[1];
		}
	}


//variable used to format.
int iIndex = 0;
int iCountPerCell = 0;//every cell
int iGT           = 0;

//to plot graph.
int iColTotal[]   = null;  
if(vColumnDetail != null)
	iColTotal = new int[vColumnDetail.size()/2 + 1];
int iMaxVal = 0;
%>
<form action="./semestral_attendance.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable">
    <tr bgcolor="#424255"> 
      <td height="25" colspan="3"><div align="center" class="thinborderTOPLEFTRIGHT"><font color="#FFFFFF" ><strong> 
          LIBRARY SEMESTRAL ATTENDANCE REPORT (<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>,
		  	<%=dbOP.getHETerm(Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"),"-1")))%>)</strong></font></div></td>
    </tr>
    <tr> 
      <td height="24" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><strong> <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
	 <tr>
      <td height="25" colspan="4">
		
		<%
	strTemp = WI.fillTextValue("show_faculty");
	if(strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
	%>
		<input name="show_faculty" type="checkbox" value="1" <%=strTemp%>>Show only Faculty Attendance
		
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
      <td width="8%" height="25">SY/Term</td>
      <td width="28%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>	  
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
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
      <td width="64%"><input name="image" type="image" src="../../../images/refresh.gif" border="1" onClick="ReloadPage();"> 
        <font size="1">Click to view Report.</font> </td>
    </tr>
	<tr> 
      <td height="30">Location</td>
      <td colspan="2"><select name="loc_index" 
			style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 13;">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%> </select></td>      
    </tr>
<!--
    <tr> 
      <td height="30">Location</td>
      <td><select name="loc_index" 
			style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 13;">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%> </select></td>
      <td>&nbsp; </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2">
        <%
strTemp = WI.fillTextValue("plot_graph");
if(strTemp.length() > 0)
	strTemp = "checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="plot_graph" value="1" <%=strTemp%>>
        Plot Graph&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <%
strTemp = WI.fillTextValue("plot_data_graph");
if(strTemp.length() > 0)
	strTemp = "checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="plot_data_graph" value="1" <%=strTemp%>>
        Plot Data and Graph &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Height 
        and width of graph 
        <%
strTemp = WI.fillTextValue("height_");
if(strTemp.length() == 0)
	strTemp = "400";
%>
        <input name="height_" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
        <%
strTemp = WI.fillTextValue("width_");
if(strTemp.length() == 0)
	strTemp = "800";
%>
        <input name="width_" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
      </td>
    </tr>
-->
    <tr> 
      <td height="19" colspan="3"><hr size="1" color="#FFCC33"></td>
    </tr>
 <%if(vRetResult != null && vRetResult.size() > 0) {%> 
    <tr> 
      <td height="25" colspan="3"><div align="right"> <font size="1"><a href="javascript:PrintPg();"><img src="../../images/print_lib_report.gif" border="0"></a>click 
          to print report</font></div></td>
    </tr>
<%}%>
  </table>
<%
String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester", "Fourth Semester"};

String strLHS = null;
String strRHS = null;//hide data if plot graph is called.
if(WI.fillTextValue("plot_graph").compareTo("1") == 0 && WI.fillTextValue("plot_data_graph").length() == 0)  {
	strLHS = "<!--";
	strRHS = "-->";
}
else {
	strLHS = "";
	strRHS = "";
}

if(vRetResult != null && vRetResult.size() > 0) {%>
<%=strLHS%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=WI.getStrValue(SchoolInformation.getInfo1(dbOP,false,false),"","<br>","")%>
		<%=WI.getStrValue(WI.fillTextValue("lib_location").toUpperCase(),"","<br>","")%>
          <b>
		  	<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, SY <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>
		  </b><br>&nbsp;</div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFCC33"> 
      <td width="10%" height="22" class="thinborder">&nbsp;</td>
      <%
	  for(int i =0; i < vColumnDetail.size(); i += 2){%>
      <td class="thinborder" width="4" align="center"><strong><font size="1"><%=(String)vColumnDetail.elementAt(i)%></font></strong></td>
      <%}%>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>GRAND 
          TOTAL</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder" align="center"><strong><font size="1"> 
        TOTAL ATTENDANCE</font></strong></td>
      <%
	  for(int p =0; p < vColumnDetail.size(); p += 2){
	  iCountPerCell = 0;
	  if( (iIndex = vRetResult.indexOf(vColumnDetail.elementAt(p))) != -1) {
			iCountPerCell = Integer.parseInt((String)vRetResult.elementAt(iIndex + 1));
			vRetResult.removeElementAt(iIndex);	vRetResult.removeElementAt(iIndex);
	  }
	  iGT += iCountPerCell;
	  iColTotal[p/2] += iCountPerCell;
	  if(iCountPerCell > iMaxVal) 
	  	iMaxVal = iCountPerCell;
	  %>
      <td class="thinborder" align="center"><%if(iCountPerCell > 0){%> <font size="1">
	  <a href="javascript:ViewDetailList('<%=(String)vColumnDetail.elementAt(p)%>')"><%=iCountPerCell%></a></font> <%}else{%>
        - 
        <%}%></td>
      <%}//show count here.%>
      <td class="thinborder" align="center"> <%if(iGT > 0){%> <font size="1"><a href="javascript:ViewDetailList('Grand Total')"><%=iGT%></a></font> <%}else{%>
        - 
        <%}%> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr><td align="left"><font size="1">Printed by : <%=(String)request.getSession(false).getAttribute("first_name")%></font></td>
	<td align="right"><font size="1">Printed date and time : <%=WI.getTodaysDateTime()%></font></td></tr>
  </table>
 <%=strRHS%>
<!--  <table width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><p align="center"><font size="1"><strong>TOTAL ENROLLED</strong></font></p></td>
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
    <tr> 
      <td height="25"><p align="center"><font size="1"><strong>AVERAGE</strong></font></p></td>
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
    <tr> 
      <td height="25"><p align="center"><font size="1"><strong>% OF USERS</strong></font></p></td>
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
  </table>-->
<%
//I have to call to plot graph if plot graph is called.
String strGraphInfo = "";
if(WI.fillTextValue("plot_graph").length() > 0 || WI.fillTextValue("plot_data_graph").length() > 0) {
	iColTotal[iColTotal.length - 1] = iMaxVal;
		String strXAxisName = "Library Users --->";String strYAxisName = "Attendance";
		int iWidthOfGraph   = 1000;int iHeightOfGraph  = 400;
		if(WI.fillTextValue("width_").length() > 0) 
			iWidthOfGraph = Integer.parseInt(WI.fillTextValue("width_"));
		if(WI.fillTextValue("height_").length() > 0) 
			iHeightOfGraph = Integer.parseInt(WI.fillTextValue("height_"));
		
		String strBGColor = "#C5CACB";
		String strColumnColor="#FC9604";
		boolean bolPlot2DGraph = true;
		strGraphInfo = libAtt.plotGraph(vColumnDetail, iColTotal, false,strXAxisName, strYAxisName,
									 iWidthOfGraph, iHeightOfGraph, strBGColor, strColumnColor);
		if(strGraphInfo == null)
			strGraphInfo = libAtt.getErrMsg();
		else	
			strGraphInfo = "<br><br>"+strGraphInfo;

}//if plot graph is called
%>
<%=strGraphInfo%>
  <%}//only if vRetResult is not null  %>
  
  <input type="hidden" name="lib_location" value="<%=WI.fillTextValue("lib_location")%>" >
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>