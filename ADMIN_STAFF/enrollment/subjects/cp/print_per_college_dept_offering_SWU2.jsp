<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector" %>

<%

WebInterface WI = new WebInterface(request);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
	
boolean bolForPosting = (WI.fillTextValue("for_posting").length() > 0);	
boolean bolPrintForSummer = (WI.fillTextValue("print_for_summer").length() > 0);	

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Class Program</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">


  
<%if(bolForPosting || bolPrintForSummer){%>	
.font20 {
	font-family: "Times New Roman";
	font-size: 23px;	
}

TD.thinborderTOPLEFTBOTTOM {
	border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 23px;
}

TD.thinborderTOPBOTTOM {
	border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 23px;
}

<%}%>
</style>

</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//strPrintStat = 0 = view only.
function ReloadPage()
{
	document.form_.form_proceed.value="";
	document.form_.submit();
}
function FormProceed()
{
	document.form_.form_proceed.value="1";
}

function loadDept() {
	var objCOA=document.getElementById("load_dept");
	var objCollegeInput = document.form_.c_index_sel[document.form_.c_index_sel.selectedIndex].value;
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index_sel&all=1";
	//alert(strURL);
	this.processRequest(strURL);
}
function PrintPg() {
	document.getElementById('myADTable2').deleteRow(0);
	var obj = document.getElementById('myADTable1');

	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	alert("Click OK to print this report.");
	window.print();
}
function Toggle(i) {
	if(i == 0 && document.form_.per_open_close.checked) {
		document.form_.per_open_close1.checked = false;
		document.form_.per_open_close2.checked = false;
	}
	else if(i == 1 && document.form_.per_open_close1.checked) {
		document.form_.per_open_close.checked = false;
		document.form_.per_open_close2.checked = false;
	}
	else if(i == 2 && document.form_.per_open_close2.checked) {
		document.form_.per_open_close.checked = false;
		document.form_.per_open_close1.checked = false;
	}
	
	document.form_.submit();
	document.form_.per_open_close.disabled=true;
	document.form_.per_open_close1.disabled=true;
	document.form_.per_open_close2.disabled=true;
}
function ForPosting() {
	if(!document.form_.print_gen_offering.checked)
		document.form_.print_gen_offering.checked = true;
}

</script>

<body bgcolor="#FFFFFF" topmargin='0' bottommargin='0'>

<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;

	if(WI.fillTextValue("per_open_close").length() > 0 || WI.fillTextValue("per_open_close1").length() > 0 || WI.fillTextValue("per_open_close2").length() > 0) {%>
		<jsp:forward page="./print_per_college_dept_offering_open_close.jsp" />
	<%}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-print class program per college/dept offering","print_per_college_dept_offering.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														null);
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




SubjectSection SS = new SubjectSection();
Vector vRetResult = null;

String strCollegeIndex = WI.fillTextValue("c_index_sel");
String strDeptIndex = WI.fillTextValue("d_index_sel");
String strSYFrom = WI.fillTextValue("school_year_fr");
String strSemester = WI.fillTextValue("offering_sem");


if(WI.fillTextValue("form_proceed").compareTo("1") ==0)
{
	vRetResult = SS.printCPPerOfferingCollegeDept(dbOP,request, 0);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
}


boolean bolIsSplit = false;
if(WI.fillTextValue("split_conf_not_conf").length() > 0) 
	bolIsSplit = true;

boolean bolIsPerSubject = false;
if(WI.fillTextValue("show_persub").length() > 0) 
	bolIsPerSubject = true;
	
boolean bolShowLecLab = false;
Vector vSubLecLab = new Vector();//[0] sub_code, [1] lec_hr, [2] lab_hr

String strSQLQuery = null;
java.sql.ResultSet rs = null;
double dTotalLecHr = 0d;
double dTotalLabHr = 0d;
Vector vLecLabHr   = new Vector();
String strLecHr    = null;
String strLabHr    = null;

if(WI.fillTextValue("show_leclab").length() > 0 && vRetResult.size() > 0) {
	bolShowLecLab = true;
	strSQLQuery = "select distinct sub_code, hour_lec, hour_lab from curriculum join subject on (subject.sub_index = curriculum.sub_index) "+
					" where curriculum.is_valid = 1";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vLecLabHr.addElement(rs.getString(1));//[0] sub_code
		vLecLabHr.addElement(rs.getString(2));//[1] hour_lec
		vLecLabHr.addElement(rs.getString(3));//[2] hour_lab
	}
	rs.close();
}


