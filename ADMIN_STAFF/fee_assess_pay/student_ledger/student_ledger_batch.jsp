<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);
boolean bolIsBasic = false;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	this.pageLoading();
	document.form_.print_all.value ="";
	document.form_.submit();
}
function CallPrint() {
	this.pageLoading();
	document.form_.print_all.value ="1";
}
function CallOnLoad() {
	document.all.processing.style.visibility='hidden';
	document.bgColor = "#FFFFFF";
}
function pageLoading() {
	document.all.processing.style.visibility='visible';
	document.bgColor = "#DDDDDD";
}
function PrintPage() {
	var obj = document.getElementById('myADTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);

	obj = document.getElementById('myADTable2');
	var oRows = obj.getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i)
		obj.deleteRow(0);

	
	window.print();
}
</script>
<body onLoad="CallOnLoad();" bgcolor="#DDDDDD">
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

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-STUDENT LEDGER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}




//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-STUDENT LEDGER - Student Ledger batch print","admission_slip_main.jsp");
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



String strSQLQuery = null;
java.sql.ResultSet rs = null;
Vector vStudList = new Vector();

String strCon = "";
String strConSection = "";

String strSYFrom   = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");
String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};


if(strSYFrom.length() > 0)
	strCon = " and stud_curriculum_hist.sy_from ="+strSYFrom+" and stud_curriculum_hist.semester = "+strSemester;
if(WI.fillTextValue("course_index").length() > 0)
	strCon += " and stud_curriculum_hist.course_index ="+WI.fillTextValue("course_index");
if(WI.fillTextValue("year_level").length() > 0)
	strCon += " and stud_curriculum_hist.year_level ="+WI.fillTextValue("year_level");
if(WI.fillTextValue("section_").length() > 0)
	strConSection = " and section = '"+WI.fillTextValue("section_")+"'";
	
if ((WI.fillTextValue("lname_from").compareTo("A") != 0) || (WI.fillTextValue("lname_to").compareTo("Z") != 0)){
	if ((WI.fillTextValue("lname_to").length() == 0) || (WI.fillTextValue("lname_to").compareTo("0") == 0))
		strSQLQuery = WI.fillTextValue("lname_from");
	else 
		strSQLQuery = WI.fillTextValue("lname_to");

	strSQLQuery = CommonUtil.filterByABC(WI.fillTextValue("lname_from"), strSQLQuery, "LNAME");
	if (strSQLQuery != null) {
		if (strCon == null)
			strCon = WI.getStrValue(strSQLQuery);
		else
			strCon = strCon + WI.getStrValue(strSQLQuery);
	}
}

int iCount = 0;
if(WI.fillTextValue("print_all").length() > 0) {
	strSQLQuery = "select distinct id_number,lname, fname from STUD_CURRICULUM_HIST join user_table on (user_Table.user_index = STUD_CURRICULUM_HIST.user_index) "+
				"where STUD_CURRICULUM_HIST.is_valid = 1 "+strCon+
				" and exists (select enroll_index from enrl_final_cur_list join e_sub_section on (e_sub_section.sub_sec_index = ENRL_FINAL_CUR_LIST.SUB_SEC_INDEX) "+
				"where ENRL_FINAL_CUR_LIST.user_index = STUD_CURRICULUM_HIST.user_index and ENRL_FINAL_CUR_LIST.sy_from = STUD_CURRICULUM_HIST.sy_from and "+
				"CURRENT_SEMESTER = semester and IS_TEMP_STUD = 0 and ENRL_FINAL_CUR_LIST.is_valid = 1 "+strConSection+") order by lname, fname";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next())
		vStudList.addElement(rs.getString(1));
	rs.close();
	
	iCount = vStudList.size();
}
else {
	strSQLQuery = "select count(distinct id_number) from STUD_CURRICULUM_HIST join user_table on (user_Table.user_index = STUD_CURRICULUM_HIST.user_index) "+
				"where STUD_CURRICULUM_HIST.is_valid = 1 "+strCon+
				" and exists (select enroll_index from enrl_final_cur_list join e_sub_section on (e_sub_section.sub_sec_index = ENRL_FINAL_CUR_LIST.SUB_SEC_INDEX) "+
				"where ENRL_FINAL_CUR_LIST.user_index = STUD_CURRICULUM_HIST.user_index and ENRL_FINAL_CUR_LIST.sy_from = STUD_CURRICULUM_HIST.sy_from and "+
				"CURRENT_SEMESTER = semester and IS_TEMP_STUD = 0 and ENRL_FINAL_CUR_LIST.is_valid = 1 "+strConSection+")";
	rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
	if(rs.next()) 
		iCount = rs.getInt(1);
	rs.close();
}


