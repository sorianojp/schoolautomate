<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
   /* TABLE.thinborder {
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
    }*/

-->
</style>
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript">

function DisplayDownload(){
	document.getElementById('display_download').style.visibility = "visible";
	document.getElementById('display_download').style.display = "block";
}

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
	var rowCount = document.getElementById("myADTable1").rows.length;
	
	if(rowCount > 0){
		if(!confirm("Click OK to print."))
			return;
		
		document.bgColor = "#FFFFFF";
		
		for(var i = 0; i < rowCount; i++)
			document.getElementById("myADTable1").deleteRow(0);
				
		window.print();
	}

	/*document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.*/
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
	//boolean bolShowChed = WI.fillTextValue("ched").equals("1");
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

String strExcelFileName = null;

boolean bolForSerialNo = false;
if(WI.fillTextValue("for_serialno").length() > 0) 
	bolForSerialNo = true;
	
boolean bolShowData = (WI.fillTextValue("print_excel").length() == 0);

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};

if(WI.fillTextValue("sy_from").length() > 0) {
	ReportRegistrar rR = new ReportRegistrar();
	vRetResult = rR.nstpGraduatePHILCST(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rR.getErrMsg();
	else{
		strTemp = "NSTP GRADUATES ";
		if(bolForSerialNo)
			strTemp += "for Serial Number ";
			
		strExcelFileName = strTemp+astrConvertSem[Integer.parseInt(request.getParameter("semester"))]+
			","+request.getParameter("sy_from")+"-"+request.getParameter("sy_to");
	}
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsUB   = strSchCode.startsWith("UB");



String strNSTPComponent = "";
if(strErrMsg != null){%>
<table width="100%" border="0" >
    <tr>
      <td width="100%" style="font-size:14px; font-weight:bold; color:#FF0000"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
 <%if(strSchCode.startsWith("UL")){%>
    <tr>
        <td></td>
        <td>&nbsp;</td>
        <td>
		<font style="font-size:9px; font-weight:bold; color:#0000FF">
			   <input type="checkbox" name="print_excel" value="checked" <%=WI.fillTextValue("print_excel")%>> Click to create excel file		   </font>
		</td>
        <td>&nbsp;</td>
    </tr>
<%}%>
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
			   <input type="checkbox" name="restrict_sem" value="checked" <%=WI.fillTextValue("restrict_sem")%>> Restrict to Selected Term		   </font>
		<%}%>	   </td>
	  <td width="23%">
	  <%
	  if(vRetResult != null && vRetResult.size() > 0)
	  if(!bolShowData){
	  strTemp = "../../../../download/"+strExcelFileName+"_"+WI.getTodaysDate()+".xls";
		%>
		<div id="display_download" style="visibility:hidden; display:none;"><a href="<%=strTemp%>"><img src="../../../../images/download.gif" border="0"></a>Click to download excel file</div><%}else{%>
	  <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> <font size="1">Print Report</font>
	  <%}%>
	  </td>
    </tr>

    <tr>
      <td></td>
      <td>Prepared By: </td>
      <td><input type="text" name="prepared_by" value="<%=WI.fillTextValue("prepared_by")%>"></td>
	  <td>
	  
	  </td>
    </tr>
	<tr>
      <td></td>
      <td>Certified Correct: </td>
      <td><input type="text" name="certified_correct" value="<%=WI.fillTextValue("certified_correct")%>"></td>
    </tr>

<%if(strSchCode.startsWith("PHILCST") || strSchCode.startsWith("UL") || strSchCode.startsWith("HTC")){%>
    <tr>
      <td></td>
      <td>NSTP Component</td>
      <td style="color:blue; font-weight:bold">
	  <select name="nstp_component">
	  	<option value="">All</option>
<%
strNSTPComponent = "All";

strTemp = WI.fillTextValue("nstp_component");
if(strTemp.equals("CWTS")) {
	strErrMsg = " selected";
	strNSTPComponent = "CWTS";
}
else	
	strErrMsg = "";
%>
	  	<option value="CWTS">CWTS</option>
<%
if(strTemp.equals("LTS")) {
	strErrMsg = " selected";
	strNSTPComponent = "LTS";
}
else	
	strErrMsg = "";
%>
	  	<option value="LTS"<%=strErrMsg%>>LTS</option>
<%
if(strTemp.equals("ROTC")) {
	strErrMsg = " selected";
	strNSTPComponent = "ROTC";
}
else	
	strErrMsg = "";
%>
	  	<option value="ROTC">ROTC</option>
	  </select>
	  
	  <!--<input type="checkbox" name="hide_spcol" value="checked" <%=WI.fillTextValue("hide_spcol")%>> Hide Specialized column 
	  &nbsp;&nbsp;&nbsp;
	  -->
	  <%if(strSchCode.startsWith("PHILCST") || strSchCode.startsWith("UL") || strSchCode.startsWith("HTC")){%>
	  	<input type="checkbox" name="for_serialno" value="checked" <%=WI.fillTextValue("for_serialno")%>> For Serial Number
	  <%}%>	  </td>
      <td>&nbsp;</td>
    </tr>
<%}%>
 </table>
<%

utility.CreateExcelSheet ces = new utility.CreateExcelSheet();

int iPageCount = 0;
if(vRetResult != null && vRetResult.size() > 0) {

ces.dontCreateFile(bolShowData);
ces.createFile(dbOP, request, strExcelFileName);	
ces.createNewSheet(strExcelFileName);

int iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("no_of_stud"));
int iStudPrinted = 0;
int iTotalStud = vRetResult.size()/12;
int iStudCount = 1;
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud %iNoOfStudPerPage > 0)
	++iTotalPageCount;

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

else if(strSchCode.startsWith("UL")) {
	strSchoolName = "University Of Luzon";
	strRegion = "I";
	strSchoolAddr = "Perez Blvd. Dagupan City, Pangasinan";
	//strRegistrarName = "Mrs. Gina Elena F. Gironella, MST";
	//strRegistrarDesignation = "University Registrar";
}
else if(strSchCode.startsWith("HTC")) {
	strSchoolName = "Holy Trinity College of General Santos City";
	strRegion = "XII";
	strSchoolAddr = "Fiscal Daproza Avenue, General Santos City";
}

int iXlsColSpan = 11;



for(int i=0; i<vRetResult.size();){ // start of the biggest for loop
//strDispPageNo = Integer.toString(iPageCount)+" of "+Integer.toString(iTotalPageCount);
++iPageCount;
iStudPrinted = 0;
if(iPageCount > 1) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}

if(i > 0 && !bolShowData)//do not create the headers on the succeeding pages, continue in excel
	ces.dontCreateFile(true);

ces.setBorder(0);
ces.setAlignment(1);
if(i > 0){
	ces.addData(null, true, iXlsColSpan);
	ces.addData(null, true, iXlsColSpan);
}

ces.addData("Republic of the Philippines", true, iXlsColSpan);
ces.addData("Office of the President", true, iXlsColSpan);
ces.addData("COMMISION ON HIGHER EDUCATION", true, iXlsColSpan);
if(!bolForSerialNo){
	ces.addData("Office of Student Services", true, iXlsColSpan);
	ces.setAlignment(2);
	ces.addData("SASD-NSTP Form 2-B", true, iXlsColSpan);
}else{
	ces.addData(null, true, iXlsColSpan);
	ces.addData("LIST OF NSTP GRADUATES FOR SERIAL NUMBER", true, iXlsColSpan);
	strTemp = astrConvertSem[Integer.parseInt(request.getParameter("semester"))]+
		", Academic Year "+request.getParameter("sy_from")+"-"+request.getParameter("sy_to");
	ces.addData(strTemp, true, iXlsColSpan);
}
ces.setAlignment(1);
ces.addData(null, true, iXlsColSpan);

%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
		<td width="14%" align="center">&nbsp;</td>
      <td colspan="2" align="center">
	  	Republic of the Philippines<br>
		Office of the President<br>
		COMMISION ON HIGHER EDUCATION<br>
		<%if(!bolForSerialNo){%>Office of Student Services<br><%}else{%>
		<br><br>LIST OF NSTP GRADUATES FOR SERIAL NUMBER<br>
		<%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>, Academic Year <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%><br>
		<%}%>
		&nbsp;	  </td>
      
      <td align="center"><%if(!bolForSerialNo){%><em>SASD-NSTP Form 2-B</em><%}%></td>
    </tr>
<%
ces.setBorder(0);
ces.setAlignment(0);
strTemp = "Name of ";
if(strSchCode.startsWith("PHILCST") || strSchCode.startsWith("UL"))
	strTemp += "HEI :";
else
	strTemp += "Institution :";
	
ces.addData(strTemp, false, 2);
ces.addData(strSchoolName, false, 5);
ces.addData("Region :", false);
ces.addData(strRegion, true, 1);

ces.addData("Address :", false, 2);
ces.addData(strSchoolAddr, false, 5);
ces.addData("NSTP Component :", false);
ces.addData(strNSTPComponent, true, 1);
ces.addData(null, true, iXlsColSpan);
%>
    <tr>
      <td style="font-size:14px;" valign="bottom">Name of <%if(strSchCode.startsWith("PHILCST") || strSchCode.startsWith("UL")) {%>HEI<%}else{%>Institution<%}%>:</td>
	  <td width="50%" style="font-size:14px;" valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=strSchoolName%></div></td>
	  <td width="18%" align="right" valign="bottom" style="font-size:14px;"><em>Region : &nbsp; </em></td>
	  <td width="18%" style="font-size:12px;" valign="bottom">
	  <div style="border-bottom:solid 1px #000000;"><%=strRegion%></div></td>
    </tr>
    <tr>
	  <td style="font-size:12px;" valign="bottom">Address:</td>
	  <td style="font-size:12px;" valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=strSchoolAddr%></div></td>
	  <td style="font-size:12px;" valign="bottom" align="right"><em>NSTP Component : &nbsp; </em></td>
	  <td style="font-size:12px;" valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=strNSTPComponent%></div></td>
    </tr>
    <tr>
      <td colspan="3" style="font-size:12px;">&nbsp;</td>
      <td style="font-size:12px;">&nbsp;</td>
    </tr>
<%if(!bolForSerialNo){
ces.setBorder(0);
ces.setAlignment(1);
ces.addData("LIST OF NSTP GRADUATES", true, iXlsColSpan);
strTemp = astrConvertSem[Integer.parseInt(request.getParameter("semester"))]+
	", Academic Year "+request.getParameter("sy_from")+"-"+request.getParameter("sy_to");
ces.addData(strTemp, true, iXlsColSpan);
%>
    <tr>
      <td colspan="4"><div align="center">
        <strong>LIST OF NSTP GRADUATES <br>
        </strong><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>, Academic Year <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></div>	  </td>
    </tr>
<%}
ces.addData(null, true, iXlsColSpan);
%>
</table>

<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr >
    <td height="18" valign="top">&nbsp;</td>
    <td height="18" valign="top">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">

    <tr style="font-weight:bold" align="center">
	<%

	
	
	ces.setBorder(0);
	ces.setAlignment(1);
	strTemp = "&nbsp;";
	if(!bolForSerialNo)
		strTemp = "No.";
	ces.addData(strTemp);
	ces.addData("Serial No.");
	ces.addData("Surname");
	ces.addData("First Name");
	ces.addData("Middle Name");
	ces.addData("Course/Program");
	ces.addData("Gender");
	ces.addData("Birthdate");
	ces.addData("City Address");
	ces.addData("Provincial Address");
	ces.addData("Contact Number<br>Telephone/ Mobile");
	ces.addData("Email Address", true);
	%>
      <td width="2%" rowspan="2" class="thinborderTOPLEFTBOTTOM"><%=strTemp%></td>
      <td width="8%" height="27" rowspan="2" class="thinborderTOPLEFTBOTTOM">Serial No. </strong></td>
      <td colspan="3" class="thinborderTOPLEFTBOTTOM">Student Name </td>
    <td width="7%" rowspan="2" class="thinborderTOPLEFTBOTTOM">Course/Program</td>
    <td width="5%" rowspan="2" class="thinborderTOPLEFTBOTTOM" style="font-size:11px; font-weight:bold">Gender</td>
    <td width="5%" rowspan="2" class="thinborderTOPLEFTBOTTOM">Birthdate </td>
    <td width="15%" rowspan="2" class="thinborderTOPLEFTBOTTOM" style="font-size:11px; font-weight:bold">City Address </td>
    <td width="8%" rowspan="2" class="thinborderTOPLEFTBOTTOM" style="font-size:11px; font-weight:bold">Provincial Address </td>
    <td width="6%" rowspan="2" class="thinborderTOPLEFTBOTTOM" style="font-size:11px; font-weight:bold">Contact Number<br>Telephone/ Mobile</td>
    <td width="6%" rowspan="2" class="thinborderALL" style="font-size:11px; font-weight:bold">Email Address </td>
    </tr>
    <tr style="font-weight:bold">
      <td width="10%" class="thinborder">Surname </td>
      <td width="10%" class="thinborder">First Name </td>
      <td width="10%" class="thinborder">Middle Name </td>
    </tr>
  <%
ces.dontCreateFile(bolShowData); 
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

ces.setBorder(0);
ces.setAlignment(0);
ces.addData(Integer.toString(iStudCount));
strTemp = null;
if(!bolForSerialNo)
	strTemp = (String)vRetResult.elementAt(i);
ces.setAlignment(1);	
ces.addData(strTemp);
%>
  <tr>
    <td class="thinborder"><%=iStudCount++%></td>
    <td height="22" align="center" class="thinborder">
	<%if(bolForSerialNo) {%>
		&nbsp;
	<%}else{%>
		<label id="sl_no_<%=iStudCount - 1%>" onClick="UpdateSLNumber('sl_no_<%=iStudCount - 1%>','<%=vRetResult.elementAt(i + 14)%>')"><%=WI.getStrValue((String)vRetResult.elementAt(i)," &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")%></label>
	<%}%>	</td>
<%
ces.setAlignment(0);	
ces.addData((String)vRetResult.elementAt(i+4));
ces.addData((String)vRetResult.elementAt(i+2));
ces.addData((String)vRetResult.elementAt(i+3));
ces.addData((String)vRetResult.elementAt(i+13));
ces.addData((String)vRetResult.elementAt(i+7));
ces.addData((String)vRetResult.elementAt(i+5));
ces.addData((String)vRetResult.elementAt(i+8));
ces.addData((String)vRetResult.elementAt(i+9));
ces.addData((String)vRetResult.elementAt(i+10));
ces.addData((String)vRetResult.elementAt(i+11),true);
%>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+13), "&nbsp;")%></td>
    <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;")%></td>
    <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+5), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+9), "&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10), "&nbsp;")%></td>
    <td class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue((String)vRetResult.elementAt(i+11), "&nbsp;")%></td>
  </tr>
  <%}
  
