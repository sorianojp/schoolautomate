<%
if(request.getParameter("printPg") != null && request.getParameter("printPg").equals("1")){%>
		<jsp:forward page="./statistics_sub_sched_print.jsp" />
<%}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css"  rel="stylesheet" type="text/css" />
<style type="text/css">
	TD{font-size:11px;}
</style>
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
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
		
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
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

Vector vRetResult =null;
StatEnrollment SE = new StatEnrollment();
//enrollment.StatEnrollmentExtn SE = new enrollment.StatEnrollmentExtn();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && 
	WI.fillTextValue("semester").length() > 0)
{
	vRetResult = SE.getSectionsSpecificHrDay(dbOP,request);
	if(vRetResult == null)
		strErrMsg = SE.getErrMsg();	
}



%>
<form name="stat_room" action="./statistics_sub_sched.jsp" method="post">

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>::::
          STATISTICS - SUBJECT SCHEDULE PAGE ::::</strong></font></strong></font></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="5%" height="27"></td>
      <td colspan="2"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2">SCHOOL YEAR 
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
        &nbsp;&nbsp;&nbsp;&nbsp;
		TERM 
        <select name="semester">
          <option value="1">1st Sem</option>
<%
strTemp =WI.fillTextValue("semester");

if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		  if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  
		  if (strSchCode.startsWith("CPU")) {
		  
		  if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.equals("4")){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}
		  } // remove 3 and 4 sem for CPU
		  
		  if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
        <td height="25"></td>
        <td>COLLEGE</td>
        <td>
		<select name="c_index" style="width:400px;">
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del = 0 order by c_name", WI.fillTextValue("c_index"), false)%>
		</select>
		</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="17%">SCHEDULE DAY </td>
      <td><input type="text" name="week_day" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("week_day")%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();">
        (M-T-W-TH-F-SAT-S)</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td>SCHEDULE TIME </td>
      <td><input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox"
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
<%}%>        </select>	  </td>
    </tr>
    <tr>
      <td height="18"></td>
      <td></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td width="78%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18">
          <hr size="1" width="100%">
      </td>
    </tr>
  </table>


