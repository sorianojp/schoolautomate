<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrConvertSem= {"Summer","1st Term","2nd Term","3rd Term","4th Term"};

	WebInterface WI = new WebInterface(request);
	
	

//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment.jsp");
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
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
							//							"fee_adjustment.jsp");
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

String[] astrSortByName = {"Course","Year Level","Last Name","Grant Name"};
String[] astrSortByVal = {"course_offered.course_code","stud_curriculum_hist.year_level",
	"user_table.lname","FA_FEE_ADJUSTMENT.MAIN_TYPE_NAME"};

ConstructSearch conSearch = new ConstructSearch();
//end of authenticaion code.
Vector vRetResult = null;
ReportFeeAssessment rFA = new ReportFeeAssessment();
//enrollment.ReportFeeAssessmentExtn rFA = new enrollment.ReportFeeAssessmentExtn();
if(WI.fillTextValue("showdetails").length() > 0) {
	vRetResult = rFA.getStudListAssistance(dbOP,request);
	if(vRetResult == null) {
		strErrMsg = rFA.getErrMsg();
	}
}




String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
//strSchCode = "DLSHSI";
boolean bolIsCLDH = true;//strSchCode.startsWith("CLDH");
boolean bolIsDLSHSI = strSchCode.startsWith("DLSHSI");

boolean bolShowLvlTotal = false;
if(WI.fillTextValue("sort_by1").indexOf("year_level") > -1 || 
	WI.fillTextValue("sort_by2").indexOf("year_level") > -1 || 
	WI.fillTextValue("sort_by3").indexOf("year_level") > -1)
	bolShowLvlTotal = true;	


boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
boolean bolShowApprovalNumber = false;
if(WI.fillTextValue("show_approval_no").length() > 0) 	
	bolShowApprovalNumber = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css"  type="text/css" rel="stylesheet">
<link href="../../../css/tableBorder.css"  type="text/css" rel="stylesheet">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }

    TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js" type="text/javascript"></script>
<script language="JavaScript">
<!--
function ReloadPage()
{ 
	document.form_.showdetails.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_"); 
}

function ShowDetails(){
	document.form_.print_page.value = "";
	document.form_.showdetails.value = 1;
	this.SubmitOnce("form_"); 
}

function PrintPg(){

	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"2\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"2\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font>";
	strInfo +="<font size =\"2\"><%=SchoolInformation.getInfo2(dbOP,false,false)%></font>";
	strInfo +="</div><br>";
	document.bgColor = "#FFFFFF";
	
	var oRows = document.getElementById('header').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i) 
		document.getElementById('header').deleteRow(0);
		
/**
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);	
	document.getElementById('header').deleteRow(0);	
	document.getElementById('header').deleteRow(0);	
	document.getElementById('header').deleteRow(0);	
**/
	//strTemp is set in Java code above
	oRows = document.getElementById('searchTable').getElementsByTagName('tr');
	iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i) 
		document.getElementById('searchTable').deleteRow(0);
		
/**
	document.getElementById('searchTable').deleteRow(0);
	document.getElementById('searchTable').deleteRow(0);
	
	document.getElementById('searchTable').deleteRow(0);
	document.getElementById('searchTable').deleteRow(0);
**/
	
	document.getElementById('myADTable').deleteRow(0);
	document.getElementById('myADTable').deleteRow(0);
	this.insRow(0, 1, strInfo);
	document.getElementById('footer').deleteRow(0);	
	document.getElementById('footer').deleteRow(0);
	window.print();
}
function PrintPgNew() {
	var strPrintSummaryOption = "";
	if(document.form_.print_summary[0].checked)
		strPrintSummaryOption = "0";
	else if(document.form_.print_summary[1].checked)
		strPrintSummaryOption = "1";
	else if(document.form_.print_summary[2].checked)
		strPrintSummaryOption = "2";
	else if(document.form_.print_summary[3].checked)
		strPrintSummaryOption = "3";
	else if(document.form_.print_summary[4] && document.form_.print_summary[4].checked)
		strPrintSummaryOption = "4";
	//alert(strPrintSummaryOption);
	
	var pgLoc = "";
	if(strPrintSummaryOption == "2" || strPrintSummaryOption == "3") 
		pgLoc = "./list_educational_assistance_print_summary_per_grant.jsp?print_summary="+strPrintSummaryOption+"&";
	else if(strPrintSummaryOption == "4")
		pgLoc = "./list_educational_assistance_ub.jsp?";
	else if(strPrintSummaryOption != "") 
		pgLoc = "./list_educational_assistance_print_summary.jsp?print_summary="+strPrintSummaryOption+"&";
	else
		pgLoc = "./list_educational_assistance_fatima.jsp?";
	if(document.form_.unit_enrolled && document.form_.unit_enrolled.checked)
		pgLoc += "unit_enrolled=1&";
	location = pgLoc+"fatima_format=1&sy_from="+document.form_.sy_from.value+	
				"&sy_to="+document.form_.sy_to.value+"&semester="+
				document.form_.semester[document.form_.semester.selectedIndex].value;
}
-->
</script>