%>

<form name="form_" action="./student_ledger_batch.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="25"><div align="center"><strong>:::: STUDENT LEDGER PRINT BY BATCH ::::</strong></div></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td height="25">SY/TERM</td>
      <td height="25" colspan="2"> <%
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");

		// force to 1 (regular for basic ) if not summer and if basic
		if (WI.fillTextValue("is_basic").equals("1") && !strSemester.equals("0"))
			strSemester = "1";

		  if(strSemester.equals("1")){
		  %>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strSemester.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strSemester.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> 
        &nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Section Name </td>
      <td height="25" colspan="2">
<select name="section_" style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;" onChange="ReloadPage();">
          <option value=""></option>
          <%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section"," from e_sub_section where is_valid = 1 and offering_sy_from = "+
		  					strSYFrom+" and offering_sem = "+strSemester+" order by e_sub_section.section",WI.fillTextValue("section_"), false)%> </select>  	  </td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">College</td>
      <td height="25" colspan="3">
	  <select name="college_" onChange="ReloadPage();">
          <option value="">Select Any</option>
<%
//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
strTemp = " from college where IS_DEL=0 order by c_name asc";
%>
          <%//=dbOP.loadCombo("c_index","c_name",strTemp, request.getParameter("college_"), false)%>
        </select>	  </td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"> Course </td>
      <td height="25" colspan="2"><select name="course_index" onChange="ReloadPage();">
          <option value=""></option>
          <%
//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
if(WI.fillTextValue("college_").length() > 0)
	strTemp = " and c_index = "+WI.fillTextValue("college_");
else
	strTemp = "";

strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 and is_visible = 1"+strTemp+" order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="12%" height="25"> Year level </td>
      <td width="50%" height="25"><select name="year_level" onChange="ReloadPage()">
          <option value=""></option>
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
      <td width="34%" height="25">&nbsp;</td>
    </tr>
	
	    <tr>
      <td height="25">&nbsp;</td>	  
      <td colspan="4" height="25">Print students whose lastname starts with
        <select name="lname_from" onChange="ReloadPage()">
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
if(iCount > 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><font size="3">TOTAL STUDENTS TO BE PRINTED
        : <strong><%=iCount%></strong></font></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Ledger&nbsp;&nbsp;"
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="CallPrint();">
	  <font size="1">click to display student list to print.</font></td>
      <td align="right">
	  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a><font size="1">Print Page</font>
	  
	  
	  </td>
    </tr>
<%}//only if vRetResult is not null;
%>
</table>
<%
enrollment.FAPaymentUtil paymentUtil = new enrollment.FAPaymentUtil();
enrollment.FAStudentLedger faStudLedg = new enrollment.FAStudentLedger();

String strStudID = null;
String strUserIndex = null;
String strPNRemarks   = null;
String strAddress = null;
String strAge = null;

Vector vBasicInfo = null;
Vector vLedgerInfo = null;

Vector vTimeSch = null;
Vector vAdjustment = null;
Vector vRefund = null;
Vector vDorm = null;
Vector vOthSchFine = null;
Vector vPayment = null;
Vector vTuitionFeeDetail = null;

String strSYTo = WI.fillTextValue("sy_to");
boolean bolShowDiscDetail = false;

String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP,false,false);


