<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
	body {
		font-size: 11px;
		font-family: Verdana, Arial, Helvetica, sans-serif;
	}
	td {
		font-size: 11px;
		font-family: Verdana, Arial, Helvetica, sans-serif;
	}


</style>
</head>

<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","year_end_report.jsp");
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
														"Student Affairs",
														"ORGANIZATIONS",request.getRemoteAddr(),
														"year_end_report.jsp");
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
Vector vOrganizationDtl = null;
boolean bolNoRecord = false;//if it is true, it is having yearly report, activate EDIT.

String strOrgIndex = null;
Organization organization = new Organization();
Vector vRetResult = null;
String[] astrStatus = {"Regular","Probationary", "Failed",""};

if(WI.fillTextValue("organization_id").length() > 0 && WI.fillTextValue("sy_from").length() > 0){
	vOrganizationDtl = organization.operateOnOrganization(dbOP, request,3);
	if(vOrganizationDtl == null)
		strErrMsg = organization.getErrMsg();
	else
	{
		strOrgIndex = (String)vOrganizationDtl.elementAt(0);
		if(WI.fillTextValue("organization_index").length() ==0) 
			request.setAttribute("organization_index",strOrgIndex);
	}
}

vRetResult  = organization.operateOnOrgIncomeStatement(dbOP, request,4);



