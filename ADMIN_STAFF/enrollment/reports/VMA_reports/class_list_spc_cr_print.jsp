<!-- 
	Class Record printing.. 
-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
		border-top: solid 1px #000000;
    	border-right: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;	
    }

    TD.thinborder {
	    border-left: solid 1px #000000;
    	border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }
    TD.thinborderBOTTOM {
   	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPBOTTOM {
   	border-top: solid 1px #000000;
   	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>
<body onLoad="window.print();" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	java.sql.ResultSet rs  =null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-print class list","class_list_cit_print.jsp");
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



Vector vRetResult = null;
Vector vFacultySection  = new Vector();
Vector vPMTSchedule = new Vector(); 

String strSYFrom      = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
String strSemester    = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));

String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER"};
String strSYTerm = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))] +":"+WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to");

ReportEnrollment reportEnrl= new ReportEnrollment();
enrollment.VMAEnrollmentReports enrlReport = new enrollment.VMAEnrollmentReports();

	
//	vFacultySection = enrlReport.getSectionOfFaculty(dbOP, strSYFrom, strSemester,WI.fillTextValue("emp_id"));
//	if(vFacultySection == null)
//		strErrMsg = enrlReport.getErrMsg();
		
	strTemp = "select e_sub_section.sub_sec_index, section "+
	 	" from faculty_load "+
		" join e_sub_section on (e_sub_section.sub_sec_index = faculty_load.sub_sec_index) "+
		" where offering_sy_from = " + strSYFrom + " and offering_sem = " + strSemester + 
		" and is_lec = 0 and faculty_load.is_valid =1 ";
	if(WI.fillTextValue("emp_id").length() > 0)
		strTemp += " and user_index = " + WI.fillTextValue("emp_id");
	if(WI.fillTextValue("section_name").length() > 0)
		strTemp += " and section = "+WI.getInsertValueForDB(WI.fillTextValue("section_name"), true, null);
	strTemp += " order by section";	
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vFacultySection.addElement(rs.getString(1));
        vFacultySection.addElement(rs.getString(2));
	}rs.close();
	if (vFacultySection.size() == 0) 
        strErrMsg = "No Result found.";

if(strErrMsg != null){
	dbOP.cleanUP();
%>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%return;}

//String strDateTimePrinted = WI.formatDateTime(null, 5);




String strSubSecIndex = null;
String strSubCode     = null;
String strSubName     = null;
String strSection     = null;
String strLecFac  = null;
String strTime    = null;
String strDay     = null;
String strRoom    = null;
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,false);


Vector vScheduleDtls = null;
Vector vLabSchDtls   = null;
Vector vTemp         = null;


strTemp = 
	" select sub_code, sub_name "+
	" from e_sub_section "+
	" join subject on (subject.sub_index = e_sub_section.sub_index) "+
	" where is_valid = 1 and sub_sec_index = ?";
java.sql.PreparedStatement pstmtSelect = dbOP.getPreparedStatement(strTemp);


strTemp = 
	" select PMT_SCH_INDEX, bsc_grading_name from FA_PMT_SCHEDULE  where is_del = 0 and is_valid = 1 "+
	" and bsc_grading_name is not null "+
	" order by EXAM_PERIOD_ORDER asc, exam_name desc ";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vPMTSchedule.addElement(rs.getString(1));
	vPMTSchedule.addElement(rs.getString(2));
}rs.close();

int iNumGrading = vPMTSchedule.size()/2;	
int iIncr = 0;
int iLineCount = 0;
int iMaxLineCount = 30;	
int iIndexOf = 0;
int k = 0;
int iPageNo = 0;
int iTotalPageCount = 0;

boolean bolPrintMale   = false;
boolean bolPrintFemale = false;
boolean bolIsPageBreak  = false;


String strStudSectionQuery = "select section_name from stud_curriculum_hist join user_Table on (user_Table.user_index = stud_curriculum_hist.user_index) where stud_curriculum_hist.is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+
							WI.fillTextValue("semester")+" and id_number = ";

