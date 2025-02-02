<%@ page language="java" import="utility.*,java.util.Vector,payroll.OvertimeMgmt" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print OT Type</title>
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
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
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
								"Admin/staff-Payroll-configuration-OT Rate","overtime_type_create.jsp");
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
	
Vector vRetResult = null;
OvertimeMgmt OTMgmt = new OvertimeMgmt();
String[] astrRateType = {"%","Flat Rate","Specific Rate"};
String[] astrOption = {"Regular","Rest Day"};
String[] astrNightDiff = {"","Night Differential"};
String[] astrAdjType = {"Deduct from salary","Add to salary"};
String[] astrTaxable = {"Non Taxable","Taxable"};
String[] astrAddToBasic = {"Not added to basic","Added to basic"};

String strCheck = null;
String strOTType = WI.getStrValue(WI.fillTextValue("ot_type"),"0");
String strLabel = "ADJUSTMENT TYPE";

if(strOTType.equals("0"))
	strLabel = "ADJUSTMENT TYPE";
else
	strLabel = "OVERTIME TYPE";

vRetResult  = OTMgmt.operateOnOvertimeType(dbOP,request,4);
%>
<form name="form_">
  <%if (vRetResult!=null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" align="center" class="thinborder"><strong>:: 
      LIST OF EXISTING <strong><%=strLabel%></strong> IN RECORD ::</strong></td>
    </tr>
    <tr> 
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>CODE</strong></font></td>
      <td width="40%" height="25" align="center" class="thinborder"><strong>NAME</strong></td>
      <td width="24%" align="center" class="thinborder"><strong>RATE</strong></td>
      <td width="22%" align="center" class="thinborder"><strong>OPTION</strong></td>
    </tr>
    <%
		//System.out.println("vRetResult " +vRetResult);
	for(int i = 0; i < vRetResult.size();i +=19){%>
    <tr> 
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
				strTemp += "&nbsp;" +(String)vRetResult.elementAt(i+5);
				
				if(strOTType.equals("1") && vRetResult.elementAt(i+12) != null){
					strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+13),"0");
					strTemp2 = astrRateType[Integer.parseInt(strTemp2)];
					strTemp += WI.getStrValue((String)vRetResult.elementAt(i+12), "<br>Excess : <br>&nbsp;", "&nbsp;" +strTemp2,"");
				}
			%>
      <td valign="top" class="thinborder"><%=strTemp%></td>
			<%
				if(strOTType.equals("1")){
					strTemp = astrOption[Integer.parseInt((String)vRetResult.elementAt(i+6))] + "<br>";
					strTemp += astrNightDiff[Integer.parseInt((String)vRetResult.elementAt(i+7))];
				}else{
					strTemp = astrAdjType[Integer.parseInt((String)vRetResult.elementAt(i+9))];
					strTemp += "<br>" + astrTaxable[Integer.parseInt((String)vRetResult.elementAt(i+10))];
					strTemp += "<br>" + astrAddToBasic[Integer.parseInt((String)vRetResult.elementAt(i+11))];					
				}			
			%>
      <td valign="top" class="thinborder"><%=strTemp%></td>
    </tr>
		<%}%>		
  </table>
<%} // if vRetResult != null%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>