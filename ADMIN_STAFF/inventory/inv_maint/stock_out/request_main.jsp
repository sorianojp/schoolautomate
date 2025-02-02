<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>

<%@ page language="java" import="utility.*" %>
<%
	WebInterface WI = new WebInterface(request);	
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	  <tr bgcolor="#A49A6A">
	  <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        STOCK OUT/ ITEM REMOVAL REQUISITION MAIN PAGE ::::</strong></font></div></td>
	  </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td width="12%" height="25">&nbsp;</td>
      <td width="15%" height="25" align="right">Operation : </td>
      <td width="2%" align="center">&nbsp;</td>
      <td width="71%"> <a href="stock_out_info.jsp"> Create/modify requisition 
        information </a></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
      <td width="71%"> <a href="stock_out_item.jsp">Add/modify requisition 
        items </a></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
      <td><a href="stock_out_update.jsp">Update request</a></td>
    </tr>		
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
      <td><a href="remove_item.jsp">Stock Out</a></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
      <td><a href="stock_out_view_search.jsp">Search stock out requests</a></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;
	    <!--<a href="javascript:ForwardTo(3);">Update requisition status</a>-->	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td width="1%" height="25">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="myHome" value="<%=WI.fillTextValue("myHome")%>">
</form>
</body>
</html>
