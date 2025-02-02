<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
String strErrMsg = null;

if(strStudID == null)
	strErrMsg = "You are already logged out. Please login again.";
else if(strAuthTypeIndex == null || !strAuthTypeIndex.equals("4"))
	strErrMsg = "Access Denied.";
if(strErrMsg != null) {%>
	<p style="font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:24px;"><%=strErrMsg%></p>
<%return;}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document </title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script>
//do nothing.
</script>
</head>
<%@ page language="java" import="utility.*,clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	String strTemp = null;

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

boolean bolLmsPending        = false; Vector vClearanceInfo = null;
boolean bolClearancePending = false;
double dOSBal = 0d;//outstanding balance.

//other clearance.
Vector vOthClearance = null;

String strSYFrom   = null;
String strSYTo     = null;
String strSemester = null;

enrollment.EnrlAddDropSubject eas = new enrollment.EnrlAddDropSubject();

String strSQLQuery = "select sy_from, sy_to, semester from stud_curriculum_hist "+
      	" join semester_sequence on (semester_sequence.semester_val = semester) "+
      	" where user_index = "+strUserIndex+
      	" and is_valid = 1 order by sy_from desc, sem_order desc";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
if(rs.next()) {
	strSYFrom   = rs.getString(1);
	strSYTo     = rs.getString(2);
	strSemester = rs.getString(3);
}
rs.close();


if(strSYFrom != null) {
	//get receivable.. 
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	dOSBal = fOperation.calOutStandingOfPrevYearSem(dbOP, strUserIndex,true, true);
	//dOSBal = 0d;
	///get other clearance posted.. 
	clearance.ClearanceMain cM = new clearance.ClearanceMain();
	vOthClearance = cM.getStudPendingClearance(dbOP,strUserIndex, "-1");
	if(vOthClearance == null) 
		strErrMsg = cM.getErrMsg();
	
	//for LMS.
	lms.PatronInformation pInfo = new lms.PatronInformation();
	vClearanceInfo = pInfo.queryForClearance(dbOP, strUserIndex);
	if(vClearanceInfo == null)
		strErrMsg = pInfo.getErrMsg();
	else if(vClearanceInfo.size() > 0) {
		bolLmsPending = true;
		bolClearancePending = true;
	}
}
String[] astrConvertTerm = {"Summer", "1st","2nd","3rd","4th","5th"};
%>

<body bgcolor="#9FBFD0">
<form name="form_" method="post" action = "clearance_main.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        CLEARANCES- PRINT CLEARANCE ::::</strong></font></div></td>
    </tr>
</table>  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;
	<%=WI.getStrValue(strErrMsg)%></td>
  </tr>
