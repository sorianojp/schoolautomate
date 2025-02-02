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
enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();
enrollment.ReportFeeAssessment RFA     = new enrollment.ReportFeeAssessment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();
String[] astrConvSemester = {"SUMMER", "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER"};


String strSubSecIndex   = null;
String strOfferedByCollege = null;

Vector vRetResult = null;
Vector vEncodedGrade = new Vector();

String strSchCode = (String)request.getSession(false).getAttribute("school_code");//strSchCode = "AUF";
if(strSchCode == null)
	strSchCode = "";
	
String strAvgGrade    = null;
String strFinalPoint  = null;
	
	

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

Vector vAdmSlipNumber   = null;
String strAdmSlipNumber = null;

Vector vWUPGrade = new Vector();

if(strSubSecIndex != null) {
	vRetResult = gsExtn.getAllGradesEncoded(dbOP,request,strSubSecIndex,bolSeparateMixedSection);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else {
		
		String strSQLQuery = "select gs_index, grade2, grade_cgh from g_sheet_final where sub_sec_index = "+strSubSecIndex;
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vWUPGrade.addElement(new Integer(rs.getInt(1)));
			vWUPGrade.addElement(rs.getString(2));
			vWUPGrade.addElement(rs.getString(3));
		}
		rs.close();
		
		vAdmSlipNumber = RFA.getAdmSlipNoPerSection(dbOP, strSubSecIndex);
		if(vAdmSlipNumber == null)
			vAdmSlipNumber = new Vector();
		//System.out.println(vAdmSlipNumber);
	}

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

int iTotEnrolled = 0;
int iTotPassed   = 0;
int iTotInc      = 0;
int iTotDropped  = 0;
int iTotFailed   = 0;
int iTotOthers   = 0;

boolean bolIsMasteral = false;
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = "select * from cculum_masters where sub_index = "+WI.fillTextValue("subject");
	if(dbOP.getResultOfAQuery(strTemp, 0) != null)
		bolIsMasteral = true;
} 

