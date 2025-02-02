<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SUBJECT SECTION MAINTENANCE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,enrollment.SubjectSectionCPU,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTempIndex = null;
	String[] astrDay = {"S","M","T","W","TH","F","SAT"};
	String[] astrAMPM = {"AM", "PM"};

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

String[]  astrConvSemester ={"Summer", "First Semester", "Second Semester"};

if((vRetResult == null || vRetResult.size() ==0) && strErrMsg == null)
	strErrMsg = subSecCPU.getErrMsg();
if(strErrMsg == null) strErrMsg = "";

float fTemp24HF = 0f;
float fTemp24HT = 0f;

int[] iTimeDataFr = null;
int[] iTimeDataTo = null;
int iPageNumber = 1;

String strTempDay = "";
String strTempRoom = "";
String strTempCol = null;
String strTempDept = null;
String strTempSub = null;
String strFacultyName = null;
boolean bIsDupe = false;
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
	iRowCtr = 0;

    strTempCol = (String)vRetResult.elementAt(0);
	strTempDept = (String)vRetResult.elementAt(2);
	strTempSub = (String)vRetResult.elementAt(4);

	for (int i = 0; i < vRetResult.size() ;){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
	
	for(; i< vRetResult.size() ; i+=22) {
	
	strTempIndex = (String)vRetResult.elementAt(i+6);

	if (i>0 && strTempIndex.equals((String)vRetResult.elementAt(i-16)))
		bIsDupe = true;
	else
		bIsDupe = false;

	if (iRowCtr == 0){%>
    <tr>
      <td height="18" colspan="6" valign="bottom"><font style="font-size:11px">C P U - General Schedule of Classes for 
        <%=astrConvSemester[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"1"))]  + " " + 
	  		WI.getStrValue(request.getParameter("sy_from"),"&nbsp;") +" - "+ 
			WI.getStrValue(request.getParameter("sy_to"),"&nbsp;")%></font></td>
	  <td height="18" colspan="3" valign="bottom"><font style="font-size:11px">Page <%=iPageNumber++%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
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
	  <td width="12%" height="20" valign="top"><font size="1">Course No. /<br>
	    Description
</font></td>
		<td width="21%" valign="top"><font size="1">Reserved for<br>
		  Department(s)
</font></td>
	  <td width="12%" valign="top"><font size="1">Time</font></td>
		<td width="7%" valign="top"><font size="1">Day</font></td>
		<td width="9%" valign="top"><font size="1">Room</font></td>
		<td width="21%" valign="top"><font size="1">Teacher</font></td>
		<td width="6%" valign="top"><font size="1">Acad. Unit</font></td>
		<td width="7%" align="center" valign="top"><font size="1">Stub No.</font></td>
		<td width="5%" align="center" valign="top"><font size="1">Class Size</font></td>
	</tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="9"><hr size="1"></td></tr>
	<%iRowCtr +=2;} 
	
	if (i==0 || 
	!(
	((strTempCol == null && vRetResult.elementAt(i)==null) ||
	(strTempCol != null && vRetResult.elementAt(i)!=null && strTempCol.equals((String)vRetResult.elementAt(i)))) &&
	((strTempDept == null && vRetResult.elementAt(i+2)==null) ||
	(strTempDept != null && vRetResult.elementAt(i+2)!=null && strTempDept.equals((String)vRetResult.elementAt(i+2))))
	))
	{
	if ((iRowCtr+5)>iRowPPG)
	{iRowCtr = 0; 
		i-=22;%>
</table>

	<%continue;}%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="9" height="25"><u><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"",
		WI.getStrValue((String)vRetResult.elementAt(i+3)," - ","",""),WI.getStrValue((String)vRetResult.elementAt(i+3),"","","&nbsp;"))%></u></td>
	</tr>
	<%
	    strTempCol = (String)vRetResult.elementAt(i);
		strTempDept = (String)vRetResult.elementAt(i+2);
		bResetSub = true;
		iRowCtr+=2;
		}
	
	if ( i== 0 || !(strTempSub.equals((String)vRetResult.elementAt(i+4))) || bResetSub){
	if ((iRowCtr+3)>iRowPPG)
	{iRowCtr = 0; 
		i-=22;%>
</table>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%continue;}%>
	<tr>
		<td colspan="9" height="10">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="9" height="25"><strong><%=(String)vRetResult.elementAt(i+4)%> - <%=(String)vRetResult.elementAt(i+5)%></strong></td>
	</tr>
	<%
	strTempSub = (String)vRetResult.elementAt(i+4);
	bResetSub = false;
	iRowCtr+=2;
	}%>
    <tr>
      <td width="12%" height="20"><font style="font-size:11px">
      <%if (bIsDupe){%>&nbsp;<%} else {%><%=(String)vRetResult.elementAt(i+4)%>
      <%}%></font></td>
      <td width="21%"><font style="font-size:11px">
      <%if (bIsDupe){%>&nbsp;<%} else {%>
	  
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%><%}%></font></td>
      <%
		strTempDay = "";
		strTempRoom = WI.getStrValue((String)vRetResult.elementAt(i+15),"TBA");

	if (vRetResult.elementAt(i+8)!=null && vRetResult.elementAt(i+9) != null)
    {  	
    	strTempDay = astrDay[Integer.parseInt((String)vRetResult.elementAt(i+10))];
    	fTemp24HF = Float.parseFloat((String)vRetResult.elementAt(i+8));
	    fTemp24HT = Float.parseFloat((String)vRetResult.elementAt(i+9));
	    
	    iTimeDataFr = comUtil.convert24HRTo12Hr(fTemp24HF);
		if (iTimeDataFr != null && (iTimeDataFr[2]  == 1) && iTimeDataFr[0] < 12)
			iTimeDataFr[0] +=12;
			
	    iTimeDataTo = comUtil.convert24HRTo12Hr(fTemp24HT);
		if (iTimeDataTo != null && (iTimeDataTo[2]  == 1) && iTimeDataTo[0] < 12)
			iTimeDataTo[0] +=12;	
	   
    while ((i+22)< vRetResult.size() && 
      strTempIndex.equals((String)vRetResult.elementAt(i+28)) &&
      vRetResult.elementAt(i+8).equals(vRetResult.elementAt(i+30)) &&
      vRetResult.elementAt(i+9).equals(vRetResult.elementAt(i+31)) &&
      ((vRetResult.elementAt(i+14) == null && vRetResult.elementAt(i+36)==null)  
      || (vRetResult.elementAt(i+14) != null && vRetResult.elementAt(i+36)!=null 
      && vRetResult.elementAt(i+14).equals(vRetResult.elementAt(i+36))) ))
      {
      	  strTempDay += astrDay[Integer.parseInt((String)vRetResult.elementAt(i+32))];
      	  i+=22;
      }}
	  
	if (vRetResult.elementAt(i+8)!=null && vRetResult.elementAt(i+9) != null && iTimeDataFr != null)
	
		strTemp = comUtil.formatMinute(Integer.toString(iTimeDataFr[0])) + 
				comUtil.formatMinute(Integer.toString(iTimeDataFr[1])) + " - " + 
				comUtil.formatMinute(Integer.toString(iTimeDataTo[0])) +
				comUtil.formatMinute(Integer.toString(iTimeDataTo[1]));
		else
		
		strTemp = "TBA";	
 %>
      <td width="12%"><font style="font-size:11px"><%=strTemp%></font></td>
      <td width="7%"><font style="font-size:11px"><%=WI.getStrValue(strTempDay,"TBA")%></font></td>
	  <td width="9%"><font style="font-size:11px"><%=strTempRoom%></font></td>
	  <%if (bIsDupe){
	  	  	strFacultyName = "&nbsp;";
		} else {
			if (vRetResult.elementAt(i+17)!=null){
				strFacultyName = ((String)vRetResult.elementAt(i+18)).charAt(0) + ". "+(String)vRetResult.elementAt(i+20);
			}else{
				strFacultyName  = "c/o";
			}
		}
  	 %>
      <td width="21%"><font style="font-size:11px"> <%=strFacultyName%></font></td>
      <td width="6%"><font style="font-size:11px">
      <%if (bIsDupe){%>&nbsp;<%} else {%>
      <%if(((String)vRetResult.elementAt(i+16)).equals("0")){%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"--")%>
      <%} else {%><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"--")%><%}%><%}%></font></td>
      <td width="7%"><font style="font-size:11px"><strong>
      <%if (bIsDupe){%>&nbsp;<%} else {%>
      <%=(String)vRetResult.elementAt(i+6)%><%}%></strong></font></td>
      <td width="5%"><font style="font-size:11px"><strong>
      <%if (bIsDupe){%>&nbsp;
      <%} else {%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+11),"--")%><%}%>
      </strong></font></td>
    </tr>
    <%++iRowCtr;
    if ((iRowCtr)>iRowPPG)
	{iRowCtr = 0; %>
	</table>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%}
}//end of view all loops %>
  </table>
 <script language="JavaScript">
		window.print();
	</script>

<%} // end outer for loop
}//end of view all display%>

</body>
</html>
<%
dbOP.cleanUP();
%>