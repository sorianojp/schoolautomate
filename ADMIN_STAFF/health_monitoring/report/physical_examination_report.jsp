<%@ page language="java" import="utility.*, health.HMReports ,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_page.value= "";
	document.form_.submit();
}
function StartSearch()
{
	document.form_.print_page.value = "";
	document.form_.executeSearch.value = "1";
	this.SubmitOnce('form_');
}

function PrintReport(strIDNumber){
	if(strIDNumber.length == 0){
		alert("Student id number not found.");
		return;
	}

	var pageLoc = "./physical_examination_report_print.jsp?id_number="+strIDNumber;
	var win=window.open(pageLoc,"PrintReport",'dependent=yes,width=850,height=800,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintBatch(){
	document.form_.print_page.value = "1";
	document.form_.submit();
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){
	
	%>
		<jsp:forward page="./physical_examination_report_print.jsp"></jsp:forward>
	<%return;}
	
	int iSearchResult = 0;
		
	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName = {"ID Number", "Last Name", "College", "Course"};
	String[] astrSortByVal  = {"id_number", "lname", "course_offered.c_index", "stud_curriculum_hist.course_index"};	
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","medical_history.jsp");
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
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"medical_history.jsp");
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

HMReports hmReports = new HMReports();
Vector vRetResult = null;
int iElemCount = 0; 
 
if (WI.fillTextValue("executeSearch").compareTo("1")==0){
	vRetResult = hmReports.getPEReportStudListSPC(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hmReports.getErrMsg();
	else
		iElemCount = hmReports.getElemCount();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<body bgcolor="#8C9AAA" class="bgDynamic">
 <form action="./physical_examination_report.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td width="61%" height="28" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PHYSICAL EXAMINATION REPORT ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="18"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr >
      <td height="25">&nbsp;</td>
      <td height="25">School year</td>
      <td colspan="2">
<%
strTemp = WI.getStrValue(WI.fillTextValue("sy_from"));
%>	  <input name="sy_from" type="text" size="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'>
        to
<%
strTemp = WI.getStrValue(WI.fillTextValue("sy_to"));
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        TERM:
        <select name="semester">
		<option value=""></option>
		<%=CommonUtil.constructTermList(dbOP, request, WI.fillTextValue("semester"))%>
        </select></td>
    </tr>
	  <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%">College</td>
      <td width="78%">
		<select name="c_index" onChange="ReloadPage();" style="width:300px;">
			<%=dbOP.loadCombo("c_index","c_name"," from college where is_del = 0 order by c_name",WI.fillTextValue("c_index"),false)%>
    	</select></td>
    </tr>
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%">Course</td>
      <td width="78%">
		<select name="course_index" onChange="ReloadPage();" style="width:300px;">
	        <option value="">Select Any</option>
			<%
			strTemp = " from course_offered where is_offered = 1 and is_valid =1 "+WI.getStrValue(WI.fillTextValue("c_index")," and c_index = ","","")+
				" order by course_name";
			%>
			<%=dbOP.loadCombo("course_index","course_name",strTemp,WI.fillTextValue("course_index"),false)%>
    	</select></td>
    </tr>
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%">Major</td>
      <td width="78%">
		<select name="major_index" style="width:300px;">
	        <option value=""></option>
			
			<%if(WI.fillTextValue("course_index").length() > 0){
			strTemp = " from major where is_del = 0 "+WI.getStrValue(WI.fillTextValue("course_index")," and course_index = ","","")+
				" order by major_name";
			%>
			<%=dbOP.loadCombo("course_index","course_name",strTemp,WI.fillTextValue("major_index"),false)%>
			<%}%>
    	</select></td>
    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Year Level</td>
	    <td>
		<select name="year_level">
		<option value=""></option>
		<%
		strTemp = WI.fillTextValue("year_level");
		if(strTemp.equals("1"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="1" <%=strErrMsg%>>First Year</option>
		<%		
		if(strTemp.equals("2"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="2" <%=strErrMsg%>>Second Year</option>
		<%		
		if(strTemp.equals("3"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="3" <%=strErrMsg%>>Third Year</option>
		<%		
		if(strTemp.equals("4"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="4" <%=strErrMsg%>>Fourth Year</option>
		<%		
		if(strTemp.equals("5"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="5" <%=strErrMsg%>>Fifth Year</option>
		</select>
		</td>
	    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Last Name </td>
      <td>
	  <select name="last_name_con">
			<%=hmReports.constructGenericDropList(WI.fillTextValue("last_name_con"),astrDropListEqual,astrDropListValEqual)%> 
		</select>
	  <input name="last_name" type="text" value="<%=WI.fillTextValue("last_name")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>First Name </td>
      <td>
	  <select name="first_name_con">
		<%=hmReports.constructGenericDropList(WI.fillTextValue("first_name_con"),astrDropListEqual,astrDropListValEqual)%> 
	</select>
	  <input name="first_name" type="text" value="<%=WI.fillTextValue("first_name")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>ID Number </td>
      <td>
	  <select name="id_con">
					<%=hmReports.constructGenericDropList(WI.fillTextValue("id_con"),astrDropListEqual,astrDropListValEqual)%> 
    			</select>
	  <input name="id_" type="text" value="<%=WI.fillTextValue("id_")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>

    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">SORT BY</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="sort_by1">
			<option value="">N/A</option>
	          <%=hmReports.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select>&nbsp;&nbsp;
			<select name="sort_by1_con">
				<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by2">
			<option value="">N/A</option>
	          <%=hmReports.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
			</select>
			<select name="sort_by2_con">
					<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select></td>
    </tr>
    <tr> 
      <td height="43">&nbsp;</td>
      <td colspan="2"><a href="javascript:StartSearch();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
 <%
 String strIDList = null;
 if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr><td align="center" height="25"><strong>LIST OF STUDENT WITH PHYSICAL EXAMINATION RECORD</strong></td> </tr>
    <tr>
        <td align="right" height="25">
		<a href="javascript:PrintBatch();"><img src="../../../images/print.gif" border="0"></a>
		<font size="1">Click to print batch</font>
		</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr>
		<td width="19%" height="25" align="" class="thinborder"><strong>ID Number</strong></td>
		<td width="38%" align="" class="thinborder"><strong>Student Name</strong></td>
		<td width="29%" align="" class="thinborder"><strong>Course</strong></td>
		<td width="14%" align="center" class="thinborder"><strong>Print</strong></td>
	</tr>
	<%for(int i = 0; i < vRetResult.size(); i+=iElemCount){
	if(strIDList == null)
		strIDList = (String)vRetResult.elementAt(i+1);
	else
		strIDList += ", "+(String)vRetResult.elementAt(i+1);
	%>
  	<tr>
  	    <td height="25" align="" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
  	    <td align="" class="thinborder"><%=strTemp%></td>
  	    <td align="" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
  	    <td align="center" class="thinborder">
		<a href="javascript:PrintReport('<%=vRetResult.elementAt(i+1)%>')"><img src="../../../images/print.gif" border="0"></a></td>
    </tr>
	<%}%>
  </table>
<%}
if(strIDList != null){
	request.getSession(false).removeAttribute("pe_spc_id_list");
	request.getSession(false).setAttribute("pe_spc_id_list",strIDList);
}
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td height="10" colspan="9">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
