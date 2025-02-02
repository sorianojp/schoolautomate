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
<body onLoad="javascript:window.print()">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Employees with Undertime  Record",
								"emp_without_late_ut.jsp");
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
														"emp_without_late_ut.jsp");	
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

	ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
	int i = 0;
 	boolean bolPageBreak = false;
	
	String[] astrMonth={" &nbsp", "January", "February", "March", "April", "May", "June", "July",
					"August", "September","October", "November", "December"};


	String strSchCode = dbOP.getSchoolIndex();
	String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
	String[] astrShowOpt = {"Without Tardiness AND Undertime","Without Tardiness","Without Undertime",
													"Without Tardiness OR Undertime"};
	vRetResult = rptExtn.generateWoutLateUt(dbOP);

	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
%>
  <form name="dtr_op">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<%
				if(WI.fillTextValue("month_of").length() > 0){
					strTemp2 = astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))] +" "+ WI.fillTextValue("year_of");
				}else{
					strTemp2 = WI.fillTextValue("date_fr") + WI.getStrValue(WI.fillTextValue("date_to"), " - ","","");
				}
			%>
			<td><%=astrShowOpt[Integer.parseInt(WI.fillTextValue("show_opt"))]%> for the period : <%=strTemp2%></td>
		</tr>
	</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="12%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="32%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
        NAME </font></strong></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">STATUS</font></strong></td>
      <td width="20%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="21%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
    </tr>
    <%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=15,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;	 
	 %>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder">&nbsp; 
	  <% 
	  	strTemp = "";
	  	if(vRetResult.elementAt(i + 8) != null) {
	  		if(vRetResult.elementAt(i + 9) != null) {
				strTemp = (String)vRetResult.elementAt(i + 8) + " / "  + (String)vRetResult.elementAt(i + 9);
			}else{
				strTemp = (String)vRetResult.elementAt(i + 8);
			}//end of inner loop/
	     }else 
	 		if(vRetResult.elementAt(i + 9) != null){ 
				strTemp = (String)vRetResult.elementAt(i + 9);
			}
	  %><%=strTemp%>      </td>
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