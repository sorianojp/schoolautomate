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
    /**
		border-top: solid 1px #000000;
    	border-right: solid 1px #000000;
	**/
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    /**
	    border-left: solid 1px #000000;
    	border-bottom: solid 1px #000000;
	**/
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
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	java.sql.ResultSet rs = null;
	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
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
Vector vSecDetail = null;
Vector vClassList = null;
Vector vSubSecRef = null;

enrollment.GradeSystem GS = new enrollment.GradeSystem();
enrollment.SubjectSection SS = new enrollment.SubjectSection();
ReportEnrollment reportEnrl= new ReportEnrollment();
vSubSecRef = reportEnrl.getClassListSubSecRefCIT(dbOP, request);
if(vSubSecRef == null)
	strErrMsg = reportEnrl.getErrMsg();
//System.out.println(vSubSecRef);




String[] astrConvertSem = {"Summer","First Term","Second Term","Third Term","Fourth Term"};



if(strErrMsg != null){
	dbOP.cleanUP();
%>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%return;}

String strDateTimePrinted = WI.formatDateTime(null, 5);

int iRowsPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iRowsPrinted = 0;

String strSubSecIndex = null;
String strSubCode     = null;
String strSubName     = null;
String strSection     = null;
String strIsLec       = null;
String strTimeRoomNo  = null;

String[] astrIsLec = {"Lec","Lab"};
int iPageNo = 0;int iCount;

String strSchoolName  = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddress     = SchoolInformation.getAddressLine1(dbOP,false,false);

Vector vScheduleDtls = null;
Vector vLabSchDtls   = null;

String strLecTime = null;
String strLabTime = null;
String strLecFac  = null;
String strLabFac  = null;

//used for SWU
double dLecUnit = 0d;
double dLabUnit = 0d;
String strUnit = null;
String strSubIndex = null;
String strRoom = null;
String strTime = null;
String strDays  = null;
boolean bolTBA = false;

//System.out.println(vSubSecRef);
boolean bolForcePrint = false;
int iCount2 = 0; 


strTemp = 
	" select id_number from enrl_final_cur_list "+
	" join user_table on (user_table.user_index = enrl_final_cur_list.user_index) "+
	" where enrl_final_cur_list.is_valid =1 and sub_sec_index = ? "+
	" and new_added_dropped = 2 "+
	" and sy_from = "+WI.fillTextValue("sy_from")+" and current_semester = "+WI.fillTextValue("semester");
java.sql.PreparedStatement pstmtWithdraw = dbOP.getPreparedStatement(strTemp);

String strInstructorName = null;

java.sql.PreparedStatement pstmtGetTime = null;
java.sql.PreparedStatement pstmtGetFaculty = null;

if(WI.fillTextValue("emp_id").length() > 0){
	strTemp = "select fname, mname, lname from user_table where is_valid =1 and id_number = "+WI.getInsertValueForDB(WI.fillTextValue("emp_id"), true, null);
	rs = dbOP.executeQuery(strTemp);
	if(rs.next())		
		strInstructorName = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
	rs.close();
	
	strTemp = "select id_number from user_table join faculty_load on (faculty_load.user_index = user_table.user_index) "+
		" and faculty_load.is_valid =1 and sub_sec_index = ?";
	pstmtGetFaculty = 	dbOP.getPreparedStatement(strTemp);
	
	strTemp = "select SCHED_FOR_MULTI_ASSIGN from FACULTY_LOAD where IS_VALID =1 "+
		" and USER_INDEX= (select user_index from user_table where id_number = "+WI.getInsertValueForDB(WI.fillTextValue("emp_id"), true, null)+") and SUB_SEC_INDEX = ?";
	pstmtGetTime = dbOP.getPreparedStatement(strTemp);
	
}

Vector vWithdrawList = new Vector();
String strLabSubSecIndex = null;
boolean bolIsLab = false;

int iLoopCount = 0;

