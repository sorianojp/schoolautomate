<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector,java.util.* " %>

<%
	WebInterface WI = new WebInterface(request);
	String strTemp = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	//System.out.println("strSchCode "+strSchCode);
	if(strSchCode == null)
		strSchCode = "";


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

CommonUtil comUtil = new CommonUtil();

Vector vEntranceData = null;
Vector vGradeDetail = null;
Vector vAdditionalInfo = null;
Vector[] vEditInfo = null;

Vector vPrelimGrade = new Vector();
Vector vMtermGrade  = new Vector();
int iIndexOf = 0;

String[] astrConvertSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};

GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
						request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));

if(vStudInfo != null && vStudInfo.size() > 0) {
enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);

if(vEntranceData == null)
		strErrMsg = entranceGradData.getErrMsg();
}

boolean bolIncludeSchedule = false;
//System.out.println(strSchCode);

if (strSchCode.startsWith("CPU")){
	bolIncludeSchedule = true;
}



if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	//get grade sheet release information.

	boolean bolIncludeEnrolledSubject = true;
	if(strSchCode.startsWith("WNU")){
		String strExcludeList = "#08-95138#,#08-94456#,#06-90163#,#95-02645#,#05-00356#,#08-94070#,#08-94472#,#07-90687#,#08-93114#,#07-91444#,#08-93878#,#07-92340#,#07-91577#,#07-92744#,#08-93053#,#06-90168#,#07-92697#,#07-91191#,#08-94889#,#08-94477#,#08-94853##05-03733#,#07-92704#,#07-92510#,#07-92297#,#06-02003#,#08-94071#,#07-92588#,#06-90221#,#84-02549#,#07-92008#,#08-94287#,#07-91517#,#09-1348-245#,#08-94156#,#07-92587#,#08-93021#,#07-91246#,#08-94747#,#06-90026#,#07-91855#";
		if(strExcludeList.indexOf("#"+request.getParameter("stud_id")+"#") > -1)
			bolIncludeEnrolledSubject = false;
	}
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),
											request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),true,bolIncludeEnrolledSubject,true,bolIncludeSchedule);
	//System.out.println("vGradeDetail "+vGradeDetail);

	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

	if(vAdditionalInfo == null)
		strErrMsg = studInfo.getErrMsg();

	//int iAge = comUtil.calculateAGE("1987/10/26");

	//System.out.println(WI.formatDate((String)vAdditionalInfo.elementAt(1),2));
	//System.out.println(iAge);
	//System.out.println("vStudInfsso "+vAdditionalInfo);


	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	vEditInfo = pif.viewPermStudPersonalInfo(dbOP,request.getParameter("stud_id"));
}


if(strSchCode == null)
	strSchCode = "";
//strSchCode = "AUF";

if(strErrMsg == null) strErrMsg = "";

double dTotalUnits = 0d;


boolean bolIsCGH = false;
if(strSchCode.startsWith("CGH"))
	bolIsCGH = true;
boolean bolIsDBTC = strSchCode.startsWith("DBTC");

boolean bolIsCollegeOnly = false;
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("CSA"))
	bolIsCollegeOnly = true;

/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;
if(vGradeDetail != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}
//System.out.println(strErrMsg);
if(strSchCode.startsWith("UDMC") && (strErrMsg == null || strErrMsg.length() == 0) ) {
	enrollment.ReportRegistrar RR = new enrollment.ReportRegistrar();
	RR.operateOnGradeReleasePrint(dbOP, request, 1);
}


boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
//System.out.println("bolIsFinal : "+bolIsFinal+"  grade_name : "+ WI.fillTextValue("grade_name"));


String strGradeCGH = null;
java.sql.PreparedStatement pstmtGetPercentGrade = dbOP.getPreparedStatement("select grade_cgh from g_sheet_final where gs_index = ?");
boolean bolIsCLDH  = strSchCode.startsWith("CLDH");
if(!bolIsFinal)
	bolIsCLDH = false;
if(strSchCode.startsWith("UL")) {
	bolIsCLDH = true;
}

