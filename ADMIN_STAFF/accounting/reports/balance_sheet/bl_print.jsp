<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,Accounting.Report.ReportGeneric, java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.

ReportGeneric rg  = new ReportGeneric();
Vector vRetResult = rg.getBalanceSheet(dbOP, request);
if(vRetResult == null)
	strErrMsg = rg.getErrMsg();

String strReportDate = null;

int iReportFormat = Integer.parseInt(WI.fillTextValue("report_format"));
if(iReportFormat == 1) {//Date Range.
	if(WI.fillTextValue("date_to").length() > 0) 
		strReportDate = " Date : "+WI.fillTextValue("date_fr")+" to "+WI.fillTextValue("date_to");
	else	
		strReportDate = " Date : "+WI.fillTextValue("date_fr");
}
else if (iReportFormat == 2){//monthly.
	String[] astrConvertMonth = {"Jan","Feb","March","April","May","June","July","Aug","Sept","Oct","Nov","Dec"};
	strReportDate = " Month of "+astrConvertMonth[Integer.parseInt(WI.fillTextValue("jv_month"))]+
					" "+WI.fillTextValue("jv_year");
}
else if(iReportFormat == 3) {
	String[] astrConvertQuarterly = {"","First Quarter","Second Quarter","Third Quarter","Fourth Quarter"};
	strReportDate = astrConvertQuarterly[Integer.parseInt(WI.fillTextValue("quarterly"))]+
					" of Year :"+WI.fillTextValue("jv_year");
}
else
	strReportDate = " Year : "+WI.fillTextValue("jv_year");

boolean bolIsSACI = false;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
bolIsSACI = strSchCode.startsWith("UDMC");
if(strSchCode.startsWith("TSUNEISHI") || strSchCode.startsWith("CDD"))
	bolIsSACI = true;
	
String strPrevYr      = WI.fillTextValue("prev_yr");
boolean bolShowPrevYr = false;
if(strPrevYr.length() > 0)
	bolShowPrevYr = true;

%>
<body>
<%if(vRetResult == null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold"><%=strErrMsg%></td>
    </tr>
  </table>
<%
dbOP.cleanUP();
return;}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" align="center">
      	<font size="2">
      	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>    
      </td>
    </tr>
    <tr> 
      <td height="50"><div align="center"><strong><u>BALANCE SHEET <br>
          </u></strong><%=strReportDate%></div></td>
    </tr>
  </table>
  
<%
int iRowCount = 0;

Vector v1 = (Vector)vRetResult.remove(0);
Vector v2 = (Vector)vRetResult.remove(0);
Vector v4 = (Vector)vRetResult.remove(0);
Vector v5 = (Vector)vRetResult.remove(0);
Vector v6 = (Vector)vRetResult.remove(0);

//System.out.println(v1);
//System.out.println(v2);
//System.out.println(v4);
//System.out.println(v5);
//System.out.println(v6);

