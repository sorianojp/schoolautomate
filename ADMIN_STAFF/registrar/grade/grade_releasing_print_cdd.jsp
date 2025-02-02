<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	String strTemp = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	//System.out.println("strSchCode "+strSchCode);
	if(strSchCode == null)
		strSchCode = "";
	

	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp2 = null;
	String strTemp3 = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Releasing print","grade_releasing_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
String[] astrConvertSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};

GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
						request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));

//System.out.println(vStudInfo);
Vector vGradeDetail = null;
Vector vAdditionalInfo = null;
Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;
//System.out.println(strSchCode);

if (strSchCode.startsWith("CPU")){
	bolIncludeSchedule = true;
}



if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	//get grade sheet release information.

	boolean bolIncludeEnrolledSubject = true;
	if(strSchCode.startsWith("WNU")){
		String strExcludeList = "#08-95138#,#08-94456#,#06-90163#,#95-02645#,#05-00356#,#08-94070#,#08-94472#,#07-90687#,#08-93114#,#07-91444#,#08-93878#,#07-92340#,#07-91577#,#07-92744#,#08-93053#,#06-90168#,#07-92697#,#07-91191#,#08-94889#,#08-94477#,#08-94853##05-03733#,#07-92704#,#07-92510#,#07-92297#,#06-02003#,#08-94071#,#07-92588#,#06-90221#,#84-02549#,#07-92008#,#08-94287#,#07-91517#,#09-1348-245#,#08-94156#,#07-92587#,#08-93021#,#07-91246#,#08-94747#,#06-90026#,#07-91855#";
		if(strExcludeList.indexOf("#"+request.getParameter("stud_id")+"#") > -1)
			bolIncludeEnrolledSubject = false;
	}
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),
											request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),true,bolIncludeEnrolledSubject,true,bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();

	student.StudentInfo studInfo = new student.StudentInfo();
	vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,(String)vStudInfo.elementAt(0));

//	System.out.println(vAdditionalInfo);
//	System.out.println(vStudInfo);

	enrollment.PersonalInfoManagement pif = new  enrollment.PersonalInfoManagement();
	vEditInfo = pif.viewPermStudPersonalInfo(dbOP,request.getParameter("stud_id"));
}


if(strSchCode == null)
	strSchCode = "";
//strSchCode = "AUF";

if(strErrMsg == null) strErrMsg = "";



double dGWA = 0d;

if(WI.fillTextValue("show_gwa").equals("1")) {
	dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
			request.getParameter("sy_from"),request.getParameter("sy_to"),
			request.getParameter("semester"), (String)vStudInfo.elementAt(6),
			(String)vStudInfo.elementAt(7),null);

}


double dTotalUnits = 0d;


boolean bolIsCGH = false;
if(strSchCode.startsWith("CGH"))
	bolIsCGH = true;
boolean bolIsDBTC = strSchCode.startsWith("DBTC");

boolean bolIsCollegeOnly = false;
if(strSchCode.startsWith("UDMC") || strSchCode.startsWith("CLDH") || strSchCode.startsWith("CSA"))
	bolIsCollegeOnly = true;

/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;
if(vGradeDetail != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}
//System.out.println(strErrMsg);
if(strSchCode.startsWith("UDMC") && (strErrMsg == null || strErrMsg.length() == 0) ) {
	enrollment.ReportRegistrar RR = new enrollment.ReportRegistrar();
	RR.operateOnGradeReleasePrint(dbOP, request, 1);	
}


boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
//System.out.println("bolIsFinal : "+bolIsFinal+"  grade_name : "+ WI.fillTextValue("grade_name"));


String strGradeCGH = null;
java.sql.PreparedStatement pstmtGetPercentGrade = dbOP.getPreparedStatement("select grade_cgh from g_sheet_final where gs_index = ?");
boolean bolIsCLDH  = strSchCode.startsWith("CLDH");
if(!bolIsFinal)
	bolIsCLDH = false;
if(strSchCode.startsWith("UL")) {
	bolIsCLDH = true;
}



%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8pt;
	margin:0in 0.2in 0in 0.2in;
}
</style>
</head>

<body <%if(!strSchCode.startsWith("DBTC") && WI.getStrValue(strErrMsg).length() ==0){%> onLoad="window.print()"<%}%>>
<div><%=strErrMsg%></div>


<%if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){%>
<!-- Student details -->
<div style="margin:1in 0in 0.4in 0in;">
<div style="float:left; width:70%;">NAME: <%=(String)vStudInfo.elementAt(1)%></div>
<div  style="float:left; width:30%;">ID: <%=request.getParameter("stud_id")%></div>
<div style="clear:both;"></div>

<div style="float:left; width:70%;">COURSE: <%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(4),"&nbsp;","","")%>
</div>
<div  style="float:left; width:30%;">SEM/SY: <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%> <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></div>
<div style="clear:both;"></div>
</div>

