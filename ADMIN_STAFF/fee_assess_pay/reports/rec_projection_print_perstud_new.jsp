<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

String strSchCode  = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
if(strSchCode.startsWith("DLSHSI")){%>
<jsp:forward page="./rec_projection_print_perstud_dlshsi.jsp"></jsp:forward>
<%return;}

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
//if(WI.fillTextValue("show_course").length() == 0) 
//	strErrMsg = "Please select a course to print per student.";
	
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

<body >
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

boolean bolIsAUF = strSchCode.startsWith("AUF");

String[] astrConvertToSem = {"SUMMER", "1ST SEM","2ND SEM","3RD SEM"};
Vector vRetResult = null;
Vector v1 = null; Vector v2 = null; Vector v3 = null;
Vector v4 = null; Vector v5 = null; Vector v6 = null;
Vector v7 = null;

int iRowsPerPg  = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"),"25"));
if(WI.fillTextValue("remove_header").equals("1"))
	iRowsPerPg = 1000000;
int iTotalPages = 0; int iCurRow = 1; int iCurPage = 0;

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
	v5 = (Vector)vRetResult.remove(0);	
	v6 = (Vector)vRetResult.remove(0);	
	v7 = (Vector)vRetResult.remove(0);
	
	iTotalPages = Integer.parseInt((String)v1.remove(0));
	int iTemp = iTotalPages;
	iTotalPages = iTotalPages/iRowsPerPg;
	if(iTemp%iRowsPerPg > 0)
		++iTotalPages;
}
if(bolIsAUF) {
	dbOP.rollbackOP();
	dbOP.forceAutoCommitToTrue();
	RE.enableDisableDropout(dbOP, request, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), false, false);
}

String strTemp = null;


//System.out.println("v1 : "+v1);
//System.out.println("v2 : "+v2);
//System.out.println("v3 : "+v3);
//System.out.println("v4 : "+v4);
//System.out.println("v5 : "+v5);
//System.out.println("v6 : "+v6);
//System.out.println("v7 : "+v7);

if(strErrMsg != null) {//return here.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
    <td height="25"><br><%=strErrMsg%></td>
    </tr>
</table>

<%dbOP.cleanUP();
return;
}

double dTotalUnit = 0d;


String strOthChargeCol = null;String strTempCCode = null; String strTempStudIndex = null;
String strTempFeeName = null; 
boolean bolCCMatch = false; int iIndex = 0; int iRowNo = 0;
String strROTC     = null;

Vector vStudYrList = new Vector();
String strSQLQuery = null;
java.sql.ResultSet rs = null;
int iIndexOf = 0;

	strSQLQuery = "select user_index, year_level from stud_curriculum_hist where is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
					" and semester = "+ WI.fillTextValue("semester");
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vStudYrList.addElement(new Integer(rs.getInt(1)));
		vStudYrList.addElement(rs.getString(2));
	}	
	rs.close();


