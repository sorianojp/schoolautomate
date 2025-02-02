 <%@ page language="java" import="utility.*,enrollment.CourseRequirement, enrollment.OfflineAdmission,java.util.Vector"	%>
 <%
   WebInterface WI = new WebInterface(request);
 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <title>Untitled Document</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <style type="text/css">
      body{
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 9px;
      }

      td{
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;
      }
      TABLE.thinborder {
      border-top: solid 1px #000000;
      border-right: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;
      }

      TABLE.thinborderall {
      border: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;
      }

      TD.thinborder {
      border-left: solid 1px #000000;
      border-bottom: solid 1px #000000;
      font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
      font-size: 12px;
      }

      TD.thinborderBottom {
      border-bottom: solid 1px #000000;
      font-size: 12px;
      }
    </style>
  </head>
  <%
    //authenticate user access level
    int iAccessLevel = -1;
    java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

    if(svhAuth == null)
      iAccessLevel = -1; // user is logged out.
    else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
      iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
    else {
      iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ADMISSION MAINTENANCE-PLACEMENT EXAM"),"0"));
      if(iAccessLevel == 0) {
        iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ADMISSION MAINTENANCE"),"0"));
      }
    }

    if(iAccessLevel == -1)//for fatal error.
    {
      request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
      request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
      response.sendRedirect("../../../commfile/fatal_error.jsp");
      return;
    } 
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
    {
      response.sendRedirect("../../../commfile/unauthorized_page.jsp");
      return;
    }

    DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
        "ADMISSION MAINTENANCE-PLACEMENT EXAM-Admission Slip","entrance_admission_slip_print.jsp");

    Vector vApplicantData = null;
    String strErrMsg = null;
    String strTemp = null;
    String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";	
	
    String strTempID = WI.fillTextValue("temp_id");
    OfflineAdmission offlineAdd = new OfflineAdmission();
    CourseRequirement cRequirement = new CourseRequirement();
    Vector vAdmissionReq = null;
    Vector vRetResult = null;
    String strSYFrom = null;
    String strSYTo = null;
    String strSemester = null;
    int iSYTo = 0;

    if (strTempID.length() > 0){
      vRetResult = offlineAdd.createAdmissionSlipReq(dbOP,strTempID);
      if (vRetResult == null)
        strErrMsg = offlineAdd.getErrMsg();
    }
    if(vRetResult != null && vRetResult.size() > 0) {
      strSYFrom = (String)vRetResult.elementAt(0);
      strSYTo = (String)vRetResult.elementAt(1);
      strSemester = (String)vRetResult.elementAt(12);
    }
    String[] astrSemester = {"Summer", " 1st Sem ", "2nd Sem ", "3rd Sem "};

if (vRetResult ==null ){%>
  <%=WI.getStrValue(strErrMsg,"&nbsp")%>
<%}else{%>
  <body onLoad="window.print()">
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td height="2">&nbsp;</td>
        <td colspan="2" align="center">
		<font size="3">
			<strong><%=SchoolInformation.getSchoolName(dbOP,false,false)%></strong></font>
				<br>
			<font size="2"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>		</td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td colspan="2" align="center" style="font-weight:bold;">OFFICE OF ADMISSIONS AND SCHOLARSHIPS </td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td colspan="2" align="center" style="font-weight:bold;">&nbsp;</td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td colspan="2">
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td width="46%">Student ID No: <b><%=strTempID%></b></td>
					<td width="24%">Status: <b><%=WI.getStrValue((String)vRetResult.elementAt(2))%></b></td>
					<td width="30%">Term & SY: <b><%=astrSemester[Integer.parseInt(strSemester)]%>, <%=strSYFrom%>-<%=strSYTo%></b></td>
				</tr>
				<tr>
				  <td>Name of Student: <b><%=WI.getStrValue((String)vRetResult.elementAt(7))%></b></td>
				  <td colspan="2">Applied Course &amp; Year: <b><%=WI.getStrValue((String)vRetResult.elementAt(9))%><%=WI.getStrValue((String)vRetResult.elementAt(10),"(",")","")%> - <%=WI.getStrValue((String)vRetResult.elementAt(17), "N/A")%></b></td>
			  </tr>
			</table>		</td>
      </tr>
      <tr>
        <td height="29">&nbsp;</td>
        <td width="50%" style="font-size:13px; font-weight:bold">
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(2));
		if(strTemp.startsWith("T"))
			strTemp = "TRANSFEREE";
		else	
			strTemp = "NEW";
		%>
		<u>Payment for: TESTING FEE - <%=strTemp%></u></td>
        <td width="48%">&nbsp;</td>
      </tr>
      <tr>
        <td width="2%" height="25">&nbsp;</td>
        <td height="25" colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td align="right">Prepared by: <b><%=(String)request.getSession(false).getAttribute("first_name")%></b></td>
        <td height="25" align="right" style="font-weight:bold"><%=WI.getTodaysDate(6)%> <%=WI.getTodaysDate(15)%> </td>
      </tr>
    </table>
<%}%>

  </body>
</html>
<%
  dbOP.cleanUP();
%>
