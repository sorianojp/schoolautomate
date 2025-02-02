<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style  type="text/css">

    TD.borderALL {
	border-right: solid 1px #000000;
	border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.borderBottomLeft {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.borderBottomLeftRight {
	border-right: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

	
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT-LOANS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-RETIREMENT-LOANS-Create Loans","loan_code_mgmt_print.jsp");
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

	//end of authenticaion code.
	Vector vRetResult = null;

	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	String[] astrLoanType = {"Regular Retirement Loan","Emergency Retirement Loan"};
	String[] astrSemester = {"","1st sem","2nd sem"};
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};
	String[] astrUnit = {"%",""};
	String[] astrFrequency = {"per annum","per month","per day"};
	
	vRetResult = PRRetLoan.operateOnLoanCode(dbOP,request,4);
%>
<body>
<form name="form_" method="post" action="./loan_code_mgmt_print.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="30" colspan="6" class="borderALL"><div align="center"><strong><font color="#000000">:: 
          LIST OF EXISTING LOAN CODE ::</font></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25" class="borderBottomLeft"><div align="center"><font size="1">LOAN CODE</font></div></td>
      <td width="12%" class="borderBottomLeft"><div align="center"><font size="1">SCHOOL YEAR</font></div></td>
      <td width="11%" class="borderBottomLeft"><div align="center"><font size="1">SEMESTER</font></div></td>
      <td width="22%" class="borderBottomLeft"><div align="center"><font size="1">LOAN TYPE</font></div></td>
      <td width="10%" height="25" class="borderBottomLeft"><div align="center"><font size="1">INTEREST</font></div></td>
      <td width="18%" class="borderBottomLeftRight"><div align="center"><font size="1">DATE OF 1ST INT. PAYMENT</font></div></td>
    </tr>
    <%for (int i = 0;i < vRetResult.size(); i+=11){%>
    <tr> 
      <td height="25" class="borderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="borderBottomLeft"> <div align="center"> <%=(String)vRetResult.elementAt(i+2)%> - <%=(String)vRetResult.elementAt(i+3)%> </div></td>
      <td class="borderBottomLeft"> <%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+4),"1"))]%> </td>
      <td class="borderBottomLeft"> <%=astrLoanType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"))]%> </td>
      <td height="25" class="borderBottomLeft"> <%=(String)vRetResult.elementAt(i+6)%> <%=astrUnit[Integer.parseInt((String)vRetResult.elementAt(i+7))]%> <%=astrFrequency[Integer.parseInt((String)vRetResult.elementAt(i+8))]%> </td>
      <td class="borderBottomLeftRight"> <%=astrConvertMonth[Integer.parseInt((String)vRetResult.elementAt(i+9))]%> <%=(String)vRetResult.elementAt(i+10)%> </td>
    </tr>
    <%}%>
  </table>
  </form>
<script language="JavaScript">
window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>