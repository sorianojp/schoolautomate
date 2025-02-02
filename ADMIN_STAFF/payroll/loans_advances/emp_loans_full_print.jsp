<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRRetirementLoan, payroll.PRMiscDeduction" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Set Loan to Zero</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

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

</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script> 
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strEmpID = null;
			
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	strEmpID = WI.fillTextValue("emp_id");
	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");

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
								"Admin/staff-Payroll-LOANS-Set Loan to Zero","emp_loans_full.jsp");
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
	Vector vPersonalDetails = null;
 	Vector vRetResult = null;
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	PRMiscDeduction prd = new PRMiscDeduction(request);
	int iDefault  = 0;

	String strPageAction = WI.fillTextValue("page_action");
	String strCodeIndex = null;
	int iSearchResult = 0;
	int i = 0;
 		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}

		vRetResult = PRRetLoan.setLoanFullPaid(dbOP, 4);
%>
<body onLoad="javascript:window.print();">
<form name="form_" method="post">
  <% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td width="97%" height="29">&nbsp;Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
  </table>
   <%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="15" colspan="9" align="center" class="BorderBottom"><strong>UPDATED LOANS </strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25" align="center" class="BorderBottomLeft">&nbsp;</td>
      <td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">REF # </font></strong></td>
      <td width="12%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN CODE </font></strong></td>
			<td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">DATE AVAILED </font></strong></td>
      <td width="10%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">AMOUNT       LOAN </font></strong></td>
			<td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">ADJUSTMENT</font></strong></td>
			<td width="24%" align="center" class="BorderBottomLeft"><strong><font size="1">REASON</font></strong></td>
      <td width="23%" align="center" class="BorderBottomLeftRight"><strong><font size="1">ADJUSTED BY </font></strong></td>
    </tr>
    <%
	int iCount = 1;
	for(i = 0; i < vRetResult.size(); i+=35, iCount++){
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+22),"&nbsp;")%></td>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp;")%></td>
			<td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <%	
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3),true);
			%>							
      <td height="24" align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
     <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+14),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
 		%>      
	  <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
		<%	
		strTemp = (String)vRetResult.elementAt(i+15);
	  %>	
    <td class="BorderBottomLeft">&nbsp;<%=strTemp%></td>
		<%	
		strTemp = (String)vRetResult.elementAt(i+32);
	  %>			
    <td class="BorderBottomLeftRight">&nbsp;<%=strTemp%></td>
    </tr>
    <%
		}// end for loop %>
  </table>	
  <%}
	}// largest if... (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>