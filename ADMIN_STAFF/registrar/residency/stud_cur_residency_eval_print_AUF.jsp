<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1



%>
<style type="text/css">

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

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	TD.thinborderTOPLEFTBOTTOM {
    border-left: solid 1px #000000;
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.GradeSystem,student.StudentEvaluation,java.util.Vector" %>
<%
	DBOperation dbOP = null; 
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	double dGWA      = 0d;

	String[] astrConvertYearLvl ={"","1","2","3","4","5","6"};
	String[] astrConvertYear ={"","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YEAR","FIFTH YEAR","SIXTH YEAR"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","","","",""};
	String[] astrConvertResStatus = {"Regular","Irregular"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT CURRICULUM EVALUATION","stud_cur_residency_eval.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","STUDENT COURSE EVALUATION",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),
					null);
}
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
	//adviser are allowed to check. 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"stud_cur_residency_eval_print.jsp");
	if(iAccessLevel == 0) {
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
}

//end of authenticaion code.

enrollment.GradeSystemTransferee GSTransferee = new enrollment.GradeSystemTransferee();

GradeSystem GS = new GradeSystem();
StudentEvaluation SE = new StudentEvaluation();
Vector vRetResult = null;
Vector vTemp = null;

//double dTotCreditEarnedOtherSchool = 0d;
double dTotalINCUnits       = 0d;
double dTotalCreditUnits    = 0d;
double dTotalCreditUnitsAUF = 0d;
//added more March 11, 2014
double dFailed  = 0d;
double dDropped = 0d;
double dWP = 0d;//withdraw with permit
double dFDA = 0d;



double dGWATotUnits        = 0d;//sum of units..
double dGWATotUnitMulGrade = 0d;//sum of unit x grade.. .. gwa = dGWATotUnitMulGrade/dGWATotUnits;


if(WI.fillTextValue("stud_id").length() > 0) {
	vTemp = GS.getResidencySummary(dbOP, WI.fillTextValue("stud_id"));
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
	else {
		vRetResult = SE.getCurriculumResidencyEval(dbOP,(String)vTemp.elementAt(0),(String)vTemp.elementAt(15),
                                           (String)vTemp.elementAt(16),(String)vTemp.elementAt(8),(String)vTemp.elementAt(9),
                                           (String)vTemp.elementAt(11));
		//dTotCreditEarnedOtherSchool = SE.getCreditedUnits(); ==> no need, added in jsp.. 
		
		if(vRetResult == null || vRetResult.size() ==0)
			strErrMsg = SE.getErrMsg();
	}
	
	//I have to get the GWA for all the subjects completed so far. -- removed date : November: 24, 2013, because i have to consider only passed grade, and include credited subject.
	//student.GWA gwa = new student.GWA();
	//dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));
}
boolean bolRemoveRemark = false;
boolean bolShowGrade = false;


bolShowGrade    = true;
bolRemoveRemark = true;

Vector vCreditedSubject = new Vector();//[0] sub_code-sub_name, [1] grade, [2] credited_same_sch

Vector vInProgress  = new Vector();

if(strErrMsg == null && vTemp != null && vTemp.size() > 0) { //save print information :: 
	String strSYFrom   = (String)vTemp.elementAt(17);
	String strSemester = (String)vTemp.elementAt(18);
	
	String strSQLQuery = "select PRINT_INDEX from TRACK_PRINTING where STUD_INDEX = "+(String)vTemp.elementAt(0)+
		" and PRINT_MODULE = 2 and SY_FROM = "+strSYFrom +" and SEMESTER="+strSemester+" and DATE_PRINTED='"+WI.getTodaysDate()+"'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null) {
		strSQLQuery = "insert into TRACK_PRINTING (STUD_INDEX,PRINT_MODULE,SY_FROM,SEMESTER,DATE_PRINTED,PRINTED_BY) values ("+(String)vTemp.elementAt(0)+
			",2,"+strSYFrom+","+strSemester+",'"+WI.getTodaysDate()+"',"+(String)request.getSession(false).getAttribute("userIndex")+")";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
	CommonUtil.setSubjectInEFCLTable(dbOP);
	String strCurHistIndex = null;
	strSQLQuery = "select cur_hist_index from stud_curriculum_hist where is_valid = 1 and user_index = "+vTemp.elementAt(0)+" and sy_from = "+
		strSYFrom+ " and semester="+strSemester;
	strCurHistIndex = dbOP.getResultOfAQuery(strSQLQuery, 0) ;
	///get list of subjects having grade already.. 
	strSQLQuery = "select s_index from g_sheet_final where cur_hist_index = "+strCurHistIndex +" and is_valid = 1";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	strSQLQuery = null;
	while(rs.next()) {
		if(strSQLQuery == null)
			strSQLQuery = rs.getString(1);
		else
			strSQLQuery += ", "+rs.getString(1);
	}
	rs.close();
	
	strSQLQuery = "select cur_index from enrl_final_cur_list where is_valid = 1 and user_index = "+vTemp.elementAt(0)+" and sy_from = "+
		strSYFrom+ " and current_semester="+strSemester+" and is_temp_stud = 0"+WI.getStrValue(strSQLQuery, " and efcl_sub_index not in (", ")", "");
	
	rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
	while(rs.next())
		vInProgress.addElement(rs.getString(1));
	rs.close();	
	//System.out.println(vInProgress);
	
	//get vCreditedSubject = new Vector();//[0] sub_code-sub_name, [1] grade, [2] credited_same_sch
	strSQLQuery = "select sub_Code, sub_name, grade, credited_same_sch from g_sheet_final join subject on (sub_index = s_index) where is_valid = 1 and user_index_ = "+
					vTemp.elementAt(0)+" and COPIED_FR_TF_GS = 1";
	rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
	while(rs.next()) {
		vCreditedSubject.addElement(rs.getString(1)+"-"+rs.getString(2));//[0] sub_code-sub_name
		vCreditedSubject.addElement(rs.getString(3));//[1] grade
		vCreditedSubject.addElement(rs.getString(4));//[2] credited_same_sch
	}
	rs.close();
}

%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="20"><div align="center"><strong><font size="2">STUDENT RESIDENCY EVALUATION</font></strong></div></td>
    </tr>
</table>
<%if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td width="98%" height="20" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  
<%}if(vTemp != null && vTemp.size()>0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">  
  <tr> 
    <td height="20" width="70%"><strong><font size="2">NAME</font>:</strong>&nbsp; <u><%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),1)%></u></td>
    <td><strong><font size="2">STUDENT NO</font>.:</strong>&nbsp; <u><%=WI.fillTextValue("stud_id")%></u></td>
  </tr>
  <tr> 
    <td height="20"><strong><font size="2">DEGREE PROGRAM</font>:</strong>&nbsp; <u><%=(String)vTemp.elementAt(6)%></u></td>
    <td align=""><strong><font size="2">CURRICULUM EFFECTIVE</font>:</strong>&nbsp; <u><%=(String)vTemp.elementAt(8)%>-<%=(String)vTemp.elementAt(9)%></u></td>
  </tr>  
