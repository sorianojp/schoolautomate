<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>
<script language="JavaScript">
function ReloadPage() {
	document.form_.submit();
}</script>
<body >
<%@ page language="java" import="utility.*,enrollment.FAElementaryPayment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean bolIsFine = false;
	boolean bolIsDownPmt =false;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Other school fees","otherschoolfees_print_receipt.jsp");
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

FAElementaryPayment faPayment = new FAElementaryPayment();
Vector vRetResult = null;
if(WI.fillTextValue("stud_id").length() > 0) {
	vRetResult = faPayment.viewPaymentDetailOfStudent(dbOP, WI.fillTextValue("stud_id"));
	if(vRetResult == null) 
		strErrMsg = faPayment.getErrMsg();
	
}


boolean bolShowReceiptHeading = true;
if(!bolShowReceiptHeading) { //forced to enter ;-)
	enrollment.ReadPropertyFileImpl readPropFileImpl = new enrollment.ReadPropertyFileImpl();
	int iRetValue = readPropFileImpl.showReceiptHeading();
	if(iRetValue == -1)
		strErrMsg = readPropFileImpl.getErrMsg();
	else if(iRetValue == 1)
		bolShowReceiptHeading = true;
}
String[] astrConvertToEduLevel = {"Preparatory","Elementary","High School"};
String[] astrConvertToSchName = {"VMCLC","VMSSHS","St. Dominic High School","St. Louis High School"};
String strTotalAmtCollected = null;
%>
<form name="form_" action="./basic_edu_pmt_view.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <%if(bolShowReceiptHeading){%>
    <tr> 
      <td height="25" colspan="3" ><div align="center"><font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
          <!--TIN - 004-005-307-000-NON-VAT-->
          <%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
          <br>
        </div></td>
    </tr>
    <%}%>
    <tr > 
      <td width="21%" height="25" >&nbsp;</td>
      <td width="27%" height="25" >&nbsp;</td>
      <td width="52%" >&nbsp;</td>
    </tr>
    <tr > 
      <td width="21%" height="25" ><div align="right">Enter Student ID&nbsp;&nbsp;&nbsp;</div></td>
      <td width="27%" height="25" ><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="52%" ><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
strTotalAmtCollected = (String)vRetResult.remove(0);%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td width="48%" height="20" >Student ID:<strong> <%=request.getParameter("stud_id")%></strong></td>
      <td width="52%" height="20" >Year Level: 
	  <%=astrConvertToEduLevel[Integer.parseInt((String)vRetResult.elementAt(0))]%>(<%=(String)vRetResult.elementAt(2)%>)</td>
    </tr>
    <tr > 
      <td height="20" >Student name:<strong> 
	  <%=WebInterface.formatName((String)vRetResult.elementAt(3),(String)vRetResult.elementAt(4),
		(String)vRetResult.elementAt(5),4)%> </strong></td>
      <td height="20" >School Name: <%=astrConvertToSchName[Integer.parseInt((String)vRetResult.elementAt(1))]%></td>
    </tr>
  </table>

  <table  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr > 
      <td height="25"  colspan="4" class="thinborder"><div align="center">:: PAYMENT DETAILS ::</div></td>
    </tr>
    <tr > 
      <td width="25%" height="25" class="thinborder"><strong>DATE PAID</strong></td>
      <td width="25%" class="thinborder"><strong>AMOUNT COLLECTED</strong></td>
      <td width="25%" class="thinborder"><strong>COLLECTED BY</strong></td>
      <td width="25%" class="thinborder"><strong>COLLECTION MODE</strong></td>
    </tr>
    <%
for(int i = 0 ; i < vRetResult.size(); i += 13){%>
    <tr >
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 6),true)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%><strong><%=WI.getStrValue((String)vRetResult.elementAt(i + 10),", Emp ID :","","")%></strong></td>
    </tr>
    <%}%>
  </table>
<%}%>
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
