<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function viewSupportingDoc() {
	strJVNumber = document.form_.cd_number.value;
	if(strJVNumber.length == 0) {
		alert("Voucher Number not found.");
		return;
	}	
	var pgLoc = "./print_jv_detail.jsp?print_stat=0&jv_number="+strJVNumber;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","jv_post.jsp");
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

String strJVNumber = WI.fillTextValue("cd_number");/////I must get when i save / edit.
JvCD jvCD = new JvCD();

Vector vJVDetail  = null; //to show detail at bottom of page. 
Vector vJVInfo    = null;
Vector vGroupInfo = null;

boolean bolCreditDebitDoesnotMatch = false;

if(WI.fillTextValue("page_action").length() > 0) {
	if(jvCD.operateOnCDPettyCash(dbOP, request, 8) == null )//for jv.. 
		strErrMsg = jvCD.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}

if(strJVNumber.length() > 0) {
	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);
	if(vJVDetail == null)
		strErrMsg = jvCD.getErrMsg();
	else {
	    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE, [2] = jv_type, [3] = is_cd
	    vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    	vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
		
		for(int i =0; i < vGroupInfo.size(); i += 4){
			if(vGroupInfo.elementAt(i + 3).equals("0")) {
				bolCreditDebitDoesnotMatch = true;
				break;
			}
		}
		
		if(vJVInfo.elementAt(3).equals("1")) {
			strErrMsg = "Please enter Journal voucher number.";
			vJVInfo = null;
		}
	}
}
else 
	strErrMsg = "Voucher not found.";

boolean bolIsDetailAvailable = false;
java.sql.ResultSet  rs = null;
if(vJVInfo != null) {
	rs = dbOP.executeQuery("select count(*) from AC_JV_DC_DETAIL "+
		"join AC_JV_DC on (AC_JV_DC.JV_CREDIT_INDEX = AC_JV_DC_DETAIL.JV_CREDIT_INDEX) "+
		" where jv_index = "+(String)vJVInfo.elementAt(0));
	rs.next();
	if(rs.getInt(1) > 0) 
		 bolIsDetailAvailable = true;
	rs.close();
}
%>
<form action="./jv_post.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          JOURNAL VOUCHER - POST VOUCHERS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><a href="cash_disbursement.jsp"></a>
	  <font style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></font>
	  </td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Voucher No.</td>
      <td width="18%"><input name="cd_number" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("cd_number")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <font size="1">&nbsp;</font> </td>
      <td width="9%"><font size="1"><a href=""><img src="../../../../images/search.gif" border="0"></a></font></td>
      <td width="54%"><font size="1">
        <input type="submit" name="12" value=" Proceed" style="font-size:11px; height:24px;border: 1px solid #FF0000;">
      </font></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2">Vouchers Not Posted yet : </td>
      <td colspan="2">
	  <table cellpadding="0" cellspacing="0" class="thinborder" width="90%">
<%
rs = dbOP.executeQuery("select jv_number, JV_DATE from AC_JV where IS_LOCKED = 0 and is_cd=0 and exists (select * from ac_jv_dc where jv_index = ac_jv.jv_index) ");
while(rs.next()) {%>
		  	<tr>
				<td class="thinborder" width="50%"><a href="./jv_post.jsp?cd_number=<%=rs.getString(1)%>"><%=rs.getString(1)%></a>(<%=ConversionTable.convertMMDDYYYY(rs.getDate(2))%>)</td>
				<td class="thinborder" width="50%">
					<%if(rs.next()){%>
						<a href="./jv_post.jsp?cd_number=<%=rs.getString(1)%>"><%=rs.getString(1)%></a>(<%=ConversionTable.convertMMDDYYYY(rs.getDate(2))%>)
					<%}else{%>&nbsp;<%}%>
				</td>
			</tr>
<%}
rs.close();
%>		
		</table>	  
	  </td>
    </tr>
    <tr> 
      <td height="26" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vJVInfo != null && vJVInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2">Date Posted :
        <%
strTemp = (String)vJVInfo.elementAt(4);
if(strTemp == null) {
	strTemp = WI.fillTextValue("lock_date");
	if(strTemp.length() == 0) { 
		strTemp = (String)vJVInfo.elementAt(1);
		if(strTemp == null)
			strTemp = WI.getTodaysDate(1);
	}
}

%>
        <input name="lock_date"  type="text" size="11" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px;">
        <a href="javascript:show_calendar('form_.lock_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
		
     &nbsp;&nbsp;&nbsp;
<%
if(bolCreditDebitDoesnotMatch){%>
<font style="font-size:11px; color:#FF0000; font-weight:bold">
	Can't Update JV status. Debit/Credit does not match</font>
<%}else{%>
	 <input type="submit" name="122" value=" Update " style="font-size:11px; height:20px; border: 1px solid #FF0000;"
		   onClick="document.form_.page_action.value='1'">		
<%}%>
		  </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Voucher Date: </td>
      <td style="font-size:11px; font-weight:bold; color:#0000FF"><%=vJVInfo.elementAt(1)%></td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="15%">&nbsp;</td>
      <td align="right" style="font-size:9px;">
<%if(bolIsDetailAvailable){%>
	  <a href="javascript:viewSupportingDoc();"><img src="../../../../images/view.gif" border="0"></a>
	  	View Supporting document 
<%}%>		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td style="font-size:13px; font-weight:bold" width="3%">&nbsp;</td> 
      <td height="25" style="font-size:13px; font-weight:bold" width="67%"><u>DEBIT</u></td>
      <td style="font-size:13px; font-weight:bold" width="15%">&nbsp;</td>
      <td style="font-size:11px;" width="15%" align="right">Amount&nbsp;&nbsp;</td>
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
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>. 
      <%}%></td>
      <td height="25" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;</td>
    </tr>
	<%vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p -= 5;}//end of while loop. 
}//end of for loop to print all debit.%>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td> 
      <td height="25" style="font-size:13px; font-weight:bold"><u>CREDIT</u></td>
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
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.<%}%></td>
      <td height="25" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;</td>
    </tr>
	<%
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);}//end of while loop. 
}//end of for loop to print all debit.%>

    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;">&nbsp;</td>
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
<%}%>
  </table>
<%}//if(vJVDetail != null && vJVDetail.size() > 0) {%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>