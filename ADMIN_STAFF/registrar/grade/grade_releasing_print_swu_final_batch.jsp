	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
	<title>Untitled Document</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style type="text/css">
	@media print { 
	  @page {
			margin-bottom:.1in;
			margin-top:0in;
			margin-left:.5in;
			margin-right:.5in;
		}
	}
	<!--
	body {
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
		font-size: 9px;
	}
	td {
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
		font-size: 9px;
	}
	th {
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
		font-size: 9px;
	}
		TABLE.thinborder {
			border-top: solid 1px #000000;
			border-right: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
			font-size: 9px;
		}
		TABLE.thinborderALL {
			border-top: solid 1px #000000;
			border-bottom: solid 1px #000000;
			border-left: solid 1px #000000;
			border-right: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
			font-size: 9px;
		}
		TD.thinborder {
			border-left: solid 1px #000000;
			border-bottom: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
			font-size: 9px;
		}
	
		TD.thinborderBottom {
			border-bottom: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
			font-size: 9px;
		}
	-->
	</style>
	
	</head>
	<script language="javascript">
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';	
		document.bgColor = "#FFFFFF";
	}
	var strMaxPage = null;
	var objLabel   = null;
	function ShowProgress(pageCount, maxPage) {
		if(objLabel == null) {
			objLabel = document.getElementById("page_progress");
			strMaxPage = maxPage;
		}
		if(!objLabel)
			return;
		var strShowProgress = pageCount+" of "+strMaxPage;
		objLabel.innerHTML = strShowProgress;
	}
	</script>
<body onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">

<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>

<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	String strStudInfoList = (String)request.getSession(false).getAttribute("stud_list");
	if(strStudInfoList == null || strStudInfoList.length() == 0) {
		return; 
	}

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	

	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	String strErrMsg  = null;
	String strTemp    = null;
	java.sql.ResultSet rs = null;
	
//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"), 
								"Admin/staff-Registrar Management-GRADES-Grade Releasing print", "grade_releasing_print.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
String[] astrConvertSem = {"SUMMER", "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER", "FOURTH SEMESTER"};	
	
GradeSystem GS        = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
String strSYFrom      = request.getParameter("sy_from");
String strSYTo        = request.getParameter("sy_to");
String strSemester    = request.getParameter("semester");
String strStudID      = null;
String strGradeFor    = request.getParameter("grade_for");
String strTermName    = request.getParameter("sem_name");
String strMailAddress = null;

int iPageCount = 1;
//get student information first before getting grade details.
Vector vStudInfo =  null;//pmtUtil.getStudBasicInfoOLD(dbOP, strStudID, strSYFrom, strSYTo, strSemester);

//System.out.println(vStudInfo);
Vector vGradeDetail = null;
Vector vAdditionalInfo = null;
Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;

if (strSchCode.startsWith("CPU")){
	bolIncludeSchedule = true;
}

Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);
while(vStudList.size() > 0) {///wraps the whole page here.. 
//System.out.println("Pirnting student : "+vStudList.elementAt(0));
	strStudID = (String)vStudList.remove(0);
//System.out.print("      Remaining to print : "+vStudList.size());
	vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, strStudID, strSYFrom, strSYTo, strSemester);
	if(vStudInfo == null)
		continue;

if(WI.fillTextValue("print_report_card").length() > 0){
	strTemp = "select RES_HOUSE_NO, RES_CITY, RES_PROVIENCE, RES_COUNTRY, RES_ZIP from INFO_CONTACT where USER_INDEX = "+(String)vStudInfo.elementAt(0);	
	strMailAddress = null;
	rs = dbOP.executeQuery(strTemp);
	if(rs.next())
		strMailAddress = WI.getStrValue(rs.getString(1)) + "<br>"+WI.getStrValue(rs.getString(5))+
			WI.getStrValue(rs.getString(2), ", ", "", "")+WI.getStrValue(rs.getString(3),", ","","");
	rs.close();
}
	
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0), strGradeFor, strSYFrom, strSYTo, strSemester, false, true, true, false);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	vEditInfo = pif.viewPermStudPersonalInfo(dbOP,strStudID);

	if(strSchCode == null)
		strSchCode = "";
	
	if(strErrMsg == null) 
		strErrMsg = "";
	
//	double fGWA = 0d;
//	
//	if(WI.fillTextValue("show_gwa").equals("1")) {
//		fGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0), strSYFrom, strSYTo, strSemester, (String)vStudInfo.elementAt(6),
//				(String)vStudInfo.elementAt(7),null);
//	
//	}

//	double dTotalUnits = 0d;
	
	
//	boolean bolIsCGH = false;
//	if(strSchCode.startsWith("CGH"))
//		bolIsCGH = true;
	
//	boolean bolIsCollegeOnly = false;
//	if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH"))
//		bolIsCollegeOnly = true;
	
	/////i have to put parenthesis for math and english enrichment.
	Vector vMathEnglEnrichment = null;
	boolean bolPutParanthesis = false;
	if(vGradeDetail != null) {
		vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
	}
	//System.out.println(strErrMsg);
