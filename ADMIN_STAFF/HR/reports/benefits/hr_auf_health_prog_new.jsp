<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRBenefitsMgmt" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11 {
		font-size:11px;
	}
	td {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
a:link {
	text-decoration: none;
}

label {
	color: #FF0000;
}

</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function PrintPg()
{
<%if (strSchCode.startsWith("AUF")) { %>
	document.getElementById('footer').deleteRow(1);
	document.getElementById('footer').deleteRow(1);	
<%}%> 

	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	window.print();
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function setLabelText(strLabelName, strLabel){
	var strOld = document.getElementById(strLabelName).innerHTML;
	var strNewValue = prompt(strLabel, strOld);
	
	if (strNewValue != null && strNewValue.length > 0)
		document.getElementById(strLabelName).innerHTML = strNewValue;
}

</script>

<body marginheight="0" >
<%

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_educ_reports.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"hr_educ_reports.jsp");
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
Vector vRetResult = null;

HRBenefitsMgmt hrStat = new HRBenefitsMgmt(request);
boolean bolForceWriteMF = false; // force to write M / F if all employees are part time!

if ( WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.getAUFNewTerminatedHealthProg(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
}




%>
<form action="./hr_auf_health_prog_new.jsp" method="post" name="form_" >
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="header">
    <tr> 
      <td height="25" colspan="5">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" class="fontsize11">Date of Report </td>

	  <%
	    String strMonth = null;
		String strYear = null;
		String[] astrMonths = {"","JANUARY", "FEBRUARY", "MARCH" , "APRIL", "MAY", "JUNE", 
								"JULY", "AUGUST", "SEPTEMBER", "OCTOBER","NOVEMBER", "DECEMBER"}; 
	  %>  		  
	  
      <td width="16%">
	  <select name="month" onChange="showList()">
	  <% for (int k = 1; k < astrMonths.length; k++){
	  		if  (k == Integer.parseInt(WI.getStrValue(WI.fillTextValue("month"),"0"))) {%>
			<option value="<%=k%>" selected><%=astrMonths[k]%> </option>
			<%}else{%>
			<option value="<%=k%>"><%=astrMonths[k]%> </option>
			<%}
			}%> 
	  </select>
	  <a href="javascript:show_calendar('form_.cut_off_date');" 
	  	title="Click to select date" onMouseOver="window.status='Select date';return true;"
		onMouseOut="window.status='';return true;"></a>	  </td>
      <td width="9%"><input name="school_year" type="text" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  value="<%=WI.fillTextValue("school_year")%>" size="6" maxlength="4"></td>
      <td width="57%"><a href="javascript:showList()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" valign="bottom" class="fontsize11">&nbsp;</td>
    </tr>
  </table>
  
 <% if (vRetResult != null && vRetResult.size() > 1) { 
 		int i = 0; int iCtr = 1;
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
<% if (((String)vRetResult.elementAt(3)).equals("0")){%> 
   <tr>
   <td height="25" colspan="3"> <strong>&nbsp;&nbsp;NEW MEMBERS AS OF  <%=astrMonths[Integer.parseInt(WI.getStrValue(WI.fillTextValue("month"),"0"))] + " " +  
   	WI.fillTextValue("school_year")%>&nbsp;</strong></td>
   </tr>
   <tr>
   <td height="25" colspan="3">&nbsp; </td>
   </tr>   
<% 
	for (; i< vRetResult.size(); i+= 4,iCtr++) {

	if (!((String)vRetResult.elementAt(i+3)).equals("0"))
		break;

%> 
   <tr>
 	  <td width="7%" valign="top">&nbsp;<%=iCtr%></td>   
 	  <td width="33%" height="19" valign="top">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
	<% strTemp =   (String)vRetResult.elementAt(i+1);
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+2); %>
 	  <td width="60%" valign="top">&nbsp;<%=strTemp%></td>
   </tr>
<% }%>
   <tr>
 	  <td width="7%" height="25" valign="top">&nbsp;</td>   
 	  <td width="33%" height="25" valign="top">&nbsp;</td>
 	  <td width="60%" height="25" valign="top">&nbsp;</td>
   </tr>

<%} 
	if ( i < vRetResult.size() && ((String)vRetResult.elementAt(i+3)).equals("1")){
%> 
 	<tr>
	  <td colspan="3" valign="top"><strong>&nbsp;&nbsp;MEMBERSHIP TERMINATED  AS OF <%=astrMonths[Integer.parseInt(WI.getStrValue(WI.fillTextValue("month"),"0"))] + " " +  
   	WI.fillTextValue("school_year")%>&nbsp;</strong></td>
    </tr>

 	<tr>
	  <td colspan="3" valign="top" height="25">&nbsp;</td>
    </tr>
<% 	iCtr = 1;
	for (; i< vRetResult.size(); i+= 4, iCtr++) {%> 
 	<tr>
 	  <td width="7%" valign="top">&nbsp;<%=iCtr%></td>   
 	  <td height="19">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
	<% strTemp =   (String)vRetResult.elementAt(i+1);
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+2); %>
 	  <td>&nbsp;<%=strTemp%></td>
    </tr>
<%} %>
 	<tr>
 	  <td valign="top">&nbsp;</td>
 	  <td height="35">&nbsp;</td>
 	  <td>&nbsp;</td>
    </tr>

<% }%> 
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	  <tr>
	  	<td width="40%">&nbsp; Prepared by :  </td>
	  	<td width="60%">Noted by: </td>
	  </tr>
	  <tr>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
	  <tr>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
	  <tr>
	    <td> <strong>&nbsp;&nbsp;
		<label id="hr_assistant" 
			onclick="setLabelText('hr_assistant','HR Assistant for Personnel')">		
		Jocelyn Z. Manalang  </label></strong></td>
	    <td height="25"><strong>
			<label id="hr_director" 
				onclick="setLabelText('hr_director','HRDC Director')">
		<%=CommonUtil.getNameForAMemberType(dbOP,"Director, HR",7)%> </label></strong></td>
    </tr>
	  <tr>
	    <td valign="top">&nbsp;&nbsp;HR Assistant for Personnel &amp;<br>
        &nbsp;&nbsp;Employee Relations Services </td>
	    <td valign="top">Director</td>
    </tr>
  </table>
<%}  %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
	<% if (vRetResult != null && vRetResult.size() > 1) { %> 
    <tr>
      <td height="25"><div align="center"><em>Items in <font color="#FF0000"><strong>RED</strong></font> are editable. Please set the printing mode to black/white before printing. </em></div></td>
    </tr>
    <tr>
      <td height="25"><div align="center"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a><font size="1">click to print report</font> </div></td>
    </tr>
	<%}%> 
  </table>
  <input type="hidden" name="print_page" value="0">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>