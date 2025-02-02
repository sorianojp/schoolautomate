<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
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

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TABLE.thinborderTOPRIGHTBOTTOM {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	 
	TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.thinborderRIGHTLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	 
	 TD.thinborderTOPBOTTOM {

    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	 
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
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

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchoolCode == null)
	strSchoolCode = "";

Vector vRetResult = null;
Vector vRetSummaryLoad  = null; 

String strCollegeName = null;

double dTotalLoadHour = 0d; 
double dTotalLoadUnit = 0d;

double dTotallec = 0d;
int iTotalUnit = 0;
double dTotalLab = 0d;

FacultyManagement FM = new FacultyManagement();


int iMaxRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("iMaxRows"),"15"));
int iRowsPrinted = 1;

boolean bolAllowLoadHour = true;
String strSubjSel = null;
String strCourse = null;
String strMaster = null;
String strDoctoral = null;

Vector vUserDetail = null;
String strPTFT = null;
String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");

Vector vEmpEduHist = new Vector();
String strExtraCon = "";
String strDepHead = null;
String strDeanName = null;
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
	
	
	strTemp= "  select degree_earned from HR_INFO_EDU_HIST " +
	         " join HR_PRELOAD_EDU_TYPE " +
             " on (HR_PRELOAD_EDU_TYPE.EDU_TYPE_INDEX = hr_info_edu_hist.EDU_TYPE_INDEX) "+
             " where is_valid = 1 and GRAD_YEAR is not null and user_index = '"+ strEmployeeIndex +"'order by GRAD_YEAR ";

	rs  = dbOP.executeQuery(strTemp);
	while(rs.next()){
		
		strTemp = WI.getStrValue(rs.getString(1));
		
		if(strTemp.toLowerCase().indexOf("master") > -1)
			strMaster = strTemp;
		else if(strTemp.toLowerCase().indexOf("doctor") > -1)
			strDoctoral = strTemp;
		else
			strCourse = strTemp;
	}rs.close();
	
	
	
	strTemp = WI.fillTextValue("print_option_swu");			
	if(strTemp.length() > 0){
		if(strTemp.equals("1"))//print only graduate schoool
			strExtraCon = " and E_SUB_SECTION.DEGREE_TYPE = 1 ";//" and C_NAME like 'graduate school%'";
		else if(strTemp.equals("2"))
			strExtraCon = " and E_SUB_SECTION.DEGREE_TYPE <> 1 ";//" and C_NAME not like 'graduate school%'";
		else
			strExtraCon = "";//meaning all print all subjects
			
		strExtraCon += WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","","");
	}else
		strExtraCon = WI.getStrValue(WI.fillTextValue("c_index")," and offered_by_college = ","","");

	 
	vUserDetail = FM.viewFacultyDetail(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"),strExtraCon);
	
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
	else {
	
		vRetResult = FM.viewFacultyLoadSummary(dbOP,strEmployeeIndex,
					WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
					WI.fillTextValue("semester"),strExtraCon, true, true);	
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




	
String[] astrSemester={"Summer", "First Semester", "Second Semester","Third Semester"};
String[] astrSem={"Summer", "1st Sem", "2nd Sem","3rd Sem"};
//end of authenticaion code.
 if(strErrMsg != null){%>
	<table width="100%">
	  <tr> 
		<td height="25" colspan="2">&nbsp;&nbsp; <%=strErrMsg%></td>
	  </tr>
	</table>
<%} %>
<form name="form_" action="./teaching_load_slip_print_swu.jsp" method="post">
    <blockquote>
        <p>
            <%


Vector vCollege = new Vector();
int iCount=1;
 if(vRetResult != null && vRetResult.size() > 0){
	for (int i = 0; i< vRetResult.size();) {  
         if(vUserDetail != null && vUserDetail.size() > 0 || vEmpEduHist!=null && vEmpEduHist.size() > 0){%>
            
        </p>
    </blockquote>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" >
		<tr>
		  <td height="25"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
		  <font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div></td>
		</tr>
		<tr>
		<td height="25" align="center"><br><strong>Teacher's Load Report</strong><br>Final Copy</td>
		</tr>
	</table>

   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
       <td width="1%" height="21" class="thinborderLEFT">&nbsp;</td>
	   <td width="11%" height="21" colspan="1"></td>
      <td width="33%" height="21"></td>
	  <td width="7%" height="21">Course</td> 
	 
	  <td width="48%" height="21">:<strong><%=WI.getStrValue(strCourse)%></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="18" class="thinborderLEFT">&nbsp;</td>
      <td width="11%" height="18"> Instructor :</td>
	  <td width="33%" height="18"><strong><%=WI.fillTextValue("emp_id")%>-<%=(String)vUserDetail.elementAt(1)%> </strong></td>
	  <td height="18">Masters </td>
	  <td height="18">:<strong><%=WI.getStrValue(strMaster)%></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="19" class="thinborder">&nbsp;</td>
      <td class="thinborderBOTTOM"> Semester :</td>
	  <%
	  if(Integer.parseInt(WI.fillTextValue("semester")) == 0)
		  strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]+" "+WI.fillTextValue("sy_to");
	else
		strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]+" "+WI.fillTextValue("sy_from");
	  %>
	  <td class="thinborderBOTTOM"><strong><%=strTemp%></strong></td>
	  <td class="thinborderBOTTOM">Doctoral</td>
	  <td class="thinborderBOTTOM">:<strong><%=WI.getStrValue(strDoctoral)%></strong></td>
    </tr>
	</table>  
     <%} // end vUserDetail != null
	 
	  
	 %>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="5" colspan="6"></td></tr>
	 <tr>
	 <td colspan="6" height="60">
	 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="">
	   <tr >
		 <td width="2%" height="25" class="thinborderTOPLEFTBOTTOM" rowspan="2"><div align="center"><font size="1"><strong>NO.</strong></font></div></td>
		 <td width="7%" height="25" class="thinborderTOPLEFTBOTTOM" rowspan="2"><div align="center"><font size="1"><strong>SUBJECT CODE</strong></font></div></td>
		 <td width="16%" class="thinborderTOPLEFTBOTTOM" rowspan="2"><div align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
		 <td width="4%" class="thinborderTOPLEFTBOTTOM" rowspan="2"><div align="center"><font size="1"><strong>UNITS</strong></font></div></td>
		 <td class="thinborderTOPLEFTBOTTOM" colspan="2"><div align="center"><font size="1"><strong>HOURS/WEEK</strong></font></div></td>
		 <td width="16%" class="thinborderTOPLEFTBOTTOM" rowspan="2"><div align="center"><font size="1"><strong>TIME</strong></font></div></td>
		 <td width="5%" class="thinborderTOPLEFTBOTTOM" rowspan="2"><div align="center"><font size="1"><strong>DAYS</strong></font></div></td>
		 <td width="9%" class="thinborderTOPLEFTBOTTOM" rowspan="2"><div align="center"><font size="1"><strong>ROOM</strong></font></div></td>
		 <td width="5%" class="thinborderTOPLEFTBOTTOM"rowspan="2"><div align="center"><font size="1"><strong>NO. OF STUDENTS</strong></font></div></td>
		 <td width="12%" class="thinborderTOPLEFTBOTTOM"rowspan="2"><div align="center"><font size="1"><strong>SECTION</strong></font></div></td>
		 <td width="14%" class="thinborderALL"rowspan="2"><div align="center"><font size="1"><strong>COLLEGE</strong></font></div></td>
	   </tr>
	   <tr>
		 <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>Lec</strong></font></div></td>
		 <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>Lab</strong></font></div></td>
	   </tr>
<%      
		 for(; i < vRetResult.size() ; i +=15, iCount++){%>
      <tr>
        <td class="thinborder"><font style="font-size:9px;"><%=iCount%></font></td>
        <td height="25" class="thinborder"><font style="font-size:9px;"><%=(String)vRetResult.elementAt(i)%></font></td>
        <%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 1));
		if(strTemp.length() > 20)
			strTemp = strTemp.substring(0, 20);
		
		%>
        <td class="thinborder"><font style="font-size:9px;"><%=strTemp%></font></td>
<%       
			
			
			try{
				iTotalUnit += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 8),"0"));
				strTemp = (String)vRetResult.elementAt(i + 8) + ".0";
			}catch(NumberFormatException e){
				iTotalUnit += 0;
				strTemp = (String)vRetResult.elementAt(i + 8);
			}
 %>
        <td class="thinborder" align="center"><font style="font-size:9px;"><%=WI.getStrValue(strTemp)%></font></td>
