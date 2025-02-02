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
	document.getElementById('myADTable1').deleteRow(0);
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body >
<form name="form_" action="./nstp_graduate_philcst.jsp" method="post">
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

if(WI.fillTextValue("sy_from").length() > 0) {
	ReportRegistrar rR = new ReportRegistrar();
	vRetResult = rR.nstpGraduatePHILCST(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rR.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
boolean bolIsUB   = strSchCode.startsWith("UB");

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
	   <%if(!strSchCode.startsWith("UC")){%>
		   <font style="font-size:9px; font-weight:bold; color:#0000FF">
			   <input type="checkbox" name="restrict_sem" value="checked" <%=WI.fillTextValue("restrict_sem")%>> Restrict to Selected Term
		   </font>
		<%}%>
	   </td>
	  <td width="23%"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> <font size="1">Print Report</font></td>
    </tr>

    <tr>
      <td></td>
      <td>Prepared By: </td>
      <td><input type="text" name="prepared_by" value="<%=WI.fillTextValue("prepared_by")%>"></td>
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

int iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("no_of_stud"));
int iStudPrinted = 0;
int iTotalStud = vRetResult.size()/12;
int iStudCount = 1;
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud %iNoOfStudPerPage > 0)
	++iTotalPageCount;
int iPageCount = 0;
String strDispPageNo = null;

int iMaleSubTotal = 0;
int iFemaleSubTotal = 0;

int iMaleTotal = 0;
int iFemaleTotal = 0;

String strSchoolName = null;
String strRegion = null;
String strSchoolAddr = null;
String strRegistrarName = null;//
String strRegistrarDesignation = null;

if(bolIsUB) {
	strSchoolName = "University of Bohol";
	strRegion = "VII";
	strSchoolAddr = "Maria Clara Street, Tagbilaran City, Bohol";
	strRegistrarName = CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase();
	strRegistrarDesignation = "University Registrar";
}
else if(strSchCode.startsWith("UC")) {
	strSchoolName = "University of the Cordilleras";
	strRegion = "CAR";
	strSchoolAddr = "Governor Pack Road, Baguio City Philippines 2600";
	strRegistrarName = CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7).toUpperCase();
	strRegistrarDesignation = "Registrar";
}
else if(strSchCode.startsWith("PHILCST")) {
	strSchoolName = "Philippine College of Science and Technology";
	strRegion = "I";
	strSchoolAddr = "Nalsian Calasiao, Pangasinan";
	strRegistrarName = "Mrs. Gina Elena F. Gironella, MST";
	strRegistrarDesignation = "College Registrar";
}

for(int i=0; i<vRetResult.size();){ // start of the biggest for loop
strDispPageNo = Integer.toString(iPageCount)+" of "+Integer.toString(iTotalPageCount);
++iPageCount;
iStudPrinted = 0;
if(iPageCount > 1) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td colspan="2" align="center">
	  	Republic of the Philippines<br>
		Office of the President<br>
		COMMISION ON HIGHER EDUCATION<br>
		Office of Student Services<br>
		&nbsp;	  </td>
    </tr>
    <tr>
      <td width="78%" style="font-size:14px;">Name of Institution: 	<%=strSchoolName%></td>
	  <td width="22%" style="font-size:12px;">Region:<u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=strRegion%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
    </tr>
    <tr>
	  <td style="font-size:12px;">Address:    <%=strSchoolAddr%></td>
	  <td style="font-size:12px;">NSTP Component:</td>
    </tr>
    <tr>
      <td style="font-size:12px;">&nbsp;</td>
      <td style="font-size:12px;">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2"><div align="center">
        <strong>LIST OF NSTP GRADUATES <br>
        </strong><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>, School Year <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></div>
	  </td>
    </tr>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="18" valign="top">&nbsp;</td>
    <td height="18" valign="top">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC" class="thinborder">

    <tr style="font-weight:bold" align="center">
      <td width="2%" rowspan="2" class="thinborder">SL #</td>
      <td width="8%" height="27" rowspan="2" class="thinborder">Serial Number </strong></td>
      <td colspan="3" class="thinborder">Student Name </td>
    <td width="7%" rowspan="2" class="thinborder">Course</td>
    <td width="5%" rowspan="2" class="thinborder" style="font-size:11px; font-weight:bold">Gender</td>
    <td width="5%" rowspan="2" class="thinborder">Birth Date </td>
    <td width="15%" rowspan="2" class="thinborder" style="font-size:11px; font-weight:bold">City/Municipal Address </td>
    <td width="8%" rowspan="2" class="thinborder" style="font-size:11px; font-weight:bold">Provincial Address </td>
    <td width="6%" rowspan="2" class="thinborder" style="font-size:11px; font-weight:bold">Contact No. <br>Tel/Mobile  </td>
    <td width="6%" rowspan="2" class="thinborder" style="font-size:11px; font-weight:bold">Email Address </td>
    </tr>
    <tr style="font-weight:bold">
      <td width="10%" class="thinborder">Last Name </td>
      <td width="10%" class="thinborder">First Name </td>
      <td width="10%" class="thinborder">Middle Name </td>
    </tr>
  <%
for(;i<vRetResult.size();i += 15){
	if(iStudPrinted++ == iNoOfStudPerPage)
		break;

if(WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;").startsWith("M")) {
	++iMaleSubTotal;
	++iMaleTotal;
}
else {
	++iFemaleSubTotal;
	++iFemaleTotal;
}

%>
  <tr>
    <td class="thinborder"><%=iStudCount++%></td>
    <td height="25" align="center" class="thinborder"><label id="sl_no_<%=iStudCount - 1%>" onClick="UpdateSLNumber('sl_no_<%=iStudCount - 1%>','<%=vRetResult.elementAt(i + 14)%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i)," &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></label></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+13), "&nbsp;")%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;")%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+5), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+9), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11), "&nbsp;")%></td>
  </tr>
  <%}%>

  <tr>
    <td height="25" colspan="2" class="thinborder">Sub Total:  </td>
    <td class="thinborder">Male: <%=iMaleSubTotal%><br>Female: <%=iFemaleSubTotal%></td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
  </tr>
<%
iMaleSubTotal = 0; iFemaleSubTotal = 0;
if((i + 12) >= vRetResult.size() ) {%>
  <tr>
    <td height="25" colspan="2" class="thinborder">Grand Total:  </td>
    <td class="thinborder">Male: <%=iMaleTotal%><br>Female: <%=iFemaleTotal%></td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td align="center" class="thinborder">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
    <td class="thinborder" align="center">&nbsp;</td>
  </tr>
<%}%>

</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr valign="bottom">
    <td width="2%" height="25">&nbsp;</td>
    <td width="57%">Prepared By: </td>
    <td width="41%"> Certified Correct:</td>
  </tr>
  <tr valign="bottom">
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr valign="bottom" align="center">
    <td height="25">&nbsp;</td>
    <td><u>&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.fillTextValue("prepared_by")%>&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
    <td><u>&nbsp;&nbsp;&nbsp;&nbsp;
		<%=strRegistrarName%>
	&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
  </tr>
  <tr valign="top" align="center">
    <td height="25">&nbsp;</td>
    <td>NSTP Coordinator </td>
    <td><%=strRegistrarDesignation%> </td>
  </tr>
</table>  
<!-- introduce page break here -->
<% 
 }//end of for loop..

}//end of if(vRetResult != null . %>


<input type="hidden" value="<%=WI.fillTextValue("ched")%>" name="ched">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
