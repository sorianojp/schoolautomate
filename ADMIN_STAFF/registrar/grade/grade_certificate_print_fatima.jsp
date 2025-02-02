<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.ReportRegistrar, enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	if(strSchCode.startsWith("UL")){%>
		<jsp:forward page="./grade_certificate_print_ul.jsp" />
	<%return;}

	String strFontSize = WI.getStrValue(WI.fillTextValue("font_size"), "11");
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
	font-size: <%=strFontSize%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
-->
</style>


</head>

<body topmargin="150px" bottommargin="0" leftmargin="20px" rightmargin="20px;">

<%
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Certification","grade_certificate.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						///								"Registrar Management","GRADES",request.getRemoteAddr(),
						///								null);
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
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.



request.getSession(false).setAttribute("checker",WI.fillTextValue("checker"));
request.getSession(false).setAttribute("designation",WI.fillTextValue("designation"));
request.getSession(false).setAttribute("registrar",WI.fillTextValue("registrar"));

GradeSystem GS = new GradeSystem();
ReportRegistrar rr = new ReportRegistrar();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
Vector vRetResult  = null;
Vector vSemester = new Vector();
String[] astrConvertSem={"Summer", "1st Sem","2nd Sem","3rd Sem"};
String strYrLevel      = null;
if (!rr.saveAddrGradeCert(dbOP,request))
	strErrMsg = rr.getErrMsg();

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
String strCollege = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(6));

Vector vGradeDetail = null;
String strDegreeType = null;// for doctoral , it should be HOURS not units.
if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else {
	strDegreeType = (String)vStudInfo.elementAt(10);//1 = masteral, 2 = doctor of medicine.
	strYrLevel    = (String)vStudInfo.elementAt(4);
}

String strSem = null;
if (WI.fillTextValue("first_sem").length() == 1) {
	vSemester.addElement("1");
	strSem = "1";
}
if (WI.fillTextValue("second_sem").length() == 1) {
	vSemester.addElement("2");
	strSem = "2";
}
if (WI.fillTextValue("third_sem").length() == 1) {
	vSemester.addElement("3");
	strSem = "3";
}
if (WI.fillTextValue("summer").length() == 1) {
	vSemester.addElement("0");
	strSem = "0";
}

//for non university schools, show College of registrar.
boolean bolIsCollege = false;
boolean bolIsCGH     = false;
if(strSchCode.startsWith("CGH"))
	bolIsCGH = true;
boolean bolIsSACI    = strSchCode.startsWith("UDMC");


if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("CGH")  || strSchCode.startsWith("UDMC"))
	bolIsCollege = true;
if(strSchCode.startsWith("CGH") && WI.fillTextValue("stud_id").length() > 0 && vStudInfo != null && vStudInfo.size() > 0) {
	strTemp = (String)vStudInfo.elementAt(0);//dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
	if(strTemp != null) {
		strTemp = "select year_level from stud_curriculum_hist where user_index = "+strTemp+
		" and is_valid =1 and sy_from = "+request.getParameter("sy_from")+" and semester = "+strSem;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null)
			strYrLevel = strTemp;
	}
}

double dGWA = 0d;

String strExtraTermCon = null;
if(vSemester.size() > 0)
	strExtraTermCon = CommonUtil.convertVectorToCSV(vSemester);

//System.out.println(strExtraTermCon);
if(WI.fillTextValue("show_gwa").compareTo("1") ==0 && bolIsCGH)
	dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
			request.getParameter("sy_from"),request.getParameter("sy_to"),strSem,
			(String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(7),strExtraTermCon);


/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;

String strSubCode = null;//this is added for CGH to
if(vStudInfo != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}


boolean bolShowIP = false;//show grades not yet encoded..
boolean bolIsCurrentlyEnrolled = false;

if( WI.fillTextValue("show_inprogress").length() > 0)
	bolShowIP = true;

