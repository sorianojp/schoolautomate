<%if(request.getSession(false).getAttribute("is_sap") == null) {%>
	<p style="font-family:Verdana, Arial, Helvetica, sans-serif; font-weight:bold; font-size:18px; color:#FF0000">You are not authorized to view this link. </p>
	<%return;

}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;

	document.form_.submit();
}
function ShowProcessing()
{
	imgWnd=
	window.open("../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
	imgWnd.focus();
	return true;
}
function CloseProcessing()
{
	if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
}
</script>

<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<%@ page language="java" import="utility.*,sap.Configuration,sap.ARInvoice, java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation();

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
Vector vDefSYTerm  = null;
String strMapStatus = null; String strEndOfTerm = null; String strEndOfTermMsg = null;

Configuration conf = new Configuration();
ARInvoice ari = new ARInvoice();

strTemp = WI.getStrValue(WI.fillTextValue("page_action"), "4");
vDefSYTerm = conf.setSYTermSAP(dbOP, request, Integer.parseInt(strTemp));
if(vDefSYTerm == null)
	strErrMsg = conf.getErrMsg();


//check number of tellers not mapped.. 
strTemp = "select count(distinct created_by) from fa_stud_payment "+
			"where fa_stud_payment.is_valid = 1 and amount > 0 and or_number is not null and not exists "+
			"(select * from SAP_TELLER_MAP where user_index = created_by)";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(!strTemp.equals("0"))
	strMapStatus = "Can't Proceed with Mapping. Teller IDs are not mapped. Total Count: "+strTemp;

if(strErrMsg == null) {
	String strIsTri  = (String)vDefSYTerm.elementAt(3);
    String strSAPSem = (String)vDefSYTerm.elementAt(2);
    if(strSAPSem.equals("0"))
      strSAPSem = "6";
    if(strIsTri.equals("1")) {//tri
      if(strSAPSem.equals("1"))
        strSAPSem = "3";
      else if(strSAPSem.equals("2"))
        strSAPSem = "4";
      else if(strSAPSem.equals("3")) {
        strSAPSem = "5";
      }
    }
    else {
      if(!strSAPSem.equals("6"))
        strSAPSem = "7";//that's regular sem of grade school.
    }

	strEndOfTerm = "select distinct docduedate from sap_arinvoice where u_schoolyr = "+(String)vDefSYTerm.elementAt(0)+" and u_sem = "+strSAPSem;
	java.sql.ResultSet rs = dbOP.executeQuery(strEndOfTerm);//System.out.println(strEndOfTerm);
	if(rs.next()) 
		strEndOfTerm = ConversionTable.convertMMDDYYYY(rs.getDate(1));
	else	
		strEndOfTerm = null;
	rs.close();
}
if(strEndOfTerm == null)
	strEndOfTermMsg = "AR Header Is not yet created.";

/**
if(strErrMsg == null && WI.fillTextValue("generate_").length() > 0) {
	ari.generateARInvoice(dbOP, request);
	strErrMsg = ari.getErrMsg();
}
**/
String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};
String[] astrConvertTermType = {"Semestral","Trimestral","Grade School (Annual)"};

%>


<form name="form_" action="./ar_invoice.jsp" method="post" onSubmit="SubmitOnceButton(this);return ShowProcessing();">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: PAYMENT - TUITION ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
	<%if(strMapStatus != null) {%>
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3" style="color:#FF0000"><b><%=strMapStatus%></b></font></td>
    </tr>
	<%}%>
	<%if(strEndOfTermMsg != null) {%>
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3" style="color:#FF0000"><b><%=strEndOfTermMsg%></b></font></td>
    </tr>
	<%}%>
  </table>
<%if(strMapStatus == null && strEndOfTermMsg == null && vDefSYTerm != null && vDefSYTerm.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr style="font-weight:bold;">
      <td width="6%" height="25">&nbsp;</td>
      <td colspan="4" style="font-size:18px">Default SY-Term: <u><%=WI.getStrValue((String)vDefSYTerm.elementAt(0))%>  - 
	  <%=WI.getStrValue((String)vDefSYTerm.elementAt(1))%>,  
	  <%=astrConvertTerm[Integer.parseInt((String)vDefSYTerm.elementAt(2))]%></u>
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  Term Type: <u><%=astrConvertTermType[Integer.parseInt((String)vDefSYTerm.elementAt(3))]%></u>
		<br><br>
		End of Term Date: <u><%=strEndOfTerm%></u>
		<input type="hidden" name="end_of_term" value="<%=strEndOfTerm%>">     </td>
    </tr>
    <tr>
      <td height="60">&nbsp;</td>
      <td width="8%" align="center">&nbsp;</td>
      <td width="54%" align="center" valign="bottom">
	  
	  <input type="submit" name="122" value="Generate Payment (Tuition and Other Payments)" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.generate_.value='1';ShowProcessing();">
	  </td>
      <td width="25%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="generate_">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
