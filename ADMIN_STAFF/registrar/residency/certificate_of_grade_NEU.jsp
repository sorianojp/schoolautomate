<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strFontSize = "11px";//for cgh, 10px;
	boolean bolIsCGH = false;
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Certificate of Grade NEU</title>
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
TD.thinborderBOTTOMRIGHT {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}
TD.thinborderBOTTOMLEFT {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}
TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}
-->
</style>
<%	response.setHeader("Pragma","No-Cache");
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

	float fGWA         = 0f;

	String[] astrPrepPropInfo = {""," (Preparatory)","(Proper)"};
	String[] astrConvertYear ={"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	String strResidencyStatus = null;

//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-RESIDENCY STATUS MONITORING","residency_status_print2.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
        <p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
        <%return;
	}
//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
				"Registrar Management","RESIDENCY STATUS MONITORING",request.getRemoteAddr(),null);
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),null);
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

    if(WI.fillTextValue("stud_id").length() > 0){
	   vTFInfo = GSTransferee.viewFinalGradePerYrSemTransferee(dbOP,request.getParameter("stud_id"),true);

	//vCourseHist = GSExtn.retrieveCourseHistory(dbOP, request.getParameter("stud_id"));
	//if (vCourseHist == null)
	//	System.out.println(GSExtn.getErrMsg());

	//student.GWA gwa = new student.GWA();
	//fGWA = gwa.computeGWAForResidency(dbOP,WI.fillTextValue("stud_id"));

	vResSummary = GS.getResidencySummary(dbOP,request.getParameter("stud_id"));
	if(vResSummary == null)
		strErrMsg = GS.getErrMsg();
	else{
	     if (WI.fillTextValue("selCourse").length()>0){
			if (WI.fillTextValue("selCourse").equals("under")){
				strTempQuery = " and (stud_curriculum_hist.course_type = 0 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 4)";
				vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vResSummary.elementAt(0),"0", strTempQuery);
				strCourseType = "0";
			}else if (WI.fillTextValue("selCourse").equals("post")){
				strTempQuery = " and (stud_curriculum_hist.course_type = 1 or stud_curriculum_hist.course_type = 3 or stud_curriculum_hist.course_type = 2)";
				vResDetail = GS.getCompleteResidencyStatus(dbOP,(String)vResSummary.elementAt(0),"1", strTempQuery);
				strCourseType = "1";
			}else{
				strTempCourse = WI.getStrValue(WI.fillTextValue("c_idx"+WI.fillTextValue("selCourse")),"");
				strTempMajor = WI.getStrValue(WI.fillTextValue("d_idx"+WI.fillTextValue("selCourse")),"");
				strTempType = WI.getStrValue(WI.fillTextValue("c_type"+WI.fillTextValue("selCourse")),"");
				if (strTempCourse.length()>0 && strTempType.length()>0){
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
		/*strSQLQuery = " select c_name, dean_name from college "+
						"join course_offered on (course_offered.c_index = college.c_index) "+
						"where course_index=" + (String)vResSummary.elementAt(15);
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strCollegeName = rs.getString(1);
			strDeanName    = rs.getString(2);
		}
		rs.close();*/
	 }
     }

	boolean bolIsScholastic = false;
	if(WI.fillTextValue("is_scholastic").equals("1"))
		bolIsScholastic = true;	
	
	///I have to get the enrolled subject.
	Vector vCurrentEnrlLoad = null;
	///get current enrollment load for CGH.
	if(true || (strSchCode.startsWith("UDMC") || bolIsCGH) && vResDetail != null && vResDetail.size() > 0) {
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
					//if(bolIsCGH)
						vResDetail.addElement("Not Ready");//grade
					//else	
					//	vResDetail.addElement("IP");//grade
					vResDetail.addElement(null);//Remark
					vResDetail.addElement(null);//credit_earned
					vResDetail.addElement(null);//prep_prop_stat
					vResDetail.addElement(strSYFromCur);//sy_from
					vResDetail.addElement(strSYToCur);//sy_to
					vResDetail.addElement(null);///Internship.
				}
				//System.out.println(vResDetail.size());
			}//if(vCurrentEnrlLoad != null) 
		}//if(strSYFromCur != null) 	
	}
	
	/////i have to put parenthesis for math and english enrichment.
	Vector vMathEnglEnrichment = null;
	if(vResDetail != null) {
		vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);	
	}
	int iRowID = 0;