/*ces.setBorder(0);
ces.setAlignment(0);
ces.addData("Sub Total:", false, 1, 1);  
if(!bolForSerialNo){
	ces.addData("Male: "+iMaleSubTotal, false, 2);  
ces.addData(null, false, 2); 
ces.addData("Submitted by", true, 2); 
}else
	ces.addData("Male: "+iMaleSubTotal, true, 2);  


if(i + 12 > vRetResult.size() ) {

}else{
	ces.addData(null, true, iXlsColSpan); 		
	ces.addData(null, true, 7); 	
	ces.setBorderLineStyle(1);
	ces.setBorder(2);
	ces.addData(null, true, 2); 	
}*/


%>

  <tr>
    <td colspan="2" rowspan="2" class="thinborder" align="center"><em>Sub Total:  </em></td>
    <td height="22" colspan="3" class="thinborder"><em>Male:</em> <%=iMaleSubTotal%></td>
    <td align="center" class="thinborderLEFT">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td colspan="4"><%if(!bolForSerialNo){%>Submitted by<%}%></td>
    </tr>
  <tr>
      <td height="22" colspan="3" class="thinborder"><em>Female :</em> <%=iFemaleSubTotal%></td>
      <td align="center" class="thinborderLEFT">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
  </tr>
<%
iMaleSubTotal = 0; iFemaleSubTotal = 0;
if(i + 12 > vRetResult.size() ) {%>
  <tr>
    <td colspan="2" rowspan="2" class="">&nbsp;</td>
    <td rowspan="2" class="thinborder"><em>Grand Total:</em></td>
    <td height="25" class="thinborder">Male</td>
    <td class="thinborder"><%=iMaleTotal%></td>
    <td align="center" class="thinborderLEFT">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td colspan="3" valign="bottom"><%if(!bolForSerialNo){%><div style="border-bottom:solid 1px #000000; width:80%;"><%=WI.fillTextValue("prepared_by")%></div><%}%></td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr>
      <td height="25" class="thinborder">Female</td>
      <td class="thinborder"><%=iFemaleTotal%></td>
      <td align="center" class="thinborderLEFT">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td colspan="3" valign="top"><%if(!bolForSerialNo){%><div style="width:80%; text-align:center;">HEI NSTP Coordinator</div><%}%></td>
      <td align="center">&nbsp;</td>
  </tr>
<%}else{%>
	<tr>
    <td colspan="2" rowspan="2" class="">&nbsp;</td>
    <td rowspan="2">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td colspan="3" valign="bottom"><%if(!bolForSerialNo){%><div style="border-bottom:solid 1px #000000; width:80%;"><%=WI.fillTextValue("prepared_by")%></div><%}%></td>
    <td align="center">&nbsp;</td>
  </tr>
  <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td colspan="3" valign="top"><%if(!bolForSerialNo){%><div style="width:80%; text-align:center;">HEI NSTP Coordinator</div><%}%></td>
      <td align="center">&nbsp;</td>
  </tr>
<%}%>
</table>

