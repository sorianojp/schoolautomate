<%@ page language="java" import="utility.*,lms.LibraryAttendance,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	String strTemp2 = "";
	int iTotal = 0;
	int iTemp = 0;
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
function ReloadPage(strAction){
	if(strAction == "1")
		document.form_.time_name.value = document.form_.iTime[document.form_.iTime.selectedIndex].text;

	document.form_.show_data.value = "1";
	document.form_.submit();
}


function PrintPg(strAction) {

	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	if(strAction == "4")
		document.getElementById('myADTable1').deleteRow(0); //7
	else if(strAction == "3"){
		document.getElementById('myADTable1').deleteRow(0); //7
		document.getElementById('myADTable1').deleteRow(0); //8
	}
	else if(strAction == "1" || strAction == "2"){
		document.getElementById('myADTable1').deleteRow(0);//7
		document.getElementById('myADTable1').deleteRow(0);//8
		document.getElementById('myADTable1').deleteRow(0);//9
	}	
	
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	
	
	alert("Click OK to print this page");
	window.print();
}
</script>
<body bgcolor="#98A7B8">
<%
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Library Attendance","REPORTS",request.getRemoteAddr(),
														"view_attendance_detail.jsp");
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

String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID Number","Last Name","First Name"};
String[] astrSortByVal     = {"id_number","lname","fname"};
String[] strConvertDays = {"SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"};
String[] astrConvertMM = {"","January","February","March","April","May","June","July","August","September","October","November","December"};
String[] astrConvertSem = {"Summer","First Semester", "Second Semester", "Third Semester", "Fourth Semester"};


int iAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iAction"),"0"));

LibraryAttendance libAtt = new LibraryAttendance();
Vector vRetResult = new Vector();
String strViewType = null;
if(WI.fillTextValue("show_data").length() > 0){
	vRetResult = libAtt.getPatronInfoLibAttendance(dbOP, request, iAction);
	if(vRetResult == null)
		strErrMsg = libAtt.getErrMsg();	
	else
		strViewType = (String)vRetResult.remove(0);
}

if(strViewType == null)
	strViewType = "";
%>
<form action="./view_attendance_detail.jsp" method="post" name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable">
<tr bgcolor="#424255"> 
<%
strTemp = "";
if(iAction == 1)
	strTemp = "(DAILY VIEW)";
if(iAction == 2)
	strTemp = "(WEEKLY VIEW)";
if(iAction == 3)
	strTemp = "(MONTHLY VIEW)";
if(iAction == 4)
	strTemp = "(SEMESTRAL VIEW)";
	
strTemp += " - "+WI.fillTextValue("header_name").toUpperCase();
%>
<td height="25" colspan="4" class="thinborderTOPLEFTRIGHT" align="center"><font color="#FFFFFF" ><strong>:::: 
LIBRARY ATTENDANCE DETAIL <%=strTemp%> ::::</strong></font></td>
</tr>
<tr> 
<td height="24" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><strong> 
<%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
</tr>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
<tr> 
	<td>&nbsp;</td>
      <td height="25">SY/Term</td>
      <td colspan="3"> <%
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
    </tr>
<tr>
	<td width="3%" height="25">&nbsp;</td> 
  <td width="14%" height="25"> Location</td>
  <td colspan="3"><select name="loc_index" 
		style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 13;">
		<option value="">ALL</option>
	  <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%> </select></td>
  </tr>

	<tr> 
      <td height="25">&nbsp;</td>
      <td>ID Number</td>
      <td width="9%"><select name="id_number_con">
      <%=libAtt.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="74%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>      
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td>
	  	<select name="lname_con">
        <%=libAtt.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select>	  </td>
      <td>
	  	<input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
      
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=libAtt.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>      
    </tr>
	<tr><td colspan="5" height="10"></td></tr>
