<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
//strSchCode = "CGH";
String strFontSize = "11px";//for cgh, 10px;
boolean bolIsCGH = false;
if(strSchCode == null)
	strSchCode = "";

boolean bolIsNEU = strSchCode.startsWith("NEU");
if(strSchCode.startsWith("CGH") || strSchCode.startsWith("PHILCST")) {
	strFontSize = "10px";
	bolIsCGH = true;
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
	font-size: <%=strFontSize%>;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
-->
</style>
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="javascript">
var iIDFr = 0;
var iIDTo = 0;
//var rowID = 0;
function RowIDClicked2() {
	return;
}
function RowIDClicked(strIDClicked) {//alert("Row ID Fr : "+iIDFr+" Row ID To : "+iIDTo);
	if(iIDFr == 0) {
		iIDFr = strIDClicked;
		return;
	}
	iIDTo = strIDClicked;//alert("Row ID Fr : "+iIDFr+" Row ID To : "+iIDTo);

	//Now i have to delete.
	//--iIDFr;
	//--iIDTo;
	if(iIDFr > iIDTo) {//swap without using variable
		/**
		b = a-b; a = a - b;6; b = a + b;1
		**/
		iIDFr = iIDTo - iIDFr;
		iIDTo = iIDTo - iIDFr;
		iIDFr = iIDTo + iIDFr;
	}
	//alert("Row ID Fr : "+iIDFr+" Row ID To : "+iIDTo);
	var iDelRow = -1;
	for(; iIDFr <= iIDTo; ++iIDFr) {
		if(iDelRow == -1)
			iDelRow = iIDFr;
		//objIDFr = document.getElementById("row_"+iIDFr);
		//objIDTo = document.getElementById("row_"+iIDTo);

		//if(!objIDFr || !objIDTo)
		//	continue;

		//alert("Row ID : "+iIDFr+" removed");
		document.getElementById('myTable1').deleteRow(iDelRow);
	}

	iIDFr = 0;
	iIDTo = 0;
	return;
}
function findRowNumber(element) { // element is a descendent of a tr element

	<%if(!bolIsCGH){///if not CGH, return from here.%>
		return;
	<%}%>

	while(element.tagName.toLowerCase() != "tr") {
		element = element.parentNode; // breaks if no "tr" in path to root
	}
	//alert(element.rowIndex);
	rowID = element.rowIndex;
	this.RowIDClicked(rowID);
}
</script>


<%@ page language="java" import="utility.*,enrollment.GradeSystem, enrollment.GradeSystemExtn, enrollment.CurriculumMaintenance ,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	int i=0; int j=0;
	int iYear = 0;
	int iSem  = 0;
	int iTempYear = 0;
	int iTempSem = 0;
	int iSchYrFrom = 0;
	int iTempSchYrFrom = 0;

	double dGWA        = 0d;

	String[] astrPrepPropInfo = {""," (Preparatory)","(Proper)"};
	String[] astrConvertYear ={"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String strResidencyStatus = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-RESIDENCY STATUS MONITORING","residency_status_print2.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","RESIDENCY STATUS MONITORING",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),
					null);
}
if(WI.fillTextValue("online_advising").compareTo("1") ==0)
	iAccessLevel = 2;
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

GradeSystem GS = new GradeSystem();
GradeSystemExtn GSExtn = new GradeSystemExtn();
enrollment.GradeSystemTransferee GSTransferee = new enrollment.GradeSystemTransferee();

Vector vCourseHist = null;
Vector vResSummary = null;
Vector vResDetail = null;
Vector vTFInfo = null;
Vector vTemp = null;


String strTempCourse  = null;
String strTempMajor   = null;
String strTempType    = null;
String strTempQuery   = null;
String strCourseType  = null;
String strCollegeName = null;
String strDeanName    = null;

java.sql.ResultSet rs = null;
String strSQLQuery    = null;

int iCtr = 0;
int iMaxSel = 0;

