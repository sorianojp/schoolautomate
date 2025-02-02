<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction, payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
///added code for HR/companies.
boolean bolPopUp = false;
String strReadOnly = "";
if(WI.fillTextValue("popup").length() > 0){
	bolPopUp = true;
	strReadOnly = " readonly";
}

boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	boolean bolMyHome = false;	
	String strEmpID = null;
	boolean bolViewOnly = false;
	
//add security here.
	if (WI.fillTextValue("my_home").equals("1")){
		strColorScheme = CommonUtil.getColorScheme(9);
		bolMyHome = true;
		bolViewOnly = true;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Misc. Deduction posting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	document.form_.donot_call_close_wnd.value="0";
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";	
	document.form_.save.disabled = true;
	document.form_.submit();
//	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	document.form_.donot_call_close_wnd.value="0";
	
		location ="./post_ded.jsp?popup="+document.form_.popup.value+
							"&emp_id="+document.form_.emp_id.value+
							"&month_of="+document.form_.month_of.value+
							"&year_of="+document.form_.year_of.value+
							"&sal_period_index="+document.form_.sal_period_index.value+
							"&date_from="+document.form_.date_from.value+
							"&date_to="+document.form_.date_to.value;
}

function ReloadPage()
{
	document.form_.donot_call_close_wnd.value="0";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){
//	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
//	"&opner_form_name=form_";
	document.form_.donot_call_close_wnd.value="0";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
function focusID() {	
	<%if(!bolPopUp){%>
	document.form_.emp_id.focus();
	<%}%>
}
function CopyID(strID)
{	
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

}

function ReloadMain(){
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();

		window.opener.focus();
	}
}


//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
function clearDates(){
	document.form_.start_date.value = "";
	document.form_.end_date.value = "";
} 

function UpdateValue(strRowIndex, strLabelID, strFieldName) {
	var strValue = prompt("Please enter new value","");
	if(strValue == null || strValue.length == 0) 
		return;
	//else I have to call for Ajax here.. 
	this.ajaxUpdateValue(strRowIndex, strLabelID, strValue, strFieldName, null);
}

function UpdatePayable(strRowIndex, strLabelID) {
	var strReason = prompt("Please enter reason for updating payable to zero","");
	if(strReason == null || strReason.length == 0) 
		return;
	//else I have to call for Ajax here.. 
	this.ajaxUpdateValue(strRowIndex, strLabelID, "0", "payable_bal", strReason);
}

function ajaxUpdateValue(strRowIndex, strLabelID, strValue, strFieldName, strReason) {
		var objCOAInput = document.getElementById(strLabelID);
		
		this.InitXmlHttpObject(objCOAInput, 2);
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=303&new_value="+strValue+
			"&post_deduct_index="+strRowIndex+"&fieldName="+strFieldName+
			"&reason="+strReason;
			
		this.processRequest(strURL);
}

function updatePreload(){	
	var loadPg = "./post_ded_preload_mgmt.jsp?opner_form_name=form_&opner_form_field=deduct_index"+
				 "&opner_form_field_value="+document.form_.deduct_index.value;
	var win=window.open(loadPg,"updatePreload",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function checkKeyPress(strFormName, strFieldName, strExtn, strKeyCode){
	/*
		strKeyCodes
			35 = end, 36 = home, 37 = left, 38 = up, 39 = right, 40 = down
			8 = backspace, 46 = delete
			96 - 105 - numpad
			48 - 57 - kanang sa taas na numbers
			110 - period sa main
			190 - period sa numpad
			111 - / sa keypad
			191 - / sa main
	*/
	//alert("strKeyCode - " + strKeyCode);
 	if((strKeyCode >= 35 && strKeyCode <= 40)		
		|| (strKeyCode >= 48	&& strKeyCode <= 57)
		|| (strKeyCode >= 96	&& strKeyCode <= 105)
		|| strKeyCode == 8	|| strKeyCode == 46)
		return;
	
	AllowOnlyFloat(strFormName, strFieldName);
}
 
-->
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	boolean bolIsRecurring = false;

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="post_ded_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions (Per Employee)","post_ded.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"post_ded.jsp");
	strEmpID = (String)request.getSession(false).getAttribute("userId");
	if (strEmpID != null ){
		if(bolMyHome){
			iAccessLevel  = 2;
			request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
		}
	}						

	strEmpID = WI.fillTextValue("emp_id");
 	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");
	if (WI.fillTextValue("emp_id").length() == 0 && strEmpID.length() > 0){
		request.setAttribute("emp_id",strEmpID);
	}
	
	if (strEmpID == null) 
		strEmpID = "";

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
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vEmpList = null;
Vector vDate = null;

PRMiscDeduction prd = new PRMiscDeduction(request);
PReDTRME prEdtrME = new PReDTRME();
Vector vSalaryPeriod 		= null;//detail of salary period.
String strSchCode = dbOP.getSchoolIndex();
	payroll.PRConfidential prCon = new payroll.PRConfidential();
	boolean bolCheckAllowed = true;
	if(!WI.getStrValue(strSchCode).toUpperCase().startsWith("FADI") && !bolMyHome)
		bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);
	
if (WI.fillTextValue("emp_id").length() > 0 || strEmpID != null) {
	if(bolCheckAllowed){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}	
	}else
	   strErrMsg = prCon.getErrMsg();
 }

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");