<body bgcolor="#D2AE72">

<form name="form_" method="post" action="./list_educational_assistance.jsp">
<input type="hidden" name="showdetails">
<input type="hidden" name="print_page">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          STUDENTS WITH EDUCATIONAL ASSISTANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="24" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="3" style="color:#0000FF">NOTE : At first time this report takes time to generate</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="3" style="color:#0000FF; font-weight:bold">
	  <input type="checkbox" name="cleanup" value="1">
	  Recompute Scholarship?(If this option is selected, Report generation will be slow)</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">School Year :</td>
      <td width="33%"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> 
        <input name="sy_from" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4">
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> 
        <input name="sy_to" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes">
        - 
<%if(bolIsBasic) {%>
		<select name="semester">
				  <%
		strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		if(strTemp == null)
			strTemp = "";
		if(!strTemp.equals("0"))
			strTemp= "1";
			
		if(strTemp.compareTo("0") ==0){%>
				  <option value="0" selected>Summer</option>
				  <%}else{%>
				  <option value="0">Summer</option>
				  <%}if(strTemp.compareTo("1") ==0){%>
				  <option value="1" selected>Regular</option>
				  <%}else{%>
				  <option value="1">Regular</option>
				  <%}%>
				</select>
<%}else{%>        
		<select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
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
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> 
<%}%>		
		
		</td>
      <td width="45%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Date Posted : </td>
      <td colspan="2"><input name="date_posted_fr" type="text" class="textbox" id="date_attendance" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_fr")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <input name="date_posted_to" type="text" class="textbox" id="date_attendance2" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_to")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		
		</td>
    </tr>
