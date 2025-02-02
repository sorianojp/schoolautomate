<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function DeleteRecord(){
	document.form_.page_action.value = "0";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value = "1";
	document.form_.sem_label.value = document.form_.offering_sem[document.form_.offering_sem.selectedIndex].text;
	document.form_.subj_label.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	this.SubmitOnce("form_");
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ReportEnrollment,ClassMgmt.CMAttendance " %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;

	Vector vSecDetail = null;
//add security here.

	if (WI.fillTextValue("print_page").compareTo("1") == 0){
%>
	<jsp:forward page="./cm_attendance_print.jsp" />
<%	return;} 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Class Management-Attendance","cm_attendance.jsp");
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
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"edit_dtr.jsp");	
iAccessLevel = 2;
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	String strSubSecIndex   = null;
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	String[] astrStatus ={"PRESENT","ABSENT","LATE","SENT OUT"};
	Vector vRetResult = null;

if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION",
						" section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
						" and e_sub_section.offering_sy_from = "+WI.fillTextValue("sy_from")+
						" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
						" and e_sub_section.offering_sem="+WI.fillTextValue("offering_sem")+
						" and is_lec=0");				
}
	
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

CMAttendance cm = new CMAttendance(request);


if (vSecDetail != null){
	vRetResult = cm.operateOnAttendance(dbOP,request,4);
	
	if (vRetResult == null){
		strErrMsg = cm.getErrMsg();	
	}
}
%>

<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
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

-->
</style>
<body bgcolor="#93B5BB">
<form action="./cm_attendance_view.jsp" method="post" name="form_" id="form_">  
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CLASS ATTENDANCE SEARCH PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="2">&nbsp;&nbsp;<strong><font size="3" color="#FF0000"> 
        <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td><strong>SY / TERM</strong></td>
      <td width="88%" height="25"><%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("gsheet","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes">
	  
	  <select name="offering_sem" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
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
        </select>
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td><font face="Verdana, Arial, Helvetica, sans-serif"><strong>SUBJECT </strong></font></td>
      <td height="25"><input name="filter_sub" type="text" class="textbox" id="filter_sub"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("filter_sub")%>" size="5" maxlength="5" > 
        <% 
	  	strTemp = WI.fillTextValue("filter_sub");
		if (strTemp.length() > 0) 
			strTemp = " and sub_code like '" + strTemp + "%'";
		strTemp = " from subject where is_del = 0 " + strTemp + " order by sub_code";
	  %> <select name="subject" onChange="ReloadPage()">
          <option value=""> Select Subject</option>
          <%=dbOP.loadCombo("distinct sub_index"," sub_code ", strTemp,WI.fillTextValue("subject"),false)%> </select> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="12%"><font face="Verdana, Arial, Helvetica, sans-serif"><strong>SECTION 
        </strong></font></td>
      <td height="25"><%
	  	if (WI.fillTextValue("subject").length() > 0 &&  WI.fillTextValue("sy_from").length() > 0 &&
		    WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("offering_sem").length() > 0)
	strTemp = " , e_sub_section.sub_index from e_sub_section join subject on (e_sub_section.sub_index = subject.sub_index) " +
		  " where  e_sub_section.sub_index  = " + WI.fillTextValue("subject") + " and subject.is_del = 0 and  " +
		  " e_sub_section.is_del = 0 and e_sub_section.OFFERING_SY_FROM ="+
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SY_TO="+WI.fillTextValue("sy_to")+
			" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem");
		else
	strTemp = null;
	
	if (strTemp != null){
%>
        <select name="section_name" id="section_name" onChange="ReloadPage();">
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("distinct section","section",strTemp, request.getParameter("section_name"), false)%> 
        </select>&nbsp;
	<%}%>
	 </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td> <strong>DATE</strong></td>
      <td height="25"> <input name="date_attendance" type="text" class="textbox" id="date_attendance" 
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_attendance")%>" size="12" maxlength="12" readonly> 
        <a href="javascript:show_calendar('form_.date_attendance');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp; </td>
      <td height="25"><a href="javascript:ReloadPage()"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
  </table>
<%	if (vRetResult != null) {
		Vector vRecorded = (Vector)vRetResult.elementAt(0);	
		Vector vUnrecorded = (Vector)vRetResult.elementAt(1);%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td>&nbsp;</td>
      <td height="25"><strong> </strong> 
        <div align="right">
          <hr size="1" noshade>
        </div></td>
    </tr>
    <tr >
      <td>&nbsp;</td>
      <td height="25"><strong>TOTAL STUDENTS ENROLLED IN THIS CLASS : <%=Integer.parseInt((String)vRecorded.elementAt(0)) + Integer.parseInt((String)vUnrecorded.elementAt(0))%></strong></td>
    </tr>
  </table>
<%  if (vUnrecorded.size() > 1){ %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
	  <td height="20">&nbsp;</td>
  </tr>
  <tr>
	  <td height="25"><div align="center"><strong>LIST OF STUDENTS WITH NO ATTENDANCE 
          RECORD</strong></div></td>
  </tr>
  </table
  ><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="12%" height="27" rowspan="2" align="center" class="thinborder"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="27" colspan="3" align="center" class="thinborder"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="15%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="5%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>YEAR </strong></font></td>
    </tr>
    <tr> 
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>MI</strong></font></td>
    </tr>
    <% 	for(int k=1; k<vUnrecorded.size(); k+=7){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vUnrecorded.elementAt(k)%></font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vUnrecorded.elementAt(k+3)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vUnrecorded.elementAt(k+1)%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(WI.getStrValue((String)vUnrecorded.elementAt(k+2), " ")).charAt(0)%></font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vUnrecorded.elementAt(k+4)%> </font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vUnrecorded.elementAt(k+5)%></font></div></td>
    </tr>
    <%}// end of for loop%>
  </table>
  <%} if (vRecorded.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
	  <td height="15">&nbsp;</td>
  </tr>
  <tr>
	  <td height="25"><div align="center"><strong>LIST OF STUDENTS WITH ATTENDANCE 
          RECORD</strong></div></td>
  </tr>
  </table
  >
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td width="12%" height="27" rowspan="2" align="center"  class="thinborder"><font size="1"><strong>STUDENT 
        ID</strong></font></td>
      <td height="27" colspan="3" align="center"  class="thinborder"><strong><font size="1">STUDENT 
        NAME</font></strong></td>
      <td width="14%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>COURSE/MAJOR</strong></font></td>
      <td width="4%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>YEAR 
        </strong></font></td>
      <td width="14%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>STATUS</strong></font></td>
      <td width="14%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <tr> 
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>LASTNAME</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>FIRSTNAME</strong></font></td>
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>MI</strong></font></td>
    </tr>
    <%	for(int k=1; k<vRecorded.size(); k+=10){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRecorded.elementAt(k)%></font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vRecorded.elementAt(k+3)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRecorded.elementAt(k+1)%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(WI.getStrValue((String)vRecorded.elementAt(k+2), " ")).charAt(0)%></font></div></td>
      <td class="thinborder"><font size="1"><%=(String)vRecorded.elementAt(k+4)%> </font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRecorded.elementAt(k+5)%></font></div></td>
      <td class="thinborder"><div align="center"><%=astrStatus[Integer.parseInt((String)vRecorded.elementAt(k+7))]%></div></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRecorded.elementAt(k+8),"&nbsp")%></font></td>
    </tr>
    <%}// end of for loop%>
  </table>
 <%}// vRecorded.size() > 1
  } // if vRetResult == null%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2"> 
    <td height="25">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="sem_label">
<input type="hidden" name="subj_label">
    <input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
