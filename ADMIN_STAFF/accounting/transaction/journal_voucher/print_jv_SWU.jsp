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

boolean bolIsAPVoucher = false;
int iVoucherType = 0;//0 = jv, 1 = cd, 2 = petty cash.

Vector vJVDetail  = null; //to show detail at bottom of page. 
Vector vJVInfo    = null;
Vector vGroupInfo = null;

double dChkAmt = 0d;

if(strJVNumber.length() > 0) {
	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);
	if(vJVDetail == null)
		strErrMsg = jvCD.getErrMsg();
	else {
	    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE, [2] = jv_type, [3] = is_cd,[4] lock_date, [5] = payee name.
	    vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    	vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
	
		iVoucherType = Integer.parseInt((String)vJVInfo.elementAt(3));
		
		if(vJVInfo.elementAt(2).equals("12")) {
			bolIsAPVoucher = true;
			String strSQLQuery = "select SUM(amount) from AC_JV_DC where JV_INDEX = "+(String)vJVInfo.elementAt(0)+" and IS_DEBIT = 0";
			java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) 
				dChkAmt = rs.getDouble(1);
			rs.close(); 
		}
		
		
		
	}
}
else 
	strErrMsg = "JV Number not found.";
	
if(iVoucherType != 0) 
	strErrMsg = "Only JV printing is allowed.";
if(strErrMsg != null) {
dbOP.cleanUP();
%>
<p align="center" style="font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold;"><%=strErrMsg%></p>
<%return;}%>
<body onLoad="window.print();">

<table width="100%" border="0">
  <tr>
    <td width="15%">&nbsp;</td>
    <td width="62%"><div align="center"><font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font>
		<br>  
          <br>  
    <font size="2"><strong>ACCOUNTING AND FINANCE</strong></font></div></td>
    <td width="23%" style="font-size:9px;" valign="bottom">
		Voucher No.: <u><b><%=WI.fillTextValue("jv_number")%></b></u><br>
		Voucher Date: <u><b><%=vJVInfo.elementAt(1)%></b></u>
		
	</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%if(bolIsAPVoucher){%>
	  <tr>
		<td colspan="3"><strong>Pay To: <%=vJVInfo.elementAt(5)%></strong></td>
	  </tr>
	  <tr>
		<td height="20" colspan="3" valign="top"><strong>Amount: 
		<%=new ConversionTable().convertAmoutToFigure(dChkAmt,"Pesos","Centavos")%>
			(<%=CommonUtil.formatFloat(dChkAmt, true)%>)
		
		</strong></td>
	  </tr>
<%}%>
        <tr>
          <td height="25" colspan="3" class="thinborderALL"><div align="center"><b><font size="2">
		  <%if(bolIsAPVoucher){%>AP <%}else{%>JOURNAL <%}%>VOUCHER </font></b></div></td>
        </tr>
        <tr>
          <td width="70%" height="25" class="thinborderBOTTOMLEFT"><div align="center"><b>PARTICULAR</b></div></td>
          <td width="15%" height="25" class="thinborderBOTTOMLEFT"><div align="center"><b>DEBIT</b></div></td>
          <td width="15%" height="20" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><b>CREDIT</b></div></td>
        </tr>
<%
int iTotalLine   = 25;
int iLinePrinted = 0;

boolean bolIsCredit = false;
boolean bolAddLine  = false;

for(int i =0; i < vGroupInfo.size(); i += 4){
bolAddLine  = true;
	strTemp = (String)vGroupInfo.elementAt(i);//group number;%>
			<%for(int q = 0; q < vJVDetail.size(); q += 5) {
				if(!vJVDetail.elementAt(q + 3).equals(strTemp)) {
					continue;
				}
				if(vJVDetail.elementAt(q + 4).equals("0"))//if not debit or if not belong to same group.. break.	
					bolIsCredit = true;
				else	
					bolIsCredit = false;

				++iLinePrinted;
					%>
				<tr>
					<td class="thinborderLEFT"><%if(bolIsCredit){if(bolAddLine){%><br><%bolAddLine = false;}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%><%=vJVDetail.elementAt(q + 1)%></td>
					<td class="thinborderLEFT" align="right"><%if(!bolIsCredit){%><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(q + 2), true)%><%}%>&nbsp;</td>
					<td class="thinborderLEFTRIGHT" align="right"><%if(bolIsCredit){%><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(q + 2), true)%><%}%>&nbsp;</td>
				</tr>
			<%
			vJVDetail.removeElementAt(q);vJVDetail.removeElementAt(q);vJVDetail.removeElementAt(q);
			vJVDetail.removeElementAt(q);vJVDetail.removeElementAt(q);
			q = q - 5;
		   }//System.out.println(vJVDetail);%>
				<tr>
					<td class="thinborderLEFT"><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(vGroupInfo.elementAt(i + 1))%><br>&nbsp;</td>
					<td class="thinborderLEFT" align="right">&nbsp;</td>
					<td class="thinborderLEFTRIGHT" align="right">&nbsp;</td>
				</tr>


	<%}
 while (iTotalLine > iLinePrinted){++iLinePrinted;%>
        <tr>
          <td class="thinborderLEFT">&nbsp;</td>
          <td height="25" class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFTRIGHT">&nbsp;</td>
        </tr>
 <%}%>
        <tr>
          <td class="thinborderTOP">&nbsp;</td>
          <td class="thinborderTOP">&nbsp;</td>
          <td class="thinborderTOP">&nbsp;</td>
        </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td width="32%" class="thinborderNONE">Prepared by: </td>
          <td width="2%" class="thinborderNONE">&nbsp;</td>
          <td width="32%" class="thinborderNONE">Verified By:</td>
          <td width="2%" class="thinborderNONE">&nbsp;</td>
          <td width="32%" class="thinborderNONE">Approved By:</td>
  </tr>
        <tr valign="bottom">
          <td class="thinborderBOTTOM" align="center"><%=(String)request.getSession(false).getAttribute("first_name")%></td>
          <td align="center">&nbsp;</td>
          <td height="25" class="thinborderBOTTOM">&nbsp;</td>
          <td>&nbsp;</td>
          <td class="thinborderBOTTOM">&nbsp;</td>
  </tr>
        <tr align="center" valign="top">
          <td class="thinborderNONE">Acctg. Asst.</td>
          <td class="thinborderNONE">&nbsp;</td>
          <td class="thinborderNONE">Accountant</td>
          <td class="thinborderNONE">&nbsp;</td>
          <td class="thinborderNONE">President </td>
        </tr>
</table>        
<!--
<table width="100%">
<tr>
	<td width="50%">&nbsp;</td>
	<td align="right" valign="bottom" style="font-size:11px;"><%=WI.formatDate((String)vJVInfo.elementAt(1), 11)%></td>
</tr>
</table>
-->
</body>
</html>
<%
dbOP.cleanUP();
%>