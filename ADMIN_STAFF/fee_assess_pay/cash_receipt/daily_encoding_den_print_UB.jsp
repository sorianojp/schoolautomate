<%@ page language="java" import="utility.*,Accounting.CashReceiptBook,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
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
	
	double dCheckPeso = 0d;//peso check amt.
	double dCheckCent = 0d;//cents check amt.
	
	double dCCPeso    = 0d;
	double dCCCent    = 0d;
	
	String strNumberOfCheck = null;
	

	vRetResult = crb.operateOnDenominationDeposit(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = crb.getErrMsg();
	else
		iTemp = vRetResult.size()/4;
		
		vCollectInfo = crb.getTotalTellerAmount(dbOP, request);
		if(vCollectInfo == null)
			strErrMsg = crb.getErrMsg();
		else {
				dTotCollection = 0d;//System.out.println(vCollectInfo);
				dTotCash  = ((Double)vCollectInfo.elementAt(0)).doubleValue();
				dTotCheck = ((Double)vCollectInfo.elementAt(1)).doubleValue();
				dTotSD    = ((Double)vCollectInfo.elementAt(2)).doubleValue();
				dTotCC    = ((Double)vCollectInfo.elementAt(3)).doubleValue();
				
				strNumberOfCheck = (String)vCollectInfo.elementAt(4);
			
				
				dCheckPeso = new Double((int)dTotCheck).doubleValue();
				dCheckCent = dTotCheck - dCheckPeso;
				
				dCCPeso = new Double((int)dTotCC).doubleValue();
				dCCCent = dTotCC - dCCPeso;

								
				dTotCollection = dTotCash+dTotCheck+dTotSD+dTotCC;
		}

%>
<body bgcolor="#FFFFFF" onLoad="window.print();">

<%if(vRetResult != null && vRetResult.size() > 0){
	int iCountDen = vRetResult.size()/4;
%>
	<input type="hidden" name="max_count" value="<%=iCountDen%>">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr><td colspan="3" height="100">&nbsp;</td></tr>
		<tr>			
			<td width="46%" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>					
						<td width="20%" align="right">&nbsp;<img src="../../../images/logo/UB_BOHOL.gif" width="50" height="50"></td>					
						<td align="center">
							<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
							<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>								
						</td>					
					<td width="20%">&nbsp;</td>
					</tr>
					<tr><td colspan="3">
						<table width="100%">
							<tr><td width="70%">&nbsp;</td><td class="thinborderBOTTOM" align="center"><%=WI.fillTextValue("date_fr")%></td></tr>
							<tr><td width="70%">&nbsp;</td><td align="center">Date</td></tr>
						</table></td></tr>
					<tr><td colspan="3" class="thinborderTOPBOTTOM" align="center"><font size="+1"><strong>DENOMINATION</strong></font></td></tr>
					<tr><td colspan="3" height="5"></td></tr>
			  </table>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
					<tr>
						<td width="30%" height="18" align="center" class="thinborder"><strong>&nbsp;</strong></td>
						<td width="20%" align="center" class="thinborder"><strong>Number</strong></td>
						<td width="30%" align="center" class="thinborder"><strong>Pesos</strong></td>
						<td width="20%" align="center" class="thinborder"><strong>Centavos</strong></td>
					</tr>
					<%if(dTotCC > 0d) {%>
						<tr>
						  <td height="18" align="center" class="thinborder">Credit Card</td>
						  <td align="center" class="thinborder">&nbsp;</td>
						  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dCCPeso, true)%> &nbsp; </td>
						  <td class="thinborder"> &nbsp; <%=CommonUtil.formatFloat(dCCCent, true)%></td>
					  </tr>
					<%}%>
					<tr>
					  <td height="18" align="center" class="thinborder">Cheque</td>
					  <td align="center" class="thinborder"><%=WI.getStrValue(strNumberOfCheck, "0")%></td>
					  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dCheckPeso, true)%> &nbsp; </td>
					  <td class="thinborder"> &nbsp; <%=CommonUtil.formatFloat(dCheckCent, true)%></td>
				  </tr>
				<%	int iCount = 0;
					double dAmtEncoded = 0d;
					double dAmtPesos = 0d;
					double dAmtCent = 0d;
					for(int i = 0; i < vRetResult.size(); i += 4, iCount++){
						dAmtPesos = 0d;
						dAmtCent = 0d;
						if(vRetResult.elementAt(i+3) != null){
							dAmtEncoded +=  Double.parseDouble((String)vRetResult.elementAt(i+2)) * Double.parseDouble((String)vRetResult.elementAt(i+3));
							dAmtPesos  = Double.parseDouble((String)vRetResult.elementAt(i+2)) * Double.parseDouble((String)vRetResult.elementAt(i+3));
							dAmtCent  = Double.parseDouble((String)vRetResult.elementAt(i+2)) * Double.parseDouble((String)vRetResult.elementAt(i+3));
						}
						
						if(dAmtCent > 1.00)
							dAmtCent = 0d;
						if(dAmtPesos < 1.00)
							dAmtPesos = 0d;
							
						
					%>
					<tr>
						<td height="18" align="center" class="thinborder">P <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), false)%></td>
						<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "0")%></td>
						<td class="thinborder" align="right"><%=CommonUtil.formatFloat(dAmtPesos, true)%> &nbsp; </td>
						<td class="thinborder"> &nbsp; <%=CommonUtil.formatFloat(dAmtCent, true)%></td>
					</tr>
				<%}%>
					<tr>
						<td height="18" colspan="2" align="center" class="thinborder"><strong>Total</strong></td>
						<td align="center" colspan="2" class="thinborder"><strong><%=CommonUtil.formatFloat(dAmtEncoded + dTotCheck + dTotCC, true)%></strong></td>
					</tr>
				</table>
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr><td height="25">Submitted the amount of:</td></tr>
					<%
					ConversionTable con = new ConversionTable();
            		
					%>
					<tr><td height="25"><%=con.convertAmoutToFigure(dAmtEncoded + dTotCheck + dTotCC,"","")%></td></tr>
				</table>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td width="60%" valign="bottom" align="right"><strong><font size="2">P</font></strong></td>
						<td height="50" valign="bottom" align="right" class="thinborderBOTTOM">
							<font size="2"><strong><%=CommonUtil.formatFloat(dAmtEncoded + dTotCheck + dTotCC, true)%></strong></font></td>
					</tr>
					
					
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
					
					<tr>
						<td height="60" colspan="2" align="center" valign="bottom"><strong>
							<div style="border-bottom:solid 1px #000000; width:80%;"><%=strTellerName%> (<%=strTemp%>)</div></strong></td>
					</tr>
				<tr><td height="25" align="center" valign="top" colspan="2">Teller</td></tr>	
						
				<tr>
					<td height="60" colspan="2" align="center" valign="bottom">
						<div style="border-bottom:solid 1px #000000; width:80%;"><strong>Bominda Cecilia T. Dalaguiado</strong></div></td>
				  </tr>
				<tr><td height="25" align="center" valign="top" colspan="2">Cashier</td></tr>
				<tr>
