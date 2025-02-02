<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>

</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	int iSubTotal   = 0; // sub total of a course - major.
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS-ENROLLEES","statistics_enrollees.jsp");
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
Vector vRetResult = new Vector();
StatEnrollment SE = new StatEnrollment();
vRetResult = SE.getEnrolleeStat(dbOP,request);
//dbOP.cleanUP();
if(vRetResult == null || vRetResult.size() ==0)
{
	strErrMsg = SE.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Error in getting enrollment list.";
}
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};

if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%return;
}%>

  <table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><strong><br>
        STATISTICS - ENROLEES STATUS<br>
        </strong>SY (<%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>) 
        <%=astrConvertToSem[Integer.parseInt((String)request.getParameter("semester"))]%> FROM <%=request.getParameter("date_from")%> TO <%=request.getParameter("date_to")%></div></td>
    </tr>
   </table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr  >
    <td height="25" colspan="2"><div align="center"> </div></td>
  </tr>
 </table>
   
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr > 
    <td width="3%" height="25">&nbsp;</td>
    <td width="50%">STUDENT STATUS :<strong> <%=request.getParameter("status_name")%></strong></td>
    <td width="47%">
	<%if(WI.fillTextValue("age").length() > 0){%>
	AGE : <strong><%=WI.getStrValue(request.getParameter("age"),"n/s")%></strong>
	<%}%></td>
  </tr>
</table>

<%if(vRetResult != null){//System.out.println(vRetResult);
	// I have to keep track of course programs, course, and major.
	String strCourseProgram = null;
	String strCourseName    = null;
	String strMajorName     = null;
	
	//displays the coruse name and major name only if major and course names are different :-)
	String strCourseNameToDisp = null;
	String strMajorNameToDisp  = null;
	
	String str1stYrM = null;
	String str1stYrF = null;
	String str2ndYrM = null;
	String str2ndYrF = null;
	String str3rdYrM = null;
	String str3rdYrF = null;
	String str4thYrM = null;
	String str4thYrF = null;
	String str5thYrM = null;
	String str5thYrF = null;
	String str6thYrM = null;
	String str6thYrF = null;
	
	int iSubGrandTotal = 0;
	
	for(int i = 1 ; i< vRetResult.size() ;){//outer loop for each course program.
	strCourseProgram = (String)vRetResult.elementAt(i);
	strCourseName = null;
	iSubGrandTotal = 0;
	%>
  
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" colspan="15" bgcolor="#DBD8C8"><strong>COLLEGE : <%=strCourseProgram%></strong></td>
    </tr>
    <tr> 
      <td width="35%" rowspan="2"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
      <td width="22%" rowspan="2" align="center"><strong><font size="1">MAJOR</font></strong></td>
      <td height="24" colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">1ST YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">2ND YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">3RD YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">4TH YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">5TH YEAR</font></strong></div></td>
      <td colspan="2"><div align="center"><font size="1"></font></div>
        <div align="center"><strong><font size="1">6TH YEAR</font></strong></div></td>
      <td width="7%" rowspan="2"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
    <tr> 
      <td width="3%" height="24"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="3%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
    </tr>
	<%
	for(int j = i; j< vRetResult.size();){//Inner loop for course/major for a course program.
	if(strCourseProgram.compareTo((String)vRetResult.elementAt(j)) != 0)
		break; //go back to main loop.
//System.out.println(strCourseName);
//System.out.println(strMajorName);
			
	if(strCourseName == null || strCourseName.compareTo((String)vRetResult.elementAt(j+1)) !=0)
	{
		strCourseName = (String)vRetResult.elementAt(j+1);
		strCourseNameToDisp = strCourseName;
		strMajorName = WI.getStrValue(vRetResult.elementAt(j+2));
		strMajorNameToDisp = strMajorName; 
	}
	else if(strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0)//course name is same.
	{
		strCourseNameToDisp = "&nbsp;";
		if(strMajorName == null || strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2)) ) !=0)
		{
			strMajorName = WI.getStrValue(vRetResult.elementAt(j+2));
			strMajorNameToDisp = strMajorName;	
		}
		else if(strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2)) ) ==0)
			strMajorNameToDisp = "&nbsp;";
	}
	str1stYrM = null;str1stYrF = null;
	str2ndYrM = null;str2ndYrF = null;str3rdYrM = null;str3rdYrF = null;str4thYrM = null;str4thYrF = null;
	str5thYrM = null;str5thYrF = null;str6thYrM = null;str6thYrF = null;
	iSubTotal = 0;
	//collect information for each year level for a course/major.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("1") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str1stYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("1") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str1stYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str1stYrF);
		j += 6;	
	}
	//2nd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("2") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str2ndYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("2") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str2ndYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str2ndYrF);
		j += 6;	
	}
	//3rd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("3") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str3rdYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("3") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str3rdYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str3rdYrF);
		j += 6;	
	}
	//4th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("4") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str4thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("4") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str4thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str4thYrF);
		j += 6;	
	}
	//5th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("5") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str5thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("5") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str5thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str5thYrF);
		j += 6;	
	}
	//6th year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("6") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("M") ==0) // 1st year. male.
	{
		str6thYrM = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str6thYrM);
		j += 6;	
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 && 
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 && 
		((String)vRetResult.elementAt(j+3)).compareTo("6") ==0 && 
		((String)vRetResult.elementAt(j+4)).compareTo("F") ==0) // 1st year. male.
	{
		str6thYrF = (String)vRetResult.elementAt(j+5);
		iSubTotal += Integer.parseInt(str6thYrF);
		j += 6;	
	}
	iSubGrandTotal += iSubTotal;
i = j;
	
	
	%>
    <tr> 
      <td height="24"><font size="1"><%=strCourseNameToDisp%></font></td>
      <td height="24"><%=WI.getStrValue(strMajorNameToDisp,"&nbsp;")%></td>
      <td><font size="1"><%=WI.getStrValue(str1stYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str1stYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str2ndYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str2ndYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str3rdYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str3rdYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str4thYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str4thYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str5thYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str5thYrF,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str6thYrM,"&nbsp;")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(str6thYrF,"&nbsp;")%></font></td>
      <td><font size="1"><%=iSubTotal%></font></td>
    </tr>
<%}%>
  </table>
    <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="93%" align="right"><strong><font size="1">SUB</font><font size="1"> 
        TOTAL :&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td width="7%" height="24"><strong><font size="1"><%=iSubGrandTotal%></font></strong></td>
    </tr>
  </table>

 <%}//outer most loop%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="93%" align="right"><strong><font size="1">GRAND TOTAL :&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td width="7%" height="24"><strong><font size="1"><%=(String)vRetResult.elementAt(0)%></font></strong></td>
    </tr>
  </table>

<%} // only if there is no error
%>


</body>
</html>
