<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

function UpdateRecord(strAppIndex,strCanUpdate,strTempId) 
{
	var pgLoc = "applicant_status_update.jsp?sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester.value+"&stud_index="+strAppIndex+"&can_update="+strCanUpdate+"&temp_id="+strTempId+"&opner_form_name=form_";
	
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	
	win.focus();
}
function ScheduleApp(strTempId)
{
	var pgLoc = "../entrance_exam_interview/applicant_scheduling.jsp?temp_id="+strTempId+"&sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester.value+"&opner_form_name=form_";
	
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	
	win.focus();
}
function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SearchApplicant();	
}
function ReloadPage()
{
	document.form_.ShowType.value=document.form_.stat_index[document.form_.stat_index.selectedIndex].text;
	document.form_.print_pg.value = "";
	this.SubmitOnce("form_");
}
function SearchApplicant() {
	document.form_.ShowType.value=document.form_.stat_index[document.form_.stat_index.selectedIndex].text;
	document.form_.searchApplicant.value = "1";
	this.SubmitOnce("form_");
}
</script>

<body bgcolor="#D2AE72">
<%
	Vector vRetResult = null;
	String strErrMsg = null;
	String strTemp = null;	
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
	
// if this page is calling print page, i have to forward page to print page.
	
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./applicant_status_update.jsp" />
	<%	return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-APPLICANT STATUS","applicant_status_main.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%	return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();

int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","APPLICANT STATUS",request.getRemoteAddr(),
														"applicant_status_main.jsp");
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

int iSearchResult = 0;
int iView = Integer.parseInt(WI.getStrValue(request.getParameter("stat_index"),"6"));
ApplicationMgmt appMgmt = new ApplicationMgmt();
if(WI.fillTextValue("searchApplicant").length() > 0) {
	vRetResult = appMgmt.viewApplicantStatus(dbOP, request, iView);
	if(vRetResult == null)
		strErrMsg = appMgmt.getErrMsg();
	else	
		iSearchResult = appMgmt.getSearchCount();
}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender","Course","Date of Appl."};
String[] astrSortByVal     = {"temp_id","lname","fname","gender","course_name","NEW_APPLICATION.CREATE_DATE"};

%>
<form name="form_" action ="./applicant_status_main.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="91%" height="25" colspan="8" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          APPLICANT STATUS PAGE::::</font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Temporary ID </td>
      <td width="10%"><select name="id_number_con">
          <%=appMgmt.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"> <input name="id_number" type="text" class="textbox" value="<%=WI.fillTextValue("id_number")%>"
       
         onfocus="style.backgroundColor='#D3EBFF'"	onblur='style.backgroundColor="white"' >
      </td>
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
          <%=appMgmt.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>SY-SEM</td>
      <td><% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
/
<select name="semester">
  <% strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
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
  <option value="2" selected=>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}
  
  if (!strSchCode.startsWith("CPU")) {
  
  if(strTemp.compareTo("3") == 0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}
  }
  %>
