<%@ page language="java" import="utility.*,java.util.Vector" buffer="16kb"%>
<%
WebInterface WI = new WebInterface(request);
DBOperation dbOP = null;
String strErrMsg = null;

if(request.getSession(false).getAttribute("userIndex") == null)
	strErrMsg = "You are already logged out. Please login again.";
else {
	String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthIndex == null || strAuthIndex.equals("4") || strAuthIndex.equals("6"))
		strErrMsg = "You are not authorized to view this page.";
}
if(strErrMsg != null){%>
<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000"><%=strErrMsg%></font>
<%return;}

String strFontSize = WI.fillTextValue("font_size");
if(strFontSize.length() == 0) 
	strFontSize = "9";
%>

	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>RECEIVABLES PROJECTION REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

-->
</style>
</head>

<body>
<%
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & payment-REPORTS","rec_projection_print_percourse.jsp");
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
String strSchCode  = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsAUF = strSchCode.startsWith("AUF");
boolean bolIsCIT = strSchCode.startsWith("CIT");

String[] astrConvertToSem = {"SUMMER", "1ST SEM","2ND SEM","3RD SEM"};
Vector vRetResult = null;
Vector v1 = null; Vector v2 = null; Vector v3 = null;
Vector v4 = null; Vector v5 = null;

String strCollegeOrCourse = null;
String strReportType      = WI.fillTextValue("report_type");
if(strReportType.compareTo("2") == 0) 
	strCollegeOrCourse = "College";
else	
	strCollegeOrCourse = "Course";

enrollment.ReportEnrollment RE = new enrollment.ReportEnrollment();
if(bolIsAUF)
	RE.enableDisableDropout(dbOP, request, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), true, true);


EnrlReport.FeeExtraction fEx = new EnrlReport.FeeExtraction();
vRetResult = fEx.getRecProjNew(dbOP, request,false);
if(vRetResult == null || vRetResult.size() == 0) {
	strErrMsg = fEx.getErrMsg();
}
else {
	v1 = (Vector)vRetResult.remove(0);
	v2 = (Vector)vRetResult.remove(0);
	v3 = (Vector)vRetResult.remove(0);	
	v4 = (Vector)vRetResult.remove(0);
	v5 = (Vector)vRetResult.remove(0);//System.out.println(v3);	
}
if(bolIsAUF) {
	dbOP.rollbackOP();
	dbOP.forceAutoCommitToTrue();
	RE.enableDisableDropout(dbOP, request, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), false, false);
}


/**
//System.out.println(vFeeDetailPerCollege);
System.out.println("v1 : "+v1);
System.out.println("v2 : "+v2);
System.out.println("v3 : "+v3);
System.out.println("v4 : "+v4);
System.out.println("v5 : "+v5);

**/
boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
String strTemp = null;

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%></div></td>
    </tr>
    <tr >
      
    <td height="25" align="right">Date and time printed: <%=WI.getTodaysDateTime()%></td>
    </tr>
</table>
<%
if(strErrMsg != null) {//return here.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
    <td height="25"><br><%=strErrMsg%></td>
    </tr>
</table>

<%dbOP.cleanUP();
return;
}


String strTotalStud = (String)v1.remove(0);%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="20" colspan="3" align="center" valign="top">
	<u><strong><font size="1">RECEIVABLES PER <%=strCollegeOrCourse%> AS OF &nbsp;<%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]+", "+WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%> <%=WI.fillTextValue("date_from")%></font></strong></u></td>
  </tr>
  <tr>
    <td height="20" colspan="3"><font size="1">Total Student count : <strong><%=strTotalStud%></strong></font></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="4%" height="20" class="thinborder"><div align="center"><%=strCollegeOrCourse%></font></div></td>
    <%if(bolIsAUF){%><td width="4%" class="thinborder">Tot Stud </td><%}%>
    <td width="4%" class="thinborder">Tot Assm. </td>
    <td width="4%" class="thinborder">Tuition Fee </td>
<%if(bolIsAUF){strTemp = "<!--";%><%=strTemp%><%strTemp = "-->";}%>
    <td width="4%" class="thinborder">Total Misc </td>
    <td width="4%" class="thinborder">Total Other Charge </td>
    <td width="4%" class="thinborder">Comp Hands on </td>
    <td width="4%" class="thinborder">Books And Manuals </td>
    <%if(bolIsAUF){%><%=strTemp%><%}%>
    <%String strOthChargeCol = null;String strTempCCode = null; String strTempFeeName = null; 
	boolean bolCCMatch = false; int iIndex = 0;
	//System.out.println(v4);
	for(int i = 0; i < v4.size(); i += 2){
		if(((String)v4.elementAt(i + 1)).compareTo("1") == 0) 
			strOthChargeCol = " color=blue";
		else	
			strOthChargeCol = " color=#000000";
	%>
    <td class="thinborder"><font <%=strOthChargeCol%>><%=((String)v4.elementAt(i)).toUpperCase()%></font></td>
    <%}%>
  </tr>
  <%//System.out.println("JSP : "+v2);
 for(int i = 0; i < v3.size(); i += 2){
 strTempCCode = (String)v3.elementAt(i);
 ///System.out.println("JSP : "+strTempCCode);
 if( v1.size() > 0 && ((String)v1.elementAt(0)).compareTo(strTempCCode) == 0) {
 	bolCCMatch = true;
	v1.removeElementAt(0);//remove college code.
 }
 else	
 	bolCCMatch = false;//System.out.println("JSP2 : "+v1.elementAt(0));%>
  <tr> 
    <td width="4%" height="20" class="thinborder"><div align="center"><%if(bolIsBasic){%><%=v3.elementAt(i + 1)%><%}else{%><%=strTempCCode%><%}%><%if(bolCCMatch && !bolIsAUF){%><br>(<%=(String)v1.remove(5)%>)<%}%></div></td>
    <%if(bolIsAUF){%><td width="4%" class="thinborder"><%if(bolCCMatch){%><%=(String)v1.remove(5)%><%}%></td><%}%>
    <td width="4%" class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(4),true)%><%}%></td>
    <td width="4%" class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(0),true)%><%}%></td>
