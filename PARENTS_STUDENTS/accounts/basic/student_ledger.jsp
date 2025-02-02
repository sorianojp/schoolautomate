<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
String strStudID    = (String)request.getSession(false).getAttribute("userId");


if(strStudID == null) {
%>
 <p style="font-size:14px; color:#FF0000;">You are already logged out. Please login again.</p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function studIDInURL() {
	if(!document.stud_ledg.show_all.checked)
		return;
	var studID = document.stud_ledg.stud_id.value;
	location = "./student_ledger_viewall.jsp";
}

</script>
<body bgcolor="#8C9AAA">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

//forward the page here.
if(WI.fillTextValue("show_all").compareTo("1") ==0){
	response.sendRedirect(response.encodeRedirectURL("./student_ledger_viewall.jsp"));
	return;
}

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","",""};

	boolean bolProceed = true;
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
//authenticate this user.


Vector vBasicInfo = null;
Vector vLedgerInfo = null;

Vector vTimeSch = null;
Vector vAdjustment = null;
Vector vRefund = null;
Vector vDorm = null;
Vector vOthSchFine = null;
Vector vPayment = null;



Vector vTuitionFeeDetail = null;


FAPaymentUtil paymentUtil = new FAPaymentUtil();
paymentUtil.setIsBasic(true);

FAStudentLedger faStudLedg = new FAStudentLedger();

	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strStudID);
	if(vBasicInfo == null){ //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
	}else//check if this student is called for old ledger information.
	{
		int iDisplayType = faStudLedg.isOldLedgerInformation(dbOP, (String)vBasicInfo.elementAt(0),request.getParameter("sy_from"),
											request.getParameter("sy_to"),request.getParameter("semester"));
		if(iDisplayType ==-1) //Error.
		{
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=faStudLedg.getErrMsg()%></font></p>
			<%
			dbOP.cleanUP();
			return;
		}
		if(iDisplayType ==1)//this is called for old ledger information.
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./old_student_ledger_view.jsp?stud_id="+strStudID+"&sy_from="+
				request.getParameter("sy_from")+"&sy_to="+request.getParameter("sy_to")+"&semester="+request.getParameter("semester")));
			return;
		}
	}
	//check if the applicant is having reservation already, if so - take directly to the print page,
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{
		strUserIndex = (String)vBasicInfo.elementAt(0);
		vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vBasicInfo.elementAt(0),request.getParameter("sy_from"),
			request.getParameter("sy_to"),null,request.getParameter("semester"));
		if(vLedgerInfo == null){
			strErrMsg = faStudLedg.getErrMsg();
//			System.out.println("StrErrMsg  2: " + strErrMsg);
		}else
		{
			vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
			vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
			vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
			vRefund				= (Vector)vLedgerInfo.elementAt(3);
			vDorm 				= (Vector)vLedgerInfo.elementAt(4);
			vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
			vPayment			= (Vector)vLedgerInfo.elementAt(6);
			if(vTimeSch == null || vTimeSch.size() ==0){
				strErrMsg = faStudLedg.getErrMsg();
//				System.out.println("StrErrMsg  3: " + strErrMsg);
			}
		}

	}

%>
<form name="stud_ledg" action="./student_ledger.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT'S LEDGER PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 7);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="4" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">SY-Term</td>
      <td height="25">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
        <select name="semester">
          <option value="1">Regular</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="53%" height="25">
<input type="checkbox" name="show_all" value="1" onClick="studIDInURL();">
        <font size="1">SHOW LEDGER from the first enrolled until present </font></td>
    </tr>
    
    <tr>
      <td></td>
      <td></td>
      <td></td>
      <td colspan="2"></td>
    </tr>
  </table>
<%
if(vBasicInfo != null && vBasicInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="42%" height="25">Student ID :<strong> <%=strStudID%></strong></td>
	  <input type="hidden" name="stud_id" value="<%=strStudID%>">
      <td width="56%" height="25"  colspan="4">Educational Level : <strong>
	  <%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vBasicInfo.elementAt(4),"0")))%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
      <td  colspan="4" height="25"><%=WI.getStrValue(astrConvertTerm[Integer.parseInt(WI.getStrValue((String)vBasicInfo.elementAt(5),"2"))],"Term :<strong> ","</strong>","&nbsp;")%></td>
    </tr>
<%
if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
<%}%>
	
    </tr>
  </table>

