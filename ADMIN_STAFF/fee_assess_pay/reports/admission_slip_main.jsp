<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

WebInterface WI = new WebInterface(request);	
	
String strInfo5 = (String)request.getSession(false).getAttribute("info5");//System.out.println(strSchCode);
//request.getSession(false).setAttribute("school_code", "DBTC");

String strPrintURL = null;
if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("VMUF"))
	strPrintURL = "./admission_slip_print_cldh.jsp";
else if(strSchCode.startsWith("CPU"))
	strPrintURL = "./admission_slip_print_cpu.jsp";
else if(strSchCode.startsWith("CGH"))
	strPrintURL = "./admission_slip_print_cgh.jsp";
else if(strSchCode.startsWith("UDMC"))
	strPrintURL = "./admission_slip_print_udmc.jsp";
else if(strSchCode.startsWith("AUF") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("PIT") || 
	strSchCode.startsWith("UPH") || strSchCode.startsWith("WUP") ||
	strSchCode.startsWith("UB") || strSchCode.startsWith("CDD") || strSchCode.startsWith("MARINER")) {
		if(strInfo5 != null && strInfo5.startsWith("jonelta"))
			strPrintURL = "./admission_slip_print_jonelta.jsp";
		else	
			strPrintURL = "./admission_slip_print_auf.jsp";
}
else if(strSchCode.startsWith("PHILCST"))
	strPrintURL = "./admission_slip_print_philcst.jsp";
else if(strSchCode.startsWith("FATIMA"))
	strPrintURL = "./admission_slip_print_fatima.jsp";
else if(strSchCode.startsWith("EAC"))
	strPrintURL = "./admission_slip_print_eac.jsp";
else if(strSchCode.startsWith("UC"))
	strPrintURL = "./admission_slip_print_uc.jsp";
else if(strSchCode.startsWith("VMA"))
	strPrintURL = "./admission_slip_print_vma.jsp";
else if(strSchCode.startsWith("PWC"))
	strPrintURL = "./admission_slip_print_PWC.jsp";
else if(strSchCode.startsWith("SWU"))
	strPrintURL = "other/cit/exam_permit_for_prelim_SWU.jsp";//prelim has diff format to other exam. so in this file, i will just forward to appropriate page	
else if(strSchCode.startsWith("SPC"))
	strPrintURL = "./admission_slip_print_spc.jsp";
else if(strSchCode.startsWith("HTC"))
	strPrintURL = "./admission_slip_print_htc.jsp";
else
	strPrintURL = "./admission_slip_print.jsp";

//System.out.println(strPrintURL);



boolean bolIsBasic = false;
if (WI.fillTextValue("is_basic").equals("1") || strSchCode.startsWith("CSA"))
	bolIsBasic = true;

boolean bolIsCLDH = strSchCode.startsWith("CLDH");///for CLDH, i have to check the payment - so it is slower in generation..
if(strSchCode.startsWith("VMUF") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("FATIMA") ||
		strSchCode.startsWith("CSA") || strSchCode.startsWith("EAC") || strSchCode.startsWith("WUP") || 
		strSchCode.startsWith("SPC") || strSchCode.startsWith("PWC") || strSchCode.startsWith("MARINER"))
	bolIsCLDH = true;

