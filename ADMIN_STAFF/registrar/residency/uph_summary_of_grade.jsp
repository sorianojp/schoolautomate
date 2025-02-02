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
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	
	TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	
	TD.thinborderBOTTOM {    
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	TD.thinborderTOPLEFTBOTTOM {
    border-left: solid 1px #000000;
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
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

	int i=0; int j=0;
	int iYear = 0;
	int iSem  = 0;
	int iTempYear = 0;
	int iTempSem = 0;
	int iSchYrFrom = 0;
	int iTempSchYrFrom = 0;
	float fTotalUnitPerSem = 0;
	double dGWA         = 0d;	


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-RESIDENCY STATUS MONITORING","residency_status_print_UPHSD.jsp");
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
														"Registrar Management","RESIDENCY STATUS MONITORING",request.getRemoteAddr(),
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
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();

Vector vRetResult = null;
Vector vTemp = null;
Vector vAdditionalInfo = null;
Vector vResDetail = null;

Vector vTFInfo = new Vector();
double dTotCreditEarnedOtherSchool = 0d;


if(WI.fillTextValue("stud_id").length() > 0) {
	
	/**vTFInfo = GSTransferee.viewFinalGradePerYrSemTransferee(dbOP,request.getParameter("stud_id"),true);
	
	if(vTFInfo != null && vTFInfo.size() > 0){			
		for(i=0; i< vTFInfo.size(); )
		{	
			iSem = Integer.parseInt((String)vTFInfo.elementAt(i+10));
			iSchYrFrom = Integer.parseInt((String)vTFInfo.elementAt(i+8));			
			 for(j=i; j< vTFInfo.size();)
			 {
				iTempSem = Integer.parseInt((String)vTFInfo.elementAt(i+10));
				iTempSchYrFrom = Integer.parseInt((String)vTFInfo.elementAt(i+8));
		
				if(iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)
					break;	
				dTotCreditEarnedOtherSchool += Double.parseDouble((String)vTFInfo.elementAt(j+3));			
				j = j + 13;
				i = j;
			}
		}
	}*/
	
	vTemp = GS.getResidencySummary(dbOP, WI.fillTextValue("stud_id"));
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
	/**else {
	
		strTemp = " and (stud_curriculum_hist.course_type = 0 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 4)";
		vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vTemp.elementAt(0),"0", strTemp);
		
		
		
		/**vRetResult = SE.getCurriculumResidencyEval(dbOP,(String)vTemp.elementAt(0),(String)vTemp.elementAt(15),
                                           (String)vTemp.elementAt(16),(String)vTemp.elementAt(8),(String)vTemp.elementAt(9),
                                           (String)vTemp.elementAt(11));
		if(vRetResult == null || vRetResult.size() ==0)
			strErrMsg = SE.getErrMsg();
	}*/
	
	
	else{
		//strUserIndex = (String)vResSummary.elementAt(0);
		String strTempQuery  = null;
		String strCourseType = null;
	if (WI.fillTextValue("selCourse").length()>0) {
			if (WI.fillTextValue("selCourse").equals("under"))
			{
				strTempQuery = " and (stud_curriculum_hist.course_type = 0 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 4)";
				vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vTemp.elementAt(0),"0", strTempQuery);
				strCourseType = "0";
			}
			else if (WI.fillTextValue("selCourse").equals("post"))
			{
				strTempQuery = " and (stud_curriculum_hist.course_type = 1 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 2)";
				vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vTemp.elementAt(0),"1", strTempQuery);
				strCourseType = "1";
			}
			else
			{
				String strTempCourse = WI.getStrValue(WI.fillTextValue("c_idx"+WI.fillTextValue("selCourse")),"");
				String strTempMajor = WI.getStrValue(WI.fillTextValue("d_idx"+WI.fillTextValue("selCourse")),"");
				String strTempType = WI.getStrValue(WI.fillTextValue("c_type"+WI.fillTextValue("selCourse")),"");
				if (strTempCourse.length()>0 && strTempType.length()>0)
				{
					strTempQuery = " and stud_curriculum_hist.course_index = "+strTempCourse;
					if (!strTempType.equals("1"))
						strTempQuery += " and (stud_curriculum_hist.course_type = 0 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 4)";
					if (strTempMajor.length()>0)
						strTempQuery += " and stud_curriculum_hist.major_index = "+strTempMajor;
					vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vTemp.elementAt(0),strTempType, strTempQuery);
				}
				strCourseType = strTempType;
			}
			//System.out.println(strTempQuery);System.out.println(GS.getErrMsg());
		}
		//else
		///	vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vTemp.elementAt(0),"0", strTempQuery);

		
		
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vTemp.elementAt(0));
		
		if(vAdditionalInfo == null)
			strErrMsg = studInfo.getErrMsg();
	}
	
	//I have to get the GWA for all the subjects completed so far.
	student.GWA gwa = new student.GWA();
	dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));
}

Vector vInProgress  = new Vector();

if(strErrMsg == null && vTemp != null && vTemp.size() > 0) { //save print information :: 
	String strSYFrom   = (String)vTemp.elementAt(17);
	String strSemester = (String)vTemp.elementAt(18);
	
	String strSQLQuery = "select cur_index from enrl_final_cur_list where is_valid = 1 and user_index = "+vTemp.elementAt(0)+" and sy_from = "+
		strSYFrom+ " and current_semester="+strSemester+" and is_temp_stud = 0";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
	while(rs.next())
		vInProgress.addElement(rs.getString(1));
	rs.close();	
}


if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td width="98%" height="20" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  
<%}

