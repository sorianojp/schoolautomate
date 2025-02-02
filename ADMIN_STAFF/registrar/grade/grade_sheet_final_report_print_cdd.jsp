<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
if(strSchCode.startsWith("UL")){%>
	<jsp:forward page="./grade_sheet_final_report_print_ul.jsp" />
<%}
if(strSchCode.startsWith("CSA")){%>
	<jsp:forward page="./grade_sheet_final_report_print_csa.jsp" />
<%}
if(strSchCode.startsWith("CIT")){%>
	<jsp:forward page="./grade_sheet_final_report_print_cit.jsp" />
<%}%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">

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
    border-right: dashed 1px #000000;
    border-bottom: dashed 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborderGradeRemark {
   /* border-right: dashed 1px #000000;*/
    border-bottom: dashed 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	
    TD.thinborderLegend {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }


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


<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0" onLoad="window.print();">
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
String[] astrConvSemester = {"SUMMER", "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER"};


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
		strDeptName = WI.getStrValue((String)vEmpRec.elementAt(14),"&nbsp");
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

for (;iNumStud < vRetResult.size()-1;){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(strSchCode.startsWith("LNU")){%>
    <tr> 
      <td colspan="3">L-NU REG # 12</td>
    </tr>
<%} else if(strSchCode.startsWith("UI")){%>
    <tr> 
      <td class="thinborderLegend">UI-REG-016</td>
      <td colspan="2" align="right" class="thinborderLegend"> REVISION N0. 01 23 MAY 2005&nbsp;&nbsp;</td>
    </tr>
<%}if(!strSchCode.startsWith("FATIMA") && !strSchCode.startsWith("CDD")){
%>
    <tr> 
      <td colspan="3"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></div></td>
    </tr>
    <tr> 
      <td colspan="3"><div align="center"><strong><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></strong></div></td>
    </tr>
    <!--  college and department group -->
<%if(strCollegeName != null){%>
    <tr> 
      <td colspan="3"><div align="center"><%=strCollegeName%></div></td>
    </tr>
<%}if(!strSchCode.startsWith("AUF")) {%>
    <tr> 
      <td colspan="3"><div align="center"><%=strDeptName%></div></td>
    </tr>
<%}%>

    <tr> 
		<% 
 		if (!strSchCode.startsWith("AUF")) 
  			strTemp = "REPORT ON FINAL GRADES";
  		else
			strTemp = "REPORT OF GRADES"; 
		%> 
      <td colspan="3"><div align="center"><strong><%=strTemp%></strong></div></td>
    </tr>

    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
    <% if (!strSchCode.startsWith("AUF")) {%>
    <tr> 
      <td width="50%">&nbsp;&nbsp;SEMESTER : <strong><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></strong></td>
      <td width="25%">
	  <%if(strSchCode.startsWith("UDMC")){%>
	  No Of Units : <u><strong><%=GS.getLoadingForSubject(dbOP, request.getParameter("subject"))%></strong></u>
	  <%}%>
	  </td>
      <td width="25%"><%if(!strSchCode.startsWith("UDMC")){%><div align="center"><u>________________________</u></div><%}%></td>
    </tr>
    <tr> 
      <td>&nbsp;&nbsp;ACADEMIC YEAR: <strong><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></td>
      <td>&nbsp;</td>
      <td><div align="center"><font size="1"><%if(!strSchCode.startsWith("UDMC")){%>DATE SUBMITTED<%}%></font></div></td>
    </tr>
    <%} //!strSchCode.startsWith("AUF") %>
	<%}//end if(!strSchCode.startsWith("UPHS"))%>
  </table>
 
<%if(vSecDetail != null){

	if (bolSeparateMixedSection) 
		strCurrentSubIndex = (String)vRetResult.elementAt(iNumStud + 8);
	else
		strCurrentSubIndex = WI.fillTextValue("subject");

if(!strSchCode.startsWith("FATIMA") && !strSchCode.startsWith("CDD")){
%>

<%if(!strSchCode.startsWith("FATIMA") && !strSchCode.startsWith("CDD")){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2"><div align="center"> <strong> </strong></div></td>
    </tr>
    <tr> 
      <td width="94%"><br>
        &nbsp;&nbsp;SUBJECT: <strong> 
<% 
	if(strCurrentSubIndex != null && strCurrentSubIndex.length() > 0 ) {
		strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_code +' (' + sub_name+')'"," and is_del=0");
%>
        <%=(WI.getStrValue(strTemp)).toUpperCase()%> 
        <%}%>
        </strong> </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;&nbsp;CLASS SECTION/SCHEDULE: <strong><%=WI.fillTextValue("section_name")%>/ 
        <%
		for( i = 1; i<vSecDetail.size(); i+=3){
	  	if(i >1){%>
        , 
        <%}%>
        <%=(String)vSecDetail.elementAt(i+2)%> 
        <%}%>
        </strong></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}%>
<% if(!strSchCode.startsWith("UI")){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="60%" valign="bottom"><div align="center"> <strong> 
          <%if(vSecDetail != null){%>
          <%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%> 
          <%}%>
          </strong></div></td>
      <td width="40%">&nbsp;</td>
    </tr>
    <tr> 
      <td><div align="center">NAME OF INSTRUCTOR(S)</div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <% }//do not show the top if UI 
 } // if !strSchCode.startsWith("AUF")
  if(!strSchCode.startsWith("FATIMA") && !strSchCode.startsWith("CDD")){%>
  <table border=0 cellpadding="0" cellspacing="0" width="100%">
    <tr> 
<% if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_code"," and is_del<>1");
}
 %>
      <td width="12%" height="25" valign="bottom">Subject Code :</td>
      <td width="16%" valign="bottom" class="thinborderBottom"> <strong>&nbsp;<%=strTemp%></strong></td>
      <%
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_name"," and is_del<>1");
}
 %>
      <td width="13%" valign="bottom"> <div align="right">Subject Title : <u></u></div></td>
      <td width="41%" valign="bottom" class="thinborderBottom"><strong>&nbsp;<%=strTemp%></strong></td>
      <td width="18%" valign="bottom"> &nbsp;&nbsp;Units: <u><strong><%=GS.getLoadingForSubject(dbOP, request.getParameter("subject"))%></strong></u></td>
    </tr>
  </table>
  <table border=0 cellpadding="0" cellspacing="0"  width="98%">
    <tr> 
      <td width="14%" height="25" valign="bottom"> &nbsp;Academic Year : </td>
      <td width="12%" valign="bottom" class="thinborderBottom"><strong>&nbsp;<%=WI.fillTextValue("sy_from")%>- <%=WI.fillTextValue("sy_to")%></strong></td>
      <td width="10%" valign="bottom"> <div align="right">Semester :<strong></strong></div></td>
      <td width="9%" valign="bottom" class="thinborderBottom"><strong>&nbsp;
	  					<%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>
		</strong></td>
      <%
		for( i = 1; i<vSecDetail.size(); i+=3){
	  if(i >1){
        strTemp += "<br>";
       }
	    strTemp = WI.getStrValue((String)vSecDetail.elementAt(i+2)) + 
					WI.getStrValue((String)vSecDetail.elementAt(i),"/","","");
       }
  %>
      <td width="16%" align="right" valign="bottom"> Day/Time/Room :</td>
      <td width="39%" valign="bottom" class="thinborderBottom"> <strong>&nbsp;<%=strTemp%></strong></td>
    </tr>
  </table>
  

  <table border=0 cellpadding="0" cellspacing="0" width="100%">
    <tr valign="bottom"> 
      <td height="25" colspan="2"> Instructor : 
        <%if(vSecDetail != null){%>
        __<u><strong><%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%></strong></u>__
<%}%> </td>
    </tr>
    <tr> 
      <td width="50%">&nbsp;</td>
      <td width="50%">&nbsp;</td>
    </tr>
  </table>
 <% }  // if else !strSchCode.startsWith("AUF")
	if (vRetResult != null && vRetResult.size() > 0){ 
	i = 0;
%>
  <table width="100%" cellpadding="0" height="1010" cellspacing="0" bgcolor="#FFFFFF" class="" border="0">
  	<!-------
    <tr> 
      <td width="3%" class="thinborder"><font color="#000099" size="1"><strong>Count</strong></font></td>
      <td width="14%" class="thinborder"><font color="#000099" size="1"><strong>ID. Number</strong></font></td>
      <td width="33%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>NAME OF STUDENT</strong></font></div></td>
<% if (strSchCode.startsWith("AUF"))
		strTemp = " COURSE YEAR / SECTION";
	else if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("DBTC"))
		strTemp = " COURSE-YR";
	else
		strTemp = " COURSE/YR.";
%>
      <td width="20%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong><%=strTemp%></strong></font></div></td>
      <% Vector vPMTSchedule = (Vector)vRetResult.elementAt(0); 
	  	 iNumGrading = vPMTSchedule.size()/2;
		int iIndexOf = 0;
		//if(strSchCode.startsWith("UDMC"))
		//	iNumGrading = 1;//show only final grade.
		for (i = 0; i < iNumGrading; ++i){
			if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") && !strSchCode.startsWith("PHILCST") )
				strTemp = Integer.toString(i+1);				
			else
				strTemp = (String)vPMTSchedule.elementAt((i*2)+1);	
				
			/**if(strTemp.equals("1"))		
				strTemp = "PRELIMS";
			else if(strTemp.equals("2"))		
				strTemp = "MIDTERMS";
			else
				strTemp = "FINALS";*/
				
			if (strTemp.toUpperCase().startsWith("MID") && strSchCode.startsWith("AUF")){
				iMidTermIndex = i;
				continue;
			}
			else if (!strTemp.toUpperCase().startsWith("FIN") && strSchCode.startsWith("UDMC"))
				continue;
			
		
		if (strSchCode.startsWith("AUF")) {
			iIndexOf = strTemp.indexOf(" "); // remove 
			if (iIndexOf != -1) 
				if (i == 0) 
					strTemp = strTemp.substring(0,iIndexOf) +  " Grade";
				else
					strTemp = strTemp.substring(0,iIndexOf);
				
				if (strTemp.toLowerCase().startsWith("final")) 
					strTemp = "Final Grade";
			

		}
		%>
      <td  class="thinborder"><div align="center"><font color="#000099" size="1"><%=strTemp%></font></div></td>
      <%} // end for loop%>
      <% if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") ){%>
      <td width="10%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>REMARKS</strong></font></div></td>
      <%}%>
    </tr>
	------>
	
	
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
		strFontColor = " color=red";
	else	
		strFontColor = "";

	%>
    <tr> 
      <td width="3%" height="18"  class=""<%=strFontColor%>><font size="1">&nbsp;<%=iIncr%>.</font></td>
      <td width="10%" class=""><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td width="33%" class=""><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
