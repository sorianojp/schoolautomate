<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.fontsize10{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function PrintPg()
{
<%if (strSchCode.startsWith("AUF")) { %>
	document.getElementById('footer').deleteRow(0);
	document.getElementById('footer').deleteRow(0);
<%}%> 
	
	document.getElementById('header').deleteRow(0);
	document.getElementById('header').deleteRow(0);
	window.print();
}


function ShowResults(){
	document.form_.show_results.value ="1";
	this.SubmitOnce("form_");
}
function ReloadPage(){
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.reloadPage.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

</script>

<body class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
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
Vector vInnerResult = null;

HRStatsReports hrStat = new HRStatsReports(request);

if (WI.fillTextValue("show_results").compareTo("1") == 0){
	vRetResult = hrStat.getListofSeniorJunior(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();		
}


%>
<form action="./hr_jr_sr_listing.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25"><div align="center"><strong>:::: 
      JUNIOR AND SENIOR STAFF LIST::::</strong></div></td>
    </tr>
    <tr >
      <td height="25" bgcolor="#FFFFFF">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="header">
    <tr> 
      <td width="2%" height="22">&nbsp;</td>
      <td width="18%">Emp. Classification</td>
      <td width="15%"> <select name="emp_catg" onChange="ShowResults()">
          <option value="">ALL</option>
          <% strTemp = WI.fillTextValue("emp_catg");
			if (strTemp.compareTo("1") ==0) { %>
          <option value="1" selected> Junior Staff</option>
          <%}else{%>
          <option value="1"> Junior Staff</option>
          <%}if (strTemp.compareTo("2") == 0) { %>
          <option value="2" selected> Senior Staff</option>
          <%}else{%>
          <option value="2"> Senior Staff</option>
          <%}%>
      </select></td>
      <td width="13%"><select name="is_teaching"  onChange="ShowResults()">
        <option value=""> ALL </option>
        <% strTemp = WI.fillTextValue("is_teaching");
			if (strTemp.equals("0")) { %>
        <option value="0" selected> NTP</option>
        <%}else{%>
        <option value="0"> NTP </option>
        <%}if (strTemp.equals("1")) { %>
        <option value="1" selected> Academic</option>
        <%}else{%>
        <option value="1"> Academic</option>
        <%}%>
      </select></td>
      <td width="52%"><a href="javascript:ShowResults()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
	  <% 
	  	strTemp = WI.fillTextValue("cut_off_date");
		if (strTemp.length()  == 0) 
			strTemp = WI.getTodaysDate(1);
	  %>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr> 
      <td height="25" colspan="2"><div align="center"><label name="jrSrLabel"></label></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="11%"  class="thinborder"><strong>ID Number </strong></td> 
      <td width="36%" height="20"  class="thinborder"><strong> Name</strong></td>
      <td width="34%"  class="thinborder"><strong>Position</strong></td>
      <td width="19%"  class="thinborder"><strong> Office </strong></td>
    </tr>
   <%  for (int i=0; i < vRetResult.size(); i+=11){  %> 
    <tr>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td> 
      <td height="20" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
	  <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
	  <% strTemp = (String)vRetResult.elementAt(i+4);
	  	if (strTemp == null)
			strTemp = (String)vRetResult.elementAt(i+6); %> 
	  <td class="thinborder"><font size="1"><%=strTemp%></font></td>
    </tr>
    <%}// end for loop%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">
	  <div align="center"><font size="1"><a href="javascript:PrintPg();"> 
          <img src="../../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print List</font></div>
	  </td>
    </tr>
  </table>
<%} //vRetResult != null && vRetResult.size() > 0%>

  <input type="hidden" name="print_page">
  <input type="hidden" name="reloadPage">
  <input type="hidden" name="show_results" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>