%>
<body onLoad="window.print();" bgcolor="#FFFFFF" topmargin="0" leftmargin="0" bottommargin="0" rightmargin="0">
<%if(vResSummary != null && vResSummary.size()>0){ 
if(vResDetail == null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
		<td width="2%" height="25">&nbsp;</td>
		<td><%=WI.getStrValue(GS.getErrMsg())%></td>
	</tr>
</table>
<%}else {

//check residency status in detail.
	float fTotalUnits = 0;
	float fTotalUnitPerSem = 0;
	
	String strSubCode = null;
	boolean bolPutParanthesis = false;
	 
	boolean bolPageBreak = false;
	int iIncr =0;
	int iMaxSemPerPage =30;	
	for(i=0 ; i< vResDetail.size();i+=13){
	 if(i==0 || bolPageBreak){		
	   if(bolPageBreak){%>
				<div style="page-break-after:always;">&nbsp;</div>
	<%}%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0" onMouseDown="return false">
  <tr>
    <td colspan="2" height="100" align="center">&nbsp;</td>
  </tr>
  
  <tr>
    <td width="83%">&nbsp;</td>
    <td width="17%" align="center"><%=WI.getTodaysDate(6)%></td>
  </tr>   
  <tr>
  	<td colspan="2">&nbsp;</td>
  </tr>
   <tr>
   <%
   strTemp = WI.formatName((String)vResSummary.elementAt(1),(String)vResSummary.elementAt(2),(String)vResSummary.elementAt(3),7);
   %>
    <td align="center" colspan="2" valign="bottom"><%=strTemp%></td>
  </tr>
  <tr>
  	<td colspan="2" height="30">&nbsp;</td>
  </tr>
</table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(i==0 || bolPageBreak){	
  if(bolPageBreak)
    bolPageBreak =false;%>
    <tr>
		<td rowspan="2" align="center">&nbsp;<!--TERM /<br>COURSE NO.--></td>
		<td rowspan="2" align="center">&nbsp;<!--DESCRIPTION TITLE--></td>
		<td colspan="2" align="center"&nbsp;>&nbsp;<!--GRADE--></td>
		<td rowspan="2" align="center">&nbsp;<!--CREDITS <br>EARNED --></td>			
	</tr>
	<tr>
		<td align="center">&nbsp;<!--FINAL--></td>
		<td align="center">&nbsp;<!--RE-EXAM --></td>
	</tr>
<%} int iPrevSem =0;
for(j=i; j< vResDetail.size();){
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
		
	   if(iYear != -1 && iSem != -1 && iSem!=iPrevSem ){%>
	  <tr id="row_<%=iRowID++%>">
		<td colspan="5">
		<%=astrConvertSem[iSem]%> <%=(String)vResDetail.elementAt(i+10) + " - "+(String)vResDetail.elementAt(i+11)%></td>
	  </tr>
	  <% iPrevSem= iSem;}
 

    
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
			bolPutParanthesis = true; 
			if(dGrade < 5d)
				vResDetail.setElementAt("(3.0)",j + 8);
			else 
				vResDetail.setElementAt("(0.0)",j + 8);
			
		}catch(Exception e){vResDetail.setElementAt("(0.0)",j + 8);}
	}else	
		bolPutParanthesis = false;	
//		System.out.println(bolPutParanthesis);
//		System.out.println(strSubCode);
	
//System.out.println(vResDetail.elementAt(j+4));System.out.println(vResDetail.elementAt(j+5));

	if(iYear != -1)
		iTempYear = Integer.parseInt(WI.getStrValue((String)vResDetail.elementAt(j),"0"));
	else
		iTempYear = -1;
	if(iSem != -1){
		if(vResDetail.elementAt(j+1) == null)
			iTempSem = 0;
		else
			iTempSem  = Integer.parseInt((String)vResDetail.elementAt(j+1));
	}else
		iTempSem = -1;

	if(vResDetail.elementAt(j+10) != null)
		iTempSchYrFrom = Integer.parseInt((String)vResDetail.elementAt(j+10));

	if(iTempYear!= iYear || iTempSem != iSem || iTempSchYrFrom != iSchYrFrom){//and check for school year
	bolPageBreak = false;
		break;
	}
	//only if remark status is passed.
	//if( ((String)vResDetail.elementAt(j+7)).compareToIgnoreCase("passed") ==0)
		try {
			fTotalUnitPerSem += Float.parseFloat(WI.getStrValue(vResDetail.elementAt(j+8),"0"));
		}catch(Exception e){}
%>
  <tr id="row_<%=iRowID++%>">
    <td  width="16%" height="19">
	<div align="left" style="padding-left:20px;"><%=(String)vResDetail.elementAt(j+2)%></div></td>
    <td><%=((String)vResDetail.elementAt(j+3)).toUpperCase()%></td>
    <td align="center" width="12%">
	<% strTemp = CommonUtil.formatFloat((String)vResDetail.elementAt(j+6),true);
	   if(strTemp.equals("Not Ready"))
		  strTemp = "In Progress";
	   else if(bolPutParanthesis)
		  strTemp = "(" + strTemp + ")";
	%>
	<%=strTemp%>
	</td>
    <td align="center" width="12%">&nbsp;</td>
    <td align="center" width="12%">
<%strTemp = WI.getStrValue(vResDetail.elementAt(j+8),"0");
  if(strTemp.indexOf(".") == -1)
	strTemp = strTemp + ".0";
//if(bolPutParanthesis)
//	strTemp = "(3.0)";
%>
<%=strTemp%></td>
  </tr>
  <%
	j = j+13;
	i = j;	
	
  if (++iIncr>=iMaxSemPerPage){
	bolPageBreak  =true;
	iIncr =0;  
	break;
  }	
	}///end of inner loop%>
  
<% fTotalUnits += fTotalUnitPerSem;
   fTotalUnitPerSem = 0;
%>
  
</table>
 <%}//end of outer loop 
 }//if residency summery exisits
 }//if student residency status in detail exists.%>
</body>
</html>
<%
dbOP.cleanUP();
%>
