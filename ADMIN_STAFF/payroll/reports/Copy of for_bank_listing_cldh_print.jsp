<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
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
<style type="text/css"> 
    TD.thinborderBOTTOM {
    	border-bottom: solid 1px #000000;
  		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 10px;			
    }

		TD.thinborderNONE {
			font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
			font-size: 11px;
		}
		
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
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
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","for_bank_listing_cldh.jsp");
								
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
														"for_bank_listing_cldh.jsp");
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

String strSchCode = dbOP.getSchoolIndex();

//end of authenticaion code.
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	ReportPayrollExtn RptPayExtn = new ReportPayrollExtn(request);
	String strPayrollPeriod  = null;	
	String strTemp2 = null;
	double dSalary = 0d;	
	boolean bolLooped = false;
	String strPrevColl = "";
	String strPrevDept = "";
	String strCurColl = "";
	String strCurDept = "";
	boolean bolPageBreak  = false;
	double dPageTotal = 0d;
	
	vRetResult = RptPayExtn.generateBankRemitPerDept(dbOP);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);

	if (vRetResult != null && vRetResult.size() > 1) {	
	 int i = 0; int iPage = 1; int iCount = 0;
	 int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
	 int iNumRec = 1;//System.out.println(vRetResult);
	 int iIncr    = 1;
	 int iTotalPages = (vRetResult.size()-1)/(15*iMaxRecPerPage);	
	 if((vRetResult.size()-1) % (15*iMaxRecPerPage) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
		 	dPageTotal = 0d;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18" class="thinborderNONE"><strong>CENTRAL LUZON DOCTORS HOSPITAL - EDUCATIONAL INSTITUTION, INC. </strong></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18" class="thinborderNONE"><strong>BANK LIST </strong></td>
    </tr>
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <% if (vRetResult!= null && vRetResult.size() > 1){
		strTemp = (String)vRetResult.elementAt(0);			
		}
	%>
      <td width="97%" height="18" class="thinborderNONE"><strong>Bank : <%=WI.getStrValue(strTemp," ")%></strong></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18" class="thinborderNONE"><strong>Pay Class : FULL TIME </strong></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
			<%
			strTemp = WI.fillTextValue("sal_period_index");		
	
			for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
						//strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) + " - " +(String)vSalaryPeriod.elementAt(i + 7);
						strPayrollPeriod =(String)vSalaryPeriod.elementAt(i + 7);
						break;
				 }
			 }
			%>			
      <td height="18" class="thinborderNONE"><strong>Payroll Period : <%=WI.getStrValue(strPayrollPeriod,"")%></strong></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" align="center" class="thinborderNONE">&nbsp;</td>
      <td width="2%" align="center" class="thinborderNONE">&nbsp;</td>
      <td width="26%" align="center" class="thinborderNONE"><strong>DEPT.</strong></td>
      <td width="32%" align="center" class="thinborderNONE"><strong> NAME</strong></td>
      <td width="2%" align="center" class="thinborderNONE">&nbsp;</td>
      <td width="18%" align="center" class="thinborderNONE"><strong>BANK ACCOUNT </strong></td>
      <td width="3%" align="center" class="thinborderNONE">&nbsp;</td>
      <td width="15%" align="center" class="thinborderNONE"><strong>NET AMOUNT</strong></td>
    </tr>
    <% bolLooped = false;
			 strPrevColl = "";
			 strPrevDept = "";
			 strCurColl = "";
			 strCurDept = "";
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=15,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>
			<%	
			if(bolLooped) {
				if(strPrevColl.equals((String)vRetResult.elementAt(i+1)) 
									 && strPrevDept.equals((String)vRetResult.elementAt(i+2))){
				strTemp = "";
			  }else{
					bolPageBreak = true;
					break;				
				}
			}else{
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13),(String)vRetResult.elementAt(i+8)); 				
			}%>								
    <tr> 
      <td height="18" class="thinborderNONE"><div align="right"><%=iCount%></div></td>
      <td class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;<%=strTemp%></td>
      <td class="thinborderNONE">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></td>
      <td class="thinborderNONE">&nbsp;</td>
      <%	
			strTemp = (String)vRetResult.elementAt(i+12);			
		  %>
      <td class="thinborderNONE"><div align="left">&nbsp;<%=WI.getStrValue(strTemp," ")%></div></td>
      <td class="thinborderNONE">&nbsp;</td>
		<%
			strTemp = (String)vRetResult.elementAt(i+9);
		%>
		<td class="thinborderNONE"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true),"&nbsp;")%>&nbsp;</div></td>
    </tr>
    <% 
		bolLooped = true;
		strPrevColl = WI.getStrValue((String)vRetResult.elementAt(i+1),"");
		strPrevDept = (String)vRetResult.elementAt(i+2);
		} // end for loop
		%>
  </table>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="5" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="5" bgcolor="#FFFFFF"><div align="left">We hereby authorize this bank to credit the above accounts and debit the account of CLDH - EI for the total amount transferred.</div></td>
    </tr>
    <tr>
      <td height="25"  colspan="5" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="18" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="37%" align="center" bgcolor="#FFFFFF"><strong>RICARDO O. HIPOLITO </strong></td>
      <td width="15%" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="39%" height="18" align="center" bgcolor="#FFFFFF"><strong>Mr. CONSTANTE P. QUIRINO JR. </strong></td>
      <td width="6%" height="18" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
      <td align="center" bgcolor="#FFFFFF">President</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="18" align="center" bgcolor="#FFFFFF">Executive Vice President </td>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Verified by: </td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="25" align="center" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
      <td align="center" bgcolor="#FFFFFF"><strong>Mrs. SISINIA T. QUIZON </strong></td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="18" align="center" bgcolor="#FFFFFF"><strong>Ms. MIRIAM A. MOLINA </strong></td>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
      <td align="center" bgcolor="#FFFFFF">Vice President for Administration </td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="18" align="center" bgcolor="#FFFFFF">Finance Manager </td>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>