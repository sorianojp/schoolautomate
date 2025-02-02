<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.ReportRegistrar, enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
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
    TD.thinborderBOTTOM {
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

    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
-->
</style>


</head>

<body >

<%
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Certification","grade_certificate.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.



request.getSession(false).setAttribute("checker",WI.fillTextValue("checker"));
request.getSession(false).setAttribute("designation",WI.fillTextValue("designation"));
request.getSession(false).setAttribute("registrar",WI.fillTextValue("registrar"));

String strGender  = null;

GradeSystem GS = new GradeSystem();
ReportRegistrar rr = new ReportRegistrar();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
Vector vRetResult  = null;
Vector vSemester = new Vector();
String[] astrConvertSem={"Summer", "1st Sem","2nd Sem","3rd Sem"};
if (!rr.saveAddrGradeCert(dbOP,request))
	strErrMsg = rr.getErrMsg();

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
String strCollege = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(6));

Vector vGradeDetail = null;
String strDegreeType = null;// for doctoral , it should be HOURS not units.
if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else {
	strGender = ((String)vStudInfo.elementAt(13)).toLowerCase();
	strDegreeType = (String)vStudInfo.elementAt(10);//1 = masteral, 2 = doctor of medicine.
}

String strSem = null;
if (WI.fillTextValue("first_sem").length() == 1) {
	vSemester.addElement(WI.fillTextValue("sy_from"));
	vSemester.addElement(WI.fillTextValue("sy_to"));
	vSemester.addElement("1");
	strSem = "1";
}
if (WI.fillTextValue("second_sem").length() == 1) {
	vSemester.addElement(WI.fillTextValue("sy_from"));
	vSemester.addElement(WI.fillTextValue("sy_to"));
	vSemester.addElement("2");
	strSem = "2";
}
if (WI.fillTextValue("third_sem").length() == 1) {
	vSemester.addElement(WI.fillTextValue("sy_from"));
	vSemester.addElement(WI.fillTextValue("sy_to"));
	vSemester.addElement("3");
	strSem = "3";
}
if (WI.fillTextValue("summer").length() == 1) {
	vSemester.addElement(WI.fillTextValue("sy_from"));
	vSemester.addElement(WI.fillTextValue("sy_to"));
	vSemester.addElement("0");
	strSem = "0";
}
//2nd line.
if (WI.fillTextValue("first_sem2").length() == 1) {
	vSemester.addElement(WI.fillTextValue("sy_from2"));
	vSemester.addElement(WI.fillTextValue("sy_to2"));
	vSemester.addElement("1");
	strSem = "1";
}
if (WI.fillTextValue("second_sem2").length() == 1) {
	vSemester.addElement(WI.fillTextValue("sy_from2"));
	vSemester.addElement(WI.fillTextValue("sy_to2"));
	vSemester.addElement("2");
	strSem = "2";
}
if (WI.fillTextValue("third_sem2").length() == 1) {
	vSemester.addElement(WI.fillTextValue("sy_from2"));
	vSemester.addElement(WI.fillTextValue("sy_to2"));
	vSemester.addElement("3");
	strSem = "3";
}
if (WI.fillTextValue("summer2").length() == 1) {
	vSemester.addElement(WI.fillTextValue("sy_from2"));
	vSemester.addElement(WI.fillTextValue("sy_to2"));
	vSemester.addElement("0");
	strSem = "0";
}

//for non university schools, show College of registrar.
boolean bolIsCollege = false;
boolean bolIsCGH     = false;
if(strSchCode.startsWith("CGH"))
	bolIsCGH = true;
boolean bolIsSACI    = strSchCode.startsWith("UDMC");


if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("CGH")  || strSchCode.startsWith("UDMC"))
	bolIsCollege = true;

double dGWA = 0d;

String strExtraTermCon = null;
if(vSemester.size() > 0)
	strExtraTermCon = CommonUtil.convertVectorToCSV(vSemester);

//System.out.println(strExtraTermCon);
if(WI.fillTextValue("show_gwa").compareTo("1") ==0 && bolIsCGH)
	dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
			request.getParameter("sy_from"),request.getParameter("sy_to"),strSem,
			(String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(7),strExtraTermCon);


/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;

String strSubCode = null;//this is added for CGH to
if(vStudInfo != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}


boolean bolShowIP = false;//show grades not yet encoded..
if( WI.fillTextValue("show_inprogress").length() > 0)
	bolShowIP = true;

