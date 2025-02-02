<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*" %>
<%
WebInterface WI = new WebInterface(request);
DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & payment-REPORTS","specific_acct_print.jsp");
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
String strSYIndex = dbOP.mapOneToOther("FA_SCHYR","sy_from",WI.fillTextValue("sy_from"),"sy_index", " and sy_to = "+WI.fillTextValue("sy_to"));
String[] astrConvertToSem = {"SUMMER", "1ST SEM","2ND SEM","3RD SEM"};

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%></div></td>
    </tr>
    <tr >
      
    <td height="25" align="right"><br>Date and time printed: <%=WI.getTodaysDateTime()%><br><BR></td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td height="20" colspan="2" bgcolor="#cccccc" align="center" class="thinborder"><strong>LIST 
      OF FEE COLLECTION AS OF <%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]+", "+WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%> <%=WI.fillTextValue("date_from")%> 
      <%
		if(WI.fillTextValue("date_to").length() > 0)
		{%>
      to <%=WI.fillTextValue("date_to")%> 
      <%}%>
      </strong></td>
  </tr>
  <tr> 
    <td width="74%" height="20" class="thinborder"><div align="center"><strong>FEE 
        TYPE </strong></div></td>
    <td width="26%" align="center" class="thinborder"><strong><font size="1">AMOUNT</font></strong></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
<%
int iCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("list_count"),"0"));
for(int i=0; i<iCount; ++i){%>
  <tr> 
    <td height="20" class="thinborder"><%=WI.fillTextValue("fee_name"+i)%></td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(WI.fillTextValue("fee_amt"+i),true)%>&nbsp;&nbsp;&nbsp;</td>
  </tr>
<%}%>
  <tr> 
    <td height="20" align="right" width="74%" class="thinborder"><strong><font size="1">TOTAL</font></strong></td>
    <td align="right" width="26%" class="thinborder"><strong><%=CommonUtil.formatFloat(WI.fillTextValue("total_amt"),true)%>&nbsp;&nbsp;&nbsp;<strong></strong></strong></td>
  </tr>
</table>
<script language="JavaScript">
window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
