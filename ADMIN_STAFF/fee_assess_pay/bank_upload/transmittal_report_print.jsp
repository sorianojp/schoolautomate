<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transmittal Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation();
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
	
	BankPosting bp = new BankPosting();
	
	int iCounter = 1;
	boolean bolStartBreak = false;
	boolean bolPageBreak = false;
	Vector vRetResult = null;
	
	String strTransDate = WI.formatDate(WI.fillTextValue("transaction_date"), 6);
	if(WI.fillTextValue("trans_date_to").length() > 0) 
		strTransDate += " to "+WI.formatDate(WI.fillTextValue("trans_date_to"), 6);
	
	
	Vector vValues = bp.generateTransmittalReport(dbOP, request);
	if(vValues != null){
		for(int x  = 0; x < vValues.size(); x += 6){
			iCounter = 1;
			if(x > 0){%>
				<DIV style="page-break-before:always" ></DIV>
		<%}
			vRetResult = (Vector)vValues.elementAt(x+3);
			if(vRetResult != null){
				int i = 0;
				int iCount = 0;
				int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
				int iNumRec = 0;
				int iPageNo = 1;
				int iTotalPages = vRetResult.size()/(4*iMaxRecPerPage);	
				if(vRetResult.size()%(4*iMaxRecPerPage) > 0)
					iTotalPages++;	
				for (;iNumRec < vRetResult.size();iPageNo++){%>	
	
	<table bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td rowspan="4" align="right" width="25%"><img src="../../../images/logo/AUG_BAW.GIF" height="100" width="100"></td>
		    <td width="50%" height="25" align="center">ANGELES UNIVERSITY FOUNDATION</td>
		    <td width="25%" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center">Accounting and Finance Office</td>
		    <td height="25" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center">Cash Management</td>
		    <td height="25" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center">Official Receipt Transmittal List</td>
		    <td height="25" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="20" colspan="3"><font style="font-size:11px">Transaction Date: <%=strTransDate%></font></td>
		</tr>
		<tr>
			<td height="20"><font style="font-size:11px">College: <%=(String)vValues.elementAt(x+2)%></font></td>
			<td width="20%"><font style="font-size:11px">Total OR Count: <%=(String)vValues.elementAt(x+4)%></font></td>
		    <td width="30%" class="thinborderNONE">Total Amount: <%=(String)vValues.elementAt(x+5)%></td>
		</tr>
		<tr>
			<td height="20" width="50%">&nbsp;</td>
		    <td height="20" colspan="2"><font style="font-size:11px">Page <%=iPageNo%> of <%=iTotalPages%></font></td>
	    </tr>
		<tr>
		  	<td height="15" colspan="3">&nbsp;</td>
	  	</tr>
	</table>
	
	<table bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>List Number</strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Student Number</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Name</strong></td>
			<td width="18%" align="center" class="thinborder"><strong>OR Number</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Amount</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Remark</strong></td>
		</tr>
	<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=4, ++iCount, iCounter++){
			bolStartBreak = false;
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;	
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCounter%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>
			<td class="thinborder">&nbsp;</td>
		</tr>
	<%}%>
	</table>
	<%if (bolPageBreak){%>
		<DIV style="page-break-before:always" ></DIV>
	<%}//page break ony if it is not last page.%>
	
<%}}}}%>
</body>
</html>
<%
dbOP.cleanUP();
%>