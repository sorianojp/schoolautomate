<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRLoanReport, payroll.PRMiscDeduction" %>
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
<script language="JavaScript">
 
function SearchEmployee(){
	document.form_.proceed.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}
  
//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strEmpID = null;
 
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
								"Admin/staff-Payroll-LOANS-Set Loan to Zero","forwarded_loans.jsp");
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
	Vector vLoanInfo = null;
	Vector vRetResult = null;
	PRLoanReport rptLoans = new PRLoanReport();
	int iDefault  = 0;
	
	String strPageAction = WI.fillTextValue("page_action");
 	int iSearchResult = 0;
	String strLoanType = null;
	String[] astrLoanType = {"Regular Retirement Loan","Emergency Loan","Institutional/Company Loan", "SSS Loan", "PAG-IBIG Loan", 
							"PERAA Loan","GSIS Loan"};
	String strTypeName = null;	
	String strCodeIndex  = null;

 	int i = 0;
	vRetResult = rptLoans.getForwardedLoans(dbOP, request);

%>
<body>
<form name="form_">
  <%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td height="15" colspan="10" class="BorderBottom">FORWARDED LOANS </td>
    </tr>
    <tr> 
      <td width="2%" height="25" align="center" class="BorderBottomLeft">&nbsp;</td>
      <td width="20%" align="center" class="BorderBottomLeft">&nbsp;</td>
      <td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">REF # </font></strong></td>
      <td width="11%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN CODE </font></strong></td>
			<td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">DATE AVAILED </font></strong></td>
      <td width="10%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">AMOUNT       LOAN </font></strong></td>
			<td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">ADJUSTMENT</font></strong></td>
			<td width="11%" align="center" class="BorderBottomLeft"><strong><font size="1">DATE FORWARDED </font></strong></td>
      <td width="20%" align="center" class="BorderBottomLeftRight"><strong><font size="1">FORWARDED  BY </font></strong></td>
    </tr>
    <%
	int iCount = 1;
	for(i = 0; i < vRetResult.size(); i+=35, iCount++){
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
      <td class="BorderBottomLeft"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4)%></strong></font></td>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+22),"&nbsp;")%></td>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp;")%></td>
			<td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <%	
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
			%>							
      <td height="24" align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
     <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+14),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
 		%>      
	  <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
		<%	
		strTemp = (String)vRetResult.elementAt(i+33);
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
  <%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>