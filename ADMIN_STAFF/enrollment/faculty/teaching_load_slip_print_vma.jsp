<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchoolCode == null) {%>
	<p style="font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px;">You are already logged out. Please login again.
<%return;
}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>teaching load slip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
 div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:50;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }

body {
	font-family: "Times New Roman";
	font-size: 12px;
}

td {
	font-family: "Times New Roman";
	font-size: 12px;
}

th {
	font-family: "Times New Roman";
	font-size: 12px;
}

.bodystyle {
	font-family: "Times New Roman";
	font-size: 12px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 12px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 12px;
    }
    TD.thinborderNONE {
	font-family: "Times New Roman";
	font-size: 12px;
    }
    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 12px;
    }	
    TD.thinborderTop {
    border-top: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 12px;
    }	
-->
</style>

</head>
<body topmargin="0" onLoad="window.print();">
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
Vector vRetSummaryLoad  = null; 
double dTotalLoadHour = 0d; 
double dTotalLoadUnit = 0d;

FacultyManagement FM = new FacultyManagement();


// for UI as of now..  any other request. please update on per school basis

int iMaxRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iMaxRows"),"15"));
int iRowsPrinted = 0;



boolean bolAllowLoadHour = true;

Vector vUserDetail = null;
String strPTFT = null;
String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");


if(strEmployeeIndex != null) {
	
	if ( strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("UB")){
		strPTFT = dbOP.mapOneToOther("INFO_FACULTY_BASIC","user_index", strEmployeeIndex, "PT_FT", 
									" and is_del = 0" );
		if (strPTFT == null || strPTFT.equals("0")) {	
			strPTFT = "Part Time";
		}else{
			strPTFT = "Full Time";
		}
	}

	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"),
					WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","",""));
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
	else {//System.out.println("Print : "+vUserDetail);
	
		vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"),
					WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","",""), true, true);
					
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
		
		if (bolAllowLoadHour || WI.fillTextValue("dynamic").length() > 0) {
			vRetSummaryLoad = FM.getFacultySummaryLoadCollege(dbOP,request);
			if ( vRetSummaryLoad == null) 
				strErrMsg =  FM.getErrMsg();
			else {//get total number of hours. 
				for (int i= 0; i < vRetSummaryLoad.size() ; i+=8)
					dTotalLoadHour += Double.parseDouble((String)vRetSummaryLoad.elementAt(i + 7));
			}
		}
	}
}


boolean bolIsEAC = strSchoolCode.startsWith("EAC");

String[] astrSemester={"Summer", "1<sup>st</sup> Semester", "2<sup>nd</sup> Semester","3<sup>rd</sup> Semester","4<sup>th</sup> Semester"};
//end of authenticaion code.
if(strErrMsg != null){%>
<table width="100%">
  <tr> 
    <td height="25" colspan="2">&nbsp;&nbsp; <%=strErrMsg%></td>
  </tr>
</table>
<%} 

String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAddr1 = SchoolInformation.getAddressLine1(dbOP, false, false);
String strSchAddr2 = SchoolInformation.getAddressLine2(dbOP, false, false);

String strDays = null;
String strTime = null;
int iIndexOf = 0;
double dTotalHours = 0d;

	strSchName += "<br>"+strSchAddr1+"<br>"+strSchAddr2;

 if(vRetResult != null && vRetResult.size() > 0){
	  for (int i = 0; i< vRetResult.size();) { 
	  
 if(vUserDetail != null && vUserDetail.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center" height="25"><strong style="font:Arial; font-size:14px;"><%=strSchName%></strong>
	<br>&nbsp;<br>&nbsp;<br><strong>TENTATIVE / FINAL TEACHING LOAD
	<br><%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></strong><br>&nbsp;</td></tr>
</table>


<%}//end of vUserDetail.%>


	
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  	<tr style="font-weight:bold;">
		<td width="16%" align="center" valign="top" class="thinborder">SUBJECT</td>
		<td width="22%" align="center" valign="top" class="thinborder">COURSE<br>
	    YEAR<br>SECTION</td>
		<td width="13%" align="center" valign="top" class="thinborder">DAYS</td>
		<td width="21%" align="center" valign="top" class="thinborder">TIME</td>
		<td width="7%" align="center" valign="top" class="thinborder">ROOM</td>
		<td width="13%" align="center" valign="top" class="thinborder">HRS/WEEK</td>
		<td width="8%" align="center" valign="top" class="thinborder">NO. OF<br>
	    STUDENTS</td>
	</tr>

  <%
for(; i < vRetResult.size() ; i +=12){
	strDays = null;
	strTime = null;
	iIndexOf = 0;
	strErrMsg = (String)vRetResult.elementAt(i + 6);
	if(strErrMsg != null) {
		Vector vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);
		while(vTemp.size() > 0) {
			strErrMsg = (String)vTemp.remove(0);
			iIndexOf = strErrMsg.indexOf(" ");
			if(iIndexOf > -1){						
			   if(strDays == null)
				   strDays = strErrMsg.substring(0, iIndexOf);
			   else
				   strDays += "<br>"+strErrMsg.substring(0, iIndexOf);
			   if(strTime == null)
				   strTime = strErrMsg.substring(iIndexOf + 1).toLowerCase();
			   else
				   strTime += "<br>"+strErrMsg.substring(iIndexOf + 1).toLowerCase();					
			   }					
		   }
	   }
%>
	
	<tr>
	    <td height="20" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(strDays,"Not Set")%></td>
	    <td class="thinborder"><%=WI.getStrValue(strTime,"Not Set")%></td>
	    <td class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
		<%
		try{
			dTotalHours += Double.parseDouble((String)vRetResult.elementAt(i + 9));
			
		}catch(Exception e){}
		%>
	    <td class="thinborder" align="center"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 9),false)%></td>
	    <td class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
    </tr>

  <!--<tr> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder" align="center">&nbsp; 
      <%if(strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("WUP")){%><%=(String)vRetResult.elementAt(i + 8)%> <%}else{%><%=(String)vRetResult.elementAt(i + 3)%><%}%>    </td>
    <td class="thinborder"><div align="center">
      <%if(bolAllowLoadHour){%>
        <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 9),false)%>
