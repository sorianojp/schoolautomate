<%@ page language="java" import="utility.*,lms.CirculationReport,enrollment.ReportEnrollment,java.util.Vector" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	window.print();
}
</script>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"LIB_Circulation","collection_usage_summary_new.jsp");
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
ReportEnrollment reportEnrollment = new ReportEnrollment();


Vector vRetResult = null;
Vector vRetResultEnrl = null;
Vector vColumnDetail = null;
Vector vRetResultBorrower = null;

int iCountPerCell = 0;//every cell
int iRowTotal     = 0; 
int iGT           = 0;
int iColTotal[]   = null;  
String strReportType = WI.fillTextValue("report_type");

if(WI.fillTextValue("search").length() > 0) {
		if(WI.fillTextValue("year_of").length() > 0) {
			vRetResult = cReport.collectionUsageSummary(dbOP, request);			
			
			vRetResultEnrl = reportEnrollment.getEnrollmentSummary(dbOP, request, true);
						
			if(vRetResult == null)
				strErrMsg = cReport.getErrMsg();				
				
			vRetResultBorrower = cReport.circulationBorrowerGroupSubjArea(dbOP, request);			
			if(vRetResultBorrower == null)
				strErrMsg = cReport.getErrMsg();
			else	
				vColumnDetail = (Vector)vRetResultBorrower.remove(0);			
		}
}

String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<body topmargin="0" bottommargin="0">
<form action="./collection_usage_summary_new.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td height="25" colspan="5"><div align="center"><strong>:::: CIRCULATION : REPORTS : COLLECTION USAGE SUMMARY PAGE ::::</strong></div></td>
    </tr>
    <tr valign="top">
      <td height="25" colspan="5" style="font-size:13px; font-weight:bold; color:#FF0000"><a href="reports_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>	  </td>
    </tr>
	
	
	<input type="hidden" name="report_type" value="4"/>
	
	
	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">School year </td>
      <td width="22%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td width="5%">Term</td>
      <td width="22%" height="25"><select name="offering_sem">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
          </tr>
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="6%">Year</td>
      <td width="29%">
<%
strTemp = WI.fillTextValue("year_of");
if(strTemp.length() == 0) {
	strTemp = WI.getTodaysDate();
	strTemp = strTemp.substring(0,4);
}%>
	  <input name="year_of" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_of');style.backgroundColor='white'"
		onKeyUp="AllowOnlyInteger('form_','year_of');"></td>
      <td width="10%">Month</td>
      <td width="52%">
	    <select name="month_of">
			<%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="submit" name="1" value="&nbsp; Show Report &nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.search.value='1'"></td>
      <td colspan="2">&nbsp;
	  <%if(strSchCode.startsWith("CLDH")){%>
		<input type="checkbox" name="is_lc" value="checked" <%=WI.fillTextValue("is_lc")%> onClick="document.form_.submit()"> Show LC Format
	  <%}%>
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td></td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print report</font></div></td>
    </tr>
  </table>
<%if(vRetResult != null) {
    Vector vTotCollection      = (Vector)vRetResult.remove(0);
    Vector vTotCirculation     = (Vector)vRetResult.remove(0);
    Vector vYrlyCirculation    = (Vector)vRetResult.remove(0);
    Vector vMonthlyCirculation = (Vector)vRetResult.remove(0);

Vector vRowDetail = new Vector();
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
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vRowDetail.addElement(rs.getString(1));// LC Code - A
		vRowDetail.addElement(rs.getString(2));//LC INT - 1
	}
	rs.close();
}
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="center">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>
	  <br><br>
	  COLLECTION USAGE SUMMARY FOR : <%=astrConvertMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%>, <%=WI.fillTextValue("year_of")%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="17%" height="25" class="thinborder">RANGE</td>
      <td width="23%" class="thinborder">TOTAL COLLECTION</td>
      <td width="20%" class="thinborder">CIRCULATION FREQ. </td>
      <td width="20%" class="thinborder">YEARLY CIRCULATION FREQ </td>
      <td width="20%" class="thinborder">MONTHLY CIRCULATION FREQ. </td>
    </tr>
<%//System.out.println(vTotCollection);
while(vRowDetail.size() > 0) {
strTemp = (String)vRowDetail.remove(1);%>
	<tr>
      <td height="25" align="center" class="thinborder"><%=vRowDetail.remove(0)%></td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals(strTemp)){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals(strTemp)){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals(strTemp)){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals(strTemp)){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
<%}%>