<% 
	if (strSchCode.startsWith("AUF"))
		strTemp = " " + WI.getStrValue((String)vRetResult.elementAt(i+5)) + " / "  +
					WI.fillTextValue("section_name");
	else if (strSchCode.startsWith("UDMC") || strSchCode.startsWith("DBTC"))
		strTemp = " - " + WI.getStrValue((String)vRetResult.elementAt(i+5));
	else
		strTemp ="";
%>
		
			  	
      <td width="20%" class="" align="center"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+3)+WI.getStrValue((String)vRetResult.elementAt(i+5),"/","","") +  strTemp%></font></td>
      <% for (k = 0; k < iNumGrading; ++k) {
	  		if (k == iMidTermIndex && strSchCode.startsWith("AUF")) 
				continue;
			else if (k < (iNumGrading - 1) && strSchCode.startsWith("UDMC"))
				continue;
			strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);
			if(strGrade != null && strGrade.indexOf(".") != -1 && strGrade.length() == 3)
				strGrade += "0";
	  %>
      <td align="center"  class="thinborderGrade"<%=strFontColor%> width="90"><font size="1"<%=strFontColor%>><strong>
	  	<%=strGrade%></strong></font></td>
      <%} //end for loop k = 0; k < iNumGrading; ++k
	  
	   if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") )  {
	  %>
      <td width="10%" align="center"  class="thinborderGradeRemark"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+7)%></font></td>
      <%} // if AUF  do not show remarks column%>
    </tr>
    <%} //end for loop i = iNumStud, iCount = 1; i<vRetResult.size(); i+=9+(iNumGrading-1), iCount++ 
	if (strSchCode.startsWith("AUF"))
		strTemp = Integer.toString(4+iNumGrading - 1) ;  // colspan -1 for the remarks, -1 midterm
	else if(strSchCode.startsWith("UDMC"))
		strTemp = "5";
	else
		strTemp = Integer.toString(5+iNumGrading);
	
	if ( iNumStud > vRetResult.size()-1 || iIncr == 1) {%>
    <tr> 
      <td valign="top" colspan="<%=strTemp%>"  class=""><div align="center">***************** NOTHING FOLLOWS *******************</div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td valign="top" colspan="<%=strTemp%>"  class=""><div align="center">************** CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}//end else
  if(strSchCode.startsWith("CLDH")){%>
    <tr> 
      <td colspan="<%=strTemp%>"  class="thinborder">NOTE : THIS REPORT MUST BE SUBMITTED TO THE REGISTRAR'S OFFICE 5 DAYS AFTER THE EXAMINATION</td>
    </tr>
    <%}%>
  </table>
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>
	  <% if(WI.fillTextValue("subject").length() > 0) {
			strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_code"," and is_del<>1");
		}%>		
		<td width="14%" height="30" valign="middle">
		<div><strong>CODE</strong></div>
		<div><%=(WI.getStrValue(strTemp)).toUpperCase()%></div>
        </td>
		<%
		if(WI.fillTextValue("subject").length() > 0) {
			strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_name"," and is_del<>1");
		}%>
		<td width="48%" valign="middle">
        <div><strong>SUBJECT DESCRIPTION</strong></div>
		<div><%=strTemp.toUpperCase()%></div>
        </td>
  <%
		for( i = 1; i<vSecDetail.size(); i+=3){
	  		if(i >1){
        		strTemp += "<br>";
      		 }
	    strTemp = WI.getStrValue((String)vSecDetail.elementAt(i+2)) + WI.getStrValue((String)vSecDetail.elementAt(i),"/","","");
       	}
  		%>
		<td width="38%" valign="middle">
		<div><strong>DAYS/TIME/ROOM</strong></div>
        <div><%=strTemp%></div>
        </td>
	</tr>
	
	
	<tr>
		<td height="30" colspan="2" valign="bottom">
			<div><strong>SEMESTER/SCHOOL YEAR</strong></div>
			<div><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> &nbsp; <%=WI.fillTextValue("sy_from")%>- <%=WI.fillTextValue("sy_to")%></div>
            </td>
		
		<td valign="bottom">
			<div><strong>INSTRUCTOR</strong></div>
            <div>
			<%if(vSecDetail != null){%>
          	<%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%> 
          	<%}%>
            </div>
		</td>
	</tr>
	
	
  </table>
  
  
  <%if(strSchCode.startsWith("UDMC")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="2">Certified Correct: </td>
      <td width="29%" rowspan="7" valign="top">
	  <strong><u>Grading Sheet :</u></strong> <br>
	  <table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
          <td width="6%">1.00 </td>
          <td width="11%">99 - 100 </td>
          <td>2.25</td>
          <td>84 - 86 </td>
          </tr>
        <tr>
          <td>1.25</td>
          <td>96 - 98 </td>
          <td>2.50</td>
          <td>81 - 83 </td>
          </tr>
        <tr>
          <td>1.50</td>
          <td>93 - 95</td>
          <td width="6%">2.75</td>
          <td width="11%">78 - 81 </td>
          </tr>
        <tr>
          <td>1.75</td>
          <td>90 - 92 </td>
          <td>3.00 </td>
          <td>75 - 77 </td>
          </tr>
        <tr>
          <td height="17">2.00 </td>
          <td>87 - 89 </td>
          <td>5.00</td>
          <td>70</td>
          </tr>
      </table></td>
    </tr>
    <tr> 
      <td height="17" colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="23" colspan="2" valign="bottom"><div align="center"> 
          <table width="90%" border="0" cellspacing="0" cellpadding="0">
            <tr> 
              <td class="thinborderBottom"><div align="center"><%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4).toUpperCase()%></div></td>
            </tr>
          </table>
        </div></td>
    </tr>
    <tr> 
      <td colspan="2"><div align="center">Signature over Printed Name of Instructor 
          / Professor</div></td>
    </tr>
    <tr> 
      <td colspan="2" valign="bottom"> <table width="98%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="15%" height="39" valign="bottom">Noted: </td>
            <td width="85%" valign="bottom" class="thinborderBottom"><div align="center"> 
                <label id="L_1" onClick="ChangeInfo('L_1')">
					<%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strOfferedByCollege,"DEAN_NAME"," and is_del = 0")).toUpperCase()%>
				</label></div></td>
          </tr>
          <tr> 
            <td height="18" valign="bottom">&nbsp;</td>
            <td valign="top"><div align="center"><font size="1">DEAN / HEAD</font></div></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="30" colspan="2" valign="bottom">Received: _____________________ 
        Date : ___________</td>
    </tr>
  </table>
  
  <%}else if (!strSchCode.startsWith("FATIMA") && !strSchCode.startsWith("CDD")) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="50%">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td>SUBMITTED BY:</td>
      <td width="24%" rowspan="5" valign="top"> <% if (vPMTSchedule!= null && vPMTSchedule.size()>0 && !strSchCode.startsWith("PHILCST")){ %> 
	  		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
          <% for (i = 0,iCount = 1; i < vPMTSchedule.size() ; i+=2, iCount++) {%>
          <tr> 
            <td width="19%" class="thinborder"><%=iCount%></td>
            <td width="81%" class="thinborder"><%=(String)vPMTSchedule.elementAt(i+1)%>
			<%if(strSchCode.startsWith("PIT") && iCount == 3){%>
				/Avg Grade
			<%}%>
			</td>
          </tr>
          <%}%>
        </table>
        <%}%> </td>
      <td width="1%" rowspan="5" valign="top">&nbsp; </td>
      <td width="24%" rowspan="5" valign="top"> 
