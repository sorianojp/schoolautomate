<%@ page language="java" import="utility.*,search.SearchStudent,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	}
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript" src="../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.search_util.print_pg.value = "1";
	document.search_util.invalidate_id.value = "";
	this.SubmitOnce('search_util');	
}
function ReloadPage()
{
	document.search_util.searchStudent.value = "";
	document.search_util.print_pg.value = "";
	document.search_util.invalidate_id.value = "";
	this.SubmitOnce('search_util');
}
function SearchStudent()
{
	document.search_util.searchStudent.value = "1";
	document.search_util.print_pg.value = "";
	document.search_util.invalidate_id.value = "";
	this.SubmitOnce('search_util');
}
function ViewDetail(strStudID)
{
//popup window here. 
	var pgLoc = "./stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DisplaySYTo() {
	var strSYFrom = document.search_util.sy_from.value;
	if(strSYFrom.length == 4)
		document.search_util.sy_to.value = eval(strSYFrom) + 1;
	if(strSYFrom.length < 4)
		document.search_util.sy_to.value = "";
}
function ShowAdvisedSubject(strEnrolStat, strStudID) {
	var pgLoc;
	if(strEnrolStat == 1) {//old stud
		pgLoc = "../ADMIN_STAFF/enrollment/reports/student_sched.jsp?stud_id="+escape(strStudID)+"&sy_from="+
		document.search_util.sy_from.value+"&sy_to="+document.search_util.sy_to.value+"&semester="+
		document.search_util.semester[document.search_util.semester.selectedIndex].value;
	}
	else {//not validated.
		pgLoc = "../ADMIN_STAFF/enrollment/advising/gen_advised_schedule_print.jsp?print=0&stud_id="+escape(strStudID);
	}
	var win=window.open(pgLoc,"ViewWindow",'width=800,height=500,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function InvalidateAdvising(strStudID) {
	var vProceed = confirm("Are you sure you want to remove advising information.");
	if(vProceed) {
		document.search_util.invalidate_id.value = strStudID;
		this.SubmitOnce('search_util');
	}
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strStudID)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	
	self.close();
}
<%}%>

function SwitchTemp()
{
	location = "./srch_stud_temp_basic.jsp?sy_from=" + document.search_util.sy_from.value + 
			 "&sy_to=" + document.search_util.sy_to.value + 
			 "&semester=" + 
			 document.search_util.semester[document.search_util.semester.selectedIndex].value + 
			 "&opner_info="+ document.search_util.opner_info.value;
}
</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

// if this page is calling print page, i have to forward page to print page.
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./srch_stud_enrolled_print.jsp" />
	<%	return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Students","srch_stud_temp.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

//Invalidate a temp student's enrollment if it is called.
if(WI.fillTextValue("invalidate_id").length() > 0) {
	enrollment.NAApplicationForm naApplForm = new enrollment.NAApplicationForm();
	if(!naApplForm.invalidateAdvising(dbOP, false, WI.fillTextValue("invalidate_id"),
	 	(String)request.getSession(false).getAttribute("userId"), 
		(String)request.getSession(false).getAttribute("login_log_index"),WI.fillTextValue("sy_from"), 
		WI.fillTextValue("sy_to"), WI.fillTextValue("semester")) )
		strErrMsg = naApplForm.getErrMsg();
}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender","Course","Enrol. Date"};
String[] astrSortByVal     = {"ID_NUMBER","lname","fname","gender","course_name","NA_OLD_STUD.create_date"};


int iSearchResult = 0;
String[] astrConvertPmt = {"","One Pmt","Two Pmt","more than two","more than two","more than two","more than two","more than two",
							"more than two","more than two","more than two","more than two","more than two","more than two",
							"more than two","more than two","more than two","more than two","more than two","more than two"};//upto 19
SearchStudent searchStud = new SearchStudent(request);
if(WI.fillTextValue("searchStudent").compareTo("1") == 0){
	vRetResult = searchStud.searchOldStudEnrollment(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}

%>
<form action="./srch_stud_enrolled_basic.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          OLD STUDENT ENROLMENT ACTIVITY PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Student ID </td>
      <td width="10%"><select name="id_number_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="8%">Gender </td>
      <td width="42%"><select name="gender">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("F") == 0){%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}if(WI.fillTextValue("gender").compareTo("M") ==0){%>
          <option value="M" selected>Male</option>
          <%}else{%>
          <option value="M">Male</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>SY-SEM</td>
<% strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}
%>
      <td><input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeyUp="DisplaySYTo();">
        to 
<% strTemp = WI.fillTextValue("sy_to");
	if (strTemp.length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}
%>		
        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
        &nbsp;&nbsp; 
<select name="semester">
          <%
strTemp = WI.fillTextValue("semester");

