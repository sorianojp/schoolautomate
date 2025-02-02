<%@ page language="java" import="utility.*,search.SearchStudent,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();
boolean bolPreventReload = false;
if(WI.fillTextValue("prevent_reload").length() > 0) 
	bolPreventReload = true;		
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.search_util.print_pg.value = "1";
	document.search_util.submit();	
}
function ReloadPage()
{
	document.search_util.searchStudent.value = "";
	document.search_util.print_pg.value = "";
	document.search_util.submit();
}
function SearchStudent()
{
	document.search_util.searchStudent.value = "1";
	document.search_util.print_pg.value = "";
	document.search_util.submit();
}
function ViewDetail(strStudID)
{
//popup window here. 
	var pgLoc = "./stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function TogglePage(){
	document.search_util.shift_page_college.value = "1";
	document.search_util.submit();
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strStudID)
{
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strStudID;
	window.opener.focus();
	<%
	if(strFormName != null && !bolPreventReload){%>
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
	if (WI.fillTextValue("shift_page_college").compareTo("1") == 0){%>
		<jsp:forward page="./srch_stud.jsp" />
	<%	return;
	}

	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./srch_stud_basic_print.jsp" />
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
String[] astrSortByName    = {"Student ID","Lastname","Firstname","Gender","GRADE LEVEL"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","year_level"};


int iSearchResult = 0;

SearchStudent searchStud = new SearchStudent(request);
if(WI.fillTextValue("searchStudent").compareTo("1") == 0){
	vRetResult = searchStud.searchBasicEduStudent(dbOP,request);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}

%>
<form action="./srch_stud_basic.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SEARCH STUDENT - BASIC EDUCATION PAGE ::::</strong></font></div></td>
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
      <td><input name="sy_from" type="text" size="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("search_util","sy_from","sy_to")' maxlength=4>
        to 
        <input name="sy_to" type="text" size="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
        -  
		<select name="semester">
	  	<option value="1"> Regular</option>
<%
strTemp = WI.fillTextValue("semester");
if (strTemp.length()==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if (strTemp.equals("0")){%>
		<option value="0" selected> Summer</option>
		<%}else{%>
		<option value="0" > Summer</option>
		<%}%>
	  </select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td class="thinborderALL"><%if(WI.fillTextValue("fs").length() > 0) {//show only fs search is called.
strTemp = WI.fillTextValue("fs_nodata");
if(strTemp.length() > 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>	  <div style="background-color:#CCCCCC;color:#0000FF;font-weight:bold"><input type="checkbox" name="fs_nodata" value="1"<%=strTemp%>>
          Show students without Finger Scan DATA</div></td>

<%}%></td>
    </tr>
    <tr>
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
      <td><%strTemp = WI.fillTextValue("g_level");%> 
	  	  <select name="g_level">
			  <option value="">ALL</option>
			  <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",strTemp,false)%> 
		  </select>	  </td>
      <td>&nbsp;</td>
      <td>Status</td>
      <td>
	  <select name="status_index">
          <option value=""></option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where is_for_student = 1 order by status asc",
					WI.fillTextValue("status_index"), false)%> </select>	 </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5"><input name="search_elem" type="checkbox" id="search_elem" value="1" onClick="TogglePage()">
        Search collegiate/graduates students</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="5" class="thinborderALL" bgcolor="#DDDDDD">
<%
strTemp = WI.fillTextValue("show_gender");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
if(request.getParameter("print_pg") == null)
	strTemp = " checked";
%> 
	<!--
		<input type="checkbox" name="show_gender" value="1"<%=strTemp%>> Show Gender 
	--->
<%
strTemp = WI.fillTextValue("show_dob");
if(strTemp.compareTo("1") == 0)
	strTemp = " checked";
else	
	strTemp = "";
%> 
	<input type="checkbox" name="show_dob" value="1"<%=strTemp%>> Show DOB
&nbsp;&nbsp;
	<input type="checkbox" name="show_section" value="checked"<%=WI.fillTextValue("show_section")%>> Show Section
	  </td>
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
      <td>
	<input type="image" src="../images/form_proceed.gif" onClick="document.search_util.searchStudent.value='1';document.search_util.print_pg.value=''">
	</td>
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
      <td height="25" align="right"><a href="javascript:PrintPg();"><img src="../images/print.gif" border="0"></a> 
        <font size="1">click to print result</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
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
<%
boolean bolShowDOB     = false;
boolean bolShowSection = false;
if(WI.fillTextValue("show_dob").length() > 0) 
	bolShowDOB = true;
if(WI.fillTextValue("show_section").length() > 0) 
	bolShowSection = true;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr align="center" style="font-weight:bold">   
      <td  width="11%" height="25" ><font size="1">STUDENT ID</font></td>
      <td width="17%"><font size="1">LASTNAME</font></td>
      <td width="19%"><font size="1">FIRSTNAME</font></td>
      <td width="4%"><font size="1">MI</font></td>
      <td width="6%"><font size="1">GENDER</font></td>
<%if(bolShowDOB) {%>
      <td width="12%"><font size="1">DOB</font></td>
<%}%>
      <td width="30%"><font size="1">GRADE LEVEL</font></td>
<%if(bolShowSection) {%>
     <td width="10%"><font size="1">SECTION</font></td>
<%}%>
    </tr>
<%
int iNoOfFields = 9;
if(bolShowDOB) 
	iNoOfFields = 11;
if(bolShowSection) 
	iNoOfFields = 12;
	
for(int i=0; i<vRetResult.size(); i+=iNoOfFields){%>
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
<%if(bolShowDOB) {%>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+10),"not set")%></td>
<%}%>
      <td><div align="center"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+6)%> 
          <%
	  if(vRetResult.elementAt(i+7) != null){%>
          - <%=(String)vRetResult.elementAt(i+7)%> 
          <%}%>
          </font></div></td>
<%if(bolShowSection) {%>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+11),"not set")%></td>
<%}%>
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
<input type="hidden" name="shift_page_college">
<!-- Instruction -- set the opner_from_name to the parent window to copy the student ID -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">


<!-- search finger scan information -->
<input type="hidden" name="fs" value="<%=WI.fillTextValue("fs")%>">

<input type="hidden" name="prevent_reload" value="<%=WI.fillTextValue("prevent_reload")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>