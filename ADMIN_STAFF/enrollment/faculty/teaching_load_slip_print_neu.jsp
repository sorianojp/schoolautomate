<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");

if (strSchoolCode == null) {%>
	<p style="font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:14px;">You are already logged out. Please login again.
<%return;
}



if(strSchoolCode.startsWith("UB")){%>
	<jsp:forward page="./teaching_load_slip_print_ub.jsp" />
<%}

if(strSchoolCode.startsWith("CDD")){%>
	<jsp:forward page="./teaching_load_slip_print_cdd.jsp" />
<%}
if(strSchoolCode.startsWith("SWU")){%>
	<jsp:forward page="./teaching_load_slip_print_swu.jsp" />
<%}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>teaching load slip</title>
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
	font-size: 10px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }	
    TD.thinborderTop {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
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
	java.sql.ResultSet rs = null;

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
Vector vRetSummaryLoad  = null; double dTotalLoadHour = 0d; double dTotalLoadUnit = 0d;

FacultyManagement FM = new FacultyManagement();


// for UI as of now..  any other request. please update on per school basis

int iMaxRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iMaxRows"),"15"));
int iRowsPrinted = 1;

boolean bolAllowLoadHour = true;

Vector vUserDetail = null;
String strPTFT = null;
String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");

String strTotUnits = null;
String strTotHours = null;
int iElemCount =0;
if(strEmployeeIndex != null) {
	
	/*if ( strSchoolCode.startsWith("UI") || strSchoolCode.startsWith("UB")){
		strPTFT = dbOP.mapOneToOther("INFO_FACULTY_BASIC","user_index", strEmployeeIndex, "PT_FT", 
									" and is_del = 0" );
		if (strPTFT == null || strPTFT.equals("0")) {	
			strPTFT = "Part Time";
		}else{
			strPTFT = "Full Time";
		}
	}*/

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
		else{
			iElemCount = FM.getElemCount();
			strTotHours = FM.strTotalFacLoadHours;
			strTotUnits = FM.strTotalFacLoadUnits;
		}
		/*if (bolAllowLoadHour || WI.fillTextValue("dynamic").length() > 0) {
			vRetSummaryLoad = FM.getFacultySummaryLoadCollege(dbOP,request);
			if ( vRetSummaryLoad == null) 
				strErrMsg =  FM.getErrMsg();
			else {//get total number of hours. 
				for (int i= 0; i < vRetSummaryLoad.size() ; i+=8)
					dTotalLoadHour += Double.parseDouble((String)vRetSummaryLoad.elementAt(i + 7));
			}
		}*/
	}
}


boolean bolIsEAC = strSchoolCode.startsWith("EAC");

String[] astrSemester={"Summer", "1st Sem", "2nd Sem","3rd Sem"};
//end of authenticaion code.
if(strErrMsg != null){%>
<table width="100%">
  <tr> 
    <td height="25" colspan="2">&nbsp;&nbsp; <%=strErrMsg%></td>
  </tr>
</table>
<%} 


strTemp = " select specific_date from FA_FEE_ADJ_ENROLLMENT where sy_from = "+WI.fillTextValue("sy_from")+
		" and semester = "+WI.fillTextValue("semester")+
		" and is_valid =1 and ADJ_PARAMETER = 6";
rs= dbOP.executeQuery(strTemp);
String strStartClass = null;
if(rs.next())
	strStartClass = ConversionTable.convertMMDDYYYY(rs.getDate(1));
rs.close();

String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};



