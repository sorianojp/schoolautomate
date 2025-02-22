<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	java.sql.ResultSet rs = null;

	boolean bolIsRestricted = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Releasing","grade_release_main.jsp");
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
														"grade_release_main.jsp");
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Releasing",request.getRemoteAddr(),
									null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","Grade Releasing - Restricted",request.getRemoteAddr(),
									null);
	if(iAccessLevel > 0)
		bolIsRestricted = true;//limit only college of logged in user.
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

if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};


//get here the list of student to be printed if the print by course is selected.
Vector vRetResult = null;
EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();
if(WI.fillTextValue("print_by").compareTo("1") == 0 && WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = SOA.getStudIDBatchPrint(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SOA.getErrMsg();
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String strInfo5   = (String)request.getSession(false).getAttribute("info5");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsVMA = strSchCode.startsWith("VMA");

String strStudCSVToPrint = null;
Vector vStudWithFailure  = new Vector();
Vector vStudWithNGA      = new Vector();
int iIndexOf = 0;

if(vRetResult != null && vRetResult.size() > 0 && (WI.fillTextValue("show_only_failed").length() > 0 || WI.fillTextValue("show_only_failed_50p").length() > 0 )) {
	String strSQLQuery = null;
	if(WI.fillTextValue("show_only_failed").length() > 0) {
		strSQLQuery = "select distinct id_number from G_SHEET_FINAL "+
							"join USER_TABLE on (USER_TABLE.USER_INDEX = G_SHEET_FINAL.user_index_)  "+
							"join STUD_CURRICULUM_HIST on (STUD_CURRICULUM_HIST.CUR_HIST_INDEX = G_SHEET_FINAL.CUR_HIST_INDEX) "+
							"where SY_FROM = "+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester")+
							" and REMARK_INDEX <> 1 and CREDIT_EARNED = 0 and g_sheet_final.is_valid = 1";
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) 
			vStudWithFailure.addElement(rs.getString(1));
	}else {
		strSQLQuery = "select id_number,count(*), count_enrolled from G_SHEET_FINAL "+
							"join USER_TABLE on (USER_TABLE.USER_INDEX = G_SHEET_FINAL.user_index_) "+
							"join STUD_CURRICULUM_HIST on (STUD_CURRICULUM_HIST.CUR_HIST_INDEX = G_SHEET_FINAL.CUR_HIST_INDEX) "+
							"join ( select count(distinct s_index) as count_enrolled, cur_hist_index as chi from g_sheet_final as gsf2 "+
							"where is_valid = 1 group by gsf2.cur_hist_index) as DT_1 on DT_1.chi = G_SHEET_FINAL.cur_hist_index "+
							"where SY_FROM = "+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester")+
							" and REMARK_INDEX <> 1 and CREDIT_EARNED = 0 and g_sheet_final.is_valid = 1 "+
							"group by id_number,count_enrolled having count(*) > 0 "+
							"order by id_number";
		rs = dbOP.executeQuery(strSQLQuery);
		double dTemp = 0d;
		while(rs.next()) {
			dTemp = rs.getDouble(2)*100d/rs.getDouble(3);
			if(dTemp < 50d)
				continue;
			vStudWithFailure.addElement(rs.getString(1));
		}
	}
	rs.close();

	for(int i =0; i < vRetResult.size(); i += 3) {
		if(vStudWithFailure.indexOf(vRetResult.elementAt(i)) > -1)
			continue;
		vRetResult.remove(i);vRetResult.remove(i); vRetResult.remove(i);
		i = i -3;
	}
}
//do not include student with grade not encoded
if(false && vRetResult != null && vRetResult.size() > 0 && strSchCode.startsWith("SWU")){
	CommonUtil.setSubjectInEFCLTable(dbOP);
	strTemp = 
		" select distinct id_number "+
		" from STUD_CURRICULUM_HIST "+
		" join USER_TABLE on (USER_TABLE.USER_INDEX = STUD_CURRICULUM_HIST.USER_INDEX) "+
		" join ENRL_FINAL_CUR_LIST on (ENRL_FINAL_CUR_LIST.USER_INDEX = STUD_CURRICULUM_HIST.USER_INDEX) "+
		" 	and ENRL_FINAL_CUR_LIST.SY_FROM = STUD_CURRICULUM_HIST.SY_FROM "+
		" 	and ENRL_FINAL_CUR_LIST.CURRENT_SEMESTER = STUD_CURRICULUM_HIST.SEMESTER "+
		" and not exists( "+
		" 	select gs_index from G_SHEET_FINAL where IS_VALID =1 "+
		" 	and CUR_HIST_INDEX = STUD_CURRICULUM_HIST.CUR_HIST_INDEX "+
		" 	and SUB_SEC_INDEX = G_SHEET_FINAL.SUB_SEC_INDEX "+
		" 	and s_index = ENRL_FINAL_CUR_LIST.EFCL_SUB_INDEX "+
		" ) "+
		" where STUD_CURRICULUM_HIST.IS_VALID =1 "+
		" and ENRL_FINAL_CUR_LIST.IS_VALID =1 "+
		" and IS_TEMP_STUD = 0 "+
		" and STUD_CURRICULUM_HIST.SY_FROM = "+WI.fillTextValue("sy_from")+
		" and SEMESTER = "+WI.fillTextValue("semester");
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		iIndexOf = vRetResult.indexOf(rs.getString(1));
		if(iIndexOf == -1)
			continue;
		vRetResult.remove(iIndexOf);vRetResult.remove(iIndexOf); vRetResult.remove(iIndexOf);			
	}rs.close();
	if(vRetResult == null || vRetResult.size() == 0)
		strErrMsg = "No student list found.";
	
}