while(vStudList.size() > 0) {
	strStudID = (String)vStudList.remove(0);
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strStudID, strSYFrom, strSYTo, strSemester);
	if(vBasicInfo == null || vBasicInfo.size() == 0) 
		continue;
	strUserIndex = (String)vBasicInfo.elementAt(0);
	vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vBasicInfo.elementAt(0),strSYFrom, strSYTo,null,strSemester, false);
	if(vLedgerInfo == null)
		strErrMsg = faStudLedg.getErrMsg();
	else
	{//System.out.println( (new java.util.Date().getTime() - lTime)/1000);
		vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
		vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
		vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
		vRefund				= (Vector)vLedgerInfo.elementAt(3);
		vDorm 				= (Vector)vLedgerInfo.elementAt(4);
		vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
		vPayment			= (Vector)vLedgerInfo.elementAt(6);
		if(vTimeSch == null || vTimeSch.size() ==0)
			strErrMsg = faStudLedg.getErrMsg();
		else {
			////get PN Remarks.
			strSQLQuery = "select pn_remarks from FA_STUD_PROMISORY_NOTE where IS_TEMP_STUD_ = 0 and is_valid = 1 and pmt_sch_index = 0 and sy_from = "+
						strSYFrom+" and semester = "+strSemester+" and user_index = "+(String)vBasicInfo.elementAt(0);
			strPNRemarks = dbOP.getResultOfAQuery(strSQLQuery, 0);
		}
		
	}
	if(strSchCode.startsWith("UB") && vBasicInfo != null && vBasicInfo.size() > 0){
		strSQLQuery = "select res_house_no, res_city, res_provience, res_zip, res_tel from info_contact "+
				"where user_index = "+(String)vBasicInfo.elementAt(0);
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strAddress = rs.getString(1);
			if(strAddress != null) {
				if(rs.getString(2) != null) 
					strAddress = strAddress + ", "+rs.getString(2);
				if(rs.getString(3) != null) 
					strAddress = strAddress + ", "+rs.getString(3);
				if(rs.getString(4) != null) 
					strAddress = strAddress + " - "+rs.getString(4);
				if(rs.getString(5) != null) 
					strAddress = strAddress + " <br> Tel: "+rs.getString(5);
			}
		}
		rs.close();
		
		strSQLQuery = "select dob from info_personal where user_index = "+(String)vBasicInfo.elementAt(0);
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next() && rs.getDate(1) != null)
			strAge = Integer.toString(CommonUtil.calculateAGE(rs.getDate(1)));
		rs.close();
	}	
