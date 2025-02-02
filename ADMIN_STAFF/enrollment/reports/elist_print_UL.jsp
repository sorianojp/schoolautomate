<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = null;//for UI , do not show remarks.
	//for CLDH, show total enrolled unit instead of remark.
	strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	//strSchCode = "CDD";
	
	String strSchName = "University of Luzon";
	String strTelNo   = "Tel.No: 522-8295";
	if(strSchCode.startsWith("CDD")) {
		strSchName = "COLEGIO DE DAGUPAN";
		strTelNo   = "";
	}
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
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }


-->
</style>
</head>

<body topmargin="0" bottommargin="0" onLoad="window.print();">
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

String strOrigSchooCode = strSchCode;//"UDMC";

//strSchCode = "VMUF";
boolean bolShowID = false; 

boolean bolIsForm19 = false; 
Vector avAddlInfo = null;

	if(WI.fillTextValue("form_19").equals("1")) {
		bolIsForm19 = true;
		//iNoOfSubPerRow = 4;
		//strSchCode  = "AUF";
	}

	//request.setAttribute("ShowAllYr","1");


Vector vAddressUL = null;
int iIndexOf = 0;
String strAddress = null;

Vector vRetResult = enrlReport.getEnrollmentList(dbOP,request,iNoOfSubPerRow,bolSeparateName);//8 subjects in one row -- change it for different no of subjects per row
	//System.out.println(vRetResult);
if(vRetResult == null || vRetResult.size() ==0) {
	strErrMsg = enrlReport.getErrMsg();

	if(strErrMsg == null)
		strErrMsg = "Enrollment list not found.";
}
else if(bolIsForm19)
	avAddlInfo = (Vector)vRetResult.remove(0);

//System.out.println(avAddlInfo);
if(strSchCode.startsWith("UL")) {
	vAddressUL = enrlReport.getStudentAddressUL(dbOP, request);
}
	
	if(vAddressUL == null)
		vAddressUL = new Vector();

//I have to now check if it is called to view only male or female - applicable for UDMC.
strTemp = WI.fillTextValue("gender_x");
if(strTemp.length() > 0 && vRetResult != null && vRetResult.size() > 0) {//filter gender
	for(int i = 4; i < vRetResult.size();) {
		vEnrlInfo = (Vector)vRetResult.elementAt(i);
		//System.out.println(vEnrlInfo.elementAt(2));
		if(!strTemp.equals(vEnrlInfo.elementAt(2)))
			vRetResult.removeElementAt(i);
		else
			++i;
	}
}
//System.out.println(vRetResult.size());




//dbOP.cleanUP();
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

int iDefNoOfRowPerPg = 18;
if(request.getParameter("stud_per_pg") != null)
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

if(!strSchCode.startsWith("CDD"))
	iDefNoOfRowPerPg = 20;
//if(((String)request.getSession(false).getAttribute("school_code")).startsWith("CDD"))
//	iDefNoOfRowPerPg = 10;

int iNoOfRowPerPg = iDefNoOfRowPerPg;
//if(strSchCode.startsWith("UI") || strSchCode.startsWith("LNU") )
//	iNoOfRowPerPg = 20;

int iStudCount = 1;
int iTemp = vRetResult.size() - 4;//depending on the number of student..
//System.out.println(iTemp);
//iTemp is not correct -- i have to run a for loop to find number of rows.

int iTotalNoOfPage = iTemp / iNoOfRowPerPg;
if(iTemp%iNoOfRowPerPg > 0) ++iTotalNoOfPage;

