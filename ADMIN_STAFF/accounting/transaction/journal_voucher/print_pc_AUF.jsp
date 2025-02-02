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
	
if(iVoucherType != 2) 
	strErrMsg = "Only JV printing is allowed.";
if(strErrMsg != null) {
dbOP.cleanUP();
%>
<p align="center" style="font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold;"><%=strErrMsg%></p>
<%return;}%>
<body onLoad="window.print();">

<table width="100%" border="0">
  <tr>
    <td width="33%" height="111"><div align="right"><img src="../../../../images/logo/AUF_PAMPANGA.gif" width="71" height="98"></div></td>
    <td width="48%"><div align="center"><font size="3">Angeles University Foundation</font><font size="5"><br>
          <font size="2">Angeles City, Philippines<br>  
          <br>  
    <font size="3">ACCOUNTING AND FINANCE</font></font></font></div></td>
    <td width="19%">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td height="25" colspan="2" class="thinborderTOPLEFTBOTTOM"><div align="center"><b><font size="3">PETTY CASH VOUCHER</font></b></div></td>
          <td width="19%" height="25"  class="thinborderALL"><div align="right">Voucher No.: <u><b><%=WI.fillTextValue("jv_number")%></b></u>&nbsp;&nbsp;</div></td>
        </tr>
        <tr>
          <td width="60%" height="25" class="thinborderBOTTOMLEFT"><div align="center"><b>PARTICULAR</b></div></td>
          <td width="20%" height="25" class="thinborderBOTTOMLEFT"><div align="center"><b>DEBIT</b></div></td>
          <td height="20" class="thinborderBOTTOMLEFTRIGHT"><div align="center"><b>CREDIT</b></div></td>
        </tr>
<%
int iTotalLine   = 21;
int iLinePrinted = 0;
	for(int p = 0; p < vJVDetail.size(); p += 5) {//System.out.println("P - "+vJVDetail.elementAt(p + 4));
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
			continue;
		++iLinePrinted;
	%>
        <tr>
          <td height="22" class="thinborderLEFT"><%=vJVDetail.elementAt(p + 1)%> (<%=vJVDetail.elementAt(p + 0)%>) </td>
          <td class="thinborderLEFT"><div align="right"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;&nbsp;</div></td>
          <td class="thinborderLEFTRIGHT">&nbsp;</td>
        </tr>
	<%
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p = p - 5;
	}%>
        <tr>
          <td height="20" class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFTRIGHT">&nbsp;</td>
        </tr>
 <%while(vJVDetail.size() > 0) {++iLinePrinted;%>
        <tr>
          <td class="thinborderLEFT">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=vJVDetail.elementAt(1)%> (<%=vJVDetail.elementAt(0)%>) </td>
          <td height="22" class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;&nbsp;</div></td>
        </tr>
 <%vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
 }
 while (iTotalLine > iLinePrinted){++iLinePrinted;%>
        <tr>
          <td class="thinborderLEFT">&nbsp;</td>
          <td height="25" class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFTRIGHT">&nbsp;</td>
        </tr>
 <%}%>
        <tr>
          <td class="thinborderLEFT">&nbsp;</td>
          <td height="18" class="thinborderLEFT">&nbsp;</td>
          <td class="thinborderLEFTRIGHT">&nbsp;</td>
        </tr>
        <tr>
          <td height="40" colspan="3" class="thinborderALL" align="center">
<%
for(int i =0; i < vGroupInfo.size(); i += 4){%>
		<%=WI.getStrValue(vGroupInfo.elementAt(i + 1)) + "<br>"%>
<%}%>		  
		  </td>
          </tr>
        <tr>
          <td class="thinborderLEFT">Prepared by: </td>
          <td height="25" colspan="2" class="thinborderLEFTRIGHT">Checked by: </td>
          </tr>
        <tr>
          <td class="thinborderBOTTOMLEFTRIGHT">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=(String)request.getSession(false).getAttribute("first_name")%></td>
          <td height="25" colspan="2" class="thinborderBOTTOMRIGHT">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Chief Accountant & Budget Offi",4))%></td>
          </tr>
      </table>        
<table width="100%">
<tr>
	<td width="50%">AUF-FORM AFO-04<br>
	August 1, 2007, Rev.0</td>
	<td align="right"><%=WI.formatDate((String)vJVInfo.elementAt(1), 11)%></td>
</tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>