<%
request.getSession(false).setAttribute("school_code","UC");
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
String[] astrConvSemester = {"SUMMER", "1ST TERM", "2ND TERM", "3RD TERM"};


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

// this is for gender
boolean bolSeparateMixedSection = true;

if(strSubSecIndex != null) {
	vRetResult = gsExtn.getAllGradesEncoded(dbOP,request,strSubSecIndex,false);
	//System.out.print("vRetResult "+vRetResult);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
}

    Vector vEmpRec = new enrollment.Authentication().operateOnBasicInfo(dbOP,request,"0");
	
	if (vRetResult != null) { 
//		System.out.println(vRetResult);
	
		int i = 0; int k = 0; int iNumGrading = 0; int iCount = 0;
		int iMidTermIndex = 0;
		int iMaxStudPerPage = 30; 

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
   
    <tr> 
      <td colspan="3"><div align="center"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong></div></td>
    </tr>
    <tr> 
      <td colspan="3"><div align="center"><strong><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></strong></div></td>
    </tr>
    
	<tr><td colspan="3" height="30">&nbsp;</td></tr>
    <tr> 
      <td colspan="3"> <div align="center"><strong>REPORT ON GRADES</strong></div></td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
   
  </table>
<%if(vSecDetail != null){
	//if (bolSeparateMixedSection) 
		//strCurrentSubIndex = (String)vRetResult.elementAt(iNumStud + 8);
	//else
		strCurrentSubIndex = WI.fillTextValue("subject");		
%>

	<table width="100%" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" border="0">
	
		
		<tr>
			<td width="2%">&nbsp;</td>
			<td class="thinborderBottom" align="center"><%=WI.fillTextValue("section_name")%></td>
			<td width="2%">&nbsp;</td>
			<%if(WI.fillTextValue("subject").length() > 0) {
				strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_code"," and is_del<>1");
			}%>
		
			<td class="thinborderBottom" align="center"><%=strTemp.toUpperCase()%></td>
			<td width="2%">&nbsp;</td>
		
		
			<td class="thinborderBottom" align="center">
			<%for( i = 1; i<vSecDetail.size(); i+=3){
				if(i >1){%>
				, 
				<%}%>
			<%=(String)vSecDetail.elementAt(i+2)%> 
			<%}%>
			</td>
			<td width="2%">&nbsp;</td>
			<td class="thinborderBottom" align="center"><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></td>
			<td width="2%">&nbsp;</td>
		</tr>
		
		
		<tr>
			<td width="2%">&nbsp;</td>
			<td align="center" valign="top">Code</td>
			<td width="2%">&nbsp;</td>
			<td align="center" valign="top">Subject</td>
			<td width="2%">&nbsp;</td>
			<td align="center" valign="top">(Time & Days)</td>
			<td width="2%">&nbsp;</td>
			<td align="center" class="thinborderBottom" valign="top"><%=WI.fillTextValue("sy_from")%>- <%=WI.fillTextValue("sy_to")%></td>
			<td width="2%">&nbsp;</td>
		</tr>
		
		<tr><td height="40">&nbsp;</td></tr>
	</table>


<%
	if (vRetResult != null && vRetResult.size() > 0){ 
	i = 0;
%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="">
    <tr> 
      <!--<td width="3%" class="thinborder"><font color="#000099" size="1"><strong>Count</strong></font></td>-->
      <td width="14%" class="" align="left"><font color="#000099" size="1"><strong><div style="border-bottom:solid 1px #000000; width:90%">ID. Number</div></strong></font></td>
      <td width="30%" align="left" class=""><div style="border-bottom:solid 1px #000000; width:90%"><font color="#000099" size="1"><strong>NAME 
          OF STUDENT</strong></font></div></td>
	  <td width="3%" align="center"><div style="border-bottom:solid 1px #000000; width:90%">
	  	<font color="#000099" size="1"><strong>&nbsp;</strong></font></div></td>
<% if (strSchCode.startsWith("AUF"))
		strTemp = " COURSE YEAR / SECTION";
	else if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("DBTC"))
		strTemp = " COURSE-YR";
	else
		strTemp = " COURSE";
%>
      <td width="20%" align="left"><div style="border-bottom:solid 1px #000000; width:90%"><font color="#000099" size="1"><strong><%=strTemp%></strong></font></div></td>
      <% Vector vPMTSchedule = (Vector)vRetResult.elementAt(0); 
	  	 iNumGrading = vPMTSchedule.size()/2;
		int iIndexOf = 0;
		//if(strSchCode.startsWith("UDMC"))
		//	iNumGrading = 1;//show only final grade.
		for (i = 0; i < iNumGrading; ++i){
			strTemp = (String)vPMTSchedule.elementAt((i*2)+1);				
		%>
      <td align="center"><div style="border-bottom:solid 1px #000000; width:90%"><font color="#000099" size="1"><strong><%=strTemp.toUpperCase()%></strong></font></div></td>
      <%} // end for loop%>
      <% if (!strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC") ){%>
      <td width="10%" align="left"><div style="border-bottom:solid 1px #000000; width:90%"><font color="#000099" size="1"><strong>REMARKS</strong></font></div></td>
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
		
	if (!bolSeparateMixedSection && (!((String)vRetResult.elementAt(i+8)).equals(strCurrentSubIndex))) {
		iIncr = 1;  // reset student number count
		bolPageBreak = true;		
		break;
	}
	
	//if( ((String)vRetResult.elementAt(i+7)).toLowerCase().startsWith("f") || ((String)vRetResult.elementAt(i+7)).toLowerCase().startsWith("f"))
	if(((String)vRetResult.elementAt(i+7)).toLowerCase().startsWith("p"))
		strFontColor = "";
	else	
		strFontColor = " color=red";

	%>
	
    <tr> 
      <!--<td height="18"  class="thinborder"<%=strFontColor%>><font size="1">&nbsp;<%=iIncr%></font></td>-->
      <td height="18" class=""><div style="border-bottom:solid 1px #000000; width:90%">
	  	<font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></div></td>
      <td height="18" class=""><div style="border-bottom:solid 1px #000000; width:90%">
	  	<font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></div></td>
		
	  <td height="18" align="center"><div style="border-bottom:solid 1px #000000; width:90%">
	  	<font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+8)%></font></div></td>

	  
      <td  class=""><div style="border-bottom:solid 1px #000000; width:90%">
	  	<font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+3)+WI.getStrValue((String)vRetResult.elementAt(i+5),"-","","")%></font></div></td>
      <% for (k = 0; k < iNumGrading; ++k) {
	  		if (k == iMidTermIndex && strSchCode.startsWith("AUF")) 
				continue;
			else if (k < (iNumGrading - 1) && strSchCode.startsWith("UDMC"))
				continue;
			
			
			strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);
			//System.out.println("strGrade1 "+strGrade);
			//if(strGrade.equalsIgnoreCase("NFE"))
			//	strGrade = "INC";
			
			if(strGrade != null && strGrade.indexOf(".") != -1 && strGrade.length() == 3)
				strGrade += "0";
	  %>
      <td align="center"  class=""<%=strFontColor%>><div style="border-bottom:solid 1px #000000; width:90%"><font size="1"<%=strFontColor%>><strong>
	  	<%=strGrade%></strong></font></div></td>
      <%} //end for loop k = 0; k < iNumGrading; ++k
	  strTemp = (String)vRetResult.elementAt(i+7);
	  if(strTemp.equalsIgnoreCase("No Final Examination"))
	  	strTemp = "NFE";
	  
	  %>
      <td align="left"  class=""><div style="border-bottom:solid 1px #000000; width:90%"><font size="1"<%=strFontColor%>><%=strTemp%></font></div></td>
      
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
		<%if(WI.fillTextValue("subject").length() > 0) {
			strErrMsg = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_name"," and is_del<>1");
		}%>
      <td height="18">COURSE DESCRIPTION: </td>
	  <td colspan="<%=strTemp%>" style="border-bottom:solid 1px #000000;" align="center"> <strong><%=strErrMsg.toUpperCase()%></strong>	 </td>	 
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td height="18" colspan="<%=strTemp%>"  class=""><div align="center">************** 
          CONTINUED ON NEXT PAGE ****************</div></td>
    </tr>
    <%}//end else%>
 
  </table>
  <hr>
  <table width="100%" border="0">
  	<tr><td colspan="5">GRADING SYSTEM: 95-EXCEPTIONAL; 90-EXCELLENT; 85-GOOD; 80-FAIR; 75-PASSING; BELOW 75-FAILURE,MUST REPEAT</td></tr>	
	<tr><td colspan="5">&nbsp;</td></tr>
	<tr>
		<td width="20%" align="right">DATE SUBMITTED</td>
		<td width="20%">______________________</td>
		<td width="20%">&nbsp;</td>
		<td align="center">______________________</td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td>______________________</td>
		<td>&nbsp;</td>
		<td align="center">SIGNATURE</td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td>______________________</td>
		<td>&nbsp;</td>
		
		<td align="center">
		<%if(vSecDetail != null){%>
		<strong><u><%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%></u></strong>
		<%}%></td>
	</tr>
	
	<tr>
		<td colspan="3">Date and Time Printed:
			<%=WI.getTodaysDateTime()%></td>	
		<td align="center">INSTRUCTOR</td>
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