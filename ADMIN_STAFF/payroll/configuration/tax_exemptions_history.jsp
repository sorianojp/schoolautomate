<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" buffer="16kb"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>TAX EXEMPTIONS HISTORY</title>
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
	String strErrMsg = null;
	String strTemp = null;
	
	WebInterface WI = new WebInterface(request);

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
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
								"Admin/staff-Payroll - configuration-Tax exemptions","tax_exemptions.jsp");
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	String strDependent = null;
	String strTaxStatus = null;			

	String[]  astrExemptionType={"Zero","Single","Head of Family","Married Employed","","","","","","","Dependent"};

	vRetResult  = prConfig.operateOnTaxExemption(dbOP, request, 4, true);
	if(vRetResult == null && strErrMsg == null){
		strErrMsg = prConfig.getErrMsg();
	}
%>
<form name="form_" action="./tax_exemptions.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: TAX EXEMPTIONS PAGE HISTORY::::</strong></font></td>
    </tr>
    <tr> 
      <td height="23">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292"><strong>TAX EXEMPTION 
          ENTRIES HISTORY</strong></td>
    </tr>
    <tr> 
      <td width="45%" height="26" align="center"><font size="1"><strong>EXEMPTION 
          TYPE </strong></font></td>
      <td width="22%" align="center"><font size="1"><strong>EXEMPTION AMOUNT</strong></font></td>
      <td width="33%" align="center"><font size="1"><strong>EFFECTIVE DATES</strong></font></td>      
    </tr>
    <%  
	for (int i = 0; i < vRetResult.size(); i +=6){%>
    <tr> 
      <td height="25"><%
					if(strTaxStatus.length() == 2){
						strDependent = strTaxStatus.substring(1,2);
						strTaxStatus = strTaxStatus.substring(0,1);						
					}
				%>
        <%=astrExemptionType[Integer.parseInt(strTaxStatus)]%><%=WI.getStrValue(strDependent," "," Dependent(s)","")%> </td>
      <td height="25" align="right"><strong>&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 1),true)%>&nbsp;</strong></td>
      <td height="25">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%><%=WI.getStrValue((String)vRetResult.elementAt(i + 4)," - ",""," - present")%></td>
    </tr>
    <% } // end for loop %>
  </table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>