//if print all - i have to print all one by one..
if(WI.fillTextValue("print_all").compareTo("1") == 0 && WI.fillTextValue("show_all_in1page").length() > 0){
	int iMaxPage = vRetResult.size()/3;
	if(WI.fillTextValue("print_option2").length() > 0) {
		//I have to now check if format entered is correct.
		int[] aiPrintPg = SOA.getPrintPage(WI.fillTextValue("print_option2"),iMaxPage);
		if(aiPrintPg == null) 
			strErrMsg = SOA.getErrMsg();
		else {//print here.
			for(int i = 0; i < aiPrintPg.length; ++i) {
				if(strStudCSVToPrint == null)
					strStudCSVToPrint = (String)vRetResult.elementAt(aiPrintPg[i] * 3 - 3);
				else
					strStudCSVToPrint = strStudCSVToPrint+","+(String)vRetResult.elementAt(aiPrintPg[i] * 3 - 3);
			}
		}//end if there is no err Msg.
		//System.out.println(strErrMsg);
	}//if(WI.fillTextValue("print_option2").length() > 0) {	
	else {
		//enter this only if page number is selected. -- but call the above only if page range in enter in the input box.
		int iPrintRangeTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("print_page_range"),"0"));
		int iPrintRangeFr = iPrintRangeTo - 25; 
		if(iPrintRangeFr < 1) 
			iPrintRangeFr = 0;
		if(iPrintRangeTo == iMaxPage && iMaxPage %25 > 0) {
			//i can't subtract just like that.. i have to find the last page count.
			iPrintRangeFr = iMaxPage - iMaxPage%25;
		}
		for(int i = 0,iCount = 0; i < vRetResult.size(); i += 3, ++iCount) {
			if(iPrintRangeTo > 0) {
				if( (iCount + 1) < iPrintRangeFr || (iCount + 1) > iPrintRangeTo)
					continue;
			}

			if(strStudCSVToPrint == null)
				strStudCSVToPrint = (String)vRetResult.elementAt(i);
			else
				strStudCSVToPrint = strStudCSVToPrint+","+(String)vRetResult.elementAt(i);
		}
	}//end of else.. 
	
}//end of printing..

