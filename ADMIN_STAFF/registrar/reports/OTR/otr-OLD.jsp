<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transcript of Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateEntranceData() {
	if(document.form_.stud_id.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "../../entrance_data/entrance_data.jsp?stud_id="+document.form_.stud_id.value+
		"&parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateGraduationData() {
	if(document.form_.stud_id.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "../../entrance_data/graduation_data.jsp?stud_id="+document.form_.stud_id.value+
		"&parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function RemovePrintPg() {
	document.form_.add_record.value = "";
	document.form_.print_pg.value = "";
	
	this.SubmitOnce("form_");
}
function PrintPg(strRowStartFr,strRowCount,strLastPage, strPrintStatus,strPageNumber,strMaxRowsToDisp) {
	document.form_.add_record.value = "";

	document.form_.print_pg.value = "1";
	
	document.form_.row_start_fr.value = strRowStartFr;
	document.form_.row_count.value = strRowCount;
	document.form_.last_page.value = strLastPage;
	
	document.form_.print_.value = strPrintStatus;
	document.form_.page_number.value = strPageNumber;
		
	document.form_.max_page_to_disp.value = strMaxRowsToDisp;	
	
	this.SubmitOnce("form_");
}
function AddRecord() {
	document.form_.add_record.value = "1";
	document.form_.print_pg.value = "";
	document.form_.hide_save.src = "../../../../images/blank.gif";

	this.SubmitOnce("form_");
}
function ShowAddlColumn(iIndex) {

	if(iIndex == 1) {
		if(document.form_.show_rle.checked) 
			document.form_.show_leclab.checked = false;
	}else {
		if(document.form_.show_leclab.checked) 
			document.form_.show_rle.checked = false;	
	}
	
}

</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strOTRExtn = null;
	if(strSchCode != null) 
		strOTRExtn = strSchCode.substring(0,strSchCode.indexOf("_"));
if(strOTRExtn != null) {//System.out.println(strOTRExtn);
	if (WI.fillTextValue("honor_point").length() > 0) 
		strOTRExtn = "./otr_print_"+strOTRExtn+"_honor.jsp";
	else
		strOTRExtn = "./otr_print_"+strOTRExtn+".jsp";
if(request.getParameter("print_pg") != null && request.getParameter("print_pg").compareTo("1") ==0){%>
	<jsp:forward page="<%=strOTRExtn%>"/>
<%return;}
}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-OTR - form 9","otr.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"otr.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;
int iPageCount = 0;

String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP, 
			(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0) 
			strErrMsg = studInfo.getErrMsg();
	}	
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	if((vEntranceData == null || vGraduationData == null) && (strErrMsg ==null))
		strErrMsg = entranceGradData.getErrMsg();
		
}

//save encoded information if save is clicked. 
Vector vForm17Info = null;
if(WI.fillTextValue("add_record").compareTo("1") ==0){
	if(repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,1,true) == null)
		strErrMsg = repRegistrar.getErrMsg();
}	
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

if(vStudInfo != null) {//get the grad detail. 
	strDegreeType = (String)vStudInfo.elementAt(15);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType);
	if(vRetResult == null) 
		strErrMsg = repRegistrar.getErrMsg();
}

if (!entranceGradData.updateGraduationData(dbOP)){
	strErrMsg = entranceGradData.getErrMsg();
}

%>
<form action="./otr.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          <%if(WI.fillTextValue("honor_point").compareTo("1") != 0 ){%>
		  OFFICIAL TRANSCRIPT OF RECORD <%}else{%>HONOR STUDENT<%}%> PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="14%">Student ID </td>
      <td width="22%"><input name="stud_id" type="text" class="textbox"  
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=WI.fillTextValue("stud_id")%>"> </td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" border="0"></a></td>
      <td width="51%"><a href="javascript:RemovePrintPg();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0 && vAdditionalInfo != null && vAdditionalInfo.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td colspan="3">Name : <strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,<%=((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Address : <strong><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%> </strong> </td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:UpdateEntranceData();"><img src="../../../../images/update.gif" border="0"></a></div></td>
      <td><font color="#0000FF" size="1">Click to update Entrance Data</font> 
      </td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td colspan="3">Entrance Data : <strong>
        <%if(vEntranceData != null){%>
        <%=astrConvertToDocType[Integer.parseInt((String)vEntranceData.elementAt(8))]%> 
        <%}%>
        </strong> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="17%">Elementary ......</td>
      <td width="71%">
        <%
if(vEntranceData != null)
	strTemp = (String)vEntranceData.elementAt(3);
else	
	strTemp = "";
%>
        <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Secondary &nbsp;......</td>
      <td>
<% if(vEntranceData != null)
	strTemp = (String)vEntranceData.elementAt(5);
else	
	strTemp = "";
