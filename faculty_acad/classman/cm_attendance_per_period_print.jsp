<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportEnrollment,ClassMgmt.CMAttendance " %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;

	Vector vSecDetail = null;
//add security here.

try
	{
		dbOP = new DBOperation();
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
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"cm_attendance");	
iAccessLevel = 2;
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
	String strSubSecIndex   = null;
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	Vector vRetResult = null;
	
	

	if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
						" and e_sub_section.offering_sem="+
						WI.fillTextValue("offering_sem")+" and is_lec=0");
							
	}
	
	if(strSubSecIndex != null) {//get here subject section detail. 
		vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
		if(vSecDetail == null)
			strErrMsg = reportEnrl.getErrMsg();
	}
	
if(WI.fillTextValue("section").length() > 0 && WI.fillTextValue("showCList").compareTo("0") != 0)
{
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,request.getParameter("section"));

	if(vSecDetail == null && WI.fillTextValue("is_firsttime").length() > 0)
		strErrMsg = reportEnrl.getErrMsg();
}
CMAttendance cm = new CMAttendance(request);
int iCtr = 0;int iCtr2 = 0;

vRetResult = cm.operateOnAttendancePeriod(dbOP,request,4);

if (vRetResult == null && strErrMsg == null){
	strErrMsg = cm.getErrMsg();	
}
%>
<html>
<head>
<title>Class Attendance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>


<body onLoad="window.print();">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;<strong><font size="3" color="#FF0000"> 
        <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="23%" valign="bottom" >School Year</td>
      <td width="28%" >Exam Period </td>
      <td width="26%" colspan="2" >&nbsp; </td>
    </tr>
    <tr> 
      <td valign="bottom" > <input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>"> 
        <strong><%=WI.fillTextValue("sem_label")%></strong> </td>
      <td valign="bottom" > <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox_noborder" readonly="yes">
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox_noborder" readonly="yes"> 
      </td>
      <td ><input name="date_attendance" type="text" class="textbox_noborder" id="date_attendance"
	  value="<%=WI.fillTextValue("exam_period_label")%>" size="11" readonly="yes" > 
      </td>
      <td colspan="2" >&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="15"></td>
      <td height="15" >&nbsp;</td>
      <td height="15" >&nbsp;</td>
    </tr>
    <tr> 
      <td></td>
      <td height="25" >INSTRUCTOR</td>
      <td width="82%" ><strong> 
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%> 
        <%}%>
        </strong></td>
    </tr>
    <tr> 
      <td width="1%"></td>
      <td width="17%" height="25" >SECTION </td>
      <td ><input type="text" name="section2" class="textbox_noborder" readonly="yes" value="<%=WI.fillTextValue("section_name")%>"> 
      </td>
    </tr>
    <tr> 
      <td></td>
      <td height="25" >SUBJECT </td>
      <td height="25" > <strong> 
        <input type="hidden" name="subject" value="<%=WI.fillTextValue("subject")%>">
        <strong><%=WI.fillTextValue("subj_label")%> <%=WI.getStrValue(dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0"),"(",")","")%></strong> </strong> </td>
    </tr>
  </table>
<%if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td width="15%">&nbsp;</td>
      <td width="24%"><div align="center"><font color="#000099" size="1"><strong>ROOM 
          NUMBER</strong></font></div></td>
      <td width="20%"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
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
<%
	if (vRetResult != null) {
		Vector vRecorded = (Vector)vRetResult.elementAt(0);	
		Vector vUnrecorded = (Vector)vRetResult.elementAt(1);
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td>&nbsp;</td>
      <td height="15" valign="top"><strong>TOTAL STUDENTS ENROLLED IN THIS CLASS : <%=Integer.parseInt((String)vRecorded.elementAt(0)) + Integer.parseInt((String)vUnrecorded.elementAt(0))%> </strong> <div align="right"></div></td>
    </tr>	
  </table>
<%  if (vUnrecorded.size() > 1){ %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
	  <td height="25"><div align="center"><strong>LIST OF STUDENTS WITH NO ATTENDANCE 
          RECORD</strong></div></td>
  </tr>
  </table
  ><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="12%" height="27" rowspan="2" align="center" class="thinborder"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="27" colspan="3" align="center" class="thinborder"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="15%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="5%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>YEAR </strong></font></td>
    </tr>
    <tr> 
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>MI</strong></font></td>
    </tr>
    <% iCtr = 0;
		for(int k=1; k<vUnrecorded.size(); k+=7, iCtr++){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vUnrecorded.elementAt(k)%></font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vUnrecorded.elementAt(k+3)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vUnrecorded.elementAt(k+1)%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(WI.getStrValue((String)vUnrecorded.elementAt(k+2), " ")).charAt(0)%></font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vUnrecorded.elementAt(k+4)%> </font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vUnrecorded.elementAt(k+5)%></font></div></td>
    </tr>
    <%}// end of for loop%>
  </table>
  <%} if (vRecorded.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
	  <td height="25"><div align="center"><strong>LIST OF STUDENTS WITH ATTENDANCE 
          RECORD</strong></div></td>
  </tr>
  </table
  >
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td width="12%" height="27" rowspan="2" align="center"  class="thinborder"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="27" colspan="3" align="center"  class="thinborder"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="14%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="4%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>YEAR 
        </strong></font></td>
      <td width="14%" rowspan="2" align="center" class="thinborder"><strong><font size="1">DAYS ABSENT </font></strong></td>
      <td width="14%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <tr> 
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>MI</strong></font></td>
    </tr>
    <%	for(int k=1; k<vRecorded.size(); k+=10,iCtr2++){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRecorded.elementAt(k)%></font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vRecorded.elementAt(k+3)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRecorded.elementAt(k+1)%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(WI.getStrValue((String)vRecorded.elementAt(k+2), " ")).charAt(0)%></font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vRecorded.elementAt(k+4)%> </font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRecorded.elementAt(k+5)%></font></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRecorded.elementAt(k+7)%></div></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRecorded.elementAt(k+8),"&nbsp")%></font></td>
    </tr>
    <%}// end of for loop%>
  </table>
 <%}// vRecorded.size() > 1
  } // if vRetResult == null
} // if vSubSecDetail not found%>
</body>
</html>
<%
	dbOP.cleanUP();
%>