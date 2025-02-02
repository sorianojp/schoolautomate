<%@ page language="java" import="utility.*,lms.LmsAcquision,java.util.Vector" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">

function GoBack(){
	location = "../report_generation.jsp";
}

function BudgetPerformance(strAction){
	
	document.form_.page_action.value = strAction;	
	document.form_.submit();
}

function PrintPg(){	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTableAD1');
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
		
	var obj1 = document.getElementById('myTableAD2');
	obj1.deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
}
</script>
<body bgcolor="#FAD3E0">

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Acquisition".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}

//end of authenticaion code.

	try {
		dbOP = new DBOperation();
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

LmsAcquision lmsAcq = new LmsAcquision();
Vector vRetResult     = null; 
Vector vInsList = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("1") == 0){
	vRetResult = lmsAcq.viewBudgetSummarySY(dbOP, request);	
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = lmsAcq.getErrMsg();
}

//System.out.println("vRetResult "+vRetResult);
%>

<form action="./budget_performance_prev_year.jsp" method="post" name="form_">
  	<table width="100%" border="0" cellpadding="0" cellspacing="0"  id="myTableAD1">
    	<tr bgcolor="#CCCCFF" id="myTR">
      		<td height="25" colspan="3"><div align="center"><strong>Budget Performance by College</strong></div></td>
    	</tr>
  	<tr><td colspan="2" height="25"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		<td align="right"><a href="javascript:GoBack();"><img src="../../images/go_back.gif" border="0" height="25" width="54"></a></td>
	</tr>
	<tr>
		<td width="15%" height="20">School Year: </td>
		<td width="10%">
			<select name="school_year">
				<%
				strTemp = WI.fillTextValue("school_year");
				if(strTemp.length() == 0) {
					strTemp = String.valueOf(Integer.parseInt(WI.getTodaysDate(12)) - 4);
				}
				%>
				<%=dbOP.loadComboYear(strTemp, 8, 0)%>
			</select>
				
		</td>
		<td><a href="javascript:BudgetPerformance('1');"><img src="../../images/form_proceed.gif"></a></td>
	</tr>
	
  </table>
 
<%if(vRetResult != null && vRetResult.size() > 0) {

String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,true);
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTableAD2">		
	<tr>		
		<td align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a></td>
	</tr>	
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">	
	<tr><td align="center" height="20"><strong>BUDGET PERFORMANCE</strong></td></tr>
	<tr><td align="center" height="20"><strong><%=strSchoolName%> Library and Learning Resource Center</strong></td></tr>
	<tr><td align="center" height="20"><strong><%=strSchoolAdd%></strong></td></tr>
</table>
	
<%
String strTotalBudget = null;
String strTotalConsumed = null;
String strTotalBalance = null;

boolean bolIsPageBreak = false;
int iResultSize = 8;
int iLineCount = 0;
int iMaxLineCount = 35;	
int iCount = 0;	
int i = 0;
String strPrevYear = "";
while(iResultSize <= vRetResult.size()){
iLineCount = 0;
%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">	
	<%
		for( ; i<vRetResult.size() ; ){			
			iCount++;
			iLineCount++;		
			iResultSize += 8;	
			strTemp = (String)vRetResult.elementAt(i+3);
			if(strTemp == null){
				i+=8;
				continue;
			}
	%>
		
		<%if(!strPrevYear.equals(strTemp)){%>
		<tr>	
			<td height="20" colspan="5" class="thinborder"><div align="center"><strong>
			AY <%=strTemp%> - <%=Integer.parseInt(strTemp)+1%></strong></div></td>
		</tr>
		<tr align="center" style="font-weight:bold">
			<td width="45%" height="20" class="thinborder">College</td>		
			<td width="15%" class="thinborder">Allocated Budget</td>
			<td width="15%" class="thinborder">Total Cost</td>
			<td width="15%" class="thinborder">Balance</td>    
		</tr>
		<%}
		strPrevYear = strTemp;
		%>
		
	<%	
	strTotalBudget   = CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 5)).doubleValue(), true);
	strTotalConsumed = CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 6)).doubleValue(), true);
	strTotalBalance  = CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 7)).doubleValue(), true);	
	%>
	  <tr>
		<td width="45%" height="20" class="thinborder">&nbsp;<%=vRetResult.elementAt(i+2)%></td>
		
		<td width="15%"  class="thinborder" align="right"><%=strTotalBudget%>&nbsp;</td>
		<td width="15%" class="thinborder" align="right"><%=strTotalConsumed%>&nbsp;</td>
		<td width="15%" class="thinborder" align="right"><%=strTotalBalance%>&nbsp;</td>
		
	  </tr> 	
	<%
		
		i+=8;			
		if(iLineCount > iMaxLineCount){
			bolIsPageBreak = true;
			break;
		}
		else
			bolIsPageBreak = false;
					
	}//for(i = 0; i < vRetResult.size(); i += 7)%>
</table>
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
<%
	}
}//end whiless%>

<%}//end of if condition.. %>


<input type="hidden" name="page_action">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>