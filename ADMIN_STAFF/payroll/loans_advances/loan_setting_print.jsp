<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
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
<title>Print internal loans setting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function PageAction(strPageAction, strInfoIndex,strCode){	
	document.form_.print_page.value = "";
	if (strPageAction == 0){
		var vProceed = confirm('Delete '+strCode+' ?');
		if(vProceed){
			document.form_.page_action.value = strPageAction;
			document.form_.info_index.value = strInfoIndex;
			document.form_.prepareToEdit.value = "";
			this.SubmitOnce('form_');
		}		
	}else{	
		document.form_.page_action.value = strPageAction;
		document.form_.info_index.value = strInfoIndex;
		document.form_.prepareToEdit.value = "";
		this.SubmitOnce("form_");
	}
}

function PrepareToEdit(strInfoIndex){	
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.proceed.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
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
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","sched_total_monthly_payments.jsp");
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

	//end of authenticaion code.	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	Vector vRetResult = null;
	String[] astrTermUnit = {"months","years"};
	String strLoanType = WI.fillTextValue("loan_type");	
	vRetResult = PRRetLoan.operateOnLoanCode(dbOP,request,4);

%>
<body onLoad="javascript:window.print();">
<form name="form_" method="post" action="./loan_setting_print.jsp">
  <%if(vRetResult != null && vRetResult.size() > 0){%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5" align="center" class="BorderAll"><font color="#000000"><strong> 
      LIST OF EXISTING LOANS IN RECORD</strong></font></td>
    </tr>
    <tr> 
	  <%if(strLoanType.equals("2") && bolIsSchool){%>
      <td width="11%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">SCHOOL 
      YEAR </font></strong></td>
	   <%}%>
      <td width="13%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN 
      CODE</font></strong></td>
      <td width="26%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN 
      NAME</font></strong></td>
	  <%if(strLoanType.equals("2")){%>
      <td width="16%" align="center" class="BorderBottomLeft"><font size="1"><strong>MAXIMUM 
      TERM OF PAYMENT</strong></font></td>
      <td width="20%" align="center" class="BorderBottomLeftRight"><strong><font size="1">INTEREST</font></strong></td>
	  <%}%>
    </tr>
    <%for(int i = 0; i < vRetResult.size();i+=14){%>
    <tr> 
	  <%if(strLoanType.equals("2") && bolIsSchool){%>
      <td align="center" class="BorderBottomLeft"><%=WI.getStrValue((String)vRetResult.elementAt(i+2))%><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"-","","&nbsp;")%> </td>
	  <%}%>
      <td height="25" class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
	  <%if(strLoanType.equals("2")){%>
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+12)%>&nbsp;<%=astrTermUnit[Integer.parseInt((String)vRetResult.elementAt(i+13))]%></td>
      <td class="BorderBottomLeftRight">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
	  <%}%>
    </tr>
    <%}// end for loop%>
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>
	<%}%>
  <input type="hidden" name="loan_type" value="2">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>