//get here prelim and mterm grade..
if(vGradeDetail != null && vGradeDetail.size() > 0) {
	String strSQLQuery = "select pmt_sch_index from fa_pmt_schedule where exam_name like 'prelim%'";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strSQLQuery = rs.getString(1);
		if(rs.next())
			strSQLQuery = strSQLQuery +", "+rs.getString(1);
		rs.close();
		strSQLQuery = "select grade, remark_abbr, sub_code from grade_sheet "+
			"join stud_curriculum_hist on (stud_curriculum_hist.cur_hist_index = grade_sheet.cur_hist_index) "+
			"join remark_status on (remark_status.remark_index = grade_sheet.remark_index)  "+
			"join subject on (subject.sub_index = s_index) "+
			"where grade_sheet.is_valid = 1 and pmt_sch_index = ("+strSQLQuery+") and user_index_ = "+(String)vStudInfo.elementAt(0)+
			" and sy_from = "+request.getParameter("sy_from")+" and semester = "+request.getParameter("semester");
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			strTemp = rs.getString(1);
			if(strTemp == null)
				strTemp = rs.getString(2);

			vPrelimGrade.addElement(strTemp);
			vPrelimGrade.addElement(rs.getString(3));
		}
		rs.close();
	}
	else
		rs.close();

	strSQLQuery = "select pmt_sch_index from fa_pmt_schedule where exam_name like 'mid%'";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strSQLQuery = rs.getString(1);
		if(rs.next())
			strSQLQuery = strSQLQuery +", "+rs.getString(1);
		rs.close();
		strSQLQuery = "select grade, remark_abbr, sub_code from grade_sheet "+
			"join stud_curriculum_hist on (stud_curriculum_hist.cur_hist_index = grade_sheet.cur_hist_index) "+
			"join remark_status on (remark_status.remark_index = grade_sheet.remark_index)  "+
			"join subject on (subject.sub_index = s_index) "+
			"where grade_sheet.is_valid = 1 and pmt_sch_index in ("+strSQLQuery+") and user_index_ = "+(String)vStudInfo.elementAt(0)+
			" and sy_from = "+request.getParameter("sy_from")+" and semester = "+request.getParameter("semester");
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			strTemp = rs.getString(1);
			if(strTemp == null)
				strTemp = rs.getString(2);

			vMtermGrade.addElement(strTemp);
			vMtermGrade.addElement(rs.getString(3));
		}
		rs.close();
	}
	else
		rs.close();
}


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

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

	TD.fontGeneva{
		font-family:Geneva, Arial, Helvetica, sans-serif;
		size: 11px;
	}

</style>

</head>

<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0" onLoad="window.print()">

<%
if(strErrMsg == null || strErrMsg.length() == 0){
if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){

%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="150" align="center">&nbsp;</td>
    </tr>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<!---------------------UPPER------------------------->

	<tr>
		<td width="100%">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td width="11%">Semester</td>
					<td colspan="5">: <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%> <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
				</tr>
				<tr>
					<td>ID No.</td>
					<td width="17%">: <%=request.getParameter("stud_id")%></td>
					<td width="16%">Course</td>
					<td width="56%">: <%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(4),"&nbsp;","","")%></td>
				</tr>
				<tr>
					<td>Name</td>
					<td colspan="3">: <%=(String)vStudInfo.elementAt(1)%></td>
				</tr>

				<tr><td colspan="5">&nbsp;</td></tr>

				<tr>
					<td>Address</td>
					<td colspan="3">: <%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%></td>
				</tr>

				<tr>
					<td>Age</td>
					<td>: <%=WI.getStrValue((String)vAdditionalInfo.elementAt(22), "&nbsp;")%></td>
					<td>Sex</td>
					<td>: <%=WI.getStrValue((String)vAdditionalInfo.elementAt(0))%></td>
				</tr>

				<tr>
					<td>Birthdate</td>
					<td>: <%=WI.getStrValue((String)vAdditionalInfo.elementAt(1))%></td>
					<td>Birthplace</td>
					<td>: <%=WI.getStrValue((String)vAdditionalInfo.elementAt(2))%></td>
				</tr>

				<tr>
					<td>Parents/Guardian</td>
					<td colspan="3">: <%
						String strGuardian = null;
						String strMother = null;
						strTemp = (String)vAdditionalInfo.elementAt(8);
						if(strTemp == null){
							strMother = (String)vAdditionalInfo.elementAt(9);
							strTemp = strMother;

							}

						if(strMother == null && strTemp == null)
							strTemp = (String)vAdditionalInfo.elementAt(13);


					%>
                    <%=WI.getStrValue(strTemp)%></td>

				</tr>

				<tr><td colspan="5">&nbsp;</td></tr>

				<tr>
					<td colspan="2">Secondary School/Year</td>
					<%if(vEntranceData != null)
						strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
					  else
						strTemp = "&nbsp;";
					%>
					<td colspan="2">: <%=strTemp%></td>
				</tr>

				<tr>
					<td colspan="2">Last School Attended</td>
					<% if (vEntranceData != null && vEntranceData.size()>0){
						strTemp = (String)vEntranceData.elementAt(7);
						if (strTemp == null)
							strTemp = (String)vEntranceData.elementAt(5);
					   }
					%>
					<td colspan="2">: <%=WI.getStrValue(strTemp)%></td>
				</tr>
			</table>
		</td>
	</tr>

