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
-->

div.skeds:nth-child(even) {
    background-color: #F3F3F3;
}
</style>


</head>
<body topmargin="0" onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector,java.util.Random" %>
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

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchoolCode == null)
	strSchoolCode = "";

Vector vRetResult = null;
Vector vRetSummaryLoad  = null; 
double dTotalLoadHour = 0d; 
double dTotalLoadUnit = 0d;

FacultyManagement FM = new FacultyManagement();


// for UI as of now..  any other request. please update on per school basis

int iMaxRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iMaxRows"),"15"));
int iRowsPrinted = 1;

boolean bolAllowLoadHour = true;
String strSubjSel = null;


Vector vUserDetail = null;
String strPTFT = null;
String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");


if(strEmployeeIndex != null) {
	
	if ( strSchoolCode.startsWith("UI")){
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
					WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","",""), true);
					
		
					
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

String strSQLQuery = "select group_name from subject_group join subject on (subject.group_index = subject_group.group_index) "+
						"where subject.is_del = 0 and sub_code = '";




boolean bolIsEAC = strSchoolCode.startsWith("EAC");

String[] astrSemester={"SUMMER", "FIRST", "SECOND","THIRD"};
String[] astrSem={"Summer", "1st Sem", "2nd Sem","3rd Sem"};


//here i have to find out how many hours per week.. 
double[] adWeekDayHour = {0d,0d,0d,0d,0d,0d,0d};//gets/sets total hours per weekday.
double[] adWeekDayTemp = {0d,0d,0d,0d,0d,0d,0d};//sets how many weekdays are in the MWF format.

double dTotalHour = 0d;//total hours per class.
int iNoOfDays     = 0;//how many times the class is in a week. to find
int iWeekDayPos   = 0; //0= monday, 1 = tuesday .. etc.

int iIndexOf = 0;

//end of authenticaion code.
if(strErrMsg != null){%>
<table width="100%">
  <tr> 
    <td height="25" colspan="2">&nbsp;&nbsp; <%=strErrMsg%></td>
  </tr>
</table>
<%} 


 if(vRetResult != null && vRetResult.size() > 0){
	  for (int i = 0; i< vRetResult.size();) { %>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>     
    <td align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
      <br></td>
  </tr>
</table>
<%  if(vUserDetail != null && vUserDetail.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      
    <td width="10%" height="20">Faculty </td>
      <td width="45%"><strong><%=((String)vUserDetail.elementAt(1)).toUpperCase()%>(<%=WI.fillTextValue("emp_id")%>)</strong></td>
      <td width="18%">Employment Status</td>
      <td width="27%"><strong>
	  <%if (!strSchoolCode.startsWith("UI")) {%> 
	  <%=(String)vUserDetail.elementAt(2)%>
	  <%}else{%>
	  <%=(String)vUserDetail.elementAt(2) + " : " + strPTFT%>
	  <%}%> 	  
	  </strong></td>
    </tr>
    <tr > 
      <td height="20">&nbsp;</td>
      <td>College</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(4))%></strong></td>
      <td>Employment Type</td>
      <td><strong><%=(String)vUserDetail.elementAt(7)%></strong></td>
    </tr>
    <tr > 
      <td height="20">&nbsp;</td>
      <td>Department</td>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(5),"N/A")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
</table>
<%}//end of vUserDetail.%>

<div style="text-align:right"><%=WI.getTodaysDateTime()%></div>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
<% if (strSchoolCode != null && strSchoolCode.startsWith("UI")) 
		strTemp = "TEACHING LOAD ASSIGNMENT";
	else
		strTemp = "TEACHING LOAD DETAILS";
%>
      <td height="20" colspan="3" align="center"><strong><%=strTemp%>
	  (<%="AY : " + WI.fillTextValue("sy_from")  +" - " + WI.fillTextValue("sy_to")%>
		 <% if (WI.fillTextValue("semester").length() > 0) 
		 		strTemp = astrSem[Integer.parseInt(WI.fillTextValue("semester"))];
			else strTemp = "";
		 %><%=WI.getStrValue(strTemp," , ","","")%>)
	  </strong></td>
    </tr>
<%//System.out.println("Dynamic : "+WI.fillTextValue("dynamic"));%>    <tr> 
      <td width="33%" height="25"><font size="1">TOTAL NO. OF SECTION : <strong><%=(String)vUserDetail.elementAt(8)%></strong></font></td>
      <td width="26%"> <font size="1">TOTAL UNITS :<strong><%=CommonUtil.formatFloat((String)vUserDetail.elementAt(6),true)%></strong></font></td>
      <td width="37%"><font size="1">TOTAL NO. OF HOURS/WEEK : <strong>
	  <%if(bolAllowLoadHour || WI.fillTextValue("dynamic").length() > 0){%>
	  	<%=CommonUtil.formatFloat(dTotalLoadHour,false)%><%}else{%>
	  <%=(String)vUserDetail.elementAt(9)%><%}%>
	  </strong></font></td>
    </tr>
  </table>
	

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<!------------------------MAIN TABLE----------------------------->
	<tr>		
		<td height="600" valign="top">
			<div style="border-bottom:1px solid #000000; border-top:1px solid #000000; font-weight:bold; padding:3px 0px 3px 0px;">	
				<div style="overflow:hidden; float:left; width:12%; margin:2px 0px 2px 0px;">CODE</div>
				<div style="overflow:hidden; float:left; width:32%; margin:2px 0px 2px 0px;">SUBJECT TITLE</div>
				<!-- <div style="overflow:hidden; float:left; width:15%; margin:2px 0px 2px 0px;">COLLEGE OFFERING</div> -->
				<div style="overflow:hidden;  float:left; width:12%; margin:2px 0px 2px 0px;">
				  <% if(strSchoolCode.startsWith("UI")){%>LOAD UNITS <%}else{%>LEC/LAB<%}%>
				</div>
				<div style="overflow:hidden; float:left; width:7%; margin:2px 0px 2px 0px;">			
					<%if(bolAllowLoadHour){%>HOURS<%}else{%>FACULTY LOAD<%}%>
				  </div>
				<div style="overflow:hidden; float:left; width:10%; margin:2px 0px 2px 0px;">SECTION</div>
				<div style="overflow:hidden; float:left; width:17%; margin:2px 0px 2px 0px;">SCHEDULE</div>
				<div style="overflow:hidden; float:left; width:5%; margin:2px 0px 2px 0px;  text-align:center;">ROOM</div>
				<div style="overflow:hidden; float:left; width:4%; margin:2px 0px 2px 0px; text-align:center;">#</div>
				<div style="clear:both"></div>			
			  </div>
	
			  <%
			  for(int k=0; i < vRetResult.size() ; i +=12,k++){
			  
			  	dTotalHour = Double.parseDouble((String)vRetResult.elementAt(i + 9));;
			  	iNoOfDays  = 0;
				adWeekDayTemp[0] = 0;adWeekDayTemp[1] = 0;adWeekDayTemp[2] = 0;adWeekDayTemp[3] = 0;adWeekDayTemp[4] = 0;adWeekDayTemp[5] = 0;adWeekDayTemp[6] = 0;
				strTemp = (String)vRetResult.elementAt(i + 6);
				String strOneChar = null;
				for(int q = 0; q < strTemp.length(); ++q) {
					strOneChar = String.valueOf(strTemp.charAt(q));
					if(strOneChar.equals("M")) {
						adWeekDayTemp[0] = 1;
						++iNoOfDays;
						continue;
					}
					if(strOneChar.equals("T") && !String.valueOf(strTemp.charAt(q + 1)).equals("H") ) {
						adWeekDayTemp[1] = 1;
						++iNoOfDays;
						continue;
					}
					if(strOneChar.equals("W")) {
						adWeekDayTemp[2] = 1;
						++iNoOfDays;
						continue;
					}
					if(strOneChar.equals("T")) {
						++q;
						adWeekDayTemp[3] = 1;
						++iNoOfDays;
						continue;
					}
					if(strOneChar.equals("F")) {
						adWeekDayTemp[4] = 1;
						++iNoOfDays;
						continue;
					}
					if(strOneChar.equals("S") && !String.valueOf(strTemp.charAt(q + 1)).equals("A")) {
						adWeekDayTemp[6] = 1;
						++iNoOfDays;
						continue;
					}
					if(strOneChar.equals("S")) {
						adWeekDayTemp[5] = 1;
						++iNoOfDays;
						q += 2;// this is SAT.
						continue;
					}
					iIndexOf = strTemp.indexOf("<br>");
					if(iIndexOf > 0) {
						strTemp = strTemp.substring(iIndexOf + 4);
						q = -1;
						continue;
					}
					
					break;
				}
				dTotalHour = dTotalHour/(double)iNoOfDays;
				for(int q = 0; q < 7; ++q) {
					if(adWeekDayTemp[q] == 1d)
						adWeekDayHour[q] += dTotalHour;
				}
				
				
			 
			 	if(WI.fillTextValue("subj_sel_"+k).equals("on")){
					
					if(strSubjSel == null)
						strSubjSel = (String)vRetResult.elementAt(i+4)+","+(String)vRetResult.elementAt(i+5);
					else	
						strSubjSel += ","+(String)vRetResult.elementAt(i+4)+","+(String)vRetResult.elementAt(i+5);		  
			  %>
			  
			 <div style="border-bottom:1px solid #000000;" class="skeds">	
				<div style="overflow:hidden; float:left; width:12%; margin:2px 0px 2px 0px;"><%=(String)vRetResult.elementAt(i)%></div>
				<div style="overflow:hidden; float:left; width:32%; margin:2px 5px 2px 0px;"><div style="white-space: nowrap; "><%=(String)vRetResult.elementAt(i + 1)%></div></div>
				<!-- <div style="overflow:hidden; float:left; width:15%; margin:2px 5px 2px 0px;"><div style="white-space: nowrap;"><%=(String)vRetResult.elementAt(i + 2)%>
				 <%=WI.getStrValue(dbOP.getResultOfAQuery(strSQLQuery+(String)vRetResult.elementAt(i)+"'", 0), "/ ", "","")%> </div></div> -->
				<div style="overflow:hidden;  float:left; width:12%; margin:2px 0px 2px 0px;">
				  <%if(strSchoolCode.startsWith("UI")){%><%=(String)vRetResult.elementAt(i + 8)%> <%}else{%><%=(String)vRetResult.elementAt(i + 3)%><%}%>    
				</div>
				<div style="overflow:hidden; float:left; width:7%; margin:2px 0px 2px 0px;">
				  <%if(bolAllowLoadHour){%>
					<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 9),false)%>
			<%}else{%><%=(String)vRetResult.elementAt(i + 8)%><%}%>
				  </div>
				<div style="overflow:hidden; float:left; width:10%; margin:2px 0px 2px 0px;"><%=(String)vRetResult.elementAt(i + 4)%></div>
				<div style="overflow:hidden; float:left; width:17%; margin:2px 0px 2px 0px;"><%=(String)vRetResult.elementAt(i + 6)%></div>
				<div style="overflow:hidden; float:left; width:5%; margin:2px 0px 2px 0px;  text-align:center;"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></div>
				<div style="overflow:hidden; float:left; width:4%; margin:2px 0px 2px 0px; text-align:center;"><%=(String)vRetResult.elementAt(i + 7)%></div>
				<div style="clear:both"></div>			
			  </div>
			  <%
			   iRowsPrinted++;
				   if (iRowsPrinted == iMaxRows + 1) {
						i += 12;
						break;
					}
					
			  }
			  
			  }%>	
			  
			
			<div align="center">
			<font style="font-weight:bold">
				MON: <%=adWeekDayHour[0]%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				TUE: <%=adWeekDayHour[1]%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				WED: <%=adWeekDayHour[2]%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				THU: <%=adWeekDayHour[3]%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				FRI: <%=adWeekDayHour[4]%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				SAT: <%=adWeekDayHour[5]%>
				&nbsp;&nbsp;&nbsp;&nbsp;
				SUN: <%=adWeekDayHour[6]%>
					
			</font>
			</div>
			
			<br><br><br><br>
					<div style="width:25%" align="center">
					<strong><font size="2"><%=(String)vUserDetail.elementAt(1)%></font></strong>
					<br>
					___________________________<br>
					Faculty Member's Signature
					</div>

		</td>		
	</tr>
	
	<!------------------------END MAIN TABLE----------------------------->	
	
	<!-------------------------- NO OF HOURS -------------------------------------->	
	
	<tr>		
		<td valign="top" colspan="7" height="50">
			<table width="100%" cellpadding="0" cellspacing="0">
		<%if (i< vRetResult.size()) {%>
			  
				<tr>
					<td height="25" colspan="10" align="center" class="thinborderNONE"> 
						<strong>********** Continued on Next Page</strong> ********** </td>
				</tr>  
			<%}else{%>
					
				<!-------------------- PRINT TOTAL NUMBER of HOURS for CDD ----------------------->
				<!--
				<tr>
					<td>MON:</td>
					<td>TUE:</td>
					<td>WED:</td>
					<td>THU:</td>
					<td>FRI:</td>
					<td>SAT:</td>
					<td>SUN:</td>
				</tr>				
				-->
			<%}%> 
			</table>
		</td>		
	</tr>
	
	<!-------------------------- END NO OF HOURS -------------------------------------->	
	
