<%@ page language="java" import="utility.*,enrollment.EnrollmentRoomMonitor,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;

	String strErrMsg = "";
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
	document.vscheduling.submit();
}
function PrintPg()
{
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var strViewFac = "0";
		if(document.vscheduling.view_fac.checked) 
			strViewFac = "1";
		var pgLoc = "./room_print_scheduling.jsp?room_index="+document.vscheduling.room_index.value+"&offering_yr_from="+
			document.vscheduling.offering_yr_from.value+"&offering_yr_to="+document.vscheduling.offering_yr_to.value+
			"&offering_sem="+document.vscheduling.offering_sem.value+
			"&view_fac="+strViewFac;
		var win=window.open(pgLoc,"PrintWindow",'width=700,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function PrintThisPage() {
	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div><br>";
	this.insRowVarTableID('myADTable',0, 1, strInfo);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(1);
	alert("Click OK to print this page");
	window.print();
}

function GoToNewFormat() {
	location = "./room_view_scheduling_new.jsp";
}

</script>

<body bgcolor="#FFFFFF">
<%
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ROOMS MONITORING",request.getRemoteAddr(),
														"room_view_scheduling.jsp");
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

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
EnrollmentRoomMonitor ERM = new EnrollmentRoomMonitor();

Vector vRoomDetail = new Vector();
Vector vRoomSchedule = new Vector();
Vector vFacInfo      = null; String strFacName = null;
strTemp = request.getParameter("room_index");
if(strTemp != null && strTemp.compareTo("selany") != 0) //room is selected.
{

	vRoomDetail = ERM.viewOneRoom(dbOP, strTemp );
	boolean bolShowFaculty = false;
	if(WI.fillTextValue("view_fac").length() > 0)
		bolShowFaculty = true;
		
	vRoomSchedule = ERM.getRoomSchDetail(dbOP,strTemp,request.getParameter("offering_yr_from"),request.getParameter("offering_yr_to"),
		request.getParameter("offering_sem"),bolShowFaculty);
	if(vRoomSchedule == null)
		strErrMsg = ERM.getErrMsg();
	else {
		if(bolShowFaculty)
			vFacInfo = (Vector)vRoomSchedule.remove(0);
		if(vRoomSchedule.size() ==0)
			strErrMsg = "No time schedule attached to this room.";
	}
}
//System.out.println(vFacInfo);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<form name="vscheduling" action="./room_view_scheduling.jsp" method="post">
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
      <td height="25">School Offering Year/Term</td>
      <td width="75%"> 
        <%
