<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
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

String[] astrConvertSem = {"SUMMER","1ST TERM","2ND TERM","3RD TERM"};

GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
						request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));

//System.out.println("vStudInfo "+vStudInfo);
//System.out.println(vStudInfo);

//System.out.println("vStudInfo "+vStudInfo);
Vector vGradeDetail = null;
Vector vAdditionalInfo = null;
//Vector[] vEditInfo = null;
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
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),
											request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),true,bolIncludeEnrolledSubject,true,bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	//System.out.println("(String)vStudInfo.elementAt(0) "+(String)vStudInfo.elementAt(0));
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

	//if(vAdditionalInfo == null) //remved as per UC's request.. dated June 14, 2014.
	//	strErrMsg = studInfo.getErrMsg();

	//System.out.println("strErrMsg "+strErrMsg);
	//enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	//vEditInfo = pif.viewPermStudPersonalInfo(dbOP,request.getParameter("stud_id"));
}


if(strSchCode == null)
	strSchCode = "";
//strSchCode = "AUF";

double dGWA = 0d;

if(WI.fillTextValue("show_gwa").equals("1")) {
	dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
			request.getParameter("sy_from"),request.getParameter("sy_to"),
			request.getParameter("semester"), (String)vStudInfo.elementAt(6),
			(String)vStudInfo.elementAt(7),null);

}

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

boolean bolForSending = false;
if(WI.fillTextValue("for_sending").length() > 0)
	bolForSending = true;

String strAddress = null;

