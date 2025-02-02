<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.print_pg.value = "";
	document.form_.search_page.value = "";
	document.form_.submit();
}
function SearchPage() {
	document.form_.print_pg.value = "";
	document.form_.search_page.value = "1";
	if(document.form_.loc_index.selectedIndex > 0)
		document.form_.loc_name.value = document.form_.loc_index[document.form_.loc_index.selectedIndex].text;
	else
		document.form_.loc_name.value = "";
	 
	document.form_.submit();
}
function PrintPg() {
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function ViewDetail(strStudID) {
	var loadPg = "./iL_usage_users_dtls.jsp?stud_id="+strStudID+"&sy_from="+
		document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+
		"&semester="+document.form_.semester.value+"&date_from="+
		document.form_.date_from.value+"&date_to="+document.form_.date_to.value;
		
	var win=window.open(loadPg,"myfile",'dependent=yes,width=850,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.ComputerUsage,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

if(WI.fillTextValue("print_pg").length() > 0) {%>
	<jsp:forward page="./iL_usage_users_print.jsp"/>	
<%return;}

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-USAGE DETAILS -user usage detail",
								"iL_usage_users.jsp");
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
														"Internet Cafe Management",
														"USAGE DETAILS",request.getRemoteAddr(),
														"iL_usage_users.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
ComputerUsage compUsage = new ComputerUsage();
Vector vRetResult = null;
int iSearchResult = 0;
if(WI.fillTextValue("search_page").length() > 0) {
	vRetResult = compUsage.getComputerUsageSummaryPerUser(dbOP, request);
	if(vRetResult == null || vRetResult.size() == 0)
		strErrMsg = compUsage.getErrMsg();
	else	
		iSearchResult = compUsage.getSearchCount();
}	
boolean bolIsStaff = false;
if(WI.fillTextValue("is_staff").length() > 0) 
	bolIsStaff = true;

//end of authenticaion code.
%>
<form action="./iL_usage_users.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          USAGE SUMMARY - INTERNET LAB PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td width="62%" height="25">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
      <td width="38%" align="right"><font size="1"><strong>Date / Time :</strong> <%=WI.getTodaysDateTime()%></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">SY/Term</td>
      <td width="82%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp; <select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp; </td>
      <td>Date Range</td>
      <td> <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a> 
        &nbsp;To 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a> 
        <font size="1">(empty date show for complet SY/Term) </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(bolIsStaff)
	strTemp = " checked";
  else	
  	strTemp = "";
%>
		  <input type="checkbox" name="is_staff" value="1"<%=strTemp%> onClick="ReloadPage();">
        Show Staff Internet usage</td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td>&nbsp;</td>
      <td><%if(bolIsStaff){%>
        Employee
        <%}else{%>
        Student
        <%}%>
        ID</td>
      <td width="82%"> <input name="stud_id" type="text" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Location</td>
      <td><select name="loc_index">
          <%=dbOP.loadCombo("location_index","location"," from IC_COMP_LOC order by location",WI.fillTextValue("loc_index"),false)%> 
        </select>
        </td>
    </tr>
    <%if(!bolIsStaff){%>
    <tr> 
      <td width="3%" height="15">&nbsp;</td>
      <td height="15">College</td>
      <td height="15"><select name="c_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="15%" height="25">Course</td>
      <td height="25"><select name="course_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("c_index");
if(strTemp.length() > 0){%>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and c_index="+strTemp+" order by course_name asc",
		  		request.getParameter("course_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
    <%}//if(!bolIsStaff)%>
    <tr> 
      <td height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong>Sort by</strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="39%" height="25"><select name="sort_by_con">
          <option value="asc">Ascending</option>
          <option value="desc">Descending</option>
        </select> <select name="sort_by">
          <option value="id_number">Student ID</option>
          <option value="lname">Lastname</option>
        </select> </td>
      <td width="58%"><a href="javascript:SearchPage();"><img src="../../images/form_proceed.gif" border="0"></a> 
        <font size="1">Click to search</font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><div align="right">
	  <a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
    <tr>
      <td width="66%" ><b> Total Result : <%=iSearchResult%> - Showing(<%=compUsage.getDisplayRange()%>) 
	  <%if(WI.fillTextValue("loc_name").length() > 0) {%>
	  Location : <%=WI.fillTextValue("loc_name")%>
	  <%}%>
	  </b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/compUsage.defSearchSize;
		if(iSearchResult % compUsage.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="SearchPage();">
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


  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFF9F"> 
      <td height="24" colspan="8"><div align="center"><font color="#0000FF"><strong>SUMMARY 
          OF USAGE</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
<%if(!bolIsStaff){%>      
	  <td width="15%"><div align="center"><font size="1"><strong>COLLEGE</strong></font></div></td>
      <td width="15%"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
<%}%>
      <td width="15%"><div align="center"><font size="1"><strong><%if(bolIsStaff){%>EMPLOYEE<%}else{%>STUDENT<%}%> ID</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong> LNAME, FNAME, 
          MI</strong></font></div></td>
      <td width="12%"><strong><font size="1">TOTAL HOURS ALLOWED</font></strong></td>
      <td width="12%"><strong><font size="1">TOTAL HOURS USED</font></strong></td>
      <td width="12%"> <div align="center"><strong><font size="1">TOTAL HOURS REMAINING 
          </font> </strong> </div></td>
      <td width="4%" height="24">&nbsp;</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 8){%>
    <tr bgcolor="#FFFFFF"> 
<%if(!bolIsStaff){%>      
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></font></td>
<%}%>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></font></td>
      <td><a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i + 3)%>");'>
	  	<img src="../../images/view.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
 <%}//only if vRetResult not null
 %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="search_page" value="<%=WI.fillTextValue("search_page")%>">
<input type="hidden" name="print_pg">
<input type="hidden" name="loc_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>