<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-COLA","variable_allowance.jsp");
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

//end of authenticaion code.
Vector vRetResult = null;
Vector vEditInfo = null;

PayrollConfig pr = new PayrollConfig();

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strTemp2 = null;
String strEmpCatg = null;
String strSchCode = dbOP.getSchoolIndex();
String[] astrTaxable={"../../../../images/x.gif","../../../../images/tick.gif"};
String[] astrBasis={"Fixed Allowance","Present","Absences", "Hours Present"};
String strCheck = null;
String strNote = null;
String[] astrActualName  ={"Every Salary Period","Monthly (Every Last Period of the Month)", 
											"Quarterly (Every Last Period of the Quarter)",
											"Bi-annual (June &amp; December)","Monthly (Every First Period)"};
vRetResult = pr.operateOnColaEcola(dbOP,request,4);
%>

<body onLoad="javascript:window.print();">
<form name="form_">
  <% if (vRetResult != null) { %> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <tr> 
      <td height="25" colspan="6" align="center" class="thinborder"><strong>LIST 
          OF ALLOWANCES IMPLEMENTED</strong></td>
    </tr>
    <tr> 
      <td width="27%" rowspan="2" align="center" class="thinborder"><strong><font size="1">ALLOWANCE 
        NAME</font></strong></td>
      <td height="18" colspan="3" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
      <td width="8%" rowspan="2" align="center" class="thinborder"><strong><font size="1">HOURS REQUIRED </font></strong></td>
      <td width="25%" rowspan="2" align="center" class="thinborder"><strong><font size="1">ALLOWANCE BASIS </font></strong></td>
    </tr>
    <tr> 
      <td width="8%" height="18" align="center" class="thinborder"><font size="1"><strong>Allowance</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>Per Day</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>Per hour </strong></font></td>
    </tr>
    <%
	for (int i = 0; i< vRetResult.size() ; i+=20) {%>
    <tr> 
	    <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6))%><%=WI.getStrValue((String)vRetResult.elementAt(i+7)," - ","","&nbsp;")%></font></td>
      <td height="25" align="right" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%>&nbsp;</font></td>
      <td align="right" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%>&nbsp;</font></td>
      <td align="right" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+10))%>&nbsp;</font></td>
      <td align="right" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"0")%>&nbsp;</font></td>
			<%strTemp2 = "";
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");	
				if(strTemp.equals("0")){
					strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+12),"0");
					strTemp2 = astrActualName[Integer.parseInt(strTemp2)];									
				}
				strTemp2 = WI.getStrValue(strTemp2,"<br>- ","","");
				if(((String)vRetResult.elementAt(i+9)).equals("1"))
					strTemp2 += "<br>- Taxable";
				else					
					strTemp2 += "<br>- Non Taxable";
				
				if(((String)vRetResult.elementAt(i+13)).equals("1"))
					strTemp2 += "<br>- Added to Basic";
			%>
      <td class="thinborder"><font size="1">&nbsp;<%=astrBasis[Integer.parseInt(strTemp)]%><%=strTemp2%></font></td>      
    </tr>
    <%}// end for loop%>
  </table>
<%}//end vRetResult != null%>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
