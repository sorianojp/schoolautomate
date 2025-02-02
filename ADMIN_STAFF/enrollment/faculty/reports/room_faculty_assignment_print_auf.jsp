<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
	body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
	}
	
	td {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
	}
	
	th {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
	}
	
	TABLE.thinborder {
		border-top: solid 1px #000;
		border-right: solid 1px #000;
		font-family:Verdana, Arial, Helvetica, sans-serif;	
		font-size: 11px;
	}
	
	TD.thinborder{
		border-left: solid 1px #000;
		border-bottom: solid 1px #000;
		font-family:Verdana, Arial, Helvetica, sans-serif;	
		font-size: 11px;
	}
	
	TD.thinborderBOTTOM{
		border-bottom: solid 1px #000;
		font-family:Verdana, Arial, Helvetica, sans-serif;	
		font-size: 11px;
	}
</style>
<body>
<%@ page language="java" import="utility.*,enrollment.FacultyManagementExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	//add security here.
	try{
		dbOP = new DBOperation();
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = 2;

	//end of authenticaion code.
FacultyManagementExtn facultyMgmt = new FacultyManagementExtn();
	Vector vRetResult = null;
	
	vRetResult = facultyMgmt.getRoomAssignmentForFacultyAttendance(dbOP, request);
	if(vRetResult == null)
		strErrMsg = facultyMgmt.getErrMsg();
	
		
	String[] astrTime12     = {"4","5","6","7","8","9","10","11","12","1","2","3","4","5","6","7",
									"8","9","10","11"};				
	
	String[] astrDay = {"SUN","MON","TUE","WED","THU","FRI","SAT"};
	String[] astrMinDisplay = {":00", ":30"};
	String[] astrAMPM = {"AM", "PM", "NN"};
	String[] astrSem ={"Summer","1st Sem.","2nd Sem.","3rd Sem."};
	
	String strClerk = "Andre M. Perez";
	String strAssistant = " ";
	String strDirector = "Anne Rose L. Reyes";
	String strHead = "Jocelyn Z. Manalang";
	
	if(vRetResult != null && vRetResult.size() > 0 && strErrMsg == null){
		Vector vTime = (Vector)vRetResult.remove(0);
		
	String strTimeFrom = null;
	String strTimeTo = null;
	
	int iIndexOf = 0;
	Vector vRoomList = new Vector();
	Vector vTemp = new Vector();
	
	for(int i = 0; i < vTime.size(); i += 2){
		
		strTimeFrom = (String)vTime.elementAt(i);
		strTimeTo = (String)vTime.elementAt(i+1);
		
		for(int x = 0; x < vRetResult.size(); x += 21){	
				
			if( !((String)vRetResult.elementAt(x + 16)).equals(strTimeFrom) && 
			    !((String)vRetResult.elementAt(x + 17)).equals(strTimeTo)  )
					continue;		 
				
			 vTemp.addElement((String)vRetResult.elementAt(x + 2));  //[0]room_number
			 vTemp.addElement((String)vRetResult.elementAt(x + 12)); //[1]fname
			 vTemp.addElement((String)vRetResult.elementAt(x + 13)); //[2]mname
			 vTemp.addElement((String)vRetResult.elementAt(x + 14)); //[3]lname
			 vTemp.addElement((String)vRetResult.elementAt(x + 10)); //[4]hours_from_24
			 vTemp.addElement((String)vRetResult.elementAt(x + 11)); //[5]hours_to_24	
		}
	}
		
	if(vTemp != null && vTemp.size() > 0){
		for(int i =0; i < vTemp.size(); i+=6){
			iIndexOf = vRoomList.indexOf((String)vTemp.elementAt(i));
			 if(iIndexOf == -1){
				vRoomList.addElement((String)vTemp.elementAt(i));
						
			 }		 		 
		}
	}
			
	int x = 0;
%>
   
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   
   <tr><td colspan="13" align="center"><font size="1"><strong>
   <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
   <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
   <br>HUMAN RESOURCES DEVELOPMENT CENTER<br><br><u>CLASSROOM MONITORING FORM</u> 
   <br><u><%=astrSem[Integer.parseInt(WI.fillTextValue("semester"))]%> A.Y. 
   <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></u>
   <br>DATE: <u><%=WI.getTodaysDate(10)%></u></strong></font><br>
   </td></tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
  <tr><td colspan="3" height="25">&nbsp;</td></tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  
  <tr>
   <td width="10%" height="18" class="thinborder">
   &nbsp;<%=astrDay[Integer.parseInt(WI.fillTextValue("date"))]%> ROOM #</td>
<%	for(int i = 0; i < vTime.size(); i += 2){
		strTimeFrom = (String)vTime.elementAt(i);
		strTimeTo = (String)vTime.elementAt(i+1);

		strTemp = strTimeFrom.substring(strTimeFrom.indexOf(".") + 1);
		if(!strTemp.equals("0"))
			strTemp = "1";
			
		strTemp = astrTime12[Integer.parseInt(strTimeFrom.substring(0,strTimeFrom.indexOf("."))) - 4] +
		          astrMinDisplay[Integer.parseInt(strTemp)];	
	
		strErrMsg = strTimeTo.substring(strTimeTo.indexOf(".") + 1);
		if(!strErrMsg.equals("0"))
			strErrMsg = "1";
		
		strErrMsg = astrTime12[Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) - 4] + 
		            astrMinDisplay[Integer.parseInt(strErrMsg)];
		
		if(Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) < 12)
			strErrMsg += " " + astrAMPM[0];
		else if(Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) == 12)
			strErrMsg += " " + astrAMPM[2];
		else if(Integer.parseInt(strTimeTo.substring(0,strTimeTo.indexOf("."))) > 12)
			strErrMsg += " " + astrAMPM[1];
