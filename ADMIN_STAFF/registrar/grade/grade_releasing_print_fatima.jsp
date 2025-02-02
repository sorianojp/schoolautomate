<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";


	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
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

int iPageWidth = 350;//this is for laser.
if(WI.fillTextValue("print_dotmatrix").length() > 0)
	iPageWidth = 550;


Vector vComponentGrade = new Vector();
Vector vComponent = new Vector();
vComponentGrade.addElement("NCM 101A");
	vComponent.addElement("NCFHN 101A");vComponent.addElement("NCMCN 101A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 102A");
	vComponent.addElement("NCOB 102A");vComponent.addElement("NCPE 102A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 103A");
	vComponent.addElement("NCMS 103A");vComponent.addElement("NCOR 103A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 104A");
	vComponent.addElement("NCD 104A");vComponent.addElement("NCS 104A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 102");
	vComponent.addElement("NCCO 102");vComponent.addElement("NCCO 102");vComponent.addElement("NCOR 102");vComponent.addElement("NCOB 102");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 104");
	vComponent.addElement("NCCD 104A");vComponent.addElement("NCMS 104A");vComponent.addElement("NCPS 104A");vComponent.addElement("NCPE 104A");
	vComponent.addElement("NCD 104A");vComponent.addElement("NCS 104A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 106A");
	vComponent.addElement("NONC 106A");vComponent.addElement("NABC 106A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 107A");
	vComponent.addElement("NCMG 107A");vComponent.addElement("NCPA 107A");
vComponentGrade.addElement(vComponent); vComponent = new Vector();

vComponentGrade.addElement("NCM 105C");
	vComponent.addElement("NCMG 105C");vComponent.addElement("NCMS 105C");
	vComponent.addElement("NCPA 105C");vComponent.addElement("NCSE 105C");
vComponentGrade.addElement(vComponent); vComponent = new Vector();
//System.out.println(vComponentGrade);




int iIndexOf = 0;
if(vGradeDetail != null && vGradeDetail.size() > 0) {
	for(int i =0; i < vGradeDetail.size(); i += 8) {
		//System.out.println();
		iIndexOf = vComponentGrade.indexOf(vGradeDetail.elementAt(i + 1));
		if(iIndexOf == -1)
			continue;
		vComponent = (Vector)vComponentGrade.elementAt(iIndexOf + 1);
		for( int p = 0; p < vGradeDetail.size(); p += 8) {
			if(vComponent.indexOf(vGradeDetail.elementAt(p + 1)) > -1) {
				i = 0;
				vGradeDetail.remove(p);vGradeDetail.remove(p);vGradeDetail.remove(p);vGradeDetail.remove(p);
				vGradeDetail.remove(p);vGradeDetail.remove(p);vGradeDetail.remove(p);vGradeDetail.remove(p);

				p = p - 8;
				continue;
			}
		}

	}
}

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
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborderBottom {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }


-->
</style>

</head>

<body onLoad="window.print()" leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0">
<%if(strErrMsg != null) {%>
<table width="<%=iPageWidth%>px" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%}
if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){

 // a world of their own for CPUvStudInfo
  if(!strSchCode.startsWith("CPU")) {
%>

  <table width="<%=iPageWidth%>px" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" colspan="6"><div align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
			  <font size="2"><strong>
			  <!--OFFICE OF THE UNIVERSITY REGISTRAR <br>-->
			  </strong></font>

        <%=request.getParameter("grade_for").toUpperCase()%><%}%> GRADES FOR <%=request.getParameter("sem_name").toUpperCase()%>
			, <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
        <br>
         </div></td>
    </tr>
</table>
<table width="<%=iPageWidth%>px" border="0" cellspacing="0" cellpadding="0">

  <tr>
    <td width="15%" height="19" >Student ID </td>
    <td width="25%" ><%=request.getParameter("stud_id")%></td>
    <td width="10%" >Course:</td>
    <td width="50%" ><%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%>
	<%=WI.getStrValue((String)vStudInfo.elementAt(4), " - ", "", "")%>
    </td>
  </tr>
  <tr>
    <td height="18" > Name</td>
    <td height="18" colspan="3" ><%=(String)vStudInfo.elementAt(1)%></td>
  </tr>
</table>
<table bgcolor="#FFFFFF"  width="<%=iPageWidth%>px" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <td width="45%" height="20" class="thinborder"><font size="1">Subject Code</font></td>
    <td width="18%" align="center" class="thinborder"><font size="1">Grade</font></td>
    <td width="18%" align="center" class="thinborder"><font size="1">Credit</font></td>
    <td width="18%" align="center" class="thinborder"><font size="1">Remarks</font></td>
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
/**
if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal) {
	if(bolIsCGH)
		strTemp = " colspan=2";
	else if (strSchCode.startsWith("CPU"))
		strTemp = " colspan=2";
	else
		strTemp = " colspan=3";
	vGradeDetail.setElementAt(null,i);
	vGradeDetail.setElementAt("Grade not verified", i + 5);
}**/

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
    <td valign="top" class="thinborder"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
    <% if (!strSchCode.startsWith("CPU")){%>
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
	<%}%>
<%if(!bolIsCGH){%>
    <%}
strGradeValue = (String)vGradeDetail.elementAt(i+5);
if(strGradeValue != null && (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
	strGradeValue = strGradeValue+"0";
%>
    <td valign="top" class="thinborder"<%=strTemp%>><div align="center"><%=strGradeValue%></div></td>
<%if(bolIsCLDH){%>
    <%} if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC") && !bolIsDBTC && !strSchCode.startsWith("UL")){%>
    <% } // remove for cpu

// force strTemp = null  for CPU, UDMC or CGH -- it must be set to null for the schools want to remove re-exam.
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
<table width="<%=iPageWidth%>px" border="0" cellspacing="0" cellpadding="0">

  <tr>
    <td valign="top">
	<%if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0d){%>
		<strong>GWA: <%=CommonUtil.formatFloat(dGWA,2)%></strong><br>
	<%}%>
	NOTE:<br>
	Students with NG(No Grade) in their subjects/courses must be updated through the Office of the College Dean within 2 weeks after scheduled Final Examination. Students with NFE must take/complete the missing exam within the current semester. Students must complete subjects with INC grades within 1 school year.</td>
  </tr>
</table>

<%}//only if vStudInfo and vGradeDetail are not null
dbOP.cleanUP();
%>

</body>
</html>