String strCon = "";
if(strSYFrom.length() > 0 && strSemester.length() > 0)
	strCon += " and offering_sy_from = " + strSYFrom + " and offering_sem = " + strSemester;


if (WI.fillTextValue("print_gen_offering").length() > 0)
strCon += " and offered_to_college is null ";  
if (strDeptIndex.length() > 0)
  strCon += " and offered_by_dept = " + strDeptIndex;
if (strCollegeIndex.length() > 0) 
  strCon += " and offered_by_college = " + strCollegeIndex;

Vector vESSDateRange = new Vector();
strTemp = "select sub_sec_index, valid_date_fr_ess, valid_date_to_ess"+
	" from e_sub_section  "+
	" where e_sub_section.is_valid = 1 and valid_date_fr_ess is not null and valid_date_to_ess is not null "+strCon;
rs = dbOP.executeQuery(strTemp);
while(rs.next()){	
	vESSDateRange.addElement(new Integer(rs.getInt(1)));
	vESSDateRange.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(2))+"-"+ConversionTable.convertMMDDYYYY(rs.getDate(3)));
}rs.close();
String strESSDateRange = null;

%>
<form name="form_" action="./print_per_college_dept_offering_SWU2.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr>
      <td height="25" colspan="3" align="center"><strong>:::: PRINT CLASS PROGRAM PER COLLEGE/DEPT OFFERING ::::</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td height="4">&nbsp;</td>
      <td width="48%" height="25" >Class program for school year : 
<%
strTemp = WI.fillTextValue("school_year_fr");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","school_year_fr","school_year_to")'> 
<%
strTemp = WI.fillTextValue("school_year_to");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        - 
        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
	  <%
	  strTemp = WI.fillTextValue("offering_sem");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	  %>
      <td>Term 
	  <select name="offering_sem" onChange="ReloadPage();">
  		<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select>
<!--        <select name="offering_sem">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Term</option>
          <%}else{%>
          <option value="1">1st Term</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Term</option>
          <%}else{%>
          <option value="2">2nd Term</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Term</option>
          <%}else{%>
          <option value="3">3rd Term</option>
          <%}%>
        </select>-->
		
		
		</td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
    
    <tr> 
      <td width="2%" height="4">&nbsp;</td>
      <td height="25">Offering College </td>
      <td width="50%">Offering Department </td>
    </tr>
    <tr> 
      <td width="2%" height="3">&nbsp;</td>
      <td><select name="c_index_sel" onChange="loadDept();">
	  <option value=""></option>
	  	<%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index_sel"), false)%>
	  </select></td>
      <td>
	  <label id="load_dept">
		<%if(WI.fillTextValue("c_index_sel").length() > 0) {%>
			  <select name="d_index_sel">
				  <option value=""></option>
				  <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index = "+WI.fillTextValue("c_index_sel")+" order by d_name asc",WI.fillTextValue("d_index_sel"), false)%>
		</select>
		<%}%>
</label></td>
    </tr>
    <tr>
      <td height="3">&nbsp;</td>
      <td style="font-weight:bold; font-size:11px; color:#0000FF">
	  <input type="checkbox" name="for_posting" value="checked" <%=WI.fillTextValue("for_posting")%>> For Posting 
	  <input type="checkbox" name="print_gen_offering" value="checked" <%=WI.fillTextValue("print_gen_offering")%>> Print General Offering 
	  <input type="checkbox" name="print_for_summer" value="checked" <%=WI.fillTextValue("print_for_summer")%>> Print for Summer Offering
	 
	  </td>
      <td style="font-weight:bold; font-size:11px; color:#0000FF">
	  	<input type="checkbox" name="per_open_close" value="checked" <%=WI.fillTextValue("per_open_close")%> onClick="Toggle(0);"> Print Per Open/Close 
	  	&nbsp;&nbsp;&nbsp;
	  	<input type="checkbox" name="per_open_close1" value="checked" <%=WI.fillTextValue("per_open_close1")%> onClick="Toggle(1);"> Print Open Only 
	  	&nbsp;&nbsp;&nbsp;
	  	<input type="checkbox" name="per_open_close2" value="checked" <%=WI.fillTextValue("per_open_close2")%> onClick="Toggle(2);"> Print Close Only
		<%if(false){%>
	  	&nbsp;&nbsp;&nbsp;
			<input type="checkbox" name="split_conf_not_conf" value="checked" <%=WI.fillTextValue("split_conf_not_conf")%>> Split Confirmed and Not Confirmed 
		<%}%>
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2" align="center"><br>
        <input name="image" type="image" onClick="FormProceed();" src="../../../../images/form_proceed.gif">      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><div align="center"></div></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
