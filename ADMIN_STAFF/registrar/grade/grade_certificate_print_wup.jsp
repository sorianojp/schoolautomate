<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.ReportRegistrar, enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

boolean bolIsBatchPrint = false;
//if(WI.fillTextValue("batch_print").equals("1"))
//	bolIsBatchPrint = true;

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
    TD.thinborderTOPBOTTOMRIGHT {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }



-->
</style>


</head>

<body onLoad="window.print()">

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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","GRADES",request.getRemoteAddr(),
							//							null);
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

String strSQLQuery = null;
boolean bolShowIP = false;//show grades not yet encoded..
if( WI.fillTextValue("show_inprogress").length() > 0)
	bolShowIP = true;

if(vStudInfo != null && vStudInfo.size() > 0){
	String strSYFrom   = request.getParameter("sy_from");

	strSQLQuery = "select PRINT_INDEX from TRACK_PRINTING where STUD_INDEX = "+(String)vStudInfo.elementAt(0)+
		" and PRINT_MODULE = 1 and SY_FROM = "+strSYFrom +" and SEMESTER="+strSem+" and DATE_PRINTED='"+
		WI.getTodaysDate()+"'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null) {
		strSQLQuery = "insert into TRACK_PRINTING (STUD_INDEX,PRINT_MODULE,SY_FROM,SEMESTER,DATE_PRINTED,PRINTED_BY) values ("+(String)vStudInfo.elementAt(0)+
			",1,"+strSYFrom+","+strSem+",'"+WI.getTodaysDate()+"',"+(String)request.getSession(false).getAttribute("userIndex")+")";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
//}


Vector vRemovalGSIndex   = new Vector();
Vector vSubmittedGSIndex = new Vector();
String strRemovalGrade = null;

strSQLQuery = "select gs_index,IS_REMOVAL_WUP,(select max(DATE_SUBMITTED_WUP) from faculty_load where sub_sec_index = g_sheet_final.sub_sec_index and faculty_load.is_valid = 1), "+
				"sub_sec_index from g_sheet_final where user_index_ = "+vStudInfo.elementAt(0)+" and is_valid = 1";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	if(rs.getInt(2) == 1)
		vRemovalGSIndex.addElement(rs.getString(1));
	if(rs.getString(4) == null)//migrated/encoded by reg :: show it.
		vSubmittedGSIndex.addElement(rs.getString(1));
	if(rs.getDate(3) != null)
		vSubmittedGSIndex.addElement(rs.getString(1));
}
rs.close();

%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="125">&nbsp;</td>
  </tr>
  <tr>
    <td width="45%" height="18" align="center" ><strong><font size="2">GRADE REPORT </font></strong>
	<br>
	<%=astrConvertSem[Integer.parseInt((String)vSemester.elementAt(0))]%> , <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
	</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="19" >&nbsp;</td>
    <td >&nbsp;</td>
  </tr>
  <tr>
    <td width="23%" height="19" >OFFICIAL GRADE REPORT OF: </td>
    <td width="77%" ><strong><%=((String)vStudInfo.elementAt(1)).toUpperCase()%></strong></td>
  </tr>
  <tr>
    <td height="18" >COURSE</td>
    <td height="18" ><%=(String)vStudInfo.elementAt(18)%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></td>
  </tr>
</table>

