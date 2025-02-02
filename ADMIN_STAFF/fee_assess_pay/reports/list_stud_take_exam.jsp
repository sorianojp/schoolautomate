<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
var imgWnd;
function PrintPg(strPrintPg) {
	document.form_.print_pg.value = strPrintPg;
	document.form_.sub_code.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	document.form_.exam_period_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.page_action.value = "";
	document.form_.print_pg.value = "";
	this.ShowProcessing();
	document.form_.submit();
}
function ChangeSubject() {
	document.form_.sub_code.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	ReloadPage();
}
function ChangeSection() {
	document.form_.section_name.value = document.form_.section[document.form_.section.selectedIndex].text;
	ReloadPage();
}
function PageAction(strAction,strHideImg) {
	document.form_.page_action.value = strAction;
	eval('document.form_.'+strHideImg+'.src = \"../../../images/blank.gif\"');
	document.form_.print_pg.value ="";
	document.form_.submit();
}
function ShowProcessing()
{
	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	document.form_.print_pg.value ="";
	imgWnd.focus();
	return true;
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
</script>


<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector" %>
<%
if(request.getParameter("print_pg") != null && request.getParameter("print_pg").length() > 0){%>
		<jsp:forward page="../listing_for_exam/list_stud_take_exam_print.jsp" />
<%}//page redirection ends..
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int j = 0 ; //count of students can't take exam. or stud with PN


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","list_stud_take_exam.jsp");
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
														"list_stud_take_exam.jsp");
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
GradeSystemExtn gSystemExtn = new GradeSystemExtn();
enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();

	Vector vRetResult = new Vector();//[0] = vStudNotAllowed, [1] = vStudWithPN, [2] = vStudPaidReqdAmt
    Vector vStudPaidReqdAmt = null;//students who paid required amount 
    Vector vStudWithPN      = null;//students with Promisory note and allowed to take exam
    Vector vStudNotAllowed  = null;//students not allowed to take exam because of less payment.

Vector vSecDetail = null;
Vector vSecList   = null;

if(WI.fillTextValue("subject").length() > 0)
{
	vSecList = reportEnrl.getSubSecList(dbOP,request.getParameter("sy_from"),request.getParameter("sy_to"),
								request.getParameter("offering_sem"),request.getParameter("subject"), null);
	if(vSecList == null)
		strErrMsg = reportEnrl.getErrMsg();
}
if(WI.fillTextValue("section").length() > 0)
{
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,request.getParameter("section"));

	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	int iAction = Integer.parseInt(strTemp);
	if(!gSystemExtn.operateOnPN(dbOP, request,iAction))
		strErrMsg = gSystemExtn.getErrMsg();
	else {
		if(iAction == 0)
			strErrMsg = "Selected Students are not permitted to take exam.";
		else	
			strErrMsg = "Selected Students are premitted to take exam.";
	}

}

if(vSecDetail != null && vSecDetail.size() > 0) {//get here student list can and can't take exam
	vRetResult = gSystemExtn.getStudCanOrCantTakeExam(dbOP, request);
	if(vRetResult == null || vRetResult.size() ==0) {
		strErrMsg = gSystemExtn.getErrMsg();
	}
	else {
		vStudNotAllowed  	= (Vector)vRetResult.elementAt(0);
    	vStudWithPN  		= (Vector)vRetResult.elementAt(1);	
    	vStudPaidReqdAmt  	= (Vector)vRetResult.elementAt(2);
	}
}



%>
<form name="form_" action="./list_stud_take_exam.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"> 
          <font color="#FFFFFF"><strong>:::: STUDENTS LISTING FOR EXAMINATION 
          PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" height="25">School Year </td>
      <td width="20%" height="25"> 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">	
      </td>
      <td width="6%">Term</td>
      <td height="25"><select name="offering_sem">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
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
      <td width="39%" height="25"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Exam Schedule</td>
      <td colspan="4"> <select name="pmt_schedule" onChange="ReloadPage();">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%> 
        </select></td>
    </tr>
