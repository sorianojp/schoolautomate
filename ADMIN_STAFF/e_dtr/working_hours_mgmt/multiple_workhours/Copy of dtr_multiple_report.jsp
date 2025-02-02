<%@ page language="java" import="utility.*,java.util.Vector,eDTR.MultipleWorkingHour" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style type="text/css">
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
 	function ViewRecords(){
		document.form_.print_page.value = "";
		document.form_.page_action.value = 4;
		document.form_.prepareToEdit.value = 0;
		document.form_.show_list.value = 1;
	}  
 
	function focusID() {
		document.form_.emp_id.focus();
	}
	
	function OpenSearch() {
		var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

	function PrintPage(){
		document.form_.print_page.value="1";
		this.SubmitOnce('form_');
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
 
</script>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
				
	if (WI.fillTextValue("print_page").equals("1")) {%> 
	<jsp:forward page="./dtr_multiple_report_print.jsp" />
<%  return;}

//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","dtr_multiple_report.jsp");

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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(),
														"dtr_multiple_report.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

///// exclusive for testers only.. 
String strUserID = (String)request.getSession(false).getAttribute("userId");
//////////////////



MultipleWorkingHour TInTOut = new MultipleWorkingHour();
Vector vRetResult = null;
  String[] astrConverAMPM = {"AM","PM"};

	vRetResult = TInTOut.getEmpLogsDateRange(dbOP, request);
	
	if (vRetResult == null || vRetResult.size() == 0){
		strErrMsg  = TInTOut.getErrMsg();
	}
%>

<form action="./dtr_multiple_report.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        DTR OPERATIONS - EDIT TIME-IN TIME-OUT PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp; <strong><a href="./working_hour_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23">Employee ID </td>
      <td width="19%" height="23">
        <input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"
	   onKeyUp="AjaxMapName(1);">
      &nbsp; </td>
      <td width="65%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Date </td>
      <td height="20" colspan="2">
<%
strTemp = WI.fillTextValue("login_date");
//if(strTemp.length() == 0)
//	strTemp = WI.getTodaysDate(1);
%>	  <input name="login_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.login_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
<!--
		&nbsp;&nbsp;<a href="javascript:ClearDate();"><img src="../../../../images/clear.gif" width="55" height="19" border="0" ></a><font size="1">
        clear the date</font> -->to 
<%
strTemp = WI.fillTextValue("login_date_to");
//if(strTemp.length() == 0)
//	strTemp = WI.getTodaysDate(1);
%>				
<input name="login_date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<a href="javascript:show_calendar('form_.login_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="4%" height="35">&nbsp;</td>
      <td width="12%" height="35">&nbsp;</td>
      <td colspan="2"><input name="image" type="image" onClick="ViewRecords()"  src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
    <tr>
      <td valign="top">&nbsp;</td>
      <td height="25" colspan="3"></td>
    </tr>
  </table>
  <%
	if ((vRetResult != null) && (vRetResult.size()>0)) { %>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="right"><a href="javascript:PrintPage()"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click to print</font></td>
  </tr>
</table>

 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
   <tr>
     <td height="25" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF 
       TIME RECORDED FOR ID : <strong><%=WI.fillTextValue("emp_id").toUpperCase()%></strong></strong></td>
   </tr>
   <tr>
     <td width="28%" height="26" align="center" class="thinborder"><strong>Scheduled Time </strong></td>
     <td width="27%" align="center" class="thinborder"><strong>Actual Time In </strong></td>
     <td width="15%" align="center" class="thinborder"><strong>TARDINESS</strong></td>
     <td width="15%" align="center" class="thinborder"><strong>UNDERTIME</strong></td>
     <td width="15%" align="center" class="thinborder"><strong>HOURS WORKED </strong></td>
   </tr>
   <% int iCount = 1;
	 	String strLoginDate = null;
		String strCurrentDate = null;
 		for(int i = 0; i < vRetResult.size(); i += 18, iCount++){
	 %>
	 <%
	 	if(i == 0 || !((String)vRetResult.elementAt(i+2)).equals(strLoginDate)){
			strLoginDate = (String)vRetResult.elementAt(i+2);
	 %>
   <tr>
     <td height="25" colspan="5" class="thinborder">&nbsp;<%=strLoginDate%></td>
    </tr>
	 <%}%>
   <tr>
	 	<input type="hidden" name="info_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<input type="hidden" name="sched_login_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+13)%>">
		<input type="hidden" name="sched_logout_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+14)%>">
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
			%>
     <td height="19" align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
		 <input type="hidden"	 name="schedule_<%=iCount%>" value="<%=strTemp%>">
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11));			
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12), strTemp + " - ","", strTemp);
		 %>
     <td align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+16));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <%
		 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+17));			
		 %>		 
     <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
   </tr>
   
   <%}%>
	  <input type="hidden" name="emp_count" value="<%=iCount%>">
 </table>
   <%} // end else (vRetResult == null)%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>


 <input type="hidden" name="page_action" value="">
 <input type="hidden" name="print_page">
 
 <input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
