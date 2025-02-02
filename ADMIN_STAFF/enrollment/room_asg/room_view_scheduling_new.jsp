<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-ROOMS MONITORING-room view scheduling","room_view_scheduling.jsp");
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
function ReloadPage()
{
	document.form_.submit();
}
function PrintThisPage() {
	document.getElementById('myADTable').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();
}

function GoToOldFormat() {
	location = "./room_view_scheduling.jsp";
}

</script>

<body bgcolor="#FFFFFF">
<%
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ROOMS MONITORING",request.getRemoteAddr(),
														"room_view_scheduling_new.jsp");
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

SubjectSection SS = new SubjectSection();
Vector vRetResult = null;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

if(WI.fillTextValue("room_i").length() > 0)  {
	vRetResult = SS.getRoomAssignmentDetail(dbOP, request, true);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();



}
String[] astrConvertTerm = {"SUMMER","1ST","2ND","3RD"}; 
//System.out.println(vFacInfo);
%>

<form name="form_" action="./room_view_scheduling_new.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" bgcolor="#FFFFFF"><div align="center"><font color="#000000"><strong><U>ROOM 
          SCHEDULE(S) FOR AY : <%=WI.fillTextValue("offering_yr_from")%> - 
		  <%=WI.fillTextValue("offering_yr_to")%>, <%=dbOP.getHETerm(Integer.parseInt(WI.getStrValue(WI.fillTextValue("offering_sem"), "-1")))%></U></strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">SY-Term</td>
      <td width="86%"> 
<%
strTemp = WI.fillTextValue("school_year_fr");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","school_year_fr","school_year_to")'>
        to 
        <%
strTemp = WI.fillTextValue("school_year_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
        &nbsp; &nbsp;&nbsp;&nbsp; <select name="offering_sem" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("offering_sem");
if(strTemp == null) strTemp = "";

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
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> 
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
<%
strTemp = WI.fillTextValue("view_fac");
if(strTemp.length() > 0)
	strTemp = "checked";
else	
	strTemp = "";
%>
		<!--<input type="checkbox" value="1" <%=strTemp%> name="view_fac">View Faculty assigned -->
		<div align="right">
		<a href="javascript:GoToOldFormat();">Go to Old Format</a>		
		</div>
	  </td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="12%">Room number:</td>
      <td width="86%"> <select name="room_i" onChange="ReloadPage();">
          <option value="">Select a room</option>
          <%=dbOP.loadCombo("room_index","room_number"," from E_ROOM_DETAIL where IS_DEL=0 AND IS_VALID=1 and NFS_ASSIGNMENT=0 ORDER BY ROOM_NUMBER", request.getParameter("room_i"), true)%> 
        </select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
      <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  
	  <%if(vRetResult != null && vRetResult.size() > 0) {%>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="javascript:javascript:PrintThisPage();"><img src="../../../images/print.gif" border="0"></a><font size="1">Print Page</font>
	  <%}%>
	  
	  </td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="76%" style="font-weight:bold">&nbsp;</td>
		<td width="24%" style="font-weight:bold; font-size:18px;" align="right">ROOM SCHEDULE</td>
	</tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td style="font-weight:bold" width="16%" class="thinborder" height="22">Description</td>
		<td width="24%" class="thinborder"><%=WI.getStrValue(vRetResult.remove(1), "&nbsp;")%></td>
		<td width="36%" rowspan="3" style="font-weight:bold; font-size:24px" class="thinborder" align="center">ROOM NUMBER </td>
		<td width="24%" rowspan="3" style="font-weight:bold; font-size:24px" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.remove(1))%></td>
	</tr>
	<tr>
	  <td style="font-weight:bold" class="thinborder" height="22">Area</td>
	  <td class="thinborder"><%=WI.getStrValue(vRetResult.remove(0), "&nbsp;")%></td>
    </tr>
	<tr>
	  <td style="font-weight:bold" class="thinborder" height="22">SY-Term</td>
	  <td class="thinborder"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, <%=WI.fillTextValue("school_year_fr")%> - <%=WI.fillTextValue("school_year_to").substring(2)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>TIME</strong></font></td> 
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>MONDAY</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>TUESDAY</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>WEDNESDAY</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>THURSDAY</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>FRIDAY</strong></font></td>
      <td width="13%" height="25" align="center" class="thinborder"><font size="1"><strong>SATURDAY</strong></font></td>
      <td width="12%" height="25" align="center" class="thinborder"><font size="1"><strong>SUNDAY</strong></font></td>
    </tr>