if(vStudInfo != null && vStudInfo.size() > 0){
	String strSYFrom   = request.getParameter("sy_from");

	String strSQLQuery = "select PRINT_INDEX from TRACK_PRINTING where STUD_INDEX = "+(String)vStudInfo.elementAt(0)+
		" and PRINT_MODULE = 1 and SY_FROM = "+strSYFrom +" and SEMESTER="+strSem+" and DATE_PRINTED='"+
		WI.getTodaysDate()+"'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null) {
		strSQLQuery = "insert into TRACK_PRINTING (STUD_INDEX,PRINT_MODULE,SY_FROM,SEMESTER,DATE_PRINTED,PRINTED_BY) values ("+(String)vStudInfo.elementAt(0)+
			",1,"+strSYFrom+","+strSem+",'"+WI.getTodaysDate()+"',"+(String)request.getSession(false).getAttribute("userIndex")+")";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
//}


int iIndexOf = 0;
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="45%" height="18" align="center" style="font-size:12px "><p>&nbsp;</p>
      <p>&nbsp;</p>
      <p>&nbsp;</p>
      <p>&nbsp;</p>
      <p>&nbsp;</p>
      <p>&nbsp;</p>
      <p>&nbsp;</p>
      <p>&nbsp;</p>
      <p>&nbsp;</p>
	  <p align="right"><%=WI.getTodaysDate(6)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p>
      <p><strong><br>
        <br>
	      <font size="3"><u>C</u> <u>E</u> <u>R</u> <u>T</u> <u>I</u> <u>F</u> <u>I</u> <u>C</u> <u>A</u> <u>T</u> <u>I</u> <u>O</u> <u>N</u> </font>

	        </strong><br>
        <br>
	&nbsp;</p></td>
  </tr>
  <tr>
    <td height="20" valign="bottom" style="font-size:12px; font-weight:bold"><br>TO WHOM IT MAY CONCERN: <br>
      &nbsp;</td>
  </tr>
<tr>
    <td height="25" valign="bottom" style="line-height:20px;font-size:12px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;This is to certify that based on records on file,      <strong><%=((String)vStudInfo.elementAt(1)).toUpperCase()%></strong> had cross enrolled in this University<strong>
    </strong>
	   with the following subjects and corresponding grades and units.
	  <%=WI.fillTextValue("purpose")%>	</td>
  </tr>
<tr>
  <td height="10" valign="bottom" >&nbsp;</td>
</tr>
</table>
<%if(bolIsCGH){%>
<%}%>

<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <td width="15%" height="25" align="center" class="thinborder"><strong><font size="1">SUBJECT CODE </font></strong></td>
    <td width="45%" align="center" class="thinborder"><font size="1"><strong><%if(bolIsCGH){%>DESCRIPTIVE TITLE<%}else{%>SUBJECTS<%}%></strong></font></td>
    <td width="15%" align="center" class="thinborder"><font size="1"><strong><%if(bolIsCGH){%>GENERAL AVERAGE<%}else{%>FINAL GRADES<%}%></strong></font></td>
<% if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC")){%>
    <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">PERCENTAGE GRADE </td>
    <%}%>
    <td width="10%" align="center" class="thinborder"><font size="1"><b>
	  <%if(bolIsCGH){%>CREDIT UNITS
      <%}else if(strDegreeType != null && strDegreeType.compareTo("2") == 0){%>
      HOURS
      <%}else{%>
      UNITS
      <%}%>
      </b></font></td>
  </tr>
  <%
	int j = 0;
	String strGradeValue = null;
	for(int i = 0; i < vSemester.size(); i += 3){
		vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),
						"final",(String)vSemester.elementAt(i),(String)vSemester.elementAt(i + 1),
						(String)vSemester.elementAt(i + 2), true, bolShowIP, false, false);

		if(vGradeDetail == null)
			strErrMsg = GS.getErrMsg();

		if(strErrMsg == null) strErrMsg = "";//System.out.println(vGradeDetail);
%>
  <tr>
    <td  height="25" colspan="5" class="thinborder"> <table width="99%" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
          <td width="1%">&nbsp;</td>
          <td height="20" colspan="2"><u><%=astrConvertSem[Integer.parseInt((String)vSemester.elementAt(i + 2))]%> , <%=(String)vSemester.elementAt(i)%> - <%=(String)vSemester.elementAt(i + 1)%> </u>
		  <%
	if(WI.fillTextValue("show_gwa").compareTo("1") ==0 && !bolIsCGH)  {
		dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
									(String)vSemester.elementAt(i),(String)vSemester.elementAt(i + 1),(String)vSemester.elementAt(i + 2),
									(String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(7),null);
	if(dGWA > 0d){%>
	(GWA : <strong><%=CommonUtil.formatFloat(dGWA,true)%></strong>)
	<%}
	}%></td>
          <td><div align="center"></div></td>
<% if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC")){%>
          <td>&nbsp;</td>
