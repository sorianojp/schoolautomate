<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function Search(){
	document.form_._search.value = '1';
	
	if(document.form_.department)
		if(document.form_.department.value.length > 0)
			document.form_.department_name.value = document.form_.department[document.form_.department.selectedIndex].text;
		else
			document.form_.department_name.value = "";
	document.form_.submit();
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	window.print();
}
</script>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<%@ page language="java" import="utility.*,lms.CirculationReport,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	java.sql.ResultSet rs = null;
	
	boolean bolBySubjectArea = WI.fillTextValue("by_subject_area").equals("1");
	boolean bolByCollSection = WI.fillTextValue("by_collection_section").equals("1");
	
	
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"LIB_Circulation","circ_by_collection_section_by_subject_area_view.jsp");
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


//end of authenticaion code.


CirculationReport cReport = new CirculationReport();
Vector vRetResult = null; Vector vColumnDetail = null; Vector vRowDetail = new Vector();
String strCount = null;
if(WI.fillTextValue("_search").length() > 0) {
	vRetResult = cReport.viewBorrowerGroupBySubjectArea(dbOP, request);	
	if(vRetResult == null)
		strErrMsg = cReport.getErrMsg();
	else	
		strCount = (String)vRetResult.remove(0);
	
}	

String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
String[] astrConvertTerm  = {"Summer","1st Sem","2nd Sem","3rd Sem"};
String strCollegeIndex = WI.fillTextValue("c_index");
String strCollegeCode  = WI.fillTextValue("c_code");
if(strCollegeCode.length() > 0 && strCollegeIndex.length() == 0){
	strTemp = "select c_index from college where is_del = 0 and c_code = "+WI.getInsertValueForDB(strCollegeCode, true, null);
	strCollegeIndex = dbOP.getResultOfAQuery(strTemp, 0);	
}


boolean bolDDCLCCode = WI.fillTextValue("ddc_lc_code").equals("1");
boolean bolGroupYearly   = WI.fillTextValue("group_yearly").equals("1");
boolean bolIsGrandTotal = strCollegeCode.toLowerCase().equals("grand total");

String strSubArea  = WI.fillTextValue("subject_area");
String strDateFrom = WI.fillTextValue("date_fr");
String strDateTo   = WI.fillTextValue("date_to");
String strYearOf   = WI.fillTextValue("year_of");
String strMonthOf  = WI.fillTextValue("month_of");

int iMonth         = Integer.parseInt(WI.getStrValue(strMonthOf,"0"));
if(bolGroupYearly)
	iMonth = iMonth - 1;


String strSYFrom   = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

String strReportName = null;
String strReportValue = null;
String strReportType = WI.fillTextValue("report_type");
if(strReportType.equals("1")){
	strReportName = "Daily Report for Date";
	strReportValue = strDateFrom;
}
else if(strReportType.equals("2")){
	strReportName = "Report for Date";
	strReportValue = strDateFrom +" - "+strDateTo;
}
else if(strReportType.equals("3") && strMonthOf.length() > 0){
	strReportName = "Monthly Report for";
	strReportValue = astrConvertMonth[iMonth]+", "+strYearOf;
}
else if(strReportType.equals("4")){
	strReportName = "Yearly report for Year";
	strReportValue = strYearOf;
}
else if(strReportType.equals("5") && strSemester.length() > 0){
	strReportName = "Semestral report for";
	strReportValue = astrConvertTerm[Integer.parseInt(strSemester)]+", "+strSYFrom;
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
if(bolBySubjectArea){	
	if(WI.fillTextValue("is_lc").length() == 0) {	
		vRowDetail.addElement("000 - 099");vRowDetail.addElement("0");
		vRowDetail.addElement("100 - 199");vRowDetail.addElement("1");
		vRowDetail.addElement("200 - 299");vRowDetail.addElement("2");
		vRowDetail.addElement("300 - 399");vRowDetail.addElement("3");
		vRowDetail.addElement("400 - 499");vRowDetail.addElement("4");
		vRowDetail.addElement("500 - 599");vRowDetail.addElement("5");
		vRowDetail.addElement("600 - 699");vRowDetail.addElement("6");
		vRowDetail.addElement("700 - 799");vRowDetail.addElement("7");
		vRowDetail.addElement("800 - 899");vRowDetail.addElement("8");
		vRowDetail.addElement("900 - 999");vRowDetail.addElement("9");
	}
	else {//get LC 
		strTemp = "select LC_GEN_CODE, LC_INT from LMS_DDC_GEN_CATG where is_valid = 1 and lc_gen_code is not null order by LC_GEN_CODE";
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()) {
			vRowDetail.addElement(rs.getString(1));// LC Code - A
			vRowDetail.addElement(rs.getString(2));//LC INT - 1
		}
		rs.close();
	}
}else{
	strTemp = "select location,book_loc_index from lms_book_loc where exists "+
 		" (select * from lms_lc_main where book_loc_index = lms_book_loc.book_loc_index) "+
	 	" order by location";
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vRowDetail.addElement(rs.getString(1));// LC Code - A
		vRowDetail.addElement(rs.getString(2));//LC INT - 1
	}
	rs.close();

}



