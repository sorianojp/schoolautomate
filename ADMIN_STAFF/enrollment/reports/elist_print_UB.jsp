<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	boolean bolShowData = true;
	if(WI.fillTextValue("print_to_excel").length() > 0)
		bolShowData = false;	
	
	String strOrigSchCode = strSchCode;
	
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
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}
/**
<%if(WI.fillTextValue("show_border").compareTo("1") ==0){%>
**/
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
/**
<%}else{%>
**/
    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
/**
<%}%>
**/
    TABLE.jumboborder {
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderTOP {
    border-top: solid 2px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderTOPex {
    /**border-top: solid 1px #000000;**/
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.jumboborderTOPONLY {
    border-top: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


-->
</style>
</head>

<body topmargin="0" bottommargin="0"<%if(bolShowData){%>onLoad="window.print();"<%}%>>
<%
	String strErrMsg = null;String strTemp = null;
	String strCollegeName = null;
	String strCollegeIndex = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
	String[] astrConvertYr	= {"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Enrollment list print","elist_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//get the enrollment list here.
ReportEnrollment enrlReport = new ReportEnrollment();
Vector vEnrlInfo = new Vector();
boolean bolSeparateName = false;
int iNoOfSubPerRow = 6;
boolean bolShowPageBreak = false;


//needed -- do not remove this.
bolSeparateName = true;
iNoOfSubPerRow = 20;
int iIndexOf = 0;

Vector vRetResult = enrlReport.getEnrollmentListUB(dbOP,request);
if(vRetResult == null || vRetResult.size() ==0) {
	strErrMsg = enrlReport.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Enrollment list not found.";
}
if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0">
<tr>
	<td>
		<font size="4"><%=strErrMsg%></font>
	</td>
</tr>
</table>
<%dbOP.cleanUP();
return;
}
Vector vDroppedStudent = new Vector();
String strSQLQuery = null;


utility.CreateExcelSheet ces = new utility.CreateExcelSheet();
ces.dontCreateFile(bolShowData);
ces.createFile(dbOP, request, "EnrollmentList");	
ces.createNewSheet("EnrollmentList");

///get list of student who withdrawn their enrollment.. 
strSQLQuery = "CREATE table #1 (ui int, enrl_i int)";
dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
strSQLQuery = "insert into #1 "+
				"select user_index, MAX(ENRL_FINAL_CUR_LIST.enroll_index) from ENRL_FINAL_CUR_LIST where IS_VALID = 0 and SY_FROM = "+WI.fillTextValue("sy_from")+
				" and CURRENT_SEMESTER = "+WI.fillTextValue("semester")+ " group by user_index";
dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);

strSQLQuery = "delete from #1 where exists (select enroll_index from ENRL_ADD_DROP_HIST where enroll_index = enrl_i)";
dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);

strSQLQuery = "select id_number from stud_curriculum_hist join user_Table on (user_Table.user_index = stud_curriculum_hist.user_index) "+
				"where STUD_CURRICULUM_HIST.IS_VALID = 1 and SY_FROM = "+WI.fillTextValue("sy_from")+ " and semester= "+WI.fillTextValue("semester")+" and not exists ( "+
				"select enroll_index from ENRL_FINAL_CUR_LIST where SY_FROM = "+WI.fillTextValue("sy_from")+ " and current_semester= "+
				WI.fillTextValue("semester")+" and  IS_VALID = 1 and USER_INDEX = STUD_CURRICULUM_HIST.USER_INDEX) and exists "+
				"(select * from #1 where ui = STUD_CURRICULUM_HIST.USER_INDEX)";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) 
	vDroppedStudent.addElement(rs.getString(1));
rs.close();


 
int iDefNoOfRowPerPg = 0;
if(request.getParameter("stud_per_pg") == null)
	iDefNoOfRowPerPg = 18;
else
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

int iNoOfRowPerPg = iDefNoOfRowPerPg;

int iStudCount = 0;
int iTemp = vRetResult.size()/12;
int iTotalNoOfPage = iTemp / iNoOfRowPerPg;
if(iTemp%iNoOfRowPerPg > 0) 
	++iTotalNoOfPage;
/////////////////// end of computation for total # of pages. ///////////

int iPageCount = 1;
String strPgCountDisp = null;
String strCourseYr    = null;

//get all the students who dropped the subject 

for(int i = 0; i < vRetResult.size();){
	if(strCourseYr == null)
		strCourseYr = (String)vRetResult.elementAt(i);
	if(!strCourseYr.equals(vRetResult.elementAt(i))) {
		strCourseYr = (String)vRetResult.elementAt(i);
		iStudCount = 0;
	}	
	
	iNoOfRowPerPg = iDefNoOfRowPerPg;
//	strPgCountDisp = "Page count : "+Integer.toString(iPageCount++) +" of "+Integer.toString(iTotalNoOfPage);
	String strTableWidth = "width=1136";
if(bolShowData){
%>
<table width=100% border="0" cellspacing="0" cellpadding="0">
<%}
	ces.setFontSize(Integer.parseInt(WI.fillTextValue("font_size")));				
	ces.setBold(true);
	ces.setBorder(0);
	ces.setBorderLineStyle(0);
	ces.setAlignment(0);	
	
	
	if(i > 0){
		ces.addData("&nbsp;", true, 7, 0);	
		ces.addData("&nbsp;", true, 7, 0);	
		ces.addData("&nbsp;", true, 7, 0);	
		ces.addData("&nbsp;", true, 7, 0);	
		ces.addData("&nbsp;", true, 7, 0);			
	}
	ces.addData("Name Of Institution:", false, 1, 0);
	ces.addData("UNIVERSITY OF BOHOL", false, 3, 0);
	ces.addData("Tel. No. (038)411-3484/(038)411-2081", true, 1, 0);
	
	if(bolShowData){
	%>
	<tr>
		<td width="20%" height="20">Name Of Institution: </td>
		<td style="font-weight:bold">UNIVERSITY OF BOHOL </td>
	    <td style="font-weight:bold">Tel. No. <b>(038)411-3484/(038)411-2081</b></td>
	</tr>
	<%
	}
	
	ces.addData("Address:", false, 1, 0);
	ces.addData("MA. CLARA STREET, TAGBILARAN CITY, BOHOL", true, 5, 0);
	if(bolShowData){
	%>
	<tr>
		<td height="20">Address:</td>
		<td colspan="2" style="font-weight:bold">MA. CLARA STREET, TAGBILARAN CITY, BOHOL</td>
	</tr>
	<%
	}
	ces.addData("Institutional Identifier:", false, 1, 0);
	ces.addData("07075", true, 5, 0);
	if(bolShowData){
	%>
	<tr>
		<td height="20">Institutional Identifier:</td>
		<td width="37%" style="font-weight:bold">07075</td>
	    <td width="43%">&nbsp;</td>
	</tr>
	<%}
	
	
	
	strTemp = WI.fillTextValue("semester");
	if(strTemp.equals("0"))
		strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))] + " "+WI.fillTextValue("sy_to");
	else
		strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))] + ", SY"+WI.fillTextValue("sy_from") +"-"+ WI.fillTextValue("sy_to");
		
	ces.addData("Sem/Tri:", false, 1, 0);
	ces.addData(strTemp, true, 5, 0);
	
	if(bolShowData){
	%>
	<tr>
		<td height="20">Sem/Tri: </td>
		<td colspan="2" style="font-weight:bold"><%=strTemp%></td>
	</tr>
	<%}
	
	ces.addData("Course/Program:", false, 1, 0);
	ces.addData((String)vRetResult.elementAt(i + 7), true, 5, 0);
	
	if(bolShowData){
	%>
	<tr>
		<td height="20">Course/Program:</td>
		<td colspan="2" style="font-weight:bold">
		<%=vRetResult.elementAt(i + 7)%></td>
	</tr>
	<%}
	
	strTemp = astrConvertYr[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 9),"0"))];
	ces.addData("Year Level:", false, 1, 0);
	ces.addData(strTemp, true, 5, 0);
		
	if(bolShowData){
	%>
	<tr>
		<td height="20">Year Level:</td>
		<td colspan="2" style="font-weight:bold"><%=strTemp%></td>
	</tr>
	
</table>
<%}
if(bolShowData)
	strTemp = "thinborder";
