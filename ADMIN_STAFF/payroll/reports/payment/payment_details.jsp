<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRExternalPayment, payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
///added code for HR/companies.

boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	String strEmpID = null;	
//add security here.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Detailed Recurring deductions Payment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--  

function ReloadPage()
{
 	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
 
function PrintPg(){
 	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
} 
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
 
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="recurring_details_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions (Per Employee)","recurring_details.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
 	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"recurring_details.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vEmpList = null;
Vector vDate = null;
double dTemp = 0d;
double dTotal = 0d;

PRExternalPayment prExt = new PRExternalPayment(request);
	
	String strSchCode = dbOP.getSchoolIndex();

	int iSearchResult = 0;
	int i = 0;
	Vector vMainInfo = null; 
 	vRetResult = prExt.getPaymentDetails(dbOP, request, WI.fillTextValue("payment_index"));
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prExt.getErrMsg();
	else{
		iSearchResult = prExt.getSearchCount();
		vMainInfo = (Vector)vRetResult.elementAt(0);
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="recurring_details.jsp" method="post" name="form_">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td height="23" colspan="4"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>		
</table>	
	<% if (vMainInfo !=null && vMainInfo.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="28">&nbsp;</td>
      <td height="28">Payee name  : <strong><%=WI.getStrValue((String)vMainInfo.elementAt(5), "n/a")%></strong></td>
    </tr>
    <tr>
      <td height="28">&nbsp;</td>
      <td height="28">OR Number : <strong><%=(String)vMainInfo.elementAt(3)%></strong></td>
    </tr>
    <tr>
      <td width="4%" height="28">&nbsp;</td>
      <td height="28">Payment date : <strong><%=(String)vMainInfo.elementAt(2)%></strong></td>
    </tr>
    
    <tr>
      <td height="29">&nbsp;</td>
      <td width="96%">Total Amount : <strong><%=CommonUtil.formatFloat((String)vMainInfo.elementAt(1), true)%></strong></td>
    </tr>
        
    <tr>
      <td height="17" colspan="2">&nbsp;</td>
    </tr>
  </table>
<% 
if (vRetResult != null &&  vRetResult.size() > 1) {
	String strTDColor = null;//grey if already deducted.%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center" height="11"><hr size="1" noshade></td>
  </tr>
  <tr>
    <td align="center"><table width="80%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
      <tr>
        <td height="26" colspan="3" align="center" bgcolor="#B9B292" class="thinborder"><strong><%=WI.fillTextValue("deduction_name").toUpperCase()%> DEDUCTIONS</strong></td>
      </tr>
      <tr>
        <td width="17%" height="28" align="center" class="thinborder">&nbsp;</td>
        <td width="48%" align="center" class="thinborder"><font size="1"><strong>NAME</strong></font></td>
        <td width="35%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
      </tr>
      <% 
			int iCount = 1;
			for (i = 1; i < vRetResult.size(); i+=10,iCount++){%>
      <tr>
        <td height="25" class="thinborder" align="center"><%=iCount%>&nbsp;</td>
        <td width="48%" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></font></td>
				<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3),true);
				dTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));				
				%>
        <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
      </tr>
      <%} //end for loop%>
			<tr>
        <td height="25" colspan="2" align="right" class="thinborder">TOTAL PAYMENTS : </td>        
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</td>
      </tr>      
    </table></td>
  </tr>
</table>

  <% } // end vRetResult != null && vRetResult.size() > 0

}// end if Employee ID is null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="post_deduct_index" value="<%=WI.fillTextValue("post_deduct_index")%>">
	<input type="hidden" name="deduction_name" value="<%=WI.fillTextValue("deduction_name")%>">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
