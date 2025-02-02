<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.ReportRegistrar, enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	if(strSchCode.startsWith("UL")){%>
		<jsp:forward page="./grade_certificate_print_ul.jsp" />
	<%return;}
	if(strSchCode.startsWith("fatima")){%>
		<jsp:forward page="./grade_certificate_print_fatima.jsp" />
	<%return;}

boolean bolIsBatchPrint = false;
if(WI.fillTextValue("batch_print").equals("1"))
	bolIsBatchPrint = true;

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:8pt;
	/*font-size: <%=WI.fillTextValue("font_size")%>px;*/
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	/*font-size: <%=WI.fillTextValue("font_size")%>px;*/
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	/*font-size: <%=WI.fillTextValue("font_size")%>px;*/
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	/*font-size: <%=WI.fillTextValue("font_size")%>px;*/
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	/*font-size: <%=WI.fillTextValue("font_size")%>px;*/
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	/*font-size: <%=WI.fillTextValue("font_size")%>px;*/
    }

    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	/*font-size: <%=WI.fillTextValue("font_size")%>px;*/
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
		dbOP = new DBOperation();
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
int iAccessLevel = 2;//

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

GradeSystem GS = new GradeSystem();
ReportRegistrar rr = new ReportRegistrar();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
Vector vRetResult  = null;
Vector vSemester = new Vector();
String[] astrConvertSem={"Summer", "1st Sem","2nd Sem","3rd Sem"};
String strYrLevel      = null;
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
	strDegreeType = (String)vStudInfo.elementAt(10);//1 = masteral, 2 = doctor of medicine.
	strYrLevel    = (String)vStudInfo.elementAt(4);
}

String strSem = null;
if (WI.fillTextValue("first_sem").length() == 1) {
	vSemester.addElement("1");
	strSem = "1";
}
if (WI.fillTextValue("second_sem").length() == 1) {
	vSemester.addElement("2");
	strSem = "2";
}
if (WI.fillTextValue("third_sem").length() == 1) {
	vSemester.addElement("3");
	strSem = "3";
}
if (WI.fillTextValue("summer").length() == 1) {
	vSemester.addElement("0");
	strSem = "0";
}

//for non university schools, show College of registrar.
boolean bolIsCollege = false;
boolean bolIsCGH     = false;
if(strSchCode.startsWith("CGH") || strSchCode.startsWith("EAC"))
	bolIsCGH = true;
boolean bolIsSACI    = strSchCode.startsWith("UDMC");


if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("CGH")  || strSchCode.startsWith("UDMC")  || strSchCode.startsWith("EAC"))
	bolIsCollege = true;
if(strSchCode.startsWith("CGH") && WI.fillTextValue("stud_id").length() > 0 && vStudInfo != null && vStudInfo.size() > 0) {
	strTemp = (String)vStudInfo.elementAt(0);//dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
	if(strTemp != null) {
		strTemp = "select year_level from stud_curriculum_hist where user_index = "+strTemp+
		" and is_valid =1 and sy_from = "+request.getParameter("sy_from")+" and semester = "+strSem;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp != null)
			strYrLevel = strTemp;
	}
}

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

	String strParentName = null;
	String strAddress = null;
	

		String strSQLQuery = " select f_name, m_name,con_per_name, res_house_no, res_city, res_provience, " + //4-7
        	" res_country, res_zip from info_contact " +
        	" left join info_parent on (info_parent.user_index = info_contact.user_index) " +
        	" where info_contact.user_index = " + (String)vStudInfo.elementAt(0) ;
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			if(rs.getString(1) != null)
				strParentName = rs.getString(1);
			else if(rs.getString(2) != null)
				strParentName = rs.getString(2);
			else if(rs.getString(3) != null)
				strParentName = rs.getString(3);
			strAddress = rs.getString(4);
			if(strAddress != null) {
				if(rs.getString(5) != null) {
					strAddress = strAddress + "<br>"+rs.getString(5);
					if(rs.getString(6) != null) 
						strAddress = strAddress + ", "+rs.getString(6);
					if(rs.getString(7) != null) 
						strAddress = strAddress + " - "+rs.getString(7);
				}
			}
		}
		rs.close();

%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="18" >
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  		<tr>
    		<td width="50%">&nbsp;</td>
    		<td align="center"><%=WI.getTodaysDate(6)%></td>
  		</tr>
	</table>
	</td>
  </tr>
  <tr>
    <td height="18" ><strong>
	<%=strParentName%>
	<%if(strAddress != null) {%>
		<br><%=strAddress%>
	<%}%>
	</strong></td>
  </tr>
