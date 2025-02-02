<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">

body{
	font-family: Arial;
	font-size: 11px;
}

td{
	font-family: Arial;
	font-size: 11px;
}

TD.thinborderTOPBOTTOMDashed {	
	font-family: Arial;
	font-size: 11px;
}

.thinborderTOPBOTTOMSolidDashed {
	border-top: solid 1px #000000;
	border-bottom: dashed 1px #000000;
	font-family: Arial;
	font-size: 11px;
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
<body onLoad="window.print();" topmargin="0" bottommargin="0" leftmargin="40px" rightmargin="40px">

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="20%" rowspan="3" align="right"><img src="../../../../images/logo/VMA_BACOLOD.gif" border="0" height="70" width="70"></td>
		<td height="20" colspan="2" align="center"><strong style="font-size:12px;">ASIAN MARI-TECH DEVELOPMENT, INC.</strong></td>	    
	    <td width="20%">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="2" align="center"><strong style="font-size:11px;">Sum-ag, Bacolod City</strong></td>
	    
	    <td height="20" align="center">&nbsp;</td>
	</tr>
	<tr>
	    <td height="20" colspan="2" align="center"><strong style="font-size:14px;">CHECK VOUCHER –VMA GLOBAL COLLEGE</strong></td>
        <td height="20" align="center">&nbsp;</td>
	</tr>
	<tr>
	    <td height="30" colspan="2" valign="bottom"><strong>CHECK Voucher No: <%=WI.fillTextValue("jv_number")%></strong></td>
        <td height="30" colspan="2" valign="bottom"><strong>Date: <%=vJVInfo.elementAt(1)%></strong></td>
    </tr>
	<tr>
	    <td height="10" valign="bottom" colspan="4"></td>
    </tr>
	<tr><td height="4" valign="middle" colspan="4"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>
	<tr><td height="4" valign="middle" colspan="4"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>
	<tr><td height="10" valign="bottom" colspan="4"></td></tr>
	<tr><td height="20" colspan="2" valign="middle"><strong>PAY TO:</strong> <%=vJVInfo.elementAt(5)%></td>
	    <td height="20" colspan="2" valign="middle">  P <%=CommonUtil.formatFloat(dChkAmt, true)%></td>
    </tr>
	<tr>
	<%
	strTemp = "select PAYEE_ADDR  from AC_JV where jv_number='"+WI.fillTextValue("jv_number")+"'";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	%>
	    <td height="20" valign="middle" colspan="4"><strong>ADDRESS:</strong> <%=WI.getStrValue(strTemp)%></td>
    </tr>
	<tr>
	    <td height="20" valign="middle" colspan="4"><strong>The sum of:</strong>
		<%=new ConversionTable().convertAmoutToFigure(dChkAmt,"Pesos","Centavos")%>		</td>
    </tr>
	<tr>
	    <td height="15" valign="middle" colspan="4"></td>
    </tr>
	<tr>
	    <td height="20" valign="middle" colspan="4"><strong>PARTICULARS/REMARKS:</strong>
		<%for(int i =0; i < vGroupInfo.size(); i += 4){%>
				<%=WI.getStrValue(vGroupInfo.elementAt(i + 1)) + "<br>"%>
		<%}%>		</td>
    </tr>
	<tr>
	    <td height="15" valign="middle" colspan="4"></td>
    </tr>
	<tr>
	    <td height="20" valign="middle"><strong>Reference : CV</strong></td>
        <td width="37%" height="20" valign="middle">&nbsp;</td>
        <td height="20" colspan="2" valign="middle"><strong>No.: <%=WI.fillTextValue("jv_number")%></strong></td>
    </tr>
	<tr>
	    <td height="20" valign="middle" colspan="4">&nbsp;</td>
    </tr>
</table>

<table width="93%" border="0" cellpadding="0" cellspacing="0" align="center">
	<tr><td height="4" valign="middle" colspan="5"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>
	<tr><td height="4" valign="middle" colspan="5"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>
	<tr style="font-weight:bold;">
		<td width="13%" height="20" class="thinborderTOPBOTTOMDashed">Date</td>
		<td width="17%" class="thinborderTOPBOTTOMDashed">Check #</td>
		<td width="40%" class="thinborderTOPBOTTOMDashed">Account Description</td>
		<td width="15%" class="thinborderTOPBOTTOMDashed">Debit Amount</td>
		<td width="15%" class="thinborderTOPBOTTOMDashed">Credit Amount</td>
	</tr>
	<tr><td height="4" valign="middle" colspan="5"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>
	<tr><td height="4" valign="middle" colspan="5"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>
	
<%
	double dDebitTotal = 0d;
	double dCreditTotal = 0d;
	for(int p = 0; p < vJVDetail.size(); p += 5) {//System.out.println("P - "+vJVDetail.elementAt(p + 4));
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
			continue;		
	%>        
        <tr>
          <td height="18"><%=WI.getStrValue(strCheckDate)%></td>
          <td><%=WI.getStrValue(strCheckNo)%></td>
          <td><%=vJVDetail.elementAt(p + 1)%></td>
		  <%
		  try{
		  	dDebitTotal += Double.parseDouble(ConversionTable.replaceString((String)vJVDetail.elementAt(p + 2), ",", ""));
		  }catch(Exception e){}
		  %>
		  <td><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%></td>
		  <td>&nbsp;</td>
        </tr>
	<%
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p = p - 5;
	}%>
	<%while(vJVDetail.size() > 0) {%>
        <tr>
          <td></td>
          <td height="18">&nbsp;</td>
          <td><%=vJVDetail.elementAt(1)%></td>
		  <td>&nbsp;</td>
		  <%
		  try{
		  	dCreditTotal += Double.parseDouble(ConversionTable.replaceString((String)vJVDetail.elementAt(2), ",", ""));
		  }catch(Exception e){}
		  %>
		  <td><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%></td>
        </tr>
        
 <%vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
 }%>
 		<tr style="font-weight:bold;">
           
            <td height="22" align="center" valign="bottom">&nbsp;</td>
			 <td align="center" valign="bottom">TOTAL</td>
            <td align="center" valign="bottom">&nbsp;</td>
            <td valign="bottom"><div class="thinborderTOPBOTTOMSolidDashed" style="width:80%;"><br><%=CommonUtil.formatFloat(dDebitTotal, true)%></div></td>
			<td valign="bottom"><div class="thinborderTOPBOTTOMSolidDashed" style="width:80%;"><br><%=CommonUtil.formatFloat(dCreditTotal, true)%></div></td>
        </tr>
 		<tr style="font-weight:bold;">
 		    <td height="4" colspan="3"></td>
 		    <td valign="bottom"><div style="border-bottom:dashed 1px #000000;width:80%;"></div></td>
 		    <td valign="bottom"><div style="border-bottom:dashed 1px #000000;width:80%;"></div></td>
    </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="15"></td></tr>
	<tr><td height="4" valign="middle"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>
	<tr><td height="4" valign="middle"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height="18" width="16%"><strong>Prepared by:</strong></td>
		<td width="23%"><strong>Checked/ Verified by:</strong></td>
		<td width="15%"><strong>Approved by:</strong></td>
		<td width="46%">Received from AMTDI the amount stated above by:</td>
	</tr>
	<tr style="font-weight:bold;">
	    <td valign="bottom" height="30"><strong>EBL</strong></td>
	    <td valign="bottom"><strong>ARSG</strong></td>
	    <td valign="bottom"><strong>FOB CNO MD/JNO</strong></td>
	    <td valign="bottom">___________________Date_______________</td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="15"></td></tr>
	<tr><td height="4" valign="middle"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>
	<tr><td height="4" valign="middle"><div style="border-bottom:dashed 1px #000000;"></div></td></tr>	
</table>


        
</body>
</html>
<%
dbOP.cleanUP();
%>