if(vStudInfo != null && vStudInfo.size() > 0){
	String strSYFrom   = request.getParameter("sy_from");

	String strSQLQuery = "select PRINT_INDEX from TRACK_PRINTING where STUD_INDEX = "+(String)vStudInfo.elementAt(0)+
		" and PRINT_MODULE = 1 and SY_FROM = "+strSYFrom +" and SEMESTER="+strSem+" and DATE_PRINTED='"+
		WI.getTodaysDate()+"'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null) {
		strSQLQuery = "insert into TRACK_PRINTING (STUD_INDEX,PRINT_MODULE,SY_FROM,SEMESTER,DATE_PRINTED,PRINTED_BY) values ("+(String)vStudInfo.elementAt(0)+
			",1,"+strSYFrom+","+strSem+",'"+WI.getTodaysDate()+"',"+(String)request.getSession(false).getAttribute("userIndex")+")";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}

	//get the last enrollment Information.
	strSQLQuery = "select sy_from, semester from stud_curriculum_hist join semester_sequence on (semester_val = semester) "+
	" where user_index = "+vStudInfo.elementAt(0)+" and is_valid = 1 order by sy_from desc, sem_order desc";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);

	String strLastEnrolledSY  = null;
	String strLastEnrolledSem = null;
	if(rs.next()) {
		strLastEnrolledSY  = rs.getString(1);
		strLastEnrolledSem = rs.getString(2);
	}
	//check the current SY/Term.
	String strCurSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strCurSem    = (String)request.getSession(false).getAttribute("cur_sem");

	int iCompareSY = CommonUtil.compareSYTerm(strLastEnrolledSY, strLastEnrolledSem, strCurSYFrom, strCurSem);
	if(iCompareSY == 0 )
		strTemp = "is/was enrolled in the following subjects for: ";
	else
		strTemp = "is/was enrolled in the following subjects for: ";

%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="45%" height="18" align="center" ><font size="4">CERTIFICATE OF GRADES</font></td>
  </tr>
  <tr>
    <td height="18" ></td>
  </tr>
  <tr>
    <td height="18" >&nbsp;</td>
  </tr>
  <tr>
    <td height="18" >&nbsp;</td>
  </tr>
  <tr>
    <td height="20" valign="bottom" >&nbsp;</td>
  </tr>
  <tr>
    <td height="25" ><strong>This is to certify that the </strong> Name: <%=(String)vStudInfo.elementAt(1)%>, Course/Year Level:
	<%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%> - <%=WI.getStrValue(strYrLevel)%>
	<%=strTemp%> </td>
  </tr>
</table>
<br><br>
<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <td width="19%" height="25" align="center" class="thinborder"><strong><font size="1">SUBJECT CODE </font></strong></td>
    <td width="45%" align="center" class="thinborder"><font size="1"><strong><%if(bolIsCGH){%>DESCRIPTIVE TITLE<%}else{%>SUBJECTS<%}%></strong></font></td>
    <td width="12%" align="center" class="thinborder"><font size="1"><strong>FINAL GRADE </strong></font></td>
    <td width="12%" align="center" class="thinborder"><font size="1"><strong>UNITS EARNED</strong></font></td>
    <td width="12%" align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
  </tr>
  <%
	int j = 0;
	String strGradeValue = null;
	for(int i = 0; i < vSemester.size(); i++){
		vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),
						"final",request.getParameter("sy_from"),request.getParameter("sy_to"),
						(String)vSemester.elementAt(i), true, bolShowIP, false, false);

		if(vGradeDetail == null)
			strErrMsg = GS.getErrMsg();

		if(strErrMsg == null) strErrMsg = "";
