<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Cash Voucher</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.


	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","print_jv_AUF.jsp");
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

	String strJVNumber = WI.fillTextValue("jv_number");/////I must get when i save / edit.
	JvCD jvCD = new JvCD();
	
	boolean bolIsCD = false;
	int iVoucherType = 0;//0 = jv, 1 = cd, 2 = petty cash.
	
	Vector vJVDetail  = null; //to show detail at bottom of page. 
	Vector vJVInfo    = null;
	Vector vGroupInfo = null;
	
	String strPreparedBy = "Arlene B. Falcon";
	String strApprovedBy = "Merle J. San Pedro / DR. Marilissa J. Ampuan";
	String strVerifiedBy = "Maria Victoria T. Martinez";
	
	
	double dChkAmt = 0d;
	
	if(strJVNumber.length() > 0) {
		vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);
		if(vJVDetail == null)
			strErrMsg = jvCD.getErrMsg();
		else {
			vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE, [2] = jv_type, [3] = is_cd,
													//[4] lock_date, [5] = payee name.
			vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
			vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
		
			iVoucherType = Integer.parseInt((String)vJVInfo.elementAt(3));
			
		}
	}
	else 
		strErrMsg = "Voucher Number not found.";
		
	if(iVoucherType != 1) 
		strErrMsg = "Only CD printing is allowed.";
	if(vJVInfo != null) {
		strTemp = "select sum(amount) from ac_jv_dc where is_debit = 0 and jv_index = "+vJVInfo.elementAt(0)+
			" and exists (select * from AC_COA_BANKCODE where AC_COA_BANKCODE.coa_index = ac_jv_dc.coa_index and is_valid = 1) ";
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			dChkAmt = rs.getDouble(1);	
		rs.close();		
	}
	
	if(strErrMsg != null) {
	dbOP.cleanUP();
%>
<p align="center" style="font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold;"><%=strErrMsg%></p>
<%return;}%>
<body onLoad="window.print();" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<!--
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">
		<div align="center">
		<font style="font-size:12px; font-weight:bold"> <%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%><br>	
		<br><br><u>CASH VOUCHER</u>				
		</div>
		</td>
	</tr>