%>
        <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="5%"> <font size="1"><font size="2"> </font></font></td>
      <td>College ............</td>
      <td>
        <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(7));
else	
	strTemp = "";
%>
        <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Course : <strong><%=(String)vStudInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Title/Degree :<strong> <%=(String)vStudInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:UpdateGraduationData();"><img src="../../../../images/update.gif" border="0"></a></div></td>
      <td><font color="#0000FF" size="1">Click to update Graduation Data</font> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">CHED Special Order No. </td>
      <td>
        <%
if(vGraduationData != null && vGraduationData.size()!=0)
	strTemp = WI.getStrValue(vGraduationData.elementAt(6));
else	
	strTemp = "";
%>
        <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="2">Date Issued </td>
      <td> 
        <%
if(vGraduationData != null && vGraduationData.size()!=0){
	if (vGraduationData.elementAt(7) != null)
		strTemp = (String)vGraduationData.elementAt(7);
	else
		strTemp = "&nbsp;";
}else{
	strTemp = "&nbsp;";
}
%>
        <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Date of Graduation</td>
      <td>
        <%
if(vGraduationData != null && vGraduationData.size()!=0)
	strTemp = (String)vGraduationData.elementAt(8);
else	
	strTemp = "";
%>
        <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Date Prepared </td>
      <td> 
<%
strTemp = WI.fillTextValue("date_prepared");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="date_prepared" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('specific_fee.date_prepared');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vEntranceData != null){//--removed because student not graduating shud be able to get OTR. && vGraduationData != null){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="27" width="2%">&nbsp;</td>
      <td colspan="2">Report prepared by :</td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="95%"> 1. ) 
        <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(1);
else	
	strTemp = WI.fillTextValue("prep_by1");
%> <input name="prep_by1" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>2. ) 
        <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(2);
else	
	strTemp = WI.fillTextValue("prep_by2");
%> <input name="prep_by2" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Report checked by :</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>1. ) 
        <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(3);
else	
	strTemp = WI.fillTextValue("check_by1");
%> <input name="check_by1" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>2. ) 
        <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(4);
else	
	strTemp = WI.fillTextValue("check_by2");
%> <input name="check_by2" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">University Registrar's Name </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(0);
else	
	strTemp = WI.fillTextValue("registrar_name");