</table>

<!----------------FOOTER------------------------->

<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td valign="top" align="center" colspan="8" height="60"><strong><font size="2">- RECOMMENDING APPROVALS -</font></strong></td>		
	</tr>
	
	<tr>
		<td width="5%">&nbsp;</td>
		<td width="20%" height="50" style="border-top: solid 1px #000000;" align="center" valign="top">Dean/Department Head</td>
		<td width="5%">&nbsp;</td>
		<td width="20%" style="border-top: solid 1px #000000;" align="center" valign="top">Director for Academics</td>
		<td width="5%">&nbsp;</td>
		<td width="20%" style="border-top: solid 1px #000000;" align="center" valign="top">MIS Administrator</td>
		<td width="5%">&nbsp;</td>
		<td width="20%" style="border-top: solid 1px #000000;" align="center" valign="top">Finance Officer</td>
		<td width="5%">&nbsp;</td>
	</tr>
	
	<tr>
		<td width="5%">&nbsp;</td>
		<td colspan="3" height="50" valign="bottom">Noted By: <strong>FELIZA ARZADON-SUA, Ed.D</strong></td>		
		<td colspan="4" valign="bottom">Approved By: <strong>VOLTAIRE P. ARZADON, Ph.D, ScD</strong></td>		
	</tr>
	<tr>
		<td width="5%">&nbsp;</td>
		<td colspan="4" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VP-Administration/Student Affairs</td>		
		<td colspan="2" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; President</td>		
	</tr>
