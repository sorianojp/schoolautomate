<%@ page language="java" import="utility.*,payroll.PRFaculty,java.util.Vector, enrollment.SubjectSection" buffer="16kb"%>
<%
///added code for HR/companies.
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Class Rate</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
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
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript">
function ReloadPage() {
	this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.emp_id.focus();
}

function CopyID(strID){
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
function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../../images/box_with_plus.gif";

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

</script>

<body bgcolor="#D2AE72" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strAmPm = null;
	WebInterface WI = new WebInterface(request);

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record-WORKING HOURS MGMT".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record".toUpperCase()),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Encoding of Absences","faculty_schedule.jsp");
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

	
	Vector vRetResult = null;
	payroll.PRMiscDeduction prd = new payroll.PRMiscDeduction(request);
	String strTemp2  = null;
	String[] astrConverAMPM = {"AM","PM"};
	
	Vector vPersonalDetails = new Vector();
	Vector vFacSchedule = null;
	
	Vector vEmpList = null;
	String strEmpID = WI.fillTextValue("emp_id");
	String[] astrConvSem = {"Summer", "1st", "2nd", "3rd"};
	String strSem = WI.fillTextValue("semester");
	String[] astrWeekday = {"S", "M", "T", "W", "TH", "F", "SAT"};
	PRFaculty prFac = new PRFaculty();
	int iSearchResult = 0;
	int i = 0;
	boolean bolIsViewOnly = ( WI.getStrValue(WI.fillTextValue("view_only"),"0").equals("1"));
	String strPageAction = WI.fillTextValue("page_action");
if(strPageAction.length() > 0){
 	vFacSchedule = prFac.operateOnFacultyLoadRate(dbOP, request, Integer.parseInt(strPageAction));
	if(vFacSchedule == null){
		strErrMsg = prFac.getErrMsg();
	}else{
		strErrMsg = "Operation Successful";
	}
}

if (strEmpID.length() > 0) {
	enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vPersonalDetails == null){
		strErrMsg = "No record for employee " + WI.fillTextValue("emp_id");
	}else{
		vFacSchedule = prFac.operateOnFacultyLoadRate(dbOP, request, 4);
		if(vFacSchedule == null)
			strErrMsg = WI.getStrValue(strErrMsg) + WI.getStrValue(prFac.getErrMsg());
		vEmpList = prd.getEmployeesList(dbOP);
		
	}

}//System.out.println(vPersonalDetails);

 	//vRetResult = prFac.operateOnEmpMultipleLogs(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = prFac.getErrMsg();
	else
		iSearchResult = prFac.getSearchCount();
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="form_" action="load_rate_per_class.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      FACULTY CLASS RATE::::</strong></font></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="4" align="right"><%
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
    <tr >
      <td  width="2%" height="25">&nbsp;</td>
      <td width="14%">Employee ID</td>
      <td width="19%"> <input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"></td>
      <td width="65%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a><font size="1">click
        to search &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <!--
		<a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0"></a>
		-->
		<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onClick="javascript:ReloadPage();">
		</font><label id="coa_info" style="position:absolute; width:300px"></label></td>
    </tr>
     <tr >
      <td height="25">&nbsp;</td>
      <td>School Year</td>
      <td height="25" colspan="2">
	  <%
	strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
     <tr >
      <td height="12" colspan="4"><hr size="1"></td>
    </tr>
  </table>
 <% if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Employee Name</td>
      <td width="24%"> &nbsp;<strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
      <td width="19%">Employment Status</td>
      <td width="35%">&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(16),"")%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>College/Office</td>
      <td>&nbsp;<strong>
        <%if(vPersonalDetails.elementAt(13) != null){%>
        <%=(String)vPersonalDetails.elementAt(13)%> ;
        <%}if(vPersonalDetails.elementAt(14) != null){%>
        <%=(String)vPersonalDetails.elementAt(14)%>
        <%}%>
        </strong></td>
      <td>Employment Type</td>
      <td>&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(15),"")%></strong></td>
    </tr>
    <tr >
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
  </table>
	<%if(vFacSchedule != null && vFacSchedule.size() > 0) {%>	
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF99">
      <td height="25" colspan="7" align="center"><strong>::: CURRENT LOAD SCHEDULE :::</strong></td>
    </tr>
  </table>	
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center">
		
		<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="13%" height="25" align="center" class="thinborder"><font size="1"><strong>SECTION
      </strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>SUBJECT CODE </strong></font></td>
      <td width="31%" align="center" class="thinborder"><font size="1"><strong>SUBJECT NAME </strong></font></td>
      <td width="19%" align="center" class="thinborder"><font size="1"><strong>SCHEDULE</strong></font></td>     
	  <td width="9%" align="center" class="thinborder"><font size="1"><strong>REGULAR RATE</strong></font></td>
	   <td width="9%" align="center" class="thinborder"><font size="1"><strong>OVERLOAD RATE</strong></font></td>
	  <%if(!bolIsViewOnly){%>
      	<td width="9%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL <br>	  
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">		
      </strong></font></td>
	  <%}%>
    </tr>
    <%
		
		int iCount = 1;
		for(i = 0 ; i < vFacSchedule.size() ; i +=8, iCount++){%>
    <tr> 		
			<input type="hidden" name="load_index_<%=iCount%>" value="<%=vFacSchedule.elementAt(i)%>">     	
		 	<td class="thinborder">&nbsp;<%=(String)vFacSchedule.elementAt(i + 2)%></td>
		 	<td align="left" class="thinborder">&nbsp;<%=(String)vFacSchedule.elementAt(i + 3)%></td>			
      		<td align="left" class="thinborder">&nbsp;<%=(String)vFacSchedule.elementAt(i + 4)%>&nbsp;</td>
			<td  align="right" height="25" class="thinborder">&nbsp;<%=(String)vFacSchedule.elementAt(i + 5)%>&nbsp;</td>
			
	<%
		strTemp = WI.getStrValue((String)vFacSchedule.elementAt(i+6), "0");
	%>		
	<td align="center" class="thinborder">	
			<input name="class_rate_<%=iCount%>" type="text" size="10" value='<%=strTemp%>'
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','class_rate_<%=iCount%>');style.backgroundColor='white';"
	  onKeyUp="AllowOnlyFloat('form_','class_rate_<%=iCount%>');">
		</td>
		<%
		strTemp = WI.getStrValue((String)vFacSchedule.elementAt(i+7), "0");
		%>
		<td align="center" class="thinborder">	
			<input name="class_ovr_rate_<%=iCount%>" type="text" size="10" value='<%=strTemp%>'
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','class_ovr_rate_<%=iCount%>');style.backgroundColor='white';"
	  onKeyUp="AllowOnlyFloat('form_','class_ovr_rate_<%=iCount%>');">
		</td>
		
      <td align="center" class="thinborder">	  	 
	  	<%
			if(!bolIsViewOnly){
				if(WI.fillTextValue("save_"+iCount).length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
	  	<input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1" <%=strTemp%>></td>
	  <%}%>
    </tr>
    <%}%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table></td>
  </tr>
</table>
	
		
	<%}%>	
<%}//show only if personal detail is found."
%>
  
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
	 <tr> 
      <td height="35" colspan="2" align="center">  
        <% if (iAccessLevel > 1) {%> 	
       				
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(1);">
				<font size="1">click to save entries </font> 				
				<%}%>				
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">				
				<font size="1">click to cancel entries</font></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="view_all">
<input type="hidden" name="page_action">
<input type="hidden" name="PageReloaded">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="view_only" value="<%=WI.fillTextValue("view_only")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>