for (;iNumStud < vRetResult.size()-1;){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
  	<td width="12%">&nbsp;</td>
	<td width="88%">
  		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr> 
			  <td colspan="2"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></div></td>
			</tr>
			<tr> 
			  <td colspan="3"><div align="center"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></div></td>
			</tr>
			<%if(strCollegeName != null) {%>
			<tr> 
			  <td colspan="3" style="font-weight:bold"><div align="center"><%=strCollegeName%></div></td>
			</tr>
			<%} if (strDeptName != null) {%>
			<!--<tr> 
			  <td colspan="3"><div align="center"><%=strDeptName%></div></td>
			</tr>-->
			<%}%>
		</table>
	</td>
  </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="12%"></td>
      <td align="center" style="font-weight:bold; font-size:15px;">GRADING SHEET
	  <%if(WI.fillTextValue("show_partial").length() > 0) {%> 
	  	(PARTIAL)
	  <%}%>
	  
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
    <% if (!strSchCode.startsWith("AUF")) {%>
    <tr> 
      <td width="50%">&nbsp;&nbsp;SEMESTER : <strong><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></strong></td>
      <td width="25%">
	  <%if(strSchCode.startsWith("UDMC")){%>
	  No Of Units : <u><strong><%=GS.getLoadingForSubject(dbOP, request.getParameter("subject"))%></strong></u>
	  <%}%>	  </td>
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
      <td width="60%" valign="bottom"><br><div align="center"> <strong> 
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

	if (vRetResult != null && vRetResult.size() > 0){ 
	i = 0;
%>
  <table width="100%" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="2%" class="thinborder"><font color="#000099" size="1"><strong>Count</strong></font></td>
      <td width="10%" class="thinborder"><font color="#000099" size="1"><strong>ID. Number</strong></font></td>
      <td width="18%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>NAME OF STUDENT</strong></font></div></td>
      <td width="8%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>COURSE-YR</strong></font></div></td>
      <% Vector vPMTSchedule = (Vector)vRetResult.elementAt(0); 
	  	 iNumGrading = vPMTSchedule.size()/2;
		int iIndexOf = 0;
		//if(strSchCode.startsWith("UDMC"))
		//	iNumGrading = 1;//show only final grade.
		for (i = 0; i < iNumGrading; ++i){
			//if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") && !strSchCode.startsWith("PHILCST") ) 
				//strTemp = Integer.toString(i+1);
			//else
			strTemp = (String)vPMTSchedule.elementAt((i*2)+1);
			
			
			iIndexOf = strTemp.indexOf(" "); // remove 
			if (iIndexOf != -1) 
				if (i == 0) 
					strTemp = strTemp.substring(0,iIndexOf) +  " Grade";
				else
					strTemp = strTemp.substring(0,iIndexOf);
				
				if (strTemp.toLowerCase().startsWith("final")) 
					strTemp = "Finals";
			

		//}
		%>
      <td  class="thinborder"><div align="center"><font color="#000099" size="1"><%=strTemp%></font></div></td>
      <%} // end for loop%>
      <td width="8%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>Avg Grade</strong></font></div></td>
      <td width="8%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>Grade Final Point</strong></font></div></td>
      <td width="8%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>REMARKS</strong></font></div></td>
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

	++iTotEnrolled ;
	strTemp = ((String)vRetResult.elementAt(i+7)).toLowerCase();
	if(strTemp.startsWith("f"))
		++iTotFailed;
	else if(strTemp.startsWith("p"))
		++iTotPassed;
	else if(strTemp.startsWith("i"))
		++iTotInc;
	else if(strTemp.startsWith("d") || strTemp.startsWith("u"))
		++iTotDropped;
	else 
		++iTotOthers;
	%>
    <tr> 
      <td height="18"  class="thinborder"<%=strFontColor%>><font size="1">&nbsp;<%=iIncr%></font></td>
      <td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+3)+  WI.getStrValue((String)vRetResult.elementAt(i+5),"-","","")%></font></td>
      <% for (k = 0; k < iNumGrading; ++k) {
			strTemp = (String)vPMTSchedule.elementAt((k*2)+1);

			strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);
			if(strGrade != null && strGrade.indexOf(".") != -1 && strGrade.length() == 3)
				strGrade += "0";
			//System.out.println(strTemp +" : "+strGrade+" i :"+(String)vRetResult.elementAt(i));
			strAvgGrade    = null;
			strFinalPoint  = null;

			if(strTemp.startsWith("F")) {
				strFinalPoint = strGrade;
				iIndexOf = vWUPGrade.indexOf(new Integer(WI.getStrValue((String)vRetResult.elementAt(i), "0")));
				if(iIndexOf > -1) {
					strGrade = (String)vWUPGrade.elementAt(iIndexOf + 1);
					strAvgGrade = (String)vWUPGrade.elementAt(iIndexOf + 2);
					vWUPGrade.remove(iIndexOf);vWUPGrade.remove(iIndexOf);vWUPGrade.remove(iIndexOf);
					
					if( ((String)vRetResult.elementAt(i+7)).toLowerCase().equals("no permit")) {
						strFinalPoint = "&nbsp;";
						strAvgGrade = "&nbsp;";
					}
				}
				else {
					strGrade = null;
				}
				
			}
			
			
			
			
			strAdmSlipNumber = null;
		if(vAdmSlipNumber !=null && vAdmSlipNumber.size() > 0) {
			iIndexOf = vAdmSlipNumber.indexOf(vRetResult.elementAt(i+1));
			//System.out.println("1: "+iIndexOf);
			//System.out.println("2: "+vPMTSchedule.elementAt((k*2)));
			
			if(iIndexOf > -1) {
				strTemp = (String)vPMTSchedule.elementAt((k*2));
				while(true) {//I have to make sure, the admission slip number is the adm slip number of that pmt schedule.
					if(vAdmSlipNumber.elementAt(iIndexOf + 1). equals(strTemp)) {
						strAdmSlipNumber = (String)vAdmSlipNumber.elementAt(iIndexOf + 2);
						vAdmSlipNumber.remove(iIndexOf);vAdmSlipNumber.remove(iIndexOf);vAdmSlipNumber.remove(iIndexOf);
						break;
					}
					if(!vAdmSlipNumber.elementAt(iIndexOf).equals(vRetResult.elementAt(i+1)) )
						break;
					iIndexOf = iIndexOf + 3;
					if(vAdmSlipNumber.size() < iIndexOf + 1)
						break;
				}	
			}
		}
		if(strAdmSlipNumber != null && strAdmSlipNumber.equals("0"))
			strAdmSlipNumber = "&nbsp;";
	  %>
      <td align="center"  class="thinborderGrade"<%=strFontColor%>><font size="1"<%=strFontColor%>><strong><%=WI.getStrValue(strGrade,"&nbsp;")%></strong></font></td>
      <%} //end for loop k = 0; k < iNumGrading; ++k%>
      <td align="center"  class="thinborder"><font size="1"<%=strFontColor%>><strong><%=WI.getStrValue(strAvgGrade, "&nbsp;")%></strong></font></td>
      <td align="center"  class="thinborder"><font size="1"<%=strFontColor%>><strong><%=WI.getStrValue(strFinalPoint, "&nbsp;")%></strong></font></td>
      <td align="center"  class="thinborder"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+7)%></font></td>
    </tr>
    <%} //end for loop i = iNumStud, iCount = 1; i<vRetResult.size(); i+=9+(iNumGrading-1), iCount++ 
	if (strSchCode.startsWith("AUF"))
		strTemp = Integer.toString(4+iNumGrading - 1) ;  // colspan -1 for the remarks, -1 midterm
	else if(strSchCode.startsWith("UDMC"))
		strTemp = "5";
	else
		strTemp = Integer.toString(5+iNumGrading*2);
	
	if ( iNumStud > vRetResult.size()-1 || iIncr == 1) {%>
    <tr> 
      <td colspan="<%=Integer.parseInt(strTemp) + 2%>"  class="thinborder"><div align="center">***************** 
          NOTHING FOLLOWS *******************</div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td colspan="<%=Integer.parseInt(strTemp) + 2%>"  class="thinborder"><div align="center">************** 
          CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}//end else%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="2">SUBMITTED BY: </td>
      <td width="42%" rowspan="7" valign="top">&nbsp;</td>
    </tr>
    <tr> 
      <td height="17" colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="23" colspan="2" valign="bottom"><div align="center"> 
          <table width="88%" border="0" cellspacing="0" cellpadding="0">
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
      <td colspan="2" valign="bottom"> <table width="94%" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td colspan="2" valign="bottom"><BR>APPROVED BY:</td>
          </tr>
          <tr> 
            <td width="15%" height="30" valign="bottom">&nbsp;</td>
            <td width="85%" valign="bottom" class="thinborderBottom"><div align="center"> 
                <label id="L_1" onClick="ChangeInfo('L_1')">
				<%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strOfferedByCollege,"DEAN_NAME"," and is_del = 0")).toUpperCase()%>				</label></div></td>
          </tr>
          <tr> 
            <td height="18" valign="bottom">&nbsp;</td>
            <td valign="top"><div align="center"><font size="1">DEAN / HEAD</font></div></td>
          </tr>
        </table></td>
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