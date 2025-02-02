<%@ page language="java" import="utility.*, Accounting.TsuneishiDC, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Invoice Description</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
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
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","view_dc_info.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}	
	
	Vector vDCInfo = null;
	Vector vRetResult = null;
	Vector vTemp = null;
	TsuneishiDC tsuDC = new TsuneishiDC();
	
	if(WI.fillTextValue("dc_number").length() > 0){
		vDCInfo = tsuDC.getDCInformation(dbOP, request);
		if(vDCInfo == null)
			strErrMsg = tsuDC.getErrMsg();
		else
			vRetResult = tsuDC.operateOnDCNoteDetails(dbOP, request, 4, (String)vDCInfo.elementAt(0));
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./view_dc_info.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: D/C NOTE DETAILS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	    </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">D/C  Number: </td>
			<td width="80%">
				<input type="hidden" name="dc_number" value="<%=WI.fillTextValue("dc_number")%>" />
				<strong><font size="3" color="#FF0000"><%=WI.fillTextValue("dc_number")%></font></strong></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
	    </tr>
	</table>
	
<%if(vDCInfo != null && vDCInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">D/C Number: </td>
		    <td colspan="3"><%=(String)vDCInfo.elementAt(2)%></td>
		    <input type="hidden" name="invoice_index" value="<%=(String)vDCInfo.elementAt(0)%>" />
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>D/C Date: </td>
		    <td width="30%"><%=(String)vDCInfo.elementAt(1)%></td>
		    <td width="17%">Currency:</td>
		    <td width="33%"><%=(String)vDCInfo.elementAt(9)%> (<%=(String)vDCInfo.elementAt(10)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Charge To: </td>
		    <td colspan="3"><%=(String)vDCInfo.elementAt(4)%></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Address:</td>
		    <td colspan="3"><%=(String)vDCInfo.elementAt(7)%></td>
	    </tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
	</table>
		
	<%if(vRetResult != null && vRetResult.size() > 0){%>	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="2" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: D/C NOTE DETAILS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="75%" align="center" class="thinborder"><strong>Details</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Amount</strong></td>
		</tr>
		<%for(int i = 0; i < vRetResult.size(); i+=7){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		    <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+2)%>&nbsp;&nbsp;</td>
	    </tr>
		<%}%>
	</table>
	<%}
}%>	

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>