if(strSchCode.startsWith("DBTC") && bolIsBasic && WI.fillTextValue("print_all").equals("1")) {%>
	<jsp:forward page="./admission_slip_print_all_dbtc_basic.jsp"/>

<%return;}
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
function EnableTempPermit() {
	var strTempPermit = "";
	if(document.form_.temp_permit.checked)
		strTempPermit = "&temp_permit=checked";
	location = "./admission_slip_main.jsp?print_by=1"+strTempPermit;
}
function ReloadPage()
{
	document.form_.print_all.value ="";
	document.form_.print_pg.value = "";
	if(document.form_.sy_to.value.length < 4 || document.form_.sy_from.value.length < 4) {
		alert("Please enter School Year information.");
		return;
	}
	this.setExamName();
	document.form_.submit();
}
function CallPrint()
{
	this.setExamName();

	document.form_.print_all.value ="";
	document.form_.print_pg.value = "1";
}
function NextPage() {
	location = "./admission_slip.jsp?sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
	"&pmt_schedule="+
	document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
}
function PrintALL() {
	if(document.form_.temp_permit && document.form_.temp_permit.checked) {
		alert("Not allowed to print temp permit in batch.");
		return;
	}
	document.form_.show_all_in1page.checked = true;
	
	document.form_.print_all.value ="1";
	document.form_.print_pg.value = "1";
	this.setExamName();
	document.form_.submit();
}
function PrintPg(id_number)
{
	if(document.form_.temp_permit && document.form_.temp_permit.checked) {
		if(document.form_.temp_permit_date.value.length == 0) {
			alert("Please enter temporary permit date.");
			return;
		}
	}


	var loadPg = "<%=strPrintURL%>?stud_id="+id_number+
		"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&offering_sem="+document.form_.semester[document.form_.semester.selectedIndex].value+
		"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
		"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
		
		if(document.form_.year_level)
			loadPg += "&gr_year_level="+document.form_.year_level[document.form_.year_level.selectedIndex].value;
		
		loadPg += "&print_one=1";
	if(document.form_.temp_permit && document.form_.temp_permit.checked) {
		if(document.form_.temp_permit_date.value.length == 0) {
			alert("Please enter temporary permit date.");
			return;
		}
		loadPg += "&temp_permit=1&temp_permit_date="+document.form_.temp_permit_date.value;
	}
	if(document.form_.print_final)
		loadPg += "&print_final="+document.form_.print_final.value;
	if(document.form_.font_size)
		loadPg += "&font_size="+document.form_.font_size[document.form_.font_size.selectedIndex].value;

	if(document.form_.is_basic)
		loadPg += "&is_basic=<%=WI.fillTextValue("is_basic")%>";
	if(document.form_.date_from)
		loadPg += "&date_from=<%=WI.fillTextValue("date_from")%>&date_to=<%=WI.fillTextValue("date_to")%>";

	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function setExamName() {
	if(!document.form_.pmt_schedule)
		return;
	if(document.form_.section_name && document.form_.section_name.selectedIndex > 0)
		document.form_.section_selected.value = document.form_.section_name[document.form_.section_name.selectedIndex].text;

	document.form_.exam_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
}
//prints the student having balance..
function PrintStudentWithBalance() {
	document.bgColor = "#FFFFFF";

	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);

	document.getElementById('myADTable5').deleteRow(1);

	//delete the dynamic rows..
	var obj = document.getElementById('myADTable2');
	var oRows; var iRowCount;
	if(obj) {
		oRows = obj.getElementsByTagName('tr');
		iRowCount = oRows.length;
		for(i = 0; i < iRowCount; ++i)
			obj.deleteRow(0);
	}
	obj = document.getElementById('myADTable3');
	if(obj) {
		oRows = obj.getElementsByTagName('tr');
		iRowCount = oRows.length;
		for(i = 0; i < iRowCount; ++i)
			obj.deleteRow(0);
	}


	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.

}

//ajax to update admission slip number
function UpdateAdmSlipNo(strIDNumber) {
	var strNewVal = prompt('Please enter Premit Number','');
	if(strNewVal == null || strNewVal == '')
		return;
	//I have to update now.
	var strParam = "user="+escape(strIDNumber)+"&sy_f="+document.form_.sy_from.value+
					"&sem="+document.form_.semester[document.form_.semester.selectedIndex].value+
					"&new_val="+escape(strNewVal)+"&pmt_sch="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
	var objCOAInput = document.getElementById(strIDNumber);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	//alert(strParam);
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=122&"+strParam;
	this.processRequest(strURL);

}
</script>
<body bgcolor="#D2AE72">
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
			if(iAccessLevel == 0)
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
		//may be called from Guidance.
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS-ADMISSION SLIP"),"0"));		
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
								"Admin/staff-Fee Assessment & Payments-REPORTS - admission Slip batch print","admission_slip_main.jsp");
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

