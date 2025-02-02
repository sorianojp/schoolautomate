<%@ page language="java" import="utility.*,enrollment.EnrollmentRoomMonitor,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

if(false && request.getParameter("printPg") != null && request.getParameter("printPg").compareTo("1") ==0){%>
		<jsp:forward page="./statistics_rooms_print.jsp" />
<%}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex, strPageAction) {
	if(strPageAction == '0') {
		if(!confirm("Are you sure you want to remove Room reservation."))
			return;
	}
	if(strPageAction == '')
		document.form_.search_page.value = '2';
		
	document.form_.page_action.value = strPageAction;
	document.form_.info_index.value  = strInfoIndex;
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PrintPg() {
	document.bgColor = "#FFFFFF";
	
   	document.getElementById('myADTable1').deleteRow(0);
   	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function PrintPageCalled() {
	<%if(WI.fillTextValue("search_page").equals("2")){%>
		this.PrintPg();
	<%}%>
}
function SearchRoom() {
	var pgLoc = "./reserve_room_search.jsp?opner_info=form_.room_no";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<body bgcolor="#D2AE72" onLoad="PrintPageCalled();">
<%
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-ROOMS MONITORING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
	}// PAYROLL-DTR = MODULE-SUBMODULE
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are not logged in. Please login to access SchoolAutomate");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-ROOMS MONITORING-Reserve a room","reserve_room.jsp");
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


Vector vRetResult = null; Vector vResSummary = null; Vector vEditInfo = null;
EnrollmentRoomMonitor ERM = new EnrollmentRoomMonitor();

strTemp = WI.fillTextValue("page_action");

if(strTemp.length() > 0 && !strTemp.equals("3")) {
	if(ERM.operateOnRoomReservation(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = ERM.getErrMsg();
	else	
		strErrMsg = "Page action is successful.";
}

boolean bolIsSearchCalled = false;
if(WI.fillTextValue("search_page").length() > 0) 
	bolIsSearchCalled = true;

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0 ) {
	vRetResult  = ERM.operateOnRoomReservation(dbOP,request, 4);
	//vResSummary = ERM.operateOnRoomReservation(dbOP, request, 5);
	if(strErrMsg == null && vRetResult == null) 
		strErrMsg = ERM.getErrMsg();
}
if(strTemp.equals("3")) {
	vEditInfo = ERM.operateOnRoomReservation(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = ERM.getErrMsg();
	else	
		vEditInfo.remove(0);
}

%>
<form name="form_" action="./reserve_room.jsp" method="post">

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          RESERVE A ROOM ::::</strong></font></strong></font></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td width="4%" height="27"></td>
      <td colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="45%" class="thinborderALL" bgcolor="#DDDDDD">SCHOOL YEAR 
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(8);
else
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
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(9);
else
	strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
        &nbsp;</td>
      <td class="thinborderTOPBOTTOMRIGHT" bgcolor="#DDDDDD">TERM 
        <select name="semester">
          <option value="1">1st Sem</option>
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(10);
else
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
        </select></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td class="thinborderBOTTOMLEFTRIGHT" bgcolor="#DDDDDD"><strong>Activity Date</strong></td>
      <td class="thinborderBOTTOMRIGHT" bgcolor="#DDDDDD"><strong>Room #</strong></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td class="thinborderBOTTOMLEFTRIGHT" bgcolor="#DDDDDD"><font size="1">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
to
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("date_to");
%>
<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>

      </font></td>
      <td width="51%" class="thinborderBOTTOMRIGHT" bgcolor="#DDDDDD">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("room_no");
%>
	  <input name="room_no" type="text" size="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">&nbsp;&nbsp;&nbsp;&nbsp;
      <a href="javascript:SearchRoom();"><img src="../../../images/search.gif" width="22" height="19" border="0"></a> <font size="1">Search  Room</font></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="2" class="thinborderLEFTRIGHT" bgcolor="#eeeeee">Reservation Time :
        <%
String[] astrTimeInfo= {"","1 AM","2 AM","3 AM","4 AM","5 AM","6 AM","7 AM","8 AM","9 AM","10 AM","11 AM","12 PM",
				"1 PM","2 PM","3 PM","4 PM","5 PM","6 PM","7 PM","8 PM","9 PM","10 PM","11 PM"};
String[] astrMinInfo= {"00","05","10","15","20","25","30","35","40","45","50","55"};

strTemp = WI.fillTextValue("time_fr_hr");
int iTemp = 0;
if(strTemp.length() == 0)
	iTemp = 9;
else 
	iTemp = Integer.parseInt(strTemp);

double dTimeFr = 0d;
double dTimeTo = 0d;

if(vEditInfo != null) {
	dTimeFr = Double.parseDouble((String)vEditInfo.elementAt(5));
	dTimeTo = Double.parseDouble((String)vEditInfo.elementAt(6));
	
	iTemp = new Double(dTimeFr).intValue();
}

%>
        <select name="time_fr_hr">
          <%for(int i = 6; i < 23; ++ i){
	if(i == iTemp) 
		strTemp = " selected";
	else	
		strTemp = "";
	%>
          <option value="<%=i%>"<%=strTemp%>><%=astrTimeInfo[i]%></option>
          <%}%>
        </select>
-
<%
strTemp = WI.fillTextValue("time_fr_min");
if(strTemp.length() == 0) 
	iTemp = 0;
else	
	iTemp = Integer.parseInt(strTemp);
if(vEditInfo != null) {
	iTemp = new Double((dTimeFr - new Double(dTimeFr).intValue()) * 60d).intValue();
	//System.out.println(iTemp);
	if(iTemp % 5 > 0)
		iTemp = iTemp - iTemp %5 + 5;
}
%>
<select name="time_fr_min">
  <%for(int i = 0; i < 12; ++ i){
	if(i == iTemp/5) 
		strTemp = " selected";
	else	
		strTemp = "";
	%>
  <option value="<%=i*5%>"<%=strTemp%>><%=astrMinInfo[i]%></option>
  <%}%>
</select>
to
<%	  
strTemp = WI.fillTextValue("time_to_hr");
if(strTemp.length() == 0)
	iTemp = 10;
else 
	iTemp = Integer.parseInt(strTemp);
if(vEditInfo != null) {
	iTemp = new Double(dTimeTo).intValue();
}
%>
<select name="time_to_hr">
  <%for(int i = 6; i < 23; ++ i){
	if(i == iTemp) 
		strTemp = " selected";
	else	
		strTemp = "";
	%>
  <option value="<%=i%>"<%=strTemp%>><%=astrTimeInfo[i]%></option>
  <%}%>
</select>
<%
strTemp = WI.fillTextValue("time_to_min");
if(strTemp.length() == 0) 
	iTemp = 30;
else	
	iTemp = Integer.parseInt(strTemp);
if(vEditInfo != null) {
	iTemp = new Double((dTimeTo - new Double(dTimeTo).intValue()) * 60d).intValue();
	//System.out.println(iTemp);
	if(iTemp % 5 > 0)
		iTemp = iTemp - iTemp %5 + 5;
}
%>
<select name="time_to_min">
  <%for(int i = 0; i < 12; ++ i){
	if(i == iTemp/5) 
		strTemp = " selected";
	else	
		strTemp = "";
	%>
  <option value="<%=i*5%>"<%=strTemp%>><%=astrMinInfo[i]%></option>
  <%}%>
</select></td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="2" class="thinborderLEFTRIGHT" bgcolor="#eeeeee" valign="top">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("res_note");
if(strTemp.length() == 0)
	strTemp = "";
%>
        <textarea name="res_note" class="textbox" rows="3" cols="65"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>	  </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="2" class="thinborderBOTTOMLEFTRIGHT" bgcolor="#eeeeee" align="right">&nbsp;	  </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="2" class="thinborderNONE"><center>
        <font size="1">
<%if(iAccessLevel > 1) {
	if(vEditInfo != null && vEditInfo.size() > 0) {%>
		<input name="image" type="image" src="../../../images/edit.gif" border="0" onClick="document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>';document.form_.page_action.value=2">Reserve a room </font>
	<%}else{%>
		<input name="image" type="image" src="../../../images/save.gif" border="0" onClick="document.form_.page_action.value=1">Reserve a room </font>
	<%}%>
<%}%>
	
	&nbsp;&nbsp;&nbsp;
<input name="image2" type="image" src="../../../images/refresh.gif" border="0" onClick="document.form_.page_action.value =' ';"> View reservation 

&nbsp;&nbsp;&nbsp;
<input type="checkbox" name="show_all" value="checked" <%=WI.fillTextValue("show_all")%>> Include expired reservations.

</font>
      </center>      </td>
    </tr>
    <tr bgcolor="#66CCCC">
      <td height="25"></td>
      <td colspan="2" class="thinborderNONE" style="font-size:13px; font-weight:bold; color:#0000FF" valign="bottom">Search Options</td>
    </tr>
    <tr bgcolor="#66CCCC">
      <td height="25"></td>
      <td colspan="2" class="thinborderNONE" style="font-weight:bold">Activity Date: 
        <input name="date_fr_s" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr_s")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr_s');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
to
<input name="date_to_s" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_to_s")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<a href="javascript:show_calendar('form_.date_to_s');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  
	  </td>
    </tr>
    <tr bgcolor="#66CCCC">
      <td height="25"></td>
      <td colspan="2" class="thinborderNONE" style="font-weight:bold">Reserved By: 
	  <input name="reserved_by" type="text" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("reserved_by")%>" size="16">
	  <label id="coa_info" style="position:absolute; width:450px;"></label>
	  
	  <input type="button" name="12" value=" Search Result " style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
	  	onClick="document.form_.search_page.value='1';document.form_.page_action.value='';document.form_.info_index.value='';document.form_.submit()">
	  
	  </td>
    </tr>
    <tr bgcolor="#66CCCC">
      <td height="25"></td>
      <td colspan="2" class="thinborderNONE">&nbsp;</td>
    </tr>
    <tr> 
      <td height="15" colspan="3"><hr size="1"></td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr >
      <td height="25" width="3%">&nbsp;</td>
      <td >&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print statistics</font></div></td>
    </tr>
  </table>
<%
int iNew = Integer.parseInt((String)vRetResult.remove(0));

boolean bolShowEdit = false;
if(WI.fillTextValue("show_all").length() ==  0) 
	bolShowEdit = true;

if(bolIsSearchCalled){
strTemp = WI.fillTextValue("date_fr_s");
if(WI.fillTextValue("date_to_s").length() > 0) 
	strTemp += " - "+WI.fillTextValue("date_to_s");
if(strTemp.length() > 0) 
	strTemp = " for Date: "+strTemp;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="20" align="center" style="font-size:11px;">
	  <font style="font-weight:bold; font-size:14px;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font> <br>
	  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
	  List of Reserved room <%=strTemp%>	  </td>
    </tr>
    <tr>
      <td align="right" style="font-size:11px;">Date and Time Printed: <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
<%}else{%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><strong><font size="1">
	  Total Rooms Reserved : <%=iNew%>(New), <%=vRetResult.size()/15 - iNew%> (Old) </font></strong></td>
      <td><div align="right"></div></td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFFFCE">
      <td width="13%" height="25" align="center" class="thinborder"><font size="1"><strong>ROOM RESERVED </strong></font></td>
      <td width="21%" align="center" class="thinborder"><font size="1"><strong>RESERVED ON</strong></font></td>
      <td width="47%" align="center" class="thinborder"><font size="1"><strong>RESERVATION NOTE</strong></font></td>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>RESERVED BY</strong></font></td>
<%if(bolShowEdit && !bolIsSearchCalled){%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>EDIT</strong></font></td>
<%}if(!bolIsSearchCalled){%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>REMOVE </strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>PRINT</strong></td>
<%}%>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 15){%>
    <tr>
      <td height="25" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%> </td>
      <td align="center" class="thinborder"><font size="1" color="#0000FF"><%=(String)vRetResult.elementAt(i + 13)%></font></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
<%if(bolShowEdit && !bolIsSearchCalled){%>
      <td align="center" class="thinborder">
	  	<%if(iAccessLevel > 1){%>
		  <a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i)%>','3');"><img src="../../../images/edit.gif" border="0"></a>
		<%}else{%>&nbsp;<%}%>	  </td>
<%}if(!bolIsSearchCalled){%>
      <td align="center" class="thinborder">
	  	<%if(iAccessLevel == 2){%>
		  <a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i)%>','0');"><img src="../../../images/x.gif" border="0"></a>
		<%}else{%>&nbsp;<%}%>	  </td>
      
	  <td align="center" class="thinborder">
	  <a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i)%>','');"><img src="../../../images/print.gif" border="0"></a>
	  </td>
      <%}%>
    </tr>
<%}%>
  </table>
<%
}//only if vRetResult is not null
%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center"></div></td>
      <td width="26%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="printPg">
<input type="hidden" name="page_action">
<input type="hidden" name="search_page">
<input type="hidden" name="info_index" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>