String strDateTimePrinted = WI.formatDateTime(new java.util.Date(), 5);
int iNoOfRowsPerPg = 55;
if(bolForPosting || bolPrintForSummer)
	iNoOfRowsPerPg = 34;


int iCurRow = 0, iPageNo = 0; int iTotCount = 0; boolean bolShowInstructor = true;
if(WI.fillTextValue("show_faculty").length() > 0)
	bolShowInstructor = true;

String strCollegeName = null;
String strDeptName    = null;
Vector vTemp = null; String strTemp2 = null; int iIndexOf = 0;

String strIsLec = null;

if(WI.fillTextValue("c_index_sel").length() > 0) { 
	strSQLQuery = "select c_name from college where c_index = "+WI.fillTextValue("c_index_sel");
	strCollegeName = dbOP.getResultOfAQuery(strSQLQuery, 0);
}

if(WI.fillTextValue("d_index_sel").length() > 0) {
	strSQLQuery = "select d_name from department where d_index = "+WI.fillTextValue("d_index_sel");
	strDeptName = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strDeptName != null)
		strDeptName = strDeptName.toUpperCase();
}
//if(strCollegeName != null)
//	strCollegeName = strCollegeName.toUpperCase() + WI.getStrValue(strDeptName, " - ", "","");

String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,false);

