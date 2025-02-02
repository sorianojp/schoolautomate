<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Increment Lists</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
    TD.noBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" 	method="post" action="./emplist_salary_inc.jsp">
<%  WebInterface WI = new WebInterface(request);

	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
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
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","encode_salary_inc.jsp");
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

	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String[] astrPTFT = {"Part-Time", "Full-time"};
	String[] astrType = {"Staff", "Faculty","Staff with Teaching Load"};
	String strPageAction = WI.fillTextValue("page_action");

	vRetResult = RptPay.operateOnIncrement(dbOP,5);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="23" colspan="3" class="footerDynamic">&nbsp;</td>
    </tr>
    <tr> 
      <td width="100%" height="23" colspan="3"><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>  
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">LIST 
      OF EMPLOYEES RECORDS</font></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="13%" height="25" align="center" ><strong><font size="1">EMPLOYEE 
      ID</font></strong></td>
      <td width="46%" align="center"><strong><font size="1">NAME</font></strong></td>
      <td width="25%" align="center"><strong><font size="1">EMPLOYMENT STATUS</font></strong></td>
      <td width="16%" align="center"><strong><font size="1">EMPLOYMENT TYPE</font></strong></td>
	  <!--
      <td width="10%"><div align="center"><strong><font size="1">SELECT ALL</font><br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
          </strong></div></td>
	-->
    </tr>
    <% int iCount = 0;
	   int iMax = 1;
	for(i = 0 ; i < vRetResult.size(); i +=7,iCount++,iMax++){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td height="25"><font size="1"><%=WI.formatName(((String)vRetResult.elementAt(i+2)).toUpperCase(), (String)vRetResult.elementAt(i+3),
							((String)vRetResult.elementAt(i+4)).toUpperCase(), 4)%></font></td>
      <%
	  	if(vRetResult.elementAt(i + 5) != null){
			strTemp = (String) vRetResult.elementAt(i + 5);
			strTemp = astrPTFT[Integer.parseInt(strTemp)];
		}else{
			strTemp = "";
		}
	  %>
      <td><%=WI.getStrValue(strTemp,"No Service Record")%></td>
      <%
	  	if(vRetResult.elementAt(i + 6) != null){
			strTemp = (String) vRetResult.elementAt(i + 6);
			strTemp = astrType[Integer.parseInt(strTemp)];
		}else{
			strTemp = "";
		}
	  %>
      <td><%=WI.getStrValue(strTemp,"No Service Record")%></td>
	  <!--
      <td> <div align="center">
          <input type="checkbox" name="user_<%=iCount%>" value="1">
          <input type="hidden" name="user_index_<%=iCount%>" value="<%=vRetResult.elementAt(i)%>">
        </div></td>
	  -->
    </tr>
    <%}//end of for loop to display employee information.%>
	<input type="hidden" name="max_display" value="<%=iMax%>">
  </table>  
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>  
  <input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
  <input type="hidden" name="employee_category" value="<%=WI.fillTextValue("employee_category")%>">
  <input type="hidden" name="pt_ft" value="<%=WI.fillTextValue("pt_ft")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>