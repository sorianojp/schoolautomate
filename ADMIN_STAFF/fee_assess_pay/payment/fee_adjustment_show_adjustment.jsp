<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function GoBack() {
	location = "./fee_adjustment.jsp?stud_id="+document.fa_payment.stud_id.value+"&sy_from="+
				document.fa_payment.sy_from.value+"&sy_to="+document.fa_payment.sy_to.value+
				"&semester="+document.fa_payment.semester.value;
}
function DeleteRecord(strIndex)
{
	document.fa_payment.deleteRecord.value="1";
	document.fa_payment.info_index.value=strIndex;
	document.fa_payment.submit();
}
function UpdateManualOverride(strAdjRef, strOrigAmt) {
	var pgLoc = "./fee_adjustment_show_adjustment_manual.jsp?adj_ref="+strAdjRef+"&orig_amt="+strOrigAmt;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAPayment,enrollment.FAFeeOperation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment_show_adjustment.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"fee_adjustment_show_adjustment.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT-FEE ADJUSTMENT",request.getRemoteAddr(),
														"fee_adjustment.jsp");
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vAdjustmentDtls = new Vector();
Vector vStudInfo = new Vector();Vector vTemp = null;

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");

String strFAFAIndex = null;
String[] astrCovnertDiscUnit={"Peso","%","unit"};
String[] astrConvertDisOn = {"Tuition Fee", "Mis Fee", "Free all", "Other Charges",
		"TUITION + MISC FEE", "MISC FEE + OTH CHARGES","OTH CHARGES","Tuition+Misc+Oth"};

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAFeeOperation fOperation = new FAFeeOperation();
FAPayment faPayment = new FAPayment();
paymentUtil.setIsBasic(bolIsBasic);

strTemp = request.getParameter("deleteRecord");

Vector vManualAdj = new Vector();
int iIndexOf = 0;

if(strTemp != null && strTemp.compareTo("1") ==0)
{
	if(!faPayment.deleteAdjustmentOfStud(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
		strErrMsg = faPayment.getErrMsg();
	else
		strErrMsg = "Adjustment for student is deleted successfully.";
}

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("semester").length() > 0)
	vStudInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),WI.fillTextValue("sy_from"),
														WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
else
	vStudInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
if(vStudInfo == null) strErrMsg = paymentUtil.getErrMsg();
else
{
	vAdjustmentDtls = faPayment.viewAdjustmentOfStudDetail(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
        (String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5));
	if(vAdjustmentDtls == null || vAdjustmentDtls.size() ==0)
		strErrMsg = faPayment.getErrMsg();
	else {
		String strSQLQuery = "select adj_index, AMT_OVERRIDE from FA_STUD_PMT_ADJUSTMENT where user_index = "+
			(String)vStudInfo.elementAt(0)+" and sy_from = "+vStudInfo.elementAt(8)+" and semester = "+vStudInfo.elementAt(5)+" and AMT_OVERRIDE > 0";
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vManualAdj.addElement(rs.getString(1));//[0] adj_index
			vManualAdj.addElement(CommonUtil.formatFloat(rs.getDouble(2), true));//[1] AMT_OVERRIDE
		}	
		rs.close();
	}
}

String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
if(strErrMsg == null) 
	strErrMsg = "";

%>

<form name="fa_payment" action="./fee_adjustment_show_adjustment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          FEE ADJUSTMENTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%">
	  <a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a>
        <strong><font size="3" color="#FF0000"><%=strErrMsg%></font></strong></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="43%" height="25">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%></strong></td>
      <td  colspan="4" height="25">Course / Major:<strong> 
	  	<%if(bolIsBasic){%>
	  		<%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(4)), false)%>
		<%}else{%>
	  	<%=(String)vStudInfo.elementAt(2)%>/ <%=WI.getStrValue(vStudInfo.elementAt(3))%>
		<%}%>
	  </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">SY-TERM:<strong> <%
	  if(WI.fillTextValue("sy_from").length() > 0){%>
	  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
	  (<%=astrConvertToSem[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"),"0"))]%>)
	  <%}else{%>
	  <%=(String)vStudInfo.elementAt(8)%> - <%=(String)vStudInfo.elementAt(9)%>(<%=astrConvertToSem[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(5),"0"))]%>)
	  <%}%>
	  </strong></td>
      <td  colspan="4" height="25"><%if(!bolIsBasic){%>YEAR: <strong><%=(String)vStudInfo.elementAt(4)%></strong><%}%></td>
    </tr>
  </table>

