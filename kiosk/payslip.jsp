<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" 
				 buffer="16kb"%>
<%
	WebInterface WI = new WebInterface(request);
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	String[] strColorScheme = CommonUtil.getColorScheme(9);
	//strColorScheme is never null. it has value always.
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Payslip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript" src="../jscript/date-picker.js"></script>
<script language="JavaScript" src="../Ajax/ajax.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function PrintFromMyHome(strSalIndex, strSalPeriodIndex){
	document.form_.print_pg.value = "1";
	document.form_.sal_index.value = strSalIndex;
	document.form_.sal_period_index.value = strSalPeriodIndex;	
	this.SubmitOnce('form_');	
}

 
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	String strEmpID = (String)request.getSession(false).getAttribute("userId");

if(strUserID == null)//for fatal error.
{%>
		<font size="5" color="#0000FF">You are already logged out. Please login again.</font>
	<%
		return;
}
	if(WI.fillTextValue("print_pg").equals("1")){%>
		<jsp:forward page="payslip_print.jsp"/>
	<%return;}
		
	
//add security here.
try
	{
		dbOP = new DBOperation();
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
int iAccessLevel = 2;
//end of authenticaion code.
PReDTRME prEdtrME = new PReDTRME();
EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();

Vector vRetResult = null;
ReportPayroll RptPay = new ReportPayroll(request);
int iItems = 0;

  vRetResult = RptPay.searchRegularPaySlip(dbOP);  
	if(vRetResult == null){
		strErrMsg = RptPay.getErrMsg();
	}else{	
		iSearchResult = RptPay.getSearchCount();
	}
 if(strErrMsg == null) 
	 strErrMsg = "";
%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./payslip.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">    
    <tr bgcolor="#FFFFFF"> 
      <td width="14%" height="25" align="right">Year&nbsp; </td>
      <td width="86%" height="25"><select name="year_of" onChange="javascript:SearchEmployee();">
        <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
      </select></td>
    </tr>
  </table>  
	<% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">    	
    
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" colspan="2" align="center"><strong>EMPLOYEE 
        ID</strong></td>
      <td class="thinborder" width="29%" align="center"><strong>EMPLOYEE NAME</strong></td>
			<%
				strTemp = "SALARY PERIOD";
			%>
      <td class="thinborder" width="36%" align="center">&nbsp;<%=strTemp%></td>
      <td class="thinborder" width="15%" align="center"><strong>PRINT</strong></td>
    </tr>
    <% 	//System.out.println("vRetResult " +vRetResult);
	for(int i = 0,iCount=1; i < vRetResult.size(); i += 27,++iCount){		
	%>
    <tr bgcolor="#FFFFFF" class="thinborder"> 
      <td class="thinborder" width="4%">&nbsp;<%=iCount%>.</td>
      <td class="thinborder" width="16%" height="25">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder" >&nbsp;<%=(String)vRetResult.elementAt(i + 2)%>, 
     <%=(String)vRetResult.elementAt(i + 1)%> </td>
    <%
			strTemp2 = (String)vRetResult.elementAt(i + 19) + " - " + (String)vRetResult.elementAt(i + 20);
		%>
      <td class="thinborder">&nbsp;<%=strTemp2%></td>
      <td class="thinborder" align="center">
		<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15),"0");
		if(strTemp.equals("1")){%>
		  <a href="javascript:PrintFromMyHome('<%=vRetResult.elementAt(i+7)%>','<%=vRetResult.elementAt(i+16)%>');"><img src="../images/view.gif" width="40" height="31" border="0"></a>
			<input type="hidden" name="is_printed" value="1">
		<%}else{%>
			Not yet enabled by HR		
		  <%}%>		</td>
    </tr>
    <%} // end for loop%>	
  </table>
  <%} // end if vRetResult != null && vRetResult.size() %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
  <input type="hidden" name="sal_index" value="">
	<input type="hidden" name="sal_period_index">
	<input name="emp_id" type= "hidden" value="<%=(String)request.getSession(false).getAttribute("userId")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>