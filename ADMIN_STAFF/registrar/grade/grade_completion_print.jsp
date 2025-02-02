<%@ page language="java" import="utility.*,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
	@media print { 
	  @page {
	  		size:8.50in 13in; 
			margin-bottom:0in;
			margin-top:.2in;
			margin-left:0in;
			margin-right:0in;
		}
	}
body {
	font-family: "Times New Roman";
	font-size: 10px;
}

td {
	font-family: "Times New Roman";
	font-size: 10px;
}

th {
	font-family: "Times New Roman";
	font-size: 10px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;	
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;	
    }
    TD.thinborderNONE {
	font-family: "Times New Roman";
	font-size: 11px;	
    }

    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderTOPLEFTRIGHT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderTOPRIGHT {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderTOPLEFT {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderTOPBOTTOMRIGHT {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }
    TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
	font-family: "Times New Roman";
	font-size: 11px;
    }

</style>
<body>
<%
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Completion","grade_completion_print.jsp");
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
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Completion",request.getRemoteAddr(),
									null);

}
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
String[] astrConvertSem = {"SUMMER" , "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER", "FOURTH SEMESTER"};
Vector vDataList = new Vector();
Vector vSelectedGSIndex = new Vector();

String strDueDate = null;
String strGSIndex = WI.fillTextValue("strSelectedGSIndex");//WI.fillTextValue("gs_index");
java.sql.ResultSet rs = null;



strTemp = Integer.toString( Integer.parseInt(WI.getStrValue(WI.fillTextValue("swu_print_count"),"0")) + 1 );
strTemp = "update g_sheet_final set COMPLETION_PRINT_COUNT = "+strTemp+
	",COMPLETION_PRINT_BY="+(String)request.getSession(false).getAttribute("userIndex")+
	",COMPLETION_PRINT_DATE='"+WI.getTodaysDate()+"' where gs_index = ? ";
java.sql.PreparedStatement pstmtUpdateCount = dbOP.getPreparedStatement(strTemp);
	