<%if(iAction == 1){%>
	<tr> 
		<td>&nbsp;</td>      
      <td >Date</td>
      <td colspan="3"> <%
strTemp = WI.fillTextValue("show_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%> <input name="show_date" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('form_.show_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
<%if(!WI.fillTextValue("is_total").equals("1")){%>
	<tr> 
	<td height="25">&nbsp;</td>
      <td height="25">Time</td>
      <td colspan="5"> 	  
	  <select name="iTime" onChange="document.form_.submit();">
<%
strTemp2 = "";

strTemp = WI.fillTextValue("iTime");
	for(int i = 6; i < 22; i++){
	
		if(strTemp.equals(Integer.toString(i)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
	
		if(i < 12){
			iTemp = i;
			strTemp2 = "AM";
		}else if(i == 12){
			iTemp = iTemp + 1;		
			strTemp2 = "PM";			
		}else{
			iTemp = i - 12;
			strTemp2 = "PM";			
		}
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=iTemp%><%=strTemp2%></option>
	  <%}%>
    </select> </td>     
    </tr>
<%}

}if(iAction == 2){%>
	<tr>  
		<td>&nbsp;</td>     
      <td>Date Range </td>
      <td colspan="3">
<input name="date_fr" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.fillTextValue("date_fr")%>"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" 
		onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> - to - 
		
<%
strTemp = WI.fillTextValue("date_to");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%> <input name="date_to" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" 
		onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
    </tr>
	<tr> 
	<td height="25">&nbsp;</td>
      <td height="25">Date</td>
      <td colspan="5"> 	  
	  <select name="days_" onChange="document.form_.submit();">
<%

strTemp2 = "";
strTemp = WI.fillTextValue("days_");
	for(int i = 1; i < 7; i++){	
		if(strTemp.equals(Integer.toString(i)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=strConvertDays[i]%></option>
	  <%}%>
    </select> </td>     
    </tr>
<%}if(iAction == 3){%>
	<tr> 
      <td>&nbsp;</td>
      <td>Month/Year</td>
      <td colspan="3"><select name="month_" onChange="document.form_.submit();">
          <option value="0">January</option>
          <%
strTemp = WI.fillTextValue("month_");
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>February</option>
          <%}else{%>
          <option value="1">February</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>March</option>
          <%}else{%>
          <option value="2">March</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>April</option>
          <%}else{%>
          <option value="3">April</option>
          <%}if(strTemp.compareTo("4") == 0){%>
          <option value="4" selected>May</option>
          <%}else{%>
          <option value="4">May</option>
          <%}if(strTemp.compareTo("5") == 0){%>
          <option value="5" selected>June</option>
          <%}else{%>
          <option value="5">June</option>
          <%}if(strTemp.compareTo("6") == 0){%>
          <option value="6" selected>July</option>
          <%}else{%>
          <option value="6">July</option>
          <%}if(strTemp.compareTo("7") == 0){%>
          <option value="7" selected>August</option>
          <%}else{%>
          <option value="7">August</option>
          <%}if(strTemp.compareTo("8") == 0){%>
          <option value="8" selected>September</option>
          <%}else{%>
          <option value="8">September</option>
          <%}if(strTemp.compareTo("9") == 0){%>
          <option value="9" selected>October</option>
          <%}else{%>
          <option value="9">October</option>
          <%}if(strTemp.compareTo("10") == 0){%>
          <option value="10" selected>November</option>
          <%}else{%>
          <option value="10">November</option>
          <%}if(strTemp.compareTo("11") == 0){%>
          <option value="11" selected>December</option>
          <%}else{%>
          <option value="11">December</option>
          <%}%>
        </select> 

<%
java.util.Calendar cal = java.util.Calendar.getInstance();
strTemp = WI.fillTextValue("date_");
if(strTemp.length() == 0) 	
	strTemp = Integer.toString(cal.get(java.util.Calendar.DATE));

	
%> <input name="date_" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">

		
<%
strTemp = WI.fillTextValue("year_");
if(strTemp.length() == 0) 	
	strTemp = Integer.toString(cal.get(java.util.Calendar.YEAR));

	
%> <input name="year_" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
  </td>
    </tr>
<%}%>
	<tr><td height="10" colspan="4"></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
		<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=libAtt.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=libAtt.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=libAtt.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
            	</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td>
				<select name="sort_by1_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select></td>
			<td>
				<select name="sort_by2_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
			<td>
				<select name="sort_by3_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
		</tr>		
		<tr>
			<td height="10" colspan="5"></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="4">
				<input type="image" src="../../../images/refresh.gif" border="1" onClick="ReloadPage('<%=iAction%>');"></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>

<%


if(vRetResult != null && vRetResult.size() > 0){%>





<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
<%
strTemp2 = "";



if(iAction == 1){
	String strTimeName = WI.fillTextValue("time_name");
	if(strTimeName.length() == 0){
		strTimeName = WI.getStrValue(WI.fillTextValue("iTime"),"-1");	
		iTemp = Integer.parseInt(strTimeName);
		strTemp2 = "";
		if(iTemp != -1){
			if(iTemp < 12)	
				strTemp2 = "AM";
			else if(iTemp == 12)		
				strTemp2 = "PM";			
			else{
				iTemp = iTemp - 12;
				strTemp2 = "PM";			
			}
		}
			
		strTimeName = Integer.toString(iTemp)+strTemp2;	
	}
	strTemp = "(DAILY VIEW)";
	strTemp2 = "Library Attendance for Date : "+WI.fillTextValue("show_date") + " :: " + strTimeName;
}
if(iAction == 2){
	strTemp = "(WEEKLY VIEW)";
	strTemp2 = "Library Attendance for  : "+WI.fillTextValue("date_fr")+" to "+WI.fillTextValue("date_to");
	if(WI.fillTextValue("days_").length() > 0)
		strTemp2 += " :: "+strConvertDays[Integer.parseInt(WI.fillTextValue("days_"))];
}
if(iAction == 3){
	strTemp = "(MONTHLY VIEW)";
	strTemp2 = "Library Attendance for  : "+astrConvertMM[Integer.parseInt(WI.getStrValue(WI.fillTextValue("month_"),"-1")) + 1].toUpperCase()+
		WI.fillTextValue("date_") + ", "+WI.fillTextValue("year_");
}
if(iAction == 4){
	strTemp = "(SEMESTRAL VIEW)";
	strTemp2 = "SY "+WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")+", "+astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))];
}
	
strTemp += " - "+WI.fillTextValue("header_name").toUpperCase();

strTemp = "LIBRARY ATTENDANCE DETAIL " + strTemp;
%>
	<tr><td align="right"><div align="right"> <font size="1"><a href="javascript:PrintPg('<%=iAction%>');"><img src="../../images/print_lib_report.gif" border="0"></a>click 
          to print report</font></div></td></tr>
	<tr><td height="25" align="center"><strong>
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br><%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
		
		<%=strTemp%><br><%=strTemp2%>
	</strong></td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="5%" class="thinborder"><strong>Count</strong></td>
		<td width="15%" height="22" class="thinborder"><strong>ID Number</strong></td>
		<td width="37%" class="thinborder"><strong>Name</strong></td>
		<%
		strTemp = "&nbsp;";
		if(strViewType.equals("1")){
			strTemp = "Course-Major-Year";
			if(WI.fillTextValue("show_basic_ed").length() > 0)
				strTemp = "Education Level - Level Name";
		}
		if(strViewType.equals("2"))
			strTemp = "Department";
		if(strViewType.equals("4"))
			strTemp = "Department/ College/ Grade Level";
		%>
		<%if(!strViewType.equals("3")){%><td width="29%" class="thinborder"><strong><%=strTemp%></strong></td><%}%>
		<td width="14%" class="thinborder"><strong>Attendance Count</strong></td>
	</tr>
	
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+=9){
	
	%>
	<tr>
		<td class="thinborder"><%=iCount++%></td>
		<td height="22" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
		<td class="thinborder"><%=strTemp%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+5)+WI.getStrValue((String)vRetResult.elementAt(i+6),"-","","")+
		WI.getStrValue((String)vRetResult.elementAt(i+7),"-","","");
		if(WI.fillTextValue("show_basic_ed").length() > 0)
			strTemp = (String)vRetResult.elementAt(i+5)+WI.getStrValue((String)vRetResult.elementAt(i+6)," - ","","");
		%>
		<%if(!strViewType.equals("3")){%><td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td><%}%>
		<%
		iTotal += Integer.parseInt((String)vRetResult.elementAt(i+8));
		%>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
	</tr>
	
	<%}%>
	<tr>
		<%
		strTemp = "4";
		if(strViewType.equals("3"))
			strTemp = "3";
		%>
		<td class="thinborder" colspan="<%=strTemp%>" align="right" height="22"><strong>TOTAL &nbsp; &nbsp;</strong></td>
		<td class="thinborder"><strong><%=iTotal%></strong></td>
	</tr>
</table>
<%}%>
	
	<input type="hidden" name="show_data" >	
	<input type="hidden" name="header_name" value="<%=WI.fillTextValue("header_name")%>" >
	<input type="hidden" name="iAction" value="<%=iAction%>" >
	<input type="hidden" name="show_faculty" value="<%=WI.fillTextValue("show_faculty")%>" >	
	<input type="hidden" name="show_basic_ed" value="<%=WI.fillTextValue("show_basic_ed")%>" >	
	<input type="hidden" name="time_name" value="<%=WI.fillTextValue("time_name")%>" >
	
	<input type="hidden" name="is_total" value="<%=WI.fillTextValue("is_total")%>">
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>