String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"}; 
if(bolForPosting || bolPrintForSummer){
		astrConvertTerm[0] = "SUMMER";
		astrConvertTerm[1] = "FIRST SEMESTER";
		astrConvertTerm[2] = "SECOND SEMESTER";
		astrConvertTerm[3] = "THIRD SEMESTER";
}
if(vRetResult != null && vRetResult.size() > 0){%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
			<tr>
			  <td align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>Print Page.</td>
			</tr>
		  </table>
<%	for(int i = 0; i < vRetResult.size();){
		if(i > 0) {%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<%}
		iCurRow = 4;

		
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="20" class="font20" colspan="4"><%=strSchoolName%></td></tr>
	<tr><td height="20" class="font20" colspan="4"><%=strSchoolAdd%></td></tr>
	<tr>	
		<td height="20" class="font20" width="12%">Department</td>
		<td colspan="3" class="font20">: <%=WI.getStrValue(strCollegeName).toUpperCase()%></td>
	</tr>
	<tr>	
		<td height="20" class="font20">Semester</td>
		<td width="59%" class="font20">: <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> 
		<%=WI.fillTextValue("school_year_fr")%>-<%=WI.fillTextValue("school_year_to")%>
		<%=WI.getStrValue(WI.fillTextValue("offering_sem")+WI.fillTextValue("school_year_fr"),"[","]","")%></td>
		<%if(!bolForPosting && !bolPrintForSummer){%>
			<td width="12%">Date Printed:</td>
			<td width="17%"><%=WI.getTodaysDate(1)%></td>
		<%}%>
	</tr>
</table>
		  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="8%" height="20" align="center" class="thinborderTOPLEFTBOTTOM"><%if(bolForPosting || bolPrintForSummer){%>Section<%}else{%>Class Code<%}%></td>
		<td width="11%" align="center" class="thinborderTOPBOTTOM"><%if(bolForPosting || bolPrintForSummer){%>Subject Name<%}else{%>Subj Name<%}%></td>
		<td align="center" class="thinborderTOPBOTTOM">Description</td>
		<td width="5%" align="center" class="thinborderTOPBOTTOM">Units</td>
		<td width="9%" align="center" class="thinborderTOPBOTTOM">Days</td>
		<td width="17%" align="center" class="thinborderTOPBOTTOM">Time</td>
		<td width="7%" align="center" class="thinborderTOPBOTTOM">Room</td>
		<%if(!bolForPosting && !bolPrintForSummer){%><td width="9%" align="center" class="thinborderTOPBOTTOMRIGHT">Stud/RM</td><%}%>
	</tr>
	
	
	 <%
	 ++iCurRow;
	 	
		boolean bolTBA = false;
		String strTime = null;
		String strDays = null;
		String strPrevDescTitle = "";
		int iCount = 1;
		for(; i < vRetResult.size(); i += 17) {		
		
		strESSDateRange = null;
		iIndexOf = vESSDateRange.indexOf(vRetResult.elementAt(i));
		if(iIndexOf > -1)
			strESSDateRange = (String)vESSDateRange.elementAt(iIndexOf + 1);
		
		strTime = null;
		strDays = null;
			strTemp = (String)vRetResult.elementAt(i + 8);
			if(strTemp != null && strTemp.indexOf("<br>") > 1)
				++iCurRow;				
				
			//limit the subject name size to 30
			strTemp = (String)vRetResult.elementAt(i + 2);
			if(strTemp != null && strTemp.length() > 25)
				strTemp = strTemp.substring(0, 25);
				
			strTemp = strTemp.toUpperCase();
				
				
			//this coded is added to swap the Days to end of time. now it is MWF 8 am to 9am :: CIT wants 8 am to 9am MWF.	
			strErrMsg = (String)vRetResult.elementAt(i + 8);
			//System.out.println(strErrMsg);
			if(strErrMsg != null) {
				vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);
				strErrMsg = "";
				while(vTemp.size() > 0) {
					strTemp2 = (String)vTemp.remove(0);
					
					iIndexOf = strTemp2.indexOf(" ");
					if(iIndexOf > -1){			
						bolTBA = false;
						if(strTime == null){
							strTime = strTemp2.substring(iIndexOf + 1).toLowerCase();							
							bolTBA = strTime.trim().equalsIgnoreCase("0:00am-0:00am");
						}else{
							strTime += "<br>"+strTemp2.substring(iIndexOf + 1).toLowerCase();			
							bolTBA = strTemp2.substring(iIndexOf + 1).trim().equalsIgnoreCase("0:00am-0:00am");		
						}
						
						if(strDays == null){
							if(bolTBA)
								strDays = "BY ARR";
							else
								strDays = strTemp2.substring(0, iIndexOf);
						}else{
							if(bolTBA)
								strDays += "<br>BY ARR";
							else
								strDays += "<br>"+strTemp2.substring(0, iIndexOf);
						}	
					}					
				}
			}
			//end of swapping.
			
			
			//check if lab subject.. 
			if(vRetResult.elementAt(i + 14).equals("1")){
				strIsLec = " (Lab)";
			} else {	
				strIsLec = "";
				++iTotCount;//only if lec.. 				
			}
		
		%>
		<%if(!bolForPosting && !bolPrintForSummer){
		++iCurRow;
		%>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td colspan="6"><%=WI.getStrValue("<u>"+(String)vRetResult.elementAt(i + 11)+"</u>", " ______________ ")%></td>
		</tr>
		<%}%>
        <tr>
          <td width="8%" valign="top" class="font20"><%if(strIsLec.length() == 0) {%><%=vRetResult.elementAt(i + 4)%><%}%></td>
          <td width="11%" valign="top" class="font20"><%if(strIsLec.length() == 0) {%><%=vRetResult.elementAt(i + 1)%><%}%></td>
          <td valign="top" class="font20"><%if(strIsLec.length() == 0) {%><%=strTemp%><%}%></td>
          <td width="5%" valign="top" class="font20" align="center">
			 	<%if(strIsLec.length() == 0) {%><%=vRetResult.elementAt(i + 12)%><%}else{%>LAB<%}%></td>
          <td width="9%" valign="top" class="font20" align="center"><%=WI.getStrValue(strDays)%></td>
          <td width="17%" valign="top" class="font20" align="center"><%=WI.getStrValue(strTime)%></td>
          <td width="7%" valign="top" class="font20" align="center"><%=vRetResult.elementAt(i + 10)%></td>
        <%if(!bolForPosting && !bolPrintForSummer){%>
			<td width="9%" valign="top" align="center">
				<%if(strIsLec.length() == 0){%>
				<%=WI.getStrValue(vRetResult.elementAt(i + 13),"0")%><%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"/","","")%>			
				<%}else{%>&nbsp;<%}%>		  	</td>
		<%}%>
        </tr>
        <tr>
            <td valign="top" height="10" class="font20"></td>
            <td valign="top" class="font20"></td>
            <td valign="top" class="font20"></td>
            <td valign="top" class="font20" align="center"></td>
            <td colspan="2" valign="top" class="font20"><%=WI.getStrValue(strESSDateRange)%></td>
            <td valign="top" class="font20" align="center"></td>
            <td valign="top" align="center"></td>
        </tr>
		
		
		
		
        <%
			if(++iCurRow >= iNoOfRowsPerPg) {
				i += 17;
				break;
			}
		}
		%>
</table>

  	   

		  	
		  
	<%}//for loop to show the pages.
	
	if(!bolForPosting && !bolPrintForSummer){
	%>
	
		<br>
		<b><font style="font-size:12px;">Total Classes Offered: <%=iTotCount%></font></b>
	<%}
}//only if vSecList.size()>0%>

<input type="hidden" name="form_proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