int iPageCount = 1;
String strUserIndex = null;
String strPgCountDisp = null;
for(int i=4; i<vRetResult.size();){
//iNoOfRowPerPg = 18;
//if(strSchCode.startsWith("UI") || strSchCode.startsWith("LNU") )
//	iNoOfRowPerPg = 20;
iNoOfRowPerPg = iDefNoOfRowPerPg;

strPgCountDisp = "Page count : "+Integer.toString(iPageCount++) +" of "+Integer.toString(iTotalNoOfPage);

%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="3"><div align="center">
        <p><strong>
<%if(bolIsForm19){%>		
		REPORT ON GRADES
<%}else{%>
		REPORT ON ENROLMENT LIST
<%}%>		
		</strong><br>
		<%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>
		<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>		</p></div></td>
  </tr>
  <tr valign="top">
    <td width="33%" height="20"><%=request.getParameter("college_name").toUpperCase()%></td>
    <td width="33%">&nbsp;</td>
    <td width="33%">Year level : <%=astrConvertYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"),"0"))]%></td>
  </tr>
  <tr valign="top">
    <td height="20">School: <%=strSchName%> </td>
    <td colspan="2">Course: <%=request.getParameter("course_name")%>
	<%if(WI.fillTextValue("major_name").length() >0){%>
	 / <%=request.getParameter("major_name")%>
    <%}%></td>
    </tr>
  <tr valign="top">
    <td height="20">Address: Dagupan City <strong>
	
	 </strong></td>
    <td><%=strTelNo%> </td>
    <td>Region: 1 </td>
  </tr>
</table>
<table width="1136" border="0" cellpadding="0" cellspacing="0" class="jumboborder">
  <tr>
    <td width="5" height="24" class="jumboborderRIGHT">EL NO.</td>
    <td width="372" class="jumboborderRIGHT">NAME OF STUDENT</td>
    <td width="45" class="jumboborderRIGHT"><div align="center">GENDER</div></td>
    <td width="82" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
    <td width="85" class="jumboborderRIGHT">SUBJECT</td>
<%if(bolIsForm19){%><td width="40" class="jumboborderRIGHT">GRADE</td><%}%>
    <td width="34" class="jumboborderRIGHT"><div align="center">UNITS</div></td>
  </tr>
	<%
float fUnitEnrolled = 0f; String strUnit = null; String strGrade = null;
int iTotCol = iNoOfSubPerRow * 2;// = 12
int iTotColPlus = iTotCol + 4;///= 16,  4 = number of elements before subject+unit info =
//Vector -> [0]=id [1] =name,[2]=gender,[3]=course regularity -- one time. =>repeat =>[4]=sub_code,[5]=unit

for(; i<vRetResult.size();++i){// this is for page wise display.
	//System.out.println(vRetResult.elementAt(i));
	vEnrlInfo = (Vector)vRetResult.elementAt(i);
	
	iIndexOf = vAddressUL.indexOf(vEnrlInfo.elementAt(0));
	if(iIndexOf > -1)
		strAddress = (String)vAddressUL.elementAt(iIndexOf + 1);//System.out.println("Address : "+strAddress);
	else	
		strAddress = "";
	
if(iNoOfRowPerPg <= 0) {
	bolShowPageBreak = true;
	break;
}
	--iNoOfRowPerPg;
	
	bolShowPageBreak = false;
	fUnitEnrolled = 0f;
	String strClass = null;
	//System.out.println("What are you?: "+vEnrlInfo.size());
	for(int k=5; k<vEnrlInfo.size(); k += 2)
		fUnitEnrolled += Float.parseFloat(WI.getStrValue(vEnrlInfo.elementAt(k), "0"));

	for(int k=0; k<vEnrlInfo.size();k += 4){
	if( k > 0) k -= 4;
	%>
  <tr>
  <%if (k==0)
  	strClass = "jumboborderTOP";
  	else
  	strClass = "jumboborderTOPex";
  %>
<!-- 1st line -->
    <% if(k == 0 && vEnrlInfo.size()>iTotColPlus){%>
    <td height="21" class="<%=strClass%>" rowspan="2">  <%=iStudCount++%>.</td>
    <%} else if (k==0 && vEnrlInfo.size()<=iTotColPlus){%><td height="21" class="<%=strClass%>"><%=iStudCount++%>.</td>
	<%} else if (k > iTotCol && vEnrlInfo.size()>iTotColPlus){%>
    	<td class="<%=strClass%>" height="21">&nbsp;</td>
		<td class="<%=strClass%>" height="21">&nbsp;</td>
    	<td class="<%=strClass%>" height="21">&nbsp;</td>
	<%}%>

<!-- 2nd line do not show.-->
<!-- 3rd line -->
    <% if(k == 0 && vEnrlInfo.size()>iTotColPlus){%>
    <td height="21" class="<%=strClass%>" rowspan="2"> <%=(String)vEnrlInfo.elementAt(k+1)%><%=WI.getStrValue(strAddress, "<br>","","")%></td>
    <%} else if (k==0 && vEnrlInfo.size()<=iTotColPlus){%>
    <td height="21" class="<%=strClass%>"> <%=WI.getStrValue(vEnrlInfo.elementAt(k+1), "&nbsp;")%><%=WI.getStrValue(strAddress, "<br>","","")%></td><%}%>

<!-- 4th line do not show-->

<!-- 5th line -->
    <% if(k == 0 && vEnrlInfo.size()>iTotColPlus){%>
    <td align="center" class="<%=strClass%>" rowspan="2"><%=(String)vEnrlInfo.elementAt(k+2)%></td>
    <%} else if (k==0 && vEnrlInfo.size()<=iTotColPlus){%>
    <td align="center" class="<%=strClass%>"><%=(String)vEnrlInfo.elementAt(k+2)%></td><%}%>

<!-- 6th line(subject) start of content subject and units.. -->
<%
strUnit = (String)vEnrlInfo.elementAt(k+5);
if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
	strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
//System.out.println(strUnit);
//System.out.println(avAddlInfo.elementAt(0));

%>
    <td class="<%=strClass%>"><%=(String)vEnrlInfo.elementAt(k+4)%></td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 7th line(unit) -->
    <td align="center" class="<%=strClass%>"><%=WI.getStrValue(strUnit, "&nbsp;")%></td>
<!-- 8th line(subject) -->
<%
if( (k+6) < vEnrlInfo.size()) {
	strUnit = (String)vEnrlInfo.elementAt(k+7);
	if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
		strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
}
%>
    <td class="<%=strClass%>"> <%if( (k+6) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+6)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+6) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 9th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+6) < vEnrlInfo.size()){%> <%=strUnit%> <%}else{%> &nbsp; <%}%> </td>
