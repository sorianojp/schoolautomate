<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

if(strSchCode == null) {%>
		<p style="font-family:Geneva, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000;"> You are already logged out. please login again.</p>
<%return;}
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
	font-size: 9px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	}

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborderLegend {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
var imgWnd;
function PrintPg() {
	document.gsheet.print_page.value = "1";
	document.gsheet.submit();
}
function CopyAll()
{
	document.gsheet.print_page.value = "";
	if(document.gsheet.copy_all.checked)
	{
		if(document.gsheet.date0.value.length == 0 || document.gsheet.time0.value.length ==0) {
			alert("Please enter first Date and time field input.");
			document.gsheet.copy_all.checked = false;
			return;
		}
		ReloadPage();
	}
}
function PageAction(strAction)
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value=strAction;
		
	if(document.gsheet.show_save.value == "1") 
		document.gsheet.hide_save.src = "../../../images/blank.gif";
	if(document.gsheet.show_delete.value == "1")
		document.gsheet.hide_delete.src = "../../../images/blank.gif";
	if(strAction ==0) 
		document.gsheet.delete_text.value = "deleting in progress....";
	if(strAction ==1)
		document.gsheet.save_text.value = "Saving in progress....";
	
	this.ShowProcessing();
}
function ReloadPage()
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value="";
	if(document.gsheet.show_save.value == "1")
		document.gsheet.hide_save.src = "../../../images/blank.gif";
	if(document.gsheet.show_delete.value == "1")
		document.gsheet.hide_delete.src = "../../../images/blank.gif";
	this.ShowProcessing();
}

function ChangeInfo(strLabelID) {
	
	var strNewInfo = prompt('Please enter new Value.',document.getElementById(strLabelID).innerHTML);
	if(strNewInfo == null || strNewInfo.legth == 0)
		return;
	document.getElementById(strLabelID).innerHTML = strNewInfo;
}
</script>


<body topmargin="0" bottommargin="0" <%if(WI.fillTextValue("no_print").length() == 0) {%>onLoad="window.print();"<%}%>>
<form name="gsheet" method="post">
<%
	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
	Vector vSecDetail = null;
	boolean bolPageBreak = false;
	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet_final_report_print_cit.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),"Registrar Management","GRADES",request.getRemoteAddr(),null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),null);

}**/
int iAccessLevel = 2;

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
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
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();
String[] astrConvSemester = {"SUMMER", "1ST SEM", "2ND SEM", "3RD SEM"};


String strSubSecIndex   = null;
String strOfferedByCollege = null;

Vector vRetResult = null;
Vector vEncodedGrade = new Vector();


//get here necessary information.
if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'" + WI.fillTextValue("section_name")+ "'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = " + WI.fillTextValue("subject") +
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+ WI.fillTextValue("sy_to") +
						" and e_sub_section.offering_sem="+ WI.fillTextValue("offering_sem")+" and is_lec=0");
}
if(strSubSecIndex != null) {//get here subject section detail. 
	
	strOfferedByCollege = dbOP.mapOneToOther("e_sub_section","sub_sec_index", strSubSecIndex, 
											"OFFERED_BY_COLLEGE", "");
	
	
	if(!strSchCode.startsWith("AUF"))
		vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	else
		vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex,true);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

boolean bolSeparateMixedSection = WI.fillTextValue("separate_grades").equals("1");

if(strSubSecIndex != null) {
	vRetResult = gsExtn.getAllGradesEncoded(dbOP,request,strSubSecIndex,bolSeparateMixedSection);

	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
}

    Vector vEmpRec = new enrollment.Authentication().operateOnBasicInfo(dbOP,request,"0");
	
	if (vRetResult != null) { 
//		System.out.println(vRetResult);
	
		int i = 0; int k = 0; int iNumGrading = 0; int iCount = 0;
		int iMidTermIndex = 0;
		int iMaxStudPerPage =40; 

		if (WI.fillTextValue("num_stud_page").length() > 0)
			iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
		if (WI.fillTextValue("first_page").length() > 0)
			iMaxStudPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("first_page"), "40"));
		//System.out.println(iMaxStudPerPage);

		String strCurrentSubIndex = null;
		int iNumStud = 1;
		int iIncr    = 1; // student count
		
		int iIncKvalue = 0; // add to to accomodate sub_index inserted in element[8]
		
		if (bolSeparateMixedSection){
			iIncKvalue = 1;
		}
		
		String strCollegeName = null;
		String strDeptName = null;
		
		String strDeanName = null;
		String strDeptHeadName = null;
		
		String strRegistrarName = null;

