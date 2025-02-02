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

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<body onLoad="window.print()">
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_stat_logout.jsp.jsp");

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
														"hr_stat_logout.jsp.jsp");
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};

String[] astrSortByName    = {"College","Department","Emp. Status","No. or Children"};
String[] astrSortByVal     = {"c_code","d_code","user_status.status","count_"};

boolean[] abolShowList={false,false,false,false};							
boolean bolShowDetail = false;

if (WI.fillTextValue("show_details").equals("1")) 
	bolShowDetail = true;

Vector vRetResult = null;
int iIncrement = 0;


	vRetResult = hrStat.hrEmpLogout(dbOP);
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
		iIncrement = Integer.parseInt((String)vRetResult.elementAt(0));
		
	}else{
		strErrMsg = hrStat.getErrMsg();
	}


 if (strErrMsg != null) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
  <%}
if (vRetResult != null && vRetResult.size() > 0) {%>
<div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br> <br><br>


	<% if (request.getParameter("title_report") != null && request.getParameter("title_report").trim().length() > 0) {%>
		<strong><%=request.getParameter("title_report")%></strong><br>
<br>

        </font></div> 
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="49%" height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%></b></td>
      <td width="51%">&nbsp;  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="9%"  class="thinborder"><font size="1"><strong>ID NUMBER</strong></font></td>
      <td width="21%" height="25" align="center"  class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME</strong></font></td>
      <td width="8%" align="center"  class="thinborder"><font size="1"><strong>OFFICE</strong></font></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">EMP. 
        STATUS</font></strong></td>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">NO. 
        OF OB </font></strong></td>
      <% if (bolShowDetail) {%>
      <td width="20%" align="center" class="thinborder"><strong><font size="1">DATE 
        OF DEPARTURE<br>
        (TIME OUT - TIME IN) </font></strong></td>
      <td width="27%" align="center" class="thinborder"><strong><font size="1">DESTINATION<br>
        ( PURPOSE)</font></strong></td>
      <%}%>
    </tr>
    <% 	String strCurrentUserIndex = "";
	boolean bolSameUser = false; 
	
		for (int i=1; i < vRetResult.size(); i+=iIncrement){
		 bolSameUser = false;
		if (i == 1) strCurrentUserIndex = (String)vRetResult.elementAt(i);
		
		if (i != 1 && strCurrentUserIndex.equals((String)vRetResult.elementAt(i)))
			bolSameUser = true;
		else
			strCurrentUserIndex = (String)vRetResult.elementAt(i);
		
		if (bolSameUser) 
			strTemp = "&nbsp;";
		else
			strTemp = strCurrentUserIndex;
	%>
    <tr>
      <td class="thinborder"><%=strTemp%></td>
      <% 
	   if (bolSameUser) 
	   		strTemp = "&nbsp;";
		else{
			strTemp = WI.formatName((String)vRetResult.elementAt(i+1),
									(String)vRetResult.elementAt(i+2),
									(String)vRetResult.elementAt(i+3),4);
		}
	%>
      <td height="23" class="thinborder">&nbsp;<%=strTemp%></td>
      <% 
	   if (bolSameUser) 
	   		strTemp = "&nbsp;";
		else{
			strTemp = (String)vRetResult.elementAt(i+4);
			if (strTemp == null) strTemp = (String)vRetResult.elementAt(i+5);
			else strTemp += WI.getStrValue((String)vRetResult.elementAt(i+5)," :: ","","");
		}
	%>
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <% 
	   if (bolSameUser) 
	   		strTemp = "&nbsp;";
		else
			strTemp = (String)vRetResult.elementAt(i+6);
	%>
      <td class="thinborder"><%=strTemp%></td>
      <% 
	   if (bolSameUser) 
	   		strTemp = "&nbsp;";
		else
			strTemp = (String)vRetResult.elementAt(i+7);
	%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <% 
	if (bolShowDetail) {
	  strTemp = (String) vRetResult.elementAt(i+10);
	  
	  if ((String)vRetResult.elementAt(i+11) != null){
	  	strTemp +="<br>(" +  CommonUtil.convert24HRTo12Hr(
						Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+11),"0")));
						
		if ( (String)vRetResult.elementAt(i+12) != null){
			strTemp += " - " + CommonUtil.convert24HRTo12Hr(
						Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+12),"0")));
		}
		
		strTemp += ")";
	  }

	%>
      <td class="thinborder"><%=strTemp%></td>
      <%
	 	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+8));
		strTemp += WI.getStrValue((String)vRetResult.elementAt(i+9),"<br>(",")","");
	 %>
      <td class="thinborder"><%=strTemp%></td>
      <%}%>
    </tr>
    <%}// end for loop%>
  </table>
<!--
  <script language="javascript">
  	window.setInterval("javascript:window.print()", 0);
  </script>
-->
<%}%>


</body>
</html>
<%
	dbOP.cleanUP();
%>