for(int i =0; i < v3.size(); i += 2) {//main loop. - always one.. 
	

	strTempCCode = (String)v3.elementAt(i);
	++iCurPage; iCurRow = 1;
	
if(iCurPage > 1){%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%></div></td>
    </tr>
    <tr >
    <td align="right">Date and time printed: <%=WI.getTodaysDateTime()%></td>
    </tr>
  	<tr> 
    	<td align="center"><strong><font size="1"><u>RECEIVABLES PER COURSE AS OF &nbsp;<%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]+", "+WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%> <%=WI.fillTextValue("date_from")%></u></font></strong></td>
  	</tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	  <tr> 
		<td width="86%" height="20" valign="top"><font size="2">Course Name :<%=(String)v3.elementAt(i  + 1)%></font></td>
	    <td width="14%" valign="top" align="right">Page <%=iCurPage%> of <%=iTotalPages%> </td>
	  </tr>	
	</table>
	<table border="0" cellpadding="0" cellspacing="0" class="thinborder">
	  <tr style="font-weight:bold"> 
		<td height="20" class="thinborder" align="center" width="15%">STUD NAME</td>
		<td class="thinborder" align="center" width="15%">ID NUMBER </td>
		<td class="thinborder" align="center" width="4%">YR Level </td>
		<td class="thinborder">UNIT</td>
		<td class="thinborder">TOT ASSM.</td>
		<td class="thinborder">TUITION FEE</td>
		<td class="thinborder">TOTAL MISC</td>
<%if(bolIsAUF){strTemp = "<!--";%><%=strTemp%><%strTemp = "-->";}%>
		<td class="thinborder">TORAL OTHER CHARGE</td>
		<td class="thinborder">COMP. HANDS ON</td>
<%if(bolIsAUF){%><%=strTemp%><%}%>
		<%
		for(int j = 0; j < v4.size(); j += 2){
			if(((String)v4.elementAt(j + 1)).compareTo("1") == 0) 
				strOthChargeCol = " color=blue";
			else	
				strOthChargeCol = " color=#000000";
		%>
		
    <td class="thinborder"><font <%=strOthChargeCol%>><%=((String)v4.elementAt(j)).toUpperCase()%></font></td>
		<%}%>
	  </tr>
	  <%
	 for(; v6.size() > 0; ){
	 	if(!WI.fillTextValue("remove_header").equals("1") && strTempCCode.compareTo((String)v6.elementAt(0)) != 0) 
			break;
		strROTC = (String)v6.remove(10);
			//if(strROTC.compareTo("0.0") != 0) 
			//	++ixxx;
		
		v6.removeElementAt(0);
		strTempStudIndex = (String)v6.remove(0);//remove id_number.
		
		
		iIndexOf = vStudYrList.indexOf(new Integer(strTempStudIndex));
		if(iIndexOf > -1)
			strTemp = (String)vStudYrList.elementAt(iIndexOf + 1);
		else	
			strTemp = null;
		
		%>
	  <tr> 
		<td height="20" class="thinborder"><%=++iRowNo%>.<%=(String)v6.remove(1)%></td>
		<td class="thinborder"><%=(String)v6.remove(0)%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
		<td height="20" class="thinborder"><div align="center">
		<%
		strTemp = (String)v6.remove(0);
		try {
			dTotalUnit += Double.parseDouble(strTemp);
		}
		catch(Exception e) {}
		%>
		<%=strTemp%>
		</div></td>
		<td class="thinborder"><%=CommonUtil.formatFloat((String)v6.remove(4),true)%></td>
		<td class="thinborder"><%=CommonUtil.formatFloat((String)v6.remove(0),true)%></td>
		<td class="thinborder"><%=CommonUtil.formatFloat((String)v6.remove(0),true)%></td>
<%if(bolIsAUF){strTemp = "<!--";%><%=strTemp%><%strTemp = "-->";}%>
		<td class="thinborder"><%=CommonUtil.formatFloat((String)v6.remove(0),true)%></td>
		<td class="thinborder"><%=CommonUtil.formatFloat((String)v6.remove(0),true)%></td>
<%if(bolIsAUF){%><%=strTemp%><%}%>
		<%
		for(int p = 0; p < v4.size(); p += 2){
		iIndex = v7.indexOf(strTempStudIndex);
		%>
		<td class="thinborder">
		<%if( iIndex != -1 && 
		((String)v4.elementAt(p)).toLowerCase().compareTo(((String)v7.elementAt(iIndex + 1)).toLowerCase()) == 0) {
			v7.removeElementAt(iIndex);v7.removeElementAt(iIndex);%><%=CommonUtil.formatFloat((String)v7.remove(iIndex),true)%>
			<%}else if( ((String)v4.elementAt(p)).compareTo("ROTC") == 0 && strROTC.compareTo("0.0") != 0) {%>
			<%=CommonUtil.formatFloat(strROTC,true)%>
			<%}else{//System.out.println(" ha ha... "+strTempCCode +" :: "+(String)v2.elementAt(0));
			//System.out.println((String)v4.elementAt(p) +" :: "+(String)v2.elementAt(1));%>&nbsp;<%}%>		</td>
		<%}//END OF SHOWING misc fee%>
	  </tr>
		
	<%	if(v6.size() > 0) 
			++iCurRow;
		if(iCurRow > iRowsPerPg) {
			i -= 2;
			break; //--start of next line..
		}
	}//end of showing student detail	
		 
//print only if it is the last page. 
if(!WI.fillTextValue("remove_header").equals("1") && iCurRow <= iRowsPerPg){
 if(v1.size() > 0 && ((String)v1.elementAt(0)).compareTo(strTempCCode) == 0) {
 	bolCCMatch = true;
	v1.removeElementAt(0);//remove college code.
	v1.removeElementAt(5);//remove total stud enrolled.
 }
 else	
 	bolCCMatch = false;%>
		  
	  <tr style="font-weight:bold"> 
		<td height="20" class="thinborder"><div align="center">GT</div></td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder">&nbsp;</td>
		<td class="thinborder"><%=CommonUtil.formatFloat(dTotalUnit, false)%></td>
	    <td class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(4),true)%><%}%></td>
	    <td class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(0),true)%><%}%></td>
	    <td class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(0),true)%><%}%></td>
<%if(bolIsAUF){strTemp = "<!--";%><%=strTemp%><%strTemp = "-->";}%>
    	<td class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(0),true)%><%}%></td>
    	<td class="thinborder"><%if(!bolCCMatch) {%>&nbsp;<%}else{%><%=CommonUtil.formatFloat((String)v1.remove(0),true)%><%}%></td>
<%if(bolIsAUF){%><%=strTemp%><%}%>
		<%
		for(int p = 0; p < v4.size(); p += 2){
		iIndex = v2.indexOf(strTempCCode);
		%>
		<td class="thinborder">
		<%if( iIndex != -1 && 
		((String)v4.elementAt(p)).toLowerCase().compareTo(((String)v2.elementAt(iIndex + 1)).toLowerCase()) == 0) {
			v2.removeElementAt(iIndex);v2.removeElementAt(iIndex);%><%=CommonUtil.formatFloat((String)v2.remove(iIndex),true)%>
			<%}else {//System.out.println(" ;.. "+strTempCCode +" :: "+(String)v2.elementAt(0));
			//System.out.println((String)v4.elementAt(p) +" :: "+(String)v2.elementAt(1));%>&nbsp;<%}%>		</td>
		<%}%>
	  </tr>
<%}//do not print if not satisfied --> if(iCurRow <= iRowsPerPg){%>
	</table>
<%}//fee per college loop
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
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