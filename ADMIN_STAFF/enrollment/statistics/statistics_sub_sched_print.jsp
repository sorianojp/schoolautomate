<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>LIST OF CLASSES</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css"  rel="stylesheet" type="text/css" />
<style type="text/css">
	TD{font-size:11px;}
</style>
</head>
<body>
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
String[] astrSemester ={"Summer", "First Semester", "Second Semester", "Third Semester"};
String[] astrAMPM = {"AM", "PM"};


if (strErrMsg != null){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="27"></td>
      <td width="97%"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
 </table>
<%}
 else 
 {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2"><div align="center"><strong>LIST OF CLASSES </strong>
	      <strong>(<%=WI.fillTextValue("week_day")%> 
	      <%=WI.fillTextValue("time_from_hr") +  ":" + WI.fillTextValue("time_from_min") +  
	  		astrAMPM[Integer.parseInt(WI.fillTextValue("time_from_AMPM"))] + " - " +  
		WI.fillTextValue("time_to_hr") +  ":" + WI.fillTextValue("time_to_min") +  
	  		astrAMPM[Integer.parseInt(WI.fillTextValue("time_to_AMPM"))] 
		%>
	  )</strong></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18"><div align="center"><strong>&nbsp;ACADEMIC YEAR :
        <% if (!WI.fillTextValue("semester").equals("0")) {%> 
        <%=WI.fillTextValue("sy_from")%> - 
        <%}%>
        <%=WI.fillTextValue("sy_to")%> , <%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%> 
        
      </strong></div></td>
    </tr>
  </table>


<% if (vRetResult != null && vRetResult.size() > 0){

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

    
  for(int i = 0; i < vRetResult.size();) {
	  	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">

    <tr> 
      <td width="16%" height="27" align="center" class="thinborder"><strong>SUBJECT </strong></td>
      <td width="17%" align="center" class="thinborder"><strong>SECTION</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>ROOM NUMBER</strong> </td>
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
		
	if (i ==0 || !strPrevCollege.equals(strCurrentCollege)) {
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
<script language="javascript">
	window.print();
</script>
<%}
}
%>

</body>
</html>
<%
dbOP.cleanUP();
%>