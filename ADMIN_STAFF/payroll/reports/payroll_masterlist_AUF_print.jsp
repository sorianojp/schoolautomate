<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<form name="form_">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","payroll_masterlist_AUF.jsp");
								
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"payroll_masterlist_AUF.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	Vector vSalPeriods = null;
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String strPayrollPeriod  = null;
	String strSchCode = dbOP.getSchoolIndex();
	String strTemp2= null;
	double dSalary = 0d;
	double dDivider = 0d;
	double dTemp = 0d;
	boolean bolPageBreak = false;
	
if(WI.fillTextValue("year_of").length() > 0){
  vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
}
if(WI.fillTextValue("searchEmployee").length() > 0) {	
	vSalPeriods = RptPay.getSalaryPeriod(dbOP);	
    vRetResult = RptPay.generateMasterlist(dbOP);
	  if(vRetResult == null){
	    strErrMsg = RptPay.getErrMsg();
  	  }else{
	    iSearchResult = RptPay.getSearchCount();
	  }
}
	if (vRetResult != null) {
	
		int i = 0; int iPage = 1; int iCount = 0; int iPeriod = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			

		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = (vRetResult.size()-1)/(6*iMaxRecPerPage);	
	    if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 iPeriod = 0;
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          </font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="5"><div align="center"><br>
        Payroll Master List
      </div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
	 <%
	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(; vSalaryPeriod != null && iPeriod < vSalaryPeriod.size(); iPeriod += 8) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(iPeriod))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(iPeriod + 6) +" - "+(String)vSalaryPeriod.elementAt(iPeriod + 7);
          }
		 }
		%>	  
      <td height="24"><div align="center"><strong><font color="#000000">PAYROLL 
          DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
      <td height="24">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="4%" height="20" class="thinborder">&nbsp;</td>
      <td width="37%" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>SALARY</strong></font></div></td>
	  <%if(vSalPeriods != null && vSalPeriods.size() > 0){
		dDivider = 0d;
	  	for(int k = 0;k < vSalPeriods.size(); k+=2,dDivider++){
		strPayrollPeriod = (String)vSalPeriods.elementAt(k) +" - "+(String)vSalPeriods.elementAt(k+1);
	  %>
      <td class="thinborder"><div align="center"><%=strPayrollPeriod%></div></td>
	  <%}
	  }%>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=6,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
    <tr> 
      <td height="22" class="thinborder"><div align="right"><%=iIncr%></div></td>
      <td class="thinborder"><div align="left"><font size="1"><strong>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></div></td>
      <%if (vRetResult != null && vRetResult.size() > 0){			
		  strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);
		  dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""))/dDivider;
		}
	  %>
      <td class="thinborder"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	  <%for(int j = 0;j < dDivider; j++){%>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</div></td>
	  <%}%>
    </tr>
    <%} // end for loop%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>  
  <input type="hidden" name="reset_page">
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>