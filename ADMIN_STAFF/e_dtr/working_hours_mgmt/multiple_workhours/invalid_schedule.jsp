<%@ page language="java" import="utility.*,eDTR.ReportMultipleWH, java.util.Vector" buffer="16kb"%>
<%
///added code for HR/companies.
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Scheduling</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage() {
	this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.remove_data.value = "";
	this.SubmitOnce('form_');
}

function PageAction() {
	document.form_.remove_data.value = 1;
	document.form_.delete_.disabled = true;
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record-WORKING HOURS MGMT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("eDaily Time Record"),"0"));
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
								"Admin/staff-Payroll-DTR-Encoding of Absences","invalid_schedule.jsp");
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
 	String strTemp2  = null;
	String[] astrConverAMPM = {"AM","PM"};
	String[] astrWeekday = {"S", "M", "T", "W", "TH", "f", "SAT"};
	
	Vector vPersonalDetails = new Vector();
	Vector vFacSchedule = null;
	
	Vector vEmpList = null;
	String strEmpID = WI.fillTextValue("emp_id");
	String[] astrConvSem = {"Summer", "1st", "2nd", "3rd"};
	String strSem = WI.fillTextValue("semester");
	ReportMultipleWH mWHour = new ReportMultipleWH();
	int iSearchResult = 0;
	int i = 0;
	boolean bolIsEdited = WI.fillTextValue("is_edited").equals("1");

	if(WI.fillTextValue("remove_data").length() > 0){
		
	}	
 
 	enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vPersonalDetails == null){
		strErrMsg = "No record for employee " + WI.fillTextValue("emp_id");
	}
 
 	vRetResult = mWHour.getInvalidScheduleForFaculty(dbOP, request, WI.fillTextValue("emp_index"), bolIsEdited);
	if(vRetResult == null)
		strErrMsg = mWHour.getErrMsg();
	else
		iSearchResult = mWHour.getSearchCount();
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="form_" action="./invalid_schedule.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      FACULTY WORKING HOURS ::::</strong></font></td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td>&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
  </tr>
</table>
  <% if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="27">&nbsp;</td>
      <td>Employee Name</td>
      <td colspan="3">&nbsp;<strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Employee ID</td>
      <td width="31%">&nbsp;<strong><%=WI.fillTextValue("emp_id")%> </strong></td>
      <td width="21%">Employment Status</td>
      <td width="26%">&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(16),"")%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Employment Type</td>
      <td>&nbsp;<strong><%=WI.getStrValue((String)vPersonalDetails.elementAt(15),"")%></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td>College/Office</td>
      <td colspan="3">&nbsp;<strong>
      <%if(vPersonalDetails.elementAt(13) != null){%>
      <%=(String)vPersonalDetails.elementAt(13)%> ;
      <%}if(vPersonalDetails.elementAt(14) != null){%>
      <%=(String)vPersonalDetails.elementAt(14)%>
      <%}%>
      </strong></td>
    </tr>
    <tr >
      <td height="12" colspan="5"></td>
    </tr>
  </table>
<%}//show only if personal detail is found."
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
		<%
			if(WI.fillTextValue("show_only_valid").length() > 0)
				strTemp = "checked";
			else
				strTemp = "";
		%>
    <td>&nbsp;<input type="checkbox" name="show_only_valid" value="1" <%=strTemp%> onClick="javascript:ReloadPage();" id="show_valid_">
    <label for="show_valid_">show only dates from today and onwards</label></td>
  </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
    <% 
	int iPageCount = iSearchResult/mWHour.defSearchSize;		
	if(iSearchResult % mWHour.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="right"><font size="2">Jump To page:
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
    </font></td>
  </tr>
</table>
<%}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  
  <tr>
    <td align="center">
		<table  bgcolor="#FFFFFF" width="85%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
			<%
				if(WI.fillTextValue("is_edited").equals("1"))
					strTemp = "LIST OF CURRENT WORKING HOURS WITH EDITED LOAD SCHEDULE FOR ID :";
				else
					strTemp = "LIST OF INVALID WORKING HOURS FOR ID :";
			%>
      <td height="25" colspan="4" align="center" bgcolor="#B9B292" class="thinborder"><%=strTemp%> <%=WI.fillTextValue("emp_id")%></td>
    </tr>
    <tr> 
      <td width="16%" height="26" align="center" class="thinborder"><strong>LOGIN  
      DATE </strong></td>
      <td width="40%" align="center" class="thinborder"><strong>TIME</strong></td>
	    <td width="20%" align="center" class="thinborder"><strong>ROOM NO </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>CONTROL</strong></td>
      </tr>
<%
int iCount = 1;
 for(i = 0; i < vRetResult.size(); i += 25, iCount++){%>
   <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 2))%>&nbsp;<%=astrWeekday[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 17), "0"))]%></td>
			<%
			strTemp = (String)vRetResult.elementAt(i + 3);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+4),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+5))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 6);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+7),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+8))];
			
			strTemp2 = (String)vRetResult.elementAt(i + 9);
			if(strTemp2 != null)
				strTemp2 = "**";
			else
				strTemp2 = "";
			%>
      <td class="thinborder">&nbsp;<%=strTemp%> <font color="#FF0000"><%=strTemp2%></font></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 16),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 18))%></td>
      <% //if (!bolMyHome) {%> 
<%//}%> 
    </tr>
<%}%>
	<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>	</td>
  </tr>
  <tr>
    <td>Note: ** - Already having an actual time in. Schedule will not be re created. </td>
  </tr>
</table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>



<input type="hidden" name="view_all">
<input type="hidden" name="remove_data">
<input type="hidden" name="PageReloaded">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
	<input type="hidden" name="emp_index" value="<%=WI.fillTextValue("emp_index")%>">
	<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
	<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">	
	<input type="hidden" name="term_type" value="<%=WI.fillTextValue("term_type")%>">	
	<input type="hidden" name="is_edited" value="<%=WI.fillTextValue("is_edited")%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>