%> <input name="registrar_name" type="text" size="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
	<%if(WI.fillTextValue("honor_point").compareTo("1") == 0) {//only if honor student.%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><strong>
<%
strTemp = WI.fillTextValue("consider_mterm");
if(strTemp.compareTo("1") == 0)
	strTemp = " selected";
else	
	strTemp = "";
%>
        <input type="checkbox" name="consider_mterm" value="1" <%=strTemp%>>
        <font color="#0066CC">Compute Midterm grade if Final grade is not encoded 
        (optional)</font></strong><br><br><br><br></td>
    </tr>
<%} if (WI.fillTextValue("honor_point").length() == 0) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">REMARK (if any). To separate line add &lt;br&gt; tag to 
        the end. To make the line bold write within &lt;b&gt;&lt;/b&gt; tag. Please 
        refer example below<br> &lt;b&gt;GRANTED HONORABLE DISMISSAL ....&lt;/b&gt; 
        &lt;br&gt;&lt;b&gt;Copy for... &lt;/b&gt;&lt;br&gt; Name of the school 
        &lt;br&gt; Address1 of the school &lt;br&gt;Address2 of the school &lt;br&gt;Address3 
        of the school<br>
        --&gt; this will look like<br> <strong>GRANTED HONORABLE DISMISSAL .... 
        <br>
        Copy for... <br>
        </strong>Name of the school <br>
        Address1 of the school<br>
        Address2 of the school<br>
        Address3 of the school</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top"> <textarea name="addl_remark" size="64" class="textbox" cols="90" rows="6"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("addl_remark")%></textarea> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center"><a href="javascript:AddRecord();"><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save/edit encoded Information</td>
    </tr>
    <%if(strSchCode.startsWith("UI")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Number of Weeks : 
        <input name="weeks" type="text" size="4" maxlength="4" class="textbox" value="<%=WI.fillTextValue("weeks")%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onKeyUp = "AllowOnlyInteger('form_','weeks')" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> <%
if(request.getParameter("show_rel") == null && request.getParameter("show_leclab") == null) 
	strTemp = " checked";
else if(WI.fillTextValue("show_rel").compareTo("1") == 0 )
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_rle" value="1" onClick="ShowAddlColumn(1);"<%=strTemp%>> 
        <strong>Show RLE hrs 
        <%
if(strTemp.length() > 0) 
	strTemp = "";
else if(WI.fillTextValue("show_leclab").length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="show_leclab" value="1" onClick="ShowAddlColumn(2);"<%=strTemp%>>
        Show Lec/Lab Hour</strong> <font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(NOTE: 
        RLE hours will be shown only if applicable.)</font></td>
    </tr>
    <%}

} //end check for honor point
if(vRetResult != null && vRetResult.size() > 0){//System.out.println(vRetResult);
//decide here page number.
int iTemp = vRetResult.size() / 11;
iPageCount = 1;
int iRowsPerPage = 30;
int iFirstPageCount = 20;//less lines in first page.
int iMaxRowToDisplay=0;//this is the max page count to display - if it is first page, val = iFirstPageCount, else iRowPerPage.

//for UI, i have to keep page count = 40 and first page count = 28
if(strSchCode != null && strSchCode.startsWith("UI")) {
	iRowsPerPage = 42;
	if (WI.fillTextValue("honor_point").length() == 0)
		iFirstPageCount = 32;
	else	
		iFirstPageCount = 42;
}
if(strSchCode != null && strSchCode.startsWith("VMUF")) {
	iRowsPerPage = 33;
	iFirstPageCount = 32;
}
if(strSchCode != null && strSchCode.startsWith("LNU")) {
	iRowsPerPage = 35;
	iFirstPageCount = 28;
}


iTemp -= iFirstPageCount;
iPageCount += iTemp / iRowsPerPage;
if(iTemp % iRowsPerPage > 0)
	++iPageCount;

int[] iRowsToShow = new int[iPageCount];
int[] iRowStartFrom = new int[iPageCount];
//if there are two pages, i have to findout the page counts here. only if the count is less than 30
iTemp = vRetResult.size() / 11;
//iTemp = 56;
for(int i = 0 ; i < iPageCount; ++i){
	if(i == 0) {
		iRowsToShow[i] = iFirstPageCount;
		iRowStartFrom[i] = 0;
		iTemp -= iFirstPageCount; 
		if(iTemp <= 0) {
			iRowsToShow[i] = iTemp + iFirstPageCount;
			break;
		}//System.out.println(iRowsToShow[i]);System.out.println(iRowStartFrom[i]);
		continue;			
	}
	iRowsToShow[i] = iRowsPerPage;
	iRowStartFrom[i] = iFirstPageCount + iRowsPerPage * (i-1);
	
	iTemp -= iRowsPerPage;
	if(iTemp <= 0) {
		iTemp += iRowsPerPage;
		iRowsToShow[i] = iTemp;//end page.
		break;
	} 
}
//System.out.println(iRowStartFrom[0]+" ,, "+iRowStartFrom[1]+" ,, "+iRowStartFrom[2]);

%>
    <!--    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">Click to print report all information in one page , or 
        select page # below to print individual page.</font></td>
    </tr>-->
    <%
int iLastPage = 0;
for(int i = 1; i <= iPageCount; ++i){
if(i == iPageCount) {
	strTemp = "Print Last Page";
	iLastPage = 1;
	iMaxRowToDisplay = iRowsPerPage;
	if(i == 1)
		iMaxRowToDisplay = iFirstPageCount;
}
else {	
	strTemp = "Print Page "+i;
	iMaxRowToDisplay = iFirstPageCount;
}
//Print page(start pt, no of rows, is last page.
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> <table width="645">
          <tr> 
            <td width="252"> <b><font size="3"> <b> <a href='javascript:PrintPg("<%=iRowStartFrom[i - 1]%>","<%=iRowsToShow[i - 1]%>","<%=iLastPage%>","1","<%=i%>",<%=iMaxRowToDisplay%>);'> 
              <%=strTemp%></a></font></b></td>
            <td width="381"><b><font size="3"> <a href='javascript:PrintPg("<%=iRowStartFrom[i - 1]%>","<%=iRowsToShow[i - 1]%>","<%=iLastPage%>","0","<%=i%>",<%=iMaxRowToDisplay%>);'> 
              View</a></font></b> </td>
          </tr>
        </table></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
  </table>
<%}//only if vEntrance Data info is not null
}//only if vStud info is not null and vStud Info.size () > 0
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  </table>
	 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
if(vEntranceData == null && vGraduationData == null && vStudInfo != null && vAdditionalInfo != null){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="89%" colspan="3"><font color="blue"> Please enter Graduation 
        and Entrace Data to View or Print OTR </font></td>
    </tr>
    <%}%>
  </table>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="row_start_fr">
<input type="hidden" name="row_count">
<input type="hidden" name="last_page">
<input type="hidden" name="honor_point" value="<%=WI.fillTextValue("honor_point")%>">

<input type="hidden" name="add_record">
<input type="hidden" name="print_pg">
<input type="hidden" name="print_">
<input type="hidden" name="page_number">
<input type="hidden" name="total_page" value="<%=iPageCount%>">
<input type="hidden" name="max_page_to_disp">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
