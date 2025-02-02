<%@ page language="java" import="utility.*,basicEdu.BasicGEExtn,basicEdu.BasicEduReports,basicEdu.BasicGradeLocking,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	boolean bolCIT = strSchCode.startsWith("CIT");

String strStudID    = (String)request.getSession(false).getAttribute("userId");
if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}

if(!strStudID.equals(WI.fillTextValue("stud_id"))){%>
 <p style="font-size:14px; color:#FF0000;">Permission Denied.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CIT Report Card</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript">
	var imgWnd;
	var objCOA;
	var objCOAInput;
	function ShowStudentReportCard(){
		if(document.form_.sy_from.value.length == 0 || document.form_.sy_to.value.length == 0){
			alert("Please provide school year information.");
			return;
		}
		
		if(document.form_.grade_for.value.length == 0){
			alert("Please provide grading period information.");
			return;
		}
		
		if(document.form_.stud_id.value.length == 0){
			alert("Please provide student id.");
			return;
		}
	
		document.form_.show_report_card.value = "1";
		document.form_.print_page.value = "";
		this.ShowProcessing();
	}
	
	function ShowProcessing() {
		imgWnd=
		window.open("../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
		document.form_.submit();
		imgWnd.focus();
	}
	
	function CloseProcessing() {
		if (imgWnd && imgWnd.open && !imgWnd.closed) 
			imgWnd.close();
	}
	
	
</script>
<%
	DBOperation dbOP  = null;
	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strFinalGrade  = null;
	String strFinalRemark = null;

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
	
	
	Vector vUserInfo = null;
	Vector vRetResult = null;
	Vector vGradingPeriods = null;
	Vector vAcadSubjects = null;
	Vector vNonAcadSubjects = null;	
	Vector vRank = null;
	Vector vAverage = null;
	Vector vNumStud = null;
	Vector vStudAttendance = null;
	Vector vCharacterGrade = null;
	Vector vConductRating = null;
	Vector vValues = null;
	
	enrollment.SetParameter sp = new enrollment.SetParameter();
	BasicEduReports bedReports = new BasicEduReports();
	BasicGradeLocking bgl = new BasicGradeLocking();
	BasicGEExtn bedExtn = new BasicGEExtn();
	
	boolean bolIsFinalGrading = false;
	boolean bolIsSecondary = false;
	boolean bolHasMakabayan = false;
	int iLockStatus = 0;//added 2010-03-24
	int iInsertIndex = 0;
	double dFailingGrade = 0d;
	
	boolean bolIsGradeVerified = false;
	
	if(WI.fillTextValue("show_report_card").length() > 0){
		vUserInfo = bedReports.getReportCardInfo(dbOP, request);
		if (vUserInfo == null)
			strErrMsg = bedReports.getErrMsg();
		else{
			bolIsGradeVerified = bgl.checkLockStatus(dbOP, request, vUserInfo);
			//System.out.println(bolIsGradeVerified);
			iLockStatus = sp.isStudentLocked(dbOP, (String)vUserInfo.elementAt(0), (String)vUserInfo.elementAt(4), "1", "2");
			if(iLockStatus == 0 || iLockStatus == 2){//if unlocked or locked for printing only, then proceed
				//[0] => user_index      [6] => section (academic)
				//[1] => name            [7] => adviser name
				//[2] => cur_hist_index  [8] => level name
				//[3] => year_level      [9] => gender
				//[4] => sy_from         [10] => dob
				//[5] => sy_to           [11] => section (non-acad)
			
				strTemp = " select edu_level from bed_level_info where g_level = " + (String)vUserInfo.elementAt(3);
				strTemp = dbOP.getResultOfAQuery(strTemp, 0);
				
				if(strTemp.equals("3") || !bolCIT){
					strTemp = " select max(max_ptg) from school_grade where is_del = 2 and remark_index > 1 ";
					dFailingGrade = Double.parseDouble(WI.getStrValue(dbOP.getResultOfAQuery(strTemp, 0), "2"));
				
					if(Integer.parseInt((String)vUserInfo.elementAt(3)) >= 11)
						bolIsSecondary = true;
				
					vGradingPeriods = bedExtn.getGradingPeriods(dbOP, request);
					
					vRetResult = bedExtn.generateReportCard(dbOP, request);
					if(vRetResult == null)
						strErrMsg = bedExtn.getErrMsg();
					else{
						vAcadSubjects = (Vector)vRetResult.remove(0);
						vNonAcadSubjects = (Vector)vRetResult.remove(0);
					}
					
					vStudAttendance = bedReports.getStudentAttendance(dbOP, request);
					if(vStudAttendance == null)
						strErrMsg = bedReports.getErrMsg();
							
					vCharacterGrade = bedExtn.getCharacterTraitGrades(dbOP, request, (String)vUserInfo.elementAt(0), (String)vUserInfo.elementAt(2));
					if(vCharacterGrade == null)
						strErrMsg = bedExtn.getErrMsg();
					
					bolIsFinalGrading = bedExtn.isFinalGrading(dbOP, request);
				}
				else{
					vUserInfo = null;
					strErrMsg = "Report card only for high school students.";				
				}
			}
			else{
				vUserInfo = null;
				if(iLockStatus == -1)
					strErrMsg = sp.getErrMsg();
				else if(iLockStatus == 1)
					strErrMsg = "Student credential is locked for viewing and printing.";
			}
		}
	}
%>
<body bgcolor="#8C9AAA" onUnload="CloseProcessing();">
<form name="form_" action="./basic_report_card.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F">
			<td height="25" colspan="6" align="center"><font color="#FFFFFF">
				<strong>:::: STUDENT REPORT CARD ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">School Year:</td>
			<td width="20%"> 
			<input type="hidden" name="offering_sem" value="1">
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox"
				value="<%=WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"))%>"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox"
				value="<%=WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"))%>" 				
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes"></td>
		    <td width="60%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Grading Period: </td>
			<td colspan="2">
				<%
					strTemp = 
						" from fa_pmt_schedule "+
						" where is_del = 0 and is_valid = 2 "+
						" and bsc_grading_name is not null "+
						" order by exam_period_order desc";
				%>
				<select name="grade_for">
					<%=dbOP.loadCombo("PMT_SCH_INDEX","BSC_GRADING_NAME",strTemp, WI.fillTextValue("grade_for"), false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Student ID: </td>
			<td><input name="stud_id2" type="text" size="32" value="<%=(String)request.getSession(false).getAttribute("userId")%>" class="textbox_noborder" readonly="yes">
			<input name="stud_id" type="hidden" size="32" value="<%=(String)request.getSession(false).getAttribute("userId")%>" class="textbox_noborder" readonly="yes">
			
			</td>
		    <td valign="top">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<a href="javascript:ShowStudentReportCard();"><img src="../../images/form_proceed.gif" border="0"></a></td>
		</tr>
	</table>
	
<%if(vUserInfo != null && vUserInfo.size() > 0){

if(!bolIsGradeVerified)
	bolIsFinalGrading = false;
%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="5"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td colspan="4"><strong><u>Student Information</u></strong></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Name:</td>
			<td colspan="3"><%=(String)vUserInfo.elementAt(1)%></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Section: </td>
			<td width="25%"><%=(String)vUserInfo.elementAt(6)%></td>
	  	    <td width="17%">Adviser:</td>
	  	    <td width="38%"><%=(String)vUserInfo.elementAt(7)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Year Level: </td>
			<td><%=(String)vUserInfo.elementAt(8)%></td>
	  	    <td>School Year: </td>
	  	    <td><%=(String)vUserInfo.elementAt(4)%>-<%=(String)vUserInfo.elementAt(5)%></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr><!--
		<tr>
			<td colspan="4">
			<%
			strTemp = WI.fillTextValue("print_new");
			if(strTemp.equals("1") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
			%><input type="radio" name="print_new" value="1" <%=strErrMsg%> > Click to print new format
			<%
			if(strTemp.equals("0"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
			%><input type="radio" name="print_new" value="0" <%=strErrMsg%> > Click to print old format
			</td>
			<td height="25" align="right">
				<%if(iLockStatus == 0){//if unlocked, then show this print button%>
					<a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a></td>
				<%}else{%>
					<font size="1">Student credential locked for printing.</font>
				<%}%>
			</td>
		</tr>	-->	
	</table>
<%}

if(vAcadSubjects != null || vNonAcadSubjects != null){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td align="center" rowspan="2" class="thinborder"><strong>SUBJECT</strong></td>		
			<td colspan="<%=vGradingPeriods.size()/2%>" height="15" class="thinborder" align="center"><strong>PERIODIC RATINGS</strong></td>
		    <td rowspan="2" align="center" class="thinborder"><strong>Final Rating</strong></td>			
		    <td rowspan="2" align="center" class="thinborder"><strong>Action Taken</strong></td>
			<td rowspan="2" align="center" class="thinborder"><strong>Unit</strong></td>
		</tr>
		<tr>
			<%	int iCount = 1;
			for(int i = 0; i < vGradingPeriods.size(); i += 2, iCount++){%>
		  	<td height="15" align="center" class="thinborder"><strong><%=iCount%></strong></td>
			<%}%>
      	</tr>		
	<%
	
	if(vAcadSubjects.size() > 0){
		strFinalRemark = (String)vAcadSubjects.remove(0);//final remark
		strErrMsg = (String)vAcadSubjects.remove(0);//final academic number of students
		strTemp = (String)vAcadSubjects.remove(0);//final academic rank
		strFinalGrade = (String)vAcadSubjects.remove(0);//final academic average
		
		vNumStud = (Vector)vAcadSubjects.remove(0);//academic number of students per quarter
		vRank = (Vector)vAcadSubjects.remove(0);//academic student ranking per quarter
		vAverage = (Vector)vAcadSubjects.remove(0);//academic student average per quarter
		
		if(vCharacterGrade != null && vCharacterGrade.size() > 0){
			Vector vTemp = null;
			for(int i = 0; i < vCharacterGrade.size(); i+=7){
				vTemp = new Vector();
				vTemp.addElement((String)vCharacterGrade.elementAt(i+2));
				vTemp.addElement((String)vCharacterGrade.elementAt(i+3));
				vTemp.addElement((String)vCharacterGrade.elementAt(i+4));
				vTemp.addElement((String)vCharacterGrade.elementAt(i+5));
				
				strTemp3 = null;
				if(strSchCode.startsWith("CIT")){
					strTemp3 = 
						" select remark_abbr from school_grade "+
						" join remark_status on (remark_status.remark_index = school_grade.remark_index) "+
						" where school_grade.is_del = 2 "+
						" and "+(String)vCharacterGrade.elementAt(i+6)+" between min_ptg and max_ptg ";
					strTemp3 = dbOP.getResultOfAQuery(strTemp3, 0);
				}
				
				vAcadSubjects.addElement(null);//0
				vAcadSubjects.addElement(null);//1
				vAcadSubjects.addElement((String)vCharacterGrade.elementAt(i+1));//2
				vAcadSubjects.addElement(null);//3
				vAcadSubjects.addElement(null);//4
				vAcadSubjects.addElement(vTemp);//5
				vAcadSubjects.addElement((String)vCharacterGrade.elementAt(i+6));//6
				vAcadSubjects.addElement(strTemp3);//7
				vAcadSubjects.addElement(null);//8
				vAcadSubjects.addElement(null);//9
				vAcadSubjects.addElement(null);//10
				vAcadSubjects.addElement("0");//11
			}
		}
	}
	
	for(int i = 0; i < vAcadSubjects.size(); i += 12){
		Vector vTemp = (Vector)vAcadSubjects.elementAt(i+5);
		//System.out.println("vTemp: "+vTemp);
		boolean bolIsMakabayan = ((String)vAcadSubjects.elementAt(i+11)).equals("1");
	%>
		<tr>
			<td height="25" class="thinborder" width="40%">
				<%if(bolIsMakabayan){%>&nbsp;&nbsp;&nbsp;&nbsp;<%}%>
				<%=(String)vAcadSubjects.elementAt(i+2)%></td>
		<%	for(int iTemp = 0; iTemp < vTemp.size(); iTemp++){
			strTemp = (String)vTemp.elementAt(iTemp);
			strErrMsg = "";
			strTemp2 = "";
			
			if(strTemp == null || Double.parseDouble(strTemp) == 0d)
				strTemp = "&nbsp;";
			else{
				strTemp = CommonUtil.formatFloat(strTemp, true);
				if(Double.parseDouble(strTemp) <= dFailingGrade){
					strErrMsg = "<font color='#FF0000'>";
					strTemp2 = "</font>";
				}
			}
			
			if(!bolIsGradeVerified)
				strTemp = "&nbsp;";
		%>
			<td width="8%" class="thinborder" align="center"><%=strErrMsg%><%=strTemp%><%=strTemp2%></td>
		<%}%>
			<td class="thinborder" width="10%">
				<%
				strTemp = "&nbsp;";
				strErrMsg = "";
				strTemp2 = "";
				if(bolIsFinalGrading){
					strTemp = (String)vAcadSubjects.elementAt(i+6);
					strErrMsg = "";
					strTemp2 = "";
					
					if(strTemp == null || Double.parseDouble(strTemp) == 0d)
						strTemp = "&nbsp;";
					else{
						if(Double.parseDouble(strTemp) <= dFailingGrade){
							strErrMsg = "<font color='#FF0000'>";
							strTemp2 = "</font>";
						}
					}
				}%>
				<%=strErrMsg%><%=strTemp%><%=strTemp2%></td>
		    <td class="thinborder" width="10%">
			<%if(bolIsFinalGrading){%>
				<%=strErrMsg%><%=WI.getStrValue((String)vAcadSubjects.elementAt(i+7), "&nbsp;")%><%=strTemp2%>
			<%}else{%>&nbsp;<%}%></td>
			<td class="thinborder" align="center" width="8%">
			<%if(bolIsFinalGrading){%>
				<%if(((String)vAcadSubjects.elementAt(i+2)).equals("MAKABAYAN") && strSchCode.startsWith("CIT")){%>(<%}%>
				<%=WI.getStrValue((String)vAcadSubjects.elementAt(i+4), "&nbsp;")%>
				<%if(((String)vAcadSubjects.elementAt(i+2)).equals("MAKABAYAN") && strSchCode.startsWith("CIT")){%>)<%}%>
			<%}else{%>&nbsp;<%}%></td>
		</tr>
	<%}%>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
<%}

if(vStudAttendance != null && vStudAttendance.size() > 0){
	int k = 0;
	int iTemp = 0;
	
	Vector vMonths = new Vector();
	for(int i = 0; i < vStudAttendance.size(); i+=5)
		vMonths.addElement((String)vStudAttendance.elementAt(i));
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" align="center" width="16%" class="thinborder">&nbsp;</td>
			<%
			for(int i = 5; i <= 15; i++){
				k = i;
				if(i > 11)// if the month is january to april
					k = k - 12; 
				
				strTemp = Integer.toString(k+1);
				if(strTemp.length() == 1)
					strTemp = "0"+strTemp;
			%>
			<td align="center"width="7%" class="thinborder"><%=strTemp%></td>
			<%}%>
			<td align="center"width="7%" class="thinborder">Total</td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Days of School </td>
			<%
			iTemp = 0;
			for(int i = 5; i <= 15; i++){
				k = i;
				if(i > 11)// if the month is january to may
					k = k - 12;
				
				k = vMonths.indexOf(Integer.toString(k));
				if(k == -1)
					strTemp = "&nbsp;";
				else{
					if((String)vStudAttendance.elementAt((k*5)+1) == null)
						strTemp = "&nbsp;";
					else{
						strTemp = (String)vStudAttendance.elementAt((k*5)+1);
						iTemp += Integer.parseInt(strTemp);
					}			
				}
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
			<%}%>
			<td align="center" class="thinborder">
			<%if(bolIsFinalGrading){%>
				<%=iTemp%>
			<%}else{%>&nbsp;<%}%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Days Present </td>
			<%
			double dTemp = 0;
			double dValue = 0;
			for(int i = 5; i <= 15; i++){//start from june...			
				k = i;
				if(i > 11)// if the month is january to april
					k = k - 12; 
				
				k = vMonths.indexOf(Integer.toString(k));
				if(k == -1)
					strTemp = "&nbsp;";
				else{
					if((String)vStudAttendance.elementAt((k*5)+4) == null)
						strTemp = "&nbsp;";
					else{
						dValue = Double.parseDouble(WI.getStrValue((String)vStudAttendance.elementAt((k*5)+4), "0"));
						dTemp += dValue;
						if(dValue%1 == 0)
							strTemp = Integer.toString((int)dValue);
						else
							strTemp = Double.toString(dValue);
					}
				}
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
			<%}
			
			if(dTemp%1 == 0)
				strTemp = Integer.toString((int)dTemp);
			else
				strTemp = Double.toString(dTemp);
			%>
			<td align="center" class="thinborder">
			<%if(bolIsFinalGrading){%>
				<%=strTemp%>
			<%}else{%>&nbsp;<%}%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Times Tardy </td>
			<%
			iTemp = 0;
			for(int i = 5; i <= 15; i++){
				k = i;
				if(i > 11)// if the month is january to april
					k = k - 12; 
				
				k = vMonths.indexOf(Integer.toString(k));
				if(k == -1)
					strTemp = "&nbsp;";
				else{
					if((String)vStudAttendance.elementAt((k*5)+3) == null)
						strTemp = "&nbsp;";
					else{
						strTemp = (String)vStudAttendance.elementAt((k*5)+3);
						iTemp += Integer.parseInt(strTemp);
					}
				}
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>
			<%}%>
			<td align="center" class="thinborder">
			<%if(bolIsFinalGrading){%>
				<%=iTemp%>
			<%}else{%>&nbsp;<%}%></td>
		</tr>
	</table>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#697A8F">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="show_report_card">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