<!-- working for DDC only..
    <tr>
      <td height="25" align="center" class="thinborder">000 - 099</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("0")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("0")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("0")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("0")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
    <tr>
      <td height="25" align="center" class="thinborder">100 - 199</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("1")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("1")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("1")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("1")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
    <tr>
      <td height="25" align="center" class="thinborder">200 - 299</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("2")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("2")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("2")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("2")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
    <tr>
      <td height="25" align="center" class="thinborder">300 - 399</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("3")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("3")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("3")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("3")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
    <tr>
      <td height="25" align="center" class="thinborder">400 - 499</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("4")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("4")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("4")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("4")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
    <tr>
      <td height="25" align="center" class="thinborder">500 - 599</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("5")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("5")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("5")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("5")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
    <tr>
      <td height="25" align="center" class="thinborder">600 - 699</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("6")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("6")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("6")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("6")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
    <tr>
      <td height="25" align="center" class="thinborder">700 - 799</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("7")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("7")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("7")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("7")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
    <tr>
      <td height="25" align="center" class="thinborder">800 - 899</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("8")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("8")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("8")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("8")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>
    <tr>
      <td height="25" align="center" class="thinborder">900 - 999</td>
      <td class="thinborder">&nbsp;<%if(vTotCollection.size() > 1 && vTotCollection.elementAt(1).equals("9")){vTotCollection.remove(1);%><%=vTotCollection.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vTotCirculation.size() > 1 && vTotCirculation.elementAt(1).equals("9")){vTotCirculation.remove(1);%><%=vTotCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vYrlyCirculation.size() > 1 && vYrlyCirculation.elementAt(1).equals("9")){vYrlyCirculation.remove(1);%><%=vYrlyCirculation.remove(1)%><%}else{%>0<%}%></td>
      <td class="thinborder">&nbsp;<%if(vMonthlyCirculation.size() > 1 && vMonthlyCirculation.elementAt(1).equals("9")){vMonthlyCirculation.remove(1);%><%=vMonthlyCirculation.remove(1)%><%}else{%>0<%}%></td>
    </tr>

