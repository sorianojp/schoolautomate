<%@ page language="java" import="utility.*,java.util.Vector,eDTR.FacultyDTR" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script> 
<body>
<%
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","schedule_by_subject.jsp");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"schedule_by_subject.jsp");	
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","PROCTOR",request.getRemoteAddr(), 
														null);	
}														
														
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");

if (strTemp == null) 
	strTemp = "";
//																					
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	FacultyDTR WHour = new FacultyDTR(); 
 	Vector vRetResult = null;
	Vector vEmployeeWH = null;
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};
	if(bolIsSchool)
		 strTemp = "College";
	else
		 strTemp = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};	
	int iSearchResult = 0;
	int i = 0;
	String strCurSubject = null;
	String strPrevSubject = "";
	boolean bolShowSubject = true;
	boolean bolPageBreak  = false;
	double dTotalHours = 0d;

	vRetResult = WHour.getProctorScheduleBySubject(dbOP, request);
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
		bolShowSubject = true;
		
%>
<form name="form_">
<table width="100%" height="71" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="61" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
      </strong> <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
  </tr>
</table>

     <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <tr> 
      <td height="20" colspan="6" align="center" class="thinborder"><strong>EXAM SCHEDULE  </strong></td>
    </tr>
    <tr>
      <td width="5%" height="23" class="thinborder">&nbsp;</td>
      <td width="15%" class="thinborder">&nbsp;</td> 
      <td width="38%" align="center" class="thinborder"><strong><font size="1">TIME</font></strong></td>
			<td width="17%" align="center" class="thinborder"><strong><font size="1">ROOM</font></strong></td>
			<!--
      <td width="8%" align="center" class="thinborder">&nbsp;</td>
			-->
      <td width="25%" align="center" class="thinborder"><strong><font size="1">PROCTOR</font></strong></td>
    </tr>
    
    <%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=30,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;					
		 		strCurSubject = (String)vRetResult.elementAt(i);
		 		if(!strCurSubject.equals(strPrevSubject))
					bolShowSubject = true;		 	
		 %>
    <%if(bolShowSubject){
				bolShowSubject = false;
				//iCount = 1;
		%>
		<tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+1) + " " + (String)vRetResult.elementAt(i+2);
			%>
      <td height="25" colspan="5" class="thinborder">&nbsp;<%=strTemp%></td>
    </tr>
		<%
			strPrevSubject = strCurSubject;
		}%>
    <tr>
      <td height="25" class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+24)%></td> 
      <input type="hidden" name="user_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
	  <%
			strTemp = (String)vRetResult.elementAt(i + 4);		
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 7);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+8),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+9))];
			
			strTemp = (String)vRetResult.elementAt(i+3) + " " + strTemp;
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+27);
				dTotalHours += Double.parseDouble(WI.getStrValue(strTemp, "0"));			
			%>			
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+25)%></td>
      <!--
			<td align="center" class="thinborder"><strong><a href="javascript:ViewSchedule('<%=(String)vRetResult.elementAt(i+1)%>');"><img src="../../../../images/view.gif" width="40" height="31" border="0"></a></strong></td>
			-->
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+22)%></td>
    </tr>
    <%} //end for loop%>    
   </table>	
	<%if(WI.fillTextValue("emp_id").length() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td height="56" valign="bottom">TOTAL NUMBER OF HOURS : <%=CommonUtil.formatFloat(dTotalHours, false)%></td>
  </tr>
	</table>
	<%}%>	 
<%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
