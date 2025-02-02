	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
	<title>Grade Releasing.</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style type="text/css">
	<!--
	body {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
	}
	td {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
	}
	th {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
	}
		TABLE.thinborder {
			border-top: solid 1px #000000;
			border-right: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 10px;
		}
		TABLE.thinborderALL {
			border-top: solid 1px #000000;
			border-bottom: solid 1px #000000;
			border-left: solid 1px #000000;
			border-right: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 10px;
		}
		TD.thinborder {
			border-left: solid 1px #000000;
			border-bottom: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 10px;
		}

		TD.thinborderBottom {
			border-bottom: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 10px;
		}
	-->
	</style>

	</head>
	<script language="javascript">
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';
		document.bgColor = "#FFFFFF";
	}
	var strMaxPage = null;
	var objLabel   = null;
	function ShowProgress(pageCount, maxPage) {
		if(objLabel == null) {
			objLabel = document.getElementById("page_progress");
			strMaxPage = maxPage;
		}
		if(!objLabel)
			return;
		var strShowProgress = pageCount+" of "+strMaxPage;
		objLabel.innerHTML = strShowProgress;
	}
	function UpdateUnitEnrolled(strLabelID, strValue) {
		document.getElementById(strLabelID).innerHTML = strValue;
	}

	</script>
	<body topmargin="1" bottommargin="0" onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">

<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>

			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>

<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);

	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
	String strTemp3   = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");

	String strStudInfoList = (String)request.getSession(false).getAttribute("stud_list");
	//String strStudInfoList = WI.fillTextValue("stud_list");
	if(strStudInfoList == null || strStudInfoList.length() == 0) {
		return;
	}


//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Releasing print", "grade_releasing_print.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
GradeSystem GS        = new GradeSystem();
enrollment.GradeSystemExtn gsEx  = new enrollment.GradeSystemExtn();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
String strSYFrom      = request.getParameter("sy_from");
String strSYTo        = request.getParameter("sy_to");
String strSemester    = request.getParameter("semester");
String strStudID      = null;
String strGradeFor    = request.getParameter("grade_name");
String strTermName    = request.getParameter("sem_name");

String strPmtSchIndex = dbOP.getResultOfAQuery("select pmt_sch_index from fa_pmt_schedule where exam_name = '"+
	strGradeFor+"' and is_valid = 1", 0);


int iPageCount = 1;
//get student information first before getting grade details.
Vector vStudInfo =  null;//pmtUtil.getStudBasicInfoOLD(dbOP, strStudID, strSYFrom, strSYTo, strSemester);

//System.out.println(vStudInfo);
Vector vGradeDetail = null;
Vector vAdditionalInfo = null;
Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;

boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");

String strGradeCGH = null;
boolean bolIsCLDH  = strSchCode.startsWith("CLDH");
if(!bolIsFinal)
	bolIsCLDH = false;

if(strSchCode.startsWith("UL")) {
	bolIsCLDH = true;
}

if (strSchCode.startsWith("CPU")){
	bolIncludeSchedule = true;
}

boolean bolIsCGH = false;
if(strSchCode.startsWith("CGH"))
	bolIsCGH = true;
boolean bolIsDBTC = strSchCode.startsWith("DBTC");

boolean bolIsCollegeOnly = false;
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("CSA"))
	bolIsCollegeOnly = true;



//more than one grade releasing in one page.
int iStudentsPerPage = 1;
int iCount = 1;
//if(strSchCode.startsWith("CSA"))
	iStudentsPerPage = 4;


Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);
java.sql.PreparedStatement pstmt = null;
Vector vTempWrapper = new Vector();
vTempWrapper.addElement(pstmt);

double dUnitEarned = 0d;
double dUnitEnrolled = 0d;
int iStudCount = 0;

//get all sub_sec_index Locked..
Vector vSubSecIndexLocked = gsEx.getSubSecIndexLocked(dbOP, strSYFrom, strSemester, strPmtSchIndex);
if(vSubSecIndexLocked == null)
	vSubSecIndexLocked = new Vector();


String strFooterDatePrinted = WI.getTodaysDate(1);
String strFooterPreparedBy  = (String)request.getSession(false).getAttribute("first_name");



String strMailAddress = null;
java.sql.ResultSet rs = null;
String strSQLQuery = null;
int iRowSize = 8;

