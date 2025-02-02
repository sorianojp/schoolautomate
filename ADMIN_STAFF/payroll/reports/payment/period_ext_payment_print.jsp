<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRExternalPayment"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>External Payments</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TABLE.thinborder{
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>  
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strEmpID = null;
 
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
		
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
			}						
		}
	}

	strEmpID = WI.fillTextValue("emp_id");
	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}	else if(iAccessLevel == 0) //NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Employee Payable Balances","period_ext_payment.jsp");
 
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

	//end of authenticaion code.	
 	PRExternalPayment prExt = new PRExternalPayment(request);
	Vector vLoans = null;
	Vector vPersonalDetails = null;
	Vector vPostCharges = null;
	Vector vRetResult = null;
 	int i = 0;
	boolean bolPageBreak = false;
	
	vRetResult = prExt.getPeriodExtPayments(dbOP, request);
	if (vRetResult != null) {	
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(10*iMaxRecPerPage);	
	if((vRetResult.size() % (10*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>

 	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  
  
  <tr>
    <td align="right">page <%=iPage%> of <%=iTotalPages%></td>
  </tr>
  <tr>
    <td align="center"><table width="80%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="21" colspan="5" align="center"class="BorderBottomLeft"><strong>LIST
      OF EXTERNAL PAYMENTS FROM <%=WI.fillTextValue("date_from")%> TO <%=WI.fillTextValue("date_to")%></strong></td>
    </tr>
    <tr>
      <td width="33%" align="center" class="BorderBottomLeft"><strong><font size="1">PAYEE</font></strong></td>
      <td width="19%" height="21" align="center" class="BorderBottomLeft"><strong><font size="1">OR NUMBER </font></strong></td>
      <td width="19%" align="center" class="BorderBottomLeft"><font size="1"><strong>AMOUNT PAID </strong></font></td>
      <td align="center" class="BorderBottomLeft"><font size="1"><strong>DATE PAID </strong></font></td>
      <!--
			<td align="center" class="BorderBottomLeft"><font size="1"><strong>POSTED BY</strong></font></td>
			-->
      </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=10,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	  %>	
    <tr>
			<%
			strTemp = (String)vRetResult.elementAt(i+5);
			%>		
      <td class="BorderBottomLeft"><font size="1">&nbsp;<%=WI.getStrValue(strTemp, "n/a")%></font></td>
			<%
			strTemp = (String)vRetResult.elementAt(i+3);
			%>
      <td height="21" class="BorderBottomLeft"><font size="1">&nbsp;<%=strTemp%></font></td>
			<%
			strTemp = (String)vRetResult.elementAt(i+1);
			%>
	    <td align="right" class="BorderBottomLeft"><font size="1"><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</font></td>
			<%
			strTemp = (String)vRetResult.elementAt(i+2);
			%>			
      <td width="21%" class="BorderBottomLeft"><font size="1">&nbsp;<%=strTemp%></font></td>
      </tr>
    <%} //end for loop%>
  </table></td>
  </tr>
</table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>	
</body>
</html>
<%
dbOP.cleanUP();
%>