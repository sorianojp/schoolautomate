<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>DAILY CASH COLLECTION DETAILED REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
</head>
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String[] astrConvertGender = {"Male","Female"};
	String strTemp = null;

	Vector vTuitionFee       = null;
	Vector vSchFacDeposit   = null;
	Vector vRemittance      = null;
	int i = 0;

	double dSubTotalCash  = 0d;
	double dSubTotalCheck = 0d;
	double dSubTotalCA    = 0d;//cash advance
	double dSubTotalCC    = 0d;//credit card.. 

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","daily_cash_col.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"daily_cash_col.jsp");
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
Vector vEmployeeInfo = null;
Authentication auth = new Authentication();
DailyCashCollection DC = new DailyCashCollection();
Vector[] vCollectionInfo = null;

vEmployeeInfo = auth.operateOnBasicInfo(dbOP, request,"0");
if(vEmployeeInfo == null)
	strErrMsg = auth.getErrMsg();
else if(WI.fillTextValue("date_of_col").length() > 0 && WI.fillTextValue("teller_index").length() > 0)
{
	vCollectionInfo  = DC.viewDailyCashCollectionDtlsPerTeller(dbOP,request.getParameter("date_of_col"),request.getParameter("teller_index"),request);
	if(vCollectionInfo == null)
		strErrMsg = DC.getErrMsg();
}

if(vCollectionInfo != null)
{
	vTuitionFee      = vCollectionInfo[0];
	vSchFacDeposit   = vCollectionInfo[1];
	vRemittance      = vCollectionInfo[2];
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<body >
<%
if(strErrMsg != null){%>
<table width="100%" cellpadding="0" cellspacing="0">
 <tr>
	<td><font size="3">Error in processing : <%=strErrMsg%></font>
	</td>
 </tr>
</table>
<%return;
}%>


<%

boolean bolIsCancelled = false;//only for cldh.. 
boolean bolIsCLDH      = strSchCode.startsWith("CLDH");
String strStrikeThru   = null;//strike thru' if OR is cancelled.

if(vCollectionInfo != null && vCollectionInfo.length > 0){%>




<table bgcolor="#FFFFFF" width="30%" cellspacing="0" cellpadding="0">
<%
if(vTuitionFee != null && vTuitionFee.size() > 0)
{
	for(i = 0; i< vTuitionFee.size(); ++i)
	{
		if( ((String)vTuitionFee.elementAt(i)).compareTo("0") !=0)//not cash, break here.
		{
			i=i+9;
			continue;
		}
		dSubTotalCash += Double.parseDouble((String)vTuitionFee.elementAt(i+3));
%>

	<tr>
		<td width="33%"><%=WI.fillTextValue("date_of_col")%>	  </td><td width="37%"><%=(String)vTuitionFee.elementAt(i+1)%></td>
		<td width="30%" align="right"><%=CommonUtil.formatFloat((String)vTuitionFee.elementAt(i+3),true)%></td>
	</tr>
	<%i = i+9;	}

}%>
	<tr><td colspan="3" align="right"><%=CommonUtil.formatFloat(dSubTotalCash,true)%></td></tr>
	<tr><td height="5" colspan="3"><div style="border-bottom:solid 1px #000000; width:100%;"></div></td></tr>
	<tr><td colspan="2">TUITION RECEIVALBLE</td><td align="right">&nbsp; </td></tr>
</table>
<script language="JavaScript">
window.print();
</script>
<%
	}//if collection information is not null.
%>
</body>
</html>
