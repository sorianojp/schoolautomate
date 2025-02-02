<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Educational Statistics</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
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
	font-size: 11px;
    }
</style>
</head>

<body marginheight="0" onLoad="window.print()">
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

HRStatsReports hrStat = new HRStatsReports(request);


	vRetResult = hrStat.searchHREduc(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
	else	
		iSearchResult = hrStat.getSearchCount();

boolean[] abolShowColumns={false, false, false, false, false,false, false}; 
boolean bolShowAtLeastOne = false;
int iShowColumns =1;
for (int i = 0; i < 7; i++){
	if ( WI.fillTextValue("checkbox"+i).equals("1")){
		abolShowColumns[i]= true;
		iShowColumns++;
	}
}
if (iShowColumns ==1) {
	abolShowColumns[2] = true;
	iShowColumns = 2;	
}
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4"><div align="center"><font size="2"><strong>
	  	<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br> <br><br>

	<% if (request.getParameter("title_report") != null && request.getParameter("title_report").trim().length() > 0) {%>
		<strong><%=request.getParameter("title_report")%></strong><br>
<br>
<br>

	<%}%>
        </font></div></td>
    </tr>
</table>

  <% if (vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="20%"  class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
          NAME </strong></font></div></td>
      <% if (abolShowColumns[0]) {%>
      <td width="8%"  class="thinborder"> <div align="center"><font size="1"><strong>EMP. 
          STATUS</strong></font></div></td>
      <%} if (abolShowColumns[1]){%>
      <td width="9%"  class="thinborder"><div align="center"><strong><font size="1">POSITION</font></strong></div></td>
      <%} if (abolShowColumns[5]){%>
      <td width="9%"  class="thinborder"><div align="center"><strong><font size="1">OFFICE 
          </font></strong></div></td>
      <%} if (abolShowColumns[4]) {%>
      <td width="7%"  class="thinborder"><font size="1"><strong>EDUC. LEVEL</strong></font></td>
      <%} if (abolShowColumns[2]){%>
      <td width="32%"  class="thinborder"><div align="center"><font size="1"><strong><font size="1">DEGREE 
          (UNITS)</font></strong></font></div></td>
      <%} if (abolShowColumns[3]){%>
      <td width="8%" align="center" class="thinborder"><strong><font size="1"><strong>SCHOOL</strong></font></strong></td>
      <%} if (abolShowColumns[6]){%>
       <td width="15%" align="center" class="thinborder"><strong><font size="1">SCHOOL NAME</font></strong></td>
      <%}%>
    </tr>
    <% 
		String strCurrentUser = null;
		String strCurrentCollege = null;
		String strPrevCollege = null;
		boolean bolSameUser = false;
		boolean bolSameCollege = false;
		int iChkBox = 0;
		
		for (int i=0; i < vRetResult.size(); i+=20){
			bolSameUser = false;
			bolSameCollege = false;
		
		if (strCurrentUser == null) {
			strCurrentUser = (String)vRetResult.elementAt(i+2);
			strPrevCollege = (String)vRetResult.elementAt(i+12); // college
			if (strPrevCollege == null)
				strPrevCollege = (String)vRetResult.elementAt(i+13);
			else
				strPrevCollege +=  WI.getStrValue((String)vRetResult.elementAt(i+13),"::","","");
		}
		
		if (strCurrentUser.equals((String)vRetResult.elementAt(i+2)) && i != 0)
			bolSameUser = true;
		else
			strCurrentUser = (String)vRetResult.elementAt(i+2);

		if (!bolSameUser){
			strCurrentCollege = (String)vRetResult.elementAt(i+12); // college
			if (strCurrentCollege == null)
				strCurrentCollege = (String)vRetResult.elementAt(i+13);
			else
				strCurrentCollege +=  WI.getStrValue((String)vRetResult.elementAt(i+13),"::","","");
				
			if(strCurrentCollege == null) {
				strCurrentCollege = "College info not set";
				strPrevCollege = "";
			}
			else 				
			if (strPrevCollege.equals(strCurrentCollege)){
				bolSameCollege = true;
			}else{
				strPrevCollege = strCurrentCollege;
			}

			strTemp = WI.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),
	  							  (String)vRetResult.elementAt(i+5),4);
		}else{
			strTemp = "";
			bolSameCollege = true;	
		}	

		if (!bolSameCollege || i == 0) {
			if (WI.fillTextValue("checkboxED"+iChkBox).equals("1")){
	%>
	<tr bgcolor="#F2E8D9">
		<td  colspan="<%=iShowColumns%>" class="thinborder"><strong>&nbsp;<%=strPrevCollege%></strong></td>
	</tr>
<%}	iChkBox++;
 } //end !bolSameCollege 
 		


 	if (!WI.fillTextValue("checkboxED"+iChkBox).equals("1")) {
		iChkBox++;
		continue;
 	}
	iChkBox++;
 %>
    <tr> 
      <td class="thinborder">&nbsp;<%=strTemp.toUpperCase()%> </td>
      <% if (abolShowColumns[0]) { 
	  		if (bolSameUser) strTemp = "";
			else
				strTemp = (String)vRetResult.elementAt(i+14);
	  %>
      <td class="thinborder">&nbsp;<%=strTemp%> </td>
      <%}if (abolShowColumns[1]) { 
	  		if (bolSameUser) strTemp = "";
			else
				strTemp = (String)vRetResult.elementAt(i+15);	  
	  %>
      <td class="thinborder">&nbsp;<%=strTemp%> </td>
      <%}if (abolShowColumns[5]) {  
	  		if (bolSameUser) 
				strTemp = "";
			else{
		  		strTemp = (String)vRetResult.elementAt(i+17);
				if (strTemp == null) 
					strTemp = (String)vRetResult.elementAt(i +18);
				else 	
					strTemp += WI.getStrValue((String)vRetResult.elementAt(i+18),"::","","");
			}
	  %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%> </td>
      <%} if (abolShowColumns[4]) { %>	  
      <td class="thinborder">&nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(i+1))%></td>
      <%}if (abolShowColumns[2]) { %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7))%> <%=WI.getStrValue((String)vRetResult.elementAt(i+16),"(",")","")%><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"(",")","")%></td>
      <%}if (abolShowColumns[3]) { %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
      <%}if (abolShowColumns[6]) { %>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+19))%></td>
      <%}%>
    </tr>
    <%}// end for loop
	%>
  </table>
<%}%>

</body>
</html>
<%
	dbOP.cleanUP();
%>