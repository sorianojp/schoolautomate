<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Class Program</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	document.form_.form_proceed.value='1';
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
	document.form_.submit()
	document.form_.per_open_close.disabled=true;
	document.form_.per_open_close1.disabled=true;
	document.form_.per_open_close2.disabled=true;
}
</script>

<body bgcolor="#FFFFFF" topmargin='0' bottommargin='0'>
<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

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
Vector vOpen  = null;
Vector vClose = null;
if(WI.fillTextValue("per_open_close").length() > 0) {
	vOpen  = SS.printCPPerOfferingCollegeDept(dbOP,request, 2);
	vClose = SS.printCPPerOfferingCollegeDept(dbOP,request, 1);
}
if(WI.fillTextValue("per_open_close1").length() > 0) //Open only
	vOpen  = SS.printCPPerOfferingCollegeDept(dbOP,request, 2);

if(WI.fillTextValue("per_open_close2").length() > 0)//close only. 
	vClose = SS.printCPPerOfferingCollegeDept(dbOP,request, 1);



boolean bolIsSplit = false;
if(WI.fillTextValue("split_conf_not_conf").length() > 0) 
	bolIsSplit = true;
%>
<form name="form_" action="./print_per_college_dept_offering.jsp" method="post">
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
      <td>Term 
        <select name="offering_sem">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
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
      <td style="font-weight:bold; font-size:11px; color:#0000FF"><input type="checkbox" name="show_faculty" value="checked" <%=WI.fillTextValue("show_faculty")%>> Show Faculty </td>
      <td style="font-weight:bold; font-size:11px; color:#0000FF"><input type="checkbox" name="per_open_close" value="checked" <%=WI.fillTextValue("per_open_close")%> onClick="Toggle(0);"> Print Per Open/Close 
	  	&nbsp;&nbsp;&nbsp;
	  	<input type="checkbox" name="per_open_close1" value="checked" <%=WI.fillTextValue("per_open_close1")%> onClick="Toggle(1);"> Print Open Only 
	  	&nbsp;&nbsp;&nbsp;
	  	<input type="checkbox" name="per_open_close2" value="checked" <%=WI.fillTextValue("per_open_close2")%> onClick="Toggle(2);"> Print Close Only

	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2" align="center"><br>
        <input name="image" type="image" onClick="FormProceed();" src="../../../../images/form_proceed.gif">      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td style="font-weight:bold; font-size:13px;color:#FF0000"><%if((WI.fillTextValue("per_open_close1").length() > 0 || WI.fillTextValue("per_open_close").length() > 0) && (vOpen == null || vOpen.size() == 0)) {%>No Open Subject Found.<%}%></td>
      <td style="font-weight:bold; font-size:13px;color:#FF0000"><%if((WI.fillTextValue("per_open_close2").length() > 0 || WI.fillTextValue("per_open_close").length() > 0) && (vClose == null || vClose.size() == 0) ) {%>No Closed Subject Found.<%}%></td>
    </tr>
  </table>
<%
String strDateTimePrinted = WI.formatDateTime(new java.util.Date(), 5);
int iNoOfRowsPerPg = 30;

int iCurRow = 0, iPageNo = 0; int iTotCount = 0; boolean bolShowInstructor = false;
if(WI.fillTextValue("show_faculty").length() > 0)
	bolShowInstructor = true;

String strCollegeName = null;
String strDeptName    = null;
Vector vTemp = null; String strTemp2 = null; int iIndexOf = 0;

String strIsLec = null;

String strSQLQuery = null;
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
if(strCollegeName != null)
	strCollegeName = strCollegeName.toUpperCase() + WI.getStrValue(strDeptName, " - ", "","");

String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"}; 
boolean bolInsPgBreak = false;
%>

		  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
			<tr>
			  <td align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>Pring Page.</td>
			</tr>
		  </table>
