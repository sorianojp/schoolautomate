<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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

.bodystyle {
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
	 
	 TD.thinborderBottom {    
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	 
	 TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	 
-->
</style>
</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);

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

String strPTFT = null;
String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");


if(strEmployeeIndex != null) {
	

		strPTFT = dbOP.mapOneToOther("INFO_FACULTY_BASIC","user_index", strEmployeeIndex, "PT_FT", 
									" and is_del = 0" );
		if (strPTFT == null || strPTFT.equals("0")) 
			strPTFT = "Part Time";
		else
			strPTFT = "Full Time";
		

	
	
	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
	if(vUserDetail == null){
		strErrMsg = FM.getErrMsg();
	}else {
		vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"), "", true);
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
		
	}
	
	
	
}else if (WI.fillTextValue("emp_id").length() > 0) {
	strErrMsg = " Invalid employee ID.";
}

String[] astrSemester={"Summer", "First Semester", "Second Semester","Third Semester"};

//end of authenticaion code.
%>
  

<%   if(vUserDetail != null && vUserDetail.size() > 0 && vRetResult != null && vRetResult.size() > 0){
	
	boolean bolPageBreak = false;
	int iPageCount = 1;
	int iRowCount = 0;
	int iMaxRowCount = 20;
	double dUnit = 0d;
	for(int i = 0; i < vRetResult.size(); ){
		if(bolPageBreak){
			bolPageBreak= false;
	%>
  	<div style="page-break-after:always;">&nbsp;</div>
  	<%}%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
   	<td width="49%"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
      <td width="51%" align="right">Page <%=iPageCount++%></td>
   </tr>
   <tr>
   	<td height="18">Class  Scheduling System</td>
      <td align="right"><%=WI.getTodaysDateTime()%></td>
   </tr>
</table>  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
   	<td width="19%" height="20" class="thinborderTOP">Istructor ID</td>
      <td width="58%" class="thinborderTOP"> : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
      <td width="10%" class="thinborderTOP">Status:</td>
      <td width="13%" class="thinborderTOP"><strong><%=WI.getStrValue(strPTFT)%></strong></td>      
   </tr>
   
   <tr>
   	<td height="20" class="thinborderBottom">Istructor Name</td>
      <td class="thinborderBottom"> : <strong><%=((String)vUserDetail.elementAt(1)).toUpperCase()%></strong></td>
      <td class="thinborderBottom">&nbsp;</td>
      <td class="thinborderBottom">&nbsp;</td>      
   </tr>
</table>



      	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
            <tr>
               <td width="11%" height="18"><u><strong>Subject</strong></u></td>
               <td width="25%"><u><strong>Description</strong></u></td>
               <td width="5%"><u><strong>Load Hour</strong></u></td>
               <td width="6%"><u><strong>Day</strong></u></td>
               <td width="12%"><u><strong>Time</strong></u></td>
               <td width="6%"><u><strong>Room</strong></u></td>
               <td width="6%"><u><strong>Lec/Lab</strong></u></td>
               <td width="11%"><u><strong>Section</strong></u></td>
               <td width="8%"><u><strong>No. of Stud</strong></u></td>
               <td width="10%"><u><strong>With</strong></u></td>
            </tr>
         
           <%  
           
           for(; i < vRetResult.size() ; i +=12){
				  iRowCount++;
				  %>
           <tr> 
           
             <td height="20" class=""><%=(String)vRetResult.elementAt(i)%></td>
             <td class=""><div><%=(String)vRetResult.elementAt(i + 1)%></div></td>
             <%
             strTemp = "LEC";
             if(((String)vRetResult.elementAt(i)).indexOf("LAB") > -1)
               strTemp = "LAB";
               
             if(((String)vRetResult.elementAt(i + 3)).startsWith("0.0"))
               strTemp = "LAB";
             
             dUnit += Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 9), "0"));
             %>
             <td class="" align="right"><%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(i + 9)), 1)%> &nbsp; &nbsp;</td>
             <%
            String strTemp2 = null;
             String strDays = null;
             String strTime = null;
             int iIndexOf = 0;
             strErrMsg = (String)vRetResult.elementAt(i + 6);
             if(strErrMsg != null) {
                  Vector vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);
                  strErrMsg = "";
                  while(vTemp.size() > 0) {
                     strTemp2 = (String)vTemp.remove(0);
                     
                     iIndexOf = strTemp2.indexOf(" ");
                     if(iIndexOf > -1){						
                        if(strDays == null)
                           strDays = strTemp2.substring(0, iIndexOf);
                        else
                           strDays += "<br>"+strTemp2.substring(0, iIndexOf);
                        
                        if(strTime == null)
                           strTime = strTemp2.substring(iIndexOf + 1).toLowerCase();
                        else
                           strTime += "<br>"+strTemp2.substring(iIndexOf + 1).toLowerCase();					
                     }					
                  }
               }
             %>
             
             <td class=""><%=WI.getStrValue(strDays, "&nbsp;")%></td>
             <td class=""><%=WI.getStrValue(strTime, "&nbsp;")%></td>
             <td class=""><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
             <td class=""><%=strTemp%></td>
             <td class=""><%=(String)vRetResult.elementAt(i + 4)%></td>
             <td class=""><%=(String)vRetResult.elementAt(i + 7)%></td>
             <td class="">&nbsp;</td>
           </tr>
           <%
			  
			 	if(iRowCount >= iMaxRowCount) {
					bolPageBreak = true;
					i+=9;
					iRowCount = 0;
					break;	
				}
			  
			  }
			  if(i + 12 >= vRetResult.size()){
			  %>
           
           
           <tr>
            <td colspan="2" height="18" align="right"><strong>Total Load Hours: &nbsp; &nbsp;</strong></td>
            <td class="thinborderTOP" align="right"><strong><%=CommonUtil.formatFloat(dUnit, 1)%> &nbsp; &nbsp;</strong></td>
           </tr>
           <%}%>
           <tr>
           	<td class="thinborderBottom" colspan="10">&nbsp; </td>
           </tr>
         </table>



<% 
	}//end outer loop


}//if vRetResult != null  %>

</body>
</html>
<%
dbOP.cleanUP();
%>