<%if (strSchCode.startsWith("DBTC")) {%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			  <tr> 
				<td width="23%" class="thinborder">DR</td>
				<td width="77%" class="thinborder"> Dropped</td>
			  </tr>
			  <tr> 
				<td class="thinborder">NA</td>
				<td class="thinborder">No Attendance</td>
			  </tr>
			  <tr> 
				<td class="thinborder">W</td>
				<td class="thinborder">Withdrawn</td>
			  </tr>
			</table>
<%}else if(!strSchCode.startsWith("PIT")){%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			  <tr> 
				<td width="50%" class="thinborder">No Final Exam</td>
				<td width="50%" class="thinborder"> (NFE)</td>
			  </tr>
			  <tr> 
				<td class="thinborder">Incomplete</td>
				<td class="thinborder">(INC)</td>
			  </tr>
			  <tr> 
				<td class="thinborder">Dropped</td>
				<td class="thinborder">(DRP)</td>
			  </tr>
			</table>
<%}%>
		</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="50%" valign="bottom"><div align="center"> <strong> </strong>
          <table width="90%" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td height="19" class="thinborderBottom"><div align="center"><strong> 
                  <%
if(!strSchCode.startsWith("UI")){%>
                  <%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4).toUpperCase()%> 
                  <%}else if(vSecDetail != null){%>
                  <%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%> 
                  <%}%>
                  </strong></div></td>
            </tr>
          </table>
        </div></td>
    </tr>
    <tr> 
      <td><div align="center"><font size="1">INSTRUCTOR'S NAME AND SIGNATURE</font></div></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4">
