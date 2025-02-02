<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body <%if(WI.fillTextValue("print_stat").equals("1")){%> onLoad="window.print();"<%}%>>
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
Vector vRetResult = rg.getGLInfoSummary(dbOP, request);
if(vRetResult == null)
	strErrMsg = rg.getErrMsg();

%>

<%if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2" style="font-size:13px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
    </tr>
  </table>
<%
dbOP.cleanUP();return;}

double dDebit  = 0d; 
double dCredit = 0d;
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="72%" height="28" valign="bottom">Date and time printed : <%=WI.getTodaysDateTime()%></td>
      <td width="28%" height="28" valign="bottom" align="right">&nbsp;</font></td>
    </tr>
    
    <tr> 
      <td height="30" colspan="2" valign="bottom"><strong><%=WI.fillTextValue("coa_index")%>: &nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td class="thinborder" width="13%"><div align="center"><font size="1"><strong>TYPE</strong></font></div></td>
      <td class="thinborder" width="17%"><div align="center"><strong><font size="1">DEBIT</font></strong></div></td>
      <td height="30" class="thinborder" width="17%"><div align="center"><strong><font size="1">CREDIT</font></strong></div></td>
      <td class="thinborder" width="17%"><div align="center"><strong><font size="1">BALANCE</font></strong></div></td>
    </tr>
<%//System.out.println(vRetResult);
for(int i = 3; i < vRetResult.size(); i += 3){
	
	dDebit  = 0d; 
	dCredit = 0d;
	
	dDebit  = Double.parseDouble((String)vRetResult.elementAt(i + 1));
	dCredit = Double.parseDouble((String)vRetResult.elementAt(i + 2));

	dBalance = dDebit - dCredit;	
	%>
    <tr> 
      <td height="21" class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder" align="right"><%if(dDebit > 0d){%><%=CommonUtil.formatFloat(dDebit,true)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" align="right"><%if(dCredit > 0d){%><%=CommonUtil.formatFloat(dCredit,true)%><%}else{%>&nbsp;<%}%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
<%}//end of for loop - Inner printing. %>
    <tr> 
      <td class="thinborder"><div align="right">TOTALS : &nbsp;&nbsp;</div></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(0)%></td>
      <td height="24" class="thinborder" align="right"><%=vRetResult.elementAt(1)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(2)%></td>
    </tr>
  </table>

</body>
</html>
<%
dbOP.cleanUP();
%>