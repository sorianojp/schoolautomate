<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
</script>
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.TimeInTimeOut" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","edit_dtr.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"edit_dtr.jsp");	
iAccessLevel = 2;
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
	String strPrepareToEdit = null;
%>
<body bgcolor="#93B5BB">
<form name="cm_op" method="post" action="./cm_attendance.jsp">  
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CLASS ATTENDANCE - VIEW ATTENDANCE SUMMARY PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="16%"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;SUBJECT 
        CODE</strong></font></td>
      <td height="25" colspan="2"> <select name="select3">
          <option>English 101</option>
          <option>Nat Sci 201 Lec/Lab</option>
        </select> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;SECTION</strong></font></td>
      <td height="25" colspan="2"><select name="select2">
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td> <strong><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;</strong></font>PERIOD</strong><font size="2"><strong></strong></font></td>
      <td width="13%" height="25"><select name="select4">
          <option>ALL</option>
          <option>Prelim</option>
          <option>Midterm</option>
          <option>Pre-Final</option>
          <option>Finals</option>
        </select></td>
      <td width="71%"><a href="cm_attendance_view.jsp"><img src="../../images/view.gif" border="0"></a><font size="1">click 
        to show attendance for this class for the specified period</font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp; </td>
      <td height="25" colspan="2"><img src="../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5"> <p><strong>&nbsp;&nbsp;SUBJECT TITLE :</strong> 
        </p></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="21%" height="25"><strong>&nbsp;&nbsp;Lec/Lab Units : </strong>3 
        (lec)</td>
      <td width="5%">&nbsp;</td>
      <td width="36%" height="25"><strong>Lec/Lab Hours/Week :</strong> 3 Lecture, 
        0 Laboratory</td>
      <td width="76%" height="25" colspan="2"><strong>Prerequisites :</strong> 
        $prereq_subjs</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr> 
      <td>&nbsp;</td>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td>&nbsp;</td>
      <td height="25" width="60%">TOTAL STUDENTS ENROLLED IN THIS CLASS : <strong><%=(String)vClassList.elementAt(0)%></strong></td>
      <td width="39%" height="25"><div align="right"><font size="1"><a href="javascript:show_calendar('cm_op.date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../images/print.gif" border="0"></a>click 
          to print attendance</font></div></td>
    </tr>
  <tr bgcolor="#EBF5F5">
      <td height="25" colspan="3"><div align="center">LIST OF STUDENTS OFFICIALLY
          ENROLLED </div></td>
  </tr>
</table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="10%" height="27" rowspan="2" align="center"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="27" colspan="3" align="center"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="8%" rowspan="2" align="center"><font size="1"><strong>TOTAL DAYS 
        PER SEMESTER</strong></font></td>
      <td width="10%" rowspan="2" align="center"><font size="1"><strong>TOTAL 
        ABSENCES</strong></font></td>
      <td width="6%" rowspan="2" align="center"><div align="center"><font size="1"><strong>PRELIM</strong></font></div></td>
      <td width="8%" rowspan="2" align="center"><div align="center"><font size="1"><strong>MIDTERM</strong></font></div></td>
      <td width="7%" rowspan="2" align="center"><div align="center"><font size="1"><strong>PRE-FINALS</strong></font></div></td>
      <td width="8%" rowspan="2" align="center"><div align="center"><font size="1"><strong>FINALS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="16%" align="center"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="17%" align="center"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>MI</strong></font></td>
    </tr>
    <%
for(int i=1; i<vClassList.size(); ++i){%>
    <tr> 
      <td height="25"><div align="center"><font size="1">CC-04-000000</font></div></td>
      <td><font size="1">Patalinhug Dela</font></td>
      <td><font size="1">John Thomas</font></td>
      <td><div align="center"><font size="1">C.</font></div></td>
      <td><div align="center"><font size="1">54</font></div></td>
      <td><div align="center"><font size="1">8</font></div></td>
      <td><div align="center"><font size="1">2 </font></div></td>
      <td><div align="center"><font size="1">3</font></div></td>
      <td><div align="center"><font size="1">5</font></div></td>
      <td> <div align="center"></div>&nbsp;</div></td>
    </tr>
    <%
i = i+7;
}%>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2">
      <td height="25" bgcolor="#FFFFFF"><div align="center">
          <input name="image" type="image" 
		  onClick="AddRecord()" src="../../images/save.gif" >
          <font size="1">click to save changes/entries</font></div></td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>