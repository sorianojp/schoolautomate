<%
String strStudID    = (String)request.getSession(false).getAttribute("userId");
if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.FAAssessment,enrollment.EnrlAddDropSubject,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;

	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Parent/Student-enrollment","installment_sched.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForParentStudLink(dbOP,(String)request.getSession(false).getAttribute("userId"),
							(String)request.getSession(false).getAttribute("authTypeIndex"),request.getRemoteAddr());
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
//end of authenticaion code.

astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)//db error
{
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=dbOP.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}

//end of security code.
Vector vStudInfo = new Vector();
Vector vScheduledPmt = new Vector();
Vector vInstallPmtSchedule = null;
double dRefunded = 0d;//I have to consider refunded amout at the end of payment schedule.
double dInstallmentPayable = 0d;double dCumInstallmentPayable = 0d;


FAAssessment FA = new FAAssessment();
EnrlAddDropSubject enrlInfo = new EnrlAddDropSubject();

vStudInfo = enrlInfo.getEnrolledStudInfo(dbOP,strStudID, strStudID, astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);

if(vStudInfo == null || vStudInfo.size() == 0)
	strErrMsg = enrlInfo.getErrMsg();
else
{
	dRefunded = new enrollment.FAFeeOperation().calRefundedAmount(dbOP, -1, (String)vStudInfo.elementAt(0),
						 astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2], true);

	//get scheduled payment information.
	vScheduledPmt =FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),
										astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2]);
	if(vScheduledPmt == null || vScheduledPmt.size() ==0)
		strErrMsg = FA.getErrMsg();
  //////////// Posting pmt schedule.
   vInstallPmtSchedule = 
        FA.getOtherChargePayable(dbOP, astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2], (String)vStudInfo.elementAt(0) );
	if(vInstallPmtSchedule != null)
		vInstallPmtSchedule.removeElementAt(0);
    //this determines how the posting fees paid.
}


dbOP.cleanUP();
if(strErrMsg == null) strErrMsg = "";
%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" ><strong>::::
        SCHEDULE ACCOUNT PAYMENT SCHEDULE ::::</strong></font></div></td>
    </tr>
	</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#BECED3">
      <td height="25" bgcolor="#BECED3"><div align="center"><font color="#FFFFFF" size="1"><strong>PAYMENT
        SCHEDULE FOR <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>,
        SCHOOL YEAR <%=astrSchYrInfo[0]+"-"+astrSchYrInfo[1]%></strong></font></div></td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" >&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
	</table>