</table>
-->
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="7%">PAY TO:  </td>
		<td width="52%"><%=vJVInfo.elementAt(5)%></td>
		<td width="10%" style="padding-left:20px;">DATE</td>
		<td width="31%"><%=vJVInfo.elementAt(1)%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr><td colspan="2">&nbsp;</td></tr>
	<tr>
		<td width="60%" height="20" valign="bottom">
		<div align="center"><b>PARTICULAR</b></div></td>
		<td colspan="2"><div align="center"><b>AMOUNT</b></div></td>
	</tr>
	<tr>
		<td align="center"  height="20" valign="bottom">
		<td width="21%">&nbsp;</td>
		<td width="19%">&nbsp;</td>
	</tr>
	<tr>
		<td align="center" height="25">
		<%	for(int i =0; i < vGroupInfo.size(); i += 4){%>
		<%=WI.getStrValue(vGroupInfo.elementAt(i + 1)) + "<br>"%>
		<%	}%></td>
		<td >&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td >&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td align="center"><div  align="center">(Total Amount in words)
		</div><br>&nbsp;
		<%=new ConversionTable().convertAmoutToFigure(dChkAmt,"Pesos","Centavos")%>
		(<%=CommonUtil.formatFloat(dChkAmt, true)%>)</td>
		<td  valign="bottom">P <%=CommonUtil.formatFloat(dChkAmt, true)%></td>
		<td>&nbsp;</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="2">Charge to:</td>
	</tr>
	<tr>
		<td width="38%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td align="center" colspan="3" height="20">Account</td>
				</tr>
				<tr>
					<td colspan="3" height="20">
						<table width="100%" border="0" cellpadding="0" cellspacing="0" >
							<tr>
								<td width="37%" height="20">&nbsp;</td>
								<td width="34%"  align="center">DEBIT</td>
								<td width="29%"  align="center">CREDIT</td>
							</tr>
							<%	int iTotalLine   = 6;
								int iLinePrinted = 0;
								float fDebit = 0f;
								float fCredit = 0f;
								float fDTotal = 0f;
								float fCTotal = 0f;
									for(int p = 0; p < vJVDetail.size(); p += 5) {
										if(vJVDetail.elementAt(p + 4).equals("0"))
										//if not debit or if not belong to same group.. continue.
											continue;
										++iLinePrinted;
										
										
							     fDebit = Float.parseFloat((String)vJVDetail.elementAt(p + 2));		
							%>
							
							
							<tr>
							   <td height="25"><%=vJVDetail.elementAt(p + 1)%> 
							   (<%=vJVDetail.elementAt(p + 0)%>) 
							   </td>
							   <td height="25" >
							   <div align="right">
							   <%=fDebit%>&nbsp;&nbsp;</div>
							   </td>
							   <td height="25">&nbsp;</td>
							  </tr>
							<%	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
								vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
								p = p - 5;
								
								fDTotal +=fDebit;
								}
							%>
							<%while(vJVDetail.size() > 0) {++iLinePrinted;
							  fCredit = Float.parseFloat((String)vJVDetail.elementAt(2));
							
							
							%>
							<tr>
								  <td >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								  <%=vJVDetail.elementAt(1)%> (<%=vJVDetail.elementAt(0)%>) </td>
								  <td height="25" >&nbsp;</td>
								  <td ><div align="right">
								  <%=fCredit%>&nbsp;&nbsp;</div></td>
							</tr>
							<%		vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
									vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
									
									fCTotal +=fCredit;
							 }
							 while (iTotalLine > iLinePrinted){++iLinePrinted;%>
							<tr>
							  <td >&nbsp;</td>
							  <td height="25" >&nbsp;</td>
							  <td >&nbsp;</td>
							</tr>
							 <%}%>
							 <tr>
							 <td align="right" height="20">TOTALS - P</td>
							 <td align="right"><%=fDTotal%></td>
							  <td align="right"><%=fCTotal%></td>
							 </tr>
						</table>
					</td>
				</tr>
			</table>		
	  </td>
		<td width="62%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
			  <tr>
				<td width="57%" valign="top">
					<table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
					<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;Prepared by:</td>					
					</tr>
					<tr><td height="25" align="center" valign="bottom" style="padding-right:10px; padding-left:10px;">
					
					<%=WI.getStrValue(strPreparedBy)%>
					</td></tr>
					<tr><td>&nbsp;</td></tr>
					<tr>
					<td height="20">&nbsp;&nbsp;&nbsp;&nbsp;Approved by:</td>					
					</tr>
					<tr><td height="25" align="center" style="padding-right:10px; padding-left:10px;">
					
					<%=WI.getStrValue(strApprovedBy).toUpperCase()%>
					
					</td></tr>
					
					<tr><td>&nbsp;</td></tr>
					<tr>
					<td height="25" valign="bottom">
					&nbsp;&nbsp;&nbsp;&nbsp;Bank/Check No.<u>&nbsp;</u></td>					
					</tr>
					
					<tr><td>&nbsp;</td></tr>
					<tr><td height="25" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;Date 
					<u>&nbsp;</u></td></tr>
				  </table>
			    </td>
				<td width="43%" valign="top">
				    <table width="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
					<td height="20">Verified by:</td>					
					</tr>
					<tr><td height="25" align="center" valign="bottom">
					<%=WI.getStrValue(strVerifiedBy)%>
					</td></tr>
					
					<tr><td>&nbsp;</td></tr>
					<tr>
					<td height="25">Recieved payment mentioned aboved in Check/Cash</td>					
					</tr>					
					<tr><td>&nbsp;</td></tr>
					<tr><td height="25" valign="bottom">Date <%=WI.formatDate((String)vJVInfo.elementAt(1), 11)%></td></tr>
					<tr>
					<td height="20">&nbsp;</td>					
					</tr>
					<tr><td height="25" valign="bottom" align="center">&nbsp;<br>Signature</td></tr>
			    </table></td>
			  </tr>
			</table>
	  </td>	
	</tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>