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
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector, java.util.Calendar" %>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);
	int iIndexOf = 0;
	int iAccessLevel = 0;
	int iDateFrom = 0;
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
Vector vEmpEduHist = new Vector();
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
		
	
	strTemp = " select degree_earned, sch_code, grad_year, major_name, minor_name "+
		" from HR_INFO_EDU_HIST "+ 
		" join HR_PRELOAD_SCHOOL on (HR_PRELOAD_SCHOOL.sch_index = hr_info_edu_hist.sch_index) "+
		" where is_valid = 1 and user_index = "+strEmployeeIndex;
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vEmpEduHist.addElement(rs.getString(1));//[0]degree_earned
		vEmpEduHist.addElement(rs.getString(2));//[1]sch_code
		vEmpEduHist.addElement(rs.getString(3));//[2]grad_year
		vEmpEduHist.addElement(rs.getString(4));//[3]major_name
		vEmpEduHist.addElement(rs.getString(5));//[4]minor_name
	}rs.close();
	
	//get the teaching years.
	//previous first.
	Vector vEmpHist = new Vector();
	strTemp = "select doe_ from hr_info_emp_hist where is_valid = 1 and user_index = "+strEmployeeIndex;
	rs = dbOP.executeQuery(strTemp);
	//i will get the year only	
	
	while(rs.next()){
		//check for the last index of '/'
		strTemp = WI.getStrValue(rs.getString(1));
		iIndexOf = strTemp.lastIndexOf("/");
		if( iIndexOf > -1){
			strTemp = strTemp.substring(iIndexOf + 1, strTemp.length());			
			//check if the length is 4. then its year
			if(strTemp.length() != 4)
				continue;		
		}else{
			if(strTemp.length() != 4)
				continue;	
		}
		if(iDateFrom == 0)
			iDateFrom = Integer.parseInt(strTemp);
		else{
			if(Integer.parseInt(strTemp) < iDateFrom)
				iDateFrom = Integer.parseInt(strTemp);
		}
	}rs.close();

	Calendar cal = Calendar.getInstance();
	//strTemp = Integer.toString(cal.get(Calendar.YEAR));
	//if no emp hist. then get the date of employment.
	if(iDateFrom == 0){
		strTemp = "select doe from info_faculty_basic where is_valid = 1 and user_index = "+strEmployeeIndex;
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()){
			strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1));
			iIndexOf = strTemp.lastIndexOf("/");
			if( iIndexOf > -1)
				strTemp = strTemp.substring(iIndexOf + 1, strTemp.length());		
		}rs.close();
		if(strTemp.length() == 4)
			iDateFrom = Integer.parseInt(strTemp);
	}	
	
		
	
	//get todays year - start of work as teacher
	if(iDateFrom > 0)
		iDateFrom = cal.get(Calendar.YEAR) - iDateFrom; 


	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
	if(vUserDetail == null){
		strErrMsg = FM.getErrMsg();
	}else {
		vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"));
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
		
	}
	
	
	
}else if (WI.fillTextValue("emp_id").length() > 0) {
	strErrMsg = " Invalid employee ID.";
}

String[] astrSemester={"Summer", "First Semester", "Second Semester","Third Semester"};

//end of authenticaion code.
%>
  
<table width="100%" border="0" bgcolor="#FFFFFF">
  <tr><td ><%=WI.getTodaysDateTime()%></td></tr>
  <tr>    
  	<% 
		if (WI.fillTextValue("semester").length() > 0) 
			strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))];
		else strTemp = "";
	%>
    <td align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
    		Class  Scheduling System<br>
       <%=WI.getStrValue(strTemp,"")%><%=", SY " + WI.fillTextValue("sy_from")  +" - " + WI.fillTextValue("sy_to")%>
		 </font>
      <br></td>
  </tr>  