<%if(strSchCode.startsWith("PHILCST")){%>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="32%">NOTED BY: </td>
            <td width="36%">RECEIVED BY: </td>
            <td width="32%">APPROVED BY: </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr valign="bottom" align="center"> 
            <td height="20"><%
			strTemp = dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"OFFERED_BY_COLLEGE",null);
			if(strTemp == null) 
				strTemp = (String)vEmpRec.elementAt(11);
			%>
___<u><%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strTemp,"DEAN_NAME"," and is_del = 0")).toUpperCase()%></u>___</td>
            <td height="20">___<u>ENGR. RAUL B. GIRONELLA SR.</u>___</td>
            <td height="20">
			<u><%=CommonUtil.getNameForAMemberType(dbOP, "university registrar",1).toUpperCase()%></u></td>
          </tr>
          <tr align="center"> 
            <td height="18">DEAN</td>
            <td>VP  ACADEMIC AFFAIRS</td>
            <td>REGISTRAR</td>
          </tr>
        </table>	
<%}else if(strSchCode.startsWith("DBTC")){%>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="56%" style="font-size:10px;">NOTED BY: </td>
            <td width="12%">&nbsp;</td>
            <td width="32%" style="font-size:10px;">RECEIVED BY: </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr valign="bottom" align="center"> 
            <td height="20" style="font-size:10px;"><%
			strTemp = dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"OFFERED_BY_COLLEGE",null);
			if(strTemp == null) 
				strTemp = (String)vEmpRec.elementAt(11);
			%>
