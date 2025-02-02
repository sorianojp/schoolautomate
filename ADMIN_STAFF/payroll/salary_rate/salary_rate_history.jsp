<%@ page language="java" import="utility.*,payroll.PRSalaryRate,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Rate History</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function CloseWindow(){
	window.opener.document.form_.show_history.checked = false;
	self.close();
	opener.focus();
}
</script>


<body bgcolor="#D2AE72" onUnload="CloseWindow()" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-SALARY RATE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
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
								"Admin/staff-Payroll-SALARY RATE-SALARY RATE","salary_rate_history.jsp");
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

	PRSalaryRate prSalRate = new PRSalaryRate();
	Vector vRetResult = null; 

	vRetResult = prSalRate.getSalaryRateHistory(dbOP, request);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = prSalRate.getErrMsg();
%>
<form name="form_" action="./salary_rate_history.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: SALARY RATE PAGE HISTORY::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="85%" height="23">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td colspan="8" class="thinborder"><div align="right"></div></td>
    </tr>
    <tr> 
      <td colspan="8" class="thinborder"><div align="center"></div></td>
    </tr>
    <tr bgcolor="#666666"> 
      <td height="30" colspan="8"><div align="center"><font color="#FFFFFF"><strong>::: 
          SALARY RECORD DETAIL ::: </strong></font></div></td>
    </tr>
    <tr align="center"> 
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">INCLUSIVE 
          DATES</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>BASIC 
          SALARY</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">DAILY 
          RATE</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">HOURLY 
          RATE</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">TEACH 
          RATE</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">TEACH 
          OVER LOAD RATE</font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">SAL 
          PERIOD</font></strong></div></td>
      <td width="7%" class="thinborder"><strong><font size="1">BANK ACCOUNT</font></strong> </td>
    </tr>
    <%  
  String[] astrConvertUnit = {"Per hr","Per unit","Per session"};
  String[] astrConvertSalPeriod = {"Daily","Weekly","Bi-monthly","Monthly"};
  if (vRetResult != null && vRetResult.size() > 0){
  for (int i = 0; i < vRetResult.size(); i +=12){%>
    <tr> 
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i + 9)%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 10)," - <br>",""," - present")%></div></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","","&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"","","&nbsp;")%></td>
      <td align="center" class="thinborder"> <%if(vRetResult.elementAt(i + 5) != null && ((String)vRetResult.elementAt(i + 5)).compareTo("0.0") != 0){%> <%=(String)vRetResult.elementAt(i + 5)%> <%=astrConvertUnit[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%> <%}else{%> &nbsp; <%}%> </td>
      <td align="center" class="thinborder"> <%if(vRetResult.elementAt(i + 7) != null && ((String)vRetResult.elementAt(i + 7)).compareTo("0.0") != 0){%> <%=(String)vRetResult.elementAt(i + 7)%> <%=astrConvertUnit[Integer.parseInt((String)vRetResult.elementAt(i + 8))]%> <%}else{%> &nbsp; <%}%> </td>
      <td align="center" class="thinborder"><%=astrConvertSalPeriod[Integer.parseInt((String)vRetResult.elementAt(i + 2))]%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 11), "&nbsp;")%></td>
    </tr>
    <% } // end for loop 
	}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<% 
dbOP.cleanUP(); 
%>