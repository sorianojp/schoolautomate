<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">


<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>

TD{
	font-size:11px;
	font-family:Verdana;
}
SELECT{
	font-size:12px;
}

table.thinborder{
	border-top-width: 1px;
	border-right-width: 1px;
	border-top-style: solid;
	border-right-style: solid;
	border-top-color: #000000;
	border-right-color: #000000;
}
td.thinborder{
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-size: 11px;
	border-bottom-width: 1px;
	border-left-width: 1px;
	border-bottom-style: solid;
	border-left-style: solid;
	border-bottom-color: #000000;
	border-left-color: #000000;
}
</style>
</head>
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRApplicantSearch" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Applicants","hr_applicant_viewall.jsp");

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
														"HR Management","APPLICANTS DIRECTORY",request.getRemoteAddr(),
														"hr_applicant_viewall_print.jsp");
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

HRApplicantSearch hrStat = new HRApplicantSearch (request);


	vRetResult = hrStat.searchApplicants(dbOP);
	

	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
	else	
		iSearchResult = hrStat.getSearchCount();
		


String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal","at least","at most"};
String[] astrDropListValGT = {"'='","'>='","'<='"};
String[] astrSortByName    = {"Reference ID", "Last Name","First Name","Date Application"};
String[] astrSortByVal     = {"APPLICANT_ID","lname","fname","APPLICATION_DATE"};

String[] astrIsSuitable ={ "&nbsp;",
						   "<img src=\"../../../images/tick.gif\">"};

boolean bolShowIntvResult = true;
if(WI.fillTextValue("remove_intv_result").length() > 0 && WI.fillTextValue("final_intv_result").length() == 0 &&
	WI.fillTextValue("ok_interview").length() == 0) {
	
	bolShowIntvResult = false;
}		
%>
<body onLoad="javascript:window.print()">
<% if (strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><font color="#FF0000" size="3"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
    <%} if (vRetResult  != null && vRetResult.size() > 0)  {%>
  <div align="center">
    <font size="2" face="Verdana, Arial, Helvetica, sans-serif">  
	 <strong> <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
    <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
    <%=SchoolInformation.getInfo1(dbOP,false,false)%> </font><br> 
    <br>
    
  </div>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="7" class="thinborderLEFT" align="center"><strong>LIST OF APPLICANTS</strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center"> 
      <td width="13%" height="25" class="thinborder"><font size="1">Reference ID </font></td>
      <td width="29%" class="thinborder"><font size="1">Name</font></td>
      <td width="20%" class="thinborder"><font size="1">Course</font></td>
      <td width="13%" class="thinborder"><font size="1">Application Date</font></td>
      <td width="27%" class="thinborder"><font size="1">Contact Information</font></td>
<%if(bolShowIntvResult) {%>
      <td width="9%" class="thinborder"><font size="1">Status</font></td>
      <td width="9%" class="thinborder"><font size="1">Suitable For Interview?</font></td>
<%}%>
    </tr>
<% 	String[] astrConvertIntvStatus = {"REJECTED","ACCEPTED","PENDING","WL","&nbsp;"};
	for (int i = 0; i < vRetResult.size(); i+=11) {%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2),
	  												(String)vRetResult.elementAt(i+3),
													(String)vRetResult.elementAt(i+4),4)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+10),"&nbsp;")%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
      <% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5));
	if (WI.getStrValue((String)vRetResult.elementAt(i+6)).length() > 0) {
		if (strTemp.length() == 0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
		else
			strTemp += "<br>&nbsp;" + WI.getStrValue((String)vRetResult.elementAt(i+6));
	}
%> 
<%if(bolShowIntvResult) {%>
      <td class="thinborder"><div align="center"><%=astrConvertIntvStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+9),"4"))]%> </div></td>
      <td align="center" class="thinborder">
	  <%=astrIsSuitable[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+8), "0"))]%>	  </td>
<%}%>
    </tr>
<%}%>
</table>
<%}%>
</body>
</html>
<% 
	dbOP.cleanUP();
%>
