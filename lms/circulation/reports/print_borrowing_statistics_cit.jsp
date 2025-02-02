<%@ page language="java" import="utility.*,enrollment.ReportEnrollment, lms.CirculationReport, java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function submitForm() {
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
	
	var obj = document.getElementById('myTable4');
	obj.deleteRow(0);
	obj.deleteRow(0);
		
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myTable3').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
	

	

}
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}

function GenerateReport(){
	/**var date = new Date();	
	var year = date.getFullYear(); 
	
	var value = year - document.form_.sy_from.value
	if(value < 4){
		alert("School year must be less than 5 years from todays year.");
		return;
	}*/
	
	document.form_.page_action.value = '1';
	document.form_.submit();
}
</script>
<body onLoad="window.print();">
<%
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	int iElemSubTotal = 0;
	int iHSSubTotal = 0;
	int iPreElemSubTotal = 0;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LMS-CIRCULATION-REPORTS","print_borrowing_statistics_cit.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Circulation","REPORTS",request.getRemoteAddr(),
														"print_borrowing_statistics_cit.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";//for UI, the detrails are different from others. UI adds elementary details.
Vector vCatalogType = null;

CirculationReport CR = new CirculationReport();
Vector vRetResult = null;

	vRetResult = CR.circulationBorrowingStat(dbOP,request);
	if(vRetResult == null)
		strErrMsg = CR.getErrMsg();
	else
		vCatalogType = (Vector)vRetResult.remove(0);
	




%>

  

  
  
  
  
<%if(vRetResult != null && vRetResult.size() > 0){%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr><td align="center" height="20"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td></tr>
	<tr><td align="center" height="20">Library and Learning Resource Center</td></tr>	
	<tr><td align="center" height="20">From <%=WI.getStrValue(WI.fillTextValue("date_fr"))%> <%=WI.getStrValue(WI.fillTextValue("date_to")," To ","","")%></td></tr>
	<tr><td align="center" height="20"><font size="2"><strong>BORROWER</strong></font></td></tr>	
	<tr><td>&nbsp;</td></tr>	
  </table>
 
 
<%
boolean bolIsPageBreak = false;
int iResultSize = 10;
int iLineCount = 0;
int iMaxLineCount = 30;	
int iCount = 1;	
int i = 0;
int iBorrowCount = 0;
String strPrevName = "";
while(iResultSize <= vRetResult.size()){
iLineCount = 0;
%> 
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr>
		<td class="thinborder" width="5%" height="18" align="center"><strong>No.</strong></td>
		<td class="thinborder" width="20%"><strong>Name/Course & Year</strong></td>
		<td class="thinborder" width="15%"><strong>Call No.</strong></td>
		<td class="thinborder" width="30%"><strong>Author/Title</strong></td>
		<td class="thinborder" width="10%"><strong>Access. No.</strong></td>
		<td class="thinborder" width="15%"><strong>Material Type</strong></td>
		<td class="thinborder" width="5%" align="center"><strong>Freq.</strong></td>
	</tr>
	
	<%				
	for( ; i < vRetResult.size() ; ){
	iLineCount++;		
	iResultSize += 10;	
	
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
	strTemp += " "+WI.getStrValue((String)vRetResult.elementAt(i+8))+"-"+WI.getStrValue((String)vRetResult.elementAt(i+9));		
	%>
	
	
	<%if(i != 0 && !strPrevName.equals(strTemp)){%>
	
	<tr>
		<td height="" class="thinborder">&nbsp;</td>
		<td colspan="2" class="thinborder">TOTAL number of books borrowed: <%=iBorrowCount%></td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>		
	</tr>
	<%}%>
	
	<tr>
	<%if(!strPrevName.equals(strTemp)){iBorrowCount = 1;%>
		<td align="center" class="thinborder" height="18"><%=iCount++%></td>
		<td class="thinborder"><%=strTemp%></td>
	<%}else{%>
		<td align="center" class="thinborder" height="18">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	<%iBorrowCount++;}%>			
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "N/A")%></td>
		<td class="thinborder"><%=WI.getStrValue("/",WI.getStrValue((String)vRetResult.elementAt(i+1),"N/A"), WI.getStrValue((String)vRetResult.elementAt(i+2),"N/A"), "N/A")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "N/A")%></td>
		<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5), "N/A")%></td>
		<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "N/A")%></td>
	</tr>
	
	<%if(i+10 == vRetResult.size() && !strPrevName.equals(strTemp)){%>	
	<tr>
		<td height="" class="thinborder">&nbsp;</td>
		<td colspan="2" class="thinborder">TOTAL number of books borrowed: <%=iBorrowCount%></td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>		
	</tr>
	<%}strPrevName = strTemp;%>
		
	<%
	i+=10;
	if(iLineCount >= iMaxLineCount){
		bolIsPageBreak = true;
		break;		
	}else
		bolIsPageBreak = false;	
	%>	
	
	<%}%>
  </table> 
  
  	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>
  

<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">	
	<tr><td height="30" colspan="5"></td></tr>
	<%	
	
	int iTotal = 0;
	
	if(vCatalogType != null && vCatalogType.size() > 0){
		iTotal = Integer.parseInt(WI.getStrValue((String)vCatalogType.remove(0),"0"));
	
	
		while(vCatalogType.size() > 0){
	%>
	<tr>
		<td height="25" width="25%"><%if(vCatalogType.size() > 0){%><%=vCatalogType.remove(0)%> : <%=vCatalogType.remove(0)%><%}else{%>&nbsp;<%}%></td>
		<td width="25%"><%if(vCatalogType.size() > 0){%><%=vCatalogType.remove(0)%> : <%=vCatalogType.remove(0)%><%}else{%>&nbsp;<%}%></td>
		<td width="25%"><%if(vCatalogType.size() > 0){%><%=vCatalogType.remove(0)%> : <%=vCatalogType.remove(0)%><%}else{%>&nbsp;<%}%></td>
		<td width="25%"><%if(vCatalogType.size() > 0){%><%=vCatalogType.remove(0)%> : <%=vCatalogType.remove(0)%><%}else{%>&nbsp;<%}%></td>
	</tr>
	<%}
	}%>
	<tr><td height="25"><strong>TOTAL : <%=iTotal%></strong></td></tr>
</table>



<%}%>	

<!--- Processing Div --->

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