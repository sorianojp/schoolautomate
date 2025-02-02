<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
</head>
<body >
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-list print","faculty_list_print_load.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

	FacultyManagement FM = new FacultyManagement();
	String strExtraCon = "";
	if(request.getParameter("gender")!= null && request.getParameter("gender").trim().length() > 0)
	 	strExtraCon = " and INFO_FACULTY_BASIC.GENDER="+request.getParameter("gender");
	if(request.getParameter("emp_status") != null && request.getParameter("emp_status").trim().length() > 0)
		strExtraCon += " and user_status.status_index="+request.getParameter("emp_status");
	if(request.getParameter("d_index") != null && request.getParameter("d_index").trim().length() > 0)
		strExtraCon += " and INFO_FACULTY_BASIC.d_index="+request.getParameter("d_index");

	if(WI.fillTextValue("show_with_load").length() > 0) 
		strExtraCon += " and exists (select * from faculty_load where is_valid = 1 and exists (select * from e_sub_section where "+
		" sub_sec_index = faculty_load.sub_sec_index and offering_sy_from = "+request.getParameter("sy_from")+
		" and offering_sem="+request.getParameter("semester")+") and INFO_FACULTY_BASIC.user_index = faculty_load.user_index) ";


Vector vRetResult = FM.viewFacPerCollegeWithLoadStat(dbOP, request.getParameter("c_index"),null,request.getParameter("sy_from"),
														request.getParameter("sy_to"),request.getParameter("semester"),
														strExtraCon,false,0f,"0","");

//dbOP.cleanUP();//clean up here.

if(vRetResult == null || vRetResult.size() == 0)
	strErrMsg = FM.getErrMsg();
if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%}else{%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%"><div align="center"><font size="1"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></font></div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><font size="1"><strong><%=request.getParameter("college_name")%></strong></font></div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>LIST
          OF FACULTIES</strong></font></div></td>
    </tr>
  </table>


<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="18%" height="25" class="thinborder"><div align="center"><font size="1">COLEGE 
        :: DEPT</font></div></td>
    <td width="13%" class="thinborder"><div align="center"><font size="1">EMPLOYEE 
        ID</font></div></td>
    <td width="34%" class="thinborder"><div align="center"><font size="1">EMPLOYEE 
        NAME</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">GENDER</font></div></td>
    <td width="10%" class="thinborder"><div align="center"><font size="1">EMP. 
        STATUS</font></div></td>
    <td width="8%" class="thinborder"><div align="center"><font size="1">MAX LOAD</font></div></td>
    <td width="8%" class="thinborder"><div align="center"><font size="1">TOTAL 
        UNITS LOAD</font></div></td>
  </tr>
  <%
int i = 0;
 for(; i< vRetResult.size(); ++i){%>
  <tr> 
    <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5))%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborder">
      <%if( ((String)vRetResult.elementAt(i+8)).compareTo("0") == 0){%>
      <font color="#0000FF">Not Set</font> 
      <%}else{%>
      <%=WI.getStrValue((String)vRetResult.elementAt(i+8))%> 
      <%}%>
    </td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
  </tr>
  <% //System.out.println(vRetResult.elementAt(i+6));
  i = i+9;
}%>
  <tr> 
    <td  colspan="7" height="25" class="thinborder"><font size="1">TOTAL NUMBER 
      OF FACULTIES FOR THIS COLLEGE : <strong><%=i/8%></strong></font> </td>
  </tr>
</table>
<script language="JavaScript">
	window.print();
window.setInterval("javascript:window.close();",0);
</script>
<%} // only if there is no error
%>



</body>
</html>
