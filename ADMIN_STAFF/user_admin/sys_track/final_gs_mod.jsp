<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript"><!--
function RefreshPage(){
	document.form_.ReloadPage.value="";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function ReloadPage(){
	document.form_.ReloadPage.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function ClearDates(){
	document.form_.date_from.value ="";
	document.form_.date_to.value ="";
}
function PrintPg(){
	document.form_.print_page.value="1";
	document.form_.ReloadPage.value="1";
	this.SubmitOnce("form_");
}

function ViewDetail(strInfoIndex) {
	var pgLoc = "./final_gs_mod_detail.jsp?view_details=1&info_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'dependent=yes,width=500,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./final_gs_mod_print.jsp" />
<%	return;}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-System Tracking","final_gs_mod.jsp");
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
														"System Administration","System Tracking",request.getRemoteAddr(),
														"final_gs_mod.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
SysTrack ST = new SysTrack(request);
strTemp = WI.fillTextValue("page_action");
int iSearchResult = 0;

if(WI.fillTextValue("ReloadPage").compareTo("1") == 0){
	vRetResult = ST.searchGradeMod(dbOP);
	if(vRetResult == null)
		strErrMsg = ST.getErrMsg();
	else	
		iSearchResult = ST.getSearchCount();
}

String[] astrSemester = {"Summer","1st Sem","2nd Sem"," 3rd Sem"};

String[] astrSortByName = {"Date Edited","Employee ID","Student ID","Last Name", "First Name","Subject"};
String[] astrSortByVal  = {"g_sheet_final.last_modified_date","emp.id_number","stud.id_number","stud.lname","stud.fname","sub_code"};

%>
<form name="form_" action="./final_gs_mod.jsp" method="post">
<input type="hidden" name="ReloadPage">
<input type="hidden" name="viewDetail" value="">
<input type="hidden" name="print_page" value="1">

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          System Tracking - Grade Modifications Page ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="13%">Date Edited</td>
      <td width="64%"> <font size="1">from 
        <input name="date_from" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_from")%>" size="12" maxlength="12" readonly="true">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        to</font> <input name="date_to" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="12" maxlength="12" readonly="true">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:ClearDates()"><img src="../../../images/clear.gif" width="55" height="19" border="0"></a> 
        <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to clear 
        dates</font></td>
      <td width="19%"><a href="./final_gs_mod_report.jsp">Go To Other Format</a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Employee ID</td>
      <td colspan="2"><select name="emp_id">
          <option value=""> ALL </option>
          <%=dbOP.loadCombo("distinct user_index","  lname +' . '+ fname  +' &nbsp;&nbsp;&nbsp;('+id_number +')' as emp_name"," from G_SHEET_FINAL_CHNGLOG join user_table on (G_SHEET_FINAL_CHNGLOG.modified_by = user_table.user_index) order by emp_name", WI.fillTextValue("emp_id"),false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student ID</td>
      <td colspan="2"><input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("stud_id")%>" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Subject</td>
      <td colspan="2"><input name="filter_sub" type="text" class="textbox" onKeyUp="AutoScrollListSubject('filter_sub','sub_index',true,'form_');"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("filter_sub")%>" size="16" >
        <font size="1">&nbsp;(enter subject code to auto scroll the subject list box)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"> <select name="sub_index" style="font-size:11px">
          <option value=""> ALL SUBJECTS</option>
          <%=dbOP.loadCombo("distinct sub_index","sub_code +' &nbsp;  ('+ sub_name+')' as list_sub", " from subject where is_del = 0 order by list_sub",
		  				WI.fillTextValue("sub_index"),false)%> </select></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td colspan="3">Sorting Conditions : </td>
    </tr>
    <tr> 
      <td height="30" colspan="4"><table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="33%"><select name="sort_by1">
                <option value="">N/A</option>
                <%=ST.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by1_con">
                <option value="asc">Ascending</option>
                <% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select></td>
            <td width="33%"><select name="sort_by2">
                <option value="">N/A</option>
                <%=ST.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by2_con">
                <option value="asc">Ascending</option>
                <% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select></td>
            <td width="34%"><select name="sort_by3">
                <option value="">N/A</option>
                <%=ST.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by3_con">
                <option value="asc">Ascending</option>
                <%if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
                <option value="desc" selected>Descending</option>
                <%}else{%>
                <option value="desc">Descending</option>
                <%}%>
              </select></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="20" colspan="4">&nbsp;</td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> - Showing(<%=ST.getDisplayRange()%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/ST.defSearchSize;
		if(iSearchResult % ST.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="ReloadPage();">
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
    </tr></table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr bgcolor="#B9B292">
      <td height="25"><div align="center"><strong>LIST OF GRADES MODIFIED 
          <% if (WI.fillTextValue("emp_id").length() > 0){%>
          <br>
          ( by <%=(String)vRetResult.elementAt(9)%> ) 
          <%} // ennd i emp id %>
          </strong></div></td>
    </tr>
</table>


  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="8%"><div align="center"><font size="1"><strong>DATE EDITED</strong></font></div></td>
      <td width="12%" height="25"><div align="center"><strong><font size="1">STUDENT 
          ID</font></strong></div></td>
      <td width="25%"><div align="center"><font size="1"><strong>STUDENT NAME 
          </strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>SCHOOL YEAR (SEMESTER)</strong></font></div></td>
      <td width="23%"><div align="center"><font size="1"><strong>SUBJECT</strong></font></div></td>
      <% if (WI.fillTextValue("emp_id").length() == 0){%>
      <td width="7%"><font size="1"><strong>MODIFIED BY </strong></font></td>
      <%} // ennd i emp id %>
      <td width="9%"><div align="center"><font size="1"><strong>DETAIL</strong></font></div></td>
    </tr>
    <% for(int i =0;i< vRetResult.size(); i +=12){%>
    <tr> 
      <td><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></div></td>
      <td><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%></font></td>
      <td><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5) + " - "+(String)vRetResult.elementAt(i+6) %><br>
          (<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+7))]%>)</font></div></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
      <% if (WI.fillTextValue("emp_id").length() == 0){%>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></td>
      <%}%>
      <td>
	  <% if (((String)vRetResult.elementAt(i+11)).compareTo("0") !=0){%>
	    <div align="center"><a href="javascript:ViewDetail(<%=(String)vRetResult.elementAt(i+10)%>)"><img src="../../../images/view.gif" width="40" height="31" border="0"></a></div>
	  <%}else{%>&nbsp;<%}%>
	  </td>
    </tr>
    <%} //end for loop%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="20"><div align="center"></div></td>
      <% if (WI.fillTextValue("emp_id").length() == 0){%>
      <%} // ennd i emp id %>
    </tr>
    <tr>
      <td height="25"><div align="center"><font size="1"><strong><a href="javascript:PrintPg()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a></strong>click 
          to print list</font></div></td>
    </tr>
  </table>
  <%} // end if vretResutl%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
