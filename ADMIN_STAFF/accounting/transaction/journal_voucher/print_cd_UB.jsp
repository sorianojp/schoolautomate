<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">

body{
	font-family: "Times New Roman";
	font-size: 12px;
}

td{
	font-family: "Times New Roman";
	font-size: 12px;
}

TD.thinborderTOPBOTTOMDashed {	
	font-family: "Times New Roman";
	font-size: 12px;
}

.thinborderTOPBOTTOMSolidDashed {
	border-top: solid 1px #000000;
	border-bottom: dashed 1px #000000;
	font-family: "Times New Roman";
	font-size: 12px;
}
</style>
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
		
	}
}
else 
	strErrMsg = "Voucher Number not found.";
	
if(iVoucherType != 1) 
	strErrMsg = "Only CD printing is allowed.";

String strCheckNo = null;
String strCheckDate = null;	
if(vJVInfo != null) {
	strTemp = "select sum(amount) from ac_jv_dc where is_debit = 0 and jv_index = "+vJVInfo.elementAt(0)+
			" and exists (select * from AC_COA_BANKCODE where AC_COA_BANKCODE.coa_index = ac_jv_dc.coa_index and is_valid = 1) ";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	if(rs.next())
		dChkAmt = rs.getDouble(1);	
	rs.close();		
	
	
	strTemp = "select CHECK_NO, CHK_DATE from AC_CD_CHECK_DTL where cd_index ="+vJVInfo.elementAt( 0 );
	rs = dbOP.executeQuery(strTemp);
	if(rs.next()){
		strCheckNo = rs.getString(1);
		strCheckDate = ConversionTable.convertMMDDYYYY(rs.getDate(2));
	}rs.close();
}

