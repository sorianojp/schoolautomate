<%@ page language="java" import="utility.*,enrollment.ReportRegistrar,java.util.Vector, java.util.Date" %>
<%
WebInterface WI = new WebInterface(request);
String strTemp  = WI.fillTextValue("font_size");


	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	if(strSchCode.startsWith("PHILCST")){%>
		<jsp:forward page="./rep_promo_grad_print_PHILCST.jsp"/>
	<%return;}
	if(strSchCode.startsWith("SPC")){
		if(WI.fillTextValue("report_format").length() > 0) {%>
		<jsp:forward page="./rep_promo_grad_print_SPC.jsp"/>
		<%}else{%>
		<jsp:forward page="./rep_promo_grad_print_SPC2.jsp"/>
		<%}%>
	<%return;}

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
	font-size: <%=strTemp%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strTemp%>px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strTemp%>px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strTemp%>px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strTemp%>px;
    }


-->
</style>
</head>

<body onLoad="window.print()">
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strCollegeName = null;
	String strCollegeIndex = null;

	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
	String[] astrConvertYr	= {"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Promotion for Graduation PRINT","rep_promo_grad_print.jsp");
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
ReportRegistrar regReport = new ReportRegistrar();
Vector vEnrlInfo = new Vector();
Vector vRetResult = null;


vRetResult = regReport.getPromoForGrad(dbOP,request,8);//8 subjects in one row -- change it for different no of subjects per row
if(vRetResult == null || vRetResult.size() ==0)
{
	strErrMsg = regReport.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Promotion for graduation list not found.";
}
if(WI.fillTextValue("course_index").length() > 0)
	strCollegeName = dbOP.mapOneToOther("course_offered join college on (college.c_index = course_offered.c_index) ",
						"course_index",WI.fillTextValue("course_index"),"c_name",null);
						

//I have to now check if it is called to view only male or female - applicable for UDMC. 
strTemp = WI.fillTextValue("gender_x");
if(strTemp.length() > 0 && vRetResult != null && vRetResult.size() > 0) {//filter gender
	for(int i = 4; i < vRetResult.size();) {
		vEnrlInfo = (Vector)vRetResult.elementAt(i);//System.out.println(vEnrlInfo.elementAt(2));
		//System.out.println(vEnrlInfo.elementAt(2));
		if( !((String)vEnrlInfo.elementAt(2)).startsWith(strTemp))
			vRetResult.removeElementAt(i);
		else	
			++i;
	}
}

//System.out.println(vRetResult.size());



if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0">
<tr>
	<td>
		<%=strErrMsg%>
	</td>
</tr>
</table>
<%dbOP.cleanUP();
return;
}
int iDefNoOfRowPerPg = 0;
if(request.getParameter("stud_per_pg") == null) 
	iDefNoOfRowPerPg = 12;
else	
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));   

int iNoOfRowPerPg = 0;
int iStudCount = 1;
int iTemp = Integer.parseInt((String)vRetResult.elementAt(3));//total no of rows.
int iTotalNoOfPage = iTemp / iDefNoOfRowPerPg;
if(iTemp%iDefNoOfRowPerPg > 0) ++iTotalNoOfPage;

int iPageCount = 1;
String strUserIndex = null;
String strPgCountDisp = null;
boolean bolShowPageBreak = false;
//Vector vTemp = vRetResult; vTemp.removeElementAt(0);vTemp.removeElementAt(0);vTemp.removeElementAt(0);vTemp.removeElementAt(0);
for(int i=4; i<vRetResult.size();){
iNoOfRowPerPg = iDefNoOfRowPerPg;
strPgCountDisp = "Page count : "+Integer.toString(iPageCount++) +" of "+Integer.toString(iTotalNoOfPage);
%>

<table width="1136" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><div align="center">
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false), "", "<br>", "&nbsp;")%>
          <!-- Pangasinan 2420 Philippines -->
          <%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), "", "<br>", "&nbsp;")%>
          <!-- Tel Nos. (075) 532-2380; (075) 955-5054 FAX No. (075) 955-5477 -->
          <%=WI.getStrValue(SchoolInformation.getAddressLine3(dbOP,false,false), "", "<br>", "&nbsp;")%>
          <br>
          <strong><!-- REGION I -->
          <%=SchoolInformation.getInfo2(dbOP,false,false)%></strong> <br>
          <br>
     <%if(strSchCode.startsWith("UDMC")){%>SUMMARY OF RATINGS<%}else{%>REPORT ON PROMOTION FOR GRADUATION<%}%></strong><br>
          <%=strCollegeName%><br>
          <strong><%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%></strong>,
          School Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong>
      </div></td>
  </tr>
  <tr valign="top">
    <td width="761" height="20">Course / Major : <strong>
	<%=request.getParameter("course_name")%>
	<%if(WI.fillTextValue("major_name").length() >0){%>
	 / <%=request.getParameter("major_name")%>
	 <%}%>
	 </strong></td>
    <td width="224">Year level : <strong><%=astrConvertYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year"),"0"))]%></strong></td>
  </tr>
  <tr>
    <td>Total Enrollees: <strong><%=(String)vRetResult.elementAt(0)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	Female(<%=(String)vRetResult.elementAt(2)%>) : Male(<%=(String)vRetResult.elementAt(1)%>)</strong></td>
    <td>&nbsp;</td>
  </tr>
