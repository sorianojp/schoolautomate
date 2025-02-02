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

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
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
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	Vector vEmployeeList = (Vector)request.getSession(false).getAttribute("emp_list");

	if(WI.fillTextValue("batch_print").length() == 0){
		vEmployeeList = new Vector();		
		vEmployeeList.addElement(WI.fillTextValue("emp_id"));
	}		
	
	if( vEmployeeList == null || vEmployeeList.size() == 0 ) {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">Employee List not found.</p>
	<%return;}

	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	
	
	

	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-TEACHING LOAD"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-Faculty Load Print","teaching_load_slip_print.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"teaching_load_slip_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/

Vector vRetResult = null;

FacultyManagement FM = new FacultyManagement();
Vector vUserDetail = null;
String strEmployeeIndex = "";//dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							//"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");

String[] astrSemester={"Summer", "First Semester", "Second Semester","Third Semester"};

String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP,false,false);

double dTotalUnits = 0d;
double dLabHours   = 0d;

int i  =0;
int iMaxRowCount   = 35;
int iRowCount      = 0;
int iTemp          = 0;
boolean bolPageBreak = false;


String strExtraCon = WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","","")+
		WI.getStrValue(WI.fillTextValue("d_index")," and offered_by_dept = ","","");



for(int j = 0; j< vEmployeeList.size(); ++j){
	dTotalUnits = 0d;
	dLabHours = 0d;
	strEmployeeIndex = (String)vEmployeeList.elementAt(j);

	if(strEmployeeIndex == null)
		continue;
		
	 strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+strEmployeeIndex+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");
	if(strEmployeeIndex == null)
		continue;
	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"),strExtraCon);	
	if(vUserDetail == null)
		continue;
	
	vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmployeeIndex,
				WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
				WI.fillTextValue("semester"), strExtraCon, true);	
	if(vRetResult == null)
		continue;
		
	if(j == 0 || bolPageBreak)
		iRowCount = 4;
	iRowCount += 5;
	iRowCount += (vRetResult.size()/15);
	
	if(iRowCount >= iMaxRowCount){
		bolPageBreak =  true;
		j=j-1;
		iRowCount = 0;
		continue;
	}

if(bolPageBreak || j == 0){
	if(bolPageBreak){		
		bolPageBreak = false;%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}
%>
  
<table width="100%" border="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="100%" colspan="2"><div align="center"><font size="2"><strong>
			<%=strSchName%></strong> </font><br>
        <font size="1"><%=strSchAddr%></font><br>
<br>

		 <%=WI.fillTextValue("sy_from")  +" - " + WI.fillTextValue("sy_to")%>
		 <% if (WI.fillTextValue("semester").length() > 0) 
		 		strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))];
			else strTemp = "";
		 %><%=WI.getStrValue(strTemp," , ","","")%></div>
      <br></td>
  </tr>
  <% if(strErrMsg != null){%>
  <tr> 
    <td height="25" colspan="2">&nbsp;&nbsp; <%=strErrMsg%></td>
  </tr>
  <%}%>
</table>
<%}
if(vUserDetail != null && vUserDetail.size() > 0){%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr > 
    <td width="2%" height="30">&nbsp;</td>
    <td width="15%">Employee Name</td>
    <td width="29%"><strong><%=(String)vUserDetail.elementAt(0)+" "+(String)vUserDetail.elementAt(1)%></strong></td>
    <td width="19%">Employment Status</td>
    <td width="35%"><strong><%=WI.getStrValue((String)vUserDetail.elementAt(2))%></strong></td>
  </tr>
  <tr > 
    <td height="25">&nbsp;</td>
    <td>College :: Dept </td>
	
	<% strTemp = (String)vUserDetail.elementAt(4);
	   if (strTemp == null) strTemp = (String)vUserDetail.elementAt(5);
	   else strTemp += WI.getStrValue((String)vUserDetail.elementAt(5),"::","","");%>	
	   
    <td><strong> <%=WI.getStrValue(strTemp)%></strong></td>
    <td>Employment Type</td>
    <td><strong><%=WI.getStrValue(vUserDetail.elementAt(7))%></strong></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="33%" height="25"><font size="1">TOTAL NO. OF SECTION : <strong><%=(String)vUserDetail.elementAt(8)%></strong></font></td>
  </tr>
</table>
<%}//end of vUserDetail. 

if(vRetResult != null && vRetResult.size() > 0){%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="14%" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>SUBJECT 
        CODE</strong></font></div></td>
    <td width="26%" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>COLLEGE 
        OFFERING </strong></font></div></td>
    <td width="4%" class="thinborderTOPLEFTBOTTOM"><div align="center"><strong><font size="1">LEC<br>Hours</font></strong></div></td>
    <td width="4%" class="thinborderTOPLEFTBOTTOM"><div align="center"><strong><font size="1">LAB<br>Hours</font></strong></div></td>
    <td width="15%" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>SECTION 
        </strong></font></div></td>
    <td width="20%" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
    <td width="11%" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>ROOM 
        #</strong></font></div></td>
    <td width="6%" class="thinborderALL"><div align="center"><font size="1"><strong>NO. 
        OF STUD.</strong></font></div></td>
  </tr>
  <%    
  for(i = 0 ; i < vRetResult.size() ; i += 15){%>
  <tr> 
    <td height="20" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
	<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i + 12),"0.0");
		dTotalUnits += Double.parseDouble(strTemp);
	%>
    <td class="thinborder" align="center"><div align="center"><%=strTemp%></div></td>
	<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i + 13),"0.0");
		dLabHours += Double.parseDouble(strTemp);
	%>
    <td class="thinborder" align="center"><%=strTemp%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
    <td class="thinborderBOTTOMLEFTRIGHT" align="center"><%=(String)vRetResult.elementAt(i + 7)%></td>
  </tr>
  
  <%}%>
  <tr>
      <td height="20" class="">&nbsp;</td>
      <td class="thinborder" align="right"><strong>TOTAL</strong> &nbsp;</td>
      <td class="thinborder" align="center"><%=CommonUtil.formatFloat(dTotalUnits,1)%></td>
      <td class="thinborder" align="center"><%=CommonUtil.formatFloat(dLabHours,1)%></td>
      <td class="thinborderLEFT">&nbsp;</td>
      <td class="">&nbsp;</td>
      <td class="">&nbsp;</td>
      <td class="" align="center">&nbsp;</td>
  </tr>
</table>

<% }//if vRetResult != null 
} %>

</body>
</html>
<%
dbOP.cleanUP();
%>