boolean bolIsGradeCertification = WI.fillTextValue("grade_cert").equals("1");			
boolean bolIsCIT = strSchCode.startsWith("CIT");
boolean bolIsSWU = strSchCode.startsWith("SWU");
boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
if(strStudCSVToPrint != null) {
		
	strTemp = "./grade_releasing_print_ui_batch.jsp";
	if(strSchCode.startsWith("PHILCST"))
		strTemp = "./grade_releasing_print_philcst_batch.jsp";
	if(strSchCode.startsWith("CSA"))
		strTemp = "./grade_releasing_print_csa_batch.jsp";
	if(strSchCode.startsWith("SWU"))		
		strTemp = "./grade_releasing_print_swu_batch.jsp";		
	
		
	
	if(strSchCode.startsWith("EAC") || strSchCode.startsWith("UC") || strSchCode.startsWith("CDD") || 
		strSchCode.startsWith("UPH") || strSchCode.startsWith("SPC") || bolIsVMA) {
		strTemp = "./grade_releasing_print_eac_batch.jsp";
		
		if(vStudWithFailure != null && vStudWithFailure.size() > 0) {
			Vector vStudList = CommonUtil.convertCSVToVector(strStudCSVToPrint, ",", true);
			for(int i = 0; i < vStudList.size(); ++i) {
				if(vStudWithFailure.indexOf(vStudList.elementAt(i)) > -1)
					continue;
				vStudList.remove(i);
			}
			strStudCSVToPrint = CommonUtil.convertVectorToCSV(vStudList);
		}
				
		request.getSession(false).setAttribute("stud_list",strStudCSVToPrint);
		strStudCSVToPrint = "-1";

	}
	else if(bolIsCIT) {
		strTemp = "./grade_releasing_print_cit_batch.jsp";
		
		//check if finals, go to finals page.. 
		if(WI.fillTextValue("grade_name").toLowerCase().startsWith("fin") && WI.fillTextValue("print_report_card").length() > 0)
			strTemp = "./grade_releasing_print_cit_batch_finals.jsp";
		
		request.getSession(false).setAttribute("stud_list",strStudCSVToPrint);
		strStudCSVToPrint = "-1";
	}
	else {
		request.getSession(false).setAttribute("stud_list",strStudCSVToPrint);
		strStudCSVToPrint = "-1";
	}
		
	strTemp += "?stud_list="+strStudCSVToPrint+"&sy_from="+
				WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")+
				"&grade_for="+WI.fillTextValue("grade_name")+
				"&sem_name="+WI.fillTextValue("semester_name")+
				"&grade_name="+WI.fillTextValue("grade_name")+
				"&show_gwa="+WI.fillTextValue("show_gwa")+
				"&is_gpa="+WI.fillTextValue("is_gpa");
				//why before grade_for was pmt_schedule .. I am not sure.. 
	
	//if grade certification and UL go to UL grade certification batch printing.. 
	if(bolIsGradeCertification) {
		//if(strSchCode.startsWith("UL"))
		strTemp = "./grade_certificate_print_ul_batch.jsp";
		strTemp += "?stud_list="+strStudCSVToPrint+"&sy_from="+WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester");
		if (WI.fillTextValue("first_sem").length() > 0) 
			strTemp += "&first_sem=1";
		if (WI.fillTextValue("second_sem").length() > 0) 
			strTemp += "&second_sem=2";
		if (WI.fillTextValue("third_sem").length() > 0) 
			strTemp += "&third_sem=3";
		if (WI.fillTextValue("summer").length() > 0) 
			strTemp += "&summer=0";
	}
	if(WI.fillTextValue("print_lx").length() > 0) 
		strTemp += "&print_lx=1";
	if(WI.fillTextValue("for_sending").length() > 0) 
		strTemp += "&for_sending=1";
	if(WI.fillTextValue("show_only_failed").length() > 0) 
		strTemp += "&show_only_failed=1";
	
	if(strSchCode.startsWith("SWU"))
		strTemp += "&print_report_card="+WI.fillTextValue("print_report_card");	
	
	dbOP.cleanUP();
	if(WI.fillTextValue("show_con").length() > 0) 
		strTemp += "&show_con="+WI.fillTextValue("show_con");
	//System.out.println(strTemp);
	response.sendRedirect(response.encodeRedirectURL(strTemp));
	//System.out.println("Redirecting..");
	return;
}	

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function SetFields()
{
	var strIsGPA     = "0";
	var strGradeName = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
	if(strGradeName == "GPA"){//the drop down is only open for VMA so no need to check the schoolcode here
		strGradeName = "Finals";
		strIsGPA     = "1";
	}
	document.form_.is_gpa.value= strIsGPA;	
	document.form_.grade_name.value= strGradeName;	
}

