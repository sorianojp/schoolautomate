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
	
LmsAcquision lmsAcq   = new LmsAcquision();
Vector vRetResult     = null;
Vector vCollegeList   = null;
Vector vSourceList    = null;
Vector vOtherSupplier = null;
Vector vTotalList     = null;
Vector vGrandTotal    = null;


if(WI.fillTextValue("generate_report").length() > 0){
	vRetResult = lmsAcq.operateOnAcquisitionReport(dbOP, request, 1);
	if(vRetResult == null)
		strErrMsg = lmsAcq.getErrMsg();
	else{
		vSourceList    = (Vector)vRetResult.remove(0);
		vCollegeList   = (Vector)vRetResult.remove(0);
		vOtherSupplier = (Vector)vRetResult.remove(0);
		vTotalList     = (Vector)vRetResult.remove(0);
		vGrandTotal     = (Vector)vRetResult.remove(0);
	}
}

%>

<form action="./book_acquisition_profile.jsp" method="post" name="form_">
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    	<tr bgcolor="#CCCCFF">
      		<td height="25" colspan="5"><div align="center"><strong>BOOK ACQUISITION PROFILE</strong></div></td>
    	</tr>	
  	<tr>
		<td colspan="3" height="25"><font color="#FF0000" size="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		<td align="right"><a href="javascript:GoBack();"><img src="../../images/go_back.gif" border="0" height="25" width="54"></a></td>
	</tr>
	<tr>
        <td width="8%">School Year : </td>
        <td width="12%">
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
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">		</td>
        <td><a href="javascript:GenerateReport();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
		<td>&nbsp;</td>
    </tr>
	
  </table>
 
<%
if(vRetResult != null && vRetResult.size() > 0 && vSourceList != null && vSourceList.size() > 0 && vCollegeList != null && vCollegeList.size() > 0){


//System.out.println("vSourceList "+vSourceList);
//System.out.println("vCollegeList "+vCollegeList);
//System.out.println("vCollegeList "+vRetResult);

String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,true);