//	if(strSchCode.startsWith("UDMC") && (strErrMsg == null || strErrMsg.length() == 0) ) {
//		enrollment.ReportRegistrar RR = new enrollment.ReportRegistrar();
//		RR.operateOnGradeReleasePrint(dbOP, request, 1);	
//	}


boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
	%>
	
<script language="javascript">
	ShowProgress(<%=iPageCount++%>, <%=vStudList.size() + 1%>);
</script>
<!-- End of printing information -->


	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr >
		  <td height="20" align="center"><%=strErrMsg%></td>
		</tr>
	</table>
	
	<%
	if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr>
		<td width="12%">&nbsp;</td>
		<td width="18%"><%=strStudID%></td>		
		<td width="50%"><%=(String)vStudInfo.elementAt(1)%></td>	  
	  	<td width="20%"><%=(String)vStudInfo.elementAt(2)%><%=WI.getStrValue((String)vStudInfo.elementAt(3)," MAJOR IN ","","").toUpperCase()%>
		<%=WI.getStrValue((String)vStudInfo.elementAt(4)," - ","","")%>		</td>
	</tr>
</table>
<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
	
	<tr>
		<td valign="top" height="180">
			<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td rowspan="2">&nbsp;</td>
				<td width="55%" height="25" align="center" valign="bottom">&nbsp;</td>
				<Td colspan="3" rowspan="2">&nbsp;</Td>
				<Td rowspan="2" width="10%">&nbsp;</Td>
			</tr>
			<tr>
				<%
			if(Integer.parseInt(WI.fillTextValue("semester")) == 0)
				strTemp = WI.fillTextValue("sy_to");
			else
				strTemp = WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");
			%>
			    <td align="center" valign="bottom">
				<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> &nbsp; &nbsp; &nbsp; 
				<%=strTemp%>
				</td>
			</tr>
			
<%
int iSubjCount = 0;
int iRowSize = 8;
int k = 0;

String strGradeValue = null;
String strSubCode    = null; //System.out.println(vGradeDetail);
for(int i=0; i< vGradeDetail.size(); i +=iRowSize){
	++iSubjCount;
	strSubCode = (String)vGradeDetail.elementAt(i + 1);
	
	if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
		bolPutParanthesis = true;
		try {
			double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(i + 5));			
			bolPutParanthesis = true; 
			if(dGrade < 5d)
				vGradeDetail.setElementAt("(3.0)",i + 3);
			else 
				vGradeDetail.setElementAt("(0.0)",i + 3);			
		}
		catch(Exception e){vGradeDetail.setElementAt("(0.0)",i + 3);}
	}
	else	
		bolPutParanthesis = false;	



if(vGradeDetail.elementAt(i) == null) {	
		strTemp = " colspan=3";
}else
	strTemp = "";
//added to show grade not verified instead of grade and remark.
//System.out.println("I am here. :"+vGradeDetail.elementAt(i + 7));
if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal) {	
		strTemp = " colspan=3";
	vGradeDetail.setElementAt(null,i);
	vGradeDetail.setElementAt("Grade not verified", i + 5);
}

strGradeValue = (String)vGradeDetail.elementAt(i+5);

%>
  <tr>
		<td width="15%"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
		<td ><%=((String)vGradeDetail.elementAt(i+2)).toUpperCase()%></td>
		<td width="7%" <%=strTemp%> align="center"><%=strGradeValue%></td>
<%
if(strTemp.length() == 0){
strErrMsg = (String)vGradeDetail.elementAt(i + 5);
strTemp = null;
if(vGradeDetail.size() > (i + 5 + 8) && strErrMsg != null && 
		( (strErrMsg.toLowerCase().indexOf("inc") == -1 || strErrMsg.toLowerCase().indexOf("inr") == -1 || strErrMsg.toLowerCase().indexOf("ine") == -1) ) &&
		((String)vGradeDetail.elementAt(i + 1)).compareTo((String)vGradeDetail.elementAt(i + 1 + 8)) == 0 ){ //sub code,
		strTemp = (String)vGradeDetail.elementAt(i + 3 + 8);		
      	strErrMsg = (String)vGradeDetail.elementAt(i + 5 + 8);
		i += 8;
}else
	strErrMsg = "";
%>
		<td width="7%" align="center"><%=strErrMsg%></td>
<%
if(strTemp == null)
	strTemp = WI.getStrValue((String)vGradeDetail.elementAt(i + 3),"0");
%>
        <td width="6%" align="right">&nbsp; <%=WI.getStrValue(strTemp)%></td>
<%}%>
		<td>&nbsp;</td>	
  </tr>
	  
<%} // end for loop%>
	
	<tr><td colspan="6" align="center"> 
	-swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu--swu-  </td></tr>
</table>
		</td>
	</tr>
</table>


<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td valign="top" width="19%"><!--<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1).toUpperCase()%><br>-->
		<%=WI.getTodaysDateTime()%></td>	  	
	    <td width="81%" valign="top"><%=WI.getStrValue(strMailAddress)%></td>
	</tr>	
</table>

<%}//only if vStudInfo and vGradeDetail are not null%>

<%if(vStudList.size() > 0) {%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>


<%}//end of while loop... %>

</body>
</html>

<%
dbOP.cleanUP();
%>