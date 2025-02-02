<%@ page language="java" import="utility.*,inventory.InventorySearch,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View / Search Requisition</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script> 
<body onLoad="javascript:window.print();">
<%
	String strErrMsg = null;
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}				
	}
	
	if(WI.fillTextValue("my_home").equals("1"))
		iAccessLevel = 2;
		
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition Search","issuance_view_search.jsp");
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
	
	InventorySearch InvSearch = new InventorySearch();
	Vector vRetResult = null;		
 	int iSearch = 0;
	int iDefault = 0;
	
 		vRetResult = InvSearch.searchIssuances(dbOP,request);
		if(vRetResult == null)
			strErrMsg = InvSearch.getErrMsg();
		else
			iSearch = InvSearch.getSearchCount();
 %>
<form name="form_">
  <%if(vRetResult != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" align="center" class="thinborderTOPLEFTRIGHT"><strong>LIST 
      OF ISSUANCES</strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td width="20%" height="25" align="center" class="thinborder"><strong>ISSUANCE NO.</strong></td>
      <td width="20%" align="center" class="thinborder"><strong>DATE ISSUED </strong></td>
      <td width="38%" align="center" class="thinborder"><strong>RECEIVED BY </strong></td>
    </tr>
    <%for(int i = 0;i < vRetResult.size();i+=5){%>
    <tr> 
      <td height="25" align="center" class="thinborder"> 
        <%if(WI.fillTextValue("opner_info").length() > 0) {%>
        <a href='javascript:CopyID("<%=(String)vRetResult.elementAt(i+1)%>");'> 
        <%=(String)vRetResult.elementAt(i+1)%> </a> 
        <%}else{%>   
     	  <%=(String)vRetResult.elementAt(i+1)%>
        <%}%>        </td class="thinborder">
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%></td>
    </tr>	
    <%   
	}%>
	<%if(WI.fillTextValue("opner_info").length() < 1) {%> 
    
	<%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>    
  </table>
<%}%>
<!-- all hidden fields go here --> </form>
</body>
</html>
<%
dbOP.cleanUP();
%>