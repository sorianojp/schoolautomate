<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp2 = null;
	String strTemp3 = null;
//add security here.
	try
	{ 
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Releasing print","grade_releasing_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
						request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));

//System.out.println(vStudInfo);
Vector vGradeDetail = null;
Vector vAdditionalInfo = null;
Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;




if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	//get grade sheet release information.

	boolean bolIncludeEnrolledSubject = true;
	
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),
											request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),true,bolIncludeEnrolledSubject,true,bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

//	System.out.println(vAdditionalInfo);
//	System.out.println(vStudInfo);

	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	vEditInfo = pif.viewPermStudPersonalInfo(dbOP,request.getParameter("stud_id"));
}




if(strErrMsg == null) strErrMsg = "";

double dTotalUnits = 0d;

/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;
if(vGradeDetail != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}



boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
//System.out.println("bolIsFinal : "+bolIsFinal+"  grade_name : "+ WI.fillTextValue("grade_name"));


String strGradeCGH = null;
java.sql.PreparedStatement pstmtGetPercentGrade = dbOP.getPreparedStatement("select grade_cgh from g_sheet_final where gs_index = ?");


Vector vRemovalGSIndex   = new Vector();
Vector vSubmittedGSIndex = new Vector();
String strRemovalGrade = null;

String strSQLQuery = "select gs_index,IS_REMOVAL_WUP,(select DATE_SUBMITTED_WUP from faculty_load where sub_sec_index = g_sheet_final.sub_sec_index and faculty_load.is_valid = 1), "+
				"sub_sec_index from g_sheet_final where user_index_ = "+vStudInfo.elementAt(0)+" and is_valid = 1";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	if(rs.getInt(2) == 1)
		vRemovalGSIndex.addElement(rs.getString(1));
	if(rs.getString(4) == null)//migrated/encoded by reg :: show it.
		vSubmittedGSIndex.addElement(rs.getString(1));
	if(rs.getDate(3) != null)
		vSubmittedGSIndex.addElement(rs.getString(1));
}
rs.close();


%>

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
    TD.thinborder {

    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;

	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderTopRightBottom {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.thinborderTopBottom {
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>

</head>

<body topmargin="1" bottommargin="0" <%if(WI.getStrValue(strErrMsg).length() ==0){%> onLoad="window.print()"<%}%>>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" align="center"><%=strErrMsg%></td>
    </tr>
</table>

<%
if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){

%>

<table width="100%" border="0" cellspacing="0" cellpadding="0"> 
    <tr ><td height="60">&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>GRADE REPORT</strong></td></tr>
	<tr><td align="center" height="20" valign="top"><%=request.getParameter("sem_name").toUpperCase()%>, SY <%=request.getParameter("sy_from")%>-<%=request.getParameter("sy_to")%></td></tr>
	<tr><td>OFFICIAL GRADE REPORT OF: <strong><%=(String)vStudInfo.elementAt(1)%></strong></td></tr>
	<tr><td>COURSE: <i><%=(String)vStudInfo.elementAt(18)%> <%=WI.getStrValue((String)vStudInfo.elementAt(19)," MAJOR IN ","","").toUpperCase()%></i></td></tr>
</table>
<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
  
  <tr>
		<td align="center" width="15%" height="20" class="thinborderTopRightBottom">Subject</td>
		<td align="center" class="thinborderTopRightBottom">Descriptive Title</td>
		<td align="center" class="thinborderTopRightBottom" width="10%">Grade</td>
		<td align="center" class="thinborderTopRightBottom" width="10%">Removal</td>
		<td align="center" class="thinborderTopRightBottom" width="10%">Units</td>
		<td align="center" width="15%" class="thinborderTopBottom">Remarks</td>
	</tr>
  
  <%
   int iSubjCount = 0;
   int iRowSize = 8;
   int k = 0;

   if (bolIncludeSchedule)
   		iRowSize =9;
   Vector vScheduleDetails = null;

String strGradeValue = null;
String strSubCode    = null; //System.out.println(vGradeDetail);
for(int i=0; i< vGradeDetail.size(); i +=iRowSize){
	++iSubjCount;
	strSubCode = (String)vGradeDetail.elementAt(i + 1);
	
	strGradeValue = (String)vGradeDetail.elementAt(i+5);
	
	
	if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
		bolPutParanthesis = true;
		try {
			double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(i + 5));			
			bolPutParanthesis = true; 
			if(dGrade < 5d)
				vGradeDetail.setElementAt("(3.0)",i + 3);
			else 
				vGradeDetail.setElementAt("(0.0)",i + 3);			
		}
		catch(Exception e){vGradeDetail.setElementAt("(0.0)",i + 3);}
	}
	else	
		bolPutParanthesis = false;	



if(vGradeDetail.elementAt(i) == null) {	
		strTemp = " colspan=3";
}else
	strTemp = "";
//added to show grade not verified instead of grade and remark.
//System.out.println("I am here. :"+vGradeDetail.elementAt(i + 7));
				if(vRemovalGSIndex.indexOf(vGradeDetail.elementAt(i)) > -1) {
					strRemovalGrade = strGradeValue;
					strGradeValue = "&nbsp;";
				}
				else {
					strRemovalGrade = "&nbsp;";
				}

				if(vSubmittedGSIndex.indexOf(WI.getStrValue(vGradeDetail.elementAt(i))) == -1) {
					strGradeValue = "NGS";
					vGradeDetail.setElementAt("NGS",i + 6);//remarks.
					vGradeDetail.setElementAt("&nbsp;",i + 3);//units.
				}
				else if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal) {	
					strGradeValue = "WDA";
					vGradeDetail.setElementAt("WDA",i + 6);
					vGradeDetail.setElementAt("&nbsp;",i + 3);
				}

%>
  <tr>
		<td width="15%" height="20"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
		<td ><%=(String)vGradeDetail.elementAt(i+2)%></td>
		<td align="center" width="10%"><%=strGradeValue%></td>
		<td align="center" width="10%"><%=strRemovalGrade%></td>
		<td align="center" width="10%">
			<%
			strGradeValue = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0");%>
				<%=strGradeValue%>
		</td>
		<td width="15%" align="center"><%=(String)vGradeDetail.elementAt(i+6)%></td>
	</tr>
	  
<%} // end for loop%>
	
	<tr><td height="20" colspan="6" align="center"> 
	-------------------------------------------------- NOTHING FOLLOWS -------------------------------------------------- </td></tr>
</table>

<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td width="70%">Printed by:</td><td align="center">Certified Correct:</td></tr>
	<tr><td><%=WI.getTodaysDateTime()%></td></tr>
	<tr><td height="20">&nbsp;</td></tr>
	<tr><td>Legend: INC - Incomplete</td></tr>
	<tr><td>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; NGS - No Grading Sheet</td><td align="center">JULIE V. CABLING</td></tr>
	<tr><td>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; WDA - Waiting for Dean's Approval</td><td align="center">Officer in Charge</td></tr>
</table>

<%}//only if vStudInfo and vGradeDetail are not null
dbOP.cleanUP();
%>
</body>
</html>