</table>

	<!---------------------LOWER------------------------->


<div style="height:60px;">&nbsp;</div>
		<div style="width:100%;">
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
			/**	if(vMathEnglEnrichment != null &&
					WI.getStrValue(vGradeDetail.elementAt(i+6)).toLowerCase().startsWith("p") &&
						vMathEnglEnrichment.indexOf(strSubCode) != -1)
					bolPutParanthesis = true;
				else
					 bolPutParanthesis = false;
			**/
				if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
					bolPutParanthesis = true;
					try {
						double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(i + 5));
						//System.out.println(dGrade);
						bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
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
				if(bolIsCGH)
					strTemp = " colspan=2";
				else if (strSchCode.startsWith("CPU"))
					strTemp = " colspan=2";
				else
					strTemp = " colspan=3";
			}
			else
				strTemp = "";

			//added to show grade not verified instead of grade and remark.
			//System.out.println("I am here. :"+vGradeDetail.elementAt(i + 7));
			if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal) {
				//strTemp = " colspan=2";
				vGradeDetail.setElementAt("&nbsp;",i);
				vGradeDetail.setElementAt("-=*=-", i + 5);
				vGradeDetail.setElementAt("Grades Not Yet Submitted", i + 6);
				strTemp = "  style=\"font-family:Geneva, Arial, Helvetica, sans-serif;font-size:9px;\"";
			}

			%>

			  	<!-- <td valign="top" width="10%" class="fontGeneva">&nbsp;<%//=(String)vGradeDetail.elementAt(i)%></font></td> -->
				<div style="width:15%;  float:left;" class="fontGeneva"><%=(String)vGradeDetail.elementAt(i + 1)%></div>

				<div style="width:35%; overflow:hidden;  float:left;" class="fontGeneva" >
                	<div style="white-space:nowrap; padding:0px 5px 0px 0px;">
             			<%=(String)vGradeDetail.elementAt(i+2)%>
             		</div>
               </div>


			<%
			//System.out.println("vGradeDetail.elementAt(i) "+vGradeDetail.elementAt(i));
			strGradeValue = (String)vGradeDetail.elementAt(i+5);
			if(strGradeValue != null && (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
				strGradeValue = strGradeValue+"0";
			if(strGradeValue != null && strGradeValue.startsWith("Grade not encoded"))
				strGradeValue = "GNA";

			iIndexOf = vPrelimGrade.indexOf((String)vGradeDetail.elementAt(i + 1));
			if(iIndexOf > -1)
				strTemp = (String)vPrelimGrade.elementAt(iIndexOf - 1);
			else
				strTemp = "&nbsp;";
			iIndexOf = vMtermGrade.indexOf((String)vGradeDetail.elementAt(i + 1));
			if(iIndexOf > -1)
				strErrMsg = (String)vMtermGrade.elementAt(iIndexOf - 1);
			else
				strErrMsg = "&nbsp;";

			%>
				<!---------------------------- GRADES ------------------------------------->
				<div style="width:8%; text-align:center; float:left;"><%=strTemp%></div>
				<div style="width:7%; text-align:center;  float:left;"><%=strErrMsg%></div>
				<div style="width:7%; text-align:center;  float:left;"><%=strGradeValue%></div>

				<!---------------------------- REMARKS HERE ------------------------------------->
				<div style="width:7%; float:left;"  <%//=strTemp%>><%=WI.getStrValue((String)vGradeDetail.elementAt(i+6))%></div>

               <!---------------------------- UNITS HERE ------------------------------------->
        	   <div style="width:7%; text-align:center;  float:left;"><%=(String)vGradeDetail.elementAt(i+3)%></div>

				<!----------INSTRUCTOR NI DRI-------------------->
				<div style="overflow:hidden;  float:left; width:14%;">
                   <div style="white-space:nowrap; padding:0px 5px 0px 0px;"><%=(WI.getStrValue((String)vGradeDetail.elementAt(i+4),"N/F")).toUpperCase()%></div>
                </div>
			<div style="clear:both; padding:0px; margin:0px;"></div>
			 <%
			} // end for loop
			//System.out.println(strSchCode);
			if(strSchCode.startsWith("FATIMA")) {%>
					<div> --= Nothing Follows =-- </div>
			<%}%>
</div>


<%}//only if vStudInfo and vGradeDetail are not null
}//if strErrMsg equal to null
else{%>
<div><%=strErrMsg%></div>
<%}%>
</body>
</html>
<%dbOP.cleanUP();%>
