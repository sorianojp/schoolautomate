<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig, payroll.PReDTRME,
									payroll.PRMiscDeduction, payroll.OvertimeMgmt, payroll.PRSalary"%>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<body onLoad="javscript:window.print();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
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
		CommonUtil comUtil = new CommonUtil();
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"overtime_encoding_print.jsp");
		
		if(iAccessLevel == 0){//NOT AUTHORIZED.
			dbOP.cleanUP();
			response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
			return;
		}	
		
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-configuration-OT Rate","overtime_encoding.jsp");
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
	
	PayrollConfig Pconfig = new PayrollConfig();
	PReDTRME prEdtrME = new PReDTRME();
	OvertimeMgmt OTMgmt = new OvertimeMgmt();
	PRSalary Salary = new PRSalary();
	
	Vector vRetResult = null;
	Vector vPersonalDetails = null;
	Vector vEmpList         = null;
	Vector vSalaryPeriod 	= null;//detail of salary period.
	Vector vTypes = null;
	Vector vSalaryDetails = null;
		
	String strEmpID = WI.fillTextValue("emp_id");
	String strPageAction = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
	String[] astrRateType = {"%","Flat Rate", "Specific Rate"};
	String strPayrollPeriod = null;
	String strSalDateFr = null;
	String strSalDateTo = null;
	double dHourlyRate = 0d;
	double dTotalOT = 0d;
	
	int iTotalHours = 0;
	int iTotalMin = 0;
	int iTemp = 0;
		
	enrollment.Authentication authentication = new enrollment.Authentication();
	vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
			
	vRetResult  = OTMgmt.operateOnOvertimeEncoding(dbOP,request,4);	
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
		strTemp = WI.fillTextValue("sal_period_index");		

		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
					//strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) + " - " +(String)vSalaryPeriod.elementAt(i + 7);
					strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
					break;
			 }
		 }	
%>
<form name="form_">
	<%if (vPersonalDetails !=null && vPersonalDetails.size() > 0) {%>	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td>Employee Name : </td>
      <td><strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Employee ID : </td>
      <td><strong>&nbsp;<%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : </td>
      <%
		strTemp = (String)vPersonalDetails.elementAt(13);
		if (strTemp == null){
			strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}else{
			strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
		}
		%>
      <td><strong>&nbsp;<%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Employment Type/Position : </td>
      <td><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="25%">Employment Status<strong> : </strong></td>
      <td width="72%"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td  height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
	<%}%>
<%if (vRetResult!=null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" class="thinborder"><strong><font color="#000000">:: 
          LIST OF OVERTIME FOR THE PAY PERIOD  <%=WI.getStrValue(strPayrollPeriod,"")%> ::</font></strong></td>
    </tr>
    <tr> 
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>COUNT</strong></font></td>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>CODE</strong></font></td>
      <td width="40%" height="25" align="center" class="thinborder"><strong>NAME</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>RATE</strong></td>
      <td width="18%" align="center" class="thinborder"><strong>WORKED DURATION </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>OVERTIME 
      PAY </strong></td>
    </tr>
    <%//System.out.println("vRetResult " +vRetResult);		
	for(int i = 0,iCount = 1; i < vRetResult.size();i +=13,iCount++){%>
    <tr>
      <td align="right" valign="top" class="thinborder"><%=iCount%>&nbsp;</td>
      <td valign="top" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td valign="top" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td align="right" valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%> <%=astrRateType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+4),"0"))]%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				iTemp = Integer.parseInt(ConversionTable.replaceString(strTemp,",",""));				
				if(iTemp == 0)
					strTemp = "";
				iTotalHours += iTemp;

				strTemp2 = (String)vRetResult.elementAt(i+11);				
				iTemp = Integer.parseInt(ConversionTable.replaceString(strTemp2,",",""));				
				iTotalMin += iTemp;
			%>
      <td align="right" valign="top" class="thinborder"><%=WI.getStrValue(strTemp,"", " hr(s) and","")%>&nbsp;<%=WI.getStrValue(strTemp2,"", " min ","")%></td>			
			<%
				strTemp = (String)vRetResult.elementAt(i+7);
				strTemp = ConversionTable.replaceString(strTemp,",","");
				dTotalOT +=  Double.parseDouble(strTemp);
			%>
      <td align="right" valign="top" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true),"&nbsp;")%>&nbsp;</td>
    </tr>
		<%}%>
    
    <tr> 
      <td height="26" valign="top" class="thinborder">&nbsp;</td>
      <td height="26" valign="top" class="thinborder">&nbsp;</td>
      <td height="26" class="thinborder">&nbsp;</td>
      <td height="26" align="center" class="thinborder"><strong>TOTAL :</strong></td>
			<%
				iTotalHours +=  iTotalMin / 60;				
				iTotalMin = iTotalMin % 60;
				strTemp = Integer.toString(iTotalHours);
				
				if(iTotalHours == 0)
					strTemp = "";				
				strTemp2 = Integer.toString(iTotalMin);				
			%>
      <td height="26" align="right" class="thinborder"><%=WI.getStrValue(strTemp,"", " hr(s) and","")%>&nbsp;<%=WI.getStrValue(strTemp2,"", " min ","")%>&nbsp;</td>
      <td height="26" align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalOT,true)%>&nbsp;</td>
    </tr>
  </table>
<%} // if vRetResult != null%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>