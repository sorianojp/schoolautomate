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


//strSchCode = "AUF";
	if(strSchCode.startsWith("CLDH") && iVoucherType < 2){
		dbOP.cleanUP();
		if(iVoucherType == 1)//Cash disbursement
			response.sendRedirect(response.encodeRedirectURL("./print_cd_CLDH.jsp?jv_number="+request.getParameter("jv_number")));
		if(iVoucherType == 0)//Journal Voucher.
			response.sendRedirect(response.encodeRedirectURL("./print_jv_CLDH.jsp?jv_number="+request.getParameter("jv_number")));
		return;
	}
	else if(strSchCode.startsWith("CIT")){
		dbOP.cleanUP();
		if(iVoucherType == 1){//Cash disbursement
			response.sendRedirect(response.encodeRedirectURL("./print_cd_CIT.jsp?jv_number="+request.getParameter("jv_number")));
		}
		if(iVoucherType == 0)//Journal Voucher.
			response.sendRedirect(response.encodeRedirectURL("./print_jv_CIT.jsp?jv_number="+request.getParameter("jv_number")));
		else if(iVoucherType == 2) //Petty cash.
			response.sendRedirect(response.encodeRedirectURL("./print_pc_CIT.jsp?jv_number="+request.getParameter("jv_number")));
		return;
	}
	else if(strSchCode.startsWith("AUF")){
		dbOP.cleanUP();
		if(iVoucherType == 1){//Cash disbursement
			response.sendRedirect(response.encodeRedirectURL("./print_cd_AUF.jsp?jv_number="+request.getParameter("jv_number")));
		}
		else if(iVoucherType == 0)//Journal Voucher.
			response.sendRedirect(response.encodeRedirectURL("./print_jv_AUF.jsp?jv_number="+request.getParameter("jv_number")));
		else //Petty cash.
			response.sendRedirect(response.encodeRedirectURL("./print_pc_AUF.jsp?jv_number="+request.getParameter("jv_number")));
		return;
	}
	else if(strSchCode.startsWith("CGH")){		
		if(iVoucherType == 1){//Cash disbursement
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./print_cd_CGH.jsp?jv_number="+request.getParameter("jv_number")));
			return;
		}
		//if(iVoucherType == 0)//Journal Voucher.
		//	response.sendRedirect(response.encodeRedirectURL("./print_jv_AUF.jsp?jv_number="+request.getParameter("jv_number")));
		//return;
	}
	else if(strSchCode.startsWith("WNU")){		
		if(iVoucherType == 1){//Cash disbursement
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./print_cd_WNU.jsp?jv_number="+request.getParameter("jv_number")));
			return;
		}
	}
	else if(strSchCode.startsWith("LHS")){
		dbOP.cleanUP();
		if(iVoucherType == 1){//Cash disbursement
			response.sendRedirect(response.encodeRedirectURL("./print_cd_LHS.jsp?jv_number="+request.getParameter("jv_number")));
		}
		if(iVoucherType == 0)//Journal Voucher.
			response.sendRedirect(response.encodeRedirectURL("./print_jv_LHS.jsp?jv_number="+request.getParameter("jv_number")));
		if(iVoucherType == 2)//Journal Voucher.
			response.sendRedirect(response.encodeRedirectURL("./print_pc_LHS.jsp?jv_number="+request.getParameter("jv_number")));
		return;
	}
	else if(strSchCode.startsWith("DBTC") && iVoucherType == 1){
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./print_cd_DBTC.jsp?jv_number="+request.getParameter("jv_number")));
		return;
	}
	else if(strSchCode.startsWith("PHILCST") && iVoucherType == 1){
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./print_cd_PHILCST.jsp?jv_number="+request.getParameter("jv_number")));
		return;
	}
	else if(strSchCode.startsWith("TSUNEISHI")){
		dbOP.cleanUP();
		response.sendRedirect(response.encodeRedirectURL("./print_jv_TSUNEISHI.jsp?jv_number="+request.getParameter("jv_number")));
		return;
	}
	else if(strSchCode.startsWith("ARTCRAFT")){
		dbOP.cleanUP();
		if(iVoucherType == 2)//Petty disbursement
			response.sendRedirect(response.encodeRedirectURL("./print_pc_ARTCRAFT.jsp?jv_number="+request.getParameter("jv_number")));
		//if(iVoucherType == 1)//Cash disbursement
		else
			response.sendRedirect(response.encodeRedirectURL("./print_cd_ARTCRAFT.jsp?jv_number="+request.getParameter("jv_number")));
		return;
	}
	else {
		if(iVoucherType == 0){//Journal Voucher.
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./print_jv_GENERIC.jsp?jv_number="+request.getParameter("jv_number")));
			return;
		}
	}


