<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ReloadPage() {
	document.form_.exam_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","dropout_dueto_absence.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"dropout_dueto_absence.jsp");
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

String strSchCode = (String)request.getSession(false).getAttribute("school_code");

//get different grant here.
ReportFeeAssessment RFA = new ReportFeeAssessment();

Vector vRetResult = null;

if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = RFA.getStudentWithAllSameRemark(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RFA.getErrMsg();	
}


%>

<form name="form_" method="post" action="./dropout_dueto_absence.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: DROPPED OUT STUDENT DUE TO ABSENCES ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="18%" height="25">School year /Term</td>
      <td height="25" colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Remark (select multiple) </td>
      <td height="25" colspan="2">
	  <select name="remark1">
        <%=dbOP.loadCombo("remark_index","remark"," from remark_status where is_del = 0 and is_internal=1 and remark_index > 5 order by remark", WI.fillTextValue("remark1"),false)%>
      </select>
	  or 
	  <select name="remark2">
	  	<option value=""></option>
        <%=dbOP.loadCombo("remark_index","remark"," from remark_status where is_del = 0 and is_internal=1 and remark_index > 5 order by remark", WI.fillTextValue("remark2"),false)%>
      </select>
	  or
	  <select name="remark3">
	  	<option value=""></option>
        <%=dbOP.loadCombo("remark_index","remark"," from remark_status where is_del = 0 and is_internal=1 and remark_index > 5 order by remark", WI.fillTextValue("remark3"),false)%>
      </select>
	  or
	  <select name="remark4">
	  	<option value=""></option>
        <%=dbOP.loadCombo("remark_index","remark"," from remark_status where is_del = 0 and is_internal=1 and remark_index > 5 order by remark", WI.fillTextValue("remark4"),false)%>
      </select>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Payment Schedule</td>
      <td height="25" colspan="2"><select name="pmt_sch">
	  <option value="">Final</option>
          <%
//i have to check if i should use the fa_pmt_schedule_extn or fa_pmt_schedule table.
String strSYFrom = request.getParameter("sy_from");
String strSYTo   = null;

if(strSYFrom == null) {
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	strTemp   = (String)request.getSession(false).getAttribute("cur_sem");
}
else {
	strSYFrom = request.getParameter("sy_from");
	strSYTo   = request.getParameter("sy_to");
	strTemp   = request.getParameter("semester");
}
strTemp = dbOP.loadCombo("fa_pmt_schedule_extn.PMT_SCH_INDEX","EXAM_NAME",
		" from fa_pmt_schedule_extn  join fa_pmt_schedule on (fa_pmt_schedule_extn.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where EXAM_NAME NOT LIKE 'FINAL%' AND fa_pmt_schedule_extn.is_del=0 and fa_pmt_schedule_extn.is_valid=1 and sy_from="+strSYFrom+
		" and sy_to="+strSYTo+" and semester="+strTemp+
		 " order by fa_pmt_schedule_extn.EXAM_PERIOD_ORDER asc", request.getParameter("pmt_sch"), false);
//System.out.println("Printing : "+(String)vStudInfo.elementAt(8)+","+(String)vStudInfo.elementAt(9)+","+(String)vStudInfo.elementAt(5));
if(strTemp.length() ==0)
	strTemp = dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where EXAM_NAME NOT LIKE 'FINAL%' and is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc",
		request.getParameter("pmt_sch"), false);
%>
          <%=strTemp%> </select>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <input type="image" src="../../../../images/refresh.gif" onClick="ReloadPage();"></td>
    </tr>
    <tr> 
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td width="31%" class="thinborderBOTTOM">&nbsp; <%if(vRetResult != null) {%> <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> 
        <font size="1">click to print</font> <%}%> </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {
String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"};%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td colspan="2"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="top"><div align="center"><strong>DROPPED OUT STUDENT LIST DUE TO ABSENSES AS OF : <%=WI.fillTextValue("exam_name")%><br>
		  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
          </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="42%" height="24">&nbsp;</td>
      <td height="24" align="right">Date and time printed : &nbsp;<%=WI.getTodaysDateTime()%> &nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr align="center" style="font-weight:bold"> 
      <td width="15%" height="24" style="font-size:9px;" align="left" class="thinborder">Student ID </td>
      <td width="20%" style="font-size:9px;" class="thinborder">Student Name </td>
      <td width="10%" style="font-size:9px;" class="thinborder">Course Code </td>
      <td width="10%" style="font-size:9px;" class="thinborder">Year Level </td>
      <td width="30%" style="font-size:9px;" class="thinborder">Address</td>
      <td width="15%" style="font-size:9px;" class="thinborder">OS Balance </td>
    </tr>
	<%
	for(int i = 0; i < vRetResult.size(); i += 7){
	%>
    <tr> 
      <td height="24" class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 6)%></td>
    </tr>
	<%}%>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="69%" height="24"><font size="1">Printed by : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></font></td>
      <td width="12%">&nbsp;</td>
      <td width="19%">&nbsp;</td>
    </tr>
  </table>
<%}//////////////////// end of report ////////////////////%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="exam_name" value="<%=WI.fillTextValue("exam_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
