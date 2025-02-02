<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strInfo5 = (String)request.getSession(false).getAttribute("info5");
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
}//System.out.println(vRetResult);

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


boolean bolIsCollege = false;
if(strSchCode.startsWith("EAC"))
	bolIsCollege = true;

String strGradeRemark = null;

boolean bolIsMasteral = false;
if(WI.fillTextValue("subject").length() > 0) {
	String strSQLQuery = "select * from cculum_masters where sub_index = "+WI.fillTextValue("subject");
	if(dbOP.getResultOfAQuery(strSQLQuery, 0) != null)
		bolIsMasteral = true;
}


for (;iNumStud < vRetResult.size()-1;){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
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
<%} if (!strSchCode.startsWith("AUF")) {%>
    <tr> 
      <td colspan="3"><div align="center"><%=strDeptName%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="3"> <% 
 	if (!strSchCode.startsWith("AUF")) 
  		strTemp = "REPORT ON FINAL GRADES";
  	else
		strTemp = "REPORT OF GRADES"; 
%> <div align="center"><strong><%=strTemp%></strong></div></td>
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
  </table>
<%if(vSecDetail != null){

	if (bolSeparateMixedSection) 
		strCurrentSubIndex = (String)vRetResult.elementAt(iNumStud + 8);
	else
		strCurrentSubIndex = WI.fillTextValue("subject");

	if (!strSchCode.startsWith("AUF")) {
%>
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
  else{ %>
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
 <table width="100%" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr>
     <td width="3%" class="thinborder"><font color="#000099" size="1"><strong>Count</strong></font></td>
     <td width="14%" class="thinborder"><font color="#000099" size="1"><strong>ID. 
       Number</strong></font></td>
     <td width="33%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>NAME 
       OF STUDENT</strong></font></div></td>
     <% if (strSchCode.startsWith("AUF"))
		strTemp = " COURSE YEAR / SECTION";
	else if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("DBTC"))
		strTemp = " COURSE-YR";
	else
		strTemp = " COURSE";
%>
     <td width="20%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong><%=strTemp%></strong></font></div></td>
     <% Vector vPMTSchedule = (Vector)vRetResult.elementAt(0); 
	  //vPMTSchedule.remove(0);vPMTSchedule.remove(0);
	  	 iNumGrading = vPMTSchedule.size()/2;
		int iIndexOf = 0;
		//if(strSchCode.startsWith("UDMC"))
		//	iNumGrading = 1;//show only final grade.
		for (i = 0; i < iNumGrading; ++i){
			//if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") && !strSchCode.startsWith("PHILCST") ) 
				//strTemp = Integer.toString(i+1);
			//else
				strTemp = (String)vPMTSchedule.elementAt((i*2)+1);
			
			if (strTemp.toUpperCase().startsWith("PRELIM")) {
				iMidTermIndex = i;
				continue;
			}
		
		%>
     <td  class="thinborder" style="color:#000099; font-size:9px;" width="10%"><div align="center"><%=strTemp%></div></td>
     <%} // end for loop%>
     <td width="10%"  class="thinborder" style="color:#000099; font-size:9px;" align="center">Final Grade </td>
     <% if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") ){%>
     <td width="10%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>REMARKS</strong></font></div></td>
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
		strFontColor = " color=red";
	else	
		strFontColor = "";

	%>
   <tr>
     <td height="18"  class="thinborder"<%=strFontColor%>><font size="1">&nbsp;<%=iIncr%></font></td>
     <td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
     <td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
     <% 
	if (strSchCode.startsWith("AUF"))
		strTemp = " " + WI.getStrValue((String)vRetResult.elementAt(i+5)) + " / "  +
					WI.fillTextValue("section_name");
	else if (strSchCode.startsWith("UDMC") || strSchCode.startsWith("DBTC"))
		strTemp = " - " + WI.getStrValue((String)vRetResult.elementAt(i+5));
	else
		strTemp ="";
%>
     <td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+3)+WI.getStrValue((String)vRetResult.elementAt(i+4),"/","","") +  strTemp%></font></td>
     <% 
	  strTemp = null;
	  for (k = 0; k < iNumGrading; ++k) {
	  		if (k == iMidTermIndex) 
				continue;
			
			strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);
			if(strGrade != null && strGrade.indexOf(".") != -1 && strGrade.length() == 3)
				strGrade += "0";
			strGradeRemark = (String)vRetResult.elementAt(i+7);
			if(strGrade == null) {
				strGrade = strGradeRemark;
				strTemp = strGrade;
			}
			else {
				iIndexOf = strGrade.indexOf("/");
				if(iIndexOf > -1) {
					strTemp = strGrade.substring(iIndexOf + 1);
					strGrade = strGrade.substring(0, iIndexOf);
					if(strGrade.indexOf(".") != -1 && strGrade.length() == 3)
						strGrade += "0";
				}
			}
	  %>
     <td align="center"  class="thinborderGrade"<%=strFontColor%>><font size="1"<%=strFontColor%>><strong> <%=strGrade%></strong></font></td>
     <%} //end for loop k = 0; k < iNumGrading; ++k%>
     <td align="center"  class="thinborder" style="font-weight:bold; font-size:9px;"<%=strFontColor%>><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
     <%
	   if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") )  {
	  %>
     <td align="center"  class="thinborder"><font size="1"<%=strFontColor%>><%=WI.getStrValue(strGradeRemark, "&nbsp;")%></font></td>
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
     <td colspan="<%=strTemp%>"  class="thinborder"><div align="center">***************** 
       NOTHING FOLLOWS *******************</div></td>
   </tr>
   <%}else{// end iNumStud >= vRetResult.size()%>
   <tr>
     <td colspan="<%=strTemp%>"  class="thinborder"><div align="center">************** 
       CONTINUED ON NEXT PAGE ****************</div></td>
   </tr>
   <%}//end else
  if(strSchCode.startsWith("CLDH")){%>
   <tr>
     <td colspan="<%=strTemp%>"  class="thinborder">NOTE : THIS REPORT MUST BE SUBMITTED TO THE REGISTRAR'S OFFICE 5 DAYS AFTER THE EXAMINATION</td>
   </tr>
   <%}%>
 </table>
 <%if (!strSchCode.startsWith("AUF")) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="50%">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td>SUBMITTED BY:</td>
      <td width="24%" rowspan="5" valign="top">&nbsp;</td>
      <td width="1%" rowspan="5" valign="top">&nbsp; </td>
      <td width="24%" rowspan="5" valign="top"> 
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
                <% boolean bolShowDept = false; strTemp = null;
			if(!strSchCode.startsWith("EAC"))
				strTemp = dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"OFFERED_BY_DEPT",null);
			if(strTemp != null ) {
				  bolShowDept = true;
			%>
                <u>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(dbOP.mapOneToOther("DEPARTMENT","D_INDEX",strTemp,"DH_NAME"," and is_del = 0"),"NOT ASSIGNED").toUpperCase()%>&nbsp;&nbsp;&nbsp;</u><%}%></div></td>
            <td height="20"><div align="center">
			<%
			strTemp = null;
			if(!strSchCode.startsWith("EAC"))
				strTemp = dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"OFFERED_BY_COLLEGE",null);
			if(strTemp == null) 
				strTemp = (String)vEmpRec.elementAt(11);
			%>
			
			<%if(strSchCode.startsWith("UPH")){%><br>
				<u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</u>
			<%}else{%>
				___<u><%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strTemp,"DEAN_NAME"," and is_del = 0")).toUpperCase()%></u>___
			<%}%>
			</div></td>
            <td height="20"><div align="center">
			<u><%=CommonUtil.getNameForAMemberType(dbOP, "university registrar",1)%></u></div></td>
          </tr>
          <tr> 
            <td height="18"><div align="center"><%if(bolShowDept){%>DEPARTMENT HEAD<%}%></div></td>
            <td><div align="center">DEAN</div></td>
            <td align="center">
			REGISTRAR
			
			</td>
          </tr>
        </table>
	  </td>
    </tr>
  </table>
  <%}  // end if strSchCode.startsWith("AUF") 
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