if(WI.fillTextValue("stud_id").length() > 0)
{
	vTFInfo = GSTransferee.viewFinalGradePerYrSemTransferee(dbOP,request.getParameter("stud_id"),true);

	vCourseHist = GSExtn.retrieveCourseHistory(dbOP, request.getParameter("stud_id"));
	if (vCourseHist == null)
		System.out.println(GSExtn.getErrMsg());

	student.GWA gwa = new student.GWA();
	dGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));

	vResSummary = GS.getResidencySummary(dbOP,request.getParameter("stud_id"));
	if(vResSummary == null)
		strErrMsg = GS.getErrMsg();
	else{
	if (WI.fillTextValue("selCourse").length()>0)
		{
			if (WI.fillTextValue("selCourse").equals("under"))
			{
				strTempQuery = " and (stud_curriculum_hist.course_type = 0 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 4)";
				vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vResSummary.elementAt(0),"0", strTempQuery);
				strCourseType = "0";
			}
			else if (WI.fillTextValue("selCourse").equals("post"))
			{
				strTempQuery = " and (stud_curriculum_hist.course_type = 1 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 2)";
				vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vResSummary.elementAt(0),"1", strTempQuery);
				strCourseType = "1";
			}
			else
			{
				strTempCourse = WI.getStrValue(WI.fillTextValue("c_idx"+WI.fillTextValue("selCourse")),"");
				strTempMajor = WI.getStrValue(WI.fillTextValue("d_idx"+WI.fillTextValue("selCourse")),"");
				strTempType = WI.getStrValue(WI.fillTextValue("c_type"+WI.fillTextValue("selCourse")),"");
				if (strTempCourse.length()>0 && strTempType.length()>0)
				{
					strTempQuery = " and stud_curriculum_hist.course_index = "+strTempCourse;
					if (!strTempType.equals("1"))
						strTempQuery += " and (stud_curriculum_hist.course_type = 0 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 4)";
					if (strTempMajor.length()>0)
						strTempQuery += " and stud_curriculum_hist.major_index = "+strTempMajor;
					vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vResSummary.elementAt(0),strTempType, strTempQuery);
				}
				strCourseType = strTempType;
			}

		}
		strSQLQuery = " select c_name, dean_name from college "+
						"join course_offered on (course_offered.c_index = college.c_index) "+
						"where course_index=" + (String)vResSummary.elementAt(15);
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strCollegeName = rs.getString(1);
			strDeanName    = rs.getString(2);
		}
		rs.close();
	}
}

boolean bolIsScholastic = false;
//if(WI.fillTextValue("is_scholastic").equals("1"))
	bolIsScholastic = true;  //I am not showing any more lec/lab units.. and combining all into one. ug/masteral/medicine..  .. line number.. 588


///I have to get the enrolled subject.
Vector vCurrentEnrlLoad = null;
///get current enrollment load for CGH.
if((strSchCode.startsWith("UDMC") || bolIsCGH || bolIsNEU) && vResDetail != null && vResDetail.size() > 0) {
	String strSYFromCur = null; String strSYToCur = null; String strSemesterCur = null;
	//first get the current enrollment
	strSQLQuery = "select sy_from,sy_to,semester from stud_curriculum_hist join SEMESTER_SEQUENCE on "+
	"(SEMESTER_SEQUENCE.semester_val = stud_curriculum_hist.semester) "+
	"where user_index = "+	(String)vResSummary.elementAt(0)+" and is_valid = 1 order by sy_from desc,SEM_ORDER desc";

	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strSYFromCur = rs.getString(1);strSYToCur = rs.getString(2);
		strSemesterCur = rs.getString(3);
	}
	rs.close();
	if(strSYFromCur != null) {
		String strGradeSYFrom = null; String strGradeSYTo = null; String strGradeSemester = null;
		enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();
		vCurrentEnrlLoad = reportEnrl.getStudentLoad(dbOP, request.getParameter("stud_id"),strSYFromCur,
							strSYToCur,strSemesterCur);
		if(vCurrentEnrlLoad != null) {
			///i have to take care of subject code NSTP 1 (cwts), cwts is added in vCurrentEnrlLoad
			for(int p = 1; p < vCurrentEnrlLoad.size(); p += 11) {
				strTemp = (String)vCurrentEnrlLoad.elementAt(p);
				//System.out.println(strTemp);
				if(strTemp == null)
					continue;

				int iIndexOf = strTemp.indexOf("(");
				if(iIndexOf != -1 && strTemp.toLowerCase().indexOf("nstp") != -1) {
					strTemp = strTemp.substring(0, iIndexOf);
					vCurrentEnrlLoad.setElementAt(strTemp, p);
				}

			}

			///I have to now run a loop to check if already having grade.
			//int iSizeOfGsVector = vResDetail.size();
			boolean bolInsert = false;int iIndexOf = 0;
			String strYRLevel = (String)((Vector)vCurrentEnrlLoad.remove(0)).elementAt(4);
			for(int x = 0; x < vResDetail.size(); x += 13) {
				if(strSemesterCur.equals(vResDetail.elementAt(x + 1)) &&
					strSYFromCur.equals(vResDetail.elementAt(x + 10))) {
					//bolInsert = true;
					iIndexOf = vCurrentEnrlLoad.indexOf(vResDetail.elementAt(x + 2));
					if(iIndexOf != -1)  {//remove 10 elements
						vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
						vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
						vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
						vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
						vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
						vCurrentEnrlLoad.removeElementAt(iIndexOf);
					}

				}//if(strSemesterCur.equals(vResDetail.elementAt(x + 1)) && --> if not same SY/Term
				/**
				else {//if insert is true, i have to insert here. because
					if(bolIsInsert) {
						///insert here.
						for(int p = 0; p < vCurrentEnrlLoad.size();) {
							vResDetail.insertElementAt(strYRLevel, x++);//year
							vResDetail.insertElementAt(strSemesterCur, x++);//semester
							vResDetail.insertElementAt(vCurrentEnrlLoad.elementAt(p), x++);//sub code.
							vResDetail.insertElementAt(vCurrentEnrlLoad.elementAt(p+1), x++);//sub name
							vResDetail.insertElementAt(vCurrentEnrlLoad.elementAt(p+7), x++);//Lec_unit
							vResDetail.insertElementAt(vCurrentEnrlLoad.elementAt(p+8), x++);//lab_unit
							vResDetail.insertElementAt(null, x++);//grade
							vResDetail.insertElementAt("Grade not encoded", x++);//Remark
							vResDetail.insertElementAt(null, x++);//credit_earned
							vResDetail.insertElementAt(null, x++);//prep_prop_stat
							vResDetail.insertElementAt(strSYFromCur, x++);//sy_from
							vResDetail.insertElementAt(strSYToCur, x++);//sy_to
							vResDetail.insertElementAt(null, x++);///Internship.

							vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
							vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
							vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
							vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
							vCurrentEnrlLoad.removeElementAt(iIndexOf);vCurrentEnrlLoad.removeElementAt(iIndexOf);
						}
						break;
					}
					bolIsInsert = false;
				}**/
			}//for(int x = 0; x < vResDetail.size(); x += 13) 

			///now insert all left over.
			//System.out.println(vCurrentEnrlLoad);
			for(int p = 0; p < vCurrentEnrlLoad.size(); p+= 11) {
				vResDetail.addElement(strYRLevel);//year
				vResDetail.addElement(strSemesterCur);//semester
				vResDetail.addElement(vCurrentEnrlLoad.elementAt(p));//sub code.
				vResDetail.addElement(vCurrentEnrlLoad.elementAt(p+1));//sub name
				vResDetail.addElement(vCurrentEnrlLoad.elementAt(p+7));//Lec_unit
				vResDetail.addElement(vCurrentEnrlLoad.elementAt(p+8));//lab_unit
				if(bolIsCGH)
					vResDetail.addElement("Not Ready");//grade
				else if(bolIsNEU)
					vResDetail.addElement("In Progress");//grade
				else
					vResDetail.addElement("IP");//grade
				vResDetail.addElement(null);//Remark
				vResDetail.addElement(null);//credit_earned
				vResDetail.addElement(null);//prep_prop_stat
				vResDetail.addElement(strSYFromCur);//sy_from
				vResDetail.addElement(strSYToCur);//sy_to
				vResDetail.addElement(null);///Internship.
			}
			//System.out.println(vResDetail.size());
		}//if(vCurrentEnrlLoad != null) {



	}//if(strSYFromCur != null) {

}