function ReloadPage()
{
	document.form_.print_all.value ="";
	document.form_.print_pg.value = "";
	//if(document.form_.grade_name.value.length == 0)
		//document.form_.grade_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
	this.SetFields();
	if(document.form_.sy_to.value.length < 4 || document.form_.sy_from.value.length < 4) {
		alert("Please enter Schoolyear information first.");
		return;
	}
	document.form_.submit();
}
function CallPrint()
{
	//document.form_.grade_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
	this.SetFields();
	document.form_.print_all.value ="";
	document.form_.print_pg.value = "1";
}
function NextPage() {
	location = "./grade_release.jsp?sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester.value+
	"&pmt_schedule="+document.form_.pmt_schedule.value;
}
function PrintALL() {
	//document.form_.grade_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
	this.SetFields();
	document.form_.print_all.value ="1";
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function PrintPg(id_number)
{
	//document.form_.grade_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
	
	this.SetFields();
	var showGWA = "";
	if(document.form_.show_gwa && document.form_.show_gwa.checked)
		showGWA = "1";
	var loadPg = "./grade_releasing_print.jsp?stud_id="+id_number+
		"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
		"&grade_for="+escape(document.form_.grade_name.value)+
		"&sem_name="+escape(document.form_.semester_name.value)+
		"&show_gwa="+showGWA+
		"&is_gpa="+escape(document.form_.is_gpa.value)+
		"&grade_name="+escape(document.form_.grade_name.value);
		
	if(document.form_.allow_with_balance && document.form_.allow_with_balance.checked)
		loadPg += "&allow_with_balance=1";
	if(document.form_.for_sending && document.form_.for_sending.checked)
		loadPg += "&for_sending=1";
	if(document.form_.show_only_failed && document.form_.show_only_failed.checked)
		loadPg += "&show_only_failed=1";

	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function updateGradeName() {
	document.form_.grade_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
}

</script>
<body bgcolor="#D2AE72">

<form name="form_" action="./grade_release_main.jsp" method="post">
<input type="hidden" name="semester_name" value="<%=astrConvertTerm[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"),"0"))]%>">
<input type="hidden" name="grade_cert" value="<%=WI.fillTextValue("grade_cert")%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          GRADE <%if(bolIsGradeCertification){%>CERTIFICATION<%}else{%>RELEASE<%}%> (BATCH) PRINT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(strSchCode.startsWith("EAC")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4" style="font-size:11px; font-weight:bold; color:#0000FF">
		<input type="checkbox" name="allow_with_balance" value="checked" <%=WI.getStrValue(WI.fillTextValue("allow_with_balance"), "")%>> 
		Allow student with Balance (works for single student print only)	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY/TERM</td>
      <td height="25" colspan="3" style="font-size:9px; font-weight:bold; color:#0000FF"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>		
		<%if(strSchCode.startsWith("UI") || strSchCode.startsWith("PHILCST") || strSchCode.startsWith("CSA") || strSchCode.startsWith("UL") || strSchCode.startsWith("CIT") || 
		strSchCode.startsWith("EAC") || strSchCode.startsWith("UC") || strSchCode.startsWith("CDD") || strSchCode.startsWith("UB") || true) {%>
		<input type="checkbox" name="show_all_in1page" value="checked" <%=WI.getStrValue(WI.fillTextValue("show_all_in1page"), "checked")%>> Show all in 1 page (for batch printing - recommended to print < 25 pages)
		
		<%}%>		
		
		</td>
    </tr>
