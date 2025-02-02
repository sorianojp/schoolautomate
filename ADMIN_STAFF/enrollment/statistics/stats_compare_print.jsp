<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.StatEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

	String strErrMsg = null;
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"statistics_enrollees.jsp");
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
StatEnrollment SE = new StatEnrollment();
Vector vRetResult = null;
if(WI.fillTextValue("reloadPage").length() > 0 && WI.fillTextValue("reloadPage").compareTo("1") !=0)
{
	vRetResult = SE.getEnrolleeStatCompare(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SE.getErrMsg();
}

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="20" colspan="2" bgcolor="#CCCCCC"><div align="center"><strong>:::: 
          STATISTICS COMPARISON - ENROLEES PAGE ::::</strong></div></td>
    </tr>
<%if(strErrMsg != null) {%>
  <tr> 
    <td width="5%" height="20"></td>
    <td width="95%"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
  </tr>
<%}%>
  <tr> 
    <td width="5%" height="20"></td>
    <td width="95%" align="right"><font size="1">Date and Time Printed : <%=WI.getTodaysDateTime()%> &nbsp;&nbsp;&nbsp;&nbsp;</td>
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

	String strPrevYrM = null;
	String strPrevYrF = null;
	String strCurYrM = null;
	String strCurYrF = null;
	
	String strPrevSY  = WI.fillTextValue("prev_sy_from");
	String strPrevSem = WI.fillTextValue("prev_semester");
	String strSY      = WI.fillTextValue("sy_from");
	String strSem     = WI.fillTextValue("semester");
	
	
	int iSubGrandTotalPrevSY = 0; 
	int iSubGrandTotalCurSY = 0; 

	if (strSchCode.startsWith("UI")){
	
		if (strPrevSem.equals("0")){
			iSubGrandTotalPrevSY = Integer.parseInt(WI.getStrValue(strPrevSY,"0")) -1 ;
			strPrevSY = Integer.toString(iSubGrandTotalPrevSY);
		}
		
		if (strSem.equals("0")){
			iSubGrandTotalPrevSY = Integer.parseInt(WI.getStrValue(strSY,"0")) -1 ;
			strSY = Integer.toString(iSubGrandTotalPrevSY);
		}
	}
	
	iSubGrandTotalPrevSY = 0; 
	iSubGrandTotalCurSY = 0; 
	
	int iSubTotalPrevSY = 0;
	int iSubTotalCurSY = 0;
	
	int iGTPrevSY = 0; 
	int iGTSY = 0;
	
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};

	for(int i = 1 ; i< vRetResult.size() ;){//outer loop for each course program.
	strCourseProgram = (String)vRetResult.elementAt(i);
	strCourseName = null;
	
	iSubGrandTotalPrevSY = 0; 
	iSubGrandTotalCurSY = 0;
	%>
  <table  bgcolor="#000000" width="100%" cellspacing="1" cellpadding="1">
    <tr> 
      <td height="20" colspan="8" bgcolor="#DBD8C8"><strong>COLLEGE : <%=strCourseProgram%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="40%" rowspan="2"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
      <td rowspan="2" align="center"><strong></strong><strong><font size="1">MAJOR</font></strong></td>
      
    <td colspan="3" align="center" style="font-size:9px;"><strong><%=WI.fillTextValue("prev_sy_from")%> 
      <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("prev_semester"))]%></strong>
	  <%=WI.getStrValue(WI.fillTextValue("date_prev"), "<br>","","")%>	  </td>
      <td height="24" colspan="3" align="center" style="font-size:9px;"><strong><%=WI.fillTextValue("sy_from")%> 
        <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]%></strong>
		<%=WI.getStrValue(WI.fillTextValue("date_cur"), "<br>","","")%>	  </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center" width="5%"><font size="1"><strong>M</strong></font></td>
      <td align="center" width="5%"><font size="1"><strong>F</strong></font></td>
      <td align="center" width="7%"><strong><font size="1">TOTAL</font></strong></td>
      <td width="5%"><div align="center"><font size="1"><strong>M</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>F</strong></font></div></td>
      <td width="7%"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
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
	strPrevYrM = null;strPrevYrF = null;strCurYrM = null;strCurYrF = null;
	
	
	//collect information for each year level for a course/major.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		strPrevSY.compareTo((String)vRetResult.elementAt(j + 5)) == 0 &&
		strPrevSem.compareTo((String)vRetResult.elementAt(j + 6)) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("M") ==0) // Prev year. male.
	{
		strPrevYrM = (String)vRetResult.elementAt(j+4);
		iSubTotalPrevSY += Integer.parseInt(strPrevYrM);
		j += 7;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		strPrevSY.compareTo((String)vRetResult.elementAt(j + 5)) == 0 &&
		strPrevSem.compareTo((String)vRetResult.elementAt(j + 6)) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("F") ==0) // Prev sy female
	{
		strPrevYrF = (String)vRetResult.elementAt(j+4);
		iSubTotalPrevSY += Integer.parseInt(strPrevYrF);
		j += 7;
	}
	//2nd year.
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		strSY.compareTo((String)vRetResult.elementAt(j + 5)) == 0 &&
		strSem.compareTo((String)vRetResult.elementAt(j + 6)) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("M") ==0) // 1st year. male.
	{
		strCurYrM = (String)vRetResult.elementAt(j+4);
		iSubTotalCurSY += Integer.parseInt(strCurYrM);
		j += 7;
	}
	if(j < vRetResult.size() && strCourseName.compareTo((String)vRetResult.elementAt(j+1)) ==0 &&
		strMajorName.compareTo(WI.getStrValue(vRetResult.elementAt(j+2))) == 0 &&
		strSY.compareTo((String)vRetResult.elementAt(j + 5)) == 0 &&
		strSem.compareTo((String)vRetResult.elementAt(j + 6)) == 0 &&
		((String)vRetResult.elementAt(j+3)).compareTo("F") ==0) // 1st year. male.
	{
		strCurYrF = (String)vRetResult.elementAt(j+4);
		iSubTotalCurSY += Integer.parseInt(strCurYrF);
		j += 7;
	}
	iSubGrandTotalPrevSY += iSubTotalPrevSY; 
	iSubGrandTotalCurSY += iSubTotalCurSY;
	
	i = j;

	%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24"><%=strCourseNameToDisp%></td>
      <td><%=WI.getStrValue(strMajorNameToDisp,"&nbsp;")%></td>
      <td><div align="center"><%=WI.getStrValue(strPrevYrM,"&nbsp;")%></div></td>
      <td><div align="center"><%=WI.getStrValue(strPrevYrF,"&nbsp;")%></div></td>
      <td align="center"><%=iSubTotalPrevSY%></td>
      <td><div align="center"><%=WI.getStrValue(strCurYrM,"&nbsp;")%></div></td>
      <td><div align="center"><%=WI.getStrValue(strCurYrF,"&nbsp;")%></div></td>
      <td align="center"><%=iSubTotalCurSY%></td>
    </tr>
<%iSubTotalPrevSY = 0;iSubTotalCurSY = 0; }%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24" colspan="2" align="right"><strong><font size="1">TOTAL</font> 
        &nbsp;&nbsp;</strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center"><%=iSubGrandTotalPrevSY%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center"><%=iSubGrandTotalCurSY%></td>
    </tr>
 <%	iGTPrevSY += iSubGrandTotalPrevSY; 
	iGTSY += iSubGrandTotalCurSY;
	iSubGrandTotalPrevSY = 0; iSubGrandTotalCurSY = 0;}//outer most loop%>
    <tr bgcolor="#FFFFFF"> 
      <td height="24" colspan="2" align="right"><strong><font size="1" color="#0000FF">GRAND TOTAL</font> 
        &nbsp;&nbsp;</strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center"><font color="#0000FF"><%=iGTPrevSY%></font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center"><font color="#0000FF"><%=iGTSY%></font></td>
    </tr>
  </table>
<%}//only if vRetResult is not null
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
