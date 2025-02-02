<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
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
function encodeExpectedCollection() {
	var pgLoc = "./major_exam_summary_new2_expected_encode.jsp";
	var win=window.open(pgLoc,"Encode Window",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","major_exam_summary_new2.jsp");
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
														"major_exam_summary_new2.jsp");
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

String strSchCode = (String)request.getSession(false).getAttribute("school_code");

//get different grant here.
FeeExtraction feeEx = new FeeExtraction();

Vector vRetResult = null;

if(WI.fillTextValue("pmt_schedule").length() > 0) {
	vRetResult = feeEx.getMajorExamPmtSummaryNew2(dbOP, request);
	if(vRetResult == null)
		strErrMsg = feeEx.getErrMsg();	
}
//System.out.println(vRetResult);

%>

<form name="form_" method="post" action="./major_exam_summary_new2.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MAJOR EXAM COLLECTION REPORT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="13%" height="25">SY-Term</td>
      <td height="25"> <%
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
      <td height="25"><a href="javascript:encodeExpectedCollection();">Encode Expected Collection</a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Exam Period </td>
      <td height="25" colspan="2"><select name="pmt_schedule" onChange="ReloadPage();">
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
		" where fa_pmt_schedule_extn.is_del=0 and fa_pmt_schedule_extn.is_valid=1 and sy_from="+strSYFrom+
		" and sy_to="+strSYTo+" and semester="+strTemp+
		 " order by fa_pmt_schedule_extn.EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false);
//System.out.println("Printing : "+(String)vStudInfo.elementAt(8)+","+(String)vStudInfo.elementAt(9)+","+(String)vStudInfo.elementAt(5));
if(strTemp.length() ==0)
	strTemp = dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc",
		request.getParameter("pmt_schedule"), false);
%>
          <%=strTemp%> </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Payment As of </td>
      <td height="25" colspan="2">
<%
strTemp = WI.fillTextValue("as_of");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
	  <input name="as_of" type= "text"  class="textbox" 
		   onFocus="style.backgroundColor='#D3EBFF'" 
		   onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','as_of','/')" 
		   onKeyUp="AllowOnlyIntegerExtn('form_','as_of','/')" value = "<%=strTemp%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('form_.as_of');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" colspan="2" class="thinborderBOTTOM" style="font-size:9px;"> 
        <font color="#0000FF"><strong>Note: This report depends on AR Student and Scholarship Reports.
        </strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <input type="image" src="../../../images/refresh.gif"> </td>
      <td width="31%" class="thinborderBOTTOM">&nbsp; <%if(vRetResult != null) {%> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print</font> <%}%> </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {
Vector vSummary = (Vector)vRetResult.remove(0);

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
      <td height="20" colspan="2" valign="top"><div align="center"><strong>
<%
strTemp = WI.fillTextValue("exam_name").toUpperCase();
if(strTemp.indexOf("EXAM") == -1)
	strTemp = strTemp + " EXAM";
%>
	  PROGRESS REPORT ON <%=strTemp%><br>
		  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%><br>
		  As of <%=WI.formatDate(WI.fillTextValue("as_of"),6) %>
          </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="50%">&nbsp;</td>
      <td width="50%" align="right" style="font-size:11px;">Date and time printed: <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="20%" height="22" class="thinborderTOPBOTTOM" align="center"><strong><font size="1">DEPT/COURSE</font></strong></td>
      <td width="16%" class="thinborderTOPBOTTOM" align="right"><strong><font size="1">EXPECTED</font></strong></td>
      <td width="16%" class="thinborderTOPBOTTOM" align="right"><strong><font size="1">COLLECTED</font></strong></td>
      <td width="16%" class="thinborderTOPBOTTOM" align="right"><strong><font size="1">UNCOLLECTED</font></strong></td>
      <td width="16%" class="thinborderTOPBOTTOM" align="right"><strong><font size="1">PN</font></strong></td>
      <td width="16%" class="thinborderTOPBOTTOM" align="right"><strong><font size="1">UNCLAIMED PERMITS</font></strong></td>
    </tr>
    <%for(int i = 0; i < vRetResult.size(); i += 7){%>
    <tr> 
      <td height="22" class="thinborderNONE"><%=(String)vRetResult.elementAt(i)%></td>
      <td align="right" class="thinborderNONE"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td align="right" class="thinborderNONE"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="right" class="thinborderNONE"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td align="right" class="thinborderNONE"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td align="right" class="thinborderNONE"><%=(String)vRetResult.elementAt(i + 6)%></td>
    </tr>
	<%}%>
    <tr> 
      <td height="22"><strong>T O T A L</strong></td>
      <td class="thinborderTOP" align="right"><%=(String)vSummary.elementAt(0)%><br><img src="doubleline.jpg" width="100"></td>
      <td class="thinborderTOP" align="right"><%=(String)vSummary.elementAt(1)%><br><img src="doubleline.jpg" width="100"></td>
      <td class="thinborderTOP" align="right"><%=(String)vSummary.elementAt(2)%><br><img src="doubleline.jpg" width="100"></td>
      <td class="thinborderTOP" align="right"><%=(String)vSummary.elementAt(3)%><br><img src="doubleline.jpg" width="100"></td>
      <td class="thinborderTOP" align="right"><%=(String)vSummary.elementAt(4)%><br><img src="doubleline.jpg" width="100"></td>
    </tr>
    <tr> 
      <td height="24"></td>
      <td class="thinborderNONE"></td>
      <td class="thinborderNONE" align="right"><u><%=(String)vSummary.elementAt(5)%>%</u></td>
      <td class="thinborderNONE" align="right"><u><%=(String)vSummary.elementAt(6)%>%</u></td>
      <td class="thinborderNONE" align="right"><u><%=(String)vSummary.elementAt(7)%>%</u></td>
      <td class="thinborderNONE" align="right"><u><%=(String)vSummary.elementAt(8)%>%</u></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="69%" height="24"><font size="1">Printed by : <%=(String)request.getSession(false).getAttribute("first_name")%></font></td>
      <td width="12%">&nbsp;</td>
      <td width="19%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24"><div align="center">Prepared By : </div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
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
<input type="hidden" name="exam_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
