<%@ page language="java" import="utility.*,java.util.Vector,payroll.PREarningDed" %>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","view_print_posted.jsp");

	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"view_print_posted.jsp");
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
Vector vRetResult = null;
boolean bolShowDeducted = false;
PREarningDed prd = new PREarningDed(request);


if(WI.fillTextValue("proceedclicked").length() > 0){
	vRetResult = prd.searchEarningDeductions(dbOP);
	if (vRetResult == null){
		strErrMsg = prd.getErrMsg();
	}
}

if (WI.fillTextValue("staff_type").compareTo("0") == 0) 
	strTemp = "8";
else strTemp = "7";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View Print Posted Earnings Deduction</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

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


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function ProceedClicked(){
	document.form_.proceedclicked.value= "1";
	ReloadPage();
}

function PrintPg(){

	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div>";
	document.bgColor = "#FFFFFF";
	
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	//strTemp is set in Java code above
	for (i=0; i<<%=strTemp%>; ++i)
		document.getElementById('searchTable').deleteRow(0);
	if (document.getElementById('search1'))
		document.getElementById('search1').getElementsByTagName("tr")[0].style.backgroundColor = "#FFFFFF";
	if (document.getElementById('search2'))
		document.getElementById('search2').getElementsByTagName("tr")[0].style.backgroundColor = "#FFFFFF";		
	document.getElementById('myADTable').deleteRow(1);
	this.insRow(0, 1, strInfo);
	this.insRow(1, 1, "&nbsp");

	
	document.getElementById('footer').deleteRow(0);	
	document.getElementById('footer').deleteRow(0);
	window.print();
}
-->
</script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>

