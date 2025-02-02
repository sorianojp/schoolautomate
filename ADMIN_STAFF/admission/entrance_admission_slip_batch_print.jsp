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
    } else if(iAccessLevel == 0)//NOT AUTHORIZED.
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
    Vector vCompliedRequirement = null;
    Vector vExamsPassed = null;
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

      vAdmissionReq = cRequirement.getStudentPendingCompliedList(dbOP,(String)vRetResult.elementAt(16),
          strSYFrom,strSYTo,strSemester,true,true,true);//get both pending and complied list

      if(vAdmissionReq == null && strErrMsg == null){
        //System.out.println("3333");
        strErrMsg = cRequirement.getErrMsg();} else {
        vCompliedRequirement = (Vector)vAdmissionReq.elementAt(1);
        }
		
		vExamsPassed = offlineAdd.getExamResults(dbOP,request,strTempID);
    }

    String[] astrSemester = {"Summer", " First Semester ", "Second Semester", "Third Semester "};

    if (vRetResult ==null ){%>
  <%=WI.getStrValue(strErrMsg,"&nbsp")%>
  <%}else{%>
  <body>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(strSchCode.startsWith("WNU")){%>
      <tr>
        <td height="2">&nbsp;</td>
        <td colspan="2" align="center"><font size="3"><strong>West Negros University </strong></font><br>
		<font size="1">Bacolod City, Philippines</font><br>
		<strong>CENTER FOR ENGLISH LANGUAGE & LITERATURE</strong><br>
		<strong>EPT Individual Result</strong><br>
		<strong>School Year: <%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(12),"1"))]%> &nbsp;&nbsp;<%=(String)vRetResult.elementAt(0)%> - <%=iSYTo%></strong></td>
      </tr>
<%}else{%>
      <tr>
        <td height="2">&nbsp;</td>
        <td colspan="2"></td>
      </tr>

      <tr>
        <td height="2">&nbsp;</td>
        <td colspan="2">
		<font size="3">
			<strong><%=SchoolInformation.getSchoolName(dbOP,false,false)%></strong></font></td>
      </tr>
      <tr>
        <td height="2">&nbsp;</td>
        <td><font size="3" face="Courier New, Courier, mono"><strong>ADMISSION SLIP</strong></font></td>
        <%
          iSYTo = (Integer.parseInt((String)vRetResult.elementAt(0)))+1; %>
        <td><strong><%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(12),"1"))]%> &nbsp;&nbsp;<%=(String)vRetResult.elementAt(0)%> - <%=iSYTo%></strong></td>
      </tr>
<%}%>
      <tr>
        <td height="2">&nbsp;</td>
        <td width="50%">&nbsp;</td>
        <td width="48%">&nbsp;</td>
      </tr>
      <tr>
        <td width="2%" height="25">&nbsp;</td>
        <td height="25" colspan="2"> Name : <strong><%=WI.getStrValue((String)vRetResult.elementAt(7))%></strong></td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td height="25">Temporary ID : <strong><%=WI.getStrValue((String)vRetResult.elementAt(3))%></strong></td>
        <td height="25">Classification : <strong><%=WI.getStrValue((String)vRetResult.elementAt(2))%></strong></td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td height="25">College : <strong><%=WI.getStrValue((String)vRetResult.elementAt(8))%></strong></td>
        <td height="25">Course/Major Applied :<strong><%=WI.getStrValue((String)vRetResult.elementAt(9))%><%=WI.getStrValue((String)vRetResult.elementAt(10),"(",")","")%></strong> </td>
      </tr>
      <tr>
        <td height="25">&nbsp; </td>
		 
		 <% strTemp ="";
		 	boolean bolIsWNU = strSchCode.startsWith("WNU");
			
            if (vExamsPassed.size() > 0){
              for (int i = 0; i < vExamsPassed.size() ; i+=4){
                if (i == 0) {
                  strTemp  += (String)vExamsPassed.elementAt(i)+WI.getStrValue((String)vExamsPassed.elementAt(i+1),"(",")","");
				}
                else
                  strTemp  += "," +(String)vExamsPassed.elementAt(i)+WI.getStrValue((String)vExamsPassed.elementAt(i+1),"(",")","");
              }
            }%>
        <td height="25"><%if(bolIsWNU){%>Total Score<%}else{%>Placement Exams<%}%> : <strong><%=strTemp%><%//=WI.getStrValue((String)vRetResult.elementAt(4))%></strong></td>
        <td height="25">HS Average : <strong><%=WI.getStrValue((String)vRetResult.elementAt(6))%></strong></td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td height="25" colspan="2"> Credentials Presented : <strong>
          <% if(vCompliedRequirement != null && vCompliedRequirement.size() > 0){
              for(int i = 0 ; i< vCompliedRequirement.size(); i +=3){
              if ( i != 0) {%>
          , <%=(String)vCompliedRequirement.elementAt(i+1)%>
          <%}else{%>
          <%=(String)vCompliedRequirement.elementAt(i+1)%>
          <%} // end if else
                } // end for loop
            }else{ // end if vComplietRe%>
          NONE
          <%}%>
        </strong></td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td height="25" colspan="2">Date Admitted : <strong><%=WI.getTodaysDate()%></strong></td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td height="25">&nbsp;</td>
<%
strTemp = null;
if(strSchCode.startsWith("WNU"))
	strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"Cell Director",7)).toUpperCase();
else	
	strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7)).toUpperCase();
%>
        <td height="25" align="center">__<u><%=strTemp%></u>__</td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td height="25" valign="top"><font size="1">
        <% if (strSchCode.startsWith("CPU")){%>
        Revised May 2006
        <%}%>
        &nbsp;</font></td>
        <td height="25" align="center" valign="top">
		<%if(strSchCode.startsWith("WNU")){%>
			Director
		<%}else{%>
			Registrar
		<%}%>
		</td>
      </tr>
    </table>
    <script language="JavaScript">
      window.print();
    </script>
    <%}%>

  </body>
</html>
<%
  dbOP.cleanUP();
%>