</table>
<%   if(vUserDetail != null && vUserDetail.size() > 0){%>
  
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
      <td class="thinborderBottom">Total Units:</td>
      <td class="thinborderBottom"><strong><%=CommonUtil.formatFloat((String)vUserDetail.elementAt(6),true)%></strong></td>      
   </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
   	<td style="padding-left:15px;" width="18%" height="20">Degree/s</td>
      <td style="padding-left:15px;" width="24%">School/s</td>
      <td align="center" width="8%">Year</td>
      <td style="padding-left:15px;" width="17%">Major/s</td>
      <td style="padding-left:15px;" width="17%">Minor/s</td>
      <td width="16%"></td>
   </tr>
   
   <tr>
   	<td height="20" colspan="6">&nbsp;</td>
   </tr>
   
   
   <%if(vEmpEduHist!=null && vEmpEduHist.size() > 0){
   for(int i = 0; i < vEmpEduHist.size(); i+=5){
   	if(vEmpEduHist.elementAt(i) == null)
		continue;
   %>
   
   <tr>
   	<td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%; text-align:left;">
		<%=WI.getStrValue((String)vEmpEduHist.elementAt(i),"&nbsp;")%></div></td>
      <td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%; text-align:left;">
	  	<%=WI.getStrValue((String)vEmpEduHist.elementAt(i + 1),"&nbsp;")%></div></td>
      <td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%;">
	  	<%=WI.getStrValue((String)vEmpEduHist.elementAt(i + 2),"&nbsp;")%></div></td>
     <td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%; text-align:left;">
	 	<%=WI.getStrValue((String)vEmpEduHist.elementAt(i + 3),"&nbsp;")%></div></td>
      <td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%; text-align:left;">
	  	<%=WI.getStrValue((String)vEmpEduHist.elementAt(i + 4),"&nbsp;")%></div></td>
      <td>&nbsp;</td>
   </tr>
   
   <%}//end of looop
   
   }else{%>
   <tr>
   	<td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%;"></div></td>
      <td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%;"></div></td>
      <td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%;"></div></td>
     <td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%;"></div></td>
      <td height="20" valign="bottom" align="center"><div style="border-bottom:solid 1px #000000; width:90%;"></div></td>
      <td>&nbsp;</td>
   </tr>
   <%}%>
</table>  
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="20" colspan="2">Other specialized studies:</td></tr>
   <tr>
   	<td width="15%">&nbsp;</td>
      <td width="85%" class="thinborderBottom">&nbsp;</td>
   </tr>
   <tr>
   	<td>&nbsp;</td>
      <td class="thinborderBottom">&nbsp;</td>
   </tr>
</table>  

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
   	<td width="23%" height="20">Teaching Experience (No. of years)</td>
	<%
	strTemp = Integer.toString(iDateFrom);
	if(iDateFrom == 0)
		strTemp = "";
	%>
      <td width="46%"> : ___<u><%=strTemp%></u>___</td>
      <td width="13%">Rate per mo./hr.</td>
      <td width="18%"> : __________</td>
   </tr>
   <tr><td class="thinborderBottom" colspan="4">&nbsp;</td></tr>
</table>
<%}//end of vUserDetail. 
 
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
   	<td valign="top" height="500">
      	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
            <tr>
               <td width="11%" height="18"><u><strong>Schedule Code</strong></u></td>
               <td width="9%"><u><strong>Subject</strong></u></td>
               <td width="24%"><u><strong>Description</strong></u></td>
               <td width="4%"><u><strong>Unit</strong></u></td>
               <td width="5%"><u><strong>Day</strong></u></td>
               <td width="11%"><u><strong>Time</strong></u></td>
               <td width="5%"><u><strong>Room</strong></u></td>
               <td width="5%"><u><strong>Lec/Lab</strong></u></td>
               <td width="10%"><u><strong>Section</strong></u></td>
               <td width="7%"><u><strong>No. of Stud</strong></u></td>
               <td width="9%"><u><strong>With</strong></u></td>
            </tr>
         
           <%  
           double dUnit = 0d;
           for(int i = 0 ; i < vRetResult.size() ; i +=9){%>
           <tr> 
           <%
           strTemp = (String)vRetResult.elementAt(i + 4) + "-" + (String)vRetResult.elementAt(i);
           %>
             <td height="20" class=""><%=strTemp%></td>
             <td class=""><%=(String)vRetResult.elementAt(i)%></td>
             <td class=""><div><%=(String)vRetResult.elementAt(i + 1)%></div></td>
             <%
             strTemp = "LEC";
             if(((String)vRetResult.elementAt(i)).indexOf("LAB") > -1)
               strTemp = "LAB";
               
             if(((String)vRetResult.elementAt(i + 3)).startsWith("0.0"))
               strTemp = "LAB";
             
             dUnit += Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 8), "0"));
             %>
             <td class="" align="right"><%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(i + 8)), 1)%> &nbsp; &nbsp;</td>
             <%
            String strTemp2 = null;
             String strDays = null;
             String strTime = null;
             iIndexOf = 0;
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
           <%}%>
           <tr>
            <td colspan="3" height="18" align="right"><strong>Total Units : &nbsp; &nbsp;</strong></td>
            <td class="thinborderTOP" align="right"><strong><%=CommonUtil.formatFloat(dUnit, 1)%> &nbsp; &nbsp;</strong></td>
           </tr>
      </table>
      </td>
   </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
   	<td colspan="2" height="20">Recommended by:</td>
      <td colspan="2" height="20">Approved by:</td>
   </tr>
   
   <tr>
   	<td width="25%" height="40" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%">&nbsp;</div></td>
      <td width="25%" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%">&nbsp;</div></td>
      <td width="25%" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%">&nbsp;</div></td>
      <td width="25%" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%">&nbsp;</div></td>
   </tr>
   <tr>
   	<td align="center" valign="top">Vice President for Academic Affairs</td>
      <td align="center" valign="top">Department Dean</td>
      <td align="center" valign="top">President</td>
      <td align="center" valign="top">Instructor's Signature</td>
   </tr>
</table>

<% }//if vRetResult != null  %>

</body>
</html>
<%
dbOP.cleanUP();
%>