</table>
<%
if(WI.fillTextValue("sy_from").length()> 0){%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%">Subject</td>
      <td><select name="subject" onChange="ChangeSubject();">
	  <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct e_sub_section.sub_index","sub_code",
		  	" from e_sub_section join subject on (subject.sub_index = e_sub_section.sub_index) "+
		  	"where e_sub_section.is_del=0 and e_sub_section.is_valid=1 and e_sub_section.OFFERING_SY_FROM="+
		  	WI.getStrValue(request.getParameter("sy_from"),"0")+" and OFFERING_SY_TO="+WI.getStrValue(request.getParameter("sy_to"),"0")+
		  	" and OFFERING_SEM= "+WI.getStrValue(request.getParameter("offering_sem"),"0")+
		  	" order by sub_code asc", request.getParameter("subject"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Subject Desc</td>
      <td><%=WI.getStrValue(
	  dbOP.mapOneToOther("SUBJECT", "sub_index", WI.getStrValue(WI.fillTextValue("subject"),"0"), "sub_name",null ))%></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
</table>	
<%}//show only if sy from is entered.
if(vSecList != null && vSecList.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%">&nbsp;</td>
      <td height="25" colspan="2">Section 
        <select name="section" onChange="ChangeSection()">
          <option value="">Select a section</option>
          <%
strTemp = WI.fillTextValue("section");
for(int i=0; i<vSecList.size();i +=2){
	if(strTemp.compareTo((String)vSecList.elementAt(i)) ==0){%>
          <option value="<%=(String)vSecList.elementAt(i)%>" selected><%=(String)vSecList.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vSecList.elementAt(i)%>"><%=(String)vSecList.elementAt(i+1)%></option>
          <%}
}%>
        </select></td>
      <td width="50%" height="25">Instructor :
	  <%if(vSecDetail != null){%>
	  <%=WI.getStrValue(vSecDetail.elementAt(0))%>
	  <%}%></td>
    </tr>
</table>
<%}if(vSecDetail != null && vSecDetail.size() > 0){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr> 
      <td>&nbsp;</td>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>		
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  align="right">
	  <a href="javascript:PrintPg(1);"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print complete list</font></td>
    </tr>
  </table>
</table>
<%
if(vStudNotAllowed != null && vStudNotAllowed.size() > 0) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF">LIST 
          OF STUDENTS <strong>NOT ALLOWED</strong> TO TAKE THE EXAM FOR SUBJECT 
          <strong><%=WI.fillTextValue("sub_code")%>(<%=WI.fillTextValue("section_name")%>)</strong></font></div></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%"><b>Total Students : <%=vStudNotAllowed.size()/8%></b> </td>
      <td width="50%" align="right">
	  <a href="javascript:PrintPg(2);"><img src="../../../images/print.gif" border="0"></a>
	  <font color="#0000FF" size="1">Click to print only this list</font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="14%" height="25"><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="19%"><div align="center"><strong><font size="1">STUDENT NAME 
          <br>
          (LNAME,FNAME,MI)</font></strong></div></td>
      <td width="48%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="4%"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
      <td width="9%"><div align="center"><strong><font size="1">REASON</font></strong></div></td>
      <%if(iAccessLevel > 1){%>
	  <td width="6%"><strong><font size="1">ALLOW</font></strong></td>
	  <%}%>
    </tr>
<%j=0;
for(int i = 0 ; i< vStudNotAllowed.size(); i +=8,++j){%>
    <tr> 
      <td height="25"><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 1)%></font></td>
      <td><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 2)%></font></td>
      <td><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 3)%>
	  <%if(vStudNotAllowed.elementAt(i + 4) != null){%>
	  /<%=(String)vStudNotAllowed.elementAt(i + 4)%><%}%></font></td>
      <td><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 5)%></font></td>
      <td><font size="1"><%=(String)vStudNotAllowed.elementAt(i + 7)%>, No PN</font></td>
      <%if(iAccessLevel > 1){%>
      <td><input type="checkbox" name="save_<%=j%>" value="<%=(String)vStudNotAllowed.elementAt(i)%>"></td>
	  <%}%>
    </tr>
<%}%>
 <input type="hidden" name="save_count" value="<%=j+1%>">
  </table>
<table bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0">
      <tr> 
      <td height="25" align="right">
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PageAction("1","hide_save")'>
	  <img name="hide_save" src="../../../images/save.gif" border="0"></a> 
	  <font size="1">Click to allow all selected students</font>
