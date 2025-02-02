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

vRetResult = cm.operateOnAttendancePeriod(dbOP,request,5);

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
    TD.thinborderLEFTRIGHTTOP {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
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
      <td width="28%" >Attendace Period  </td>
      <td width="26%" colspan="2" >&nbsp; </td>
    </tr>
    <tr> 
      <td valign="bottom" > <input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>"> 
        <strong><%=WI.fillTextValue("sem_label")%></strong> </td>
      <td valign="bottom" > <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox_noborder" readonly="yes">
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox_noborder" readonly="yes"> 
      </td>
      <td ><strong>Semestral Attendance </strong></td>
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
<%if (vRetResult != null && vRetResult.size() > 0) {
String strDaysOfClass = (String)vRetResult.remove(0);
Vector vPmtSchInfo    = (Vector)vRetResult.remove(0);
int iOneRecordSizeInVector = 8 + vPmtSchInfo.size()/2;

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td>&nbsp;</td>
      <td height="25">Total Students Listed   : <strong><%=vRetResult.size() /iOneRecordSizeInVector%></strong></td>
      <td height="25">Number of Days of Class : <strong><%=strDaysOfClass%></strong></td>
    </tr>
  <tr bgcolor="#EBF5F5">
      <td height="25" colspan="3" class="thinborderLEFTRIGHTTOP"><div align="center"><strong>LIST OF STUDENTS 
          WITH ATTENDANCE </strong></div></td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="15%" height="27" align="center" class="thinborder"><font size="1"><strong>STUDENT ID</strong></font></td> 
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>MI</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>YEAR </strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>TOTAL ABSENT </strong></font></td>
<%for(int i = 0; i <vPmtSchInfo.size(); i += 2) {%> 
      <td width="5%" align="center" class="thinborder"><font size="1"><strong><%=((String)vPmtSchInfo.elementAt(i + 1)).toUpperCase()%></strong></font></td>
<%}%>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i +=iOneRecordSizeInVector) {%> 
    <tr>
      <td width="15%" height="27" align="center" style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i)%></td> 
      <td width="10%" align="center" style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td width="10%" align="center" style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td width="5%" align="center" style="font-size:9px;" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+2)," ").charAt(0)%></font></td>
      <td width="15%" align="center" style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td width="5%" align="center" style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td width="5%" align="center" style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
<%for(int p = 0; p <vPmtSchInfo.size(); p += 2) {%> 
      <td width="5%" align="center" style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 8 + p/2)%></td>
<%}//System.out.println(iOneRecordSizeInVector);%>
    </tr>
<%}//end of for loop.%>
  </table>
  <%
  } // if vRetResult == null
} // if vSubSecDetail not found%>
</body>
</html>
<%
	dbOP.cleanUP();
%>