___<u><%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strTemp,"DEAN_NAME"," and is_del = 0")).toUpperCase()%></u>___</td>
            <td height="20">&nbsp;</td>
            <td height="20" style="font-size:10px;">
			<u><%=CommonUtil.getNameForAMemberType(dbOP, "university registrar",1).toUpperCase()%></u></td>
          </tr>
          <tr align="center"> 
            <td height="18" style="font-size:10px;">DEAN</td>
            <td>&nbsp;</td>
            <td style="font-size:10px;">REGISTRAR</td>
          </tr>
        </table>	
<%}else{%>	
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="32%">APPROVED BY:</td>
            <td width="36%">&nbsp;</td>
            <td width="32%">RECEIVED BY:</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr valign="bottom"> 
            <td height="20"><div align="center">&nbsp;
                <% boolean bolShowDept = false;
			strTemp = dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"OFFERED_BY_DEPT",null);
			if(strTemp != null) {
				  bolShowDept = true;
			%>
            <u>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(dbOP.mapOneToOther("DEPARTMENT","D_INDEX",strTemp,"DH_NAME"," and is_del = 0"),"NOT ASSIGNED").toUpperCase()%>&nbsp;&nbsp;&nbsp;</u><%}%></div></td>
            <td height="20"><div align="center">
			<%
			strTemp = dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"OFFERED_BY_COLLEGE",null);
			if(strTemp == null) 
				strTemp = (String)vEmpRec.elementAt(11);
			%>
			___<u><%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strTemp,"DEAN_NAME"," and is_del = 0")).toUpperCase()%></u>___</div></td>
            <td height="20"><div align="center">
			<u><%=CommonUtil.getNameForAMemberType(dbOP, "university registrar",1)%></u></div></td>
          </tr>
          <tr> 
            <td height="18"><div align="center"><%if(bolShowDept){%>DEPARTMENT HEAD<%}%></div></td>
            <td><div align="center">DEAN</div></td>
            <td><div align="center">UNIVERSITY REGISTRAR</div></td>
          </tr>
