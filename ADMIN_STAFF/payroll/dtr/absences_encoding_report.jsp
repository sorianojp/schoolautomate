<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Absences Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage(){	
	document.form_.searchEmployee.value = "";
	this.SubmitOnce('form_');
}
function SearchEmployee(){
	document.form_.searchEmployee.value = "1";
	document.form_.submit();
}
function CheckList() {
	if(document.form_.check_list.checked) {
		document.form_.show_only_deduction.checked = false;
		document.form_.is_summary.checked = false;
	}	
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PReDTRME" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-ENCODE-FACULTY ABSENCES"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
		
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Absences Report","absences_encoding_report.jsp");

	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

Vector vSalaryPeriod 		= null;//detail of salary period.

PReDTRME prEdtrME = new PReDTRME();
Vector vRetResult = null;
if(WI.fillTextValue("searchEmployee").equals("1")) {
	vRetResult = prEdtrME.absenseEncodingReport(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = prEdtrME.getErrMsg();
}


boolean bolSummary = false;
if(WI.fillTextValue("is_summary").length() > 0) 
  bolSummary = true;

String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

boolean bolPrintCheckList = false;
if(WI.fillTextValue("check_list").length() > 0) 
	bolPrintCheckList = true;
	
%>

<body>
<form name="form_" method="post" action="./absences_encoding_report.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td width="100%" height="25" align="center"><strong>:::: ABSENCES REPORT ::::</strong></td>
    </tr>
    <tr> 
      <td height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date Range </td>
      <td height="25">
<%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>	<input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        <%if(!strSchCode.startsWith("VMUF")){%>
		to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  	<%}%>
	  </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%" height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td width="77%" height="25"><select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Office</td>
      <td height="26">
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>
				</label>
				</td>
    </tr>
    
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " onClick="javascript:SearchEmployee();"
			style="font-size:11px; height:26px;border: 1px solid #FF0000;">

			<font size="1">click 
        to display employee list to create.</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"></div></td>
    </tr>
  </table>
<%if(!strSchCode.startsWith("VMUF")){%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable3">
  <tr>
    <td width="3%">&nbsp;</td>
    <td colspan="2"><strong>OPTIONS</strong><font size="1">(for aid in viewing which things an employee lack)</font></td>
    </tr>
<tr>
    <td>&nbsp;</td>
    <td colspan="2"><input name="show_only_deduction" type="checkbox" value="checked" <%=WI.fillTextValue("show_only_deduction")%>>
Show only employees with deduction </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td colspan="2"><input name="is_summary" type="checkbox" value="checked" <%=WI.fillTextValue("is_summary")%>>  Show Summary </td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td width="57%"><input name="check_list" type="checkbox" value="checked" <%=WI.fillTextValue("check_list")%> onClick="CheckList();"> 
      Show Check List </td>
    <td width="40%" align="right">
	<select name="rows_per_page">
<%
int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "30"));
for(int i = 25; i < 100; ++i) {
	if(iDef == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>	
	</select>
	<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>Print Page<%}%>&nbsp;&nbsp;</td>
  </tr>
</table>
<%}else{%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable3">
  <tr><td></td></tr>
  <tr><td></td></tr>
  <tr><td align="right">
  
<input type="hidden" name="check_list" value="checked">
	<select name="rows_per_page">
<%
int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "30"));
for(int i = 25; i < 100; ++i) {
	if(iDef == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>	
	</select>
	<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>Print Page<%}%>&nbsp;&nbsp;
</td></tr></table>
<%}%>


