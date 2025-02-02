<%
	WebInterface WI  = new WebInterface(request);
	String strJVNumber = WI.fillTextValue("jv_number");/////I must get when i save / edit.
%>
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
function PrintDetail() {
	if(!confirm("Click ok to print Detail Debit/Credit."))
		return;
	location = "./print_cd_AUF_dc_detail.jsp?jv_number=<%=strJVNumber%>";	
}
//this function adjusts the height of 
function ReadjustTextArea() {
	if(!document.form_.particular)
		return;
	
	var therows=0
	var thetext = document.form_.particular.value;
	var newtext = thetext.split("\n");
	therows+=newtext.length
	var i;
	for(i=0;i<newtext.length;i++)
		therows+=Math.floor(newtext[i].length/70)
		
	document.form_.particular.rows = therows + 1;
}
</script>

<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;

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

<body onLoad="ReadjustTextArea();window.print()" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<form name="form_">
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
<table><tr><td height="35">&nbsp;</td></tr></table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="67%" height="25"><br><br>&nbsp;</td>
      <td width="33%" valign="top" style="font-size:14px;"><br><br>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  	<%=WI.formatDate((String)vJVInfo.elementAt(1), 6)%><br>&nbsp;
	  </td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;<br><br>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
int iLinePrinted      = 0;
int iLineCapacity     = 11;
int iNoOfColumn       = 0;
boolean bolPrintGroup = false;
String strCharAt      = null;

