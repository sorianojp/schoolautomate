<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
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
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
	}

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
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


<body topmargin="0" bottommargin="0" onLoad="window.print();">
<form name="gsheet" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
	Vector vSecDetail = null;
	boolean bolPageBreak = false;
	int j = 0;
	java.sql.ResultSet rs = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet.jsp");
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
String[] astrConvSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};


String strSubSecIndex   = null;
String strOfferedByCollege = null;

Vector vRetResult = null;
Vector vEncodedGrade = new Vector();

String strCourseCode = null;
String strYearLevel  = null;

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
	
	
	strTemp = 
		" select course_code, year from curriculum "+
		" join e_sub_section on (e_sub_section.cur_index = curriculum.cur_index) "+
		" join course_offered on (course_offered.course_index = curriculum.course_index) "+
		" where curriculum.is_valid = 1 and e_sub_section.is_valid =1 and sub_sec_index = "+strSubSecIndex+
		" and section = '"+WI.fillTextValue("section_name")+"'";
	rs = dbOP.executeQuery(strTemp);
	if(rs.next()){
		strCourseCode = rs.getString(1);
		strYearLevel  = rs.getString(2);
	}rs.close();

	if(!strSchCode.startsWith("AUF"))
		vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	else
		vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex,true);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

boolean bolSeparateMixedSection = false;//WI.fillTextValue("separate_grades").equals("1");
Vector vAddlGrade = new Vector();//additional grade. to hold grade cgh and grade 2
String strAvgGrade = null;