String strSourceName = null;

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable2">
	<tr><td height="25" align="right"><a href="javascript:PrintPage();"><img src="../../images/print.gif" border="0"></a></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="center" height="20"><strong>BOOK ACQUISITION PROFILE SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></strong></td></tr>
	<tr><td align="center" height="20"><strong><%=strSchoolName%> Library and Learning Resource Center</strong></td></tr>
	<tr><td align="center" height="20"><strong><%=strSchoolAdd%></strong></td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td class="thinborder" height="16" align="center" width="20%">&nbsp;</td>
		
		<%for(int i = 0; i < vSourceList.size(); i++){
			strSourceName = (String)vSourceList.elementAt(i);
			
			if(strSourceName == null)
				continue;
		%>
		<td class="thinborder" align="center" rowspan="2" colspan="3"><strong><%=strSourceName%></strong></td>
		<%}%>
		
		<td class="thinborder" align="center" rowspan="2" colspan="3"><strong>Other Suppliers</strong></td>
		<td colspan="3" rowspan="2" align="center" class="thinborder"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="16">&nbsp;</td>		
	</tr>
	
	<tr>
		<td class="thinborder" height="16">&nbsp;</td>
		<%for(int i = 0; i < vSourceList.size(); i++){
			strSourceName = (String)vSourceList.elementAt(i);
			
			if(strSourceName == null)
				continue;
		%>
		<td class="thinborder" height="16" width="5%" align="center"><strong>Titles</strong></td>
		<td class="thinborder" height="16" width="5%" align="center"><strong>Vols</strong></td>
		<td class="thinborder" height="16" width="10%" align="center"><strong>Total Amount</strong></td>
		<%}%>
		<td class="thinborder" height="16" width="5%" align="center"><strong>Titles</strong></td>
		<td class="thinborder" height="16" width="5%" align="center"><strong>Vols</strong></td>
		<td class="thinborder" height="16" width="10%" align="center"><strong>Total Amount</strong></td>
		<td class="thinborder" height="16" width="5%" align="center"><strong>Titles</strong></td>
		<td class="thinborder" height="16" width="5%" align="center"><strong>Vols</strong></td>
		<td class="thinborder" height="16" align="center" width="10%"><strong>AMOUNT</strong></td>
	</tr>
	
	
	<%
	String strCollegeName = null;
	String strPrevColName = "";
	
	int iNoTitles = 0;
	int iNoVols   = 0;
	double dTotal    = 0d;	
	
	int iOtherTitles = 0;
	int iOtherVols   = 0;
	double dOtherTotal  = 0d;
	
	int iTotalTitle = 0;
	int iTotalVol   = 0;
	double dTotalAmount = 0d;
	
	int iIndexOf = 0;
	
	String strTemp2 = null;
	
	for(int iRowCount = 0; iRowCount < vCollegeList.size(); iRowCount+=4){
		strTemp2 = (String)vCollegeList.elementAt(iRowCount);//this is used in indexing below.
		strCollegeName = (String)vCollegeList.elementAt(iRowCount+1);
	%>
	<%if(!strPrevColName.equals(strCollegeName)){
		strPrevColName = strCollegeName;
	%>
	<tr>
		<td height="16" class="thinborder" colspan="<%=7 + (vSourceList.size() * 3)%>"><strong><%=strCollegeName%></strong></td>		
	</tr>
	<%}%>
	
	<tr>
		<td height="16" class="thinborder" style="padding-left:50px;"><strong><%=(String)vCollegeList.elementAt(iRowCount+3)%></strong></td>
		
		<%
		for(int i = 0; i < vSourceList.size(); i++){
			strTemp = (String)vSourceList.elementAt(i);
			if(strTemp == null)
				continue;
		
			for(int iResult = 0; iResult < vRetResult.size(); iResult+=10){			
				strSourceName = (String)vRetResult.elementAt(iResult + 8);	
				if(strSourceName == null)					
					continue;	
					
				if(((String)vRetResult.elementAt(iResult)).equals(strTemp2+"-"+(String)vSourceList.elementAt(i))){				
					iNoTitles += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(iResult + 6),"0"));
					iNoVols   += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(iResult + 7),"0"));
					dTotal    += Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(iResult + 9),"0"));						
				}								
			}	
		%>
		
		
		<%
		strTemp = Integer.toString(iNoTitles);
		if(iNoTitles == 0)
			strTemp = "&nbsp;"; 
		%>
		<td class="thinborder" height="16" align="center"><%=strTemp%></td>
		<%
		strTemp = Integer.toString(iNoVols);
		if(iNoVols == 0)
			strTemp = "&nbsp;"; 
		%>
		<td class="thinborder" height="16" align="center"><%=strTemp%></td>
		<%
		strTemp = CommonUtil.formatFloat(dTotal,true);
		if(dTotal == 0d)
			strTemp = "&nbsp;"; 
		%>		
		<td class="thinborder" height="16" align="right"><%=strTemp%></td>
		
		
		<%		
	
		iNoTitles = 0;
		iNoVols = 0;
		dTotal = 0d;		
		
		}
		%>	
		
			
		
		<%
			iIndexOf = vOtherSupplier.indexOf(strTemp2);
			if(iIndexOf == -1){
				iOtherTitles = 0;
				iOtherVols = 0;
				dOtherTotal = 0d;
			}else{
				iOtherTitles = Integer.parseInt(WI.getStrValue((String)vOtherSupplier.elementAt(iIndexOf + 1),"0"));
				iOtherVols   = Integer.parseInt(WI.getStrValue((String)vOtherSupplier.elementAt(iIndexOf + 2),"0"));
				dOtherTotal  = Double.parseDouble(WI.getStrValue((String)vOtherSupplier.elementAt(iIndexOf + 3),"0"));
			}
		%>
		
		
		<%
			strTemp = Integer.toString(iOtherTitles);
			if(iOtherTitles == 0)
				strTemp = "&nbsp;";
		%>
		<td class="thinborder" height="16" align="center"><%=strTemp%></td>
		<%
			strTemp = Integer.toString(iOtherVols);
			if(iOtherVols == 0)
				strTemp = "&nbsp;";
		%>
		<td class="thinborder" height="16" align="center"><%=strTemp%></td>
		<%
			strTemp = CommonUtil.formatFloat(dOtherTotal,true);
			if(dOtherTotal == 0d)
				strTemp = "&nbsp;";
		%>
		<td class="thinborder" height="16" align="right"><%=strTemp%></td>
		
		
		<%
			iIndexOf = vTotalList.indexOf(strTemp2);
			if(iIndexOf == -1){
				iTotalTitle = 0;
				iTotalVol = 0;
				dTotalAmount = 0d;
			}else{
				iTotalTitle = Integer.parseInt(WI.getStrValue((String)vTotalList.elementAt(iIndexOf + 1),"0"));
				iTotalVol   = Integer.parseInt(WI.getStrValue((String)vTotalList.elementAt(iIndexOf + 2),"0"));
				dTotalAmount  = Double.parseDouble(WI.getStrValue((String)vTotalList.elementAt(iIndexOf + 3),"0"));
			}
		%>
		
		
		<%
			strTemp = Integer.toString(iTotalTitle);
			if(iTotalTitle == 0)
				strTemp = "&nbsp;";
		%>
		<td class="thinborder" height="16" align="center"><%=strTemp%></td>
		<%
			strTemp = Integer.toString(iTotalVol);
			if(iTotalVol == 0)
				strTemp = "&nbsp;";
		%>
		<td class="thinborder" height="16" align="center"><%=strTemp%></td>
		<%
			strTemp = CommonUtil.formatFloat(dTotalAmount,true);
			if(dTotalAmount == 0d)
				strTemp = "&nbsp;";
		%>
		<td class="thinborder" height="16" align="right"><%=strTemp%></td>
	</tr>
	
	
	<%}%>
	
	
	
	<tr>
		<td height="16" class="thinborder"><strong>GRAND TOTAL</strong></td>
		<%
		int iGrandTitle = 0;
		int iGrandVol = 0;
		double dGrandAmt = 0d;	

		for(int i = 0; i < vSourceList.size(); i++){
			strSourceName = (String)vSourceList.elementAt(i);
			
			if(strSourceName == null)
				continue;
			
			iIndexOf = vGrandTotal.indexOf(strSourceName);
			if(iIndexOf == -1){
				iGrandTitle = 0;
				iGrandVol = 0;
				dGrandAmt = 0d;	
			}else{
				iGrandTitle = Integer.parseInt(WI.getStrValue((String)vGrandTotal.elementAt(iIndexOf + 1)));
				iGrandVol   = Integer.parseInt(WI.getStrValue((String)vGrandTotal.elementAt(iIndexOf + 2)));
				dGrandAmt   = Double.parseDouble(WI.getStrValue((String)vGrandTotal.elementAt(iIndexOf + 3)));
				
				vGrandTotal.remove(iIndexOf);vGrandTotal.remove(iIndexOf);
				vGrandTotal.remove(iIndexOf);vGrandTotal.remove(iIndexOf);
			}

			
		%>
		<%
		strTemp = Integer.toString(iGrandTitle);
		if(iGrandTitle == 0)
			strTemp = "&nbsp;";
		%>
		<td class="thinborder" height="16" width="5%" align="center"><strong><%=strTemp%></strong></td>
		<%
		strTemp = Integer.toString(iGrandVol);
		if(iGrandVol == 0)
			strTemp = "&nbsp;";
		%>
		<td class="thinborder" height="16" width="5%" align="center"><strong><%=strTemp%></strong></td>
		<%
		strTemp = CommonUtil.formatFloat(dGrandAmt,true);
		if(dGrandAmt == 0d)
			strTemp = "&nbsp;";
		%>
		<td class="thinborder" height="16" width="10%" align="right"><strong><%=strTemp%></strong></td>
		<%}%>
		
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = (String)vGrandTotal.remove(0);
		%>
		<td class="thinborder" height="16" width="5%" align="center"><strong><%=strTemp%></strong></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = (String)vGrandTotal.remove(0);
		%>
		<td class="thinborder" height="16" width="5%" align="center"><strong><%=strTemp%></strong></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = CommonUtil.formatFloat((String)vGrandTotal.remove(0),true);
		%>
		<td class="thinborder" height="16" width="10%" align="right"><strong><%=strTemp%></strong></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = (String)vGrandTotal.remove(0);
		%>
		<td class="thinborder" height="16" width="5%" align="center"><strong><%=strTemp%></strong></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = (String)vGrandTotal.remove(0);
		%>
		<td class="thinborder" height="16" width="5%" align="center"><strong><%=strTemp%></strong></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = CommonUtil.formatFloat((String)vGrandTotal.remove(0),true);
		%>
		<td class="thinborder" height="16" align="right" width="10%"><strong><%=strTemp%></strong></td>
	</tr>
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