if(strErrMsg != null) {
dbOP.cleanUP();
%>
<p align="center" style="font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold;"><%=strErrMsg%></p>
<%return;}%>
<body onLoad="window.print();" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="9%"><img src="../../../../images/logo/UB_BOHOL.gif" border="0" height="70" width="70"></td>
		<td width="57%"><strong style="font-size:18px;">CHECK VOUCHER</strong></td>
	    <td width="34%">
		<div style="border:solid 1px #000000; width:70%; height:60px;"><strong>NO.</strong> <br><br><div style="text-align:center;"><%=WI.fillTextValue("jv_number")%></div></div>		</td>
	</tr>
	<tr>
	    <td colspan="2" height="20"><strong>TRANSACTION DETAILS</strong></td>
	    <td><strong>Date : </strong><%=vJVInfo.elementAt(1)%></td>
    </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td valign="top" height="30" colspan="2" class="thinborder">
			<strong>Pay to</strong><br><label style="padding-left:30px;"><%=vJVInfo.elementAt(5)%></label>
		</td>
	</tr>
	<tr>
		<td valign="top" height="30" colspan="2" class="thinborder"><strong>The Amount of </strong><br>
		<label style="padding-left:30px;"><%=new ConversionTable().convertAmoutToFigure(dChkAmt,"Pesos","Centavos")%></label></td>
	</tr>
	<tr>
		<td valign="top" width="66%" height="30" class="thinborder"><strong>In Payment of </strong><br>
			<label style="padding-left:30px;"><%for(int i =0; i < vGroupInfo.size(); i += 4){%>
				<%=WI.getStrValue(vGroupInfo.elementAt(i + 1)) + "<br>"%>
		<%}%></label></td>
		<td valign="top" width="34%" class="thinborder"><strong>Amount </strong><br><%=CommonUtil.formatFloat(dChkAmt, true)%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="25"><strong>APPROVALS</strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td width="50%" height="50" valign="top" class="thinborder">1. Budget:
		<div style="text-align:center;"><br><br><strong>ELVIE S. KUDEMUS</strong><br>Budget Officer</div>
		</td>
		<td width="50%" valign="top" class="thinborder">4. Approved:
		<div style="text-align:center;"><br><br>
		<strong>VISITATION R. CAGAS </strong><br>
		Cashier</div></td>
	</tr>
	<tr>
		<td valign="top" height="50" class="thinborder">2. Checked:
		    <div style="text-align:center;"><br><br><strong>MERLINDA V. MENDEZ</strong><br>Accountant</div>
		</td>
		<td valign="top" class="thinborder">5. Approved:
		    <div style="text-align:center;"><br><br><strong>Dr. CRISTETA B. TIROL</strong><br>Vice President for Finance</div>
		</td>
	</tr>
	<tr>
		<td valign="top" height="50" class="thinborder">3. Audited by:
		    <div style="text-align:center;"><br><br><strong>ROGEMER G. OJENDRAS</strong><br>Auditor</div>
		</td>
		<td valign="top" class="thinborder">3. Approved:
		    <div style="text-align:center;"><br><br><strong>ATTY. NUEVAS T. MONTES</strong><br>Acting President</div>
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="25"><strong>CHECK DETAILS </strong></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td width="21%" rowspan="2" valign="top" class="thinborder"><strong>Check No.</strong><br>
	    <br><br><div style="text-align:center;"><%=WI.getStrValue(strCheckNo)%></div></td>
		<td class="thinborder" valign="top" height="40" width="79%"><strong>Received the amount of</strong><br>
	    <%=new ConversionTable().convertAmoutToFigure(dChkAmt,"Pesos","Centavos")%></td>
	</tr>
	<tr>
		<td valign="top" class="thinborder">
			<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td height="20" width="23%" align="center" class="thinborderBOTTOM">( &nbsp; <%=CommonUtil.formatFloat(dChkAmt, true)%> &nbsp;)</td>
					<td width="77%">&nbsp; &nbsp;in full payment of the account</td>
				</tr>
				<tr>
				    <td height="20" align="center" class="thinborderBOTTOM"><%=WI.getStrValue(strCheckDate)%></td>
				    <td valign="bottom" align="right">
					<div style="border-bottom:solid 1px #000000; width:70%; text-align:center"><%=vJVInfo.elementAt(5)%></div>					</td>
			    </tr>
				<tr>
				    <td valign="top" height="20" align="center"><strong>Date</strong></td>
				    <td valign="top" align="right"><div style="width:70%; text-align:center"><strong>Printed Name & Signature</strong></div></td>
			    </tr>
			</table>
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="25"><strong>ACCOUNTING USE ONLY </strong></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
        
        <tr>
          <td height="17" class="thinborder"><div align="center"><b>Account Title</b></div></td>
          <td width="15%" class="thinborder"><div align="center"><b>Charge Code</b></div></td>
          <td width="15%" class="thinborder"><div align="center"><b>Debit</b></div></td>
          <td width="15%" class="thinborder"><div align="center"><b>Credit</b></div></td>
        </tr>
<%
int iTotalLine   = 6;
int iLinePrinted = 0;
	for(int p = 0; p < vJVDetail.size(); p += 5) {//System.out.println("P - "+vJVDetail.elementAt(p + 4));
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
			continue;
		++iLinePrinted;
	%>
        <tr>
          <td height="17" class="thinborder"><%=vJVDetail.elementAt(p + 1)%></td>
          <td class="thinborder" align="center"><%=vJVDetail.elementAt(p + 0)%></td>
          <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;&nbsp;</div></td>
          <td class="thinborder">&nbsp;</td>
        </tr>
	<%
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p = p - 5;
	}%>
        
 <%while(vJVDetail.size() > 0) {++iLinePrinted;%>
        <tr>
          <td class="thinborder" style="padding-left:30px;"><%=vJVDetail.elementAt(1)%></td>
          <td class="thinborder" align="center"><%=vJVDetail.elementAt(0)%></td>
          <td height="17" class="thinborder">&nbsp;</td>
          <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;&nbsp;</div></td>
        </tr>
 <%vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
 }
 while (iTotalLine > iLinePrinted){++iLinePrinted;%>
        <tr>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">&nbsp;</td>
          <td height="17" class="thinborder">&nbsp;</td>
          <td class="thinborder">&nbsp;</td>
        </tr>
 <%}%>
</table>


        
</body>
</html>
<%
dbOP.cleanUP();
%>