%>
      <td width="15%" class="thinborder">PERIOD: <%=strTemp + " - " + strErrMsg%></td>
      <td width="15%" class="thinborder">REMARKS</strong></td>
      <%}%> 
   </tr> 
<%    String strRoomNo = null;
  	  String strPrevNo = "";
	  while(vRoomList.size() > 0){ 	    
		strRoomNo =   (String)vRoomList.remove(0);					
		
		while(vTemp.indexOf(strRoomNo) > -1){
		
			if(!strPrevNo.equals(strRoomNo)){
				strPrevNo = strRoomNo;
				strErrMsg = strRoomNo;
			}else
				strErrMsg = "&nbsp;";
%>
   <tr>   
	   <td class="thinborder"><%=strErrMsg%></td>	   	   
<%     double dTimeFrom = 0d;
	   double dTimeTo   = 0d;
	   double dTempTimeFrom = 0d;
	   double dTempTimeTo = 0d;
	   
	   for(int i = 0; i < vTime.size(); i += 2){
	   
	   		strTimeFrom = (String)vTime.elementAt(i);
		    strTimeTo = (String)vTime.elementAt(i+1);
		    strTemp ="&nbsp;";
			
			dTimeFrom = Double.parseDouble(strTimeFrom);
			dTimeTo = Double.parseDouble(strTimeTo);
			
			for(x = 0; x < vTemp.size(); x+=6){			
				
				dTempTimeFrom = Double.parseDouble((String)vTemp.elementAt(x + 4));
				dTempTimeTo = Double.parseDouble((String)vTemp.elementAt(x + 5));
			
				if(   ( dTempTimeFrom < dTimeFrom  && dTempTimeTo > dTimeTo) || 
					  ( dTempTimeFrom < dTimeFrom &&  dTempTimeTo <= dTimeTo && dTempTimeTo > dTimeFrom )	||
					  ( dTempTimeFrom >= dTimeFrom && dTempTimeTo <= dTimeTo ) ||
					  ( dTempTimeFrom >= dTimeFrom && dTempTimeTo >= dTimeTo && dTempTimeFrom < dTimeTo )
				 ){
				
					if(((String)vTemp.elementAt(x )).equals(strRoomNo)){				
						vTemp.remove(x);
						strTemp = WebInterface.formatName((String)vTemp.remove(x), (String)vTemp.remove(x), 
							  (String)vTemp.remove(x), 4)  ;
						vTemp.remove(x);	
						vTemp.remove(x);
						break;
					}
				}
				
			}
%>
	   <td class="thinborder"><%=strTemp%></td>
	   <td class="thinborder">&nbsp;</td>  
	   <%}//end of vTime loop%>
   </tr>  
   <%   }//end of vTemp.indexOf(strRoomNo) > -1
   }//vRoomList.size() > 0%>
</table>
<script>window.print();</script>
<%}else{%>
	<div align="center"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></div>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="25%" height="25">Monitored by:</td>
		<td width="24%">Verified by:</td>
		<td width="22%">Noted by:</td>
		<td colspan="2">Legend:</td>
	</tr>
	<tr>
		<td><br><u><%=WI.getStrValue(strClerk, "&nbsp;")%></u><br>HR Clerk/Monitor</td>
		<td><br><u><%=WI.getStrValue(strAssistant, "&nbsp;")%></u><br>HR Assistant</td>
		<td><br><u><%=WI.getStrValue(strDirector, "&nbsp;")%></u><br>HRDC Director</td>
		<td width="8%">/<br>
	  x<br>RV </strong></td>
		<td width="21%">Present<br>
	  Faculty was not around<br>Room Vacant</td>
  </tr>
	 <tr> 
		 <td>&nbsp;</td>
		 <td><br><u><%=WI.getStrValue(strHead, "&nbsp;")%></u><br>Head, PERS</td>
		 <td>&nbsp;</td>
		 <td>OL/OB<br>OW<br>&nbsp;</td>
		 <td>On Leave/Official Business<br>Office Work<br>&nbsp;</td>
	 </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="45" colspan="2">&nbsp;</td></tr>
	<tr>
		<td>AUF-FORM-HRDC-PERS-02<br>November 3, 2009 REV-01</td></tr>
</table>
</body>
</html>
<%dbOP.cleanUP();%>
