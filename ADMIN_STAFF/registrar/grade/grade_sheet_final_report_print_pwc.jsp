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
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	}

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
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
	String strFinalGrade = null;
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
String[] astrConvSemester = {"Summer", "FIRST TRIME.", "SECOND TRIME.", "THIRD TRIME.", "FOURTH TRIME."};


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
	
	/*strOfferedByCollege = dbOP.mapOneToOther("e_sub_section","sub_sec_index", strSubSecIndex, 
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
*/
	
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex,strSchCode.startsWith("AUF"));
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

boolean bolSeparateMixedSection = WI.fillTextValue("separate_grades").equals("1");
bolSeparateMixedSection = false;
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
		
		String strDeanName = null;
		String strDeptName = null;	
		
		if (strSubSecIndex != null && strSubSecIndex.length() > 0) {
			strTemp = "select dean_name from college "+
						"join e_sub_section on (e_sub_section.offered_by_college = c_index) "+
						"where sub_sec_index = "+strSubSecIndex;
			strDeanName = dbOP.getResultOfAQuery(strTemp, 0);			
		}
		
		if(vEmpRec != null && vEmpRec.size() > 0){
			
			strTemp = "select  DH_NAME from DEPARTMENT where d_INDEX = "+vEmpRec.elementAt(12);
			strDeptName = dbOP.getResultOfAQuery(strTemp, 0);
		}
		
if (strSchCode.startsWith("AUF")){
		astrConvSemester[0] = "Summer";
		astrConvSemester[1] = "First";
		astrConvSemester[2] = "Second";
		astrConvSemester[3] = "Third";
}

double[] adAvgRoundOff = null;
Vector vInfoAvgRoundOff = new Vector();

