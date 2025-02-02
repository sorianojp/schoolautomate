<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.assessment_sch.print_all.value ="";
	document.assessment_sch.print_pg.value = "";
	if(document.assessment_sch.sy_to.value.length < 4 || document.assessment_sch.sy_from.value.length < 4) {
		alert("Please enter Schoolyear information first.");
		return;
	}
	document.assessment_sch.action = "./statement_of_account_UI_main.jsp";
	document.assessment_sch.submit();
}
function CallPrint()
{
	document.assessment_sch.print_all.value ="";
	document.assessment_sch.print_pg.value = "1";
	document.assessment_sch.action = "./statement_of_account_UI_main.jsp";
}
function NextPage() {
	location = "./statement_of_account_UI.jsp?sy_from="+document.assessment_sch.sy_from.value+
	"&sy_to="+document.assessment_sch.sy_to.value+
	"&semester="+document.assessment_sch.semester[document.assessment_sch.semester.selectedIndex].value+
	"&pmt_schedule="+
	document.assessment_sch.pmt_schedule[document.assessment_sch.pmt_schedule.selectedIndex].value;
}
function PrintALL() {
	document.assessment_sch.print_all.value ="1";
	document.assessment_sch.print_pg.value = "1";
	document.assessment_sch.action = "./statement_of_account_UI_main.jsp";
	document.assessment_sch.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT-assessment batch sched","assessment_sched_batch.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"assessment_sched_batch.jsp");
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

if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};