<%
if(vAdjustmentDtls != null && vAdjustmentDtls.size() > 0)
{%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center">LIST OF EXISTING FEE ADJUSTMENT(S)
          FOR THIS STUDENT </div></td>
    </tr>
    <tr>
      <td height="25"><div align="center"><strong><font size="1">EDUCATIONAL ASSISTANCE
          TYPE</font></strong></div></td>
      <td height="25"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="15%" height="25"><div align="center"><font size="1"><strong>EXEMPTIONS/DISCOUNTS (AMOUNT / %)</strong></font></div></td>
      <td width="13%"><div align="center"><font size="1"><strong>AMOUNT ADJUSTED<br>(System Computed)</strong></font></div></td>
      <td width="8%" height="25" align="center"><font size="1"><strong>DELETE</strong></font></td>
      <td width="8%" align="center" style="font-weight:bold; font-size:9px;">MANUAL OVERRIDE  </td>
    </tr>
<%
enrollment.FAPmtMaintenance FA = new enrollment.FAPmtMaintenance();
String strManualOverride = null;

double dDiscountSysComputed = 0d;

for(int i=0; i< vAdjustmentDtls.size(); ++i){
	vTemp = FA.operateOnMultipleFeeAdjustment(dbOP, request, 4, (String)vAdjustmentDtls.elementAt(i + 1));
	if(vTemp != null)
		strTemp = "<br>"+(String)vTemp.elementAt(0);
	else
		strTemp = "&nbsp;";
	
	iIndexOf = vManualAdj.indexOf(vAdjustmentDtls.elementAt(i));
	if(iIndexOf == -1) 
		strManualOverride = null;
	else	
		strManualOverride = (String)vManualAdj.elementAt(iIndexOf + 1);

	dDiscountSysComputed = fOperation.calAdjustmentRebate(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
        (String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5),(String)vAdjustmentDtls.elementAt(i+1), true, false, false);
%>
    <tr>
      <td width="20%" height="22"><%=(String)vAdjustmentDtls.elementAt(i+2)%></td>
      <td width="30%" height="22">&nbsp;<%=WI.getStrValue(vAdjustmentDtls.elementAt(i+6))%></td>
      <td height="22"><%=(String)vAdjustmentDtls.elementAt(i+3)%>
	  <%=astrCovnertDiscUnit[Integer.parseInt((String)vAdjustmentDtls.elementAt(i+4))]%>
	  (<%=astrConvertDisOn[Integer.parseInt((String)vAdjustmentDtls.elementAt(i+5))]%>)
	  <%=strTemp%>	  </td>
      <td>
	  <%
	  	strTemp = CommonUtil.formatFloat(dDiscountSysComputed, true);
	  %>
	  <%=strTemp%></td>
      <td height="22">
	  <%if(iAccessLevel ==2){%>
	  	<a href='javascript:DeleteRecord("<%=(String)vAdjustmentDtls.elementAt(i)%>");'>
	  	<img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
	  <%}else{%>Not authoized<%}%></td>
      <td align="center" style="font-weight:bold"><%=WI.getStrValue(strManualOverride, "Not Set")%>
	  <br>
	  <a href="javascript:UpdateManualOverride('<%=vAdjustmentDtls.elementAt(i)%>','<%=strTemp%>');"><img src="../../../images/update.gif" border="0"></a>
	  </td>
    </tr>
<%
i = i+6;
}%>
  </table>
<%
	}//if vAdjustmentDtls is not null.
}//if student info is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
<input type="hidden" name="is_basic" value="<%=WI.fillTextValue("is_basic")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
