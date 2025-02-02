<%@ page language="java" import="utility.*,Accounting.AccountPayable,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Reports - AP Journal","apj_print.jsp");
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

AccountPayable AP = new AccountPayable();
Vector vRetResult = AP.APJournalReport(dbOP, request);
if(vRetResult == null)
	strErrMsg = AP.getErrMsg();

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function PrintPg() {
	<%if(WI.fillTextValue("print_pg").equals("1")){%>
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
int iCurPg    = 0;

int iIndexOf  = 0; 

if(vRetResult != null && vRetResult.size() > 0) {
int iPageOf = 1;
int iTotalPages = vRetResult.size()/(13 * iRowPerPg);
if(vRetResult.size() % (13 * iRowPerPg) > 0)
	++iTotalPages;
	
//System.out.println(vRetResult);	
double dAmt    = 0d;
double dTotAmt = 0d;
int iCount = 0;

Vector vDebitList = null;

for(int i = 0; i < vRetResult.size(); ++iPageOf){
iCurPg = 0;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" height="25" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        AP Journal <br>
        
		<u><%=WI.getStrValue(request.getAttribute("report_format"))%></u>		
	 </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="22" align="right" style="font-size:10px">Page <%=iPageOf%> of <%=iTotalPages%>&nbsp;</td>
    </tr>
  </table>
  
  <table border="0" cellpadding="0" cellspacing="0" class="thinborder" width="100%">
    <tr align="center" style="font-weight:bold">
      <td class="thinborder" width="3%">Count</td>
      <td class="thinborder" width="8%">Trans Date </td>
      <td class="thinborder" width="8%">Supplier TIN </td>
      <td class="thinborder" width="12%">Supplier Name </td>
      <td class="thinborder" width="8%">Reference Number </td>
      <td class="thinborder" width="12%">Description</td>
      <td class="thinborder" width="8%">Invoice Amount </td>
      <td class="thinborder" width="12%">Credit Account</td>
      <td class="thinborder" width="8%">Amout</td>
      <td height="25" class="thinborder" width="15%">Debit Account</td>
      <td class="thinborder" width="6%">Amount</td>
    </tr>
<%for(; i < vRetResult.size();){
dAmt    = ((Double)vRetResult.elementAt(i + 2)).doubleValue();
dTotAmt += dAmt;
vDebitList = (Vector)vRetResult.elementAt(i + 8);

%>
	<tr valign="top">
	  <td class="thinborder"><%=++iCount%></td>
	  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 12), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 7), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), "&nbsp;")%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dAmt, true)%></td>
      <td class="thinborder">
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 10), "&nbsp;")%>
	  <br>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 11), "&nbsp;")%>	  </td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dAmt, true)%></td>
      <td height="25" colspan="2" class="thinborder">	
	  <%if(vDebitList == null || vDebitList.size() == 0) {%>&nbsp;<%}else{%>  
		  <table width="100%" cellpadding="0" cellspacing="0">
			<%while(vDebitList.size() > 0) {%>
				<tr>
					<td width="72%" <%if(vDebitList.size() == 3){%>class="thinborderNONE"<%}else{%>class="thinborderBOTTOM"<%}%>><%=vDebitList.remove(0)%><br><%=vDebitList.remove(0)%></td>
					<td width="28%" align="right" <%if(vDebitList.size() == 1){%>class="thinborderNONE"<%}else{%>class="thinborderBOTTOM"<%}%>><%=vDebitList.remove(0)%></td>
				</tr>
		  	<%}%>
		  </table>
	  <%}%>
	  
	  </td>
    </tr>
<%
i += 13;
if(i == vRetResult.size()){%>
    <tr>
      <td align="right" class="thinborder" colspan="9" height="25"><strong>TOTAL: <%=CommonUtil.formatFloat(dTotAmt, true)%></strong></td>
      <td align="right" class="thinborder" colspan="2"><strong><%=CommonUtil.formatFloat(dTotAmt, true)%></strong></td>
      <!--<td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotAmt, true)%></td>-->
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