if (strTemp.length()==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Regular</option>
<%}else{%>
          <option value="1">Regular</option>
<%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<td height="25">&nbsp;</td>
      <td>School </td>
      <td colspan="4"><% strTemp = WI.fillTextValue("sch_index"); %> 
	<select name="sch_index">
		  <option value="">ALL</option>
          <%=dbOP.loadCombo("SCH_INDEX","SCH_NAME"," from SCHOOL_LIST order by SCH_NAME",strTemp,false)%> </select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Level / Year</td>
      <td colspan="4"><%strTemp = WI.fillTextValue("g_level");%> 
	  	  <select name="g_level">
			  <option value="">ALL</option>
			  <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",strTemp,false)%> 
		  </select>	  </td>    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5" style="font-size:9px;"><%
strTemp = WI.fillTextValue("is_enrolled");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else 
	strTemp ="";
%>
        <input type="checkbox" name="is_enrolled" value="1" <%=strTemp%>>
Show Enrolled Student
<%
strTemp = WI.fillTextValue("is_advised");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else
	strTemp = "";

%>
<input type="checkbox" name="is_advised" value="1" <%=strTemp%>>
Show Advised Student
<%
strTemp = WI.fillTextValue("is_downpmt_paid");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else
	strTemp = "";

%>
<input type="radio" name="is_downpmt_paid" value="1" <%=strTemp%>>
Show Student with Downpayment &nbsp;&nbsp;
<%
if(WI.fillTextValue("is_downpmt_paid").equals("2"))
	strTemp = " checked";
else
	strTemp = "";

%>
<input type="radio" name="is_downpmt_paid" value="2" <%=strTemp%>>
Show Student with Registration fee		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5" style="font-size:11px;"><a href="javascript:SwitchTemp()">Search Temporary student</a></td>
    </tr>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="25%">
	  <select name="sort_by1">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con">
          <option value="asc">Ascending</option>
<%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="25%"><select name="sort_by2">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
<%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="39%"><select name="sort_by3">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
<%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:SearchStudent();"><img src="../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<!--    <tr>
      <td height="25" colspan="3"><div align="right">
	  <a href="javascript:PrintPg();"><img src="../images/print.gif" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#FFFFFF" align="right">
	  <a href="javascript:PrintPg();"><img src="../images/print.gif" border="0"></a>
	  <font size="1">Click to print result</font></td>
    </tr> -->
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH
          RESULT</font></strong></div></td>
    </tr>
    <tr>
      <td width="66%" ><b> Total Students : <%=iSearchResult%> - Showing(<%=searchStud.getDisplayRange()%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchStud.defSearchSize;
		if(iSearchResult % searchStud.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="SearchStudent();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
          <%}%>
        </div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="15%" height="25" ><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">START DATE OF 
          ENROLLMENT </font></strong></div></td>
      <td width="18%"><div align="center"><strong><font size="1">LNAME, FNAME, 
          MI </font></strong></div></td>
      <td width="4%"><div align="center"><strong><font size="1">GEN</font></strong></div></td>
      <td width="35%"><div align="center"><strong><font size="1">GRADE LEVEL </font></strong></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>APPL CATG</strong></font></div></td>
<!--      <td width="5%"><div align="center"><strong><font size="1"> ENROLLED</font></strong></div></td>-->
      <td width="5%"><div align="center"><strong><font size="1"> ADVISED</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">NO. OF PMT</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">VIEW ADVISED SUBJ</font></strong></div></td>
      <td width="5%"><font size="1"><strong>REMOVE ADVISING</strong></font></td>
    </tr>
    <%
boolean bolIsEnrolled = false;
Vector vGradeLevel = new Vector();

for(int i=0; i<vRetResult.size(); i+=13){bolIsEnrolled = false;%>
    <tr> 
      <td height="25"><font size="1">
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%> 
        <%}%>
        </font></td>
      <td height="25"><font size="1">
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"Not thru' system")%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+2)%>, <%=(String)vRetResult.elementAt(i+3)%> 
        <%if(vRetResult.elementAt(i+4) != null && ((String)vRetResult.elementAt(i+4)).length() > 0){%>
        , <%=((String)vRetResult.elementAt(i+4)).charAt(0)%> 
        <%}%>
        </font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5),"n/f")%></font></td>
      <td><font size="1">&nbsp;</font></td>
      <td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
<!--      <td align="center">&nbsp;
        <%if( Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+10),"0")) > 0 && 
			vRetResult.elementAt(i+12) != null){%>
        <img src="../images/tick.gif"> 
        <%bolIsEnrolled = true;}%>
      </td>-->
      <td align="center">&nbsp; <%if( Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+10),"0")) > 0){%> <img src="../images/tick.gif"> <%}%> </td>
      <td>&nbsp; <%=astrConvertPmt[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+11),"0"))]%> </td>
      <td> <%if(WI.fillTextValue("is_enrolled").compareTo("1") == 0){%> 
	  <a href='javascript:ShowAdvisedSubject("1","<%=(String)vRetResult.elementAt(i + 1)%>");'> 
        <%}else{%><a href='javascript:ShowAdvisedSubject("0","<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%}%>
        <img src="../images/view.gif" border="0"></a></td>
      <td>
        <%//if(WI.fillTextValue("is_enrolled").length() == 0 && Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+10),"0")) > 0){%>
		<a href='javascript:InvalidateAdvising("<%=(String)vRetResult.elementAt(i+1)%>");'>
		<img src="../images/delete.gif" border="0" height="25" width="50"></a>
	  <%//}else{%>&nbsp;<%//}%>
      </td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right"> </div></td>
      <td width="31%">&nbsp;</td>
    </tr>
<!--    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="srch_stud_print.jsp"><img src="../images/print.gif" width="58" height="26" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>-->
  </table>
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="searchStudent" value="<%=WI.fillTextValue("searchStudent")%>">
<input type="hidden" name="print_pg">
<input type="hidden" name="invalidate_id">

<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
<input type="hidden" name="is_basic" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>