while(vSubSecRef.size() > 0) {
	strSubSecIndex    = (String)vSubSecRef.remove(0);
	strSubCode        = (String)vSubSecRef.remove(0);
	strSubName        = (String)vSubSecRef.remove(0);
	strSection        = (String)vSubSecRef.remove(0);
	strIsLec          = (String)vSubSecRef.remove(0);
	vScheduleDtls     = (Vector)vSubSecRef.remove(0);	
	vLabSchDtls	      = null;
	strLabSubSecIndex = null;
	
/*
	if SWU, I have to check if the subject has laboratory
	if there is, I have to loop back. :D
*/

	if(strIsLec.equals("1"))//i have to get lec sub_sec_index
		strSubSecIndex = SS.getLecSchIndex(dbOP, strSubSecIndex);
	else		
		strLabSubSecIndex = SS.getLabSchIndex(dbOP, strSubSecIndex);



if(strSubSecIndex == null || strSubSecIndex.length() == 0)
	continue;

if(strLabSubSecIndex != null && strLabSubSecIndex.length() > 0){
	iLoopCount = 2;
	bolIsLab = true;
}else{
	iLoopCount = 1;
	bolIsLab = false;
}

while(--iLoopCount >= 0){
	//if there is lab, first loop is lec, then lab
	//if(iLoopCount == 0 && bolIsLab)
	//	strSubSecIndex = strLabSubSecIndex;
		
//	System.out.println("iLoopCount11 : "+iLoopCount);

/**
if they encode faculty id in search.
I have to check if the faculty in laboratory is same.
else
	do not show lab info.

*/
if(WI.fillTextValue("emp_id").length() > 0 && bolIsLab){

	if(iLoopCount == 1)
		strTemp = strSubSecIndex;
	else
		strTemp = strLabSubSecIndex;
	
	pstmtGetFaculty.setString(1, strTemp);
	rs = pstmtGetFaculty.executeQuery();
	if(rs.next()){
		if(!WI.fillTextValue("emp_id").equals(rs.getString(1))){
			rs.close();
			continue;
		}	
	}rs.close();		
}



	strLecTime = null;strLabTime = null;strLecFac  = null;strLabFac  = null;
	
	
	strRoom = null;
	strTime = null;
	strDays  = null;

	strTemp = "select sub_index from E_SUB_SECTION where IS_VALID  = 1 and SUB_SEC_INDEX = "+strSubSecIndex;
	strSubIndex = dbOP.getResultOfAQuery(strTemp, 0);
	if(strSubIndex != null)
		strUnit = GS.getLoadingForSubject(dbOP, strSubIndex);
	

	//vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	
if(vScheduleDtls != null && vScheduleDtls.size() > 0) {
	if((iLoopCount == 1 && bolIsLab) || (iLoopCount ==0 && !bolIsLab)){//remove only in first loop
		vLabSchDtls = (Vector)vScheduleDtls.remove(0);
//		System.out.println(" iLoopCount "+ iLoopCount+" bolIsLab "+bolIsLab);	
//		System.out.println(" strSubSecIndex "+ strSubSecIndex);	
//		System.out.println(" vLabSchDtls "+ vLabSchDtls);	
	}
	
	
		
	if(vScheduleDtls.size() > 0){
		strLecFac = (String)vScheduleDtls.elementAt(0);
		for(int p = 1; p<vScheduleDtls.size(); p+=3) {
			if(strLecTime == null)
				strLecTime = (String)vScheduleDtls.elementAt(p + 2) + " Room: " + (String)vScheduleDtls.elementAt(p);
			else	
				strLecTime +=", "+ (String)vScheduleDtls.elementAt(p + 2) + " Room: " + (String)vScheduleDtls.elementAt(p);
		}
	}
	
	if(vLabSchDtls != null && vLabSchDtls.size() > 0) {
		//System.out.println(" vLabSchDtls "+ vLabSchDtls);
		strLabFac = (String)vLabSchDtls.elementAt(0);
		for(int p = 1; p<vLabSchDtls.size(); p+=3) {
			if(strLabTime == null)
				strLabTime = (String)vLabSchDtls.elementAt(p + 2) + " Room: " + (String)vLabSchDtls.elementAt(p);
			else	
				strLabTime +=", "+ (String)vLabSchDtls.elementAt(p + 2) + " Room: " + (String)vLabSchDtls.elementAt(p);
		}
	}
	
	
		if(iLoopCount == 0 && bolIsLab){//2nd loop
			vScheduleDtls = new Vector();			
			vScheduleDtls.addAll(vLabSchDtls);	
			
		}
		for(int p = 1; p < vScheduleDtls.size(); p+=3){
			if(strRoom == null)
				strRoom = (String)vScheduleDtls.elementAt(p);
			else
				strRoom += ", "+(String)vScheduleDtls.elementAt(p);
								
			strErrMsg = WI.getStrValue((String)vScheduleDtls.elementAt(p + 2));
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


	vClassList = reportEnrl.getClassListDetailCIT(dbOP, strSubSecIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
	if(vClassList == null || vClassList.size() == 0) 		
		continue;
	
	
	pstmtWithdraw.setString(1, strSubSecIndex);
	rs = pstmtWithdraw.executeQuery();
	while(rs.next())
		vWithdrawList.addElement(rs.getString(1));
	rs.close();
	
	if(pstmtGetTime != null){
		pstmtGetTime.setString(1, strSubSecIndex);
		rs = pstmtGetTime.executeQuery();
		if(rs.next())
			strTemp = rs.getString(1);
		rs.close();
		
		
		
		if(strTemp != null && strTemp.length() > 0){
			strDays = null;
			strTime = null;
			java.util.StringTokenizer strToken = new java.util.StringTokenizer(strTemp);
			while (strToken.hasMoreTokens()) {
				if(strDays == null)
					strDays = strToken.nextToken();
				else
					strDays += "<br>" +strToken.nextToken();
				
				if(strTime == null)
					strTime = strToken.nextToken();
				else
					strTime += "<br>" +strToken.nextToken();				
			}		
		}
	}
	
	if(iCount2++ > 0)
		bolForcePrint = true;

	iPageNo = 0;iCount = 0;
	for(int i =0; i < vClassList.size();) {
		if(i > 0 || bolForcePrint || (iLoopCount == 0 && bolIsLab)){%>
			<DIV style="page-break-after:always" >&nbsp;</DIV>
		<%bolForcePrint = true;}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td colspan="4"><div align="center"><font style="font-size:13px; font-weight:bold;"><%=strSchoolName%></font><br>
			  <%=strAddress%><br>
			 Class Master List Per Instructor<br>
				<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")+"-"+(Integer.parseInt(WI.fillTextValue("sy_from"))+1)%><br>
			  Printed Date and Time : <%=WI.getTodaysDateTime()%><br><br><br>&nbsp;
		  </div></td>
		</tr>	
	</table>
		  
		
	
<table  width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="16%" height="20">Instructor</td>
		<%
		if(strInstructorName == null){
			strInstructorName = WI.getStrValue(vScheduleDtls.elementAt(0));		
		}
		%>
		<td width="51%">: <%=strInstructorName%></td>
		<td width="8%">Date</td>
		<td width="25%">: <%=WI.getStrValue(strDays)%></td>
	</tr>
	<%
	if(WI.fillTextValue("emp_id").length() == 0)//i have to clean this so that other faculty will display
		strInstructorName = null;
	%>
	<tr>
		<td height="20">Subject</td>
		<td>: <%=strSection%>-<%=strSubCode%></td>
		<td>Time</td>
		<td>: <%=WI.getStrValue(strTime)%></td>
	</tr>
	<tr>
		<td height="20">Room</td>
		<td>: <%=strRoom%></td>
		<td>Units</td>
		<td>: <%=WI.getStrValue(strUnit)%></td>
	</tr>
</table>


<table width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="thinborderTOPBOTTOM" width="5%" height="20" align="center">Seq. #</td>
		<td class="thinborderTOPBOTTOM" width="14%">Student No</td>
		<td class="thinborderTOPBOTTOM" width="" align="center">Name</td>
		<td class="thinborderTOPBOTTOM" width="6%" align="center">Gender</td>
		<td class="thinborderTOPBOTTOM" width="12%" align="center">Course</td>
		<td class="thinborderTOPBOTTOM" width="7%" align="center">Year</td>
		<td class="thinborderTOPBOTTOM" width="15%" align="center">Date Enrolled</td>
	</tr>
	<%
	
	for(iRowsPrinted = 0; i < vClassList.size(); i += 7, ++iRowsPrinted) {
		if(iRowsPerPg <= iRowsPrinted)
			break;
		
		strTemp = "";
		if(vWithdrawList.indexOf(vClassList.elementAt(i)) > -1)
			strTemp = " W";
		
		%>
		<tr>
		<td height="22" align="center"><%=++iCount%>. <%=strTemp%></td>
		<td><%=vClassList.elementAt(i)%></td>		
		<td><%=vClassList.elementAt(i + 1)%></td>
		<td align="center"><%=WI.getStrValue((String)vClassList.elementAt(i + 2),"N/A")%></td>
		<td align="center"><%=vClassList.elementAt(i + 3)%><%=WI.getStrValue((String)vClassList.elementAt(i + 4), " - ", "","")%></td>
		<td align="center"><%=WI.getStrValue((String)vClassList.elementAt(i + 5),"N/A")%></td>		
		<td><%=WI.getStrValue((String)vClassList.elementAt(i + 6), "&nbsp;")%></td>
	</tr>
	<%}%>
</table>






			
		
<%}//outer for loop.%>
	
<%}
}//while(vSubSecRef.size() > 0) %>


</body>
</html>
<%
dbOP.cleanUP();
%>