</table>
<%}//only vTemp is not null -- having residency summary.

if(vRetResult != null && vRetResult.size() > 0){ 
String strCourseName = null;
String strDegreeType = (String) vTemp.elementAt(11);
String strPrevCourseName = "";
int iTemp = 2;
if(strDegreeType.equals("1")){
	for(int i = 0; i < vRetResult.size(); i += 16){
		strCourseName = WI.getStrValue(vRetResult.elementAt(i));
		if(!strPrevCourseName.equals(strCourseName)){	
			strPrevCourseName = strCourseName;		
			if(iTemp == 2)
				iTemp = 1;
			else
				iTemp = 2;
		}
		
		vRetResult.setElementAt(Integer.toString(iTemp), i+1);
	}
}


String strPrevYr  = null;
String strCurYr   = null;
int iPrevSem = 0;
int iCurSem  = 0;

int i = 0;
int iLineCount = 0;
double dTotalUnit = 0d;
double dTotalPassed  = 0d;
String strPassed = null;
String strLegend = null;
int iIndexOf = 0;
double dTotalCurrEnrl = 0d;




%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td class="" height="10px" colspan="3"><hr size="1"></td></tr>
	<tr>
		<td height="500" width="48%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
				<tr>
					<td width="10%" class="thinborder">&nbsp;</td>
					<td width="15%" class="thinborder" align="center"><font color="#0066FF"><strong>SUBJECT</strong></font></td>
					<td width="50%" class="thinborder" align="center"><font color="#0066FF"><strong>TITLE</strong></font></td>
					<td width="12%" class="thinborder" align="center"><font color="#0066FF"><strong>UNITS</strong></font></td>
					<td width="13%" class="thinborder" align="center"><font color="#0066FF"><strong>GRADE</strong></font></td>
				</tr>
				
				
				
				
				<%for(; i< vRetResult.size();){
					
					iLineCount += 1;
					dTotalUnit = 0d;
					iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));					
				  	%>	
				  
				  
				 
					<%					
					if(iCurSem == 1){
						strCourseName = WI.getStrValue(vRetResult.elementAt(i));
					%> 
						<tr bgcolor="#CCCCCC">
							<td colspan="5" align="center" class="thinborder"><strong>
							<%if(strDegreeType.equals("1")){%>
							<%=strCourseName%>
							<%}else{%>
							<%=astrConvertYear[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i),"0"))]%> - FIRST SEMESTER</strong>
							<%}%>
							</td>
						</tr>							
												
						<%for(; i< vRetResult.size();){//1st semester only.
						strLegend = "";
						iLineCount += 1;
						iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
						if(iCurSem != 1)
							break;
							
							
							
							
						dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
						
						strPassed = WI.getStrValue(vRetResult.elementAt(i+15));		
						strTemp = WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp;");//remarks.
						
						//System.out.println("strPassed: "+strPassed);
						//System.out.println("strTemp: "+strTemp);
						
						if(strTemp.equalsIgnoreCase("credited")){
							strLegend = "T";
							strTemp = "Passed";
							
							iIndexOf = vCreditedSubject.indexOf((String)vRetResult.elementAt(i+4)+"-"+(String)vRetResult.elementAt(i+5));
							if(iIndexOf > -1) {
								if(vCreditedSubject.elementAt(iIndexOf + 1) != null)
									strTemp = (String)vCreditedSubject.elementAt(iIndexOf + 1);
								if(vCreditedSubject.elementAt(iIndexOf + 2).equals("1")) {
									strLegend = "S";
									dTotalCreditUnitsAUF += Double.parseDouble((String)vRetResult.elementAt(i+10));
									dTotalCreditUnits -= Double.parseDouble((String)vRetResult.elementAt(i+10));	
								}
								///add this to gwa computation.
								try {
									dGWATotUnitMulGrade += Double.parseDouble((String)vRetResult.elementAt(i+10)) * Double.parseDouble(strTemp);
									dGWATotUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));	
								}
								catch(Exception e) {}
								}
							
							dTotalCreditUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));						
						}
						else if(strPassed.equalsIgnoreCase("Passed")){
							strLegend = "P";
							dTotalPassed += Double.parseDouble((String)vRetResult.elementAt(i+10));	
							
							try {
								dGWATotUnitMulGrade += Double.parseDouble((String)vRetResult.elementAt(i+10)) * Double.parseDouble(strTemp);
								dGWATotUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));	
							}
							catch(Exception e) {}
							
					
						}
						if(strPassed.equalsIgnoreCase("incomplete")){
							dTotalINCUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));	
							strLegend = "I";				
						}
						if(strPassed.equalsIgnoreCase("failed")){
							strLegend = "F";		
							dFailed += Double.parseDouble((String)vRetResult.elementAt(i+10));		
						}
						if(strPassed.startsWith("Failure")){
							strLegend = "FA";				
							dFDA += Double.parseDouble((String)vRetResult.elementAt(i+10));
						}
						if(strTemp.equalsIgnoreCase("WP")){
							strLegend = "WP";				
							dWP += Double.parseDouble((String)vRetResult.elementAt(i+10));
						}
						if(strTemp.equalsIgnoreCase("dr")){
							strLegend = "D";				
							dDropped += Double.parseDouble((String)vRetResult.elementAt(i+10));
						}
												
						if(vInProgress.indexOf(vRetResult.elementAt(i+3)) > -1){
							strLegend = "C";
							dTotalCurrEnrl += Double.parseDouble((String)vRetResult.elementAt(i+10));	
						}
													
						
						
						%>
						<tr>
							<td class="thinborder" align="center"><%=WI.getStrValue(strLegend,"&nbsp;")%></td> 
						  	<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
						  	<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
						  	<td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+10)%></td>
						  	<td class="thinborder" align="center"><%=strTemp%></td>
						</tr>
						<%i += 16;}//prints only 1st semester. - Inner for loop%>
						  
					  <%}//only for 1st year.%> 
					
				  
				  	<%if(iCurSem == 2){%> 											
						<%for(; i< vRetResult.size();){//1st semester only.
						iLineCount += 1;
						iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
						if(iCurSem != 2)
							break;						
						%>						
						<%i += 16;}//prints only 1st semester. - Inner for loop%>
											  
					  <%}//only for 1st year.%>
				  
				  
				  
				  <!----------------------SUMMER----------------------------->
				<%				
				if(iCurSem == 0) {				
				%>	
					<tr bgcolor="#CCCCCC"><td colspan="5" align="center" class="thinborder">
					<strong>
					<%if(strDegreeType.equals("1")){%>
					<%=strCourseName%>
					<%}else{%>
					<%=astrConvertYear[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i),"0"))]%> - SUMMER
					<%}%>
					</strong></td></tr>						
						<%for(; i< vRetResult.size();){//1st semester only.	
						strLegend = "";
						iLineCount += 1;					
						iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
						if(iCurSem != 0)
							break;
							
						dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
						
						strPassed = WI.getStrValue(vRetResult.elementAt(i+15));						
						strTemp = WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp;");//remarks.
						
						if(strTemp.equalsIgnoreCase("credited")){
							strLegend = "T";
							
							strTemp = "Passed";
							
							iIndexOf = vCreditedSubject.indexOf((String)vRetResult.elementAt(i+4)+"-"+(String)vRetResult.elementAt(i+5));
							if(iIndexOf > -1) {
								if(vCreditedSubject.elementAt(iIndexOf + 1) != null)
									strTemp = (String)vCreditedSubject.elementAt(iIndexOf + 1);
								if(vCreditedSubject.elementAt(iIndexOf + 2).equals("1")) {
									strLegend = "S";
									dTotalCreditUnitsAUF += Double.parseDouble((String)vRetResult.elementAt(i+10));
									dTotalCreditUnits -= Double.parseDouble((String)vRetResult.elementAt(i+10));	
								}
								try {
									dGWATotUnitMulGrade += Double.parseDouble((String)vRetResult.elementAt(i+10)) * Double.parseDouble(strTemp);
									dGWATotUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));	
								}
								catch(Exception e) {}
								}
							
							dTotalCreditUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));						
						}
						else if(strPassed.equalsIgnoreCase("Passed")){
							strLegend = "P";
							dTotalPassed += Double.parseDouble((String)vRetResult.elementAt(i+10));	
							try {
								dGWATotUnitMulGrade += Double.parseDouble((String)vRetResult.elementAt(i+10)) * Double.parseDouble(strTemp);
								dGWATotUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));	
							}
							catch(Exception e) {}					
						}
						
						if(vInProgress.indexOf(vRetResult.elementAt(i+3)) > -1){
							strLegend = "C";
							dTotalCurrEnrl += Double.parseDouble((String)vRetResult.elementAt(i+10));	
						}
						if(strPassed.equalsIgnoreCase("incomplete")){
							dTotalINCUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));
							strLegend = "I";				
						}
						
						if(strPassed.equalsIgnoreCase("failed")){
							strLegend = "F";		
							dFailed += Double.parseDouble((String)vRetResult.elementAt(i+10));		
						}
						if(strPassed.startsWith("Failure")){
							strLegend = "FA";				
							dFDA += Double.parseDouble((String)vRetResult.elementAt(i+10));
						}
						if(strTemp.equalsIgnoreCase("WP")){
							strLegend = "WP";				
							dWP += Double.parseDouble((String)vRetResult.elementAt(i+10));
						}
						if(strTemp.equalsIgnoreCase("dr")){
							strLegend = "D";				
							dDropped += Double.parseDouble((String)vRetResult.elementAt(i+10));
						}
						
						
						%>
						<tr> 
							<td class="thinborder" align="center"><%=WI.getStrValue(strLegend,"&nbsp;")%></td>
						  	<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
						  	<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
						  	<td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+10)%></td>
						  	<td class="thinborder" align="center"><%=strTemp%></td>
						</tr>
						<%i += 16;}//prints only 1st semester. - Inner for loop%> 						
					  
				  <%}//end of display summer.
				  
				  
				  if(iLineCount == 43){%>
				  	<DIV style="page-break-before:always" >&nbsp;</DIV>					
				<%}
				}//end of for loop to display grade/course evaluation
				%>
			</table>
		</td>
		
		<td height="500" valign="top">&nbsp;</td>
		
		<!------------------------------------------RIGHT SIDE------------------------------------------------------>
		<td height="500" width="48%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
				<tr>
					<td class="thinborder" width="10%">&nbsp;</td>
					<td class="thinborder" width="15%" align="center"><font color="#0066FF"><strong>SUBJECT</strong></font></td>
					<td class="thinborder" width="50%" align="center"><font color="#0066FF"><strong>TITLE</strong></font></td>
					<td class="thinborder" width="12%" align="center"><font color="#0066FF"><strong>UNITS</strong></font></td>
					<td class="thinborder" width="13%" align="center"><font color="#0066FF"><strong>GRADE</strong></font></td>
				</tr>
				
				
				
				
				<%
				i = 0;
				for(; i< vRetResult.size();){
					
					iLineCount += 1;
					dTotalUnit = 0d;
					iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
					
				  	%>	
					
					<%if(iCurSem == 1){%> 													
						<%for(; i< vRetResult.size();){//1st semester only.
						iLineCount += 1;
						iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
						if(iCurSem != 1)
							break;											
						%>						
						<%i += 16;}%>											  
					  <%}%> 
					  
					<%if(iCurSem == 2){
					
						strCourseName = WI.getStrValue(vRetResult.elementAt(i));
					%> 
						<tr bgcolor="#CCCCCC"><td colspan="5" align="center" class="thinborder"><strong>
						<%if(strDegreeType.equals("1")){%>
						<%=strCourseName%>
						<%}else{%>
						<%=astrConvertYear[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i),"0"))]%> - SECOND SEMESTER
						<%}%>
						</strong>
				  	</td></tr>					
						<%for(; i< vRetResult.size();){//2nd semester only.
						strLegend = "";
						iLineCount += 1;
						iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
						if(iCurSem != 2)
							break;
						dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
						
						strPassed = WI.getStrValue(vRetResult.elementAt(i+15));						
						strTemp = WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp;");//remarks.
						
						if(strTemp.equalsIgnoreCase("credited")){
							strLegend = "T";
							strTemp = "Passed";
							
							iIndexOf = vCreditedSubject.indexOf((String)vRetResult.elementAt(i+4)+"-"+(String)vRetResult.elementAt(i+5));
							if(iIndexOf > -1) {
								if(vCreditedSubject.elementAt(iIndexOf + 1) != null)
									strTemp = (String)vCreditedSubject.elementAt(iIndexOf + 1);
								if(vCreditedSubject.elementAt(iIndexOf + 2).equals("1")) {
									strLegend = "S";
									dTotalCreditUnitsAUF += Double.parseDouble((String)vRetResult.elementAt(i+10));
									dTotalCreditUnits -= Double.parseDouble((String)vRetResult.elementAt(i+10));	
								}
								try {
									dGWATotUnitMulGrade += Double.parseDouble((String)vRetResult.elementAt(i+10)) * Double.parseDouble(strTemp);
									dGWATotUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));	
								}
								catch(Exception e) {}
								}
							
							dTotalCreditUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));						
						}
						else if(strPassed.equalsIgnoreCase("Passed")){
							strLegend = "P";
							dTotalPassed += Double.parseDouble((String)vRetResult.elementAt(i+10));	
							try {
								dGWATotUnitMulGrade += Double.parseDouble((String)vRetResult.elementAt(i+10)) * Double.parseDouble(strTemp);
								dGWATotUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));	
							}
							catch(Exception e) {}					
						}
						
						if(vInProgress.indexOf(vRetResult.elementAt(i+3)) > -1){
							strLegend = "C";
							dTotalCurrEnrl += Double.parseDouble((String)vRetResult.elementAt(i+10));	
						}
						if(strPassed.equalsIgnoreCase("failed")){
							strLegend = "F";		
							dFailed += Double.parseDouble((String)vRetResult.elementAt(i+10));		
						}
						if(strPassed.startsWith("Failure")){
							strLegend = "FA";				
							dFDA += Double.parseDouble((String)vRetResult.elementAt(i+10));
						}
						if(strTemp.equalsIgnoreCase("WP")){
							strLegend = "WP";				
							dWP += Double.parseDouble((String)vRetResult.elementAt(i+10));
						}
						if(strTemp.equalsIgnoreCase("dr")){
							strLegend = "D";				
							dDropped += Double.parseDouble((String)vRetResult.elementAt(i+10));
						}
						//System.out.println("Printing Status:"+strPassed+"ENd of printing");
						if(strPassed.equalsIgnoreCase("incomplete")){
							dTotalINCUnits += Double.parseDouble((String)vRetResult.elementAt(i+10));	
							strLegend = "I";				
						}
						
						
						%>
						<tr>
							<td  class="thinborder" align="center"><%=WI.getStrValue(strLegend,"&nbsp;")%></td> 
						  	<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
						  	<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
						  	<td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+10)%></td>
						  	<td class="thinborder" align="center"><%=strTemp%></td>
						</tr>
						<%i += 16;}%>											  
					  <%}%> 
					  
					  
				<%if(iCurSem == 0) {				
					for(; i< vRetResult.size();){						
						iLineCount += 1;					
						iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
						if(iCurSem != 0)
							break;						
						%>						
						<%i += 16;}%>
				  <%}%>	
				<%					 
				}//end of for loop to display grade/course evaluation
				%>
			</table>
		</td>
	</tr>
	<tr><td class="" height="10px" colspan="3"><hr size="1"></td></tr>
	
	
	
	
	
	
	
	
	<!--------------------------------------------FOOTER------------------------------------------------------------->
	<tr>
		<td colspan="3">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td width="30%" valign="top">
						<table border="0" cellpadding="0" cellspacing="0" width="100%">
							<tr>
								<td valign="top">LEGEND:</td>
								<td>
									(P)Passed/Credited<br>
									(F)Failed<br>
									(I)Incomplete<br>
									(D)Dropped<br>
									(WP)Withdrawal with Permit<br>
									(FA)Failure Due to Absences<br>
									(C)Currently Enrolled Subject<br>
									(T)Subjects Credited from Other School<br>
									(S)Subjects Credited AUF<br>
									( )Deficiencies
								</td>
							</tr>
							
						</table>						
					</td>					
					<td valign="top" class="thinborderALL">REMARKS:</td>
					
					<td valign="top" width="30%">
						<table border="0" cellpadding="0" cellspacing="0" width="100%">
							<tr><td width="80%">Total Units Required</td><td>: <%=(String)vTemp.elementAt(12)%></td></tr>
							<tr><td>Total Units Passed/Credited</td><td>: <%=dTotalPassed%></td></tr>
							
							<%
							double dTotUnitRequired = 0d;
							try{
								dTotUnitRequired = Double.parseDouble((String)vTemp.elementAt(12));
							}catch(NumberFormatException nfe){
							
							}
							%>
							
							<tr> <td>Total Units Failed</td><td>: <%=dFailed%></td></tr>
							<tr><td>Total Units Incomplete</td><td>: <%=dTotalINCUnits%></td></tr>
							<tr> <td>Total Units Dropped</td><td>: <%=dDropped%></td></tr>
							<tr> <td>Total Units Withdrawal with Permit</td><td>: <%=dWP%></td></tr>
							<tr> <td>Total Units Failure Due to Absenses</td><td>: <%=dFDA%></td></tr>
							<tr><td>Total Units Currently Enrolled found in Template</td><td>: <%=dTotalCurrEnrl%></td></tr>
							<%
							//if(dTotCreditEarnedOtherSchool > 0d)
							//	strTemp = Double.toString(dTotCreditEarnedOtherSchool);
							//else
							//	strTemp = "";
							%>
							<tr><td>Total Units Credited from Other School</td><td>: <%=dTotalCreditUnits%></td></tr>
							<tr><td>Total Units with Equivalent Subject</td><td>: <%=dTotalCreditUnitsAUF%></td></tr>
							<tr><td>Total Units Computed</td><td>: <%=dTotalCreditUnits + dTotalPassed + dTotalCreditUnitsAUF%></td></tr>
							<tr><td>Academic Year Level</td><td>: <%=astrConvertYearLvl[Integer.parseInt(WI.getStrValue(vTemp.elementAt(10),"0"))]%></td></tr>
							<%//System.out.println(dGWATotUnitMulGrade);//System.out.println(dGWATotUnits);
							if(dGWATotUnits > 0d)
								dGWA = dGWATotUnitMulGrade/dGWATotUnits;
							if(dGWA > 0d)
								strTemp = CommonUtil.formatFloat(dGWA,true);//Float.toString(fGWA);
							else
								strTemp = "";
							%>
							<tr><td><strong>General Weighted Average(GWA)</strong></td><td>: <%=strTemp%></td></tr>
						</table>
					</td>
				</tr>
			</table>
		</td>		
	</tr>
	
</table>

<br>


<table border="0" cellpadding="0" cellspacing="0" width="100%">
  	<tr>
  		<td width="30%">Run Date/Time: <u><%=WI.getTodaysDateTime()%></u></td>
		<td>Printed By: <u><%=(CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1))%></u></td>
		<td width="30%">Evaluated By: _________________________________________</td>
	</tr>
</table>

<%}//if vRetResult != null%>


<%
dbOP.cleanUP();
if(strErrMsg == null) {//no error.%>
<script language="javascript">
window.print();

</script>
<%}%>
</body>
</html>
