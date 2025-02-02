<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsSWU = strSchCode.startsWith("SWU");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>

<%
	

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

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
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-SUMMARY LOAD"),"0"));
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
								"Admin/staff-Enrollment-Faculty-Summary Load","summary_faculty_load_per_college_dept.jsp");
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
														"summary_faculty_load_per_college_dept.jsp");
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
**/
Vector vRetResult = null;
Vector vEmpRec = null;
utility.ConstructSearch conSearch = new utility.ConstructSearch(request);



enrollment.FacultyManagementExtn fmExtn = new enrollment.FacultyManagementExtn();
vRetResult = fmExtn.viewSummaryFacultyLoadPerCollege(dbOP, request);
if(vRetResult == null) 
	strErrMsg = fmExtn.getErrMsg();	

String[] astrSortByName    = {"Employee ID","Lastname","Firstname","Faculty Load"};
String[] astrSortByVal     = {"id_number","lname","fname","load_u"};

String[] astrConvertSem ={"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};





int iIndexOf = 0;
boolean bolShowAll    = (WI.fillTextValue("d_index").length() == 0 && WI.fillTextValue("c_index").length() == 0 &&  bolIsSWU);
boolean bolPerCollege = (WI.fillTextValue("d_index").length() == 0 && bolIsSWU);
Vector vCollegeFaculty = new Vector();

String strPTFT = null;
strTemp = "select pt_ft from INFO_FACULTY_BASIC where IS_VALID = 1 and USER_INDEX = (select USER_INDEX from USER_TABLE where ID_NUMBER =?) ";
java.sql.PreparedStatement pstmtPTFT = dbOP.getPreparedStatement(strTemp);
java.sql.ResultSet rs = null;
%>
<body>

  


  
  
  
<%if(vRetResult != null && vRetResult.size() > 0) { //System.out.println(vRetResult.size() + ":::"+vRetResult);
int iMaxRowCount = 30;
int iRowCount = 0;
int iPageNo = 0;
boolean bolPageBreak = false;
 String strCollegeName = null;
 for(int i = 0; i < vRetResult.size(); i += 6) {
 iRowCount = 0;
 strTemp = (String)vRetResult.elementAt(i);
  if(bolShowAll && strTemp != null){
	
	iIndexOf = strTemp.indexOf(" :::");
	if(iIndexOf > -1)
		strTemp = strTemp.substring(0, iIndexOf);			
	strCollegeName = strTemp;
}
 
 
 if(strCollegeName != null)
	strTemp = strCollegeName;
	
if(bolPageBreak){
	bolPageBreak = false;
%>  
	<div style="page-break-after:always;">&nbsp;</div>
<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr><td colspan="2"><div align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div><br></td></tr>
	<tr><td height="20" align="center"><strong><font size="2"><%=strTemp%><br><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>,  
	<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></font></strong> 
		
	</td></tr>
	<tr>
	    <td height="20" align="right">Page No. <%=++iPageNo%></td>
    </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="6" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>SUMMARY OF FACULTY LOAD</strong></font></div></td>
    </tr>
    <tr> 
      <td width="13%" height="25" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE ID </strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME </strong></font></div></td>
	   <%if(bolIsSWU){%>
	   <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>EMP. STATUS</strong></font></div></td>
	  <%}
	  strTemp = "TOTAL LOAD UNITS";
	  if(bolIsSWU)
	  	strTemp = "MAXIMUM HOUR LOAD";
	  	
	  %>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong><%=strTemp%></strong></font></div></td>	  
      <td width="10%" class="thinborder" align="center" style="font-weight:bold; font-size:9px;">TOTAL LOAD HOUR </td>
      <%if(!bolIsSWU){%><td width="54%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECTS HANDLED</strong></font></div></td><%}%>
    </tr>

    <!--<tr> 
      <td height="25" colspan="6" class="thinborder" bgcolor="#FFFFDF"> <strong><%=WI.getStrValue(strTemp)%></strong></td>
    </tr>-->
 <%
 

 
 vRetResult.setElementAt(null,i);
 for(; i < vRetResult.size(); i += 6) {
 	if(  vRetResult.elementAt(i) != null && (!bolPerCollege ||  bolShowAll) ) {
		iIndexOf = -1;
		if(bolShowAll){
			strTemp = (String)vRetResult.elementAt(i);
			
			if(strCollegeName != null)
				iIndexOf = strTemp.indexOf(strCollegeName);
		}
		
		if(iIndexOf == -1)		{
			bolPageBreak = true;
			iPageNo = 0;
			i -= 6;
			break;
		}
	}
	
	
	
	if(bolPerCollege){
	
		if(vCollegeFaculty.indexOf((String)vRetResult.elementAt(i + 1)) > -1)
			continue;
		
		vCollegeFaculty.addElement((String)vRetResult.elementAt(i + 1));
	}
	
	strPTFT = null;
	pstmtPTFT.setString(1, (String)vRetResult.elementAt(i + 1));
	rs = pstmtPTFT.executeQuery();
	if(rs.next()){
		strPTFT = WI.getStrValue(rs.getString(1));
		if(strPTFT.equals("1"))
			strPTFT = "Full-Time";
		else if(strPTFT.equals("0"))
			strPTFT = "Part-Time";
		else
			strPTFT = "";			
	}rs.close();
	if(++iRowCount > iMaxRowCount){
		bolPageBreak = true;
		i -= 6;
		break;
	}
	%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
	  <%if(bolIsSWU){%>
	   <td width="15%" class="thinborder"><div align="center"><%=WI.getStrValue(strPTFT,"&nbsp;")%></div></td>
	   <%}%>
      <td class="thinborder"><div align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), false)%></div></td>
      <td class="thinborder" align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 4), false)%></td>
      <%if(!bolIsSWU){%><td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td><%}%>
    </tr>
 <%
 
	 
 
 }//inner loop 
 
 %>
  </table>
<%
}//outer loop.%>
<script>window.print();</script>
<%}//only if vRetResult is not null%>
  
 
</body>
</html>
<%
dbOP.cleanUP();
%>