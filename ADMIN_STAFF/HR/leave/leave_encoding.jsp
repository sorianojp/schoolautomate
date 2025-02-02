<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLeave"%>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Manual update leave credits</title>
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
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: block;
	margin-left: 16px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script>
<!--
function PrintPage(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}
function PageAction(strAction) {
	document.form_.print_pg.value="";
	document.form_.page_action.value = strAction;
	document.form_.reset_page.value = "1";	
	document.form_.submit();
}

function CancelRecord(){
//	document.form_.page_action.value = "";
//	document.form_.print_pg.value="";
//	document.form_.reset_page.value = "1";	
//	this.SubmitOnce('form_');
	location = "./leave_encoding.jsp?emp_id="+document.form_.emp_id.value;
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.print_pg.value="";
	this.SubmitOnce('form_');
}

function CopyID(strID)
{
	document.form_.emp_id.value=strID;
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function SelectCode(){
	var selectedIndex = document.form_.benefit_index.selectedIndex;	
	if(selectedIndex == 0){
		document.form_.rate.value = "";
		document.form_.rate_unit.value = "";
		document.form_.rate_unit_val.value = "";		
		return;
	}
	document.form_.rate.value = eval('document.form_.rate_'+selectedIndex+'.value');	
	document.form_.rate_unit.value = eval('document.form_.rate_unit_'+selectedIndex+'.value');
	document.form_.rate_unit_val.value = eval('document.form_.rate_unit_val_'+selectedIndex+'.value');
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

function focusID() {
	if(document.form_.emp_id)
		document.form_.emp_id.focus();
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

///////////////////////////////////////// End of collapse and expand filter ////////////////////

function ComputeCredit(){
	var vSummer =  document.form_.credit_0.value;
	var vFirst = document.form_.credit_1.value;
	var vSecond =  document.form_.credit_2.value;
	
	if(isNaN(vSummer) || vSummer.length == 0) 
		vSummer = "0";

	if(isNaN(vFirst) || vFirst.length == 0) 
		vFirst = "0";

	if(isNaN(vSecond) || vSecond.length == 0)  
		vSecond = "0";
	var vTotalCredit = 0;
	vTotalCredit = eval(vSummer) +  eval(vFirst) + eval(vSecond);
	if(isNaN(vTotalCredit))
		return;
	document.form_.available.value = eval(vTotalCredit);
}

-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="focusID()">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strHasWeekly = null;
	String strLeaveScheduler = null;
 
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
 	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null){//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	}else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-LEAVE APPLICATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
 	}
 	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-configuration-OT Rate","leave_encoding.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");			
		strLeaveScheduler = readPropFile.getImageFileExtn("LEAVE_SCHEDULER","0");					
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
	HRInfoLeave hrPx = new HRInfoLeave();	

	Vector vRetResult = null;
	Vector vEditInfo= null;	
	Vector vPersonalDetails = null;
	Vector vSalaryPeriod 	= null;//detail of salary period.
	Vector vTypes = null;
	Vector vSalaryDetails = null;
	boolean bolIsForSem = false;
		
	String strEmpID = WI.fillTextValue("emp_id");
	String strPageAction = WI.fillTextValue("page_action");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));

	String strSYFrom = WI.fillTextValue("sy_from");
  String strSYTo = WI.fillTextValue("sy_to");
  String strSemester = WI.fillTextValue("semester");

	Vector vAllowedLeave = null;
	Vector vLeaveDetail = null;
	if(strPageAction.length() > 0){
		if(hrPx.operateOnEmpAvailableLeave(dbOP, request,Integer.parseInt(strPageAction)) == null)
		   strErrMsg = hrPx.getErrMsg();
		else{
			if(strPageAction.equals("2"))
				strErrMsg = "Successfully updated leave running table";
		}
	}

	if (strEmpID.length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
		//vAllowedLeave = hrPx.getAllowedLeave(dbOP, request);
		vAllowedLeave = hrPx.getAvailableLeaveForSemNew(dbOP, request);
		
		vLeaveDetail = hrPx.operateOnEmpAvailableLeave(dbOP, request,3);
		// vLeaveDetail = hrPx.getApplicableEmployeeLeaves(dbOP, request, 4);
		
		if(vPersonalDetails == null)
			strErrMsg = "Employee Profile not Found";
		
		if(vAllowedLeave ==  null)
			strErrMsg = hrPx.getErrMsg();
	}//System.out.println(vPersonalDetails);
	
