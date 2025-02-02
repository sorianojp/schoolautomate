<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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

-->
</style>
</head>
<body >
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-print class list","class_lists_print.jsp");
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
Vector vSecDetail = null;
Vector vClassList = null;
Vector vOfferingCollege = null;
java.sql.ResultSet rs = null;
ReportEnrollment reportEnrl= new ReportEnrollment();

vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,request.getParameter("section"));
Vector vDateEnrollList = new Vector();
if(vSecDetail == null)
	strErrMsg = reportEnrl.getErrMsg();
else
{
	vClassList = reportEnrl.getClassList(dbOP,request);
	if(vClassList == null)
		strErrMsg = reportEnrl.getErrMsg();
	else{
		strTemp = 
			" select  id_number, date_of_enrollment "+
			" from stud_curriculum_hist "+
			" join user_table on (user_table.user_index = stud_curriculum_hist.user_index) "+
			" join enrl_final_cur_list on (enrl_final_cur_list.user_index = stud_curriculum_hist.user_index) "+
			" 	and enrl_final_cur_list.sy_from = stud_curriculum_hist.sy_from  "+
			" 	and current_semester = stud_curriculum_hist.semester "+
			" where stud_curriculum_hist.is_valid = 1 "+
			" and is_temp_stud = 0 and enrl_final_cur_list.is_valid =1 "+
			" and stud_curriculum_hist.sy_from = "+WI.fillTextValue("sy_from")+
			" and semester = "+WI.fillTextValue("offering_sem")+
			" and sub_sec_index = "+WI.fillTextValue("section")+
			" and year_level = "+WI.fillTextValue("year_level");
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			vDateEnrollList.addElement(rs.getString(1));
			vDateEnrollList.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(2)));
		}rs.close();

	}
	
}
if(strErrMsg == null)
{
	vOfferingCollege = reportEnrl.getCollegeDeptOffering(dbOP,request.getParameter("course_index"));
	//if(vOfferingCollege == null)
	//	strErrMsg = reportEnrl.getErrMsg();
}
//get subject units
	String strSQLQuery = null;    
    
    double dLecUnit = 0d;
    double dLabUnit = 0d;
    String strUnit = null;
String strSubIndex = WI.fillTextValue("subject");
if(strSubIndex != null && strSubIndex.length() > 0){
	strSQLQuery = " select distinct lec_unit, lab_unit from curriculum where sub_index = "+strSubIndex+" and is_valid = 1 ";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()){
		dLecUnit = rs.getDouble(1);
		dLabUnit = rs.getDouble(2);
	}rs.close();
	if(dLecUnit > 0d)
		strUnit = CommonUtil.formatFloat((dLecUnit+dLabUnit),1);
	
	if(strUnit == null || strUnit.length() == 0){
		strSQLQuery = " select distinct unit from cculum_Masters where sub_index = "+strSubIndex+" and is_valid = 1 ";
		strUnit = dbOP.getResultOfAQuery(strSQLQuery,0);
		if(strUnit != null)
			strUnit = CommonUtil.formatFloat(Double.parseDouble(strUnit),1);
	}
	if(strUnit == null || strUnit.length() == 0){
		strSQLQuery = " select distinct main_unit from cculum_medicine where main_sub_index = "+strSubIndex+" and is_valid = 1 ";
		strUnit = dbOP.getResultOfAQuery(strSQLQuery,0);
		if(strUnit != null)
			strUnit = CommonUtil.formatFloat(Double.parseDouble(strUnit),1);
	}
}
//dbOP.cleanUP();//clean up here.
if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" align="center"><%=strErrMsg%></td>
    </tr>
