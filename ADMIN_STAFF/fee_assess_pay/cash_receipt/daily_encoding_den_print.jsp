<%@ page language="java" import="utility.*,Accounting.CashReceiptBook,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS-Daily Encoding Denomination","daily_encoding_den.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
															"daily_encoding_den.jsp");
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
	
	int iTemp = 0;
	double dAmount = 0d;
	Vector vRetResult = null;
	CashReceiptBook crb = new CashReceiptBook();
	
	String strTellerName = null;
	
	Vector vCollectInfo = null;
	double dTotCollection = 0d;
	double dTotCash  = 0d;
	double dTotCheck = 0d;
	double dTotSD    = 0d;
	double dTotCC    = 0d;

	vRetResult = crb.operateOnDenominationDeposit(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = crb.getErrMsg();
	else
		iTemp = vRetResult.size()/4;
		
		vCollectInfo = crb.getTotalTellerAmount(dbOP, request);
		if(vCollectInfo == null)
			strErrMsg = crb.getErrMsg();
		else {
				dTotCollection = 0d;
				dTotCash  = ((Double)vCollectInfo.elementAt(0)).doubleValue();
				dTotCheck = ((Double)vCollectInfo.elementAt(1)).doubleValue();
				dTotSD    = ((Double)vCollectInfo.elementAt(2)).doubleValue();
				dTotCC    = ((Double)vCollectInfo.elementAt(3)).doubleValue();
				
				dTotCollection = dTotCash+dTotCheck+dTotSD+dTotCC;
		}


	String strORRange = "";
	if(WI.fillTextValue("date_fr").length() > 0) { 
		Vector vORUsed = new EnrlReport.DailyCashCollection().getOrNumberRangeUsed(dbOP, (String)request.getSession(false).getAttribute("userIndex"), WI.fillTextValue("date_fr"));

		if(vORUsed != null) {
			while(vORUsed.size() > 0) {
				if(strORRange.length() > 0)
					strORRange = strORRange + ", ";
				
				strORRange = strORRange + (String)vORUsed.remove(0) + " - "+(String)vORUsed.remove(0);
			}
				
		}
	}
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
%>
<body bgcolor="#FFFFFF" onLoad="window.print();">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="4" align="center"><strong>:::: TELLER CASH COUNTING DETAIL ::::</strong></td>
		</tr>
<%if(strErrMsg != null) {%>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
<%}%>
		<tr>
			<td height="15" colspan="4" align="right">Date Time Printed: <%=WI.getTodaysDateTime()%></td>
		</tr>
		<tr>
		  	<td height="18">&nbsp;</td>
		  	<td>Teller </td>
		  	<td colspan="2" valign="top">
<%
if(WI.fillTextValue("emp_id").length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("userId");
else
	strTemp = WI.fillTextValue("emp_id");

	strTellerName = "select fname, mname, lname from user_table where id_number = '"+strTemp+"'";
	java.sql.ResultSet rs = dbOP.executeQuery(strTellerName);
	if(rs.next()) 
		strTellerName = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
	rs.close();
%>
				<%=strTellerName%> (<%=strTemp%>)</td>
	  	</tr>
		<tr>
			<td height="18" width="3%">&nbsp;</td>
			<td width="17%">Collection Date: </td>
			<td width="21%"><%=WI.fillTextValue("date_fr")%></td>
		    <td width="59%" align="right">OR #: <%=WI.getStrValue(strORRange)%></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){
	int iCountDen = vRetResult.size()/4;
%>
	<input type="hidden" name="max_count" value="<%=iCountDen%>">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="20%">&nbsp;</td>
			<td width="60%">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
					<tr>
						<td height="18" width="50%" align="center" class="thinborder"><strong>Denomination</strong></td>
						<td width="50%" align="center" class="thinborder"><strong>Quantity</strong></td>
					</tr>
				<%	int iCount = 0;
					double dAmtEncoded = 0d;
					for(int i = 0; i < vRetResult.size(); i += 4, iCount++){
						if(vRetResult.elementAt(i+3) != null)
							dAmtEncoded +=  Double.parseDouble((String)vRetResult.elementAt(i+2)) * Double.parseDouble((String)vRetResult.elementAt(i+3));
					%>
					<tr>
						<td height="18" align="center" class="thinborder">P <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), false)%></td>
						<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "0")%></td>
					</tr>
				<%}%>
					<tr>
						<td height="18" align="center" class="thinborder"><strong>Total</strong></td>
						<td align="center" class="thinborder"><%=CommonUtil.formatFloat(dAmtEncoded, true)%></td>
					</tr>
				</table>
			</td>
			<td width="20%">&nbsp;</td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="2"></td>
		</tr>
		<tr>
		  <td height="25" colspan="2">
		  	<table width="50%" align="center">
				<tr>
					<td width="63%">Total Machine Collection: </td>
					<td width="37%"><strong><%=CommonUtil.formatFloat(dTotCollection, true)%></strong></td>
				</tr>
				<tr>
					<td>Total Cash: </td>
					<td><strong><%=CommonUtil.formatFloat(dTotCash, true)%></strong></td>
				</tr>
				<tr>
					<td>Total Check: </td>
					<td><strong><%=CommonUtil.formatFloat(dTotCheck, true)%></strong></td>
				</tr>
				<tr>
					<td>Cash Short/Excess: </td>
					<td><strong><%=CommonUtil.formatFloat(dAmtEncoded - dTotCash, true)%></strong></td>
				</tr>
			</table>		  </td>
	  </tr>
		<tr>
		  <td height="25" colspan="2"></td>
	  </tr>
<%if(strSchCode.startsWith("CIT")){%>
		<tr valign="bottom">
		  <td width="50%" height="25">Teller Signature: _________________________ </td>
	      <td width="50%" height="25">Cashier Name: <u>MA. RAINA ROMANA V. JEREZA</u></td>
      </tr>
<%}else{%>
		<tr valign="bottom">
		  <td width="50%" height="25">Teller's Signature: _________________________ </td>
	      <td width="50%" height="25">Teller's Name: <u><%=(String)request.getSession(false).getAttribute("first_name")%></u></td>
      </tr>
		<tr valign="bottom">
		  <td width="50%" height="25">Verified by: _________________________ </td>
	      <td width="50%" height="25">Approved by: _________________________ </td>
      </tr>
<%}%>
	</table>
	<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>