<!-- Student Grade details -->			
<div style="margin:0px 0px 0px 0px; height:2.7in;">
			  <%
			   int iSubjCount = 0;
			   int iRowSize = 8;
			   int k = 0;
			
			   if (bolIncludeSchedule)
					iRowSize =9;
			   Vector vScheduleDetails = null;
			
			String strGradeValue = null;
			String strSubCode    = null; //System.out.println(vGradeDetail);
			for(int i=0; i< vGradeDetail.size(); i +=iRowSize){
				++iSubjCount;
				strSubCode = (String)vGradeDetail.elementAt(i + 1);
			/**	if(vMathEnglEnrichment != null &&
					WI.getStrValue(vGradeDetail.elementAt(i+6)).toLowerCase().startsWith("p") &&
						vMathEnglEnrichment.indexOf(strSubCode) != -1)
					bolPutParanthesis = true;
				else
					 bolPutParanthesis = false;
			**/
				if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
					bolPutParanthesis = true;
					try {
						double dGrade = Double.parseDouble((String)vGradeDetail.elementAt(i + 5));
						//System.out.println(dGrade);
						bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
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
				if(bolIsCGH)
					strTemp = " colspan=2";
				else if (strSchCode.startsWith("CPU"))
					strTemp = " colspan=2";
				else
					strTemp = " colspan=3";
			}
			else
				strTemp = "";
				
			//added to show grade not verified instead of grade and remark.
			//System.out.println("I am here. :"+vGradeDetail.elementAt(i + 7));
			if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 && bolIsFinal) {				
				//strTemp = " colspan=2";
				vGradeDetail.setElementAt(null,i);
				vGradeDetail.setElementAt("GNA", i + 5);
				vGradeDetail.setElementAt("&nbsp;", i + 6);
				//strTemp = "  style=\"font-family:Geneva, Arial, Helvetica, sans-serif;font-size:9px;\"";
				strTemp = " ";
			}			
			%>
			  <div style="float:left; width:10%;"><%=(String)vGradeDetail.elementAt(i + 1)%></div>
				
			<div style="float:left; width:40%; overflow:hidden;">
				<div style="white-space:nowrap; padding:0px 5px 0px 0px;"><%=(String)vGradeDetail.elementAt(i+2)%></div>
           </div>
				
			
			<%
			//System.out.println("vGradeDetail.elementAt(i) "+vGradeDetail.elementAt(i));
			strGradeValue = (String)vGradeDetail.elementAt(i+5);
			if(strGradeValue != null) {
				if((strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
					strGradeValue = strGradeValue+"0";	
				if(strGradeValue.toLowerCase().startsWith("grade not"))
					strGradeValue = "GNA";
			}
			%>			
				<!---------------------------- GRADE ------------------------------------->
				<div style="float:left; width:8%;"><%=strGradeValue%></div>
				
			<% 
			//if(vGradeDetail.elementAt(i) != null) {%>     
				<!---------------------------- REMARKS HERE ------------------------------------->
				 <div style="float:left; width:17%;"><%=WI.getStrValue((String)vGradeDetail.elementAt(i+6), "&nbsp;")%></div>
			<%//}%>
				
				<!----------INSTRUCTOR NI DRI-------------------->
				<%
				strTemp = WI.getStrValue((String)vGradeDetail.elementAt(i+4),"N/F");
				Vector vTemp = CommonUtil.convertCSVToVector(strTemp, "<br>", true);
				if(vTemp != null && vTemp.size() > 0) 
					strTemp = (String)vTemp.elementAt(0);
				%>
				 <div style="float:left; width:25%; overflow:hidden;">
				 	<div style="white-space:nowrap; padding:0px 5px 0px 0px;"><%=strTemp%></div>
                 </div>	
				
				
				<div style="clear:both;"></div>
			 <%
			} // end for loop
			//System.out.println(strSchCode);
			
			
		if(WI.fillTextValue("show_gwa").equals("1") && dGWA > 0d){%>
			<div style="float:left; width:10%;">&nbsp;</div>
        	<div style="float:left; width:40%; font-weight:bold;">GWA &nbsp;&nbsp;</div>
        	<div style="float:left; width:8%; font-weight:bold;"><%=CommonUtil.formatFloat(dGWA,2)%></div>
        	<div style="float:left; width:17%;">&nbsp;</div>
        	<div style="clear:both;"></div>
		
		<%}			
			if(strSchCode.startsWith("FATIMA")) {%>
			<div> --= Nothing Follows =--</div>
			<%}%>
</div>
<!----------------------------- MAIN TABLE ENDS HERE ---------------------------------->


<div style="margin:0.2in 0in 0in 0in">
<%=request.getParameter("stud_id")%>&nbsp;&nbsp;<%=(String)vStudInfo.elementAt(1)%>&nbsp;&nbsp; <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%> <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>
</div>
<%}//only if vStudInfo and vGradeDetail are not null
dbOP.cleanUP();


if(strSchCode.startsWith("DBTC")){%>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
this.autoPrint();

this.closeWnd = 1;
</script>
<%}%>
</body>
</html>
