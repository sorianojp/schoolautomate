<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

if(strSchCode.startsWith("PHILCST")){%>
	<jsp:forward page="./nstp_graduate_philcst.jsp" />
<%}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript">
function PrintPg() {
}

function UpdateSpecialized(strInputFieldName, strUserIndex){
	var varSLNo = prompt("Please enter new Specialization : ","");
	if(varSLNo == null || varSLNo == 0)
		return;
	this.dynamicUpdate(strInputFieldName,varSLNo,strUserIndex,"1");
}


function UpdateSLNumber(strInputFieldName, strUserIndex) {
	var varSLNo = prompt("Please enter new SL Number : ","");
	if(varSLNo == null || varSLNo == 0)
		return;
	this.dynamicUpdate(strInputFieldName,varSLNo,strUserIndex,"0");
}
function dynamicUpdate(strInputFieldName, strInputVal, strUserIndex,strSpecialized) {
		var objCOA=document.getElementById(strInputFieldName);

		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result found
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=201&sl_no="+
			escape(strInputVal)+"&user_index="+strUserIndex+"&spl="+strSpecialized;
		this.processRequest(strURL);
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body >
<form name="form_" action="./nstp_graduate.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrar,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean bolShowChed = WI.fillTextValue("ched").equals("1");
	try	{
		dbOP = new DBOperation();
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

Vector vRetResult = null;
	ReportRegistrar rR = new ReportRegistrar();

if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = rR.nstpGraduate(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rR.getErrMsg();
}



if(strErrMsg != null){%>
<table width="100%" border="0" >
    <tr>
      <td width="100%" style="font-size:14px; font-weight:bold; color:#FF0000"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%}

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td width="3%"></td>
      <td width="13%">SY/Term</td>
      <td width="61%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>
        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
       &nbsp; - &nbsp;
	   <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
	   &nbsp;&nbsp;&nbsp;
	   <input name="Submit" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" value="Proceed">
	   <select name="no_of_stud" style="font-size:9px">
<%
int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("no_of_stud"), "15"));
for(int i = 15; i < 50; ++i){
	if(i == iDefVal)
		strTemp = " selected";
	else
		strTemp = "";
%>
         <option value="<%=i%>"<%=strTemp%>><%=i%></option>
<%}%>
       </select>
	   <font style="font-size:9px; font-weight:bold; color:#0000FF">
		   <input type="checkbox" name="restrict_sem" value="checked" <%=WI.fillTextValue("restrict_sem")%>> Restrict to Selected Term
	   </font>
	   
	   </td>
	  <td width="23%"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> <font size="1">Print Report</font></td>
    </tr>
<%if(bolShowChed){%>
    <tr>
      <td></td>
      <td>&nbsp;</td>
      <td style="color:blue; font-weight:bold"><input type="checkbox" name="hide_spcol" value="checked" <%=WI.fillTextValue("hide_spcol")%>>
	  Hide Specialized column </td>
      <td>&nbsp;</td>
    </tr>
<%}%>
 </table>
<%if(vRetResult != null && vRetResult.size() > 0) {
Vector vStudCourseInfo   = rR.getInternshipInfo();//i save course and specialized_dim there.. 
String strCourseCode = null;
int iIndexOf = 0;


boolean bolShowPageBreak = false;
int iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("no_of_stud"));
int iStudPrinted = 0;
int iTotalStud = vRetResult.size()/12;
int iStudCount = 1;
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud %iNoOfStudPerPage > 0)
	++iTotalPageCount;
int iPageCount = 1;
String strDispPageNo = null;


for(int i=0; i<vRetResult.size();){ // start of the biggest for loop
strDispPageNo = Integer.toString(iPageCount)+" of "+Integer.toString(iTotalPageCount);
++iPageCount;
iStudPrinted = 0;

if (!bolShowChed){
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		  <br>
		  <%=SchoolInformation.getAddressLine3(dbOP,false,false)%><br>
		  <%=SchoolInformation.getInfo2(dbOP,false,false)%>
		  </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center">
        <strong>NSTP-CWTS Graduate<br>
        </strong><!--
		<%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,--> SY
		<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></div></td>
    </tr>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="18" valign="top">&nbsp;</td>
    <td height="18" valign="top">&nbsp;</td>
  </tr>
  <tr >
    <td height="20"  colspan="2">Region NCR</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC" class="thinborder">

    <tr>
      <td width="3%" align="center" class="thinborder" style="font-size:11px; font-weight:bold">SL #</td>
      <td width="10%" height="27" align="center" class="thinborder"><strong>Serial Number </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>Student No </strong></td>
    <td width="20%" align="center" class="thinborder"><strong>Name</strong></td>
    <td width="5%" align="center" class="thinborder"><strong>Course</strong></td>
    <td width="10%" align="center" class="thinborder"><strong>Higher Education Institution </strong></td>
    <td width="4%" align="center" class="thinborder"><strong>Year Level </strong></td>
    <td width="5%" align="center" class="thinborder"><strong>Birth Date </strong></td>
    <td width="4%" align="center" class="thinborder"><strong>Age</strong></td>
    <td width="4%" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Gender</td>
    <td width="18%" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Address</td>
    <td width="7%" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Tel. No </td>
  </tr>
  <%
for(;i<vRetResult.size();){
if(iStudPrinted++ == iNoOfStudPerPage) {
	bolShowPageBreak = true;
	break;
}
else {
	bolShowPageBreak = false;
}


strCourseCode = null;

iIndexOf = vStudCourseInfo.indexOf(vRetResult.elementAt(i+1));
if(iIndexOf > -1) {
	strCourseCode     = (String)vStudCourseInfo.elementAt(iIndexOf + 1);
	vStudCourseInfo.remove(iIndexOf);vStudCourseInfo.remove(iIndexOf);vStudCourseInfo.remove(iIndexOf);
}

%>
  <tr>
    <td class="thinborder"><%=iStudCount++%></td>
    <td height="25" align="center" class="thinborder"><label id="sl_no_<%=iStudCount - 1%>" onClick="UpdateSLNumber('sl_no_<%=iStudCount - 1%>','<%=vRetResult.elementAt(i + 8)%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i)," &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue(strCourseCode, "BSN")%></td>
    <td class="thinborder" align="center">CGHCNLA</td>
    <td align="center" class="thinborder">1</td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;")%></td>
    <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "&nbsp;")%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;")%></td>
  </tr>
  <%
i = i+12;
}%>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="3%" height="18">&nbsp;</td>
    <td width="73%" valign="top">Certified Correct By : <br><br>
	<%=CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)%><br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Registrar<br>
	<%=WI.getTodaysDate(6)%>

	</td>
    <td width="24%" valign="top"><div align="right">page <strong><%=strDispPageNo%></strong></div></td>
  </tr>