String strDateFr = null;
String strDateTo = null;
String strPayrollPeriod  = null;
String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
int iSearchResult = 0;
int i = 0;
double dPayable = 0d;

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (prd.operateOnMiscDeductions(dbOP,request,0) != null){
			strErrMsg = " Deduction removed successfully ";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (prd.operateOnMiscDeductions(dbOP,request,1) != null){
			strErrMsg = " Deduction posted successfully ";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (prd.operateOnMiscDeductions(dbOP,request,2) != null){
			strErrMsg = " Deduction updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = prd.getErrMsg();
			if(strErrMsg.startsWith("Salary of"))
				strPrepareToEdit = "";
		}
	}
}
 	if (WI.fillTextValue("emp_id").length() > 0 || strEmpID != null) {
		/*		vDate = prd.getSalaryPeriodInfo(dbOP,WI.getTodaysDate());
			if(vDate != null && vDate.size() > 0){
			  strDateFr = (String)vDate.elementAt(0);
			  strDateTo = (String)vDate.elementAt(1);
			}else{
			  strDateFr = "";
			  strDateTo = "";
			}*/
		vRetResult = prd.operateOnMiscDeductions(dbOP,request,4);
 		if(vRetResult == null && strErrMsg == null){
			strErrMsg = prd.getErrMsg();
		}else{
			iSearchResult = prd.getSearchCount();
		}
		vEmpList = prd.getEmployeesList(dbOP);
		
	}


Vector vInfoDetail = null;
if (strPrepareToEdit.length() > 0){
	vInfoDetail = prd.operateOnMiscDeductions(dbOP, request, 3);
	if (vInfoDetail == null)
		strErrMsg = prd.getErrMsg();
}

if(WI.fillTextValue("view").length() > 0){
	bolViewOnly = true;
	strReadOnly = " readonly";
}

	if(WI.fillTextValue("year_of").length() > 0 && WI.fillTextValue("reset_page").length() == 0) {
		vSalaryPeriod = prEdtrME.getEmployeePeriods(dbOP, request, strEmployeeIndex);
		if(vSalaryPeriod == null)
			strErrMsg = prEdtrME.getErrMsg();

	}
%>
<body bgcolor="#D2AE72" onLoad="focusID();" onUnload="ReloadMain();" class="bgDynamic">
<form action="post_ded.jsp" method="post" name="form_" id="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
		 MISC. DEDUCTIONS : POST DEDUCTIONS PAGE ::::</strong></font></td>
	</tr>