/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
if(vResDetail != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}

	int iRowID = 0;

boolean bolIsCollegeOnly = false;
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("CSA") || 
	strSchCode.startsWith("EAC") || strSchCode.startsWith("MARINER"))
	bolIsCollegeOnly = true;

boolean bolShowYrLevel = false;
if(strSchCode.startsWith("DBTC"))
	bolShowYrLevel = true;

%>
<body onLoad="window.print();" bgcolor="#FFFFFF" topmargin="0" leftmargin="0" bottommargin="0" rightmargin="0">
<%if(!bolIsCGH){%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" ><div align="center">
	  <font size="3"><b><%=SchoolInformation.getSchoolName(dbOP,true,false)%></b>
	  <%if(strSchCode.startsWith("UL")){%><br>OFFICE OF THE REGISTRAR<%}%>
	  </font>
	  <%if(!strSchCode.startsWith("UL") && !strSchCode.startsWith("FATIMA")){%>
	  	<br><%=strCollegeName%>
	  <%}%>
	  <br><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
    </tr>
    <tr>
      <td height="19"><hr size="1"></td>
    </tr>
  </table>
<%}if(vResSummary != null && vResSummary.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="19" width="2%">&nbsp;</td>
      <td width="10%">Student: <strong></strong></td>
      <td width="58%"><strong><%=WI.formatName((String)vResSummary.elementAt(1),(String)vResSummary.elementAt(2),(String)vResSummary.elementAt(3),1)%></strong></td>
      <td width="7%">Year: </td>
      <td width="23%"><strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vResSummary.elementAt(10),"0"))]%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="19">&nbsp;</td>
      <td>Course:</td>
      <td><strong><%=(String)vResSummary.elementAt(6)%>
	  <%=WI.getStrValue((String)vResSummary.elementAt(7),"/","","")%> (<%=(String)vResSummary.elementAt(8)%>-<%=(String)vResSummary.elementAt(9)%>)</strong></td>
      <td><% if(WI.fillTextValue("hide_2").length() == 0)
	  			if (!((String)vResSummary.elementAt(11)).equals("1") || !((String)vResSummary.elementAt(11)).equals("2")){%>
GWA:
  <%}%></td>
      <td><% if(WI.fillTextValue("hide_2").length() == 0)
	  			if (!((String)vResSummary.elementAt(11)).equals("1") || !((String)vResSummary.elementAt(11)).equals("2")){%>
        <strong><%=CommonUtil.formatFloat(dGWA,false)%></strong>
        <%}%>