<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="15%" height="25" align="center" class="thinborderTOPBOTTOMRIGHT" style="font-size:9px; font-weight:bold">SUBJECT CODE</td>
    <td width="57%" align="center" class="thinborderTOPBOTTOMRIGHT" style="font-size:9px; font-weight:bold">DESCRIPTIVE TITLE</td>
    <td width="7%" align="center" class="thinborderTOPBOTTOMRIGHT" style="font-size:9px; font-weight:bold">GRADE</td>
    <td width="7%" align="center" class="thinborderTOPBOTTOMRIGHT" style="font-size:9px; font-weight:bold">REMOVAL</td>
    <td width="7%" align="center" class="thinborderTOPBOTTOMRIGHT" style="font-size:9px; font-weight:bold">UNITS</td>
    <td width="7%" align="center" class="thinborderTOPBOTTOM" style="font-size:9px; font-weight:bold">REMARKS</td>
  </tr>
  <%
	int j = 0;
	String strGradeValue = null;
		vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),
						"final",request.getParameter("sy_from"),request.getParameter("sy_to"),
						(String)vSemester.elementAt(0), true, bolShowIP, true, false);
		if(vGradeDetail == null) {%>
		  <tr>
			<td height="18" class="thinborderNONE" colspan="6"><%=GS.getErrMsg()%></td>
		  </tr>
		<%}else{
			for(j=0; j< vGradeDetail.size(); j += 8){
				strSubCode = (String)vGradeDetail.elementAt(j+1);
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
				//if(bolPutParanthesis)
				//	strGradeValue = "("+strGradeValue+")";
		
				strTemp = (String)vGradeDetail.elementAt(j + 5);
				if(strGradeValue != null && strGradeValue.equals("Grade not encoded"))
					strGradeValue = "In Progress";
				
				if(vRemovalGSIndex.indexOf(vGradeDetail.elementAt(j)) > -1) {
					strRemovalGrade = strGradeValue;
					strGradeValue = "&nbsp;";
				}
				else {
					strRemovalGrade = "&nbsp;";
				}
				
				//I have to now find if submitted or not.. 
				if(vSubmittedGSIndex.indexOf(WI.getStrValue(vGradeDetail.elementAt(j))) == -1) {
					strGradeValue = "NGS";
					vGradeDetail.setElementAt("NGS",j + 6);//remarks.
					vGradeDetail.setElementAt("&nbsp;",j + 3);//units.
				}
				else if(vGradeDetail.elementAt(j + 7) != null && vGradeDetail.elementAt(j + 7).equals("0")) {
					strGradeValue = "WDA";
					vGradeDetail.setElementAt("WDA",j + 6);
					vGradeDetail.setElementAt("&nbsp;",j + 3);
				}
					
				
				
			  %>
			  <tr>
				<td height="18" class="thinborderNONE"><%=(String)vGradeDetail.elementAt(j + 1)%></td>
				<td class="thinborderNONE"><%=(String)vGradeDetail.elementAt(j + 2)%></td>
				<td align="center" class="thinborderNONE"><%=strGradeValue%></td>
				<td align="center" class="thinborderNONE"><%=strRemovalGrade%></td>
				<%
				if(strGradeValue != null && strGradeValue.equals("In Progress"))
					strGradeValue = "&nbsp;";
				else {
					strGradeValue = WI.getStrValue((String)vGradeDetail.elementAt(j + 3),"0");
				}
				%>
				<td align="center" class="thinborderNONE"><%=strGradeValue%></td>
				<td align="center" class="thinborderNONE"><%=(String)vGradeDetail.elementAt(j + 6)%></td>
			  </tr>
		<%}
		}%>
			  <tr>
			    <td colspan="6" class="thinborderNONE" align="center">------------------------------------------------- NOTHING FOLLOWS -------------------------------------------------</td>
  			  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2" height="10" >Printed by: <u><%=request.getSession(false).getAttribute("first_name")%></u></td>
    <td >Certified Correct: </td>
  </tr>
  <tr>
    <td colspan="3" height="10" ><%=WI.getTodaysDateTime()%></td>
  </tr>
  <tr>
    <td colspan="3" height="10" >&nbsp;</td>
  </tr>
  <tr>
    <td width="7%" height="25" valign="top">Legend: </td>
    <td width="55%" valign="top">INC - Incomplete <br>
    NGS - No Grading Sheet <br>WDA - Waiting for Deans's Approval</td>
    <td width="38%" valign="top" align="center"><strong>JULIE V. CABLING</strong><br><font style="font-size:11px;">Officer in Charge</font></td>
  </tr>
</table>
<%}%>
</body>
</html>
<%dbOP.cleanUP();%>