if(vRetResult != null && vRetResult.size() > 0){
	for (int i = 0; i< vRetResult.size();) { %>



<%  if(vUserDetail != null && vUserDetail.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td colspan="2" height="55" valign="top" align="right"><%=WI.getTodaysDate(1)%> <%=WI.formatDateTime(Long.parseLong(WI.getTodaysDate(28)),3)%></td></tr>
	<tr><td align="center" style="padding-left:25px;"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></td>
	<td align="center"><%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	    <td height="35">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2">&nbsp;</td>
    </tr>
	<tr>
		<td height="25" width="12%">&nbsp;</td>
		<td width="57%"><%=((String)vUserDetail.elementAt(1)).toUpperCase()%>(<%=WI.fillTextValue("emp_id")%>)</td>
		<td colspan="2" style="padding-left:35px;"><%=WI.getStrValue(vUserDetail.elementAt(4),WI.getStrValue(vUserDetail.elementAt(5)))%></td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
		<%
		strTemp = "select CON_ADDRESS, TEL_NO from INFO_FACULTY_BASIC where USER_INDEX = "+strEmployeeIndex;
		rs = dbOP.executeQuery(strTemp);
		strTemp = null;
		strErrMsg = null;
		if(rs.next()){
			strTemp = rs.getString(1);
			strErrMsg = rs.getString(2);
		}rs.close();
		%>
	    <td colspan="2"><%=WI.getStrValue(WI.getStrValue(strTemp).toUpperCase(),"&nbsp;")%></td>
	    <td width="21%"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
	</tr>
</table>


<%}//end of vUserDetail.%>
  
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="">
  <tr>
		<td width="14%" height="18" rowspan="2" align="center"><!--Subject--></td>
		<td align="center" rowspan="2" width="19%"><!--Sec--></td>		
		<td align="center" rowspan="2" width="9%">&nbsp;</td>
		<td align="center" rowspan="2" width="18%"><!--Time--></td>
		<td align="center" width="8%" rowspan="2"><!--Room No--></td>
		<td align="center" width="5%" rowspan="2"><!--Class Size--></td>
		<td align="center" width="5%" rowspan="2"><!--Units--></td>
		<td align="center" colspan="2" height="25"><!--No of Hours--></td>
		<td align="center" rowspan="2" width="12%"><!--Date Of Efec--></td>
	</tr>
	<tr>
		<td align="center" width="5%" height="18"><!--LEC--></td>
		<td align="center" width="5%"><!--LAB--></td>
	</tr>
  <%
for(; i < vRetResult.size() ; i +=iElemCount){%>
  <tr>
  	<%
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 1));
	if(strTemp.length() > 25)
		strTemp = strTemp.substring(0,25);
	
	%>
	<td valign="top" style="font-size:10px;" height="22"><%=(String)vRetResult.elementAt(i)%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"(",")","")%></td>
	<td height="22" valign="top" style="font-size:10px;"><%=strTemp%></td>
	<td height="22" valign="top" style="font-size:10px;"><%=(String)vRetResult.elementAt(i + 4)%></td>
	<td valign="top" style="font-size:10px;" width="18%"><%=(String)vRetResult.elementAt(i + 6)%></td>
	<td valign="top" style="font-size:10px;" width="8%"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></td>
	<td valign="top" style="font-size:10px;" align="center" width="5%"><%=(String)vRetResult.elementAt(i + 7)%></td>
	<td valign="top" style="font-size:10px;" align="center" width="5%"><%=(String)vRetResult.elementAt(i + 3)%></td>
	<%
	strTemp = (String)vRetResult.elementAt(i + 11);
	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i + 9);	
	strTemp = 	CommonUtil.formatFloat(strTemp,false);
	
	
	if(vRetResult.elementAt(i + 13) != null)
		strTemp = (String)vRetResult.elementAt(i + 13);
	
	%>
	<td valign="top" style="font-size:10px;" align="center" height="25" colspan="2"><%=strTemp%></td>
	<%
		strTemp = (String)vRetResult.elementAt(i+12);
	  if(strTemp == null || strTemp.length() == 0)
		strTemp = strStartClass;
	%>
	<td valign="top" style="font-size:10px;" width="12%"><%=WI.getStrValue(strTemp,"NA")%></td>
</tr>
  
  <%
   iRowsPrinted++;
	   if (iRowsPrinted == iMaxRows + 1) {
			i += iElemCount;
			break;
		}
  }
 
  if (i< vRetResult.size()) {
  %>
  <tr>
    <td height="25" colspan="10" align="center" class="thinborderNONE"> <strong>********** Continued on Next Page</strong> ********** </td>
  </tr>
  <%}else{%>
  <tr>
      <td valign="top" style="font-size:10px;" height="22">&nbsp;</td>
      <td height="22" valign="top" style="font-size:10px;">&nbsp;</td>
      <td height="22" valign="top" style="font-size:10px;">&nbsp;</td>
      <td valign="top" style="font-size:10px;">&nbsp;</td>
      <td valign="top" style="font-size:10px;">&nbsp;</td>
      <td valign="top" style="font-size:10px;" align="center">&nbsp;</td>	 
      <td valign="top" style="font-size:10px;" align="center"><%=WI.getStrValue(strTotUnits)%></td>
      <td valign="top" style="font-size:10px;" align="center" height="25" colspan="2"><%=WI.getStrValue(strTotHours)%></td>
      <td valign="top" style="font-size:10px;">&nbsp;</td>
  </tr> 
  <%}%>
</table> 
<%if (i< vRetResult.size()) { %>
	<DIV style="page-break-after:always" >&nbsp;</DIV>
<%  iRowsPrinted = 1; // reset rows printed to 1
   }
 } // end  outer for loop
%>



 <!-- signatory -- different for different schools.-->

 
  
<%
}//if vRetResult != null%>
</body>
</html>
<%
dbOP.cleanUP();
%>