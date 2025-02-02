
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
	<title>Untitled Document</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style type="text/css">
	@media print { 
	  @page {
			margin-bottom:.1in;
			margin-top:0in;
			margin-left:.5in;
			margin-right:.5in;
		}
	}
	<!--
	body {
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
		font-family: "Times New Roman";
		font-size: 11px;
	}
	td {
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
		font-family: "Times New Roman";
		font-size: 11px;
	}
	th {
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
		font-family: "Times New Roman";
		font-size: 11px;
	}
		TABLE.thinborder {
			border-top: solid 1px #000000;
			border-right: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
			font-family: "Times New Roman";
			font-size: 11px;
		}
		TABLE.thinborderALL {
			border-top: solid 1px #000000;
			border-bottom: solid 1px #000000;
			border-left: solid 1px #000000;
			border-right: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
			font-family: "Times New Roman";
			font-size: 11px;
		}
		TD.thinborder {
			border-left: solid 1px #000000;
			border-bottom: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
			font-family: "Times New Roman";
			font-size: 11px;
		}
	
		TD.thinborderBottom {
			border-bottom: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
			font-family: "Times New Roman";
			font-size: 11px;
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
	</script>
	<body onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">

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
	String strStudInfoList = (String)request.getSession(false).getAttribute("stud_list");
	if(strStudInfoList == null || strStudInfoList.length() == 0) {
		return; 
	}

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";


	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);

	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
	String strTemp3   = null;

	


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
	
String[] astrConvertSem = {"SUMMER", "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER", "FOURTH SEMESTER"};
GradeSystem GS        = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
String strSYFrom      = request.getParameter("sy_from");
String strSYTo        = request.getParameter("sy_to");
String strSemester    = request.getParameter("semester");
String strStudID      = null;
String strGradeFor    = request.getParameter("grade_for");
String strTermName    = request.getParameter("sem_name");

int iPageCount = 1;
//get student information first before getting grade details.
Vector vStudInfo =  null;//pmtUtil.getStudBasicInfoOLD(dbOP, strStudID, strSYFrom, strSYTo, strSemester);

//System.out.println(vStudInfo);
Vector vGradeDetail = null;
//Vector vAdditionalInfo = null;
//Vector[] vEditInfo = null;
//boolean bolIncludeSchedule = false;

//if (strSchCode.startsWith("CPU")){
//	bolIncludeSchedule = true;
//}

Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);
while(vStudList.size() > 0) {///wraps the whole page here.. 
//System.out.println("Pirnting student : "+vStudList.elementAt(0));
	strStudID = (String)vStudList.remove(0);
//System.out.print("      Remaining to print : "+vStudList.size());
	vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, strStudID, strSYFrom, strSYTo, strSemester);
	if(vStudInfo == null)
		continue;
	
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0), strGradeFor, strSYFrom, strSYTo, strSemester, false, true, false, true);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	//vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	//vEditInfo = pif.viewPermStudPersonalInfo(dbOP,strStudID);


	
	if(strErrMsg == null) 
		strErrMsg = "";
	
//	double fGWA = 0d;
//	
//	if(WI.fillTextValue("show_gwa").equals("1")) {
//		fGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0), strSYFrom, strSYTo, strSemester, (String)vStudInfo.elementAt(6),
//				(String)vStudInfo.elementAt(7),null);
//	
//	}

	double dTotalUnits = 0d;
	
	
//	boolean bolIsCGH = false;
//	if(strSchCode.startsWith("CGH"))
//		bolIsCGH = true;
	
//	boolean bolIsCollegeOnly = false;
//	if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH"))
//		bolIsCollegeOnly = true;
	
	/////i have to put parenthesis for math and english enrichment.
	Vector vMathEnglEnrichment = null;
	boolean bolPutParanthesis = false;
	if(vGradeDetail != null) {
		vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
	}
	//System.out.println(strErrMsg);
//	if(strSchCode.startsWith("UDMC") && (strErrMsg == null || strErrMsg.length() == 0) ) {
//		enrollment.ReportRegistrar RR = new enrollment.ReportRegistrar();
//		RR.operateOnGradeReleasePrint(dbOP, request, 1);	
//	}



	%>
	
<script language="javascript">
	ShowProgress(<%=iPageCount++%>, <%=vStudList.size() + 1%>);
</script>
<!-- End of printing information -->


	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr >
		  <td height="20" align="center"><%=strErrMsg%></td>
		</tr>
	</table>
	
<%
if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="67%" height="18"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>		
	    <td width="33%">STUDENT STUDY LOAD</td>
	</tr>
	<tr>		
		<td height="18">College : <%=(String)vStudInfo.elementAt(16)%></td>
		<%
			if(Integer.parseInt(WI.fillTextValue("semester")) == 0)
				strTemp = WI.fillTextValue("sy_to");
			else
				strTemp = WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");
			%>
	    <td height="18"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=strTemp%></td>
	</tr>
	<tr>		
		<td height="18">Course : <%=(String)vStudInfo.elementAt(18)%><%=WI.getStrValue((String)vStudInfo.elementAt(4)," - ","","")%></td>
	    <td height="18">Total Units : &nbsp; <label id="total_units_enrolled_<%=strStudID%>"></label>  </td>
	</tr>
	<tr>		
		<td height="18" colspan="2">Student No./Name : <%=strStudID%> &nbsp; &nbsp; <%=(String)vStudInfo.elementAt(1)%></td>
	</tr>