</table>
<table width="1136" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="245" height="24" class="thinborder"><div align="center">NAME OF STUDENT</div></td>
    <td width="45" class="thinborder"><div align="center">GENDER</div></td>
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">GRADE</div></td>
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">GRADE</div></td>
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">GRADE</div></td>
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">GRADE</div></td>
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">GRADE</div></td>
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">GRADE</div></td>
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">GRADE</div></td>
    <td width="60" class="thinborder"><div align="center">SUBJECT</div></td>
    <td width="40" class="thinborder"><div align="center">GRADE</div></td>
    <td width="46" class="thinborder"><div align="center"><%if(strSchCode.startsWith("UDMC")){%>TOTAL UNITS<%}else{%>REMARKS<%}%></div></td>
  </tr>
  <%//System.out.println(vRetResult);
  String strGradeColor = null;//for UDMC, if not pass, i have to make it red.
  boolean bolIsUDMC = strSchCode.startsWith("UDMC");
  
for(; i<vRetResult.size();++i){// this is for page wise display.
	vEnrlInfo = (Vector)vRetResult.elementAt(i);
if(iNoOfRowPerPg <= 0) {
	bolShowPageBreak = true;
	break;
}
else 
	bolShowPageBreak = false;
	
	for(int k=0; k<vEnrlInfo.size(); ++k){
	if( k > 0) k -= 4;
	--iNoOfRowPerPg;
	%>
  <tr>
    <td height="24" class="thinborder">
      <% if(k ==0){%>
      <%=iStudCount++%> <%=(String)vEnrlInfo.elementAt(k+1)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td class="thinborder">
      <% if(k ==0){%>
      <%=(String)vEnrlInfo.elementAt(k+2)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td class="thinborder"><%=(String)vEnrlInfo.elementAt(k+4)%></td>
<%
if(!bolIsUDMC)
	strGradeColor = "";
else {
	strGradeColor = (String)vEnrlInfo.elementAt(k+5);
	if(strGradeColor.startsWith("1") || strGradeColor.startsWith("2") || strGradeColor.startsWith("3") || strGradeColor.startsWith("4") || strGradeColor.toLowerCase().startsWith("p"))
		strGradeColor = "";
	else	
		strGradeColor = " style='color=red'";
}%>
    <td align="center" class="thinborder"<%=strGradeColor%>><%=(String)vEnrlInfo.elementAt(k+5)%></td>
    <td class="thinborder">
      <%if( (k+6) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+6)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
<%
strGradeColor = "";
if(bolIsUDMC && (k+6) < vEnrlInfo.size()){
	strGradeColor = (String)vEnrlInfo.elementAt(k+7);
	if(strGradeColor.startsWith("1") || strGradeColor.startsWith("2") || strGradeColor.startsWith("3") || strGradeColor.startsWith("4") || strGradeColor.toLowerCase().startsWith("p"))
		strGradeColor = "";
	else	
		strGradeColor = " style='color=red'";
}%>
    <td align="center" class="thinborder"<%=strGradeColor%>>
      <%if( (k+6) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+7)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td class="thinborder">
      <%if( (k+8) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+8)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
<%
strGradeColor = "";
if(bolIsUDMC && (k+8) < vEnrlInfo.size()){
	strGradeColor = (String)vEnrlInfo.elementAt(k+9);
	if(strGradeColor.startsWith("1") || strGradeColor.startsWith("2") || strGradeColor.startsWith("3") || strGradeColor.startsWith("4") || strGradeColor.toLowerCase().startsWith("p"))
		strGradeColor = "";
	else	
		strGradeColor = " style='color=red'";
}%>
    <td align="center" class="thinborder"<%=strGradeColor%>>
      <%if( (k+8) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+9)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td class="thinborder">
      <%if( (k+10) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+10)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
<%
strGradeColor = "";
if(bolIsUDMC && (k+10) < vEnrlInfo.size()){
	strGradeColor = (String)vEnrlInfo.elementAt(k+11);
	if(strGradeColor.startsWith("1") || strGradeColor.startsWith("2") || strGradeColor.startsWith("3") || strGradeColor.startsWith("4") || strGradeColor.toLowerCase().startsWith("p"))
		strGradeColor = "";
	else	
		strGradeColor = " style='color=red'";
}%>
    <td align="center" class="thinborder"<%=strGradeColor%>>
      <%if( (k+10) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+11)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td class="thinborder">
      <%if( (k+12) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+12)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
<%
strGradeColor = "";
if(bolIsUDMC && (k+12) < vEnrlInfo.size()){
	strGradeColor = (String)vEnrlInfo.elementAt(k+13);
	if(strGradeColor.startsWith("1") || strGradeColor.startsWith("2") || strGradeColor.startsWith("3") || strGradeColor.startsWith("4") || strGradeColor.toLowerCase().startsWith("p"))
		strGradeColor = "";
	else	
		strGradeColor = " style='color=red'";
}%>
    <td align="center" class="thinborder"<%=strGradeColor%>>
      <%if( (k+13) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+13)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td class="thinborder">
      <%if( (k+14) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+14)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
<%
strGradeColor = "";
if(bolIsUDMC && (k+14) < vEnrlInfo.size()){
	strGradeColor = (String)vEnrlInfo.elementAt(k+15);
	if(strGradeColor.startsWith("1") || strGradeColor.startsWith("2") || strGradeColor.startsWith("3") || strGradeColor.startsWith("4") || strGradeColor.toLowerCase().startsWith("p"))
		strGradeColor = "";
	else	
		strGradeColor = " style='color=red'";
}%>
    <td align="center" class="thinborder"<%=strGradeColor%>>
      <%if( (k+14) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+15)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td class="thinborder">
      <%if( (k+16) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+16)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
<%
strGradeColor = "";
if(bolIsUDMC && (k+16) < vEnrlInfo.size()){
	strGradeColor = (String)vEnrlInfo.elementAt(k+17);
	if(strGradeColor.startsWith("1") || strGradeColor.startsWith("2") || strGradeColor.startsWith("3") || strGradeColor.startsWith("4") || strGradeColor.toLowerCase().startsWith("p"))
		strGradeColor = "";
	else	
		strGradeColor = " style='color=red'";
}%>
    <td align="center" class="thinborder"<%=strGradeColor%>>
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
<%
strGradeColor = "";
if(bolIsUDMC && (k+18) < vEnrlInfo.size()){
	strGradeColor = (String)vEnrlInfo.elementAt(k+19);
	if(strGradeColor.startsWith("1") || strGradeColor.startsWith("2") || strGradeColor.startsWith("3") || strGradeColor.startsWith("4") || strGradeColor.toLowerCase().startsWith("p"))
		strGradeColor = "";
	else	
		strGradeColor = " style='color=red'";
}%>
    <td align="center" class="thinborder"<%=strGradeColor%>>
      <%if( (k+18) < vEnrlInfo.size()){%>
      <%=(String)vEnrlInfo.elementAt(k+19)%>
      <%}else{%>
      &nbsp;
      <%}%>
    </td>
    <td align="center" class="thinborder">
      <% if(k ==0){%>
      <%=(String)vEnrlInfo.elementAt(k+3)%>
      <%}else{%>

      &nbsp;
      <%}%>
    </td>
  </tr>
  <%
 k = k+19;}
 }//end of print per page.%>
</table>
<table width="1136" border="0" cellspacing="0" cellpadding="0">
<%if(strSchCode.startsWith("CGH")){%>
  <tr>
	<td>&nbsp;</td>
	<td align="right"><%=strPgCountDisp%></td>
  </tr>
<%}else if(strSchCode.startsWith("UDMC")) {//print registrar name.%>
  <tr>
	<td><%=strPgCountDisp%></td>
	<td align="right"><br>
	____________________________<br>
	Minda O. Gnilo &nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br>
	Registrar&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </td>
  </tr>
<%}else{%>
  <tr>
    <td height="20" valign="bottom"><%if(strSchCode.startsWith("VMUF")) {%>Example Abbreviation:<%}%>
	<td width="532" align="right"><%=strPgCountDisp%></td>
  </tr>
  <tr>
    <td width="604">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<%if(strSchCode.startsWith("VMUF")) {%>Engl 101 - English 1 : Math 101 - Mathematics 1: Fil 101 - FIlipino 1<%}%></td>
    <td>&nbsp;</td>
  </tr>
<%}%>
</table>
<!-- introduce page break here -->
<% if(bolShowPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//only if it is not last page.

}//end of printing.

if(strSchCode.startsWith("PHILCST")){%>
<table width="1136" border="0" cellspacing="0" cellpadding="0">
  <tr>
	<td></td>
	<td align="right"><br>
	____________________________<br>
	Mrs. Gina Elena F. Gironella &nbsp;  &nbsp; <br>
	Registrar&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </td>
  </tr>
</table>
<%}%>
<script language="JavaScript">
alert("Total no of pages to print : <%=iTotalNoOfPage%>");
//window.print();

</script>
</body>
</html>
<%
dbOP.cleanUP();
%>