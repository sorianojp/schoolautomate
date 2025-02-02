<%@ page language="java" import="utility.*,enrollment.FAExternalPay,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg= null;
	String strTemp   = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - External Payments","misc_oc_payable.jsp");
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
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"misc_oc_payable.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
Vector vFeeList   = new Vector();

FAExternalPay fa = new FAExternalPay(request);

if(WI.fillTextValue("show_list").length() > 0) {
	vFeeList = fa.getStudentListPaidMiscOC(dbOP, request, 0);
	if(vFeeList == null) 
		strErrMsg= fa.getErrMsg();
	else {
		if(WI.fillTextValue("show_list").equals("1") ) {
			vRetResult = fa.getStudentListPaidMiscOC(dbOP, request, 1);
			if(vRetResult == null) 
				strErrMsg= fa.getErrMsg();
		}
	}
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";


    boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
	String strFeeName  = WI.fillTextValue("fee_name");
	String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};
	if(bolIsBasic)
		astrConvertTerm[1] = "Regular";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
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
-->
</style>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
<!--
function showList(){
	document.form_.show_list.value = "1";
	document.form_.print_page.value = "";
	document.form_.submit();
}
function printPg() {
	document.bgColor = "#FFFFFF";
	var oRows = document.getElementById('myADTable1').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	objTable = document.getElementById('myADTable1');
	for( i = 0; i < iRowCount; ++i) 
		objTable.deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function showProcessing() {
	document.all.processing.style.visibility='visible';	
	document.bgColor = "#DDDDDD";
}
function CallOnLoad() {
	document.all.processing.style.visibility='hidden';	
	document.bgColor = "#FFFFFF";
}
-->
</script>
<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();" bgcolor="#DDDDDD">
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align="center" class="thinborderALL">
      <tr>
            <td align="center" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page</font></p>
			<img src="../../../../Ajax/ajax-loader2.gif"></td>
      </tr>
</table>
</div>
<form action="./misc_oc_payable.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  id="myADTable1">
    <tr>
      <td height="25" align="center" class="thinborderBOTTOM" valign="bottom" colspan="3"><strong>:::: MISC - OC PAYABLE DETAIL ::::</strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
<%
if(!strSchCode.startsWith("FATIMA")) {
strTemp = WI.fillTextValue("is_basic");
if(strTemp.length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-weight:bold; color:#0000FF; font-size:11px;"><input type="checkbox" name="is_basic" value="1" <%=strTemp%> onClick="document.form_.show_list.value='';document.form_.submit();"> Process for Basic</td>
    </tr>
<%}%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%">SY-Term</td>
      <td width="83%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
- 
<%if(bolIsBasic) {%>
<select name="semester">
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");


if(strTemp.equals("0"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="0" <%=strErrMsg%>>Summer</option>
<%
if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>Regular</option>
      </select>  	  
<%}else{%>	  
<select name="semester">
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");


if(strTemp.equals("0"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="0" <%=strErrMsg%>>Summer</option>
<%
if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
      </select>
<%}%>	  
  	  </td>
    </tr>
<%if(bolIsBasic) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Grade Level</td>
      <td colspan="2">
	  <select name="year_level">
          <option value="">ALL</option>
	  	<%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("year_level"),false)%>
        </select>	  </td>
    </tr>
<%}else {%>
    <tr>
      <td>&nbsp;</td>
      <td>College</td>
      <td height="25">
<%
String strCIndex = WI.fillTextValue("c_index");
%>
		<select name="c_index" style="font-size:11px; width:400px" onChange="document.form_.show_list.value='';document.form_.submit();">
		    <option value=""></option>
	        <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",strCIndex, false)%> 
		</select>	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Course</td>
      <td height="25">
		<select name="course_index" style="font-size:11px; width:400px" onChange="document.form_.show_list.value='';document.form_.submit();">
          <option value=""></option>
<%
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 ";
if(strCIndex.length() > 0) 
	strTemp += " and c_index = "+strCIndex;
strTemp += " order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%> 
        </select>	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Year Level </td>
      <td height="25">
	  <select name="year_level" onChange="document.form_.show_list.value='';document.form_.submit();">
	  <option value=""></option>
		<%
		strTemp = WI.fillTextValue("year_level");
		int iDefVal = Integer.parseInt(WI.getStrValue(strTemp, "0"));
				for(int i = 1; i < 7; ++i) {
					if(iDefVal == i)
						strTemp = " selected";
					else	
						strTemp ="";
				%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
		<%}%>
	  </select>	  </td>
    </tr>
<%}///basic condition.. %>
    <tr>
      <td>&nbsp;</td>
      <td>Gender</td>
      <td height="25">
	  <select name="gender" onChange="document.form_.show_list.value='';document.form_.submit();">
	    <option value=""></option>
<%
strTemp = WI.fillTextValue("gender");
if(strTemp.equals("M"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="M"<%=strErrMsg%>>Male</option>
<%
if(strTemp.equals("F"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  	<option value="F"<%=strErrMsg%>>Female</option>
	  </select>	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Student ID </td>
      <td height="25">
	  	<input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Fee Type </td>
      <td height="25">
	  <select name="is_oc" onChange="document.form_.show_list.value='';document.form_.submit();">
	    <option value=""></option>
		<%
		strTemp = WI.fillTextValue("is_oc");
		if(strTemp.equals("0"))
			strErrMsg = " selected";
		else	
			strErrMsg = "";
		%>
				<option value="0"<%=strErrMsg%>>Misc Fee</option>
		<%
		if(strTemp.equals("1"))
			strErrMsg = " selected";
		else	
			strErrMsg = "";
		%>
	  	<option value="1"<%=strErrMsg%>>Other Charges</option>
	  </select>  	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">
	  <input type="button" onClick="document.form_.show_list.value='2';document.form_.submit();" name="_" value="<<< Proceed >>>">	  </td>
    </tr>
<%
int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("no_of_rows"), "100000"));
strTemp = WI.fillTextValue("show_list");
if(strTemp.length() > 0) {%>
    <tr>
      <td>&nbsp;</td>
      <td>Fee Name </td>
      <td height="25">
	  <select name="fee_name" style="width:300px; font-size:11px;">
	  <%
	  if(vFeeList != null && vFeeList.size() > 0) {
	  	for(int i =0; i < vFeeList.size(); i += 2) {
	  		if(strFeeName.equals(vFeeList.elementAt(i)))
				strTemp = " selected";
			else	
				strTemp = "";
		%>
			<option value="<%=vFeeList.elementAt(i)%>" <%=strTemp%>><%=vFeeList.elementAt(i + 1)%></option>
	  <%}
	  }%>
	  
	  </select>
	  &nbsp;&nbsp;
	  <input type="checkbox" name="show_not_charged" value="checked" <%=WI.fillTextValue("show_not_charged")%>> Show List of student not charged
	  <input type="checkbox" name="show_excluded" value="checked" <%=WI.fillTextValue("show_excluded")%>> Show Excluded Student Only
	  </td>
    </tr>
    
    <tr> 
      <td>&nbsp;</td>
      <td>Rows per page </td>
      <td height="25">
	  <select name="no_of_rows">
	  <option value="100000">Show all in one page</option>
<%
for(int i =  40; i < 60; ++i) {
	if(i == iDef)
		strErrMsg = " selected";
	else	
		strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
<%}%>
	  </select>	  </td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <input type="button" onClick="document.form_.show_list.value='1';showProcessing();document.form_.submit();" name="_2" value="<<< Show Student List >>>">	  </td>
    </tr>
<%}%>
  </table>
<%
double dTotal  = 0d; 
if(vRetResult != null && vRetResult.size() > 0) {
String strDateRange = null;
if(WI.fillTextValue("date_to").length() > 0)
	strDateRange = WI.fillTextValue("date_from") +" to "+WI.fillTextValue("date_to");
else	
	strDateRange = WI.fillTextValue("date_from");
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr> 
      <td height="25" align="right" style="font-size:9px;"><a href="javascript:printPg();"><img src="../../../../images/print.gif" border="0"></a>Print Page</td>
    </tr>
</table>
<%
//System.out.println(vRetResult);
int iPageNo = 0; int i= 0; 
int iCurRow = 0;
String strDateTimePrinted = WI.getTodaysDateTime();
String strTotalAmt = (String)vRetResult.remove(0);

while(vRetResult.size() > 0){
if(iPageNo > 0) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="2"><div align="center"><strong><font size="2">List of Students 
	  <%if(WI.fillTextValue("show_not_charged").length() > 0){%>did not pay<%}else{%>paid<%}%>
	  specific fee </font></strong></div></td>
    </tr>
    <tr>
      <td colspan="2" align="center"><%=strFeeName%></td>
    </tr>
    <tr>
      <td colspan="2" align="center"><%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%></td>
    </tr>
    <tr>
      <td width="57%">Page Number: <%=++iPageNo%></td>
      <td width="43%" align="right">Date and time printed: <%=strDateTimePrinted%></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr align="center" style="font-weight:bold"> 
      <td width="5%" height="25" class="thinborder" style="font-size:9px;">Count</td>
	  	<td width="15%" class="thinborder" style="font-size:9px;">Student ID </td>
	    <td width="25%" class="thinborder" style="font-size:9px;">Student Name</td>
        <td width="15%" class="thinborder" style="font-size:9px;">Course-Yr</td>
        <td width="5%" class="thinborder" style="font-size:9px;">Gender</td>
		<td width="10%" class="thinborder" style="font-size:9px;"><%if(WI.fillTextValue("show_excluded").length() > 0){%>Encoded By<%}else{%>Amount<%}%></td>
    </tr>
<%
while(vRetResult.size() > 0) {
++iCurRow;
if(iCurRow > iDef) {
	iCurRow = 0;
	++iPageNo;
	break;
}
%>
    <tr>
      <td height="25" class="thinborder" style="font-size:10px;"><%=++i%></td>
	  	<td width="10%" class="thinborder"><%=vRetResult.elementAt(0)%></td>
      <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(1)%></td>
      <td class="thinborder" style="font-size:10px;">
	  <%if(bolIsBasic) {%>
		  <%=vRetResult.elementAt(2)%> 
	  <%}else{%>
		  <%=vRetResult.elementAt(2)%>
	  	<%=WI.getStrValue((String)vRetResult.elementAt(3), "&nbsp;", "","")%>
	  	<%=WI.getStrValue((String)vRetResult.elementAt(4), " - ", "","")%>
	  <%}%>
	  </td>
      <td class="thinborder" style="font-size:10px;"><%=vRetResult.elementAt(5)%></td>
	  <td class="thinborder" style="font-size:10px;" align="right"><%=vRetResult.elementAt(6)%></td>
    </tr>
<%
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	vRetResult.remove(0);vRetResult.remove(0);
}%>
  </table>

<%if(WI.fillTextValue("show_excluded").length() == 0){%>  
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
  		<tr>
			<td align="right" style="font-weight:bold;">Total: <%=strTotalAmt%></td>
		</tr>
  	</table>
<%}%>


<%}//outer while.
}//if vRetResult is not null.
%>
<input type="hidden" name="show_list" value="0">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>