<% if(strSchCode.startsWith("LNU")) {%>	
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="3">

			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderall">

                <tr> 
                  <td width="18%"><div align="center">Issue Status</div></td>
                  <td width="19%"><div align="center">Revision</div></td>
                  <td width="21%"> <div align="center">Date </div></td>
                  <td width="42%"><div align="center">Approved by: (SGD.) DR. 
                      GONZALO T. DUQUE</div></td>
                </tr>
                <tr> 
                  <td><div align="center">3</div></td>
                  <td><div align="center">3</div></td>
                  <td><div align="center">DEC. 12, 2004</div></td>
                  <td><div align="center">President</div></td>
                </tr>
              </table>
		    </td>
<%}%>				
          </tr>
        </table>
<%}%>
	  </td>
    </tr>
  </table>

 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="2">Certified Correct: </td>
      <td width="51%" rowspan="7"><table width="98%" border="0" align="right" cellpadding="0" cellspacing="0">
          <tr> 
            <td colspan="4">GRADING SYSTEM:</td>
          </tr>
          <tr> 
            <td width="22%" class="thinborderLegend">1.00-97-100</td>
            <td width="27%" class="thinborderLegend">EXCELLENT</td>
            <td width="32%" class="thinborderLegend">2.75 -77-78</td>
            <td width="19%" class="thinborderLegend">FAIR</td>
          </tr>
          <tr> 
            <td class="thinborderLegend">1.25-94-96</td>
            <td class="thinborderLegend">VERY GOOD</td>
            <td class="thinborderLegend">3.00 -75-76</td>
            <td class="thinborderLegend">PASSED</td>
          </tr>
          <tr> 
            <td class="thinborderLegend">1.50-91-93</td>
            <td class="thinborderLegend">VERY GOOD</td>
            <td class="thinborderLegend">5.00 - BELOW 75</td>
            <td class="thinborderLegend">FAILURE</td>
          </tr>
          <tr> 
            <td class="thinborderLegend">1.75-88-90</td>
            <td class="thinborderLegend">GOOD</td>
            <td colspan="2" class="thinborderLegend">INC &nbsp;-&nbsp; INCOMPLETE</td>
          </tr>
          <tr> 
            <td class="thinborderLegend">2.00-85-87</td>
            <td class="thinborderLegend">GOOD</td>
            <td colspan="2" class="thinborderLegend">DR &nbsp; -&nbsp;&nbsp;DROPPED</td>
          </tr>
          <tr> 
            <td class="thinborderLegend">2.25-82-84</td>
            <td class="thinborderLegend">GOOD</td>
            <td colspan="2" class="thinborderLegend">FA&nbsp;&nbsp; &nbsp;-&nbsp;&nbsp;Failure 
              due to Absences</td>
          </tr>
          <tr> 
            <td class="thinborderLegend">2.50-79-81</td>
            <td class="thinborderLegend">FAIR</td>
            <td colspan="2" class="thinborderLegend">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="4"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr> 
                  <td width="42%" class="thinborderLegend">FOR GRADUATE SCHOOL 
                    : </td>
                  <td width="58%"  class="thinborderLegend">Below 90 no credit 
                    for Ph.D.</td>
                </tr>
                <tr> 
                  <td>&nbsp;</td>
                  <td class="thinborderLegend">Below 85 no credit for M.A.</td>
                </tr>
                <tr> 
                  <td>&nbsp;</td>
                  <td>&nbsp;</td>
                </tr>
                <tr> 
                  <td colspan="2" class="thinborderLegend">ONE UNIT OF CREDIT 
                    is one hour lecture or recitation, or three <br>
                    hours of laboratory, drafting or shop work each week for the 
                    period </td>
                </tr>
              </table></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="17" colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="23" colspan="2" valign="bottom"><div align="center"> 
          <table width="90%" border="0" cellspacing="0" cellpadding="0">
            <tr> 
              <td class="thinborderBottom"><div align="center"><%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4).toUpperCase()%></div></td>
            </tr>
          </table>
        </div></td>
    </tr>
    <tr> 
      <td colspan="2"><div align="center">Signature over Printed Name of Instructor 
          / Professor</div></td>
    </tr>
    <tr> 
      <td colspan="2" valign="bottom"> <table width="98%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="15%" height="39" valign="bottom">Noted: </td>
            <td width="85%" valign="bottom" class="thinborderBottom"><div align="center"><label id="L_1" onClick="ChangeInfo('L_1')"> 
                <%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strOfferedByCollege,"DEAN_NAME"," and is_del = 0")).toUpperCase()%>
				</label></div></td>
          </tr>
          <tr> 
            <td height="18" valign="bottom">&nbsp;</td>
            <td valign="top"><div align="center"><font size="1">DEAN / HEAD</font></div></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="50" colspan="2" valign="bottom">Received: _____________________ 
        Date : ___________</td>
    </tr>
    <tr> 
      <td height="35" colspan="2" valign="bottom" style="font-family:century Gothic; font-size:9px;">
	  AUF-Form-RO-06<br>
	  August 1, 2007 - Rev. 0</td>
    </tr>
  </table>

  <%}  // end if strSchCode.startsWith("AUF") 
  } //end vRetResult size  == 0
} // vSecDetail != null
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END.
if (bolPageBreak){%>
  <DIV style="page-break-before:always" ></DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumStud < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
    <input type="hidden" name="page_action">
    <input type="hidden" name="print_page">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>