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
if(vJVInfo != null) {
	strTemp = "select sum(amount) from ac_jv_dc where is_debit = 0 and jv_index = "+vJVInfo.elementAt(0)+
			" and exists (select * from AC_COA_BANKCODE where AC_COA_BANKCODE.coa_index = ac_jv_dc.coa_index and is_valid = 1) ";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	if(rs.next())
		dChkAmt = rs.getDouble(1);	
	rs.close();		
	
	
	strTemp = "select check_no from AC_CD_CHECK_DTL where cd_index = "+vJVInfo.elementAt(0);
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		if(strCheckNo == null)
			strCheckNo = rs.getString(1);
		else
			strCheckNo +=  "," +  rs.getString(1);
	}rs.close();
}


/*iLineCapacity = 40;
int iNoOfPages = vJVDetail.size() /(5 * 40) + 1;
if(vJVDetail.size() % (5 * 40) > 0)
++iNoOfPages;
int iCurPg = 1; int iCurLine = 0;*/	
double dDebit = 0d;
double dCredit = 0d;

if(strErrMsg != null) {
dbOP.cleanUP();
%>
<p align="center" style="font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold;"><%=strErrMsg%></p>
<%return;}%>
<body onLoad="window.print();" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td colspan="4" align="center">
			<div align="center"><font size="3" style="font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><font size="5"><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br> 
		TIN: 001-749-801-000 
          <br>  <br>  
    <font size="3"><strong>CHECK VOUCHER</strong></font></font></font></div>
		</td>
	</tr>
	
	<tr>
		<td height="22" width="9%">&nbsp;</td>
		<td width="68%">&nbsp;</td>
		<td width="9%"><strong><div style="padding-left:10px; border:solid 1px #000000; font-size:11px;" align="center">DATE</div></strong></td>
		<td width="14%" style="padding-left:5px;"><div style="border-bottom:solid 1px #000000; font-size:11px;"><%=vJVInfo.elementAt(1)%></div></td>
	</tr>
	
	<tr>
		<td height="22" valign="middle"><strong><div style="padding-left:10px; border:solid 1px #000000; font-size:11px;">PAYEE</div></strong></td>
		<td style="padding-left:5px; padding-right:5px;"><div style="border-bottom:solid 1px #000000; font-size:11px;"><%=vJVInfo.elementAt(5)%></div></td>
		<td><strong><div style="padding-left:10px; border:solid 1px #000000; font-size:11px;" align="center">CV#</div></strong></td>
		<td style="padding-left:5px;"><div style="border-bottom:solid 1px #000000; font-size:11px;"><%=WI.fillTextValue("jv_number")%></div></td>
	</tr>
	<tr>
		<td height="22" valign="middle"><strong><div  style="padding-left:10px; border:solid 1px #000000; font-size:11px;">PESOS</div></strong></td>
		<td style="padding-left:5px; padding-right:5px; font-size:11px;" colspan="3"><div style="border-bottom:solid 1px #000000;">
		<%=new ConversionTable().convertAmoutToFigure(dChkAmt,"Pesos","Centavos")%></div></td>
		<!--
		<td><strong><div style="padding-left:10px; border:solid 1px #000000; font-size:11px;" align="center">X-REFER</div></strong></td>
		
		<td style="padding-left:5px;"><div style="border-bottom:solid 1px #000000; font-size:11px;"><%=WI.getStrValue(strCheckNo,"&nbsp;")%></div></td>
		-->
	</tr>
</table>

<table width="101%" border="0" cellpadding="0" cellspacing="0">
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
						<%for(int i =0; i < vGroupInfo.size(); i += 4){%>
								<%=WI.getStrValue(vGroupInfo.elementAt(i + 1)) + "<br>"%>
						<%}%>
					</td>
					<td valign="top" align="right"><strong><font size="2">**<%=CommonUtil.formatFloat(dChkAmt, true)%>**</font></strong></td>
				</tr>	
			</table>
			
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="21%" height="20" align="center" class="thinborderALL"><strong>ACCOUNT</strong></td>
					<td width="49%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>ACCOUNT TITLE</strong></td>
					<td width="15%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>DEBIT</strong></td>
					<td width="15%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>CREDIT</strong></td>		
				</tr>
				
				
				<%
			/*
			iLineCapacity = 40;
			int iNoOfPages = vJVDetail.size() /(5 * 40) + 1;
			if(vJVDetail.size() % (5 * 40) > 0)
				++iNoOfPages;
			int iCurPg = 1; int iCurLine = 0;	*/
				
			
				for(int p = 0; p < vJVDetail.size(); p += 5) {//System.out.println("P - "+vJVDetail.elementAt(p + 4));
					if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
						continue;	
						
					dDebit += Double.parseDouble((String)vJVDetail.elementAt(p + 2));			
				%>
					<tr>
					  <td style="font-size:10px;">&nbsp;<%=vJVDetail.elementAt(p + 0)%></td>
					  <td class="" style="font-size:10px;"><%=vJVDetail.elementAt(p + 1)%></td>
					  <td class="" style="font-size:10px;">
					  	<div align="right"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;&nbsp;</div></td>
					  <td class="" style="font-size:10px;">&nbsp;</td>
					</tr>
				<%
				vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
				p = p - 5;
				}%>
					
			 <%while(vJVDetail.size() > 0) {
			 	dCredit += Double.parseDouble((String)vJVDetail.elementAt(2));
			 %>
					<tr>
					  <td style="font-size:10px;">&nbsp;<%=vJVDetail.elementAt(0)%></td>
					  <td style="font-size:10px;" class="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=vJVDetail.elementAt(1)%></td>
					  <td>&nbsp;</td>
					  <td class="" style="font-size:10px;"><div align="right"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;&nbsp;</div></td>
					</tr>
			 <%vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
			 }%>	
			 
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
	<tr>
		<td width="22%" height="20" valign="bottom"><strong>CHECK SIGNED BY:</strong></td>
		<td width="20%" class="thinborderBOTTOM">&nbsp;</td>
		<td width="4%">&nbsp;</td>
		<td width="26%" class="thinborderBOTTOM">&nbsp;</td>
		<td width="28%">&nbsp;</td>
	</tr>
	<tr><td colspan="6" height="10"><div style="border-bottom:solid 3px #000000;"></div></td></tr>
</table>





<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="25%" height="20" valign="bottom">Prepared by:</td>
		<td width="25%" valign="bottom">Reviewed by:</td>
		<td width="25%" valign="bottom">Approved by:</td>
		<td width="25%" valign="bottom">Received by/date:</td>
	</tr>
	<tr>
		<td height="40" style="padding-right:20px;" valign="bottom"><div style="border-bottom:solid 2px #000000;">&nbsp;
		<%=(String)request.getSession(false).getAttribute("first_name")%></div></td>
		<td height="40" style="padding-right:20px;" valign="bottom"><div style="border-bottom:solid 2px #000000;">&nbsp;</div></td>
		<td height="40" style="padding-right:20px;" valign="bottom"><div style="border-bottom:solid 2px #000000;">&nbsp;</div></td>
		<td height="40" valign="bottom"><div style="border-bottom:solid 2px #000000;">&nbsp;</div></td>
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
	<td width="50%" valign="bottom"><strong><font size="+1"><!--CV#--><%=WI.fillTextValue("jv_number")%></font></strong></td>
	<td align="right" valign="bottom" style="font-size:11px;"><%=WI.formatDate((String)vJVInfo.elementAt(1), 11)%></td>
</tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>