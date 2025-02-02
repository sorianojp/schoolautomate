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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript">
function GoBack(){
	location = "../report_generation.jsp";
}

function PrintPage(){
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
	obj.deleteRow(0);	
			
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	
	
	/*document.getElementById('myTable3').deleteRow(0);
	
	document.getElementById('myTable4').deleteRow(0);	
	document.getElementById('myTable4').deleteRow(0);
	*/
	window.print();

}


function GenerateReport(){
	
	
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.form_.generate_report.value = '1';
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

</script>
<body bgcolor="#FAD3E0">

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; 
	String strTemp = null;
	String strTemp2 = null;
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
	
LmsAcquision lmsAcq   = new LmsAcquision();
Vector vRetResult     = null;
Vector vCollegeList   = null;
Vector vSourceList    = null;
Vector vOtherSupplier = null;
Vector vTotalCost     = null;
Vector vStudCount     = new Vector();
Vector vBudgetAlloc   = new Vector();

int iTotalEnrl = 0;

if(WI.fillTextValue("generate_report").length() > 0){
	
	vBudgetAlloc = lmsAcq.viewBudgetSummary(dbOP, request);
	
	vRetResult = lmsAcq.operateOnAcquisitionReport(dbOP, request, 2);
	if(vRetResult == null)
		strErrMsg = lmsAcq.getErrMsg();
	else{
		vCollegeList   = (Vector)vRetResult.remove(0);
		vStudCount     = (Vector)vRetResult.remove(0);
		vTotalCost	   = (Vector)vRetResult.remove(0);
		vSourceList    = (Vector)vRetResult.remove(0);		
		vOtherSupplier = (Vector)vRetResult.remove(0);
		iTotalEnrl     = Integer.parseInt(WI.getStrValue((String)vRetResult.remove(0),"0"));
	}
}

double dTotalBudget = 0;
if(vBudgetAlloc != null && vBudgetAlloc.size() > 0){
	for(int i = 0; i < vBudgetAlloc.size(); i+=7)
		dTotalBudget += ((Double)vBudgetAlloc.elementAt(i + 1)).doubleValue();
}

%>

<form action="./budget_running_balance.jsp" method="post" name="form_">
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    	<tr bgcolor="#CCCCFF">
      		<td height="25" colspan="5"><div align="center"><strong>BUDGET RUNNING BALANCE</strong></div></td>
    	</tr>	
  	<tr>
		<td colspan="3" height="25"><font color="#FF0000" size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		<td width="37%" align="right"><a href="javascript:GoBack();"><img src="../../images/go_back.gif" border="0" height="25" width="54"></a></td>
	</tr>
	<tr>
        <td width="8%">School Year : </td>
        <td width="23%">
<%
strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp=" DisplaySYTo('form_','sy_from','sy_to')">
<%	
strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">		
	  <%
			strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
		%>
	  <select name="semester">
	<%if(strTemp.equals("1")){%>
		<option value="1" selected>1st Sem</option>
	<%}else{%>
		<option value="1">1st Sem</option>
	
	<%}if(strTemp.equals("2")){%>
		<option value="2" selected>2nd Sem</option>
	<%}else{%>
		<option value="2">2nd Sem</option>
		
	<%}if(strTemp.equals("3")){%>
		<option value="3" selected>3rd Sem</option>
	<%}else{%>
		<option value="3">3rd Sem</option>
	
	<%}if(strTemp.equals("0")){%>
		<option value="0" selected>Summer</option>
	<%}else{%>
		<option value="0">Summer</option>
	<%}%>
	</select>
	  
	  </td>
        <td width="32%"><a href="javascript:GenerateReport();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
		<td>&nbsp;</td>
    </tr>
	
  </table>
 
<%
if(vSourceList != null && vSourceList.size() > 0 && vCollegeList != null && vCollegeList.size() > 0){


String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,true);



String[]  astrConvertSem = {"Summer", "1<sup>st</sup> Sem.", "2<sup>nd</sup> Sem.", "3<sup>rd</sup> Sem.", "4<sup>th</sup> Sem.", ""};




%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable2">
	<tr><td height="25" align="right"><a href="javascript:PrintPage();"><img src="../../images/print.gif" border="0"></a></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center" height="20"><strong>Total Enrollment = <%=iTotalEnrl%> 
		SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>
		<%=astrConvertSem[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"),"5"))]%>
		&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
		BUDGET FOR BOOKS <%=CommonUtil.formatFloat(dTotalBudget,true)%>
		
		</strong></td></tr>
	<tr><td align="center" height="20"><strong><%=strSchoolName%> Library and Learning Resource Center</strong></td></tr>
	<tr><td align="center" height="20"><strong><%=strSchoolAdd%></strong></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td class="thinborder" height="16" width="20%" align="center"><strong>Population/Colleges</strong></td>
		<td class="thinborder" width="18%" align="center">&nbsp;</td>
		<td class="thinborder" width="5%" align="center"><strong>Titles</strong></td>
		<td class="thinborder" width="5%" align="center"><strong>Vols</strong></td>
		<td class="thinborder" width="13%" align="center"><strong>Cost</strong></td>
		<td class="thinborder" width="13%" align="center"><strong>Total Cost</strong></td>
		<td class="thinborder" width="13%" align="center"><strong>Budget Allocated</strong></td>
		<td class="thinborder" width="13%" align="center"><strong>BALANCE</strong></td>
	</tr>
	
	<%
	String strPrevCCode  = "";
	String strCCode  = "";
	String strCName = "";
	String strSourceName = "";
	String strPrevSourceName = "";
	
	String strMatName = "";
	
	int iIndexOf = 0;
	double dPopPercentage = 0d;
	
	int iTitles  = 0;
	int iVolumes = 0;
	double dCost = 0d;
	
	boolean bolShowOthSupp = false;	
	
	double dBalance = 0d;
	double dBudget = 0d;
	
	
	
	double dTemp = 0d;
	
	for(int iRowCount = 0; iRowCount < vSourceList.size();){
		
		strCCode = (String)vSourceList.elementAt(iRowCount + 1);
		strCName = (String)vSourceList.elementAt(iRowCount + 7);
		strSourceName = (String)vSourceList.elementAt(iRowCount + 2);		
		strMatName = (String)vSourceList.elementAt(iRowCount + 3);
		
		iTitles = Integer.parseInt(WI.getStrValue((String)vSourceList.elementAt(iRowCount + 4),"0"));
		iVolumes = Integer.parseInt(WI.getStrValue((String)vSourceList.elementAt(iRowCount + 5),"0"));
		dCost = Double.parseDouble(WI.getStrValue((String)vSourceList.elementAt(iRowCount + 6),"0"));
		
		iIndexOf = vStudCount.indexOf(strCCode);
		if(iIndexOf == -1)
			strTemp2 = "0";
		else
			strTemp2 = (String)vStudCount.elementAt(iIndexOf + 1);		
		dPopPercentage = (Double.parseDouble(strTemp2) / Double.parseDouble(Integer.toString(iTotalEnrl)) ) * 100;	
	%>
	
	
	<!-- this will occur when change of course . meaning first row per course --->
	<%if(!strPrevCCode.equals(strCCode)){		
		strPrevSourceName = strSourceName;
		strTemp = " <table width='100%' border='0' cellpadding='0' cellspacing='0'> "+
			" <tr> "+
			" 	<td width='53%'> <strong>"+ strCCode+ "</strong></td> "+
			" 	<td width='23%' align='right'><strong>"+ strTemp2 + "</strong></td> "+
			" 	<td width='24%' align='right'><strong>"+WI.getStrValue(CommonUtil.formatFloat(dPopPercentage,true),"(",")","")+ "</strong></td> "+
			" </tr> "+
		" </table>";		
	%>
	<tr>
		<td class="thinborder" height="16" valign="top"><%=strTemp%></td>
		<td class="thinborder" colspan="5"><strong><%=strSourceName%></strong></td>	
		
		<%
		iIndexOf = vBudgetAlloc.indexOf(strCName);
		if(iIndexOf > -1){
			strTemp = CommonUtil.formatFloat(((Double)vBudgetAlloc.elementAt(iIndexOf + 1)).doubleValue(), true);
			dBudget = ((Double)vBudgetAlloc.elementAt(iIndexOf + 1)).doubleValue();
		}else
			strTemp = "&nbsp;";
		%>
		
		<td class="thinborder" align="right"><strong><%=strTemp%></strong></td>		
		<td class="thinborder">&nbsp;</td>	
	</tr>	
	<%}%>
	
	
	
	<!--- this will occur when the source name is change. ---->
	<%
	if(!strPrevSourceName.equals(strSourceName) && strPrevCCode.equals(strCCode)){	
		strPrevSourceName = strSourceName;
	%>
	<tr>
		<td class="thinborder" height="16">&nbsp;</td>
		<td class="thinborder" colspan="7"><strong><%=strPrevSourceName%></strong></td>		
	</tr>
	<%}
	
		String strShowCostInData = null;
		String strShowCostInOthSupp = null;
		
		String strShowBalanceInData = null;
		String strShowBalanceInOthSupp = null;
		
		String strTemp3 = "";
		
		if(iRowCount + 8 >= vSourceList.size())
			strTemp3 = "";
		else
			strTemp3 = (String)vSourceList.elementAt(iRowCount + 8 + 1);
			
		if(strCCode.equals(strTemp3))
			bolShowOthSupp = false;
		else
			bolShowOthSupp = true;
	
		boolean bolTemp = false;
		iIndexOf = vOtherSupplier.indexOf(strCCode);		
		if(bolShowOthSupp && iIndexOf > -1)
			bolTemp = true;
		
		iIndexOf = vTotalCost.indexOf(strCCode);
		if(iIndexOf > -1){
			if(bolTemp){
				strShowCostInOthSupp = CommonUtil.formatFloat((String)vTotalCost.elementAt(iIndexOf + 2),true);
				dTemp = Double.parseDouble(WI.getStrValue((String)vTotalCost.elementAt(iIndexOf + 2),"0"));
				dBalance = dBudget - dTemp;
				strShowBalanceInOthSupp = CommonUtil.formatFloat(dBalance,true);
			}else{
				if(bolShowOthSupp || strTemp3.length() == 0){
					strShowCostInData = CommonUtil.formatFloat((String)vTotalCost.elementAt(iIndexOf + 2),true);				
					dTemp = Double.parseDouble(WI.getStrValue((String)vTotalCost.elementAt(iIndexOf + 2),"0"));
					dBalance = dBudget - dTemp;
					strShowBalanceInData = CommonUtil.formatFloat(dBalance,true);
				}
			}
		}
		
	%>
	
	
	
	<tr>
		<td class="thinborder" height="16">&nbsp;</td>
		<td class="thinborder" style="padding-left:30px;"><%=strMatName%></td>	
		<td class="thinborder" align="center"><strong><%=iTitles%></strong></td>	
		<td class="thinborder" align="center"><strong><%=iVolumes%></strong></td>	
		<td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dCost,true)%></strong></td>	
		<td class="thinborder" align="right"><strong><%=WI.getStrValue(strShowCostInData,"&nbsp;")%></strong></td>	
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder" align="right"><strong><%=WI.getStrValue(strShowBalanceInData,"&nbsp;")%></strong></td>
	</tr>
	
	<%			
		iIndexOf = vOtherSupplier.indexOf(strCCode);		
		if(bolShowOthSupp && iIndexOf > -1){
			
			strTemp   = (String)vOtherSupplier.elementAt(iIndexOf + 2);
			strTemp2  = (String)vOtherSupplier.elementAt(iIndexOf + 3);
			strErrMsg = CommonUtil.formatFloat((String)vOtherSupplier.elementAt(iIndexOf + 4),true);	
	%>
	
	<tr>
		<td class="thinborder" height="16">&nbsp;</td>
		<td class="thinborder"><strong>Other Supp.</strong></td>		
		<td class="thinborder" align="center"><strong><%=strTemp%></strong></td>
		<td class="thinborder" align="center"><strong><%=strTemp2%></strong></td>
		<td class="thinborder" align="right"><strong><%=strErrMsg%></strong></td>
		<td class="thinborder" align="right"><strong><%=WI.getStrValue(strShowCostInOthSupp,"&nbsp;")%></strong></td>
		<td class="thinborder" align="right">&nbsp;</td>
		<td class="thinborder" align="right"><strong><%=WI.getStrValue(strShowBalanceInOthSupp,"&nbsp;")%></strong></td>
	</tr>
	
	<%}
	
	if(!strCCode.equals(strTemp3) && strTemp3.length() > 0){
	%>
	
	
	<tr>
		<td class="thinborder" height="16" colspan="8">&nbsp;</td>		
	</tr>
	
	
	<%}
	
	
		strPrevCCode = strCCode;
		iRowCount+=8;
	}%>
</table>



<%}%>

	<input type="hidden" name="generate_report" value="" >

</form>


<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div> 


</body>
</html>
<%
dbOP.cleanUP();
%>