</select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=appMgmt.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Year Level</td>
      <td><select name="year_level">
          <option value="">N/A</option>
   <% strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0) {%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0) {%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0) {%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0) {%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0) {%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option> <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="4"><select name="course_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
		  					" and is_offered = 1 and is_visible = 1  order by course_name asc", 
							request.getParameter("course_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td colspan="4"><select name="major_index">
          <option value="">N/A</option>
          <% if(WI.fillTextValue("course_index").length()>0){
				strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+
				" order by major_name asc"; %>
          <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 							request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Applicant Stat. </td>
      <td colspan="2"><select name="stat_index" onChange="ReloadPage();">
        <option value="6">All </option>
       <% strTemp = WI.fillTextValue("stat_index");
		  if (strTemp.compareTo("0")==0){%>
        <option value="0" selected>Score not Encoded</option>
        <%}else{%>
        <option value="0">Score not Encoded</option>
        <%} if (strTemp.compareTo("1")==0){%>
        <option value="1" selected>For Result Updating</option>
        <%}else{%>
        <option value="1">For Result Updating</option>
        <%} if (strTemp.compareTo("2")==0){%>
        <option value="2" selected>For Examination</option>
        <%}else{%>
        <option value="2">For Examination </option>
        <%} if (strTemp.compareTo("3")==0){%>
        <option value="3" selected>Approved/Accepted</option>
        <%}else{%>
        <option value="3">Approved/Accepted</option>
        <%} if (strTemp.compareTo("4")==0){%>
        <option value="4" selected>Denied</option>
        <%}else{%>
        <option value="4">Denied</option>
        <%} if (strTemp.compareTo("5")==0){%>
        <option value="5" selected>Under further evaluation</option>
        <%}else{%>
        <option value="5">Under further evaluation</option>
        <%}%>
      </select></td>
      <td>Appl Date. </td>
      <td><input name="appl_date" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("appl_date")%>"
	   readonly="yes">
        <a href="javascript:show_calendar('form_.appl_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  <img src="../../../images/calendar_new.gif" border="0"></a></td>
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
          <%=appMgmt.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="25%"><select name="sort_by2">
	 	<option value="">N/A</option>
          <%=appMgmt.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="32%"><select name="sort_by3">
	 	<option value="">N/A</option>
          <%=appMgmt.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:SearchApplicant();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="6" class="thinborder"><div align="center"><strong><font color="#FFFFFF" size="1">LIST 
          OF <%=WI.getStrValue(request.getParameter("ShowType")).toUpperCase()%> 
		  APPLICANTS FOR 
		  <%=dbOP.getHETerm(Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"-1"))).toUpperCase()%>, 
		  SY <%=WI.fillTextValue("sy_from") + " - "+WI.fillTextValue("sy_to")%></font></strong></div></td>
    </tr>
    <tr>  
	      <td height="25" colspan="4" class="thinborder"><strong><font size="1">
		  TOTAL APPLICANT(S) : <%=iSearchResult%> - Showing(<%=appMgmt.getDisplayRange()%>)</font></strong></td>
      <td height="25" colspan="2" align="right" class="thinborder"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/appMgmt.defSearchSize;
		if(iSearchResult % appMgmt.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump To page: 
          <select name="jumpto" onChange="SearchApplicant();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}
			%>
          </select>
          <%} else {%>&nbsp;<%}%></td>
    </tr>
    <tr> 
      <td width="13%" height="25" class="thinborder"><div align="center"><strong><font size="1">TEMPORARY / APPLICANT 
      ID</font></strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>
	  <font size="1">APPLICANT NAME </font></strong> </div></td>
      <td width="11%" class="thinborder"><div align="center"><strong><font size="1">DATE APPLIED</font></strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong><font size="1">COURSE NAME/MAJOR 
      APPLIED</font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><b><font size="1">APPLICATION STATUS</font></b></div></td>
      <b> </b> 
      <td align="center" class="thinborder">&nbsp;</b></td>
    </tr>
<% 	String[] astrConvertResultStat1 = {"FOR RESULT ENCODING","SCORE NOT ENCODED","FOR EXAM SCHEDULING",""};//index8
	String[] astrConvertResultStat2 = {"DENIED","APPROVED","UNDER FURTHER EVALUATION",""};//index 9

for(int i = 0 ; i< vRetResult.size(); i += 11){%>
    <tr> 
      <td class="thinborder"><div align="center"><%=((String)vRetResult.elementAt(i+1))%></div></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),4)%></font></td>
      <td class="thinborder"><%=((String)vRetResult.elementAt(i+5))%></td>
      <td class="thinborder">	 
	    <font size="1"><%=WI.getStrValue(WI.getStrValue((String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+6)+"/","",
		(String)vRetResult.elementAt(i+6)),"Not Available")%></font></td>
      <td class="thinborder">
	    <font size="1">
	    <%
	  if(vRetResult.elementAt(i + 9) == null){%>
	  	<%=astrConvertResultStat1[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 8),"3"))]%>
	    <%}else{%>
	    <%=astrConvertResultStat2[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 9),"3"))]%>
	    <%}%>
        </font></td>
      <td width="10%" align="center" class="thinborder"> <font size="1">
	  <%if (((String)vRetResult.elementAt(i+8)).compareTo("0")==0){%>
	  <a href='javascript:UpdateRecord(<%=((String)vRetResult.elementAt(i))%>,"1","<%=((String)vRetResult.elementAt(i+1))%>")'>
	  <img src="../../../images/update.gif" border="0"></a>
	  <%} if (((String)vRetResult.elementAt(i+8)).compareTo("1")==0){%>
	  <a href='javascript:UpdateRecord(<%=((String)vRetResult.elementAt(i))%>,"0","<%=((String)vRetResult.elementAt(i+1))%>")'>
	  <img src="../../../images/view.gif" width="40" height="31" border="0"></a>
          <%} if (((String)vRetResult.elementAt(i+8)).compareTo("2")==0){%>
		  <a href='javascript:ScheduleApp("<%=((String)vRetResult.elementAt(i+1))%>")'>
		  <img src="../../../images/schedule.gif" width="55" height="30" border="0"></a><%}%>  
      </font></td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult != null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#B5AB73">
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="ShowType">
<input type="hidden" name="print_pg">
<input type="hidden" name="searchApplicant" >
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>