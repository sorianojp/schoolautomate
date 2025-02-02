<%@ page language="java" import="utility.*,java.util.Vector,payroll.PREarningDed" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Post Earnings Deduction</title>
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
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./earning_deduct.jsp?emp_id="+document.form_.emp_id.value;
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function viewList(table,indexname,colname,labelname)
{
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
	"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
function focusID() {
	document.form_.emp_id.focus();
}
function CopyID(strID)
{
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

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
-->
</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="post_ded_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","earning_deduct.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"earning_deduct.jsp");
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

PREarningDed prd = new PREarningDed(request);

if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}
}

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strSchCode = dbOP.getSchoolIndex();
int iEmpIndex = 0;
if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (prd.operateOnEarningDeductions(dbOP,request,0) != null){
			strErrMsg = " Deduction removed successfully ";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (prd.operateOnEarningDeductions(dbOP,request,1) != null){
			strErrMsg = " Deduction posted successfully ";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (prd.operateOnEarningDeductions(dbOP,request,2) != null){
			strErrMsg = " Deduction updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = prd.getErrMsg();
		}
	}
}

	if (WI.fillTextValue("emp_id").length() > 0) {
		vRetResult = prd.operateOnEarningDeductions(dbOP,request,4);
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = prd.getErrMsg();
		vEmpList = prd.getEmployeesList(dbOP);
	}


Vector vInfoDetail = null;
if (strPrepareToEdit.length() > 0){
	vInfoDetail = prd.operateOnEarningDeductions(dbOP,request,3);
	if (vInfoDetail == null)
		strErrMsg = prd.getErrMsg();
}

boolean bolViewOnly = false;
if(WI.fillTextValue("view").length() > 0)
	bolViewOnly = true;
%>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form action="earning_deduct.jsp" method="post" name="form_" id="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        PAYROLL: EARNING DEDUCTIONS : POST DEDUCTIONS PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3">&nbsp;&nbsp;<strong> <font size="2"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
      <td width="273" height="23" align="right"><%
	  		if (vEmpList != null && vEmpList.size() > 0){
			  %>
        <%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
        <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
        <%}else{%>
FIRST
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
<%}else{%>
PREVIOUS
<%}%>
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
<%}else{%>
NEXT
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=((String)vEmpList.elementAt(vEmpList.size()-1)).toUpperCase()%>');">LAST</a>
<%}else{%>
LAST
<%}%>
<%}// if (vEmpList != null && vEmpList.size() > 0)%></td>
    </tr>
    <tr>
      <td width="228">Employee ID :
        <input name="emp_id" type="text" class="textbox" onKeyUp="AjaxMapName(1);"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">
      </td>
      <%if(!bolViewOnly){%>
      <td width="40" height="10"><a href="javascript:OpenSearch()"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <%}%>
      <td colspan="2"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="5%" height="28">&nbsp;</td>
      <td width="45%">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
      <td width="50%" height="28">Employee ID :<strong><%=WI.fillTextValue("emp_id")%></strong> </td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="29" colspan="2"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%>
        </strong></td>
      <td height="29">Employment Status : <strong><%=(String)vPersonalDetails.elementAt(16)%>
        </strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
<%if(!bolViewOnly){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="29">&nbsp;</td>
      <td width="17%" height="29">Deduction Name : </td>
      <td width="80%"><select name="deduct_index">
          <%	if(vInfoDetail!=null) strTemp= (String)vInfoDetail.elementAt(1);
	else strTemp= WI.fillTextValue("deduct_index");%>
          <option value="">Select Deduction Name</option>
          <%=dbOP.loadCombo("earn_ded_index","earn_ded_name", " from preload_earn_ded order by earn_ded_name",strTemp,false)%>
        </select>
        <a href='javascript:viewList("preload_earn_ded","earn_ded_index","earn_ded_name","EARNING DEDUCTION NAMES");'><img src="../../../images/update.gif" border="0" ></a><font size="1">click
        to add to the list earnings deduction</font></td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Deduction Period : </td>
      <td height="29"><strong> </strong><strong>
<%	if(vInfoDetail!=null) strTemp= (String)vInfoDetail.elementAt(4);
	else strTemp= WI.fillTextValue("date_to");%>
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Amount :<strong> </strong></td>
      <td><strong>
        <%	if(vInfoDetail!=null) strTemp= (String)vInfoDetail.elementAt(5);
	else strTemp= WI.fillTextValue("amount");%>
        <input  type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onblur="style.backgroundColor='white'"  name="amount" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </strong></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
<%if (iAccessLevel > 1) { //if iAccessLevel > 1%>
	<tr>
	  <td height="29">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("viewAll");
		if(strTemp.compareTo("1") ==0)
			strTemp = "checked";
		else
			strTemp = "";
		%>
	  <td colspan="2" align="center"><strong>
    <input type="checkbox" name="viewAll" value="1" <%=strTemp%> onClick="javascript:ReloadPage();">
</strong><font size="1">View all(show also deducted earnings)</font></td>
	  </tr>
	<tr>
      <td height="29">&nbsp;</td>
      <td colspan="2"><div align="center">
<%if (vInfoDetail == null) {%>
          <a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
          to add</font>
          <%}else{%>
          <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
          to save changes</font>
          <%}%>
          <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
          <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to
          cancel or go previous</font>

        </div></td>
    </tr>
<%} //end iAccessLevel > 1%>
  </table>
<%}//end if bolIsView is false..

if (vRetResult != null &&  vRetResult.size() > 0) {
	String strTDColor = null;//grey if already deducted.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="30%" height="10">&nbsp;</td>
      <td width="70%" height="10" colspan="2"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a>
          click to print</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" colspan="8" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST
      OF POSTED EARNING DEDUCTIONS</strong></td>
    </tr>
    <tr>
      <td width="16%" align="center" class="thinborder"><strong><font size="1">DEDUCTION
      NAME</font></strong></td>
      <td width="10%" height="28" align="center" class="thinborder"><font size="1"><strong>DATE
      DEDUCTION</strong></font></td>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>PAYABLE
      BALANCE</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DATE POSTED</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>POSTED
      BY</strong></font></td>
      <%if(!bolViewOnly){%>
      <td colspan="2" align="center" class="thinborder"><font size="1"><strong>OPTIONS</strong></font></td>
      <%}%>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+=12){
	if(vRetResult.elementAt(i + 7) != null && ((String)vRetResult.elementAt(i + 7)).equals("1"))
		strTDColor = "bgcolor=#DDDDDD";
	else
		strTDColor = "";
	%>
    <tr <%=strTDColor%>>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td align="right" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</font></td>
      <td align="right" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+10)%>&nbsp;</font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></td>
      <td width="13%" height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+8)%></font></td>
      <%if(!bolViewOnly){%>
      <td width="9%" align="center" class="thinborder"> 
        <% if (iAccessLevel > 1 && strTDColor.length() == 0){%>
        <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0" ></a>
        <%}else{%>
        N/A
        <%}%>        </td>
      <td width="14%" align="center" class="thinborder"> 
        <%if (iAccessLevel==2 && strTDColor.length() == 0) {%>
        <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0" ></a>
        <%}else{%>
        N/A
        <%}%>        </td>
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

<%if(bolViewOnly){%>
<input type="hidden" name="view" value="1">
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>