if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){
	strTemp = (String)vAdditionalInfo.elementAt(3);
	if(strTemp != null)
		strTemp = (String)vAdditionalInfo.elementAt(3);
	else
		strTemp = "";

	strAddress = strTemp;

	strTemp = (String)vAdditionalInfo.elementAt(4);
	if(strTemp != null)
		strTemp = (String)vAdditionalInfo.elementAt(4);
	else
		strTemp = "";
	if(strTemp != null && strTemp.length() > 0) {
		if(strAddress == null)
			strAddress = strTemp;
		else
			strAddress = strAddress +" "+strTemp;
	}
	strTemp = (String)vAdditionalInfo.elementAt(5);
	if(strTemp != null)
		strTemp = (String)vAdditionalInfo.elementAt(5);
	else
		strTemp = "";
	if(strTemp != null && strTemp.length() > 0) {
		if(strAddress == null)
			strAddress = strTemp;
		else
			strAddress = strAddress +" "+strTemp;
	}
	strTemp = (String)vAdditionalInfo.elementAt(6);
	if(strTemp != null)
		strTemp = (String)vAdditionalInfo.elementAt(6);
	else
		strTemp = "";
	if(strTemp != null && strTemp.length() > 0) {
		if(strAddress == null)
			strAddress = strTemp;
		else
			strAddress = strAddress +" "+strTemp;
	}
	strTemp = (String)vAdditionalInfo.elementAt(7);
	if(strTemp != null)
		strTemp = (String)vAdditionalInfo.elementAt(7);
	else
		strTemp = "";
	if(strTemp != null && strTemp.length() > 0) {
		if(strAddress == null)
			strAddress = strTemp;
		else
			strAddress = strAddress +" "+strTemp;
	}
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
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOMDOT {
    border-top: solid 1px #000000;
	border-style:dashed;
	border-width:thin
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

<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0" <%if(WI.getStrValue(strErrMsg).length() ==0){%> onLoad="window.print()"<%}%>>

<%if(strErrMsg != null && strErrMsg.length() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" align="center"><%=strErrMsg%></td>
    </tr>
</table>
<% dbOP.cleanUP();
return;}%>

<%if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td colspan="2">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="">
				<tr><td colspan="3"><font size="3"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td></tr>
				<tr><td colspan="3"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td></tr>

				<%if(bolForSending) {
					strTemp = "";
					if(vAdditionalInfo.size() > 0) {
						strTemp = (String)vAdditionalInfo.elementAt(8);
						if(strTemp != null && strTemp.length() > 0)
							strTemp = "Mr. "+strTemp;
						strErrMsg = (String)vAdditionalInfo.elementAt(9);
						if(strErrMsg != null && strErrMsg.length() > 0) {
							if(strTemp != null && strTemp.length() > 0)
								strTemp += "Mrs. "+strErrMsg;
							else
								strTemp = "Mrs. "+strErrMsg;
						}
						if(strTemp != null)
							strTemp = "<b>"+strTemp+"</b>";
					}

				%>
					<tr>
					  <td colspan="3">
					  		<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<td width="11%">&nbsp;</td>
								<td width="89%"><br><%=strTemp%><br><%=WI.getStrValue(strAddress).toUpperCase()%><br><br><br><br>&nbsp;</td>
							</table>
					  </td>
					</tr>
				<%}%>


<%
strTemp = WI.fillTextValue("grade_for");
if(strTemp.endsWith("s"))
	strTemp = strTemp.substring(0, strTemp.length() - 1);
%>
				<tr><td align="right" colspan="3"><font size="3"><strong><%=strTemp.toUpperCase()%> GRADES</strong></font></td></tr>

				<tr>
					<td width="30%"><%=request.getParameter("sem_name").toUpperCase()%> SY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
					<td width="30%">&nbsp;</td>
					<td width="30%" align="right"><%=WI.getTodaysDate(2)%></td>
				</tr>

				<tr>
					<td height="25" valign="bottom" align="center">Student No.</td>
					<td align="center" valign="bottom">Name</td>
					<td align="center" valign="bottom">Course and Year</td>
				</tr>

				<tr>
					<td valign="top" align="center"><%=request.getParameter("stud_id")%></td>
					<td align="center" valign="top" ><%=(String)vStudInfo.elementAt(1)%></td>
					<td align="center" valign="top" ><%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(4)," - &nbsp;","","")%></td>
				</tr>
				<%if(!bolForSending) {//Address is in header.%>
					<tr>
						<td height="20" colspan="3">Address : &nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strAddress).toUpperCase()%></td>
					</tr>
				<%}%>
			</table>		</td>
	</tr>

	<tr>
		<td height="270" valign="top" colspan="2">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td height="25" align="center"><strong>SUBJECT NAME</strong></td>
					<td align="center"><strong>DESCRIPTIVE TITLE</strong></td>
					<td align="center"><strong>GRADE</strong></td>
					<td align="center"><strong>UNITS</strong></td>
				</tr>

				<%
				   int iSubjCount = 0;
				   int iRowSize = 8;
				   int k = 0;

				   if (bolIncludeSchedule)
						iRowSize =9;
				   Vector vScheduleDetails = null;//System.out.println(GS.vGSIndexLocked);

				String strGradeValue = null;
				String strSubCode    = null; //System.out.println(vGradeDetail);
				String strCE         = null;
				for(int i=0; i< vGradeDetail.size(); i +=iRowSize){
					++iSubjCount;
					strSubCode = (String)vGradeDetail.elementAt(i + 1);

					if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0) {
						vGradeDetail.setElementAt("Grade not verified", i + 5);
					}



					strGradeValue = (String)vGradeDetail.elementAt(i+5);
					if(strGradeValue != null && strGradeValue.startsWith("Grade")) {
						strGradeValue = " --- ";
						strCE = " --- ";
					}
					else {
						strCE = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0.0");
						try {
							dTotalUnits += Double.parseDouble(strCE);
						}catch(Exception e){}
					}

					//if subject is not locked ,, force grade is GNA and unit = 0;
					/*if(GS.vGSIndexLocked.indexOf(vGradeDetail.elementAt(i)) == -1) {
						if(vSubSecIndexLocked.indexOf(vGradeDetail.elementAt(i + 4)) == -1) {
							strCE = "0.0";
							strGradeValue = "GNA";
						}
					}*/
					//dUnitEarned += Double.parseDouble(strCE);


					strTemp = (String)vGradeDetail.elementAt(i+2);
					if(strTemp != null && strTemp.length() > 50)
						strTemp = strTemp.substring(0, 50);
					%>

				  <tr>
					<td valign="top" height="20"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
					<td valign="top"><%=strTemp%></td>
					<td valign="top"><div align="center"><%=strGradeValue%></div></td>
					<td valign="top" align="center"><%=strCE%></td>
				  </tr>
				<%} // end for loop%>
				<%if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0d){%>
				  <tr style="font-weight:bold">
					<td valign="top" height="20">&nbsp;</td>
					<td align="right">GWA</td>
					<td align="center" class="thinborderTOP"><%=CommonUtil.formatFloat(dGWA,2)%></td>
					<td align="center" class="thinborderTOP"><%=CommonUtil.formatFloat(dTotalUnits, false)%></td>
				  </tr>
				<%}%>
					<tr>
						<td height="20" colspan="5" align="center" style="font-weight:bold; font-size:11px">
						--------------------------- ENTRY BELOW THIS LINE NOT VALID --------------------------- </font></td>
					</tr>
			</table>		</td>
	</tr>

	<!------------FOOTER------------------->
	<tr><td colspan="2" class="thinborderTOP"><i><font size="2"><strong>THIS COPY IS NOT VALID AS A TRANSFER CREDENTIAL.</strong></font></i></td></tr>
	<tr><td><i><font size="2">NOTE: 1. </font> Any erasures or alterations on this form renders it INVALID</i></td>
	  <td align="center">&nbsp;</td>
	</tr>
	<tr>
		<td width="75%"><i><font size="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2. </font>
		INC/NFE mark not completed within one month is automatically marked "No Grade".</i></td>
		<td align="center" class="thinborderBottom"><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase()%></td>
	</tr>

	<tr>
		<td>&nbsp;</td>
		<td align="center">University Registrar</td>
	</tr>
</table>


<%}//only if vStudInfo and vGradeDetail are not null
dbOP.cleanUP();


if(strSchCode.startsWith("DBTC")){%>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
this.autoPrint();

this.closeWnd = 1;
</script>
<%}%>
</body>
</html>
