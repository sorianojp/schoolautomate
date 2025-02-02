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

if(strSubSecIndex != null) {
	vRetResult = gsExtn.getAllGradesEncoded(dbOP,request,strSubSecIndex,bolSeparateMixedSection);
	//System.out.println(gsExtn.vCGHGrade);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else {
		//if partial, remove the entries without grade.. 
		if(WI.fillTextValue("show_partial").length() > 0) {
			//remove all entries without grade.. 
			Vector vTemp = (Vector)vRetResult.elementAt(0);
			int iPmtSch = 0;
			for (int iq = 0; iq < vTemp.size(); iq += 2){
				strTemp = (String)vTemp.elementAt(iq + 1);
				if(!strTemp.startsWith("M") && !strTemp.startsWith("F"))
					continue; 
				++iPmtSch;
			}
			
			iPmtSch = 8 + (iPmtSch * 2);
			//System.out.println(iPmtSch);
			for(int iq = 1; iq < vRetResult.size(); iq += iPmtSch) {
				if(vRetResult.elementAt(iq) == null) {
					for(int ir = 0; ir < iPmtSch; ++ir) 
						vRetResult.remove(iq);
					iq = iq - iPmtSch;
					//System.out.println("Removed 1 row.");
				}
			} 
			
		}
	
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
  	<td width="12%"><img src="../../../images/logo/UL_DAGUPAN.gif" width="75" height="75"></td>
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
      <td width="3%" class="thinborder"><font color="#000099" size="1"><strong>Count</strong></font></td>
      <td width="10%" class="thinborder"><font color="#000099" size="1"><strong>ID. 
        Number</strong></font></td>
      <td width="25%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>NAME 
          OF STUDENT</strong></font></div></td>
<% if (strSchCode.startsWith("AUF"))
		strTemp = " COURSE YEAR / SECTION";
	else if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("DBTC"))
		strTemp = " COURSE-YR";
	else
		strTemp = " COURSE";
%>
      <td width="10%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong><%=strTemp%></strong></font></div></td>
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
			
			if(!strTemp.startsWith("M") && !strTemp.startsWith("F"))
				continue; 
			
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
      <td  class="thinborder"><div align="center"><font color="#000099" size="1">Permit No</font></div></td>
      <%} // end for loop%>
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
<% 
	if (strSchCode.startsWith("AUF"))
		strTemp = " " + WI.getStrValue((String)vRetResult.elementAt(i+5)) + " / "  +
					WI.fillTextValue("section_name");
	else if (strSchCode.startsWith("UDMC") || strSchCode.startsWith("DBTC"))
		strTemp = " - " + WI.getStrValue((String)vRetResult.elementAt(i+5));
	else
		strTemp ="";