<%if(strSchCode.startsWith("UI") || strSchCode.startsWith("UL") || strSchCode.startsWith("CIT") || true){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:11px; font-weight:bold; color:#0000FF"><input type="checkbox" name="show_approval_no" value="checked" <%=WI.fillTextValue("show_approval_no")%>> Show Approval Number</td>
      <td colspan="2" style="font-size:11px; font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("is_basic");
if(strTemp.length() > 0) 
	strTemp = " checked";
%>
		  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="ReloadPage();"> Process Report for Grade School 
<%if(strSchCode.startsWith("VMA")){%>
&nbsp;&nbsp;&nbsp;&nbsp;
		  <input type="checkbox" name="unit_enrolled" value="checked"<%=WI.fillTextValue("unit_enrolled")%> onClick="ReloadPage();"> Show Unit Enrolled 
<%}%>
	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="19" colspan="4"><hr size="1" color="#008080"></td> 
    </tr>
  </table>
<% if (WI.fillTextValue("sy_from").length()!=0 && WI.fillTextValue("sy_to").length()!= 0) {
String strIsValidCon = "1";
if(strTemp.length() > 0) 
	strIsValidCon = "2";
%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0" id="searchTable">
    <tr> 
      <td height="32">&nbsp;</td>
      <td width="27%">Educational Assistance Type : </td>
      <td width="33%"><select name="assistance0" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%=dbOP.loadCombo("distinct MAIN_TYPE_NAME","MAIN_TYPE_NAME"," from FA_FEE_ADJUSTMENT where is_del=0 and is_valid="+strIsValidCon+" and "+
		  "tree_level=0 and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
		  " and (semester = "+WI.fillTextValue("semester")+" or semester is null) order by FA_FEE_ADJUSTMENT.MAIN_TYPE_NAME asc", 
		  request.getParameter("assistance0"), false)%> </select></td>
      <td width="39%"><a href="javascript:ShowDetails()"><img src="../../../images/view.gif" width="40" height="31" border="0"></a><font size="1">click 
        to view list of students</font></td>
    </tr>
    <tr> 
      <td height="32">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"> <%
strTemp = request.getParameter("assistance0");
if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0){
strTemp = ConversionTable.replaceString(strTemp,"'","''");
strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid="+strIsValidCon+" and tree_level=1 and MAIN_TYPE_NAME='"+strTemp+
"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+ 
" and (semester = "+WI.fillTextValue("semester")+" or semester is null) order by SUB_TYPE_NAME1 asc";
%> <select name="assistance1" onChange="ReloadPage();">
          <option value="">Select</option>
          <%=dbOP.loadCombo("SUB_TYPE_NAME1","SUB_TYPE_NAME1",strTemp, 
	request.getParameter("assistance1"), false)%> </select> <%
		strTemp = request.getParameter("assistance1");
		if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0){
		strTemp = ConversionTable.replaceString(strTemp,"'","''");
		strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid="+strIsValidCon+" and tree_level=2 and MAIN_TYPE_NAME='"+
		ConversionTable.replaceString(request.getParameter("assistance0"),"'","''")+"' and SUB_TYPE_NAME1='"+
		strTemp+"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
		  " and semester = "+WI.fillTextValue("semester")+" order by SUB_TYPE_NAME2 asc";
		%> <select name="assistance2" onChange="ReloadPage();">
          <option value="">Select</option>
          <%=dbOP.loadCombo("SUB_TYPE_NAME2","SUB_TYPE_NAME2",strTemp, request.getParameter("assistance2"), false)%> 
        </select> <%}

		strTemp = request.getParameter("assistance2");
		if(strTemp != null && strTemp.compareTo("0") != 0 && strTemp.length() > 0){
		strTemp = ConversionTable.replaceString(strTemp,"'","''");
		strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid="+strIsValidCon+" and tree_level=3 and MAIN_TYPE_NAME='"+
		ConversionTable.replaceString(request.getParameter("assistance0"),"'","''")+"' and SUB_TYPE_NAME1='"+
		ConversionTable.replaceString(request.getParameter("assistance1"),"'","''")+"' and SUB_TYPE_NAME2='"+strTemp+
		"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
		  " and semester = "+WI.fillTextValue("semester")+" order by SUB_TYPE_NAME3 asc";
		%> <select name="assistance3" onChange="ReloadPage();">
          <option value="">Select</option>
          <%=dbOP.loadCombo("SUB_TYPE_NAME3","SUB_TYPE_NAME3",strTemp, request.getParameter("assistance3"), false)%> 
        </select> <%}//for last condition.
}%> </td>
    </tr>
<%if(WI.fillTextValue("is_basic").length() == 0){%>
    <tr> 
      <td width="1%" height="32">&nbsp;</td>
      <td colspan="3">College : 
        <select name="c_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from college where is_del = 0",request.getParameter("c_index"), false)%> 
	  </select></td>
    </tr>
<% if (WI.fillTextValue("c_index").length() > 0) {%>	
    <tr>
      <td height="32">&nbsp;</td>
      <td colspan="3">Department : 
        <select name="d_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%=dbOP.loadCombo("d_index","d_name"," from department where c_index = "+ WI.fillTextValue("c_index"),WI.fillTextValue("d_index"), false)%> 
	    </select>	  </td>
    </tr>
    
<%}
}//do not show for basic.. 

if(bolIsDLSHSI){
%>
	<tr>
        <td height="32">&nbsp;</td>
        <td colspan="3">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=conSearch.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
            	</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td>
				<select name="sort_by1_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select></td>
			<td>
				<select name="sort_by2_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
			<td>
				<select name="sort_by3_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
		</tr>
		
	</table>
		
		</td>
    </tr>
<%}%>
  </table>