<%if(bolIsAUF){strTemp = "<!--";%><%=strTemp%><%strTemp = "-->";}%>
    <td width="4%" class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(0),true)%><%}%></td>
    <td width="4%" class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(0),true)%><%}%></td>
    <td width="4%" class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(0),true)%><%}%></td>
    <td width="4%" class="thinborder">&nbsp;</td>
    <%if(bolIsAUF){%><%=strTemp%><%}%>
    <%
	for(int p = 0; p < v4.size(); p += 2){
	iIndex = v2.indexOf(strTempCCode);
	//System.out.println(" ha ha... "+strTempCCode +" :: "+(String)v2.elementAt(0));
	//System.out.println((String)v4.elementAt(p) +" :: "+(String)v2.elementAt(1));%>
    <td class="thinborder">
	<%if( iIndex != -1 && 
	((String)v4.elementAt(p)).trim().compareToIgnoreCase(((String)v2.elementAt(iIndex + 1)).trim()) == 0) {
		v2.removeElementAt(iIndex);v2.removeElementAt(iIndex);%><%=CommonUtil.formatFloat((String)v2.remove(iIndex),true)%>
		<%}else {//System.out.println(" ha ha... "+strTempCCode +" :: "+(String)v2.elementAt(0));
		//System.out.println((String)v4.elementAt(p) +"x::"+(String)v2.elementAt(1)+"x");%>&nbsp;<%}%>	</td>
    <%}%>
  </tr>
  <%}%>
  <tr style="font-weight:bold"> 
    <td width="4%" height="20" class="thinborder"><div align="center">GT</font></div></td>
    <%if(bolIsAUF){%><td width="4%" class="thinborder"><%=strTotalStud%></td><%}%>
    <td width="4%" class="thinborder"><%=CommonUtil.formatFloat((String)v5.remove(4),true)%></td>
    <td width="4%" class="thinborder"><%=CommonUtil.formatFloat((String)v5.remove(0),true)%></td>
<%if(bolIsAUF){strTemp = "<!--";%><%=strTemp%><%strTemp = "-->";}%>
    <td width="4%" class="thinborder"><%=CommonUtil.formatFloat((String)v5.remove(0),true)%></td>
    <td width="4%" class="thinborder"><%=CommonUtil.formatFloat((String)v5.remove(0),true)%></td>
    <td width="4%" class="thinborder"><%=CommonUtil.formatFloat((String)v5.remove(0),true)%></td>
    <td width="4%" class="thinborder">&nbsp;</td>
    <%if(bolIsAUF){%><%=strTemp%><%}%>
    <%
	for(int p = 0; p < v4.size(); p += 2){%>
    <td class="thinborder">
	<%if( v5.size() > 0 && WI.getStrValue(v4.elementAt(p)).trim().toLowerCase().equals(WI.getStrValue(v5.elementAt(0)).trim().toLowerCase()) ) {
		v5.remove(0);//System.out.println("Removing : "+v5.remove(0));%><%=CommonUtil.formatFloat((String)v5.remove(0),true)%>
		<%}else {//System.out.println(WI.getStrValue(v4.elementAt(p)).trim().length());System.out.println("V5 : "+WI.getStrValue(v5.elementAt(0)).trim().length());
		//System.out.println(v4.elementAt(p));
		//System.out.println(v5.elementAt(0));
		%>&nbsp;<%}%>		</td>
    <%}%>
  </tr>
</table>

  
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25"  colspan="2"><font size="1">&nbsp;</font></td>
    <td width="0">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25"><font size="1">Prepared by :</font></td>
    <td height="25"><font size="1">Reviewed by : </font></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" valign="bottom"><font size="1">__________________________________________________</font></td>
    <td height="25" valign="bottom"><font size="1">_____________________________________________________</font></td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td width="48%" height="24"><div align="left"><font size="1"><%if(bolIsAUF){%>Receivable Clerk<%}else{%>Accountant<%}%></font></div></td>
    <td width="52%" height="24"><font size="1"><%if(bolIsAUF){%>Head Accounts Management<%}else{%>Head Accountant<%}%></font></td>
    <td>&nbsp;</td>
  </tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>