<%if(vOpen != null && vOpen.size() > 0){
	bolInsPgBreak = true;//
	
	for(int i = 0; i < vOpen.size();){
		if(i > 0) {%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<%}
		iCurRow = 0;
		%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
			  <td>Date Printed: <%=strDateTimePrinted%></td>
			  <td align="right">Page: <%=++iPageNo%></td>
			</tr>
			<tr>
			  <td colspan="2" align="center"><%=WI.getStrValue(strCollegeName)%></td>
			</tr>
			<tr>
			  <td colspan="2" align="center">SUBJECT OFFERINGS (OPEN SUBJECTS)</td>
			</tr>
			<tr>
			  <td colspan="2" align="center"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, SY <%=WI.fillTextValue("school_year_fr")%> - <%=WI.fillTextValue("school_year_to")%></td>
			</tr>
		  </table>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr style="font-weight:bold"> 
			  <td width="2%" height="24" class="thinborderTOPBOTTOM">&nbsp;</td>
			  <td width="15%" class="thinborderTOPBOTTOM">Code - Section </td>
<%if(!bolShowInstructor){%>
			  <td width="25%" class="thinborderTOPBOTTOM">Descriptive Title </td>
<%}%>			 
			  <td width="5%" class="thinborderTOPBOTTOM">Units</td>
			  <td width="23%" class="thinborderTOPBOTTOM">Schedule</td>
			  <td width="5%" class="thinborderTOPBOTTOM">Room</td>
			  <td width="5%" class="thinborderTOPBOTTOM">Limit</td>
			  <td width="5%" class="thinborderTOPBOTTOM">Qty</td>
<%if(bolIsSplit) {%>
              <td width="5%" class="thinborderTOPBOTTOM">Conf</td>
              <td width="5%" class="thinborderTOPBOTTOM">Not Conf</td>
<%}if(bolShowInstructor){%>
			  <td width="25%" class="thinborderTOPBOTTOM">Instructor</td>
<%}%>
			</tr>
		<%
		for(; i < vOpen.size(); i += 17) {
			strTemp = (String)vOpen.elementAt(i + 8);
			if(strTemp != null && strTemp.indexOf("<br>") > 1)
				++iCurRow;
			//limit the subject name size to 30
			strTemp = (String)vOpen.elementAt(i + 2);
			if(strTemp != null && strTemp.length() > 30)
				strTemp = strTemp.substring(0, 30);
			//this coded is added to swap the Days to end of time. now it is MWF 8 am to 9am :: CIT wants 8 am to 9am MWF.	
			strErrMsg = (String)vOpen.elementAt(i + 8);
			if(strErrMsg != null) {
				vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);
				strErrMsg = "";
				while(vTemp.size() > 0) {
					strTemp2 = (String)vTemp.remove(0);
					iIndexOf = strTemp2.indexOf(" ");
					if(iIndexOf > -1)
						strTemp2 = strTemp2.substring(iIndexOf).toLowerCase() +  " &nbsp;" + strTemp2.substring(0, iIndexOf);
					if(strErrMsg.length() > 0) 
						strErrMsg = strErrMsg + "<br>";
					strErrMsg = strErrMsg +strTemp2;
				}
			}
			//end of swapping.
			
			//check if lab subject.. 
			if(vOpen.elementAt(i + 14).equals("1"))
				strIsLec = " (Lab)";
			else {	
				strIsLec = "";
				++iTotCount;//only if lec.. 
			}
		%>
			<tr valign="top">
			  <td height="24">&nbsp;</td>
			  <td><%if(strIsLec.length() == 0) {%><%=vOpen.elementAt(i + 1)%> - <%=vOpen.elementAt(i + 4)%><%}%></td>
<%if(!bolShowInstructor){%>
			  <td><%if(strIsLec.length() == 0) {%><%=strTemp%><%}%></td>
<%}%>
			  <td><%if(strIsLec.length() == 0) {%><%=vOpen.elementAt(i + 12)%><%}else{%><div align="right">LAB&nbsp;</div><%}%></td>
			  <td><%=strErrMsg%></td>
			  <td><%=vOpen.elementAt(i + 10)%></td>
			  <td><%=WI.getStrValue(vOpen.elementAt(i + 5),"&nbsp;")%></td>
			  <td><%=WI.getStrValue(vOpen.elementAt(i + 13),"&nbsp;")%></td>
<%if(bolIsSplit) {%>
             <td><%=WI.getStrValue(vOpen.elementAt(i + 15),"&nbsp;")%></td>
              <td><%=WI.getStrValue(vOpen.elementAt(i + 16),"&nbsp;")%></td>
<%}if(bolShowInstructor){
strTemp = WI.getStrValue(vOpen.elementAt(i + 11), " ______________ ");
if(strTemp.length() > 32)
	strTemp = strTemp.substring(0, 32);
%>
			  <td><%=strTemp%></td>
<%}%>
			</tr>
		<%
			if(++iCurRow > iNoOfRowsPerPg) {
				i += 17;
				break;
			}
		}%>
		  </table>
	<%}//for loop to show the pages.%>
<br>
<b><font style="font-size:14px;">Total Number of Open Subjects/Sections: <%=iTotCount%></font></b>

<%}//only if vSecList.size()>0%>

