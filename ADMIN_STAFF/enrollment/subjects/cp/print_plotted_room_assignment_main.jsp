<%@ page language="java" import="utility.*,enrollment.SubjectSection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

if(WI.fillTextValue("batch_print").equals("1")){%>
	<jsp:forward page="print_cp_plotted_room_assignment_batch.jsp" />	

<%return;}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Class Program</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//strPrintStat = 0 = view only.
function ReloadPage()
{
	document.ssection.batch_print.value="";
	document.ssection.submit();
}
function PrintOne(strRoomI) {
	var strViewClassSize = ""
	if(document.ssection.show_class_size.checked)
		strViewClassSize = "1";
	var printLoc = "./print_plotted_room_assignment_one.jsp?school_year_fr="+
					document.ssection.school_year_fr.value+"&school_year_to="+
					document.ssection.school_year_to.value+"&offering_sem="+
					document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value+
					"&room_i="+strRoomI+"&show_class_size="+strViewClassSize;
	
	var win=window.open(printLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ViewOne(strRoomI, strIsMWF) {
	var printLoc = "./viewRoomAssignment.jsp?school_year_fr="+
					document.ssection.school_year_fr.value+"&school_year_to="+
					document.ssection.school_year_to.value+"&offering_sem="+
					document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value+"&room_i="+
					strRoomI;
	
	if(strIsMWF == '1')
		printLoc += "&show_mwf=1";

	var win2=window.open(printLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win2.focus();
}

function SelALL() {
	var iMaxDisp = document.ssection.max_disp.value;
	if(iMaxDisp < 1) 
		return;
	
	var bolChkStat = document.ssection.sel_all.checked;
	
	for(i = 0; i < iMaxDisp; ++i) {
		eval('objChkBox = document.ssection._'+i);
		if(!objChkBox)
			continue;
		objChkBox.checked = bolChkStat;
	}
}
function PrintPg() {
	document.ssection.batch_print.value = '1';
	document.ssection.submit();
}
function ViewConflict() {
	var strPgLoc = "../subject_list_with_conflict.jsp?sy_from="+document.ssection.offering_sem.value+
					"&semester="+document.ssection.offering_sem[document.ssection.offering_sem.selectedIndex].value;
	var win2=window.open(strPgLoc,"PrintWindow",'width=600,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win2.focus();
}
</script>

<body bgcolor="#FFFFFF" topmargin='0' bottommargin='0'>
<%
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-print class program per plotted room assignment","print_plotted_room_assignment.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														null);
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

SubjectSection SS = new SubjectSection();
Vector vRetResult = null;

if(WI.fillTextValue("form_proceed").equals("1") && WI.fillTextValue("room_i").length() > 0)  {
	vRetResult = SS.getRoomAssignmentDetail(dbOP, request);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
	//System.out.println(vRetResult);
}

String strSYFrom = null;
String strSem    = null;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="ssection" action="./print_plotted_room_assignment_main.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr>
      <td height="25" colspan="3" align="center"><strong>:::: PRINT PLOTTED ROOM ASSIGNMENT ::::</strong></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2"> <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="63%" height="25" >School year/Term : 
<%
strSYFrom = WI.fillTextValue("school_year_fr");
if(strSYFrom.length() ==0) 
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="school_year_fr" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ssection","school_year_fr","school_year_to")'> 
<%
strTemp = WI.fillTextValue("school_year_to");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        - 
        <input name="school_year_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
        - 
        <select name="offering_sem">
          <option value="0">Summer</option>
          <%
strSem = WI.fillTextValue("offering_sem");
if(strSem.length() ==0)
	strSem = (String)request.getSession(false).getAttribute("cur_sem");
if(strSem.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strSem.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strSem.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
      <td width="35%" height="25" >
	  <%if(strSchCode.startsWith("CIT")){%>
	  	<a href="javascript:ViewConflict();">View Conflict in Class Program</a> 
	  <%}%>
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="2" align="center">
        <input name="image" type="image" onClick="ReloadPage();" src="../../../../images/form_proceed.gif">      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%if(strSYFrom.length() > 0) {
strTemp = " select room_index, room_number from e_room_detail where exists (select * from e_room_assign "+
			"join e_sub_section on (e_sub_section.sub_sec_index = e_room_assign.sub_sec_index) "+
			"join subject on (subject.sub_index = e_sub_section.sub_index) "+
			"where room_index = e_room_detail.room_index "+
			"and e_sub_section.offering_sy_from = "+strSYFrom+" and offering_sem = "+strSem+" and "+
			"e_room_assign.is_valid = 1 and e_sub_section.is_valid = 1 and subject.is_del = 0) order by room_number";//limits only college offering.
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
String strRoomIndex = null;
String strRoomNumber = null;
%>	  
    <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
	<tr>
	<%
	strTemp = WI.fillTextValue("show_class_size");
	if(strTemp.equals("1"))
		strErrMsg = "checked";
	else
		strErrMsg = "";
	%>
	 <td width="51%">
	 <input type="checkbox" name="show_class_size" value="1" <%=strErrMsg%>>Click to show class size
	 </td>
	  <td width="49%" align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>Print Selectd Sections.</td>
	 
	</tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr style="font-weight:bold">
    <td width="5%" class="thinborder">Count</td>
  	<td width="15%" class="thinborder" align="center">Select All<br>
		<input type="checkbox" name="sel_all" onClick="SelALL();">	</td>
    <td width="10%" class="thinborder" align="center">Print One </td>
    <td width="10%" class="thinborder" align="center">View One (MWF) </td>
    <td width="10%" class="thinborder" align="center">View One </td>
  	<td width="50%" class="thinborder" height="25">Room Number </td>
  </tr>
<%
int iMaxDisp = 0;
while(rs.next()) {
++iMaxDisp;
strRoomIndex  = rs.getString(1);
strRoomNumber = rs.getString(2);
%>
   <tr>
     <td class="thinborder"><%=iMaxDisp%>. </td>
  	<td class="thinborder" align="center"><input type="checkbox" name="_<%=iMaxDisp%>" value="<%=strRoomIndex%>"></td>
    <td class="thinborder" align="center"><a href='javascript:PrintOne("<%=strRoomIndex%>");'><img src="../../../../images/print.gif" border="0"></a></td>
    <td class="thinborder" align="center"><a href='javascript:ViewOne("<%=strRoomIndex%>","1");'><img src="../../../../images/view.gif" border="0"></a></td>
    <td class="thinborder" align="center"><a href='javascript:ViewOne("<%=strRoomIndex%>","0");'><img src="../../../../images/view.gif" border="0"></a></td>
  	<td class="thinborder" height="25" onClick="SelOne(document.ssection._<%=iMaxDisp%>);"><%=strRoomNumber%></td>
   </tr>
<%}%>
  </table>
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
<%}%>

<input type="hidden" name="form_proceed">
<input type="hidden" name="batch_print">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
