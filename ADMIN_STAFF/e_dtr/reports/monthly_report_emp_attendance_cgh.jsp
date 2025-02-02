<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,java.util.Calendar" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
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
	
	TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	
	TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
-->
</style>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
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


function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.form_.reloadpage.value="1";
	this.SubmitOnce("form_");;
}


function ViewRecords()
{
	document.form_.viewRecords.value="1";
	this.SubmitOnce("form_");;
}
function PrintPage()
{
	document.getElementById("header1").deleteRow(0);
	document.getElementById("header1").deleteRow(0);
	document.getElementById("header2").deleteRow(0);
	document.getElementById("header2").deleteRow(0);
	document.getElementById("header2").deleteRow(0);
	document.getElementById("mainHead").deleteRow(0);
	document.getElementById("footer").deleteRow(0);
//  disabled for now.. 
//	document.getElementById("admin_").deleteRow(16); // remove the row of save button
	
	document.form_.effectivedate.style.border ="0px";
	document.form_.effectivedateto.style.border ="0px";
	document.form_.duration.style.border ="0px";	
	document.form_.vlc.style.border ="0px";	
	
	document.form_.date_icon1.src ="../../../images/blank.gif";	
	document.form_.date_icon2.src ="../../../images/blank.gif";		
	document.getElementById("labelfrm").innerHTML = "";
	document.getElementById("labelto").innerHTML = "";	
	
	window.print();
}

function viewLateDetails(strEmpID)
{
//popup window here. 
	var bolShowOnlyDeduct ;
	if (document.form_.show_only_deduct.checked) bolShowOnlyDeduct = "1";
	else bolShowOnlyDeduct= "";

	var pgLoc = "./summary_emp_late_timein_detail.jsp?show_only_total=&viewRecords=1&window_opener=1&emp_id="+escape(strEmpID)+"&from_date="+escape(document.form_.from_date.value)+
	 "&to_date="+escape(document.form_.to_date.value)+"&show_only_deduct="+bolShowOnlyDeduct;
	var win=window.open(pgLoc,"ShowDetail",'width=550,height=400,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateMonth(){

	if (document.form_.strMonth) {
		if (document.form_.strMonth.selectedIndex !=0) {
			if ( document.getElementById("month_")) 
				document.getElementById("month_").innerHTML = 
					document.form_.strMonth[document.form_.strMonth.selectedIndex].text;
				document.form_.month_label.value = 
					document.form_.strMonth[document.form_.strMonth.selectedIndex].text;
		}else{
			if (document.getElementById("month_")) 
				document.getElementById("month_").innerHTML = "";
			document.form_.month_label.value = "";
			
		}
	}
}

</script>
<body>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

if( request.getParameter("print_page") != null && request.getParameter("print_page").compareTo("1") ==0)
{ %>
	<jsp:forward page="./summary_emp_late_timein_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Ind Monthly Report of Emp Attendance",
								"monthly_report_emp_attendance_cgh.jsp");
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
														"monthly_report_emp_attendance_cgh.jsp");	
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

ReportEDTR RE = new ReportEDTR(request);
enrollment.Authentication authentication = new enrollment.Authentication();
Vector vEmpRecord = authentication.operateOnBasicInfo(dbOP,request,"0");
 hr.HRUpdateTables hrU = new hr.HRUpdateTables(dbOP);

