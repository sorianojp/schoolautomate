<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">

function GetRoomDetail(){
	document.form_.get_room_detail.value = "1";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagementExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	if(WI.fillTextValue("print_page").length() > 0){
		if(strSchCode.startsWith("AUF")){%>
		<jsp:forward page="./room_faculty_assignment_print_auf.jsp" />
	<%return;}else {%>
		<jsp:forward page="./room_faculty_assignment_print.jsp" />
	<%return;}
	}
	
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
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-REPORTS AND STATISTICS"),"0"));
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
//authenticate this user.

//end of authenticaion code.
FacultyManagementExtn facultyMgmt = new FacultyManagementExtn();

Vector vRetResult = null;


if(WI.fillTextValue("get_room_detail").length() > 0){
	vRetResult = facultyMgmt.getRoomAssignmentForFacultyAttendance(dbOP, request);
	if(vRetResult == null)
		strErrMsg = facultyMgmt.getErrMsg();
}


String[] astrTime     = {"4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19",
								"20","21","22","23"};
String[] astrTime12     = {"4","5","6","7","8","9","10","11","12","1","2","3","4","5","6","7",
								"8","9","10","11"};				
				
String[] astrTimeDisp = {"4AM","5AM","6AM","7AM","8AM","9AM","10AM","11AM","12NN","1PM","2PM","3PM",
								"4PM","5PM","6PM","7PM","8PM","9PM","10PM","11PM"};
								
String[] astrTimeInterval     = {"1","2","3","4","5","6","7","8"};
String[] astrTimeDispInterval = {"1Hr","2Hr","3Hr","4Hr","5Hr","6Hr","7Hr","8Hr"};
								
String[] astrMin      = {"0.0","0.5"};
String[] astrMinDisp  = {"00 Min","30 Min"};

String[] astrDay = {"SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY"};
String[] astrMinDisplay = {":00", ":30"};
String[] astrAMPM = {"AM", "PM", "NN"};


%>
<form action="./room_faculty_assignment.jsp" method="post" name="form_">
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" ><strong>::::
          FACULTY ATTENDANCE REPORT PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp; &nbsp; &nbsp; <font color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
      </tr>
   <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">School year </td>
      <td width="21%" height="25"> <%
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
	  readonly="yes"> 
	  
	  &nbsp; &nbsp;<select name="semester">
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
      <td width="58%">
	  <input type="button" name="Login" value="Generate Report" onClick="GetRoomDetail();">	  </td>
    </tr>
    
    <tr>
    	<td>&nbsp;</td>
      <td>Schedule Day</td>
      <td colspan="2">
      	<select name="date">
         <option value="">Select day of schedule</option>
         <%
			strTemp = WI.fillTextValue("date");
			if(strTemp.equals("1"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
         	<option value="1" <%=strErrMsg%>>MONDAY</option>
         <%			
			if(strTemp.equals("2"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
         	<option value="2" <%=strErrMsg%>>TUESDAY</option>
         <%			
			if(strTemp.equals("3"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
         	<option value="3" <%=strErrMsg%>>WEDNESDAY</option>
           <%			
			if(strTemp.equals("4"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
         	<option value="4" <%=strErrMsg%>>THURSDAY</option>
          <%			
			if(strTemp.equals("5"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
         	<option value="5" <%=strErrMsg%>>FRIDAY</option>
         <%			
			if(strTemp.equals("6"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
         	<option value="6" <%=strErrMsg%>>SATURDAY</option>
         <%			
			if(strTemp.equals("0"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
         	<option value="0" <%=strErrMsg%>>SUNDAY</option>
         </select>
      </td>
    </tr>
    
    
    <tr>
    	<td>&nbsp;</td>
      <td>Start Time</td>
      <td colspan="2">
      	<select name="start_time_hour" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("start_time_hour");
			//if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
			//	if(vRetResult.elementAt(0).equals("0"))
			//		strTemp = (String)vRetResult.elementAt(1);
			//}
			
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
              	<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
            <%}else{%>
            	<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select>
        
        : 
		  <select name="start_time_min" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("start_time_min");
			/*if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("0"))
					strTemp = (String)vRetResult.elementAt(2);
			}*/
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               	<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
            <%}else{%>
               	<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select> 
        
      </td>
    </tr>
    
    
     <tr>
    	<td>&nbsp;</td>
      <td>End Time</td>
      <td colspan="2">
      	<select name="end_time_hour" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("end_time_hour");
			//if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
			//	if(vRetResult.elementAt(0).equals("0"))
			//		strTemp = (String)vRetResult.elementAt(1);
			//}
			
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
              	<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
            <%}else{%>
            	<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select>
        
        : 
		  <select name="end_time_min" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("end_time_min");
			/*if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("0"))
					strTemp = (String)vRetResult.elementAt(2);
			}*/
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               	<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
            <%}else{%>
               	<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select> 
       
      </td>
    </tr>
    
    
    <tr>
    	<td>&nbsp;</td>
      <td>Interval Time</td>
      <td colspan="2">
      	<select name="interval_time_hour" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("interval_time_hour");
			//if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
			//	if(vRetResult.elementAt(0).equals("0"))
			//		strTemp = (String)vRetResult.elementAt(1);
			//}
			
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrTimeInterval.length; ++p){
				if(strTemp.equals(astrTimeInterval[p])){%>
              	<option value="<%=astrTimeInterval[p]%>" selected><%=astrTimeDispInterval[p]%></option>
            <%}else{%>
            	<option value="<%=astrTimeInterval[p]%>"><%=astrTimeDispInterval[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select>
        
        : 
		  <select name="interval_time_min" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("interval_time_min");
			/*if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("0"))
					strTemp = (String)vRetResult.elementAt(2);
			}*/
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               	<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
            <%}else{%>
               	<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select> 
      
      </td>
    </tr>
    
    
    <tr>
    	<td>&nbsp;</td>
      <td>Break Start Time (Optional)</td>
      <td colspan="2">
      	<select name="break_start_time_hour" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("break_start_time_hour");
			//if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
			//	if(vRetResult.elementAt(0).equals("0"))
			//		strTemp = (String)vRetResult.elementAt(1);
			//}
			
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
              	<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
            <%}else{%>
            	<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select>
        
        : 
		  <select name="break_start_time_min" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("break_start_time_min");
			/*if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("0"))
					strTemp = (String)vRetResult.elementAt(2);
			}*/
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               	<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
            <%}else{%>
               	<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select> 
       
      </td>
    </tr>
    
    
    <tr>
    	<td>&nbsp;</td>
      <td>Break End Time (Optional)</td>
      <td colspan="2">
      	<select name="break_end_time_hour" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("break_end_time_hour");
			//if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
			//	if(vRetResult.elementAt(0).equals("0"))
			//		strTemp = (String)vRetResult.elementAt(1);
			//}
			
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.equals(astrTime[p])){%>
              	<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
            <%}else{%>
            	<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select>
        
        : 
		  <select name="break_end_time_min" style="width:70px;">
          <option value=""></option>
          <%
			strTemp = WI.fillTextValue("break_end_time_min");
			/*if(strTemp == null && vRetResult != null && vRetResult.size() > 0) {
				if(vRetResult.elementAt(0).equals("0"))
					strTemp = (String)vRetResult.elementAt(2);
			}*/
			
			if(strTemp == null) strTemp = "";
			for(int p =0; p < astrMin.length; ++p){
				if(strTemp.equals(astrMin[p])){%>
               	<option value="<%=astrMin[p]%>" selected><%=astrMinDisp[p]%></option>
            <%}else{%>
               	<option value="<%=astrMin[p]%>"><%=astrMinDisp[p]%></option>
            <%}//end of else.
			}//end of for%>
        </select> 
       
      </td>
    </tr>
    
    <tr> 
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" align="right"> 
        <%if(vRetResult != null && vRetResult.size() > 0)
{%>
        <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print listing of rooms with details</font></td>
      <%}%>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){
	Vector vTime = (Vector)vRetResult.remove(0);
	
String strTimeFrom = null;
String strTimeTo = null;

String strTimeFrom24 = null;
String strTimeTo24 = null;	
String strSection = null;




	%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%for(int i = 0; i < vTime.size(); i += 2){
	
	strTimeFrom = (String)vTime.elementAt(i);
	strTimeTo = (String)vTime.elementAt(i+1);
	%>	
   <tr>
   <%
	strTemp = strTimeFrom.substring(strTimeFrom.indexOf(".") + 1);
	if(!strTemp.equals("0"))
		strTemp = "1";
		
	strTemp = astrTime12[Integer.parseInt(strTimeFrom.substring(0,strTimeFrom.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strTemp)];	
	
	strErrMsg = strTimeTo.substring(strTimeTo.indexOf(".") + 1);
	if(!strErrMsg.equals("0"))
		strErrMsg = "1";
	
	strErrMsg = astrTime12[Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strErrMsg)];
	
	if(Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) < 12)
		strErrMsg += " " + astrAMPM[0];
	else if(Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) == 12)
		strErrMsg += " " + astrAMPM[2];
	else if(Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) > 12)
		strErrMsg += " " + astrAMPM[1];
	
	%>
   	<td colspan="6" height="30" valign="bottom" align="center">
      	<font size="2"><strong><%=astrDay[Integer.parseInt(WI.fillTextValue("date"))]%> <%=strTemp + " - " + strErrMsg%></strong></font></td>
   </tr>
   
   <tr>
   	<td width="11%" height="18">&nbsp;<strong>ROOM</strong></td>
      <td width="33%" align="center"><strong>TEACHER</strong></td>
      <td width="13%" align="center">PRESENT</td>
      <td width="12%" align="center">TARDY</td>
      <td width="22%" align="center">TIME VERIFIED</td>
      <td width="9%" align="center">ABSENT</td>
   </tr>
   
   
   <%
	
	for(int x = 0; x < vRetResult.size(); x += 21){

		if( !((String)vRetResult.elementAt(x + 16)).equals(strTimeFrom) && !((String)vRetResult.elementAt(x + 17)).equals(strTimeTo)  )
			continue;
			
		vRetResult.remove(x);//sub_sec_index
		vRetResult.remove(x);//room_index
		%>
   <tr>
   	<td><%=(String)vRetResult.remove(x)%></td>
      <%
		
		vRetResult.remove(x);//room_type
		vRetResult.remove(x);//floor
		vRetResult.remove(x);//description
		vRetResult.remove(x);//status_remakr
		vRetResult.remove(x);//total_cap
		vRetResult.remove(x);//location
		vRetResult.remove(x);//is_lec
		
		strTimeFrom24 = (String)vRetResult.remove(x);
		strTimeTo24 = (String)vRetResult.remove(x);
		
		
		strTemp = strTimeFrom24.substring(strTimeFrom24.indexOf(".") + 1);
		if(!strTemp.equals("0"))
			strTemp = "1";
			
		strTemp = astrTime12[Integer.parseInt(strTimeFrom24.substring(0,strTimeFrom24.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strTemp)];	
		
		strErrMsg = strTimeTo24.substring(strTimeTo24.indexOf(".") + 1);
		if(!strErrMsg.equals("0"))
			strErrMsg = "1";
		
		strErrMsg = astrTime12[Integer.parseInt(strTimeTo24.substring(0,strTimeTo24.indexOf("."))) - 4] + astrMinDisplay[Integer.parseInt(strErrMsg)];
		
		strTemp = " ("+strTemp+"-"+strErrMsg+") ";
		
		//fname , mname, lname
		strTemp = WebInterface.formatName((String)vRetResult.remove(x), (String)vRetResult.remove(x), (String)vRetResult.remove(x), 4) + strTemp;
		
		strSection = (String)vRetResult.remove(x);//section		
		
		strTemp = strTemp + strSection;
		
		vRetResult.remove(x);//time from in vector
		vRetResult.remove(x);//time to in vector
		vRetResult.remove(x);//
		vRetResult.remove(x);//
		vRetResult.remove(x);//
		x-=21;
		%>
      <td colspan="5"><%=strTemp%></td>
   </tr>
   
   <%}%>
   
<%}%>   
</table>


<%}%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="get_room_detail" value="" > 
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%dbOP.cleanUP();%>
