<%@ page language="java" import="utility.*,search.StudentFingerInfo,java.util.Vector" %>
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
<title>Search Student Without Finger Data</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../jscript/common.js"></script>
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
	var pgLoc = "./stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function TogglePage(){
	document.search_util.shift_page_basic.value = "1";
	this.SubmitOnce("search_util");
}
function TogglePage2(){
	document.search_util.shift_page_basic.value = "2";
	this.SubmitOnce("search_util");
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
function focusID() {
	document.search_util.id_number.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;

// if this page is calling print page, i have to forward page to print page.
	if (WI.fillTextValue("shift_page_basic").compareTo("1") == 0){%>
		<jsp:forward page="./srch_stud_basic.jsp" />
	<%	return;
	}else if (WI.fillTextValue("shift_page_basic").compareTo("2") == 0){%>
		<jsp:forward page="./srch_stud_temp.jsp" />
	<%	return;
	}
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./srch_stud_finger_data_print.jsp" />
	<%	return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Students","srch_stud_finger_data.jsp");
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
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender","Course"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","course_name"};


int iSearchResult = 0;

StudentFingerInfo searchStud = new StudentFingerInfo(request);
if(WI.fillTextValue("searchStudent").compareTo("1") == 0){
	vRetResult = searchStud.searchGeneric(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}

%>
<form action="./srch_stud_finger_data.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SEARCH STUDENT WITHOUT FINGER DATA PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5"> <%
strTemp = WI.fillTextValue("show_only_enrolled");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_only_enrolled" value="1" <%=strTemp%>>
        Show only the students currently enrolled (please enter SY - Summer information)</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Student ID </td>
      <td width="10%"><select name="id_number_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="26%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
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
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>SY-SEM</td>
      <td><input name="sy_from" type="text" size="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("search_util","sy_from","sy_to")'>
        to 
        <input name="sy_to" type="text" size="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="">N/A</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
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
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>Year Level</td>
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
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5"><input name="search_elem" type="checkbox" id="search_elem" value="1"  onClick="TogglePage()">
        Search elementary/high school students
        <input name="search_temp" type="checkbox" value="1"  onClick="TogglePage2()">
        Search temporary student.</td>
    </tr>
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
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
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
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
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
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
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
      <td><input type="image" src="../images/form_proceed.gif" onClick="SearchStudent();"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"><%
	  if(WI.fillTextValue("opner_info").length() > 0){%>
	  NOTE : Please click ID number to copy ID to form it is called from.
	  <%}%></td>
      <td height="25" align="right">Number of 
        Students Per Page: 
        <select name="num_stud_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select><a href="javascript:PrintPg();">
        <img src="../images/print.gif" border="0"></a> <font size="1">click to 
        print result</font></td>
    </tr>
    <tr> 
      <td height="32" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF STUDENT WITHOUT FINGER DATA</font></strong></div></td>
    </tr>
    <tr> 
      <td width="66%" ><b> Total Students : <%=iSearchResult%> - Showing(<%=searchStud.getDisplayRange()%>)</b></td>
      <td width="34%"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchStud.defSearchSize;
		if(iSearchResult % searchStud.defSearchSize > 0) ++iPageCount;

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
      <td  width="11%" height="25" ><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="17%"><div align="center"><strong><font size="1">LASTNAME</font></strong></div></td>
      <td width="19%"><div align="center"><strong><font size="1">FIRSTNAME</font></strong></div></td>
      <td width="4%"><div align="center"><strong><font size="1">MI</font></strong></div></td>
      <td width="6%"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
      <td width="33%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">VIEW DETAIL</font></strong></div></td>
    </tr>
    <%
for(int i=0; i<vRetResult.size(); i+=9){%>
    <tr> 
      <td height="25"><font size="1">
	  <%if(WI.fillTextValue("opner_info").length() > 0) {%>
	  <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'>
	  <%=(String)vRetResult.elementAt(i+1)%></a>
	  <%}else{%>
	  <%=(String)vRetResult.elementAt(i+1)%>
	  <%}%>
	  </font></td>
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td>&nbsp;<font size="1"> 
        <%if(vRetResult.elementAt(i+4) != null && ((String)vRetResult.elementAt(i+4)).length() > 0){%>
        <%=((String)vRetResult.elementAt(i+4)).charAt(0)%> 
        <%}%>
        </font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5),"n/f")%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+6)%> 
        <%
	  if(vRetResult.elementAt(i+7) != null){%>
        /<%=(String)vRetResult.elementAt(i+7)%> 
        <%}%>
        </font></td>
      <td align="center"><a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../images/view.gif" width="34" height="25" border="0"></a></td>
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
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../images/print.gif" border="0"></a> 
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>