%>
  <tr>
    <td  height="25" colspan="5" class="thinborder">
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
          <td width="1%">&nbsp;</td>
          <td height="20" colspan="2"><u><%=astrConvertSem[Integer.parseInt((String)vSemester.elementAt(i))]%> , <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></u></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <%
	if (vGradeDetail !=null) {
		for(j=0; j< vGradeDetail.size(); j += 7){
			//I've to check if this is for math/english enrichment & if stud has passed(for CGH only)
			//if math/eng enrichment and passed, I have to put parantheris.
			strSubCode = (String)vGradeDetail.elementAt(j+1);
			/**if(vMathEnglEnrichment != null &&
				WI.getStrValue(vGradeDetail.elementAt(j+6)).toLowerCase().startsWith("p") &&
					vMathEnglEnrichment.indexOf(strSubCode) != -1)
				bolPutParanthesis = true;
			else
				bolPutParanthesis = false;
			**/
			if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
				bolPutParanthesis = true;
				try {
					double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(j + 5));
					//System.out.println(dGrade);
					bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
					if(dGrade < 5d)
						vGradeDetail.setElementAt("(3.0)",j + 3);
					else
						vGradeDetail.setElementAt("(0.0)",j + 3);

				}
				catch(Exception e){vGradeDetail.setElementAt("(0.0)",j + 3);}
			}
			else
				bolPutParanthesis = false;

		strGradeValue = (String)vGradeDetail.elementAt(j + 5);
		if(strGradeValue != null && (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
			strGradeValue = strGradeValue+"0";
		if(bolPutParanthesis)
			strGradeValue = "("+strGradeValue+")";

		strTemp = (String)vGradeDetail.elementAt(j + 5);
		if(strGradeValue != null && strGradeValue.equals("Grade not encoded"))
			strGradeValue = "In Progress";
		%>
        <tr>
          <td>&nbsp;</td>
          <td width="18%" height="20"><%=(String)vGradeDetail.elementAt(j + 1)%> </td>
          <td width="45%"><%=(String)vGradeDetail.elementAt(j + 2)%></td>
          <td width="12%"><div align="center"><%=strGradeValue%>&nbsp;</div></td>
<%
				// force strTemp = null  for CPU, UDMC or CGH -- it must be set to null for the schools want to remove re-exam.
				if (strSchCode.startsWith("CPU") || strSchCode.startsWith("UDMC") || bolIsCGH)
					strTemp= null;%>
          <td width="12%"><div align="center">
<%
if(strGradeValue != null && strGradeValue.equals("In Progress"))
	strGradeValue = "&nbsp;";
else {
	strGradeValue = WI.getStrValue((String)vGradeDetail.elementAt(j + 3),"0");
}
%>
		  <%=strGradeValue/**(String)vGradeDetail.elementAt(j + 3)**/%>&nbsp;</div></td>
          <td width="12%" align="center"><%=WI.getStrValue(vGradeDetail.elementAt(j + 6))%></td>
        </tr>
        <%} //end inner for loop
}else{%>
        <td  height="20" colspan="6" > &nbsp; <%=WI.getStrValue(strErrMsg,"")%></td>
        <%}%>
      </table></td>
  </tr>
  <%} // for (i <vSemester.size() %>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="9" height="10" >&nbsp;</td>
  </tr>
  <tr>
    <td colspan="9" height="10" >Date Printed: <%=WI.getTodaysDate(1)%></td>
  </tr>
  <tr>
    <td width="2%" height="25" >&nbsp;</td>
    <td width="34%" valign="top" align="center">&nbsp;</td>
    <td width="64%" valign="top" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" >&nbsp;</td>
    <td valign="top" align="center" class="thinborderBOTTOM">&nbsp;</td>
    <td valign="top" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" >&nbsp;</td>
    <td valign="top" align="center">Registrar</td>
    <td valign="top" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" >&nbsp;</td>
    <td valign="top" align="center">&nbsp;</td>
    <td valign="top" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3" valign="top">This Certification is issued to the above student solely for reference purposes only.</td>
  </tr>
</table>
<%}//if(vStudInfo != null && vStudInfo.size() > 0)%>
<script language="JavaScript">
	window.print();
</script>

</body>
</html>
<%dbOP.cleanUP();%>