if ((vEmpRec!=null || vEmpRec.size()>0) && !strSchCode.startsWith("AUF")) {
		strCollegeName = (String)vEmpRec.elementAt(13);
		strDeptName = WI.getStrValue((String)vEmpRec.elementAt(14),"&nbsp;");
		if (strSchCode.startsWith("UI") &&  strSubSecIndex != null && strSubSecIndex.length() > 0) {
	

			strCollegeName = dbOP.mapOneToOther("COLLEGE","c_index",strOfferedByCollege,"c_name",null);
			strTemp = dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"OFFERED_BY_DEPT",null);
			if (strTemp != null)
				strDeptName = dbOP.mapOneToOther("department","d_index",strTemp,"d_name",null);
			else
				strDeptName = "&nbsp;";
		}
		
}else{
		strCollegeName = "&nbsp;";
		strDeptName = "&nbsp;";
}

if (strSchCode.startsWith("AUF")){
		astrConvSemester[0] = "Summer";
		astrConvSemester[1] = "First";
		astrConvSemester[2] = "Second";
		astrConvSemester[3] = "Third";
}

int iIndexOf = 0;

boolean bolIsCIT = true;

boolean bolIsFinalCopy = WI.fillTextValue("is_final_copy").equals("1");
//System.out.println("Final Copy: "+WI.fillTextValue("is_final_copy"));
//System.out.println(bolIsFinalCopy);
java.sql.ResultSet rs    = null;
String strFinalPrintDate = null;
String strSQLQuery       = null;

if(strErrMsg == null && bolIsFinalCopy) {

	//make sure can't subject final grade if midter is not yet locked.. 
	if(WI.fillTextValue("grade_for").equals("3")) {//check if mter is already locked
		strSQLQuery = "select VERIFY_DATE from FACULTY_GRADE_VERIFY  where s_s_index = "+strSubSecIndex+" and pmt_sch_index = 2";
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null) {
			dbOP.cleanUP();	%>
				<font style="font-size:16px; font-weight:bold; color:#FF0000">Please Lock Midterm grade first before printing Finals</font>
			<%return;
		}
		
	}
	
	//reset all individual lock status..
	if(WI.fillTextValue("grade_for").equals("3"))
		strSQLQuery = " g_sheet_final ";
	else
		strSQLQuery = "grade_sheet";
	strSQLQuery = "update "+strSQLQuery+" set FORCE_LOCK_STAT = null where sub_sec_index = "+strSubSecIndex;
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	//end of resetting.. 

	
	strSQLQuery = "select VERIFY_DATE, verify_time, verify_index,is_unlocked from FACULTY_GRADE_VERIFY  where s_s_index = "+strSubSecIndex+
	" and pmt_sch_index = "+WI.fillTextValue("grade_for");
	rs = dbOP.executeQuery(strSQLQuery);
	strSQLQuery = null;
	if(rs.next()) {
		if(rs.getString(2) != null)
			strFinalPrintDate = WI.formatDateTime(rs.getLong(2), 5);
		else	
			strFinalPrintDate = WI.formatDate(rs.getDate(1), 6);
		if(rs.getInt(4) == 1)
			strSQLQuery = rs.getString(3);
	}
	rs.close();
	
	//System.out.println(strFinalPrintDate);
	
	if(strFinalPrintDate == null) {//save here.
		strFinalPrintDate = WI.getTodaysDate(1);
		strSQLQuery = "select load_index from faculty_load where sub_sec_index = "+strSubSecIndex +
					  " and user_index = "+(String)request.getSession(false).getAttribute("userIndex")+" and is_valid = 1";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		
		strSQLQuery = "insert into FACULTY_GRADE_VERIFY (LOAD_INDEX,PMT_SCH_INDEX,VERIFY_DATE," +
				      "VERIFIED_BY, s_s_index, verify_time) values (" + strSQLQuery + "," + WI.fillTextValue("grade_for") + ",'" +
          			   WI.getTodaysDate() + "'," + 
					   (String)request.getSession(false).getAttribute("userIndex") + ", "+strSubSecIndex+", " + new java.util.Date().getTime()+")";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
	else if(strSQLQuery != null)
		dbOP.executeUpdateWithTrans("update FACULTY_GRADE_VERIFY set is_unlocked = 0 where verify_index = "+strSQLQuery, null, null, false);
		
}
	