<!-- 10th line (subject)-->
<%
if( (k+8) < vEnrlInfo.size()) {
	strUnit = (String)vEnrlInfo.elementAt(k+9);
	if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
		strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
}
%>
    <td class="<%=strClass%>"> <%if( (k+8) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+8)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+8) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 11th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+8) < vEnrlInfo.size()){%> <%=WI.getStrValue(strUnit,"&nbsp;")%> <%}else{%> &nbsp; <%}%> </td>
<!-- 12th line (subject-->
<%
if( (k+10) < vEnrlInfo.size()) {
	strUnit = (String)vEnrlInfo.elementAt(k+11);
	if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
		strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
}
%>    
	<td class="<%=strClass%>"> <%if( (k+10) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+10)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+10) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 13th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+10) < vEnrlInfo.size()){%> <%=strUnit%> <%}else{%> &nbsp; <%}%> </td>
<!-- 14th line (subject)-->
<%//do not show below if it is called for form 19 - AUF
	///added for AUF - they want to show only 4 subjects.
if(!bolIsForm19 || true){%>

<%
if( (k+12) < vEnrlInfo.size()) {
	strUnit = (String)vEnrlInfo.elementAt(k+13);
	if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
		strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
}
%>    
    <td class="<%=strClass%>"> <%if( (k+12) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+12)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+12) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 15th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+13) < vEnrlInfo.size()){%> <%=strUnit%> <%}else{%> &nbsp; <%}%> </td>
<!-- 16th line (subject)-->
<%
if( (k+14) < vEnrlInfo.size()) {
	strUnit = (String)vEnrlInfo.elementAt(k+15);
	if(bolIsForm19 && avAddlInfo != null && avAddlInfo.size() > 0)
		strUnit = enrlReport.getUnitForAUFForm19(strUnit, (String)avAddlInfo.elementAt(0),strOrigSchooCode);
}
%>    
    <td class="<%=strClass%>"> <%if( (k+14) < vEnrlInfo.size()){%> <%=(String)vEnrlInfo.elementAt(k+14)%> <%}else{%> &nbsp; <%}%> </td>
<%if(bolIsForm19){%><td width="40" class="<%=strClass%>">&nbsp;
			<%if(avAddlInfo != null && avAddlInfo.size() > 0 && (k+14) < vEnrlInfo.size() ) {%>
				<%=WI.getStrValue((String)avAddlInfo.remove(0))%><%}%></td><%}%>
<!-- 17th line (unit)-->
    <td align="center" class="<%=strClass%>"> <%if( (k+14) < vEnrlInfo.size()){%> <%=strUnit%> <%}else{%> &nbsp; <%}%> </td>

<%}//do not show for AUF form 19%>

    <!--    <td class="thinborder">
      <%if( (k+16) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+16)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td align="center" class="thinborder">
      <%if( (k+16) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+17)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td class="thinborder">
      <%if( (k+18) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+18)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td align="center" class="thinborder">
      <%if( (k+18) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+19)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
-->
  </tr>
  <%
k += iNoOfSubPerRow * 2; // only 6 rows or 4 rows(for AUF)
}//end of printing rows.

 }//end of print per page.%>
</table>
<table width="1136" border="0" cellspacing="0" cellpadding="0">
  <tr valign="top">
	<td width="775" align="right"><%if( iPageCount > iTotalNoOfPage){%>***** Nothing Follows *****<%}%></td>
    <td width="361" align="right"><%=strPgCountDisp%></td>
  </tr>
</table>
<!-- introduce page break here -->
<%if(bolShowPageBreak){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}//break only if it is not last page.

}//end of printing. - outer for loop.
%>

<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr style="font-weight:bold">
		<td width="50%">Prepared By: </td>
		<td width="50%">Checked By: </td>
	</tr>
	<tr style="font-weight:bold">
	  <td align="center">_________________</td>
	  <td align="center">_________________</td>
  </tr>
	<tr>
		<%
	  strTemp = WI.fillTextValue("printed_by");
	  strErrMsg = WI.fillTextValue("printed_by_designation");
	  if(strOrigSchooCode.startsWith("CDD"))	  {
		strTemp = WI.getStrValue(strTemp, "Sheila Bernadette D. Viray");		
		strErrMsg = WI.getStrValue(strErrMsg, "Registrar Staff");
	  }
		
	  
	  %>
	  <td align="center" style="font-size:9px;"><%=strTemp%><%=WI.getStrValue(strErrMsg, "<br>","","")%></td>
	  <%
	  strTemp = WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"University Registrar",7));
	  strErrMsg = "Registrar";
	  if(strOrigSchooCode.startsWith("CDD"))	  {
		strTemp = WI.getStrValue(WI.fillTextValue("checked_by"), "Catherine A. Solomon");		
		strErrMsg = WI.getStrValue(WI.fillTextValue("checked_by_designation"), "Registrar");
	  }
		
	  
	  %>
	  <td align="center" style="font-size:9px;"><%=strTemp%> <br><%=strErrMsg%></td>
  </tr>
</table>


<script language="JavaScript">
alert("Total no of pages to print : <%=iTotalNoOfPage%>");
//window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