%>
		  <table width="100%" border="0" >
			<tr>
			  <td width="100%"><div align="center"><%=strSchName%><br>
				<%=strSchAddr%><br>
				</div></td>
			</tr>
			<tr>
			  <td height="30"><div align="center"><br>
				STUDENT LEDGER<br>
				<%=strSYFrom%> - <%=strSYTo%>
				(<%=astrConvertTerm[Integer.parseInt(strSemester)]%>)
		
				</strong></div>
				<div align="right">Date and time printed: <%=WI.getTodaysDateTime()%></div></td>
			</tr>
		</table>
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
			<tr>
			  <td  width="2%" height="25">&nbsp;</td>
			  <td width="37%" height="25">Student ID :<strong> <%=strStudID%></strong></td>
			  <td width="61%" height="25"  colspan="4">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
				<%
			  if(vBasicInfo.elementAt(3) != null){%>
				/<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
				<%}%>
				</strong> </td>
			</tr>
			<tr>
			  <td height="25">&nbsp;</td>
			  <td height="25">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
			  <td  colspan="4" height="25">Current Year/Term :<strong> <%=WI.getStrValue(vBasicInfo.elementAt(4),"xx")%>/
				<%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
			</tr>
		<%
		if(strSchCode.startsWith("FATIMA")){
		String strPlanInfo = "select PLAN_NAME from FA_STUD_MIN_REQ_DP_PER_STUD "+
							"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
							" where is_temp_stud = 0 and stud_index = "+vBasicInfo.elementAt(0)+
							" and sy_from = "+strStudID+" and semester = "+strSemester;
		strPlanInfo = dbOP.getResultOfAQuery(strPlanInfo, 0);
		
		if(strPlanInfo != null){
		%>
			<tr>
			  <td height="25">&nbsp;</td>
			  <td style="font-weight:bold; color:#0000FF; font-size:12px;"><u>Plan Subscribed: <%=strPlanInfo.toUpperCase()%></u></td>
			  <td  colspan="4" height="25">&nbsp;</td>
			</tr>
		<%}
		}%>
		  </table>
		
		<%
		if(vTimeSch != null && vTimeSch.size() > 0){
			double dBalance = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
			double dCredit = 0d;
			double dDebit = 0d;
			String strTransDate = null;
			int iIndex = 0;
			boolean bolDatePrinted = false;
		%>
		  
		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		  <tr bgcolor="#E6E6EA"> 
			<td width="11%" height="20" align="center" class="thinborder" style="font-size:11px;"><strong>Date</strong></td>
			<td width="40%" align="center" class="thinborder" style="font-size:11px;"><strong>Particulars</strong></td>
			<td width="6%" class="thinborder" style="font-size:11px;"><div align="center"><strong>Collected by (ID) </strong></div></td>
			<td width="13%" align="center" class="thinborder" style="font-size:11px;"><strong>Debit</strong></td>
			<td width="13%" align="center" class="thinborder" style="font-size:11px;"><strong>Credit</strong></td>
			<td width="17%" align="center" class="thinborder" style="font-size:11px;"><strong>Balance</strong></td>
		  </tr>
		  <tr > 
			<td height="25" class="thinborder">&nbsp;</td>
			<td align="right" class="thinborder">Old Account </td>
			<td align="center" class="thinborder">&nbsp;</td>
			<td  align="right" class="thinborder">&nbsp;</td>
			<td align="right" class="thinborder">&nbsp;</td>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
		  </tr>
		  <%
		String strGrant = null;
		
		for(int i=0; i<vTimeSch.size(); ++i) {
			strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.elementAt(i));
			bolDatePrinted = false;
			
			if(vTuitionFeeDetail.contains((Date)vTimeSch.elementAt(i))){
				dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
				dBalance += dDebit;
				
				bolDatePrinted = true;
			%>
			  <tr > 
				<td height="25" class="thinborder"><%=strTransDate%></td>
				<td class="thinborder">Tuition Fee</td>
				<td align="center" class="thinborder">&nbsp;</td>
				<td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
				<td align="right" class="thinborder">&nbsp;</td>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
			  </tr>
			  <%
				dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
				dBalance += dDebit;
			%>
			  <tr > 
				<td height="25" class="thinborder">&nbsp;</td>
				<td class="thinborder">Miscellaneous Fee</td>
				<td align="center" class="thinborder">&nbsp;</td>
				<td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
				<td align="right" class="thinborder">&nbsp;</td>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
			  </tr>
				<%
				dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();
				if(dDebit > 0d){
				dBalance += dDebit;%>
				<tr > 
				  <td height="25" class="thinborder">&nbsp;</td>
				  <td class="thinborder">Other Charges</td>
				  <td align="center" class="thinborder">&nbsp;</td>
				  <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
				  <td align="right" class="thinborder">&nbsp;</td>
				  <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
				</tr>
				<%}
				dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
				if(dDebit > 0d){
				  dBalance += dDebit; %>
			  <tr > 
				<td height="25" class="thinborder">&nbsp;</td>
				<td class="thinborder">Hands on</td>
				<td align="center" class="thinborder">&nbsp;</td>
				<td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
				<td align="right" class="thinborder">&nbsp;</td>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
			  </tr>
			<%}
			//show this if there is any discounts. 
			if(vTuitionFeeDetail.elementAt(5) != null){
				double dTemp = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
				if(dTemp > 0)
					dCredit = dTemp;
				else	
					dDebit  =  -1 * dTemp;
				dBalance -= dTemp;
			%>
				<tr >
				  <td height="25" class="thinborder">&nbsp;</td>
				  <td class="thinborder"><%=vTuitionFeeDetail.elementAt(6)%></td>
				  <td align="center" class="thinborder">&nbsp;</td>
				  <td  align="right" class="thinborder">&nbsp;
				  <%if(dDebit > 0d){%>
				  <%=CommonUtil.formatFloat(dDebit,true)%>
				  <%}%>
				  </td>
				  <td align="right" class="thinborder">&nbsp;
				  <%if(dCredit > 0d){%>
				  <%=CommonUtil.formatFloat(dCredit,true)%>
				  <%}%>
				  </td>
				  <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
				</tr>
			<%}if(vTuitionFeeDetail.elementAt(8) != null){%>	
				<tr > 
				  <td height="25" class="thinborder">&nbsp;</td>
				  <td colspan="5" class="thinborder">NOTE : <%=(String)vTuitionFeeDetail.elementAt(8)%></td>
				</tr>
		  	<%}
			} //for tuition fee detail.
		
			//adjustment here
			int iIndexOf2 = 0;
			Vector vDiscountAddlDetail = faStudLedg.vDiscountAddlDetail;
			if(vDiscountAddlDetail == null)
				vDiscountAddlDetail = new Vector();
				
			while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
			
				dCredit = Double.parseDouble((String)vAdjustment.elementAt(iIndex-3));
				dBalance -= dCredit;
				
				iIndexOf2 = vDiscountAddlDetail.indexOf(new Integer((String)vAdjustment.elementAt(iIndex + 2)));
				if(iIndexOf2 == -1) {
					strTemp = null;
					strErrMsg = null;
				}
				else {
					strTemp = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 1);
					if(vDiscountAddlDetail.elementAt(iIndexOf2 + 2) != null && ((String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2)).length() > 0) 
						strErrMsg = (String)vDiscountAddlDetail.elementAt(iIndexOf2 + 2);
				}
				strGrant = (String)vAdjustment.elementAt(iIndex-4);
				if(!bolShowDiscDetail && strGrant != null && strGrant.length() > 20 && strGrant.indexOf("<br>") > 0) {
					strGrant = strGrant.substring(0, strGrant.indexOf("<br>"));
				}
			%>
			  <tr > 
				<td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
				<td class="thinborder"><%=strGrant%>(Grant)
				  <%=WI.getStrValue(strErrMsg, "<br>Approval #: ","","")%></td>
				  <td align="center" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
				<td  align="right" class="thinborder">&nbsp;</td>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dCredit,true)%></td>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
			  </tr>
			  <%
				//remove the element here.
				vAdjustment.removeElementAt(iIndex);
				vAdjustment.removeElementAt(iIndex-1);
				vAdjustment.removeElementAt(iIndex-2);
				vAdjustment.removeElementAt(iIndex-3);
				vAdjustment.removeElementAt(iIndex-4);
				vAdjustment.removeElementAt(iIndex-5);
			}
		
			//Refund here
			while( (iIndex = vRefund.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
				dDebit = Double.parseDouble((String)vRefund.elementAt(iIndex-1));
				dBalance += dDebit;
			%>
			  <tr > 
				<td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
				<td class="thinborder"><%=(String)vRefund.elementAt(iIndex-3)%>(Refund)</td>
				<td align="center" class="thinborder">&nbsp;</td>
				<td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
				<td align="right" class="thinborder">&nbsp;</td>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
			  </tr>
			  <%
				//remove the element here.
				vRefund.removeElementAt(iIndex);vRefund.removeElementAt(iIndex-1);vRefund.removeElementAt(iIndex-2);
				vRefund.removeElementAt(iIndex-3);
			}
		//dormitory charges
			while( (iIndex = vDorm.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
					dDebit = Double.parseDouble((String)vDorm.elementAt(iIndex-1));
					dBalance += dDebit;
				%>
				  <tr > 
					<td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
					<td class="thinborder"><%=(String)vDorm.elementAt(iIndex-2)%></td>
					<td align="center" class="thinborder">&nbsp;</td>
					<td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
					<td align="right" class="thinborder">&nbsp;</td>
					<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
				  </tr>
				  <%
				//remove the element here.
				vDorm.removeElementAt(iIndex);vDorm.removeElementAt(iIndex-1);vDorm.removeElementAt(iIndex-2);
			}
		
			//Other school fees/fine/school facility fee charges(except dormitory)
			while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
					dDebit = Double.parseDouble((String)vOthSchFine.elementAt(iIndex-1));
					dBalance += dDebit;
				%>
				  <tr > 
					<td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
					<td class="thinborder"><%=(String)vOthSchFine.elementAt(iIndex-2)%></td>
					<td align="center" class="thinborder">&nbsp;</td>
					<td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
					<td align="right" class="thinborder">&nbsp;</td>
					<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
				  </tr>
				  <%
				//remove the element here.
				vOthSchFine.removeElementAt(iIndex);vOthSchFine.removeElementAt(iIndex-1);vOthSchFine.removeElementAt(iIndex-2);
			}
		
			//vPayment goes here, ;-)
			while( (iIndex = vPayment.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
				dCredit = Double.parseDouble((String)vPayment.elementAt(iIndex-2));
				dBalance -= dCredit;
			%>
			  <tr > 
				<td height="25" class="thinborder"> <% if(bolDatePrinted){%> &nbsp; <%}else{%> <%=strTransDate%> <%bolDatePrinted=true;}%> </td>
				<td class="thinborder"><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%> <%=(String)vPayment.elementAt(iIndex+1)%>
			<%if(false){%>
				  (Refuned)
				  <%}%>
				</td>
				<td align="center" class="thinborder"><%=(String)vPayment.elementAt(iIndex + 3)%></td>
				<td  align="right" class="thinborder">&nbsp;
				  <%//show only the refunds in debit column.
				  if(dCredit < 0d || 
					(vPayment.elementAt(iIndex+1) != null && ((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
				  <%=CommonUtil.formatFloat(-1 * dCredit,true)%>
				  <%}%></td>
				  <td align="right" class="thinborder">&nbsp;
				  <%if(dCredit >= 0d && 
					(vPayment.elementAt(iIndex+1) == null || !((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
				  <%=CommonUtil.formatFloat(dCredit,true)%>
				  <%}%>
				  </td>
				<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
			  </tr>
			  <%
				//remove the element here.
				vPayment.removeElementAt(iIndex+2);vPayment.removeElementAt(iIndex+1);vPayment.removeElementAt(iIndex);
				vPayment.removeElementAt(iIndex-1);vPayment.removeElementAt(iIndex-2);
			}%>
		  <%
		}%>
		</table>
		<%}//only if vTimeSch is not null =--- end of printing ledger of one student.. 
		
		%>
<%if(vStudList.size() > 0) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>

<%}%>

<input type="hidden" name="print_all">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
