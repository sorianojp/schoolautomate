<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if ( WI.fillTextValue("print_page").equals("1")){%>
	<jsp:forward page="./post_charge_print.jsp" />
<%	return;} %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
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
table.thinborder{
	border-top : solid  1px #BB0004;
	border-right : solid 1px #BB0004;
}

TD.thinborder {
    border-left: solid 1px #BB0004;
    border-bottom: solid 1px #BB0004;
} 
-->
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.print_page.value = "";
	document.form_.page_action.value = "";	
	
	if(document.getElementById("accept_pmt_button"))
		document.getElementById("accept_pmt_button").disabled = true;
	if(document.getElementById("del_pmt_button"))
		document.getElementById("del_pmt_button").disabled = true;
	
	document.form_.submit();
}
function OpenSearch() {
	document.form_.print_page.value = "";
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	//document.getElementById('myADTable3').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);
	alert("Click OK to print this page");
	window.print();
}

//on changing service type, i must compute payable amt.
function ComputeAmtPayable() {
	var iNoOfUnit = document.form_.no_of_units.value;
	if(iNoOfUnit.length == 0) {
		iNoOfUnit = "1";
		//document.form_.no_of_units.value = "1";
	}
	var iFeeTypeSel = document.form_.service_ref.selectedIndex;
	var strFeeAmt = "";
	eval('strFeeAmt=document.form_._'+iFeeTypeSel+'.value');
	strFeeAmt = eval(strFeeAmt) * eval(iNoOfUnit);
	document.getElementById('tot_amt').innerHTML = this.formatFloat(strFeeAmt,2,true);
}


///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}


</script>
<body>
<%
	String strErrMsg = null;
	String strTemp = null;

	double dUnitPrice   = 0d;
	double dNoOfUnit    = 0d;
	double dTotalCharge = 0d;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET OTHER SERVICES - Post Charges","post_charge.jsp");
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
														"Internet Cafe Management","INTERNET OTHER SERVICES",
														request.getRemoteAddr(),"post_charge.jsp");
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

Vector vStudInfo  = null;
Vector vRetResult = null;
iCafe.ICafeOtherService iCafeService = new iCafe.ICafeOtherService();

if(WI.fillTextValue("stud_id").length() > 0) {//only if student id is entered.
	FAPaymentUtil paymentUtil = new FAPaymentUtil();
	vStudInfo = paymentUtil.getStudBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null) 
		strErrMsg = paymentUtil.getErrMsg();
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	iCafeService.operateOnPostCharge(dbOP, request, Integer.parseInt(strTemp));
	strErrMsg = iCafeService.getErrMsg();
}

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";


Vector vServiceFee = new Vector();
strTemp = "select SERVICE_INDEX,SERVICE_CODE, service_name,UNIT_PRICE from IC_SERVICE where is_Valid = 1 order by service_code";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next()) {
	vServiceFee.addElement(rs.getString(1));//service index
	vServiceFee.addElement(rs.getString(2));//service_code
	vServiceFee.addElement(rs.getString(3));//service_name
	vServiceFee.addElement(ConversionTable.replaceString(CommonUtil.formatFloat(rs.getDouble(4),true), ",",""));//unit_price
}
rs.close();

vRetResult = iCafeService.operateOnPostCharge(dbOP, request, 4);

String strActionType = WI.fillTextValue("action_type");
if(strActionType.length() == 0) 
	strActionType = "0";
%>
<form name="form_" action="./post_charge.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>:::: Post Other Charges ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="57%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
      <td width="43%" style="font-size:9px">
<%
if(strActionType.equals("0"))
	strTemp = " checked";
else	
	strTemp = "";
