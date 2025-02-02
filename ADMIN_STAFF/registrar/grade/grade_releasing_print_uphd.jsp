	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
	<title>Grade Releasing.</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style type="text/css">
	<!--
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
			border-bottom: solid 1px #000000;
			border-left: solid 1px #000000;
			border-right: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 12px;
		}
		TD.thinborder {
			border-left: solid 1px #000000;
			border-bottom: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 12px;
		}
	
		TD.thinborderBottom {
			border-bottom: solid 1px #000000;
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 12px;
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
<body onLoad="window.print()" leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0">



<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector,java.util.Calendar " %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);

	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
	String strTemp3   = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");

	String strStudInfoList = WI.fillTextValue("stud_id");
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

boolean bolIsCGH = false;
boolean bolIsDBTC = strSchCode.startsWith("DBTC");

boolean bolIsCollegeOnly = false;
//get all sub_sec_index Locked.. 

String strFooterDatePrinted = WI.getTodaysDate(1);
String strFooterPreparedBy  = (String)request.getSession(false).getAttribute("first_name");

	strStudID = WI.fillTextValue("stud_id");
	vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, strStudID, strSYFrom, strSYTo, strSemester);
	if(vStudInfo == null)
		strErrMsg = pmtUtil.getErrMsg();
	else{
		vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0), strGradeFor, strSYFrom, strSYTo, strSemester, true, true, true, bolIncludeSchedule);
		if(vGradeDetail == null)
			strErrMsg = GS.getErrMsg();
		//System.out.println(vGradeDetail);
		//System.out.println(strErrMsg);
	
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));
	
		enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
		vEditInfo = pif.viewPermStudPersonalInfo(dbOP,strStudID);	
	}
	
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
	
%>
	

<!-- End of printing information -->

<%if(strErrMsg != null) {%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr >
		  <td height="20" align="center"><%=WI.getStrValue(strErrMsg)%>&nbsp;<br>&nbsp;</td>
		</tr>
	</table>
<%}%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr >
		  <td height="36" align="center">&nbsp;</td>
		</tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr><td width="88%">&nbsp;</td>
		<td width="12%"><font size="1"><%=WI.getTodaysDate(1)%></font></td></tr>
		<%
		Calendar cal = Calendar.getInstance();	     
		%>
		<tr><td width="88%">&nbsp;</td>
		<td><font size="1"><%=WI.formatDate(cal.getTime(),15)%></font></td></tr>
		<tr><td width="88%">&nbsp;</td>
		<td><font size="1"><%=request.getSession(false).getAttribute("userId")%></font></td></tr>	
		<tr><td colspan="2" height="5"></td></tr>
	</table>

	<table width="100%" border="0" cellspacing="0" cellpadding="0">		
		<tr>
			<td width="42%" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr><td width="22%">&nbsp;</td><td colspan="3">&nbsp; &nbsp; <%=request.getParameter("stud_id")%></td></tr>
					<tr><td colspan="4">&nbsp; &nbsp;&nbsp; &nbsp; <%=(String)vStudInfo.elementAt(1)%></td></tr>
					<tr><td colspan="4">&nbsp; &nbsp;&nbsp; &nbsp; 
				      <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%>
						<%=WI.getStrValue((String)vAdditionalInfo.elementAt(14))%>
				      <%}%>
					</td></tr>
					<tr><td colspan="4">&nbsp; &nbsp;&nbsp; &nbsp; 
				      <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%>
						<%=WI.getStrValue((String)vAdditionalInfo.elementAt(15))%>
				      <%}%>
					</td></tr>
					<tr><td colspan="4">&nbsp; &nbsp;&nbsp; &nbsp; 
				      <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%>
						<%=WI.getStrValue((String)vAdditionalInfo.elementAt(16))%>
				      <%}%>
					</td></tr>
					<tr><td colspan="4">&nbsp;</td></tr>
					<tr>
					  <td height="15">&nbsp;</td><td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=request.getParameter("sy_from")%>-<%=request.getParameter("sy_to")%></td><td width="19%"><%=WI.fillTextValue("semester").toUpperCase()%></td>
					</tr>
					<tr><td height="15">&nbsp;</td><td width="5%">&nbsp;</td><td width="54%">&nbsp;</td><td><%=(String)vStudInfo.elementAt(2)%></td></tr>
					<tr><td>&nbsp;</td><td colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue((String)vStudInfo.elementAt(4))%></td><%
					strTemp = "&nbsp;";
					if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){
						strTemp = (String)vAdditionalInfo.elementAt(0);
						if(strTemp.equalsIgnoreCase("Male"))
							strTemp = "M";
						else
							strTemp = "F";
					}
					%>
					<td><%=strTemp%></td></tr>
					<tr><td colspan="4" height="35" align="center" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%;">&nbsp;</div></td></tr>
					<tr>
					  <td align="center" colspan="4">University Registrar</td>
					</tr>
				</table>			
			</td>
			
			
			
			<td valign="top">
				<table height="228" width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
				<td valign="top">
				<table width="95%" border="0" cellspacing="0" cellpadding="0">
				  <tr>					  			  			
					<td width="17%" height="40">&nbsp;</td>
					<td width="57%">&nbsp;</td>
					<td width="16%">&nbsp;</td>
					<td width="10%">&nbsp;</td>
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
			
					strGradeValue = (String)vGradeDetail.elementAt(i+5);
					if(strGradeValue != null && strGradeValue.startsWith("Grade"))
						strGradeValue = "GNA";
					strCE = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0.0");
				
					if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal) {
						strCE = "0.0";
						strGradeValue = "GNA";
					}
			
					
					strTemp = (String)vGradeDetail.elementAt(i+2);
					if(strTemp != null && strTemp.length() > 50)
						strTemp = strTemp.substring(0, 50);
					%>
					
				  <tr>		
					<td valign="top"><font size="1"><%=(String)vGradeDetail.elementAt(i+1)%></font></td>
					<td valign="top"><font size="1"><%=strTemp%></font></td>
					<td valign="top"><font size="1"><%=strGradeValue%></font></td>
					<td valign="top"><font size="1"><%=strCE%></font></td>
				  </tr>
				<%} // end for loop%>
				
				</table>
				</td></tr></table>		
			</td>
		</tr>
	</table>		

<%//}//end of while loop... %>

</body>
</html>
<%
dbOP.cleanUP();
%>