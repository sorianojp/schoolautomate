<%
	String strTemp = request.getParameter("print_pg");
	if(strTemp != null && strTemp.equals("1")){%>
	<jsp:forward page="./grad_search_print.jsp"></jsp:forward>
<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%//response.setHeader("Pragma","No-Cache");
//response.setDateHeader("Expires",0);
//response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
//response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">

function ViewAll() {
	document.form_.viewall.value="1";
	document.form_.page_action.value="";
	document.form_.print_pg.value="";
	document.form_.submit();
}

function ReloadPage(){
	document.form_.page_action.value="";
	document.form_.print_pg.value="";
	document.form_.submit();
}

function DeleteRecord(strIndex){
	document.form_.page_action.value="0";
	document.form_.info_index.value =strIndex;
	document.form_.print_pg.value="";
	document.form_.submit();
}

function EditRecord(strIndex){
	location = "./grad_mgt.jsp?info_index="+strIndex+"&prepareToEdit=1";
}

function SearchStudent(){
	document.form_.viewall.value="1";
	document.form_.page_action.value="";
	document.form_.print_pg.value="";
	document.form_.submit();
}
function loadCourse() {
	if(document.form_.major_index)
		document.form_.major_index[document.form_.major_index.selectedIndex].value = "";
		
	document.form_.viewall.value="";
	document.form_.page_action.value="";
	document.form_.print_pg.value="";
	document.form_.submit();
}
function loadCollege() {
	document.form_.course_index.selectedIndex = 0;
	if(document.form_.major_index)
		document.form_.major_index[document.form_.major_index.selectedIndex].value = "";
	document.form_.viewall.value="";
	document.form_.page_action.value="";
	document.form_.print_pg.value="";
	document.form_.submit();
}
function PrintReport() {
	if(document.form_.get_summary && document.form_.get_summary.checked) {
		if(document.form_.yr_grad.value.length == 0) {
			alert("Please enter year of graudation.");
			document.form_.yr_grad.focus();
			return;
		}
	}
	document.form_.print_pg.value = '1';
	document.form_.submit();
}
function CheckGradYear() {
	if(document.form_.get_summary.checked) {
		if(document.form_.yr_grad.value.length == 0) {
			alert("Please enter year of graudation.");
			document.form_.yr_grad.focus();
			return;
		}
	}
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.GraduationDataReport,
							enrollment.EntranceNGraduationData,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	boolean bolShowEditInfo = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_mgt.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_mgt.jsp");
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
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Course","Year of Grad", "Month of Grad","Semester"};
String[] astrSortByVal     = {"id_number","lname","fname","course_index","grad_year","grad_month","semester"};
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
String[] astrDropListMonth = {"","January", "February", "March", "April", "May", "June", "July", 
							  "August", "September", "October","November", "December"};
String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd sem"};
GraduationDataReport gdr = new GraduationDataReport(request);
int iSearchResult = 0 ;

Vector vRetResult = null;
if (WI.fillTextValue("page_action").compareTo("0") == 0){
 	EntranceNGraduationData eng = new EntranceNGraduationData();
	vRetResult = eng.operateOnGraduationData(dbOP,request,0);
	if (vRetResult == null){
		strErrMsg = eng.getErrMsg();
	}else{
		strErrMsg = "Graduation data removed successfully";
	}
}

if (WI.fillTextValue("viewall").length() !=0){
	vRetResult = gdr.viewAllGraduates(dbOP);
	if(vRetResult == null)
		strErrMsg = gdr.getErrMsg();
	else {	
		iSearchResult = gdr.getSearchCount();
		if(WI.fillTextValue("get_summary").length() > 0) 
			vRetResult.remove(0);
	}	
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<form name="form_" action="./grad_search.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          GRADUATION DATA PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td height="30" colspan="4" ><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="22" ><font size="1"><strong>Student ID </strong></font></td>
      <td width="37%" ><select name="id_number_con">
      <%=gdr.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.fillTextValue("stud_id")%>" size="20"></td>
      <td width="7%" ><font size="1"><strong>Grad. Year </strong></font></td>
      <td width="39%" height="22" style="font-size:9px;"><input name="yr_grad" type="text" class="textbox" id="yr_grad"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" value="<%=WI.fillTextValue("yr_grad")%>" size="4" maxlength="4"> 
        &nbsp;
		or grad yr Range 
		<input name="grad_yr_fr" type="text" class="textbox" id="yr_grad"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" value="<%=WI.fillTextValue("grad_yr_fr")%>" size="4" maxlength="4">
	   - to 
	   <input name="grad_yr_to" type="text" class="textbox" id="yr_grad"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" value="<%=WI.fillTextValue("grad_yr_to")%>" size="4" maxlength="4">
	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td width="15%" height="22" ><font size="1"><strong>First Name </strong></font></td>
      <td ><strong> 
        <select name="fname_con" id="fname_con">
          <%=gdr.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select>
        <input name="fname" type="text" size="20" class="textbox"  value="<%=WI.fillTextValue("fname")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        </strong></td>
      <td ><font size="1"><strong>Grad. Month </strong></font></td>
      <td height="22" > <select name="month_grad" id_month="month_grad">
          <option  value=""></option>
          <%for(int i =1; i < 13; i++){ 
			if (WI.fillTextValue("month_grad").compareTo(Integer.toString(i)) == 0){%>
          <option value="<%=i%>" selected><%=astrDropListMonth[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrDropListMonth[i]%></option>
          <%}}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="24" ><font size="1"><strong>Last Name </strong></font></td>
      <td ><strong>
        <select name="lname_con" id="lname_con">
          <%=gdr.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
        <input name="lname" type="text" size="20" class="textbox" value="<%=WI.fillTextValue("lname")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </strong></td>
      <td ><font size="1"><strong>Semester</strong></font></td>
	 	  
      <td height="24" > <strong> 
        <select name="semester" id_month="semester">
          <option  value="">&nbsp;</option>
          <% if (WI.fillTextValue("semester").compareTo("0") == 0){%>
          <option  value="0" selected>Summer</option>
          <%}else {%>
          <option value="0">Summer</option>
          <%}if (WI.fillTextValue("semester").compareTo("1") == 0) {%>
          <option  value="1" selected>1st</option>
          <%}else {%>
          <option value="1">1st</option>
          <%}if (WI.fillTextValue("semester").compareTo("2") == 0) {%>
          <option  value="2" selected>2nd</option>
          <%}else {%>
          <option value="2">2nd</option>
          <%}if (WI.fillTextValue("semester").compareTo("3") == 0) {%>
          <option  value="3" selected>3rd</option>
          <%}else {%>
          <option value="3">3rd</option>
          <%}%>
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td ><strong><font size="1">SO Number </font></strong></td>
      <td ><strong>
        <select name="so_num_con" id="so_num_con">
          <%=gdr.constructGenericDropList(WI.fillTextValue("so_num_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
        <input name="so_num" type="text" class="textbox" id="so_num"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("so_num")%>" size="20">
      </strong></td>
      <td ><font size="1"><strong>Gender</strong></font></td>
      <td>
	  <select name="gender">
	  <option value="">All</option>
<%
strTemp = WI.fillTextValue("gender");
if(strTemp.equals("0"))
	strErrMsg= " selected";
else	
	strErrMsg = "";
%>		<option value="0"<%=strErrMsg%>>Male</option>	  
<%
if(strTemp.equals("1"))
	strErrMsg= " selected";
else	
	strErrMsg = "";
%>		<option value="1"<%=strErrMsg%>>Female</option>	  
	  </select>
	  
	  </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td ><strong><font size="1">College</font></strong></td>
      <td colspan="3" >
	  <select name="c_index" onChange="loadCollege();">
      	<option value="">Select Any</option>
        <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",WI.fillTextValue("c_index"), false)%> 
	  </select>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td width="15%" height="25" ><strong><font size="1">Course </font></strong></td>
      <td width="83%" height="25" > 
<%
strTemp = " from course_offered where IS_VALID=1 ";
if(WI.fillTextValue("c_index").length() > 0) 
	strTemp += " and c_index = "+WI.fillTextValue("c_index");
strTemp += " order by course_name asc";
%>
	  <select name="course_index" onChange="loadCourse();">
      	<option value="">Select Any</option>
        <%=dbOP.loadCombo("course_index","course_name",strTemp, WI.fillTextValue("course_index"), false)%> 
	  </select>
	  </td>
    </tr>
    <tr> 
      <td height="20" >&nbsp;</td>
      <td height="25" ><strong><font size="1">Major </font></strong></td>
      <td height="25" > <% if (WI.fillTextValue("course_index").length()!=0){ %> <select name="major_index">
          <option value="">Select Any</option>
          <%=dbOP.loadCombo("major_index","major_name"," from major where IS_DEL=0 and course_index =" + WI.fillTextValue("course_index") + " order by major_name asc",	WI.fillTextValue("major_index"), false)%> </select> <%}%> </td>
    </tr>
    <tr> 
      <td height="20" >&nbsp;</td>
      <td><strong><font size="1">HS graduated From</font></strong></td>
      <td>
	  <select name="sec_sch_index" style="font-size:11px; width:600px;">
	  <option value=""></option>
          <%=dbOP.loadCombo("SCH_ACCR_INDEX","sch_code + ' ::: '+SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 and exists (select * from entrance_data where sec_sch_index = sch_accr_index) order by SCH_NAME",WI.fillTextValue("sec_sch_index"),false)%> </select>
		  <font size="1">Taken from Entrance data of TOR</font>
	  </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" ><a href="javascript:ViewAll();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="20" >&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="11%">&nbsp;&nbsp;<strong>SORT BY</strong></td>
      <td width="26%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=gdr.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select> <br> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="29%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=gdr.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> <br> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="34%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=gdr.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> <br> <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td><hr size="1"></td>
    </tr>
  </table>
  <%  if (vRetResult != null && vRetResult.size() > 0){ %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"><div align="center"><strong>SEARCH RESULTS</strong></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3" style="font-size:9px" align="right">
	  <%if(strSchCode.startsWith("CGH")){%>
	  <input type="checkbox" name="get_summary" value="checked" <%=WI.fillTextValue("get_summary")%> onClick="CheckGradYear();">
	  Show Summary &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%>
	  <select name="no_of_rows" style="font-size:11px;">
<%
int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("no_of_rows"),"35"));
	for(int i = 30; i < 60; ++i) {
		if(iDef == i)
			strTemp = " selected";
		else	
			strTemp = "";
	%><option value="<%=i%>"<%=strTemp%>><%=i%></option>
<%}%>	  
	  </select>
	  
	  Number of rows Per page.
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  <a href="javascript:PrintReport();"><img src="../../../images/print.gif" border="0"></a>Print Result &nbsp;</td>
    </tr>
<%if(strSchCode.startsWith("UDMC") || true){%>
    <tr>
      <td height="25" colspan="3" style="font-size:9px"><b><u>Show</u></b> <br>
		  <input type="checkbox" value="1" name="show_graddate"> Date of Graduation 
		  <input type="checkbox" value="1" name="show_so"> SO Number 
		  <input type="checkbox" value="1" name="show_address"> Address 
		  <input type="checkbox" value="1" name="show_birthdate"> Birth Date 
		  <input type="checkbox" value="1" name="show_birthplace"> Birth Place 
		  <input type="checkbox" value="1" name="show_hs_grad_fr"> Show HS graduated from 
	  </td>
    </tr>
<%}%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="67%"><b>Total Students : <%=iSearchResult%> - Showing(<%=gdr.getDisplayRange()%>)</b></td>
      <td width="31%">&nbsp; 
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/gdr.defSearchSize;
		if(iSearchResult % gdr.defSearchSize > 0) ++iPageCount;

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
  <table width="100%" border="1" cellspacing="0" cellpadding="1" bgcolor="#FFFFFF">
    <tr> 
      <td width="11%" height="25"><div align="center"><strong><font size="1">ID NUMBER</font></strong></div></td>
      <td width="22%"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
      <td width="18%"><div align="center"><font size="1"><strong>DATE OF GRADUATION</strong></font></div></td>
      <td width="24%"><div align="center"><strong><font size="1">COURSE/MAJOR</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">SO NUMBER</font></strong></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <% 	for (int i= 2; i < vRetResult.size(); i+=21) {
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+10),"");
		
		if (strTemp.length() == 0){
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+12),"") + 
						WI.getStrValue((String)vRetResult.elementAt(i+11),"-","","&nbsp");
		}
		
		if ((String)vRetResult.elementAt(i+15) != null){
			strTemp += " (" + astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+15))] + ")";
		}
	%>
    <tr> 
      <td height="25"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"N/A")%></font></td>
      <td><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),8).toUpperCase()%></font></td>
      <td><font size="1">&nbsp;<%=strTemp%> </font></td>
      <td><font size="1"><%=((String)vRetResult.elementAt(i+13))+WI.getStrValue((String)vRetResult.elementAt(i+14),"/","","")%></font></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"N/A")%></font></div></td>
      <td><a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a><a href="javascript:EditRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a></td>
    </tr>
    <%} //end for loop%>
  </table>
  <%} //end if vRetResult !=null %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="viewall" value="">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">

<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