%>
<form action="leave_encoding.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      MANUAL LEAVE UPDATE::::</strong></font></td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3">&nbsp;<font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%">Employee ID</td>
      <td width="83%"><input name="emp_id" type="text" size="16" value="<%=strEmpID%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			onKeyUp="AjaxMapName(1);">
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a><label id="coa_info"></label>
		<!--
		<input type="hidden" name="sy_from" value="<%=WI.getTodaysDate(12)%>">
	  <input type="hidden" name="sy_to" value="<%=WI.getTodaysDate(12)%>">
		-->
		</td>
    </tr>
		<%if(strLeaveScheduler.equals("0") || strLeaveScheduler.equals("2") || strLeaveScheduler.equals("3")){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2"><%if(bolIsSchool){%>
        SY / SEM
          <%}else{%>
          Year
          <%}%>
          &nbsp;:
          <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) {
	if(!bolIsSchool) 
		strTemp = WI.getTodaysDate().substring(0,4);
	else	
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
}
%>
          <input name="sy_from" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4" onKeyUp="DisplaySYTo('form_', 'sy_from', 'sy_to')">
          <%
 	strSYTo = WI.fillTextValue("sy_to");
	if(strSYTo.length() ==0)
		strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%>
          <%if(bolIsSchool){%>
- &nbsp;
<input name="sy_to" type= "text" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" size="4" maxlength="4" 
		onBlur="style.backgroundColor='white'"  value="<%=strSYTo%>" readonly="yes">
&nbsp;&nbsp;
 
<%}else{///for companies.%>
<input type="hidden" name="sy_to" value="<%=strTemp%>">
 
<%}%></td>
    </tr>
		<%}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ReloadPage();"></a><font size="1">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        Click
        to reload page.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>	
	<%if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Employee Name : </td>
      <td><strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID : </td>
      <td><strong>&nbsp;<%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>
        /Office : </td>
      <%
		strTemp = (String)vPersonalDetails.elementAt(13);
		if (strTemp == null){
			strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}else{
			strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
		}
		%>
      <td><strong>&nbsp;<%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : </td>
      <td><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="25%">Employment Status<strong> : </strong></td>
      <td width="72%"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td  height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>	
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="17%">Leave Type:</td>
  		<%
				strTemp = WI.fillTextValue("benefit_index");
			%>
      <td height="26" colspan="2">
			<select name="benefit_index" onChange="ReloadPage();">
        <option value="0">Select Leave</option>
    <% 
		if (vAllowedLeave != null && vAllowedLeave.size() > 0){		
		for (int i= 0; i < vAllowedLeave.size(); i+=15){ 		
		   if (((String)vAllowedLeave.elementAt(i+3)).equals(strTemp)){%>
        <option selected value="<%=(String)vAllowedLeave.elementAt(i+3)%>"> <%=(String)vAllowedLeave.elementAt(i+4)%></option>
        <%}else{%>
        <option value="<%=(String)vAllowedLeave.elementAt(i+3)%>"> <%=(String)vAllowedLeave.elementAt(i+4)%></option>
        <%}
				} // end for loop 
		 	} // vaAllowedLeave  != null %>
      </select>

			<!--
			<select name="benefit_index" onChange="ReloadPage();">
        <option value="0">Select Leave</option>
    <% 
		//boolean bolShowLeaveForward = false;
		//if (vAllowedLeave != null && vAllowedLeave.size() > 0){		
	//	for (int i= 0; i < vAllowedLeave.size(); i+=3){ 		
  		 // if(vAllowedLeave.elementAt(i+2) != null 
				//&& ((Double)vAllowedLeave.elementAt(i+2)).doubleValue() <.01d){
				//	bolShowLeaveForward = true;
		   //}
		   
		  // if (((String)vAllowedLeave.elementAt(i)).equals(strTemp)){%>
        <option selected value="<%//=(String)vAllowedLeave.elementAt(i)%>"> <%//=(String)vAllowedLeave.elementAt(i+1)%></option>
        <%//}else{%>
        <option value="<%//=(String)vAllowedLeave.elementAt(i)%>"> <%//=(String)vAllowedLeave.elementAt(i+1)%></option>
        <%//}
				//} // end for loop 
		 	//} // vaAllowedLeave  != null %>
      </select>
			-->
			</td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td>Applicable leave : </td>
			<%
				if(vLeaveDetail != null && vLeaveDetail.size() > 0 && !WI.fillTextValue("reset_page").equals("1")){
					strTemp = (String)vLeaveDetail.elementAt(1);
 				}else
					strTemp = WI.fillTextValue("applicable"); 				
			%>
      <td width="11%" height="28"><strong>
        <input name="applicable" type="text" class="textbox" size="6" maxlength="12" 
	      onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				value="<%=strTemp%>" style="text-align:right" >
      </strong>			</td>
      <td width="69%"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
			<%
				if(vLeaveDetail != null && vLeaveDetail.size() > 0 && !WI.fillTextValue("reset_page").equals("1"))
					strTemp = (String)vLeaveDetail.elementAt(2);
				else
					strTemp = WI.fillTextValue("consumed");
			%>
      <td>Consumed : </td>
      <td height="26" colspan="2"><strong>
      <input name="consumed" type="text" class="textbox" size="6" maxlength="12" 
	      onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				value="<%=strTemp%>" style="text-align:right" >
      </strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td valign="top">Available : </td>
			<%
				if(vLeaveDetail != null && vLeaveDetail.size() > 0 && !WI.fillTextValue("reset_page").equals("1")){
					strTemp = (String)vLeaveDetail.elementAt(3);
				}else
					strTemp = WI.fillTextValue("available");
				
				if(vLeaveDetail != null && vLeaveDetail.size() > 0)
					strTemp2 = (String)vLeaveDetail.elementAt(4);
				
				strTemp2 = WI.getStrValue(strTemp2);
				if(strTemp2.equals("1"))
					bolIsForSem = true;

				if(bolIsForSem){
					strTemp2 = "readonly";					
				}else{
					strTemp2 = "";
				}
			%>
      <td height="26" valign="top"><strong>
        <input name="available" type="text" class="textbox" size="6" maxlength="12" 
	      onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				value="<%=strTemp%>" style="text-align:right" <%=strTemp2%>>
      </strong></td>
      <td height="26">			
			<%if(bolIsForSem){%>
			<div onClick="showBranch('branch11');swapFolder('folder11')">
        <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder11">
        <b><font color="#0000FF">Per sem detail</font></b></div>
        
				<span class="branch" id="branch11">				
				<table width="50%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="24%"><font size="1">1st sem</font></td>
		<%
				if(vLeaveDetail != null && vLeaveDetail.size() > 0 && !WI.fillTextValue("reset_page").equals("1"))
					strTemp = (String)vLeaveDetail.elementAt(6);
				else
					strTemp = WI.fillTextValue("credit_1");
		%>		
    <td width="76%"><strong>
      <input name="credit_1" type="text" class="textbox" size="6" maxlength="12" 
	      onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				value="<%=strTemp%>" style="text-align:right;font-size:10px" 
			 onBlur="ComputeCredit();" onKeyUp="AllowOnlyFloat('form_','credit_1');ComputeCredit();">
    </strong></td>
  </tr>
  <tr>
    <td><font size="1">2nd sem</font></td>
		<%
				if(vLeaveDetail != null && vLeaveDetail.size() > 0 && !WI.fillTextValue("reset_page").equals("1"))
					strTemp = (String)vLeaveDetail.elementAt(7);
				else
					strTemp = WI.fillTextValue("credit_2");
		%>		
    <td><strong>
      <input name="credit_2" type="text" class="textbox" size="6" maxlength="12" 
	      onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				value="<%=strTemp%>" style="text-align:right;font-size:10px" 
				onBlur="ComputeCredit();" onKeyUp="AllowOnlyFloat('form_','credit_2');ComputeCredit();">
    </strong></td>
  </tr>
  <tr>
    <td><font size="1">Summer</font></td>
		<%
				if(vLeaveDetail != null && vLeaveDetail.size() > 0 && !WI.fillTextValue("reset_page").equals("1"))
					strTemp = (String)vLeaveDetail.elementAt(5);
				else
					strTemp = WI.fillTextValue("credit_0");
		%>
    <td><strong>
      <input name="credit_0" type="text" class="textbox" size="6" maxlength="12" 
	      onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				value="<%=strTemp%>" style="text-align:right;font-size:10px" 
				onBlur="ComputeCredit();" onKeyUp="AllowOnlyFloat('form_','credit_0');ComputeCredit();">
    </strong></td>
  </tr>
</table>
</span>
			<%}%></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_no_credit");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td height="26" colspan="3"><input type="checkbox" name="show_no_credit" value="1" <%=strTemp%>>
        show also leaves with no credits</td>
    </tr>
		
		<%if(iAccessLevel > 1){%>
    <tr> 
      <td height="28" colspan="4" align="center">  
				
				<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2');">
				<font size="1">click to save changes</font>
				
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">					
				<font size="1">click to cancel</font>				</td>
    </tr>
		<%}%>
  </table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="24"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<%
		if(vLeaveDetail != null && vLeaveDetail.size() > 0)
			strTemp = (String)vLeaveDetail.elementAt(0);
		else
			strTemp = WI.fillTextValue("info_index");
	%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
<input type="hidden" name="reset_page">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>