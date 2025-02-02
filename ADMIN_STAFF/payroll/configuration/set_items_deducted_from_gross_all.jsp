<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAYROLL: SET ITEMS DEDUCTED FROM GROSS INCOME FOR TAX COMPUTATION</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderBOTTOM{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--

function CloseWindow(){
	self.close();
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

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./set_items_deducted_from_gross_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month  Pay Parameters","set_items_deducted_from_gross.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"set_items_deducted_from_gross.jsp");
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
Vector vRetResult = null;

PayrollConfig pr = new PayrollConfig();


vRetResult = pr.operateOnGrossIncDeduct(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}

String[] astrDeductGrossInc = {"SSS","PAG-IBIG","Philhealth","COLA/ECOLA","GSIS"};

%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="set_items_deducted_from_gross_all.jsp" method='post' name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: ITEMS DEDUCTED FROM GROSS INCOME FOR TAX COMPUTATION PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="100%" height="25"> &nbsp;<a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0"></a>&nbsp; 
      &nbsp;<%=WI.getStrValue(strErrMsg,"<font size='3' color='#FF0000'><strong>","</strong></font>","")%></td>
  </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td>
<%if (vRetResult != null) {%> <div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a>click 
        to print list</font></div>
      <%}%> </td>
  </tr>
</table>
  <% if (vRetResult != null) {  %>
  
<table width="100%" border="0" cellpadding="3" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td height="25" colspan="2" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST 
        OF ITEMS DEDUCTED FROM GROSS INCOME FOR TAX COMPUTATION</strong></div></td>
  </tr>
  <% for (int i  = 0; i < vRetResult.size(); i+=3) {  
	if ((String)vRetResult.elementAt(i+1) != null) { %>
  <tr> 
    <td height="25" colspan="2" class="thinborder">&nbsp;YEAR : <strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
  </tr>
  <%} // end if %>
  <tr> 
    <td width="44" class="thinborder">
    <td width="640" height="25" class="thinborderBOTTOM"> &nbsp;&gt;&gt; &nbsp;<%=astrDeductGrossInc[Integer.parseInt((String)vRetResult.elementAt(i+2))]%> </tr>
  <% } //end for int i = 0 loop%>
</table>
<%} //  vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>