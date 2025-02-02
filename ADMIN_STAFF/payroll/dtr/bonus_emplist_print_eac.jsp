<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Additional month pay Employee list</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PRAddlPay" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
try
	{
		dbOP = new DBOperation();
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
														"PAYROLL","DTR",request.getRemoteAddr(),
														null);
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

PRAddlPay prAddl = new PRAddlPay();
Vector vRetResult = null; Vector vSummary = null;
int i = 0;

boolean bolPageBreak = false;

double dPageTotActualGross = 0d;
double dPageTotProjGross   = 0d;
double dPageTotGross       = 0d;
double dPageTot13thMonth   = 0d;
double dTemp = 0d;

double dTempGross = 0d;
double dTempTotGross = 0d;

double dGTActualGross = 0d; double dGTProj = 0d;

int iRowCount = 0;
	vRetResult = prAddl.getAddlMonthPayReportEAC(dbOP,request);
	//System.out.println(vRetResult);
	//vRetResult = null;
	if (vRetResult != null) {
		vSummary = (Vector)vRetResult.remove(0);			
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"45"));
		int iTotalPages = vRetResult.size()/(8*iMaxRecPerPage);				
		int iPageNo = 1;
		if(vRetResult.size()%(8*iMaxRecPerPage) > 0)
			iTotalPages++;		
		for (i = 0; i < vRetResult.size();iPageNo++){		
		
			dPageTotActualGross = 0d;
			dPageTotProjGross   = 0d;
			dPageTotGross       = 0d;
			dPageTot13thMonth   = 0d;
%>
<body onLoad="javascript:window.print();">
<form name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
<%=SchoolInformation.getAddressLine2(dbOP,false,false)%></font></td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    
    <tr class="thinborder"> 
	  <%
	    strTemp = WI.fillTextValue("bonus_name") + " for the Year " + WI.fillTextValue("year_of") ;
	  %>	
      <td height="23" colspan="7" align="center" class="thinborder"><strong><%=strTemp%></strong></td>	  
    </tr>
    <tr style="font-weight:bold" align="center">
      <td width="3%" class="thinborder" style="font-size:9px;" height="25">COUNT</td>
      <td width="14%" class="thinborder" style="font-size:9px;">EMPLOYEE ID</td> 
      <td width="35%" class="thinborder" style="font-size:9px;">EMPLOYEE NAME</td>
      <td width="12%" class="thinborder" style="font-size:9px;">ACTUAL</td>
	  <td width="12%" class="thinborder" style="font-size:9px;">PROJECTION</td>
	  <td width="12%" class="thinborder" style="font-size:9px;">TOTAL GROSS </td>
	  <td width="12%" class="thinborder" style="font-size:9px;">13th MONTH </td>
    </tr>
		<% 
		for(iCount = 1; i <vRetResult.size(); i += 8,++iCount){
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;
			
			//temp Gross = tot gross + teachers pay.
			dTempGross = Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 3), ",",""));// + Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 5), ",",""));
			dTempTotGross = dTempGross + Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 4), ",",""));
			
			dPageTotActualGross += dTempGross;
			dPageTotProjGross   += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 4), ",",""));
			dPageTotGross       += dTempTotGross;//actual gross + projection gross.
			dPageTot13thMonth   += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 6), ",",""));
			
			dGTActualGross += dTempGross;
			dGTProj        += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i + 4), ",",""));
			
			//double dTemp = 0d;
							
	%>		
    <tr bgcolor="#FFFFFF" class="thinborder">
      <td class="thinborder"><%=++iRowCount%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dTempGross, true)%></td>
 	  <td align="right" class="thinborder" ><%=vRetResult.elementAt(i + 4)%></td>
 	  <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dTempTotGross, true)%></td>
 	  <td align="right" class="thinborder" ><%=vRetResult.elementAt(i + 6)%></td>
    </tr>
    <%} // end for loop%>
		
		<tr bgcolor="#FFFFFF" class="thinborder">
		  <td height="25" colspan="3" align="right" class="thinborder" ><strong>PAGE TOTAL : </strong></td>
		  <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dPageTotActualGross,true)%></td>
	      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dPageTotProjGross,true)%></td>
	      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dPageTotGross,true)%></td>
	      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dPageTot13thMonth,true)%></td>
	  </tr>
		<%if(i >= vRetResult.size()) {%>
			<tr bgcolor="#FFFFFF" class="thinborder">
			  <td height="25" colspan="3" align="right" class="thinborder" ><strong>GRAND TOTAL : </strong></td>
			  <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dGTActualGross,true)%></td>
			  <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dGTProj,true)%></td>
			  <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dGTActualGross + dGTProj,true)%></td>
			  <td align="right" class="thinborder" ><%=vSummary.elementAt(3)%></td>
			</tr>
		<%}%>
  </table>  
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (i < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>