<%      String strTemp2 = null;
        String strLab = WI.getStrValue((String)vRetResult.elementAt(i + 13),"0.0");;
        String strLec = WI.getStrValue((String)vRetResult.elementAt(i + 12),"0.0");
        int iIndexOf = 0;
        
			try{
				dTotallec += Double.parseDouble(WI.getStrValue(strLec,"0"));
			}catch(Exception e){
				dTotallec += 0;
			}
	      
%>
            <td class="thinborder" align="center"><font style="font-size:9px;"><%=WI.getStrValue(strLec, "&nbsp;")%></font></td>		
		<%try{
				dTotalLab += Double.parseDouble(WI.getStrValue(strLab,"0"));
			}catch(Exception e){
				dTotalLab += 0;
			}
%>
	      <td class="thinborder" align="center"><font style="font-size:9px;"><%=WI.getStrValue(strLab, "&nbsp;")%></font></td>
<%	    strTemp2 = null;
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
		 <td class="thinborder"><font style="font-size:9px;"><%=WI.getStrValue(strTime, "&nbsp;")%></font></td>
		 <td class="thinborder" align="center"><font style="font-size:9px;"><%=WI.getStrValue(strDays, "&nbsp;")%></font></td>
		 <td class="thinborder"><font style="font-size:9px;"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"Not Set")%></font></td>
		 <td class="thinborder" align="center"><font style="font-size:9px;"><%=(String)vRetResult.elementAt(i + 7)%></font></td>
		 <td class="thinborder"><font style="font-size:9px;"><%=(String)vRetResult.elementAt(i + 4)%></font></td>
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 2));
		strCollegeName = strTemp;
		if(strTemp.length() > 15)
			strTemp = strTemp.substring(0, 15);
		if(vCollege.indexOf(strTemp) == -1)
			vCollege.addElement(strTemp);
		
		%>
		 <td class="thinborderRIGHTLEFTBOTTOM"><font style="font-size:9px;"><%=strTemp%></font></td>
	   </tr>
      