%>
<body topmargin="0" bottommargin="0">
<form action="./circ_by_collection_section_by_subject_area_view.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
	<tr> 
	<%
	strTemp = "SUBJECT AREA";
	if(bolByCollSection)
		strTemp = "COLLECTION SECTION";
	%>
		<td height="25" colspan="5"><div align="center"><strong>:::: CIRCULATION : REPORTS : CIRCULATION BY BORROWERS GROUP BY <%=strTemp%> ::::</strong></div></td>
	</tr>
	<tr> 
		<td width="6%" height="25">&nbsp;</td>
		<td colspan="4"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
	</tr>
</table>



<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
<%if(!bolIsGrandTotal){%>
	<tr>
		<td height="25" width="6%"></td>
		<%
		strTemp = "BORROWERS GROUP";
		if(bolDDCLCCode)
			strTemp = "SUBJECT GROUP";
		%>
		<td width="17%"><%=strTemp%> </td>
		<%
		String strTemp2 = null;
		if(!bolDDCLCCode){
			strTemp = "select c_name from college where c_index = "+strCollegeIndex;
			strTemp2 = dbOP.getResultOfAQuery(strTemp, 0);
		}
		%>
		<td>&nbsp;: <strong><%=WI.getStrValue(strCollegeCode)%><%=WI.getStrValue(strTemp2, " - ","","")%></strong></td>
	</tr>
<%}%>	
	
<%if(WI.getStrValue(strCollegeIndex).length() > 0 && !bolDDCLCCode){%>	
	<tr>
		<td height="25" width="6%"></td>
		<td width="17%">DEPARTMENT : </td>
		<%
		strTemp = WI.fillTextValue("department");
		strErrMsg = " from course_offered where is_valid =1 and is_offered = 1 and c_index ="+strCollegeIndex+" order by course_name";
		%>
		<td>&nbsp; 
			<select name="department" onChange="document.form_._search.value = ''; document.form_.submit();">			
				<option value="">Select Any</option>
				<%=dbOP.loadCombo("course_index", "course_name", strErrMsg, strTemp, false)%>
			</select>		</td>
	</tr>
<%}%>
<%
		int iIndexOf = vRowDetail.indexOf(strSubArea);
		if(iIndexOf != -1){
			if(bolBySubjectArea){
%>
	<tr>
		<td height="25" width="6%"></td>
		<td width="17%">SUBJECT AREA : </td>
		
		<td>&nbsp;: <%=WI.getStrValue((String)vRowDetail.elementAt(iIndexOf - 1))%></td>
	</tr>
	<%}else{%>
	<tr>
	   <td height="25" width="6%"></td>
	   <td width="17%">COLLECTION SECTION</td>
	   <td>&nbsp;: <%=WI.getStrValue((String)vRowDetail.elementAt(iIndexOf - 1))%></td>
	   </tr>
	<%}
}%>



	<tr>
		<td height="25" width="6%"></td>
		<td width="17%"><%=WI.getStrValue(strReportName).toUpperCase()%></td>		
	   <td>&nbsp;: <%=WI.getStrValue(strReportValue)%></td>
	</tr>
	<tr><td colspan="3" height="15">&nbsp;</td></tr>
	<tr>
		<td height="25" width="6%"></td>
		<td colspan="2">
		&nbsp; &nbsp; &nbsp; 
		<a href="javascript:Search();"><img src="../../images/form_proceed.gif" border="0"></a>		
		<font size="1">Click to search by department</font>		</td>		
	</tr>
