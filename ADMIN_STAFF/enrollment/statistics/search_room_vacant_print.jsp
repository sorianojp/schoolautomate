<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
		
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT","search_room_vacant.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Enrollment","REPORTS",request.getRemoteAddr(),
															"search_room_vacant.jsp");
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
	Vector vTimeSch = new Vector(); 	
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};	
%>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=WI.getStrValue(strErrMsg)%></div></td>
    </tr>
</table>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><strong><br>
        ROOMS AVAILABILITY FOR 
        <%=request.getParameter("week_day")%><br>
        </strong>SY (<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>) 
        <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> 
      </div></td>
    </tr>
   </table>
   <table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" colspan="2"><div align="center"> </div></td>
  </tr>
 </table>
<% 	 if(request.getParameter("sy_from").length() > 0 && request.getParameter("sy_to").length() > 0 && 
	 request.getParameter("offering_sem").length() > 0){  
		 if(WI.fillTextValue("week_day").equals("MWF")){   
		   vTimeSch.addElement("07:30 - 08:30"); vTimeSch.addElement("7.5"); vTimeSch.addElement("8.5");
		   vTimeSch.addElement("08:30 - 09:30"); vTimeSch.addElement("8.5"); vTimeSch.addElement("9.5");
		   vTimeSch.addElement("09:30 - 10:30"); vTimeSch.addElement("9.5"); vTimeSch.addElement("10.5");
		   vTimeSch.addElement("10:30 - 11:30"); vTimeSch.addElement("10.5"); vTimeSch.addElement("11.5");
		   vTimeSch.addElement("11:30 - 12:30"); vTimeSch.addElement("11.5"); vTimeSch.addElement("12.5");
		   vTimeSch.addElement("12:30 - 01:30"); vTimeSch.addElement("12.5"); vTimeSch.addElement("13.5");
		   vTimeSch.addElement("01:30 - 02:30"); vTimeSch.addElement("13.5"); vTimeSch.addElement("14.5");
		   vTimeSch.addElement("02:30 - 03:30"); vTimeSch.addElement("14.5"); vTimeSch.addElement("15.5");
		   vTimeSch.addElement("03:30 - 04:30"); vTimeSch.addElement("15.5"); vTimeSch.addElement("16.5");
		   vTimeSch.addElement("04:30 - 05:30"); vTimeSch.addElement("16.5"); vTimeSch.addElement("17.5");
		   vTimeSch.addElement("05:30 - 06:30"); vTimeSch.addElement("17.5"); vTimeSch.addElement("18.5");
		   vTimeSch.addElement("06:30 - 07:30"); vTimeSch.addElement("18.5"); vTimeSch.addElement("19.5");
		   vTimeSch.addElement("07:30 - 08:30"); vTimeSch.addElement("19.5"); vTimeSch.addElement("20.5");
		   vTimeSch.addElement("08:30 - 09:00"); vTimeSch.addElement("20.5"); vTimeSch.addElement("21");
		 }else{   
		   vTimeSch.addElement("07:30 - 09:00"); vTimeSch.addElement("7.5"); vTimeSch.addElement("9");
		   vTimeSch.addElement("09:00 - 10:30"); vTimeSch.addElement("9"); vTimeSch.addElement("10.5");
		   vTimeSch.addElement("10:30 - 12:00"); vTimeSch.addElement("10.5"); vTimeSch.addElement("12");
		   vTimeSch.addElement("12:00 - 01:30"); vTimeSch.addElement("12"); vTimeSch.addElement("13.5");
		   vTimeSch.addElement("01:30 - 03:00"); vTimeSch.addElement("13.5"); vTimeSch.addElement("15");
		   vTimeSch.addElement("03:00 - 04:30"); vTimeSch.addElement("15"); vTimeSch.addElement("16.5");
		   vTimeSch.addElement("04:30 - 06:00"); vTimeSch.addElement("16.5"); vTimeSch.addElement("18");
		   vTimeSch.addElement("06:00 - 07:30"); vTimeSch.addElement("18"); vTimeSch.addElement("19.5");
		   vTimeSch.addElement("07:30 - 09:00"); vTimeSch.addElement("19.5"); vTimeSch.addElement("21");
		  } 
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
 <tr>
 	<td width="21%" height="25" align="center" class="thinborder"><strong><%=WI.fillTextValue("week_day")%> TIME</strong></td>
	<td width="79%" align="center" class="thinborder"><strong>Vacant Rooms</strong></td>
 </tr>
 <% String[] astrWeekDays =null;
	String strWeekDayCon =null;
 	String strHourCon =null;
	String strRoomNumber = "";
	String strSQLQuery = null;
	java.sql.ResultSet rs = null;
	
	float fHrFr24 =0f;
	float fHrTo24 =0f;
	
	//get strWeekDayCon
	astrWeekDays = CommonUtil.parseWeekDays(request.getParameter("week_day"));
	for(int i=0; i<astrWeekDays.length; ++i){
		  if(strWeekDayCon == null)
			strWeekDayCon = " and ( E_ROOM_ASSIGN.week_day = "+astrWeekDays[i];
		  else
			strWeekDayCon += " or E_ROOM_ASSIGN.week_day = "+astrWeekDays[i];
	}
	strWeekDayCon += " )";	
	
	strSQLQuery = "select  distinct room_number from e_room_detail " +
          " where e_room_detail.is_valid = 1 and e_room_detail.is_del = 0 "+
		  " and NFS_ASSIGNMENT = 0 and e_room_detail.room_index not in (select room_index from e_room_assign "+
          " join e_sub_section on (e_room_assign.sub_sec_index = e_sub_section.sub_sec_index) " +
          " where e_room_assign.is_valid = 1 and e_room_assign.is_del=0 "+
          " and e_sub_section.offering_sy_from = " + request.getParameter("sy_from") + 
		  " and offering_sem = " + request.getParameter("offering_sem")+strWeekDayCon;	
				  
  String strAddCon= " and e_room_assign.room_index is not null) order by room_number";				  
  for(int i=0; i<vTimeSch.size();i+=3){ 	  	
	strRoomNumber="";
	fHrFr24 = Float.parseFloat((String)vTimeSch.elementAt(i+1));
	fHrTo24 = Float.parseFloat((String)vTimeSch.elementAt(i+2)); 		   
	try{ 
	   //get strHourCon
	   strHourCon = CommonUtil.createHourToHourFrom24Comparison("E_ROOM_ASSIGN",fHrFr24,"HOUR_FROM_24",fHrTo24,"HOUR_TO_24", true);
	   rs = dbOP.executeQuery(strSQLQuery+strHourCon+strAddCon);	
	   while(rs.next()){
			strRoomNumber +=WI.getStrValue(rs.getString(1)," ",","," ");
	   }rs.close();		   
	}catch(Exception ex){		
	} 	   
 %> 
 <tr>
 	<td height="25" class="thinborder" align="center"><strong><%=vTimeSch.elementAt(i)%></strong></td>
	<td class="thinborder"><%=WI.getStrValue(strRoomNumber,"")%></td>
 </tr>
 <%}//end of vTimeSch loop%>
</table>
<%}//end if WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("offering_sem").length() > 0%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>  
<script language="JavaScript">
	window.print();
</script>
</body>
</html>
<%dbOP.cleanUP();%>