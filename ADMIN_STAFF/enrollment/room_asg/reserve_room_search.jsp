<%
WebInterface WI = new WebInterface(request);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.printPg.value = "";
	document.form_.submit();
}
function PrintPg() {

}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function copyRoomNo(strRoomNo)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strRoomNo;
	window.opener.focus();
	window.opener.document.form_.submit();
	
	self.close();
}
<%}%>
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.EnrollmentRoomMonitor,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
		
//add security here.
	try
	{
		dbOP = new DBOperation();
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

Vector vRetResult = null;
EnrollmentRoomMonitor ERM = new EnrollmentRoomMonitor();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0)
{
	vRetResult = ERM.getRoomStat(dbOP,request);
	if(vRetResult == null)
		strErrMsg = ERM.getErrMsg();
}
boolean bolIsCalledOpnerForm = false;
if(WI.fillTextValue("opner_info").length() > 0)
	bolIsCalledOpnerForm = true;
%>
<form name="form_" action="./reserve_room_search.jsp" method="post">

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          ROOM AVAILABILITY INFORMATION ::::</strong></font></strong></font></div></td>
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
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="57%">TERM 
        <select name="semester">
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
        </select></td>
    </tr>
    <tr> 
      <td height="15" colspan="5"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%" height="25"></td>
      <td>ROOM STATUS</td>
      <td colspan="3"> 
        <select name="room_stat">
          <%
strTemp = WI.fillTextValue("room_stat");
if(strTemp.compareTo("Available") ==0){%>
          <option selected value="Available">Available</option>
          <%}else{%>
          <option value="Available">Available</option>
          <%}if(strTemp.compareTo("Occupied") == 0){%>
          <option value="Occupied" selected>Occupied</option>
          <%}else{%>
          <option value="Occupied">Occupied</option>
          <%}%>
        </select>
      </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>DATE RANGE</td>
      <td colspan="3"><font size="1">
        <%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> to
        <%
strTemp = WI.fillTextValue("date_to");
%>
        <input name="date_to" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>&nbsp;</td>
      <td colspan="3">
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
      <td>ROOM NUMBER</td>
      <td colspan="3"><input name="room_number" type="text" size="12" value="<%=WI.fillTextValue("room_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <br> <font size="1">(Optional.This field takes room # &lt;starts with&gt; 
        input.Ex. CEN outputs CENRUM 01/CENTRUM 02...)</font> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2">SHOW BY</td>
      <td colspan="2">&nbsp;</td>
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
      <td height="10"><div align="center">
          <hr size="1">
        </div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
if(false && WI.fillTextValue("opner_info").length() == 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" width="3%">&nbsp;</td>
      <td >&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print statistics</font></div></td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DBD8C8">
      <td height="20" width="3%">&nbsp;</td>
      <td ><font size="1">ROOM STATUS :<strong> <%=WI.fillTextValue("room_stat").toUpperCase()%></strong></font></td>
      <td><div align="right"></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td height="20" width="26%" class="thinborder" align="center"><strong>ROOM LOCATION </strong></td>
      <td width="74%" class="thinborder" align="center"><strong>ROOM NUMBERS </strong></td>
    </tr>
<%
boolean bolLineBreak; //only if more than one room for a location.
for(int i =0; i < vRetResult.size(); i += 4){%>
    <tr>
      <td height="20" class="thinborder">&nbsp;<%=vRetResult.elementAt(i)%></td>
      <td class="thinborder">
	  <%for(bolLineBreak = false; i < vRetResult.size(); i += 4,bolLineBreak=true) {
	  		if(bolLineBreak && vRetResult.elementAt(i) != null) {
				i = i - 4;
				break;
			}
	  		if(bolLineBreak){%> 
	  			<br>
	  		<%}
			if(bolIsCalledOpnerForm){%>
				<a href="javascript:copyRoomNo('<%=vRetResult.elementAt(i + 1)%>')">
			<%}%>
			<%=(String)vRetResult.elementAt(i + 2)%>
			<%if(bolIsCalledOpnerForm){%></a>
	  <%}
	  }%>
	  </td>
    </tr>
<%}%>
  </table>


<%
}//only if vRetResult is not null
%>

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
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>