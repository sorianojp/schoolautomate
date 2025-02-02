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
	
	var strDateType = document.form_.date_type.value;

	var pgLoc = "./print_borrowing_statistics_cit.jsp?date_type="+strDateType+
	"&date_fr="+document.form_.date_fr.value;
	if(strDateType == "2")
	pgLoc += "&date_to="+document.form_.date_to.value;			
	var win=window.open(pgLoc,"PrintPg",'width=1000,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
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
<body bgcolor="#D0E19D" topmargin="0" bottommargin="0">
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
								"LMS-CIRCULATION-REPORTS","borrowing_statistics_cit.jsp");
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
														"attendance_statistics_per_program_cit.jsp");
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
	

CirculationReport CR = new CirculationReport();
Vector vRetResult = null;
Vector vCatalogType = null;
if(WI.fillTextValue("page_action").length() > 0){
	vRetResult = CR.circulationBorrowingStat(dbOP,request);
	if(vRetResult == null)
		strErrMsg = CR.getErrMsg();
	else
		vCatalogType = (Vector)vRetResult.remove(0);

}

%>
<form action="./borrowing_statistics_cit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr  bgcolor="#77A251">
      <td width="100%" height="25" colspan="4" ><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          BORROWING STATISTICS REPORT ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable2">
 	<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Date Borrowed: </td>
			<td width="80%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
				%>
				<select name="date_type" onChange="ReloadPage();">
                  	<%if (strTemp.equals("1")){%>
					<option value="1" selected>Specific Date</option>
                  	<%}else{%>
                  	<option value="1">Specific Date</option>
                  	<%}if (strTemp.equals("2")){%>
                  	<option value="2" selected>Date Range</option>
                  	<%}else{%>
                  	<option value="2">Date Range</option>
                  	<%}%>
                </select>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
					if(strTemp.equals("2")){
				%>
				to 
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				<%}%></td>
		</tr>
	<tr><td>&nbsp;</td></tr>
	<tr> 
      <td width="2%" height="25">&nbsp;</td> 
	  <td>&nbsp;</td>     
      <td>
	  <input type="button" name="Login" value="Generate Report"	  
	   onClick="GenerateReport();" >	  </td>
    </tr>

    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  
  
  
<%if(vRetResult != null && vRetResult.size() > 0 && vCatalogType != null && vCatalogType.size() > 0){%>  

<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable3">
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td align="right"><a href="javascript:PrintPg();"><img src="../../images/print_circulation.gif" border="0"></a> 
        <font size="1">click to print report</font></td>
    </tr>
  </table>
	
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
  	<tr><td align="center" height="20"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td></tr>
	<tr><td align="center" height="20">Library and Learning Resource Center</td></tr>	
	<tr><td align="center" height="20">From <%=WI.getStrValue(WI.fillTextValue("date_fr"))%> <%=WI.getStrValue(WI.fillTextValue("date_to")," To ","","")%></td></tr>
	<tr><td align="center" height="20"><font size="2"><strong>BORROWER</strong></font></td></tr>	
	<tr><td>&nbsp;</td></tr>	
  </table>
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  	<tr>
		<td class="thinborder" width="5%" height="25" align="center"><strong>No.</strong></td>
		<td class="thinborder" width="20%"><strong>Name/Course & Year</strong></td>
		<td class="thinborder" width="15%"><strong>Call No.</strong></td>
		<td class="thinborder" width="30%"><strong>Author/Title</strong></td>
		<td class="thinborder" width="10%"><strong>Access. No.</strong></td>
		<td class="thinborder" width="15%"><strong>Material Type</strong></td>
		<td class="thinborder" width="5%" align="center"><strong>Freq.</strong></td>
	</tr>
	
	
	<%
		int iCount = 1;
		int iBorrowCount = 0; 
		String strPrevName = "";		
		
		for(int i =0; i < vRetResult.size(); i+=10){
		
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
		

		
		strTemp += " "+WI.getStrValue((String)vRetResult.elementAt(i+8))+"-"+WI.getStrValue((String)vRetResult.elementAt(i+9));		
	%>
	
	
	<%if(i != 0 && !strPrevName.equals(strTemp)){%>
	
	<tr>
		<td height="" class="thinborder">&nbsp;</td>
		<td class="thinborder">TOTAL number of books borrowed: <%=iBorrowCount%></td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	</tr>
	<%}%>
	
	<tr>
	<%if(!strPrevName.equals(strTemp)){iBorrowCount = 1;%>
		<td align="center" class="thinborder" height="25"><%=iCount++%></td>
		<td class="thinborder"><%=strTemp%></td>
	<%}else{%>
		<td align="center" class="thinborder" height="25">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	<%iBorrowCount++;}%>			
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "N/A")%></td>
		<td class="thinborder"><%=WI.getStrValue("/",(String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), "N/A")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "N/A")%></td>
		<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5), "N/A")%></td>
		<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "N/A")%></td>
	</tr>
	
	<%if(i+10 >= vRetResult.size()){%>	
	<tr>
		<td height="" class="thinborder">&nbsp;</td>
		<td class="thinborder">TOTAL number of books borrowed: <%=iBorrowCount%></td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
	</tr>
	<%}strPrevName = strTemp;%>
		
	<%}%>
  </table> 
  



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
   
   
 



<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable4">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#77A251"><td height="25">&nbsp;</td></tr>
</table>
<input type="hidden" name="summary_of_roe" value="<%=WI.fillTextValue("summary_of_roe")%>">
<input type="hidden" name="reloadPage">
<input type="hidden" name="college" value="<%=WI.fillTextValue("college")%>"/>
<input type="hidden" name="page_action" value="" />
</form>


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