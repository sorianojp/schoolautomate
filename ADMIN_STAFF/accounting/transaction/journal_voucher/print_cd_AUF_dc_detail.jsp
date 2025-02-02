<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function changeCode(strLabelID) {
	var strNewVal = prompt('Please enter new value','');
	if(strNewVal == null || strNewVal.lengh == 0) 
		return;
	
	var objLabelID = document.getElementById(strLabelID);
	if(!objLabelID)
		return;
	
	objLabelID.innerHTML = strNewVal;
}
</script>

<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
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

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
//strSchCode = "CLDH";

%>

<body onLoad="window.print()" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="15%" height="25">&nbsp;</td>
      <td width="85%" align="right" style="font-size:12px;"><u>Voucher Number : <%=WI.fillTextValue("jv_number")%></u> &nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;  &nbsp;&nbsp;&nbsp; <u>Date : <%=WI.formatDate((String)vJVInfo.elementAt(1), 6)%></u></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td style="font-size:13px; font-weight:bold" width="4%">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold" width="51%"><!--<u>DEBIT</u>--></td>
      <td style="font-size:13px; font-weight:bold" width="10%">&nbsp;</td>
      <td colspan="2" align="right" style="font-size:11px;"><!--Amount-->&nbsp;&nbsp;</td>
      <td style="font-size:11px;" width="16%" align="right">&nbsp;</td>
	</tr>
<%strErrMsg = null;String strAddPesoPInDebit = "P ";String strAddPesoPInCredit = "P ";
for(int p = 0; p < vJVDetail.size(); p += 5) {
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit continue.
			continue;%>
    <tr>
      <td style="font-size:11px;" valign="top">&nbsp;</td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 1)%></td>
      <td style="font-size:11px;" valign="top" align="right"><%=WI.getStrValue(strAddPesoPInDebit)%><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%></td>
      <td colspan="2" align="right" valign="top" style="font-size:11px;">&nbsp;</td>
      <td style="font-size:11px;" align="right" valign="top">&nbsp;</td>
    </tr>
	<%strAddPesoPInDebit = null;
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p -= 5;
}//end of for loop to print all debit.
while(vJVDetail.size() > 0) {%>
    <tr>
      <td style="font-size:11px;" valign="top">&nbsp;</td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(1)%></td>
      <td style="font-size:11px;" valign="top">&nbsp;</td>
      <td colspan="2" align="right" valign="top" style="font-size:11px;">
	  <%if(strErrMsg == null) {%>
	  <script language="javascript">
	  	document.getElementById('cd_amount').innerHTML = "<%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>";
	  </script>
	  <%}
	  strErrMsg = WI.getStrValue(strAddPesoPInCredit)+CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true);
	  strAddPesoPInCredit = null;%>
	  		
	  <%=strErrMsg%>&nbsp;</td>
      <td style="font-size:11px;" align="right" valign="top">&nbsp;</td>
    </tr>
	<%
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
}//end of while loop. 
%>
  </table>
  
</body>
</html>
<%
dbOP.cleanUP();
%>