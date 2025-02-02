<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>

<body>
<%@ page language="java" import="utility.*,Accounting.EnrollmentJournal,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

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

Vector vRetResult  = null;
Vector vSummaryCollege  = null;
Vector vSummaryCourse   = null;

String strTotalAmt = null;

//post verify here.. 
	EnrollmentJournal ERJ = new EnrollmentJournal();
	vRetResult = ERJ.getAdvanceEnrollmentList(dbOP, request);
	if(vRetResult == null)
		strErrMsg = ERJ.getErrMsg();
	else {
		strTotalAmt     = (String)vRetResult.remove(0);    
		vSummaryCourse  = (Vector)vRetResult.remove(0);
		vSummaryCollege = (Vector)vRetResult.remove(0);
	}	
	
	String[] astrConvertSem = {"SU","FS","SS","TS"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="6"><div align="center"><strong>:::: ADVANCE ENROLLMENT PAYMENT INFORMATION ::::</strong></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr valign="top">
  		<td>
			  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
				  <td height="22" colspan="2" align="center" style="font-weight:bold; font-size:14px;" valign="bottom" class="thinborderBOTTOM">SUMMARY PER COURSE </td>
				</tr>
				<tr>
				  <td height="22" align="center" style="font-weight:bold;" class="thinborderNONE">Course Code</td>
				  <td align="right" style="font-weight:bold;" class="thinborderNONE">Amount</td>
				</tr>
				<%for(int i = 0; i < vSummaryCourse.size(); i += 2) {%>
					<tr>
					  <td height="20" class="thinborderNONE"><%=vSummaryCourse.elementAt(i)%></td>
					  <td align="right" class="thinborderNONE"><%=vSummaryCourse.elementAt(i + 1)%></td>
					</tr>
				<%}%>
			  </table>
		</td>
  		<td width="6%">&nbsp;</td>
  		<td>
			  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
				  <td height="22" colspan="2" align="center" style="font-weight:bold; font-size:14px;" valign="bottom" class="thinborderBOTTOM">SUMMARY PER COLLEGE </td>
				</tr>
				<tr>
				  <td height="22" align="center" style="font-weight:bold;" class="thinborderNONE">College Code</td>
				  <td align="center" style="font-weight:bold;" class="thinborderNONE">Amount</td>
				</tr>
				<%for(int i = 0; i < vSummaryCollege.size(); i += 2) {%>
					<tr>
					  <td height="20" class="thinborderNONE"><%=vSummaryCollege.elementAt(i)%></td>
					  <td align="right" class="thinborderNONE"><%=vSummaryCollege.elementAt(i + 1)%></td>
					</tr>
				<%}%>
			  </table>
		</td>
  	</tr>
  </table>
  <br>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center" style="font-weight:bold; font-size:14px;" valign="bottom" class="thinborderBOTTOM">::: PAYMENT DETAILS ::: </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	  <td style="font-weight:bold; font-size:11px;" width="5%">Count</td>
	  <td height="20" style="font-weight:bold; font-size:11px;" width="15%">Student ID </td>
	  <td style="font-weight:bold; font-size:11px;" width="25%">Student Name </td>
	  <td style="font-weight:bold; font-size:11px;" width="10%">Course-Year </td>
	  <td style="font-weight:bold; font-size:11px;" width="10%">SY-Term</td>
	  <td style="font-weight:bold; font-size:11px;" width="10%">OR Number </td>
	  <td style="font-weight:bold; font-size:11px;" width="5%">Is Temp</td>
	  <td style="font-weight:bold; font-size:11px;" align="right" width="12%">Amount</td>
	</tr>
	<%int iRowCount = 0;
	for(int i = 0; i < vRetResult.size(); i += 9) {%>
		<tr>
		  <td><%=++iRowCount%></td>
		  <td height="22"><%=vRetResult.elementAt(i)%></td>
		  <td><%=vRetResult.elementAt(i + 1)%></td>
		  <td>
		  <%if(vRetResult.elementAt(i + 2) == null){%>
		  	<%=vRetResult.elementAt(i + 3)%>
		  <%}else{%>
		  	<%=vRetResult.elementAt(i + 2)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 3), "-","","")%>
		  <%}%>
		  </td>
		  <td><%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%><%=vRetResult.elementAt(i + 4)%></td>
		  <td><%=vRetResult.elementAt(i + 7)%></td>
		  <td><%=vRetResult.elementAt(i + 8)%></td>
		  <td align="right"><%=vRetResult.elementAt(i + 6)%></td>
		</tr>
	<%}%>
	<tr>
	  <td height="22" colspan="8" align="right" style="font-weight:bold; font-size:11px;">Total: <%=strTotalAmt%></td>
	</tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>
