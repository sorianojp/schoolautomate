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
    }

    TD.thinborderBOTTOMTOP {
    border-top: solid 1px #000000;
	border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
    }
	
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ViewRecords()
{
	document.form_.print_pg.value="";	
	document.form_.viewRecords.value="1";
	this.SubmitOnce("form_");
}

</script>
<body onLoad="javascript:window.print();">
<form name="form_">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolPageBreak = false;
	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-EmployeePayslip","atm_payroll_listing_print_cgh.jsp");
								
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
														"atm_payroll_listing_print_cgh.jsp");
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
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String strPayrollPeriod  = null;
	String strSchCode = dbOP.getSchoolIndex();
	double dGroupTotal = 0d;
	double dGrandTotal = 0d;
	boolean bolShowHeader = true;
	boolean bolShowSubTotal = false;
	String[] astrPtFt = {"PART-TIME PF ","FULL-TIME "};
	String[] astrCategory = {"NON-TEACHING STAFF","FACULTY","NON-TEACHING STAFF"};

	vRetResult = RptPay.searchEmpATMListing(dbOP);
	//System.out.println("vRetResult " +vRetResult);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}

if(WI.fillTextValue("year_of").length() > 0) {
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
    strTemp = WI.fillTextValue("sal_period_index");	
	for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		  strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 7);
		}
	 }	
}
	if (vRetResult != null) {
	
		int i = 0; int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			

		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		System.out.println("vRetResult.size() " + vRetResult.size());
		int iTotalPages = (vRetResult.size()-1)/(8*iMaxRecPerPage);	
	  if(vRetResult.size() % (8*iMaxRecPerPage) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td width="2%">&nbsp;</td>
      <td width="98%" height="25" colspan="5"><div align="left"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          BANK DEBIT LIST (<%=WI.formatDate(strPayrollPeriod,10)%>)<br>
          </font><font color="#000000" ></font></div></td>
    </tr>
  </table>   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <% 
		strTemp = (String)vRetResult.elementAt(0);			
		%>
      <td height="24" colspan="2" class="thinborderBOTTOM" valign="bottom"><font size="1"><strong><%=WI.getStrValue(strTemp," ")%></strong></font></td>
      <td height="24" colspan="2" class="thinborderBOTTOM"><font size="1">&nbsp;</font> 
        <div align="center"></div></td>
      <td width="20%" height="24" valign="bottom" class="thinborderBOTTOM">&nbsp;Page <%=iPage%> of <%=iTotalPages%></td>
    </tr>
  </table>   
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="39%" class="thinborderBOTTOM"><div align="center">EMPLOYEE NAME</div></td>
      <td colspan="2" class="thinborderBOTTOM"><font size="1">&nbsp;</font> ACCOUNT 
        NO</td>
      <td width="23%" class="thinborderBOTTOM"><div align="center">AMOUNT</div></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=8,++iIncr, ++iCount){
		i = iNumRec;
//		if (iCount > iMaxRecPerPage){
//			bolPageBreak = true;
//			break;
//		}
//		else 
//			bolPageBreak = false;			
	%>
    <% 
	  	if(i > 1 && (!((String)vRetResult.elementAt(i+6)).equals((String)vRetResult.elementAt(i-2))
				  || !((String)vRetResult.elementAt(i+7)).equals((String)vRetResult.elementAt(i-1)) ) ){
			bolShowHeader = true;
		}
	  %>
    <%
	  if(bolShowHeader){
	  bolShowHeader = false;
	%>
    <tr> 
      <td colspan="4"><strong><u><%=astrPtFt[Integer.parseInt((String)vRetResult.elementAt(i+6))]%><%=astrCategory[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></u></strong></td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></td>
      <%
	    strTemp = (String)vRetResult.elementAt(i+5);					
	  %>
      <td height="18" colspan="2"><div align="left">&nbsp;&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></div></td>
      <% 
		strTemp = (String)vRetResult.elementAt(i+4);
		dGroupTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		dGrandTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
	  %>
      <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(strTemp,true)," ")%>&nbsp;&nbsp;&nbsp;</div></td>
    </tr>
    <% 
	  	if((i + 8 < vRetResult.size() && (!((String)vRetResult.elementAt(i+6)).equals((String)vRetResult.elementAt(i+14))
				  || !((String)vRetResult.elementAt(i+7)).equals((String)vRetResult.elementAt(i+15)) )) 
		    || i + 9 > vRetResult.size())
				  {
			bolShowSubTotal = true;
		}
	  %>
    <%
	  if(bolShowSubTotal){
	  bolShowSubTotal = false;
	%>
    <tr> 
      <td><strong></strong></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderBOTTOMTop"><div align="right"><%=CommonUtil.formatFloat(dGroupTotal,true)%>&nbsp;&nbsp;&nbsp;</div></td>
    </tr>
    <% dGroupTotal = 0d;
	}%>
    <%} // end for loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td>&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="24%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td  class="thinborder">GRAND TOTAL</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder"><div align="right">&nbsp;</div></td>
      <td  class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;&nbsp;&nbsp;</div></td>
    </tr>
    <tr> 
      <td  class="thinborder"><strong>NO OF RECORD : <%=iIncr-1%></strong></td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder"><div align="right"></div></td>
      <td  class="thinborder"><div align="right"></div></td>
    </tr>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4"  class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="6%">&nbsp;</td>
            <td width="30%">Prepared by : </td>
            <td width="36%">Reviewed by : </td>
            <td width="28%">Approved by : </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>EVELYNDA E. BANARES</td>
            <td>EDGAR S. CHUNG, MSPH</td>
            <td>TAN KING KING</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Payroll Officer</td>
            <td>Assistant for administrative Affairs</td>
            <td>Executive Director</td>
          </tr>
        </table></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder">&nbsp;</td>
      <td  class="thinborder"><div align="right"></div></td>
      <td  class="thinborder"><div align="right"></div></td>
    </tr>
    <tr> 
      <td colspan="4"  class="thinborder"><div align="center"></div></td>
    </tr>
    <%}//end else%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>

  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form> 
</body>
</html>
<%
dbOP.cleanUP();
%>