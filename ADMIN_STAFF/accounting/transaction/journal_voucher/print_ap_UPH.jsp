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

double dPayableAmt = 0d;
String strSupplierName = null;

int iVoucherType = 0;//0 = jv, 1 = cd, 2 = petty cash.

Vector vJVDetail  = null; //to show detail at bottom of page. 
Vector vJVInfo    = null;
Vector vGroupInfo = null;

String strItemDetail = null;

if(strJVNumber.length() > 0) {
	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);
	if(vJVDetail == null)
		strErrMsg = jvCD.getErrMsg();
	else {
	    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE, [2] = jv_type, [3] = is_cd,[4] lock_date, [5] = payee name.
	    vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    	vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
	
		iVoucherType = Integer.parseInt((String)vJVInfo.elementAt(2));
		
		if(vJVInfo.elementAt(2).equals("12"))
			bolIsAPVoucher = true;
		String strSQLQuery = "select payee_name, amount_payable from AC_AP_BASIC_INFO "+
							"join PUR_AP_PROCESSING on (PUR_AP_PROCESSING.AP_INFO_INDEX = AC_AP_BASIC_INFO.AP_INFO_INDEX) "+
							"where JV_REF ="+vJVInfo.elementAt(0);
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strSupplierName = rs.getString(1);
			dPayableAmt     = rs.getDouble(2);
		}
		rs.close();
		
		//find item details.. 
		strSQLQuery = "select item_detail from PUR_AP_PROCESSING where jv_ref = "+vJVInfo.elementAt(0);
		 rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strItemDetail = rs.getString(1);
		}
		rs.close();
	}
}
else 
	strErrMsg = "JV Number not found.";
	
if(iVoucherType != 12) 
	strErrMsg = "Only AP voucher printing is allowed.";
	
double dDebit = 0d;
double dCredit = 0d;	
	
