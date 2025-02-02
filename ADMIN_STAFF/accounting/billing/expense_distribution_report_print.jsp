<%@ page language="java" import="utility.*, Accounting.billing.BillingTsuneishi, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Expense Distribution Mgmt</title>
<style type="text/css">
.expenses {
	height:120px; overflow:auto; width:auto; background-color:#FFFFFF;
}
.distributions {
	height:120px; overflow:auto; width:auto; background-color:#FFFFFF;
}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onload="window.print();">	
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BILLING","expense_distribution_report.jsp");
	}
	catch(Exception exp){

		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	boolean bolPageBreak = false;
	Integer iObjTemp = null;
    int iIndexOf = 0;
	int iWidth = 0;
	int i = 0;
	int iTemp = 0;
	int iSearchResult = 0;
	double dTotAmt = 0d;	
	Vector vRetResult = new Vector();
	Vector vTeams = new Vector();
	Vector vValues = null;
	
	BillingTsuneishi billTsu = new BillingTsuneishi();
	vRetResult = billTsu.generateDistributionReport(dbOP, request);
	vTeams = (Vector)vRetResult.remove(0);
	iWidth = 55/(vTeams.size()/3);	
	double[] dTotal = new double[vTeams.size()/3];
	
	if (vRetResult != null) {
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(5*iMaxRecPerPage);
		if(vRetResult.size()%(5*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="20" align="center"><font size="2">
				<strong>Tsuneishi Technical Services (Philippines), Inc.</strong></font></td>
		</tr>
		<tr>
			<td height="20" align="center"><font size="2">Balamban, Cebu</font></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center">
				EXPENSE DISTRIBUTION FOR THE PERIOD <%=WI.fillTextValue("date_fr")%> to <%=WI.fillTextValue("date_to")%></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="50%" height="25" align="left" style="font-size:9px;">Page <%=iPageNo%> of <%=iTotalPages%></td>
		  	<td width="50%" align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
 	  	</tr>
	</table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Expense Name</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Total Amount</strong></td>
		<%	for(i = 0; i < vTeams.size(); i+=3){%>
			<td width="<%=iWidth%>%" align="center" class="thinborder">
				<strong><%=(String)vTeams.elementAt(i+1)%><br />(<%=(String)vTeams.elementAt(i+2)%>)</strong></td>
		<%}%>
		</tr>	
	<% 
		int iResultCount = (iPageNo - 1) * iMaxRecPerPage + 1;
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=5, ++iCount,++iResultCount){
			i = iNumRec;
			
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;
				
			vValues = (Vector)vRetResult.elementAt(i+4);
	%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iResultCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">Php<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true)%></td>
		<%	iTemp = 0;
			for(int j = 0; j < vTeams.size(); j+=3, iTemp++){
				iObjTemp = (Integer)vTeams.elementAt(j);
				iIndexOf = vValues.indexOf(iObjTemp);
				
				if(iIndexOf != -1){
					dTotal[iTemp] += Double.parseDouble((String)vValues.elementAt(iIndexOf+1));
					strTemp = "Php"+CommonUtil.formatFloat((String)vValues.elementAt(iIndexOf+1), true);
				}
				else
					strTemp = "&nbsp;";
		%>
			<td class="thinborder"><%=strTemp%></td>
		<%}%>
		</tr>
	<%} //end for loop%>
		<tr>
			<td height="25" align="center" class="thinborder">&nbsp;</td>
			<td class="thinborder">TOTAL</td>
			<td class="thinborder">Php<%=CommonUtil.formatFloat(dTotAmt, true)%></td>
		<%	iTemp = 0;
			for(int j = 0; j < vTeams.size(); j+=3, iTemp++){%>
			<td class="thinborder">Php<%=CommonUtil.formatFloat(dTotal[iTemp], true)%></td>
		<%}%>
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