<%if(vClose != null && vClose.size() > 0){
iTotCount = 0;
	for(int i = 0; i < vClose.size();){
		if(i > 0 || bolInsPgBreak) {%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<%}
		iCurRow = 0;
		%>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
			  <td>Date Printed: <%=strDateTimePrinted%></td>
			  <td align="right">Page: <%=++iPageNo%></td>
			</tr>
			<tr>
			  <td colspan="2" align="center"><%=WI.getStrValue(strCollegeName)%></td>
			</tr>
			<tr>
			  <td colspan="2" align="center">SUBJECT OFFERINGS (CLOSED SUBJECTS)</td>
			</tr>
			<tr>
			  <td colspan="2" align="center"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>, SY <%=WI.fillTextValue("school_year_fr")%> - <%=WI.fillTextValue("school_year_to")%></td>
			</tr>
		  </table>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr style="font-weight:bold"> 
			  <td width="2%" height="24" class="thinborderTOPBOTTOM">&nbsp;</td>
			  <td width="15%" class="thinborderTOPBOTTOM">Code - Section </td>
<%if(!bolShowInstructor){%>
			  <td width="25%" class="thinborderTOPBOTTOM">Descriptive Title </td>
<%}%>			 
			  <td width="5%" class="thinborderTOPBOTTOM">Units</td>
			  <td width="23%" class="thinborderTOPBOTTOM">Schedule</td>
			  <td width="5%" class="thinborderTOPBOTTOM">Room</td>
			  <td width="5%" class="thinborderTOPBOTTOM">Limit</td>
			  <td width="5%" class="thinborderTOPBOTTOM">Qty</td>
<%if(bolIsSplit) {%>
              <td width="5%" class="thinborderTOPBOTTOM">Conf</td>
              <td width="5%" class="thinborderTOPBOTTOM">Not Conf</td>
<%}if(bolShowInstructor){%>
			  <td width="25%" class="thinborderTOPBOTTOM">Instructor</td>
<%}%>
			</tr>
		<%
		for(; i < vClose.size(); i += 17) {
			strTemp = (String)vClose.elementAt(i + 8);
			if(strTemp != null && strTemp.indexOf("<br>") > 1)
				++iCurRow;
			//limit the subject name size to 30
			strTemp = (String)vClose.elementAt(i + 2);
			if(strTemp != null && strTemp.length() > 30)
				strTemp = strTemp.substring(0, 30);
			//this coded is added to swap the Days to end of time. now it is MWF 8 am to 9am :: CIT wants 8 am to 9am MWF.	
			strErrMsg = (String)vClose.elementAt(i + 8);
			if(strErrMsg != null) {
				vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);
				strErrMsg = "";
				while(vTemp.size() > 0) {
					strTemp2 = (String)vTemp.remove(0);
					iIndexOf = strTemp2.indexOf(" ");
					if(iIndexOf > -1)
						strTemp2 = strTemp2.substring(iIndexOf).toLowerCase() +  " &nbsp;" + strTemp2.substring(0, iIndexOf);
					if(strErrMsg.length() > 0) 
						strErrMsg = strErrMsg + "<br>";
					strErrMsg = strErrMsg +strTemp2;
				}
			}
			//end of swapping.
			
			//check if lab subject.. 
			if(vClose.elementAt(i + 14).equals("1"))
				strIsLec = " (Lab)";
			else {	
				strIsLec = "";
				++iTotCount;//only if lec.. 
			}
		%>
			<tr valign="top">
			  <td height="24">&nbsp;</td>
			  <td><%if(strIsLec.length() == 0) {%><%=vClose.elementAt(i + 1)%> - <%=vClose.elementAt(i + 4)%><%}%></td>
<%if(!bolShowInstructor){%>
			  <td><%if(strIsLec.length() == 0) {%><%=strTemp%><%}%></td>
<%}%>
			  <td><%if(strIsLec.length() == 0) {%><%=vClose.elementAt(i + 12)%><%}else{%><div align="right">LAB&nbsp;</div><%}%></td>
			  <td><%=strErrMsg%></td>
			  <td><%=vClose.elementAt(i + 10)%></td>
			  <td><%=WI.getStrValue(vClose.elementAt(i + 5),"&nbsp;")%></td>
			  <td><%=WI.getStrValue(vClose.elementAt(i + 13),"&nbsp;")%></td>
<%if(bolIsSplit) {%>
              <td><%=WI.getStrValue(vClose.elementAt(i + 15),"&nbsp;")%></td>
              <td><%=WI.getStrValue(vClose.elementAt(i + 16),"&nbsp;")%></td>
<%}if(bolShowInstructor){
strTemp = WI.getStrValue(vClose.elementAt(i + 11), " ______________ ");
if(strTemp.length() > 32)
	strTemp = strTemp.substring(0, 32);
%>
			  <td><%=strTemp%></td>
<%}%>
			</tr>
		<%
			if(++iCurRow > iNoOfRowsPerPg) {
				i += 17;
				break;
			}
		}%>
		  </table>
	<%}//for loop to show the pages.%>
<br>
<b><font style="font-size:14px;">Total Number of Closed Subjects/Sections: <%=iTotCount%></font></b>

<%}//only if vSecList.size()>0%>

<input type="hidden" name="form_proceed">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
