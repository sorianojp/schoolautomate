<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
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
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","bonus_emplist_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
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
														"bonus_emplist_print.jsp");
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
Vector vRetResult = null;
int i = 0;
double dGrandTotal = 0d;
double dPageTotal = 0d;
boolean bolPageBreak = false;
	vRetResult = prAddl.operateOnAddlPayEmpList(dbOP,request, 4);
	if (vRetResult != null) {			
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iTotalPages = vRetResult.size()/(10*iMaxRecPerPage);				
		int iPageNo = 1;
		if(vRetResult.size()%(10*iMaxRecPerPage) > 0)
			iTotalPages++;		
		for (;iNumRec < vRetResult.size();iPageNo++){		
		dPageTotal = 0d;
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
	  if((WI.fillTextValue("with_schedule")).equals("1"))
	    strTemp = WI.fillTextValue("bonus_name") + " for the Year " + WI.fillTextValue("year_of") ;
	  else
	    strTemp = "EMPLOYEES WITHOUT ADDITIONAL PAY";
	  
	  %>	
      <td height="23" colspan="5" align="center" class="thinborder"><strong><%=strTemp%></strong></td>	  
    </tr>
    <tr class="thinborder">
      <td width="13%" align="center" class="thinborder"><strong><strong>EMPLOYEE ID </strong></strong></td> 
      <td width="13%" align="center" class="thinborder"><strong>ACCOUNT #</strong></td>
      <td width="37%" height="25" align="center" class="thinborder"><strong><strong>EMPLOYEE NAME </strong></strong></td>
      <td class="thinborder" width="23%" align="center"><strong><strong>OFFICE</strong></strong></td>
	  <%
	  if((WI.fillTextValue("with_schedule")).equals("1")){
	  %>
      <td class="thinborder" width="14%" align="center"><strong><strong>AMOUNT</strong></strong></td>
      <%}%>
	  </tr>
		<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=11,++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>		
    <tr bgcolor="#FFFFFF" class="thinborder">
      <%
		  	strTemp = (String)vRetResult.elementAt(i+1);
	  %>
      <td class="thinborder" >&nbsp;<%=strTemp%></td> 
      <%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+10));
	  %>
      <td class="thinborder" ><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td height="25" class="thinborder" >&nbsp;<font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>

      <%	   
	    if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
	  %>							
      <td class="thinborder" >&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5)," ")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6)," ")%> </td>
	   <%if((WI.fillTextValue("with_schedule")).equals("1")){%>	  
      <%
		  	strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+7), true);
				dPageTotal += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));				
		  %>
      <td align="right" class="thinborder" ><%=strTemp%>&nbsp;</td>
    <%}%>
 	  </tr>
    <%} // end for loop
		
		dGrandTotal += dPageTotal;
		%>
		<%
	  if((WI.fillTextValue("with_schedule")).equals("1")){
	  %>
		<tr bgcolor="#FFFFFF" class="thinborder">
		  <td height="25" colspan="4" align="right" class="thinborder" ><strong>PAGE TOTAL : </strong></td>
		  <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dPageTotal,true)%>&nbsp;</td>
	  </tr>
		<%if ( iNumRec >= vRetResult.size()) {%>
		<tr bgcolor="#FFFFFF" class="thinborder">
      <td height="25" colspan="4" align="right" class="thinborder" ><strong>GRAND TOTAL : </strong></td>
      <td align="right" class="thinborder" ><%=CommonUtil.formatFloat(dGrandTotal,true)%>&nbsp;</td>
    </tr>
		<%}%>
		
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