while(vFacultySection.size() > 0) {
	strSubSecIndex = (String)vFacultySection.remove(0);
	strSection     = (String)vFacultySection.remove(0);
	
	
		
	pstmtSelect.setString(1, strSubSecIndex);
	rs = pstmtSelect.executeQuery();
	if(rs.next()){
		strSubCode = rs.getString(1);
		strSubName = rs.getString(2);
	}rs.close();
	
	if(strSubName != null && strSubName.length() > 40) 
		strSubName = strSubName.substring(0,40);
		
	vScheduleDtls  = reportEnrl.getSubSecSchDetail2(dbOP, strSubSecIndex, true, true, true);
		
	strLecFac  = null;
	strTime = null;
	strDay  = null;
	strRoom = null;
	
	if(vScheduleDtls != null && vScheduleDtls.size() > 0) {
		vLabSchDtls    = (Vector)vScheduleDtls.remove(0);
		strLecFac = (String)vScheduleDtls.remove(0);
		for(int p = 0; p<vScheduleDtls.size(); p+=3) {
			if(strRoom == null)
				strRoom = (String)vScheduleDtls.elementAt(p);
			else
				strRoom += ", "+(String)vScheduleDtls.elementAt(p);
			
			strErrMsg = WI.getStrValue(vScheduleDtls.elementAt(p + 2));
			if(strErrMsg.length() > 0) {
				vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);						
				while(vTemp.size() > 0) {
					strTemp = (String)vTemp.remove(0);
					iIndexOf = strTemp.indexOf(" ");
					if(iIndexOf > -1){									
						if(strTime == null)
							strTime = strTemp.substring(iIndexOf + 1).toLowerCase();
						else
							strTime += "<br>"+strTemp.substring(iIndexOf + 1).toLowerCase();	
						
						if(strDay == null)							
							strDay = strTemp.substring(0, iIndexOf);
						else					
							strDay += ", "+strTemp.substring(0, iIndexOf);												
					}				
				}
			}				
		}
		if(vLabSchDtls != null && vLabSchDtls.size() > 0) {

			if(strLecFac != null && strLecFac.length() > 0)
				strLecFac += WI.getStrValue((String)vLabSchDtls.remove(0),"<br>","","");				
			else
				strLecFac = (String)vLabSchDtls.remove(0);
			
			
			
			for(int p = 0; p<vLabSchDtls.size(); p+=3) {
				if(strRoom == null)
					strRoom = "LAB "+(String)vLabSchDtls.elementAt(p);
				else{
					if(p == 0)
						strRoom += "<br>LAB "+(String)vLabSchDtls.elementAt(p);	
					else
						strRoom += ", "+(String)vLabSchDtls.elementAt(p);
				}
				
				strErrMsg = WI.getStrValue(vLabSchDtls.elementAt(p + 2));
				if(strErrMsg.length() > 0) {
					vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);						
					while(vTemp.size() > 0) {
						strTemp = (String)vTemp.remove(0);
						iIndexOf = strTemp.indexOf(" ");
						if(iIndexOf > -1){									
							if(strTime == null)
								strTime = "LAB "+strTemp.substring(iIndexOf + 1).toLowerCase();
							else{
								if(p == 0)
									strTime += "<br>LAB "+strTemp.substring(iIndexOf + 1).toLowerCase();	
								else
									strTime += ", "+strTemp.substring(iIndexOf + 1).toLowerCase();	
							}
								
							
							if(strDay == null)							
								strDay = "LAB "+strTemp.substring(0, iIndexOf);
							else{
								if(p == 0)
									strDay += "<br>LAB "+strTemp.substring(0, iIndexOf);
								else
									strDay += ", "+strTemp.substring(0, iIndexOf);												
							}					
								
						}				
					}
				}
							
			}
		}
	}
	

	vRetResult = enrlReport.getClassListSPC(dbOP, strSYFrom, strSemester, strSubSecIndex);

	if(vRetResult == null) 		
		continue;
		
		
	bolPrintMale   = false;
	bolPrintFemale = false;	
	iIncr = 0;	
	iPageNo = 0;	
	++iTotalPageCount;	
	
	for(int i =0; i < vRetResult.size();) {
		iLineCount = 0;
	%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
			    <Td align="right">Page <%=++iPageNo%> of <label id="total_page_count_<%=iTotalPageCount+"_"+iPageNo%>"></label></Td>
		    </tr>
			<tr>
				<Td align="center"><strong><%=strSchoolName%><br><%=strSchoolAdd%><br>REPORT OF GRADES</strong><br><%=strSYTerm%></Td>
			</tr>
			<tr><td height="25">&nbsp;</td></tr>
		</table>		  
		<table width="100%" align="center" cellspacing="0" cellpadding="0">
			<tr>
				<td valign="top" height="20" width="8%">Schedule</td>
				<td valign="top" width="1%" align="center">:</td>
				<td valign="top" width="51%"><%=strSubCode%></td>
				<td valign="top" width="7%">Room </td>
				<td width="1%" height="20" align="center" valign="top">:</td>
				<td valign="top" width="32%"><%=strRoom%></td>
			</tr>
			<tr>
				<td height="20" valign="top">Description</td>
				<td height="20" valign="top" align="center">:</td>
				<td valign="top"><%=strSubName%></td>
				<td valign="top">Time</td>
				<td height="20" valign="top" align="center">:</td>
				<td valign="top"><%=strTime%></td>
			</tr>
			<tr>
				<td height="20" valign="top">Instructor</td>
				<td height="20" valign="top" align="center">:</td>
				<td valign="top"><%=strLecFac%></td>
				<td valign="top">Day</td>
				<td height="20" valign="top" align="center">:</td>
				<td valign="top"><%=strDay%></td>
			</tr>
		</table> 
		
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr>
				<td width="5%" rowspan="2" class="" >&nbsp;</td>
				<td rowspan="2"  class=""><font color="#000000" size="1"><strong>Student Name</strong></font></td>
				<td width="17%" rowspan="2"  class=""><div align="center"><font color="#000000" size="1"><strong>Section</strong></font></div></td>
				<td align="center" class="" colspan="<%=iNumGrading%>" >-GRADES-</td>
				<td align="center" class="" colspan="<%=iNumGrading + 1%>">-ABSENCES-</td>
				<td width="12%" rowspan="2" class="" align="center"><font color="#000000" size="1"><strong>REMARKS</strong></font></td>
		    </tr>
			<tr style="font-weight:bold" >
			<% 
				for (int j = 0; j < iNumGrading; ++j){
					strTemp = ((String)vPMTSchedule.elementAt((j*2)+1)).toLowerCase();
					
					if(strTemp.startsWith("prelim"))
						strTemp = "P";
					else if(strTemp.startsWith("midterm"))
						strTemp= "M";
					else if(strTemp.startsWith("semi"))
						strTemp= "PF";
					else if(strTemp.startsWith("final"))
						strTemp= "F";
						
				%>
			<td  class="" align="center"  width="6%"><font color="#000000" size="1"><%=strTemp%></font></td>
			<%} // end for loop
			  
				for (int j = 0; j < iNumGrading; ++j){
					strTemp = ((String)vPMTSchedule.elementAt((j*2)+1)).toLowerCase();
					
					if(strTemp.startsWith("prelim"))
						strTemp = "P";
					else if(strTemp.startsWith("midterm"))
						strTemp= "M";
					else if(strTemp.startsWith("semi"))
						strTemp= "PF";
					else if(strTemp.startsWith("final"))
						strTemp= "F";
						
				%>
			<td  class="" align="center" width="6%"><font color="#000000" size="1"><%=strTemp%></font></td>
			<%} // end for loop%>
			<td class="" align="center" width="6%"><font color="#000000" size="1">TOT</font></td>
		  </tr>
		  
		<% 			
		for(; i < vRetResult.size();){			
			iLineCount++;		
	
		if(!bolPrintMale) {
			if(vRetResult.elementAt(i + 6).equals("M")) {
				bolPrintMale = true;%>
					<tr>
	  					<td height="18" colspan="5" style="font-size:10px;"><strong>Male</strong></td>
					</tr>
		<%}}
		if(!bolPrintFemale) {
			if(vRetResult.elementAt(i + 6).equals("F")) {
				bolPrintFemale = true;%>
					<tr>
						<td height="18" colspan="5" style="font-size:10px;"><strong>Female</strong></td>
					</tr>
		<%}}%>
		 <tr>
			<td height="18" class="" style="font-size:9px;"><%=++iIncr%></td>
			<td class="" style="font-size:9px;"><%=(String)vRetResult.elementAt(i+2)%></td>
			<%
			strTemp = strStudSectionQuery+"'"+(String)vRetResult.elementAt(i+1)+"'";
			strTemp = dbOP.getResultOfAQuery(strTemp, 0);
			if(strTemp == null)
				strTemp = WI.fillTextValue("section_name");
			%>
			<td class="" style="font-size:9px;" align="center"><%=strTemp%></td>
			
			<%for (k = 0; k < iNumGrading; ++k) {%>
			<td valign="bottom" align="center"><div style="border-bottom: solid 1px #000000; width:90%"></div></td>
			<%}%>
			
			<%for (k = 0; k < iNumGrading; ++k) {%>
			<td valign="bottom" align="center">&nbsp;</td>
			<%}%>
			<td valign="bottom" align="center">&nbsp;</td><!--TOTAL OF ABSENCES-->
			<td valign="bottom" align="center"><div style="border-bottom: solid 1px #000000;"></div></td><!--REMARKS-->
		</tr> 
		  
		  
		<%
		i+=10;
		if(iLineCount >= iMaxLineCount){
			bolIsPageBreak = true;
			break;		
		}else
			bolIsPageBreak = false;			
		
		}//end of for loop
		
		if(i + 10 >= vRetResult.size()){
		%> 
		<tr>
			<td align="center" colspan="<%=5+(iNumGrading * 2)%>">********** NOTHING FOLLOWS **********</td>
		</tr>
		<%}else{%>
		<tr>
			<td  align="center" colspan="<%=5+(iNumGrading * 2)%>">************** CONTINUED ON NEXT PAGE ****************</td>
		</tr>
		 <%}%>
		</table>
			
		<br>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
	  <Td width="40%" valign="top" class="thinborderall"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td colspan="3">REMINDERS:</td>
        </tr>
        <tr>
          <td width="6%" align="right" valign="top">1.&nbsp; </td>
          <td width="94%">SPC's final grading remarks are Passed, Failed, 
            Failure Debarred(FD), &amp; Withdrawn(W).<strong><br>
            NO other remarks are allowed</strong>.</td>
        </tr>
        <tr>
          <td valign="top" align="right">2.&nbsp; </td>
          <td>Use <strong>black ink</strong> for Passing Grades and <strong>red ink</strong> for Failures, FD, W. </td>
        </tr>
        <tr>
         
          <td valign="top" align="right">3.&nbsp; </td>
          <td>Entries in the Grading Sheet <strong>must always</strong> correspond to the entries in Schoolautomate and Class Record. </td>
        </tr>
        <tr>
         
          <td valign="top" align="right">4.&nbsp;</td>
          <td>If there are students not included in the Grading Sheet, 
            please verify with the Registrar's Office immediately.</td>
        </tr>
        
      </table></Td>
		<td width="2%">&nbsp;</td>
		<td valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>					
					<td colspan="4" align="justify">I hereby certify that the above entries are true and 
					correct and such entries correspond to the entries in my Class Record 
					and those which I have encoded in the automated grading sheet.</td>
				</tr>
				<tr><td colspan="4" height="30">&nbsp;</td></tr>
				<tr>
					<td colspan="4" height="25" valign="bottom" align="center"><%//=WI.getTodaysDate(1)%><br>Date Submitted</td>
				</tr>
				<tr><td colspan="4" height="30">&nbsp;</td></tr>
				<tr>
				  <td width="33%" height="15" align="center" valign="bottom">
		  		  <div style="border-bottom:solid 1px #000000; width:90%"></div></td>
					<td width="33%" align="center" valign="bottom">
					<div style="border-bottom:solid 1px #000000; width:90%"></div></td>
					<td width="34%" align="center" valign="bottom">
					<div style="border-bottom:solid 1px #000000; width:90%"></div></td>
			  </tr>
				  <tr>
					<td align="center">Prelim</td>
					<td align="center">Midterm</td>
					<td align="center">Finals</td>
				  </tr>
				  
				 <tr>
					<td align="center">&nbsp;</td>
					<td align="center" height="30" valign="bottom">
						<div style="border-bottom:solid 1px #000000; width:90%"></div></td>
					<td align="center">&nbsp;</td>
			  </tr>
				  <tr>
					<td align="center">&nbsp;</td>
					<td align="center">Signature</td>
					<td align="center">&nbsp;</td>
				  </tr> 
			</table>		</td>
	</tr>
  </table>		
			
		
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}
	
	}//outer for loop.%>
	
<script>
	<%for(int i = 1; i <= iPageNo; ++i){%>
	document.getElementById('total_page_count_<%=iTotalPageCount+"_"+i%>').innerHTML = <%=iPageNo%>;
	<%}%>
</script>
<%
if(vFacultySection.size() > 0){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}


	
}//while(vSubSecRef.size() > 0) %>




</body>
</html>
<%
dbOP.cleanUP();
%>