if(strErrMsg != null) {
dbOP.cleanUP();
%>
<p align="center" style="font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold;"><%=strErrMsg%></p>
<%return;}%>
<body onLoad="window.print();">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="4" align="center">
			<div align="center"><font size="3" style="font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><font size="5"><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br> 
		TIN: 001-749-801-000 
          <br>  <br>  
    <font size="3"><strong>ACCOUNTS PAYABLE VOUCHER</strong></font></font></font></div>		</td>
	</tr>
	
	<tr>
		<td height="22" width="9%">&nbsp;</td>
		<td width="68%">&nbsp;</td>
		<td width="9%"><strong><div style="padding-left:10px; border:solid 1px #000000; font-size:11px;" align="center">DATE</div></strong></td>
		<td style="padding-left:5px;"><div style="border-bottom:solid 1px #000000; font-size:11px;"><%=vJVInfo.elementAt(1)%></div></td>
	</tr>
	
	<tr>
		<td height="22" valign="middle"><strong><div style="padding-left:10px; border:solid 1px #000000; font-size:11px;">SUPPLIER</div></strong></td>
		<td style="padding-left:5px; padding-right:5px;"><div style="border-bottom:solid 1px #000000; font-size:11px;"><%=WI.getStrValue(strSupplierName,"&nbsp;")%></div></td>
		<td><strong><div style="padding-left:10px; border:solid 1px #000000; font-size:11px;" align="center">APV#</div></strong></td>
		<td style="padding-left:5px;"><div style="border-bottom:solid 1px #000000; font-size:11px;"><%=WI.fillTextValue("jv_number")%></div></td>
	</tr>
	<tr>
		<td height="22" valign="middle"><strong><div  style="padding-left:10px; border:solid 1px #000000; font-size:11px;">PESOS</div></strong></td>
		<td colspan="3" style="padding-left:5px; padding-right:5px; font-size:11px;"><div style="border-bottom:solid 1px #000000;">
		<%=new ConversionTable().convertAmoutToFigure(dPayableAmt,"Pesos","Centavos")%></div></td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td>&nbsp;</td></tr>
	<tr>
		<td valign="top" height="660px">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td class="thinborderALL" height="20" width="82%" align="center"><strong>PARTICULARS</strong></td>
					<td class="thinborderTOPBOTTOMRIGHT" width="18%" align="center"><strong>AMOUNT</strong></td>
				</tr>
				<tr><td colspan="2" height="10"></td></tr>
				<tr>
					<td height="40" valign="top">
						<%=strItemDetail%>
					</td>
					<td valign="top" align="right"><strong><font size="2">**<%=CommonUtil.formatFloat(dPayableAmt, true)%>**</font></strong></td>
				</tr>	
			</table>
			
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="15%" height="20" align="center" class="thinborderALL"><strong>ACCOUNT</strong></td>
					<td width="49%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>ACCOUNT TITLE</strong></td>
					<td width="18%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>DEBIT</strong></td>
					<td width="18%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>CREDIT</strong></td>		
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
					<td style="font-size:10px;">&nbsp;<%=vJVDetail.elementAt(q + 0)%></td>
					<td class="" style="font-size:10px;">
						<%if(bolIsCredit){%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%><%=vJVDetail.elementAt(q + 1)%></td>
					<td class="" align="right" style="font-size:10px;"><%if(!bolIsCredit){  dDebit += Double.parseDouble((String)vJVDetail.elementAt(q + 2));%>
						<%=CommonUtil.formatFloat((String)vJVDetail.elementAt(q + 2), true)%><%}%>&nbsp;&nbsp;</td>
					<td class="" align="right" style="font-size:10px;"><%if(bolIsCredit){ dCredit += Double.parseDouble((String)vJVDetail.elementAt(q + 2));%>
						<%=CommonUtil.formatFloat((String)vJVDetail.elementAt(q + 2), true)%><%}%>&nbsp;&nbsp;</td>
				</tr>
			<%
			vJVDetail.removeElementAt(q);vJVDetail.removeElementAt(q);vJVDetail.removeElementAt(q);
			vJVDetail.removeElementAt(q);vJVDetail.removeElementAt(q);
			q = q - 5;
		   }//System.out.println(vJVDetail);%>


	<%}%>
			 
			 <tr>
			 	<td>&nbsp;</td>
				<td align="right" style="padding-right:30px;font-size:10px;">GRAND TOTAL ...</td>
				<td align="right" style="font-size:10px; font-weight:bold;">
					<div style="border-bottom:solid 1px #000000; border-top:solid 1px #000000;"><%=CommonUtil.formatFloat(dDebit, true)%>&nbsp;&nbsp;</div></td>
				<td align="right" style="font-size:10px; font-weight:bold; padding-left:5px;">
					<div style="border-bottom:solid 1px #000000; border-top:solid 1px #000000;"><%=CommonUtil.formatFloat(dCredit, true)%>&nbsp;&nbsp;</div></td>
			 </tr>				
			</table>

		</td>
	</tr>
</table>



<table width="100%" border="0" cellpadding="0" cellspacing="0">	
	<tr><td colspan="6" height="10"><div style="border-bottom:solid 3px #000000;"></div></td></tr>
</table>





<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="25%" height="20" valign="bottom">Prepared by:</td>
		<td width="25%" valign="bottom">Reviewed by:</td>
		<td width="25%" valign="bottom">Approved by:</td>
		<td width="25%" valign="bottom">&nbsp;</td>
	</tr>
	<tr>
		<td height="40" style="padding-right:20px;" valign="bottom"><div style="border-bottom:solid 2px #000000;">&nbsp;
		<%=(String)request.getSession(false).getAttribute("first_name")%></div></td>
		<td height="40" style="padding-right:20px;" valign="bottom"><div style="border-bottom:solid 2px #000000;">&nbsp;</div></td>
		<td height="40" style="padding-right:20px;" valign="bottom"><div style="border-bottom:solid 2px #000000;">&nbsp;</div></td>
		<td height="40" valign="bottom">&nbsp;</td>
	</tr>
	<tr valign="top" align="center">
		<td width="25%">&nbsp;</td>
		<td style="font-size:9px;">Chief Accountant </td>
		<td style="font-size:9px;">Chief Finance Officer </td>
		<td>&nbsp;</td>
	</tr>
</table>

        
<table width="100%">
<tr>
	<td width="50%" valign="bottom"><strong><font size="+1"><!--APV#--><%=WI.fillTextValue("jv_number")%></font></strong></td>
	<td align="right" valign="bottom" style="font-size:11px;"><%=WI.formatDate((String)vJVInfo.elementAt(1), 11)%></td>
</tr>
</table>

























</body>
</html>
<%
dbOP.cleanUP();
%>