<%if(strSYFrom != null && strSemester != null) {%>
  <tr>
    <td width="4%" height="25">&nbsp;</td>
    <td width="15%" style="font-weight:bold; font-size:16px;">SY/Term: </td>
    <td width="81%" style="font-weight:bold; font-size:16px;"><%=astrConvertTerm[Integer.parseInt(strSemester)]%>, <%=strSYFrom%> - <%=strSYTo%></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td style="font-weight:bold; font-size:16px;">Student ID</td>
    <td style="font-weight:bold; font-size:16px;"><%=strStudID%></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td style="font-weight:bold; font-size:16px;">Student Name</td>
    <td style="font-weight:bold; font-size:16px;"><%=(String)request.getSession(false).getAttribute("first_name")%></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td></td>
    <td></td>
  </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" bgcolor="#FFFFFF">
	<tr><td width="40%">
	<%if(bolLmsPending) {%>
		<table width="95%" border="0" cellpadding="0" cellspacing="0">
		  <tr>
			<td colspan="2" align="center" bgcolor="#9FcFFF" class="thinborderALL" height="18"><strong>Circulation Detail</strong></td>
		  </tr>
		  <tr>
			<td width="24%" height="18" bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT"> Books Issued(Due now) </td>
			<td bgcolor="#EEEEEE" width="8%" class="thinborderBOTTOMLEFTRIGHT"><%=(String)vClearanceInfo.elementAt(0)%></td>
		  </tr>
		  <tr>
			<td height="18" bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT"> Overdue </td>
			<td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT"><%=(String)vClearanceInfo.elementAt(1)%></td>
		  </tr>
		  <tr>
			<td height="18" bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Unpaid Fine Outstanding </td>
			<td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT"><%=(String)vClearanceInfo.elementAt(2)%></td>
		  </tr>
		</table>
	<%}else{%>
		<font style="color:#0000FF; font-weight:bold; font-size:14">Library Clearance :: OK </font>
		<font size="1" color="#0000FF"><br> &radic; All books are returned <br> 
		&radic; No outstanding balance/Fine  </font>
	    <%}%>
	</td>
	<td width="10%"></td>
	<td width="50%" valign="top">
	<%if(dOSBal > 1.0d){bolClearancePending = true; %>
		<font size="4" color="red"><strong>Outstanding Balance : 
			<%=CommonUtil.formatFloat(dOSBal,true)%></strong></font>	
	<%}else{%>
		<font style="color:#0000FF; font-weight:bold; font-size:14">Accounts Receivable :: OK </font>
		<font size="1" color="#0000FF"><br> &radic; No outstanding balance</font>
	<% }%>
	</td>
	</tr>
</table>
<%if(vOthClearance != null && vOthClearance.size() > 0) {bolClearancePending = true;%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	  <tr>
		<td colspan="6" align="center" bgcolor="#9FcFFF" class="thinborderALL" height="18"><strong>:: Other Pending Clearance :: </strong></td>
	  </tr>
	  <tr bgcolor="#DDDDDD">
		<td width="20%" height="18" class="thinborderBOTTOMLEFT"><strong> Posted By </strong></td>
		<td width="10%" class="thinborderBOTTOMLEFT"><strong>Due</strong></td>
		<td width="25%" class="thinborderBOTTOMLEFT"><strong>Requirement</strong></td>
		<td width="25%" class="thinborderBOTTOMLEFT"><strong>Remark</strong></td>
		<td width="10%" class="thinborderBOTTOMLEFTRIGHT"><strong>Date Posted </strong></td>
	    <td width="10%" class="thinborderBOTTOMLEFTRIGHT"><strong>Last Date to Clear </strong></td>
	  </tr>
<%for(int i = 0; i < vOthClearance.size(); i += 8){%>
	  <tr bgcolor="#EEEEEE">
	    <td height="18" class="thinborderBOTTOMLEFT"><%=vOthClearance.elementAt(i) +" - "+vOthClearance.elementAt(i + 1)%></td>
	    <td class="thinborderBOTTOMLEFT">
			Amt : <%=WI.getStrValue((String)vOthClearance.elementAt(i+2),"","","0")%><br>
			Qty : <%=WI.getStrValue((String)vOthClearance.elementAt(i+3),"","","n/a")%></td>
	    <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(vOthClearance.elementAt(i + 4),"&nbsp;")%></td>
	    <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(vOthClearance.elementAt(i + 5),"&nbsp;")%></td>
	    <td class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue(vOthClearance.elementAt(i + 6),"&nbsp;")%></td>
	    <td class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue(vOthClearance.elementAt(i + 7),"&nbsp;")%></td>
      </tr>
<%}//end of for loop %>
    </table>
<%}//end of vOthClearance..
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<!--
<%if(bolClearancePending){%>
    <tr> 
      <td height="25" colspan="5" style="font-size:14px; color:#FF0000; font-weight:bold" align="center">System suggests not to print Clearance for this student</td>
    </tr>
<%}if(strSchCode.startsWith("AUF")){%>
    <tr> 
      <td height="25" colspan="5" align="center"><a href="javascript:PrintPg();">
	  	<img src="../../../images/print.gif" border="0"></a><font size="1"> Print Clearance</font></td>
    </tr>
<%}%>
-->
<%if(!bolClearancePending){%>
    <tr> 
      <td height="25" colspan="5" style="font-size:24px; color:; font-weight:bold" align="center"><<<<<<< Nothing Pending For Clearance. >>>>>>>></td>
    </tr>
<%}%>
 
 
<%}//do not show if syfrom is null%>
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr bgcolor="#47768F"> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
</table>  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>