if(vResDetail != null && vResDetail.size() > 0){ 

int iCurSem  = 0;

double dTotalUnit = 0d;

boolean bolIsPageBreak = false;
int iResultSize = 13;
int iLineCount = 0;
int iMaxLineCount = 37;	
int iCount = 0;	


String strAdvSem = "";
String strPrevSem = "";

int iIndexOf = 0;

while(iResultSize <= vResDetail.size()){

iLineCount = 0;


if(vTemp != null && vTemp.size()>0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
<tr>
<td height="20"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
<br><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><u>Summary of Student Grade</u>
</strong></div><br><br><br></td>
</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="12%" height="20"><strong>Student No.</strong></td>
		<td width="60%">: <%=WI.fillTextValue("stud_id")%></td>
		<td><strong>Year Level :</strong> &nbsp; <%=(String)vTemp.elementAt(10)%></td>
	</tr>
	<tr>
		<td width="12%" height="20"><strong>Name</strong></td>
		<td colspan="2">: <strong><%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),1)%></strong></td>
	</tr>
	<tr>
		<td width="12%" height="20"><strong>Course</strong></td>
		<td colspan="2">: <%=(String)vTemp.elementAt(6)%></td>
	</tr>
	<tr>
		<td width="12%" height="20"><strong>Address</strong></td>
		<td colspan="2">: <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%> 
			<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%>
			<%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%>
			<%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%> <%}%></td>
	</tr>
</table>

<%}//only vTemp is not null -- having residency summary.%>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>					
		<td width="15%" class="thinborderTOPBOTTOM" align="center" height="25">SUBJ CODE</td>
		<td width="" class="thinborderTOPBOTTOM" align="center">DESCRIPTIVE TITLE</td>
		<td width="5%" class="thinborderTOPBOTTOM" align="center">UNITS</td>
		<td width="10%" class="thinborderTOPBOTTOM" align="center">GRADE</td>
		<td width="10%" class="thinborderTOPBOTTOM" align="center">COMPLETION</td>
	</tr>
	
    <%
	for( ;i < vResDetail.size(); ){
	
	iCurSem = Integer.parseInt(WI.getStrValue(vResDetail.elementAt(i+1),"6"));
	
	iResultSize += 13;
	iLineCount++;
	
	iIndexOf = i + 14;
	if(iIndexOf > vResDetail.size()){}
	else
		strAdvSem = (String)vResDetail.elementAt(iIndexOf);
	
	try {
		fTotalUnitPerSem += Float.parseFloat(WI.getStrValue(vResDetail.elementAt(i+8),"0"));
	}catch(Exception e){}
	%>
	 
	<%
		if(!strPrevSem.equals(Integer.toString(iCurSem)) || i == 0){			
			strPrevSem = Integer.toString(iCurSem);
			iLineCount++;
	%>
	<tr>      	
    	<td colspan="5" class="thinborderTOPBOTTOM">
			ACADEMIC YEAR <%=(String)vResDetail.elementAt(i+10) + " - "+(String)vResDetail.elementAt(i+11)%>
			SEMESTER <%=iCurSem%>	
		</td>		
    </tr>
	<%}	
	%>
	 
    <tr>      	
      	<td height="19"><%=(String)vResDetail.elementAt(i+2)%></td>
     	<td><%=(String)vResDetail.elementAt(i+3)%></td>     	
	<%
		strTemp = WI.getStrValue(vResDetail.elementAt(i+8),"0");		
	%>
      	<td align="right"><%=CommonUtil.formatFloat(strTemp,true)%></td>
      	<td align="center"><%=CommonUtil.formatFloat((String)vResDetail.elementAt(i+6),true)%></td>
	<%
		strTemp = null;
		if(vResDetail.size() > (i + 5 + 13) && vResDetail.elementAt(i + 6) != null && ((String)vResDetail.elementAt(i + 6)).toLowerCase().indexOf("inc") != -1 &&
		((String)vResDetail.elementAt(i + 2)).compareTo((String)vResDetail.elementAt(i + 2 + 13)) == 0 ){			
			strTemp = CommonUtil.formatFloat((String)vResDetail.elementAt(i + 6 + 13),true);
		i += 13;
		}
	%>		
      	<td align="center"><%=WI.getStrValue(strTemp)%></td>	  	
    </tr>
	
	<%
		if(!strAdvSem.equals(Integer.toString(iCurSem)) || i+13 >= vResDetail.size()){
			iLineCount++;
	%>
	
	<tr>							
		<td height="20" colspan="2">&nbsp;</td>
		<td align="right" class="thinborderTOP"><%=CommonUtil.formatFloat(fTotalUnitPerSem,true)%></td>
		<td colspan="2" align="center" class="thinborderTOP">&nbsp;</td>
	</tr>
	
	<%
		fTotalUnitPerSem = 0;
	}%>
		
		
		<%		
		i+=13;
		if(iLineCount >= iMaxLineCount){
			bolIsPageBreak = true;
			break;		
		}else
			bolIsPageBreak = false;
		}		
	%>   
</table>
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}
	
	
	}//end while%>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center" class="thinborderTOPBOTTOM">***Nothing Follows***</td></tr>
	<tr><td height="1"><div style="border-bottom:solid 1px #000000;"></div></td></tr>
	<tr><td><strong>NOTE: FOR EVALUATION PURPOSE ONLY, NOT VALID AS COPY OF TRANSCRIPT
	OF RECORDS.</strong></td></tr>
	<tr><td>NOTED BY: ______________________________</td></tr>
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
