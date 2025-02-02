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
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post">
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
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","tax_year_to_date_print.jsp");
								
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
														"tax_year_to_date_print.jsp");
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
 	
	vRetResult = RptPay.generateEmpTaxYTD(dbOP);
		
	if (vRetResult != null) {
	
		int i = 0; int iPage = 1; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(8*iMaxRecPerPage);	
	    if(vRetResult.size() % (8*iMaxRecPerPage) > 0) ++iTotalPages;
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
      <td height="25" colspan="2"><div align="center">EMPLOYEE TAX DEDUCTED FOR THE YEAR <%=WI.fillTextValue("year_of")%></div></td>
    </tr>
    <tr>
      <td width="50%"><font size="1">DATE / TIME PRINTED : <%=WI.getTodaysDateTime()%></font></td>
      <td width="50%" height="25"><div align="right">&nbsp;Page <%=iPage%> of <%=iTotalPages%>&nbsp;</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="6%" height="25" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>COUNT NO.</strong></font></div></td>
      <td width="12%" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>EMPLOYEE ID</strong></font></div></td>
      <td width="42%" class="thinborderTOPLEFTBOTTOM"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td width="18%" class="thinborderALL"><div align="center"><strong><font size="1">TAX WITHELD FOR YEAR </font></strong></div></td>
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
	  	strTemp = (String)vRetResult.elementAt(i+5);
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>							
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="right"><font size="1"><strong><%=strTemp%>&nbsp;&nbsp;</strong></font></div></td>
    </tr>
    <%}// end for Loop%>
    <%if ( iNumRec >= vRetResult.size()) {%>
    <tr> 
      <td height="13" colspan="4"><div align="center"><font size="1">*** NOTHING 
          FOLLOWS ***</font></div></td>
    </tr>
    <%}else{// end iNumStud >= vRetResult.size()%>
    <tr> 
      <td height="15" colspan="4"><div align="center"><font size="1">*** CONTINUED 
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