</table>
<%}else{
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%"><div align="center"><font style="font-size:13px; font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
		  Teacher's Load/ Plantilla Master List<br><br>
		  Printed Date and Time : <%=WI.getTodaysDateTime()%>
		  </div></td>
    </tr>
</table>
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
<%
String strRoom = null;
String strTime = null;
String strDays  = null;
boolean bolTBA = false;
if(vSecDetail != null && vSecDetail.size() > 0){	
	for(int i = 1; i < vSecDetail.size(); i+=3){
		if(strRoom == null)
			strRoom = (String)vSecDetail.elementAt(i);
		else
			strRoom += ", "+(String)vSecDetail.elementAt(i);
		
		
		
		strErrMsg = WI.getStrValue((String)vSecDetail.elementAt(i + 2));
		if(strErrMsg.length() > 0) {
			Vector vTemp = CommonUtil.convertCSVToVector(strErrMsg, "<br>",true);			
			strErrMsg = "";
			while(vTemp.size() > 0) {
				strTemp = (String)vTemp.remove(0);
				int iIndexOf = strTemp.indexOf(" ");
				if(iIndexOf > -1){
					bolTBA = false;					
					if(strTime == null){
						strTime = strTemp.substring(iIndexOf + 1).toLowerCase();						
						bolTBA = WI.getStrValue(strTime).trim().equalsIgnoreCase("0:00am-0:00am");
					}else{
						strTime += ", "+strTemp.substring(iIndexOf + 1).toLowerCase();			
						bolTBA = WI.getStrValue(strTemp).substring(iIndexOf + 1).trim().equalsIgnoreCase("0:00am-0:00am");		
					}
					
					if(strDays == null){
						if(bolTBA)
							strDays = "BY ARR";
						else
							strDays = strTemp.substring(0, iIndexOf);
					}else{
						if(bolTBA)
							strDays += ", BY ARR";
						else
							strDays += ", "+strTemp.substring(0, iIndexOf);
					}						
				}				
			}
		}
		
	}	
}

%>
	<tr>
		<td width="16%" height="20">Instructor</td>
		<td width="51%">: <%=WI.getStrValue(vSecDetail.elementAt(0))%></td>
		<td width="8%">Date</td>
		<td width="25%">: <%=WI.getStrValue(strDays)%></td>
	</tr>
	<tr>
		<td height="20">Subject</td>
		<td>: <%=request.getParameter("section_name")%>-<%=request.getParameter("subject_name")%> &nbsp; Units : <%=strUnit%></td>
		<td>Time</td>
		<td>: <%=WI.getStrValue(strTime)%></td>
	</tr>
	<tr>
		<td height="20">Room</td>
		<td>: <%=strRoom%></td>
	</tr>
</table>
<%
boolean bolShowPageBreak = false;

int iNoOfStudPerPage = 26;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));

int iStudPrinted = 0;

int iTotalStud = Integer.parseInt( (String)vClassList.elementAt(0));
int iStudCount = 1;
int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud %iNoOfStudPerPage > 0)
	++iTotalPageCount;
int iPageCount = 1;
String strDispPageNo = null;

for(int i=1; i<vClassList.size();){
strDispPageNo = Integer.toString(iPageCount)+" of "+Integer.toString(iTotalPageCount);
++iPageCount;
iStudPrinted = 0;
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td class="thinborderTOPBOTTOM" width="8%" height="20" align="center">Seq. #</td>
		<td class="thinborderTOPBOTTOM" width="14%">Student No</td>
		<td class="thinborderTOPBOTTOM" width="40%" align="center">Name</td>
		<td class="thinborderTOPBOTTOM" width="15%" align="center">Course</td>
		<td class="thinborderTOPBOTTOM" width="8%" align="center">Year</td>
		<td class="thinborderTOPBOTTOM" width="15%" align="center">Date Enrolled</td>
	</tr>
	
<%
for(;i<vClassList.size();){
if(iStudPrinted++ == iNoOfStudPerPage) {
	bolShowPageBreak = true;
	break;
}
else
	bolShowPageBreak = false;
%>
	<tr>
		<td height="22" align="center"><%=iStudCount++%>.</td>
		<td><%=(String)vClassList.elementAt(i)%></td>
		<%
		strTemp = WebInterface.formatName((String)vClassList.elementAt(i+2),(String)vClassList.elementAt(i+3), (String)vClassList.elementAt(i+1),4);
		%>
		<td><%=strTemp%></td>
		<td align="center"><%=(String)vClassList.elementAt(i+4)%><%=WI.getStrValue((String)vClassList.elementAt(i+5), "-","","")%></td>
		<td align="center"><%=WI.getStrValue((String)vClassList.elementAt(i+6),"N/A")%></td>
		<%
		
if(WI.fillTextValue("show_not_validated").length() == 0)
	strTemp = (String)vDateEnrollList.elementAt(vDateEnrollList.indexOf((String)vClassList.elementAt(i)) + 1);
else
	strTemp =(String)vClassList.elementAt(i + 8);



		%>
		<td><%=strTemp%></td>
	</tr>
<%
if(WI.fillTextValue("show_not_validated").length() == 0)
	i = i+8;
else	
	i = i+9;

}%>	
</table>
 
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="3%" height="18">&nbsp;</td>
    <td width="73%" valign="top">&nbsp;</td>
    <td width="24%" valign="top"><div align="right">Page <%=strDispPageNo%></div></td>
  </tr>
</table>
<!-- introduce page break here -->
<% if(bolShowPageBreak){%>
<DIV style="page-break-after:always;" >&nbsp;</DIV>
<%}//do not print for last page.

}%>


<script language="JavaScript">
	window.print();
</script>
<%} // only if there is no error
%>



</body>
</html>
