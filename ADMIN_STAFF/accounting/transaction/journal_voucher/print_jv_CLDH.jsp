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
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","print_jv.jsp");
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
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

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



int iRowPerPg = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"), "40"));
int iTotalPage = 0;
if(vJVDetail != null) {
	iTotalPage = vJVDetail.size() /(5 * iRowPerPg);
  	if(vJVDetail.size() % (5 * iRowPerPg) > 0)
  		++iTotalPage;
}

int iCurPage   = 1;
int iCurRow    = 0;

%>

<body onLoad="window.print()" topmargin="25" bottommargin="0" leftmargin="15" rightmargin="0">
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td style="font-size:14px; color:#0000FF; font-weight:bold">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr> 
  </table>
<%
	dbOP.cleanUP();
	return;
}
boolean bolPrintGroup = false;
String strBGRed = null;
while(vJVDetail.size() > 0) {
iCurRow    = 0;
bolPrintGroup = false;
strBGRed = "";
if(iCurPage > 1){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="63%" height="25">
	  <font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        Accounting Office	  </td>
      <td width="2%" valign="top">&nbsp;</td>
      <td width="35%" valign="top"><font style="font-size:15px;">
		  JV# : <%=WI.fillTextValue("jv_number")%><br>
		  JV Date : <%=vJVInfo.elementAt(1)%><br></font>
		  <font size="1">Date/time Printed : <%=WI.getTodaysDateTime()%> </font>	  </td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="85%" height="22" align="center" valign="bottom" style="font-size:16px; font-weight:bold">JOURNAL VOUCHER</td>
      <td width="15%" valign="bottom" style="font-size:11px;" align="right">Page <%=iCurPage++%> of <%=iTotalPage%></td>
    </tr>
    <tr> 
      <td height="9" colspan="2"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(vJVDetail.elementAt(4).equals("1")){++iCurRow;%>
	<tr>
      <td style="font-size:13px; font-weight:bold" width="3%">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold" width="67%"><u>DEBIT</u></td>
      <td style="font-size:13px; font-weight:bold" width="15%">&nbsp;</td>
      <td style="font-size:11px;" width="15%" align="right">Amount&nbsp;&nbsp;</td>
    </tr>
<%
//++iCurRow;
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
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>. 
      <%}%></td>
      <td height="20" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;</td>
    </tr>
	<%vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p -= 5;
	++iCurRow;
	if(iCurRow >=iRowPerPg)
		break;
	}//end of for(int i =0; i < vGroupInfo.size(); i += 4) 
	if(iCurRow >=iRowPerPg)
		break;
}//end of for loop to print all debit.

}//only if vJVDetail.elementAt(p + 4).equals("1")// print Debit.
if(iCurRow < iRowPerPg){++iCurRow;%>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold"><u>CREDIT</u></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%//++iCurRow;
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
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.<%}%></td>
      <td height="20" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;</td>
    </tr>
	<%
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
	++iCurRow;
	if(iCurRow >=iRowPerPg)
		break;
	}//end of while loop. 
	if(iCurRow >=iRowPerPg)
		break;
}//end of for loop to print all debit.
if(vJVDetail.size() == 0) {%>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:13px; font-weight:bold"><u>EXPLANATION</u></td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){%>
    <tr>
      <td style="font-size:11px;" valign="top"><%=vGroupInfo.elementAt(i)%>.</td>
      <td height="25" colspan="3" valign="top"><%=WI.getStrValue(vGroupInfo.elementAt(i + 1))%></td>
    </tr>
<%}
}//print only if printing debit/credit is already done. %>

<%}//if(iCurRow < iRowPerPg)%>
</table>
 
 <%}//big while loop. ... to print per page.. %> 
<!-- End of printing per page.. -->

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" style="font-size:11px;"></td>
      <td height="10" style="font-size:11px;">Prepared By : <%=(String)request.getSession(false).getAttribute("first_name")%></td>
      <td height="10" style="font-size:11px;">Correct</td>
      <td height="10" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" style="font-size:11px;"></td>
      <td height="10" style="font-size:11px;">&nbsp;</td>
      <td height="10" style="font-size:11px;"></td>
      <td height="10" style="font-size:11px;" align="center">(Accountant)</td>
    </tr>
    <tr>
      <td height="10" style="font-size:11px;"></td>
      <td height="10" style="font-size:11px;">&nbsp;</td>
      <td height="10" style="font-size:11px;">Entered By </td>
      <td height="10" style="font-size:11px;"  class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" style="font-size:11px;"></td>
      <td height="10" style="font-size:11px;">&nbsp;</td>
      <td height="10" style="font-size:11px;"></td>
      <td height="10" style="font-size:11px;" align="center">(Bookkeeper) </td>
    </tr>
  </table>
	
</body>
</html>
<%
dbOP.cleanUP();
%>