if(strErrMsg == null)
	strErrMsg = "";

String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

boolean bolIsTempPermit = false;
if(WI.fillTextValue("temp_permit").length() > 0) {
	bolIsTempPermit = true;
	bolIsCLDH       = false;
}
if(WI.fillTextValue("ignore_balance").length() > 0) {
	bolIsCLDH       = false;
}

boolean bolIsCalledLedger = WI.fillTextValue("called_ledger").equals("1");

if(strSchCode.startsWith("SWU")){
	bolIsCalledLedger = true;
}

if(bolIsCalledLedger && WI.fillTextValue("stud_id").length() == 0){
	dbOP.cleanUP();	
	%>
	<script>document.bgColor = "#FFFFFF";</script>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">NOT ALLOWED TO PRINT EXAM PERMIT IN THIS PAGE</font></p>
<%	return;
}

//get here the list of student to be printed if the print by course is selected.
Vector vRetResult = null; Vector vStudentNotAllowed = null;
EnrlReport.StatementOfAccount SOA  = new EnrlReport.StatementOfAccount();
enrollment.ReportFeeAssessment RFA = new enrollment.ReportFeeAssessment();

Vector vStudNotAllowed = new Vector();
/*********************** APPLY BATCH PRINT **********************************/
String strStudCSVToPrint = null;


