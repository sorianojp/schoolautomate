<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.form_.print_page.value="1";
	document.form_.show_list.value="1";
	document.form_.show_all.value="1";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value="1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

</script>

<body onLoad="window.print()">
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
		
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


HRStatsReports hrStat = new HRStatsReports(request);

String[] astrSortByName    = {"Last Name","First Name","Emp. Status", 
								"Resignation Date"	
							  };
String[] astrSortByVal     = {"lname","user_table.fname","user_status.status",
							  "RESIGNATION_DATE"
							  };
Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")){

	vRetResult = hrStat.hrStatSeparated(dbOP);
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
	}else{
		strErrMsg = hrStat.getErrMsg();
	}
}
 if (strErrMsg != null) {%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
<%} if (vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr> 
      <td height="25" colspan="2"><div align="center"><strong>INACTIVE EMPLOYEES FROM <%=WI.formatDate(WI.fillTextValue("date_from"), 6)%> TO <%=WI.formatDate(WI.fillTextValue("date_to"), 6)%></strong></div></td>
    </tr>
    <tr> 
      <td width="49%" height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%> </b></td>
      <td width="51%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>       
      <td width="4%"  class="thinborder"><div align="center"><font size="1"><strong>UNIT</strong></font></div></td>
	  <td width="19%" height="25"  class="thinborder"><div align="center"><font size="1"><strong> NAME</strong></font></div></td>
	  <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>POSITION</strong></font></div></td>
	  <td width="3%" class="thinborder"><div align="center"><font style="font-size:8px"><strong>STATUS</strong></font></div></td>
	  <td width="3%" class="thinborder"><div align="center"><font style="font-size:8px"><strong>GENDER</strong></font></div></td>
	  <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>BIRTHDATE</strong></font></div></td>
	  <td colspan="3" class="thinborder"><div align="center"><font size="1"><strong>AGE AS OF </strong></font></div></td>
	  <td colspan="2" align="center" class="thinborder"><div align="center"><font size="1"><strong>DATE HIRED </strong></font></div></td>
      <td colspan="3" class="thinborder"><div align="center"><font size="1"><strong>LENGTH OF SERVICE </strong></font></div></td>
      <td colspan="2" class="thinborder"><div align="center"><font size="1"><strong>MANNER OF SEPARATION </strong></font></div></td>
    </tr>
	<tr>
		<td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td colspan="3" class="thinborder"><div align="center"><font size="1"><strong>SEPARATION</strong></font></div></td>
	    <td class="thinborder" width="7%"><div align="center"><font size="1"><strong> FROM </strong></font></div></td>
	    <td class="thinborder" width="7%"><div align="center"><strong><font size="1"> TO</font></strong></div></td>
	    <td class="thinborder" colspan="3"><div align="center"><strong><font size="1">AS OF SEPARATION </font></strong></div></td>
	    <td class="thinborder" width="7%"><div align="center"><font size="1"><strong>EFFECTIVITY</strong></font></div></td>
	    <td class="thinborder" width="14%"><div align="center"><font size="1"><strong>REASON</strong></font></div></td>
	</tr>
	<tr>
		<td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder" width="3%"><div align="center"><font size="1"><strong>yy</strong></font></div></td>
	    <td class="thinborder" width="3%"><div align="center"><font size="1"><strong>mm</strong></font></div></td>
	    <td class="thinborder" width="3%"><div align="center"><font size="1"><strong>dd</strong></font></div></td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder" width="3%"><div align="center"><font size="1"><strong>yy</strong></font></div></td>
		<td class="thinborder" width="3%"><div align="center"><font size="1"><strong>mm</strong></font></div></td>
		<td class="thinborder" width="3%"><div align="center"><font size="1"><strong>dd</strong></font></div></td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	</tr>
    <% String strCurrentUserIndex = null;
		for (int i=0; i < vRetResult.size(); i+=25){
			strCurrentUserIndex = (String)vRetResult.elementAt(i);
	%>
    <tr> 
      <% 
		strTemp = (String)vRetResult.elementAt(i+4);
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+5);
	
	%>
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	  <td height="25" class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1),
	  													(String)vRetResult.elementAt(i+2),
					 	  							    (String)vRetResult.elementAt(i+3),4)%></td>
	  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8), "&nbsp;")%></td>
	  <%
	  	if(((String)vRetResult.elementAt(i+13)).equals("0"))
			strTemp = "PT";
		else
			strTemp = "FT";
	  %>
	  <td class="thinborder"><%=strTemp%><%=((String)vRetResult.elementAt(i+9)).substring(0,1)%></td>
	  <%
	  	if(((String)vRetResult.elementAt(i+20)).equals("0"))
			strTemp = "M";
		else
			strTemp = "F";
	  %>
	  <td class="thinborder"><%=strTemp%></td>
	  <td class="thinborder"><%=WI.formatDate((String)vRetResult.elementAt(i+19), 16)%></td>
	  <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+21), "&nbsp;")%></div></td>
	  <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+22), "&nbsp;")%></div></td>
	  <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+23), "&nbsp;")%></div></td>
      <td class="thinborder"><%=WI.formatDate((String)vRetResult.elementAt(i+6),16)%></td>
      <td class="thinborder"><%=WI.formatDate((String)vRetResult.elementAt(i+7),16)%></td>
      <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+16), "&nbsp;")%></div></td>
	  <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+17), "&nbsp;")%></div></td>
	  <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+18), "&nbsp;")%></div></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+24), "&nbsp;")%></td>
	  <% 
		if ((i+15 < vRetResult.size() && 
				!strCurrentUserIndex.equals((String)vRetResult.elementAt(i+15)))
			|| (i+15 >= vRetResult.size()))
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;");
		else
			strTemp = "&nbsp;";
	  %>
      <td class="thinborder"><%=strTemp%></td>
    </tr>
    <%}// end for loop%>
  </table>
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>