%>

	  <%//System.out.println(vRetResult);%>
      <td  class="thinborder"><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+3)+WI.getStrValue((String)vRetResult.elementAt(i+4),"/","","") +  strTemp%></font></td>
      <% for (k = 0; k < iNumGrading; ++k) {
			strTemp = (String)vPMTSchedule.elementAt((k*2)+1);
			
			if(!strTemp.startsWith("M") && !strTemp.startsWith("F"))
				continue; 

			strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);
			if(strGrade != null && strGrade.indexOf(".") != -1 && strGrade.length() == 3)
				strGrade += "0";
			//System.out.println(strTemp +" : "+strGrade);
			if(!strGrade.equals("&nbsp") && strTemp.startsWith("M")) {
				iIndexOf = gsExtn.vCGHGrade.indexOf((String)vRetResult.elementAt(i+1));
				strGrade = null;
				if(iIndexOf > -1) 
					strGrade = (String)gsExtn.vCGHGrade.elementAt(iIndexOf + 1);
				//System.out.println("I am in M: "+strGrade);
				if(strGrade == null)
					strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);
				
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
      <td align="center"  class="thinborderGrade"<%=strFontColor%>><font size="1"<%=strFontColor%>><strong><%=strGrade%></strong></font></td>
      <td align="center"  class="thinborderGrade"<%=strFontColor%>><font size="1"<%=strFontColor%>><strong><%=WI.getStrValue(strAdmSlipNumber)%></strong></font></td>
	  	
      <%} //end for loop k = 0; k < iNumGrading; ++k
	  
	   if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") )  {
	  %>
      <td align="center"  class="thinborder"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+7)%></font></td>
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
  <%if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("UL")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="2">SUBMITTED BY: </td>
      <td width="42%" rowspan="7" valign="top">
	  <table width="100%" cellpadding="0" cellspacing="0">
	  <tr>
	  	<td width="56%">
		<%if(bolIsMasteral) {%>
			<table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
				<tr>
				  <td colspan="2"><strong>GRADING SYSTEM</strong></td>
			    </tr>
				<tr>
				  <td width="40%">1.0-1.09 </td>
				  <td width="60%">Excellent</td>
				</tr>
				<tr>
				  <td>1.10-1.25 </td>
				  <td>Superior</td>
				</tr>
				<tr>
				  <td>1.26-1.50 </td>
				  <td>Very Satisfactory </td>
				</tr>
				<tr>
				  <td>1.51-1.75 </td>
				  <td>Above Average </td>
				</tr>
				<tr>
				  <td>1.76-2.00 </td>
				  <td>Average </td>
				</tr>
				<tr>
				  <td>Lower than 2.00 </td>
				  <td>Passing but not given graduate credit </td>
				</tr>
				<tr>
				  <td>5.00</td>
				  <td>Failed</td>
				</tr>
				<tr>
				  <td>DR</td>
				  <td>Dropped</td>
				</tr>
				<tr>
				  <td>W </td>
				  <td>Withdrawn (registered but never attended the subject) </td>
				</tr>
      		</table>
		<%}else{%>
			<table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
				<tr>
				  <td colspan="2"><strong>GRADING SYSTEM</strong></td>
			    </tr>
				<tr>
				  <td width="40%">1.00 </td>
				  <td width="60%">97 - 100%</td>
				</tr>
				<tr>
				  <td>1.25 </td>
				  <td>94 - 96 </td>
				</tr>
				<tr>
				  <td>1.50 </td>
				  <td>91 - 93 </td>
				</tr>
				<tr>
				  <td>1.75 </td>
				  <td>88 - 90 </td>
				</tr>
				<tr>
				  <td>2.00 </td>
				  <td>85 - 87 </td>
				</tr>
				<tr>
				  <td>2.25 </td>
				  <td>82 - 84 </td>
				</tr>
				<tr>
				  <td>2.50 </td>
				  <td>79 - 81 </td>
				</tr>
				<tr>
				  <td>2.75</td>
				  <td>76 - 78 </td>
				</tr>
				<tr>
				  <td>3.0 </td>
				  <td>75 </td>
				</tr>
				<tr>
				  <td>5.0 </td>
				  <td>74 and below </td>
				</tr>
				<tr>
				  <td>Inc </td>
				  <td>Incomplete </td>
				</tr>
				<tr>
				  <td>W </td>
				  <td>Dropped</td>
				</tr>
      		</table>
		<%}%>
		</td>
	  	<td valign="top" width="44%">
		<%if(iNumStud > vRetResult.size()-1) {%>
			<table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
		        <tr>
        		  <td><strong>SUMMARY</strong></td>
	            </tr>
		        <tr>
        		  <td>No. Of Students Passed: <%=iTotPassed%></td>
	            </tr>
		        <tr>
        		  <td>No. Of Students Given Incomplete: <%=iTotInc%></td>
	            </tr>
		        <tr>
        		  <td>No. Of Students Dropped: <%=iTotDropped%></td>
	            </tr>
		        <tr>
        		  <td>No. Of Students Failed: <%=iTotFailed%></td>
	            </tr>
		        <tr>
        		  <td>
				  <%if(WI.fillTextValue("show_partial").length() == 0) {%>
				  	  No. Of Students Enrolled: 
				  <%}else{%>
					  No. Of Students Encoded: 
				  <%}%>
				  
				  <%=iTotEnrolled%></td>
	            </tr>
      		</table>
		<%}else{%>
			<table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
		        <tr>
        		  <td><strong>&nbsp;</strong></td>
	            </tr>
      		</table>
		<%}%>
		</td>
	  </tr>
	  <tr>
	  	<td colspan="2" align="right">Date and Time Printed: <%=WI.getTodaysDateTime()%></td>
	  </tr>
	  </table>
	  
	  
	  
	  
	  </td>
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
  
  <%}else if (!strSchCode.startsWith("AUF")) {%>
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
 <%} else{%>
 
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