String[] astrConvertSGOrder = {"","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
String strBSCoaCF = null; String SGIndex = null; String strMainIndex = null; int iAddStat = 0;
double dTempAmount = 0d;

double dTempSubItemTotalAdd = 0d; double dTempSubItemTotalSubtract = 0d;
double dMainItemTotalAdd    = 0d; double dMainItemTotalSubtract    = 0d;
double dCOACFTotalAdd       = 0d; double dCOACFTotalSubtract       = 0d;

String strSubItemName = null; boolean bolIsSubPresent = false;
for(int i = 0; i < v1.size(); i += 3) {
	strBSCoaCF = (String)v1.elementAt(i);%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="18"><!--1--></td>
      <td height="18" colspan="8" style="font-size:14px; font-weight:bold" align="center"><%=v1.elementAt(i + 1)%></td>
    </tr>
 <%for(int p = 0; p < v2.size();){
 	if(!v2.elementAt(p + 1).equals(strBSCoaCF)) {
		p += 8;
		continue;
	}
	SGIndex        = (String)v2.elementAt(p + 3);
	%>
	<tr> 
      <td height="18" style="font-size:10px;"><%if(!bolIsSACI){%><%=++iRowCount%>.<%}%></td>
      <td height="18" colspan="3">&nbsp;<%if(!bolIsSACI){%><%=astrConvertSGOrder[Integer.parseInt((String)v2.elementAt(p + 2))]%>. <%}%><%=v2.elementAt(p + 4)%></td>
      <td width="14%" height="18">&nbsp;</td>
      <td width="3%" height="18">&nbsp;</td>
      <td width="14%" height="18">&nbsp;</td>
      <td width="2%" height="18">&nbsp;</td>
      <td width="17%" height="18">&nbsp;</td>
    </tr>
	<%for(;p < v2.size(); p += 8){
		strMainIndex = (String)v2.elementAt(p);
		if(!v2.elementAt(p + 1).equals(strBSCoaCF) || !v2.elementAt(p + 3).equals(SGIndex))//go out if it has a different coa_cf or sg_index
			break;
			%>
    <tr> 
      <td height="18" style="font-size:10px;"><%if(!bolIsSACI){%><%=++iRowCount%>.<%}%></td>
      <td width="2%" height="18">&nbsp;</td>
      <td height="18" colspan="2"><%=WI.getStrValue(v2.elementAt(p + 6), "--")%></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <%for(int k = 0; k < v4.size(); k += 4) {//print all sub item informatin.
		if(!v4.elementAt(k).equals(strMainIndex))
			continue; 
		iAddStat = Integer.parseInt((String)v4.elementAt(k + 2));
		dTempAmount = ((Double)v4.elementAt(k + 3)).doubleValue();
		
		if(iAddStat == 1) {
			dTempSubItemTotalAdd += dTempAmount;
			dMainItemTotalAdd    += dTempAmount;
			dCOACFTotalAdd       += dTempAmount;
		}
		else {	
			dTempSubItemTotalSubtract += dTempAmount;
			dMainItemTotalSubtract    += dTempAmount;
			dCOACFTotalSubtract       += dTempAmount;
		}
		if(v4.elementAt(k + 1) != null)
			bolIsSubPresent = true;
	%>
	<tr> 
      <td height="18" style="font-size:10px;"><%if(!bolIsSACI){%><%=++iRowCount%>.<%}%></td>
      <td height="18">&nbsp;</td>
      <td width="2%" height="18">&nbsp;</td>
      <td width="44%" height="18"><%=WI.getStrValue(v4.elementAt(k + 1))%></td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18" align="right"><%if(iAddStat == 1){%><%=CommonUtil.formatFloat(dTempAmount, true)%><%}%></td>
      <td height="18">&nbsp;</td>
      <td height="18" align="right"><%if(iAddStat == 0){%><%=CommonUtil.formatFloat(dTempAmount, true)%><%}%></td>
    </tr>
	<%
	v4.removeElementAt(k);v4.removeElementAt(k);v4.removeElementAt(k);v4.removeElementAt(k); k -= 4;
	}//end of for(int k = 0; k < v4.size(); k += 4) {
	if(bolIsSubPresent){%>
    <tr> 
      <td height="25" style="font-size:10px;"><%if(!bolIsSACI){%><%=++iRowCount%>.<%}%></td>
      <td>&nbsp;</td>
      <td colspan="2" align="center">TOTAL <%=WI.getStrValue(v2.elementAt(p + 6)).toUpperCase()%> </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right"><%if(dTempSubItemTotalAdd != 0d){%><u><%=CommonUtil.formatFloat(dTempSubItemTotalAdd, true)%></u><%}%></td>
      <td>&nbsp;</td>
      <td align="right"><%if(dTempSubItemTotalSubtract != 0d){%><u><%=CommonUtil.formatFloat(dTempSubItemTotalSubtract, true)%></u><%}%></td>
    </tr>
	<%dTempSubItemTotalAdd = 0d;dTempSubItemTotalSubtract = 0d;}bolIsSubPresent = false;
	   }//end of for(;p < v2.size(); p += 8){%>
    <tr> 
      <td height="10" style="font-size:10px;"><%if(!bolIsSACI){%><%=++iRowCount%>.<%}%></td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2" align="center">TOTAL <%=v2.elementAt(p + 4 - 8)%> </div> </td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" align="right"><%if(dMainItemTotalAdd != 0d){%><u><%=CommonUtil.formatFloat(dMainItemTotalAdd, true)%></u><%}%></td>
      <td height="10"></td>
      <td height="10" align="right"><%if(dMainItemTotalSubtract != 0d){%><u><%=CommonUtil.formatFloat(dMainItemTotalSubtract, true)%></u><%}%></td>
    </tr>
	
	
<%dMainItemTotalAdd = 0d;dMainItemTotalSubtract = 0d;
	}//end of v2%>
	
    <tr> 
      <td height="10" style="font-size:10px;"><%if(!bolIsSACI){%><%=++iRowCount%>.<%}%></td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2" align="center"><u>&nbsp;&nbsp;TOTAL <%=WI.getStrValue(v1.elementAt(i + 1)).toUpperCase()%>&nbsp;&nbsp;</u></div> </td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" align="right"><%if(dCOACFTotalAdd != 0d){%><u><%=CommonUtil.formatFloat(dCOACFTotalAdd, true)%></u><%}%></td>
      <td height="10"></td>
      <td height="10" align="right"><%if(dCOACFTotalSubtract != 0d){%><u><%=CommonUtil.formatFloat(dCOACFTotalSubtract, true)%></u><%}%></td>
    </tr>

<%dCOACFTotalAdd = 0d;dCOACFTotalSubtract = 0d;}//end of v1 -- The END.%>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>
