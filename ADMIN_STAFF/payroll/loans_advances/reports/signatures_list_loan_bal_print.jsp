<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Schedule for loans Balances</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderNone{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>

<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<body onLoad="javascript:window.print();">
<form method="post">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT-REPORTS"),"0"));
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
								"Admin/staff-RETIREMENT-ENCODE_LOANS-Create Loans","signatures_list_loan_bal.jsp");
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
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	Vector vRetResult = null;
	String strLoanType = null;
	String[] astrLoanType = {"Regular Retirement Loan","Emergency Loan"};
	int iSearchResult = 0;
	int i = 0;
	int iCount = 0;
	boolean bolPageBreak = false;

	vRetResult = PRRetLoan.getSignatureList(dbOP,request);
//	int i = 0; int k = 0; int iNumGrading = 0; int iCount = 0;
	int iMaxRecPerPage =Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	
	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iPage = 1;
	for (;iNumRec < vRetResult.size();iPage++){
%>
  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td colspan="5" class="thinborderBOTTOM"><font color="#000000">&nbsp;<%=astrLoanType[Integer.parseInt(WI.getStrValue(strLoanType,"0"))]%>, Released on <%=WI.fillTextValue("release_date")%></font></td>
  </tr>
  <tr> 
    <td height="25" colspan="5" class="BorderNone"><div align="right">Page <%=iPage%> </div></td>
  </tr>
  <tr> 
    <td width="7%" height="19" class="BorderBottom">&nbsp;</td>
    <td colspan="2" class="BorderBottom"><div align="center"><strong><font size="1">NAME 
        OF EMPLOYEE</font></strong> </div>
      <div align="center"><font size="1"></font></div></td>
    <td width="12%" class="BorderBottom"><div align="center"><strong><font size="1">AMOUNT</font></strong></div></td>
    <td width="36%" class="BorderBottom"><div align="center"><font size="1"><strong><font size="1">SIGNATURE 
        / DATE</font></strong></font></div></td>
  </tr>
  <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=5,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
  <tr> 
    <td class="BorderNone"><div align="right"><font size="1"><%=iIncr%></font>.&nbsp;&nbsp;</div></td>
    <td height="28" colspan="2" class="BorderNone"><div align="left"><font size="1"><strong>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></div></td>
    <td class="BorderNone"><div align="right">&nbsp; <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true)%>&nbsp;</div></td>
    <td class="BorderBottom"><div align="right">&nbsp;</div></td>
  </tr>
  <%} // end for loop%>
  <%if ( iNumRec >= vRetResult.size()) {%>
  <tr> 
    <td colspan="5"  class="thinborder"><div align="center"><font size="1">***************** 
        NOTHING FOLLOWS *******************</font></div></td>
  </tr>
  <%}else{// end iNumStud >= vRetResult.size()%>
  <tr> 
    <td colspan="5"  class="thinborder"><div align="center"><font size="1">************** 
        CONTINUED ON NEXT PAGE ****************</font></div></td>
  </tr>
  <%}//end else%>
</table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
%>

  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>