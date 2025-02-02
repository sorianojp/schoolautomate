<%@ page language="java" import="utility.*, java.util.Vector, 
																 payroll.PRMiscDeduction, payroll.PRConfidential,
																 payroll.ReportPayroll " %>
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
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../jscript/common.js"></script> 
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
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
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

	PRConfidential prCon = new PRConfidential();
	ReportPayroll RptPay = new ReportPayroll(request);
	Vector vRetResult = null;
	Vector vEmpRec    = null;
	String strSchCode = dbOP.getSchoolIndex();
	String strCheck = null;
	String[] astrRank = {"","1st","2nd","3rd"};
	boolean bolCheckAllowed = false;
  vRetResult = RptPay.getPeriodStepIncrements(dbOP, WI.fillTextValue("inc_index"));	
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
      <td height="18" align="center">&nbsp;</td>
    </tr>
    <tr >
      <td height="14" align="center">OFFICE OF THE VICE GOVERNOR</td>
    </tr>
    <tr >
      <td height="31" align="center" valign="bottom"><u>Notice of Step Increment</u></td>
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
      <td width="94%"><%=WI.formatName(((String)vRetResult.elementAt(4)).toUpperCase(), (String)vRetResult.elementAt(5),
							((String)vRetResult.elementAt(6)).toUpperCase(), 7)%></td>
      </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(9)%></td>
		<%
			strTemp2 = WI.fillTextValue("emp_type"); 
		%> 			
      </tr>
    <tr>
      <td height="18">&nbsp;</td>
			<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(7), (String)vRetResult.elementAt(8));			
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
      <td height="11">Dear : </td>
      </tr>
    <tr>
      <td height="11" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pursuant to joint Civil Service Commission (CSC) and Department of Budget and Management (DBM) Circular No. 1, s. 1990 implementing Section 13 @ of RA 6758, and Sangguniang Panlalawigan Resolution No. 046-2007, Adopting the 2007 Budget under General Fund Appropriation Ordinance No. 01-2007 dated March 20, 2007, re: grant of length of service step increment to qualified employees of the Provincial Government of Lanao del Norte, your salary as <u><%=WI.fillTextValue("position_name")%></u> is hereby adjusted effective <u><%=WI.formatDate((String)vRetResult.elementAt(11), 6)%></u>, as shown below : </td>
    </tr>
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11">&nbsp;</td>
    </tr>
    
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="6%">&nbsp;</td>
          <td colspan="2">Basic Monthly Salary </td>
          <td width="36%">&nbsp;</td>
          <td width="17%">&nbsp;</td>
          <td width="17%">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td width="3%">&nbsp;</td>
					<%
					 //for(int o = 0; o < 15; o++)
					 //	System.out.println(o + "-" + WI.formatDate("01/01/2011",o));
					%>
          <td width="21%" nowrap>As Of <u><%=WI.getStrValue(WI.formatDate((String)vRetResult.elementAt(18), 6))%></u></td>
          <td>&nbsp;</td>
          <td align="right"><u><strong><%=WI.getStrValue((String)vRetResult.elementAt(12))%></strong></u></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td colspan="2">Salary Adjustment </td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td colspan="2">Length of Service Increment (<u><%=WI.getStrValue((String)vRetResult.elementAt(19))%></u> years)
					<%
						int iRank = Integer.parseInt((String)vRetResult.elementAt(21));
						if(iRank <= 3)
							strTemp = astrRank[iRank];
						else
							strTemp = iRank+"th";
					%>
					<%=strTemp%> step of<u> G-<%=(String)vRetResult.elementAt(20)%></u> </td>
          <td align="right"><u><strong><%=WI.getStrValue((String)vRetResult.elementAt(10))%></strong></u></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11">&nbsp;&nbsp;&nbsp;&nbsp;This step increment is subject to review and post audit by the Department of Budget and Management and subject to readjustment and refund if found not in order. </td>
    </tr>
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="6%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
    <td width="47%">&nbsp;</td>
    <td width="20%">Very truly yours,</td>
    <td width="20%">&nbsp;</td>
  </tr>
  <tr>
    <td height="36">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><strong><%=WI.fillTextValue("signatory")%></strong></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><%=WI.fillTextValue("position")%></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Cc:</td>
    <td>GSIS</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>CSC Field Office </td>
    <td>&nbsp;</td>
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