<%}%>
	  </td>
    </tr>
  </table>
<%}//if vStudNotAllowed is not null 
if(vStudWithPN != null && vStudWithPN.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF">LIST 
          OF STUDENTS <strong>ALLOWED</strong> TO TAKE THE EXAM WITH PROMISORY 
          NOTE FOR SUBJECT <strong><%=WI.fillTextValue("sub_code")%>(<%=WI.fillTextValue("section_name")%>)</strong></font></div></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%"><b>Total Students :</b> <b><%=vStudWithPN.size()/8%></b></td>
      <td width="50%" align="right">
	  <a href="javascript:PrintPg(3);"> <img src="../../../images/print.gif" border="0"></a>
	  <font color="#0000FF" size="1">Click to print only this list</font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="13%" height="25"><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">STUDENT NAME 
          <br>
          (LNAME,FNAME,MI)</font></strong></div></td>
      <td width="52%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
      <td width="10%"><strong><font size="1">DON'T ALLOW</font></strong></td>
    </tr>
<%j = 0;
for(int i = 0 ; i< vStudWithPN.size(); i +=8,++j){%>
    <tr> 
      <td height="25"><font size="1"><%=(String)vStudWithPN.elementAt(i + 1)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vStudWithPN.elementAt(i + 2)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vStudWithPN.elementAt(i + 3)%> 
        <%if(vStudWithPN.elementAt(i + 4) != null){%>
        /<%=(String)vStudWithPN.elementAt(i + 4)%>
        <%}%>
        </font></td>
      <td><font size="1"><%=(String)vStudWithPN.elementAt(i + 5)%></font></td>
      <td><input type="checkbox" name="delete_<%=j%>" value="<%=(String)vStudWithPN.elementAt(i)%>"></td>
    </tr>
<%}%>
 <input type="hidden" name="delete_count" value="<%=j+1%>">
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" align="right">
<%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("0","hide_delete")'><img name="hide_delete" src="../../../images/delete.gif" border="0"></a> 
	  <font size="1">Click to remove student from allowed list</font>
<%}%>
	  </td>
  </tr>
 </table>
<%}//vStudWithPN is not null 
if(vStudPaidReqdAmt != null && vStudPaidReqdAmt.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF">LIST 
          OF STUDENTS HAVE PAID REQUIRED AMOUNT AND <strong>ALLOWED</strong> TO 
          TAKE THE EXAM FOR SUBJECT <strong><%=WI.fillTextValue("sub_code")%>(<%=WI.fillTextValue("section_name")%>)</strong></font></div></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%"><b>Total Students :</b> <b><%=vStudPaidReqdAmt.size()/8%></b></td>
      <td width="50%" align="right">
	  <a href="javascript:PrintPg(4);"> <img src="../../../images/print.gif" border="0"></a>
	  <font color="#0000FF" size="1">Click to print only this list</font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="13%" height="25"><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">STUDENT NAME 
          <br>
          (LNAME,FNAME,MI)</font></strong></div></td>
      <td width="61%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="6%"><div align="center"><strong><font size="1">YEAR</font></strong></div></td>
    </tr>
<%
for(int i = 0 ; i< vStudPaidReqdAmt.size(); i +=8){%>
    <tr> 
      <td height="25"><font size="1"><%=(String)vStudPaidReqdAmt.elementAt(i + 1)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vStudPaidReqdAmt.elementAt(i + 2)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vStudPaidReqdAmt.elementAt(i + 3)%> 
        <%if(vStudPaidReqdAmt.elementAt(i + 4) != null){%>
        /<%=(String)vStudPaidReqdAmt.elementAt(i + 4)%> 
        <%}%>
        </font></td>
      <td><font size="1"><%=(String)vStudPaidReqdAmt.elementAt(i + 5)%></font></td>
    </tr>
<%}%>
  </table>
<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>  
<%}//vStudPaidReqdAmt is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="sub_code" value="<%=WI.fillTextValue("sub_code")%>">
<input type="hidden" name="section_name" value="<%=WI.fillTextValue("section_name")%>">
<input type="hidden" name="progress_bar">
<input type="hidden" name="print_pg">
<input type="hidden" name="exam_period_name">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
