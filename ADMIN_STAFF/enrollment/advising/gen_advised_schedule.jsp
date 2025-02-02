<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTempStudId = "";
	String strStudType = WI.fillTextValue("stud_type");
	String strDegreeType = WI.fillTextValue("degree_type");

	if(strStudType.startsWith("New"))
		strTempStudId = request.getParameter("temp_id");
	else
		strTempStudId = request.getParameter("stud_id");

	int iMaxDisplayed = 0;
	Vector[] vAutoAdvisedList = new Vector[2];

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-advised schedule","gen_advised_schedule.jsp");
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
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"gen_advised_schedule.jsp");
//switch off security if called from online advisign page of student... this page can't be refreshed.

if(WI.fillTextValue("online_advising").compareTo("1") ==0) {
	iAccessLevel = 2;
	if((String)request.getSession(false).getAttribute("tempIndex") != null) {
		iAccessLevel = 0;

		//I have to make sure it is allowed, and not blocked.
		enrollment.NAApplicationForm naApplForm = new enrollment.NAApplicationForm();
		java.util.Vector vOnlineAdv = naApplForm.checkOnlineAdvsingStat(dbOP, (String)request.getSession(false).getAttribute("tempIndex"));
		if(vOnlineAdv != null && ((String)vOnlineAdv.elementAt(0)).equals("2")) 
			iAccessLevel = 2;
	}
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

String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
Vector vFinalAdviseList = null;
boolean bolFatalErr = true;

Advising advising = new Advising();
//if add record is called -- load the vFinalAdviseList with recorded result. else show the probable information.
strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") ==0)
{
	vFinalAdviseList = advising.saveStudentLoad(dbOP, request);
	if(vFinalAdviseList == null || vFinalAdviseList.size() ==0)
	{
		strErrMsg = advising.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Please re-schedule. System can't save student schedule. May be the room is already taken. If you find this error , please contact system admin with this error description.";
	}
	else
	{
		bolFatalErr = false;
		strErrMsg = "Advised subjects saved successfully. Click print to print this page.";
		
		/** 
		* this is added for AUF : Nov 02, 2014 to update the year level
		* Rule: Year level = max subject belong to the year level, if same number of subject, get the max year level
		* YEAR level to be updated after advising.
		*/
		if(strSchCode.startsWith("AUF")) {
			enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();

			String strUserIndex = dbOP.getResultOfAQuery("select user_index from user_Table where id_number = '"+strTempStudId+"'", 0);
			if(strUserIndex != null) {//old student
				String strSemester = WI.fillTextValue("current_sem");
				if (strSemester == null || strSemester.length() == 0) {
					strSemester = WI.fillTextValue("semester"); //for old studs.
				}
				String strSQLQuery = null;
				int iYrLevel = -1;
				String strTableName = null;
			    if(strDegreeType.equals("2"))
        			strTableName = "CCULUM_MEDICINE";
      			else
        			strTableName = "CURRICULUM";
				strSQLQuery = "select year, count(*) from enrl_final_cur_list "+
        			"join "+strTableName+" on ("+strTableName+".cur_index = enrl_final_cur_list.cur_index) "+
        			" where ENRL_FINAL_CUR_LIST.sy_from = "+WI.fillTextValue("sy_from")+" and current_semester = "+strSemester+" and is_temp_stud = 0 and user_index = "+strUserIndex+
        			" group by year order by count(*) desc, year desc";
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
				if(strSQLQuery != null && !strSQLQuery.equals("0")) {
					iYrLevel = Integer.parseInt(strSQLQuery);
					strSQLQuery = "select max(year) from "+strTableName+" where course_index = "+WI.fillTextValue("ci")+" and is_valid = 1";
					if(strDegreeType.equals("2"))
					  strSQLQuery += " and cy_from = "+WI.fillTextValue("syf")+" and cy_to = "+WI.fillTextValue("syt");
					else
					  strSQLQuery += " and sy_from = "+WI.fillTextValue("syf")+" and sy_to = "+WI.fillTextValue("syt");
					java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
					if(rs.next()) {
					  if(rs.getInt(1) < iYrLevel)
						iYrLevel = rs.getInt(1);
					}
					rs.close();
				}
				
				
				
				//offlineAdm.determineYrLevelOfStudAUF(dbOP, request, strUserIndex, WI.fillTextValue("ci"), null,
				//				WI.fillTextValue("sy_from"), strSemester, strDegreeType, false, WI.fillTextValue("syf"), WI.fillTextValue("syt"));
				if(iYrLevel > -1) {
					strSQLQuery = "select OLD_STUD_APPL_INDEX from na_old_stud where user_index = "+strUserIndex+
								" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+strSemester+" and is_valid = 1";
					strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
					if(strSQLQuery != null) {
						strSQLQuery = "update na_old_stud set year_level = "+String.valueOf(iYrLevel)+" where old_stud_appl_index = "+strSQLQuery;	
						dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
						dbOP.commitOP();
					}
				}
			}
		}
		else {
			dbOP.commitOP();
			dbOP.forceAutoCommitToTrue();
			
			///save here transaction for Lasalle.. 
			String strSemester = WI.fillTextValue("current_sem");
			if (strSemester == null || strSemester.length() == 0) {
				strSemester = WI.fillTextValue("semester"); //for old studs.
			}
			String strUserIndex = dbOP.getResultOfAQuery("select user_index from user_Table where id_number = '"+strTempStudId+"'", 0);
			boolean bolIsTempStud = false;
			if(strUserIndex == null) {
				strUserIndex = dbOP.getResultOfAQuery("select application_index from new_application where temp_id = '"+strTempStudId+"'", 0);
				bolIsTempStud = true;
			}
			new enrollment.SetParameter().trackTimeForAdvising(dbOP, request, strUserIndex, bolIsTempStud, WI.fillTextValue("sy_from"), strSemester);
			request.getSession(false).removeAttribute("start_time_long");
		}
	}
}
else
{//System.out.println("I am here.");
	vFinalAdviseList = advising.checkScheduleBeforeSave(dbOP, request);
	if(vFinalAdviseList == null || vFinalAdviseList.size() ==0)
	{
		strErrMsg = advising.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Please re-schedule. System can't create student schedule. If u find this error again, please contact system admin with error description.";
	}
}

String strSemester = null;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
function ComputeAssessmentFee()
{
	var strStudID = document.advising.stud_id.value;
	var strTempStudID = document.advising.temp_id.value;
	var vSemester     = document.advising.current_sem.value;
	if(vSemester.length ==0)
		vSemester = document.advising.semester.value;


	var pgLoc;
	if(strStudID.length > 0)
		pgLoc = "../../fee_assess_pay/assessment/fee_assess_pay_assessment.jsp?dispOnly=1&stud_id="+escape(strStudID)+"&sy_from="+
		document.advising.sy_from.value+"&sy_to="+document.advising.sy_to.value+"&semester="+vSemester;
	else
		pgLoc = "../../fee_assess_pay/assessment/fee_assess_pay_assessment.jsp?dispOnly=1&stud_id="+escape(strTempStudID)+"&sy_from="+
		document.advising.sy_from.value+"&sy_to="+document.advising.sy_to.value+"&semester="+vSemester;
	pgLoc += "&online_advising="+document.advising.online_advising.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AddRecord()
{
	document.advising.addRecord.value = 1;
	document.advising.hide_save.src = "../../../images/blank.gif";
	document.advising.submit();
}
function PrintPg()
{
	<%if(strSchCode.startsWith("CIT")){%>
		if(!confirm('Click OK to continue to printing. Printing will lock Advising.'))
			return;
	<%}%>
	
	pgLoc = "./gen_advised_schedule_print.jsp?stud_id="+escape(document.advising.stud_id.value)+"&temp_id="+
				escape(document.advising.temp_id.value);
	<%if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("PWC") || strSchCode.startsWith("UB")){%>
		pgLoc = "../../registrar/student_ids/validate_and_print_reg_form.jsp?addRecord=1&stud_id=<%=strTempStudId%>";	
	<%}%>
	
	pgLoc += "&online_advising="+document.advising.online_advising.value;
	
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function AddOptionalOthCharge() {
	var strStudID = escape(document.advising.stud_id.value);
	if(strStudID.length == 0)
		strStudID = escape(document.advising.temp_id.value);
		
	var strSemester = document.advising.current_sem.value;
	if(strSemester.length == 0) 
		strSemester = document.advising.semester.value;
		
	pgLoc = "./assessment_optional_fee.jsp?stud_id="+strStudID+"&sy_from="+document.advising.sy_from.value+"&sy_to="+document.advising.sy_to.value+
	"&semester="+strSemester;
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=700,left=0,top=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
String strAuthTypeIndex = WI.getStrValue(request.getSession(false).getAttribute("authTypeIndex"),"0");

if(strAuthTypeIndex.compareTo("4") !=0){//student logged in for online advising %>
<body bgcolor="#D2AE72">
<%}else{%>
<body bgcolor="#9FBFD0">
<%}%>

<form name="advising" action="./gen_advised_schedule.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(strAuthTypeIndex.compareTo("4") ==0){//student logged in for online advising %>
    <tr bgcolor="#A49A6A">
<%}%>      <td height="25" colspan="2" align="center"><strong> <font color="#FFFFFF"> ::::
          REGULAR/IRREGULAR STUDENT ADVISING PAGE :::: </font></strong></td>
    </tr>
    <tr> <td width="1%"></td>
      <td width="99%" height="25">
<% if (strSchCode.startsWith("CPU") || strErrMsg != null){%>
<a href="javascript:history.back()"><img align="right" src="../../../images/go_back.gif" width="50" height="27" border="0"></a>	  
<%}

if(strErrMsg != null){%>
<font size="3"><strong><%=strErrMsg%></strong></font>
<%
if(bolFatalErr)
	return;
}else{%> &nbsp; <%}%>
</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" valign="bottom">Student ID </td>
      <td height="25"  colspan="3" valign="bottom">Course </td>
      <td valign="bottom">Curriculum SY </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><strong>
	<%=strTempStudId%>	  </strong></td>
      <td  colspan="3" height="25"><strong><%=WI.fillTextValue("cn")%></strong></td>
      <td><strong><%=WI.fillTextValue("syf")%> - <%=WI.fillTextValue("syt")%></strong></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="34%" height="25" valign="bottom">Student name </td>
      <td height="25"  colspan="3" valign="bottom">Major </td>
      <td width="29%" valign="bottom">Term </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><strong><%=WI.fillTextValue("stud_name")%> </strong></td>
      <td colspan="3" height="25"><strong><%=WI.fillTextValue("mn")%></strong></td>
      <td height="25"><strong>
<%
String[] astrConvertSem = {"Summer","1st Term","2nd Term","3rd Term","4th Term", "5th Term"};
strSemester = WI.fillTextValue("current_sem");
if(strSemester.length() ==0)
	strSemester = WI.fillTextValue("semester");
if(strSemester.length() > 0)
	strTemp = astrConvertSem[Integer.parseInt(strSemester)];
%>
	<%=strTemp%></strong><font size="1">&nbsp;</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Student type </td>
      <td height="25" colspan="3" valign="bottom">Year </td>
      <td height="25" valign="bottom"><font size="2">School Year </font></td>
    </tr>
<%
strTemp =  WI.fillTextValue("stud_type");
if(strTemp.startsWith("New"))
	strTemp = "New";
%>
   <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><strong> <%=strTemp%> </strong></td>
      <td colspan="3" height="25"><strong><%=WI.getStrValue(WI.fillTextValue("year_level"),"N/A")%> Year</strong></td>
      <td height="25"><font size="2"><strong> <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="152%" height="25" colspan="6"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">LIST OF SUBJECTS ADVISED
          WITH SCHEDULE</div></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="43%">Maximum units the student can take : <strong><%=request.getParameter("maxAllowedLoad")%></strong></td>
      <td width="30%">Total student load: <strong><%=request.getParameter("sub_load")%></strong></td>
      <td width="25%">No of Subjects: <strong><%=vFinalAdviseList.size()/5%></strong></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="20%" height="25" align="center"><font size="1"><strong>SUBJECT
        CODE</strong></font></td>
      <td width="30%" align="center"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
      <% if (!strSchCode.startsWith("CPU")){ %>
      <td width="5%" align="center"><font size="1"><strong>LEC. UNITS</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>LAB. UNITS</strong></font></td>
<%}%> 
      <td width="5%" align="center"><font size="1"><strong>TOTAL UNITS</strong></font></td>
      <td width="5%" align="center"><strong><font size="1">UNITS TO TAKE</font></strong></td>
<% 
	if (strSchCode.startsWith("CPU"))
		strTemp = "STUBCODE";
	else
		strTemp = "SECTION";
%> 
      <td width="5%" align="center"><font size="1"><strong><%=strTemp%></strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>ROOM #</strong></font></td>
      <td width="20%" align="center"><font size="1"><strong>SCHEDULE</strong></font></td>
    </tr>
    <%
for(int i = 0,j=0; i<vFinalAdviseList.size(); ++i,++j)
{%>
    <tr>
      <td height="25"><%=request.getParameter("sub_code"+(String)vFinalAdviseList.elementAt(i+4))%>
	  <%
	  if(WI.fillTextValue("nstp_val"+(String)vFinalAdviseList.elementAt(i+4)).length() > 0){%>
	  (<%=WI.fillTextValue("nstp_val"+(String)vFinalAdviseList.elementAt(i+4))%>)
	  <%}%></td>
      <td><%=request.getParameter("sub_name"+(String)vFinalAdviseList.elementAt(i+4))%></td>
<% if (!strSchCode.startsWith("CPU")) {%> 
      <td><%=WI.getStrValue(WI.fillTextValue("lec_unit"+(String)vFinalAdviseList.elementAt(i+4)),"&nbsp;")%></td>
      <td><%=WI.getStrValue(WI.fillTextValue("lab_unit"+(String)vFinalAdviseList.elementAt(i+4)),"&nbsp;")%></td>
<%}%> 
	  
      <td><%=request.getParameter("total_unit"+(String)vFinalAdviseList.elementAt(i+4))%></td>
      <td><%=request.getParameter("ut"+(String)vFinalAdviseList.elementAt(i+4))%></td>
<%
	if (strSchCode.startsWith("CPU"))  
		strTemp = (String)vFinalAdviseList.elementAt(i+1);
	else
		strTemp = request.getParameter("sec"+(String)vFinalAdviseList.elementAt(i+4));
%>
      <td><%=strTemp%></td>
      <td><%=WI.getStrValue((String)vFinalAdviseList.elementAt(i+2),"TBA")%></td>
      <td><%=WI.getStrValue((String)vFinalAdviseList.elementAt(i+3),"TBA")%>
        <!-- all the hidden fileds are here. -->
        <input type="hidden" name="sub_code<%=j%>" value="<%=request.getParameter("sub_code"+(String)vFinalAdviseList.elementAt(i+4))%>">
        <input type="hidden" name="sub_name<%=j%>" value="<%=request.getParameter("sub_name"+(String)vFinalAdviseList.elementAt(i+4))%>">
        <input type="hidden" name="lab_unit<%=j%>" value="<%=request.getParameter("lab_unit"+(String)vFinalAdviseList.elementAt(i+4))%>">
        <input type="hidden" name="lec_unit<%=j%>" value="<%=request.getParameter("lec_unit"+(String)vFinalAdviseList.elementAt(i+4))%>">
        <input type="hidden" name="total_unit<%=j%>" value="<%=request.getParameter("total_unit"+(String)vFinalAdviseList.elementAt(i+4))%>">
		<input type="hidden" name="ut<%=j%>" value="<%=request.getParameter("ut"+(String)vFinalAdviseList.elementAt(i+4))%>">
        <input type="hidden" name="sec<%=j%>" value="<%=request.getParameter("sec"+(String)vFinalAdviseList.elementAt(i+4))%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vFinalAdviseList.elementAt(i)%>">
        <input type="hidden" name="sec_index<%=j%>" value="<%=(String)vFinalAdviseList.elementAt(i+1)%>">
<input type="hidden" name="nstp_val<%=j%>" value="<%=WI.fillTextValue("nstp_val"+(String)vFinalAdviseList.elementAt(i+4))%>">
        <input type="hidden" name="checkbox<%=j%>" value="checkbox"> 
	  </td>
    </tr>
    <%
i = i+4;
}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" align="right">
<% if (strSchCode.startsWith("CPU")){%> 
	  	<a href="javascript:history.back()"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a>
<%}%>	  </td>
    </tr>
    <%
if(WI.fillTextValue("addRecord").compareTo("1") != 0){%>
    <tr> 
      <td width="5%" height="25" >&nbsp;</td>
      <td colspan="2" > <a href="javascript:AddRecord();"><img src="../../../images/save.gif" name="hide_save" border="0"></a><font size="1">click 
        to save advised subjects &amp; schedule</font></td>
      <td width="35%" >&nbsp;</td>
    </tr>
    <%}else if(strSchCode.startsWith("NEU") && WI.fillTextValue("online_advising").equals("1")) {//show total assessment.. and click on view details.. 
	enrollment.FAFeeOperation FO = new enrollment.FAFeeOperation();
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	boolean bolIsTempUser = false;
	if(strUserIndex == null) {
		strUserIndex = (String)request.getSession(false).getAttribute("tempIndex");
		bolIsTempUser = true;
	}
	
	if(WI.fillTextValue("temp_id").length() > 0) {
		if(dbOP.mapUIDToUIndex(WI.fillTextValue("temp_id")) == null)
			bolIsTempUser = true;
	}
	
	int iIndex = 0;
	double dOutStandingFee = 0d;
	double dTutionFee = 0d;
	double dMiscFee = 0d;
	double dCompLabFee = 0d;
	FO.setIsBasic(bolIsTempUser);
	//System.out.println(bolIsTempUser);
	//System.out.println("1: "+request.getParameter("sy_from"));
	//System.out.println("1: "+request.getParameter("sy_to"));
	//System.out.println("1: "+request.getParameter("semester"));
	dTutionFee 		= FO.calTutionFee(dbOP, strUserIndex,bolIsTempUser,request.getParameter("sy_from"),request.getParameter("sy_to"),
											WI.fillTextValue("year_level"), strSemester);//System.out.println("1: "+FO.getErrMsg());
	dCompLabFee 	= FO.calHandsOn(dbOP, strUserIndex,bolIsTempUser,request.getParameter("sy_from"),request.getParameter("sy_to"),
											WI.fillTextValue("year_level"), strSemester);//System.out.println("2: "+FO.getErrMsg());
	dMiscFee 		= FO.calMiscFee(dbOP, strUserIndex,bolIsTempUser,request.getParameter("sy_from"),request.getParameter("sy_to"),
											WI.fillTextValue("year_level"), strSemester);//System.out.println("3: "+FO.getErrMsg());
	FO.checkIsEnrolling(dbOP,strUserIndex,request.getParameter("sy_from"),
				request.getParameter("sy_to"),strSemester);
	if(!bolIsTempUser)
		dOutStandingFee = FO.calOutStandingOfPrevYearSemEnrolling(dbOP, strUserIndex);//System.out.println(fOutStandingFee);
	//System.out.println(fTutionFee);
	//System.out.println(fCompLabFee);
	//System.out.println(fMiscFee);
	if(FO.getErrMsg() != null)
		strErrMsg = FO.getErrMsg();
	else
		strErrMsg = null;
	
		if(strErrMsg != null) {%>
		<tr>
		  <td height="25" >&nbsp;</td>
		  <td colspan="3" style="font-size:18px; color:#FF0000; font-weight:bold">Advised Successfully But Error in Displaying Assessment Information: <%=strErrMsg%> </td>
		</tr>
		<%}else{%>
			<tr>
			  <td height="25" width="5%">&nbsp;</td>
			  <td style="font-weight:bold; font-size: 14px;" width="26%">Total Assessment: </td>
			  <td style="font-weight:bold; font-size: 14px;" width="12%" align="right"><%=CommonUtil.formatFloat(dTutionFee+dMiscFee+dCompLabFee,true)%></td>
			  <td>&nbsp;</td>
			</tr>
			<tr>
			  <td height="25" >&nbsp;</td>
			  <td style="font-weight:bold; font-size: 14px;">Previous Account Balance : </td>
			  <td style="font-weight:bold; font-size: 14px;" align="right"><%=CommonUtil.formatFloat(dOutStandingFee,true)%></td>
			  <td>&nbsp;</td>
			</tr>
			<tr>
			  <td height="25" >&nbsp;</td>
			  <td style="font-weight:bold; font-size: 14px;">Total Balance Payable: </td>
			  <td style="font-weight:bold; font-size: 14px;" align="right"><%=CommonUtil.formatFloat(dTutionFee+dMiscFee+dCompLabFee+dOutStandingFee,true)%></td>
			  <td>&nbsp;
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  <%if(!bolIsTempUser) {%>
			 	<input type="button" name="122" value=" <<< View Details >>> " style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="ComputeAssessmentFee();">
			  <%}%>
			  </td>
			</tr>
		<%}%>
	
	<%}else{%>
    <tr> 
      <td width="5%" height="25" >&nbsp;</td>
      <td width="26%" ><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a></td>
      <td width="34%" > 
<%
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
if(strSchoolCode.startsWith("AUF")){%>
	  <a href="javascript:AddOptionalOthCharge();"><img src="../../../images/add.gif" border="0"></a> 
        <font size="1">Addl assessment info</font> 
<%}%>		</td>
      <td width="35%"> <div align="center"> 
     <%
	  if(WI.fillTextValue("online_advising").compareTo("1") ==0 || strSchoolCode.startsWith("VMUF")) {%>
          <a href="javascript:ComputeAssessmentFee();"><img src="../../../images/compute_assess.gif"  border="0"></a> 
          <font size="1">click to show assessment</font> 
          <%}%>
     <%if(strSchoolCode.startsWith("CGH") && !WI.fillTextValue("online_advising").equals("1") ) {%>
         <input type="button" name="122" value=" Apply Installation Fee " style="font-size:11px; height:24px;border: 1px solid #FF0000;" onClick="AddOptionalOthCharge();">
     <%}%>
        </div></td>
    </tr>
    <%}%>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#B8CDD1">
<%
if(strAuthTypeIndex.compareTo("4") ==0){//student logged in for online advising %>
    <tr bgcolor="#47768F">
<%}else{%>
    <tr bgcolor="#A49A6A">
<%}%>      <td height="25" colspan="8">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="stud_type" value="<%=WI.fillTextValue("stud_type")%>">
<input type="hidden" name="stud_name" value="<%=WI.fillTextValue("stud_name")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="year_level" value="<%=WI.fillTextValue("year_level")%>">

<input type="hidden" name="maxAllowedLoad" value="<%=request.getParameter("maxAllowedLoad")%>"><!-- max number of entries displayed.-->
<input type="hidden" name="sub_load" value="<%=request.getParameter("sub_load")%>">

<input type="hidden" name="temp_id" value="<%=WI.fillTextValue("temp_id")%>">
<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="cn" value="<%=WI.fillTextValue("cn")%>">
<input type="hidden" name="ci" value="<%=WI.fillTextValue("ci")%>">
<input type="hidden" name="mn" value="<%=WI.fillTextValue("mn")%>">
<input type="hidden" name="mi" value="<%=WI.fillTextValue("mi")%>">
<input type="hidden" name="syf" value="<%=WI.fillTextValue("syf")%>">
<input type="hidden" name="syt" value="<%=WI.fillTextValue("syt")%>">
<input type="hidden" name="maxDisplay" value="<%=request.getParameter("maxDisplay")%>"><!-- max number of entries displayed.-->
<input type="hidden" name="current_sem" value="<%=WI.fillTextValue("current_sem")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">

<input type="hidden" name="addRecord" value="<%=WI.fillTextValue("addRecord")%>">
<%
strTemp = WI.fillTextValue("lab_list");
if(strTemp.length() == 0)
	strTemp = (String)request.getAttribute("lab_list");
if(strTemp == null || strTemp.length() == 0)
	strTemp = "0";
%>
<input type="hidden" name="lab_list" value="<%=strTemp%>">
<%
strTemp = WI.fillTextValue("no_conflict_list");
if(strTemp.length() == 0)
	strTemp = (String)request.getAttribute("no_conflict_list");
if(strTemp == null || strTemp.length() == 0)
	strTemp = "0";
%><input type="hidden" name="no_conflict_list" value="<%=strTemp%>">

<!-- for online registration i have to keep this information -->
<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>