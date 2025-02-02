<%@ page language="java" import="utility.*,payroll.PRSalaryRate, java.util.Vector, 
																 payroll.PRMiscDeduction, payroll.PRConfidential,
																 payroll.PRSalaryRate" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

boolean bolHasAUFStyle = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Rate</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
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
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-SALARY RATE"),"0"));
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
								"Admin/staff-Payroll-SALARY RATE-SALARY RATE","salary_rate.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		bolHasAUFStyle = (readPropFile.getImageFileExtn("HAS_AUF_STYLE","0")).equals("1");
 
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
//			dbOP.cleanUP();
//			throw new Exception();
		}								
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

 	PRSalaryRate RptPay = new PRSalaryRate();
	Vector vRetResult = null;
	Vector vEmpRec    = null;
	String strSchCode = dbOP.getSchoolIndex();
	String strCheck = null;
	double dPrevSal = 0d;
	double dNewSal = 0d;
 	boolean bolCheckAllowed = false;
  vRetResult = RptPay.getSalAdjustmentDetails(dbOP, WI.fillTextValue("salary_index"));
%>
<body onLoad="javascript:window.print();">
<form name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="54"><div align="center"><font size="1">Republic of the Philippines<br>			
			<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
			<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
			<%=SchoolInformation.getAddressLine2(dbOP,false,false)%><br><br>
			</font></div>      </td>
    </tr>
    
    <tr >
      <td height="14" align="center"><%=WI.fillTextValue("sal_adjust_office")%></td>
    </tr>
    <tr >
      <td height="31" align="center" valign="bottom">NOTICE OF SALARY ADJUSTMENT </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" align="right">&nbsp;</td>
      <td height="23" align="center">&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
    <tr>
      <td width="65%" height="23" align="right">&nbsp;</td>
      <td width="20%" height="23" align="center" class="thinborderBOTTOM"><%=WI.formatDate(WI.fillTextValue("notice_date"), 6)%></td>
      <td width="15%" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" align="right">&nbsp;</td>
      <td height="18" align="center">Date</td>
      <td align="right">&nbsp;</td>
    </tr>
  </table>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="6%" height="18">&nbsp;</td>
      <td width="94%"><%=WI.getStrValue((String)vRetResult.elementAt(34))%><%=WI.formatName(((String)vRetResult.elementAt(28)).toUpperCase(), (String)vRetResult.elementAt(29),
							((String)vRetResult.elementAt(30)).toUpperCase(), 7)%></td>
      </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(31)%></td>
		<%
			strTemp2 = WI.fillTextValue("emp_type"); 
		%> 			
      </tr>
    <tr>
      <td height="18">&nbsp;</td>
			<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(32), (String)vRetResult.elementAt(33));			
			%>
      <td><%=strTemp%></td>
    </tr>
  
    <tr>
      <td height="11" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="11" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11">Sir/Madam : </td>
      </tr>
    <tr>
      <td height="11" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11">Executive Order No. 811 dated June 17, 2009, your salary is hereby adjusted effective March 22, 2010, as follows : </td>
    </tr>
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11">&nbsp;</td>
    </tr>
    
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="5%">&nbsp;</td>
          <td>Adjusted daily basic salary effective March 22, 2010 under </td>
          <td width="10%">&nbsp;</td>
          <td width="24%">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <%
					 //for(int o = 0; o < 15; o++)
					 //	System.out.println(o + "-" + WI.formatDate("01/01/2011",o));
					%>
          <td width="61%" nowrap>the New Salary Schedule SG <%=(String)vRetResult.elementAt(21)%> Step <%=(String)vRetResult.elementAt(22)%></td>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(3), "0");
						dNewSal = Double.parseDouble(strTemp);
					%>
          <td align="right"><%=strTemp%></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>Actual daily basic salary as of </td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td> <u></u> March 22, 2010 SG <%=(String)vRetResult.elementAt(56)%> Step <%=(String)vRetResult.elementAt(57)%></td>
					<%
						strTemp = WI.getStrValue((String)vRetResult.elementAt(38), "0");
						dPrevSal = Double.parseDouble(strTemp);
					%>
          <td align="right"><%=strTemp%></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>Daily salary adjustment effective March 22, 2010 </td>
					<%
						strTemp = CommonUtil.formatFloat(dNewSal-dPrevSal, true);
					%>
          <td align="right">&nbsp;<%=strTemp%></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="39">&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11">&nbsp;&nbsp;&nbsp;&nbsp;This salary is subject to review and post audit by the Department of Budget and Management and subject to readjustment and refund if found not in order. </td>
    </tr>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="6%" height="46">&nbsp;</td>
    <td width="19%">&nbsp;</td>
    <td width="35%">&nbsp;</td>
    <td width="27%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
  </tr>
  
  <tr>
    <td height="20">&nbsp;</td>
    <td>Office</td>
    <td>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(32), (String)vRetResult.elementAt(33))%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Item No. </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Present Salary Grade </td>
    <td>&nbsp;<%=(String)vRetResult.elementAt(21)%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="52">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp; </td>
    <td>&nbsp; </td>
    <td align="center"><strong><%=WI.fillTextValue("signatory")%></strong></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp; </td>
    <td align="center"><%=WI.fillTextValue("position")%></td>
    <td>&nbsp;</td>
  </tr>
</table>

	<input type="hidden" name="inc_index" value="<%=WI.fillTextValue("inc_index")%>"> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