boolean bolHasSingleGSIndex = true;
enrollment.GradeSystem GS = new enrollment.GradeSystem();
int iPrintCount = 0;
if(strGSIndex.length() > 0){

vSelectedGSIndex = CommonUtil.convertCSVToVector(strGSIndex);
if(vSelectedGSIndex == null || vSelectedGSIndex.size() == 0){dbOP.cleanUP();
	strErrMsg = "Please select atleast one subject for grade completion.";%>
	<div align="center" style="text-align:center"><strong><%=strErrMsg%></strong></div>
<%return;}

if(vSelectedGSIndex.size() > 1)
	bolHasSingleGSIndex = false;
	
strGSIndex = null;
while(vSelectedGSIndex.size() > 0){
strGSIndex = (String)vSelectedGSIndex.remove(0);
if(strGSIndex == null || strGSIndex.length() == 0)
	continue;

if(bolHasSingleGSIndex){
pstmtUpdateCount.setString(1, strGSIndex);
pstmtUpdateCount.executeUpdate();
}

vDataList = new Vector();

strTemp = 
	" select stud.user_index, stud.id_number, stud.fname, stud.mname, stud.lname, "+
	" course_offered.course_code, major.course_code, year_level, "+
	" sub_code, sub_name, "+
	//" (lec_unit+lab_unit) as units, "+
	" subject.sub_index , "+
	" section, "+
	" teacher.fname, teacher.mname, teacher.lname, c_code, c_name, remark_abbr "+
	" from stud_curriculum_hist  "+
	" join g_sheet_final on (g_sheet_final.cur_hist_index = stud_curriculum_hist.cur_hist_index) "+
	" join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
	" left join major on (major.major_index = stud_curriculum_hist.major_index) "+
	" join college on (college.c_index = course_offered.c_index) "+
	" join user_table as stud on (stud.user_index = stud_curriculum_hist.user_index) "+
	
	//" join curriculum on (curriculum.cur_index = g_sheet_final.cur_index) "+
	" join e_sub_section on (e_sub_section.sub_sec_index = g_sheet_final.sub_sec_index) "+
	" join subject on (subject.sub_index = e_sub_section.sub_index) "+
	" join REMARK_STATUS on (REMARK_STATUS.remark_index = g_sheet_final.remark_index) "+
	" join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = g_sheet_final.sub_sec_index) "+
	" join user_table as teacher on (teacher.user_index = FACULTY_LOAD.user_index) "+
	" where FACULTY_LOAD.is_valid = 1 and is_main =1 and stud_curriculum_hist.is_valid = 1 and gs_index = "+strGSIndex;
	rs = dbOP.executeQuery(strTemp);
	if(rs.next()){
		vDataList.addElement(rs.getString(1));//[0]user_index
		vDataList.addElement(rs.getString(2));//[1]id_number
		vDataList.addElement(rs.getString(3));//[2]fname
		vDataList.addElement(rs.getString(4));//[3]mname
		vDataList.addElement(rs.getString(5));//[4]lname
		vDataList.addElement(rs.getString(6));//[5]course_code
		vDataList.addElement(rs.getString(7));//[6]course_code
		vDataList.addElement(rs.getString(8));//[7]year_level
		vDataList.addElement(rs.getString(9));//[8]sub_code
		vDataList.addElement(rs.getString(10));//[9]sub_name
		vDataList.addElement(rs.getString(11));//[10]sub_index
		vDataList.addElement(rs.getString(12));//[11]section
		vDataList.addElement(rs.getString(13));//[12]fname
		vDataList.addElement(rs.getString(14));//[13]mname
		vDataList.addElement(rs.getString(15));//[14]lname
		vDataList.addElement(rs.getString(16));//[15]c_code
		vDataList.addElement(rs.getString(17));//[16]c_name
		vDataList.addElement(rs.getString(18));//[17]remark_abbr
	}rs.close();
	
if(vDataList.size() == 0)
	continue;

	
strTemp = GS.getLoadingForSubject(dbOP, (String)vDataList.elementAt(10));
vDataList.setElementAt(strTemp, 10);




//strTemp = "select COMPLETION_DUE_DATE from g_sheet_final where gs_index ="+strGSIndex;
//strDueDate = dbOP.getResultOfAQuery(strTemp, 0);

if(WI.fillTextValue("completion_due_date").length() > 0){
	strTemp = ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("completion_due_date"));
	if(strTemp != null && strTemp.length() > 0){
		strTemp = "update g_sheet_final set COMPLETION_DUE_DATE = '"+strTemp+"' where gs_index = "+strGSIndex;
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
	}
}
strDueDate = null;
strTemp = "select COMPLETION_DUE_DATE from g_sheet_final where gs_index = "+strGSIndex;
rs = dbOP.executeQuery(strTemp);
if(rs.next())
	strDueDate = ConversionTable.convertMMDDYYYY(rs.getDate(1));
rs.close();



++iPrintCount;
if(iPrintCount > 1){%>
	<div style="page-break-after:always;">&nbsp;</div>
<%}
%>

    

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="24%" valign="top">
			<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr><td class="thinborderALL" align="center">
					<font style="font-size:12px; font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
					<br>APPLICATION FOR GRADE COMPLETION</font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">STUDENT NO: <font style="font-size:12px; font-weight:bold;"><%=vDataList.elementAt(1)%></font></td></tr>
				<%
				strTemp = WebInterface.formatName((String)vDataList.elementAt(2),(String)vDataList.elementAt(3),(String)vDataList.elementAt(4),4);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">NAME OF APPLICANT:<br><font style="font-size:12px; font-weight:bold;">&nbsp; 
					<%=strTemp.toUpperCase()%></font></td></tr>
				<%
				strTemp = ((String)vDataList.elementAt(5)).toUpperCase() + WI.getStrValue((String)vDataList.elementAt(6),"-","","").toUpperCase() 
					+ " &nbsp; " +(String)vDataList.elementAt(7);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">CRS AND YEAR: &nbsp; <font style="font-size:12px; font-weight:bold;"><%=strTemp%></font></td></tr>
				<%
				strTemp = ((String)vDataList.elementAt(8)).toUpperCase() +"<br>&nbsp; "+ ((String)vDataList.elementAt(9)).toUpperCase();
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">SUBJECT APPLIED FOR: 
					<font style="font-size:12px; font-weight:bold;">&nbsp; <%=strTemp%></font></td></tr>
				<%
				strTemp = (String)vDataList.elementAt(10);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">UNITS: &nbsp; <font style="font-size:12px; font-weight:bold;"><%=strTemp%></font> 
					&nbsp; &nbsp; SUBJECT CODE: <font style="font-size:12px; font-weight:bold;"><%=((String)vDataList.elementAt(11)).toUpperCase()%></font></td></tr>
					<%
					if(Integer.parseInt(WI.fillTextValue("semester")) == 0){
						strTemp = WI.fillTextValue("sy_to");
						strErrMsg = WI.getStrValue(WI.fillTextValue("semester")+WI.fillTextValue("sy_to"),"[","]","");
					}else{
						strTemp = WI.fillTextValue("sy_from");
						strErrMsg = WI.getStrValue(WI.fillTextValue("semester")+WI.fillTextValue("sy_from"),"[","]","");
					}
					%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">TERM: <font style="font-size:12px; font-weight:bold;">
					<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=strTemp%> <%=strErrMsg%>
				</font></td></tr>
				<%
				strTemp = WebInterface.formatName((String)vDataList.elementAt(12),(String)vDataList.elementAt(13),(String)vDataList.elementAt(14),4);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">INSTRUCTOR:<br><font style="font-size:12px; font-weight:bold;"><%=strTemp.toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">COLLEGE:<br><font style="font-size:12px; font-weight:bold;">
				<%=((String)vDataList.elementAt(16)).toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">GRADE AS REPORTED: <font style="font-size:12px; font-weight:bold;">
					<%=((String)vDataList.elementAt(17)).toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">TIME AND DATE EXAM: <font style="font-size:12px; font-weight:bold;">By Arrangement</font></td></tr>
				<tr>
					<td valign="top" class="thinborderBOTTOMLEFTRIGHT">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td colspan="2" align="center"><strong>IMPORTANT TO INSTRUCTOR</strong></td></tr>
							<tr>
								<td valign="top">1)</td>
								<td style="padding-left:5px;">PREPARE THIS REPORT IN INK AND IN YOUR OWN HAND WRITING.</td>
							</tr>
							<tr>
								<td valign="top">2)</td>
								<td style="padding-left:5px;">SUBMIT THIS PERSONALLY OR THROUGH THE 
								DEAN'S CLERK TO THE OFFICE OF THE REGISTRAR WITH YOUR SIGNATURE ON THE
								DATE INDICATED THIS SHOULD NOT BE HAND CARRIED BY THE STUDENT.</td>
							</tr>
							<tr>
								<td valign="top">3)</td>
								<td style="padding-left:5px;">SUBMIT THE BLUE BOOK OR EXAM PAPERS.</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" align="center" style="font-size:11px;"><strong>INSTRUCTOR'S GRADE REPORT</strong></td></tr>				
				<tr><td class="thinborderBOTTOMLEFTRIGHT">DATE DUE: <font style="font-size:12px; font-weight:bold;"><%=WI.getStrValue(strDueDate,"&nbsp;")%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" align="center" style="font-size:11px;"><strong>TO BE FILLED IN BY THE INSTRUCTOR</strong></td></tr>
				<tr>
					<td valign="top" class="thinborder">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="thinborderBOTTOMRIGHT" height="18" style="font-size:12px;" align="center">SUBJECT</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">GRADE</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">UNIT</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">REMARK</td>
							</tr>
							<tr>
								<td class="thinborderRIGHT" height="28"><font style="font-size:12px; font-weight:bold;">
									<%=((String)vDataList.elementAt(8)).toUpperCase()%></font></td>
								<td class="thinborderRIGHT" height="28" align="center"><font style="font-size:12px; font-weight:bold;">&nbsp;</font></td>
								<td class="thinborderRIGHT" height="28" align="center"><font style="font-size:12px; font-weight:bold;">
									<%=(String)vDataList.elementAt(10)%></font></td>
								<td class="thinborderRIGHT" height="28"><font style="font-size:12px; font-weight:bold;">&nbsp;</font></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">DATE SUBMITTED:<br>&nbsp;<br></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:11px;" align="center">SIGNATURE OF THE INSTRUCTOR</td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">NOTED:<br>&nbsp;<br></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:11px;" align="center">DEAN OF COLLEGE</td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:12px;">APPROVED
					<div align="center"><br><strong><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></strong><br>
					UNIVERSITY REGISTRAR
					</div>
				</td></tr>
				<tr><td valign="top" class="thinborder">
					<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr><td class="thinborderRIGHT" width="15%" align="center" style="font-size:11px; font-weight:bold;">1</td>
						<td class="thinborderRIGHT" align="center" style="font-size:11px; font-weight:bold;">COPY FOR THE EDP CENTER</td></tr>
					</table>
				</td></tr>
				<tr>
					<td valign="top" class="thinborderBOTTOMLEFTRIGHT">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td colspan="4" align="center" style="font-size:11px;">RECEIVED COPY</td></tr>
							<tr>
								<td width="30%" valign="bottom" style="font-size:11px;">EDP CENTER:</td>
								<td width="20%" class="thinborderBOTTOM">&nbsp;</td>
								<td width="30%" valign="bottom" style="font-size:11px;">DATE:</td>
								<td width="20%" class="thinborderBOTTOM">&nbsp;</td>
							</tr>
							<tr><td height="2"></td></tr>
						</table>
					</td>
				</tr>
				<tr><td><font style="font-size:8px;"><%= WI.getStrValue((String)request.getSession(false).getAttribute("first_name"))%>
				&nbsp; &nbsp; &nbsp; &nbsp; <%=WI.getTodaysDateTime()%>
				</font></td></tr>
			</table>
		</td>
		<td width="1%"></td>
		<td width="24%" valign="top">
			<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr><td class="thinborderALL" align="center">
					<font style="font-size:12px; font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
					<br>APPLICATION FOR GRADE COMPLETION</font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">STUDENT NO: <font style="font-size:12px; font-weight:bold;"><%=vDataList.elementAt(1)%></font></td></tr>
				<%
				strTemp = WebInterface.formatName((String)vDataList.elementAt(2),(String)vDataList.elementAt(3),(String)vDataList.elementAt(4),4);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">NAME OF APPLICANT:<br><font style="font-size:12px; font-weight:bold;">&nbsp; 
					<%=strTemp.toUpperCase()%></font></td></tr>
				<%
				strTemp = ((String)vDataList.elementAt(5)).toUpperCase() + WI.getStrValue((String)vDataList.elementAt(6),"-","","").toUpperCase() 
					+ " &nbsp; " +(String)vDataList.elementAt(7);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">CRS AND YEAR: &nbsp; <font style="font-size:12px; font-weight:bold;"><%=strTemp%></font></td></tr>
				<%
				strTemp = ((String)vDataList.elementAt(8)).toUpperCase() +"<br>&nbsp; "+ ((String)vDataList.elementAt(9)).toUpperCase();
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">SUBJECT APPLIED FOR: 
					<font style="font-size:12px; font-weight:bold;">&nbsp; <%=strTemp%></font></td></tr>
				<%
				strTemp = (String)vDataList.elementAt(10);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">UNITS: &nbsp; <font style="font-size:12px; font-weight:bold;"><%=strTemp%></font> 
					&nbsp; &nbsp; SUBJECT CODE: <font style="font-size:12px; font-weight:bold;"><%=((String)vDataList.elementAt(11)).toUpperCase()%></font></td></tr>
					<%
					if(Integer.parseInt(WI.fillTextValue("semester")) == 0){
						strTemp = WI.fillTextValue("sy_to");
						strErrMsg = WI.getStrValue(WI.fillTextValue("semester")+WI.fillTextValue("sy_to"),"[","]","");
					}else{
						strTemp = WI.fillTextValue("sy_from");
						strErrMsg = WI.getStrValue(WI.fillTextValue("semester")+WI.fillTextValue("sy_from"),"[","]","");
					}
					%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">TERM: <font style="font-size:12px; font-weight:bold;">
					<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=strTemp%> 
					<%=strErrMsg%>
				</font></td></tr>
				<%
				strTemp = WebInterface.formatName((String)vDataList.elementAt(12),(String)vDataList.elementAt(13),(String)vDataList.elementAt(14),4);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">INSTRUCTOR:<br><font style="font-size:12px; font-weight:bold;"><%=strTemp.toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">COLLEGE:<br><font style="font-size:12px; font-weight:bold;">
				<%=((String)vDataList.elementAt(16)).toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">GRADE AS REPORTED: <font style="font-size:12px; font-weight:bold;">
					<%=((String)vDataList.elementAt(17)).toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">TIME AND DATE EXAM: <font style="font-size:12px; font-weight:bold;">By Arrangement</font></td></tr>
				<tr>
					<td valign="top" class="thinborderBOTTOMLEFTRIGHT">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td colspan="2" align="center"><strong>IMPORTANT TO INSTRUCTOR</strong></td></tr>
							<tr>
								<td valign="top">1)</td>
								<td style="padding-left:5px;">PREPARE THIS REPORT IN INK AND IN YOUR OWN HAND WRITING.</td>
							</tr>
							<tr>
								<td valign="top">2)</td>
								<td style="padding-left:5px;">SUBMIT THIS PERSONALLY OR THROUGH THE 
								DEAN'S CLERK TO THE OFFICE OF THE REGISTRAR WITH YOUR SIGNATURE ON THE
								DATE INDICATED THIS SHOULD NOT BE HAND CARRIED BY THE STUDENT.</td>
							</tr>
							<tr>
								<td valign="top">3)</td>
								<td style="padding-left:5px;">SUBMIT THE BLUE BOOK OR EXAM PAPERS.</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" align="center" style="font-size:11px;"><strong>INSTRUCTOR'S GRADE REPORT</strong></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">DATE DUE: <font style="font-size:12px; font-weight:bold;"><%=WI.getStrValue(strDueDate,"&nbsp;")%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" align="center" style="font-size:11px;"><strong>TO BE FILLED IN BY THE INSTRUCTOR</strong></td></tr>
				<tr>
					<td valign="top" class="thinborder">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="thinborderBOTTOMRIGHT" height="18" style="font-size:12px;" align="center">SUBJECT</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">GRADE</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">UNIT</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">REMARK</td>
							</tr>
							<tr>
								<td class="thinborderRIGHT" height="28"><font style="font-size:12px; font-weight:bold;">
									<%=((String)vDataList.elementAt(8)).toUpperCase()%></font></td>
								<td class="thinborderRIGHT" height="28" align="center"><font style="font-size:12px; font-weight:bold;">&nbsp;</font></td>
								<td class="thinborderRIGHT" height="28" align="center"><font style="font-size:12px; font-weight:bold;">
									<%=(String)vDataList.elementAt(10)%></font></td>
								<td class="thinborderRIGHT" height="28"><font style="font-size:12px; font-weight:bold;">&nbsp;</font></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">DATE SUBMITTED:<br>&nbsp;<br></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:11px;" align="center">SIGNATURE OF THE INSTRUCTOR</td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">NOTED:<br>&nbsp;<br></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:11px;" align="center">DEAN OF COLLEGE</td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:12px;">APPROVED
					<div align="center"><br><strong><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></strong><br>
					UNIVERSITY REGISTRAR
					</div>
				</td></tr>
				<tr><td valign="top" class="thinborder">
					<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr><td class="thinborderRIGHT" width="15%" align="center" style="font-size:11px; font-weight:bold;">1</td>
						<td class="thinborderRIGHT" align="center" style="font-size:11px; font-weight:bold;">COPY FOR THE EVALUATOR</td></tr>
					</table>
				</td></tr>
				<tr>
					<td valign="top" class="thinborderBOTTOMLEFTRIGHT">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td colspan="4" align="center" style="font-size:11px;">RECEIVED COPY</td></tr>
							<tr>
								<td width="30%" valign="bottom" style="font-size:11px;">EDP CENTER:</td>
								<td width="20%" class="thinborderBOTTOM">&nbsp;</td>
								<td width="30%" valign="bottom" style="font-size:11px;">DATE:</td>
								<td width="20%" class="thinborderBOTTOM">&nbsp;</td>
							</tr>
							<tr><td height="2"></td></tr>
						</table>
					</td>
				</tr>
				<tr><td><font style="font-size:8px;"><%= WI.getStrValue((String)request.getSession(false).getAttribute("first_name"))%>
				&nbsp; &nbsp; &nbsp; &nbsp; <%=WI.getTodaysDateTime()%>
				</font></td></tr>
			</table>
		</td>
		<td width="1%"></td>
		<td width="24%" valign="top">
			<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr><td class="thinborderALL" align="center">
					<font style="font-size:12px; font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
					<br>APPLICATION FOR GRADE COMPLETION</font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">STUDENT NO: <font style="font-size:12px; font-weight:bold;"><%=vDataList.elementAt(1)%></font></td></tr>
				<%
				strTemp = WebInterface.formatName((String)vDataList.elementAt(2),(String)vDataList.elementAt(3),(String)vDataList.elementAt(4),4);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">NAME OF APPLICANT:<br><font style="font-size:12px; font-weight:bold;">&nbsp; 
					<%=strTemp.toUpperCase()%></font></td></tr>
				<%
				strTemp = ((String)vDataList.elementAt(5)).toUpperCase() + WI.getStrValue((String)vDataList.elementAt(6),"-","","").toUpperCase() 
					+ " &nbsp; " +(String)vDataList.elementAt(7);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">CRS AND YEAR: &nbsp; <font style="font-size:12px; font-weight:bold;"><%=strTemp%></font></td></tr>
				<%
				strTemp = ((String)vDataList.elementAt(8)).toUpperCase() +"<br>&nbsp; "+ ((String)vDataList.elementAt(9)).toUpperCase();
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">SUBJECT APPLIED FOR: 
					<font style="font-size:12px; font-weight:bold;">&nbsp; <%=strTemp%></font></td></tr>
				<%
				strTemp = (String)vDataList.elementAt(10);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">UNITS: &nbsp; <font style="font-size:12px; font-weight:bold;"><%=strTemp%></font> 
					&nbsp; &nbsp; SUBJECT CODE: <font style="font-size:12px; font-weight:bold;"><%=((String)vDataList.elementAt(11)).toUpperCase()%></font></td></tr>
					<%
					if(Integer.parseInt(WI.fillTextValue("semester")) == 0){
						strTemp = WI.fillTextValue("sy_to");
						strErrMsg = WI.getStrValue(WI.fillTextValue("semester")+WI.fillTextValue("sy_to"),"[","]","");
					}else{
						strTemp = WI.fillTextValue("sy_from");
						strErrMsg = WI.getStrValue(WI.fillTextValue("semester")+WI.fillTextValue("sy_from"),"[","]","");
					}
					%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">TERM: <font style="font-size:12px; font-weight:bold;">
					<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=strTemp%> 
					<%=strErrMsg%>
				</font></td></tr>
				<%
				strTemp = WebInterface.formatName((String)vDataList.elementAt(12),(String)vDataList.elementAt(13),(String)vDataList.elementAt(14),4);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">INSTRUCTOR:<br><font style="font-size:12px; font-weight:bold;"><%=strTemp.toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">COLLEGE:<br><font style="font-size:12px; font-weight:bold;">
				<%=((String)vDataList.elementAt(16)).toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">GRADE AS REPORTED: <font style="font-size:12px; font-weight:bold;">
					<%=((String)vDataList.elementAt(17)).toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">TIME AND DATE EXAM: <font style="font-size:12px; font-weight:bold;">By Arrangement</font></td></tr>
				<tr>
					<td valign="top" class="thinborderBOTTOMLEFTRIGHT">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td colspan="2" align="center"><strong>IMPORTANT TO INSTRUCTOR</strong></td></tr>
							<tr>
								<td valign="top">1)</td>
								<td style="padding-left:5px;">PREPARE THIS REPORT IN INK AND IN YOUR OWN HAND WRITING.</td>
							</tr>
							<tr>
								<td valign="top">2)</td>
								<td style="padding-left:5px;">SUBMIT THIS PERSONALLY OR THROUGH THE 
								DEAN'S CLERK TO THE OFFICE OF THE REGISTRAR WITH YOUR SIGNATURE ON THE
								DATE INDICATED THIS SHOULD NOT BE HAND CARRIED BY THE STUDENT.</td>
							</tr>
							<tr>
								<td valign="top">3)</td>
								<td style="padding-left:5px;">SUBMIT THE BLUE BOOK OR EXAM PAPERS.</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" align="center" style="font-size:11px;"><strong>INSTRUCTOR'S GRADE REPORT</strong></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">DATE DUE: <font style="font-size:12px; font-weight:bold;"><%=WI.getStrValue(strDueDate,"&nbsp;")%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" align="center" style="font-size:11px;"><strong>TO BE FILLED IN BY THE INSTRUCTOR</strong></td></tr>
				<tr>
					<td valign="top" class="thinborder">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="thinborderBOTTOMRIGHT" height="18" style="font-size:12px;" align="center">SUBJECT</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">GRADE</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">UNIT</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">REMARK</td>
							</tr>
							<tr>
								<td class="thinborderRIGHT" height="28"><font style="font-size:12px; font-weight:bold;">
									<%=((String)vDataList.elementAt(8)).toUpperCase()%></font></td>
								<td class="thinborderRIGHT" height="28" align="center"><font style="font-size:12px; font-weight:bold;">&nbsp;</font></td>
								<td class="thinborderRIGHT" height="28" align="center"><font style="font-size:12px; font-weight:bold;">
									<%=(String)vDataList.elementAt(10)%></font></td>
								<td class="thinborderRIGHT" height="28"><font style="font-size:12px; font-weight:bold;">&nbsp;</font></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">DATE SUBMITTED:<br>&nbsp;<br></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:11px;" align="center">SIGNATURE OF THE INSTRUCTOR</td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">NOTED:<br>&nbsp;<br></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:11px;" align="center">DEAN OF COLLEGE</td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:12px;">APPROVED
					<div align="center"><br><strong><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></strong><br>
					UNIVERSITY REGISTRAR
					</div>
				</td></tr>
				<tr><td valign="top" class="thinborder">
					<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr><td class="thinborderRIGHT" width="15%" align="center" style="font-size:11px; font-weight:bold;">1</td>
						<td class="thinborderRIGHT" align="center" style="font-size:11px; font-weight:bold;">COPY FOR THE STUDENT</td></tr>
					</table>
				</td></tr>
				<tr>
					<td valign="top" class="thinborderBOTTOMLEFTRIGHT">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td colspan="4" align="center" style="font-size:11px;">RECEIVED COPY</td></tr>
							<tr>
								<td width="30%" valign="bottom" style="font-size:11px;">EDP CENTER:</td>
								<td width="20%" class="thinborderBOTTOM">&nbsp;</td>
								<td width="30%" valign="bottom" style="font-size:11px;">DATE:</td>
								<td width="20%" class="thinborderBOTTOM">&nbsp;</td>
							</tr>
							<tr><td height="2"></td></tr>
						</table>
					</td>
				</tr>
				<tr><td><font style="font-size:8px;"><%= WI.getStrValue((String)request.getSession(false).getAttribute("first_name"))%>
				&nbsp; &nbsp; &nbsp; &nbsp; <%=WI.getTodaysDateTime()%>
				</font></td></tr>
			</table>
		</td>
		<td width="1%"></td>
		<td width="24%" valign="top">
			<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr><td class="thinborderALL" align="center">
					<font style="font-size:12px; font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
					<br>APPLICATION FOR GRADE COMPLETION</font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">STUDENT NO: <font style="font-size:12px; font-weight:bold;"><%=vDataList.elementAt(1)%></font></td></tr>
				<%
				strTemp = WebInterface.formatName((String)vDataList.elementAt(2),(String)vDataList.elementAt(3),(String)vDataList.elementAt(4),4);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">NAME OF APPLICANT:<br><font style="font-size:12px; font-weight:bold;">&nbsp; 
					<%=strTemp.toUpperCase()%></font></td></tr>
				<%
				strTemp = ((String)vDataList.elementAt(5)).toUpperCase() + WI.getStrValue((String)vDataList.elementAt(6),"-","","").toUpperCase() 
					+ " &nbsp; " +(String)vDataList.elementAt(7);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">CRS AND YEAR: &nbsp; <font style="font-size:12px; font-weight:bold;"><%=strTemp%></font></td></tr>
				<%
				strTemp = ((String)vDataList.elementAt(8)).toUpperCase() +"<br>&nbsp; "+ ((String)vDataList.elementAt(9)).toUpperCase();
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">SUBJECT APPLIED FOR: 
					<font style="font-size:12px; font-weight:bold;">&nbsp; <%=strTemp%></font></td></tr>
				<%
				strTemp = (String)vDataList.elementAt(10);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">UNITS: &nbsp; <font style="font-size:12px; font-weight:bold;"><%=strTemp%></font> 
					&nbsp; &nbsp; SUBJECT CODE: <font style="font-size:12px; font-weight:bold;"><%=((String)vDataList.elementAt(11)).toUpperCase()%></font></td></tr>
					<%
					if(Integer.parseInt(WI.fillTextValue("semester")) == 0){
						strTemp = WI.fillTextValue("sy_to");
						strErrMsg = WI.getStrValue(WI.fillTextValue("semester")+WI.fillTextValue("sy_to"),"[","]","");
					}else{
						strTemp = WI.fillTextValue("sy_from");
						strErrMsg = WI.getStrValue(WI.fillTextValue("semester")+WI.fillTextValue("sy_from"),"[","]","");
					}
					%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">TERM: <font style="font-size:12px; font-weight:bold;">
					<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=strTemp%> 
					<%=strErrMsg%>
				</font></td></tr>
				<%
				strTemp = WebInterface.formatName((String)vDataList.elementAt(12),(String)vDataList.elementAt(13),(String)vDataList.elementAt(14),4);
				%>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">INSTRUCTOR:<br><font style="font-size:12px; font-weight:bold;"><%=strTemp.toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">COLLEGE:<br><font style="font-size:12px; font-weight:bold;">
				<%=((String)vDataList.elementAt(16)).toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">GRADE AS REPORTED: <font style="font-size:12px; font-weight:bold;">
					<%=((String)vDataList.elementAt(17)).toUpperCase()%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">TIME AND DATE EXAM: <font style="font-size:12px; font-weight:bold;">By Arrangement</font></td></tr>
				<tr>
					<td valign="top" class="thinborderBOTTOMLEFTRIGHT">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td colspan="2" align="center"><strong>IMPORTANT TO INSTRUCTOR</strong></td></tr>
							<tr>
								<td valign="top">1)</td>
								<td style="padding-left:5px;">PREPARE THIS REPORT IN INK AND IN YOUR OWN HAND WRITING.</td>
							</tr>
							<tr>
								<td valign="top">2)</td>
								<td style="padding-left:5px;">SUBMIT THIS PERSONALLY OR THROUGH THE 
								DEAN'S CLERK TO THE OFFICE OF THE REGISTRAR WITH YOUR SIGNATURE ON THE
								DATE INDICATED THIS SHOULD NOT BE HAND CARRIED BY THE STUDENT.</td>
							</tr>
							<tr>
								<td valign="top">3)</td>
								<td style="padding-left:5px;">SUBMIT THE BLUE BOOK OR EXAM PAPERS.</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" align="center" style="font-size:11px;"><strong>INSTRUCTOR'S GRADE REPORT</strong></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">DATE DUE: <font style="font-size:12px; font-weight:bold;"><%=WI.getStrValue(strDueDate,"&nbsp;")%></font></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" align="center" style="font-size:11px;"><strong>TO BE FILLED IN BY THE INSTRUCTOR</strong></td></tr>
				<tr>
					<td valign="top" class="thinborder">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td class="thinborderBOTTOMRIGHT" height="18" style="font-size:12px;" align="center">SUBJECT</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">GRADE</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">UNIT</td>
								<td class="thinborderBOTTOMRIGHT" style="font-size:12px;" align="center">REMARK</td>
							</tr>
							<tr>
								<td class="thinborderRIGHT" height="28"><font style="font-size:12px; font-weight:bold;">
									<%=((String)vDataList.elementAt(8)).toUpperCase()%></font></td>
								<td class="thinborderRIGHT" height="28" align="center"><font style="font-size:12px; font-weight:bold;">&nbsp;</font></td>
								<td class="thinborderRIGHT" height="28" align="center"><font style="font-size:12px; font-weight:bold;">
									<%=(String)vDataList.elementAt(10)%></font></td>
								<td class="thinborderRIGHT" height="28"><font style="font-size:12px; font-weight:bold;">&nbsp;</font></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">DATE SUBMITTED:<br>&nbsp;<br></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:11px;" align="center">SIGNATURE OF THE INSTRUCTOR</td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT">NOTED:<br>&nbsp;<br></td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:11px;" align="center">DEAN OF COLLEGE</td></tr>
				<tr><td class="thinborderBOTTOMLEFTRIGHT" style="font-size:12px;">APPROVED
					<div align="center"><br><strong><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)).toUpperCase()%></strong><br>
					UNIVERSITY REGISTRAR
					</div>
				</td></tr>
				<tr><td valign="top" class="thinborder">
					<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr><td class="thinborderRIGHT" width="15%" align="center" style="font-size:11px; font-weight:bold;">1</td>
						<td class="thinborderRIGHT" align="center" style="font-size:11px; font-weight:bold;">COPY FOR THE DEAN</td></tr>
					</table>
				</td></tr>
				<tr>
					<td valign="top" class="thinborderBOTTOMLEFTRIGHT">
						<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td colspan="4" align="center" style="font-size:11px;">RECEIVED COPY</td></tr>
							<tr>
								<td width="30%" valign="bottom" style="font-size:11px;">EDP CENTER:</td>
								<td width="20%" class="thinborderBOTTOM">&nbsp;</td>
								<td width="30%" valign="bottom" style="font-size:11px;">DATE:</td>
								<td width="20%" class="thinborderBOTTOM">&nbsp;</td>
							</tr>
							<tr><td height="2"></td></tr>
						</table>
					</td>
				</tr>
				<tr><td><font style="font-size:8px;"><%= WI.getStrValue((String)request.getSession(false).getAttribute("first_name"))%>
				&nbsp; &nbsp; &nbsp; &nbsp; <%=WI.getTodaysDateTime()%>
				</font></td></tr>
			</table>
		</td>
	</tr>
</table>
<%
}//end of while loop
}
%>
<script>
	window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
