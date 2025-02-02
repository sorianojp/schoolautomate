<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintAssessment()
{
	var studID = document.assessment_sch.stud_id.value;
	if(studID.length ==0)
	{
		alert("Please enter student ID.");
		return;
	}

 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(vProceed)
	{
		var pgLoc = "./assessment_sched_print.jsp?stud_id="+escape(studID)+"&exam_sch="+document.assessment_sch.pmt_schedule[document.assessment_sch.pmt_schedule.selectedIndex].value;
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=assessment_sch.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAAssessment,enrollment.FAPaymentUtil,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-ASSESSMENT-assessment sched","assessment_sched.jsp");
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
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"assessment_sched.jsp");
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

Vector vStudInfo = new Vector();
Vector vScheduledPmt = new Vector();

FAAssessment FA = new FAAssessment();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
vStudInfo = pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
double dRefunded = 0d;//I have to consider refunded amout at the end of payment schedule.

if(vStudInfo == null || vStudInfo.size() == 0)
	strErrMsg = pmtUtil.getErrMsg();
else
{
	dRefunded = new enrollment.FAFeeOperation().calRefundedAmount(dbOP, -1, (String)vStudInfo.elementAt(0),
						 (String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5), true);

	//get scheduled payment information.
	vScheduledPmt =FA.getInstallmentSchedulePerStudent(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(8),
						(String)vStudInfo.elementAt(9),(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5));
	if(vScheduledPmt == null || vScheduledPmt.size() ==0)
		strErrMsg = FA.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";//System.out.println(vScheduledPmt);
/*System.out.println(vStudInfo.elementAt(0));
System.out.println(vStudInfo.elementAt(8));
System.out.println(vStudInfo.elementAt(9));
System.out.println(vStudInfo.elementAt(4));
System.out.println(vStudInfo.elementAt(5));
*/
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
%>

<form name="assessment_sch" action="./assessment_sched.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          SCHEDULE ASSESSMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td  colspan="2" height="25">Enter
        Student ID
        <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
      </td>

      <td width="6%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="57%" colspan="2"><input name="image" type="image" src="../../../images/form_proceed.gif" width="81" height="21">
      </td>
    </tr>
	</table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="43%" height="25">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%></strong></td>
      <td  colspan="2" height="25">Course/Major :<strong> <%=(String)vStudInfo.elementAt(2)%>
        <%if(vStudInfo.elementAt(3) != null){%>
		/ <%=WI.getStrValue(vStudInfo.elementAt(3))%>
		<%}%></strong></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="43%" height="25">Year :<strong> <%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong></td>
      <td height="25">SY-Term :<strong> <%=(String)vStudInfo.elementAt(8)+" - "+(String)vStudInfo.elementAt(9)+" ("+
	  	astrConvertToSem[Integer.parseInt((String)vStudInfo.elementAt(5))]+")"%></strong></td>
      <td width="22%" colspan="-1">&nbsp;</td>
    </tr>
  </table>
<%
if(vScheduledPmt != null && vScheduledPmt.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="58%" height="25" colspan="9" bgcolor="#B9B292"><div align="center">STUDENT
          ACCOUNT SCHEDULE</div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="23%" height="25">&nbsp;</td>
      <td width="34%"><font size="2">OLD ACCOUNTS</font></td>
      <td width="43%"><font size="2"><strong><%=CommonUtil.formatFloat((vScheduledPmt.elementAt(1)).toString(),true)%>
        Php</strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><font size="2">TOTAL PAYABLE TUITION FEE AND OTHER PAYABLE</font></td>
      <td><font size="2"><strong><%=CommonUtil.formatFloat((vScheduledPmt.elementAt(0)).toString(),true)%> Php </strong><font size="1">(for tuition fee only check ledger)</font></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><font size="2">AMOUNT PAID UPON ENROLLMENT</font></td>
      <td><font size="2"><strong><%=CommonUtil.formatFloat((vScheduledPmt.elementAt(2)).toString(),true)%>
        Php</strong></font></td>
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
      <td height="25" colspan="3"><div align="left"></div>
        <hr size="1"> <font size="2">&nbsp;</font></td>
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


  //////////// Posting pmt schedule.
   Vector vInstallPmtSchedule = 
        FA.getOtherChargePayable(dbOP, (String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),
			(String)vStudInfo.elementAt(5), (String)vStudInfo.elementAt(0) );
	if(vInstallPmtSchedule != null)
		vInstallPmtSchedule.removeElementAt(0);
    double dInstallmentPayable = 0d;double dCumInstallmentPayable = 0d;
    //this determines how the posting fees paid.


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
	  if(j ==5 && iEnrlSetting == 0){%><%=CommonUtil.formatFloat(fInstallAmount - fAmoutPaidDurEnrollment + dInstallmentPayable,true)%>
	  <%}else{%><%=CommonUtil.formatFloat(fInstallAmount + dInstallmentPayable,true)%>
      <%}%>
      </td>
      <td align="center">
        <%if(vScheduledPmt.size() > j){%> <%=(String)vScheduledPmt.elementAt(j+1)%> <%}%>
      </td>
      <td align="center"><%=CommonUtil.formatFloat(fAmountDue,true)%></td>
      <td align="center">
        <%if(vScheduledPmt.size() > j){%> <%=CommonUtil.formatFloat(vScheduledPmt.elementAt(j+2).toString(),true)%> <%}%>
      </td>
      <td align="center">
    <%if(iEnrlSetting == 2){%> <%=CommonUtil.formatFloat(fAmountDue - ((Float)vScheduledPmt.elementAt(j+2)).floatValue(),true)%> 
	<%}else{%> <%=CommonUtil.formatFloat(fInstallAmount*(i+1) + dCumInstallmentPayable - fCumAmountPaid,true)%> <%}%>&nbsp;&nbsp;
    </td>
    </tr>
    <%
j = j+3;
}
if(dRefunded > 0.2d || dRefunded < -0.2d){%>
 <tr>
      <td height="25">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="right"><font size="1" color="#0033FF"><b>AMOUNT REFUNDED</b></font> &nbsp;&nbsp;</td>
      <td align="right"><font size="1" color="#0033FF"><b><%=CommonUtil.formatFloat(dRefunded,true)%></b></font> &nbsp;&nbsp;</td>
    </tr>
<%}//show refund if there is any.%>	
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="6" height="25"><strong>PRINT ASSESSMENT FOR SCHEDULE
        <select name="pmt_schedule">
          <%
//i have to check if i should use the fa_pmt_schedule_extn or fa_pmt_schedule table.
strTemp = dbOP.loadCombo("fa_pmt_schedule_extn.PMT_SCH_INDEX","EXAM_NAME",
		" from fa_pmt_schedule_extn  join fa_pmt_schedule on (fa_pmt_schedule_extn.pmt_sch_index = fa_pmt_schedule.pmt_sch_index)"+
		" where fa_pmt_schedule_extn.is_del=0 and fa_pmt_schedule_extn.is_valid=1 and sy_from="+(String)vStudInfo.elementAt(8)+
		" and sy_to="+(String)vStudInfo.elementAt(9)+" and semester="+(String)vStudInfo.elementAt(5)+
		 " order by fa_pmt_schedule_extn.EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false);
//System.out.println("Printing : "+(String)vStudInfo.elementAt(8)+","+(String)vStudInfo.elementAt(9)+","+(String)vStudInfo.elementAt(5));
if(strTemp.length() ==0)
	strTemp = dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc",
		request.getParameter("pmt_schedule"), false);
%>
          <%=strTemp%>         </select>
        </strong></td>
      <td height="25"> <a href="javascript:PrintAssessment();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
        to print</font></td>
    </tr>
    <tr >
      <td width="6%" height="25">&nbsp;</td>
      <td width="12%" height="25">&nbsp;</td>
      <td width="10%" height="25">&nbsp;</td>
      <td width="9%" height="25">&nbsp;</td>
      <td width="20%" height="25">&nbsp;</td>
      <td width="6%" height="25">&nbsp;</td>
      <td width="15%" height="25">&nbsp;</td>
      <td width="22%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25"><strong><font color="#000099">NOTE : </font></strong></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="7"><strong><font color="#000099">TOTAL PAYABLE
        TUITION FEE is an updated amount. Adjustments, discounts and dropped/withdrawn
        subjects are already integrated</font></strong>.</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25" colspan="7">&nbsp;</td>
    </tr>
    <%	}//only if vScheduledPmt != null;
}//only if stud info is not null;
%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
