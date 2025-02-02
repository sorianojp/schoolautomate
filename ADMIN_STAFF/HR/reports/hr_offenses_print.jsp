<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
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
<style>


body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
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
														"hr_offenses.jsp");
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
 vRetResult = hrStat.getEmployeeOffenses(dbOP, true);
int i = 0;
boolean bolPageBreak = false;
String strPrevUser = "";
boolean bolSameUser = false;

if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iPage = 1;
		int iTotalPage = 0;
		
		iTotalPage = vRetResult.size() / (25 * iMaxRecPerPage);
 		if(vRetResult.size() % (25 * iMaxRecPerPage) > 0)
			iTotalPage ++;			
		
		for (;iNumRec < vRetResult.size();iPage++){

			strPrevUser = "";
%>
<body onLoad="javascript:window.print();">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4" align="center"><strong><%=WI.fillTextValue("title_report")%></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="right"><%=WI.getTodaysDateTime()%></td>
    </tr>
    <tr> 
      <td width="49%" height="25" align="right"><%=iPage%> of <%=iTotalPage%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="22%" height="25" align="center"  class="thinborder"><font size="1"><strong>EMPLOYEE NAME </strong></font></td>
      <td width="15%" align="center"  class="thinborder"><strong><font size="1">OFFICE/DEPT</font></strong></td>
			<td width="13%" align="center"  class="thinborder"><strong><font size="1">&nbsp;DATE OF <br>
      OFFENSE / REPORT </font></strong></td>
      <td width="34%" align="center"  class="thinborder"><strong><font size="1">NAME OF OFFENSE / DETAIL </font></strong></td>
      <td width="16%" align="center"  class="thinborder"><font size="1"><strong>ACTION TAKEN / EFFECTIVE DATE(S)</strong></font></td>
      
    </tr>
 		<%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=25,++iIncr, ++iCount){
			i = iNumRec;
			bolSameUser = false;
			if(strPrevUser.equals((String)vRetResult.elementAt(i+15)))
				bolSameUser = true;
			
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>	
    <tr>
			<%
				if(bolSameUser)
					strTemp = "";
				else
					strTemp = WI.formatName((String)vRetResult.elementAt(i+2),
  									(String)vRetResult.elementAt(i+3),
									(String)vRetResult.elementAt(i+4),4);
			%>			
      <td class="thinborder">&nbsp;<%=strTemp%></td>
<%
				if(bolSameUser)
					strTemp = "";
				else{
					if((String)vRetResult.elementAt(i + 13)== null || (String)vRetResult.elementAt(i + 14)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}					
					
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 13),"") + strTemp +
										WI.getStrValue((String)vRetResult.elementAt(i + 14),"");
				}
			%>				
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>			
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7))%></td>
      <td class="thinborder"><strong>Offense</strong> :<%=(String)vRetResult.elementAt(i+5)%> <br>
        <strong>Detail</strong> :<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "N/a")%> </td>
	<% 
		if ((String)vRetResult.elementAt(i+9) != null) {
			strTemp = "<br>(" + (String)vRetResult.elementAt(i+9);
			strTemp +=  ((String)vRetResult.elementAt(i+10) != null)?
					" - " +  (String)vRetResult.elementAt(i+10) + ")": ")";

		}else strTemp = ""; %>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i+8))  + strTemp%> </td>
    </tr>
    <%
		strPrevUser = (String) vRetResult.elementAt(i+15);
		}// end for loop
	%>
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