<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SUBJECT SECTION MAINTENANCE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">
	td{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
		

</style>

</head>

<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,enrollment.SubjectSectionCPU,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTempIndex = null;
	String[] astrDay = {"S","M","T","W","TH","F","SAT","",""};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-edit subject section","edit_section.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"gen_sched.jsp");
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

SubjectSectionCPU subSecCPU = new SubjectSectionCPU();
Vector vRetResult = subSecCPU.getOfferingPerCollege(dbOP,request,null, null);

dbOP.cleanUP();

String[]  astrConvSemester ={"Summer", "First Semester", "Second Semester"};

if((vRetResult == null || vRetResult.size() ==0) && strErrMsg == null)
	strErrMsg = subSecCPU.getErrMsg();
if(strErrMsg == null) strErrMsg = "";

int iPageNumber = 1;


boolean bolDuplicate = false;
boolean bResetSub = true;
int iRowPPG = 0;
int iRowCtr = 0;
if (WI.fillTextValue("row_ppg").length()>0)
	iRowPPG = Integer.parseInt(WI.fillTextValue("row_ppg"));
else
	{
	strErrMsg = "Row limit not found";
	return;
	}

%>
		<%
if(vRetResult != null && vRetResult.size() > 0)
{
	String strDay = "";
	String strRoom = "";
	String strCurrentCollege = null;
	String strPrevCollege = "";
	String strPrevSubj = "";
	String strCurrSubj = "";
	String strFacultyName = null;
	String strPrevSubSecIndex = "";
	String strCurrSubSecIndex = null;
	String strRoomNumber = null;
	String strUnit = null;
	String strSection = null;
	String strHourFrom = null;
	String strHourTo = null;
	String strFaculty = null;
	String strClassSize = null;
	String strLab = "";
	
	float fTemp24HF = 0f;
	float fTemp24HT  = 0f;
	int[] iTimeDataFr = null;
	int[] iTimeDataTo = null;
	boolean bolIncremented = false;
	int iRollBack  = 0;
	
//	boolean bolForceBreak = false;

	for (int i = 0; i < vRetResult.size();){

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
<% 
	for (; i< vRetResult.size();) {
	
	bolIncremented = false;
	
    strCurrentCollege = (String)vRetResult.elementAt(i+1); // initial value;
	if (strCurrentCollege == null)
		strCurrentCollege = (String)vRetResult.elementAt(i+3);
	else
		strCurrentCollege += WI.getStrValue((String)vRetResult.elementAt(i+3)," - ","","");

	if (iRowCtr == 0) {%> 
	<tr>
      <td height="18" colspan="6" valign="bottom"><font style="font-size:11px">C P U - General Schedule of Classes for 
        <%=astrConvSemester[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"1"))]  + " " + 
	  		WI.getStrValue(request.getParameter("sy_from"),"&nbsp;") +" - "+ 
			WI.getStrValue(request.getParameter("sy_to"),"&nbsp;")%></font></td>
	  <td height="18" colspan="3" valign="bottom"><font style="font-size:11px">Page <%=iPageNumber++%></font></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
		<td width="11%" height="20" valign="top"><font size="1">Course No. /<br>
	  Description</font></td>
		<td width="20%" valign="top"><font size="1">Reserved for<br>
	  Department(s)</font></td>
		<td width="10%" valign="top"><font size="1">Time</font></td>
		<td width="8%" valign="top"><font size="1">Day</font></td>
		<td width="9%" valign="top"><font size="1">Room</font></td>
		<td width="25%" valign="top"><font size="1">Teacher</font></td>
		<td width="5%" valign="top"><font size="1">Acad. Unit</font></td>
		<td width="7%" align="center" valign="top"><font size="1">Stub No.</font></td>
		<td width="5%" align="center" valign="top"><font size="1">Class Size</font></td>
	</tr>
	<tr><td colspan="9"><hr size="1"></td></tr>
<% 
	iRowCtr += 3;  } // show only if start of page

	if (i == 0 || !strCurrentCollege.equals(strPrevCollege)) {

		
	if (iRowCtr + 5 > iRowPPG) {
		iRowCtr = 0;
		break;
	}
	iRowCtr += 2;
	strPrevCollege = strCurrentCollege;
	
	if (iRowCtr != 5){
%> 
	<tr>
		<td colspan="9">&nbsp;</td>
	</tr>
   <%} // put only if not %> 
	<tr>
		<td colspan="9" height="18"><u><%=strPrevCollege%></u></td>
	</tr>
<%} // show college or depart offering

	if (i==0 || !strPrevSubj.equals((String)vRetResult.elementAt(i+4))){

	
	if(iRowCtr+3 > iRowPPG){
		iRowCtr = 0;
		break;
	}
		iRowCtr++;
%> 
	<tr>
		<td colspan="9" height="10">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="9" height="18"><strong><%=(String)vRetResult.elementAt(i+4)+ " - " +
											(String)vRetResult.elementAt(i+5)%></strong></td>
	</tr>
<%
	strPrevSubj = (String)vRetResult.elementAt(i+4); // print before checking
	} // i==0 || !strPrevSubj.equals((String)vRetResult.elementAt(i+4)

	bolDuplicate = false;

	
	strCurrSubSecIndex = (String)vRetResult.elementAt(i+6);
	strHourFrom= WI.getStrValue((String)vRetResult.elementAt(i+8));
	strHourTo = WI.getStrValue((String)vRetResult.elementAt(i+9)); 
	strRoomNumber = WI.getStrValue((String)vRetResult.elementAt(i+15),"TBA");
	strSection = WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;"); 
	strClassSize = WI.getStrValue((String)vRetResult.elementAt(i+11),"--");

	if (((String)vRetResult.elementAt(i+16)).equals("1"))
		strLab = " Lab";
	else
		strLab ="";


	if ((String)vRetResult.elementAt(i+17) != null) 
		strFaculty = ((String)vRetResult.elementAt(i+18)).charAt(0) + ". " +
						(String)vRetResult.elementAt(i+20);
	else
		strFaculty = "c/o";
		
	if(((String)vRetResult.elementAt(i+16)).equals("0")){
		strUnit = WI.getStrValue((String)vRetResult.elementAt(i+12),"--");
	}else{
		strUnit = WI.getStrValue((String)vRetResult.elementAt(i+13),"--");
	}		
	
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
	
	if (vRetResult.elementAt(i+8)!=null && vRetResult.elementAt(i+9) != null)
    {  	
    	fTemp24HF = Float.parseFloat((String)vRetResult.elementAt(i+8));
	    fTemp24HT = Float.parseFloat((String)vRetResult.elementAt(i+9));
	    
	    iTimeDataFr = comUtil.convert24HRTo12Hr(fTemp24HF);
		if (iTimeDataFr != null && (iTimeDataFr[2]  == 1) && iTimeDataFr[0] < 12)
			iTimeDataFr[0] +=12;
			
	    iTimeDataTo = comUtil.convert24HRTo12Hr(fTemp24HT);
		if (iTimeDataTo != null && (iTimeDataTo[2]  == 1) && iTimeDataTo[0] < 12)
			iTimeDataTo[0] +=12;
	} 	


	while ( i < vRetResult.size() && 
			strCurrSubSecIndex.equals((String)vRetResult.elementAt(i+6)) &&
			strHourFrom.equals(WI.getStrValue((String)vRetResult.elementAt(i+8))) && 
			strHourTo.equals(WI.getStrValue((String)vRetResult.elementAt(i+9))) &&
			strRoomNumber.equals(WI.getStrValue((String)vRetResult.elementAt(i+15),"TBA"))) {

		strDay += astrDay[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+10),"8"))];
		bolIncremented = true;
		i+=22;
	}
		strPrevSubSecIndex = strCurrSubSecIndex;
	// check before printing if it can still be accomodated to the number of rows per page
	iRowCtr++;
	
	strPrevSubj += strLab;
	
	if (strPrevSubj.length() > 13) 
		strPrevSubj = strPrevSubj.substring(0,13);