<%
if (vRetResult != null && vRetResult.size() > 0)  {
	if (WI.fillTextValue("assistance0").length() == 0){
		strTemp = "ALL ";
	}else{
		strTemp = (String)vRetResult.elementAt(5);
	}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable">
    <tr> 
      <td width="69%" height="25"><a href="javascript:PrintPgNew()"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print list (New Format - Prints ALL)
	  <!--
	  <input type="checkbox" name="inc_summary" value="checked" <%=WI.fillTextValue("inc_summary")%>>
	   Include Summary
	   -->
	  </font></td>
      <td width="31%" height="25"><div align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print list</font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="2">
	  <input type="radio" name="print_summary" value="0"> Print Summary Per Course 
	  <input type="radio" name="print_summary" value="1"> Print Summary Per College 
	  <input type="radio" name="print_summary" value="2"> Print Summary Per Grant(Per Course) 
	  <input type="radio" name="print_summary" value="3"> Print Summary Per Grant(Per College)
<%if(strSchCode.startsWith("UB") || true){%>
	  <input type="radio" name="print_summary" value="4"> Print Summary Per Grant
<%}%>	  
	  <div align="left">Note: Summary Option Prints ALL</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6" class="thinborderBOTTOM" align="center"><font size="2"><strong>LIST OF STUDENTS WITH EDUCATIONAL ASSISTANCE : <%=strTemp%></strong></font><br>
          SY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>, <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%>
		<%if(WI.fillTextValue("date_posted_fr").length() > 0) {%>
			<br><font size="1">Cut-off Date : <%=WI.fillTextValue("date_posted_fr")%> 
			<%=WI.getStrValue(WI.fillTextValue("date_posted_to")," to ", "", "")%></font>
		<%}%></td>
    </tr>
    <tr> 
      <td height="25" colspan="6" class="thinborderNONE"><strong>TOTAL STUDENTS :<%=(String)vRetResult.elementAt(0)%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="10%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT 
          ID</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div></td>
      <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>COURSE<%if(!bolIsBasic){%>/MAJOR<%}%></strong></font></div></td>
      <%if(bolIsCLDH){%>
	  <td width="10%" class="thinborder" align="center" style="font-weight:bold">DATE APPROVED</td>
      <%}if(bolShowApprovalNumber){%>
      <td width="10%" class="thinborder" align="center" style="font-weight:bold">APPROVAL NUMBER </td>
      <%}%>
	  <td width="20%" class="thinborder"> <div align="center"><font size="1"><strong>GRANT NAME</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>DISCOUNTS</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
    </tr>
<% 
/**
 *  [0] = total Student.   [1] = total Disc Amt.
 *  [0] student index [1] Stud Name [2] fa_fa_indexs  [3] main adjustment
 *  [4] sub adjustment type 1  [5] sub adjustment type 2  [6] sub adjustment type 3
 *  [7] discount_type  [8] year level
 *  [9] id number  [10]  course  [11]  major  [12]  discount_amount
 *  [13] college   [14] dept, [15] date approved, [16] approval number.
 */
 //System.out.println(vRetResult);
 String strCollege = ""; String strDepartment = "";
 boolean bolChanged = false;
 
 String strCurrYrLvl = null;
 String strPrevYrLvl = "";
 boolean bolChangeYr = false;
 float fYrLvlTotal = 0f;
 
 String[] astrConvertYr = {"","First Year","Second Year","Third Year","Fourth Year","Fifth Year","Sixth Year"};
 for (int i =2; i < vRetResult.size() ; i+=17) {
	bolChanged = false;
	if (vRetResult.elementAt(i+13) != null &&  strCollege.compareTo((String)vRetResult.elementAt(i+13)) != 0){
		bolChanged = true;
		strCollege = (String)vRetResult.elementAt(i+13);		
	}
	if (vRetResult.elementAt(i+14) != null && strDepartment.compareTo((String)vRetResult.elementAt(i+14)) != 0){
		bolChanged  = true;
		strDepartment = (String)vRetResult.elementAt(i+14);		
	}
	strTemp = (String)vRetResult.elementAt(i+10);
	if ((String)vRetResult.elementAt(i+11) !=null){
		strTemp+= "(" + (String)vRetResult.elementAt(i+11) + ")";
	}
	
	if(bolIsBasic)	
		strTemp = dbOP.getBasicEducationLevel(Integer.parseInt(strTemp));
	else	
		strTemp = strTemp + WI.getStrValue((String)vRetResult.elementAt(i+8),"-","","");
	
	bolChangeYr = false;
	strCurrYrLvl = WI.getStrValue((String)vRetResult.elementAt(i+8),"0");
	if(bolShowLvlTotal && !strPrevYrLvl.equals(strCurrYrLvl)){	
		strPrevYrLvl = strCurrYrLvl;
		if(i > 2)
			bolChangeYr = true;
	}
	
	if(bolChangeYr){bolChangeYr =false;
	
	
	%>
    <tr style="font-weight:bold"> 
	<%
	
	strErrMsg = "5";
	if(bolIsCLDH)
		strErrMsg = Integer.toString(Integer.parseInt(strErrMsg)+ 1);
	if(bolShowApprovalNumber)
		strErrMsg = Integer.toString(Integer.parseInt(strErrMsg)+ 1);
	
	
	%>
      <td height="25" colspan="<%=strErrMsg%>" class="thinborderBOTTOMLEFT"><%
	  strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i-(17-8)),"0");
	  
	  if(!bolIsBasic)
	  	strErrMsg = astrConvertYr[Integer.parseInt(strErrMsg)];
	  else
	  	strErrMsg = dbOP.getBasicEducationLevel(Integer.parseInt((String)vRetResult.elementAt(i-(17-10))));
	  %><font size="1"><%=strErrMsg%></font></td>
      <td class="thinborderBOTTOM" align="right"><font size="1"><%=CommonUtil.formatFloat(fYrLvlTotal, true)%></font></td>
      
    </tr>	
<%	fYrLvlTotal = 0f;
}if(bolChanged){
%>
    <tr> 
      <td height="25" colspan="6" class="thinborderBOTTOMLEFT"><%if(!bolIsBasic){%>College : <%}%><strong><%=strCollege%><%=WI.getStrValue(strDepartment," &nbsp;&nbsp;&nbsp;&nbsp; Department :","","")%></strong></td>
      <%if(bolIsCLDH){%><td class="thinborderBOTTOM">&nbsp;</td><%}%>
      <%if(bolShowApprovalNumber){%><td class="thinborderBOTTOM">&nbsp;</td><%}%>
    </tr>
<%fYrLvlTotal = 0f;}%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
      <%if(bolIsCLDH){%>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+15)%></td>
      <%}if(bolShowApprovalNumber){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+16),"&nbsp;")%></td>
      <%}%>
	  <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"/","","")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></font></td>
	  <%
	  try{
	  	strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+12),",","");
	  	fYrLvlTotal += Float.parseFloat(strTemp);
	  }catch(Exception e){}
	  %>
      <td class="thinborder" align="right"><font size="1"><%=(String)vRetResult.elementAt(i+12)%></font></td>
    </tr>
    <%}//END OF FOR LOOP
	
	if(bolShowLvlTotal){
	%>	
	<tr style="font-weight:bold;">
	<%
	strErrMsg = "5";
	if(bolIsCLDH)
		strErrMsg = Integer.toString(Integer.parseInt(strErrMsg)+ 1);
	if(bolShowApprovalNumber)
		strErrMsg = Integer.toString(Integer.parseInt(strErrMsg)+ 1);
	%> 
      <td height="25" colspan="<%=strErrMsg%>" class="thinborderBOTTOMLEFT"><%
	  if(!bolIsBasic)
	  	strErrMsg = astrConvertYr[Integer.parseInt(strCurrYrLvl)];
	  else
	  	strErrMsg = dbOP.getBasicEducationLevel(Integer.parseInt(strCurrYrLvl));
	  %><font size="1"><%=strErrMsg%></font></td>
      <td class="thinborderBOTTOM" align="right"><font size="1"><%=CommonUtil.formatFloat(fYrLvlTotal, true)%></font></td>
    </tr>
	<%}%>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
      <tr> 
      <td height="25" align="right" style="font-size:10px;font-weight:bold">TOTAL DISCOUNT:&nbsp;&nbsp;&nbsp;
	  	<%=(String)vRetResult.elementAt(1)%></td>
    </tr>

  </table>
  <%}//if(vRetResult != null)

}//if (WI.fillTextValue("sy_from").length()!=0 && WI.fillTextValue("sy_to").length()!= 0)%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="footer">

    <tr> 
      <td height="25">&nbsp;</td>
      <td width="49%" valign="middle">&nbsp;</td>
      <td width="50%" valign="middle"></tr>
    <tr bgcolor="#A49A6A"> 
      <td width="1%" height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>