</table>

<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>    
    <td width="10%" align="center" class="dottedborderTOPBOTTOM">Class Code</td>
    <td width="13%" height="20" align="center" class="dottedborderTOPBOTTOM">Subject Name</td>    
    <td width="32%" align="center" class="dottedborderTOPBOTTOM">Descriptive Title</td>
    <td width="6%" align="center" class="dottedborderTOPBOTTOM">Units</td>
    <td width="15%" align="center" class="dottedborderTOPBOTTOM">DAY / TIME</td>
    <td width="12%" align="center" class="dottedborderTOPBOTTOM">ROOM #</td>
    <td width="6%" align="center" class="dottedborderTOPBOTTOM">Midterm</td>
    <td width="6%" align="center" class="dottedborderTOPBOTTOM">Final</td>    
  </tr>
  <%
int iSubjCount = 0;
int iRowSize = 8;
int k = 0;

Vector vScheduleDetails = null;

String strGradeValue = null;
String strSubCode    = null; 

strTemp = "select cur_hist_index from STUD_CURRICULUM_HIST where is_valid =1 and user_index = "+(String)vStudInfo.elementAt(0)+
	" and sy_from = "+WI.fillTextValue("sy_from")+
	" and semester = "+WI.fillTextValue("semester");
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
boolean bolGetFinalGrade = false;
java.sql.PreparedStatement pstmtGetPercentGrade = null;
java.sql.ResultSet rs = null;
if(strTemp != null && strTemp.length() > 0){
	bolGetFinalGrade = true;
	strTemp = "select grade from g_sheet_final where is_valid=1 and grade is not null and sub_sec_index=? and cur_hist_index = "+strTemp;
	pstmtGetPercentGrade = dbOP.getPreparedStatement(strTemp);
}


strTemp = "select section, sub_index from e_sub_section where sub_sec_index = ? ";
java.sql.PreparedStatement pstmtGetSection = dbOP.getPreparedStatement(strTemp);


String strFinalGrade = null;
String strSubIndex = null;
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
		
strTemp = null;
pstmtGetSection.setString(1,(String)vGradeDetail.elementAt(i + 4));
rs = pstmtGetSection.executeQuery();
if(rs.next()){
	strTemp = rs.getString(1);
	strSubIndex = rs.getString(2);
}
rs.close();

%>
  <tr>
  
    <td valign="top"> <%=WI.getStrValue(strTemp, "&nbsp;")%></td>
   
    <td valign="top"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
    
    <td valign="top"><%=(String)vGradeDetail.elementAt(i+2)%></td>
<%
strTemp = GS.getLoadingForSubject(dbOP, strSubIndex);
if(strTemp != null && strTemp.length() > 0){
	try{
		dTotalUnits += Double.parseDouble(strTemp);
	}catch(Exception e){
		dTotalUnits += 0d;
	}
}
%>
    <td valign="top" align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
    <%
		vScheduleDetails = (Vector)vGradeDetail.elementAt(i+7);
		strTemp2 = "";
		strTemp3 = "";
		if ( vScheduleDetails != null && vScheduleDetails.size() > 0)
		for (k=0; k < vScheduleDetails.size(); k+=3){
			if (k ==0){
				strTemp2 = (String)vScheduleDetails.elementAt(k);
				strTemp3 = (String)vScheduleDetails.elementAt(k+2);
			}else{
				strTemp2 += "<br> " +  (String)vScheduleDetails.elementAt(k);
				strTemp3 += "<br> " +  (String)vScheduleDetails.elementAt(k+2);
			}
		}
	%>
	<td valign="top"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
	<td valign="top"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td>    
    <td valign="top"<%=strTemp%>><div align="center"><%=WI.getStrValue((String)vGradeDetail.elementAt(i+5),"&nbsp;")%></div></td>
<%
strFinalGrade = null;
if(bolGetFinalGrade){
	pstmtGetPercentGrade.setString(1,(String)vGradeDetail.elementAt(i+4));	
	rs = pstmtGetPercentGrade.executeQuery();
	if(rs.next())
		strFinalGrade = rs.getString(1);
	rs.close();
}
%>
    <td valign="top"><div align="center"><%=WI.getStrValue(strFinalGrade,"&nbsp;")%></div></td>  
  </tr>    
<%
} // end for loop
%>
</table>


<%
if(dTotalUnits > 0d){%>
<script>
	document.getElementById('total_units_enrolled_<%=strStudID%>').innerHTML = <%=CommonUtil.formatFloat(dTotalUnits, 1)%>;
</script>
<%}%>

<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="60%"><!--<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1).toUpperCase()%><br>-->
		<%=WI.getTodaysDateTime()%></td>	  	
	</tr>	
</table>

<%}//only if vStudInfo and vGradeDetail are not null%>

<%if(vStudList.size() > 0) {%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>


<%}//end of while loop... %>

</body>
</html>

<%
dbOP.cleanUP();
%>