if(iVoucherType > 0){
String strBankCode = "";
String strCheckNo  = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
strTemp = null;

if(vGroupInfo != null && vGroupInfo.size() > 0) {
	strTemp = (String)vGroupInfo.elementAt(1);
}
if(strTemp == null)
	strTemp = "";
//System.out.println(strTemp);
int iIndexOf = strTemp.toLowerCase().indexOf("check #");
if(iIndexOf > -1) {
	strCheckNo = strTemp.substring(iIndexOf + 8);
	
	while(iIndexOf > 0) {
		strCharAt = String.valueOf(strTemp.charAt(--iIndexOf));
		if(strCharAt.trim().length() == 0) {
			if(strBankCode.length() > 0)
				break;
			continue;
		}
		strBankCode = strCharAt + strBankCode;		
	}
}
if(strBankCode.length() == 0) 
	strBankCode = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
%>
    <tr>
      <td width="4%">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold" width="50%">
	  	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<u><%=vJVInfo.elementAt(5)%></u></td>
      <td height="20" colspan="2" style="font-size:13px; font-weight:bold" width="23%"><label id="checkNO" onClick="changeCode('checkNO')"><%=strCheckNo%></label>        <label id="bankCODE" onClick="changeCode('bankCODE')"></label></td>
      <td colspan="2" style="font-size:13px; font-weight:bold" width="23%"><%=strBankCode%></td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
      <td height="25" colspan="2">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp; </td>
    </tr>
<!-- Start of explanation   <tr>
      <td height="10" colspan="5" style="font-size:13px; font-weight:bold"><u>EXPLANATION</u>&nbsp;</td>
    </tr> --> 
<%//System.out.println(vGroupInfo);
Vector vExplanation = null; Vector vTemp = null; 
String strAddPesoPInDebit = "P ";String strAddPesoPInCredit = "P ";String strAddPesoPInParticular = "P ";
for(int i =0; i < vGroupInfo.size(); i += 4){
	strTemp = (String)vGroupInfo.elementAt(i + 1);
	if(iIndexOf > 0) {
		strTemp = strTemp.substring(0,iIndexOf);
		iIndexOf = 0;
	}

	vExplanation= jvCD.formatExplanation(strTemp);
	if(vExplanation != null && vExplanation.size() > 0 ) {
		iNoOfColumn = Integer.parseInt((String)vExplanation.remove(0));
		iLinePrinted += vExplanation.size();
	}
	%>
    <tr>
      <td style="font-size:11px;" valign="top"><%//=vGroupInfo.elementAt(i)%>&nbsp;</td>
      <td height="25" colspan="5" valign="top"><br><br>
	  <%if(vExplanation != null && vExplanation.size() > 0) {%>
<!-- Crazy idea -- but working --> 
	  <table cellpadding="0" cellspacing="0" width="80%">
	  <tr>
	  	<td width="81%">
		<textarea name="particular" rows="4" cols="70" class="textbox" style="font-size:11px; border:0px; overflow:hidden;" readonly="readonly"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
		<!--<pre><%//=strTemp%></pre>-->
		</td>
		<td width="19%" valign="top"><%if(vJVInfo.elementAt(6) != null){%>
			<span style="font-size:11px; font-weight:bold"><%=WI.getStrValue(strAddPesoPInParticular)%><label id='cd_amount'><%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%></label></span>
			<%strAddPesoPInParticular=null;}vJVInfo.setElementAt(null, 6);%></td>		
	  </tr>
	  
	  
	  <%if(false)
	  while(vExplanation.size() > 0) {
	  	vTemp = (Vector)vExplanation.remove(0);%>
		  <tr>
		  <%for(int p = 0; p < iNoOfColumn; ++p){
		  	if(p%2 == 1) 
				strTemp = " align='right'";
			else
				strTemp = "";%>
			<td width="81%"<%=strTemp%>>&nbsp;
		    <%if(vTemp.size() > 0) {%><%=vTemp.remove(0)%><%}%>&nbsp;&nbsp;&nbsp;&nbsp;</td>
		    <td width="19%"<%=strTemp%>><%if(vJVInfo.elementAt(6) != null){%>
			<span style="font-size:11px; font-weight:bold"><%=WI.getStrValue(strAddPesoPInParticular)%><label id='cd_amount'><%=CommonUtil.formatFloat((String)vJVInfo.elementAt(6), true)%></label></span>
			<%strAddPesoPInParticular=null;}vJVInfo.setElementAt(null, 6);%>			</td>
		    <%}//end of for.. %>
	   </tr>	   
	   <%}//end of while.%>
	  </table>
	<%}//only if vExplanation is not null %>	  </td>
    </tr>
<%}
if(true) {
iLinePrinted += 4;
//System.out.println("iLinePrinted : "+iLinePrinted+" iLineCapacity: "+iLineCapacity);
	for(; iLinePrinted < iLineCapacity; ++iLinePrinted){%>
    <tr>
      <td height="10" colspan="6" style="font-size:11px;">&nbsp;</td>
    </tr>
<%}}%>
    <tr>
      <td height="20" colspan="6" >&nbsp;</td>
    </tr>
<!-- end of explanation.. -->
<!-- this is shown only if cldh.. -->
	<tr>
      <td style="font-size:13px; font-weight:bold" width="4%">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold" width="50%"><!--<u>DEBIT</u>--></td>
      <td style="font-size:13px; font-weight:bold" width="11%">&nbsp;</td>
      <td width="12%" align="right" style="font-size:11px;"><!--Amount-->&nbsp;&nbsp;</td>
      <td width="7%" align="right" style="font-size:11px;">&nbsp;</td>
      <td style="font-size:11px;" width="16%" align="right">&nbsp;</td>
	</tr>
<%strErrMsg = null;
iLineCapacity = iLineCapacity+4; //Max number of lines to be printed for first page.. I have to print in other pages.. -2 because one line is Printed Debit, and -- is done after one line is printed.. 

//System.out.println("vJVDetail : "+ vJVDetail);
strTemp = ""; Vector vTempDebit = new Vector();
for(int i = 0; i < vJVDetail.size(); i += 5) {
	if(vJVDetail.elementAt(i + 4).equals("0"))//if credit .. continue.. 
		continue;

	if(strTemp.length() > 0)
		strTemp = strTemp + ",'"+vJVDetail.elementAt(i)+"'";
	else	
		strTemp = "'"+vJVDetail.elementAt(i)+"'";
}

if(strTemp.length() > 0) {
	strTemp = "select parent.COMPLETE_CODE, parent.account_name, self.complete_code from AC_COA as self "+
			"join ac_coa as parent on (self.PARENT_INDEX = parent.coa_index) where self.complete_code in ("+strTemp+") and self.is_valid = 1 order by parent.COMPLETE_CODE";
//System.out.println(strTemp);
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vTempDebit.addElement(rs.getString(1));//[0] parent account code.
		vTempDebit.addElement(rs.getString(2));//[1] account name.
		vTempDebit.addElement(rs.getString(3));//[2] self account code. 
	}
	rs.close();
}
//System.out.println("TempDebit Before :: "+vTempDebit);
for(int i = 0; i < vTempDebit.size(); ) {
	strTemp = (String)vTempDebit.elementAt(i);
	//remove it because the element is at the end and it is only one element.
	if( (i + 4) > vTempDebit.size() ) {
		vTempDebit.removeElementAt(i);vTempDebit.removeElementAt(i);vTempDebit.removeElementAt(i);
		break;
	}
	//remove it because it is only one record.
	if(!vTempDebit.elementAt(i + 3).equals(strTemp)) {
		vTempDebit.removeElementAt(i);vTempDebit.removeElementAt(i);vTempDebit.removeElementAt(i);
		
		continue;
	}
	//having multiple account with one parent.
	i += 3;
	if(i >= vTempDebit.size())
		break;
	while(vTempDebit.elementAt(i).equals(strTemp)) {
		i += 3;
		if( i >= vTempDebit.size())
			break;
	}
}
//System.out.println("TempDebit After :: "+vTempDebit);
int iIndexOf1 = 0; int iIndexOf2 = 0; double dTemp = 0d;

