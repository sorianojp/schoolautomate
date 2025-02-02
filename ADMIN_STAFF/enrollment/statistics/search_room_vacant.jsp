<%if(request.getParameter("printPg") != null && request.getParameter("printPg").compareTo("1") ==0){%>
	<jsp:forward page="./search_room_vacant_print.jsp" />
<%}%>
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
function Proceed(){
	document.form_.printPg.value = "";
	document.form_.submit();
}
function PrintPg(){
	document.form_.printPg.value = "1";
	document.form_.submit();								 
}
function GoBack() {
	location = "./statistics_rooms.jsp";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
		
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS-ROOMS","search_room_vacant.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Enrollment","Reports",request.getRemoteAddr(),
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
<form name="form_" action="./search_room_vacant.jsp" method="post">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5">
	  <div align="center"><font color="#FFFFFF"><strong>:::: SEARCH ROOMS PAGE ::::</strong></font></strong></font></div>
	  </td>
    </tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td height="27" width="40"></td>
      <td colspan="3"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25" width="40">&nbsp;</td>
      <td width="90">SY-TERM</td>
	  <td width="828" colspan="2">
<%	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
      &nbsp; -
        <select name="offering_sem">
          <option value="1">1st Sem</option>
         <%	strTemp =WI.fillTextValue("offering_sem");
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
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <a href="javascript:GoBack();">Go Back</a>
	  
	  </td>
    </tr>
	<tr>
		<td height="25" width="40">&nbsp;</td>
		<td>RANGE</td>
		<td colspan="3">
		<select name="week_day">
		<% strTemp =WI.fillTextValue("week_day");
		 	if(strTemp.compareTo("MWF") ==0){%>
          <option value="MWF" selected>MWF</option>
         <%	}else{%>
          <option value="MWF" >MWF</option>
          <%}if(strTemp.compareTo("TTH") ==0){%>
          <option value="TTH" selected>TTH</option>
         <%	}else{%>
          <option value="TTH">TTH</option>
		  <%}%>
      </select>
		</td>
	</tr> 	
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
    <tr> 
      <td height="25" colspan="2"></td>
      <td colspan="2"><a href="javascript:Proceed();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <td height="25"><div align="center"><hr size="1"></div></td>
    </tr>
  </table>
<% if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && 
	 WI.fillTextValue("offering_sem").length() > 0){  	  
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
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td height="25"><div align="right"><a href="javascript:PrintPg();">
	  <img src="../../../images/print.gif" width="58" height="26" border="0"></a>
	  <font size="1">click to print vacant room</font></div></td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable5">
	<tr>
 	<td height="25" align="center" colspan="2">
	<font size="+1"><strong>Search of vacant rooms for <%=WI.fillTextValue("week_day")%></strong></font>
	</td>
 </tr> 
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" id="myADTable8">
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
	astrWeekDays = CommonUtil.parseWeekDays(WI.fillTextValue("week_day"));
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
          " and e_sub_section.offering_sy_from = " + WI.fillTextValue("sy_from") + 
		  " and offering_sem = " + WI.fillTextValue("offering_sem")+strWeekDayCon;	
		  
	String strAddCon= " and e_room_assign.room_index is not null) order by room_number";				  
  for(int i=0; i<vTimeSch.size();i+=3){ 	  	
	strRoomNumber="";
	fHrFr24 = Float.parseFloat((String)vTimeSch.elementAt(i+1));
	fHrTo24 = Float.parseFloat((String)vTimeSch.elementAt(i+2)); 		   
	try{ 
	   //get strHourCon
	   strHourCon = CommonUtil.createHourToHourFrom24Comparison("E_ROOM_ASSIGN",fHrFr24,"HOUR_FROM_24",fHrTo24,"HOUR_TO_24", true);
	   rs = dbOP.executeQuery(strSQLQuery+strHourCon+ strAddCon);
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
<%}//end if WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("offering_sem").length() > 0 %>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable9">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center"></div></td>
      <td width="26%" height="25">&nbsp;</td>
    </tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable10">
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
  <input type="hidden" name="room_stat" value="Available"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>