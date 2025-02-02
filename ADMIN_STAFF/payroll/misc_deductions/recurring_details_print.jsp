<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction, payroll.PReDTRME" %>
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
<title>print Recurring deductions payment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
 
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
Vector vEmpList = null;
Vector vDate = null;
double dTemp = 0d;
double dTotal = 0d;

PRMiscDeduction prd = new PRMiscDeduction(request);
	
	String strSchCode = dbOP.getSchoolIndex();

	int iSearchResult = 0;
	int i = 0;
	Vector vEmpInfo = null; 	
 	vRetResult = prd.getRecurringDetails(dbOP, request, WI.fillTextValue("post_deduct_index"));
	if(vRetResult != null && vRetResult.size() > 0)
		vEmpInfo = (Vector)vRetResult.elementAt(0);
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%> </font></div></td>
    </tr>
    <tr> 
      <td height="10"><hr size="1"></td>
    </tr>
  </table>	
	<% if (vEmpInfo !=null && vEmpInfo.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="28">&nbsp;</td>
      <td width="96%" height="28">Employee Name : <strong><%=WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3),
							(String)vEmpInfo.elementAt(4), 4)%></strong></td>
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
    <td colspan="3" align="center"><table width="80%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
      <tr>
        <td height="20" colspan="3" align="center" class="thinborder"><strong><%=WI.fillTextValue("deduction_name").toUpperCase()%> DEDUCTIONS</strong></td>
      </tr>
      <tr>
        <td width="23%" height="20" align="center" class="thinborder">&nbsp;</td>
        <td width="42%" align="center" class="thinborder"><font size="1"><strong>DATE DEDUCTED</strong></font></td>
        <td align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
      </tr>
      <%
			int iCount = 1;
			for (i = 1; i < vRetResult.size(); i+=8,iCount++){%>
      <tr>
        <td height="19" class="thinborder" align="center"><%=iCount%>&nbsp;</td>
        <td width="42%" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
				<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true);
				dTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));				
				%>
        <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
      </tr>
      <%} //end for loop%>
			<tr>
        <td height="19" colspan="2" align="right" class="thinborder">TOTAL PAYMENTS : </td>        
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</td>
      </tr>      
    </table>		</td>
  </tr>
	<%if(WI.fillTextValue("remarks").length() > 0){%>
  <tr>
    <td width="10%" align="center">&nbsp;</td>
    <td colspan="2"><%=WI.fillTextValue("remarks")%></td>
  </tr>
  <tr>
    <td height="38" align="center">&nbsp;</td>
    <td width="29%" align="center" valign="bottom" class="thinborderBOTTOM"><%=WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3),
							(String)vEmpInfo.elementAt(4), 4)%></td>
    <td width="61%">&nbsp;</td>
  </tr>
  <tr>
    <td align="center">&nbsp;</td>
    <td align="center">Signature</td>
    <td>&nbsp;</td>
  </tr>
	<%}%>
</table>

  <% } // end vRetResult != null && vRetResult.size() > 0

}// end if Employee ID is null %>
  <input type="hidden" name="post_deduct_index" value="<%=WI.fillTextValue("post_deduct_index")%>">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