<!--  <tr>
    <td height="12" ><font size="1">&nbsp;</font></td>
  </tr>-->
<%
//if CGH, do not show the letter content, show only grade..
if(!bolIsCGH){%>
  <tr>
    <td height="20" valign="bottom" >&nbsp;</td>
  </tr>
  <tr>
    <td height="20" valign="bottom" >&nbsp;</td>
  </tr>
  <tr>
    <td height="20" valign="bottom" ><strong>Dear Sir/Madam<%//=strAddressee%>: </strong></td>
  </tr>
  <tr>
    <td height="25" >&nbsp;</td>
  </tr>
  <tr>
    <td height="25" >In
      accordance with the school's policy to ensure a smooth school-student-parent
      relationship, we respectfully submit the final grades of your son/daughter
      <strong><%=((String)vStudInfo.elementAt(1)).toUpperCase()%><%if(bolIsSACI){%>,<%=((String)vStudInfo.elementAt(2)).toUpperCase()%><%}%></strong>

	  who was enrolled at the <strong> <%if(bolIsSACI){%><%=vStudInfo.elementAt(16)%><%}else{%><%=((String)vStudInfo.elementAt(2)).toUpperCase()%><%}%></strong> during the <strong> <%=astrConvertSem[Integer.parseInt((String)vSemester.elementAt(0))]%>
      <% for (int i = 1; i <vSemester.size() ; ++i) {%>
      <%=" & " + astrConvertSem[Integer.parseInt((String)vSemester.elementAt(i))]%>
      <%}%>
      </strong>, School Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%> </strong> . <br>
      <br>
    </td>
  </tr>
<%}else{%>
<tr>
  <td height="10" valign="bottom" >&nbsp;</td>
</tr>
<tr>
    <td height="10" valign="bottom" >&nbsp;</td>
  </tr>
<%}%>
</table>


<%if(bolIsCGH){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="13%" height="19" >Student ID</td>
    <td width="32%" ><strong><%=request.getParameter("stud_id")%></strong></td>
    <td width="14%" >Course/Major</td>
    <td  colspan="2" ><strong><%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
  </tr>
  <tr>
    <td height="18" > Name</td>
    <td height="18" ><strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    <td height="18" >Year</td>
    <td width="13%" height="18" ><strong><%=WI.getStrValue(strYrLevel)%><%//=WI.getStrValue(vStudInfo.elementAt(4))%></strong></td>
    <td width="28%" height="18" >
	<%if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0d
		&& !strSchCode.startsWith("UDMC")){%>
		GWA : <strong><%=CommonUtil.formatFloat(dGWA,2)%></strong>
	<%}%></td>
  </tr>
  <tr>
    <td height="18" colspan="5" align="right">&nbsp;&nbsp;</td>
  </tr>
</table>
<%}%>



<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <td width="15%" height="25" align="center" class="thinborder"><strong>SUBJECT CODE</strong></td>
    <td width="40%" align="center" class="thinborder"><strong><%if(bolIsCGH){%>DESCRIPTIVE TITLE<%}else{%>SUBJECTS<%}%></strong></td>
    <td width="15%" align="center" class="thinborder"><strong><%if(bolIsCGH){%>GENERAL AVERAGE<%}else{%>FINAL GRADES<%}%></strong></td>
<% if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC")){%>
    <td width="15%" align="center" class="thinborder"><strong><%if(strSchCode.startsWith("CDD")){%>REMARKS<%}else if(bolIsCGH){%>COMPLETION GRADE<%}else{%>RE-EXAM<%}%></strong></td>
<%}%>
    <td width="15%" align="center" class="thinborder"><strong>
	  <%if(bolIsCGH){%>CREDIT UNITS
      <%}else if(strDegreeType != null && strDegreeType.compareTo("2") == 0){%>
      HOURS
      <%}else{%>
      UNITS
      <%}%>
      </strong></td>
  </tr>
  <%
	int j = 0;
	String strGradeValue = null;
	for(int i = 0; i < vSemester.size(); i++){
		vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),
						"final",request.getParameter("sy_from"),request.getParameter("sy_to"),
						(String)vSemester.elementAt(i), true, bolShowIP, false, false);

		if(vGradeDetail == null)
			strErrMsg = GS.getErrMsg();

		if(strErrMsg == null) strErrMsg = "";
