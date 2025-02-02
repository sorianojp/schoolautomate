<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td.subheader {
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
	font-size: 8px;
    }
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }
    TD.thinborderLRB {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }

-->
</style>
<body>
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolShowEditInfo = false;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_candidates_print.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_candidates_print.jsp");
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

Vector vRetResult = null;
EntranceNGraduationData eng = new EntranceNGraduationData();
vRetResult = eng.viewAllGraduatingStudents(dbOP,request);
Vector vRetCandidates = null;


if (vRetResult == null){
	strErrMsg = eng.getErrMsg();
}

vRetCandidates = eng.operateOnCandidatesList(dbOP,request,4);

if (vRetCandidates == null) vRetCandidates = new Vector();

String[] astrConvertSem = {"Summer","1st Term","2nd Term","3rd Term","4th Term", "5th Term"};

	String strCollegeName = 
	new enrollment.CurriculumMaintenance().getCollegeName(dbOP,WI.fillTextValue("course_index"));
	if(strCollegeName != null)
		strCollegeName = strCollegeName.toUpperCase();
%>

<% if (vRetCandidates !=null && vRetCandidates.size() > 0) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="2" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" colspan="6" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,true)%> <br>
		<%=strCollegeName%>
<br>
        <strong>CANDIDATES FOR GRADUATION </strong>
		<br>
		<font style="font-size:11px; font-weight:bold">
		  <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
		</font>
		<div align="right" style="font-size:9px;">Date and time printed: <%=WI.getTodaysDateTime()%></div></td>
  </tr>
  <tr> 
    <td width="3%" class="thinborderALL"><strong><font size="1">COUNT</font></strong></td>
    <td width="12%" height="22" class="thinborderALL"><font size="1"><strong>ID NUMBER </strong></font></td>
    <td width="22%" class="thinborderALL"><font size="1"><strong>NAME</strong></font></td>
    <td width="8%" class="thinborderALL"><font size="1"><strong>COURSE</strong></font></td>
    <td width="5%" class="thinborderALL"><strong><font size="1">STATUS</font></strong></td>
    <td width="50%" class="thinborderALL"><strong><font size="1">REMARKS</font></strong></td>
  </tr>
  <% int iCtr = 1;
  	 boolean bolPrintPass = false; boolean bolPrintPending = false;
	 strTemp = WI.fillTextValue("print_stat");
	 if(strTemp.equals("1"))
	 	bolPrintPass = true;
	 else if(strTemp.equals("2"))
	 	bolPrintPending = true;
		
	 
	 for(int i =0; i < vRetCandidates.size() ; i+=7) {  
	 	if(bolPrintPass && ((String)vRetCandidates.elementAt(i+4)).startsWith("PE"))
			continue;
	 	if(bolPrintPending && ((String)vRetCandidates.elementAt(i+4)).startsWith("PA"))
			continue;
	 %>
  <tr> 
    <td class="thinborder"><font size="1"><%=iCtr++%>)</font></td>
    <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetCandidates.elementAt(i+2)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetCandidates.elementAt(i+3)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetCandidates.elementAt(i+6)%></font></td>
    <td class="thinborder"><font size="1"><%=(String)vRetCandidates.elementAt(i+4)%></font></td>
    <td class="thinborderLRB"><font size="1"><%=ConversionTable.replaceString(WI.getStrValue((String)vRetCandidates.elementAt(i+5),"&nbsp"),"\n\r","<br>")%></font></td>
  </tr>
  <%}//end for loop of candidates%>
</table>
<%}else{ // end vRetCandidates = null%>
<font size="3">&nbsp; <%=strErrMsg%></font>
<%}%>
 <script language="JavaScript">
alert("Press any key to start printing.");
window.print();
 </script>
</body>
</html>
<%
dbOP.cleanUP();
%>
