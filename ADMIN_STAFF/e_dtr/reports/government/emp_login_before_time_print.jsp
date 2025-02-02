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
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

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
<body onLoad="javascrip:window.print();">
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
	String strOption = WI.fillTextValue("show_option");
 
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Employees with Undertime  Record",
								"emp_login_before_time.jsp");
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
														"emp_login_before_time.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

	ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
	int i = 0;
	String strSchCode = dbOP.getSchoolIndex();
	String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
	String strCurDate = null;
	boolean bolPageBreak = false;
	
	vRetResult = rptExtn.generateLoginBeforeSpecified(dbOP);
	
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
			strCurDate = null;
%>
<form name="dtr_op">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
		<%
			if(strOption.equals("0"))
				strTemp2 = " before ";
			else if(strOption.equals("1"))
				strTemp2 = " between ";
			else
				strTemp2 = " after ";
			
			if(!strOption.equals("1")){
				strTemp2 += WI.fillTextValue("hour") + " : " +WI.fillTextValue("minute");
			}
			
			strTemp = WI.fillTextValue("am_pm");
			if(strTemp.equals("1"))
				strTemp = " PM";
			else
				strTemp = " AM";
		%>
    <td width="50%"><strong>Employees with login <%=strTemp2%> : <%=strTemp%></strong></td>
    <td width="50%" align="right"> Date/Time printed: <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td  width="5%" align="center"  class="thinborder">&nbsp;</td> 
      <td  width="9%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="26%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
        NAME </font></strong></td>
      <td width="29%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
      <td width="22%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">TIME IN </font></strong></td>
    </tr>
		<%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=14,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		if(strCurDate == null || !((String)vRetResult.elementAt(i + 10)).equals(strCurDate)){
			strCurDate = (String)vRetResult.elementAt(i + 10);
		%>
		<tr>
      <td height="25" colspan="6" class="thinborder"><strong>DATE : <%=strCurDate%></strong></td>
    </tr>
		<%}%>
    <tr>
      <td align="right" class="thinborder"><%=iIncr%>&nbsp;</td> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder">&nbsp; 
	  <% 
	  	strTemp = "";
	  	if(vRetResult.elementAt(i + 7) != null) {
	  		if(vRetResult.elementAt(i + 8) != null) {
				strTemp = (String)vRetResult.elementAt(i + 7) + " / "  + (String)vRetResult.elementAt(i + 8);
			}else{
				strTemp = (String)vRetResult.elementAt(i + 7);
			}//end of inner loop/
	     }else 
	 		if(vRetResult.elementAt(i + 8) != null){ 
				strTemp = (String)vRetResult.elementAt(i + 8);
			}
	  %><%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%>&nbsp;</td>
    </tr>
    <%}//end of for loop to display employee information.%>
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