%>
  <tr>
    <td  height="25" colspan="5" class="thinborder"> <table width="99%" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
          <td width="1%">&nbsp;</td>
          <td height="20" colspan="2"><u><%=astrConvertSem[Integer.parseInt((String)vSemester.elementAt(i))]%> , <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%> </u>
		  <%
	if(WI.fillTextValue("show_gwa").compareTo("1") ==0 && !bolIsCGH)  {
		dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
									request.getParameter("sy_from"),request.getParameter("sy_to"),(String)vSemester.elementAt(i),
									(String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(7),null);
	if(dGWA > 0d){%>
	(GWA : <strong><%=CommonUtil.formatFloat(dGWA,2)%></strong>)
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
		if(bolIsCGH && strGradeValue != null && (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
			strGradeValue = strGradeValue+"0";
		if(bolPutParanthesis)
			strGradeValue = "("+strGradeValue+")";

		strTemp = (String)vGradeDetail.elementAt(j + 5);
		if(strGradeValue != null && strGradeValue.equals("Grade not encoded"))
			strGradeValue = "In Progress";
		%>
        <tr>
          <td>&nbsp;</td>
          <td width="15%"><%=(String)vGradeDetail.elementAt(j + 1)%> </td>
          <td width="40%"><%=(String)vGradeDetail.elementAt(j + 2)%></td>
          <td width="15%"><div align="center"><%=strGradeValue%></div></td>
		  <%if(strSchCode.startsWith("CDD")) {%>
          	<td width="15%"><div align="center"><%=(String)vGradeDetail.elementAt(j + 6)%></div></td>
		  
<%} if (!strSchCode.startsWith("CPU") &&  !strSchCode.startsWith("UDMC")){%>
     <!--     <td width="15%" align="center">
		        <%//System.out.println(vGradeDetail.elementAt(j + 1)+" : Next Sub Code : "+vGradeDetail.elementAt(j + 1 + 7));
				//it is re-exam if student has INC and cleared in same semester,
				strTemp = null;
				if(vGradeDetail.size() > (j + 5 + 7) && vGradeDetail.elementAt(j + 5) != null && ((String)vGradeDetail.elementAt(j + 5)).toLowerCase().indexOf("inc") != -1 &&
					((String)vGradeDetail.elementAt(j + 1)).compareTo((String)vGradeDetail.elementAt(j + 1 + 7)) == 0 ){ //sub code,
						strTemp = (String)vGradeDetail.elementAt(j + 3 + 7);
					%>
				  <%=CommonUtil.formatFloat((String)vGradeDetail.elementAt(j + 5 + 7), true)%>
					<%j += 7;}%>
				
</td> -->
				<% } // remove for cpu

				// force strTemp = null  for CPU, UDMC or CGH -- it must be set to null for the schools want to remove re-exam.
				if (strSchCode.startsWith("CPU") || strSchCode.startsWith("UDMC") || bolIsCGH)
					strTemp= null;%>
          <td width="15%"><div align="center">
<%
if(strGradeValue != null && strGradeValue.equals("In Progress"))
	strGradeValue = "&nbsp;";
else {
	strGradeValue = WI.getStrValue((String)vGradeDetail.elementAt(j + 3),"0");
	//if(strGradeValue != null && strGradeValue.endsWith(".0"))
	//	strGradeValue = strGradeValue.substring(0, strGradeValue.length() - 2);
	//if(bolIsCGH && strGradeValue != null && strGradeValue.endsWith("0") && strGradeValue.length() > 1)
	//	strGradeValue = strGradeValue+"0";
	//if(bolPutParanthesis)
	//	strGradeValue = "(3.0)";
}
%>
		  <%=strGradeValue/**(String)vGradeDetail.elementAt(j + 3)**/%></div></td>
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
  <tr>
    <td colspan="9" height="10" >&nbsp;</td>
  </tr>
  <tr>
    <td colspan="9" height="10" >&nbsp;</td>
  </tr>
  <tr>
    <td width="2%" height="25" >&nbsp;</td>
    <td width="47%" valign="top"><%=request.getParameter("stud_id")%>
	<br />
	<%=(String)vStudInfo.elementAt(1)%>
	<br />
	<%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%><%=WI.getStrValue(strYrLevel," - ","","")%>
	</td>
    <td width="51%" valign="top" align="center">
   <div style="padding:0px; margin:0px;"><img src="./cdd_signature.jpg"></div>
   <div style="padding:0px; margin:0px;">
   <strong>JOSE S. MAGLEO III, REE, MSME</strong><br>
   Director, Student's Records and Support Services
   </div>
    <!-- <img src="./cdd_signature.gif"> --></td>
  </tr>
</table>
<%
}//if(vStudInfo != null && vStudInfo.size() > 0)
if(!bolIsBatchPrint){%>
<script language="JavaScript">
	window.print();
</script>
<%}%>

</body>
</html>
<%dbOP.cleanUP();%>
