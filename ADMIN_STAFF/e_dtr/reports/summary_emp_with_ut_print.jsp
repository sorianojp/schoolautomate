<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script> 
<body onLoad="javascript:window.print()">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Employees with Undertime  Record",
								"summary_emp_with_undertime_records.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"summary_emp_with_undertime_records.jsp");	
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

//end of authenticaion code.

ReportEDTR RE = new ReportEDTR(request);

String[] astrMonth={" &nbsp", "January", "February", "March", "April", "May", "June", "July",
					"August", "September","October", "November", "December"};
String strSchCode = dbOP.getSchoolIndex();
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
boolean bolPageBreak = false;

 	vRetResult = RE.searchUndertime(dbOP);
	if (vRetResult != null) {	
		int iCount = 0;
		int i = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 2;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
%>
<form name="dtr_op">
   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <%  if (vRetResult != null) 
	  		strTemp = (String)vRetResult.elementAt(0) + WI.getStrValue((String)vRetResult.elementAt(1)," - " , "", ""); 
		  else
		  	strTemp = "";	
  	%>
      <td height="25"  colspan="5" align="center" class="thinborder"><strong>SUMMARY 
          OF EMPLOYEES WITH UNDERTIME (<%=strTemp%>)</strong></td>
    </tr>
    <tr> 
      <td width="9%" height="25" align="center" class="thinborder"><strong><font size="1">EMP 
        ID</font></strong></td>
      <td width="31%" height="25" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></td>
      <td width="27%" align="center" class="thinborder"><font size="1"><strong>DEPT/OFFICE</strong></font></td>
      <td width="28%" height="25" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="5%" height="25" align="center" class="thinborder"><strong><font size="1">TOTAL 
      </font></strong></td>
     </tr>
    <%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=9,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>		
    <tr> 
      <td height="22" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2),
	  											(String)vRetResult.elementAt(i+3),
												(String)vRetResult.elementAt(i+4),4)%></td>
<% 
	strTemp = (String)vRetResult.elementAt(i+5);
	if (strTemp == null) 
		strTemp = (String)vRetResult.elementAt(i+6);
	else 
		strTemp += WI.getStrValue((String)vRetResult.elementAt(i+6), " :: " ,"","");
	
%>
      <td nowrap class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>

      <td nowrap class="thinborder">&nbsp; <%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder" align="right"> <%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(i+8)),false)%>&nbsp;</td>
     </tr>
    <%} // end for loop%>
  </table>
<%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<% dbOP.cleanUP(); %>