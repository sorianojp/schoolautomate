<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" SRC="../../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script>
function ViewDetails(strInfoIndex, strStudIndex)
{
	var pgLoc = "./view_dtls_absences.jsp?stud_id="+strStudIndex+"&info_index="+strInfoIndex+"&absent_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SearchNow()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

</script>
<%@ page language="java" import="utility.*, osaGuidance.GDAbsence, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	

	boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
	if(bolIsBasic) {
		astrSemester[1] = "Regular";
	}
		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Student Tracker-Absences","search_absences.jsp");
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
														"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"STUDENT AFFAIRS","Student Tracker",request.getRemoteAddr(), null);
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Course","Absence Date"};
String[] astrSortByVal     = {"id_number","lname","fname","course_name","absent_date_from"};


int iSearchResult = 0;
GDAbsence GDAbsent = new GDAbsence();

if(WI.fillTextValue("executeSearch").compareTo("1") == 0){
	vRetResult = GDAbsent.searchAbsence(dbOP, request);
	if(vRetResult == null)
		strErrMsg = GDAbsent.getErrMsg();
	else	
		iSearchResult = GDAbsent.getSearchCount();
}

%>
<body bgcolor="#D2AE72">
<form action="./search_absences.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: COUNSELING CASES SEARCH PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="4" height="20"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
	</table>
	  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">Student ID </td>
      <td width="10%"><select name="id_number_con">
          <%=GDAbsent.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="8%">SY-SEM</td>
      <td width="38%"><input name="sy_from" type="text" size="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <input name="sy_to" type="text" size="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; 
	  <select name="semester">
          <option value="">N/A</option>
          <%=dbOP.loadSemester(bolIsBasic, WI.fillTextValue("semester"), request)%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=GDAbsent.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Year</td>
      <td><select name="year_level">
          <option value="">N/A</option>
          <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=GDAbsent.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Date Absent</td>
      <td><%strTemp = WI.fillTextValue("date_absent_fr");%>
		<input name="date_absent_fr" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_absent_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
        <%strTemp = WI.fillTextValue("date_absent_to");%>
		<input name="date_absent_to" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_absent_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
        </td>
    </tr>
<%if(!bolIsBasic) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="4"><select name="course_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 										" order by course_name asc", request.getParameter("course_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td colspan="4"><select name="major_index">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("course_index").length()>0){
strTemp = " from major where IS_DEL=0 and course_index="+request.getParameter("course_index")+" order by major_name asc";
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index="+
 							request.getParameter("course_index")+" order by major_name asc", request.getParameter("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
<%}%>
    <tr> 
      <td height="25" colspan="6"><hr size="1"></td>
    </tr>
    </table>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
    <td colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="10%">Sort by</td>
      <td width="25%">
	  <select name="sort_by1">
	 	<option value="">N/A</option>
          <%=GDAbsent.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
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
          <%=GDAbsent.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
<%}else{%>
          <option value="desc">Descending</option>
<%}%>
        </select></td>
      <td width="37%"><select name="sort_by3">
	 	<option value="">N/A</option>
          <%=GDAbsent.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <br/>
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
<% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
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
      <td><a href="javascript:SearchNow();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr bgcolor="#A9C0CD"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong> 
          ABSENTEE LIST </strong></font></div>
        </td>
    </tr>
    <tr>  
	      <td height="25" colspan="5" class="thinborder"><strong><font size="1">
		  TOTAL INCIDENTS(S) : <%=iSearchResult%> - Showing(<%=GDAbsent.getDisplayRange()%>)</font></strong></td>
      <td height="25" colspan="3" align="right" class="thinborder"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/GDAbsent.defSearchSize;
		if(iSearchResult % GDAbsent.defSearchSize > 0) ++iPageCount;
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
    <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>SY/TERM</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="18%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT 
          NAME </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>ABSENCE DATE</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>COURSE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT/ TIME</strong></font></div></td>
      <td width="18%" class="thinborder"><div align="center"><strong><font size="1"><strong>REASON</strong></font></strong></div></td>
      <td width="5%" class="thinborder">&nbsp;</td>
    </tr>
    <%for (int i = 0; i<vRetResult.size(); i+=16){
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+7));
	if(bolIsBasic) 
		strTemp = dbOP.getBasicEducationLevel(Integer.parseInt((String)vRetResult.elementAt(i + 9)));
	%>
    <tr> 
     <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+13)%>&nbsp;-&nbsp;<%=(String)vRetResult.elementAt(i+14)%><br><%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+15))]%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></div></td>
      <td height="25" class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),7)%></font></td>
      <td class="thinborder"><font size="1">
      <%=(String)vRetResult.elementAt(i+5)%><%=WI.getStrValue((String)vRetResult.elementAt(i+6)," to ","","&nbsp;")%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=strTemp%></font></div></td>
      <td class="thinborder"><font size="1">Subject: <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"Not Defined")%><br>
      	  Time: <%=WI.getStrValue((String)vRetResult.elementAt(i+11),"Not Defined")%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+12)%></font></td>
      <td class="thinborder"><a href='javascript:ViewDetails(<%=((String)vRetResult.elementAt(i))%>, "<%=((String)vRetResult.elementAt(i+1))%>")'>
	  <img src="../../../../images/view.gif" width="40" height="31" border="0"></a></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="is_basic" value="<%=WI.fillTextValue("is_basic")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

