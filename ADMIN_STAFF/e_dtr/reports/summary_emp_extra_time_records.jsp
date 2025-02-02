<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employees With Extra Time</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
		
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.dtr_op.print_page.value = "";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	this.SubmitOnce("dtr_op");
}

function ViewRecordDetail(index){
	document.dtr_op.print_page.value = "";

	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.SummaryDetail.value="1";
	document.dtr_op.emp_id.value=index;
	document.dtr_op.emp_type.value ="";
	document.dtr_op.c_index.value ="";
	document.dtr_op.d_index.value ="";
	this.SubmitOnce("dtr_op");
}
function ViewRecords()
{
	document.dtr_op.print_page.value = "";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	this.SubmitOnce("dtr_op");
}
function PrintPage()
{
	document.dtr_op.print_page.value = "1";
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.emp_id.value;
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
	document.dtr_op.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").compareTo("1") ==0)
{ %>
	<jsp:forward page="./extra_time_records_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	boolean bolHasTeam = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS - Summary of Emp with Extra Time Record",
								"summary_emp_extra_time_records.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"summary_emp_extra_time_records.jsp");	
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
String[] astrWeekday = {"","S","M","T","W","TH","F","SAT"};

ReportEDTR RE = new ReportEDTR(request);
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
if (WI.fillTextValue("viewRecords").compareTo("1") == 0) {
	vRetResult = RE.searchExtraTime(dbOP);
	if (vRetResult == null) 
		strErrMsg = RE.getErrMsg();
}
%>
<form action="./summary_emp_extra_time_records.jsp" name="dtr_op" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      EMPLOYEE WITH EXTRA TIME RECORD ::::</strong></font></td>
    </tr>
  <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td><p><strong> Date</strong> &nbsp;&nbsp;&nbsp;&nbsp;:: &nbsp;From: 
          <input name="from_date" type="text"  id="from_date" size="12" readonly="true"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("from_date")%>">
          <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
          : 
          <input name="to_date" type="text"  id="to_date" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("to_date")%>">
          <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</p>
        
      </td>
  </tr>


</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr > 
      <td>&nbsp;</td>
      <td height="25">Employee ID</td>
      <td height="25"><input name="emp_id" type="text"  id="emp_id" size="12" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value="<%=WI.fillTextValue("emp_id")%>" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="24">Extra Time (min)</td>
      <td height="24"> &nbsp;&nbsp; <select name="logSelect">
          <option value="time_in , timein_date">Time In</option>
          <%
strTemp = WI.fillTextValue("logSelect");
if(strTemp.startsWith("time_out")){%>
          <option value="time_out, timeout_date" selected>Time Out</option>
          <%}else{%>
          <option value="time_out, timeout_date">Time Out</option>
          <%}%>
        </select> <select name="extracond">
          <option value="&gt;=">More than or equals</option>
          <%
strTemp = WI.fillTextValue("extracond");
if(strTemp.length() ==0){%>
          <option value="" selected>less than</option>
          <%}else{%>
          <option value="">less than</option>
          <%}%>
        </select> 
        <input name="extra_time" type="text"  size="8" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("extra_time")%>" onKeyUp="AllowOnlyInteger('dtr_op','extra_time')">
        (in minutes)</td>
    </tr>
<%if (((String)request.getSession(false).getAttribute("school_code")).startsWith("AUF")) { %>
    <tr> 
      <td>&nbsp;</td>
      <td height="24">Employee Catg</td>
			<%
				strTemp = WI.fillTextValue("emp_type_catg");
			%>
      <td height="24"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
				for(int i = 0;i < astrCategory.length;i++){
					if(strTemp.equals(Integer.toString(i))) {%>
        <option value="<%=i%>" selected><%=astrCategory[i]%></option>
        <%}else{%>
        <option value="<%=i%>"> <%=astrCategory[i]%></option>
        <%}
							}%>
      </select></td>
    </tr>
<%}%>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="17%" height="24">Employment Type</td>
      <td width="79%" height="24"><strong> 
        <%strTemp2 = WI.fillTextValue("emp_type");%>
        <select name="emp_type">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
					WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
					" order by EMP_TYPE_NAME asc", strTemp2, false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="25"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
		strTemp = WI.fillTextValue("c_index");
		if (strTemp.length()<1) strTemp="0";
	   if(strTemp.compareTo("0") ==0)
		   strTemp2 = "Offices";
	   else
		   strTemp2 = "Department";
	%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> 
        </select> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25"> <select name="d_index">
          <% if(strTemp.compareTo("") ==0){//only if from non college.%>
          <option value="">All</option>
          <%}else{%>
          <option value="">All</option>
          <%} strTemp3 = WI.fillTextValue("d_index");%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> 
        </select> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Office/Dept filter<br></td>
      <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
     <%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>      </td>
    </tr>
		<%}%>
    <tr>
      <td>&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_weekday");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td height="18" colspan="2"><input type="checkbox" name="show_weekday" value="1" <%=strTemp%>>
        show weekday </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25"><a href="javascript:ViewRecords()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <% 
  	if (vRetResult !=null && vRetResult.size() > 0){ 
  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="80%">&nbsp;</td>
      <td width="20%"><input name="image2" type="image" onClick="PrintPage()" src="../../../images/print.gif" align="right" width="58" height="26"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFE6E6"> 
      <% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
      <td height="25"  colspan="6" align="center" class="thinborder"><strong>LIST OF EMPLOYEE 
      WITH EXTRA TIME (<%=strTemp%>)</strong></td>
    </tr>
    <tr align="center"> 
      <td width="13%" height="25" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="26%" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="13%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="17%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>EXPECTED 
        TIME 
        <%if(WI.fillTextValue("logSelect").startsWith("time_in")){%>
        IN 
        <%}else{%>
        OUT 
        <%}%>
        </strong></font></td>
      <td width="17%" height="25" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">ACTUAL 
        TIME 
        <%if(WI.fillTextValue("logSelect").startsWith("time_in")){%>
        IN 
        <%}else{%>
        OUT 
        <%}%>
        </font></strong></td>
      <td width="14%" height="25" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EXTRA 
        MINUTES</font></strong></td>
    </tr>
    <%  strTemp2 = "";strTemp3 = "";
	for ( int i = 0 ; i< vRetResult.size(); i+=6){ 
	
	strTemp = (String)vRetResult.elementAt(i);
	if (strTemp2.compareTo(strTemp) == 0){
		strTemp = "";
	}else{
		strTemp2 = strTemp;
	}
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	 <% if (strTemp.length() == 0) strTemp = "&nbsp;";
	    else strTemp = (String)vRetResult.elementAt(i+5);%> 
      <td class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
			%>
      <td class="thinborder">&nbsp;<%=strTemp%><%if(WI.fillTextValue("show_weekday").length() > 0){%>
					<%=astrWeekday[eDTR.eDTRUtil.getWeekDay(strTemp)]%>
				<%}%></td>
      <td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+2)),2)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+3)),2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%>&nbsp;</td>
    </tr>
    <%} // end for loop%>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
  <input type=hidden name="viewRecords" value="0">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>