for (;iNumStud < vRetResult.size()-1;){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">    
	<tr>
		<td height="70px" align="center" valign="bottom"><strong><font size="2">GRADE SHEET</font></strong></td>
	</tr>   
  </table>
<%if(vSecDetail != null){

String strDays = null;
String strTime = null;


	for(int x = 1; x < vSecDetail.size(); x+=3){		
		strErrMsg = (String)vSecDetail.elementAt(x + 2);
		if(strErrMsg != null) {
			Vector vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);			
			strErrMsg = "";
			while(vTemp.size() > 0) {
				strTemp = (String)vTemp.remove(0);
				int iIndexOf = strTemp.indexOf(" ");
				if(iIndexOf > -1){							
					if(strTime == null)
						strTime = strTemp.substring(iIndexOf + 1).toLowerCase();						
					else
						strTime += ", "+strTemp.substring(iIndexOf + 1).toLowerCase();	
					
					if(strDays == null)						
						strDays = strTemp.substring(0, iIndexOf);
					else						
						strDays += ", "+strTemp.substring(0, iIndexOf);
											
				}				
			}
		}
		
	}	
	 

	if (vRetResult != null && vRetResult.size() > 0){ 
	i = 0;
	double dDynamicWidth = 0d;
	

	strErrMsg = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_code"," and is_del=0");
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");

	
%>

<table width="100%" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="bottom" width="15%"><strong>Course Cat. No.</strong></td>
		<td valign="bottom" width="30%" class="thinborderBottom"><%=(WI.getStrValue(strErrMsg)).toUpperCase()%></td>
		<td valign="bottom" width="13%" align="right"><strong>Section&nbsp;</strong></td>
		<td valign="bottom" class="thinborderBottom" width="20%"><%=WI.fillTextValue("section_name")%></td>
		<td width="8%">&nbsp;</td>		
		<td width="14%">&nbsp;</td>		
	</tr>
	
	<tr>
		<td valign="bottom"><strong>Course Title</strong></td>
		<td valign="bottom" class="thinborderBottom"><%=(WI.getStrValue(strTemp)).toUpperCase()%></td>
		<td align="right"><strong>Days&nbsp;</strong></td>
		<td class="thinborderBottom"><%=strDays%></td>
		<td valign="bottom" align="right"><strong>Trimester</strong>&nbsp;</td>		
		<td valign="bottom" class="thinborderBottom"><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></td>		
	</tr>
	
	<tr>
		<td valign="bottom"><strong>Units</strong></td>
		<td valign="bottom" class="thinborderBottom"><%=GS.getLoadingForSubject(dbOP, request.getParameter("subject"))%></td>
		<td align="right"><strong>Time&nbsp;</strong></td>
		<td class="thinborderBottom"><%=strTime%></td>
		<td valign="bottom" align="right"><strong>S.Y.</strong>&nbsp;</td>		
		<td valign="bottom" class="thinborderBottom"><%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></td>		
	</tr>
</table>

  <br>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td valign="top" width="85%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
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
      
      <td  class="thinborderGrade">&nbsp;</td>
		<td  class="thinborderGrade"><div align="center"><font color="#000099"><strong>STUDENT'S NAME</strong></font></div></td>
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
			strTemp = ((String)vPMTSchedule.elementAt((i*2)+1)).toLowerCase();
			
			if(strTemp.startsWith("prelim"))
				strTemp = "PRELIM";
			else if(strTemp.startsWith("midterm"))
				strTemp= "MIDTERM";
			else if(strTemp.startsWith("semi"))
				strTemp= "PRE-FINAL";
			else if(strTemp.startsWith("final"))
				strTemp= "FINAL";
		%>
      <td  class="thinborder" width="10%"><div align="center"><font color="#000099"><%=strTemp.toUpperCase()%></font></div></td>
      <%} // end for loop%>
      <td  class="thinborder" width="10%"><div align="center"><font color="#000099">FINAL GRADE</font></div></td>
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
      <td width="3%" height="18"  class="thinborder"><font<%=strFontColor%>>&nbsp;<%=iIncr%>.</font></td>
      <td class="thinborder"><font<%=strFontColor%>><%=(String)vRetResult.elementAt(i+2)%></font></td>
     
      <% 
		
		
		for (k = 0; k < iNumGrading; ++k) {
			strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);
			if(strGrade == null)
				strGrade = "";
		//System.out.println("strGrade "+strGrade);
		//System.out.println("strGrade "+strGrade);
	  iIndexOf = strGrade.indexOf("/");
	  if(iIndexOf > -1) {
	  	strFinalGrade = strGrade.substring(iIndexOf + 1);
		strGrade = strGrade.substring(0, iIndexOf);	
	  }
	  else
	  	strFinalGrade = "";

		if(strGrade != null) {
			try {
				Double.parseDouble(strGrade);
				//double dGrade = Double.parseDouble(strGrade);
				//if(strGrade.length() == 4)
				///	strGrade += "0";
				//else if(strGrade.length() == 2)	
				//	strGrade += ".00";
					
			}catch(Exception e) {	
				strGrade = "0.00";		
			}
		}
		if(strFinalGrade != null) {
			try {
				Double.parseDouble(strFinalGrade);
				if(strFinalGrade.length() == 4)
					strFinalGrade = strFinalGrade.substring(0,3);
			}
			catch(Exception e) {			
			}
		}
	  vInfoAvgRoundOff.addElement(strGrade);
	  if(strGrade.equals("0.00"))
	  	strGrade = "&nbsp;";
	  %>
    <td align="center"  class="thinborderGrade"<%=strFontColor%>><font<%=strFontColor%>><strong> <%=WI.getStrValue(strGrade,"-")%></strong></font></td>
    <%} //end for loop k = 0; k < iNumGrading; ++k
	 	adAvgRoundOff  = gsExtn.getAvgAndRoundOff(vInfoAvgRoundOff);
	   vInfoAvgRoundOff = new Vector();
	 %>
      <td align="center"  class="thinborderGrade">&nbsp;<font<%=strFontColor%>>
      <%if(adAvgRoundOff != null) {%>
      <strong><%=CommonUtil.formatFloat(adAvgRoundOff[0], true)%></strong>
      <%}%>
    </font></td>
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
		</td>
		
		<td align="center" valign="top">
			<br><br><br>
			<table width="95%" border="0" cellspacing="0" cellpadding="0" style="border:solid 1px #CCCCCC;">
				<tr><td colspan="3">Grade Equivalent</td></tr>
				<tr>
					<td width="22%">1.00</td>
					<td width="16%" align="center">=</td>
					<td width="62%">99-100</td>
				</tr>
				<tr>
					<td>1.25</td>
					<td align="center">=</td>
					<td>96-98</td>
				</tr>
				<tr>
					<td>1.50</td>
					<td align="center">=</td>
					<td>93-95</td>
				</tr>
				<tr>
					<td>1.75</td>
					<td align="center">=</td>
					<td>90-92</td>
				</tr>
				<tr>
					<td>2.00</td>
					<td align="center">=</td>
					<td>87-89</td>
				</tr>
				<tr>
					<td>2.25</td>
					<td align="center">=</td>
					<td>84-86</td>
				</tr>
				<tr>
					<td>2.50</td>
					<td align="center">=</td>
					<td>81-83</td>
				</tr>
				<tr>
					<td>2.75</td>
					<td align="center">=</td>
					<td>78-80</td>
				</tr>
				<tr>
					<td>3.00</td>
					<td align="center">=</td>
					<td>75-77</td>
				</tr>
				<tr>
					<td>4.00</td>
					<td align="center">=</td>
					<td>71-74</td>
				</tr>
				<tr>
					<td>5.00</td>
					<td align="center">=</td>
					<td>50-70</td>
				</tr>
				<tr>
					<td>9.00</td>
					<td align="center">=</td>
					<td>Dropped</td>
				</tr>
				<tr>
					<td valign="top">5FA</td>
					<td valign="top" align="center">=</td>
					<td>Failure Due to excess absences</td>
				</tr>
				<tr>
					<td valign="top">GWH</td>
					<td valign="top" align="center">=</td>
					<td>Grade Withheld</td>
				</tr>
			</table>
			<br>
			<table width="95%" border="0" cellspacing="0" cellpadding="0" style="border:solid 1px #CCCCCC;">
				<tr>
					<td align="justify">
						1. This Grade Sheet should be submitted to the 
							Chairperson within 10 working days after the last day of exam period.
					</td>
				</tr>
				<tr>
					<td align="justify">						
						2. Please use font 12, Arial
					</td>
				</tr>
			</table>
			<br>
			<table width="95%" border="0" cellspacing="0" cellpadding="0" style="border:solid 1px #CCCCCC;">
				<tr><td colspan="2" height="">&nbsp;</td></tr>
				<tr><td colspan="2" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%"></div>Signatures:</td></tr>
				<tr><td colspan="2" height="30">&nbsp;</td></tr>
				<tr>
					<td width="65%" valign="bottom" align="center"><div style="border-bottom: solid 1px #000000; width:90%"></div>Instructor</td>
					<td width="35%" valign="bottom" align="center"><div style="border-bottom: solid 1px #000000; width:90%"></div>Date</td>
				</tr>
				<tr><td colspan="2"><%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4).toUpperCase()%></td></tr>
				
				<tr><td colspan="2" height="30">&nbsp;</td></tr>
				<tr>
					<td width="65%" valign="bottom" align="center"><div style="border-bottom: solid 1px #000000; width:90%"></div>Chairperson</td>
					<td width="35%" valign="bottom" align="center"><div style="border-bottom: solid 1px #000000; width:90%"></div>Date</td>
				</tr>
				<tr><td colspan="2"><%=WI.getStrValue(strDeptName).toUpperCase()%></td></tr>
				
				<tr><td colspan="2" height="30">&nbsp;</td></tr>
				<tr>
					<td width="65%" valign="bottom" align="center"><div style="border-bottom: solid 1px #000000; width:90%"></div>Dean</td>
					<td width="35%" valign="bottom" align="center"><div style="border-bottom: solid 1px #000000; width:90%"></div>Date</td>
				</tr>
				<tr><td colspan="2"><%=WI.getStrValue(strDeanName).toUpperCase()%></td></tr>
			</table>
		</td>
	</tr>
</table>
  
  
 
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="2">Received:</td></tr>
	<tr>
		<td height="40" width="50%" align="center" valign="bottom"><div style="border-bottom: solid 1px #000000; width:60%;"></div></td>
		<td height="40" align="center" valign="bottom"><div style="border-bottom: solid 1px #000000; width:60%;">
		<%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4).toUpperCase()%>
		</div></td>
	</tr>
	<tr>
		<td valign="top" align="center">Registrar</td>
		<td valign="top" align="center">Printed Name of Instructor</td>
	</tr>
	<tr>
		<td height="20" valign="bottom">Date Received: ____________</td>
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