/*** start of block :: to avoid grouping .. remove this block ***/
for(int i = 0; i < vJVDetail.size(); i += 5) {
	if(vJVDetail.elementAt(i + 4).equals("0"))//if credit .. continue.. 
		continue;

	strTemp = (String)vJVDetail.elementAt(i);
	//System.out.println(" Coa in operation1 :: "+strTemp);	

	iIndexOf1 = vTempDebit.indexOf(strTemp);
	if(iIndexOf1 == -1)
		continue;
	//System.out.println(" Coa in operation2 :: "+strTemp);	
	//else :: it is having pair.. 
	dTemp = Double.parseDouble((String)vJVDetail.elementAt(i + 2)); 
	//i += 5;
	for(int p = i + 5; p < vJVDetail.size(); p += 5) {
		if(vJVDetail.elementAt(p + 4).equals("0"))//if credit .. continue.. 
			continue;
		strTemp = (String)vJVDetail.elementAt(p);
		iIndexOf2 = vTempDebit.indexOf(strTemp);
		if(iIndexOf2 == -1)
			continue;
			
		if(!vTempDebit.elementAt(iIndexOf2 - 2).equals(vTempDebit.elementAt(iIndexOf1 - 2)) )
			break;
		dTemp += Double.parseDouble((String)vJVDetail.elementAt(p + 2)); 
		vJVDetail.remove(p);vJVDetail.remove(p);vJVDetail.remove(p);vJVDetail.remove(p);vJVDetail.remove(p);
		p = p - 5;
	}
	//i = i + 5;
	vJVDetail.setElementAt(vTempDebit.elementAt(iIndexOf1 - 1), i + 1);
	vJVDetail.setElementAt(Double.toString(dTemp), i + 2);
	//i = i - 5;
}
/*** end of block :: to avoid grouping .. remove this block ***/



for(int i =0; i < vGroupInfo.size(); i += 4){
	//if(iLineCapacity == 0) break;//stop printing.. 
	
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = false;%>
	<%for(int p = 0; p < vJVDetail.size(); p += 5, --iLineCapacity) {
		if(!vJVDetail.elementAt(p + 3).equals(strTemp) )
			continue;
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
			continue;%>
    <tr>
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>. <%}%></td>
      <td style="font-size:11px;" valign="top"><label onDblClick="PrintDetail();"><%=vJVDetail.elementAt(p + 1)%></label></td>
      <td style="font-size:11px;" valign="top" align="right"><%=WI.getStrValue(strAddPesoPInDebit)%><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%></td>
      <td colspan="2" align="right" valign="top" style="font-size:11px;">&nbsp;</td>
      <td style="font-size:11px;" align="right" valign="top">&nbsp;</td>
    </tr>
	<%strAddPesoPInDebit = null;
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p -= 5;//if(iLineCapacity == 0) break;
	}//end of while loop. 
}//end of for loop to print all debit.
iLineCapacity -= 1;//decremeted because it will Print credit line .. and 
if(iLineCapacity > 0){//print only if there is still lines to be printed.. %>
<!--    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td> 
      <td height="26" style="font-size:13px; font-weight:bold"><u>CREDIT</u></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>-->
<%
for(int i =0; i < vGroupInfo.size(); i += 4){
	//if(iLineCapacity == 0) break;//stop printing.. 
	
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = false;%>
	<%while(vJVDetail.size() > 0) {
		if(!vJVDetail.elementAt(3).equals(strTemp))//if not belong to same group.. break.
			break;
			--iLineCapacity;%>
    <tr>
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.<%}%></td>
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
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);//if(iLineCapacity == 0) break;
	}//end of while loop. 
}//end of for loop to print all debit.
}//Print only if iLineCapacity > 0%>