strTemp = WI.fillTextValue("offering_yr_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="offering_yr_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("vscheduling","offering_yr_from","offering_yr_to")'>
        to 
        <%
strTemp = WI.fillTextValue("offering_yr_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="offering_yr_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
        &nbsp; &nbsp;&nbsp;&nbsp; <select name="offering_sem" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("offering_sem");
if(strTemp == null) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp == null) 
	strTemp = "";

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
<%if(!strSchCode.startsWith("VMA")){
	strTemp = WI.fillTextValue("view_fac");
	if(strTemp.length() > 0)
		strTemp = "checked";
	else	
		strTemp = "";
%>
		<input type="checkbox" value="1" <%=strTemp%> name="view_fac">View Faculty assigned 
		<div align="right">
		<a href="javascript:GoToNewFormat();">Go to New Format</a>		
		</div>
<%}%>		
	  </td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="23%">Select a Room number:</td>
      <td width="75%"> <select name="room_index" onChange="ReloadPage();">
          <option value="selany">Select a room</option>
          <%=dbOP.loadCombo("room_index","room_number"," from E_ROOM_DETAIL where IS_DEL=0 AND IS_VALID=1 and NFS_ASSIGNMENT=0 ORDER BY ROOM_NUMBER", request.getParameter("room_index"), true)%> 
        </select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%
if(vRoomDetail != null && vRoomDetail.size() >0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="33%">Room # : <strong><%=(String)vRoomDetail.elementAt(0)%></strong></td>
      <td width="33%">Type : <strong><%=(String)vRoomDetail.elementAt(1)%></strong></td>
      <td width="32%">Location/Floor : <strong><%=(String)vRoomDetail.elementAt(5)%>/<%=(String)vRoomDetail.elementAt(6)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Reg. Students : <strong><%=WI.getStrValue(vRoomDetail.elementAt(2))%> 
        </strong></td>
      <td>Irreg. Students : <strong><%=WI.getStrValue(vRoomDetail.elementAt(3))%></strong> 
      </td>
      <td>Total Capacity: <strong><%=WI.getStrValue(vRoomDetail.elementAt(4))%> 
        </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr> 
      <td width="100%" height="25"><b><%=WI.getStrValue(strErrMsg)%></b></td>
    </tr>
    <tr>
      <td height="25"><div align="right"><a href="javascript:PrintThisPage();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print room schedules</font></div></td>
    </tr>
  </table> 
  <%
  if(vRoomSchedule != null && vRoomSchedule.size() > 0){%>

    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="7" align="center" class="thinborder"><strong><font color="#333399" size="2">ROOM 
        SCHEDULES</font></strong></td>
    </tr>
    <tr> 
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>MONDAY</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>TUESDAY</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>WEDNESDAY</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>THURSDAY</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>FRIDAY</strong></font></td>
      <td width="14%" height="25" align="center" class="thinborder"><font size="1"><strong>SATURDAY</strong></font></td>
      <td width="14%" height="25" align="center" class="thinborder"><font size="1"><strong>SUN</strong></font></td>
    </tr>
    <%
	//get here constants. 10:0 am to 11:0 am / EE-A section
	String[] convertAMPM={" am"," pm"};//System.out.println("Start of printing ......................................");
	//build here the time table -- start from 5 am to 11 pm.
	int iStartFrom_24 = 0; int iEndAt_24 = 24;int iStartTo_24 = 2; int iFacInfoIndex = 0;int iTemp = 0;
	int iScheduleTime = 0;boolean bolProceed = true;//int p = 0;
	for(int i=0; i< vRoomSchedule.size(); )
	{
		//arrange the schedule from 1am to 24pm ;-)
		iScheduleTime = (int)Float.parseFloat( (String)vRoomSchedule.elementAt(i+9));
		//System.out.println(iScheduleTime);		System.out.println(vRoomSchedule.elementAt(i));
		///the query is in asc order, so if first result does not match -- do not proceed further.
		while(iScheduleTime <iStartFrom_24 || iScheduleTime >=iStartTo_24)
		{
			bolProceed = true;
			++iStartFrom_24;++iStartTo_24;
			if(iStartFrom_24 > iEndAt_24)
			{
				i = vRoomSchedule.size();
				bolProceed = false;
				break;
			}//System.out.println(iScheduleTime);
			//to print the empty schedule --- do it here. check the time and print empty table.
		}
		//if(iScheduleTime == 10){++p; if(p == 3) break;} for testing.
		%>
    <tr> 
      <%strTemp = "";strFacName = null;
		  while( bolProceed && ((String)vRoomSchedule.elementAt(i)).compareTo("1") ==0) //this is monday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  
		  //if faculty is loaded get fac infor.
		  if(vFacInfo != null && vFacInfo.size() > 0 && strFacName == null) {
		  	iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7)) ;
			while(iFacInfoIndex != -1) {
			//if(iFacInfoIndex > -1) {
				if( ((String)vFacInfo.elementAt(iFacInfoIndex + 1)).compareTo((String)vRoomSchedule.elementAt(i + 8)) == 0 &&
					((String)vFacInfo.elementAt(iFacInfoIndex + 2)).compareTo((String)vRoomSchedule.elementAt(i + 10)) == 0) {
					strFacName =(String)vFacInfo.elementAt(iFacInfoIndex + 3) ;break;
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
				}
				iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7), iFacInfoIndex + 1) ;				
			}
		  }	
			
		  strTemp += WI.getStrValue(vRoomSchedule.elementAt(i+11),"<br>","")+
		  			(String)vRoomSchedule.elementAt(i+1)+":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+2))+
					convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+3))]+" to "+(String)vRoomSchedule.elementAt(i+4)+
					":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+5))+ convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+6))]+"<br>"+
					(String)vRoomSchedule.elementAt(i+7)+"<br>"+(String)vRoomSchedule.elementAt(i+8)+"<br>("+
					(String)vRoomSchedule.elementAt(i+10)+")";
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);//++i;
			if(vRoomSchedule.size() > 10)
				iScheduleTime = (int)Float.parseFloat( (String)vRoomSchedule.elementAt(i+9));
			else iScheduleTime = -1;
			if(iScheduleTime >=iStartFrom_24 && iScheduleTime <iStartTo_24) bolProceed=true;
			else bolProceed = false;//System.out.println(iScheduleTime);		System.out.println(vRoomSchedule.elementAt(i));
			//System.out.println("printing .");
			}%>
      <td align="center" height="25" class="thinborder">
	  <%=WI.getStrValue(strTemp,"&nbsp;")%><%=WI.getStrValue(strFacName,"<br><font size=1 color=blue>","</font>","")%></td>
      <%
	  	strTemp = "";strFacName = null;
	  	while( bolProceed && ((String)vRoomSchedule.elementAt(i)).compareTo("2") ==0) //this is Tuesday
		  {if(strTemp.length() > 0) strTemp += "<br>";

		  //if faculty is loaded get fac infor.
		  if(vFacInfo != null && vFacInfo.size() > 0 && strFacName == null) {
		  	iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7)) ;
			while(iFacInfoIndex != -1) {
			//if(iFacInfoIndex > -1) {
				if( ((String)vFacInfo.elementAt(iFacInfoIndex + 1)).compareTo((String)vRoomSchedule.elementAt(i + 8)) == 0 &&
					((String)vFacInfo.elementAt(iFacInfoIndex + 2)).compareTo((String)vRoomSchedule.elementAt(i + 10)) == 0) {
					strFacName =(String)vFacInfo.elementAt(iFacInfoIndex + 3) ;break;
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
				}
				iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7), iFacInfoIndex + 1) ;				
			}
		  }	
		  
		  strTemp += WI.getStrValue(vRoomSchedule.elementAt(i+11),"<br>","")+
		  			(String)vRoomSchedule.elementAt(i+1)+":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+2))+
					convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+3))]+" to "+(String)vRoomSchedule.elementAt(i+4)+
					":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+5))+ convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+6))]+"<br>"+
					(String)vRoomSchedule.elementAt(i+7)+"<br>"+(String)vRoomSchedule.elementAt(i+8)+"<br>("+
					(String)vRoomSchedule.elementAt(i+10)+")";
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);//++i;
			if(vRoomSchedule.size() > (i+10))
				iScheduleTime = (int)Float.parseFloat( (String)vRoomSchedule.elementAt(i+9));
			else iScheduleTime = -1;
			if(iScheduleTime >=iStartFrom_24 && iScheduleTime <iStartTo_24) bolProceed=true;
			else bolProceed = false;//System.out.println("printing .");
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%><%=WI.getStrValue(strFacName,"<br><font size=1 color=blue>","</font>","")%></td>
      <%strTemp = "";strFacName = null;
	  	while( bolProceed && ((String)vRoomSchedule.elementAt(i)).compareTo("3") ==0) //this is Wednesday
		  {if(strTemp.length() > 0) strTemp += "<br>";

		  //if faculty is loaded get fac infor.
		  if(vFacInfo != null && vFacInfo.size() > 0 && strFacName == null) {
		  	iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7)) ;
			while(iFacInfoIndex != -1) {
			//if(iFacInfoIndex > -1) {
				if( ((String)vFacInfo.elementAt(iFacInfoIndex + 1)).compareTo((String)vRoomSchedule.elementAt(i + 8)) == 0 &&
					((String)vFacInfo.elementAt(iFacInfoIndex + 2)).compareTo((String)vRoomSchedule.elementAt(i + 10)) == 0) {
					strFacName =(String)vFacInfo.elementAt(iFacInfoIndex + 3) ;break;
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
				}
				iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7), iFacInfoIndex + 1) ;				
			}
		  }	
		  
		  strTemp += WI.getStrValue(vRoomSchedule.elementAt(i+11),"<br>","")+
		  			(String)vRoomSchedule.elementAt(i+1)+":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+2))+
					convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+3))]+" to "+(String)vRoomSchedule.elementAt(i+4)+
					":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+5))+ convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+6))]+"<br>"+
					(String)vRoomSchedule.elementAt(i+7)+"<br>"+(String)vRoomSchedule.elementAt(i+8)+"<br>("+
					(String)vRoomSchedule.elementAt(i+10)+")";
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);//++i;
			if(vRoomSchedule.size() > (i+10))
				iScheduleTime = (int)Float.parseFloat( (String)vRoomSchedule.elementAt(i+9));
			else iScheduleTime = -1;
			if(iScheduleTime >=iStartFrom_24 && iScheduleTime <iStartTo_24) bolProceed=true;
			else bolProceed = false;//System.out.println("printing .");
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%><%=WI.getStrValue(strFacName,"<br><font size=1 color=blue>","</font>","")%></td>
      <%strTemp = "";strFacName = null;
	  	while( bolProceed && ((String)vRoomSchedule.elementAt(i)).compareTo("4") ==0) //this is Thursday
		  {if(strTemp.length() > 0) strTemp += "<br>";

		  //if faculty is loaded get fac infor.
		  if(vFacInfo != null && vFacInfo.size() > 0 && strFacName == null) {
		  	iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7)) ;
			while(iFacInfoIndex != -1) {
			//if(iFacInfoIndex > -1) {
				if( ((String)vFacInfo.elementAt(iFacInfoIndex + 1)).compareTo((String)vRoomSchedule.elementAt(i + 8)) == 0 &&
					((String)vFacInfo.elementAt(iFacInfoIndex + 2)).compareTo((String)vRoomSchedule.elementAt(i + 10)) == 0) {
					strFacName =(String)vFacInfo.elementAt(iFacInfoIndex + 3) ;break;
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
				}
				iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7), iFacInfoIndex + 1) ;				
			}
		  }	
		  
		  strTemp += WI.getStrValue(vRoomSchedule.elementAt(i+11),"<br>","")+
		  			(String)vRoomSchedule.elementAt(i+1)+":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+2))+
					convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+3))]+" to "+(String)vRoomSchedule.elementAt(i+4)+
					":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+5))+ convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+6))]+"<br>"+
					(String)vRoomSchedule.elementAt(i+7)+"<br>"+(String)vRoomSchedule.elementAt(i+8)+"<br>("+
					(String)vRoomSchedule.elementAt(i+10)+")";
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);//++i;
			if(vRoomSchedule.size() > (i+10))
				iScheduleTime = (int)Float.parseFloat( (String)vRoomSchedule.elementAt(i+9));
			else iScheduleTime = -1;
			if(iScheduleTime >=iStartFrom_24 && iScheduleTime <iStartTo_24) bolProceed=true;
			else bolProceed = false;//System.out.println("printing .");
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%><%=WI.getStrValue(strFacName,"<br><font size=1 color=blue>","</font>","")%></td>
      <%strTemp = "";strFacName = null;
	  	while( bolProceed && ((String)vRoomSchedule.elementAt(i)).compareTo("5") ==0) //this is Friday
		  {if(strTemp.length() > 0) strTemp += "<br>";

		  //if faculty is loaded get fac infor.
		  if(vFacInfo != null && vFacInfo.size() > 0 && strFacName == null) {
		  	iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7)) ;
			while(iFacInfoIndex != -1) {
			//if(iFacInfoIndex > -1) {
				if( ((String)vFacInfo.elementAt(iFacInfoIndex + 1)).compareTo((String)vRoomSchedule.elementAt(i + 8)) == 0 &&
					((String)vFacInfo.elementAt(iFacInfoIndex + 2)).compareTo((String)vRoomSchedule.elementAt(i + 10)) == 0) {
					strFacName =(String)vFacInfo.elementAt(iFacInfoIndex + 3) ;break;
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
				}
				iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7), iFacInfoIndex + 1) ;				
			}
		  }	
		  
		  strTemp += WI.getStrValue(vRoomSchedule.elementAt(i+11),"<br>","")+
		  			(String)vRoomSchedule.elementAt(i+1)+":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+2))+
					convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+3))]+" to "+(String)vRoomSchedule.elementAt(i+4)+
					":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+5))+ convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+6))]+"<br>"+
					(String)vRoomSchedule.elementAt(i+7)+"<br>"+(String)vRoomSchedule.elementAt(i+8)+"<br>("+
					(String)vRoomSchedule.elementAt(i+10)+")";
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);//++i;
			if(vRoomSchedule.size() > (i+10))
				iScheduleTime = (int)Float.parseFloat( (String)vRoomSchedule.elementAt(i+9));
			else iScheduleTime = -1;
			if(iScheduleTime >=iStartFrom_24 && iScheduleTime <iStartTo_24) bolProceed=true;
			else bolProceed = false;//System.out.println("printing .");
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%><%=WI.getStrValue(strFacName,"<br><font size=1 color=blue>","</font>","")%></td>
      <%strTemp = "";strFacName = null;
	  	while( bolProceed && ((String)vRoomSchedule.elementAt(i)).compareTo("6") ==0) //this is Saturday
		  {if(strTemp.length() > 0) strTemp += "<br>";

		  //if faculty is loaded get fac infor.
		  if(vFacInfo != null && vFacInfo.size() > 0 && strFacName == null) {
		  	iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7)) ;
			while(iFacInfoIndex != -1) {
			//if(iFacInfoIndex > -1) {
				if( ((String)vFacInfo.elementAt(iFacInfoIndex + 1)).compareTo((String)vRoomSchedule.elementAt(i + 8)) == 0 &&
					((String)vFacInfo.elementAt(iFacInfoIndex + 2)).compareTo((String)vRoomSchedule.elementAt(i + 10)) == 0) {
					strFacName =(String)vFacInfo.elementAt(iFacInfoIndex + 3) ;break;
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
				}
				iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7), iFacInfoIndex + 1) ;				
			}
		  }	
		  
		  strTemp += WI.getStrValue(vRoomSchedule.elementAt(i+11),"<br>","")+
		  			(String)vRoomSchedule.elementAt(i+1)+":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+2))+
					convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+3))]+" to "+(String)vRoomSchedule.elementAt(i+4)+
					":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+5))+ convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+6))]+"<br>"+
					(String)vRoomSchedule.elementAt(i+7)+"<br>"+(String)vRoomSchedule.elementAt(i+8)+"<br>("+
					(String)vRoomSchedule.elementAt(i+10)+")";
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);//++i;
			if(vRoomSchedule.size() > (i+10))
				iScheduleTime = (int)Float.parseFloat( (String)vRoomSchedule.elementAt(i+9));
			else iScheduleTime = -1;
			if(iScheduleTime >=iStartFrom_24 && iScheduleTime <iStartTo_24) bolProceed=true;
			else bolProceed = false;//System.out.println("printing .");
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%><%=WI.getStrValue(strFacName,"<br><font size=1 color=blue>","</font>","")%></td>
      <%strTemp = "";strFacName = null;
	  	while( bolProceed && ((String)vRoomSchedule.elementAt(i)).compareTo("0") ==0) //this is Sunday
		  {if(strTemp.length() > 0) strTemp += "<br>";

		  //if faculty is loaded get fac infor.
		  if(vFacInfo != null && vFacInfo.size() > 0 && strFacName == null) {
		  	iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7)) ;
			while(iFacInfoIndex != -1) {
			//if(iFacInfoIndex > -1) {
				if( ((String)vFacInfo.elementAt(iFacInfoIndex + 1)).compareTo((String)vRoomSchedule.elementAt(i + 8)) == 0 &&
					((String)vFacInfo.elementAt(iFacInfoIndex + 2)).compareTo((String)vRoomSchedule.elementAt(i + 10)) == 0) {
					strFacName =(String)vFacInfo.elementAt(iFacInfoIndex + 3) ;break;
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
					//vFacInfo.removeElementAt(iFacInfoIndex); vFacInfo.removeElementAt(iFacInfoIndex);
				}
				iFacInfoIndex = vFacInfo.indexOf(vRoomSchedule.elementAt(i + 7), iFacInfoIndex + 1) ;				
			}
		  }	
		  
		  strTemp += WI.getStrValue(vRoomSchedule.elementAt(i+11),"<br>","")+
		  			(String)vRoomSchedule.elementAt(i+1)+":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+2))+
					convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+3))]+" to "+(String)vRoomSchedule.elementAt(i+4)+
					":"+CommonUtil.formatMinute((String)vRoomSchedule.elementAt(i+5))+ convertAMPM[Integer.parseInt((String)vRoomSchedule.elementAt(i+6))]+"<br>"+
					(String)vRoomSchedule.elementAt(i+7)+"<br>"+(String)vRoomSchedule.elementAt(i+8)+"<br>("+
					(String)vRoomSchedule.elementAt(i+10)+")";
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);
			vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);vRoomSchedule.removeElementAt(i);//++i;
			if(vRoomSchedule.size() > (i+10))
				iScheduleTime = (int)Float.parseFloat( (String)vRoomSchedule.elementAt(i+9));
			else iScheduleTime = -1;
			if(iScheduleTime >=iStartFrom_24 && iScheduleTime <iStartTo_24) bolProceed=true;
			else bolProceed = false;//System.out.println("printing .");
			}%>
      <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%><%=WI.getStrValue(strFacName,"<br><font size=1 color=blue>","</font>","")%></td>
    </tr>
    <%
	//i = i+9;
	}%>
  </table>
<% 	}//end of displaying the room schedule.
} //end of showing the room detail - show the room schedule if there is any room availble.
%>
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>