<%
if(vTimeSch != null && vTimeSch.size() > 0){
	double dBalance = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
	double dCredit = 0d;
	double dDebit = 0d;
	String strTransDate = null;
	int iIndex = 0;
	boolean bolDatePrinted = false;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td width="11%" height="25" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="40%" align="center" bgcolor="#B9B292" class="thinborder"><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>COLLECTED
          BY (ID) </strong></font></div></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="17%" align="center" class="thinborder"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td colspan="4" align="right" class="thinborder">OLD ACCOUNTS<%=faStudLedg.getDormOldAccountInfo(true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
for(int i=0; i<vTimeSch.size(); ++i){
strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.elementAt(i));
bolDatePrinted = false;

if(vTuitionFeeDetail.contains((Date)vTimeSch.elementAt(i))){
dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
dBalance += dDebit;

bolDatePrinted = true;
%>
    <tr >
      <td height="25" class="thinborder"><%=strTransDate%></td>
      <td class="thinborder">Tuition Fee</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">Miscellaneous Fee</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();
if(dDebit > 0f){
dBalance += dDebit;%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">Other Charges</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
if(dDebit > 0f){
dBalance += dDebit;%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">Hands on</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}
//show this if there is any discounts.
if(vTuitionFeeDetail.elementAt(5) != null){
double dTemp = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
if(dTemp > 0)
	dCredit = dTemp;
else
	dDebit  =  -1 * dTemp;
dBalance -= dTemp;
%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder"><%=vTuitionFeeDetail.elementAt(6)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">&nbsp;
        <%if(dDebit > 0f){%>
        <%=CommonUtil.formatFloat(dDebit,true)%>
        <%}%>
      </td>
      <td align="right" class="thinborder">&nbsp;
        <%if(dCredit > 0f){%>
        <%=CommonUtil.formatFloat(dCredit,true)%>
        <%}%>
      </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%}if(vTuitionFeeDetail.elementAt(8) != null){%>
    <tr >
      <td height="25" class="thinborder">&nbsp;</td>
      <td colspan="5" class="thinborder">NOTE : <%=(String)vTuitionFeeDetail.elementAt(8)%></td>
    </tr>
    <%}
} //for tuition fee detail.

//add or drop subject history here,

//adjustment here
//System.out.println(vAdjustment);
while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dCredit = Float.parseFloat((String)vAdjustment.elementAt(iIndex-3));
	dBalance -= dCredit;
%>
    <tr >
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
      <td class="thinborder"><%=(String)vAdjustment.elementAt(iIndex-4)%>(Grant)</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dCredit,true)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
vAdjustment.removeElementAt(iIndex);vAdjustment.removeElementAt(iIndex-1);vAdjustment.removeElementAt(iIndex-2);
vAdjustment.removeElementAt(iIndex-3);vAdjustment.removeElementAt(iIndex-4);
}

//Refund here
while( (iIndex = vRefund.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Float.parseFloat((String)vRefund.elementAt(iIndex-1));
	dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
      <td class="thinborder"><%=(String)vRefund.elementAt(iIndex-3)%>(Refund)</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
vRefund.removeElementAt(iIndex);vRefund.removeElementAt(iIndex-1);vRefund.removeElementAt(iIndex-2);
vRefund.removeElementAt(iIndex-3);
}
//dormitory charges
while( (iIndex = vDorm.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Float.parseFloat((String)vDorm.elementAt(iIndex-1));
	dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
      <td class="thinborder"><%=(String)vDorm.elementAt(iIndex-2)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
vDorm.removeElementAt(iIndex);vDorm.removeElementAt(iIndex-1);vDorm.removeElementAt(iIndex-2);
}

//Other school fees/fine/school facility fee charges(except dormitory)
while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dDebit = Float.parseFloat((String)vOthSchFine.elementAt(iIndex-1));
	dBalance += dDebit;
%>
    <tr >
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
      <td class="thinborder"><%=(String)vOthSchFine.elementAt(iIndex-2)%></td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td  align="right" class="thinborder"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td align="right" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
vOthSchFine.removeElementAt(iIndex);vOthSchFine.removeElementAt(iIndex-1);vOthSchFine.removeElementAt(iIndex-2);
}

//vPayment goes here, ;-)
while( (iIndex = vPayment.indexOf((Date)vTimeSch.elementAt(i))) != -1)
{
	dCredit = Float.parseFloat((String)vPayment.elementAt(iIndex-2));
	dBalance -= dCredit;
%>
    <tr >
      <td height="25" class="thinborder">
        <% if(bolDatePrinted){%>
        &nbsp;
        <%}else{%>
        <%=strTransDate%>
        <%bolDatePrinted=true;}%>
      </td>
      <td class="thinborder"><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%>(<%=(String)vPayment.elementAt(iIndex+1)%>)</td>
      <td align="center" class="thinborder"><%=(String)vPayment.elementAt(iIndex + 3)%></td>
      <td  align="right" class="thinborder">&nbsp;
        <%//show only the refunds in debit column.
	  if(dCredit < 0d || (vPayment.elementAt(iIndex+1) != null && ((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
        <%=CommonUtil.formatFloat(-1 * dCredit,true)%>
        <%}%>
      </td>
      <td align="right" class="thinborder">&nbsp;
        <%if(dCredit > 0d && (vPayment.elementAt(iIndex+1) == null || !((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded"))){%>
        <%=CommonUtil.formatFloat(dCredit,true)%>
        <%}%>
      </td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dBalance,true)%></td>
    </tr>
    <%
//remove the element here.
vPayment.removeElementAt(iIndex+3);
vPayment.removeElementAt(iIndex+2);
vPayment.removeElementAt(iIndex+1);
vPayment.removeElementAt(iIndex);
vPayment.removeElementAt(iIndex-1);
vPayment.removeElementAt(iIndex-2);
}%>
    <%
}%>
  </table>
  <%}//only if vTimeSch is not null
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="user_index" value="<%=(String)vBasicInfo.elementAt(0)%>">

<%} //only if basic info is not null;
%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>