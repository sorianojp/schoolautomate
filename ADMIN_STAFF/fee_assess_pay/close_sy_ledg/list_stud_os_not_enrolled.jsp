<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.FAStudentLedgerExtn,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strErrMsg = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","list_stud_os_not_enrolled.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"list_stud_os_not_enrolled.jsp");
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

FAStudentLedgerExtn FASLedg = new FAStudentLedgerExtn();
Vector vRetResult = FASLedg.viewOutStandingBalanceAndRefundNotEnrolled(dbOP, request);
Vector vStudConInfo = new Vector();
Vector vUserIndex   = new Vector();

if(vRetResult == null) 
	strErrMsg = FASLedg.getErrMsg();
else {
	vStudConInfo = (Vector)vRetResult.remove(0);
	if(vStudConInfo == null)
		vStudConInfo = new Vector();
	else	
		vUserIndex = (Vector)vStudConInfo.remove(0);
}

String[] astrConvertTerm = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};

boolean bolShowAddress = WI.fillTextValue("inc_address").equals("1");
int iIndexOfAddr = 0;
int iColSpan = 0;

if(bolShowAddress)
	iColSpan = -1;
else	
	iColSpan = -2;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable4">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF STUDENTS WITH BACK-ACCOUNT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr> 
      <td width="1%" height="25"></td>
      <td width="99%" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%
double dAmountPerRow = 0d;
double dSubTotal     = 0d; 
double dGT           = 0d;

if(vRetResult != null){%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="4" bgcolor="#C2BEA3" class="thinborder"><div align="center"><strong><font color="#FFFFFF">::: 
          LIST OF STUDENT WITH OUTSTANDING BALANCE AND NOT ENROLLED IN (
		  <%if(WI.fillTextValue("semester").length() > 0) {%>
		  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, 
		  <%}//for whole school year. %>
		  <%=WI.fillTextValue("sy_from")%>-<%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>) :::</font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr style="font-weight:bold">
      <td width="5%" class="thinborder" style="font-size:9px;">No.</td> 
      <td width="15%" height="24" class="thinborder" style="font-size:9px;">Student ID</td>
      <td width="25%" class="thinborder" style="font-size:9px;">Student Name</td>
<%if(!bolShowAddress){%>
      <td width="10%" class="thinborder" style="font-size:9px;">Year Level</td>
<%}else{%>
      <td width="10%" class="thinborder" style="font-size:9px;">Last SY/Term </td>
      <td width="25%" class="thinborder" style="font-size:9px;">Contact Address </td>
<%}%>
      <td width="28%" class="thinborder"><font size="1"><strong>BALANCE AMOUNT</strong></font></td>
    </tr>
    <%
String strCourseName = null; String strCourseToDisp = null;
int iRowCount = 0;
for(int i = 0; i< vRetResult.size() ; i +=6){
if(strCourseName == null) {
	strCourseName = (String)vRetResult.elementAt(i + 2);
	strCourseToDisp = strCourseName;
}
else if(strCourseName.equals(vRetResult.elementAt(i + 2))) {
	strCourseToDisp = null;
}
else {//it is not equal now.. 
	strCourseName = (String)vRetResult.elementAt(i + 2);
	strCourseToDisp = strCourseName;
	//also display the total per course row here.. %>
    <tr>
      <td class="thinborder" align="right" colspan="7">Sub Total : <%=CommonUtil.formatFloat(dSubTotal,true)%> &nbsp;&nbsp;&nbsp;</td>
    </tr>
	
<%dSubTotal = 0d;}
//System.out.println("Student ID : "+vRetResult.elementAt(i));
//System.out.println("Balance Amt : "+vRetResult.elementAt(i + 5));
dAmountPerRow = ((Double)vRetResult.elementAt(i + 5)).doubleValue();
dSubTotal += dAmountPerRow;
dGT += dAmountPerRow;
if(strCourseToDisp != null) {%>
    <tr>
      <td class="thinborder" colspan="7">&nbsp;&nbsp;Course : <%=strCourseToDisp%></td>
    </tr>
<%}%>
    <tr>
      <td class="thinborder"><%=++iRowCount%>.</td> 
      <td height="24" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
<%if(!bolShowAddress){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4),"&nbsp;")%></td>
<%}else{
iIndexOfAddr = vStudConInfo.indexOf((Integer)vUserIndex.elementAt(i/6));
if(iIndexOfAddr > -1) {
	strTemp = (String)vStudConInfo.elementAt(iIndexOfAddr + 1) + " - "+ (String)vStudConInfo.elementAt(iIndexOfAddr + 2);
	strErrMsg = (String)vStudConInfo.elementAt(iIndexOfAddr + 3);
	vStudConInfo.remove(iIndexOfAddr);vStudConInfo.remove(iIndexOfAddr);
	vStudConInfo.remove(iIndexOfAddr);vStudConInfo.remove(iIndexOfAddr);
}	
else {
	strTemp = null;
	strErrMsg = null;
}%>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(strErrMsg, "&nbsp;")%></td>
<%}%>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dAmountPerRow,true)%></td>
    </tr>
<%}//end of for loop.. %>
    <tr>
      <td class="thinborder" align="right" colspan="7">Sub Total : <%=CommonUtil.formatFloat(dSubTotal,true)%> &nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr>
      <td class="thinborder" align="right" colspan="7">Grand Total : <%=CommonUtil.formatFloat(dGT,true)%> &nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td><a href="javascript:PrintPg();">
	  <img src="../../../images/print.gif" border="0" name="print_hide"></a> 
        <font size="1">click to print list</font></td>
    </tr>
  </table>
 <%}//only if vRetResult != null%>
 
</body>
</html>
<%
dbOP.cleanUP();
%>