String strSubCode = null;
String strSubName = null;
String strSchedule = null;

if(WI.fillTextValue("subject").length() > 0 ) {
	strSQLQuery = "select sub_code, sub_name from subject where sub_index = "+WI.fillTextValue("subject");
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strSubCode = WI.getStrValue(rs.getString(1)).toUpperCase();
		strSubName = rs.getString(2);
	}
	rs.close();
	
}
if(vSecDetail != null && vSecDetail.size() > 0) {
	for( i = 1; i<vSecDetail.size(); i+=3) {
		if(strSchedule == null)	
			strSchedule = (String)vSecDetail.elementAt(i+ 2);
		else
			strSchedule = strSchedule + ", "+(String)vSecDetail.elementAt(i + 2);
	}
}

boolean bolIsFinal = false;
String strAddlRemark = null;

String strGradeName = null;
if(WI.fillTextValue("grade_for").length() > 0) 
	strGradeName = dbOP.mapOneToOther("FA_PMT_SCHEDULE", "PMT_SCH_INDEX", WI.fillTextValue("grade_for"), "EXAM_NAME", null);
if(strGradeName != null && strGradeName.toLowerCase().startsWith("f"))
	bolIsFinal = true;

for (;iNumStud < vRetResult.size()-1;){%>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="6%"><img src="../../../images/logo/CIT_CEBU.gif" height="70" width="70"></td>
            <td width="94%">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr align="center" style="font-weight:bold">
					  <td><font size="4"><b><%=SchoolInformation.getSchoolName(dbOP,true,false)%></b></font><br>
						  <font size="3">GRADE SHEET</font>
						 <%if(!bolIsFinalCopy) {%><div align="right" style="font-size:16px;">
						 	<%if(WI.fillTextValue("no_print").length() > 0) {%><font color="#FF0000">FOR VIEWING PURPOSE ONLY</font><%}else{%>DRAFT COPY<%}%></div><%}%>
					  </td>
					</tr>
            	</table>
			</td>
          </tr>
  </table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr align="center">
				<td class="thinborderBottom" width="15%" style="font-size:9px;"><%=WI.getStrValue(strSubCode, "&nbsp;")%></td>
				<td width="1%" style="font-size:9px;">&nbsp;</td>
				<td class="thinborderBottom" width="25%" style="font-size:9px;"><%=WI.getStrValue(strSubName, "&nbsp;")%></td>
				<td width="1%" style="font-size:9px;">&nbsp;</td>
				<td class="thinborderBottom" width="12%" style="font-size:9px;"><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to").substring(2)%></td>
				<td width="1%" style="font-size:9px;">&nbsp;</td>
				<td class="thinborderBottom" width="13%" style="font-size:9px;"><%=strSchedule%></td>
				<td width="1%" style="font-size:9px;">&nbsp;</td>
				<td class="thinborderBottom" width="10%" style="font-size:9px;"><%=WI.fillTextValue("section_name")%></td>
			</tr>
			<tr align="center">
				<td style="font-size:9px;">Subject No.</td>
				<td style="font-size:9px;">&nbsp;</td>
				<td style="font-size:9px;">Description of Subject</td>
				<td style="font-size:9px;">&nbsp;</td>
				<td style="font-size:9px;">Sem. & School Year</td>
				<td style="font-size:9px;">&nbsp;</td>
				<td style="font-size:9px;">Time</td>
				<td style="font-size:9px;">&nbsp;</td>
				<td style="font-size:9px;">Section</td>
			</tr>
		</table>
		<%if(vSecDetail != null){%>




<%if (vRetResult != null && vRetResult.size() > 0){ 
	i = 0;
%>
  <table width="100%" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="3%" rowspan="2" class="thinborder"><font color="#000099" size="1"><strong>Count</strong></font></td>
      <%if(!bolIsCIT){%>
	  	<td width="14%" rowspan="2" class="thinborder"><font color="#000099" size="1"><strong>ID. Number</strong></font></td>
	  <%}%>
      <td width="30%" rowspan="2"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>NAME 
          OF STUDENT</strong></font></div></td>
<% strTemp = " COURSE-YR";%>
      <td width="12%" rowspan="2"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong><%=strTemp%></strong></font></div></td>
      <% Vector vPMTSchedule = (Vector)vRetResult.elementAt(0); 
	  	 iNumGrading = vPMTSchedule.size()/2;
		//if(strSchCode.startsWith("UDMC"))
		//	iNumGrading = 1;//show only final grade.
		for (i = 0; i < iNumGrading; ++i){
			strTemp = (String)vPMTSchedule.elementAt((i*2)+1);
			
			if (strTemp.toUpperCase().startsWith("PRE")){
				iMidTermIndex = i;
				continue;
			}
		%>
      <td colspan="2" align="center"  class="thinborder"><font color="#000099" size="1"><%=strTemp%></font></td>
      <%} // end for loop%>
      <% if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") ){%>
      <td width="16%" rowspan="2"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>REMARKS</strong></font></div></td>
      <%}%>
    </tr>
    <tr>
      <% for (k = 0; k < iNumGrading; ++k) {
	  		if (k == iMidTermIndex) 
				continue;
	  %>
      <td  class="thinborder" align="center" width="5%">ABS</td>
      <td  class="thinborder" align="center" width="5%">GRADES</td>
	  <%}%>
    </tr>
    <%	String strFontColor = null;//red if failed.
		String strGrade     = null;	
		for(iCount = 1; iNumStud<vRetResult.size(); iNumStud+=9+(iNumGrading-1)+iIncKvalue,++iIncr, ++iCount){
		i = iNumStud;
		if (iCount > iMaxStudPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;
		
	if (bolSeparateMixedSection && (!((String)vRetResult.elementAt(i+8)).equals(strCurrentSubIndex))) {
		iIncr = 1;  // reset student number count
		bolPageBreak = true;		
		break;
	}
	
	if( ((String)vRetResult.elementAt(i+7)).toLowerCase().startsWith("f"))
		strFontColor = " ";//strFontColor = " color=red";
	else	
		strFontColor = "";

	%>
    <tr> 
      <td  class="thinborder"<%=strFontColor%>><font size="1">&nbsp;<%=iIncr%></font></td>
      <%if(!bolIsCIT){%>
		<td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
	  <%}%>
      <td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
<% 
	strTemp = " - " + WI.getStrValue((String)vRetResult.elementAt(i+5));
%>

	  
      <td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+3)+WI.getStrValue((String)vRetResult.elementAt(i+4),"/","","") +  strTemp%></font></td>
      <% for (k = 0; k < iNumGrading; ++k) {
	  		if (k == iMidTermIndex) 
				continue;
			else if (k < (iNumGrading - 1) && strSchCode.startsWith("UDMC"))
				continue;
			strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);
			
			iIndexOf = gsExtn.vAttendance.indexOf(vRetResult.elementAt(i+1));
			//System.out.println(gsExtn.vAttendance);
			if(iIndexOf > -1) {//if this gives error must check exam schedule index.
				strTemp = (String)gsExtn.vAttendance.elementAt(iIndexOf - 1);
				iIndexOf = iIndexOf - 3;
				
				strAddlRemark = (String)gsExtn.vAttendance.elementAt(iIndexOf + 4);
				//System.out.println(strAddlRemark);
				gsExtn.vAttendance.remove(iIndexOf);
				gsExtn.vAttendance.remove(iIndexOf);
				gsExtn.vAttendance.remove(iIndexOf);
				gsExtn.vAttendance.remove(iIndexOf);
				gsExtn.vAttendance.remove(iIndexOf);
			}
			else {
				strTemp = null;
			}
	  		
	  %>
      <td align="center"  class="thinborderGrade"<%=strFontColor%>><font size="1"<%=strFontColor%>><%=WI.getStrValue(strTemp, "&nbsp;")%></font></td>
      <td align="center"  class="thinborderGrade"<%=strFontColor%>><font size="1"<%=strFontColor%>><%=strGrade%></font></td>
      <%} //end for loop k = 0; k < iNumGrading; ++k%>
      <td align="center"  class="thinborder"><font size="1"<%=strFontColor%>><%=WI.getStrValue(strAddlRemark, (String)vRetResult.elementAt(i+7)+" ", "", (String)vRetResult.elementAt(i+7))%> <%strAddlRemark = null;%></font></td>
    </tr>
    <%} //end for loop i = iNumStud, iCount = 1; i<vRetResult.size(); i+=9+(iNumGrading-1), iCount++ 
		strTemp = Integer.toString(5+iNumGrading);
	
	if ( iNumStud > vRetResult.size()-1 || iIncr == 1) {%>
    <%}
	boolean bolPrintCount = true; boolean bolPrintOnce = true;
	for(int a = iIncr; a <= iMaxStudPerPage ; ++a, ++iIncr) {bolPrintCount = true;%>
		<tr> 
			<%for(int b = Integer.parseInt(strTemp); b > 0; --b) {%>
		  		<td class="thinborder">&nbsp;<%if(bolPrintCount){%><%=iIncr%><%}%></td>
				<%if(bolPrintOnce) {--b;bolPrintOnce=false;%>
					<td class="thinborder">****** NOTHING FOLLOWS ******</td>
				<%}%>
		  	<%if(bolPrintCount) bolPrintCount = false;}%>
		</tr>
	<%}%>
	
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="50%">Midterm</td>
      <td width="50%">Final</td>
  	</tr>
    <tr align="center"> 
      <td><br><u>&nbsp;&nbsp;&nbsp;&nbsp;<%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),7).toUpperCase()%>&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
      <td>
		  <u>
		  <%if(bolIsFinal) {%>
			&nbsp;&nbsp;&nbsp;&nbsp;<%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),7).toUpperCase()%>&nbsp;&nbsp;&nbsp;&nbsp;
		  <%}else{%>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <%}%>
		  </u>
	  </td>
  	</tr>
    <tr align="center">
      <td>Instructor</td>
      <td>Instructor</td>
    </tr>
    <tr align="center">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%