<%
boolean bolAdd12pm = false;
if(strSchCode.startsWith("VMA") || strSchCode.startsWith("EAC") || strSchCode.startsWith("SWU"))
	bolAdd12pm = true;

	Vector vTimeSch = new Vector();
	vTimeSch.addElement("07:00AM - 08:00AM");  vTimeSch.addElement("08:00AM - 09:00AM");
	vTimeSch.addElement("09:00AM - 10:00AM");  vTimeSch.addElement("10:00AM - 11:00AM");
	vTimeSch.addElement("11:00AM - 12:00PM");  
	if(bolAdd12pm)
		vTimeSch.addElement("12:00PM - 01:00PM");	
		
	vTimeSch.addElement("01:00PM - 02:00PM");
	vTimeSch.addElement("02:00PM - 03:00PM");  vTimeSch.addElement("03:00PM - 04:00PM");
	vTimeSch.addElement("04:00PM - 05:00PM");  vTimeSch.addElement("05:00PM - 06:00PM");
	vTimeSch.addElement("06:00PM - 07:00PM");  vTimeSch.addElement("07:00PM - 08:00PM");
	vTimeSch.addElement("08:00PM - 09:00PM");

	Vector vRoomSch = vRetResult;
	int iIndexOf = 0;
	
	double dStartTime = 6.5d;
	double dTimeFr = 0d;
	double dTimeTo = 0d;
	double dDiff   = 0d;
	
	String strValM  = null;
	String strValT  = null;
	String strValW  = null;
	String strValTH = null;
	String strValF  = null;
	String strValS  = null;
	String strValSU = null;
	
	boolean bolIsUsed = true;
	int iWeekDay   = 0;
	String strSubCode = null;
	String strRoomNo  = null;
	String strIsLec   = null;

	dStartTime = 6d;


	String[] astrWeekDaySched = {"","","","","","","",""};
	
for(int p = 0; p < vTimeSch.size(); ++p) {
	 dStartTime += 1d;
	 if(dStartTime == 12d && !bolAdd12pm)
	 	++dStartTime;
	 
	 astrWeekDaySched[0] = "&nbsp;";
	 astrWeekDaySched[1] = "&nbsp;";
	 astrWeekDaySched[2] = "&nbsp;";
	 astrWeekDaySched[3] = "&nbsp;";
	 astrWeekDaySched[4] = "&nbsp;";
	 astrWeekDaySched[5] = "&nbsp;";
	 astrWeekDaySched[6] = "&nbsp;";
	 
	 for(int a = 0; a < 7; ++a) {//7 days :: 0 = sunday.
	 	for(int b = 0; b < vRoomSch.size(); b += 13) {
	 		iWeekDay = Integer.parseInt((String)vRoomSch.elementAt(b));
	 		dTimeFr  = Double.parseDouble((String)vRoomSch.elementAt(b + 7));
	 		dTimeTo  = Double.parseDouble((String)vRoomSch.elementAt(b + 8));
	 		
	 		if(iWeekDay == a) {//match the time, if it falls.. 
				
	 			if(dStartTime == dTimeFr || (dTimeFr < dStartTime && dTimeTo > dStartTime) || (dTimeFr > dStartTime && (dTimeFr-1) < dStartTime)) {//due to 1 hour difference.
	 				//strTemp = (String)vRoomSch.elementAt(i + 11) + "<br>"+(String)vRoomSch.elementAt(i + 9);				
						astrWeekDaySched[a] = (String)vRoomSch.elementAt(b + 11) + 
							"<br>"+(String)vRoomSch.elementAt(b + 9)+ WI.getStrValue((String)vRoomSch.elementAt(b + 12), "<br>","","");
				}
	 		}	
	 	}
	 }

%>
    <tr>
	  <td height="15" class="thinborder" style="font-weight:bold"><%=vTimeSch.elementAt(p)%></td>
      <td align="center" height="25" class="thinborder"><%=astrWeekDaySched[1]%></td>
      <td align="center" class="thinborder"><%=astrWeekDaySched[2]%></td>
      <td align="center" class="thinborder"><%=astrWeekDaySched[3]%></td>
      <td align="center" class="thinborder"><%=astrWeekDaySched[4]%></td>
      <td align="center" class="thinborder"><%=astrWeekDaySched[5]%></td>
      <td align="center" class="thinborder"><%=astrWeekDaySched[6]%></td>
      <td align="center" class="thinborder"><%=astrWeekDaySched[0]%></td>
    </tr>
<%}%>

  </table>
<%}%>
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>