if(strSubSecIndex != null) {
	vRetResult = gsExtn.getAllGradesEncoded(dbOP,request,strSubSecIndex,bolSeparateMixedSection);

	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else {
		String strSQLQuery = "select gs_index, grade_cgh from g_sheet_final where sub_sec_index = "+strSubSecIndex;
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vAddlGrade.addElement(new Integer(rs.getInt(1)));
			vAddlGrade.addElement(rs.getString(2));
		}
		rs.close();
	}

}

    Vector vEmpRec = new enrollment.Authentication().operateOnBasicInfo(dbOP,request,"0");
	
	if (vRetResult != null) { 
//		System.out.println(vRetResult);
	
		int i = 0; int k = 0; int iNumGrading = 0; int iCount = 0;
		int iMidTermIndex = -1;
		int iMaxStudPerPage =40; 

		if (WI.fillTextValue("num_stud_page").length() > 0)
			iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
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
		
		//String strDeanName = null;
		String strDeptHeadName = null;
		
		String strRegistrarName = null;

		strCollegeName = (String)vEmpRec.elementAt(13);
		strDeptName = WI.getStrValue((String)vEmpRec.elementAt(14),"&nbsp");
		if (strSubSecIndex != null && strSubSecIndex.length() > 0) {
			strDeptHeadName = "select dean_name,c_name from college "+
						"join e_sub_section on (e_sub_section.offered_by_college = c_index) "+
						"where sub_sec_index = "+strSubSecIndex;
			rs = dbOP.executeQuery(strDeptHeadName);
			if(rs.next()) {
				strDeptHeadName = rs.getString(1);
				strCollegeName  = rs.getString(2);
			}
			else {
				strDeptHeadName = null;
				strCollegeName  = null;
			}
			rs.close();
		}
		else{
			strCollegeName = "&nbsp;";
			strDeptName = "&nbsp;";
		}

if (strSchCode.startsWith("AUF")){
		astrConvSemester[0] = "Summer";
		astrConvSemester[1] = "First";
		astrConvSemester[2] = "Second";
		astrConvSemester[3] = "Third";
}

for (;iNumStud < vRetResult.size()-1;){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">    
	<tr> 
      <td width="81%"><div align="center">
	  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
	  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
	  <br><%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
	  
	  <br>
	  <br>
	  GRADING SHEET<BR>
	  <%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>,
	  School Year <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
	  
	  </div></td>
      <td width="17%" valign="top">
	  	<table width="100%" class="thinborderall" cellpadding="0" cellspacing="0">
			<tr><td style="font-size:9px;">
				Form I.D.: Deans 0010<br>
				Rev. No: 06<br>
				Rev. Date:  Jan.15, 2011
			</td>
			</tr>
		</table>
	  
	  </td>
      <td width="2%">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vSecDetail != null){%>
<!--
  <table border=0 cellpadding="0" cellspacing="0" width="100%">
      <%
	  strTemp = "";
		for( i = 1; i<vSecDetail.size(); i+=3){
		  if(i >1){
			strTemp += "<br>";
		   }
	    	strTemp = WI.getStrValue((String)vSecDetail.elementAt(i+2)) + 
					WI.getStrValue((String)vSecDetail.elementAt(i),"/","","");
       }
	 %>
    <tr align="center" valign="bottom">
      <td width="13%" height="25"><u><%=WI.fillTextValue("section_name")%></u></td>
      <td width="27%"><u><%=strTemp%></u></td>
      <td width="27%">
<% 
	strErrMsg = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_code +' (' + sub_name+')'"," and is_del=0");
%>
        <u><%=(WI.getStrValue(strErrMsg)).toUpperCase()%></u>
	  </td>
      <td width="33%"><u><%=GS.getLoadingForSubject(dbOP, request.getParameter("subject"))%></u></td>
    </tr>
    <tr align="center" valign="top">
      <td height="25">Section</td>
      <td>Day-Time</td>
      <td>Subject/Description</td>
      <td># of Units </td>
    </tr>
  </table>
-->
  <%
	if (vRetResult != null && vRetResult.size() > 0){ 
	i = 0;
	double dDynamicWidth = 0d;
%>
  <table width="100%" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td  class="thinborder" width="18%"><%=WI.fillTextValue("section_name")%></td>
      <td  class="thinborder" width="23%"><%=strTemp%></td>
      <td width="49%"  class="thinborder"><%=(WI.getStrValue(strErrMsg)).toUpperCase()%></td>
      <td  class="thinborder" width="10%"><%=GS.getLoadingForSubject(dbOP, request.getParameter("subject"))%></td>
    </tr>
    <tr>
      <td  class="thinborder">Course/Year/Section</td>
      <td  class="thinborder">Day-Time</td>
      <td  class="thinborder">Subject/Descriptive Title </td>
      <td  class="thinborder"># of units </td>
    </tr>
  </table>
  <table width="100%" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <!--<tr>
      <td colspan="2"  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2"  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
    </tr>-->
    <tr> 
      <td colspan="2"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>NAME 
          OF STUDENT</strong></font></div></td>
<% if (strSchCode.startsWith("AUF"))
		strTemp = " COURSE YEAR / SECTION";
	else if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("DBTC"))
		strTemp = " COURSE-YR";
	else
		strTemp = " COURSE";
%>
      <% Vector vPMTSchedule = (Vector)vRetResult.elementAt(0); 
	  	 iNumGrading = vPMTSchedule.size()/2;
		int iIndexOf = 0;
		//if(strSchCode.startsWith("UDMC"))
		//	iNumGrading = 1;//show only final grade.
		for (i = 0; i < iNumGrading; ++i){
			//if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") && !strSchCode.startsWith("PHILCST") ) 
			//	strTemp = Integer.toString(i+1);
			//else
				strTemp = (String)vPMTSchedule.elementAt((i*2)+1);
			
			
			if (strTemp.toUpperCase().startsWith("PRE-")){
				iMidTermIndex = i;
				continue;
			}
			++dDynamicWidth;
		
		//if (strSchCode.startsWith("AUF")) {
			iIndexOf = strTemp.indexOf(" "); // remove 
			if (iIndexOf != -1) 
				if (i == 0) 
					strTemp = strTemp.substring(0,iIndexOf) +  " Grade";
				else
					strTemp = strTemp.substring(0,iIndexOf);
		//}
		%>
      <td  class="thinborder"><div align="center"><font color="#000099" size="1"><%=strTemp%></font></div></td>
      <%} // end for loop%>
      <td  class="thinborder"><div align="center"><font color="#000099" size="1">GPA</font></div></td>
      <td width="10%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>REMARKS</strong></font></div></td>
    </tr>
    <%	
		++dDynamicWidth;
		dDynamicWidth = (100 - 33 - 10)/dDynamicWidth;
		
		String strFontColor = null;//red if failed.
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
		strFontColor = " color=red";
	else	
		strFontColor = "";

	%>
    <tr> 
      <td width="3%" height="18"  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=iIncr%>.</font></td>
      <td width="30%"  class="thinborder"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <% 
		strTemp ="";
%>

      <% for (k = 0; k < iNumGrading; ++k) {
	  		if (k == iMidTermIndex) 
				continue;

			strTemp = (String)vPMTSchedule.elementAt((k*2)+1);
			strAvgGrade    = null;

			strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);

			if(strTemp.startsWith("F")) {
				strAvgGrade = strGrade;
				iIndexOf = vAddlGrade.indexOf(new Integer(WI.getStrValue((String)vRetResult.elementAt(i), "0")));
				if(iIndexOf > -1) {
					strGrade = (String)vAddlGrade.elementAt(iIndexOf + 1);
					vAddlGrade.remove(iIndexOf);vAddlGrade.remove(iIndexOf);
				}
				else {
					strGrade = null;
				}
				
			}
				
			strGrade = WI.getStrValue(strGrade,"&nbsp;");
			strAvgGrade = WI.getStrValue(strAvgGrade, "&nbsp;");
			
	  %>
      <td align="center"  class="thinborderGrade"<%=strFontColor%> width="<%=dDynamicWidth%>%"><font size="1"<%=strFontColor%>><strong><%=strGrade%></strong></font></td>
      <%} //end for loop k = 0; k < iNumGrading; ++k%>
      <td align="center"  class="thinborderGrade"<%=strFontColor%> width="<%=dDynamicWidth%>%"><font size="1"<%=strFontColor%>><strong><%=strAvgGrade%></strong></font></td>
      <td align="center"  class="thinborder"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+7)%></font></td>
    </tr>
    <%} //end for loop i = iNumStud, iCount = 1; i<vRetResult.size(); i+=9+(iNumGrading-1), iCount++ 
		strTemp = Integer.toString(3+iNumGrading);
	
	if ( iNumStud > vRetResult.size()-1 || iIncr == 1) {%>
	<tr> 
	<td colspan="<%=iNumGrading + 4%>"  class="thinborder"><div align="center">***************** 
          NOTHING FOLLOWS *******************</div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
	<tr> 
	<td colspan="<%=iNumGrading + 4%>"  class="thinborder"><div align="center">************** 
          CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}%>
  </table>
  
 
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
		  <td align="center" style="font-weight:bold; font-size:14px;">FURTHER ENTRY IS INVALID</td>
	    </tr>
		<tr> 
		  <td align="center">I certify on my honor that the entries reflected herein are true and correct.</td>
	    </tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td>&nbsp;</td>
      <td valign="bottom"></td>
      <td valign="bottom"></td>
      <td valign="bottom"></td>
    </tr>
    <tr> 
      <td valign="bottom">Submitted by: </td>
      <td class="thinborderBottom" valign="bottom" align="center">
		<%
		if(!strSchCode.startsWith("UI")){%>
        	<%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4).toUpperCase()%> 
        <%}else if(vSecDetail != null){%>
            <%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%> 
        <%}%>	  </td>
      <td valign="top" align="center">&nbsp;</td>
      <td valign="top" align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td align="center" valign="top">Instructor Name and Signature </td>
      <td>&nbsp;</td>
      <td valign="top">Date: __________________ </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
    <tr> 
      <td width="22%">&nbsp;</td>
      <td width="43%" valign="top">&nbsp;</td>
      <td width="10%" valign="top">&nbsp;</td>
      <td width="25%" valign="top">&nbsp;</td>
    </tr>
    <tr> 
      <td>Received by: </td>
      <td class="thinborderBottom" valign="bottom" align="center">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td align="center" valign="top">Dean's Secretary</td>
      <td>&nbsp;</td>
      <td valign="top">Date: __________________</td>
    </tr>
    
    <tr>
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
		
		<tr>
		  <td>Checked and Verified by:</td>
      	  <td class="thinborderBottom" valign="bottom" align="center">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		</tr>
		
		<tr>
		  <td align="center">&nbsp;</td>
		  <td align="center"> Dean of Maritime Studies/Business Education/IT Program Head/BSBA Program Head</td>
		  <td align="center">&nbsp;</td>
          <td valign="top">Date: __________________</td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		</tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>Approved by:</td>
      <td class="thinborderBottom" valign="bottom" align="center"><font style="font-weight:bold">MICHELLE M. SAPLADA,Ph.D.</font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    
    <tr>
      <td align="">&nbsp;</td>
      <td align="center" valign="top">Dean of Academics</td>
      <td align="center">&nbsp;</td>
      <td valign="top">Date: __________________</td>
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