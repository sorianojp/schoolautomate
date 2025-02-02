<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
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
//System.out.println(strSchCode);

if (strSchCode.startsWith("CPU")){
	bolIncludeSchedule = true;
}



if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	//get grade sheet release information.



	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),
											request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),true,true,true,bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

//	System.out.println(vAdditionalInfo);
//	System.out.println(vStudInfo);

	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	vEditInfo = pif.viewPermStudPersonalInfo(dbOP,request.getParameter("stud_id"));
}


if(strSchCode == null)
	strSchCode = "";
//strSchCode = "AUF";

if(strErrMsg == null) strErrMsg = "";

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

boolean bolIsCollegeOnly = false;
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH"))
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

boolean bolIsINC = false;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
function duplicateLabel() {
document.getElementById("student_copy").innerHTML = document.getElementById("registrar_copy").innerHTML;
}
</script>

<body topmargin="0" bottommargin="0" <%if(strErrMsg == null || strErrMsg.length() ==0){%> onLoad="duplicateLabel();window.print()"<%}%>>
<%if(strErrMsg != null && strErrMsg.length() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%}
if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td valign="top">&nbsp;</td>
      <td align="right" valign="top" style="font-size:9px;">PHILCSTREG#17 </td>
    </tr>
    <tr >
      <td width="17%" valign="top" align="right"><img src="../../../images/logo/PHILCST_DAGUPAN.gif" width="100" height="100"></td>
      <td width="83%" height="20"><div align="center">
	  	<font size="3"><strong>PHILIPPINE COLLEGE OF SCIENCE AND TECHNOLOGY</strong></font><br>
		<font size="1">
		Old Nalsian Road, Nalsian, Calasiao, Pangasinan, Philippines 2418 <br>
        Tel. No. (075) 522-8032/Fax No. (075) 523-0894/Website: www.philcst.edu.ph<br>
        ISO 9001: 2008 CERTIFIED, Member: Philippine Association of Colleges and Universities (PACU),<br>
        Philippine Association of Maritime Institutions (PAMI) <br>
		</font>
		<br>
		<strong><font size="2">OFFICIAL GRADE SHEET</font></strong><br>
		<%=request.getParameter("grade_name").toUpperCase()%> GRADES FOR <%=request.getParameter("sem_name").toUpperCase()%>, AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%><br>
		<font size="1">Registrar Copy</font><br>
         </div></td>
    </tr>
</table>
<label for="registrar_copy">&nbsp;</label>
<table cellpadding="0" cellspacing="0" border="0" width="100%" id="registrar_copy"><tr><td>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="6" align="right"><font size="1"> Date Printed : <%=WI.getTodaysDate(6)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
  </tr>
  <tr>
    <td width="3%" height="19" >&nbsp;</td>
    <td width="10%" height="19" >Student ID </td>
    <td width="34%" ><strong><%=request.getParameter("stud_id")%></strong></td>
    <td width="13%" >Course/Major</td>
    <td  colspan="2" ><strong><%=(String)vStudInfo.elementAt(18)%> <%=WI.getStrValue((String)vStudInfo.elementAt(19),"/","","")%></strong></td>
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
  <tr>
    <td height="20" >&nbsp;</td>
    <td height="20" >Address</td>
    <td height="20" colspan="4" > <%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%> <%}%> </td>
  </tr>
</table>