<%}else{%><%=(String)vRetResult.elementAt(i + 8)%><%}%>
      </div></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
<%if(!bolIsEAC) {%>
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>-->
  <%

	   if (++iRowsPrinted > iMaxRows) {
			i += 12;
			break;
		}
  }
 
  if (i< vRetResult.size()) {
  %>
</table>
  <table width="100%" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" colspan="10" align="center" class="thinborderNONE"> <strong>********** Continued on Next Page</strong> ********** </td>
  </tr>  
<%}%> 
</table>
<%if (i< vRetResult.size()) { %>
	<DIV style="page-break-after:always" >&nbsp;</DIV>
<%  iRowsPrinted = 0; // reset rows printed to 1
   }
 } // end  outer for loop
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="20" colspan="7" align="right">TOTAL No. of Hours = &nbsp;</td>
	    <td width="13%" valign="bottom" class="thinborderBottom" align="center"><%=CommonUtil.formatFloat(dTotalHours,false)%></td>
	    <td width="8%" align="right">&nbsp;</td>
	</tr>
	<tr>
		<td width="10%" valign="bottom" align="center">&nbsp;</td>
	    <td height="35" colspan="2" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
        <td width="11%" valign="bottom" align="center">&nbsp;</td>
        
        <td width="22%" align="right" valign="bottom" style="padding-right:10px;">Received by:</td>
	    <td colspan="3" align="center"  valign="bottom"><div style="border-bottom:solid 1px #000000;"></div></td>
	   
	    <td align="center"  valign="bottom">&nbsp;</td>
	</tr>
	
	<tr>
	    <td valign="bottom" align="center">&nbsp;</td>
	    <td colspan="2" align="center" valign="bottom"><strong>INSTRUCTOR</strong></td>
	    <td colspan="2" align="center" valign="bottom">&nbsp;</td>
	    <td colspan="3" align="center"  valign="bottom"><strong>(Dean’s Office)</strong></td>
	    <td align="center"  valign="bottom">&nbsp;</td>
    </tr>
	<tr>
		<td height="35" align="right" valign="bottom">&nbsp;</td>
	    <td width="10%" height="35" align="left" valign="bottom">Approved by</td>
	    
	    <td width="17%" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
	    <td valign="bottom" align="center">&nbsp;</td>
	    <td colspan="2" valign="bottom" align="right" style="padding-right:10px;">Assessed by/Received by:</td>
	    <td colspan="2" align="center"  valign="bottom"><div style="border-bottom:solid 1px #000000;"></div></td>
	    <td align="center"  valign="bottom">&nbsp;</td>
    </tr>
	<tr>
	    <td colspan="6" align="center" valign="bottom">&nbsp;</td>
	    <td colspan="2" align="center"  valign="bottom">Accounting Office</td>
	    <td align="center"  valign="bottom">&nbsp;</td>
    </tr>
</table>


<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>Form ID.</td>
		<td>: Deans 0007</td>
	</tr>
	<tr>
		<td>Rev. No.</td>
		<td>: 03</td>
	</tr>
	<tr>
		<td>Rev. Date</td>
		<td>: 11/06/12</td>
	</tr>
</table>
</div>

 <!-- signatory -- different for different schools.-->
<%
}//if vRetResult != null%>
</body>
</html>
<%
dbOP.cleanUP();
%>