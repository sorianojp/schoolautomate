	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
	<title>Untitled Document</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style type="text/css">
	<!--
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
		TABLE.thinborderALL {
			border-top: solid 1px #000000;
			border-bottom: solid 1px #000000;
			border-left: solid 1px #000000;
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
	if(strStudInfoList == null)
		return;


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
Vector vAdditionalInfo = null;
Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;

boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");

String strGradeCGH = null;
java.sql.PreparedStatement pstmtGetPercentGrade = dbOP.getPreparedStatement("select grade_cgh from g_sheet_final where gs_index = ?");
boolean bolIsCLDH  = strSchCode.startsWith("CLDH");
if(!bolIsFinal)
	bolIsCLDH = false;

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
int iStudCount = 1;
if(strSchCode.startsWith("CSA"))
	iStudentsPerPage = 2;


Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);
while(vStudList.size() > 0) {///wraps the whole page here..
//System.out.println("Pirnting student : "+vStudList.elementAt(0));
	strStudID = (String)vStudList.remove(0);
//System.out.print("      Remaining to print : "+vStudList.size());
	vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, strStudID, strSYFrom, strSYTo, strSemester);
	if(vStudInfo == null)
		continue;

	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0), strGradeFor, strSYFrom, strSYTo, strSemester, true, true, true, bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	vEditInfo = pif.viewPermStudPersonalInfo(dbOP,strStudID);

	if(strSchCode == null)
		strSchCode = "";

	if(strErrMsg == null)
		strErrMsg = "";

	double dGWA = 0d;

	if(WI.fillTextValue("show_gwa").equals("1")) {
		dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0), strSYFrom, strSYTo, strSemester, (String)vStudInfo.elementAt(6),
				(String)vStudInfo.elementAt(7),null);

	}

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
	if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){

	 // a world of their own for CPUvStudInfo
	  if(!strSchCode.startsWith("CPU")) {
	%>

	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
	 <%if(strSchCode.startsWith("UI")){%>
		<tr >

		<td height="20" colspan="6" align="right"><font style="font-size:9px"> UI-REG-0016
		  Revision Date: Feb, 2004 </font></td>
		</tr>
	 <%}%>
		<tr >
		  <td height="20" colspan="6"><div align="center"><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
			  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
	<%
	if(!strSchCode.startsWith("CLDH")){
		if (!strSchCode.startsWith("UDMC") && !bolIsCGH){%>
				  <font size="2"><strong>
				  <%if (strSchCode.startsWith("AUF")){%>
				  <%=new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(6))%>
				  <%}else {if(false){%>COLLEGE OF<%}else{%>OFFICE OF THE
					<%if(!strSchCode.startsWith("DBTC") && !strSchCode.startsWith("CSA")){%>UNIVERSITY<%}%>
				  <%}%> REGISTRAR <%}%>
				  </strong></font>
				  <br>
				  <br>
		<%}else{%>
				  <br><font size="2"><strong>
					<%if(bolIsCGH){%>
					GRADES SLIP
					<%}else{%>REPORT OF GRADES<%}%></strong></font><br>
	<%	}
	}//do not show for CLDH

		strTemp = request.getParameter("grade_for").toUpperCase()+" GRADE";
		if(strTemp.startsWith("F"))
			strTemp = "FINAL RATINGS";
%>
			<strong>
			<%=strTemp%> FOR
			<%=request.getParameter("sem_name").toUpperCase()%>,
			AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
			</strong>
			<br>
			 </div></td>
		</tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td height="18" colspan="6" align="right"><font size="1"> Date Printed : <%=WI.getTodaysDate(6)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
	  </tr>
	  <tr>
		<td width="3%" height="19" >&nbsp;</td>
		<td width="10%" height="19" >Student ID </td>
		<td width="34%" ><strong><%=strStudID%></strong></td>
		<td width="13%" >Course/Major</td>
		<td  colspan="2" ><strong><%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
	  </tr>
	  <tr>
		<td height="18" >&nbsp;</td>
		<td height="18" > Name</td>
		<td height="18" ><strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
		<td height="18" >Year</td>
		<td width="12%" height="18" ><strong><%=WI.getStrValue(vStudInfo.elementAt(4))%></strong></td>
		<td width="28%" height="18" >
		<%if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0d
			&& !strSchCode.startsWith("UDMC")){%>
			GWA : <strong><%=CommonUtil.formatFloat(dGWA,2)%></strong>
		<%}%></td>
	  </tr>

	<% if (!strSchCode.startsWith("UDMC")){ %>
	  <tr>
		<td height="20" >&nbsp;</td>
		<td height="20" >Address</td>
		<td height="20" colspan="4" > <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%><%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","")%> <%}%> </td>
	  </tr>
	<%}%>
	</table>

	<%}else{ // begin of CPU's own world %>

	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
	<td width="70%">&nbsp;<%=SchoolInformation.getSchoolName(dbOP,true,false)%> - Collegiate Grade Record</td>
		<td width="30%"><div align="right"><%=request.getParameter("sem_name").toUpperCase()%> , <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%> </div></td>
	</tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	  <tr valign="bottom">
		<td width="7%" height="25">Name: </td>
		<td width="27%" class="thinborderBottom">&nbsp;<%=(String)vStudInfo.elementAt(1)%></td>
		<td width="11%"> <div align="right">Stud. No.:</div></td>
		<td width="20%" class="thinborderBottom">&nbsp;<%=request.getParameter("stud_id")%></td>
		<td width="11%"><div align="right">Course/Year : </div></td>

		<td width="12%" class="thinborderBottom"><strong>&nbsp; </strong><%=WI.getStrValue((String)vStudInfo.elementAt(11))%> <%=WI.getStrValue((String)vStudInfo.elementAt(12),"(", ")", "")%> <%=WI.getStrValue((String)vStudInfo.elementAt(4))%></td>
		<td width="5%"><div align="right">Sex:</div></td>
		<%
			if (vEditInfo != null)
				strTemp = WI.getStrValue(vEditInfo[0].elementAt(15));
			else
				strTemp = "";
		%>
		<td width="5%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
	  </tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	  <tr>
		<td width="7%"> College: </td>
		<td width="24%" class="thinborderBottom">&nbsp; <%=WI.getStrValue((String)vStudInfo.elementAt(13))%> </td>
		<td width="11%"> <div align="right">Civil Status: </div></td>
	<%
		if (vEditInfo != null)
			strTemp = WI.getStrValue(vEditInfo[0].elementAt(20));
		else
			strTemp = "";
	%>
		<td width="10%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
		<td width="13%"><div align="right">Citizenship: </div></td>
	<%
		if (vEditInfo != null)
			strTemp = WI.getStrValue(vEditInfo[0].elementAt(17));
		else
			strTemp = "";
	%>
		<td width="15%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
		<td width="13%"><div align="right">Classification:</div></td>
		<td width="7%" class="thinborderBottom">&nbsp;</td>
	  </tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	  <tr>
		<td width="11%"> LandLady: </td>
	<%
		if (vEditInfo != null)
			strTemp = WI.getStrValue(vEditInfo[0].elementAt(43));
		else
			strTemp = "";
	%>
		<td width="23%" class="thinborderBottom">&nbsp;<%=strTemp%></td>

		<td width="10%"> <div align="right">Address: </div></td>
	<%
		if (vEditInfo != null)
			strTemp = WI.getStrValue((String)vEditInfo[0].elementAt(45))  +
					WI.getStrValue((String)vEditInfo[0].elementAt(46), ", " , "","") +
					WI.getStrValue((String)vEditInfo[0].elementAt(47), ", " , "","") +
					WI.getStrValue((String)vEditInfo[0].elementAt(48), ", " , "","") +
					WI.getStrValue((String)vEditInfo[0].elementAt(49), " ","","" );
		else
			strTemp = "";
	%>

		<td width="56%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
	  </tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	  <tr>
		<td width="9%"> Parent: </td>
	<%
		if (vEditInfo != null){
			strTemp = WI.getStrValue(vEditInfo[0].elementAt(68));
			if (strTemp.length() == 0)
				strTemp = WI.getStrValue(vEditInfo[0].elementAt(74));
		}else
			strTemp = "";
	%>
		<td width="26%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
		<td width="10%"> <div align="right">Address: </div></td>
	<%
		if (vEditInfo != null)
			strTemp = WI.getStrValue((String)vEditInfo[0].elementAt(37))  +
					WI.getStrValue((String)vEditInfo[0].elementAt(38), ", " , "","") +
					WI.getStrValue((String)vEditInfo[0].elementAt(39), ", " , "","") +
					WI.getStrValue((String)vEditInfo[0].elementAt(40), ", " , "","") +
					WI.getStrValue((String)vEditInfo[0].elementAt(41), " ","","" );
		else
			strTemp = "";
	%>
		<td width="55%" class="thinborderBottom">&nbsp;<%=strTemp%></td>
	  </tr>
	  <tr>
		<td height="18">&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	  </tr>
	</table>
	<%}%>

	<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	  <tr>
		<% if (strSchCode.startsWith("CPU")) {%>
		<td width="3%" align="center" class="thinborder"><font size="1"><strong>NO.</strong></font></td>
		<%
			strTemp = "SUBJECT";
		}else
			strTemp ="SUBJECT CODE";
		if(bolIsDBTC)
			strTemp = "COURSE CODE";
		%>
		<td width="15%" height="20" align="center" class="thinborder"><font size="1"><strong>
			<%=strTemp%></strong></font></td>
		<% if (!strSchCode.startsWith("CPU")) {%>
		<td width="30%" align="center" class="thinborder"><font size="1"><strong>
		<%if(bolIsCGH || bolIsDBTC){%>DESCRIPTIVE TITLE <%}else{%>SUBJECT NAME/DESCRIPTION<%}%></strong></font></td>
		<%} //  end remove td
	 if (strSchCode.startsWith("CPU")) {
				strTemp = "TEACHER";  %>
		<td width="14%" align="center" class="thinborder"><font size="1"><strong>
		  DAY / TIME </strong></font></td>
		<td width="9%" align="center" class="thinborder"><font size="1"><strong>
		  ROOM </strong></font></td>
	<%}else {
				strTemp = "INSTRUCTOR";
	}%>

	<%if(!bolIsCGH){%>
		<td width="16%" align="center" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
	<%}%>
		<td width="6%" align="center" class="thinborder"><font size="1"><strong><%if(!bolIsCGH){%>GRADE<%}else{%>GENERAL AVERAGE<%}%>
		  </strong></font></td>
	<%if(bolIsCLDH){%>
		<td width="6%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">%ge Grade </td>
	<%} if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("UDMC") && !bolIsDBTC) {%>
		<td width="7%" align="center" class="thinborder"><font size="1"><strong><%if(bolIsCGH){%>COMPLETION GRADE<%}else{%>RE-EXAM<%}%></strong></font></td>
		<%}%>
		<td width="6%" align="center" class="thinborder"><font size="1"><strong><%if(bolIsCGH){%>CREDIT UNITS<%}else{%>CREDITS<%}%></strong></font></td>
		<% if (!strSchCode.startsWith("CPU") && !bolIsCGH) {%>
		<td width="9%" align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
		<% }%>
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
		if(bolIsCGH)
			strTemp = " colspan=2";
		else if (strSchCode.startsWith("CPU"))
			strTemp = " colspan=2";
		else
			strTemp = " colspan=3";
		vGradeDetail.setElementAt(null,i);
		vGradeDetail.setElementAt("Grade not verified", i + 5);
	}

	if(bolIsCLDH && vGradeDetail.elementAt(i) != null) {
		pstmtGetPercentGrade.setInt(1, Integer.parseInt((String)vGradeDetail.elementAt(i)));
		java.sql.ResultSet rs = pstmtGetPercentGrade.executeQuery();
		if(rs.next())
			strGradeCGH = rs.getString(1);
		else
			strGradeCGH = "&nbsp;";
		rs.close();
	}
	else
		strGradeCGH = "&nbsp;";

	%>
	  <tr>
		<%if (strSchCode.startsWith("CPU")) {%>
		<td valign="top" class="thinborder"> <%=iSubjCount%></td>
		<%}%>
		<td valign="top" class="thinborder"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
		<% if (!strSchCode.startsWith("CPU")){%>
		<td valign="top" class="thinborder"><%=(String)vGradeDetail.elementAt(i+2)%></td>
		<%}else{
			vScheduleDetails = (Vector)vGradeDetail.elementAt(i+8);
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
		<td valign="top" class="thinborder"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
		<td valign="top" class="thinborder"><div align="center"><%=WI.getStrValue(strTemp2,"&nbsp;")%></div></td>
		<%}%>
	<%if(!bolIsCGH){%>
		<td valign="top" class="thinborder">&nbsp;<%=WI.getStrValue((String)vGradeDetail.elementAt(i+4),"n/f")%></td>
	<%}
	strGradeValue = (String)vGradeDetail.elementAt(i+5);
	if(bolIsCGH && strGradeValue != null && (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
		strGradeValue = strGradeValue+"0";
		if(bolPutParanthesis && !strGradeValue.startsWith("Grade"))
			strGradeValue = "("+strGradeValue+")";
	%>
		<td valign="top" class="thinborder"<%=strTemp%>><div align="center"><%=strGradeValue%></div></td>
	<%if(bolIsCLDH){%>
		<td valign="top" class="thinborder"<%=strTemp%> align="center"><%=WI.getStrValue(strGradeCGH, "&nbsp;")%></td>
	<%} if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC") && !bolIsDBTC){%>
		<td valign="top" class="thinborder"><div align="center">
		  <%
		//it is re-exam if student has INC and cleared in same semester,
		strTemp = null;
		if(vGradeDetail.size() > (i + 5 + 8) && vGradeDetail.elementAt(i + 5) != null && ((String)vGradeDetail.elementAt(i + 5)).toLowerCase().indexOf("inc") != -1 &&
			((String)vGradeDetail.elementAt(i + 1)).compareTo((String)vGradeDetail.elementAt(i + 1 + 8)) == 0 ){ //sub code,
				strTemp = (String)vGradeDetail.elementAt(i + 3 + 8);
			%>
		  <%=CommonUtil.formatFloat((String)vGradeDetail.elementAt(i + 5 + 8),true)%>
			<%i += 8;}%>
			&nbsp; </div></td>
		<% } // remove for cpu

	// force strTemp = null  for CPU, UDMC or CGH -- it must be set to null for the schools want to remove re-exam.
	if (strSchCode.startsWith("CPU") || strSchCode.startsWith("UDMC") || bolIsCGH || bolIsDBTC)
		strTemp= null;

	if(vGradeDetail.elementAt(i) != null) {%>
		<td valign="top" class="thinborder"><div align="center">
			<%if(strTemp != null) {%>
			<%=strTemp%>
			<%}else{
				try {
					dTotalUnits += Double.parseDouble(WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0"));
				}catch(Exception e){}

	strGradeValue = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0");
	//if(bolIsCGH && strGradeValue != null && strGradeValue.endsWith(".0"))
	//	strGradeValue = strGradeValue.substring(0, strGradeValue.length() - 2);

	//if(bolPutParanthesis)
	//	strGradeValue = "(3.0)";
			%>
			<%=strGradeValue%>
			<%}%>
		  </div></td>
		<% if (!strSchCode.startsWith("CPU") && !bolIsCGH) {%>
		<td valign="top" class="thinborder"><div align="center"><%=(String)vGradeDetail.elementAt(i+6)%></div></td>
		<% } // remove remarks for cpu
	 }
	%>
	  </tr>
	  <% if (strSchCode.startsWith("CPU")) {%>
	  <tr>
		<td class="thinborder">&nbsp;</td>
		<td colspan="8" class="thinborder"><%=(String)vGradeDetail.elementAt(i+2)%></td>
	  </tr>
	  <%
	  } // end cpu descriptive title
	} // end for loop

	if(strSchCode.startsWith("UDMC")) {%>
	<tr>
		<td height="20" colspan="6" align="center" class="thinborder"> Note: Issued
		  for re-enrollment purposes only </td>
	</tr>

	<%}else if(bolIsCGH){%>
	<tr>
		<td height="20" colspan="5" align="center" class="thinborder"> ************** NOTHING FOLLOWS **************</td>
	</tr>
	<%}%>
	</table>
	<%if (bolIsCGH){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td colspan="9" height="10" >&nbsp;</td>
	  </tr>
	  <tr>
		<td colspan="9" height="10" >&nbsp;</td>
	  </tr>
	  <tr>
		<td width="2%" height="25" >&nbsp;</td>
		<td width="47%" valign="top" align="center">
		<strong><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1).toUpperCase()%></strong><br>
		Prepared/Checked by</td>
		<td width="51%" valign="top" align="center"><strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase()%></strong><br>
	Registrar</td>
	  </tr>
	</table>
	<%} else if (!strSchCode.startsWith("UDMC")) {%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td colspan="10" height="10" >&nbsp;</td>
	  </tr>
	  <tr>
		<td width="2%" height="33" >&nbsp;</td>
		<td width="47%" height="33" valign="top">
	<%if(strSchCode.startsWith("LNU")){%>
		  Prepared by : <u>&nbsp;
		  <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>
		  &nbsp;</u>
	<%}else if(!strSchCode.startsWith("DBTC")){%>
		NOTE:
	<%}%></td>
	<%if(strSchCode.startsWith("AUF")){%>
		<td width="25%" valign="top" align="center">&nbsp;</td>
	<%}%>
		<td width="<%if(strSchCode.startsWith("AUF")){%>25<%}else{%>51<%}%>%" valign="top" align="center">CERTIFIED CORRECT:</td>
	  </tr>
	  <tr>
		<td  height="20" >&nbsp;</td>
		<td height="20" valign="top" >
	<%if(strSchCode.startsWith("LNU")){%>
		  NOTE : A student is given 100 days to complete incomplete grades counted
		  from the date of final examination.
	<%}else if(!strSchCode.startsWith("DBTC")){
		if(strSchCode.startsWith("VMU")){%>
		Incomplete grades must be completed within a month,
		<%}else{%>
		Inc grades must be completed within a year,
		<%}%><br>otherwise they become <%if(strSchCode.startsWith("CSA")){%>No Credit<%}else{%>failure<%}%>
	<%}%>    </td>
	<%if(strSchCode.startsWith("AUF")){%>
		<td align="center">&nbsp;</td>
	<%}%>
		<td height="20" align="center">
	<%if (!strSchCode.startsWith("AUF")) {%>
		<strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1)%></strong><br>
		<%if(!strSchCode.startsWith("DBTC") && !bolIsCollegeOnly){%>University <%}%>Registrar
	<%}else{%>
		<strong><%=WI.getStrValue(vStudInfo.elementAt(15)).toUpperCase()%></strong><br>Dean
	<%}%>
		</td>
	  </tr>
	</table>
	<%}else{
		// UDMC .. in  a world of their own

	%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td height="10" >&nbsp;</td>
		<td height="10" colspan="4" ><font size="1">Grading System</font></td>
		<td >&nbsp;</td>
		<td >&nbsp;</td>
		<td >&nbsp;</td>
		<td height="10" >&nbsp;</td>
	  </tr>
	  <tr>
		<td width="1%"  height="20" >&nbsp;</td>
		<td width="5%" height="20" valign="top" ><font size="1">1.0<br>
		  1.25<br>
		  1.5<br>
		  1.75<br>
		  2.0<br>
		  </font></td>
		<td width="6%" valign="top" ><font size="1">99-100<br>
		  96-98<br>
		  93-95<br>
		  90-92<br>
		  87-89<br>
		  </font></td>
		<td width="5%" valign="top" ><font size="1">2.25<br>
		  2.5<br>
		  2.75<br>
		  3.0<br>
		  5.0<br>
		  </font></td>
		<td width="8%" valign="top" ><font size="1">84-86<br>
		  81-83<br>
		  78-80<br>
		  75-77<br>
		  70<br>
		  </font></td>
		<td width="4%" valign="top" ><font size="1">Inc. <br>
		  AW <br>
		  UW <br>
		  DRP </font></td>
		<td width="20%" valign="top" ><font size="1">Incomplete <br>
		  Authorized Withdrawal<br>
		  Un authorized Withdrawal<br>
		  Dropped </font></td>
		<td width="25%" valign="top" ><font size="1">&nbsp;Total No. of Units:__<u><strong><%=dTotalUnits%></strong></u>__<br>
		  &nbsp;Weighted Average:__<u>
		  <%if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0d
			&& strSchCode.startsWith("UDMC")){%>
		  <strong><%=CommonUtil.formatFloat(dGWA,true)%></strong>
		  <%}%>
		  </u>__ </font></td>
		<td width="25%" height="20" valign="bottom"><div align="center">
		<img src="./gnilo_signature.gif"><br>
		<!--<font size="1"><strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1).toUpperCase()%></strong><br>
			Registrar</font>--></div></td>
	  </tr>
	  <tr>
		<td  height="20" >&nbsp;</td>
		<td height="20" colspan="8" style="font-size:11px;">NOTE : INC. grades must be completed within a year otherwise it will be a FAILED grade. </td>
	  </tr>
	</table>

	<%} //end of UDMC's world%>

	<%}//only if vStudInfo and vGradeDetail are not null%>

<%if(vStudList.size() > 0) {
if(iStudCount % iStudentsPerPage == 0) {%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}}
++iStudCount;%>


<%}//end of while loop... %>

</body>
</html>

<%
dbOP.cleanUP();
%>