boolean bolIsCLDH = false;
boolean bolIsAUF  = false;

bolIsCLDH = strSchCode.startsWith("CLDH");
bolIsAUF  = strSchCode.startsWith("AUF");


if(iVoucherType != 1) {
	bolIsCLDH = false;
	bolIsAUF  = false;
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
}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="67%" height="25">
	  <%if(!bolIsCLDH && !strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC")){%>
	  <div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        Accounting Office</div>
		<%}//do not show if cldh.. 
		else{%><br><br>&nbsp;<%}%>
		
	  </td>
      <td width="33%" valign="top">
	  Voucher Number: <%=WI.fillTextValue("jv_number")%><br>
	  Voucher Date: <%=vJVInfo.elementAt(1)%><br>
	  Date Printed: <%=WI.formatDate((String)vJVInfo.elementAt(1), 6)%>
	  </td>
    </tr>
</table>
<%if(!bolIsCLDH && !strSchCode.startsWith("AUF") && !strSchCode.startsWith("UDMC")){%>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" valign="bottom" style="font-size:16px; font-weight:bold" align="center"> 
	  <%if(iVoucherType == 2){%>PETTY CASH<%}else if(iVoucherType == 0){%>JOURNAL VOUCHER <%}else{%>
	   DISBURSEMENT
VOUCHER	   
<%}%>
    </tr>
    <tr> 
      <td height="9"><hr size="1"></td>
    </tr>
  </table>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}%>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(iVoucherType > 0){%>
    <tr>
      <td>&nbsp;</td> 
      <td height="25" colspan="2" style="font-size:12px; font-weight:bold"><%if(!bolIsCLDH && !strSchCode.startsWith("UDMC")){%>Pay to :<%}else{if(strSchCode.startsWith("UDMC")){%><br><br><br><br><%}%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%}%> <u><%=vJVInfo.elementAt(5)%></u></td>
      <td height="25" style="font-size:12px; font-weight:bold">
	  <%if(strSchCode.startsWith("UDMC")){%><br><br><br><br><%=vJVInfo.elementAt(1)%><%}%></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;&nbsp;</td> 
      <td height="25" colspan="2" style="font-size:12px; font-weight:bold">
	  	<%if(!bolIsCLDH){%>Amount :
		 <%=new ConversionTable().convertAmoutToFigure(Double.parseDouble((String)vJVInfo.elementAt(6)),"Pesos","Centavos")%>
		(<%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%>)<%}%></td>
      <td height="25" style="font-size:12px; font-weight:bold"><%if(bolIsCLDH){%>
        <%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%>
      <%}%></td>
    </tr>
<%}if(strSchCode.startsWith("UDMC")){%>
	<tr>
		<td colspan="4"><br><br><br>&nbsp;</td>
    <tr>
<%}%>	

	<tr>
      <td style="font-size:13px; font-weight:bold" width="3%">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold" width="66%"><u>DEBIT</u></td>
      <td style="font-size:13px; font-weight:bold" width="17%">&nbsp;</td>
      <td style="font-size:12px;" width="14%" align="right">Amount&nbsp;&nbsp;</td>
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
      <td height="10" colspan="4" style="font-size:12px;"><hr size="1"></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold"><u>CREDIT</u></td>
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
      <td height="10" colspan="4" style="font-size:12px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:12px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:13px; font-weight:bold"><u>EXPLANATION</u></td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){%>
    <tr>
      <td style="font-size:12px;" valign="top"><%=vGroupInfo.elementAt(i)%>.</td>
      <td height="25" colspan="3" valign="top"><%=WI.getStrValue(vGroupInfo.elementAt(i + 1))%></td>
    </tr>
<%}%>
    <tr>
      <td height="10" colspan="4" style="font-size:12px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="4">
	  	<table width="100%" cellpadding="0" cellspacing="0" border="0">
			<tr valign="bottom">
				<td width="32%" height="50" align="center" style="font-size:11px;"><%=(String)request.getSession(false).getAttribute("first_name")%></span></td>
				<td width="2%" align="center">&nbsp;</td>
				<td width="32%" align="center"><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Accountant",7)),"").toUpperCase()%></td>
			    <td width="2%" align="center">&nbsp;</td>
			    <td width="32%" align="center" style="font-size:10px;"><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Internal Auditor",7)),"").toUpperCase()%></td>
			</tr>
			<tr valign="top">
			  <td height="15" align="center" style="font-size:10px; font-weight:bold" class="thinborderTOP">PREPARED BY</td>
			  <td align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td align="center" style="font-size:10px; font-weight:bold" class="thinborderTOP">CHECKED BY</td>
			  <td align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td align="center" style="font-size:10px; font-weight:bold" class="thinborderTOP">INTERNAL AUDITOR </td>
		  </tr>
			<tr>
			  <td height="15" valign="bottom" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
		  </tr>
			<tr>
			  <td height="15" valign="bottom" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td align="center" valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
		      <td align="center" valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
		      <td align="center" valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
		  </tr>
			<tr>
			  <td align="center" colspan="5">
			  	<table width="70%" cellpadding="0" cellspacing="0">
					<tr>
					  <td width="45%" height="15" align="center" valign="bottom" style="font-size:10px;"><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Comptroller",7)),"").toUpperCase()%></td>
					  <td width="10%" align="center" valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
					  <td width="45%" align="center" valign="bottom" style="font-size:10px;"><%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"President",7)),"").toUpperCase()%></td>
				  </tr>
					<tr>
					  <td height="15" valign="top" align="center" style="font-size:10px; font-weight:bold" class="thinborderTOP">COMPTROLLER</td>
					  <td valign="bottom" align="center" style="font-size:10px; font-weight:bold">&nbsp;</td>
					  <td align="center" valign="top" style="font-size:10px; font-weight:bold" class="thinborderTOP">PRESIDENT</td>
				  </tr>
				</table>			  </td>
		  </tr>
			<tr>
			  <td height="15" valign="top" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="top" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
		  </tr>
			<tr>
			  <td height="15" valign="top" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="top" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
		  </tr>
			<tr>
			  <td height="15" valign="top" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="top" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px; font-weight:bold">&nbsp;</td>
		  </tr>
			<tr>
			  <td height="15" valign="top" style="font-size:11px;">Payment Made by: 
			  <u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="top" style="font-size:11px;">Check No: 
			  <u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:11px;">Date: <u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
		  </tr>
			<tr>
			  <td height="15" valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
		  </tr>
			<tr>
			  <td height="15" valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
		  </tr>
			<tr>
			  <td height="15" valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
		  </tr>
			<tr valign="bottom">
			  <td height="15" colspan="5" style="font-size:11px;">Received the amount of: 
			  
			  <u>
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;			 
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;			 
				</u>			  </td>
		  </tr>
			<tr>
			  <td height="15" valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
		  </tr>
			<tr>
			  <td height="15" valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="top" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
		  </tr>
			<tr align="center">
			  <td height="15" valign="bottom" style="font-size:10px;">
			  <u>
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;			  </u></td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">
			  <u>
			  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;			  </u></td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
		  </tr>
			<tr align="center">
			  <td valign="top" style="font-size:11px;">Payee</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="top" style="font-size:11px;">Date</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
			  <td valign="bottom" style="font-size:10px;">&nbsp;</td>
		  </tr>
		</table>	  </td>
    </tr>
  </table>
	
</body>
</html>
<%
dbOP.cleanUP();
%>