<%
if((i + 12) >= vRetResult.size() ) {
if(bolForSerialNo){
%>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="53%"><em>Prepared by:</em></td>
		<td width="47%">Certified Correct:</td>
	</tr>
	<tr>
	    <td height="25" valign="bottom"><%=WI.fillTextValue("prepared_by")%></td>
	    <td valign="bottom"><%=WI.fillTextValue("certified_correct")%>&nbsp;</td>
	    </tr>
	<tr>
		<td>HEI Coordinator</td>
		<td>President/Authorized Representative of HEI</td>
	</tr>
</table>
<%}
}
if(!strSchCode.startsWith("UL")){
%><br>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<%
strTemp = "NSTP - LIST OF NSTP GRADUATES";
if(bolForSerialNo)
	strTemp = "NSTP - List of NSTP Graduates for Serial Number";
%>
	<td width="52%"><em><%=strTemp%></em></td>
	<td width="48%" align="right">Page <%=iPageCount%> of <label id="page_count_<%=iPageCount%>"></label></td>
</tr>
</table>
<%}%>

<!-- introduce page break here -->
<% 
 }//end of for loop..

}//end of if(vRetResult != null . 

if(!bolShowData){
	ces.writeAndClose(request);
%><script>DisplayDownload();</script>
<%}%>

<script>
<%for(int i = 1; i <= iPageCount; i++){%>
	document.getElementById('page_count_<%=i%>').innerHTML = <%=iPageCount%>;
<%}%>
</script>

<input type="hidden" value="<%=WI.fillTextValue("ched")%>" name="ched">
<input type="hidden" value="installDir" name="installDir">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
