<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
								"Admin/staff-Accounting-Transaction","journal_voucher_entry.jsp");
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

if(strJVNumber.length() > 0) {
	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);
	if(vJVDetail == null)
		strErrMsg = jvCD.getErrMsg();
	else {
	    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE, [2] = jv_type, [3] = is_cd,[4] lock_date, [5] = payee name.
	    vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    	vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
	
		iVoucherType = Integer.parseInt((String)vJVInfo.elementAt(3));
		
	}
}
else 
	strErrMsg = "JV Number not found.";

String strCheckNo     = null;
String strBankCode    = null;
String strCheckAmount = null;
if(vJVInfo != null && vJVInfo.size() > 0) {
	strTemp = "select BANK_CODE,CHECK_NO,amount from AC_CD_CHECK_DTL join AC_COA_BANKCODE on (AC_COA_BANKCODE.bank_index = AC_CD_CHECK_DTL.bank_index) where cd_index = "+ 
		vJVInfo.elementAt(0);
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	if(rs.next()) {
		strBankCode = rs.getString(1);
		strCheckNo  = rs.getString(2);
		strCheckAmount = CommonUtil.formatFloat(rs.getDouble(3), true);
	}		
	rs.close();
}	

%>

<body onLoad="window.print()" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<%
if(strErrMsg != null) {
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td style="font-size:14px; color:#0000FF; font-weight:bold">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr> 
  </table>
<%
	dbOP.cleanUP();
	return;
}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="12%" align="center"><img src="../../../../images/logo/PHILCST_DAGUPAN.gif" width="100" height="100"></td>
      <td width="88%" height="25" align="center" style="font-weight:bold" valign="top">
	   <font size="4">PHILIPPINE COLLEGE OF SCIENCE AND TECHNOLOGY</font><br>
	    <font size="2" style="font-weight:normal">Calasiao,Pangasinan</font><br><br>
		<font size="4">CASH VOUCHER</font>
	  
	  </td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td> 
      <td width="97%" height="25" style="font-size:12px; font-weight:bold">Pay to: <u><%=vJVInfo.elementAt(5)%></u></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;&nbsp;</td> 
<%
strTemp = "select payee_addr from ac_jv where jv_index = "+(String)vJVInfo.elementAt(0);
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
%>      <td height="25" style="font-size:12px; font-weight:bold">Address: <%=WI.getStrValue(strTemp)%>
	  </td>
    </tr>
  </table>
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr style="font-weight:bold" align="center">
			<td width="40%" style="font-size:14px;" class="thinborderTOPBOTTOM">EXPLANATION</td>
			<td width="30%" style="font-size:14px;" class="thinborderALL">ACCOUNT CHARGED</td>
			<td width="15%" style="font-size:14px;" class="thinborderTOPBOTTOM">ACCOUNT NO.</td>
			<td width="15%" style="font-size:14px;" class="thinborderTOPLEFTBOTTOM">AMOUNT</td>
		</tr>
		<tr>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
		  <td class="thinborderRIGHT" align="center"><%=WI.getStrValue(vGroupInfo.elementAt(1), "&nbsp;")%></td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td>&nbsp;P <%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%></td>
	  </tr>
		<tr>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td class="thinborderRIGHT">&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
		  <td class="thinborderBOTTOMRIGHT">&nbsp;</td>
		  <td class="thinborderBOTTOMRIGHT">&nbsp;</td>
		  <td class="thinborderBOTTOMRIGHT">&nbsp;</td>
		  <td class="thinborderBOTTOM">&nbsp;</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td class="thinborderBOTTOMRIGHT" align="right">TOTAL P</td>
		  <td class="thinborderBOTTOM">&nbsp;<%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%></td>
	  </tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td width="50%" valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td>Cash Voucher No.  <u><%=WI.fillTextValue("jv_number")%></u></td>
				</tr>
				<tr>
					<td>Bank ____________________ Check No. ________________ </td>
				</tr>
				<tr>
				  <td>Date _____________________________________ </td>
			  </tr>
				<tr>
				  <td>Prepared By: ______________________________ </td>
			  </tr>
				<tr>
				  <td>Entered By: _______________________________ </td>
			  </tr>
				<tr>
				  <td>Certified By: _______________________________ </td>
			  </tr>
				<tr>
				  <td>Approved By: ______________________________ </td>
			  </tr>
			</table>
		</td>
		<td valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td> Received from Philippine College of  Science and Technology the sum of Pesos ________________</td>
				</tr>
				<tr>
				  <td>_________________________ (P _________________)</td>
			  </tr>
				<tr>
				  <td>_____________________________________________</td>
			  </tr>
				<tr>
				  <td>Sgd.</td>
			  </tr>
				<tr>
				  <td class="thinborderBOTTOM">&nbsp;</td>
			  </tr>
				<tr>
				  <td align="center">Payee</td>
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