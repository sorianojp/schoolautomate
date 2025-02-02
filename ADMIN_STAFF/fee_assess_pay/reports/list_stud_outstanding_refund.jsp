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
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
var imgWnd;
function ShowHidePanalty() {
<%if(strSchCode.startsWith("UI")){%>
	if(document.fee_report.show_panalty.checked)
		showLayer("show_hide_panalty");
	else	
		hideLayer("show_hide_panalty");
<%}%>
}
function PrintPg()
{
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
<%if(strSchCode.startsWith("UI")){%>
		document.getElementById('myADTable3').deleteRow(0);
		document.getElementById('myADTable3').deleteRow(0);
		document.getElementById('myADTable3').deleteRow(0);//total 15 rows.
<%}%>
	document.getElementById('myADTable4').deleteRow(0);
	window.print();
}
function ReloadPage()
{
	document.fee_report.print_all_letter.value = ""
	document.fee_report.reloadPage.value = "1";
	document.fee_report.submit();
}
function ShowProcessing()
{
	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
	return true;
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
function checkAll()
{
	var maxDisp = document.fee_report.os_count.value;
	//unselect if it is unchecked.
	if(!document.fee_report.selAll.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.fee_report.apply_penalty_'+i+'.checked=false');
	}
	else {
		for(var i =0; i< maxDisp; ++i)
			eval('document.fee_report.apply_penalty_'+i+'.checked=true');
	}

}
function ComputeForGS() {
	if(document.fee_report.is_basic.checked) {
		document.fee_report.semester.selectedIndex = 1;
		document.fee_report.is_yearly.checked = false;
	}
}

function ShowBackAccount() {
	var strSYFrom   = document.fee_report.sy_from.value;
	var strSemester = document.fee_report.semester[document.fee_report.semester.selectedIndex].value;
	var strIsBasic  = "";
	if(document.fee_report.is_yearly && document.fee_report.is_yearly.checked)
		strSemester = "";
	
	if(document.fee_report.is_basic && document.fee_report.is_basic.checked)
		strIsBasic = "&is_basic=1";
	
	var pgLoc = "../close_sy_ledg/list_stud_os_not_enrolled.jsp?sy_from="+strSYFrom+
	"&semester="+strSemester+strIsBasic;
	
	if(document.fee_report.inc_address) {
		if(document.fee_report.inc_address.checked)
			pgLoc += "&inc_address=1";
	}
	
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function ShowBackAccountEncoded() {
	var pgLoc = "./list_stud_balance_forward_manually.jsp?show_summary=checked";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.fee_report.id_number.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.fee_report.id_number.value = strID;
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.fee_report.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
function PrintCollectionLetter(strIDNumber){
	var pgLoc = "./collection_letter_ub.jsp?stud_id_collection_print="+strIDNumber+
		"&sy_from="+document.fee_report.sy_from.value+
		"&semester="+document.fee_report.semester.value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintAllCollectionLetter(){
	document.fee_report.print_all_letter.value = "1";
	document.fee_report.submit();
}
</script>
<body bgcolor="#ffffff" onUnload="CloseProcessing();" onLoad="ShowHidePanalty();">
<%@ page language="java" import="utility.*,enrollment.FAStudentLedgerExtn,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;

	if(WI.fillTextValue("print_all_letter").length()  >0){
		strTemp = "./collection_letter_ub.jsp?sy_from="+WI.fillTextValue("sy_from")+
					"&semester="+WI.fillTextValue("semester");
		response.sendRedirect(response.encodeRedirectURL(strTemp));
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","list_stud_outstanding_refund.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"list_stud_outstanding_refund.jsp");
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

FAStudentLedgerExtn FASLedg = new FAStudentLedgerExtn();
enrollment.FAStudentLedger faLedg = new enrollment.FAStudentLedger();
Vector vRetResult = null;

String strStudInfoList = null;
boolean bolCollectionLetter = (WI.fillTextValue("for_collection_letter").length() > 0);

Vector vStudWithOS  = new Vector();//student with outstanding balance.
Vector vStudWithRef = new Vector();//student with refund.
Vector vStudConInfo = new Vector();//set for wnu ,, having last sy/term enrolled and contact address.. 

boolean bolShowOS   = false;
boolean bolShowRef  = false;
if(WI.fillTextValue("disp_condition").compareTo("0") == 0 || WI.fillTextValue("disp_condition").compareTo("2") ==0)
	bolShowOS = true;
if(WI.fillTextValue("disp_condition").compareTo("1") == 0 || WI.fillTextValue("disp_condition").compareTo("2") ==0)
	bolShowRef = true;


if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("reloadPage").length() ==0)
{
	if(WI.fillTextValue("use_old").length() > 0) 
		vRetResult = FASLedg.viewOutStandingBalanceAndRefund(dbOP, request);
	else
		vRetResult = FASLedg.viewOutStandingBalanceAndRefundNew(dbOP, request);
	if(vRetResult == null)
		strErrMsg = FASLedg.getErrMsg();
	else {
		vStudWithOS  = (Vector)vRetResult.remove(0);
		vStudWithRef = (Vector)vRetResult.remove(0);
		vStudConInfo = (Vector)vRetResult.remove(0);
		if(vStudConInfo == null)
			vStudConInfo = new Vector();
	}
	
}
///I have to find if student already panalized.. 
Vector vStudListWithPanelty = null;

if(WI.fillTextValue("sy_from").length() > 0) {
	vStudListWithPanelty = faLedg.postPaneltyUI(dbOP, request, false);
	if(vStudListWithPanelty == null) {
		if(strErrMsg == null)
			strErrMsg = faLedg.getErrMsg();
	}
	else
		strErrMsg = "Panelty successfully posted.";
	
	vStudListWithPanelty = faLedg.postPaneltyUI(dbOP, request, true);
		
}



String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Year Level"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","stud_curriculum_hist.year_level"};
//String[] astrConvertTerm   = {"Summer","

boolean bolShowAddress = WI.fillTextValue("inc_address").equals("1");
int iIndexOfAddr = 0;
int iColSpan = 0;

if(bolShowAddress)
	iColSpan = -1;
else	
	iColSpan = -2;
%>
<form action="./list_stud_outstanding_refund.jsp" method="post" name="fee_report" onSubmit="SubmitOnceButton(this);return ShowProcessing();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable4">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF STUDENTS WITH OUTSTANDING BALANCE/REFUND PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr> 
      <td width="1%" height="25"></td>
      <td colspan="5" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%>
	  
	  <div align="right" style="font-size:11px;">
	  
	  <%if(strSchCode.startsWith("UC") ||strSchCode.startsWith("SPC") ){%>
	  	<a href="./list_stud_outstanding_refund_cumulative_ledger.jsp"><font color="#990033">GO TO Cumulative Ledger(Enrolled/Not Enrolled)</font></a>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <%}%>
	  
	  	<a href="./list_stud_outstanding_refund_all.jsp"><font color="#990033">GO TO OS BALANCE/REFUND - ALL(Enrolled/Not Enrolled)</font></a>
	  </div>
	  </td>
    </tr>
    <tr>
      <td height="25"></td>
      <td colspan="5"><a href="javascript:ShowBackAccountEncoded();">Click to View Balance Forward Manually Encoded into the system.</a></td>
    </tr>
<%if(strSchCode.startsWith("UI") || strSchCode.startsWith("WNU") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("EAC")){%>
    <tr>
      <td height="25"></td>
      <td colspan="5">
<!--<input type="checkbox" name="append_old_ledg" value="checked"<%=WI.fillTextValue("append_old_ledg")%>> Include students not enrolled in selected SY/Term. -->
			<a href="javascript:ShowBackAccount();">Click here to generate list of student having back account and not enrolled in SY-Term</a>
			<font size="1" color="#000000">(Report will be wrong if Ledger is not closed for all previous sy/term)</font>	  </td>
    </tr>
<%}%>
<!--
    <tr>
      <td height="25"></td>
      <td colspan="5">
<%
	if(WI.fillTextValue("use_old").length() > 0) 
		strTemp = " checked";
	else	
		strTemp = "";
%>
	  <input name="use_old" type="checkbox" value="1"<%=strTemp%>>
        <font style="font-size:11px; font-weight:bold; color:#0000FF"> Use Old way (does not use temp. storage - slower generation)</font></td>
    </tr>
-->
    <tr> 
      <td height="25"></td>
      <td colspan="5" class="thinborderNONE">School Year/Term 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fee_report","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
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
        </select> 
		&nbsp;
<!--
		<%
		if(WI.fillTextValue("clean_up").length() > 0) 
			strTemp = " checked";
		else	
			strTemp = "";
		%>
		<input name="clean_up" type="checkbox" value="1"<%=strTemp%>>
		<font style="font-size:11px; font-weight:bold; color:#0000FF">
			Init Tuition and Discount : (slower generation)</font>
	 	-->
		<%
		
		if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("EAC") || true){
		if(WI.fillTextValue("remove_advanced").equals("1")) 
			strTemp = " checked";
		else	
			strTemp = "";
		%>
		<input name="remove_advanced" type="radio" value="1"<%=strTemp%>><font style="font-size:11px; font-weight:bold; color:#0000FF">Remove If Enrolled in next sy/term</font>
		<%
			if(WI.fillTextValue("remove_advanced").equals("2")) 
				strTemp = " checked";
			else	
				strTemp = "";
		%>
		<input name="remove_advanced" type="radio" value="2"<%=strTemp%>><font style="font-size:11px; font-weight:bold; color:#0000FF">Show Only If Enrolled in next sy/term</font>
		<%}else{
			if(WI.fillTextValue("remove_advanced").equals("1")) 
				strTemp = " checked";
			else	
				strTemp = "";
		%>
		<input name="remove_advanced" type="checkbox" value="1"<%=strTemp%>><font style="font-size:11px; font-weight:bold; color:#0000FF">Remove If Enrolled in next sy/term</font>
		<%}%>
	  </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2" class="thinborderNONE">Display condition</td>
      <td colspan="3"><select name="disp_condition" style="font-family:Verdana, Arial, Helvetica, sans-serif;">
          <option value="0">Show student list with outstanding balance</option>
          <%
strTemp = WI.fillTextValue("disp_condition");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Show student list with refund</option>
          <%}else{%>
          <option value="1">Show student list with refund</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>Show student list with outstanding balance 
          and refund</option>
          <%}else{%>
          <option value="2">Show student list with outstanding balance and refund</option>
          <%}%>
        </select> </td>
    </tr>