&nbsp;</td>
    <!--
      <td>Status:<strong>
        </strong></td>
      <td><strong>
<%
strResidencyStatus = (String)vResSummary.elementAt(14);
if(strResidencyStatus != null && strResidencyStatus.compareTo("0") ==0)
	strResidencyStatus = "Regular";
else if(strResidencyStatus != null && strResidencyStatus.compareTo("1") ==0)
	strResidencyStatus = "Irregular";
%>			   &nbsp;<%=WI.getStrValue(strResidencyStatus)%></strong></td>
-->    </tr>
<%if(!bolIsCGH && WI.fillTextValue("hide_1").length() == 0){%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25"  colspan="2">
	  Total units required for this course : <strong><%=(String)vResSummary.elementAt(12)%></strong></td>
      <td height="25"  colspan="2">Total units taken : <strong><%=WI.getStrValue(vResSummary.elementAt(13))%></strong></td>
    </tr>
<%}%>
  </table>
	<%if(vTFInfo != null && vTFInfo.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF"><strong>-
          TOR ENTRIES FROM PREVIOUS SCHOOL - </strong></font></div></td>
    </tr>
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="23%"  height="25" ><div align="left"><font size="1"><strong>SUBJECT
          CODE</strong></font></div></td>
      <td width="53%" ><div align="left"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="6%" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="5%" ><div align="left"><font size="1"><strong>FINAL GRADES</strong></font></div></td>
      <td width="10%" ><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
<%//System.out.println(vTFInfo);
for(i=0; i< vTFInfo.size(); )
{
	iSem = Integer.parseInt((String)vTFInfo.elementAt(i+10));
	iSchYrFrom = Integer.parseInt((String)vTFInfo.elementAt(i+8));

	/*System.out.println(vTFInfo.elementAt(i));
	System.out.println(vTFInfo.elementAt(i+1));
	System.out.println(vResDetail.elementAt(i+2));
	System.out.println(vTFInfo.elementAt(i+3));
	System.out.println(vTFInfo.elementAt(i+4));
	System.out.println(vTFInfo.elementAt(i+5));
	System.out.println(vTFInfo.elementAt(i+6));
	*/
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="5">SCHOOL YEAR
	  (<%=(String)vTFInfo.elementAt(i+8) + " - "+(String)vTFInfo.elementAt(i+9)%>)/
	  (<%=astrConvertYear[Integer.parseInt(WI.getStrValue(vTFInfo.elementAt(i + 11),"0"))] +
	  	 " - "+ (String)vTFInfo.elementAt(i+12)%>) </td>
    </tr>
	<%
	//run a loop here to display transferee information.
	 for(j=i; j< vTFInfo.size();)
	 {//System.out.println(vResDetail.elementAt(j+4));System.out.println(vResDetail.elementAt(j+5));

		iTempSem = Integer.parseInt((String)vTFInfo.elementAt(i+10));
		iTempSchYrFrom = Integer.parseInt((String)vTFInfo.elementAt(i+8));

		if(iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)
			break;
	if(vTFInfo.elementAt(i) != null){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="5">School Name: <strong><%=(String)vTFInfo.elementAt(i)%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%=WI.getStrValue(vTFInfo.elementAt(j+1),"&nbsp;")%></td>
      <td><%=(String)vTFInfo.elementAt(j+2)%></td>
      <td><%=(String)vTFInfo.elementAt(j+3)%></td>
      <td><%=(String)vTFInfo.elementAt(j+5)%></td>
      <td><%=(String)vTFInfo.elementAt(j+6)%></td>
    </tr>
	<%
	j = j + 13;
	i = j;
	}
}%>
  </table>
    <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6" bgcolor="#B9B292" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>-
          TOR ENTRIES FROM CURRENT SCHOOL - </strong></font></div></td>
    </tr>
</table>
 <%
 }//if vResDetail !=null - student is having grade created already.
//check residency status in detail.
float fTotalUnits = 0;
float fTotalUnitPerSem = 0;

String strSubCode = null;
boolean bolPutParanthesis = false;

if(vResDetail == null)
{%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <td width="2%" height="25">&nbsp;</td>
  <td><%=WI.getStrValue(GS.getErrMsg())%></td>
</table>
<%}
else {
	if(strCourseType.compareTo("0") ==0 || strCourseType.compareTo("3") ==0 || strCourseType.compareTo("4") ==0 || true)//under graduate
	{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1" onClick="findRowNumber(event.target||event. srcElement);">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><em></em></div></td>
<%if(!bolIsScholastic){%>
      <td colspan="2"><div align="center"><strong><font size="1">UNITS</font></strong></div></td>
<%}if(!bolIsCGH){%>
      <td>&nbsp;</td>
<%}%>
      <td>&nbsp;</td>
<%if(bolIsCGH){%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}if(!bolIsScholastic){%>
      <td>&nbsp;</td>
<%}%>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td width="15%"  height="19"><div align="left"><font size="1"><strong>SUBJECT CODE</strong></font></div></td>
      <td width="32%"><div align="left"><font size="1"><strong><%if(bolIsCGH){%>DESCRIPTIVE TITLE<%}else{%>
      SUBJECT DESCRIPTION
              <%}%></strong></font></div></td>
<%if(!bolIsScholastic){%>
      <td width="7%"><div align="center"><font size="1"><strong>LEC</strong></font></div></td>
      <td width="9%" height="15"><div align="center"><font size="1"><strong>LAB
          </strong></font></div></td>
<%}if(!bolIsCGH){%>
      <td width="12%"><div align="center"><font size="1"><strong><%if(bolIsCGH){%>CREDIT UNIT<%}else{%>CREDITS EARNED<%}%></strong></font></div></td>
<%}%>
      <td width="8%" align="center"><font size="1"><strong><%if(bolIsCGH){%>FINAL<%}%> GRADE</strong></font></td>
<%if(bolIsCGH){%>
      <td width="8%" style="font-size:9px; font-weight:bold" align="center">COMPLETION GRADE</td>
      <td width="8%" style="font-size:9px; font-weight:bold" align="center">CREDIT UNIT</td>
<%}if(!bolIsScholastic){%>
      <td width="16%" align="left"><font size="1"><strong>REMARKS</strong></font></td>
<%}%>    </tr>
    <%for(i=0 ; i< vResDetail.size();){
	if(vResDetail.elementAt(i) != null)
		iYear = Integer.parseInt((String)vResDetail.elementAt(i));
	else
		iYear = -1;
	if(vResDetail.elementAt(i+1) != null)
		iSem = Integer.parseInt((String)vResDetail.elementAt(i+1));
	else if(iYear ==-1)
		iSem = -1;
	else
		iSem = 0;//for summer.
	if(vResDetail.elementAt(i+10) != null)
		iSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(i+10));
	if(iYear != -1 && iSem != -1){%>
    <tr id="row_<%=iRowID++%>">
      <td width="1%">&nbsp;</td>
      <td colspan="2"><strong><u><font size="1"><%if(bolShowYrLevel){%><%=iYear%> Year<%}%> <%=astrConvertSem[iSem]%>, SY
        <%=(String)vResDetail.elementAt(i+10) + " - "+(String)vResDetail.elementAt(i+11)%>
        <%=astrPrepPropInfo[Integer.parseInt(WI.getStrValue(vResDetail.elementAt(i+9),"0"))]%></font></u></strong></td>
<%if(!bolIsScholastic){%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}if(!bolIsCGH){%>
      <td>&nbsp;</td>
<%}%>
      <td>&nbsp;</td>
<%if(bolIsCGH){%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}if(!bolIsScholastic){%>
      <td>&nbsp;</td>
<%}%>
    </tr>
    <%}else if(iYear == -1 && iSem != -1){%>
    <tr>
      <td width="1%">&nbsp;</td>
      <td colspan="2"><strong><u><font size="1"><%=astrConvertSem[iSem]%>, SY
        <%=(String)vResDetail.elementAt(i+10) + " - "+(String)vResDetail.elementAt(i+11)%></font></u></strong></td>
<%if(!bolIsScholastic){%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}if(!bolIsCGH){%>
      <td>&nbsp;</td>
<%}%>
      <td>&nbsp;</td>
<%if(bolIsCGH){%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}if(!bolIsScholastic){%>
      <td>&nbsp;</td>
<%}%>
    </tr>
<%} for(j=i; j< vResDetail.size();){

	//I have to check if this is for math/english enrichment and if stud has passed - for CGH only..
	//if math/eng enrichment and passed, I have to put parantheris.
	strSubCode = (String)vResDetail.elementAt(j+2);
	/**
	if(vMathEnglEnrichment != null &&
		WI.getStrValue(vResDetail.elementAt(j+7)).toLowerCase().startsWith("p") &&
			vMathEnglEnrichment.indexOf(strSubCode) != -1)
		bolPutParanthesis = true;
	else
		bolPutParanthesis = false;
	**/
	if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
		bolPutParanthesis = true;
		try {
			double dGrade = Double.parseDouble((String)vResDetail.elementAt(j + 6));
			//System.out.println(dGrade);
			bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
			if(dGrade < 5d)
				vResDetail.setElementAt("(3.0)",j + 8);
			else
				vResDetail.setElementAt("(0.0)",j + 8);

		}
		catch(Exception e){vResDetail.setElementAt("(0.0)",j + 8);}
	}
	else
		bolPutParanthesis = false;
//		System.out.println(bolPutParanthesis);
//		System.out.println(strSubCode);

//System.out.println(vResDetail.elementAt(j+4));System.out.println(vResDetail.elementAt(j+5));

	if(iYear != -1)
		iTempYear = Integer.parseInt(WI.getStrValue((String)vResDetail.elementAt(j),"0"));
	else
		iTempYear = -1;
	if(iSem != -1)
	{
		if(vResDetail.elementAt(j+1) == null)
			iTempSem = 0;
		else
			iTempSem  = Integer.parseInt((String)vResDetail.elementAt(j+1));
	}
	else
		iTempSem = -1;

	if(vResDetail.elementAt(j+10) != null)
		iTempSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(j+10));

	if(iTempYear!= iYear || iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)//and check for school year ;-)
		break;
	//only if remark status is passed.
	//if( ((String)vResDetail.elementAt(j+7)).compareToIgnoreCase("passed") ==0)
		try {
		fTotalUnitPerSem += Float.parseFloat(WI.getStrValue(vResDetail.elementAt(j+8),"0"));
		}catch(Exception e){}
	 %>
    <tr id="row_<%=iRowID++%>">
      <td>&nbsp;</td>
      <td  height="19"><div align="left"><%=(String)vResDetail.elementAt(j+2)%></div></td>
      <td><%=(String)vResDetail.elementAt(j+3)%></td>
<%if(!bolIsScholastic){%>
      <td><div align="center"><%=(String)vResDetail.elementAt(j+4)%> </div></td>
      <td><div align="center"><%=(String)vResDetail.elementAt(j+5)%> </div></td>
<%}if(!bolIsCGH){%>
      <td align="center">
<%if(!bolIsCGH && !bolIsNEU){%><%=WI.getStrValue(vResDetail.elementAt(j+8))%><%}else{
strTemp = WI.getStrValue(vResDetail.elementAt(j+8),"0");
if(strTemp.indexOf(".") == -1)
	strTemp = strTemp + ".0";
%>
<%=strTemp%><%}%></td>
<%}%>
      <td align="center">
       
		<%if(bolIsCGH){
			strTemp = CommonUtil.formatFloat((String)vResDetail.elementAt(j+6),true);
			if(strTemp.equals("Not Ready"))
				strTemp = "In Progress";
			else if(bolPutParanthesis)
				strTemp = "(" + strTemp + ")";
			%>
			<%=strTemp%>
		<%}else{
		strTemp = (String)vResDetail.elementAt(j+6);
		if(bolIsNEU && strTemp != null && (strTemp.endsWith(".0") || strTemp.length() == 3) && strTemp.indexOf(".") > -1)
			strTemp = strTemp+"0";
		%>
        	<%=strTemp%>
		<%}%>
        </td>
<%if(bolIsCGH){%>
      <td align="center">
	        <%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vResDetail.size() > (j + 5 + 13) && vResDetail.elementAt(j + 6) != null && ((String)vResDetail.elementAt(j + 6)).toLowerCase().indexOf("inc") != -1 &&
		((String)vResDetail.elementAt(j + 2)).compareTo((String)vResDetail.elementAt(j + 2 + 13)) == 0 ){ //sub code,
			strTemp = (String)vResDetail.elementAt(j + 3 + 8);
		%>
      <%=CommonUtil.formatFloat((String)vResDetail.elementAt(j + 6 + 13),true)%>
        <%j += 13;}%>
        &nbsp; </div></td>
      <td align="center">
	<%
	strTemp = WI.getStrValue(vResDetail.elementAt(j+8),"0");
	if(strTemp.indexOf(".") == -1)
		strTemp = strTemp + ".0";
	//if(bolPutParanthesis)
	//	strTemp = "(3.0)";%>
	<%=strTemp%></td>
<% } // only for CGH.


if(!bolIsScholastic){%>
      <td><%=WI.getStrValue(vResDetail.elementAt(j+7))%></td>
<%}%>
    </tr>

    <%if(vResDetail.elementAt(j+12) != null){%>
    <tr id="row_<%=iRowID++%>">
      <td>&nbsp;</td>
      <td  height="19" colspan="7"><font size="1"><%=(String)vResDetail.elementAt(j+12)%></font></td>
<%if(bolIsCGH){%>
      <td>&nbsp;</td>
<%}if(!bolIsScholastic){%>
      <td>&nbsp;</td>
<%}%>
    </tr>
    <%}
	j = j+13;
	i = j;
	}///end of inner loop%>
