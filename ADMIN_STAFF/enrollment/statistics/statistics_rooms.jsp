<%
if(request.getParameter("printPg") != null && request.getParameter("printPg").compareTo("1") ==0){%>
		<jsp:forward page="./statistics_rooms_print.jsp" />
<%}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
//if(strSchCode.startsWith("CIT")) {
//	response.sendRedirect("./search_room_vacant.jsp");
//	return;
//}

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.stat_room.printPg.value = "";
	document.stat_room.submit();
}
function PrintPg()
{
	document.stat_room.printPg.value = "1";
	document.stat_room.range.value = document.stat_room.time_from_hr.value +":"+
									document.stat_room.time_from_min.value+" "+
									document.stat_room.time_from_AMPM[document.stat_room.time_from_AMPM.selectedIndex].text+
									" to "+
									document.stat_room.time_to_hr.value +":"+
									document.stat_room.time_to_min.value+" "+
									document.stat_room.time_to_AMPM[document.stat_room.time_to_AMPM.selectedIndex].text+
									" ("+document.stat_room.week_day.value +")"

	document.stat_room.submit();
}
function OtherFormat() {
	location = "./search_room_vacant.jsp";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	//SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS-ROOMS","statistics_rooms.jsp");
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
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"statistics_rooms.jsp");
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

Vector vRetResult = new Vector();
StatEnrollment SE = new StatEnrollment();
Vector vOccupiedRoom  = null;
Vector vAvailableRoom = null;

boolean bolShowOnlyRoomNo = false;
if(WI.fillTextValue("show_only_room").length() > 0) 
	bolShowOnlyRoomNo = true;

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("offering_sem").length() > 0)
{
	vRetResult = SE.getRoomStat(dbOP,request);
	if(vRetResult == null)
		strErrMsg = SE.getErrMsg();
	else	
	{
		if(bolShowOnlyRoomNo) {
			String strSQLQuery = "select room_number,room_status from TEMP_ENRL_STATISTICS  order by room_number, room_status";//room_status 0 = occupied.
			java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
			vOccupiedRoom = new Vector();
			vAvailableRoom = new Vector();
			while(rs.next()) {
				if(rs.getInt(2) == 0) 
					vOccupiedRoom.addElement(rs.getString(1));
				else
					vAvailableRoom.addElement(rs.getString(1));
			}
			rs.close();
			
			if(WI.fillTextValue("room_stat").equals("Occupied"))
				vAvailableRoom = null;
			else if(WI.fillTextValue("room_stat").length() > 0)
				vOccupiedRoom = null;
		}
		else {
			vOccupiedRoom  = (Vector)vRetResult.elementAt(0);
			vAvailableRoom = (Vector)vRetResult.elementAt(1);
		}
	}
}


%>
<form name="stat_room" action="./statistics_rooms.jsp" method="post">

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          STATISTICS - ROOMS PAGE ::::</strong></font></strong></font></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="27"></td>
      <td colspan="4"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="3">SCHOOL YEAR 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("stat_room","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
        &nbsp;</td>
      <td width="57%">TERM 
        <select name="offering_sem">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
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
        </select>
		&nbsp;&nbsp;&nbsp;&nbsp;
		
		<a href="javascript:OtherFormat()">Go to Other Format</a>
		</td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%" height="25"></td>
      <td>ROOM STATUS</td>
      <td colspan="3"> 
        <select name="room_stat">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("room_stat");
if(strTemp.compareTo("Occupied") ==0){%>
          <option selected value="Occupied">Occupied</option>
          <%}else{%>
          <option value="Occupied">Occupied</option>
          <%}if(strTemp.compareTo("Available") == 0){%>
          <option value="Available" selected>Available</option>
          <%}else{%>
          <option value="Available">Available</option>
          <%}%>
        </select>        </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>RANGE</td>
      <td colspan="3"><input type="text" name="week_day" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("week_day")%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();">
        (M-T-W-TH-F-SAT-S)</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>&nbsp;</td>
      <td colspan="3"><input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input type="text" name="time_from_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <select name="time_from_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_from_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
        <input type="text" name="time_to_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input type="text" name="time_to_min"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <select name="time_to_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_to_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
<%}else{%>
          <option value="1">PM</option>
<%}%>        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>ROOM NUMBER</td>
      <td colspan="3"><input name="room_number" type="text" size="12" value="<%=WI.fillTextValue("room_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <br> <font size="1">(Optional.This field takes room # &lt;starts with&gt; 
        input.Ex. CEN outputs CENRUM 01/CENTRUM 02...)</font> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="4">
<%
if(WI.fillTextValue("show_room_number").compareTo("1") ==0)
	strTemp = " checked";
else	
 	strTemp = "";
%>
	    <input type="checkbox" name="show_room_number" value="1"<%=strTemp%>> Show Room number Per Room Type/Location
