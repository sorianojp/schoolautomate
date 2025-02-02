<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction" %>
<%

boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	String strErrMsg = null;
	String strTemp = null;
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-View/Print Posted","view_posted_balances.jsp");

	}catch(Exception exp)	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Misc Deductions with payable</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
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

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<%
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"view_posted_balances.jsp");
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
PRMiscDeduction prMiscDed = new PRMiscDeduction(request);
boolean bolShowDeducted = false;
double dTemp = 0d;
int iSearchResult = 0;
int i = 0;
boolean bolPageBreak = false;

	vRetResult = prMiscDed.getPostedDeductionsWithPayable(dbOP, request);
	if (vRetResult != null) {			
		int iCount = 0;
		int iTemp  = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(25*iMaxRecPerPage);				
		if(vRetResult.size()%(25*iMaxRecPerPage) > 0)
			iTotalPages++;		
		for (;iNumRec < vRetResult.size();iPageNo++){	
%>
<body onLoad="javascript:window.print();">
<form name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
  </tr>
  <tr>
    <td align="center"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="search2">
    <tr>  
      <td height="26" colspan="6" align="center"class="thinborder"><strong><font color="#00000" size="2">LIST 
        OF EMPLOYEES WITH PAYABLE</font></strong></td>
    </tr>
    <tr> 
      <td width="9%" align="center" class="thinborder"><strong><font size="1">EMP ID</font></strong></td>
      <td width="28%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <td width="15%" height="26" align="center"  class="thinborder"><font size="1"><strong>DATE POSTED</strong></font></td>
      <td width="12%" align="center"  class="thinborder"><font size="1"><strong>AMOUNT POSTED </strong></font></td>
      <td align="center"  class="thinborder"><font size="1"><strong>PAYABLE BALANCE </strong></font></td>
      <td align="center"  class="thinborder"><font size="1"><strong>DETAILS</strong></font></td>
    </tr>
		<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=25,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
		%>	
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%></td>
      <td  class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
      <td height="24" align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true)%>&nbsp;</td>
			<%
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true);
			strTemp = ConversionTable.replaceString(strTemp,",","");
			dTemp = Double.parseDouble(strTemp);
			if(dTemp == 0d)
				strTemp = "--";
			%>			
      <td width="13%" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+18);
				if(strTemp.equals("2"))
					strTemp = "Recurring deduction";
				else
					strTemp = "";
				
				if(strTemp.length() > 0)
					strTemp += "<br>";			
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+9),"REF #: ","","");
				if(strTemp.length() > 0)
					strTemp += "<br>";
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+11),"Note : ","","");
			%>
      <td width="23%" class="thinborder">&nbsp;<%=strTemp%></td>
    </tr>
    <%}%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>