%> 	  <input name="action_type" type="radio" value="0"<%=strTemp%> onClick="ReloadPage();"> None 
<%
if(strActionType.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input name="action_type" type="radio" value="1"<%=strTemp%> onClick="ReloadPage();"> Accept Payment 
<%
if(strActionType.equals("2"))
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input name="action_type" type="radio" value="2"<%=strTemp%> onClick="ReloadPage();"> Delete Post Charge
	  </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr bgcolor="#DDDDDD">
      <td height="25">&nbsp;</td>
      <td colspan="3" >
<%
strTemp = WI.fillTextValue("show_not_paid");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  	<input name="show_not_paid" type="radio" value="0"<%=strErrMsg%>> View not paid
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  	<input name="show_not_paid" type="radio" value="1"<%=strErrMsg%>> View paid
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	
	  	<input name="show_not_paid" type="radio" value="2"<%=strErrMsg%>> View all 
	 </td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" colspan="3" >Date Posted Range :
        <input name="date_posted_fr" type="text" class="textbox" id="date_attendance" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_fr")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <input name="date_posted_to" type="text" class="textbox" id="date_attendance2" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_to")%>" size="10" maxlength="12" readonly>
      <a href="javascript:show_calendar('form_.date_posted_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td height="20">&nbsp;</td>
      <td colspan="3" style="font-size:10px;">USE FILTER TO LIMIT VIEW. <strong>ID NUMBER</strong> OF STUDENT STARTS WITH 
        <input type="text" name="id_number_starts" size="12"
			value="<%=WI.fillTextValue("id_number_starts")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp;&nbsp;
        <input name="1234" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = ''" value="Refresh >>">        </td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable3">
    <tr bgcolor="#DDDDDD">
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">Show only Fee : 
	  <select name="show_fee">
	  <option value=""></option>
<%
strTemp = WI.fillTextValue("show_fee");
for(int i = 0; i < vServiceFee.size(); i += 4) {
	if(strTemp.equals(vServiceFee.elementAt(i)))
		strErrMsg = " selected";
	else	
		strErrMsg = "";
	%><option value="<%=vServiceFee.elementAt(i)%>"<%=strErrMsg%>><%=vServiceFee.elementAt(i + 1) +" :: "+vServiceFee.elementAt(i + 3)+" /Unit"%></option>
<%}%>	  
	  </select>
	  </td>
    </tr>
    <tr bgcolor="#DDDDDD"> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">
	  <div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')">
	  	<img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
	 	<u>Help on how to use this page</u>		</div>
			<span class="branch" id="branch1">
		  		<table width="84%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td style="font-size:9px;">
					<b>Operation :</b> <br>
					 None  	: To print the report <br>
					 Accept Payment : To post charge and accept payment <br>
					 Delete Post Charge : To Delete post charge. <br> <br>
					 
					<b>Search Condition :</b>  <br>
					View not paid  : Show student list not yet paid. <br>
					View paid  : Show list who paid <br>
					View all : includes list who paid and who did not pay. <br> <br>					
					
					<b>To Post charge :</b> <br>
					1. Select operation "Accept payment", Page will reload <br>
					2. select the service requested, and number of units to charge, enter ID of student and click refresh <br>
					3. Save button appears, click save.  <br>
					4. For more number of student, just enter another ID, select service type, enter number of units and save <br>
					
					</td>
				</tr>
				</table>
					</span>	  

	  </td>
    </tr>
<!--    <tr bgcolor="#DDDDDD"> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2"><strong><font color="#FF0000">SORTING CONDITIONS :&nbsp;</font></strong></td>
    </tr>
    <tr bgcolor="#DDDDDD"> 
      <td height="25">&nbsp;</td>
      <td width="36%">
	  <select name="sort_by1">
        <option value="0">Sort by</option>
        <%if (WI.fillTextValue("sort_by1").equals("1")){%>
        <option value="1" selected>Date Posted</option>
        <%}else{%>
        <option value="1">Date Posted</option>
        <%}if (WI.fillTextValue("sort_by1").equals("2")){%>
        <option value="2" selected>Fee Name</option>
        <%}else{%>
        <option value="2">Fee Name</option>
        <%}if (WI.fillTextValue("sort_by1").equals("3")){%>
        <option value="3" selected>ID Number</option>
        <%}else{%>
        <option value="3">ID Number</option>
		<%}if (WI.fillTextValue("sort_by1").equals("4")){%>
        <option value="4" selected>Lastname</option>
        <%}else{%>
        <option value="4">Lastname</option>
        <%}%>
      </select>
      <select name="sort_by1_cond">
		  <option value=" asc">Ascending</option>
		  <% if (WI.fillTextValue("sort_by1_cond").startsWith("d")){%>
		  <option value="desc" selected>Descending</option>
		  <%}else{%>
		  <option value="desc">Descending</option>
		  <%}%>
      </select>&nbsp;</td>
      <td width="62%"><select name="sort_by2">
          <option value="0">Sort by</option>
		  <%if (WI.fillTextValue("sort_by2").compareTo("1") == 0){%>
		  <option value="1" selected>Date Posted</option>
		  <%}else{%>
		  <option value="1">Date Posted</option>
		  <%}if (WI.fillTextValue("sort_by2").compareTo("2") == 0){%>
		  <option value="2" selected>Fee Name</option>
		  <%}else{%>
		  <option value="2">Fee Name</option>
		  <%}if (WI.fillTextValue("sort_by2").compareTo("3") == 0){%>
		  <option value="3" selected>ID Number</option>
		  <%}else{%>
		  <option value="3">ID Number</option>
		<%}if (WI.fillTextValue("sort_by1").equals("4")){%>
        <option value="4" selected>Lastname</option>
        <%}else{%>
        <option value="4">Lastname</option>
	  <%}%>
		 </select> 
		  <select name="sort_by2_cond">
		  <option value=" asc">Ascending</option>
		  <% if (WI.fillTextValue("sort_by2_cond").startsWith("d")){%>
		  <option value="desc" selected>Descending</option>
		  <%}else{%>
		  <option value="desc">Descending</option>
		  <%}%>
	  </select>&nbsp;</td>
    </tr>-->
  </table>