</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<%if(WI.fillTextValue("department_name").length() > 0){%><tr><td align="center">DEPARTMENT OF <%=WI.getStrValue(WI.fillTextValue("department_name"))%></td></tr><%}%>
	<%
	strTemp = "TOTAL COUNT";
	if(bolIsGrandTotal)
		strTemp = "GRAND TOTAL";		
	%>	
	<tr><td align="center"><%=strTemp%> : <strong><%=WI.getStrValue(strCount)%></strong></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="5%" align="center" class="thinborder" height="20">Count</td>
		<td width="20%" class="thinborder">ID Number</td>
		<td width="38%" class="thinborder">Student Name</td>
		<td width="24%" class="thinborder">Course & Year / Patron Type</td>
		<td width="13%" align="center" class="thinborder">No. of book(s) borrowed</td>
	</tr>
	
	<%
	int iCount = 1;
	int iBorrowTotal = 0;
	for(int i = 0; i < vRetResult.size(); i+=5){
		iBorrowTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+4),"0"));
	%>
	<tr>
		<td align="center" class="thinborder"><%=iCount++%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+3),"- ","","")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>
	</tr>
	<%}%>

	<tr>
		<td class="thinborder" colspan="4" align="right" height="25"><strong>Total Borrowed :</strong> &nbsp; &nbsp; </td>
		<td class="thinborder"><strong><%=iBorrowTotal%></strong></td>
	</tr>
</table>



<%}%>







  

<input type="hidden" name="_search">	
<input type="hidden" name="date_fr" value="<%=strDateFrom%>">	
<input type="hidden" name="date_to" value="<%=strDateTo%>">	
<input type="hidden" name="year_of" value="<%=strYearOf%>">	
<input type="hidden" name="month_of" value="<%=strMonthOf%>">	
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">	
<input type="hidden" name="semester" value="<%=strSemester%>">

<input type="hidden" name="is_lc" value="<%=WI.fillTextValue("is_lc")%>">
<input type="hidden" name="is_total" value="<%=WI.fillTextValue("is_total")%>">

<input type="hidden" name="by_subject_area" value="<%=WI.fillTextValue("by_subject_area")%>">
<input type="hidden" name="by_collection_section" value="<%=WI.fillTextValue("by_collection_section")%>">

<input type="hidden" name="ddc_lc_code" value="<%=WI.fillTextValue("ddc_lc_code")%>">
<input type="hidden" name="group_yearly" value="<%=WI.fillTextValue("group_yearly")%>">
<input type="hidden" name="group_monthly" value="<%=WI.fillTextValue("group_monthly")%>">


<input type="hidden" name="report_type" value="<%=strReportType%>">	
<input type="hidden" name="c_index" value="<%=strCollegeIndex%>" >
<input type="hidden" name="c_code" value="<%=strCollegeCode%>" >	
<input type="hidden" name="subject_area" value="<%=strSubArea%>" >	

<input type="hidden" name="department_name" value="<%=WI.fillTextValue("department_name")%>" />


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>