<%
if(vScheduledPmt != null && vScheduledPmt.size() > 0)
{%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="21%" height="25">&nbsp;</td>
    <td width="33%">OUTSTANDING BALANCE</td>
    <td width="46%"><%=CommonUtil.formatFloat((vScheduledPmt.elementAt(1)).toString(),true)%>
      Php</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>TOTAL PAYABLE TUITION FEE</td>
    <td><%=CommonUtil.formatFloat((vScheduledPmt.elementAt(0)).toString(),true)%>
      Php</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>AMOUNT PAID UPON ENROLLMENT</td>
    <td><%=CommonUtil.formatFloat((vScheduledPmt.elementAt(2)).toString(),true)%>
      Php</td>
  </tr>
   <%
	if(dRefunded > 0.2d || dRefunded < -0.2d){%>
	 <tr>
      <td height="25">&nbsp;</td>
      <td><font size="1" color="#0033FF"><b>AMOUNT REFUNDED</b></font></td>
      <td><font size="1" color="#0033FF"> <b>Php <%=CommonUtil.formatFloat(dRefunded,true)%></b></font></td>
    </tr>
   <%}%>
  <tr>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25" width="2%">&nbsp;</td>
    <td width="20%" align="center"><strong><font size="1">INSTALLAMENT AMOUNT</font></strong></td>
    <td width="20%" align="center"><strong><font size="1">LAST DUE DATE(mm/dd/yyyy)</font></strong></td>
    <td width="20%" align="center"><strong><font size="1">AMOUNT DUE</font></strong></td>
    <td width="20%" align="center"><strong><font size="1">AMOUNT PAID</font></strong></td>
    <td width="18%" align="center"><strong><font size="1">BALANCE AMOUNT</font></strong></td>
  </tr>
  <%
int iEnrlSetting      = FA.getEnrollemntInstallmentSetting();//1= (total due-first payment)/iInstalCount, 0=total due/iInstallCount - first installment.
float fAmoutPaidDurEnrollment = ((Float)vScheduledPmt.elementAt(2)).floatValue();
float fInstallAmount = ((Float)vScheduledPmt.elementAt(3)).floatValue();
float fCumAmountPaid = 0f; // total amount paid
if(iEnrlSetting ==0)
	fCumAmountPaid = fAmoutPaidDurEnrollment;
float fAmountDue = 0f; //installment amount + amount due in previous payment.
int iNoOfInstallments = ((Integer)vScheduledPmt.elementAt(4)).intValue();

for(int i=0,j=5; i<iNoOfInstallments ;++i)
{
	if(j ==5)
	{
		if(iEnrlSetting ==0)
			fAmountDue = fInstallAmount - fAmoutPaidDurEnrollment;
		else if(iEnrlSetting == 1)
			fAmountDue = fInstallAmount;
                else if(iEnrlSetting == 2) //UI
			fAmountDue = ((Double)vScheduledPmt.elementAt(vScheduledPmt.size() - 1)).floatValue();

	}
	else
		fAmountDue += fInstallAmount - ((Float)vScheduledPmt.elementAt(j+2 - 3)).floatValue();
	fCumAmountPaid += ((Float)vScheduledPmt.elementAt(j+2)).floatValue();

	

       //////////////// installment payment - start /////////
	   dInstallmentPayable = 0d;
        if(vInstallPmtSchedule != null) {
          for(;vInstallPmtSchedule.size() > 0;) {
            //if matching, get value and break. else continue;
            if( ((String)vInstallPmtSchedule.elementAt(1)).compareTo((String)vScheduledPmt.elementAt(j)) == 0) {
              dInstallmentPayable = Double.parseDouble((String)vInstallPmtSchedule.elementAt(2));
              vInstallPmtSchedule.removeElementAt(0);
              vInstallPmtSchedule.removeElementAt(0);
              vInstallPmtSchedule.removeElementAt(0);
              break;
            }
            ///keep adding to payable.
            dInstallmentPayable = Double.parseDouble((String)vInstallPmtSchedule.elementAt(2));
            vInstallPmtSchedule.removeElementAt(0);
            vInstallPmtSchedule.removeElementAt(0);
            vInstallPmtSchedule.removeElementAt(0);
          }
        }
		dCumInstallmentPayable += dInstallmentPayable;
		fAmountDue += dInstallmentPayable;
        //////////////// installment payment - end /////////
	

%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td align="center"> 
      <%
	  if(j ==5 && iEnrlSetting == 0){%>
      <%=CommonUtil.formatFloat(fInstallAmount - fAmoutPaidDurEnrollment + dInstallmentPayable,true)%> 
      <%}else{%>
      <%=CommonUtil.formatFloat(fInstallAmount + dInstallmentPayable,true)%> 
      <%}%>
    </td>
    <td align="center"> 
      <%
	  if(vScheduledPmt.size() > j){%>
      <%=(String)vScheduledPmt.elementAt(j+1)%> 
      <%}%>
    </td>
    <td align="right"><%=CommonUtil.formatFloat(fAmountDue,true)%>&nbsp;&nbsp;</td>
    <td align="right"> 
      <%
	  if(vScheduledPmt.size() > j){%>
      <%=CommonUtil.formatFloat(vScheduledPmt.elementAt(j+2).toString(),true)%> 
      <%}%>
      &nbsp;&nbsp;</td>
    <td align="right"> 
      <%if(iEnrlSetting == 2){%>
      <%=CommonUtil.formatFloat(fAmountDue - ((Float)vScheduledPmt.elementAt(j+2)).floatValue(),true)%> 
      <%}else{%>
      <%=CommonUtil.formatFloat(fInstallAmount*(i+1) + dCumInstallmentPayable - fCumAmountPaid,true)%> 
      <%}%>
      &nbsp;&nbsp;</td>
  </tr>
  <%
j = j+3;
}if(dRefunded > 0.2d || dRefunded < -0.2d){%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td align="right"><font size="1" color="#0033FF"><b>AMOUNT REFUNDED</b></font> 
      &nbsp;&nbsp;</td>
    <td align="right"><font size="1" color="#0033FF"><b><%=CommonUtil.formatFloat(dRefunded,true)%></b></font> &nbsp;&nbsp;</td>
  </tr>
  <%}//show refund if there is any.%>
</table>

<%
}//only if vScheduledPmt != null;
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" colspan="2"><strong><font color="#000099">NOTE : </font></strong></td>
  </tr>
  <tr>
    <td width="5%" height="25">&nbsp;</td>
    <td width="95%"><strong><font color="#000099">TOTAL PAYABLE TUITION FEE is
      an updated amount. Adjustments, discounts and dropped/withdrawn subjects
      are already integrated</font></strong></td>
  </tr>
  <tr>
    <td height="25" colspan="2">&nbsp;</td>
  </tr>
  <tr bgcolor="#B8CDD1">
    <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
  </tr>
</table>
</body>
</html>