</table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td height="23" colspan="4"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>		
</table>	
 <%if(!bolMyHome){%>
 
<%if (vRetResult != null &&  vRetResult.size() > 0) {
	String strTDColor = null;//grey if already deducted.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a>
          click to print</font></div></td>
    </tr>
    <%
		int iPageCount = iSearchResult/prd.defSearchSize;		
		if(iSearchResult % prd.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="right">Jump To page:
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
      </div></td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" colspan="11" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST
      OF POSTED MISCELLANEOUS DEDUCTIONS</strong></td>
    </tr>
    <tr>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">DEDUCTION NAME</font></strong></td>
      <td width="18%" height="28" align="center" class="thinborder"><strong><font size="1">START DEDUCTION<br>(in System)</font></strong></td>
      <td width="19%" align="center" class="thinborder"><strong><font size="1">DEDUCTION RANGE </font></strong></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
	    <td width="10%" align="center" class="thinborder"><font size="1"><strong>MAX DEDUCTION </strong></font></td>
	    <td width="10%" align="center" class="thinborder"><font size="1"><strong>PAYABLE BALANCE</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DATE POSTED</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DETAILS</strong></font></td>
      <!--
			<td align="center" class="thinborder"><font size="1"><strong>POSTED BY</strong></font></td>
			-->
 <%if(!bolViewOnly && !bolPopUp){%>
      <td colspan="2" align="center" class="thinborder"><font size="1"><strong>OPTIONS</strong></font></td>
 <%}%>
    </tr>
	<% for (i = 0; i < vRetResult.size(); i+=25){
		bolIsRecurring = false;
		strTemp = (String)vRetResult.elementAt(i + 8);
 		if(strTemp != null && !strTemp.equals("0")){
			strTDColor = "bgcolor=#DDDDDD";
			if(strTemp.equals("2")){
				strTemp2 = "Recurring";
				bolIsRecurring = true;
			}else if(strTemp.equals("3")){
				strTemp2 = "Stopped";
			} else {
				strTemp2 = "&nbsp;";
			}
		}else{
			strTDColor = "";
			//strTemp2 = (String)vRetResult.elementAt(i+4) +"-"+
			strTemp2 = (String)vRetResult.elementAt(i+5);
 		}
	%>
    <tr <%=strTDColor%>>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=strTemp2%></font></td>
			<%
				strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+18), ""," - "+(String)vRetResult.elementAt(i+19),"&nbsp;");
			%>
			<td class="thinborder"><font size="1"><%=strTemp2%></font></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
			%>			
      <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+16),true);
			%>				
			<td align="right" class="thinborder">
 			<font size="1"><label id="max_ded_<%=i%>" <%if(!bolIsRecurring){%>onDblClick="UpdateValue('<%=vRetResult.elementAt(i)%>','max_ded_<%=i%>', 'max_deduction');"<%}%>>
			<%=strTemp%>&nbsp;</label></font></td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+13),true);
				dPayable = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
			%>						
	    <td align="right" class="thinborder">
			<!--
			onDblClick="UpdateValue('<%=vRetResult.elementAt(i)%>','payable_<%=i%>', 'payable_bal');"
			-->
			<font size="1"><label id="payable_<%=i%>"<%if(!bolIsRecurring && dPayable > 0d){%>onDblClick="UpdatePayable('<%=vRetResult.elementAt(i)%>','payable_<%=i%>');"<%}%>>
			<%=strTemp%>&nbsp;</label></font>			</td>
      <td width="10%" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
			<td width="10%" align="center" class="thinborder">&nbsp;</td>
			<!--
      <td width="12%" height="25" class="thinborder"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+10),
								(String)vRetResult.elementAt(i+11),(String)vRetResult.elementAt(i+12),4)%></font></td>
			-->			
 <%if(!bolViewOnly && !bolPopUp){%>
      <td width="6%" class="thinborder">
	  <% if (iAccessLevel > 1 && strTDColor.length() == 0){%>
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0" ></a>
	  <%}else{%> N/A <%}%>	  </td>

      <td width="8%" align="center" class="thinborder">
	  <%if (iAccessLevel==2 && strTDColor.length() == 0) {%>
	  <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0" ></a>
	  <%}else{%>
	  N/A
	  <%}%>	  </td>
<%}%>
    </tr>
    <%} //end for loop%>
  </table>

<% } // end vRetResult != null && vRetResult.size() > 0

}// end if Employee ID is null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
<input type="hidden" name="reset_page">
<%if(bolViewOnly){%>
<input type="hidden" name="view" value="1">
<%}%>
<input type="hidden" name="popup" value="<%=WI.fillTextValue("popup")%>">

<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->

<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