else
	strTemp = "";
if(bolShowData){ 
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="<%=strTemp%>">
  <%}
  	ces.setBold(false);
	ces.setBorder(1);
  	ces.setBorderLineStyle(1);
  	ces.addData("Sl. No", false);
	ces.addData("Student ID", false);
	ces.addData("Last Name", false);
	ces.addData("First Name", false);
	ces.addData("Middle Name", false);
	ces.addData("Gender", false);
	ces.addData("Subject(s) Enrolled", false);
	ces.addData("Total Unit(s)", true);
	
	if(bolShowData){
  %>
  <tr>
    <td width="5%" height="24" class="thinborderSP" align="center">Sl. No</td>
    <td width="10%" class="thinborderSP"><div align="center">Student ID</div></td>
    <td width="10%" class="thinborderSP" align="center">Last Name</td>
    <td width="10%" class="thinborderSP"><div align="center">First Name</div></td>
    <td width="10%" class="thinborderSP" align="center">Middle Name</td>
    <td width="5%" class="thinborderSP"><div align="center">Gender</div></td>
    <td width="45%" class="thinborderSP"><div align="center">Subject(s) Enrolled</div></td>
    <td width="5%" class="thinborderSP"><div align="center">Total Unit(s)</div></td>
  </tr>
  <%}%>
  <%//bolShowID = true;