<body  bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./view_print_posted.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : EARNING DEDUCTIONS : VIEW/PRINT POSTED DEDUCTIONS PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="23" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg,"&nbsp")%></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="searchTable">

    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%">DATE</td>
      <td colspan="2"><strong> 
        <% strTemp= WI.fillTextValue("date_from");%>
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </strong> to&nbsp; <strong> 
        <%strTemp= WI.fillTextValue("date_to");%>
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		</strong><a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
<%if(bolIsSchool){%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee Type</td>
      <td height="29"  colspan="2">
	  	<%
			strTemp = WI.fillTextValue("staff_type");
		%>
	  	<select name="staff_type" onChange="ReloadPage()">
          <option value="">ALL</option>
          <%if (strTemp.equals("1")){%>
          <option value="1" selected>Non-teaching</option>
          <%}else{%>
          <option value="1" >Non-teaching</option>
          <%}%>
          <%if (strTemp.equals("0")){%>
          <option value="0" selected>Teaching</option>
          <%}else{%>
          <option value="0" >Teaching</option>
          <%}%>
        </select> </td>
    </tr>
<%} 
	strTemp = WI.fillTextValue("staff_type");
	String strCollegeIndex = WI.fillTextValue("c_index");
	if (strTemp.compareTo("0") == 0){ 
%>
	
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td height="29"  colspan="2"> <select name="c_index" onChange="ReloadPage()">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Department</td>
      <td height="29"  colspan="2"> <% if (strCollegeIndex.length() > 0) {%> <select name="d_index">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> </select> <%}%> </td>
    </tr>
    <%} else {
		strTemp = WI.fillTextValue("d_index"); %>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Office/Department</td>
      <td height="29"  colspan="2"><font size="1"> 
        <select name="d_index">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index is null or c_index = 0", strTemp,false)%> 
        </select>
        </font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID</td>
      <td width="33%" height="29"><strong> 
        <input name="emp_id" type="text" size="12" maxlength="12" class="textbox" value="<%=WI.fillTextValue("emp_id")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong> <font size="1"> (for specific employee) </font></td>
      <td width="47%"><strong><a href="javascript:OpenSearch()"><img src="../../../images/search.gif" border="0"></a></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Show</td>
      <td height="29"  colspan="2">
	    <select name="is_posted" onChange="ReloadPage()">
          <option value="">ALL</option>
          <%if (WI.fillTextValue("is_posted").compareTo("0") == 0) {%>
          <option value="0" selected>Posted Deductions Only</option>
          <%}else{%>
          <option value="0">Posted Deductions Only</option>
          <%}if (WI.fillTextValue("is_posted").compareTo("1") == 0) {%>
          <option value="1" selected>Posted Deductions Deducted from Salary</option>
          <%}else{%>
          <option value="1">Posted Deductions Deducted from Salary</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
      <td height="29"  colspan="2"><a href="javascript:ProceedClicked()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
	<%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" ></a> 
          click to print</font></div></td>
    </tr>
  </table>
  <% strTemp = WI.fillTextValue("is_posted");
  		if (strTemp.length() == 0 || strTemp.equals("0")){
  %>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder" id="search1">
    <tr bgcolor="#B9B292"> 
      <td height="26" colspan="8" class="thinborder"><div align="center"><strong><font color="#000000" size="2">LIST 
          OF POSTED EARNING DEDUCTIONS</font></strong></div></td>
    </tr>
    <tr> 
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE ID</font></strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE NAME</font></strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong><font size="1">  
           DEPARTMENT / OFFICE</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">DEDUCTION NAME</font></strong></div></td>
      <td width="12%" height="26" class="thinborder"><div align="center"><font size="1"><strong>PERIOD</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>DATE POSTED</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>POSTED BY</strong></font></div></td>
    </tr>
    <% 	for (int i= 0; i < vRetResult.size(); i+=17){
		if (((String)vRetResult.elementAt(i+15)).equals("1")){
			bolShowDeducted = true;
			continue;
		}
	%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
      <%
	String strTemp2 = (String)vRetResult.elementAt(i+5);
	if (strTemp2 == null)
		strTemp2 = (String)vRetResult.elementAt(i+7);
	else
		strTemp2 += WI.getStrValue((String)vRetResult.elementAt(i+7)," :: ","","");
		
%>
      <td class="thinborder">&nbsp;<%=strTemp2%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
      <td class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+12)%>&nbsp;</div></td>
      <td width="10%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+13)%></td>
      <td width="12%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
    </tr>
    <%} //end for loop%>

  </table>
 
 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr> 
      <td height="26">&nbsp;</td>
    </tr>
</table> 
<%}if ((strTemp.length() == 0 && bolShowDeducted) || strTemp.equals("1")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="search2">
    <tr bgcolor="#CCCC99">  
      <td height="26" colspan="7"class="thinborder"><div align="center"><strong><font color="#00000" size="2">LIST 
          OF POSTED EARNING DEDUCTIONS DEDUCTED 
          FROM SALARY</font></strong></div></td>
    </tr>
    <tr> 
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE 
          ID</font></strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE 
          NAME</font></strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong><font size="1">
          DEPARTMENT / OFFICE</font></strong></div></td>
      <td width="17%"  class="thinborder"><div align="center"><strong><font size="1">DEDUCTION 
          NAME</font></strong></div></td>
      <td width="10%" height="26"  class="thinborder"><div align="center"><font size="1"><strong>DATE 
          POSTED</strong></font></div></td>
      <td width="7%"  class="thinborder"><div align="center"><font size="1"><strong>AMOUNT 
          POSTED </strong></font></div></td>
      <td  class="thinborder"><div align="center"><font size="1"><strong>PAYABLE 
          BALANCE </strong></font></div></td>
    </tr>
    <% 	for (int i= 0; i < vRetResult.size(); i+=17){
		if (((String)vRetResult.elementAt(i+15)).equals("0")){
			continue;
		}
	%>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
      <%
		String strTemp2 = (String)vRetResult.elementAt(i+5);
		if (strTemp2 == null)
			strTemp2 = (String)vRetResult.elementAt(i+7);
		else
			strTemp2 += WI.getStrValue((String)vRetResult.elementAt(i+7)," :: ","","");
		%>
      <td class="thinborder">&nbsp;<%=strTemp2%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%></td>
      <td  class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+13)%></td>
      <td height="24" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+12)%>&nbsp;</div></td>
      <td width="7%" class="thinborder"><div align="right"><%=(String)vRetResult.elementAt(i+16)%>&nbsp;</div></td>
    </tr>
    <%}%>
  </table>
<%}
}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="footer">
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
</table>
  
<input type="hidden" name="print_page">
<input type="hidden" name="proceedclicked">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>