<%}//prints incase of not cldh..%>
  </table>
  
  <!-- Print now in other pages.. -->
  <% 
  iLineCapacity = 40;
  int iNoOfPages = vJVDetail.size() /(5 * 40) + 1;
  if(vJVDetail.size() % (5 * 40) > 0)
  	++iNoOfPages;
  int iCurPg = 1; int iCurLine = 0;	
  while(vJVDetail.size() > 0) {%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="67%" height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        Accounting Office</div>
		<div align="left"><u>Page <%=++iCurPg%> of <%=iNoOfPages%></u></div>
	  </td>
      <td width="33%" valign="top">
			CD Number : <%=WI.fillTextValue("jv_number")%><br>
			CD Date :<%=vJVInfo.elementAt(1)%><br>
			Date and time Printed : <%=WI.getTodaysDateTime()%>
	  </td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%//I have to make sure Debit is still to be printed..

if(vJVDetail.elementAt(4).equals("1")){//Debit..%>
	<tr>
      <td style="font-size:13px; font-weight:bold" width="4%">&nbsp;</td> 
      <td height="20" style="font-size:13px; font-weight:bold" width="63%"><u>DEBIT</u></td>
      <td style="font-size:13px; font-weight:bold" width="10%">&nbsp;</td>
      <td style="font-size:11px;" width="10%" align="right">Amount&nbsp;&nbsp;</td>
    </tr>
	<%bolPrintGroup = false;iCurLine = 2;
	for(int i =0; i < vGroupInfo.size(); i += 4){
		strTemp = (String)vGroupInfo.elementAt(i);//group number;
		bolPrintGroup = true;%>
		<%for(int p = 0; p < vJVDetail.size(); p += 5) {
			if(!vJVDetail.elementAt(p + 3).equals(strTemp) )
				continue;
			if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
				break;%>
		<tr>
		  <td valign="top" style="font-size:11px;"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>. <%}%></td>
		  <td valign="top" style="font-size:11px;"><%=vJVDetail.elementAt(p + 1)%></td>
		  <td valign="top" style="font-size:11px;"><%=vJVDetail.elementAt(p + 0)%></td>
		  <td align="right" valign="top" style="font-size:11px;"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;</td>
	    </tr>
		<%vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
		vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
		p -= 5;if(iLineCapacity <= ++iCurLine) break;}//end of while loop. 
	}//end of for loop to print all debit.%>

<%}//if(vJVDetail.elementAt(4).equals("0")){//Debit.. -- Print if debit information is left in vector.. 
iCurLine += 2;
if(iLineCapacity >  iCurLine) {//must have less lines - so it can print.. %>
		<tr>
		  <td style="font-size:13px; font-weight:bold">&nbsp;</td> 
		  <td height="26" style="font-size:13px; font-weight:bold"><u>CREDIT</u></td>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
	    </tr>
	<%bolPrintGroup = false;
	for(int i =0; i < vGroupInfo.size(); i += 4){
		strTemp = (String)vGroupInfo.elementAt(i);//group number;
		bolPrintGroup = true;%>
		<%while(vJVDetail.size() > 0) {
			if(!vJVDetail.elementAt(3).equals(strTemp))//if not belong to same group.. break.
				break;
		%>
		<tr>
		  <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.<%}%></td>
		  <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(1)%></td>
		  <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(0)%></td>
		  <td style="font-size:11px;" align="right" valign="top">
		  <%if(strErrMsg == null) {%>
	  <script language="javascript">
	  	document.getElementById('cd_amount').innerHTML = "<%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>";
	  </script>
	  <%}
	  strErrMsg = CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true);%>
	  		
	  <%=strErrMsg%>&nbsp;</td>
	    </tr>
		<%
		vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
		vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);if(iLineCapacity <= ++iCurLine) break;}//end of while loop. 
	}//end of for loop to print all debit.%>
<%}//	if(iLineCapacity >  CurLine) {//must have less lines - so it can print.. %>
</table>
  <%}//end of 2nd page printing.. //end of while(vJVDetail.size() > 0) {%>
  
</form>	
</body>
</html>
<%
dbOP.cleanUP();
%>