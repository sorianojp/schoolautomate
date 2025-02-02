<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	

	WebInterface WI = new WebInterface(request);
	String strTemp = null;
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
	
GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
String strCurHistIndex = null;

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
						request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));

//System.out.println(vStudInfo);
Vector vGradeDetail = null;
//Vector vAdditionalInfo = null;
//Vector[] vEditInfo = null;
boolean bolIncludeSchedule = false;




if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{

	//get grade sheet release information.
	
	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),
											request.getParameter("sy_from"),request.getParameter("sy_to"),
											request.getParameter("semester"),false,true,true,bolIncludeSchedule);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();
	
	strTemp = "select cur_hist_index from stud_curriculum_hist where is_valid =1 and sy_from = "+request.getParameter("sy_from")+
		" and semester = "+request.getParameter("semester")+
		" and user_index = "+(String)vStudInfo.elementAt(0);
	strCurHistIndex = dbOP.getResultOfAQuery(strTemp,0);
}




if(strErrMsg == null) strErrMsg = "";

double dTotalUnits = 0d;

/////i have to put parenthesis for math and english enrichment.
Vector vMathEnglEnrichment = null;
boolean bolPutParanthesis = false;
if(vGradeDetail != null) {
	vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
}

String[] astrConvertSem = {"SUMMER", "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER", "FOURTH SEMESTER"};
%>

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
body {
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
}


td {
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
}

