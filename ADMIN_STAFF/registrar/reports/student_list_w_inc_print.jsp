<%
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");

if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {
 request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
 request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
 response.sendRedirect("../../../commfile/fatal_error.jsp");
 return;
}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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

<body bgcolor="#ffffff">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector" %>
<%

	String strSchCode= (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsNEU = strSchCode.startsWith("NEU");

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Student list with INC","student_list_w_inc.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","REPORTS",request.getRemoteAddr(),
							//							"student_list_w_inc.jsp");
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
ReportRegistrarExtn RR = new ReportRegistrarExtn();
//enrollment.ReportRegistrarAUF RR = new enrollment.ReportRegistrarAUF();
Vector vRetResult      = null;

if(strSchCode.startsWith("AUF"))
	vRetResult = RR.listStudWithINCAUF(dbOP, request);
else
	vRetResult = RR.listStudWithINC(dbOP, request);
	
if(vRetResult == null)
	strErrMsg = RR.getErrMsg();
dbOP.cleanUP();

String[] astrConvertToSem = {"SUMMER","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER"};
boolean bolShowCourse = true;
boolean bolShowFaculty = true;
boolean bolShowAddress = false;
if(WI.fillTextValue("rem_fac").length() > 0) 
	bolShowFaculty = false;
if(WI.fillTextValue("rem_course").length() > 0) 
	bolShowCourse = false;
if(WI.fillTextValue("show_address").length() > 0) 
	bolShowAddress = true;


Vector vSubjectSummary = null;
///if show_no_of_stud is clicked i have to show # of student per subject. 
if(WI.fillTextValue("show_no_of_stud").length() > 0 && vRetResult != null && vRetResult.size() > 0 && 
	!WI.fillTextValue("report_type").equals("0")) 
	vSubjectSummary = (Vector)vRetResult.remove(0);

if(vRetResult != null && vRetResult.size() > 0){%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td height="25" colspan="8" bgcolor="#dddddd" class="thinborder"><div align="center"><font color="#666600"><strong>LIST 
        OF STUDENTS WITH GRADE STATUS: <%=WI.fillTextValue("report_type_name")%></strong>
		<br>
		<font size="1">For <%=WI.fillTextValue("sy_from") + "-" +WI.fillTextValue("sy_to")%>
		, <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]%>
		<%=WI.getStrValue(WI.fillTextValue("report_name"), "<br>","", "")%></font></font>
		</div></td>
  </tr>
  <tr align="center">
    <td width="1%" class="thinborder"><strong>SL#</strong></td> 
    <td width="10%" height="25" class="thinborder"><font size="1"><strong>STUDENT ID</strong></font></td>
    <td width="12%" class="thinborder"><font size="1"><strong>STUDENT NAME<br>(fname,mi,lname) </strong></font></td>
<%if(bolShowCourse){%>
    <td width="15%" align="center" class="thinborder"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
<%}//remove course if it is called to remove%>
    <td width="25%" class="thinborder"><font size="1"><strong>SUBJECT CODE 
	<%if(bolShowFaculty){%>(INSTRUCTOR/ SECTION)<%}%></strong> </font></td>
<%if(bolShowAddress){%>
    <td width="20%" class="thinborder"><font size="1"><strong>ADDRESS</strong></font></td>
    <td width="8%" class="thinborder"><font size="1"><strong>TELEPHONE</strong></font></td>
<%}%>
	</tr>
<%
strTemp = null;
boolean bolShowID = false;//show Name and show view icon.
int j =0; 
boolean bolShowGrade = WI.fillTextValue("show_grade").equals("1");
String strAddress = null;
String strTelNo   = null;

int iMaxRow = 15;
if(WI.fillTextValue("report_type").equals("0") || WI.fillTextValue("report_type_0").equals("0"))
	iMaxRow = 12;

//arrange grade here.. 
if(bolShowGrade && iMaxRow == 15) {
	for(int i = 0;i < vRetResult.size(); i += 15) {
		if(vRetResult.elementAt(i + 12) == null)
			continue;
		strTemp	= WI.getStrValue((String)vRetResult.elementAt(i + 12));
		
		if( bolIsNEU && strTemp != null && (strTemp.endsWith(".0") || strTemp.length() == 3) && strTemp.indexOf(".") > -1)
			strTemp = strTemp+"0";
			
		vRetResult.setElementAt((String)vRetResult.elementAt(i + 4) + " - "+strTemp, i + 4);
	}
}

for(int i = 0; i< vRetResult.size() ; i += iMaxRow){
	if(iMaxRow == 15) {
		strAddress = WI.getStrValue((String)vRetResult.elementAt(i + 13), "&nbsp;");
		strTelNo   = WI.getStrValue((String)vRetResult.elementAt(i + 14), "&nbsp;");
	}
	else {
		strAddress = "&nbsp;";
		strTelNo = "&nbsp;";
	}
//bolShowID = false;
bolShowID = true;
if(strTemp == null) {
	//bolShowID = true;
	strTemp = (String)vRetResult.elementAt(i);
}
else {
	if(strTemp.compareTo((String)vRetResult.elementAt(i)) != 0) {//id is different.
		//bolShowID = true;
		strTemp = (String)vRetResult.elementAt(i);
	}

} %>
    <tr>
      <td class="thinborder"><%=++j%>.</td> 
      <td height="25" class="thinborder">
	  <%if(bolShowID) {%>
	  <%=(String)vRetResult.elementAt(i)%>
	  <%}else{%>&nbsp;<%}%>	  </td>
      <td class="thinborder">
	  <%if(bolShowID) {%>
	  <%=(String)vRetResult.elementAt(i + 1)%>
	  <%}else{%>&nbsp;<%}%>	  </td>
<!-- no need to display SY/ Term info.
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6) + " - "+(String)vRetResult.elementAt(i + 7)%>
	  (<%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+8))]%>)</td>
