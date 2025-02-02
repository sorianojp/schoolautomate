<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function ChangeTitle() {
	var objLabel = document.getElementById("label_title");
	var strReportTitle = prompt('Please enter new reprt title.',objLabel.innerHTML);
	if(strReportTitle == null || strReportTitle.length == 0)
		return;
	objLabel.innerHTML = strReportTitle;
	
}
</script>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
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

JvCD jvCD = new JvCD();

Vector vRetResult = null;//all regarding check detail. 
Vector vSummary   = null;

	vRetResult = jvCD.operateOnCDCheck(dbOP, request, 6);
	if(vRetResult == null) 
		strErrMsg = jvCD.getErrMsg();

int iMaxDisp = 0; double dTotCheckAmt = 0d;

String strDateFrom = WI.fillTextValue("chk_date_fr");String strDateTo = WI.fillTextValue("chk_date_to");

String strMonth    = WI.fillTextValue("jv_month");
String strYear     = WI.fillTextValue("jv_year");

String[] astrConvertYr = {"January","February","March","April","May","June","July","August",
							"September","October","November","December"};
if(strMonth.length() > 0)
	strMonth = astrConvertYr[Integer.parseInt(strMonth)];


String strChkStat = WI.fillTextValue("chk_stat");

Vector vCancelledVoucher = new Vector();
String strSQLQuery = "select jv_number from ac_jv_cancelled ";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vCancelledVoucher.addElement(rs.getString(1));
}
rs.close();


if(vRetResult != null && vRetResult.size() > 0) {
vSummary = (Vector)vRetResult.remove(0);
vRetResult.removeElementAt(0);
dTotCheckAmt = Double.parseDouble((String)vRetResult.remove(0));
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	 <tr>
      <td height="25" colspan="7" align="center">
	  		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          	<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <br>
        <font style="font-size:11px; font-weight:bold"><u><label id="label_title" onClick="ChangeTitle()">
		CHECK REGISTER - <%=vRetResult.elementAt(2)%>
		<%if(strDateFrom.length() > 0 && strDateTo.length() > 0) {%>From <%=strDateFrom%> to <%=strDateTo%>
	  <%}else if(strDateFrom.length() > 0){%>For <%=strDateFrom%><%}else if(strMonth.length() > 0){%>
	  For Month of <%=strMonth%> <%=WI.fillTextValue("jv_year")%><%}else{%> PRINT ALL<%}%>
	  <%if(WI.fillTextValue("show_cancelled").length() > 0) {%>
	  <br>Cancelled Check Report
	  <%}%>
		</label>
		<!--
		List of <%if(strChkStat.equals("0")){%>Outstanding<%}else if(strChkStat.equals("1")){%>Cleared<%}%> Checks 
	  <%if(strDateFrom.length() > 0 && strDateTo.length() > 0) {%>From <%=strDateFrom%> to <%=strDateTo%>
	  <%}else if(strDateFrom.length() > 0){%>For <%=strDateFrom%><%}else{%>
	  For Month of <%=strMonth%> <%=WI.fillTextValue("jv_year")%><%}%> - <%=vRetResult.elementAt(2)%>
	  -->
	  
	  </u>
		</font>
	   </td>
    </tr>
    <tr>
      <td height="25" colspan="7" align="right" style="font-size:9px;">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="4%">NO.</td> 
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="12%"><span class="thinborder" style="font-size:9px; font-weight:bold">DATE</span></td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="12%"><span class="thinborder" style="font-size:9px; font-weight:bold">CHECK # </span></td>
      <td height="26" class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="44%">PAYEE</td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="14%"><span class="thinborder" style="font-size:9px; font-weight:bold">AMOUNT</span></td>
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="14%">VOUCHER # </td>
<!--
      <td class="thinborder" style="font-size:9px; font-weight:bold" align="center" width="14%">CHK RELEASE DATE </td>
-->
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 12){%>
    <tr>
      <td class="thinborder"><%=++iMaxDisp%>.</td> 
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td height="26" class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder" align="right"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 10)%>
	  <%if(vCancelledVoucher.indexOf(vRetResult.elementAt(i + 10)) > -1) {%>
	  	<br>(Cancelled)
	  <%}%>
	  
	  </td>
<!--
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 11), "&nbsp;")%></td>
-->
    </tr>
<%}%>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="56%" height="25">&nbsp;</td>
      <td width="44%" height="25" style="font-size:11px; font-weight:bold" align="right">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TOTAL : <%=CommonUtil.formatFloat(dTotCheckAmt, true)%></td>
    </tr>
<%if(WI.fillTextValue("show_os_summary").length() > 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="44%" height="25" align="right" style="font-size:11px; font-weight:bold">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2" style="font-size:11px; font-weight:bold">Summary of Outstanding Checks <span class="thinborder" style="font-size:11px; font-weight:bold;">
        <%if(strDateFrom.length() > 0 && strDateTo.length() > 0) {%> From <%=strDateFrom%> to <%=strDateTo%>
        <%}else{%> For <%=strDateFrom%><%}%>
      </span></td>
    </tr>
<%for(int i =0; i < vSummary.size(); i += 3){%>
    <tr>
      <td height="25" style="font-size:11px;"><%=vSummary.elementAt(i)%> - <%=vSummary.elementAt(i + 1)%></td>
      <td height="25" style="font-size:11px;" align="right"><%=vSummary.elementAt(i + 2)%>&nbsp;&nbsp;</td>
    </tr>
<%}%>

<%}//show only if selected to show.%>
</table>
 <%}//if(vRetResult != null && vRetResult.size() > 0) {
 else{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="left"></div></td>
      <td width="94%" height="25" style="font-size:14px; color:#FF0000; font-weight:bold"><%=strErrMsg%></td>
    </tr>
</table>
 <%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>