-->







    <tr style="font-weight:bold">
      <td height="25" class="thinborder">TOTAL</td>
      <td class="thinborder">&nbsp;<%=vTotCollection.remove(0)%></td>
      <td class="thinborder">&nbsp;<%=vTotCirculation.remove(0)%></td>
      <td class="thinborder">&nbsp;<%=vYrlyCirculation.remove(0)%></td>
      <td class="thinborder">&nbsp;<%=vMonthlyCirculation.remove(0)%></td>
    </tr>
  </table>
  <br /><br /><br />
 
  
  
  
  
  
  
  
  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  	<tr><td class="thinborder" height="30" colspan="7" align="center"><font size="2"><strong>Student Utilization Frequency of Use</strong></font></td></tr>
	<tr>
		<td height="20" class="thinborder">College</td>
		<td class="thinborder">Population</td>
		<td class="thinborder"># of Borrower</td>
		<td class="thinborder"># of books used</td>
		<td class="thinborder">% Reach Out</td>
		<td class="thinborder">Ratio</td>
		<td class="thinborder">Daily Average</td>
	</tr>
	
	
	  <%
	  Vector vBorrowerDetail = new Vector();
	  String strCollegeCode = null;
	  String strUserIndex   = null;
	  
	  //THis query is to get the # of borrower for the specified school year
	  strTemp = "select college.c_code,college.c_index,lms_book_issue.user_index from lms_book_issue " +
					"join STUD_CURRICULUM_HIST on (lms_book_issue.user_index = STUD_CURRICULUM_HIST.user_index) " +
					"join course_offered on (course_offered.course_index=STUD_CURRICULUM_HIST.course_index) " +
					"join college on (college.c_index = course_offered.c_index) " +
					"where lms_book_issue.sy_from = "+WI.fillTextValue("sy_from")+" and STUD_CURRICULUM_HIST.sy_from = "+WI.fillTextValue("sy_from") + " " +
					"order by c_code";
	
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	int iCount = 0;
	int iIndexOf = 0;
	while(rs.next()) {
		if(strCollegeCode == null || !strCollegeCode.equals(rs.getString(1))){			
			strCollegeCode = rs.getString(1);
			strUserIndex   = rs.getString(3);	
			iCount = 1;		
			vBorrowerDetail.addElement(strCollegeCode);
			vBorrowerDetail.addElement(rs.getString(2));// c_index
			vBorrowerDetail.addElement(Integer.toString(iCount));// user_index						 
		}else if(strCollegeCode.equals(rs.getString(1)) && !strUserIndex.equals(rs.getString(3))){
			strCollegeCode = rs.getString(1);
			strUserIndex   = rs.getString(3);
						
			iIndexOf = vBorrowerDetail.indexOf(rs.getString(1));			
				if(iIndexOf == -1)
                      continue;			
			iCount += 1;
			vBorrowerDetail.setElementAt(Integer.toString(iCount), iIndexOf + 2);
		}else{			
			continue;
		}		
	}
	//System.out.println("vBorrowerDetail "+vBorrowerDetail);
	rs.close();
	  
	  
  	// I have to keep track of course programs, course, and major.
	String strCourseProgram = null;	
	
	int iSubTotal      = 0; // sub total of a course - major.
	int iSubGrandTotal = 0; //System.out.println(reportEnrollment.avAddlInfo);
	int iGrandTotal    = 0;
	String strRatio    = null;
	String strReachOut = null;
  	String strSubGrandTotal = null;
	
  for(int i = 1 ; i< vRetResultEnrl.size() ;){//outer loop for each course program.
	strCourseProgram = (String)vRetResultEnrl.elementAt(i);	
	iSubGrandTotal = 0;
	
		for(int j = i; j< vRetResultEnrl.size();){//Inner loop for course/major for a course program.
				if(strCourseProgram.compareTo((String)vRetResultEnrl.elementAt(j)) != 0)
					break; //go back to main loop.	
				
				iSubTotal = 0;
				//collect information for each year level for a course/major.
				
					iSubTotal += Integer.parseInt((String)vRetResultEnrl.elementAt(j+5));
					j += 6;	
				
				//yr level not found.. 
				if(iSubTotal == 0) {
					System.out.println("------ Wrong Yr Level in Enrollment Summary ----------");
					System.out.println(" Course Name : "+vRetResultEnrl.elementAt(j+1));
					System.out.println(" strMajorName : "+vRetResultEnrl.elementAt(j+2));
					System.out.println(" Year Level : "+vRetResultEnrl.elementAt(j+3));
					System.out.println(" Gender : "+vRetResultEnrl.elementAt(j+4));
					
					j += 6;
				}
				
				iSubGrandTotal += iSubTotal;
				i = j;	
		}
	iGrandTotal += iSubGrandTotal;
	
	strSubGrandTotal = iSubGrandTotal+".0";
	//loop for the no. of books used.
  	strRatio = "";		  
  	iCountPerCell = 0;
		  for(int q = 0 ; q < vRetResultBorrower.size(); q += 3) {			  
				if(strCourseProgram.equals(vRetResultBorrower.elementAt(q + 1)) ) {
					vRetResultBorrower.remove(q);vRetResultBorrower.remove(q);
					iCountPerCell = Integer.parseInt((String)vRetResultBorrower.remove(q));		
					strRatio = iCountPerCell+".0";			
					strRatio = CommonUtil.formatFloat(Double.parseDouble(strRatio)/Double.parseDouble(strSubGrandTotal),true);
					break;
				}
				else
					strRatio = "0.00";
		  }
			  
	//loop for the no. of borrower		 
		iCount = 0; 
		strReachOut = "";
		
		  for(int q=0 ; q < vBorrowerDetail.size(); q += 3) {		  	
		  		  if(strCourseProgram.equals(vBorrowerDetail.elementAt(q)) ) {
				  		vBorrowerDetail.remove(q);vBorrowerDetail.remove(q);
				  		iCount = Integer.parseInt((String)vBorrowerDetail.remove(q));
						strReachOut = iCount+".0";						
						strReachOut = CommonUtil.formatFloat(((Double.parseDouble(strReachOut)/Double.parseDouble(strSubGrandTotal)) * 100),true);
						break;
				  }else{				  	
					strReachOut = "0.00";
				  }		  
		  }
		  
			  
	%>			  
		  
	
	<tr>
		<td height="20" class="thinborder"><%=strCourseProgram%></td>
		<td class="thinborder"><%=iSubGrandTotal%></td>
		<td class="thinborder"><%=iCount%></td>
		<td class="thinborder"><%if(iCountPerCell > 0){%> <font size="1"><%=iCountPerCell%></font> <%}else{%> - <%}%></td>
		<td class="thinborder"><%=strReachOut%></td>
		<td class="thinborder"><%=strRatio%></td>
		<td class="thinborder">&nbsp;</td>
	</tr>
	
<%}//outer most loop%>	
	<tr>
		<td class="thinborder" height="20">Total</td>
		<td class="thinborder"><%=iGrandTotal%></td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	</tr>
	
  
  </table>
<%}%>

<input type="hidden" name="search">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