String strGradeValue = null;
String strSubCode    = null; //System.out.println(vGradeDetail);
String strCE         = null;

while(vStudList.size() > 0) {///wraps the whole page here..
//System.out.println("Pirnting student : "+vStudList.elementAt(0));
	Thread.sleep(250);
	strStudID = (String)vStudList.remove(0);
//System.out.print("      Remaining to print : "+vStudList.size());
	vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, strStudID, strSYFrom, strSYTo, strSemester);
	if(vStudInfo == null)
		continue;
	//////////////////////////////////////////////////////////////////// get grade mailing address ////////
	strSQLQuery = "select mail_to, mail_house_no, mail_city, mail_province, mail_zip from info_mail_grade where user_index = "+(String)vStudInfo.elementAt(0);
	strMailAddress = null;
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next())
		strMailAddress = rs.getString(1) + "<br>"+rs.getString(2)+" "+rs.getString(3)+"<br>"+rs.getString(5)+" "+rs.getString(4);
	rs.close();
	//////////////////////////////////////////////////////////////////// end of grade mailing address ////////

	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0), strGradeFor, strSYFrom, strSYTo, strSemester, false, true, true, bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();
	//System.out.println(vGradeDetail);
	//System.out.println(strErrMsg);

	student.StudentInfo studInfo = new student.StudentInfo();
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	vEditInfo = pif.viewPermStudPersonalInfo(dbOP,strStudID);

	if(strSchCode == null)
		strSchCode = "";

	double dTotalUnits = 0d;

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

	//I have to use vector to make sure the pstmt is not initialized always.
	dUnitEnrolled = gsEx.getUnitsEnrolledUnitEarned(vTempWrapper, dbOP, (String)vStudInfo.elementAt(0), strSYFrom, strSemester);
	dUnitEarned = 0d;


boolean bolIsPrintLX = WI.fillTextValue("print_lx").equals("1");
%>

<script language="javascript">
	ShowProgress(<%=iPageCount++%>, <%=vStudList.size() + 1%>);
</script>
<!-- End of printing information -->