<%//do not show this if strActionType is not 0  
if(strActionType.equals("1")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20" colspan="3" bgcolor="#B9B292"><div align="center"><strong>Service Post Charge Detail</strong></div></td>
    </tr>
    <tr> 
      <td width="2%" height="18">&nbsp;</td>
      <td width="46%" valign="bottom">Service Type :: Rate </td>
      <td width="52%" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  <select name="service_ref" onChange="ComputeAmtPayable();">
<%
strTemp = WI.fillTextValue("service_ref");
for(int i = 0; i < vServiceFee.size(); i += 4) {
	if(strTemp.equals(vServiceFee.elementAt(i))) {
		strErrMsg  = " selected";
		dUnitPrice = Double.parseDouble((String)vServiceFee.elementAt(i + 3)); 
	}
	else	
		strErrMsg = "";
	%><option value="<%=vServiceFee.elementAt(i)%>"<%=strErrMsg%>><%=vServiceFee.elementAt(i + 1) +" :: "+vServiceFee.elementAt(i + 3)+" /Unit"%></option>
<%}

if(dUnitPrice == 0d) 
	dUnitPrice = Double.parseDouble((String)vServiceFee.elementAt(3)); 
dNoOfUnit = Double.parseDouble(WI.getStrValue(WI.fillTextValue("no_of_units"), "1"));

dTotalCharge = dUnitPrice * dNoOfUnit;
%>	  
	  </select>	  
<%for(int i = 0; i < vServiceFee.size(); i += 4) {%>
	<input type="hidden" name="_<%=i/4%>" value="<%=vServiceFee.elementAt(i + 3)%>">
<%}%>	  </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Unit quantity/usage/requested: 
        <input name="no_of_units" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("no_of_units")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" onKeyUp="ComputeAmtPayable();"></td>
      <td ><font color="#0000FF"><strong>Amount payable :<label id="tot_amt"> 
        <%=CommonUtil.formatFloat(dTotalCharge,true)%></label></strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Date Posted 
<%
strTemp = WI.fillTextValue("date_posted");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_posted" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_posted');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>        </td>
      <td >
        <input name="12345" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = ''" value="Refresh >>">
      
	  <font size="1">Click to update amount payable</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="12%" height="10" colspan="9"><hr size="1"></td>
    </tr>
  </table>
<%//dTotalCharge = 0d;
}%>
<%if(dTotalCharge > 0d){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
      <td  colspan="3"><strong><font color="#0000FF"><u>FEE CHARGE TO :</u></font></strong></td>
    </tr>
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%" >Specific Student ID &nbsp; </td>
      <td width="17%"> <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" 
      class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="62%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="48%" >Student name :<strong> <%=(String)vStudInfo.elementAt(1)%> </strong></td>
      <td width="50%" >Current Year/Term:<strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%> 
      (<%=astrConvertTerm[Integer.parseInt((String)vStudInfo.elementAt(5))]%>)</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" >Course / Major:<strong> <%=(String)vStudInfo.elementAt(2)%> 
        <%if(vStudInfo.elementAt(3) != null){%>/<%=WI.getStrValue(vStudInfo.elementAt(3))%> <%}%>
        </strong></td>
    </tr>
  </table>
<%}//if student info is not null
boolean bolShowSave = false;
if(iAccessLevel > 1)
	bolShowSave = true;
else	
	strErrMsg = "Not authorized to save.";
//bolShowSave is false if the chage is for a specific student and student information is not found. 
if(bolShowSave && (vStudInfo == null || vStudInfo.size() ==0) )
	bolShowSave = false;
