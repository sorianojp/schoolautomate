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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

	TD.fontSize9{
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 9px;
	}

	TD.thinborderBOTTOMTOP{
		border-bottom: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 9px;
	}
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>
</head>
<body rightmargin="0" leftmargin="0" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,student.StudentEvaluation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	//float fGWA      = 0f;

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
GradeSystem GS = new GradeSystem();
StudentEvaluation SE = new StudentEvaluation();
Vector vRetResult = null;
Vector vTemp = null;

if(WI.fillTextValue("stud_id").length() > 0) {
	vTemp = GS.getResidencySummary(dbOP, WI.fillTextValue("stud_id"));
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
	else {
		vRetResult = SE.getCurriculumResidencyEval(dbOP,(String)vTemp.elementAt(0),(String)vTemp.elementAt(15),
                                           (String)vTemp.elementAt(16),(String)vTemp.elementAt(8),(String)vTemp.elementAt(9),
                                           (String)vTemp.elementAt(11));
		if(vRetResult == null || vRetResult.size() ==0)
			strErrMsg = SE.getErrMsg();
	}

	//I have to get the GWA for all the subjects completed so far.
	//student.GWA gwa = new student.GWA();
	//fGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));
}
boolean bolRemoveRemark = false;
boolean bolShowGrade = false;
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

bolShowGrade    = true;
bolRemoveRemark = true;

Vector vInProgress  = new Vector();

if(strErrMsg == null && vTemp != null && vTemp.size() > 0) { //save print information ::
	String strSYFrom   = (String)vTemp.elementAt(17);
	String strSemester = (String)vTemp.elementAt(18);

	String strSQLQuery = "select PRINT_INDEX from TRACK_PRINTING where STUD_INDEX = "+(String)vTemp.elementAt(0)+
		" and PRINT_MODULE = 2 and SY_FROM = "+strSYFrom +" and SEMESTER="+strSemester+" and DATE_PRINTED='"+
		WI.getTodaysDate()+"'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null) {
		strSQLQuery = "insert into TRACK_PRINTING (STUD_INDEX,PRINT_MODULE,SY_FROM,SEMESTER,DATE_PRINTED,PRINTED_BY) values ("+(String)vTemp.elementAt(0)+
			",2,"+strSYFrom+","+strSemester+",'"+WI.getTodaysDate()+"',"+(String)request.getSession(false).getAttribute("userIndex")+")";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
	strSQLQuery = "select cur_index from enrl_final_cur_list where is_valid = 1 and user_index = "+vTemp.elementAt(0)+" and sy_from = "+
		strSYFrom+ " and current_semester="+strSemester+" and is_temp_stud = 0";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
	while(rs.next())
		vInProgress.addElement(rs.getString(1));
	rs.close();
}

%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="20" colspan="4"><div align="center"><strong><font size="3">Cebu Institute of Technology - University</font><br>
        <i>STUDENT'S TEMPORARY EVALUATION</i><br>
        </strong></div></td>
    </tr>
</table>
<%if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="98%" height="20" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>

<%}if(vTemp != null && vTemp.size()>0){
String strCourseCode = (String)vTemp.elementAt(15);
String strMajorCode  = (String)vTemp.elementAt(16);
strCourseCode = "select course_code from course_offered where course_index = "+strCourseCode;
strCourseCode = dbOP.getResultOfAQuery(strCourseCode, 0);

if(strMajorCode != null) {
	strMajorCode = "select course_code from major where major_index = "+strMajorCode;
	strMajorCode = dbOP.getResultOfAQuery(strMajorCode, 0);
}

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="20">&nbsp;</td>
    <td align="right" class="fontSize9">ID No.: &nbsp;&nbsp;</td>
    <td><%=WI.fillTextValue("stud_id")%></td>
    <td colspan="2">Date and time printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
    <td width="10%" align="right" class="fontSize9">Name: &nbsp;&nbsp;</td>
    <td width="47%"><strong><%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),4)%></strong></td>
    <td width="18%">&nbsp;</td>
    <td width="23%"><strong>&nbsp;</strong></td>
  </tr>
  <tr>
    <td width="2%" height="20">&nbsp;</td>
    <td align="right" class="fontSize9">Course & Year: &nbsp;&nbsp;</td>
    <td><%=strCourseCode%> <%=WI.getStrValue(strMajorCode)%> - <%=astrConvertYearLvl[Integer.parseInt(WI.getStrValue(vTemp.elementAt(10),"0"))]%></td>
    <td align="right" class="fontSize9">Curriculum : &nbsp;&nbsp;</td>
    <td>&nbsp; <%=(String)vTemp.elementAt(8)%>-<%=(String)vTemp.elementAt(9)%></td>
  </tr>
</table>
<%}//only vTemp is not null -- having residency summary.