<%if(vRetResult != null && vRetResult.size() > 0) {
int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "30"));
int iTotalPages  = 0;
if(bolPrintCheckList || !bolSummary) {
	iTotalPages = vRetResult.size()/(12 * iRowsPerPage);
	if(vRetResult.size()%(12 * iRowsPerPage) > 0)
		++iTotalPages;
}
else {
	iTotalPages = vRetResult.size()/(4 * iRowsPerPage);
	if(vRetResult.size()%(4 * iRowsPerPage) > 0)
		++iTotalPages;
}
int iCurPage = 0;int i = 0;
while(iTotalPages > iCurPage) {
	if(iCurPage > 0) {//auto print.. %>
		<div style="page-break-after:always">&nbsp;</div><br>
	<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="2" class="thinborderBOTTOM"><div align="center"><strong><%if(bolPrintCheckList){%>ATTENDANCE MONITORING SHEET<%}else{%>LIST OF ABSENCES<%}%></strong></div>
	<div align="right">Page <%=++iCurPage%> of <%=iTotalPages%>&nbsp;&nbsp;&nbsp;</div>
	</td>
  </tr>
  <tr> 
    <td width="57%" height="26">Date of Report : <b><%=WI.fillTextValue("date_fr")%> 
	<%=WI.getStrValue(WI.fillTextValue("date_to"), " to ","","")%></b></td>
    <td width="43%" height="26" align="right">Date and Time Printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>
<%if(bolPrintCheckList || !bolSummary){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td width="20%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">ID Number <br>Employee Name</td>
    <td width="15%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Time : Duration </td>
<%if(bolPrintCheckList){%>
    <td width="10%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Room No. </td>
    <td width="10%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Subject</td>
    <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">On Post </td>
    <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Clean Board </td>
    <td width="5%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">In-Uniform</td>
<%}%>
    <td width="30%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Reason</td>
    </tr>
  <%
String[] astrConvertAMPM = {"AM","PM"};
String[] astrConvertRemark = {"With leave application","Without leave application","Leave Application will be filed later"};	
String[] astrConvertSelection = {"No","Yes","N/A"};
for(; i < vRetResult.size(); i += 12){ if( i > 0 && (i/12) % (iRowsPerPage*iCurPage) == 0) break;%>
  <tr> 
    <td height="25" class="thinborder"><strong style="font-size:10px;"><%=(String)vRetResult.elementAt(i + 1)%></strong><br>
      <%=(String)vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder">
	<%if(!bolSummary){%>
		<%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%><br>
	<%}%>
	<%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
<%if(bolPrintCheckList){%>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 10), "&nbsp;")%></td>
    <td class="thinborder"><%=astrConvertSelection[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%></td>
    <td class="thinborder"><%=astrConvertSelection[Integer.parseInt((String)vRetResult.elementAt(i + 7))]%></td>
    <td class="thinborder"><%=astrConvertSelection[Integer.parseInt((String)vRetResult.elementAt(i + 8))]%></td>
<%}%>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 11), "&nbsp;")%></td>
    </tr>
  <%}%>
</table>
<%}else{%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td width="20%" height="25" class="thinborder"><div align="center"><font size="1"><strong><strong>ID Number </strong></strong></font></div></td>
    <td width="54%" class="thinborder"><div align="center"><font size="1"><strong>Name</strong></font></div></td>
    <td width="26%" class="thinborder"><div align="center"><font size="1"><strong>Duration</strong></font></div></td>
    </tr>
  <%
String[] astrConvertAMPM = {"AM","PM"};
String[] astrConvertRemark = {"With leave application","Without leave application","Leave Application will be filed later"};	
for(; i < vRetResult.size(); i += 4){ if( i > 0 && (i/4) % (iRowsPerPage*iCurPage) == 0) break;%>
  <tr> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "&nbsp;")%></td>
    </tr>
  <%}%>
</table>
<%}//end of printin if it is for checklist or not.. %>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="76%" height="25">Printed By : </td>
    <td width="24%"><%if(bolPrintCheckList){%>Verified By<%}%></td>
  </tr>
  <tr>
    <td height="25" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<u><%=(String)request.getSession(false).getAttribute("first_name")%></u></td>
    <td height="25" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%if(bolPrintCheckList){%><u>Monitoring Head</u><%}%> </td>
  </tr>
</table>
<%}//while iTotalPage > iCurPage.

}//if vRetResult is not null.%> 


  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>