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
								"Admin/staff-Accounting-Reports - journal_voucher","jv_summary_print.jsp");
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
Vector vRetResult = RFS.getJVSummary(dbOP, request);
if(vRetResult == null)
	strErrMsg = RFS.getErrMsg();

String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};

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
	<%if(WI.fillTextValue("print_").equals("1")){%>
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
<%}
int iRowPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iCurPg    = 0; int iLineNumber = 0;
if(vRetResult != null && vRetResult.size() > 0) {
int iVectorSize = Integer.parseInt((String)vRetResult.remove(0));
double dTotalDebit  = ((Double)vRetResult.remove(0)).doubleValue();
double dTotalCredit = ((Double)vRetResult.remove(0)).doubleValue();
dTotalDebit = 0d; dTotalCredit = 0d;

int iPageOf = 1; 
int iTotalPages = iVectorSize/iRowPerPg;
if(iVectorSize % iRowPerPg > 0)
	++iTotalPages;

for(int i = 0; i < vRetResult.size(); ++iPageOf){
iCurPg = 0;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" height="25" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        Summary of Journal Voucher Entries <br>
        For the Month of 
		<u><%=astrConvertMonth[Integer.parseInt(WI.fillTextValue("jv_month"))]%> <%=WI.fillTextValue("jv_year")%></u>		
	 </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="22" align="right" style="font-size:10px">Page <%=iPageOf%> of <%=iTotalPages%>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
		  <td width="3%" align="center" class="thinborder"><strong>Line #</strong></td>
		  <td width="15%" align="center" class="thinborder"><strong>Account Number</strong></td>
		  <td width="52%" height="26" align="center" class="thinborder"><strong>Account Title</strong></td>
		  <td width="15%" class="thinborder" align="center"><strong>DEBIT</strong></td>
		  <td width="15%" class="thinborder" align="center"><strong>CREDIT</strong></td>
		</tr>
<%boolean bolPrintDebit = false;
double dDebit = 0d;
double dCredit = 0d;
for(; i < vRetResult.size();){
dDebit = 0d;dCredit = 0d;
if(vRetResult.elementAt(i + 1).equals("1"))
	dDebit = Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 2), ",",""));
else	
	dCredit = Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 2), ",",""));

if(dDebit > 0d && (i + 4) < vRetResult.size()) {
	if(vRetResult.elementAt(i).equals(vRetResult.elementAt(i + 4)) && vRetResult.elementAt(i + 1 + 4).equals("0")) {
		dCredit = Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 2 + 4), ",",""));
		i += 4;
	}
}	
dDebit = dDebit - dCredit;
if(dDebit < 0d) {
	dCredit = -1 * dDebit;
	dDebit = 0d;
}else
	dCredit = 0d;

dTotalDebit += dDebit;
dTotalCredit += dCredit;
	%>
<!--
		<tr>
		  <td class="thinborder"><%//=++iLineNumber%></td>
		  <td class="thinborder"><%//=vRetResult.elementAt(i + 3)%></td>
		  <td height="26" class="thinborder"><%//=vRetResult.elementAt(i)%></td>
		  <td class="thinborder" align="right">
		  	<%//if(vRetResult.elementAt(i + 1).equals("1")){%>
				<%//=vRetResult.elementAt(i + 2)%><%//bolPrintDebit=true;
			//}else{bolPrintDebit=false;%>&nbsp;<%//}%>		  </td>
		  <td class="thinborder" align="right">
		  <%//if(bolPrintDebit) {//i have to check if next row belongs to same account
		  	//i = i + 4; 
			//if(i < vRetResult.size()) {
				//if(vRetResult.elementAt(i).equals(vRetResult.elementAt(i - 4)) && vRetResult.elementAt(i + 1).equals("0"))
				//{}else
					//i = i - 4;//go back to prev.
			//}
			//else 
				//i = i - 4;
			//}%>
		  	<%//if(vRetResult.elementAt(i + 1).equals("0")){%><%//=vRetResult.elementAt(i + 2)%><%//}else{%>&nbsp;<%//}%>		  </td>
		</tr>
-->
		<tr>
		  <td class="thinborder"><%=++iLineNumber%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
		  <td height="26" class="thinborder"><%=vRetResult.elementAt(i)%></td>
		  <td class="thinborder" align="right">
		  	<%if(dDebit > 0d){%>
				<%=CommonUtil.formatFloat(dDebit, true)%>
			<%}else{%>&nbsp;<%}%>
			 </td>
		  <td class="thinborder" align="right">
		  	<%if(dCredit > 0d){%>
				<%=CommonUtil.formatFloat(dCredit, true)%>
			<%}else{%>&nbsp;<%}%>
		  </td>
		</tr>

<% i += 4;
if(i >= vRetResult.size()){%>
		<tr>
		  <td class="thinborder" align="right">&nbsp;</td>
		  <td class="thinborder" align="right">&nbsp;</td>
		  <td height="26" class="thinborder" align="right"><strong>TOTAL :&nbsp;&nbsp;&nbsp; </strong></td>
		  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalDebit,true)%></td>
		  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalCredit,true)%></td>
		</tr>
<%}
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