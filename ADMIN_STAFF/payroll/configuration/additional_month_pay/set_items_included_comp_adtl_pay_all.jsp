<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAYROLL: SET ADDITIONAL MONTH PAY PARAMETERS : NUMBER OF MONTHS FOR ADDITIONAL MONTH PAY PAGE</title>
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

    TD.thinborderBottom {
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
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
<!--

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
	<jsp:forward page="./set_items_included_comp_adtl_pay_all_print.jsp" />
<% return;}

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
Vector vEditInfo = null;

PayrollConfig pr = new PayrollConfig();

vRetResult = pr.operateOnMonthPayComp(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}

String[] astrTypeLabel = {"Basic Salary","Gross Salary","Net Salary",""};
String[] astrOBI = {"Benefit", "Incentive", "Overtime",""};


%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./set_items_included_comp_adtl_pay.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: SET ADDITIONAL MONTH PAY PARAMETERS : ITEMS INCLUDED IN ADDITIONAL 
          MONTH PAY COMPUTATION PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%">&nbsp;</td>
      <td width="57%">&nbsp;</td>
      <td width="42%" height="10" align="right">&nbsp;
<%if (vRetResult != null) {%>
<font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0" ></a>click 
          to print list</font>
<%}%>
	 </td>
    </tr>
  </table>
  <% if (vRetResult != null) {  %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="2" align="center" bgcolor="#B9B292" class="thinborder">LIST OF 
          ITEMS INCLUDED IN THE COMPUTATION OF ADDITIONAL MONTH PAY</td>
    </tr>
    <tr> 
      <td height="26" colspan="2" align="center" class="thinborder"><strong>ITEMS</strong></td>
    </tr>
    <%  int j = 0 ; boolean bolShowHeaders = true;
	for (int i = 0; i < vRetResult.size(); i+=6 ){
		if ((String)vRetResult.elementAt(i+1) != null){
			bolShowHeaders = true; 	j = i;
		}
	if (bolShowHeaders) {
%>
    <tr> 
      <td height="25" colspan="2" class="thinborder" > &nbsp; 
        <% for (;j < vRetResult.size(); j+=6){
		if (vRetResult.elementAt(j+1) != null && j != i){	
			bolShowHeaders = false;
			break;
	    }else{%>
        <font color="#0000FF"><strong><%=WI.getStrValue((String)vRetResult.elementAt(j+1), ""," :: " ,"")/*year*/%>
		<%=astrTypeLabel[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(j+2),"3"))]/* salary type*/%>
		</strong> </font><%}//end if else  inner loop
	}// end innner for loop 
	bolShowHeaders = false;
	%> </td>
    </tr>
    <%} //end bolShowHeaders%>
    <tr> 
      <td width="50" class="thinborder">&nbsp;</td>
      <td width="730" height="25" class="thinborderBottom"> &gt;&gt; <% strTemp =(String)vRetResult.elementAt(i+5);
	   	if (strTemp == null)
			strTemp = astrOBI[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"3"))]/* O B I */ + WI.getStrValue((String)vRetResult.elementAt(i+5)," (",")","");/*sub - type*/
		if (strTemp.length() == 0)
			strTemp = "(" +  astrTypeLabel[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"3"))] + " only )" ;%> <%=strTemp%></td>
    </tr>
    <% } //end for int i = 0 loop%>
  </table>
<%} //  vRetResult != null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>