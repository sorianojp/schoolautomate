<%@ page language="java" import="utility.*,health.SchoolSpecific,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other(Hepa/xRay)","hepa_xray.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
SchoolSpecific SS = new SchoolSpecific();
String strCollegeName = null; String strCourseCode = null; String strYear = null;
	vRetResult = SS.operateOnStudLeaveApplication(dbOP, request, 3);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
	else {
		strTemp = (String)vRetResult.elementAt(8);
		strTemp = "select c_name, course_code, year_level from stud_curriculum_hist "+
			"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
			"join college on (college.c_index = course_offered.c_index) "+
			"where user_index="+strTemp+" and stud_curriculum_hist.is_valid = 1 and "+
			" sy_from = "+request.getParameter("sy_from")+" and semester="+request.getParameter("semester");
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			strCollegeName = rs.getString(1);
			strCourseCode  = rs.getString(2);
			strYear        = rs.getString(3);
		}
	}

String[] astrConvertToTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTTOPBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>
<body onLoad="window.print(); document.form_.input_.focus();">
<form name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="83"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
		<%=strCollegeName%> <br>
		SY/ Term : <%=request.getParameter("sy_from") + " - "+ request.getParameter("sy_to")%>, 
		<%=astrConvertToTerm[Integer.parseInt(request.getParameter("semester"))]%>
		<br>
        <strong> 
		Leave of Absence Slip	
		</strong></font></div></td>
  </tr>
</table>
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="22">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <%}
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="22" align="right">Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr style="font-weight:bold"> 
      <td width="33%" height="22">Student Number</td>
      <td width="34%">Student Name </td>
      <td width="33%">Course/Yr</td>
    </tr>
    <tr>
      <td height="22"><%=vRetResult.elementAt(13)%></td>
      <td><%=vRetResult.elementAt(14)%></td>
      <td><%=strCourseCode%> / <%=strYear%></td>
    </tr>
    <tr style="font-weight:bold">
      <td height="22">Date Filed </td>
      <td>Days Absent </td>
      <td>Time of Absence </td>
    </tr>
    <tr>
      <td height="22"><%=vRetResult.elementAt(16)%></td>
      <td><%=vRetResult.elementAt(1)%> <%=WI.getStrValue((String)vRetResult.elementAt(2), " to ","","")%></td>
      <td><%strTemp = "";
		if(vRetResult.elementAt(3) != null)
			strTemp = (String)vRetResult.elementAt(3) + ":"+WI.getStrValue(vRetResult.elementAt(4),"00");
		if(vRetResult.elementAt(5) != null)
			strTemp += " to "+(String)vRetResult.elementAt(5) + ":"+WI.getStrValue(vRetResult.elementAt(6),"00");
		%>
      <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    </tr>
    <tr style="font-weight:bold">
      <td height="22">Remarks</td>
      <td>Status</td>
      <td>Approved By</td>
    </tr>
    <tr>
      <td height="22"><%=vRetResult.elementAt(10)%></td>
      <td><%if(vRetResult.elementAt(11).equals("1")){%>Excused<%}else{%>Un-Excused<%}%></td>
      <td><%=vRetResult.elementAt(15)%></td>
    </tr>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="41" valign="bottom"><u><%=(String)request.getSession(false).getAttribute("first_name")%></u></td>
      <td width="100%" height="41" valign="bottom" align="right"><input type="text" name="input_" style="border-left:0; border-right:0; border-top:0; border-bottom-color:#000000; border-bottom-width:1px;"></td>
    </tr>
    <tr> 
      <td width="100%" height="32" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Prepared by</td>
      <td width="100%" height="32" valign="bottom" align="right">Approved by &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
</table>
<%}//end of display. %>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>