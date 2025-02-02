<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
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
	document.form_.print_page.value=1;
	this.SubmitOnce("form_");	
}

function ShowResults(){
	document.form_.show_results.value ="1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}
function ReloadPage(){
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.reloadPage.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function UpdateHeadOffices(){
	var pgLoc = "./hr_department_main.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")) { %>
	<jsp:forward page="./hr_chancellor_appoint_print.jsp" />
	
<% return; }
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

if (WI.fillTextValue("show_results").equals("1")){
	vRetResult = hrStat.getJrSrChancellorAppoint(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
}

String[] strJrSrLabel = {"Senior and Junior Staff", "Junior Staff","Senior Staff"};

%>
<form action="./hr_chancellor_appoint.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF"><strong>:::: 
          JUNIOR AND SENIOR STAFF APPOINTED BY THE CHANCELLOR&nbsp;&nbsp;::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" bgcolor="#FFFFFF">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Emp. Classification</td>
      <td width="44%"> <select name="emp_catg">
          <option value=""> </option>
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
        </select>
        <a href="javascript:ShowResults()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td width="33%">
	  	<a href="javascript:UpdateHeadOffices()"><img src="../../../../images/update.gif" width="60" height="26" border="0">		</a><font size="1">click to update head office </font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="18">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="42%"><a href="javascript:ShowResults()"%></a></td>
      <td width="35%">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr> 
      <td height="25" colspan="2" bgcolor="#CDC8B1"><div align="center"><strong><font color="#000000">LIST OF STAFF APPOINTED BY THE CHANCELLOR </font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
<% String strCurrentHeadOffice = "";
	for (int i=0; i < vRetResult.size(); i+=10){  
	  if (i == 0  || !strCurrentHeadOffice.equals((String)vRetResult.elementAt(i+9))){
	  strCurrentHeadOffice = (String)vRetResult.elementAt(i+9); 
%>
    <tr>
      <td height="25" colspan="4"  class="thinborder"><div align="center"><strong><%=strJrSrLabel[Integer.parseInt(WI.getStrValue(WI.fillTextValue("emp_catg"),"0"))]  + 
	  		" under the " + strCurrentHeadOffice%></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25"  class="thinborder"> <strong>Unit</strong></td>
      <td width="25%"  class="thinborder"><div align="center"><strong>Name</strong></div></td>
      <td width="40%"  class="thinborder"><div align="center"><strong> Position</strong></div></td>

      <td width="25%" class="thinborder"><strong>Duration of Appointment </strong></td>
    </tr>
	<%}
		strTemp = (String)vRetResult.elementAt(i+4);
		if (strTemp == null){
			strTemp = (String)vRetResult.elementAt(i+6);
		}
	%> 
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
	  <% strTemp = (String)vRetResult.elementAt(i+2);
	  		if (strTemp.toLowerCase().indexOf("dean") != -1  ||
				strTemp.toLowerCase().indexOf("direct") != -1 ||
				strTemp.toLowerCase().indexOf("secret") != -1){
					if ((String)vRetResult.elementAt(i+3) != null)
						strTemp +=", "  + (String)vRetResult.elementAt(i+3);
					else
						strTemp +=", "  + (String)vRetResult.elementAt(i+5);
				}
	   %>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+7)) + " - "  +
	  		   WI.getStrValue((String)vRetResult.elementAt(i+8))%> </td>
    </tr>
    <%}// end for loop%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1"><a href="javascript:PrintPg();"> 
          <img src="../../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print List</font></div></td>
    </tr>
  </table>
<%} //vRetResult != null && vRetResult.size() > 0%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page" value="0">
  <input type="hidden" name="reloadPage">
  <input type="hidden" name="show_results" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>