<%}%>
          <td><div align="center"></div></td>
        </tr>
        <%
	if (vGradeDetail !=null) {
		for(j=0; j< vGradeDetail.size(); j += 7){
			//I've to check if this is for math/english enrichment & if stud has passed(for CGH only)
			//if math/eng enrichment and passed, I have to put parantheris.
			strSubCode = (String)vGradeDetail.elementAt(j+1);
			/**if(vMathEnglEnrichment != null &&
				WI.getStrValue(vGradeDetail.elementAt(j+6)).toLowerCase().startsWith("p") &&
					vMathEnglEnrichment.indexOf(strSubCode) != -1)
				bolPutParanthesis = true;
			else
				bolPutParanthesis = false;
			**/
			if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
				bolPutParanthesis = true;
				try {
					double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(j + 5));
					//System.out.println(dGrade);
					bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
					if(dGrade < 5d)
						vGradeDetail.setElementAt("(3.0)",j + 3);
					else
						vGradeDetail.setElementAt("(0.0)",j + 3);

				}
				catch(Exception e){vGradeDetail.setElementAt("(0.0)",j + 3);}
			}
			else
				bolPutParanthesis = false;

		strGradeValue = (String)vGradeDetail.elementAt(j + 5);
		if(bolIsCGH && strGradeValue != null && (strGradeValue.endsWith(".00") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
			strGradeValue = strGradeValue+"0";
		if(bolPutParanthesis)
			strGradeValue = "("+strGradeValue+")";

		strTemp = (String)vGradeDetail.elementAt(j + 5);
		if(strGradeValue != null && strGradeValue.equals("Grade not encoded"))
			strGradeValue = "In Progress";
		%>
        <tr>
          <td>&nbsp;</td>
          <td width="15%" height="20"><%=(String)vGradeDetail.elementAt(j + 1)%> </td>
          <td width="45%"><%=(String)vGradeDetail.elementAt(j + 2)%></td>
          <td width="15%"><div align="center"><%=strGradeValue%>&nbsp;</div></td>
          <td width="15%" align="center">
		  <%
		  iIndexOf = GS.vCGHGrade.indexOf(vGradeDetail.elementAt(j));
		  if(iIndexOf > -1) {		  
		  String grd= WI.getStrValue(GS.vCGHGrade.elementAt(iIndexOf + 1));
		  if (grd.indexOf(".")!=-1) {		 
		  %>
		  	<%=WI.getStrValue(GS.vCGHGrade.elementAt(iIndexOf + 1))%>
		  <%
		  }
		  }
		  %>

		  </td>
          <td width="10%"><div align="center">
<%
if(strGradeValue != null && strGradeValue.equals("In Progress"))
	strGradeValue = "&nbsp;";
else {
	strGradeValue = WI.getStrValue((String)vGradeDetail.elementAt(j + 3),"0");
}
%>
		  <%=strGradeValue/**(String)vGradeDetail.elementAt(j + 3)**/%>&nbsp;</div></td>
        </tr>
        <%} //end inner for loop
}else{%>
        <td  height="20" colspan="6" > &nbsp; <%=WI.getStrValue(strErrMsg,"")%></td>
        <%}%>
      </table></td>
  </tr>
  <%} // for (i <vSemester.size() %>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%
int iFormat = 1;
%>
  <tr align="right">
    <td width="1%" height="20" >&nbsp;</td>
    <td colspan="3"><br>      &nbsp;</td>
  </tr>
  <tr valign="top">
    <td height="94">&nbsp;</td>
    <td colspan="3" style="font-size:12px;">
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
This certification is issued upon request of   <strong><%=((String)vStudInfo.elementAt(1)).toUpperCase()%></strong> <%=WI.fillTextValue("purpose_footer")%>	</td>
  </tr>
  <tr align="right">
    <td  height="12" rowspan="2" >&nbsp;</td>
    <td height="12" colspan="2" rowspan="2" valign="top">&nbsp;</td>
    <td width="36%" height="6" align="center" valign="top" style="font-size:12px;"><span class="thinborderBOTTOM">__<u><%=WI.fillTextValue("registrar")%></u>__</span></td>
  </tr>
  <tr align="right">
    <td height="6" valign="top" align="center" style="font-size:10px;">University Registrar</td>
  </tr>
  <tr><td>&nbsp;</td><td width="33%">&nbsp;</td><td width="30%">&nbsp;</td><td>&nbsp;</td></tr>
  <tr><td>&nbsp;</td>
  <td style="font-size:12px "> <div align="center">__<u>FERDINAND C. SOMIDO, PhD</u>__</div></td><td>&nbsp;</td><td>&nbsp;</td></tr>
  <tr><td>&nbsp;</td>
  <td style="font-size:10px "><div align="center">Executive School Director</div></td>
  <td>&nbsp;</td><td>&nbsp;</td></tr>
  
</table>
<%
}//if(vStudInfo != null && vStudInfo.size() > 0)%>
<script language="JavaScript">
	window.print();
</script>

</body>
</html>
<%dbOP.cleanUP();%>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         