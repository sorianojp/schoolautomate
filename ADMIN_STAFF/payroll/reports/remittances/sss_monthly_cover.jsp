<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SSS Monthly Remittance Cover</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	int iSearchResult = 0;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","sss_monthly_cover.jsp");

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
														"sss_monthly_cover.jsp");
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

Vector vRetResult = null;
Vector vEmployerInfo = null;
PRRemittance PRRemit = new PRRemittance(request);

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
int i = 0;
String strTotalRec = null;
String strRemittance = null;
	
	if(WI.fillTextValue("is_for_loan").equals("1"))
		vRetResult = PRRemit.SSSMonthlyLoan(dbOP, true);
	else
  	vRetResult = PRRemit.SSSMonthlyPremium(dbOP, true);
		
 	//System.out.println("vRetResult--------  " + vRetResult);
 	
	if(vRetResult != null && vRetResult.size() > 3){
		vEmployerInfo = (Vector)vRetResult.elementAt(0);			
		strTotalRec = (String)vRetResult.elementAt(1);	
		strRemittance = (String)vRetResult.elementAt(2);	
	}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" height="710" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="6" align="center"><font size="2"><strong>
			  <%if(vEmployerInfo != null){
					strTemp = (String) vEmployerInfo.elementAt(12);
					strTemp += "<br>" + (String) vEmployerInfo.elementAt(3) + "<br>";
				%>
        <%=strTemp%>
        <%}else{%>
        <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <%}%>
      </font></td>
		</tr>
		<tr>
		  <td colspan="6" align="center">&nbsp;</td>
	  </tr>
		<tr>
		  <td colspan="6" align="center">&nbsp;</td>
	  </tr>
		<tr>
		  <td colspan="6" align="center">&nbsp;</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
	    <td><strong>TRANSMITTAL LIST </strong></td>
	    <td width="15%">&nbsp;</td>
	    <td width="9%">&nbsp;</td>
	    <td width="8%">&nbsp;</td>
	    <td width="22%">&nbsp;</td>
		</tr>
		<tr>
		  <td colspan="6">&nbsp;</td>
	  </tr>
		<tr>
		  <td colspan="6">&nbsp;</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>ER ID No. </td>
		  <td>&nbsp;</td>
		  <%
			if(vEmployerInfo != null && vEmployerInfo.size() > 0)
				strTemp = (String)vEmployerInfo.elementAt(6);
			else
				strTemp = "";
		%>		 
	    <td colspan="3">&nbsp;<%=strTemp%></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>Billing Month </td>
		  <td>&nbsp;</td>
		  <td colspan="3">&nbsp;<%=Integer.parseInt(WI.fillTextValue("month_of")) + 1%>,&nbsp;<%=WI.fillTextValue("year_of")%></td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>Total No. of Records </td>
		  <td>&nbsp;</td>
		  <td colspan="3">&nbsp;<%=WI.getStrValue(strTotalRec,"0")%></td>
	  </tr>
		<tr>
		  <td colspan="3">&nbsp;</td>
		  <td colspan="3">&nbsp;</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>REMITTANCE</td>
		  <td>&nbsp;</td>
		  <td colspan="3">&nbsp;<%=WI.getStrValue(strRemittance,"0")%></td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>Trans/SBR No. </td>
		  <td>&nbsp;</td>
		  <td colspan="3">&nbsp;<%=WI.fillTextValue("sbr_no")%></td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>Date Paid </td>
		  <td>&nbsp;</td>
		  <td colspan="3">&nbsp;<%=WI.getTodaysDate(1)%></td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="4" align="center">&nbsp;</td>
	  </tr>
		<tr>
		  <td width="3%">&nbsp;</td>
		  <td width="43%">&nbsp;</td>
		  <td colspan="4" align="center">Certified Correct </td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
			<%				
				strTemp = WI.fillTextValue("certified_by");
			%>						
		  <td colspan="4" align="center" class="thinborderBOTTOM"><%=WI.getStrValue(strTemp).toUpperCase()%></td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="4" align="center">Company Authorized Representative </td>
	  </tr>
		<tr>
		  <td height="17" colspan="6"><hr size="1" color="#000000"></td>
	  </tr>
		<tr>
		  <td height="17" colspan="6">To be filled up by SSS Personnel </td>
	  </tr>
		<tr>
		  <td height="22">&nbsp;</td>
		  <td>Received by </td>
	    <td colspan="3" class="thinborderBOTTOM">&nbsp;:</td>
	    <td>&nbsp;</td>
		</tr>
		<tr>
		  <td height="22">&nbsp;</td>
		  <td>&nbsp;</td>
	    <td colspan="3" class="thinborderBOTTOM">&nbsp;</td>
	    <td>&nbsp;</td>
		</tr>
		<tr>
		  <td height="22">&nbsp;</td>
		  <td>&nbsp;</td>
	    <td colspan="3" class="thinborderBOTTOM">&nbsp;</td>
	    <td>&nbsp;</td>
		</tr>
		<tr>
		  <td height="22">&nbsp;</td>
		  <td>Remarks : </td>
		  <td colspan="2">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
	    <td colspan="5" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
		<tr>
		  <td>&nbsp;</td>
	    <td colspan="5" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
		<tr>
		  <td>&nbsp;</td>
	    <td colspan="5" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
		
		<tr>
		  <td>&nbsp;</td>
		  <td height="30">Diskette returned to ER : </td>
		  <td colspan="2" align="center" valign="top">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td height="30">&nbsp;</td>
		  <td colspan="4" align="center" valign="top" class="thinborderTOP">Printed name </td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td height="30">&nbsp;</td>
		  <td colspan="4" align="center" valign="top" class="thinborderTOP">Signature</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td colspan="4" align="center" valign="top" class="thinborderTOP">Date</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>Other Documents : (Specify) </td>
		  <td colspan="2">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>1. DISKETTE </td>
		  <td colspan="2">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>2. INVALID ENTRIES</td>
		  <td colspan="2">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>3. TRANSMITTAL/RECEIPT </td>
		  <td colspan="2">&nbsp;</td>
		  <td colspan="2">&nbsp;</td>
	  </tr>
  </table> 	
	<input type="hidden" name="employer_index" value="<%=WI.fillTextValue("employer_index")%>">
	<input type="hidden" name="month_of" value="<%=WI.fillTextValue("month_of")%>">
	<input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>">
	<input type="hidden" name="code_index" value="<%=WI.fillTextValue("code_index")%>">	
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>