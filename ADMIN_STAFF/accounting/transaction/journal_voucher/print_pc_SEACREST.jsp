<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script>
function IntInfo() {
	document.getElementById("sum_1").innerHTML = document.getElementById("sum_2").innerHTML
	
}
</script>
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
	strErrMsg = "PC Voucher Number not found.";
	
double dTotalDebit = 0d;

if(iVoucherType != 2) 
	strErrMsg = "Only Pettycash printing is allowed.";
if(strErrMsg != null) {
dbOP.cleanUP();

%>
<p align="center" style="font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold;"><%=strErrMsg%></p>
<%return;}%>
<body onLoad="IntInfo();window.print();">

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="3" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
	<font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>  
          <br>  
    <strong>ACCOUNTING AND FINANCE</strong></font></td>
  </tr>
  <tr>
    <td width="9%">Pay To </td>
    <td height="18" width="62%"><u><%=vJVInfo.elementAt(5)%></u></td>
    <td width="29%">Voucher: <u><b><%=WI.fillTextValue("jv_number")%></b></u></td>
  </tr>
  <tr>
    <td>Amount </td>
    <td height="18"><u><label id="sum_1"></label></u></td>
    <td>Date: <u><b><%=vJVInfo.elementAt(1)%></b></u></td>
  </tr>
</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td><div align="center"><b><font size="2">PETTY CASH  VOUCHER </font></b></div></td>
        </tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
        <tr>
          <td width="60%" height="18" class="thinborderBOTTOMLEFT"><div align="center"><b>PARTICULAR</b></div></td>
          <td width="20%" class="thinborderBOTTOMLEFT"><div align="center"><b>DEBIT</b></div></td>
          <td width="19%" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><b>CREDIT</b></div></td>
        </tr>
<%
int iTotalLine   = 4;
int iLinePrinted = 0;
	for(int p = 0; p < vJVDetail.size(); p += 5) {//System.out.println("P - "+vJVDetail.elementAt(p + 4));
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
			continue;
		++iLinePrinted;
	dTotalDebit += Double.parseDouble((String)vJVDetail.elementAt(p + 2));
	%>
        <tr>
          <td height="18" class="thinborderLEFT"><%=vJVDetail.elementAt(p + 1)%> (<%=vJVDetail.elementAt(p + 0)%>) </td>
          <td class="thinborderLEFT"><div align="right"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;&nbsp;</div></td>
          <td class="thinborderLEFTRIGHT">&nbsp;</td>
        </tr>
	<%
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p = p - 5;
	}%>
        <tr>
          <td height="10" class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFTRIGHT">&nbsp;</td>
        </tr>
 <%while(vJVDetail.size() > 0) {++iLinePrinted;%>
        <tr>
          <td class="thinborderLEFT">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=vJVDetail.elementAt(1)%> (<%=vJVDetail.elementAt(0)%>) </td>
          <td height="18" class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;&nbsp;</div></td>
        </tr>
 <%vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
 }
 while (iTotalLine > iLinePrinted){++iLinePrinted;%>
        <tr>
          <td class="thinborderLEFT">&nbsp;</td>
          <td height="10" class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFTRIGHT">&nbsp;</td>
        </tr>
 <%}%>
        <tr>
          <td height="25" colspan="3" class="thinborderALL" valign="top">
<%
for(int i =0; i < vGroupInfo.size(); i += 4){%>
		<%=WI.getStrValue(vGroupInfo.elementAt(i + 1)) + "<br>"%>
<%}%>		  </td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
        
        
        <tr align="center" valign="top">
          <td width="59%" class="thinborderNONE">
		  	<table width="100%" cellpadding="0" cellspacing="0">
				<tr>
				  <td width="38%" class="thinborderNONE" height="25">Prepared by: </td>
				  <td width="12%" class="thinborderNONE">&nbsp;</td>
				  <td width="50%" class="thinborderNONE">Verified By:</td>
			    </tr>
				<tr valign="bottom">
				  <td class="thinborderBOTTOM" align="center"><%=(String)request.getSession(false).getAttribute("first_name")%></td>
				  <td align="center">&nbsp;</td>
				  <td height="25" class="thinborderBOTTOM">&nbsp;</td>
			    </tr>
				<tr align="center" valign="top">
				  <td class="thinborderNONE">Acctg. Asst.</td>
				  <td class="thinborderNONE">&nbsp;</td>
				  <td class="thinborderNONE">Accountant</td>
			    </tr>
				<tr valign="bottom">
				  <td class="thinborderNONE"><br>Approved By: </td>
				  <td class="thinborderNONE">&nbsp;</td>
				  <td class="thinborderNONE">&nbsp;</td>
			  </tr>
				<tr align="center" valign="top">
				  <td height="25" class="thinborderBOTTOM">&nbsp;</td>
				  <td class="thinborderNONE">&nbsp;</td>
				  <td class="thinborderNONE">&nbsp;</td>
			  </tr>
				<tr align="center" valign="top">
				  <td class="thinborderNONE">President and or Vice President </td>
				  <td class="thinborderNONE">&nbsp;</td>
				  <td class="thinborderNONE">&nbsp;</td>
			  </tr>
		  </table>		  </td>
          <td width="41%" class="thinborderNONE">Received the sum of: <u>
            <label id="sum_2"><%=new ConversionTable().convertAmoutToFigure(dTotalDebit,"Pesos","Centavos")%></label>
          </u><br><br>
          ____________________<br>
          Payee</td>
        </tr>
</table>        
</body>
</html>
<%
dbOP.cleanUP();
%>