for(; i<vRetResult.size();i += 12){// this is for page wise display.
	vEnrlInfo = (Vector)vRetResult.elementAt(i + 11);
	
	if(vDroppedStudent.indexOf(vRetResult.elementAt(i + 2)) > -1)
		continue;
		
	//System.out.println(vEnrlInfo);
if(iNoOfRowPerPg <= 0) {
	bolShowPageBreak = true;
	break;
}
//if different course, must break.
if(!strCourseYr.equals(vRetResult.elementAt(i))) {
	bolShowPageBreak = true;
	break;
}
	--iNoOfRowPerPg;
	bolShowPageBreak = false;

if(bolShowData){	
%>
  <tr>
<%}%>
  
  	<%
	
	ces.addData(Integer.toString((++iStudCount)), false);
	ces.addData((String)vRetResult.elementAt(i+2), false);
	ces.addData((String)vRetResult.elementAt(i+5), false);
	ces.addData((String)vRetResult.elementAt(i+3), false);
	ces.addData(WI.getStrValue((String)vRetResult.elementAt(i + 4), "&nbsp;"), false);
	ces.addData((String)vRetResult.elementAt(i + 6), false);
	
	if(bolShowData){
	%>
  
    <td height="21" class="thinborder"><%=iStudCount%>.</td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "&nbsp;")%></td>
    <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
	<%}
	
	
	strTemp = null;
	if(vEnrlInfo.size() > 8)
		--iNoOfRowPerPg;
		
	for(int k=0; k < vEnrlInfo.size() ; k+= 3){//only sub and units enrolled.
		if(strTemp == null)
			strTemp = (String)vEnrlInfo.elementAt(k);
		else
			strTemp = strTemp +", "+(String)vEnrlInfo.elementAt(k);
	}
		if(strTemp == null)
			strTemp = "***** Withdrawn All Subjects *****";
			
	ces.addData(strTemp, false);
	ces.addData(WI.getStrValue((String)vRetResult.elementAt(i + 10), "0"), true);
	if(bolShowData){
	%>	
    <td class="thinborder"><%=strTemp%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 10), "0")%></td>
	
  </tr>
  <%}%>
  <%
 }//end of print per page.
if(bolShowData){ 
%>
 
</table>
<%}
ces.setBorderLineStyle(1);
ces.setBorder(0);
ces.addData("&nbsp;", true, 7, 0);	
ces.addData("&nbsp;", true, 7, 0);	
ces.addData("&nbsp;", true, 7, 0);	
ces.addData("&nbsp;", true, 7, 0);	
ces.addData("&nbsp;", true, 7, 0);		


ces.addData("Certified Correct by:", false, 1, 0);
ces.addData("DALIA MELDA T. MAGNO, CPA, MSBA <br>University Registrar", true, 5, 0);

if(bolShowData){
%>
<table cellpadding="0" cellspacing="0">

	

  <tr>
    <td height="40">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="172"> Certified Correct by: </td>
    <td align="center">
	DALIA MELDA T. MAGNO, CPA, MSBA <br>
	University Registrar
	<!--
	<img src="./ub_elist_signature.jpg">
	-->
	</td>
  </tr>
  
</table>
<%}
if(bolShowPageBreak && bolShowData){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}//break only if it is not last page.

}//end of printing. - outer for loop.



ces.writeAndClose(request);
if(!bolShowData){
	strTemp = "../../../download/EnrollmentList_"+WI.getTodaysDate()+".xls";
%>
	<a href="<%=strTemp%>">Click to download excel file</a>
<%}

%>
</body>
</html>
<%
dbOP.cleanUP();
%>