<% if (vRetResult != null && vRetResult.size() > 0){
	
%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print statistics</font></div></td>
    </tr>
  </table>
<% 
  String strCurrentCollege = null;
  String strPrevCollege = "";
  String strSubCode = null;
  String strCurrSubSecIndex = null;
  String strHourFrom= null;
  String strHourTo = null;
  String strRoomNumber = null;
  String strSection = null;
  String strClassSize = null;
  String strLab = null;
  String strFaculty = null;
  String strPrevSubSecIndex = "";
  String strDay = "";
  String strPrevSubj  = null;
  String strCurrDay = "";
  String strFacultyName = "";
  String strCurrFacultyName = "";
  
  Vector vFacultyList = new Vector();
  
  String[] astrDay = {"S","M","T","W","TH","F","SAT","",""};
  
  float	fTemp24HF = 0f;
  float	fTemp24HT = 0f;	

	boolean bolIncremented = false;
	boolean bolDuplicate = false;

  int iRollBack  = 0;
  int[] iTimeDataFr = null;
  int[] iTimeDataTo = null;
  String[] astrAMPM = {"AM", "PM"};
    
  for(int i = 0; i < vRetResult.size();) {
	  	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">

    <tr> 
<!--
      <td width="9%" height="27" align="center" class="thinborder"><strong>STUB CODE </strong></td>
-->
      <td width="16%" align="center" class="thinborder"><strong>SUBJECT </strong></td>
      <td width="17%" align="center" class="thinborder"><strong>SECTION</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>ROOM NUMBER</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>TIME </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>DAY</strong></td>
      <td width="23%" align="center" class="thinborder"><strong>FACULTY</strong> </td>
      <td width="6%" align="center" class="thinborder"><strong>NO OF STUDS</strong></td>
    </tr>
<% 	for(;i < vRetResult.size();) {
		bolIncremented = false; 

	strCurrentCollege = (String)vRetResult.elementAt(i);
	if (strCurrentCollege == null) 
		strCurrentCollege = (String)vRetResult.elementAt(i+1);
	else
		strCurrentCollege += WI.getStrValue((String)vRetResult.elementAt(i+1)," - " , "", "");
		
	if (i ==0 || !WI.getStrValue(strPrevCollege).equals(strCurrentCollege)) {
		strPrevCollege =  strCurrentCollege;
%>
    <tr bgcolor="#DBD8C8">
      <td height="20" colspan="7" class="thinborder">&nbsp; <strong><%=strPrevCollege%></strong></td>
    </tr>
<%} // end show college 

	strPrevSubj = (String)vRetResult.elementAt(i+2);
	strCurrSubSecIndex = (String)vRetResult.elementAt(i+3);
	strHourFrom= WI.getStrValue((String)vRetResult.elementAt(i+5));
	strHourTo = WI.getStrValue((String)vRetResult.elementAt(i+6)); 
	strRoomNumber = WI.getStrValue((String)vRetResult.elementAt(i+8),"TBA");
	strSection = WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;"); 
	strClassSize = WI.getStrValue((String)vRetResult.elementAt(i+13),"--");
	

	if ((String)vRetResult.elementAt(i+9) != null && ((String)vRetResult.elementAt(i+9)).equals("1"))
		strLab = " Lab";
	else
		strLab ="";


	if ((String)vRetResult.elementAt(i+10) != null) 
		strFaculty = ((String)vRetResult.elementAt(i+10)).charAt(0) + ". " +
						(String)vRetResult.elementAt(i+11);
	else
		strFaculty = "c/o";
	
	if (strSection.length() > 20) 
		strSection = strSection.substring(0,20);
	
	if (strSection.equals("*"))
		strSection = "&nbsp;";
	
	if (strPrevSubSecIndex.equals(strCurrSubSecIndex))
		bolDuplicate = true;
		
	iRollBack = i; 	 // value of for RollBack;
	strDay="";
	
	fTemp24HF = 0f;
	fTemp24HT = 0f;	
	
	if (vRetResult.elementAt(i+5)!=null && vRetResult.elementAt(i+6) != null)
    {  	
	   	fTemp24HF = Float.parseFloat((String)vRetResult.elementAt(i+5));
	    fTemp24HT = Float.parseFloat((String)vRetResult.elementAt(i+6));
	    
	    iTimeDataFr = comUtil.convert24HRTo12Hr(fTemp24HF);
		if (iTimeDataFr != null && (iTimeDataFr[2]  == 1) 
			 && iTimeDataFr[0] < 12 && strSchCode.startsWith("CPU"))
			iTimeDataFr[0] +=12;
			
	    iTimeDataTo = comUtil.convert24HRTo12Hr(fTemp24HT);
		if (iTimeDataTo != null && (iTimeDataTo[2]  == 1) 
				&& iTimeDataTo[0] < 12 && strSchCode.startsWith("CPU"))
			iTimeDataTo[0] +=12;
	} 	
	strCurrDay = "";
	strFacultyName = "";
	vFacultyList.clear();

	while ( i < vRetResult.size() && 
			strCurrSubSecIndex.equals((String)vRetResult.elementAt(i+3)) &&
			strHourFrom.equals(WI.getStrValue((String)vRetResult.elementAt(i+5))) && 
			strHourTo.equals(WI.getStrValue((String)vRetResult.elementAt(i+6))) 
//			&& strRoomNumber.equals(WI.getStrValue((String)vRetResult.elementAt(i+8),"TBA"))
			) {

		if (!strCurrDay.equals(WI.getStrValue((String)vRetResult.elementAt(i+7),"8"))) 
			strDay += astrDay[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+7),"8"))];

		if ((String)vRetResult.elementAt(i+10) != null &&
			 (String)vRetResult.elementAt(i+12) != null){
			if (strSchCode.startsWith("CPU")) {
				strFacultyName += ((String)vRetResult.elementAt(i+10)).charAt(0) +". " + 
										(String)vRetResult.elementAt(i+12);
			}else{
				strCurrFacultyName =WI.formatName((String)vRetResult.elementAt(i+10), 
												(String)vRetResult.elementAt(i+11),
												(String)vRetResult.elementAt(i+12),6);
				if (vFacultyList.indexOf(strCurrFacultyName) == -1){
					if(strFacultyName.length() == 0) 
						strFacultyName += strCurrFacultyName;
					else
						strFacultyName += ", " + strCurrFacultyName;
				
					vFacultyList.addElement(strCurrFacultyName);
				}
			}
		}




		strCurrDay = WI.getStrValue((String)vRetResult.elementAt(i+7),"8");
		bolIncremented = true;
		i+=14;
	}
		strPrevSubSecIndex = strCurrSubSecIndex;
	// check before printing if it can still be accomodated to the number of rows per page
	
	strPrevSubj += strLab;
	
	if (strPrevSubj.length() > 13) 
		strPrevSubj = strPrevSubj.substring(0,13);

%>
    <tr> 
<!--
      <td class="thinborder">&nbsp; <%=strPrevSubSecIndex%></td>  
-->
      <td height="20" class="thinborder">&nbsp;<%=strPrevSubj%></td>
      <td class="thinborder">&nbsp;<%=strSection%></td>
      <td class="thinborder"><%=strRoomNumber%></td>
      <% if (fTemp24HF != 0f && fTemp24HT != 0f && iTimeDataFr != null && iTimeDataTo != null){
	  		if (strSchCode.startsWith("CPU")) 
		      strTemp = comUtil.formatMinute(Integer.toString(iTimeDataFr[0])) + 
					comUtil.formatMinute(Integer.toString(iTimeDataFr[1])) + "-" +
					comUtil.formatMinute(Integer.toString(iTimeDataTo[0])) + 
					comUtil.formatMinute(Integer.toString(iTimeDataTo[1]));
			else
		      strTemp = Integer.toString(iTimeDataFr[0]) + ":" +  
					comUtil.formatMinute(Integer.toString(iTimeDataFr[1])) + 
					astrAMPM[iTimeDataFr[2]] + "-" +
  				    Integer.toString(iTimeDataTo[0]) + ":" +  
					comUtil.formatMinute(Integer.toString(iTimeDataTo[1])) +
					astrAMPM[iTimeDataTo[2]];
				
    }else{
		strTemp = "TBA";
		strDay = "TBA";
	} 
%>  	  
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder"><div align="center"><%=strDay%></div></td>
      <td class="thinborder">&nbsp;<%=strFacultyName%></td>
      <td class="thinborder">&nbsp;<%=strClassSize%></td>
    </tr>
<%

	if(!bolIncremented){
		 break;
	} 
  } // inner for loop

	if(!bolIncremented) {
		 break;
  }
 } // outer for loop
%>
  </table>
  
<%}%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
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