<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Demographic Children Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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

if(bolIsSchool)
   strTemp = "College";
else
   strTemp = "Division";
String[] astrSortByName    = {strTemp,"Department","Emp. Status","No. or Children"};
String[] astrSortByVal     = {"c_code","d_code","user_status.status","count_"};

boolean[] abolShowList={false,false,false,false};							
boolean bolShowOneDetail = false;
int iIndex =1;


for(; iIndex <= 3; iIndex++){
	if(WI.fillTextValue("checkbox"+iIndex).equals("1")){
		abolShowList[iIndex] = true;
		bolShowOneDetail = true;
	}	
}

Vector vRetResult = null;
int iIncrement = 0;

if (WI.fillTextValue("show_list").equals("1")){

	vRetResult = hrStat.hrDemoDependents(dbOP);
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
		iIncrement = Integer.parseInt((String)vRetResult.elementAt(0));
		
	}else{
		strErrMsg = hrStat.getErrMsg();
	}
}
%>
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
  <% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="49%" height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%> 	 </b></td>
      <td width="51%">&nbsp; </td>
    </tr>
  </table>
 
<% 	String strCurrentUserIndex = "";
	boolean bolSameUser = false;
 	boolean bolFirstLineEntry = false;
	int iMaxEmployeePerPage = Integer.parseInt(WI.fillTextValue("max_lines"));
    int iIncrementNextPage = iMaxEmployeePerPage + 2;  
    int iCount = 0;

	for (int i =1; i < vRetResult.size();){
		bolFirstLineEntry = true;	
%>
	 
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="22%" height="25"  class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
          NAME</strong></font></div></td>
      <td width="11%"  class="thinborder"><div align="center"><font size="1"><strong>OFFICE</strong></font></div></td>

      <td width="12%" align="center" class="thinborder"><strong><font size="1">EMP. 
        STATUS</font></strong></td>
      <td width="11%" class="thinborder"><strong><font size="1">NO. OF CHILDREN</font></strong></td>
      <% iIndex = 1; if (abolShowList[iIndex++]){%>
      <td width="24%" class="thinborder"><font size="1"><strong>NAME OF CHILD</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>	  
      <td width="10%" class="thinborder"><font size="1"><strong>BIRTHDATE</strong></font></td>
      <%}if (abolShowList[iIndex]){%>
      <td width="10%" class="thinborder"><strong><font size="1">AGE</font></strong></td>
      <%}%>
    </tr>		
    <% iCount = 1;
		for (; i < vRetResult.size() && iCount < iMaxEmployeePerPage; i+=iIncrement,++iCount){
		iIndex = 1;

		 bolSameUser = false;
		if (i == 1) strCurrentUserIndex = (String)vRetResult.elementAt(i);
		
		if (i != 1 && strCurrentUserIndex.equals((String)vRetResult.elementAt(i))
		    && !bolFirstLineEntry)
			bolSameUser = true;
		else
			strCurrentUserIndex = (String)vRetResult.elementAt(i);
		
		bolFirstLineEntry = false;
		
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
			strTemp = (String)vRetResult.elementAt(i+7);
	%>
	  
      <td class="thinborder"><%=strTemp%></td>
   <% 
	   if (bolSameUser) 
	   		strTemp = "&nbsp;";
		else{
			strTemp = (String)vRetResult.elementAt(i+8);
		}
	%>
	  <td class="thinborder"><%=strTemp%></td>
      <%if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+9),
	  										  (String)vRetResult.elementAt(i+10),
											  (String)vRetResult.elementAt(i+11),4)
											 %></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex]){
	  		if ((String)vRetResult.elementAt(i+12) != null) {
				strTemp = "&nbsp;" + 
						 ConversionTable.differenceInYearMonthDaysNow((String)vRetResult.elementAt(i+12));
				if (strTemp.indexOf("Y") != -1) 
					strTemp = strTemp.substring(0,strTemp.indexOf("Y"));
			}else
				strTemp = "&nbsp;";	  
	  %>
      <td class="thinborder"><%=strTemp%></td>
      <%}%>
    </tr>
    <%}// end of inner for loop %>
  </table>
<% if (i < vRetResult.size()) { %>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%} // if (i < vRetResult.size())
 } // END OF outer for loop 
} // end vRetResult  == null%>

</body>
</html>
<%
	dbOP.cleanUP();
%>