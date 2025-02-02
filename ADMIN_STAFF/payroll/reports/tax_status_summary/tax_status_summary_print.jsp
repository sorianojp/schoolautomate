<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Tax Status Summary</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./tax_status_summary_print.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","payroll_summary_for_bank.jsp");
								
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
														"payroll_summary_for_bank.jsp");
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
	ReportPayroll RptPay = new ReportPayroll(request);
	Vector vRetResult = null;	
	boolean bolPageBreak  = false;
	String[] astrTaxStatus = {"Zero Exemption","Single","Head of the Family","Married","Not Set"};
	String[] astrExemptionName    = {"Zero", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																	"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																	"Head of Family 2 Dependents (HF4)", "Married Employed", 																	 
																	 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																	 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
	String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};
	String strStatus = null;
	String strDependent = null;

	
	vRetResult = RptPay.searchTaxStatusSummary(dbOP);
		
	if (vRetResult != null) {
	
		int i = 0; int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(8*iMaxRecPerPage);	
	    if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          </font><font color="#000000" ></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="50%"><font size="1">DATE / TIME PRINTED : <%=WI.getTodaysDateTime()%></font></td>
      <td width="50%" height="25"><div align="right">&nbsp;Page <%=iPage%> of <%=iTotalPages%>&nbsp;</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="6%" height="25" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>COUNT NO.</strong></font></td>
      <td width="12%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>EMPLOYEE ID</strong></font></td>
      <td width="42%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>EMPLOYEE NAME</strong></font></td>
      <td width="18%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>TAX STATUS</strong></font></td>
      <td width="10%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>NO. OF ELIGIBLE DEPENDENTS</strong></font></td>
      <td width="12%" align="center" class="thinborderALL"><font size="1"><strong>TOTAL TAX EXEMPTION</strong></font></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=8,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>
    <tr> 
      <td height="20" class="thinborderBOTTOMLEFT">&nbsp;<%=iIncr%></td>
      <td class="thinborderBOTTOMLEFT"><font size="1">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborderBOTTOMLEFT"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></font></td>
        <%
				strStatus = WI.getStrValue((String)vRetResult.elementAt(i+5),"4");
				strDependent = (String)vRetResult.elementAt(i+6);
					if(strStatus.length() == 2){
						strDependent = strStatus.substring(1,2);
						strStatus = strStatus.substring(0,1);						
					}
				%>									
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=astrTaxStatus[Integer.parseInt(strStatus)]%></td>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strDependent,"0")%></td>
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="right"><%=(String)vRetResult.elementAt(i+7)%>&nbsp;&nbsp;</div></td>
    </tr>
    <%}// end for Loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td height="13" colspan="6"><div align="center"><font size="1">*** NOTHING 
          FOLLOWS ***</font></div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td height="15" colspan="6"><div align="center"><font size="1">*** CONTINUED 
          ON NEXT PAGE ***</font></div></td>
    </tr>
    <%}%>
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