//get here the list of student to be printed if the print by course is selected.
Vector vRetResult = null;
if(WI.fillTextValue("print_by").compareTo("1") == 0) {
	EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();
	vRetResult = SOA.getStudIDBatchPrint(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SOA.getErrMsg();
}

%>

<form name="assessment_sch" action="" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          PRINT STATEMENT OF ACCOUNT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY/TERM</td>
      <td height="25" colspan="3"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("assessment_sch","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
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
        </select>&nbsp;&nbsp;&nbsp;&nbsp;
        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="4%" height="35">&nbsp;</td>
      <td height="25">Print by </td>
      <td width="18%" height="25"><select name="print_by" onChange="ReloadPage();">
          <option value="0">Student</option>
          <%
strTemp = WI.fillTextValue("print_by");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Course</option>
          <%}else{%>
          <option value="1">Course</option>
          <%}%>
        </select></td>
      <td width="14%">Exam Period </td>
      <td width="47%"><strong>
        <select name="pmt_schedule">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        </select>
        </strong></td>
    </tr>
    <%
strTemp = WI.fillTextValue("print_by");
if(strTemp.compareTo("1") != 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp; </td>
      <td height="25">&nbsp; </td>
      <td height="25"><a href="javascript:NextPage();">NEXT PAGE</a></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"> Course </td>
      <td height="25" colspan="3"><select name="course_index" onChange="ReloadPage();">
          <option value="0">Select Any</option>
          <%
//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Major</td>
      <td height="25" colspan="3"> <select name="major_index">
          <%
strTemp = request.getParameter("course_index");
if(strTemp != null && strTemp.compareTo("0") != 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="17%" height="25"> Year level </td>
      <td height="25" colspan="2"><select name="year_level" onChange="ReloadPage()">
          <option value="">ALL</option>
          <%
strTemp = request.getParameter("year_level");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">Print students whose lastname starts with
        <select name="lname_from" onChange="ReloadPage()">
          <%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        to
        <select name="lname_to" onChange="ReloadPage()">
          <option value="0"></option>
          <%
 strTemp = WI.fillTextValue("lname_to");

 for(int i=++j; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
     <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><font size="3">TOTAL STUDENTS TO BE PRINTED : <strong><%=vRetResult.size()/2%></strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">PRINT OPTION</td>
      <td height="25" colspan="3">
	  <select name="print_page_range">
	<option value="">ALL</option>
	  <%
	  strTemp = WI.fillTextValue("print_page_range");
	  int iTemp = vRetResult.size()/2;
	  int iLastCount = 0;
	  for(int i = 1; i <= iTemp;){
	  	i += 25; //in batch of 25
		if(i > iTemp)
			iLastCount = iTemp;
		else
			iLastCount += 25;
		 if(strTemp.compareTo(Integer.toString(iLastCount)) == 0){%>
		 <option value="<%=iLastCount%>" selected><%=i - 25%> to <%=iLastCount%></option>
		<%}else{%>
		 <option value="<%=iLastCount%>"><%=i - 25%> to <%=iLastCount%></option>
	  <%}
	  }%></select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> <input type="image" src="../../../images/form_proceed.gif" onClick="CallPrint()">
        <font size="1">click to display student list to print.</font></td>
    </tr>
<%}//only if vRetResult is not null;

	}//if print_by is not student
%>
	</table>
<%
if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("print_pg").compareTo("1") == 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3" align="right"><a href="javascript:PrintALL();"><img src="../../../images/print.gif" border="0"></a>
        <font size="1">Click to print all.</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr bgcolor="#999999">
      <td height="25" colspan="3" align="center"><B>LIST OF STUDENT FOR PRINTING.</B></td>
    </tr>
    <tr bgcolor="#ffff99">
      <td width="28%" height="25" align="center"><strong>STUDENT ID</strong></td>
      <td width="52%" align="center"><strong>STUDENT NAME</strong></td>
      <td width="20%" align="center"><strong>PRINT</strong></td>
    </tr>
 <%
 for(int i = 0; i < vRetResult.size(); i += 2){%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center"><a href="./statement_of_account_UI_print.jsp?stud_id=<%=(String)vRetResult.elementAt(i)+
	  "&sy_from="+WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")+
	  "&pmt_schedule="+WI.fillTextValue("pmt_schedule")%>" target="_blank"><img src="../../../images/print.gif" border="0"></a></td>
    </tr>
 <%}%>
  </table>
<%}//end of vRetResult display.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="print_all" value="">
	</form>

<%
//if print all - i have to print all one by one..
if(WI.fillTextValue("print_all").compareTo("1") == 0 && vRetResult != null && vRetResult.size() > 0){
int iMaxPage = vRetResult.size()/2;
int iPrintRangeTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("print_page_range"),"0"));
int iPrintRangeFr = iPrintRangeTo - 25; if(iPrintRangeFr < 1) iPrintRangeFr = 0;
if(iPrintRangeTo == iMaxPage && iMaxPage %25 > 0) {
	//i can't subtract just like that.. i have to find the last page count.
	iPrintRangeFr = iMaxPage - iMaxPage%25;
}
%>
	<script language="JavaScript">
		var printCountInProgress = 0;
		var totalPrintCount = 0;
		<%int iCount = 0;
		for(int i = 0; i < vRetResult.size(); i += 2,++iCount) {
			if(iPrintRangeTo > 0) {
				if( (iCount + 1) < iPrintRangeFr || (iCount + 1) > iPrintRangeTo)
					continue;
			}%>
			function PRINT_<%=iCount%>() {
				var pgLoc = "./statement_of_account_UI_print.jsp?stud_id=<%=(String)vRetResult.elementAt(i)%>"+
					"&sy_from=<%=WI.fillTextValue("sy_from")%>&sy_to=<%=WI.fillTextValue("sy_to")%>&semester=<%=WI.fillTextValue("semester")%>"+
					"&pmt_schedule=<%=WI.fillTextValue("pmt_schedule")%>";

				window.open(pgLoc);
			}//end of printing function.
		<%
	}//end of for loop.

	//for(int i = 0;  i < vRetResult.size(); i += 2){
	%>totalPrintCount = <%=iCount%>;
	printCountInProgress = <%=iPrintRangeFr%>;
	<%if(iPrintRangeTo == 0)
		iPrintRangeTo = iCount;
	%>
	totalPrintCount = <%=iPrintRangeTo%>;
	function callPrintFunction() {
		//alert(printCountInProgress);
		if(eval(printCountInProgress) >= eval(totalPrintCount))
			return;
		eval('this.PRINT_'+printCountInProgress+'()');
		printCountInProgress = eval(printCountInProgress) + 1;//alert(printCountInProgress);

		window.setTimeout("callPrintFunction()", 15000);
	}
	//function PrintALL(strIndex) {
		//if(eval(strIndex) < eval(totalPrintCount))
	//}
		this.callPrintFunction();
	</script>

<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
