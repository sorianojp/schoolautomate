<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>MONTHLY MISCELLANEOUS DEDUCTIONS</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
 
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iSearchResult = 0;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","misc_ded_payable.jsp");
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
														"misc_ded_payable.jsp");
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
	PReDTRME prEdtrME = new PReDTRME();
	Vector vRetResult = null;
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	String strDedName = null;					  
	String strPrevID = "";
	int i = 0;
	boolean bolPageBreak = false;
	if(WI.fillTextValue("deduct_index").length() > 0){
		strDedName = dbOP.mapOneToOther("preload_deduction","pre_deduct_index",
					 WI.fillTextValue("deduct_index"),"pre_deduct_name","");
	}

	vRetResult = RptPay.getMiscPostingWithBalance(dbOP);
	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	double dPageTotal = 0d;
	int iTotalPages = (vRetResult.size())/(15*iMaxRecPerPage);	
	if((vRetResult.size() % (15*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 	dPageTotal =0d;		
		strPrevID = "";
%>

<body>
<form name="form_">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
  <tr>
		<%
		if(WI.fillTextValue("view_adjusted").length() > 0)
			strTemp = " ADJUSTMENTS ";
		else
			strTemp = " BALANCES ";		
		%>
    <td height="33" align="center" class="thinborderBOTTOM"><strong><%=(WI.getStrValue(strDedName,"")).toUpperCase()%><%=strTemp%>as of <%=WI.getTodaysDateTime()%><br>
        </strong></td>
    </tr>    
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td align="center" class="thinborderBOTTOMLEFT">EMPLOYEE ID </td>
    <td height="21" align="center" class="thinborderBOTTOMLEFT">EMPLOYEE NAME </td>
    <td align="center" class="thinborderBOTTOMLEFT">AMOUNT</td>
    <td align="center" class="thinborderBOTTOMLEFT">PERIOD</td>
		<%if(WI.fillTextValue("view_adjusted").length() > 0){%>
    <td align="center" class="thinborderBOTTOMLEFTRIGHT">REASON</td>
		<%}%>
  </tr>
	<% 
	for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=15,++iIncr, ++iCount){
	i = iNumRec;
	if (iCount > iMaxRecPerPage){
		bolPageBreak = true;
		break;
	}
	else 
		bolPageBreak = false;			
	%>
  <tr>
    <td width="5%" align="right" class="thinborderBOTTOMLEFT"><%=iIncr%>&nbsp;</td>
		<%
			if(((String)vRetResult.elementAt(i)).equals(strPrevID)){
				strTemp = "&nbsp;";
				strTemp2 = "&nbsp;";
			}else{
				strTemp = (String)vRetResult.elementAt(i);
				strTemp2 = WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), 
									(String)vRetResult.elementAt(i+3), 4).toUpperCase();
			}
			
			strPrevID = (String)vRetResult.elementAt(i);
		%>
    <td width="12%" class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp%></td>
    <td width="36%" height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp2%></td>
		<%
		if(WI.fillTextValue("view_adjusted").length() > 0)
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+10),true);
		else
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);		
		%>				
    <td width="11%" align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
    <td width="16%" align="right" class="thinborderBOTTOMLEFT"><%=(String)vRetResult.elementAt(i+7)%>-<%=(String)vRetResult.elementAt(i+8)%>&nbsp;</td>
    <%if(WI.fillTextValue("view_adjusted").length() > 0){%>
		<td width="20%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
		<%}%>
  </tr>
  <%}// end for loop%>
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