%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td align="center">
<%if(bolShowSave){%>
<input name="submit5" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = '5'" value="Save Entries >>">
</a> 
        <font size="1">click to save entries</font>
    <%}else{%><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font><%}%></td>
    </tr>
  </table>
<%}//only if dTotalCharge > 0f)
//and if the student's current enrollment information is same as the WI.fillTextValue("sy_from"),
if(vRetResult != null && vRetResult.size() > 0 ) {
String strTotalPaid = (String)vRetResult.remove(0);
String strTotalUnpaid = (String)vRetResult.remove(0);
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable4">
<%
if(strActionType.equals("0")){%>
    <tr> 
      <td width="46%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="54%" bgcolor="#FFFFFF"><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print charges</div></td>
    </tr>
<%}%>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong>LIST OF FEE CHARGE(S) POSTED</strong></div></td>
    </tr>
    <tr> 
      <td style="font-size:9px;">Total Display : <%=vRetResult.size()/13%></td>
      <td height="20" align="right" style="font-size:9px;">Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#999999">
   <tr bgcolor="#FFFFFF">
     <td width="5%" align="center"><strong><font size="1">Count</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">ID Number </font></strong></td>
      <td width="20%" align="center"><strong><font size="1">Name</font></strong></td>
      <td width="25%" height="20"><div align="center"><font size="1"><strong>Service Code : Service Name </strong></font></div></td>
      <td width="10%" align="center"><strong><font size="1">Total Charge </font></strong></td>
      <td width="10%" align="center"><font size="1"><strong>Charged By </strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>Date Posted </strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>Is Paid </strong></font></td>
<%
if(!strActionType.equals("0")){%>
      <td width="8%" align="center"><strong><font size="1">Select</font></strong></td>
<%}%>
     </tr>
<%
//	System.out.println("vRetResult : " + vRetResult);

boolean bolIsPaid = false; int iRowCount = 0; 
//strActionType = 1(accept payment) if bolIsPaid is true, do not show check box.
//strActionType = 2 (delete post charges) if bolPaid is true, do not show check box.
boolean bolShowCheckBox = false;//meaning , in both the cases if bolIsPaid, i do not show check box.. so i am not using this field as of now.

for(int i = 0 ; i < vRetResult.size(); i += 13) {
if(vRetResult.elementAt(i + 10) == null)
	bolIsPaid = false;
else	
	bolIsPaid = true;
%>
    <tr bgcolor="#FFFFFF">
      <td><%=i/13 + 1%>.</td>
      <td><%=vRetResult.elementAt(i + 2)%></td>
      <td><%=vRetResult.elementAt(i + 3)%></td>
      <td height="20"><%=vRetResult.elementAt(i + 4)%> :: <%=vRetResult.elementAt(i + 5)%></td>
      <td align="right"><%=vRetResult.elementAt(i + 11)%>&nbsp;</td>
      <td ><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td ><div align="right"><%=(String)vRetResult.elementAt(i + 12)%>&nbsp;</div>      </td>
      <td align="center"><%if(bolIsPaid){%><img src="../../../images/tick.gif"><%}else{%><img src="../../../images/x.gif"><%}%></td>
<%
if(!strActionType.equals("0")){%>
      <td align="center"><%if(!bolIsPaid){%><input type="checkbox" name="<%=iRowCount++%>" value="<%=vRetResult.elementAt(i)%>"><%}else{%>&nbsp;<%}%></td>
<%}%>
     </tr>
<%}//end of for loop.%>
<input type="hidden" name="max_disp" value="<%=iRowCount%>">
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="20" style="font-size:11px; font-weight:bold; color:#0033FF">Total Payment Made :<%=strTotalPaid%> &nbsp;&nbsp;&nbsp; Total Balance Payment :<%=strTotalUnpaid%> 
	  <div align="right" style="font-size:9px; color:#000000">
	  Printed By : <%=request.getSession(false).getAttribute("first_name")%></div>
	  </td>
    </tr>
    <tr> 
      <td height="25" align="center">
<%
if(strActionType.equals("1")) {//accept payment.%>
	<input name="submit5" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" id="accept_pmt_button" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = '6'" value="Accept Payment >>">
<%}else if(strActionType.equals("2")) {//Delete post charges.%>
<input name="submit5" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" id="del_pmt_button" 
			onClick="document.form_.print_page.value = '';document.form_.page_action.value = '0'" value="Delete Post Charges >>">
<%}%>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}%>
 <input type="hidden" name="page_action" value="">
 <input type="hidden" name="print_page">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
