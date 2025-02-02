<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrConvertSem= {"Summer","1st Term","2nd Term","3rd Term","4th Term"};

	WebInterface WI = new WebInterface(request);

//add security here.

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
							//							"fee_adjustment.jsp");
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
Vector vRetResult = null;
Vector vGrantType = null;

ReportFeeAssessment rFA = new ReportFeeAssessment();
	vRetResult = rFA.getStudListAssistanceSummaryPerGrantUB(dbOP,request);
	if(vRetResult == null) {
		strErrMsg = rFA.getErrMsg();
	}
	else
		vGrantType = (Vector)vRetResult.remove(0);
		

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");

dbOP.cleanUP();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Scholarship Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css"  type="text/css" rel="stylesheet">
<link href="../../../css/tableBorder.css"  type="text/css" rel="stylesheet">
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
	font-size: 10px;	
    }

    TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
</head>
<body onLoad="window.print();">
<%if(strErrMsg != null) {%>
	<p align="center" style="font-weight:bold; font-size:14px; color:#FF0000"><%=strErrMsg%></p>
<%return;}
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25"><div align="center"><font size="2"><strong>LIST OF STUDENTS WITH EDUCATIONAL ASSISTANCE - PER GRANT</strong></font> <br>
          SY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>, <%=astrConvertSem[Integer.parseInt(request.getParameter("semester"))]%></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <tr> 
      <td width="14%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>COURSE<%if(!bolIsBasic){%>- YEAR<%}%></strong></font> </div></td>
	  <td width="35%" class="thinborder"> <div align="center"><font size="1"><strong>GRANT NAME</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
    </tr>
<% 
  /**
   *  [0]Vector [0] MAIN_TYPE_NAME, [1] total discount for that grant type.
   * 
   *  [0] = total Disc Amt.
   *  [0] Stud Name [1] main adjustment [2] discount_type  [3] year level
   *  [4] id number [5]  course  [6]  major  [7]  discount_amount, [8] date approved, [9] approval number.
   */

String strTotalGrant = (String)vRetResult.remove(0);
System.out.println(vRetResult);

for(int i = 0; i < vGrantType.size(); i += 2){%>
    <tr>
      <td height="25" colspan="5" class="thinborder" style="font-weight:bold"><%=vGrantType.elementAt(i)%>: <%=vGrantType.elementAt(i + 1)%></td>
    </tr>
	<%while(vRetResult.size() > 0) {
		if(!vRetResult.elementAt(1).equals(vGrantType.elementAt(i)))
			break;	
	%>
		<tr> 
		  <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(4)%></font></td>
		  <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(0)%></font></td>
		<%
			strTemp = (String)vRetResult.elementAt(5);
			if(bolIsBasic)	
				strTemp = dbOP.getBasicEducationLevel(Integer.parseInt(strTemp));
			else {
				if(vRetResult.elementAt(3) != null)
					strTemp = strTemp + " - "+vRetResult.elementAt(3);
			}	
		%>
		  <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
		  <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(10)%></font></td>
		  <td class="thinborder" align="right"><font size="1"><%=(String)vRetResult.elementAt(7)%></font></td>
		</tr>
	<%
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	}%>
<%}%>
  </table>
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>