-->
<%if(bolShowCourse){%>
      <td class="thinborder"><%if(bolShowID) {%>
        <%=(String)vRetResult.elementAt(i + 2)%>
        <%if(vRetResult.elementAt(i + 3) != null){%>
/<%=(String)vRetResult.elementAt(i + 3)%>
<%}
	  }else{%>
&nbsp;
<%}%></td>
<%}//show only if course is required to show.%>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%>
	  <%if(bolShowFaculty){%>
	  (<%=WI.getStrValue(vRetResult.elementAt(i + 10),"N/F")%>/<%=WI.getStrValue(vRetResult.elementAt(i + 11),"N/F")%>)
	  <%}%>
<%
	///keep all the subjects/ faculty name in one column.
	for(i = i + iMaxRow; i< vRetResult.size() ; i += iMaxRow){//System.out.println("i -: "+i);
		if(!strTemp.equals(vRetResult.elementAt(i))) {
			i = i - iMaxRow;
			break;
		} 
	%>
	;<br><%=(String)vRetResult.elementAt(i + 4)%>
			 <%if(bolShowFaculty){%>(<%=WI.getStrValue(vRetResult.elementAt(i + 10),"N/F")%>/<%=WI.getStrValue(vRetResult.elementAt(i + 11),"N/F")%>)
	<%}//show only if faculty. 
	}%>	  </td>
<%if(bolShowAddress){%>
      <td class="thinborder"><%=strAddress%></td>
      <td class="thinborder"><%=strTelNo%></td>
<%}%>
    </tr>
<%}%>
  </table>

<script language="javascript">
 window.print();

</script>

<%}//only if vRetResult not null

if(vSubjectSummary != null && vSubjectSummary.size() > 0) {%><br>
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
        <tr bgcolor="#DDDDDD">
			<TD width="25%" class="thinborderBOTTOM">Subject Code </TD>
			<TD width="22%" class="thinborderBOTTOM"># of Student </TD>
			<TD class="thinborderBOTTOMRIGHT">&nbsp;</TD>
			<TD class="thinborderBOTTOM">&nbsp;</TD>
			<TD width="25%" class="thinborderBOTTOM">Subject Code </TD>
        	<TD width="22%" class="thinborderBOTTOM"># of Student</TD>
        </tr>
<%for(int i =0; i < vSubjectSummary.size(); i += 2){%>
        <tr>
          <TD class="thinborderNONE"><%=vSubjectSummary.elementAt(i)%></TD>
          <TD class="thinborderNONE"><%=vSubjectSummary.elementAt(i + 1)%></TD>
          <TD class="thinborderRIGHT">&nbsp;</TD>
          <TD class="thinborderNONE">&nbsp;</TD>
          <TD class="thinborderNONE">&nbsp;<%i = i +2; if(i < vSubjectSummary.size()){%> <%=vSubjectSummary.elementAt(i)%><%}%></TD>
          <TD class="thinborderNONE">&nbsp;<%if(i < vSubjectSummary.size()){%> <%=vSubjectSummary.elementAt(i + 1)%><%}%></TD>
        </tr>
<%}%>
 </table>
<%}%>
  <table  bgcolor="#ffffff" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
  </tr>
</table>

</body>
</html>
