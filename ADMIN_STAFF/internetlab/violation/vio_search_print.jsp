<%@ page language="java" import="utility.*,iCafe.Violation,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.search_util.print_pg.value = "1";
	this.SubmitOnce("search_util");	
}
function ReloadPage()
{
	document.search_util.searchStudent.value = "";
	document.search_util.print_pg.value = "";
	this.SubmitOnce("search_util");
}
function SearchStudent()
{
	document.search_util.searchStudent.value = "1";
	document.search_util.print_pg.value = "";
	this.SubmitOnce("search_util");
}
function ViewDetail(strStudID)
{
//popup window here. 
	var pgLoc = "./vio_info_detail.jsp?vio_user="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	document.search_util.id_number.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	if (WI.fillTextValue("shift_page_basic").compareTo("1") == 0){
		response.sendRedirect(response.encodeRedirectURL("./srch_stud_basic.jsp?fs="+WI.fillTextValue("fs")));		
		return;
	}
// if this page is calling print page, i have to forward page to print page.
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./vio_search_print.jsp" />
	<%	return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Students","srch_stud.jsp");
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender"};
String[] astrSortByVal     = {"id_number","lname","fname","gender"};


int iSearchResult = 0;

Violation vioSearch = new Violation(request);
if(WI.fillTextValue("searchStudent").compareTo("1") == 0){
	vRetResult = vioSearch.searchViolation(dbOP);
	if(vRetResult == null)
		strErrMsg = vioSearch.getErrMsg();
	else	
		iSearchResult = vioSearch.getSearchCount();
}

%>
<form action="./vio_search.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SEARCH STUDENT PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5"> <%
strTemp = WI.fillTextValue("srch_emp");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="srch_emp" value="1" <%=strTemp%> onClick="ReloadPage();">
        Search Employee (uncheck this to search student)</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Student ID </td>
      <td width="10%"><select name="id_number_con">
          <%=vioSearch.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="7%">Gender </td>
      <td width="43%"><select name="gender">
          <option value=""></option>
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
          <%=vioSearch.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>Year</td>
      <td><input name="v_year" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("v_year")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=vioSearch.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>V-Date:</td>
      <td> Between 
        <input name="v_date_fr" type="text" size="10" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("v_date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('search_util.v_date_fr');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        &nbsp;and 
        <input name="v_date_to" type="text" size="10" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("v_date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('search_util.v_date_to');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
    <%
if(!WI.fillTextValue("srch_emp").equals("1")){%>
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
    <!--    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderTOPLEFTRIGHT" bgcolor="#DDDDDD"> <%
strTemp = WI.fillTextValue("show_section");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_section" value="1"<%=strTemp%>>
        Show Section enrolled (shows only one section - useful only for block 
        section)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderBOTTOMLEFTRIGHT" bgcolor="#DDDDDD"> <%
strTemp = WI.fillTextValue("show_course");
if(strTemp.compareTo("1") == 0 || request.getParameter("print_pg") == null) // first time.
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_course" value="1"<%=strTemp%>>
        Show Course/Major 
        <%
strTemp = WI.fillTextValue("show_yr");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_yr" value="1"<%=strTemp%>>
        Show Year Level &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Name Format: 
        <select name="name_format" style="font-size:11px;font-weight:bold">
          <option value="4">lname, fname mi. (default)</option>
          <%
strTemp = WI.fillTextValue("name_format");
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>fname mname lname</option>
          <%}else{%>
          <option value="1">fname mname lname</option>
          <%}if(strTemp.compareTo("7") == 0) {%>
          <option value="7" selected>fname mi. lname</option>
          <%}else{%>
          <option value="7">fname mi. lname</option>
          <%}if(strTemp.compareTo("5") == 0) {%>
          <option value="5" selected>lname,fname mname</option>
          <%}else{%>
          <option value="5">lname,fname mname</option>
          <%}%>
        </select> </td>
    </tr>
-->
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="27%">
	  <select name="sort_by1" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=vioSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="28%"><select name="sort_by2" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=vioSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="34%"><select name="sort_by3" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=vioSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
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
      <td><input type="image" src="../../../images/form_proceed.gif" onClick="SearchStudent();"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">
<%
	  if(WI.fillTextValue("opner_info").length() > 0){%>
        NOTE : Please click ID number to copy ID to form it is called from. 
        <%}%></td>
      <td width="16%" height="25">&nbsp;</td>
      <td width="18%" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print </font>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="66%" ><b> Total Students : <%=iSearchResult%> - Showing(<%=vioSearch.getDisplayRange()%>)</b></td>
      <td colspan="2"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/vioSearch.defSearchSize;
		if(iSearchResult % vioSearch.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
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
      <%if(WI.fillTextValue("show_id").length() > 0) {%>
      <td  width="10%" height="25" ><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <%}%>
      <td width="15%"><div align="center"><strong><font size="1">LASTNAME</font></strong></div></td>
      <td width="15%"><div align="center"><strong><font size="1">FIRSTNAME</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">MI</font></strong></div></td>
      <%if(WI.fillTextValue("show_gender").length() > 0) {%>
      <td width="5%"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
      <%}if(WI.fillTextValue("show_course").length() > 0) {%>
      <%}if(WI.fillTextValue("show_yr").length() > 0) {%>
      <%}if(WI.fillTextValue("show_section").length() > 0) {%>
      <%}if(WI.fillTextValue("search_foreign").length() > 0) {%>
      <%}if(WI.fillTextValue("show_dob").length() > 0) {%>
      <%}%>
      <td width="5%"><div align="center"><strong><font size="1">VIEW VIOLATION</font></strong></div></td>
    </tr>
    <%
for(int i=0; i<vRetResult.size(); i+=14){%>
    <tr> 
      <%if(WI.fillTextValue("show_id").length() > 0) {%>
      <td height="25"><font size="1"> 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%></a> 
        <%}else{%>
        <%=(String)vRetResult.elementAt(i+1)%> 
        <%}%>
        </font></td>
      <%}%>
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td>&nbsp;<font size="1"> 
        <%if(vRetResult.elementAt(i+4) != null && ((String)vRetResult.elementAt(i+4)).length() > 0){%>
        <%=((String)vRetResult.elementAt(i+4)).charAt(0)%> 
        <%}%>
        </font></td>
      <%if(WI.fillTextValue("show_gender").length() > 0) {%>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5),"n/f")%></font></td>
      <%}if(WI.fillTextValue("show_course").length() > 0) {%>
      <%}if(WI.fillTextValue("show_yr").length() > 0) {%>
      <%}if(WI.fillTextValue("show_section").length() > 0) {%>
      <%}if(WI.fillTextValue("search_foreign").length() > 0) {%>
      <%}if(WI.fillTextValue("show_dob").length() > 0) {%>
      <%}%>
      <td align="center"><a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../../../images/view.gif" width="34" height="25" border="0"></a></td>
    </tr>
    <%}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right"> </div></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
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
<input type="hidden" name="shift_page_basic">
<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
<!-- search finger scan information -->
<input type="hidden" name="fs" value="<%=WI.fillTextValue("fs")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>