<%//System.out.println(strSchCode);
if(strSchCode.startsWith("UI") || strSchCode.startsWith("AUF") || strSchCode.startsWith("WNU") || strSchCode.startsWith("DBTC") || true){%>
    <tr>
      <td height="25"></td>
      <td colspan="5" style="font-size:11px; font-weight:bold; color:#0000FF">
<%if(!strSchCode.startsWith("FATIMA")){
	strTemp = WI.fillTextValue("is_basic");
	if(strTemp.length() > 0) 
		strTemp = " checked";
	%>
			  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="ComputeForGS();"> Process Report for Grade School 
			&nbsp;&nbsp; 
<%}
strTemp = WI.fillTextValue("is_yearly");
if(strTemp.length() > 0) 
	strTemp = " checked";
%>

		  <input type="checkbox" name="is_yearly" value="1"<%=strTemp%>> 
		  Outstanding for Complete School Year	
		  <!--&nbsp;&nbsp;&nbsp;  
		  <font color="#000000">
		  Display Per Page: 
			<select name="rows_per_page">
					<option value="1000000">All in One Page</option>
					<option value="50">50</option>
			<%
			int iDefValue = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"), "0"));
			for(int i =51; i < 75; ++i){		
				if(iDefValue == i)
					strTemp = " selected";
				else	
					strTemp = "";
			%>
					<option value="<%=i%>" <%=strTemp%>><%=i%></option>
			<%}%>
				  </select>		  
		  </font>-->
	  </td>
    </tr>
<%}//show only if UI
if(strSchCode.startsWith("UB")){
%>
    <tr>
        <td height="25"></td>
        <td colspan="5" style="font-size:11px; font-weight:bold; color:#0000FF">
		<%
strTemp = WI.fillTextValue("for_collection_letter");
if(strTemp.length() > 0) 
	strTemp = " checked";
		%>
	  <input type="checkbox" name="for_collection_letter" value="1" <%=strTemp%>> 
		  For Printing of Collection Letter	

		</td>
        <td colspan="2">&nbsp;</td>
    </tr>
<%}%>
    <tr> 
      <td height="25"></td>
      <td colspan="3"><strong>Show By :</strong></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td width="1%">&nbsp;</td>
      <td width="16%" class="thinborderNONE">College/School </td>
      <td colspan="3"><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="31"></td>
      <td></td>
      <td class="thinborderNONE">Course</td>
      <td colspan="3"><select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() > 0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+strTemp+" order by course_name asc",
		  		request.getParameter("course_index"), false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td class="thinborderNONE">Major</td>
      <td colspan="3"><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td></td>
      <td class="thinborderNONE">Year Level</td>
      <td colspan="3"><select name="year_level">
          <option value="">All</option>
          <%