<%if(strSchCode.startsWith("UC")){%>
	<tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4" style="font-size:9px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="for_sending" value="checked" <%=WI.fillTextValue("for_sending")%>> Print For Grade Sending 
	  <input type="checkbox" name="show_only_failed" value="checked" <%=WI.fillTextValue("show_only_failed")%>> Print only students with Failure Grades
	  <input type="checkbox" name="show_only_failed_50p" value="checked" <%=WI.fillTextValue("show_only_failed_50p")%>> Print only students >= 50% Failure Grades</td>
    </tr>
<%}%>
    <tr>
      <td width="4%" height="35">&nbsp;</td>
      <td height="25">Print by </td>
      <td width="20%" height="25"><select name="print_by" onChange="ReloadPage();">
          <option value="0">Student</option>
          <%
strTemp = WI.fillTextValue("print_by");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Course</option>
          <%}else{%>
          <option value="1">Course</option>
          <%}%>
        </select></td>
      <td width="14%">Exam Period </td>
      <td width="47%">
<%
/*if(bolIsCIT || strSchCode.startsWith("SWU")) 
	strTemp = " and (exam_name like 'midterm%' or exam_name like 'final%') ";	  
else	
	strTemp = " and (exam_name like 'final%') ";
	
if(strSchCode.startsWith("CSA"))
	strTemp = "";	  */

strTemp  = " from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 ";
strErrMsg = "";
if(bolIsCIT || strSchCode.startsWith("SWU"))  
	strErrMsg = " and (exam_name like 'midterm%' or exam_name like 'final%') ";	  
if(bolIsVMA)
	strErrMsg = " and (exam_name not like 'pre-final%') ";	  
	
strTemp += strErrMsg + "order by EXAM_PERIOD_ORDER asc"; 

String strPmtSchIndex = "";
strErrMsg = "select PMT_SCH_INDEX from FA_PMT_SCHEDULE where IS_VALID =1 and EXAM_NAME like 'final%'";
strPmtSchIndex = dbOP.getResultOfAQuery(strErrMsg, 0);
%>

        <select name="pmt_schedule" onChange="SetFields()">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME", strTemp, request.getParameter("pmt_schedule"), false)%>
		  <%
		  if(bolIsVMA){	
		  if(WI.fillTextValue("pmt_schedule").equals("GPA") )	
		  	strErrMsg = "selected";  
		  else
		  	strErrMsg = "";
		  %><option value="<%=strPmtSchIndex%>" <%=strErrMsg%>>GPA</option>		  
		  <%}%>
        </select>
      </strong></td>
    </tr>
    <%