%> 
    <tr>
<% if(bolDuplicate) 
		strTemp = "";
	else 
		strTemp = strPrevSubj;
%>
      <td width="12%" height="18"><%=strTemp%></td>
<% if(bolDuplicate) 
		strTemp = "";
	else 
		strTemp = strSection;
%>
      <td width="20%"><%=strTemp%></td>
<%	if (fTemp24HF != 0f && fTemp24HT != 0f && iTimeDataFr != null && iTimeDataTo != null){
      strTemp = comUtil.formatMinute(Integer.toString(iTimeDataFr[0])) + 
				comUtil.formatMinute(Integer.toString(iTimeDataFr[1])) + "-" +
				comUtil.formatMinute(Integer.toString(iTimeDataTo[0])) + 
				comUtil.formatMinute(Integer.toString(iTimeDataTo[1]));
    }else{
		strTemp = "TBA";
		strDay = "TBA";
	} 
%>   
      <td width="10%"><%=strTemp%></td>
      <td width="8%"><%=strDay%></td>
	  <td width="9%"><%=strRoomNumber%></td>  
      <td width="24%"><%=strFaculty%></td>
<%
	if (strLab.length() > 0) 
		strUnit ="--";
%>	  
      <td width="5%"><%=strUnit%></td>
<%
	if (strLab.length() > 0) 
		strCurrSubSecIndex ="--";
%>
      <td width="7%"><strong><%=strCurrSubSecIndex%></strong></td>
      <td width="5%"><div align="center"><strong><%=strClassSize%></strong></div></td>
    </tr>
<%  
	if (!bolIncremented){
		System.out.println("Infinite Loop ::  Gen Sched Print : " + 
				WI.fillTextValue("sy_from") + " - " +  WI.fillTextValue("sy_to") +
				" : " + WI.fillTextValue("semester"));
		break; 
   	  }
	} // end inner for loop %>
  </table>
<%
	if (i<vRetResult.size()) {
%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%
   } //i<vRetResult.size() Print Break
} // end page %>

 <script language="JavaScript">
		window.print();
 </script>
<%

 }// end if vRetResult.size() > 0

%>

</body>
</html>