if(vRetResult != null){
String strPrevYr  = null;
String strCurYr   = null;
int iPrevSem = 0;
int iCurSem  = 0;

int i = 0;
int iLineCount = 0;
double dTotalUnit = 0d;


double dSubjectUnit = 0d;
double dCreditEarned = 0d;
double dLakcingCredit = 0d;

%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<!--------------------------------------------MAIN BODY------------------------------------------------------------->
		<td height="860" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="50%">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
							  <td class="thinborderBOTTOMTOP" height="20" width="20%"><strong>Subject</strong></td>
							  <td class="thinborderBOTTOMTOP" width="55%"><strong>Descriptive Title</strong></td>
							  <td class="thinborderBOTTOMTOP" width="7%"><strong>Unit</strong></td>
							  <td class="thinborderBOTTOMTOP" width="18%"><strong>Status</strong></td>
							</tr>
						</table>
					</td>
					<td width="50%">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
							  <td height="20" width="20%" class="thinborderBOTTOMTOP"><strong>Subject</strong></td>
							  <td width="51%" class="thinborderBOTTOMTOP"><strong>Descriptive Title</strong></td>
							  <td width="7%" class="thinborderBOTTOMTOP"><strong>Unit</strong></td>
							  <td width="22%" class="thinborderBOTTOMTOP"><strong>Status</strong></td>
							</tr>
						</table>
					</td>
				</tr>

				  <%for(; i< vRetResult.size();){
				  	//System.out.println(vRetResult.elementAt(i+1));
					iLineCount += 1;
					dTotalUnit = 0d;
					iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
					if(iCurSem == 3)
						iCurSem = 0;
				  	%>

				  <!----------------YEAR----------------------------->
				  <tr>
					<td colspan="2" align="left">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
							<tr>
							<td width="10%">&nbsp;</td><td>
								<strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i),"0"))]%></strong>
							</td></tr>
						</table>
					</td>
				  </tr>

				  <tr>
					<!-------------------FIRST SEM--------------------------->
					<td width="50%" valign="top">
					<%

					//System.out.println(WI.getStrValue(vRetResult.elementAt(i+1)));
					if(iCurSem == 1){
					%>
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<%for(; i< vRetResult.size();){//1st semester only.
						iLineCount += 1;
						iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
						if(iCurSem != 1)
							break;
						dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
						//strTemp = WI.getStrValue(vRetResult.elementAt(i+14));
						/*if(strTemp.length() == 0) {
							int iIndexOf = vInProgress.indexOf(vRetResult.elementAt(i + 3));
							if(iIndexOf > -1) {
								strTemp = "IP";
							}
						}*/
						strTemp = WI.getStrValue(vRetResult.elementAt(i+15));
						if(strTemp.equalsIgnoreCase("Passed")) {
							strTemp = WI.getStrValue(vRetResult.elementAt(i+15));
							
							dSubjectUnit = Double.parseDouble((String)vRetResult.elementAt(i + 10));
							dCreditEarned = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 13), "0"));
							dLakcingCredit = dSubjectUnit - dCreditEarned;
							
							if(dLakcingCredit > 0d)
								strTemp = "Lacking "+dLakcingCredit+" Unit(s)";
						}
						else
							strTemp = "_____";
						%>
						<tr>
						  <td width="20%" class="fontSize9"><%=(String)vRetResult.elementAt(i+4)%></td>
						  <td width="55%" class="fontSize9"><%=(String)vRetResult.elementAt(i+5)%></td>
						  <td width="7%" class="fontSize9"><%=(String)vRetResult.elementAt(i+10)%></td>
						  <td width="18%" class="fontSize9"><%=strTemp%></td>
						</tr>
						<%i += 16;}//prints only 1st semester. - Inner for loop%>
						<tr><td colspan="5">&nbsp;</td></tr>
					  </table>
					  <%}//only for 1st year.%>
					</td>


					<!----------------------SECOND SEM---------------------------->

					<td width="50%" valign="top">
					<%
					//dTotalUnit =0d;
					//iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));

					if(iCurSem == 2){
					%>
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<%for(; i< vRetResult.size();){//1st semester only.
						iLineCount += 1;
						iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
						if(iCurSem != 2)
							break;
						dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
						//strTemp = WI.getStrValue(vRetResult.elementAt(i+14));
						/*if(strTemp.length() == 0) {
							int iIndexOf = vInProgress.indexOf(vRetResult.elementAt(i + 3));
							if(iIndexOf > -1) {
								strTemp = "IP";
							}
						}*/
						strTemp = WI.getStrValue(vRetResult.elementAt(i+15));
						if(strTemp.equalsIgnoreCase("Passed")) {
							strTemp = WI.getStrValue(vRetResult.elementAt(i+15));
							
							///check if any lacking unit.. 
							
							dSubjectUnit = Double.parseDouble((String)vRetResult.elementAt(i + 10));
							dCreditEarned = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 13), "0"));
							dLakcingCredit = dSubjectUnit - dCreditEarned;
							
							if(dLakcingCredit > 0d)
								strTemp = "Lacking "+dLakcingCredit+" Unit(s)";							
						}
						else
							strTemp = "_____";
						%>
						<tr>
						  <td width="20%" class="fontSize9"><%=(String)vRetResult.elementAt(i+4)%></td>
						  <td width="55%" class="fontSize9"><%=(String)vRetResult.elementAt(i+5)%></td>
						  <td width="7%" class="fontSize9"><%=(String)vRetResult.elementAt(i+10)%></td>
						  <td width="18%" class="fontSize9"><%=strTemp%></td>
						</tr>
						<%i += 16;}//prints only 1st semester. - Inner for loop%>
						<tr><td colspan="5">&nbsp;</td></tr>
					  </table>
					  <%}//only for 1st year.%> </td>

				  </tr>





				  <!----------------------SUMMER----------------------------->
				  <%
				//iCurSem = 1;
				//dTotalUnit = 0d;
				//if(i < vRetResult.size())
					//iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
				//System.out.println("iCurSem "+iCurSem);
				if(iCurSem == 0) {
				%>
				  <tr>
					<td align="center" width="50%">
						<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td>&nbsp;</td>
						  <td align="left"><strong>SUMMER</strong></td>
						</tr>
						<%for(; i< vRetResult.size();){//1st semester only.

						iLineCount += 1;
						iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
						if(iCurSem == 3)
							iCurSem = 0;

						if(iCurSem != 0)
							break;

						dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
						//strTemp = WI.getStrValue(vRetResult.elementAt(i+14));
						/*if(strTemp.length() == 0) {
							int iIndexOf = vInProgress.indexOf(vRetResult.elementAt(i + 3));
							if(iIndexOf > -1) {
								strTemp = "IP";
							}
						}*/
						strTemp = WI.getStrValue(vRetResult.elementAt(i+15));
						if(strTemp.equalsIgnoreCase("Passed")) {
							strTemp = WI.getStrValue(vRetResult.elementAt(i+15));
							
							dSubjectUnit = Double.parseDouble((String)vRetResult.elementAt(i + 10));
							dCreditEarned = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 13), "0"));
							dLakcingCredit = dSubjectUnit - dCreditEarned;
							
							if(dLakcingCredit > 0d)
								strTemp = "Lacking "+dLakcingCredit+" Unit(s)";
						}
						else
							strTemp = "_____";
						%>
						<tr>
						  <td width="20%" class="fontSize9"><%=(String)vRetResult.elementAt(i+4)%></td>
						  <td width="55%" class="fontSize9"><%=(String)vRetResult.elementAt(i+5)%></td>
						  <td width="7%" class="fontSize9"><%=(String)vRetResult.elementAt(i+10)%></td>
						  <td width="18%" class="fontSize9"><%=strTemp%></td>
						</tr>
						<%i += 16;}//prints only 1st semester. - Inner for loop%>
						<tr><td colspan="5">&nbsp;</td></tr>
					  </table>
				    </td>
					 <td>&nbsp;</td>
				  </tr>
				  <%}//end of display summer.


				  if(iLineCount == 43){%>
				  	<DIV style="page-break-before:always" >&nbsp;</DIV>
				<%}
				}//end of for loop to display grade/course evaluation
				%>

				  <tr>
				  <%
				  	double dToTake = Double.parseDouble((String)vTemp.elementAt(12)) - Double.parseDouble((String)vTemp.elementAt(13));
					if(dToTake < 0d)
						dToTake = 0d;
				  %>
					<td class="fontSize9">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						TOTAL UNITS Earned: <%=WI.getStrValue(vTemp.elementAt(13))%>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						To Take: <%=dToTake%>
					</td>
					<td class="fontSize9">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Printed by:
						<%=(CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1))%></td>
				  </tr>
		  </table>
		</td>
	</tr>









	<!--------------------------------------------FOOTER------------------------------------------------------------->
	<tr>
		<td>
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td align="center" height="25"><u><strong><font size="3">'BE RESPONSIBLE'</font>,
						<font size="2">please read, review and verify before signing...</font></strong></u></td>
				</tr>
				<tr><td align="center" height="20"><u><strong>STUDENT'S UNDERTAKING</strong></u></td></tr>
				<tr>
				  <td class="fontSize9">
				I have read carefully the evaluation of subjects that I have taken and passed. I understand that any errors or discrepancy in the evaluation
				<u>should be verified immediately</u> with my Record in-Charge at the Registrar's Office.
				This temporary evaluation is subject to the final evaluation of the School Registrar which will be used as basis for graduation.
				Any deficiency in the subjects and units in the curriculum will disqualify me for graduation.
				</td>
				</tr>
				<tr><td height="25">&nbsp;</td></tr>
				<tr><td align="center" valign="bottom"><u><strong>
					<%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),1)%></strong></u></td></tr>
				<tr><td valign="top" align="center">Student's name and Signature</td></tr>

				<tr><td height="20" align="center" valign="bottom"><u>Note:</u> &nbsp;&nbsp;&nbsp; The student's temporary evaluation <u>must be signed</u> by the student and <u>attached to the enrollment form</u>.
				</td>
				</tr>
				<tr><td align="center">Students may photocopy this evaluation for their file.</td></tr>
			</table>
		</td>
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
