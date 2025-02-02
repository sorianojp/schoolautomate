<%@ page language="java" import="utility.*,Accounting.Report.ReportFS,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Reports - journal_voucher","jv_details_print.jsp");
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
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.

ReportFS RFS = new ReportFS();
//Vector vRetResult = RFS.getGeneralJournalSummary(dbOP, request);
Vector vRetResult = RFS.getGeneralJournalNew(dbOP, request);

if(vRetResult == null)
	strErrMsg = RFS.getErrMsg();

String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};

//System.out.println(vRetResult);
//System.out.println(vJVDetail);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
</head>
<script language="javascript">
function PrintPg() {
	<%if(WI.fillTextValue("show_detail").equals("0")){%>
		window.print();
	<%}%>
}
</script>
<body onLoad="PrintPg()">
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; font-weight:bold; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%dbOP.cleanUP();return;}
int iRowPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iCurPg    = 0; int iLineNumber = 0;

if(vRetResult != null && vRetResult.size() > 0) {
String strTotalDebit  = (String)vRetResult.remove(0);
String strTotalCredit = (String)vRetResult.remove(0);
int iPageOf = 1;
int iTotalPages = vRetResult.size()/(3 * iRowPerPg);
if(vRetResult.size() % (3 * iRowPerPg) > 0)
	++iTotalPages;
	
//System.out.println(vRetResult);	
for(int i = 0; i < vRetResult.size(); ++iPageOf){
iCurPg = 0;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" height="25" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        General Journal for the month of 
		<u><%=astrConvertMonth[Integer.parseInt(WI.fillTextValue("jv_month"))]%> <%=WI.fillTextValue("jv_year")%></u>		
	 </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="22" align="right" style="font-size:10px">Page <%=iPageOf%> of <%=iTotalPages%>&nbsp;</td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td height="26" align="center" class="thinborder"><strong>Line #</strong></td>
      <td height="26" align="center" class="thinborder"><strong>Account Title</strong></td>
      <td class="thinborder" align="center"><strong>Debit</strong></td>
      <td class="thinborder" align="center"><strong>Credit</strong></td>
    </tr>
<%for(; i < vRetResult.size();){%>
	<tr>
      <td width="3%"  height="22" class="thinborder"><%=++iLineNumber%></td>
      <td width="67%" class="thinborder"><%=vRetResult.remove(0)%></td>
      <td width="15%" class="thinborder" align="right"><%=vRetResult.remove(0)%></td>
      <td width="15%" class="thinborder" align="right"><%=vRetResult.remove(0)%></td>
    </tr>
<%if(i == vRetResult.size()){%>
    <tr>
      <td height="22" class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right" style="font-weight:bold; font-size:10px;">TOTAL&nbsp;&nbsp;</td>
      <td class="thinborder" align="right" style="font-weight:bold; font-size:10px;"><%=strTotalDebit%></td>
      <td class="thinborder" align="right" style="font-weight:bold; font-size:10px;"><%=strTotalCredit%></td>
    </tr>

<%}//print at end.. 
if(++iCurPg == iRowPerPg)
	break;
}%>
  </table>
<%if(i < vRetResult.size()){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>

<%}//end of vRetResult.. 
}//end of big loop - if condition.%>

</body>
</html>
<%
dbOP.cleanUP();
%>