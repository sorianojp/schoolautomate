<%@ page language="java" import="utility.*, Accounting.SOAManagement, java.util.Vector"%>
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
<title>SOA Details</title>
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
								"ACCOUNTING-BILLING","SOA_details.jsp");
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
	
	Vector vSOAInfo = null;
	Vector vRetResult = null;
	SOAManagement soa = new SOAManagement();
	
	vSOAInfo = soa.getSOAInformation(dbOP, request);
	vRetResult = soa.getSOADetails(dbOP, request, (String)vSOAInfo.elementAt(0));
	
	if(vSOAInfo != null && vSOAInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="17%">S/A Number: </td>
		    <td><%=(String)vSOAInfo.elementAt(1)%></td>
		    <td>Date:</td>
		    <td><%=(String)vSOAInfo.elementAt(2)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Type:</td>
		    <td width="30%"><%=(String)vSOAInfo.elementAt(4)%></td>
		    <td width="17%">Currency:</td>
		    <td width="33%"><%=(String)vSOAInfo.elementAt(18)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Charge To: </td>
		    <td colspan="3"><%=(String)vSOAInfo.elementAt(13)%></td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Address:</td>
		    <td colspan="3"><%=(String)vSOAInfo.elementAt(14)%></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Attention:</td>
		    <td><%=(String)vSOAInfo.elementAt(8)%></td>
	        <td>Position:</td>
	        <td><%=(String)vSOAInfo.elementAt(9)%><%=WI.getStrValue((String)vSOAInfo.elementAt(30), " (", ")", "")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Account Name: </td>
		    <td><%=(String)vSOAInfo.elementAt(11)%></td>
	        <td>Account No.: </td>
	        <td><%=(String)vSOAInfo.elementAt(12)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Category: </td>
			<td colspan="3"><%=(String)vSOAInfo.elementAt(25)%> (<%=(String)vSOAInfo.elementAt(24)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Activity: </td>
			<td colspan="3"><%=(String)vSOAInfo.elementAt(22)%> (<%=(String)vSOAInfo.elementAt(21)%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Amount:</td>
		    <td colspan="3">
				<%
					strTemp = CommonUtil.formatFloat((String)vSOAInfo.elementAt(16), false);
					strErrMsg = ConversionTable.replaceString(strTemp, ",", "");
				%>				
				<%=(String)vSOAInfo.elementAt(18)%><%=strTemp%></td>
	    </tr>
		<tr>
			<td height="15" colspan="5"><hr size="1" /></td>
		</tr>
	</table>
	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="4" class="thinborder"><div align="center"><strong>::: SOA DETAILS ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="50%" align="center" class="thinborder"><strong>Employee</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=7, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%> (<%=(String)vRetResult.elementAt(i+1)%>)</td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true)%></td>
	      	<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/delete.gif" border="0"></a>
				<%}%>
			<%}else{%>
				Not authorized.
			<%}%></td>
		</tr>
	<%}%>
	</table>
	<%}
}%>	
</body>
</html>
<%
dbOP.cleanUP();
%>