&nbsp;&nbsp;&nbsp;
	    <input type="checkbox" name="show_only_room" value="checked"<%=WI.fillTextValue("show_only_room")%>> Show only room number (remove type/location)
		
		</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="15%">&nbsp;</td>
      <td width="13%"> LOCATION</td>
      <td colspan="2"> <select name="room_location" onChange="ReloadPage();">
          <option value="">ALL BUILDINGS</option>
          <%=dbOP.loadComboDISTINCT("LOCATION","LOCATION"," from E_ROOM_DETAIL where IS_DEL=0 order by location asc",WI.fillTextValue("room_location") , false)%> 
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td> TYPE</td>
      <td colspan="2"><select name="room_type" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadComboDISTINCT("TYPE","TYPE"," from E_ROOM_TYPE where IS_DEL=0 order by TYPE asc",WI.fillTextValue("room_type") , false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"><div align="center">
          <hr size="1">
        </div></td>
    </tr>
  </table>
<%
if(bolShowOnlyRoomNo)
	vRetResult = null;
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" width="3%">&nbsp;</td>
      <td >&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print statistics</font></div></td>
    </tr>
  </table>
<%String strPrevLocation = null;
String strLocationToDisp = null;
if(vOccupiedRoom != null && vOccupiedRoom.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><font size="1">ROOM STATUS :<strong> OCCUPIED</strong></font></td>
      <td><div align="right"></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="44%" height="27" align="center"><font size="1"><strong>TYPE</strong></font></td>
      <td width="48%" align="center"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>TOTAL </strong></font></td>
    </tr>
<%
for(int i = 1; i< vOccupiedRoom.size();i +=3){
if(strPrevLocation == null || strPrevLocation.compareTo((String)vOccupiedRoom.elementAt(i)) !=0)
{
	strLocationToDisp = (String)vOccupiedRoom.elementAt(i);
	strPrevLocation    = (String)vOccupiedRoom.elementAt(i);
}
else	
	strLocationToDisp = "";
	%>
    <tr> 
      <td height="25"><%=strLocationToDisp%></td>
      <td><%=(String)vOccupiedRoom.elementAt(i+1)%></td>
      <td><%=(String)vOccupiedRoom.elementAt(i+2)%></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="89%" align="right"><strong><font size="1">GRAND 
          TOTAL : &nbsp;&nbsp;&nbsp;</font></strong></td>
      <td><strong><%=(String)vOccupiedRoom.elementAt(0)%> </strong></td>
    </tr>
    <tr>
</table>
<%}//if occupied room is having some value. 
strPrevLocation = null;
if(vAvailableRoom != null && vAvailableRoom.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><font size="1">ROOM STATUS :<strong> AVAILABLE</strong></font></td>
      <td><div align="right"></div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="44%" height="27" align="center"><font size="1"><strong>TYPE</strong></font></td>
      <td width="48%" align="center"><font size="1"><strong>LOCATION</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>TOTAL </strong></font></td>
    </tr>
<%
for(int i = 1; i< vAvailableRoom.size();i +=3){
if(strPrevLocation == null || strPrevLocation.compareTo((String)vAvailableRoom.elementAt(i)) !=0)
{
	strLocationToDisp = (String)vAvailableRoom.elementAt(i);
	strPrevLocation    = (String)vAvailableRoom.elementAt(i);
}
else	
	strLocationToDisp = "";
%>
    <tr> 
      <td height="25"><%=strLocationToDisp%></td>
      <td><%=(String)vAvailableRoom.elementAt(i+1)%></td>
      <td><%=(String)vAvailableRoom.elementAt(i+2)%></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="89%" align="right"><strong><font size="1">GRAND 
          TOTAL : &nbsp;&nbsp;&nbsp;</font></strong></td>
      <td><strong><%=(String)vAvailableRoom.elementAt(0)%> </strong></td>
    </tr>
    <tr>
</table>

<%
	}//if vAvailable Room is not null. 	
}//only if vRetResult is not null


if(bolShowOnlyRoomNo && vOccupiedRoom != null && vOccupiedRoom.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><font size="1">ROOM STATUS :<strong> OCCUPIED</strong></font></td>
      <td><div align="right"></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center"><font size="1"><strong>Room Number</strong></font></td>
    </tr>
<%
for(int i = 0; i< vOccupiedRoom.size();++i){%>
    <tr> 
      <td height="20"><%=(String)vOccupiedRoom.elementAt(i)%></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="89%" align="right"><strong><font size="1">GRAND 
          TOTAL : &nbsp;&nbsp;&nbsp;</font></strong></td>
      <td><strong><%=vOccupiedRoom.size()%> </strong></td>
    </tr>
    <tr>
</table>
<%}if(bolShowOnlyRoomNo && vAvailableRoom != null && vAvailableRoom.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><font size="1">ROOM STATUS :<strong> OCCUPIED</strong></font></td>
      <td><div align="right"></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center"><font size="1"><strong>Room Number</strong></font></td>
    </tr>
<%
for(int i = 0; i< vAvailableRoom.size();++i){%>
    <tr> 
      <td height="20"><%=(String)vAvailableRoom.elementAt(i)%></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="89%" align="right"><strong><font size="1">GRAND 
          TOTAL : &nbsp;&nbsp;&nbsp;</font></strong></td>
      <td><strong><%=vAvailableRoom.size()%> </strong></td>
    </tr>
    <tr>
</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
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
<input type="hidden" name="range">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>