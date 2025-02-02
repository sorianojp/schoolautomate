<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoServiceRecord"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
 TD{
 	font-size: 11px;
 }
</style>
</head>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
//add security hehol.
	try
	{
		dbOP = new DBOperation();		
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}

hr.HRRetirementMgmt retMgmt = new hr.HRRetirementMgmt();

Vector vRetResult = null;
int iElemCount = 0;


vRetResult = retMgmt.getRetirementContributionSummary(dbOP, request);
if(vRetResult == null)
	strErrMsg = retMgmt.getErrMsg();
else
	iElemCount = retMgmt.getElemCount();

double dMultiplier = Double.parseDouble(WI.getStrValue(WI.fillTextValue("multiplier"),".0325"));
%>

<body>

 <% 
if(strErrMsg != null){dbOP.cleanUP();
%>
<div style="text-align:center; color:#FF0000; font-weight:bold;font-size:12px;"><%=strErrMsg%></div>
<%return;}
if(vRetResult != null && vRetResult.size() > 0){

double dGrandTotal = 0d;
double dTemp = 0d;
int iCount = 0;

String[] astrMonthOf = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
String strSchName = SchoolInformation.getSchoolName(dbOP, true, false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP, false, false);

int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));



int iTotalPages = (vRetResult.size())/(iElemCount*iMaxRecPerPage);		
if((vRetResult.size()) % (iElemCount*iMaxRecPerPage) > 0) ++iTotalPages;

int iRecPerPage = 0;
int iPageCount = 0;
boolean bolPageBreak = false;

int i = 0;

for(i =0 ; i < vRetResult.size(); ){
iRecPerPage = 0;
if(bolPageBreak){bolPageBreak = false;
%>
<div style="page-break-after:always;">&nbsp;</div>
<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td align="center"><strong style="font-size:12px;"><%=strSchName%><br><%=strSchAddr%></strong></td>
	</tr>
	<tr>
	    <td align="center" height="25">&nbsp;</td>
    </tr>
	<tr><td align="center" height="25"><strong style="font-size:12px;">SUMMARY OF RETIREMENT CONTRIBUTION<br>
	For the Month of <u><%=astrMonthOf[Integer.parseInt(WI.fillTextValue("month_of"))].toUpperCase()%> <%=WI.fillTextValue("year_of")%></u>
	</strong></td></tr>
	<tr >
        <td height="20" colspan="5" align="right"><font size="1">Page <%=++iPageCount%> of <%=iTotalPages%></font></td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="6%" height="20" align="center" class="thinborder">No.</td>
		<td width="13%" align="center" class="thinborder">EMPLOYEE ID</td>
		<td width="19%" align="center" class="thinborder">LAST NAME</td>
		<td width="16%" align="center" class="thinborder">FIRST NAME</td>
		<td width="19%" align="center" class="thinborder">MIDDLE NAME</td>
		<td width="15%" align="center" class="thinborder">BASIC PAY</td>
		<td width="12%" align="center" class="thinborder">AMOUNT</td>
	</tr>
<%


for(; i < vRetResult.size(); i+=iElemCount){

if(++iRecPerPage > iMaxRecPerPage){
	bolPageBreak = true;
	break;
}

%>
	<tr>
	    <td align="right" class="thinborder" height="20"><%=++iCount%>.&nbsp;</td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i))%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3)).toUpperCase()%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+1)).toUpperCase()%></td>
	    <td class="thinborder"><%=WI.getStrValue(WI.getStrValue(vRetResult.elementAt(i+2)).toUpperCase(),"&nbsp;")%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+4);
		dTemp  = Double.parseDouble(ConversionTable.replaceString(strTemp, ",", ""));		
		%>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTemp,true)%></td>
		<%
		dTemp = dTemp * dMultiplier;
		
		dGrandTotal += dTemp;
		%>
	    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTemp,true)%></td>
	</tr>
	
<%}
if(i >= vRetResult.size()){
%>
	<tr>
	    <td height="20" colspan="6" align="right" class="thinborder"><strong>GRAND TOTAL</strong> &nbsp;</td>
	    <td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(dGrandTotal,true)%></strong></td>
    </tr>
<%}%>
</table>
<%}//end outer loop%>
<script>window.print();</script>
<%}%>


</body>
</html>
<%
dbOP.cleanUP();
%>