//if print all - i have to print all one by one..
if(WI.fillTextValue("print_all").compareTo("1") == 0 && WI.fillTextValue("show_all_in1page").length() > 0 && WI.fillTextValue("s_l").length() > 0){
	vRetResult = CommonUtil.convertCSVToVector(WI.fillTextValue("s_l"));
	
	int iMaxPage = vRetResult.size();
	if(WI.fillTextValue("print_option2").length() > 0) {
		//I have to now check if format entered is correct.
		int[] aiPrintPg = SOA.getPrintPage(WI.fillTextValue("print_option2"),iMaxPage);
		if(aiPrintPg == null)
			strErrMsg = SOA.getErrMsg();
		else {//print here.
			for(int i = 0; i < aiPrintPg.length; ++i) {
				if(strStudCSVToPrint == null)
					strStudCSVToPrint = (String)vRetResult.elementAt(aiPrintPg[i] - 1);
				else
					strStudCSVToPrint = strStudCSVToPrint+","+(String)vRetResult.elementAt(aiPrintPg[i]  - 1);
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
		for(int i = 0,iCount = 0; i < vRetResult.size(); ++i, ++iCount) {
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

if(strStudCSVToPrint != null) {
	strTemp = "./admission_slip_batch_print_generic.jsp";
	request.getSession(false).setAttribute("stud_list",strStudCSVToPrint);
	if(strSchCode.startsWith("SPC"))
		strTemp = "./admission_slip_print_spc.jsp";
	//if(strSchCode.startsWith("HTC"))
	//	strTemp = "./admission_slip_print_htc.jsp";

	strTemp += "?sy_from="+WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&offering_sem="+
		WI.fillTextValue("semester")+"&pmt_schedule="+WI.fillTextValue("pmt_schedule")+
		"&gr_year_level="+WI.fillTextValue("year_level")+"&print_final="+WI.fillTextValue("print_final")+"&is_basic="+WI.fillTextValue("is_basic");

	if(WI.fillTextValue("font_size").length() > 0)
		strTemp += "&font_size="+WI.fillTextValue("font_size");
	if(WI.fillTextValue("date_from").length() > 0)
		strTemp += "&date_from="+WI.fillTextValue("date_from")+"&date_to="+WI.fillTextValue("date_to");
	if(WI.fillTextValue("course_classification").length() > 0)
		strTemp += "&course_classification="+WI.fillTextValue("course_classification");

	dbOP.cleanUP();

	//System.out.println(strTemp);

	response.sendRedirect(response.encodeRedirectURL(strTemp));
	return;
}


/*********************** END OF BATCH PRINT **********************************/


vRetResult = null;

boolean bolIncStudWithBalance = WI.fillTextValue("inc_stud_with_balance").equals("1");
if(strSchCode.startsWith("DBTC") && bolIsBasic && WI.fillTextValue("print_by").equals("1") && !bolIncStudWithBalance) {
	vRetResult = SOA.getStudIDBatchPrint(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SOA.getErrMsg();
}
else if(WI.fillTextValue("print_by").compareTo("1") == 0 && !bolIsCLDH) {
	vRetResult = SOA.getStudIDBatchPrint(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SOA.getErrMsg();

	
	if(strSchCode.startsWith("SWU")){
		strTemp = 
			" select id_number from USER_TABLE "+
			" join ADM_SLIP_PRN_COUNT on (ADM_SLIP_PRN_COUNT.USER_INDEX = USER_TABLE.USER_INDEX) "+
			" where ADM_SLIP_PRN_COUNT.IS_VALID = 1 "+
			" and SY_FROM = "+WI.fillTextValue("sy_from")+
			" and SEMESTER = "+WI.fillTextValue("semester")+
			" and PMT_SCH_INDEX = "+WI.fillTextValue("pmt_schedule")+
			" and ALLOW_REPRINT = 0 ";
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			vStudNotAllowed.addElement(rs.getString(1));
		}rs.close();
	}

}
else if(WI.fillTextValue("print_pg").equals("1") && bolIsCLDH) {//System.out.println("I am here.");
	vRetResult = RFA.getExamPermitList(dbOP, request);
		if(vRetResult == null)
			strErrMsg = RFA.getErrMsg();
		else if(vRetResult.size() == 1) {
			vStudentNotAllowed = (Vector)vRetResult.remove(0);
			vRetResult = null;
		}
		else
			vStudentNotAllowed = (Vector)vRetResult.remove(0);
		//System.out.println("I am here1.");
}





String strSList = null;

boolean bolIsExamPermit = false;
if(strSchCode.startsWith("SPC"))
	bolIsExamPermit = true;
%>

<form name="form_" action="./admission_slip_main.jsp" method="post" onSubmit="SubmitOnceButton(this);">
<input type="hidden" name="group_by_level" value="1">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          PRINT <%if(bolIsExamPermit){%>EXAM PERMIT<%}else{%>ADMISSION SLIP PAGE<%}%> ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
<%if(strSchCode.startsWith("FATIMA")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
	  <input type="checkbox" name="temp_permit" value="checked" <%=WI.fillTextValue("temp_permit")%> onClick="EnableTempPermit();"> Issue Temporary Permit.
	  Enter Validity Date:
	  	  <input name="temp_permit_date" type="text" size="10" maxlength="10" value="<%=WI.fillTextValue("temp_permit_date")%>" class="textbox" readonly="yes"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';">
		<a href="javascript:show_calendar('form_.temp_permit_date',<%=CommonUtil.getMMYYYYForCal()%>);"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
    </tr>
<%}if(strSchCode.startsWith("UI") || strSchCode.startsWith("AUF") || strSchCode.startsWith("DBTC") ||
strSchCode.startsWith("CSA") || strSchCode.startsWith("PHILCST") || strSchCode.startsWith("UL") || strSchCode.startsWith("WUP") ||
strSchCode.startsWith("EAC") || strSchCode.startsWith("PWC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
<%
if(bolIsBasic)
	strTemp = " checked";
else
	strTemp = "";
if(strSchCode.startsWith("CSA"))
	strTemp = " checked";
%>
        <input type="checkbox" name="is_basic" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font color="#0000FF"><strong>Check for Grade school

<%if(!strSchCode.startsWith("UL") && !strSchCode.startsWith("PWC")){
	if(bolIncStudWithBalance)
		strTemp = " checked";
	else
		strTemp = "";
%>
			<input type="checkbox" name="inc_stud_with_balance" value="1" <%=strTemp%>> Show Stduent with Balance
<%}%>
		</strong></font></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY/TERM</td>
      <td height="25" colspan="3"> <%
String strSYFrom = WI.fillTextValue("sy_from");
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
String strSemester = WI.fillTextValue("semester");
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
        </select> &nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>

		<%if( !bolIsCalledLedger && (strSchCode.startsWith("PHILCST") || strSchCode.startsWith("EAC") || strSchCode.startsWith("UC") || strSchCode.startsWith("WUP") ||
		strSchCode.startsWith("UPH") || strSchCode.startsWith("VMA") || strSchCode.startsWith("PWC") || strSchCode.startsWith("SWU") || true)) {%>
		<font  style="font-size:9px; font-weight:bold; color:#0000FF">
			<input type="checkbox" name="show_all_in1page" value="checked" checked="checked">
			Show all in 1 page (for batch printing)		</font>
		<%}%>		
		
		<%if(strSchCode.startsWith("SPC")) {%>
		<font  style="font-size:9px; font-weight:bold; color:#0000FF">
			<input type="checkbox" name="ignore_balance" value="checked" <%=WI.fillTextValue("ignore_balance")%>>
			Ignore Balance		</font>
		<%}%>		</td>
    </tr>
<%if(bolIsCalledLedger){%>	
	<tr>
      <td width="4%" height="25">&nbsp;</td>
      <td height="25">Student ID</td>
      <td width="18%" height="25">
	  <strong style="font-size:13px;"><%=WI.fillTextValue("stud_id")%></strong>
	  <input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
	  <input type="hidden" name="print_by" value="1">
	  </td>
      <td width="14%">Exam Period </td>
      <td width="47%">
        <select name="pmt_schedule">
		<%if(bolIsBasic){%>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
		<%}else{%>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}%>
		</select>
<!--
		<% if (bolIsBasic && strSchCode.startsWith("UI")) {
			strTemp = WI.fillTextValue("print_final");
			if (strTemp.length() > 0)
				strTemp = " checked";
			else
				strTemp = "";
		%>
			<input type="checkbox" name="print_final" value="1" <%=strTemp%>>
			<font size="1">print Final Statement of Account</font>
		<%}else{%>
			<input type="hidden" name="print_final">
		<%}%>

-->
<%if(strSchCode.startsWith("EAC")){%>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <select name="font_size">
<%
strTemp = WI.fillTextValue("font_size");
if(strTemp.length() == 0)
	strTemp = "9";
for(int i = 9; i < 14; ++i) {
	if(strTemp.equals(Integer.toString(i)))
		strErrMsg = " selected";
	else
		strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>
	  </select> Font Size
<%}%>	 </td>
    </tr>
<%}//end bolIsCalledLedger

if(!bolIsCalledLedger){%>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td height="25">Print by </td>
      <td width="18%" height="25"><select name="print_by" onChange="ReloadPage();">
<%
strTemp = WI.fillTextValue("print_by");
strTemp = "1";
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Course</option>
          <%}else{%>
          <option value="1">Course</option>
          <%}%>
        </select></td>
      <td width="14%">Exam Period </td>
      <td width="47%">
        <select name="pmt_schedule">
		<%if(bolIsBasic){%>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
		<%}else{%>
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}%>
		</select>
<!--
		<% if (bolIsBasic && strSchCode.startsWith("UI")) {
			strTemp = WI.fillTextValue("print_final");
			if (strTemp.length() > 0)
				strTemp = " checked";
			else
				strTemp = "";
		%>
			<input type="checkbox" name="print_final" value="1" <%=strTemp%>>
			<font size="1">print Final Statement of Account</font>
		<%}else{%>
			<input type="hidden" name="print_final">
		<%}%>

-->
<%if(strSchCode.startsWith("EAC")){%>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <select name="font_size">
<%
strTemp = WI.fillTextValue("font_size");
if(strTemp.length() == 0)
	strTemp = "9";
for(int i = 9; i < 14; ++i) {
	if(strTemp.equals(Integer.toString(i)))
		strErrMsg = " selected";
	else
		strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>
	  </select> Font Size
<%}%>	 </td>
    </tr>
<%
}//end not called from ledger
if(strSchCode.startsWith("UC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Exam Date </td>
      <td colspan="3">
	  <input name="date_from" type="text" size="10" maxlength="10" value="<%=WI.fillTextValue("date_from")%>" class="textbox" readonly="yes"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';">
		<a href="javascript:show_calendar('form_.date_from',<%=CommonUtil.getMMYYYYForCal()%>);"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  -
	  <input name="date_to" type="text" size="10" maxlength="10" value="<%=WI.fillTextValue("date_to")%>" class="textbox" readonly="yes"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';">
		<a href="javascript:show_calendar('form_.date_to',<%=CommonUtil.getMMYYYYForCal()%>);"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
    </tr>
<%}
strTemp = WI.fillTextValue("print_by");
strTemp = "1";
if(strTemp.compareTo("1") != 0 && !bolIsBasic){
	if(!bolIsCLDH){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp; </td>
      <td height="25">&nbsp; </td>
      <td height="25"><a href="javascript:NextPage();">NEXT PAGE</a></td>
      <td height="25">&nbsp;</td>
    </tr><%}%>
    <%}else{
	if(!bolIsBasic){%>
<%
if(strSchCode.startsWith("UC") || strSchCode.startsWith("UL") || strSchCode.startsWith("SPC") || strSchCode.startsWith("MARINER")
 || strSchCode.startsWith("HTC") ){
if(strSchCode.startsWith("SPC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Section Name </td>
      <td height="25" colspan="3">
<%
strTemp = " from stud_curriculum_hist join course_offered on (course_offered.course_index = stud_Curriculum_hist.course_index) join college on (college.c_index = course_offered.c_index) where stud_curriculum_hist.is_valid = 1 and sy_from = "+strSYFrom+" and semester = "+strSemester;
if(WI.fillTextValue("course_index").length() > 0 && !WI.fillTextValue("course_index").equals("0")) 
	strTemp += " and stud_curriculum_hist.course_index = "+WI.fillTextValue("course_index");
else if(WI.fillTextValue("college_").length() > 0) 
	strTemp += " and college.c_index = "+WI.fillTextValue("college_");
%>
  <select name="section_name">
          <%=dbOP.loadCombo("distinct stud_curriculum_hist.section_name","stud_curriculum_hist.section_name",strTemp, request.getParameter("section_name"), false)%>
	  </select>
	  </td>
    </tr>
<%}%>
<%if(!bolIsCalledLedger){%>

	<tr>
		  <td height="25">&nbsp;</td>
		  <td height="25">Course Prog. </td>
		  <td height="25" colspan="3">
		<select name="course_classification">
          <option value=""></option>
          <%=dbOP.loadCombo("cc_index","cc_name"," from cclassification where IS_DEL=0 order by cc_name", request.getParameter("course_classification"), false)%> 
        </select>
		</td>
    </tr>

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
          <%=dbOP.loadCombo("c_index","c_name",strTemp, request.getParameter("college_"), false)%>
        </select>	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"> Course </td>
      <td height="25" colspan="3"><select name="course_index" onChange="ReloadPage();">
          <option value="0">Select Any</option>
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
<%if(!bolIsCLDH){%>    <tr>
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
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="17%" height="25"> Year level </td>
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
<%}//do not show if called from ledger.. 

}//show if basic
   else {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Education Level</td>
      <td colspan="3">
  <%if(strSchCode.startsWith("WNU")){%>
	  <select name="edu_level" onChange="ReloadPage()">
          <%=dbOP.loadCombo("distinct edu_level","EDU_LEVEL_NAME"," from BED_LEVEL_INFO order by edu_LEVEL",WI.fillTextValue("edu_level"),false)%>
	  </select>
	  <%}else{%>
	  <select name="year_level" onChange="ReloadPage()">
          <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("year_level"),false)%>
      </select>
	  -
	  <%if(WI.fillTextValue("sy_from").length() > 0) {%>
	  		  <select name="section_name" onChange="ReloadPage()">
				  <option value=""></option>
					  <%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section"," from e_sub_section where offering_sy_from = "+WI.fillTextValue("sy_from")+
						" and offering_sem = "+WI.fillTextValue("semester")+" and exists (select * from subject where sub_index = e_sub_section.sub_index and is_del = 2) "+
						" and exists (select * from enrl_final_cur_list where sub_sec_index = e_sub_section.sub_sec_index and is_valid = 1 and current_year_level = "+
						WI.getStrValue(WI.fillTextValue("year_level"), "1")+")",WI.fillTextValue("section_name"),false)%>
			  </select>
	  <%}%>

  <%}%>		</td>
    </tr>
<%}//show only if basic.%>

<%if(!bolIsCalledLedger){%>
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

 for(int i=++j; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>		</td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" style="font-size:11px; color:#0000FF; font-weight:bold"> Student ID (to print one) </td>
      <td height="25" colspan="3" style="font-size:11px; color:#0000FF; font-weight:bold">
	  <input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(bolIsCLDH){%>
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  <input type="checkbox" name="show_not_printed" value="checked" <%=WI.fillTextValue("show_not_printed")%>> Show list not printed.
<%}%>	  </td>
    </tr>

<%}// end bolIsCalledLedger
if(bolIsCLDH || (vRetResult != null && vRetResult.size() > 0) ){
if(vRetResult == null)
	vRetResult = new Vector();
if(!bolIsCalledLedger){
%>
	
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
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;"
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="CallPrint();">
	  <font size="1">click to display student list to print.</font></td>
    </tr>
    <%}//only if vRetResult is not null;

	}//if print_by is not student
%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("print_pg").compareTo("1") == 0){%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#000000" id="myADTable3">
 	<tr bgcolor="#FFFFFF">
	<td><input type="button" name="_2" disabled="disabled" border="0" 
				style="font-size:11px; height:25px; width:25px; background-color:#CCFFFF; border:solid 1px #000000;	" />Not Allowed to Print</td>
	</tr>
 </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000" id="myADTable3">
  <%if(!bolIsCalledLedger){%>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="5" align="right"><a href="javascript:PrintALL();">
        <img src="../../../images/print.gif" border="0"></a> <font size="1">Click
        to print</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
	<%}%>
    <tr bgcolor="#999999">
      <td height="25" colspan="5" align="center"><B>LIST OF STUDENT FOR PRINTING.</B></td>
    </tr>
    <tr bgcolor="#ffff99">
      <td height="25" align="center">&nbsp;</td>
      <td height="25" align="center"><strong>STUDENT ID</strong></td>
      <td height="25" align="center"><strong>STUDENT NAME</strong></td>
      <td width="21%" align="center"><strong>ADMISSION SLIP NO.</strong></td>
      <td width="13%" align="center"><strong>PRINT</strong></td>
    </tr>
    <%
	int iIndexOf = 0;
	String strBGColor = "";
	int iMaxDisp = 0;
 for(int i = 0,iCount=1; i < vRetResult.size(); i += 3,++iCount, ++iMaxDisp){
 	iIndexOf = vStudNotAllowed.indexOf((String)vRetResult.elementAt(i));
	if(iIndexOf > -1)
		strBGColor = "#CCFFFF";
	else
		strBGColor = "#FFFFFF";
 %>
    <tr bgcolor="<%=strBGColor%>">
      <td width="4%"><%=iCount%>.</td>
      <td width="18%"><%=(String)vRetResult.elementAt(i)%></td>
      <td width="44%" height="25">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td onDblClick="UpdateAdmSlipNo('<%=(String)vRetResult.elementAt(i)%>');">&nbsp;&nbsp;
	  <label id="<%=(String)vRetResult.elementAt(i)%>">
	  	<%=WI.getStrValue((String)vRetResult.elementAt(i + 2))%>
	  </label>
	  </td>
      <td align="center"><a href='javascript:PrintPg("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/print.gif" border="0"></a></td>
    </tr>
	<input type="hidden" name="stud_id_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
    <%
		if(strSList == null)
			strSList = (String)vRetResult.elementAt(i);
		else	
			strSList += ","+(String)vRetResult.elementAt(i);
	}%>
	<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
  </table>
<%}//end of vRetResult display.

if(bolIncStudWithBalance && vStudentNotAllowed != null && vStudentNotAllowed.size() > 0) {%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
		<tr>
			<td align="center">
        		<p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          		<!-- Martin P. Posadas Avenue, San Carlos City -->
          		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), ",","")%>
          		<!-- Pangasinan 2420 Philippines -->
          		<br>
          		<strong>LIST OF STUDENT HAVING PAYABLE BALANCE FOR :<%=WI.fillTextValue("exam_name").toUpperCase()%>
				<%if(WI.fillTextValue("section_selected").length() > 0) {%>
						<br>SECTION : <%=WI.fillTextValue("section_selected")%>
				<%}%>
				</strong></p>
			</td>
		</tr>
		<tr>
			<td align="right" style="font-size:9px">
        		<a href="javascript:PrintStudentWithBalance();"><img src="../../../images/print.gif" border="0"></a> Click to print list.
			</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#ffff99" align="center" style="font-weight:bold">
      <td height="25" width="5%" class="thinborder">COUNT</td>
      <td width="15%" class="thinborder">STUDENT ID</td>
      <td width="30%" class="thinborder">STUDENT NAME</td>
      <td width="20%" class="thinborder">AMOUNT BALANCE</td>
    </tr>
    <%
 for(int i = 0,iSL=1; i < vStudentNotAllowed.size(); i += 5){%>
    <tr bgcolor="#FFFFFF">
      <td class="thinborder" height="22"><%=iSL++%>.</td>
      <td class="thinborder"><%=(String)vStudentNotAllowed.elementAt(i)%></td>
      <td class="thinborder">&nbsp;&nbsp;<%=(String)vStudentNotAllowed.elementAt(i + 1)%></td>
      <td class="thinborder" align="right"><%=WI.getStrValue((String)vStudentNotAllowed.elementAt(i + 4))%> &nbsp;&nbsp;</td>
    </tr>
    <%}%>
  </table>

<%}//end of printing the student with balance.. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="print_all" value="">
  <input type="hidden" name="exam_name" value="">
  <input type="hidden" name="section_selected" value="">
  
  
  <input type="hidden" name="s_l" value="<%=WI.getStrValue(strSList)%>">
  <input type="hidden" name="called_ledger" value="<%=WI.fillTextValue("called_ledger")%>">
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
				var pgLoc = "./admission_slip_print.jsp?stud_id=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 3 - 3)%>"+
					"&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&offering_sem=<%=WI.fillTextValue("semester")%>"+
					"&pmt_schedule=<%=WI.fillTextValue("pmt_schedule")%>"+
					"&gr_year_level=<%=WI.fillTextValue("year_level")%>" +
				    "&print_final=<%=WI.fillTextValue("print_final")%>"+
					"&is_basic=<%=WI.fillTextValue("is_basic")%>";
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

			window.setTimeout("callPrintFunction()", 10000);
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
					var pgLoc = "<%=strPrintURL%>?stud_id=<%=(String)vRetResult.elementAt(i)%>"+
						"&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&offering_sem=<%=WI.fillTextValue("semester")%>"+
						"&pmt_schedule=<%=WI.fillTextValue("pmt_schedule")%>"+
						"&gr_year_level=<%=WI.fillTextValue("year_level")%>" +
					    "&print_final=<%=WI.fillTextValue("print_final")%>"+
						"&is_basic=<%=WI.fillTextValue("is_basic")%>";

					window.open(pgLoc);
				}//end of printing function.
			<%
		}//end of for loop.

		//for(int i = 0;  i < vRetResult.size(); i += 2){
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

			window.setTimeout("callPrintFunction()", 10000);
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
