<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css"> 
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
 <script language="JavaScript" src="../../../jscript/common.js"></script> 
<body onLoad="javascript:window.print();">
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
	boolean bolHasTeam = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Employees with Undertime  Record",
								"summary_emp_with_ob.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");								
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
														"summary_emp_with_ob.jsp");	
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

ReportEDTRExtn RE = new ReportEDTRExtn(request);
String[] astrMonth={" &nbsp", "January", "February", "March", "April", "May", "June", "July",
					"August", "September","October", "November", "December"};

String strSchCode = dbOP.getSchoolIndex();
boolean bolPageBreak = false;
 	vRetResult = RE.searchWithOBForPeriod(dbOP);
	if (vRetResult != null) {	
		int iCount = 0;
		int i = 0;
		int iPage = 1; 
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;

		int iTotalPages = (vRetResult.size())/(30*iMaxRecPerPage);	
		if((vRetResult.size() % (30*iMaxRecPerPage)) > 0) ++iTotalPages;

		for (;iNumRec < vRetResult.size();iPage++){	
%>
<form name="dtr_op">
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
			<%
				if(WI.fillTextValue("month_of").length() > 0){
					strTemp2 = astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))] +" "+ WI.fillTextValue("year_of");
				}else{
					strTemp2 = WI.fillTextValue("from_date") + WI.getStrValue(WI.fillTextValue("to_date"), " - ","","");
				}
			%>      
			<td height="25"  colspan="5" align="center"><strong>SUMMARY OF EMPLOYEES WITH OFFICIAL BUSINESS/TIME<br>
			  <%=strTemp2%></strong></td>
    </tr>
    <tr>
      <td height="25"  colspan="5" align="right"><%=iPage%> of <%=iTotalPages%></td>
    </tr>
    </table>
		<table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
      <td width="8%" height="25" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="25%" height="25" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE 
        NAME </strong></font></td>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <td width="20%" align="center" class="thinborder"><strong><font size="1">DATE</font></strong> </td>
      <td width="35%" height="25" align="center" class="thinborder"><font size="1"><strong>DETAILS </strong></font></td>
    </tr>
    <%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=30,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>		
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3),
	  											(String)vRetResult.elementAt(i+4),
												(String)vRetResult.elementAt(i+5),4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+21)%></td>
			<% 
				strTemp = (String)vRetResult.elementAt(i+19);
				if(strTemp == null){
					strTemp2 = (String)vRetResult.elementAt(i+14); 
 					strTemp2 = strTemp2 + "<br>"+CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i + 15))) + " to " +
									CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i + 16)));

 				} else {
					strTemp2 = (String)vRetResult.elementAt(i+14) + " - " + (String)vRetResult.elementAt(i+19); 
				}
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp2)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12))%><br>
			<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
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