<%@ page language="java" import="utility.*,payroll.PRRetirementLoan,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
	
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Rate</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript">
function ReloadPage() {
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.emp_id.focus();
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp  = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-SALARY RATE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-SALARY RATE-SALARY RATE","fs_ledger.jsp");
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
	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	
	Vector vRetResult = null; 
	Vector vEmpRec    = null;
	String strTransDate = null;
	double dDebit = 0d;
	double dCredit = 0d;
	double dBalance = 0d;
	
	if(WI.fillTextValue("emp_id").length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
		if(vEmpRec == null)
			strErrMsg = "Employee has no profile.";
	}
	
	if(vEmpRec != null && vEmpRec.size() > 0){
		vRetResult = PRRetLoan.getEmployeeLedger(dbOP,request);
	}
%>
<body bgcolor="#D2AE72" onLoad="FocusID()" class="bgDynamic">
<form action="./fs_ledger.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL : SALARY INFORMATION PAGE ::::</strong></font></div></td>
    </tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">Employee ID</td>
      <td width="19%"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="65%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
		</td>
    </tr>
  </table>
<%if(vEmpRec != null && vEmpRec.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="25%" height="18">&nbsp; </td>
      <td> <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id")+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=1>";%> <%=WI.getStrValue(strTemp)%> <br> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%> <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
        <%=new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> <br></td>
      <td width="25%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
  </table>
 
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td width="11%" height="25" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="40%" align="center" bgcolor="#B9B292" class="thinborder"><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>COLLECTED 
          BY (ID) </strong></font></div></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <tr > 
      <td height="25" class="thinborder"><%=strTransDate%></td>
      <td class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <tr > 
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <tr > 
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <tr > 
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>   
  </table>
  <%}//if vRetResult.size() > 0

}//only if(vEmpRec != null && vEmpRec.size() > 0) %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="print_page" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>