</table>



<%if (i< vRetResult.size()) { %>
	<DIV style="page-break-after:always" >&nbsp;</DIV>
<%  iRowsPrinted = 1; // reset rows printed to 1
   }
 } // end  outer for loop
}//if vRetResult != null%>

<!---- i need to page break here to print teacher schedule detail ----->
<%//if(false){%>

<DIV style="page-break-after:always" >&nbsp;</DIV>

<%
	
//FacultyManagement FM = new FacultyManagement();
vUserDetail = null;
vRetResult = null;
Vector vRetCISched = null;


//if ( WI.fillTextValue("show_list").compareTo("1") == 0) {
		strTemp = WI.fillTextValue("emp_id");
		
		if (strTemp.length() > 0)
		{
			strTemp = dbOP.mapOneToOther("USER_TABLE","ID_NUMBER","'" + strTemp+"'","user_index"," and is_del = 0");

			if ( strTemp != null) {
				vUserDetail = FM.viewFacultyDetail(dbOP,strTemp,WI.fillTextValue("sy_from"),
												WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
												
				if(vUserDetail == null)
					strErrMsg = FM.getErrMsg();
				else
				{
					vRetResult = FM.viewFacultyLoadDetail(dbOP,strTemp,WI.fillTextValue("sy_from"),
												WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
												
					//System.out.println("vRetResult "+vRetResult);
//					if(vRetResult == null) {
//						strErrMsg = FM.getErrMsg();
//					}
					
					vRetCISched = FM.operateOnFacultyLoadCI(dbOP,request,4);
//					if (vRetCISched	== null && strErrMsg == null ) 
//						strErrMsg = FM.getErrMsg();
				}
			}else{ 
				strErrMsg = " Please enter a valid faculty ID.";
			}
		}else{
			strErrMsg = " Please enter faculty ID.";
		}
	if(strErrMsg == null) strErrMsg = "";
//}

%>

<% if (vUserDetail != null) {%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="mid_level">
    <tr>
      <td height="25" colspan="3"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
	  <font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
 	  <font size ="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font></div></td>
    </tr>

    <tr> 
      <td width="4%" height="20">&nbsp;</td>
      <td width="50%">Employee Name : <%=(String)vUserDetail.elementAt(1)%></td>
	  <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td colspan="2"> College : <%=(String)vUserDetail.elementAt(4)%></td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td colspan="2"> Position : <%=(String)vUserDetail.elementAt(7)%></td>
    </tr>
	<tr> 
      <td height="20">&nbsp;</td>
      <td >Employment Status : <%=(String)vUserDetail.elementAt(2)%></td><br>
	  <td align="right">SEM : <%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%> SY : <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
    </tr>

  </table>  

<%
} // end vUserDetail != null

if(vRetResult != null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="700" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" >
				<!----------------------MAIN TABLE-------------------------->
				<tr>
					<td valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
							<tr bgcolor="#EBD6E6"> 
							  <td height="25" colspan="7" align="center" bgcolor="#FFE6E7" class="thinborder"><strong><font color="#0000FF">FACULTY LOAD/SCHEDULE 
								DETAIL</font></strong></td>
							</tr>
							<tr> 
							  <td align="center" class="thinborder"><strong>MONDAY</strong></td>
							  <td align="center" class="thinborder"><strong>TUESDAY</strong></td>
							  <td align="center" class="thinborder"><strong>WEDNESDAY</strong></td>
							  <td align="center" class="thinborder"><strong>THURSDAY</strong></td>
							  <td align="center" class="thinborder"><strong>FRIDAY</strong></td>
							  <td height="25" align="center" class="thinborder"><strong>SATURDAY</strong></td>
							  <td align="center" class="thinborder"><strong>SUNDAY</strong></td>
							</tr>
						<%
						String[] convertAMPM={" AM"," PM"};//System.out.println(vRetResult);	
						
						String strColorCode = null;
												
						Vector vSubject   = new Vector();
						Vector vColorCode = new Vector();
						
						Random rand = new Random(); 
						int red = 0;
						int green = 0;
						int blue = 0;
						
						//if(FM.vCollegeOffered != null && FM.vCollegeOffered.size() > 0) {
							strSQLQuery = "select c_index, color_ from college where is_del = 0";
							Vector vTempC = new Vector();
							java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
							while(rs.next()) {
								vTempC.addElement(rs.getString(1));
								vTempC.addElement(rs.getString(2));
							}
							rs.close();
							
							for(int i=0,j=0; i< vRetResult.size();i+=14,j++){
								if( (i + 13) == vRetResult.size())
									vRetResult.addElement(vTempC.elementAt(vTempC.indexOf(FM.vCollegeOffered.elementAt(j)) + 1));
								else	
									vRetResult.insertElementAt(vTempC.elementAt(vTempC.indexOf(FM.vCollegeOffered.elementAt(j)) + 1), i + 13);
							}
						//}
						
						
						for(int i=0,j=1; i< vRetResult.size();i+=14,j++){						
							red = rand.nextInt(128)+128; 
							green = rand.nextInt(128)+128; 
							blue = rand.nextInt(128)+128; 
							
							//if color is black need to random again.					
							if(red ==0 && green ==0 && blue ==0){								
								red = rand.nextInt(128)+128; 
								green = rand.nextInt(128)+128; 
								blue = rand.nextInt(128)+128; 						
							}else{
							
								iIndexOf = vSubject.indexOf(vRetResult.elementAt(i+7));
								if(iIndexOf == -1){
																								
								 	String strColor = Integer.toHexString(red)+""+Integer.toHexString(green)+""+Integer.toHexString(blue);
									
									 vSubject.addElement((String)vRetResult.elementAt(i+7));
									 vColorCode.addElement(strColor);
								 }else
								 	continue;
							}								
						}
						
						iIndexOf = 0;
						Vector vSubjSel = new Vector();
						if(strSubjSel != null)
							vSubjSel = CommonUtil.convertCSVToVector(strSubjSel, ",", true);	
							
						int iIndexSection = 0;
						int iIndexRoom = 0;
						
						for(int i = 0; i< vRetResult.size();){
							
													
						%>
						
							<tr> 
							  <%strTemp = "";
							  	strColorCode = "";
								
								  while( vRetResult.size() > 0 && ((String)vRetResult.elementAt(i)).compareTo("1") ==0) //this is monday
								  {
								  //checking for selected subject
								  	iIndexSection = vSubjSel.indexOf(vRetResult.elementAt(i+7));
   						    		iIndexRoom   = vSubjSel.indexOf(vRetResult.elementAt(i+8));								  	
								  
								  if(iIndexSection >= 0 && iIndexRoom  >= 0){
										  if(strTemp.length() > 0)
											 strTemp += "<br>";						
											
										  strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
													(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
													convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
													":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
													(String)vRetResult.elementAt(i+7)+"<br> Room: "+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj: "+
													(String)vRetResult.elementAt(i+10);										
											
											
											iIndexOf = vSubject.indexOf(vRetResult.elementAt(i+7));																								
											if(iIndexOf >= 0 && strTemp.length() >0)
												strColorCode = "bgcolor=#"+(String)vColorCode.elementAt(iIndexOf);
											if(vRetResult.elementAt(i + 13) != null)
												strColorCode = "bgcolor=#"+(String)vRetResult.elementAt(i + 13);
									}	
											
										vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
										vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
										vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
										vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									
								}//end while%>													
							  <td <%=strColorCode%> height="25" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
							  
							  
							  <%strTemp = ""; 
							  	strColorCode = "";
								
								  while( vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("2") ==0) //this is Tuesday
								  {
								  //checking for selected subject
								  iIndexSection = vSubjSel.indexOf(vRetResult.elementAt(i+7));
								  iIndexRoom   = vSubjSel.indexOf(vRetResult.elementAt(i+8));
								 
								  if(iIndexSection >= 0 && iIndexRoom  >= 0){								  
									  if(strTemp.length() > 0) 
										strTemp += "<br>";
									  
										strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
												(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
												convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
												":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
												(String)vRetResult.elementAt(i+7)+"<br> Room: "+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj: "+
													(String)vRetResult.elementAt(i+10);										
										
										
										iIndexOf = vSubject.indexOf(vRetResult.elementAt(i+7));																								
										if(iIndexOf >= 0 && strTemp.length() >0)
											strColorCode = "bgcolor=#"+(String)vColorCode.elementAt(iIndexOf);
										if(vRetResult.elementAt(i + 13) != null)
											strColorCode = "bgcolor=#"+(String)vRetResult.elementAt(i + 13);
									}	
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									
								}//end while%>														
							  <td <%=strColorCode%>  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
							  
							  
							  <%strTemp = ""; 
							  	strColorCode = "";
								
								  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("3") ==0) //this is Wednesday
								  {
								  //checking for selected subject
								  iIndexSection = vSubjSel.indexOf(vRetResult.elementAt(i+7));
								  iIndexRoom   = vSubjSel.indexOf(vRetResult.elementAt(i+8));
								  
								  if(iIndexSection >= 0 && iIndexRoom  >= 0){								  
									  if(strTemp.length() > 0) 
										strTemp += "<br>";
										
									   strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
												(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
												convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
												":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
												(String)vRetResult.elementAt(i+7)+"<br> Room: "+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj: "+
													(String)vRetResult.elementAt(i+10);										
										
										iIndexOf = vSubject.indexOf(vRetResult.elementAt(i+7));																								
										if(iIndexOf >= 0 && strTemp.length() >0)
											strColorCode = "bgcolor=#"+(String)vColorCode.elementAt(iIndexOf);					
										if(vRetResult.elementAt(i + 13) != null)
											strColorCode = "bgcolor=#"+(String)vRetResult.elementAt(i + 13);
									}	
										vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
										vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
										vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
										vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									
								}//end while%>								
							  <td <%=strColorCode%>  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
							  
							  
							  <%strTemp = ""; 
							  	strColorCode = "";
							  	
								  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("4") ==0) //this is Thursday
								  {
								  //checking for selected subject
								  iIndexSection = vSubjSel.indexOf(vRetResult.elementAt(i+7));
								  iIndexRoom   = vSubjSel.indexOf(vRetResult.elementAt(i+8));
								
								  if(iIndexSection >= 0 && iIndexRoom  >= 0){									
									  if(strTemp.length() > 0) 
										strTemp += "<br>";
										
										strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
												(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
												convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
												":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
												(String)vRetResult.elementAt(i+7)+"<br> Room: "+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj: "+
													(String)vRetResult.elementAt(i+10);										
											
										iIndexOf = vSubject.indexOf(vRetResult.elementAt(i+7));																								
										if(iIndexOf >= 0 && strTemp.length() >0)
											strColorCode = "bgcolor=#"+(String)vColorCode.elementAt(iIndexOf);
										if(vRetResult.elementAt(i + 13) != null)
											strColorCode = "bgcolor=#"+(String)vRetResult.elementAt(i + 13);
									}			
																											
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);			
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									
								}//end while%>								
							  <td <%=strColorCode%>  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
							  
							  
							  <%strTemp = ""; 
							  	strColorCode = "";
								 
								  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("5") ==0) //this is Friday
								  {
								 	//checking for selected subject
								  iIndexSection = vSubjSel.indexOf(vRetResult.elementAt(i+7));
								  iIndexRoom   = vSubjSel.indexOf(vRetResult.elementAt(i+8));
								 
								  if(iIndexSection >= 0 && iIndexRoom  >= 0){
									  if(strTemp.length() > 0) 
										strTemp += "<br>";
										
										strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
												(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
												convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
												":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
												(String)vRetResult.elementAt(i+7)+"<br> Room: "+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj: "+
													(String)vRetResult.elementAt(i+10);										
										
								  
										iIndexOf = vSubject.indexOf(vRetResult.elementAt(i+7));																								
										if(iIndexOf >= 0 && strTemp.length() >0)
											strColorCode = "bgcolor=#"+(String)vColorCode.elementAt(iIndexOf);
								
										if(vRetResult.elementAt(i + 13) != null)
											strColorCode = "bgcolor=#"+(String)vRetResult.elementAt(i + 13);
									}							
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									
								}//end while%>
									
								
							  <td <%=strColorCode%>  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
							  
							  
							  <%strTemp = ""; 
							  	strColorCode = "";
								
								  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("6") ==0) //this is Saturday
								  {	
								  //checking for selected subject
								  iIndexSection = vSubjSel.indexOf(vRetResult.elementAt(i+7));
								  iIndexRoom   = vSubjSel.indexOf(vRetResult.elementAt(i+8));
								  
								  if(iIndexSection >= 0 && iIndexRoom  >= 0){																		
									  if(strTemp.length() > 0) 
										strTemp += "<br>";
										
										strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
												(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
												convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
												":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
												(String)vRetResult.elementAt(i+7)+"<br> Room: "+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj: "+
													(String)vRetResult.elementAt(i+10);										
										
										iIndexOf = vSubject.indexOf(vRetResult.elementAt(i+7));																								
										if(iIndexOf >= 0 && strTemp.length() >0)
											strColorCode = "bgcolor=#"+(String)vColorCode.elementAt(iIndexOf);
										if(vRetResult.elementAt(i + 13) != null)
											strColorCode = "bgcolor=#"+(String)vRetResult.elementAt(i + 13);
									}										
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									
								}//end while%>
								
								
							  <td <%=strColorCode%>  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
							  
							  
							  <%strTemp = ""; 
							  	strColorCode = "";
								
								  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("0") ==0) //this is Sunday
								  {
								  //checking for selected subject
								  iIndexSection = vSubjSel.indexOf(vRetResult.elementAt(i+7));
								  iIndexRoom   = vSubjSel.indexOf(vRetResult.elementAt(i+8));
								 
								  if(iIndexSection >= 0 && iIndexRoom  >= 0){									
									  if(strTemp.length() > 0) 
										strTemp += "<br>";
										
										strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
												(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
												convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
												":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
												(String)vRetResult.elementAt(i+7)+"<br> Room: "+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subj: "+
													(String)vRetResult.elementAt(i+10);										
										
										iIndexOf = vSubject.indexOf(vRetResult.elementAt(i+7));																								
										if(iIndexOf >= 0 && strTemp.length() >0)
											strColorCode = "bgcolor=#"+(String)vColorCode.elementAt(iIndexOf);										
										if(vRetResult.elementAt(i + 13) != null)
											strColorCode = "bgcolor=#"+(String)vRetResult.elementAt(i + 13);
									}	
																		
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
									
								}//end while%>															
							  <td <%=strColorCode%>  class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
							  
							</tr>
							
							<%}%>
						  </table>
					</td>
				</tr>
				<!----------------------END MAIN TABLE-------------------------->
				
				<!-------------------------- NO OF HOURS -------------------------------------->	
				
				<tr>		
					<td valign="top" colspan="7">
						<table width="100%" cellpadding="0" cellspacing="0">		
							<tr><td colspan="7" height="30">&nbsp;</td></tr>
							<!-------------------- PRINT TOTAL NUMBER of HOURS for CDD ----------------------->
							<tr><td height="25" valign="bottom" colspan="7" align="right"><strong>Total Number of Hours Per Week : &nbsp; 
								<%if(bolAllowLoadHour || WI.fillTextValue("dynamic").length() > 0){%>
								<%=CommonUtil.formatFloat(dTotalLoadHour,false)%><%}else{%>
								<%=(String)vUserDetail.elementAt(9)%><%}%></strong>
								</td>
							</tr>	
							<tr><td height="50" valign="bottom" colspan="7"><strong><font size="2"><%=(String)vUserDetail.elementAt(1)%></font></strong></td></tr>	
							<tr><td colspan="7">Faculty Member's Signature</td></tr>			
							
						
						</table>
					</td>		
				</tr>	
				<!-------------------------- END NO OF HOURS -------------------------------------->		
			</table>
		</td>
	</tr>
</table>
			
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td valign="top" align="center" colspan="8" height="40"><strong><font size="2">- RECOMMENDING APPROVALS -</font></strong></td>		
				</tr>
				
				<tr>
					<td width="5%">&nbsp;</td>
					<td width="20%" height="40" style="border-top: solid 1px #000000;" align="center" valign="top">Dean/Department Head</td>
					<td width="5%">&nbsp;</td>
					<td width="20%" style="border-top: solid 1px #000000;" align="center" valign="top">Director for Academics</td>
					<td width="5%">&nbsp;</td>
					<td width="20%" style="border-top: solid 1px #000000;" align="center" valign="top">MIS Administrator</td>
					<td width="5%">&nbsp;</td>
					<td width="20%" style="border-top: solid 1px #000000;" align="center" valign="top">Finance Officer</td>
					<td width="5%">&nbsp;</td>
				</tr>
				
				<tr>
					<td width="5%">&nbsp;</td>
					<td colspan="3" height="30" valign="bottom">Noted By: <strong>FELIZA ARZADON-SUA, Ed.D</strong></td>		
					<td colspan="4" valign="bottom">Approved By: <strong>VOLTAIRE P. ARZADON, Ph.D, ScD</strong></td>		
				</tr>
				<tr>
					<td width="5%">&nbsp;</td>
					<td colspan="4" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; VP-Administration/Student Affairs</td>		
					<td colspan="2" align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; President</td>		
				</tr>
			</table>
			







<%}
//}if false%>







<input type="hidden" name="show_list" value="0"> 



</body>
</html>
<%
dbOP.cleanUP();
%>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        