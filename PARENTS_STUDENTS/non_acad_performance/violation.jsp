<%
String strStudIndex = (String)request.getSession(false).getAttribute("userIndex");
if(strStudIndex == null) {
	%>
		<p style="font-weight:bold; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif">
			You are already logged out. Please login again.
		</p>
	<%return;
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="JavaScript">
</script>
<body bgcolor="9FBFD0">
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ViolationConflict"%>
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
String strSQLQuery    = null;
java.sql.ResultSet rs = null;
Vector vRetResult     = new Vector();

strSQLQuery = "select sy_from, semester, date_of_violation, date_reported, case_no,VIOLATION_NAME, INCIDENT,"+
				"VIOLATION_DESCRIPTION, action_taken, RECOMENDATAION, IS_CLEAR  from OSA_VIOLATION "+
				"join OSA_PRELOAD_VIOL_TYPE on (OSA_PRELOAD_VIOL_TYPE.VIOLATION_TYPE_INDEX = osa_violation.VIOLATION_TYPE_INDEX) "+
				"join OSA_PRELOAD_VIOL_INCIDENT on (OSA_PRELOAD_VIOL_INCIDENT.INCIDENT_INDEX = osa_violation.INCIDENT_INDEX) "+
				"where is_valid = 1 and exists (select * from OSA_VIOLATION_CPARTY where v_index = osa_violation.VIOLATION_INDEX and u_index = "+strStudIndex+") "+
				"order by IS_CLEAR asc, DATE_OF_VIOLATION desc";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vRetResult.addElement(rs.getString(1));//[0] sy_from 
	vRetResult.addElement(rs.getString(2));//[1] semester 
	vRetResult.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(3)));//[2] date_of_violation 
	vRetResult.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(4)));//[3] date_reported 
	vRetResult.addElement(rs.getString(5));//[4] case_no 
	vRetResult.addElement(rs.getString(6));//[5] VIOLATION_NAME 
	vRetResult.addElement(rs.getString(7));//[6] INCIDENT 
	vRetResult.addElement(rs.getString(8));//[7] VIOLATION_DESCRIPTION 
	vRetResult.addElement(rs.getString(9));//[8] action_taken 
	vRetResult.addElement(rs.getString(10));//[9] RECOMENDATAION 
	vRetResult.addElement(rs.getString(11));//[10] IS_CLEAR 
}				 
rs.close();
dbOP.cleanUP();

if(vRetResult.size() == 0) {%>
	<p style="font-size:14px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> No Violation recorded.</p>
<%
return;
}%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center"><strong>List of Violations</strong></td>
    </tr>
 </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold;" align="center">
      <td width="8%" height="26" class="thinborder">SY-Term </td>
      <td width="8%" class="thinborder">Violation Date </td>
      <td width="8%" class="thinborder">Case # </td>
      <td width="20%" class="thinborder">Incident </td>
      <td width="20%" class="thinborder">Description</td>
      <td width="36%" class="thinborder">Recommendation</td>
    </tr>
    <%
	String strTRCol = "";
	String[] astrConvertTerm = {"SU","FS","SS","TS","4","5"};
	for(int i = 0 ; i< vRetResult.size(); i += 11){
		if(strTRCol.length() == 0 && vRetResult.elementAt(i + 10).equals("1"))
			strTRCol = "bgcolor='#bbbbbb'";
	%>
    <tr <%=strTRCol%>>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i)%> - <%=astrConvertTerm[Integer.parseInt((String)vRetResult.elementAt(i + 1))]%></font></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 7)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 9)%></font></td>
    </tr>
    <%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable4">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>

</body>
</html>
<%
dbOP.cleanUP();
%>