<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <% if (strSchCode.startsWith("CPU")) {%>
    <td width="3%" align="center" class="thinborder"><font size="1"><strong>NO.</strong></font></td>

    <%
		strTemp = "SUBJECT";
	}else
		strTemp ="SUBJECT CODE";
	%>
    <td width="12%" height="20" align="center" class="thinborder"><font size="1"><strong>
		<%=strTemp%></strong></font></td>
    <% if (!strSchCode.startsWith("CPU")) {%>
    <td width="33%" align="center" class="thinborder"><font size="1"><strong>
	<%if(bolIsCGH){%>DESCRIPTIVE TITLE <%}else{%>SUBJECT NAME/DESCRIPTION<%}%></strong></font></td>
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
<%} if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("UDMC")) {%>
    <td width="7%" align="center" class="thinborder"><font size="1"><strong>RE-EXAM</strong></font></td>
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
<%} if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC")){%>
    <td valign="top" class="thinborder"><div align="center">
      <%
	//it is re-exam if student has INC and cleared in same semester,
	bolIsINC = false;
	strTemp = ((String)vGradeDetail.elementAt(i + 5)).toLowerCase();
	if(strTemp.indexOf("inc") != -1 || strTemp.indexOf("nfe") != -1)
		bolIsINC = true;

	strTemp = null;
	if(vGradeDetail.size() > (i + 5 + 8) && vGradeDetail.elementAt(i + 5) != null && bolIsINC &&
		((String)vGradeDetail.elementAt(i + 1)).compareTo((String)vGradeDetail.elementAt(i + 1 + 8)) == 0 ){ //sub code,
			strTemp = (String)vGradeDetail.elementAt(i + 3 + 8);
		%>
      <%=CommonUtil.formatFloat((String)vGradeDetail.elementAt(i + 5 + 8),true)%>
        <%i += 8;}%>
        &nbsp; </div></td>
    <% } // remove for cpu

// force strTemp = null  for CPU, UDMC or CGH -- it must be set to null for the schools want to remove re-exam.
if (strSchCode.startsWith("CPU") || strSchCode.startsWith("UDMC") || bolIsCGH)
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
  <%
} // end for loop
%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="9" height="10" style="font-size:9px;">NOTE: INC and NFE grades shall be completed within the completion period, otherwise it becomes failure.</td>
  </tr>
  <tr valign="bottom">
    <td width="2%" height="18" >&nbsp;</td>
    <td width="50%">Noted By: </td>
    <td width="48%">Approved By: </td>
  </tr>

  <tr valign="bottom">
    <td  height="28" >&nbsp;</td>
    <td align="center">
	<strong>ENGR. RAUL B. GIRONELLA</strong>	<br>
	Vice President - Academic Affairs </td>
    <td align="center">
	<strong><%=CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1).toUpperCase()%></strong><br>
	Registrar	</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td valign="top" align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr align="center">
    <td width="33%" style="font-size:9px;">Revision: 6</td>
    <td width="33%" style="font-size:9px;">Date: April 9, 2009	</td>
    <td width="33%" style="font-size:9px;">Approved By: President</td>
  </tr>
</table>
</td></tr></table>
<DIV style="page-break-before:always" >&nbsp;</DIV>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td valign="top">&nbsp;</td>
      <td align="right" valign="top" style="font-size:9px;">PHILCSTREG#17 </td>
    </tr>
    <tr >
      <td width="17%" valign="top" align="right"><img src="../../../images/logo/PHILCST_DAGUPAN.gif" width="100" height="100"></td>
      <td width="83%" height="20"><div align="center">
	  	<font size="3"><strong>PHILIPPINE COLLEGE OF SCIENCE AND TECHNOLOGY</strong></font><br>
		<font size="1">
		Old Nalsian Road, Nalsian, Calasiao, Pangasinan, Philippines 2418 <br>
        Tel. No. (075) 522-8032/Fax No. (075) 523-0894/Website: www.philcst.edu.ph<br>
        ISO 9001: 2000 CERTIFIED, Member: Philippine Association of Colleges and Universities (PACU)<br>
		</font>
		<br>
		<strong><font size="2">OFFICIAL GRADE SHEET</font></strong><br>
		<%=request.getParameter("grade_for").toUpperCase()%> GRADES FOR <%=request.getParameter("sem_name").toUpperCase()%>, AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%><br>
		<font size="1">Student Copy</font><br>
         </div></td>
    </tr>
</table>
<label id="student_copy"></label>

<%}//only if vStudInfo and vGradeDetail are not null
dbOP.cleanUP();%>
</body>
</html>
