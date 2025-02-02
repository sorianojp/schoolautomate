<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Suppliers</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
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
</style>
</head>
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,purchasing.Supplier"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-SUPPLIERS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
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
								"Admin/staff-PURCHASING-SUPPLIERS-Print Suppliers","suppliers_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.	
	
	Supplier SUP = new Supplier();	
	Vector vRetSuppliers = null;
	vRetSuppliers = SUP.operateOnSupplierInfo(dbOP,request,4);
	if(vRetSuppliers == null)
		strErrMsg = SUP.getErrMsg();
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int u = 1;
	int iCount = 0;
	boolean bolPageBreak = false;

if(vRetSuppliers == null){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">    
    <tr valign="top" bgcolor="#FFFFFF"> 
      
    <td height="34">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
</table>
<%}else{
	for (;u < vRetSuppliers.size();){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
    <td height="25" colspan="2"><div align="center"> 
          <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>          
          <br>
          </div></td>
  </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <%if(vRetSuppliers.size() > 1){%>
    <tr> 
      <td  height="25" colspan="7" class="thinborder"><div align="center"><strong>LIST 
          OF SUPPLIERS</strong></div></td>
    </tr>
    <tr> 
      <td  height="25" colspan="7" class="thinborder"><strong>TOTAL SUPPLIER(S) : <%=(String)vRetSuppliers.elementAt(0)%></strong></td>
    </tr>
    <tr> 
      <td width="5%" class="thinborder"><div align="center"><strong>COUNT NO.</strong></div></td>
      <td width="9%" height="26" class="thinborder"><div align="center"><strong>SUPPLIER CODE </strong></div></td>
      <td width="25%" class="thinborder"><div align="center"><strong>SUPPLIER NAME</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>TYPE</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>CONTACT NOS.</strong></div></td>
      <td width="27%" class="thinborder"><div align="center"><strong>CONTACT PERSON</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>A/P BALANCE</strong></div></td>
    </tr>
	<% 
 	for(iCount = 0; iCount <= iMaxStudPerPage; u += 24,++iCount){
  		if (iCount >= iMaxStudPerPage || u >= vRetSuppliers.size()){
			if(u >= vRetSuppliers.size())
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;			
	}%>    
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(u+6)/6%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetSuppliers.elementAt(u+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vRetSuppliers.elementAt(u+2)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetSuppliers.elementAt(u+3)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vRetSuppliers.elementAt(u+4)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vRetSuppliers.elementAt(u+5)%></div></td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}
	if (u >= vRetSuppliers.size()){	
   %>
  <tr> 
    <td colspan="7" class="thinborder"><div align="center"><font size="1"> *****************NOTHING FOLLOWS *******************</font></div></td>
  </tr>
   <%}else{%>    
  <tr> 
    <td colspan="7" class="thinborder"><div align="center"><font size="1"> ************** CONTINUED ON NEXT PAGE ****************</font></div></td>
  </tr>
  <%}%>
  </table>  
</table><%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
  <%}%>
  </table>
  <%}%>
</body>
</html>
<% 
dbOP.cleanUP();
%>