<%
if(strErrMsg != null){ //|| (iStudCount % iStudentsPerPage > 0)) {%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr >
		  <td height="20" align="center"><%=WI.getStrValue(strErrMsg)%>&nbsp;<br>&nbsp;</td>
		</tr>
	</table>
<%}if(iStudCount >0) {%>
<table height="54px">
	<tr><td>&nbsp;</td></tr>
</table>

<!--<br><br><br><br><br><br>--><%}%>
<%if(iStudCount == 3 && false) {%>
<table height="15px">
	tr><td>&nbsp;</td></tr>
</table>
<%}%>

	  <table border="0" cellspacing="0" cellpadding="0" width="500px">

	  <tr>
		<td width="33%" >&nbsp;</td>
		<td colspan="2" ></td>
	  </tr>
	  <tr>
		<td width="33%" >&nbsp;</td>
		<td colspan="2" ></td>
	  </tr>
	  <tr>
		<td width="33%" >&nbsp;</td>
		<td colspan="2" ></td>
	  </tr>
	  <tr>
		<td>&nbsp;</td>
		<td colspan="2" style="font-size:11px;"><%=(String)vStudInfo.elementAt(1)%></td>
	  </tr>
	  <tr>
	    <td>&nbsp;</td>
	    <td width="35%" style="font-size:11px;"><%=(String)vStudInfo.elementAt(11)%> <%=WI.getStrValue((String)vStudInfo.elementAt(12),"/","","")%><%=WI.getStrValue((String)vStudInfo.elementAt(4), "-", "", "")%></td>
	    <td width="32%" align="right" style="font-size:11px;"><%=request.getParameter("sem_name").toUpperCase()%>,
		<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
      </tr>
	  <tr>
		<td width="33%" >&nbsp;</td>
		<td colspan="2" ></td>
	  </tr>
	</table>
	<table height="<%if(bolIsPrintLX){%>120<%}else{%>120<%}%>" width="400px" border="0" cellspacing="0" cellpadding="0"><tr>
		<td valign='top' width="47%">
			<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderNONE">
			  <tr>
				<td width="20%" height="20"><font size="1"><strong> SUBJECT </strong></font></td>
				<td width="7%" align="center"><font size="1"><strong>GRADES</strong></font></td>
				<td width="8%" align="center"><font size="1"><strong>UNITS</strong></font></td>
			  </tr>
			  <%
			for(int i=0; i< vGradeDetail.size(); i +=2 * iRowSize){
				strSubCode = (String)vGradeDetail.elementAt(i + 1);

				strGradeValue = (String)vGradeDetail.elementAt(i+5);
				if(strGradeValue != null && strGradeValue.startsWith("Grade"))
					strGradeValue = "GNA";
				strCE = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0.0");

				//if subject is not locked ,, force grade is GNA and unit = 0;
				if(GS.vGSIndexLocked.indexOf(vGradeDetail.elementAt(i)) == -1) {
					if(vSubSecIndexLocked.indexOf(vGradeDetail.elementAt(i + 4)) == -1) {
						strCE = "0.0";
						strGradeValue = "GNA";
					}
				}
				dUnitEarned += Double.parseDouble(strCE);

				strTemp = (String)vGradeDetail.elementAt(i+2);
				if(strTemp != null && strTemp.length() > 50)
					strTemp = strTemp.substring(0, 50);

				%>

			  <tr>
				<td valign="top"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
				<td valign="top"><div align="center"><%=strGradeValue%></div></td>
				<td valign="top" align="center"><%=strCE%></td>
			  </tr>
			<%} // end for loop%>
			<tr>
				<td valign="top">***</td>
				<td valign="top" align='center'>***</div></td>
				<td valign="top" align="center">***</td>
			</tr>
			</table>
		</td>
		<td width="6%">&nbsp;</td>
		<td valign='top' width="47%">
			<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderNONE">
				  <tr>
					<td width="20%" height="20"><font size="1"><strong> SUBJECT </strong></font></td>
					<td width="7%" align="center"><font size="1"><strong>GRADES</strong></font></td>
					<td width="8%" align="center"><font size="1"><strong>UNITS</strong></font></td>
				  </tr>
				  <%
				for(int i=iRowSize; i< vGradeDetail.size(); i += 2 * iRowSize){
					strSubCode = (String)vGradeDetail.elementAt(i + 1);

					strGradeValue = (String)vGradeDetail.elementAt(i+5);
					if(strGradeValue != null && strGradeValue.startsWith("Grade"))
						strGradeValue = "GNA";
					strCE = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0.0");

					//if subject is not locked ,, force grade is GNA and unit = 0;
					if(GS.vGSIndexLocked.indexOf(vGradeDetail.elementAt(i)) == -1) {
						if(vSubSecIndexLocked.indexOf(vGradeDetail.elementAt(i + 4)) == -1) {
							strCE = "0.0";
							strGradeValue = "GNA";
						}
					}
					dUnitEarned += Double.parseDouble(strCE);

					strTemp = (String)vGradeDetail.elementAt(i+2);
					if(strTemp != null && strTemp.length() > 50)
						strTemp = strTemp.substring(0, 50);

					%>

				  <tr>
					<td valign="top"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
					<td valign="top"><div align="center"><%=strGradeValue%></div></td>
					<td valign="top" align="center"><%=strCE%></td>
				  </tr>
				<%} // end for loop%>
				<tr>
					<td valign="top">***</td>
					<td valign="top" align='center'>***</div></td>
					<td valign="top" align="center">***</td>
			  </tr>
		  </table>
	</td></tr></table>
	<br>
	<table width="400px" cellpadding="0" cellspacing="0">
		<td align="right">STUD IDNO: <%=strStudID%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
	</table>
	<table width="400px" cellpadding="0" cellspacing="0" height='60px'>
		<td valign='top' style="font-size:11px;"><%=strMailAddress%></td>
	</table>

	Total Units Enrolled: <%=dUnitEnrolled%><br>
	Total Units Passed: <%=dUnitEarned%>
	
<%
++iStudCount;
if(vStudList.size() > 0 && iStudCount % iStudentsPerPage == 0 ) {iStudCount = 0;
//if(iStudCount % iStudentsPerPage == 0 && iStudCount > 1 ) {%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%//}
}
%>


<%}//end of while loop... %>

</body>
</html>
<%
dbOP.cleanUP();
%>