<td height="60" colspan="2" align="center" valign="bottom">
						<div style="border-bottom:solid 1px #000000; width:80%;"><strong>Rogemer G. Ojendras </strong></div></td>
				  </tr>
				<tr>
				  <td height="25" align="center" valign="top" colspan="2">Auditor</td>
				</tr>
				<tr>
				  <td height="25" align="center" valign="top" colspan="2">&nbsp;</td>
				  </tr>
</table>
			</td>	
			
			
			<td >&nbsp;</td>
			
			
			<td width="46%" valign="top">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>					
						<td width="20%" align="right">&nbsp;<img src="../../../images/logo/UB_BOHOL.gif" width="50" height="50"></td>					
						<td align="center">
							<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
							<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>								
						</td>					
					<td width="20%">&nbsp;</td>
					</tr>
					<tr><td colspan="3">
						<table width="100%">
							<tr><td width="70%">&nbsp;</td><td class="thinborderBOTTOM" align="center"><%=WI.fillTextValue("date_fr")%></td></tr>
							<tr><td width="70%">&nbsp;</td><td align="center">Date</td></tr>
						</table></td></tr>
					<tr><td colspan="3" class="thinborderTOPBOTTOM" align="center"><font size="+1"><strong>DENOMINATION</strong></font></td></tr>
					<tr><td colspan="3" height="5"></td></tr>
			  </table>
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
					<tr>
						<td width="30%" height="18" align="center" class="thinborder"><strong>&nbsp;</strong></td>
						<td width="20%" align="center" class="thinborder"><strong>Number</strong></td>
						<td width="30%" align="center" class="thinborder"><strong>Pesos</strong></td>
						<td width="20%" align="center" class="thinborder"><strong>Centavos</strong></td>
					</tr>
					<%if(dTotCC > 0d) {%>
						<tr>
						  <td height="18" align="center" class="thinborder">Credit Card </td>
						  <td align="center" class="thinborder">&nbsp;</td>
					  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dCCPeso, true)%> &nbsp; </td>
					  <td class="thinborder"> &nbsp; <%=CommonUtil.formatFloat(dCCCent, true)%></td>
					  </tr>
					<%}%>
					<tr>
					  <td height="18" align="center" class="thinborder">Cheque</td>
					  <td align="center" class="thinborder"><%=WI.getStrValue(strNumberOfCheck, "0")%></td>
					  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dCheckPeso, true)%> &nbsp; </td>
					  <td class="thinborder"> &nbsp; <%=CommonUtil.formatFloat(dCheckCent, true)%></td>
				  </tr>
				<%	iCount = 0;
					dAmtEncoded = 0d;
					dAmtPesos = 0d;
					dAmtCent = 0d;
					for(int i = 0; i < vRetResult.size(); i += 4, iCount++){
						dAmtPesos = 0d;
						dAmtCent = 0d;
						if(vRetResult.elementAt(i+3) != null){
							dAmtEncoded +=  Double.parseDouble((String)vRetResult.elementAt(i+2)) * Double.parseDouble((String)vRetResult.elementAt(i+3));
							dAmtPesos  = Double.parseDouble((String)vRetResult.elementAt(i+2)) * Double.parseDouble((String)vRetResult.elementAt(i+3));
							dAmtCent  = Double.parseDouble((String)vRetResult.elementAt(i+2)) * Double.parseDouble((String)vRetResult.elementAt(i+3));
						}
						
						if(dAmtCent > 1.00)
							dAmtCent = 0d;
						if(dAmtPesos < 1.00)
							dAmtPesos = 0d;
							
						
					%>
					<tr>
						<td height="18" align="center" class="thinborder">P <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), false)%></td>
						<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "0")%></td>
						<td class="thinborder" align="right"><%=CommonUtil.formatFloat(dAmtPesos, true)%> &nbsp; </td>
						<td class="thinborder"> &nbsp; <%=CommonUtil.formatFloat(dAmtCent, true)%></td>
					</tr>
				<%}%>
					<tr>
						<td height="18" colspan="2" align="center" class="thinborder"><strong>Total</strong></td>
						<td align="center" colspan="2" class="thinborder"><strong><%=CommonUtil.formatFloat(dAmtEncoded + dTotCheck + dTotCC, true)%></strong></td>
					</tr>
				</table>
				
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr><td height="25">Submitted the amount of:</td></tr>
					<tr><td height="25"><%=con.convertAmoutToFigure(dAmtEncoded + dTotCheck + dTotCC,"","")%></td></tr>
				</table>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td width="60%" valign="bottom" align="right"><strong><font size="2">P</font></strong></td>
						<td height="50" valign="bottom" align="right" class="thinborderBOTTOM">
							<font size="2"><strong><%=CommonUtil.formatFloat(dAmtEncoded + dTotCheck + dTotCC, true)%></strong></font></td>
					</tr>
					
					
					<%
					if(WI.fillTextValue("emp_id").length() == 0) 
						strTemp = (String)request.getSession(false).getAttribute("userId");
					else
						strTemp = WI.fillTextValue("emp_id");
					
						strTellerName = "select fname, mname, lname from user_table where id_number = '"+strTemp+"'";
						rs = dbOP.executeQuery(strTellerName);
						if(rs.next()) 
							strTellerName = WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4);
						rs.close();
					%>
					
					<tr>
						<td height="60" colspan="2" align="center" valign="bottom"><strong>
							<div style="border-bottom:solid 1px #000000; width:80%;"><%=strTellerName%> (<%=strTemp%>)</div></strong></td>
					</tr>
				<tr><td height="25" align="center" valign="top" colspan="2">Teller</td></tr>	
						
				<tr>
					<td height="60" colspan="2" align="center" valign="bottom">
						<div style="border-bottom:solid 1px #000000; width:80%;"><strong>Bominda Cecilia T. Dalaguiado</strong></div></td>
				  </tr>
				<tr><td height="25" align="center" valign="top" colspan="2">Cashier</td></tr>
				<tr>
<td height="60" colspan="2" align="center" valign="bottom">
						<div style="border-bottom:solid 1px #000000; width:80%;"><strong>Rogemer G. Ojendras</strong></div></td>
				  </tr>
				<tr>
				  <td height="25" align="center" valign="top" colspan="2">Auditor</td>
				</tr>
</table>
			</td>
			
			
			
						
		</tr>
	</table>
	
	<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>