<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>

<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","report_schedule5_print.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"report_schedule5_print.jsp");
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

	ReportPayroll AtcCode = new ReportPayroll(request);
	Vector vRetResult = null;
	vRetResult = AtcCode.operateOnFinalTaxPayees(dbOP, 4);
%>
<body onLoad="javascript:window.print();">
<form action="report_schedule5_print.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2"><div align="center"><font size="1"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          Office of the Treasurer</font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="2" valign="bottom"><div align="center"><font color="#000000" size="1" ><strong>Schedule 
          5 Alphalist of Payees Subject to Final Withholding Tax (Reported Under 
          Form 2306)</strong></font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="23" colspan="2" valign="top"><div align="center"><font size="1">From 
          Whom Taxes Have Been Witheld for the Taxable Year <%=WI.fillTextValue("year_of")%></font></div></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="14"><div align="right"></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td class="thinborderBottom" width="3%" rowspan="2"><div align="center">Nbr.</div></td>
      <td class="thinborderBottom" width="9%" rowspan="2"><div align="center">TIN 
          #</div></td>
      <td height="21" colspan="3"><div align="center"><font size="1">NAME OF PAYEES</font></div></td>
      <td class="thinborderBottom" width="5%" rowspan="2"><div align="center">ATC 
          Code</div></td>
      <td class="thinborderBottom" width="12%" rowspan="2"><div align="center">Nature 
          of Income<br>
          . . . Payment . . .</div></td>
      <td class="thinborderBottom" width="8%" rowspan="2"><div align="right"><font color="#000000">Amount 
          of Income Payment</font></div></td>
      <td class="thinborderBottom" width="5%" rowspan="2"><div align="right">Tax 
          Rate</div></td>
      <td class="thinborderBottom" width="7%" rowspan="2"><div align="right">Amount 
          of Tax Withheld</div></td>
    </tr>
    <tr> 
      <td class="thinborderBottom" width="15%" height="22">Last Name</td>
      <td class="thinborderBottom" width="16%">First Name</td>
      <td class="thinborderBottom" width="13%">Middle Name</td>
    </tr>
    <% int iCount = 1;
	for(int i = 0;i < vRetResult.size(); i+=12,iCount++){%>
    <tr> 
      <td height="18"><font size="1">&nbsp;<%=iCount%> .</font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <%if(((String)vRetResult.elementAt(i+2)).equals("0")){%>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
      <%}else{%>
      <td colspan="3"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <%}%>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+8)%></font></td>
      <td width="2%"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%></font></div></td>
      <td width="2%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"","%","")%></font></div></td>
      <td width="3%"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+11),true)%></font></div></td>
    </tr>
    <%}%>
  </table>
  <%}// end if vRetResult != null%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr> 
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>