</table>
<!-- introduce page break here -->
<% if(bolShowPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//do not print for last page.
 } else {

 %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		  <br>
		  <%=SchoolInformation.getAddressLine3(dbOP,false,false)%><br>
		  <%=SchoolInformation.getInfo2(dbOP,false,false)%>
		  </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center">
        <strong>List of NSTP-CWTS Graduates<br>
        </strong><!--
		<%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>,--> SY
		<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></div></td>
    </tr>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="18" valign="top">&nbsp;</td>
    <td height="18" valign="top">&nbsp;</td>
  </tr>
  <tr >
    <td height="20"  colspan="2">Region NCR</td>
  </tr>
</table>
<%
boolean bolHideSpecializedCol = WI.fillTextValue("hide_spcol").equals("checked");
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC" class="thinborder">

    <tr>
      <td width="4%" rowspan="2" align="center" class="thinborder" style="font-size:11px; font-weight:bold">SL #</td>
      <td width="10%" height="27" rowspan="2" align="center" class="thinborder"><strong>Serial Number </strong></td>
      <td width="20%" rowspan="2" align="center" class="thinborder"><strong>Name</strong></td>
    <td width="5%" rowspan="2" align="center" class="thinborder"><strong>Course</strong></td>
    <td width="5%" rowspan="2" align="center" class="thinborder"><strong>Birthdate </strong></td>
    <td width="5%" rowspan="2" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Gender</td>
    <td width="2%" rowspan="2" align="center" class="thinborder"><strong>Age</strong></td>
    <td width="19%" rowspan="2" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Address</td>
    <td width="9%" rowspan="2" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Tel. No </td>
    <td colspan="2" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Grade</td>
    <%if(!bolHideSpecializedCol){%>
		<td width="15%" rowspan="2" align="center" class="thinborder" style="font-size:11px; font-weight:bold">Specialized<br>(Based on Dimensions) </td>
    <%}%>
	</tr>
    <tr>
      <td width="2%" align="center" class="thinborder" style="font-size:11px; font-weight:bold">1st</td>
      <td width="4%" align="center" class="thinborder" style="font-size:11px; font-weight:bold">2nd</td>
    </tr>
  <%
for(;i<vRetResult.size();){
if(iStudPrinted++ == iNoOfStudPerPage) {
	bolShowPageBreak = true;
	break;
}
else {
	bolShowPageBreak = false;
}

strCourseCode = null;

iIndexOf = vStudCourseInfo.indexOf(vRetResult.elementAt(i+1));
if(iIndexOf > -1) {
	strCourseCode     = (String)vStudCourseInfo.elementAt(iIndexOf + 1);
	vStudCourseInfo.remove(iIndexOf);vStudCourseInfo.remove(iIndexOf);vStudCourseInfo.remove(iIndexOf);
}
%>
  <tr>
    <td class="thinborder"><%=iStudCount++%></td>
    <td height="25" align="center" class="thinborder"><label id="sl_no_<%=iStudCount - 1%>" onClick="UpdateSLNumber('sl_no_<%=iStudCount - 1%>','<%=vRetResult.elementAt(i + 8)%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i)," &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue(strCourseCode, "BSN")%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
    <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "&nbsp;")%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;")%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10), "&nbsp;")%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11), "&nbsp;")%></td>
    <%if(!bolHideSpecializedCol){%>
	    <td align="center" class="thinborder"><label id="spl_no_<%=iStudCount - 1%>" onClick="UpdateSpecialized('spl_no_<%=iStudCount - 1%>','<%=vRetResult.elementAt(i + 8)%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i+9)," &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></label></td>
    <%}%>
	</tr>
  <%
i = i+12;
}%>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="3%" height="18">&nbsp;</td>
    <td width="73%" valign="top">Certified Correct By : <br><br>
	<%=CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)%><br>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Registrar<br>
	<%=WI.getTodaysDate(6)%>

	</td>
    <td width="24%" valign="top"><div align="right">page <strong><%=strDispPageNo%></strong></div></td>
  </tr>
</table>
<!-- introduce page break here -->
<% if(bolShowPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//do not print for last page.

  } // end if else bolShowChed
 }//end of for loop..

}//end of if(vRetResult != null . %>


<input type="hidden" value="<%=WI.fillTextValue("ched")%>" name="ched">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