<%if(false){%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%if(!bolIsScholastic){%>
      <td><div align="center"></div></td>
      <td><div align="center"></div></td>
<%}if(!bolIsCGH){%>
      <td>&nbsp;</td>
<%}%>
      <td>&nbsp;</td>
<%if(bolIsCGH){%>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <%}if(!bolIsScholastic){%>
      <td>&nbsp;</td>
<%}%>
    </tr>
<%}
if(!bolIsCGH && WI.fillTextValue("hide_1").length() == 0){%>
    <tr>
      <td colspan="8"><div align="center"><em>Total units completed for this semester
          :<strong> <%=fTotalUnitPerSem%></strong></em></div></td>
<%if(false){%>      <td colspan="2">&nbsp;</td><%}%>
    </tr>
<%}///do not show total units completed.
fTotalUnits += fTotalUnitPerSem;
fTotalUnitPerSem = 0;
}//end of outer loop %>
    <tr>
      <td height="18" colspan="10">&nbsp;</td>
    </tr>
  </table>
<%}//end of displaying for graduate course.
else if(strCourseType.compareTo("2") ==0)//College of Medicine.
{%>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td>&nbsp;</td>
      <td  height="19" ><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td colspan="2"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td><font size="1"><strong>TOTAL LOAD</strong></font></td>
      <td><div align="center"><strong><font size="1">CREDIT EARNED</font></strong></div></td>
      <td><font size="1"><strong>GRADE</strong></font></td>
      <td width="8%"><font size="1"><strong>REMARK</strong></font></td>
    </tr>
    <%
	String strMainSubject = null;//System.out.println(vResDetail);
	for(i=0 ; i< vResDetail.size();){
		iYear = Integer.parseInt((String)vResDetail.elementAt(i));
		iSem = Integer.parseInt((String)vResDetail.elementAt(i+1));
		iSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(i+12));%>
    <tr>
      <td align="center">&nbsp;</td>
      <td colspan="7"><font size="1"><strong><u> <%=iYear%> YEAR/<%=iSem%> SEMESTER,
        SY <font size="1"><%=(String)vResDetail.elementAt(i+12) + " - "+(String)vResDetail.elementAt(i+13)%></font></u></strong></font></td>
    </tr>
    <%for(j = i ; j< vResDetail.size();){
		iTempYear = Integer.parseInt((String)vResDetail.elementAt(j));
		iTempSem = Integer.parseInt((String)vResDetail.elementAt(j+1));
		iTempSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(i+12));

	if(iTempYear != iYear || iTempSem != iSem ||  iTempSchYrFrom != iSchYrFrom) break;
	strMainSubject = (String)vResDetail.elementAt(j+2);%>
    <tr>
      <td align="center"><em></em></td>
      <td align="center"><div align="left"><%=strMainSubject%></div></td>
      <td  colspan="2" align="center"><div align="left"><%=(String)vResDetail.elementAt(j+3)%></div></td>
      <td align="center"><div align="left"><%=(String)vResDetail.elementAt(j+6)%> (<%=(String)vResDetail.elementAt(j+8)%>)
        </div></td>
      <td align="center"><%=WI.getStrValue(vResDetail.elementAt(j+11))%></td>
      <td align="center"><div align="left">
          <%//Display F for failed grade.
	  if( ((String)vResDetail.elementAt(j+10)).toLowerCase().indexOf("fail") != -1){%>
          F
          <%}else{%>
          <%=(String)vResDetail.elementAt(j+9)%>
          <%}%>
        </div></td>
      <td><%=(String)vResDetail.elementAt(j+10)%></td>
    </tr>
<%if(vResDetail.elementAt(j + 14) != null){%>
    <tr>
      <td ></td>
      <td></td>
      <td  colspan="6"><font size="1"><%=(String)vResDetail.elementAt(j+14)%></font></td>
    </tr>
    <%}
	for(int k = j ; k< vResDetail.size();)//check for sub_subject list
	{
		if(true)//forced break - because I am not displaying the sub Subject information.
			break;
		if(strMainSubject.compareTo((String)vResDetail.elementAt(k+2)) !=0)//check if there is a main in next entry.
		{
			j = j-15;
			break;
		}
		if(vResDetail.elementAt(j+4) == null)
			break;
		%>
    <tr>
      <td align="center">&nbsp;</td>
      <td width="21%"  height="19">&nbsp;</td>
      <td>&nbsp;&nbsp;<%=(String)vResDetail.elementAt(j+4)%></td>
      <td width="27%"><%=(String)vResDetail.elementAt(j+5)%></td>
      <td width="10%"><%=(String)vResDetail.elementAt(j+7)%></td>
      <td width="8%">&nbsp;</td>
      <td width="6%"><%=(String)vResDetail.elementAt(j+9)%></td>
      <td><%=(String)vResDetail.elementAt(j+10)%></td>
    </tr>
    <%
		k = k +15;
		j = k;

	}//show the sub subject.

	j = j+15;
	i = j;
  }//show the main subject for same year/ semester.%>
    <tr>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td  colspan="2" align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
    <%}//show major / sub subject detail %>
    <!--    <tr>
      <td colspan="8" align="center"><strong>4th Year </strong></td>
    </tr>
    <tr>
      <td colspan="8" align="center"><strong><u>Twelve Full-Month Clinical Clerkship
        Program</u></strong></td>
    </tr>-->
    <tr>
      <td colspan="8" align="center">&nbsp;</td>
    </tr>
    <%
}//end of displyaing college of medicine course.
else if(strCourseType.compareTo("1") ==0)
{
	%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%">&nbsp;</td>
      <td width="17%" height="25"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td width="28%"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="16%"><font size="1"><strong>TOTAL LOAD</strong></font></td>
      <td width="20%"><div align="center"><strong><font size="1">CREDIT EARNED</font></strong></div></td>
      <td width="9%"><font size="1"><strong>GRADE</strong></font></td>
      <td width="9%"><font size="1"><strong>REMARK</strong></font></td>
    </tr>
    <%
for(i=0 ; i< vResDetail.size();)
{
if(vResDetail.elementAt(i+1) != null)
	iSem = Integer.parseInt((String)vResDetail.elementAt(i+1));
else
	iSem = 0;//for summer.
if(vResDetail.elementAt(i + 10) != null)
	iSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(i + 10));

if(iSem != -1){%>
    <tr>
      <td width="1%">&nbsp;</td>
      <td colspan="7"><strong><u><font size="1"><%=astrConvertSem[iSem]%>,SY <%=(String)vResDetail.elementAt(i + 10) + " - "+(String)vResDetail.elementAt(i+11)%></font></u></strong></td>
    </tr>
    <%}
 for(j=i; j< vResDetail.size();) {
 	if(iSem != -1) {
		if(vResDetail.elementAt(j+1) == null)
			iTempSem = 0;
		else
			iTempSem  = Integer.parseInt((String)vResDetail.elementAt(j+1));
	}
	else
		iTempSem = -1;

	if(vResDetail.elementAt(j + 10) != null)
		iTempSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(j + 10));

	if(iTempSem != iSem || iTempSchYrFrom != iSchYrFrom)//and check for school year ;-)
		break;
	 %>
    <tr>
      <td>&nbsp;</td>
      <td  height="19"><%=(String)vResDetail.elementAt(j+2)%></td>
      <td><%=(String)vResDetail.elementAt(j+3)%></td>
      <td align="center"><%=(String)vResDetail.elementAt(j+4)%> </td>
      <td align="center"><%=(String)vResDetail.elementAt(j+8)%></td>
      <td align="center"><%=WI.getStrValue(vResDetail.elementAt(j+6))%></td>
      <td>
        <%//Display F for failed grade.
	  if( ((String)vResDetail.elementAt(j+7)).toLowerCase().indexOf("fail") != -1){%>
        F
        <%}else{%>
        <%=(String)vResDetail.elementAt(j+7)%>
        <%}%>
      </td>
    </tr>
<%if(vResDetail.elementAt(j + 12) != null ){%>
    <tr>
      <td>&nbsp;</td>
      <td  height="19">&nbsp;</td>
      <td colspan="5"><font size="1"><%=(String)vResDetail.elementAt(j+12)%></font></td>
    </tr>
    <%}
j = j+13;
i = j;
}///end of inner loop%>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><em></em></div></td>
      <td><div align="center"></div></td>
      <td><div align="center"></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%
}//end of outer loop %>
  </table>