strTemp =WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select> </td>
    </tr>
    <tr id="row_3"> 
      <td height="25"></td>
      <td></td>
      <td class="thinborderNONE">Student ID </td>
      <td width="18%"><input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute"></label>
	  
	  </td>
      <td colspan="2" class="thinborderNONE">Show only if balance is greater than 
        <input name="amt_gt" type="text" size="5" value="<%=WI.fillTextValue("amt_gt")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr id="row_2"> 
      <td height="25"></td>
      <td></td>
      <td class="thinborderNONE">Sort Result by</td>
      <td width="18%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=new ConstructSearch().constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select> <br> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td width="27%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=new ConstructSearch().constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> <br> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
<%if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="37%" valign="bottom"><span class="thinborder">
        <input type="submit" name="12" value=" Refresh Page " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.fee_report.print_all_letter.value=''">
      </span></td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="2" class="thinborderNONE">Cutoff date/Range</td>
      <td colspan="3" style="font-size:9px; font-weight:bold; color:#0000FF">
      <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('fee_report.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
<%if(strSchCode.startsWith("UI") || strSchCode.startsWith("SPC") ){%>	  
	  to 
	  <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('fee_report.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
	  &nbsp;Enter one date for cut off date and both dates for date range	  
<%}%>	  
	<input type="checkbox" name="restrict_sy_term" value="checked" <%=WI.fillTextValue("restrict_sy_term")%>> Restrict Balacne to Specified SY-Term
	&nbsp;&nbsp;
	<input type="checkbox" name="no_balance_forward" value="checked" <%=WI.fillTextValue("no_balance_forward")%>> Ignore Balance from Previous SY-Term
	&nbsp;&nbsp;
	<input type="checkbox" name="show_graduating" value="checked" <%=WI.fillTextValue("show_graduating")%>> Show Only Graduating Student
</td>
    </tr>
<%
if(strSchCode.startsWith("WNU") || strSchCode.startsWith("UPH")){//compute panalty is for UI only.. %>
    <tr>
      <td height="25"></td>
      <td colspan="5" class="thinborderNONE" style="font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("inc_address");
if(strTemp.length() > 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="inc_address" value="1" <%=strTemp%>> Show Last Enrolled SY/Term and Contact Information.</td>
    </tr>
<%}//show only if wnu... 

if(strSchCode.startsWith("UI") || strSchCode.startsWith("UL")){//compute panalty is for UI only.. %>
    <tr>
      <td height="25"></td>
      <td colspan="5" class="thinborderNONE" style="font-weight:bold; color:#0000FF"><%
strTemp = WI.fillTextValue("show_panalty");
if(strTemp.length() > 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="show_panalty" value="1" <%=strTemp%> onClick="ShowHidePanalty();"> 
        Compute Penalty </td>
    </tr>
    <tr id="show_hide_panalty">
      <td height="25"></td>
      <td colspan="2" class="thinborderNONE">Penalty</td>
      <td colspan="3" class="thinborderNONE">Peso 
<%
strTemp = WI.fillTextValue("panalty_amt");
if(strTemp.length() == 0) 
	strTemp = "50";
if(strSchCode.startsWith("UL"))
	strTemp = "1";
%>        <input type="text" name="panalty_amt" size="3" maxlength="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      for every of 
<%
strTemp = WI.fillTextValue("for_every");
if(strTemp.length() == 0) 
	strTemp = "1000";
if(strSchCode.startsWith("UL"))
	strTemp = "10";
%>		<input type="text" name="for_every" size="5" maxlength="5" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  	  
	  outstanding
	  <input type="submit" name="122" value=" Recompute " style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.fee_report.print_all_letter.value=''">	  </td>
    </tr>
    <tr id="show_hide_panalty">
      <td height="25"></td>
      <td colspan="5" class="thinborderNONE" style="color:#0000FF">NOTE : If there is any amount in Penalty Amount, System posts penalty to ledger. To avoid posting penalty for a student , remove the penalty amount for that student, Leave it blank or set it to zero. In leger it appears as &quot;Panelty for o/s balance&quot; </td>
    </tr>
<%}%>	
  </table>
<%
double dAmountPerRow = 0d;
double dSubTotal     = 0d; 
double dGT           = 0d;

double dPanaltyAmt       = 0d;
double dPanaltyForEvery  = 0d;
double dTotPanalty       = 0d;

boolean bolShowPanalty   = false;
if(WI.fillTextValue("show_panalty").length() > 0) 
	bolShowPanalty = true;

if(vRetResult != null){
if(bolShowOS && vStudWithOS != null && vStudWithOS.size() > 0){
	String strDateTime = WI.getTodaysDateTime();
%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(strSchCode.startsWith("UB")) {%>
    <tr>
        <td height="25" align="right">
		<a href="javascript:PrintAllCollectionLetter();"><img src="../../../images/print.gif" border="0"></a>
		<font size="1">Click to print all collection letter</font>
		</td>
    </tr>
<%}%>
    <tr> 
      <td height="25"><div align="center"><strong>::: LIST OF STUDENT WITH OUTSTANDING BALANCE :::</strong></div>
	  <div align="right" style="font-size:9px;">Date and Time Printed: <%=strDateTime%></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr style="font-weight:bold">
      <td width="5%" class="thinborder" style="font-size:9px;">No.</td> 
      <td width="15%" height="24" class="thinborder" style="font-size:9px;">Student ID</td>
      <td width="25%" class="thinborder" style="font-size:9px;">Student Name</td>
<%if(!bolShowAddress){%>
      <td width="10%" class="thinborder" style="font-size:9px;">Year Level</td>
<%}else{%>
      <td width="10%" class="thinborder" style="font-size:9px;">Last SY/Term </td>
      <td width="25%" class="thinborder" style="font-size:9px;">Contact Address </td>
<%}%>
      <td width="28%" class="thinborder" style="font-size:9px;">Outstanding Balance</td>
<%if(bolShowPanalty){%>
      <td width="12%" class="thinborder" style="font-size:9px;" align="center">Penalty<br>
	     <input type="checkbox" value="0" onClick="checkAll();" checked name="selAll">	  </td>
<%}
if(bolCollectionLetter){
%>
      <td width="12%" class="thinborder" style="font-size:9px;" align="center">PRINT</td>
<%}%>
    </tr>
    <%
dPanaltyAmt      = Double.parseDouble(WI.getStrValue(WI.fillTextValue("panalty_amt"), "0"));
dPanaltyForEvery = Double.parseDouble(WI.getStrValue(WI.fillTextValue("for_every"), "0"));
int iMultiplier  = 0;
int j = 0; 
for(int i = 0; i< vStudWithOS.size() ; i +=8, ++j){
dAmountPerRow = ((Float)vStudWithOS.elementAt(i + 7)).doubleValue();
dSubTotal += dAmountPerRow;

if(strStudInfoList == null)
	strStudInfoList = (String)vStudWithOS.elementAt(i + 4)+","+dAmountPerRow;
else
	strStudInfoList += ","+(String)vStudWithOS.elementAt(i + 4)+","+dAmountPerRow;

iMultiplier = (int) (dAmountPerRow/dPanaltyForEvery);
dTotPanalty = (double)iMultiplier * dPanaltyAmt;

if(vStudWithOS.elementAt(i + 1) != null) {%>
    <tr bgcolor="#EFEFEF"> 
      <td height="20" colspan="<%=7+iColSpan%>" class="thinborder"><strong>COLLEGE : <%=(String)vStudWithOS.elementAt(i + 1)%></strong></td>
<%if(bolShowPanalty){%>
      <td height="20" class="thinborder">&nbsp;</td>
<%}
if(bolCollectionLetter){%>
      <td height="20" class="thinborder">&nbsp;</td>
<%}%>
    </tr>
    <%}if(vStudWithOS.elementAt(i + 2) != null || vStudWithOS.elementAt(i + 3) != null) {%>
    <tr> 
      <td height="24" colspan="<%=7+iColSpan%>" class="thinborder"><font size="1">::Course::Major: <%=(String)vStudWithOS.elementAt(i + 2)%> 
        <%=WI.getStrValue(vStudWithOS.elementAt(i + 3))%></font></td>
<%if(bolShowPanalty){%>
      <td height="24" class="thinborder">&nbsp;</td>
<%}
if(bolCollectionLetter){%>
      <td height="20" class="thinborder">&nbsp;</td>
<%}%>
    </tr>
    <%}%>
    <tr>
      <td class="thinborder"><%=j+1%>.</td> 
      <td height="24" class="thinborder"><%=(String)vStudWithOS.elementAt(i + 4)%></td>
      <td class="thinborder"><%=(String)vStudWithOS.elementAt(i + 5)%></td>
<%if(!bolShowAddress){%>
      <td class="thinborder"><%=WI.getStrValue(vStudWithOS.elementAt(i + 6),"&nbsp;")%></td>
<%}else{
iIndexOfAddr = vStudConInfo.indexOf(new Integer((String)vStudWithOS.elementAt(i)));
if(iIndexOfAddr > -1) {
	strTemp = (String)vStudConInfo.elementAt(iIndexOfAddr + 1) + " - "+ (String)vStudConInfo.elementAt(iIndexOfAddr + 2);
	strErrMsg = (String)vStudConInfo.elementAt(iIndexOfAddr + 3);
	vStudConInfo.remove(iIndexOfAddr);vStudConInfo.remove(iIndexOfAddr);
	vStudConInfo.remove(iIndexOfAddr);vStudConInfo.remove(iIndexOfAddr);
}	
else {
	strTemp = null;
	strErrMsg = null;
}%>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strErrMsg, "&nbsp;")%></td>
<%}%>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dAmountPerRow,true)%></td>
<%if(bolShowPanalty){%>
      <td class="thinborder" align="center" style="font-size:9px; color:#0000FF; font-weight:bold">
	  <%if(vStudListWithPanelty != null && vStudListWithPanelty.indexOf(vStudWithOS.elementAt(i)) != -1){%>
	  	.. Posted ..
	   <%j = j - 1;}else{%>
        <input type="text" name="panalty_amt_<%=j%>" size="4" value="<%=dTotPanalty%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  <input type="hidden" name="stud_index_<%=j%>" value="<%=(String)vStudWithOS.elementAt(i)%>">
      <input type="checkbox" name="apply_penalty_<%=j%>" value="0" checked>
	  <%}%>      </td>
<%}
if(bolCollectionLetter){
%>
      <td class="thinborder" align="center" style="font-size:9px; color:#0000FF; font-weight:bold">
		<a href="javascript:PrintCollectionLetter('<%=(String)vStudWithOS.elementAt(i + 4)+","+dAmountPerRow%>')"><img src="../../../images/print.gif" border="0"></a></td>
<%}%>
    </tr>
 <%//show this after every college. 
 if(  (i + 9) < vStudWithOS.size() && vStudWithOS.elementAt(i + 1 + 8) != null) {%>
    <tr>
      <td height="24" colspan="<%=7+iColSpan%>" align="right" class="thinborder"><strong><font size="1">SUB TOTAL :&nbsp;&nbsp;&nbsp;</font></strong><strong><%=CommonUtil.formatFloat(dSubTotal,true)%></strong></td>
<%if(bolShowPanalty){%>
      <td class="thinborder" align="center">&nbsp;</td>
<%}
if(bolCollectionLetter){%>
      <td height="20" class="thinborder">&nbsp;</td>
<%}%>
    </tr>
    <%
		dGT += dSubTotal;
		dSubTotal = 0d;
		}////shows subtotal for each college.
	}//end of for loop%>
<input type="hidden" name="os_count" value="<%=j%>">
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="24" align="right" class="thinborder"><strong><font size="1">SUB TOTAL :&nbsp;&nbsp;&nbsp;</font><%=CommonUtil.formatFloat(dSubTotal,true)%></strong></td>
<%if(bolShowPanalty){%>
      <td width="10%" class="thinborder">&nbsp;</td>
<%}%>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="24" align="right"><strong><font size="1">GRAND TOTAL :&nbsp;&nbsp;&nbsp;</font></strong><strong><%=CommonUtil.formatFloat(dGT+dSubTotal,true)%></strong></td>
<%if(bolShowPanalty){%>
      <td width="10%" align="right">
        <input type="submit" name="1222" value="Post Penalty" style="font-size:10px; height:22px;width:65px;border: 1px solid #FF0000;" 
		onClick="document.fee_report.p_panelty.value='1';document.fee_report.print_all_letter.value=''">
      </td>
<%}%>
    </tr>
  </table>
<%}if(bolShowRef && vStudWithRef != null && vStudWithRef.size() > 0){
//reset the amounts 
dAmountPerRow = 0d;
dSubTotal     = 0d; 
dGT           = 0d;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4" bgcolor="#C2BEA3"><div align="center"><strong><font color="#FFFFFF">::: 
          LIST OF STUDENT WITH REFUND :::</font></strong></div></td>
    </tr></table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" style="font-size:9px; font-weight:bold">NO</td> 
      <td width="19%" height="24"><font size="1"><strong>STUDENT ID</strong></font></td>
      <td width="34%"><font size="1"><strong>NAME (LNAME,FNAME, MI)</strong></font></td>
      <td width="20%"><font size="1"><strong>YEAR LEVEL</strong></font></td>
      <td width="27%"><font size="1"><strong>BALANCE AMOUNT</strong></font></td>
    </tr>
    <%int j = 0;
for(int i = 0; i< vStudWithRef.size() ;i +=8){
dAmountPerRow = ((Float)vStudWithRef.elementAt(i + 7)).doubleValue();
dSubTotal += dAmountPerRow;
if(vStudWithRef.elementAt(i + 1) != null) {
%>
    <tr bgcolor="#EFEFEF"> 
      <td height="20" colspan="5"><strong>COLLEGE : <%=(String)vStudWithRef.elementAt(i + 1)%></strong></td>
    </tr>
    <%}if(vStudWithRef.elementAt(i + 2) != null || vStudWithRef.elementAt(i + 3) != null) {%>
    <tr> 
      <td height="24" colspan="5"><font size="1">::Course::Major: <%=(String)vStudWithRef.elementAt(i + 2)%> 
        <%=WI.getStrValue(vStudWithRef.elementAt(i + 3))%></font></td>
    </tr>
    <%}%>
    <tr>
      <td width="4%"><%=++j%>.</td> 
      <td width="19%" height="24"><%=(String)vStudWithRef.elementAt(i + 4)%></td>
      <td width="34%"><%=(String)vStudWithRef.elementAt(i + 5)%></td>
      <td width="20%"><%=WI.getStrValue(vStudWithRef.elementAt(i + 6),"&nbsp;")%></td>
      <td><%=CommonUtil.formatFloat(dAmountPerRow,true)%></td>
    </tr>
 <%//show this after every college. 
 if(  (i + 9) < vStudWithRef.size() && vStudWithRef.elementAt(i + 1 + 8) != null) {%>
    <tr>
      <td colspan="4" align="right"><strong><font size="1">SUB TOTAL :&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td height="24"><strong><%=CommonUtil.formatFloat(dSubTotal,true)%></strong></td>
    </tr>
    <%
		dGT += dSubTotal;
		dSubTotal = 0d;
		}////shows subtotal for each college.
	}//end of for loop%>
  </table>
   <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="73%" align="right"><strong><font size="1">SUB</font><font size="1"> 
        TOTAL :&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td width="27%" height="24"><strong><%=CommonUtil.formatFloat(dSubTotal,true)%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="73%" align="right"><strong><font size="1">GRAND TOTAL :&nbsp;&nbsp;&nbsp;</font></strong></td>
      <td width="27%" height="24"><strong><%=CommonUtil.formatFloat(dGT+dSubTotal,true)%></strong></td>
    </tr>
  </table>
<%}//show vStudWithRef %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td><a href="javascript:PrintPg();">
	  <img src="../../../images/print.gif" border="0" name="print_hide"></a> 
        <font size="1">click to print list</font></td>
    </tr>
  </table>
 <%}//only if vRetResult != null%>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<%
request.getSession(false).setAttribute("stud_list_collection_print",strStudInfoList);
%>
<input type="hidden" name="reloadPage">
<input type="hidden" name="p_panelty">
<input type="hidden" name="print_all_letter">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>