<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Schedule 5</title>
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
								"Admin/staff-Payroll-REPORTS-Post Deductions","report_schedule5_print.jsp");

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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
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
	boolean bolPageBreak = false;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int iLoop = 0;
	vRetResult = AtcCode.operateOnFinalTaxPayees(dbOP, 4);
	if(vRetResult != null ){
	for(iLoop = 2;iLoop < vRetResult.size();){
%>
<body onLoad="javascript:window.print();">
<form action="report_schedule5_print.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="2"><div align="center"><font size="1"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          Office of the Treasurer</font></div></td>
    </tr>
    <tr > 
      <td height="16" colspan="2" valign="bottom"><div align="center"><font color="#000000" size="1" ><strong>Schedule 
          5 Alphalist of Payees Subject to Final Withholding Tax (Reported Under 
          Form 2306)</strong></font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="18" colspan="2" valign="top"><div align="center"><font size="1">From 
          Whom Taxes Have Been Witheld for the Taxable Year <%=WI.fillTextValue("year_of")%></font></div></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
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
      <td class="thinborderBottom" width="15%" height="14">Last Name</td>
      <td class="thinborderBottom" width="16%">First Name</td>
      <td class="thinborderBottom" width="13%">Middle Name</td>
    </tr>
    <%
 	for(int i = 0; i <= iMaxStudPerPage; iLoop += 12,++i){
  		if (i >= iMaxStudPerPage || iLoop >= vRetResult.size()){
			if(iLoop >= vRetResult.size())
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;
	     }%>
    <tr> 
      <td height="11"><font size="1">&nbsp;&nbsp;<%=(iLoop+12)/12%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(iLoop)%></font></td>
      <%if(((String)vRetResult.elementAt(iLoop+1)).equals("0")){%>
      <td><font size="1"><%=(String)vRetResult.elementAt(iLoop+2)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(iLoop+3)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(iLoop+4)%></font></td>
      <%}else{%>
      <td colspan="3"><font size="1"><%=(String)vRetResult.elementAt(iLoop+2)%></font></td>
      <%}%>
      <td><font size="1"><%=(String)vRetResult.elementAt(iLoop+6)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(iLoop+7)%></font></td>
      <td width="2%"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+8),true)%></font></div></td>
      <td width="2%"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(iLoop+9),"","%","")%></font></div></td>
      <td width="3%"><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(iLoop+10),true)%></font></div></td>
    </tr>
    <%}%>
    <%	
   if (iLoop >= vRetResult.size()){
   %>
    <tr> 
      <td  class="thinborderBottom" height="10" colspan="10">&nbsp;</td>
    </tr>
    <tr> 
      <td  class="thinborder" height="18" colspan="9"><div align="left"></div>
        <div align="right"><strong>&nbsp; &nbsp;&nbsp;</strong></div>
        <div align="right"></div></td>
      <td height="18" class="thinborder"><div align="right"><font size="1"><%=CommonUtil.formatFloat(WI.getStrValue((Double)vRetResult.elementAt(0),"0"),true)%></font>&nbsp;</div></td>
    </tr>
    <tr> 
      <td colspan="10" class="thinborder" ><div align="center">
          <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr> 
              <td width="3%">&nbsp;</td>
              <td width="28%"><font size="1">Submitted by:</font></td>
              <td width="14%">&nbsp;</td>
              <td width="21%">&nbsp;</td>
              <td width="16%">&nbsp;</td>
              <td width="18%">&nbsp;</td>
            </tr>
            <tr> 
              <td height="18">&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
            </tr>
            <tr> 
              <td>&nbsp;</td>
              <td><div align="center"><font size="1"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></div></td>
              <td><div align="center"><strong><font size="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font></strong></div></td>
              <td><div align="center"><strong><font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></strong></div></td>
              <td><div align="center"><strong><font size="1"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"VP for Finance",1),"&nbsp;")%></font></strong></div></td>
              <td><div align="center"><strong><font size="1">VP-Finance &amp; 
                  Enterprises</font></strong></div></td>
            </tr>
            <tr> 
              <td>&nbsp;</td>
              <td valign="top"><div align="center"><font size="1">Name of Payor</font></div></td>
              <td valign="top"><div align="center"><font size="1">TIN</font></div></td>
              <td valign="top"><div align="center"><font size="1">Address of Payor</font></div></td>
              <td valign="top"><div align="center"><font size="1">Authorized Representative</font></div></td>
              <td valign="top"><div align="center"><font size="1">Title</font></div></td>
            </tr>
          </table>
        </div>
        </td>
    </tr>
    <%}else{%>
	<tr> 
      <td  class="thinborder" height="18" colspan="10"><hr color="#000000" size="1" ></td>
    </tr>
	<%}%>
  </table>
  <%}// end if vRetResult != null%>
  <%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END.
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }}%>
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