%>
<body onLoad="window.print()">
<% if (strErrMsg != null){ %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%}
if(vOrganizationDtl != null && vOrganizationDtl.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Organization ID : <strong><%=WI.fillTextValue("organization_id")%></strong>
  	  </td>
      <td height="25">Status : 
	  	<strong><%=astrStatus[Integer.parseInt(WI.getStrValue((String)vOrganizationDtl.elementAt(16),"3"))]%>	  	</strong></td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="59%" height="25">Organization name : <strong><%=(String)vOrganizationDtl.elementAt(2)%></strong></td>
      <td width="35%" height="25">Date accredited: <strong><%=(String)vOrganizationDtl.elementAt(3)%></strong></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">College/Department : <strong><%=WI.getStrValue(vOrganizationDtl.elementAt(5))%><%=WI.getStrValue((String)vOrganizationDtl.elementAt(7),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><div align="right"><font size="1"><font size="1"><a 	href="activities_view_all.htm"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>c<font size="1">lick
          to view other activities of the organization</font></font></font></div></td>
    </tr> -->
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%}//only if organization information is correct.
if(WI.fillTextValue("sy_from").length() > 0 && vOrganizationDtl != null 
		&& vOrganizationDtl.size() > 0){%>
<%}//WI.fillTextValue("sy_from").length() > 0

	if (vRetResult != null && vRetResult.size() > 0) { 
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr >
    <td height="25" colspan="7"><div align="center"><strong>ORGANIZATION INCOME STATEMENT </strong><br>
    For School Year <%=WI.fillTextValue("sy_from") + " - " + WI.fillTextValue("sy_to")%></div></td>
  </tr>
  <tr>
    <td height="25" colspan="7">&nbsp;</td>
  </tr>
<% 
	String strIncomeExpense = "";
	String strCurrentMain = "";
	String[] astrIncomeExpense = {"INCOME", "EXPENSE"};
	String strAmount = "";
	strTemp ="";
	String strTotalIncome = WI.getStrValue((String)vRetResult.elementAt(1),"0.00");
	String strTotalExpense  = "0.00";

	for (int i = 2; i < vRetResult.size() ; i+=5) {

	if (i==2 || !strIncomeExpense.equals((String)vRetResult.elementAt(i+1))) { 
		strIncomeExpense = (String)vRetResult.elementAt(i+1);
		
 	 if (i != 2) {
		strTotalExpense = WI.getStrValue((String)vRetResult.elementAt(0),"0.00");
%> 
  <tr>
    <td width="13%" height="2"></td>
    <td width="3%"></td>
    <td colspan="2"></td>
    <td width="15%"><hr size="1"></td>
    <td width="3%"></td>
    <td width="13%"></td>
  </tr>
  <tr>
    <td width="13%" height="18">&nbsp;</td>
    <td width="3%">&nbsp;</td>
    <td colspan="2"><div align="right">Total </div></td>
    <td width="15%"><div align="right"><%=strTotalIncome%></div></td>
    <td width="3%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
  </tr>
  <tr>
    <td width="13%" height="18">&nbsp;</td>
    <td width="3%">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
    <td width="15%">&nbsp;</td>
    <td width="3%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
  </tr>

 <%}%> 
  <tr>
    <td width="13%" height="18"><div align="right"><%=Integer.parseInt(strIncomeExpense) + 1%></div></td>
    <td width="3%">&nbsp;</td>
    <td colspan="2">&nbsp;<%=astrIncomeExpense[Integer.parseInt(strIncomeExpense)]%></td>
    <td width="15%">&nbsp;</td>
    <td width="3%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
  </tr>
<%}

	if ((String)vRetResult.elementAt(i+3) == null
		|| !strCurrentMain.equals((String)vRetResult.elementAt(i+2))){

		strTemp = (String)vRetResult.elementAt(i+2);
		strCurrentMain = strTemp;

	}else{
		strTemp = "";
	}	

	if ((String)vRetResult.elementAt(i+3) == null) 
		strAmount = (String)vRetResult.elementAt(i+4);
	else
		strAmount = "";

	if (strTemp.length() > 0) { 
%> 

  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td> 
    <td colspan="2">&nbsp;<%=strTemp%></td>
    <td><div align="right"><%=strAmount%></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%} if ((String)vRetResult.elementAt(i+3) != null) {%>  
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="38%">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    <td><div align="right"><%=(String)vRetResult.elementAt(i+4)%></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<%}
 }
  if (strTotalExpense != null) {
%> 
  <tr>
    <td width="13%" height="2"></td>
    <td width="3%"></td>
    <td colspan="2"></td>
    <td width="15%"><hr size="1"></td>
    <td width="3%"></td>
    <td width="13%"></td>
  </tr>
  <tr>
    <td width="13%" height="18">&nbsp;</td>
    <td width="3%">&nbsp;</td>
    <td colspan="2"><div align="right">Total </div></td>
    <td width="15%"><div align="right"><%=strTotalExpense%></div></td>
    <td width="3%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
  </tr>
 <%}
 %> 
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="19%">&nbsp;</td>
    <td height="18">&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="18"><div align="right">Total Income: &nbsp;</div></td>
    <td width="12%" height="18" align="right"><%=strTotalIncome%></td>
    <td height="18" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="18"><div align="right">Less &nbsp; </div></td>
    <td height="18" align="right">&nbsp;</td>
    <td width="31%" height="18">&nbsp;</td>
    <td width="12%">Prepared by : </td>
    <td width="26%">_______________________</td>
  </tr>
  <tr>
    <td height="18"><div align="right">Total Expense:&nbsp;</div></td>
    <td height="18"><div align="right"><%=strTotalExpense%></div></td>
    <td height="18" colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td height="2"></td>
    <td height="2"><hr size="1"></td>
    <td height="2" colspan="3"></td>
  </tr>
  <tr>
    <td height="18"><div align="right">Net Income / Loss:&nbsp; </div></td>
    <td height="18" align="right">&nbsp;
<% 
	if (strTotalIncome.length()  > 0 && strTotalExpense.length() > 0) {
%> 
	<%=CommonUtil.formatFloat(Double.parseDouble(ConversionTable.replaceString(strTotalIncome,",",""))			
		-  Double.parseDouble(ConversionTable.replaceString(strTotalExpense,",","")),true)%>	 
<%}%> 	
	</td>
    <td height="18"></td>
    <td height="18">Checked by : </td>
    <td height="18">_______________________</td>
  </tr>
</table>
<%
	}

%> 

</body>
</html>
<%
dbOP.cleanUP();
%>