String[] astrMonth={" &nbsp", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
String strYear = WI.fillTextValue("sy_");

     java.util.Calendar calendar = java.util.Calendar.getInstance();
	  
	  try{
	  
		  if ( strYear.length()> 0){
		    if (Integer.parseInt(strYear) >= 2005) 
			  	calendar.set(Calendar.YEAR, Integer.parseInt(strYear));
			else
				strErrMsg = " Invalid year entry";
				
		  }else{
		  	strYear = Integer.toString(calendar.get(Calendar.YEAR));
		  }
	  }
	  catch (NumberFormatException nfe){
	  strErrMsg = " Invalid year entry";
	  }

	if (WI.fillTextValue("viewRecords").equals("1") && 
		WI.fillTextValue("strMonth").length() > 0 &&
		!WI.fillTextValue("strMonth").equals("0") &&
		WI.fillTextValue("sy_").length() == 4){

		vRetResult = RE.getMonthlySummaryCGH(dbOP, request);
		
		if (vRetResult == null || vRetResult.size() == 0){
			strErrMsg = RE.getErrMsg();
		}
	}

%>
<form action="./monthly_report_emp_attendance_cgh.jsp" name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="header1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        MONTHLY EDTR SUMMARY::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" ><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","&nbsp;")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="header2">
    <tr bgcolor="#FFFFFF">
      <td width="3%" height="10"></td>
      <td height="10">Employee ID</td>
      <td width="16%" height="30"><input name="emp_id" type="text"  size="12" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>"  onKeyUp="AjaxMapName(1);"></td>
      <td width="68%"><label id="coa_info"></label></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="24"></td>
      <td width="13%" height="24">Month </td>
      <td height="24" colspan="2"><select name="strMonth" onChange="UpdateMonth()">
	  <% 
	  	for (int i = 0; i <= 12; ++i) {
	  		if (Integer.parseInt(WI.getStrValue(request.getParameter("strMonth"),"0")) == i) {
	  %>
	  	<option value="<%=i%>" selected><%=astrMonth[i]%></option>	  
	  <%}else{%>
	  	<option value="<%=i%>"><%=astrMonth[i]%></option>
	  <%} 
	  } // end for lop%>
	  </select> <input type="hidden" name="month_label"></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="24"></td>
      <td height="24">Year</td>
<%
	strTemp = WI.fillTextValue("sy_");
	if (strTemp.length() == 0) 
		strTemp = strYear;
%>	  
      <td height="24"><input name="sy_" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','sy_')"  value="<%=strTemp%>" size="4" maxlength="4" onKeyUp="AllowOnlyInteger('form_','sy_')"></td>
      <td height="24"><input name="proceed" type="image" onClick="ViewRecords();" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
  <% if (vEmpRecord !=null){  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="mainHead">
    <tr> 
      <td colspan="4"></td>
    </tr>
    <tr>
      <td height="25" colspan="4" align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" align="center"><strong>CHINESE GENERAL HOSPITAL COLLEGE OF NURSING</strong> <br>
      Blumentritt St, Sta. Cruz, Manila <br>
      <br>
      <strong>ATTENDANCE REPORT</strong> </td>
    </tr>
    <tr>
      <td width="10%" height="18">&nbsp;</td>
      <td colspan="3" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;&nbsp;Name : </td>
      <td width="46%">&nbsp;<%=WI.formatName((String)vEmpRecord.elementAt(1),
	  										(String)vEmpRecord.elementAt(2),
											(String)vEmpRecord.elementAt(3),4)%></td>
      <td width="19%" align="right">Date :&nbsp;&nbsp;</td>
      <td width="25%">&nbsp;<%=WI.getTodaysDate(6)%></td>
    </tr>
    <tr>
      <td height="18">&nbsp;&nbsp;Position : </td>
      <td>&nbsp;<%=(String)vEmpRecord.elementAt(15)%></td>
      <td align="right">Employment Status:&nbsp;&nbsp;</td>
      <td>&nbsp;<%=(String)vEmpRecord.elementAt(16)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<% 
	if (vRetResult != null && vRetResult.size() > 0) {
	Vector vLeaveNames = (Vector)vRetResult.elementAt(0);
	Vector vLeaveSummary = (Vector)vRetResult.elementAt(1);
%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td colspan="9"></td>
    </tr>
    <tr>
      <td width="10%" height="18" align="center" class="thinborder">&nbsp;</td>
      <td colspan="3" align="center" class="thinborder">ABSENCES </td>
      <td colspan="3" align="center" class="thinborder">TARDINESS</td>
      <td colspan="2" align="center" class="thinborder">UNDERTIME </td>
    </tr>
    <tr>
      <td height="18" align="center" class="thinborder">MONTH</td>
      <td align="center" class="thinborder">EXCUSED</td>
      <td width="8%" rowspan="2" align="center" class="thinborder">UNEX</td>
      <td width="8%" rowspan="2" align="center" class="thinborder">SUS </td>
      <td width="8%" rowspan="2" align="center" class="thinborder">&lt; 15 min </td>
      <td colspan="2" align="center" class="thinborder">&gt; 15 min </td>
      <td width="8%" rowspan="2" align="center" class="thinborder">&nbsp;Ex </td>
      <td width="8%" rowspan="2" align="center" class="thinborder">&nbsp;Unex</td>
    </tr>
    <tr>
      <td height="18" align="center" class="thinborder">&nbsp;</td>
      <td rowspan="3" align="center" class="thinborder">
	  <!-- leave records...  --> 

	  
   	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
<% 
	for (int k = 0; k < vLeaveNames.size() ; k++){
	strTemp = "class=\"thinBorder\"";
	if (k== 0)
		strTemp = "class=\"thinBorderBottom\"";
%>
          <td  height="18" align="center" <%=strTemp%>><%=(String)vLeaveNames.elementAt(k)%></td>
<%}%> 
          </tr>
        <tr>
<% 
	for (int k = 0; k < vLeaveNames.size() ; k++){
	strTemp = "class=\"thinBorder\"";
	if (k== 0)
		strTemp = "class=\"thinBorderBottom\"";
%>		
          <td  <%=strTemp%>  height="18">&nbsp; </td>
          <%}%>
          </tr>
        <tr>
<% 
	for (int k = 0; k < vLeaveSummary.size() ; k++){
	strTemp = "class=\"thinBorderLeft\"";
	if (k== 0)
		strTemp = "";
%>			
          <td  height="18" align="center"  <%=strTemp%>><%=(String)vLeaveSummary.elementAt(k)%></td>
<%}%>
        </tr>
      </table>
      <!-- end of leave records page -->	  </td>
      <td width="8%" align="center" class="thinborder">&nbsp;Ex</td>
      <td width="8%" align="center" class="thinborder">&nbsp;Unex</td>
    </tr>
    <tr>
      <td height="18" align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" align="center" class="thinborder">&nbsp;<label id="month_"></label></td>
      <td width="8%" align="center" class="thinborder"><%=(String)vRetResult.elementAt(2)%></td>
      <td width="8%" align="center" class="thinborder"><%=(String)vRetResult.elementAt(3)%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(4)%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(5)%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(6)%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(7)%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(8)%></td>
    </tr>
    <tr>
      <td height="18" align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"></td>
    </tr>
    <tr>
      <td width="10%" height="18" colspan="2" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" align="center">Certified by: </td>
      <td align="center">Noted by: </td>
    </tr>
    <tr>
      <td height="18" align="center"><br>
      <br>
      EVELYNDA BA&Ntilde;ARES<br>
      Personnel / Payroll Officer </td>
      <td height="18" align="center"><br>
      <br>
      <br>
      Immediate Supervisor / Coordinator </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="admin_">
    <tr>
      <td colspan="5"></td>
    </tr>
    <tr>
      <td height="18" colspan="5" align="center"><hr size="1"></td>
    </tr>
    <tr>
      <td height="18" colspan="5" align="center">ADMINISTRATIVE ACTION </td>
    </tr>
    <tr>
      <td width="9%" height="18" align="center">&nbsp;</td>
      <td width="3%" height="18"><input type="radio" name="select1" value="3"></td>
      <td colspan="3">Commendation</td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td width="7%">&nbsp;</td>
      <td width="3%"><label>
        <input name="radiobutton" type="radio" value="radiobutton">
      </label></td>
      <td width="78%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="27%">Vacation Leave Credit :            </td>
          <td width="8%" align="center" class="thinborderBottom"><input name="vlc" type="text" class="textbox" size="2" maxlength="2"></td>
          <td width="65%">&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input name="radiobutton" type="radio" value="radiobutton"></td>
      <td>Bulletin Board Notice </td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18"><input type="radio" name="select1" value="3"></td>
      <td colspan="3">Warning </td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input name="radiobutton" type="radio" value="radiobutton"></td>
      <td>Written Reprimand </td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input name="radiobutton" type="radio" value="radiobutton"></td>
      <td>Verbal Reprimand </td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18"><input type="radio" name="select1" value="3"></td>
      <td colspan="3">Suspension</td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input name="radiobutton" type="radio" value="radiobutton"></td>
      <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="13%">Duration : </td>
            <td width="8%" align="center" class="thinborderBottom">
				<input name="duration" type="text" class="textbox" size="2" maxlength="2">		    </td>
            <td width="79%">&nbsp;</td>
          </tr>
        </table></td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input name="radiobutton" type="radio" value="radiobutton"></td>
      <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="18%">Inclusive Dates: </td>
          <td width="51%" class="thinborderBottom"><label id="labelfrm">From </label> &nbsp;
            <input name="effectivedate" size="10" type="text" id="date1"
						class="textbox" maxlength="10" 
						onKeyUp="AllowOnlyIntegerExtn('form_','effectivedate','/')">
						
            <img src="../../../images/calendar_new.gif" name="date_icon1" width="20" height="16" border="0" id="date_icon1"> <label id="labelto">  To </label>
            <input name="effectivedateto" type="text" class="textbox" id="date2"
	  		size="10" maxlength="10" onKeyUp="AllowOnlyIntegerExtn('form_','effectivedateto','/')">
            <img src="../../../images/calendar_new.gif" name="date_icon2" width="20" height="16" border="0" id="date_icon2"></td>
          <td width="31%">&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18"><input type="radio" name="select1" value="3"></td>
      <td colspan="3">Dismissal</td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">Date of Effectivity : </td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18"><input type="radio" name="select1" value="4"></td>
      <td colspan="3">Remarks: __________________________________________________________________ </td>
    </tr>
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td colspan="3">&nbsp;<input type="hidden" name="is_saved"  value="<%=strTemp%>"></td>
    </tr>
<!--
    <tr>
      <td height="18" colspan="5" align="center"><img src="../../../images/save.gif" width="48" height="28" name="hide_save">
      </td>
	</tr>
-->
    <tr>
      <td height="18" align="center">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"></td>
    </tr>
    <tr>
      <td height="18" colspan="2" align="center"><hr size="1"></td>
    </tr>
    <tr>
      <td height="18" colspan="2" align="center">Recommended by </td>
    </tr>
    <tr>
      <td width="4%" height="18" align="center"><br>
        <br>
        <strong>EDGAR S. CHUNG, MSPH</strong><br>
      Asst. For Administrative Affairs </td>
      <td width="5%" align="center"><br>
      <br>
      <strong>IRIS CHUA SO, RN, MAN </strong><br>
      Dean</td>
    </tr>
    <tr>
      <td height="18" colspan="2" align="center"><br>
        Approved by : </td>
    </tr>
    <tr>
      <td height="18" align="center"><br>
        <br>
        <strong>DR. TAN KING KING </strong><br>
      Executive Director<br>
      College of Nursing<br>
      <em>(For Suspension)</em> </td>
      <td height="18" align="center"><br>
        <br>
        <strong>DR. JAMES G. DY</strong><br>
      President and Honorary Chairman<br>
      Philippine Chinese Charitable Association, Inc.<br>
      (For Dismissal) </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"></td>
    </tr>
    <tr>
      <td height="18" colspan="2" align="center"><hr size="1"></td>
    </tr>
    <tr>
      <td width="4%" height="18" align="center"><br>
 Recieved by : ____<u><%=WI.formatName((String)vEmpRecord.elementAt(1),
	  										(String)vEmpRecord.elementAt(2),
											(String)vEmpRecord.elementAt(3),4)%></u>____</td>
      <td width="5%" height="18" align="center"><p><br>
        Date Received : ________________
      </p>
      </td>
    </tr>
  </table>
  <%}%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="footer">
    <tr valign="bottom"> 
      <td height="46" align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif"  border="0"></a><font size="1">click to print list</font> </td>
    </tr>
  </table>
  <%}%>
  <input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
  <input type=hidden name="viewRecords" value="0">
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_only_total" value="1">  
</form>
<script language="javascript">
<!--
UpdateMonth();
-->
</script>
</body>
</html>
<% dbOP.cleanUP(); %>