<%
			}//only if there course type is DOCTORAL / MASTERAL.
		}//if residency summery exisits%>
	<%}//if student residency status in detail exists.%>
<table cellpadding="0" cellspacing="0" width="100%" border="0">
  <%if(WI.fillTextValue("remarks").length() > 0 && !WI.fillTextValue("remarks").equals("null")) {%>
  <tr>
    <td colspan="2"><font size="2"><br>
      <%=WI.fillTextValue("remarks")%></font></td>
  </tr>
  <%}%>
  <tr>
    <td width="59%" valign="bottom"><div align="left"><br>

<%if(!strSchCode.startsWith("UL")){%>
        <font size="1">Printed by: <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></font>
<%}%>
	</div></td>
	<td width="41%" align="right"><div align="center"><strong><font size="2">
<%if(strSchCode.startsWith("AUF")){%>
		<u><%=WI.getStrValue(strDeanName,"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></u><br>
        </font></strong>
		Dean
<%}else{
int iFormatName = 1;
if(bolIsCGH)
	iFormatName = 7;

strTemp = CommonUtil.getNameForAMemberType(dbOP,"University Registrar",iFormatName);

//for UL, they encode the name of incharge..

%>	<%=WI.getStrValue(WI.fillTextValue("pos_new"), strTemp)%><br>
        </font></strong>
        <%if(!bolIsCollegeOnly  && !strSchCode.startsWith("CLDH") && !strSchCode.startsWith("CGH") && !strSchCode.startsWith("UDMC") && !strSchCode.startsWith("DBTC") && !strSchCode.startsWith("FATIMA") ){%>
        	<%=WI.getStrValue(WI.fillTextValue("des_new"), "University Registrar")%>
        <%}else{%>
	        Registrar
		<%}%>
<%}%></div>
	</td>
  </tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>