strTemp = WI.fillTextValue("print_by");
if(strTemp.compareTo("1") != 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp; </td>
      <td height="25">&nbsp; </td>
      <td height="25"><a href="javascript:NextPage();">NEXT PAGE</a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">College</td>
      <td height="25" colspan="3">
	  <select name="college_index" onChange="ReloadPage();">
	  <%if(!bolIsRestricted){%>
          <option value=""></option>
	  <%}%>
<%
strTemp = " from college where IS_DEL = 0 order by c_name asc";

if(bolIsRestricted) {
	strErrMsg = (String)request.getSession(false).getAttribute("info_faculty_basic.c_index");
	strTemp = " from college where IS_DEL = 0 and c_index = "+strErrMsg;
}
else
	strErrMsg = (String)request.getParameter("college_index");
%>
          <%=dbOP.loadCombo("c_index","c_name",strTemp, strErrMsg, false)%>
        </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"> Course </td>
      <td height="25" colspan="3"><select name="course_index" onChange="ReloadPage();">
          <option value="0">Select Any</option>
<%

if(WI.getStrValue(strErrMsg).length() > 0)
	strTemp = " and c_index = "+strErrMsg;
else	
	strTemp = "";
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 "+strTemp+" order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Major</td>
      <td height="25" colspan="3"> <select name="major_index">
          <option value="">ALL</option>
          <%
strTemp = request.getParameter("course_index");
if(strTemp != null && strTemp.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="15%" height="25"> Year level </td>
      <td height="25" colspan="2"><select name="year_level" onChange="ReloadPage()">
          <option value="">ALL</option>
          <%
strTemp = request.getParameter("year_level");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select></td>
      <td height="25">&nbsp;</td>
    </tr>
<%if(!bolIsRestricted){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student ID </td>
      <td height="25" colspan="2">
	  <input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
      <td height="25">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
	  <%
	  //used in SWU
	  strTemp = WI.fillTextValue("overwrite_starts_with");
	  if(strTemp.equals("1"))
	  	strErrMsg = "overwrite_lname_from";
	else
		strErrMsg = "lname_from";
	  %>
      <td colspan="4" height="25">Print students whose lastname starts with
        <select name="<%=strErrMsg%>" onChange="ReloadPage()">
          <%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        to
        <select name="lname_to" onChange="ReloadPage()">
          <option value="0"></option>
          <%
 strTemp = WI.fillTextValue("lname_to");
 if(request.getParameter("lname_to") == null)
 	strTemp = "Z";	

 for(int i=++j; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
	
<%
if(strSchCode.startsWith("SWU")){
%>	
	<tr>
      <td height="18">&nbsp;</td>
	  <%
	  strTemp = WI.fillTextValue("overwrite_starts_with");
	  if(strTemp.equals("1"))
	  	strErrMsg = "checked";
	else
		strErrMsg = "";
	  %>
      <td height="18" colspan="4"><input type="checkbox" name="overwrite_starts_with" value="1" <%=strErrMsg%> onClick="ReloadPage();">
	  Click to override search for lastname	  </td>
    </tr>
	<tr>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="4">Print students whose lastname starts with
	      <input name="lname_from" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("lname_from")%>" 
	  	class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
      </tr>
<%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
<%
if(!strSchCode.startsWith("SWU")){
%>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="3">&nbsp;&nbsp;&nbsp;
        <%strTemp = WI.fillTextValue("show_gwa");
	  if(strTemp.compareTo("1") == 0)
	  	strTemp = " checked";
	  else
	  	strTemp = "";
		%>
        <input name="show_gwa" type="checkbox" value="1" <%=strTemp%>>
        <strong><font color="#0033FF">In printout s</font></strong><font color="#0033FF"><strong>how
        GWA of student for this semester (only if final grade is selected)</strong></font></td>
    </tr>
<%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <%
if(vRetResult != null && vRetResult.size() > 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><font size="3">TOTAL STUDENTS TO BE PRINTED
        : <strong><%=vRetResult.size()/3%></strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">PRINT OPTION 1</td>
      <td height="25" colspan="3"> <select name="print_page_range">
          <option value="">ALL</option>
          <%
	  strTemp = WI.fillTextValue("print_page_range");
	  int iTemp = vRetResult.size()/3;
	  int iLastCount = 0;
	  for(int i = 1; i <= iTemp;){
	  	i += 25; //in batch of 25
		if(i > iTemp)
			iLastCount = iTemp;
		else
			iLastCount += 25;
		 if(strTemp.compareTo(Integer.toString(iLastCount)) == 0){%>
          <option value="<%=iLastCount%>" selected><%=i - 25%> to <%=iLastCount%></option>
          <%}else{%>
          <option value="<%=iLastCount%>"><%=i - 25%> to <%=iLastCount%></option>
          <%}
	  }%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">PRINT OPTION 2</td>
      <td height="25" colspan="3" valign="top"><input name="print_option2" type="text" size="16" maxlength="32"
	  value="<%=WI.fillTextValue("print_option2")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <br> <font color="#0099FF"> <strong>(Enter page numbers and/or page ranges
        separated by commas. For ex: 1,3,5-12)</strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> <input type="image" src="../../../images/form_proceed.gif" onClick="CallPrint()">
        <font size="1">click to display student list to print.</font></td>
    </tr>
<%if(bolIsGradeCertification){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4" style="font-size:10px; color:blue; font-weight:bold">
<% 	if (WI.fillTextValue("first_sem").compareTo("1") == 0)
		strTemp = "checked";
	else 
		strTemp="";
%>
        <input type="checkbox" name="first_sem" value="1" <%=strTemp%>> 1st Sem 
<% 	if (WI.fillTextValue("second_sem").compareTo("2") == 0)
		strTemp = "checked";
	else 
		strTemp="";
%>
	   <input type="checkbox" name="second_sem" value="2" <%=strTemp%>> 2nd Sem 
<% 	if (WI.fillTextValue("third_sem").compareTo("3") == 0)
		strTemp = "checked";
	else 
		strTemp="";
%>
       <input type="checkbox" name="third_sem" value="3" <%=strTemp%>> 3rd Sem 
<% 	if (WI.fillTextValue("summer").compareTo("0") == 0)
		strTemp = "checked";
	else 
		strTemp="";
%>
       <input type="checkbox" name="summer" value="0" <%=strTemp%>> Summer	  </td>
    </tr>
<%}
if(strSchCode.startsWith("PHILCST")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
<%
strTemp = WI.getStrValue(WI.fillTextValue("show_con"), "3");
if(strTemp.equals("1"))
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>	  
		<input type="radio" name="show_con" value="1" <%=strErrMsg%>> Show only Registrar's Copy &nbsp;
<%
if(strTemp.equals("2"))
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>	  
		<input type="radio" name="show_con" value="2" <%=strErrMsg%>> Show only Student's Copy &nbsp;
<%
if(strTemp.equals("3"))
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>	  
		<input type="radio" name="show_con" value="3" <%=strErrMsg%>> Show both
	  <br>
	  <font style="font-weight:bold; font-size:11px; color:#0000FF">
	  	(Conditions applicable only if batch printing is selected)	  </font>	  </td>
    </tr>
<%}//show only if PIT%>
	
    <%}//only if vRetResult is not null;

	}//if print_by is not student
%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("print_pg").compareTo("1") == 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4" align="right" style="font-size:9px; font-weight:bold; color:#0000FF">
<%if(strSchCode.startsWith("CIT") || strSchCode.startsWith("SWU")){%>
	  <input name="print_report_card" type="checkbox" value="checked" <%=WI.fillTextValue("print_report_card")%>>Print Report Card (applicable for Finals Only)
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%}if(strSchCode.startsWith("CIT")){%>	
	  <input type="checkbox" name="print_lx" value="checked" <%=WI.fillTextValue("print_lx")%>>Print to LX
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%}%>
	  <a href="javascript:PrintALL();">
        <img src="../../../images/print.gif" border="0"></a> <font size="1">Click
        to print</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr bgcolor="#999999">
      <td height="25" colspan="4" align="center"><B>LIST OF STUDENT FOR PRINTING.</B></td>
    </tr>
    <tr bgcolor="#ffff99">
      <td height="25" colspan="2" align="center"><strong>STUDENT ID</strong></td>
      <td width="40%" align="center"><strong>STUDENT NAME</strong></td>
      <%if(!bolIsCIT){%><td width="18%" align="center"><strong>PRINT</strong></td><%}%>
    </tr>
    <%
 for(int i = 0,iCount=1; i < vRetResult.size(); i += 3,++iCount){%>
    <tr bgcolor="#FFFFFF">
      <td width="6%"><%=iCount%>.</td>
      <td width="36%" height="25">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
<%if(!bolIsCIT){%>      
	  <td align="center"><a href='javascript:PrintPg("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/print.gif" border="0"></a></td>
<%}%>	 
    </tr>
    <%}%>
  </table>
<%}//end of vRetResult display.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="print_all" value="">
  <input type="hidden" name="grade_name" value="<%=WI.fillTextValue("grade_name")%>">
  <input type="hidden" name="is_gpa" value="<%=WI.fillTextValue("is_gpa")%>">
</form>

<%
//if print all - i have to print all one by one..
if(WI.fillTextValue("print_all").compareTo("1") == 0 && vRetResult != null && vRetResult.size() > 0){
int iMaxPage = vRetResult.size()/3;
if(WI.fillTextValue("print_option2").length() > 0) {
//I have to now check if format entered is correct.
	int[] aiPrintPg = SOA.getPrintPage(WI.fillTextValue("print_option2"),iMaxPage);
	if(aiPrintPg == null) {
		strErrMsg = SOA.getErrMsg();%>
		<script language="JavaScript">alert("<%=strErrMsg%>");</script><%
	}
	else {//print here.
		int iCount = 0; %>
		<script language="JavaScript">
		var countInProgress = 0;
		<%
		for(int i = 0; i < aiPrintPg.length; ++i,++iCount) {%>
			function PRINT_<%=iCount%>() {
				var pgLoc = "./grade_releasing_print.jsp?stud_id=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 3 - 3)%>"+
					"&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>"+
					"&grade_for=<%=response.encodeRedirectURL(WI.fillTextValue("grade_name"))%>"+
					"&sem_name=<%=response.encodeRedirectURL(WI.fillTextValue("semester_name"))%>";

				//alert("I am in count <%=iCount%>");

				window.open(pgLoc);
			}
		<%}%>
		function callPrintFunction() {
			//alert(countInProgress);
			if(eval(countInProgress) > <%=iCount-1%>)
				return;
			eval('this.PRINT_'+countInProgress+'()');//alert(countInProgress);
			countInProgress = eval(countInProgress) + 1;//alert(printCountInProgress);

			window.setTimeout("callPrintFunction()", 15000);
		}
		this.callPrintFunction();
		</script>
	<%
	}
}
else {
	//enter this only if page number is selected. -- but call the above only if page range in enter in the input box.
	int iPrintRangeTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("print_page_range"),"0"));
	int iPrintRangeFr = iPrintRangeTo - 25; if(iPrintRangeFr < 1) iPrintRangeFr = 0;
	if(iPrintRangeTo == iMaxPage && iMaxPage %25 > 0) {
		//i can't subtract just like that.. i have to find the last page count.
		iPrintRangeFr = iMaxPage - iMaxPage%25;
	}
	%>
		<script language="JavaScript">
			var printCountInProgress = 0;
			var totalPrintCount = 0;
			<%int iCount = 0;
			for(int i = 0; i < vRetResult.size(); i += 3,++iCount) {
				if(iPrintRangeTo > 0) {
					if( (iCount + 1) < iPrintRangeFr || (iCount + 1) > iPrintRangeTo)
						continue;
				}%>

				function PRINT_<%=iCount%>() {
					var pgLoc = "./grade_releasing_print.jsp?stud_id=<%=(String)vRetResult.elementAt(i)%>"+
						"&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>"+
						"&grade_for=<%=response.encodeRedirectURL(WI.fillTextValue("grade_name"))%>"+
						"&sem_name=<%=response.encodeRedirectURL(WI.fillTextValue("semester_name"))%>";

					window.open(pgLoc);
				}//end of printing function.
			<%
		}//end of for loop.

		//for(int i = 0;  i < vRetResult.size(); i += 2)
		%>totalPrintCount = <%=iCount%>;
		printCountInProgress = <%=iPrintRangeFr%>;
		<%if(iPrintRangeTo == 0)
			iPrintRangeTo = iCount;
		%>
		totalPrintCount = <%=iPrintRangeTo%>;
		function callPrintFunction() {
			//alert(printCountInProgress);
			if(eval(printCountInProgress) >= eval(totalPrintCount))
				return;
			eval('this.PRINT_'+printCountInProgress+'()');//alert(printCountInProgress);
			printCountInProgress = eval(printCountInProgress) + 1;//alert(printCountInProgress);

			window.setTimeout("callPrintFunction()", 15000);
		}
		//function PrintALL(strIndex) {
			//if(eval(strIndex) < eval(totalPrintCount))
		//}
			this.callPrintFunction();
		</script>

<%}//end if print_option2 is not entered.

}//end if print is called.%>
</body>
</html>
<%
dbOP.cleanUP();
%>
