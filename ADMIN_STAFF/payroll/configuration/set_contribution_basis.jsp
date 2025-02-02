<%@ page language="java" import="utility.*, java.util.Vector, payroll.PayrollConfig" %>
<%
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Contribution settings</title>
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
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
 function AddRecord()
{
	document.form_.addRecord.value = "1";
} 
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Contribution basis","set_contribution_basis.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","CONFIGURATION",request.getRemoteAddr(), 
														"set_contribution_basis.jsp");	
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

PayrollConfig pConfig = new PayrollConfig();
Vector vRetResult = null;
int i = 0;
String[] astrBasis = {"N/a", "Monthly Rate","Basic(Monthly Rate less absences)" ,"Gross"};
strTemp = WI.fillTextValue("addRecord");
if(strTemp.equals("1"))
{
	if(pConfig.operateOnContributionBasis(dbOP, request, 1) != null)
		strErrMsg = "Contribution basis updated.";
	else
		strErrMsg = pConfig.getErrMsg();
}
	vRetResult = pConfig.operateOnContributionBasis(dbOP, request, 3);

%>	
<form action="./set_contribution_basis.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      CONTRIBUTION - SETTINGS ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>SSS</strong></u></td>
      <td height="30"><u><strong>SSS Contribution basis </strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
			<% 
				strTemp = "";
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(1);
			%>
      <td width="48%" height="25"><%=astrBasis[Integer.parseInt(WI.getStrValue(strTemp,"0"))]%></td>
			
      <td width="50%" height="25"><font size="1">
        <select name="sss_basis">
				<% for(i = 0; i < astrBasis.length; i++) {
					if(strTemp.equals(Integer.toString(i))) {%>
					<option value="<%=i%>" selected><%=astrBasis[i]%></option>
				<%}else{%>
					<option value="<%=i%>"><%=astrBasis[i]%></option>
				<%}
				}// end for%>
        </select>
      </font></td>
    </tr>
    
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>Philhealth</strong></u></td>
      <td height="30"><u><strong>Philhealth Contribution basis </strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(3);
			%>
      <td width="48%" height="25"><%=astrBasis[Integer.parseInt(WI.getStrValue(strTemp,"0"))]%></td>
      <td width="50%" height="25"><font size="1">
        <select name="phic_basis">
          <% for(i = 0; i < astrBasis.length; i++) {
					if(strTemp.equals(Integer.toString(i))) {%>
          <option value="<%=i%>" selected><%=astrBasis[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrBasis[i]%></option>
          <%}
				}// end for%>
        </select>
      </font></td>
    </tr>
		<%if(bolIsSchool){%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>PERAA</strong></u></td>
      <td height="30"><u><strong>PERAA Contribution basis </strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
			<% 
				strTemp = "";
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(5);
			%>
      <td width="48%" height="25"><%=astrBasis[Integer.parseInt(WI.getStrValue(strTemp,"0"))]%></td>
      <td width="50%" height="25"><font size="1">
        <select name="peraa_basis">
          <% for(i = 0; i < astrBasis.length; i++) {
					if(strTemp.equals(Integer.toString(i))) {%>
          <option value="<%=i%>" selected><%=astrBasis[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrBasis[i]%></option>
          <%}
				}// end for%>
        </select>
      </font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>GSIS</strong></u></td>
      <td height="30"><u><strong>GSIS Contribution basis </strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
			<%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = (String)vRetResult.elementAt(7);
			%>
      <td width="48%" height="25"><%=astrBasis[Integer.parseInt(WI.getStrValue(strTemp,"0"))]%></td>
      <td width="50%" height="25"><font size="1">
        <select name="gsis_basis">
          <% for(i = 0; i < astrBasis.length; i++) {
					if(strTemp.equals(Integer.toString(i))) {%>
          <option value="<%=i%>" selected><%=astrBasis[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrBasis[i]%></option>
          <%}
				}// end for%>
        </select>
      </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="3"></td>
    </tr>
  </table>
	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" align="center">
			<%if(iAccessLevel > 1){%>
	    <input type="image" src="../../../images/save.gif" border="0" onClick="AddRecord();">
	    <font size="1">click to save changes</font>
	    <%}%>
			</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="addRecord">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>