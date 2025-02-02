<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRLoansAdv" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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

-->
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS/ADVANCES-Print Entries","loans_advances_entry_print.jsp");
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
														"Payroll","LOANS/ADVANCES",request.getRemoteAddr(),
														"loans_advances_entry_print.jsp");
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
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vInfoDetail = null;

PRLoansAdv prd = new PRLoansAdv(request);

String[]  astrSchedDeduct={
	"Every Salary Period", "Every 5th of Month", "Every 15th of Month", "Every 20th of Month",
"Every end of Month", "Every Week", "End of Term"};


if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}
}


vRetResult = prd.operateOnLoansAdv(dbOP,request,4);
if (vRetResult == null && strErrMsg == null){
	strErrMsg = prd.getErrMsg();
}

%>


<body onLoad="javascript:window.print();">
  <% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>

	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> <td  colspan="3">
  <div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
	<font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
	<font size="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div>
	</td>  
	</tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="6%" height="22">&nbsp;</td>
      <td width="43%" height="22">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> </td>
      <td width="51%" align="right">Date and Time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td height="22" colspan="2">Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong> <input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>"></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="22" colspan="2"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td colspan="2">Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td colspan="2">Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>
    </tr>
  </table>
<% 	if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="10" class="thinborder"><div align="center"><strong>ADVANCES/DEDUCTIONS 
          STATUS </strong></div></td>
    </tr>
    <tr> 
      <td height="28" colspan="4" class="thinborder"><strong><font size="1">TOTAL APPLIED ADVANCES/DEDUCTIONS 
        : <font color="#0000FF" size="2"><%=(String)vRetResult.elementAt(0)%></font></font></strong></td>
      <td height="28" colspan="4" class="thinborder"><font size="1"><strong>TOTAL ACTIVE APPLIED 
        ADVANCES/DEDUCTIONS : <font color="#FF9900"><%=(String)vRetResult.elementAt(1)%></font></strong></font></td>
      <td height="28" colspan="2" class="thinborder"><font size="1"><strong>CURRENT 
        BALANCE :<br>
        <font color="#FF0000">Php <%=CommonUtil.formatFloat((String)vRetResult.elementAt(2),true)%></font></strong></font></td>
    </tr>
    <tr> 
      <td width="3%" class="thinborder"><div align="center"><strong><font size="1">LOAN</font></strong></div></td>
      <td width="5%" height="28" class="thinborder"><div align="center"><font size="1"><strong>DATE 
          APPLIED</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>APPLICATION NO.</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>AMOUNT APPLIED</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>DATE APPROVED</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>TERMS </strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>SCHEDULE OF DEDUCTION</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>START OF DEDUCTION</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>DUE PER DEDUCTION</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>BALANCE</strong></font></div></td>
    </tr>
    <% for (int i = 3; i < vRetResult.size() ; i+=18){ 

	%>
    <tr> 
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+6)%></font></div></td>
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></div></td>
      <td width="4%" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+10)%></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><%=astrSchedDeduct[Integer.parseInt((String)vRetResult.elementAt(i+11))]%></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+12)%></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+13),true)%></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+15),true)%></font></div></td>
    </tr>
    <%}%>
  </table>
<%}}%>
</body>
</html>
<%
dbOP.cleanUP();
%>