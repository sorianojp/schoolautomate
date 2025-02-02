<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function ShowDetailPerSection(strSection) {
	var pgURL = "./exam_permit_report_summary_per_section.jsp?section_ref="+strSection+
		"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
		"&pmt_schedule="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
	var win=window.open(pgURL,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-EXAM PERMIT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}




//add security here.
	try
	{
		dbOP = new DBOperation();
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

boolean bolIsBasic = false;
String strExamName = null;
String strExamPeriod = null;
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");
strExamPeriod      = WI.fillTextValue("pmt_schedule");

Vector vRetResult  = null;//get subject schedule information.
if(WI.fillTextValue("show_result").length() > 0) {
	enrollment.ReportEnrollment RE = new enrollment.ReportEnrollment();
	vRetResult = RE.examPermitDetail(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RE.getErrMsg();
}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./exam_permit_report_summary.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ADMISSION SLIP STATUS ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:16px; font-weight:bold; color:#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="13%" height="25">SY/TERM</td>
      <td height="25" colspan="2"> <%
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
        </select> &nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td height="25">Exam Period</td>
      <td width="14%" height="25"><select name="pmt_schedule">
        <%if(bolIsBasic){%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}else{%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}%>
      </select></td>
      <td width="71%"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Subject</td>
      <td height="25" colspan="2">
		<select name="sub_index" onChange="document.form_.show_result.value=''; document.form_.submit()">
			<option value=""></option>
        	<%=dbOP.loadCombo("distinct subject.sub_index","sub_code, sub_name"," from e_sub_section join subject on (subject.sub_index = e_sub_section.sub_index) "+
							" where e_sub_section.is_valid = 1 and e_sub_section.offering_sy_from = "+strSYFrom+" and e_sub_section.offering_sem = "+
							strSemester+" and subject.is_del = 0 order by sub_code", WI.fillTextValue("sub_index"), false)%>
      	</select>	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Section</td>
      <td height="25" colspan="2">
<%if(WI.fillTextValue("sub_index").length() > 0) {%>
		<select name="section_i">
 			<option value=""></option>
       	<%=dbOP.loadCombo("e_sub_section.sub_sec_index","section"," from e_sub_section where e_sub_section.is_valid = 1 and e_sub_section.offering_sy_from = "+strSYFrom+" and e_sub_section.offering_sem = "+
							strSemester+" and sub_index = "+WI.fillTextValue("sub_index")+" order by section", WI.fillTextValue("section_i"), false)%>
      	</select>	  
<%}%>	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Exam Date </td>
      <td height="25" colspan="2" style="font-size:9px;">
<%
strTemp = WI.fillTextValue("exam_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="exam_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.exam_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>

<!--<input type="checkbox" name="as_of" value="checked" <%=WI.fillTextValue("as_of")%>> As Of Date?-->
&nbsp;&nbsp;&nbsp;
Time: 


<%
Vector vTime = new Vector();
vTime.addElement("7");vTime.addElement("7 AM");
vTime.addElement("7.25");vTime.addElement("7:15 AM");
vTime.addElement("7.5");vTime.addElement("7:30 AM");
vTime.addElement("7.75");vTime.addElement("7:45 AM");
vTime.addElement("8");vTime.addElement("8 AM");
vTime.addElement("8.25");vTime.addElement("8:15 AM");
vTime.addElement("8.5");vTime.addElement("8:30 AM");
vTime.addElement("8.75");vTime.addElement("8:45 AM");
vTime.addElement("9");vTime.addElement("9 AM");
vTime.addElement("9.25");vTime.addElement("9:15 AM");
vTime.addElement("9.5");vTime.addElement("9:30 AM");
vTime.addElement("9.75");vTime.addElement("9:45 AM");
vTime.addElement("10");vTime.addElement("10 AM");
vTime.addElement("10.25");vTime.addElement("10:15 AM");
vTime.addElement("10.5");vTime.addElement("10:30 AM");
vTime.addElement("10.75");vTime.addElement("10:45 AM");
vTime.addElement("11");vTime.addElement("11 AM");
vTime.addElement("11.25");vTime.addElement("11:15 AM");
vTime.addElement("11.5");vTime.addElement("11:30 AM");
vTime.addElement("11.75");vTime.addElement("11:45 AM");
vTime.addElement("12");vTime.addElement("12 PM");
vTime.addElement("12.25");vTime.addElement("12:15 PM");
vTime.addElement("12.5");vTime.addElement("12:30 PM");
vTime.addElement("12.75");vTime.addElement("12:45 PM");
vTime.addElement("13");vTime.addElement("1 PM");
vTime.addElement("13.25");vTime.addElement("1:15 PM");
vTime.addElement("13.5");vTime.addElement("1:30 PM");
vTime.addElement("13.75");vTime.addElement("1:45 PM");
vTime.addElement("14");vTime.addElement("2 PM");
vTime.addElement("14.25");vTime.addElement("2:15 PM");
vTime.addElement("14.5");vTime.addElement("2:30 PM");
vTime.addElement("14.75");vTime.addElement("2:45 PM");
vTime.addElement("15");vTime.addElement("3 PM");
vTime.addElement("15.25");vTime.addElement("3:15 PM");
vTime.addElement("15.5");vTime.addElement("3:30 PM");
vTime.addElement("15.75");vTime.addElement("3:45 PM");
vTime.addElement("16");vTime.addElement("4 PM");
vTime.addElement("16.25");vTime.addElement("4:15 PM");
vTime.addElement("16.5");vTime.addElement("4:30 PM");
vTime.addElement("16.75");vTime.addElement("4:45 PM");
vTime.addElement("17");vTime.addElement("5 PM");
vTime.addElement("17.25");vTime.addElement("5:15 PM");
vTime.addElement("17.5");vTime.addElement("5:30 PM");
vTime.addElement("17.75");vTime.addElement("5:45 PM");
vTime.addElement("18");vTime.addElement("6 PM");
vTime.addElement("18.25");vTime.addElement("6:15 PM");
vTime.addElement("18.5");vTime.addElement("6:30 PM");
vTime.addElement("18.75");vTime.addElement("6:45 PM");
vTime.addElement("19");vTime.addElement("7 PM");
vTime.addElement("19.25");vTime.addElement("7:15 PM");
vTime.addElement("19.5");vTime.addElement("7:30 PM");
vTime.addElement("19.75");vTime.addElement("7:45 PM");
vTime.addElement("20");vTime.addElement("8 PM");
%>
	  <select name="exam_time">
		<option value=""></option>
<%
strTemp = WI.fillTextValue("exam_time");
for(int i = 0; i < vTime.size(); i += 2) {
	if(strTemp.equals(vTime.elementAt(i))) 
		strErrMsg = "selected";
	else	
		strErrMsg = "";
%>	<option value="<%=vTime.elementAt(i)%>" <%=strErrMsg%>><%=vTime.elementAt(i + 1)%></option>
<%}%>
	  </select>


</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> 
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22" bgcolor="#CCCCCC" align="center" class="thinborderNONE" style="font-weight:bold">SUMMARY OF ADMISSION SLIP</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center"> 
      <td width="5%" height="22" class="thinborder">Count</td>
      <td width="15%" class="thinborder">Subject Code</td>
      <td width="25%" class="thinborder">Subject Name</td>
      <td width="10%" class="thinborder">Section</td>
      <td width="9%" class="thinborder">Class Size</td>
      <td width="9%" class="thinborder">#With Admission Slip</td>
      <td width="9%" class="thinborder">#With Temp Permit</td>
      <td width="9%" class="thinborder">Total Examinee</td>
      <td width="9%" class="thinborder">No Permit</td>
    </tr>
<%int iCount = 0; 
for(int i = 0; i < vRetResult.size(); i += 9){%>
    <tr onDblClick="ShowDetailPerSection('<%=vRetResult.elementAt(i)%>')">
      <td height="22" class="thinborder"><%=++iCount%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="show_result">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>