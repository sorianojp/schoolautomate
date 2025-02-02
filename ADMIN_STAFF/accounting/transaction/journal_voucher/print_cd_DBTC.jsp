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
      <td width="11%" align="center">&nbsp;</td>
      <td width="52%" height="25" align="center">
	  <div align="center"><font size="3">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
		
		<br><br>
		<font style="font-size:16px; font-weight:bold">CHECK VOUCHER<br>&nbsp;</font>
	  </div>	
	  </td>
      <td width="37%" valign="top"><font size="1">
	  	Voucher Number : <%=WI.fillTextValue("jv_number")%><br>
		Voucher Date : <%=vJVInfo.elementAt(1)%><br>
		Date & time Printed : <%=WI.getTodaysDateTime()%> <br>
		<%if(strCheckNo != null) {%>
		Check #: <%=strCheckNo%><br>
		Check Amount: <%=strCheckAmount%><br>
		Bank: <%=strBankCode%>
		<%}%>
	  </font>		</td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td> 
      <td height="25" colspan="3" style="font-size:12px; font-weight:bold">Pay to: <u><%=vJVInfo.elementAt(5)%></u></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;&nbsp;</td> 
      <td height="25" colspan="3" style="font-size:12px; font-weight:bold">
	  	Amount :
		 <%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vJVInfo.elementAt(6)),"Pesos","Centavos")%>
		(<%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%>)</td>
    </tr>
      <td style="font-size:13px; font-weight:bold" width="3%">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold" width="67%" valign="bottom">DEBIT</td>
      <td style="font-size:13px; font-weight:bold" width="15%">&nbsp;</td>
      <td style="font-size:12px;" width="15%" align="right">Amount&nbsp;&nbsp;</td>
    </tr>
<%boolean bolPrintGroup = false;
String strBGRed = null;
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") && vJVInfo.elementAt(3).equals("0"))//coloring is for jv only , for cd - none.
		strBGRed = " bgcolor=red";
	else	
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = true;%>
	<%for(int p = 0; p < vJVDetail.size(); p += 5) {
		if(!vJVDetail.elementAt(p + 3).equals(strTemp) )
			continue;
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
			continue;%>
    <tr<%=strBGRed%>>
      <td style="font-size:12px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>. 
      <%}%></td>
      <td height="20" style="font-size:12px;" valign="top"><%=vJVDetail.elementAt(p + 1)%></td>
      <td style="font-size:12px;" valign="top"><%=vJVDetail.elementAt(p + 0)%></td>
      <td style="font-size:12px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;</td>
    </tr>
	<%vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p -= 5;}//end of while loop. 
}//end of for loop to print all debit.%>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold" valign="bottom">CREDIT</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") && vJVInfo.elementAt(3).equals("0") )//coloring is for jv only , for cd - none.
		strBGRed = " bgcolor=red";
	else	
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = true;%>
	<%while(vJVDetail.size() > 0) {
		if(!vJVDetail.elementAt(3).equals(strTemp))//if not belong to same group.. break.
			break;%>
    <tr<%=strBGRed%>>
      <td style="font-size:12px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.<%}%></td>
      <td height="20" style="font-size:12px;" valign="top"><%=vJVDetail.elementAt(1)%></td>
      <td style="font-size:12px;" valign="top"><%=vJVDetail.elementAt(0)%></td>
      <td style="font-size:12px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;</td>
    </tr>
	<%
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);}//end of while loop. 
}//end of for loop to print all debit.%>

    <tr>
      <td height="10" colspan="4" style="font-size:13px; font-weight:bold">EXPLANATION</td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){%>
    <tr>
      <td style="font-size:12px;" valign="top"><%=vGroupInfo.elementAt(i)%>.</td>
      <td height="25" colspan="3" valign="top"><%=WI.getStrValue(vGroupInfo.elementAt(i + 1))%></td>
    </tr>
<%}%>

    <tr>
      <td height="10" colspan="4">
	  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr>
			  <td align="center" valign="bottom">&nbsp;</td>
			  <td>&nbsp;</td>
			  <td valign="top" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="top" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
		  </tr>
			<tr>
				<td width="25%" height="35" align="center" valign="bottom"><%=(String)request.getSession(false).getAttribute("first_name")%></td>
				<td width="25%">&nbsp;</td>
			  <td width="25%" valign="top" align="center" style="font-size:10px; font-weight:bold">APPROVED FOR PAYMENT  <BR>
			    <BR>
			  <%
				strTemp = CommonUtil.getNameForAMemberType(dbOP,"Administrator",7);
				if(strTemp == null)
					strTemp = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
				else
					strTemp = strTemp.toUpperCase();
				%><%=strTemp%>			  </td>
				<td width="25%" valign="top" align="center" style="font-size:10px; font-weight:bold">CHECK RECEIVED BY <BR><BR>
				&nbsp;</td>
			</tr>
			<tr>
			  <td height="15" valign="bottom" align="center" style="font-size:10px; font-weight:bold">PREPARED BY</td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">CHECKED BY </td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">ADMINISTRATOR</td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">SIGNATURE ABOVE PRINTED NAME </td>
		  </tr>
		</table>	  </td>
    </tr>
  </table>
	
</body>
</html>
<%
dbOP.cleanUP();
%>