<% } }// end of vRetResult outer loop%>
		
	   <tr>
        <td class="">&nbsp;</td>
        <td height="25" class="">&nbsp;</td>
        <td class="thinborder" align="right">Total : &nbsp; &nbsp;</td>
        <td class="thinborder" align="center"><%=iTotalUnit%></td>
        <td class="thinborder" align="center"><label id="total_lec"><%=dTotallec%></label></td>
        <td class="thinborder" align="center"><label id="total_lab"><%=dTotalLab%></label></td>
        <td class="thinborderLEFT">&nbsp;</td>
        <td class="" align="center">&nbsp;</td>
        <td class="">&nbsp;</td>
        <td class="" align="center">&nbsp;</td>
        <td class="">&nbsp;</td>
        <td class="">&nbsp;</td>
      </tr>

	   <tr>
		 <td height="2" colspan="12"></td>
	   </tr>
	 </table>	 </td>
	</tr>
	<!--<tr> 
	  <td height="27" width="21%">&nbsp;</td>
	  <td width="4%" align="right" class="thinborderTOPLEFTBOTTOM">Total:&nbsp;</td>
	   
	  <td width="4%" class="thinborderTOPBOTTOM" align="center">&nbsp;<strong><%=iTotalUnit%></strong></td>
	  <td width="7%" class="thinborderTOPBOTTOM" align="center">&nbsp;<strong><%=dTotallec%></strong></td>
	  <td width="7%" class="thinborderTOPBOTTOM" align="center">&nbsp;<strong><%=dTotalLab%></strong></td>
	  <td class="thinborderLEFT">&nbsp;</td>
	</tr>-->
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	<td height="17"><u>Semestral Term</u></td>
	</tr>
	<tr>
	<td height="19">&nbsp; Classes Start: <%=WI.fillTextValue("class_start")%></td>
	</tr>
	<tr>
	<td height="20">&nbsp; Classes End: <%=WI.fillTextValue("class_end")%></td>
	</tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			 <td height="25" colspan="3"><br>
		  <strong><div style="border-bottom:solid 1px #000000;"></div></strong></td>
		   <td colspan="3"><br>
		  <b><div style="border-bottom:solid 1px #000000;"></div></b></td>
	  </tr>
	</table>
	
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr> 
	<td valign="top" width="33%">	
		<table width="99%" height="236" border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td align="center" valign="top" height="258" class="thinborderALL">
		<table width="100%" height="33"  border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td><strong>This is to certify that:</strong></td>
          </tr>
		  </table>
		  <table width="100%"  border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td width="13%" align="right">1.&nbsp;</td>
		<td width="87%">I received the list of subjects with</td>
		</tr>
		<tr><td></td><td> the names of students</td></tr>
		<tr><td height="5"></td></tr>
		<tr>
		<td width="13%" align="right">2.&nbsp;</td>
		<td width="87%">I would not allow those who are </td>
		</tr>
		<tr><td></td><td> not in the list from attending the <br>class except those authorized for <br>insertion.</td></tr>
		<tr><td height="5"></td></tr>
		<tr>
		<td width="13%" align="right">3.&nbsp;</td>
		<td width="87%">I will enforce the policy of		  </td>
		</tr>
		<tr><td></td><td>"No permit No Examination"</td></tr>
		</table>
		<br><br><br><br><br>
			<div style="border-bottom:solid 1px #000000; width:80%"></div>
				Faculty		 </td>
		</tr>
	  </table></td>
	  
	  
	<td valign="top">
	<table width="98%" align="center" border="0" cellpadding="0" cellspacing="0">
	  <tr>
		<td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderALL">
		  <tr>
			<td height="63">
			<table width="100%"  border="0" cellpadding="0" cellspacing="0" >
				<%
				
				if(vCollege.size() == 1 && strCollegeName != null){
					strTemp = 
						" select COUNT(*) from department "+
						" join COLLEGE on (college.C_INDEX = DEPARTMENT.C_INDEX) "+
						" where department.IS_DEL = 0 and IS_COLLEGE_DEPT = 1 "+
						" and C_NAME = "+WI.getInsertValueForDB(strCollegeName, true, null);
					strTemp = dbOP.getResultOfAQuery(strTemp, 0);
					if(strTemp != null && !strTemp.equals("1"))
						strDepHead = null;
					else{
						strTemp = 
							" select DH_NAME from department "+
							" join COLLEGE on (college.C_INDEX = DEPARTMENT.C_INDEX) "+
							" where department.IS_DEL = 0 and IS_COLLEGE_DEPT = 1 "+
							" and C_NAME = "+WI.getInsertValueForDB(strCollegeName, true, null);
						strDepHead = dbOP.getResultOfAQuery(strTemp, 0);
					}
				}
				
				/*strTemp = " select DH_NAME from DEPARTMENT where D_NAME ="+WI.getInsertValueForDB((String)vUserDetail.elementAt(5), true, null)+
				  " and IS_COLLEGE_DEPT =1";
				rs  = dbOP.executeQuery(strTemp);
				if(rs.next())
					strDepHead = rs.getString(1);
				rs.close();*/
				%>
				<tr><td>Reviewed By :</td></tr>
				<tr><td height="50" valign="bottom" align="center"><strong><%=WI.getStrValue(strDepHead).toUpperCase()%>
				</strong><br>Department Head</td></tr>
			</table>			</td>
		  </tr>
		</table>		</td>
	  </tr>
	  <tr><td height="5"></td></tr>
	  <tr>
	  <td>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderALL">
		  <tr>
		<td height="63">
			<table width="100%"  border="0" cellpadding="0" cellspacing="0" >
				<tr><td>Recommending Approval :</td></tr>
				<%
				strTemp = WI.getStrValue(vUserDetail.elementAt(10)).toUpperCase();
				if(vCollege.size() > 1)
					strTemp = "&nbsp;";
				%>
				<tr><td height="50" valign="bottom" align="center"><strong><%=strTemp%></strong><br>Dean</td></tr>
			</table>		 </td>
		</tr>
		</table>		</td>
	  </tr>
	  <tr><td height="5"></td></tr>
	  
	  <tr>
	  <td>
	  <table width="100%"  border="0" cellpadding="0" cellspacing="0" class="thinborderALL">
		  <tr>
		<td height="53" align="center" valign="bottom">
		  <strong><%=WI.getTodaysDate(6)%></strong><br>Date Issued </td></tr>
		</table>	</td>
	  </tr>
	  <tr><td height="5"></td></tr>
	  <tr><td>
	  <table width="100%"  border="0" cellpadding="0" cellspacing="0" class="thinborderALL">
		  <tr>
		<td height="57" align="center" valign="bottom">
		  <strong><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></strong><br>Issued By: </td>
		  </tr>
		</table>
		</td>
	  </tr>
	</table>	</td>
	
	
	
	<td valign="top" width="33%">
	<table align="right" width="99%" border="0" cellpadding="0" cellspacing="0">
	<tr>
	<td>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<%
		strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "VPAA",7)).toUpperCase();
		if(strTemp.length() == 0)
			strTemp = "&nbsp;";
		%>
	 <tr><td height="135" valign="top" class="thinborderALL">
	 	<table width="100%"  border="0" cellpadding="0" cellspacing="0" >
			<tr><td>Approved :</td></tr>
			<tr><td height="120" valign="bottom" align="center"><strong>NOE G. QUIÑANOLA, Ph.D</strong><br>
	    University President</td></tr>
		</table>
	</td>
	 </tr>
	</table>	</td>
	</tr>
	<tr><td height="5"></td></tr>
	<tr>
	<td><table width="100%"  border="0" cellpadding="0" cellspacing="0" >
	 <tr><td valign="top" height="118" class="thinborderALL">Copy :  
	 							 1 - EDP CENTER <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								 1 - DEAN <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								 1 - PAYROLL <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								 1 - VPAA<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								 1 - VP ADMIN<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								 1 - EVALUATION<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								 1 - UMS</td>
	 </tr>
	</table></td></tr>
	</table>	</td>
	</tr>
	</table>
<%} // end of vRetReuslt != null%>
<input type="hidden" name="show_list" value="0"> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>