strTemp = WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strOfferedByCollege,"DEAN_NAME"," and is_del = 0")).toUpperCase();
%>
    <tr align="center">
      <td><u>&nbsp;&nbsp;&nbsp;&nbsp;<%=strTemp%>&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
      <td>
		  <u>
		  <%if(bolIsFinal) {%>
			&nbsp;&nbsp;&nbsp;&nbsp;<%=strTemp%>&nbsp;&nbsp;&nbsp;&nbsp;
		  <%}else{%>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <%}%>
		  </u>
	  </td>
    </tr>
    <tr align="center">
      <td>Dean</td>
      <td>Dean</td>
    </tr>
    <tr align="center">
      <td align="left">Note: Under no circumtances should the mid-term and final "GRADES" columns be left blank. Indicate date of dropping or withdrawing the subject.</td>
      <td align="right"><%=WI.getStrValue(strFinalPrintDate)%></td>
    </tr>
  </table>
  
  <%
  } //end vRetResult size  == 0
} // vSecDetail != null
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END.
if (bolPageBreak){%>
  <DIV style="page-break-before:always" >&nbsp;</DIV>
    <%}//page break ony if it is not last page.
	} //end for (iNumStud < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
    <input type="hidden" name="page_action">
    <input type="hidden" name="print_page">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>