<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,Accounting.Report.ReportGeneric, java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.

ReportGeneric rg  = new ReportGeneric();
Vector vRetResult = rg.getGLInfo(dbOP, request);
if(vRetResult == null)
	strErrMsg = rg.getErrMsg();

%>

<body <%if(WI.fillTextValue("print_stat").equals("1")){%> onLoad="window.print();"<%}%>>
<%if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2" style="font-size:13px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
    </tr>
  </table>
<%dbOP.cleanUP();return;}

int iRowPerPg  = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iTotalRow  = vRetResult.size()/5;
int iTotalPage = iTotalRow / iRowPerPg;
if(iTotalRow % iRowPerPg > 0) 
	++iTotalPage;
	
int iCurPage   = 0;
int iCurRow    = 1; boolean bolEndOfPrinting = false;
int iRowCount  = 1;

double dDebit  = 0d; 
double dCredit = 0d;

double dTotalDebit  = 0d;
double dTotalCredit = 0d;

double dBalance     = 0d;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2">
	  	<div align="center"><font size="2">
      	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br></div>
	  </td>
    </tr>
  </table>
<%for(int i =0; i < vRetResult.size(); i += 5) {
++iCurPage;	
iCurRow = 0; %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="72%" height="28" valign="bottom">Date and time printed : <%=WI.getTodaysDateTime()%></td>
      <td width="28%" height="28" valign="bottom" align="right">Page <%=iCurPage%> of <%=iTotalPage%></font></td>
    </tr>
    
    <tr> 
      <td height="30" colspan="2" valign="bottom"><strong><%=WI.fillTextValue("coa_index")%>: &nbsp;&nbsp;&nbsp;<%=rg.getErrMsg()%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td class="thinborder" width="7%"><div align="center"><font size="1"><strong>COUNT</strong></font></div></td>
      <td class="thinborder" width="13%"><div align="center"><font size="1"><strong>REFERENCE #</strong></font></div></td>
      <td class="thinborder" width="9%"><div align="center"><font size="1"><strong>DATE</strong></font></div></td>
      <td class="thinborder" width="17%"><div align="center"><strong><font size="1">DEBIT</font></strong></div></td>
      <td height="30" class="thinborder" width="17%"><div align="center"><strong><font size="1">CREDIT</font></strong></div></td>
      <td class="thinborder" width="17%"><div align="center"><strong><font size="1">BALANCE</font></strong></div></td>
      <td class="thinborder" width="20%"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
    </tr>
<%bolEndOfPrinting = true;
for(; i < vRetResult.size(); i += 5){
	++iCurRow; 
	if(iCurRow > iRowPerPg) {//break out of here and print in other page.. 
		bolEndOfPrinting = false;
		i = i - 5;
		break;
	}
	
	dDebit  = 0d; 
	dCredit = 0d;
	
	if(vRetResult.elementAt(i + 2).equals("0"))
		dDebit  = Double.parseDouble((String)vRetResult.elementAt(i + 3));
	else	
		dCredit = Double.parseDouble((String)vRetResult.elementAt(i + 3));

	dTotalDebit  += dDebit;
	dTotalCredit += dCredit;

	dBalance = dBalance - dCredit;
	dBalance = dBalance + dDebit;
	
	%>
    <tr> 
      <td height="21" class="thinborder"><%=iRowCount++%>.</td>
      <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" align="right"><%if(dDebit > 0d){%><%=CommonUtil.formatFloat(dDebit,true)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" align="right"><%if(dCredit > 0d){%><%=CommonUtil.formatFloat(dCredit,true)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
    </tr>
<%}//end of for loop - Inner printing. 
if(bolEndOfPrinting) {%>
    <tr> 
      <td colspan="3" class="thinborder"><div align="right">TOTALS : &nbsp;&nbsp;</div></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalDebit,true)%></td>
      <td height="24" class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalCredit,true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td height="24" class="thinborder">&nbsp;</td>
    </tr>
<%}%>
  </table>
<%if(!bolEndOfPrinting) {%><DIV style="page-break-after:always">&nbsp;</DIV><%}%>

<%}//end of page print.. outer for loop.. 
%>
</body>
</html>
<%
dbOP.cleanUP();
%>