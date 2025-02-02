<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Cola</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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
	font-size: 11px;
    }

-->
</style>
</head>

<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Print","cola_ecola.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"cola_ecola_print.jsp");
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
Vector vEditInfo = null;

PayrollConfig pr = new PayrollConfig();

vRetResult = pr.operateOnColaEcola(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}
%>
<body onLoad="javascript:window.print();">
<%=WI.getStrValue(strErrMsg)%> 
<% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%> </font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" align="center" class="thinborder"><strong><font size="2">LIST 
          OF COLA/ECOLA IMPLEMENTED</font></strong></td>
    </tr>
    <tr> 
      <td width="34%" height="26" rowspan="2" align="center" class="thinborder"><font size="1"><strong>EFFECTIVITY 
      DATE</strong></font></td>
      <td colspan="2" align="center" class="thinborder"><font size="1"><strong>COLA/ECOLA AMOUNT</strong></font></td>
      <td width="20%" rowspan="2" align="center" class="thinborder"><strong><font size="1">DEDUCT 
           WHEN ABSENT</font></strong></td>
    </tr>
    <tr> 
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>Per Month</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>Per Day</strong></font></td>
    </tr>
  <% String[] astrDeductAbsent={"../../../images/x.gif","../../../images/tick.gif"};
	for (int i = 0; i< vRetResult.size() ; i+=20) {%>
    <tr> 
      <td height="30" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%><%=WI.getStrValue((String)vRetResult.elementAt(i+2)," - ",""," - PRESENT")%></font></td>
      <td align="right" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%>&nbsp;</font></td>
      <td align="right" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%>&nbsp;</font></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");
				if(!strTemp.equals("0"))
						strTemp = "1";
			%>			
      <td class="thinborder"><div align="center">&nbsp;<img src="<%=astrDeductAbsent[Integer.parseInt(strTemp)]%>" ></div></td>
    </tr>
    <%}// end for loop%>
</table>
<%}//end vRetResult != null%>
</body>
</html>
<%
	dbOP.cleanUP();
%>
