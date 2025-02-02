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
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month  Pay Parameters","set_num_of_mths_pay.jsp");
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
														"set_num_of_mths_pay.jsp");
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

<body onLoad="javascript:window.print();">
<%=WI.getStrValue(strErrMsg)%>
<% if (vRetResult != null) {  %>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          </font><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%> </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="3" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td height="25" colspan="2" class="thinborder"><div align="center"><strong>LIST 
        OF ITEMS DEDUCTED FROM GROSS INCOME FOR TAX COMPUTATION</strong></div></td>
  </tr>
  <% for (int i  = 0; i < vRetResult.size(); i+=3) {  
	if ((String)vRetResult.elementAt(i+1) != null) { %>
  <tr> 
    <td height="25" colspan="2" class="thinborder">&nbsp;YEAR :<font color="#FF0000"> <strong><%=(String)vRetResult.elementAt(i+1)%></strong></font></td>
  </tr>
  <%} // end if %>
  <tr> 
    <td width="44" class="thinborder">
    <td width="640" height="25" class="thinborderBOTTOM"> &nbsp;&gt;&gt; &nbsp;<%=astrDeductGrossInc[Integer.parseInt((String)vRetResult.elementAt(i+2))]%> </tr>
  <% } //end for int i = 0 loop%>
</table>
<%} //  vRetResult != null%>
</body>
</html>
<%
	dbOP.cleanUP();
%>