th {
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;

	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborder {

    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;

	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
    }

    TD.thinborderTopRightBottom {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
    }
	
	TD.thinborderTopBottom {
	border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
	font-size: 11px;
    }
	
	TD.dottedborderTOPBOTTOM{
		border-top: dotted 1px #000000;
		border-bottom: dotted 1px #000000;
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
		font-size: 11px;
	}

</style>

</head>

<body <%if(WI.getStrValue(strErrMsg).length() ==0){%> onLoad="window.print()"<%}%>>
<%if(WI.getStrValue(strErrMsg).length() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="20" align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%}

if(vStudInfo != null && vStudInfo.size() > 0 && vGradeDetail != null && vGradeDetail.size() > 0){

//i will increment the print count here.	
//I use grade_sheet bec. this format is not for finals		
if(strCurHistIndex != null && strCurHistIndex.length() >0){
	
	strTemp = "update grade_sheet set SWU_PRINT_COUNT = isnull(SWU_PRINT_COUNT,0) + 1 "+
		",SWU_PRINT_BY="+(String)request.getSession(false).getAttribute("userIndex")+
		",SWU_PRINT_DATE='"+WI.getTodaysDate()+"' where is_valid =1 and cur_hist_index = "+strCurHistIndex+
		" and GRADE_NAME like '"+WI.fillTextValue("grade_name")+"%'";
	
	dbOP.executeUpdateWithTrans(strTemp, null, null, false);
}

%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="67%" height="18"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>		
	    <td width="33%">STUDENT STUDY LOAD</td>
	</tr>
	<tr>		
		<td height="18">College : <%=(String)vStudInfo.elementAt(16)%></td>
		<%
			if(Integer.parseInt(WI.fillTextValue("semester")) == 0)
				strTemp = WI.fillTextValue("sy_to");
			else
				strTemp = WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");
			%>
	    <td height="18"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=strTemp%></td>
	</tr>
	<tr>		
		<td height="18">Course : <%=(String)vStudInfo.elementAt(18)%><%=WI.getStrValue((String)vStudInfo.elementAt(4)," - ","","")%></td>
	    <td height="18">Total Units : &nbsp; <label id="total_units_enrolled"></label>  </td>
	</tr>
	<tr>		
		<td height="18" colspan="2">Student No./Name : <%=WI.fillTextValue("stud_id")%> &nbsp; &nbsp; <%=(String)vStudInfo.elementAt(1)%></td>
	</tr>
</table>

<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>    
    <td width="10%" align="center" class="dottedborderTOPBOTTOM">Class Code</td>
    <td width="13%" height="20" align="center" class="dottedborderTOPBOTTOM">Subject Name</td>    
    <td width="32%" align="center" class="dottedborderTOPBOTTOM">Descriptive Title</td>
    <td width="6%" align="center" class="dottedborderTOPBOTTOM">Units</td>
    <td width="15%" align="center" class="dottedborderTOPBOTTOM">DAY / TIME</td>
    <td width="12%" align="center" class="dottedborderTOPBOTTOM">ROOM #</td>
    <td width="6%" align="center" class="dottedborderTOPBOTTOM">Midterm</td>
    <td width="6%" align="center" class="dottedborderTOPBOTTOM">Final</td>    
  </tr>
  <%

int iRowSize = 8;
int k = 0;

enrollment.SubjectSection ss = new enrollment.SubjectSection();
Vector vScheduleDetails = null;

String strGradeValue = null;
String strSubCode    = null; 



boolean bolGetFinalGrade = false;
java.sql.PreparedStatement pstmtGetPercentGrade = null;
java.sql.ResultSet rs = null;

if(strCurHistIndex != null && strCurHistIndex.length() > 0){
	bolGetFinalGrade = true;
	strTemp = "select grade from g_sheet_final where is_valid=1 and grade is not null and sub_sec_index=? and cur_hist_index = "+strCurHistIndex;
	pstmtGetPercentGrade = dbOP.getPreparedStatement(strTemp);
}


strTemp = "select section, sub_index from e_sub_section where sub_sec_index = ? ";
java.sql.PreparedStatement pstmtGetSection = dbOP.getPreparedStatement(strTemp);


Vector vTemp = null;
String strLabSecIndex = null;
String strSubSecIndex = null;
String strFinalGrade = null;
String strSubIndex = null;
for(int i=0; i< vGradeDetail.size(); i +=iRowSize){
	strSubSecIndex = (String)vGradeDetail.elementAt(i + 4);
	vScheduleDetails = ss.getRoomScheduleDetailInMWFWithLoc(dbOP, (String)vGradeDetail.elementAt(i + 4));
	
	if(vScheduleDetails != null && vScheduleDetails.size() > 0){
		strLabSecIndex = ss.getLabSchIndex(dbOP, strSubSecIndex);
		if (strLabSecIndex != null) {
			vTemp = ss.getRoomScheduleDetailInMWFWithLoc(dbOP, strLabSecIndex);
	
			if (vTemp != null) {
			  vScheduleDetails.addAll(vTemp);
			}
		  }
	}
	
	
	strSubCode = (String)vGradeDetail.elementAt(i + 1);

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
		
strTemp = null;



pstmtGetSection.setString(1,strSubSecIndex);
rs = pstmtGetSection.executeQuery();
if(rs.next()){
	strTemp = rs.getString(1);
	strSubIndex = rs.getString(2);
}
rs.close();

%>
  <tr>
  
    <td valign="top"> <%=WI.getStrValue(strTemp, "&nbsp;")%></td>
   
    <td valign="top"><%=(String)vGradeDetail.elementAt(i + 1)%></td>
    
    <td valign="top"><%=(String)vGradeDetail.elementAt(i+2)%></td>
<%
strTemp = GS.getLoadingForSubject(dbOP, strSubIndex);
if(strTemp != null && strTemp.length() > 0){
	try{
		dTotalUnits += Double.parseDouble(strTemp);
	}catch(Exception e){
		dTotalUnits += 0d;
	}
}
%>
    <td valign="top" align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
    <%
		
		strTemp2 = "";
		strTemp3 = "";
		if ( vScheduleDetails != null && vScheduleDetails.size() > 0)
		for (k=0; k < vScheduleDetails.size(); k+=3){
			if (k ==0){
				strTemp2 = (String)vScheduleDetails.elementAt(k);
				strTemp3 = (String)vScheduleDetails.elementAt(k+2);
			}else{
				strTemp2 += "<br> " +  (String)vScheduleDetails.elementAt(k);
				strTemp3 += "<br> " +  (String)vScheduleDetails.elementAt(k+2);
			}
		}
	%>
	<td valign="top"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
	<td valign="top"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td>   
<%
strTemp = "";

if(vGradeDetail.elementAt(i + 7) != null && ((String)vGradeDetail.elementAt(i + 7)).compareTo("0") == 0 ) {	
		strTemp = " colspan=2";
	vGradeDetail.setElementAt(null,i);
	vGradeDetail.setElementAt("Grade not verified", i + 5);
	//vGradeDetail.setElementAt("&nbsp;", i + 5);	
}
%> 
    <td valign="top"<%=strTemp%>><div align="center"><%=WI.getStrValue((String)vGradeDetail.elementAt(i+5),"&nbsp;")%></div></td>
<%
strFinalGrade = null;
if(bolGetFinalGrade){
	pstmtGetPercentGrade.setString(1,strSubSecIndex);	
	rs = pstmtGetPercentGrade.executeQuery();
	if(rs.next())
		strFinalGrade = rs.getString(1);
	rs.close();
}
%>
    <%if(strTemp.length() == 0){%><td valign="top"><div align="center"><%=WI.getStrValue(strFinalGrade,"&nbsp;")%></div></td> <%}%>
  </tr>    
<%
} // end for loop
%>
</table>


<%
if(dTotalUnits > 0d){%>
<script>
	document.getElementById('total_units_enrolled').innerHTML = <%=CommonUtil.formatFloat(dTotalUnits, 1)%>;
</script>
<%}%>

<table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="60%"><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1).toUpperCase()%><br>
		<%=WI.getTodaysDateTime()%></td>	  	
	</tr>	
</table>

<%}//only if vStudInfo and vGradeDetail are not null
dbOP.cleanUP();
%>
</body>
</html>
