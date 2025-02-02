<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Tax Per Salary type</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
  TD.thinborder {
  border-left: solid 1px #000000;
  border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
  table.thinborder {
  border-top: solid 1px #000000;
  border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
  TD.NoBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
 
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll - Tax Table Configuration","tax_per_type.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"tax_per_type.jsp");
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vEditInfo  = null;
	Vector vRetResult = null;
 	String[] astrSalaryType = {"D A I L Y ","W E E K L Y","SEMI-MONTHLY","MONTHLY"}; 
 
	vRetResult  = prConfig.operateOnTaxPerSalaryType(dbOP, request,4);		
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <%
 if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" height="24" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("salary_type"),"0");
				strTemp = astrSalaryType[Integer.parseInt(strTemp)];
			%>
      <td height="20" align="center" class="thinborder"><strong><%=strTemp%> TAX 
          TABLE ENTRIES </strong></td>
    </tr>
  </table>
	 
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <tr> 
      <td width="10%" height="25" align="center" class="thinborder">Status</td>
			<% int iCount = 1;
				for(int i = 0; i < vRetResult.size() ; i += 16, iCount++){
				strTemp = Integer.toString(iCount);
				strTemp += "<br>" + (String)vRetResult.elementAt(i + 2);
				strTemp += "<br>+" + (String)vRetResult.elementAt(i + 3) + "% over"; 
			%>
      <td align="center" class="thinborder">&nbsp;<font size="1"><%=strTemp%></font></td>
			<%}%>
    </tr>
    <tr>
      <td height="25" colspan="<%= 1 + (vRetResult.size()/16)%>" class="thinborder">A. Without dependent children </td>
    </tr>
    <tr>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td height="20" class="NoBorder">1.) Z </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">2.) S &nbsp;</td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">3.) HF </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">4.) ME </td>
        </tr>
        
      </table></td>
			<%for(int i = 0; i < vRetResult.size() ; i += 16, iCount++){%>
      <td height="25" class="thinborder">
			  <table width="100%" border="0" cellspacing="0" cellpadding="0">        
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 4)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 5)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 6)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 7)%>&nbsp;</td>
        </tr>        
      </table></td>
			<%}%>
    </tr>
    <tr>
      <td height="25" colspan="<%= 1 + (vRetResult.size()/16)%>" class="thinborder">B. Head of family with dependent child(ren) </td>
    </tr>
    <tr>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td height="20" class="NoBorder">1.) HF 1 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">2.) HF 2 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">3.) HF 3 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">4.) HF 4 </td>
        </tr>
        
      </table></td>
			<%for(int i = 0; i < vRetResult.size() ; i += 16, iCount++){%>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 8)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 9)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 10)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 11)%>&nbsp;</td>
        </tr>        
      </table></td>
			<%}%>
    </tr>
    <tr>
      <td height="25" colspan="<%= 1 + (vRetResult.size()/16)%>" class="thinborder">B. Married employee with dependent child(ren) </td>
    </tr>
    <tr>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        
        <tr>
          <td height="20" class="NoBorder">1.) ME 1 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">2.) ME 2 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">3.) ME 3 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">4.) ME 4 </td>
        </tr>
      </table></td>
			<%for(int i = 0; i < vRetResult.size() ; i += 16, iCount++){%>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 12)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 13)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 14)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 15)%>&nbsp;</td>
        </tr>
      </table></td>
			<%}%>
    </tr>
  </table>
 <%}//if vRetResult is not null%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
