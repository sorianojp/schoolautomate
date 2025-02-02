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
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>

<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
try
	{
		dbOP = new DBOperation();

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"HR Management","REPORTS AND STATISTICS",
											request.getRemoteAddr(),"hr_awards.jsp");
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

String[] astrSortByName    = {"Last Name","First Name", "College", "Department/Office"};
String[] astrSortByVal     = {"lname","user_table.fname","c_name", "D_NAME"};

if(!bolIsSchool)
	astrSortByName[2] = "Division";
	

Vector vRetResult = null;
Vector vAwardDetail = null;
int iDetail = 0;
boolean bolPageBreak = false;
int i = 0;
 	vRetResult = hrStat.awardsRecognitions(dbOP, true);
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){	
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <% if ( strErrMsg  != null) {%>
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
 <%}%>
    <tr> 
      <td width="3%" height="25"><div align="center"><font size="2">
	  <strong>
	  	<%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br> <br>


	<% if (request.getParameter("title_report") != null && request.getParameter("title_report").trim().length() > 0) {%>
	<strong><%=request.getParameter("title_report")%></strong><br>
	<br>&nbsp;
	<%}%>
        </font></div> </td>
    </tr> 
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4" align="center"><strong>:::: AWARDS/RECOGNITIONS REPORTS ::::</strong></td>
    </tr>
  </table>

     <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="23%" height="25" class="thinborder"><font size="1">EMPLOYEE NAME</strong></font></td>
      <td width="19%" class="thinborder">IMMEDIATE HEAD / OFFICE</td>
      <td width="58%" class="thinborder"> <font size="1">AWARDS/RECOGNITIONS DETAIL </font></td>
    </tr>
		<%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){
			i = iNumRec;
			vAwardDetail = (Vector)vRetResult.elementAt(i+9);
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>		
    <tr>
	
      <td height="25" valign="top" class="thinborder">&nbsp;<strong><%=WI.formatName((String)vRetResult.elementAt(i+2),
	  													(String)vRetResult.elementAt(i+3),
					 	  							    (String)vRetResult.elementAt(i+4),4)%></strong>
																<br>&nbsp;<%=vRetResult.elementAt(i + 1)%>
																<br>&nbsp;<%=vRetResult.elementAt(i + 10)%></td>
      <% 
				strTemp = (String)vRetResult.elementAt(i+5);
				if (strTemp == null) 
					strTemp = (String)vRetResult.elementAt(i+6);
				else 
					strTemp += WI.getStrValue((String)vRetResult.elementAt(i+6)," :: ","","");
			%>																	
      <td valign="top" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11))%><br>&nbsp;<%=strTemp%></td>
      <td valign="top" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <%
				strTemp = "";
				for(iDetail = 0; iDetail < vAwardDetail.size(); iDetail += 10){%>
				<tr>
				<%
					strTemp = (String)vAwardDetail.elementAt(iDetail+1);
					strTemp += "-" + (String)vAwardDetail.elementAt(iDetail+2);
					strTemp += WI.getStrValue((String)vAwardDetail.elementAt(iDetail+4), " [", "]", "[--]");
				%>
          <td width="79%">&nbsp;<font size="1"><%=strTemp%></font></td>
        </tr>
				<%}%>
      </table></td>
    </tr>
    <%}// end for loop%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</body>
</html>
<%
	dbOP.cleanUP();
%>