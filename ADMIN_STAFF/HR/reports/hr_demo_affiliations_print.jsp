<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
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
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script> 

<body onLoad="window.print()">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Dependents","hr_demo_relationship.jsp");

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
														"hr_demo_relationship.jsp");
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
String strSchCode = dbOP.getSchoolIndex();
if(bolIsSchool)
   strTemp = "College";
else
   strTemp = "Division";
String[] astrSortByName    = {strTemp,"Department","Emp. Status"};
String[] astrSortByVal     = {"c_code","d_code","user_status.status",};

boolean[] abolShowList={false,false,false,false};							
boolean bolShowOneDetail = false;
int iIndex =1;
String[] astrRelation = {"Spouse","Child","Brother", "Sister", "Parent/Guardian"};

for(; iIndex <= 3; iIndex++){
	if(WI.fillTextValue("checkbox"+iIndex).equals("1")){
		abolShowList[iIndex] = true;
		bolShowOneDetail = true;
	}	
}

Vector vRetResult = null;
	String strCurrentUserIndex = "";
	boolean bolSameUser = false;
 	boolean bolFirstLineEntry = false;
	int iMaxEmployeePerPage = Integer.parseInt(WI.fillTextValue("max_lines"));
  int iIncrementNextPage = iMaxEmployeePerPage + 2;  
  int iCount = 0;
	vRetResult = hrStat.getDemographicAffilitations(dbOP); 
	if (vRetResult != null && vRetResult.size() > 0) {
	for (int i = 0; i < vRetResult.size();){
		bolFirstLineEntry = true;	
		iCount = 0;
	
%>
<form action="./hr_demo_relationship.jsp" method="post" name="form_" >
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <% if ( strErrMsg  != null) {%>
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
 <%}%>
    <tr> 
      <td width="3%" height="25"><div align="center"><font size="2"><strong>
	  	<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br> <br><br>


	<% if (request.getParameter("title_report") != null && request.getParameter("title_report").trim().length() > 0) {%>
		<strong><%=request.getParameter("title_report")%></strong><br>
<br>
<br>

	<%}%>
        </font></div> </td>
    </tr> 
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="22%" height="25" align="center"  class="thinborder"><font size="1"><strong>EMPLOYEE 
            NAME</strong></font></td>
      <td width="12%" align="center"  class="thinborder"><font size="1"><strong>OFFICE</strong></font></td>

      <td width="10%" align="center" class="thinborder"><strong><font size="1">EMP. 
          STATUS</font></strong></td>
      <td width="26%" align="center" class="thinborder"><strong><font size="1">GROUP NAME </font></strong></td>
    </tr>
    <% 
		for (; i < vRetResult.size() && iCount < iMaxEmployeePerPage; i+=20,++iCount){
		iIndex = 1;

		 bolSameUser = false;
		if (i == 1) 
			strCurrentUserIndex = (String)vRetResult.elementAt(i);
		
		if (i != 1 && strCurrentUserIndex.equals((String)vRetResult.elementAt(i)))
			bolSameUser = true;
		else
			strCurrentUserIndex = (String)vRetResult.elementAt(i);
				
		if (bolSameUser) 
			strTemp = "&nbsp;";
		else
			strTemp = WI.formatName((String)vRetResult.elementAt(i+2),
									(String)vRetResult.elementAt(i+3),
									(String)vRetResult.elementAt(i+4),4);
	%>
    <tr> 
      <td height="23" class="thinborder">&nbsp;<%=strTemp%></td>
   <% 
	   if (bolSameUser) 
	   		strTemp = "&nbsp;";
		else{
			strTemp = (String)vRetResult.elementAt(i+5);
			if (strTemp == null) strTemp = (String)vRetResult.elementAt(i+6);
			else strTemp += WI.getStrValue((String)vRetResult.elementAt(i+6)," :: ","","");
		}
	%>
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
   <% 
	   if (bolSameUser) 
	   		strTemp = "&nbsp;";
		else
			strTemp = (String)vRetResult.elementAt(i+11);
	%>
	  
      <td class="thinborder"><%=strTemp%></td>
 			<%
				strTemp = (String)vRetResult.elementAt(i+10);
			%>
      <td class="thinborder"><%=strTemp%></td>
    </tr>
    <%}// end for loop%>
  </table>
<% if (i < vRetResult.size()) { %>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%} // if (i < vRetResult.size())
 } // END OF outer for loop 
} // end vRetResult  == null%>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>