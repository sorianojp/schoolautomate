<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function printHere() {
    document.getElementById('myADTable').deleteRow(0);
    document.getElementById('myADTable').deleteRow(0);
	
    document.getElementById('myADTable1').deleteRow(0);
    document.getElementById('myADTable1').deleteRow(0);
	
    document.getElementById('myADTable2').deleteRow(0);
	
	alert("Click to print this page.");
	window.print();
	
}
//all about ajax.
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
function updateTotal() {
		var strInput = document.form_.total_hidden.value;
		var strInput1 = document.form_.input1.value;
		var strInput2 = document.form_.input2.value;
		var strInput3 = document.form_.input3.value;
		var strInput4 = document.form_.input4.value;
		
		if(strInput1.length == 0)
			strInput1 = "0";
		if(strInput2.length == 0)
			strInput2 = "0";
		if(strInput3.length == 0)
			strInput3 = "0";
		if(strInput4.length == 0)
			strInput4 = "0";
		
		strInput = strInput+"_"+strInput1+"_"+strInput2+"_"+strInput3+"_"+strInput4;
				
		var objCOAInput;
		objCOAInput = document.form_.total_;
			
		this.InitXmlHttpObject(objCOAInput, 1);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=150&input="+strInput+"&format=1";
		
		this.processRequest(strURL);
}
</script>
<body onLoad="document.form_.stud_id.focus();">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr",
        				"5th Yr","6th Yr","7th Yr","8th Yr"};

	boolean bolProceed = true;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Student ledger","ui_ledger_summary.jsp");
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
														"Fee Assessment & Payments","STUDENT LEDGER",request.getRemoteAddr(),
														"ui_ledger_summary.jsp");
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


Vector vBasicInfo = null;
Vector vCurHistInfo = null;//records curriculum hist detail.

Vector vLedgerInfo = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger faStudLedg = new FAStudentLedger();
student.ChangeCriticalInfo changeInfo = new student.ChangeCriticalInfo();
enrollment.FAStudentLedgerExtn faStudLedgExtn = new enrollment.FAStudentLedgerExtn();

if(WI.fillTextValue("stud_id").length() > 0) {
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
}
if(vBasicInfo != null) {
	vCurHistInfo = changeInfo.operateOnStudCurriculumHist(dbOP,request,(String)vBasicInfo.elementAt(0),4);
	if(vCurHistInfo == null)
		strErrMsg = changeInfo.getErrMsg();
}


%>
<form name="form_" action="./ui_ledger_summary.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT LEDGER SUMMARY PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr valign="top">
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%">Student ID</td>
      <td width="18%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="6%">
        <input name="image" type="image" src="../../../images/form_proceed.gif">
      </td>
      <td width="59%"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td colspan="5" height="26"><hr size="1"></td>
    </tr>
  </table>
<%
strTemp = null;
String strLabelID = null;

String strLastSYFrom = null;
String strLastTerm   = null;

if(vBasicInfo != null && vBasicInfo.size() > 0 && vCurHistInfo != null && vCurHistInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" align="right" style="font-size:11px;"><a href="javascript:printHere();"><img src="../../../images/print.gif" border="0"></a> Print page.&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><div align="center"><u>STUDENT  LEDGER</u> SUMMARY </div>
      <div align="right"><font size="1">Date and time printed: <%=WI.getTodaysDateTime()%></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="47%" height="25">Student ID : <strong><%=WI.fillTextValue("stud_id")%></strong></td>
      <td width="51%" height="25">Student Name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Current SY, Year,Term :<strong> <%=(String)vBasicInfo.elementAt(8) + " - " +(String)vBasicInfo.elementAt(9)%>, <%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue((String)vBasicInfo.elementAt(4),"0"))]%>, <%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Course/Major :<strong> <%=(String)vBasicInfo.elementAt(2)%>
        <%
	  if(vBasicInfo.elementAt(3) != null){%>
        /<%=WI.getStrValue(vBasicInfo.elementAt(3))%>
        <%}%>
        </strong></td>
    </tr>
  </table>

<%
//to update the ledger hist balance information
double dNewBalance  = 0f;
double dPrevBalance = 0f;
String strLedgHistIndex = null;
//ledger information thru' normal enrollment.
%>
  <table   width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFAF">
      <td width="30%" height="25" align="center" class="thinborder"><font size="1"><strong>Period</strong></font></td>
      <td align="center" width="15%" class="thinborder"><font size="1"><strong>Charge</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>Payments</strong></font></td>
      <td width="13%" align="center" class="thinborder"><font size="1"><strong>Balance</strong></font></td>
      <td width="27%" align="center" class="thinborder"><font size="1"><strong>Remarks</strong></font></td>
    </tr>

<%//start of new ledger info display.
for(int i = 0 ; i < vCurHistInfo.size(); i += 16) {
strLabelID = Integer.toString(i);

	vLedgerInfo = faStudLedgExtn.viewLedgerTuitionDetail(dbOP,(String)vBasicInfo.elementAt(0),(String)vCurHistInfo.elementAt(i + 1),
										(String)vCurHistInfo.elementAt(i + 2),(String)vCurHistInfo.elementAt(i + 3));
	if(vLedgerInfo == null)
		continue;
		//strErrMsg = faStudLedgExtn.getErrMsg();
	else
		strErrMsg = null;
	%>
    
    <%
if(strErrMsg != null){%>
    <tr bgcolor="#FFFFAF">
      <td height="25" colspan="5" class="thinborder"><strong><font size="1">ERROR IN GETTING LEDGER
        INFO : <%=strErrMsg%></font></strong></td>
    </tr>
<%}else if(vLedgerInfo	!= null && vLedgerInfo.size() > 1){
dNewBalance = Double.parseDouble( ConversionTable.replaceString(WI.getStrValue((String)vLedgerInfo.elementAt(0),"0"), ",","") );
if((dNewBalance - dPrevBalance) !=0f && strLedgHistIndex != null ){%>    
	<tr>
      <td colspan="5" style="font-size:11px; font-weight:bold; color:#FF0000" class="thinborder"> &nbsp;&nbsp;&nbsp;Balance forward does not match. Please 
	  <a href="./student_ledger_viewall.jsp?stud_id=<%=WI.fillTextValue("stud_id")%>">click here</a> 
	  to view Ledger Detail</td>
    </tr>
    <%}//balance forward does not match. Must give error message.. 
strLedgHistIndex = (String)vLedgerInfo.elementAt(1);
double dTotalCharge = 0d; double dTotalPayment = 0d;
for(int p = 2; p< vLedgerInfo.size() ; p += 6) {
	strTemp = WI.getStrValue(vLedgerInfo.elementAt(p + 3));
	if(strTemp.length() > 0) 
		dTotalCharge += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	strTemp = WI.getStrValue(vLedgerInfo.elementAt(p + 4));
	if(strTemp.length() > 0) 
		dTotalPayment += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));
	if(p < vLedgerInfo.size() - 6)
		continue;
strTemp = WI.getStrValue(vLedgerInfo.elementAt(p + 5));		

strLastSYFrom = (String)vCurHistInfo.elementAt(i + 1);
strLastTerm   = (String)vCurHistInfo.elementAt(i + 3);
%>
    <tr>
      <td height="25" align="center" class="thinborder"><%=(String)vCurHistInfo.elementAt(i + 1)+ " - "+(String)vCurHistInfo.elementAt(i + 2)%> (<%=astrConvertTerm[Integer.parseInt((String)vCurHistInfo.elementAt(i + 3))]%>) :: <%=vCurHistInfo.elementAt(i + 7)%></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalCharge, true)%> &nbsp;</td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalPayment, true)%> &nbsp;</td>
      <td align="right" class="thinborder"><%=strTemp%> &nbsp;</td>
      <td align="center" class="thinborder">&nbsp;<%if(strTemp != null && strTemp.length() > 0 && !strTemp.equals("0.00")){%><label id="<%=i%>" onClick="ChangeLabel('<%=i%>')">Balance Forwareded</label><%}%></td>
    </tr>
    <%dPrevBalance =
		Double.parseDouble( ConversionTable.replaceString(
			WI.getStrValue((String)vLedgerInfo.elementAt(p + 5),"0"), ",","") );
		}//end of for loop.
}//end of vLedgerInfo%>



<%}//end of displaying new ledger info.

if(strTemp != null && strTemp.length() > 0 && !strTemp.equals("0.00")){
	if(strTemp.startsWith("-") )
		strErrMsg = "Excess";
	else
		strErrMsg = "Balance";

	strErrMsg = "<font color='red'><b>"+strErrMsg+"</b></font>";%>
	
	<script language="javascript">
		document.getElementById('<%=strLabelID%>').innerHTML = "<%=strErrMsg%>"
	</script>
<%}
if(strTemp == null || strTemp.length() == 0) 
	strTemp = "0.00";
else	
	strTemp = ConversionTable.replaceString(strTemp, ",","");
%>
<input type="hidden" name="balance" value="<%=strTemp%>">

  </table>


  <table   width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="4%" height="25" align="center">&nbsp;</td>
      <td align="center" width="21%">&nbsp;</td>
      <td width="75%" align="center">&nbsp;</td>
    </tr>
<%
int iRowPrinted =0;
strErrMsg  = "select transaction_date,fa_stud_payable.amount * no_of_units, fee_name from fa_stud_payable "+
				"join fa_oth_sch_fee on (reference_index = othsch_fee_index) "+
				"where user_index = "+vBasicInfo.elementAt(0)+" and payable_type = 0 and (fee_name = 'diploma' or fee_name = 'vistas') "+
				"and sy_from = "+strLastSYFrom+" and semester = "+strLastTerm+
				" order by fee_name ";
java.sql.ResultSet rs = dbOP.executeQuery(strErrMsg);
if(rs.next()){++iRowPrinted;%>    
<tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" class="thinborderNONE">
	  	<table width="50%" border="0" class="thinborder" cellpadding="0" cellspacing="0">
			<tr bgcolor="#CCCCCC">
				<td class="thinborder"> Fee Name</td>
				<td class="thinborder"> Date Posted</td>
				<td class="thinborder"> Amount Posted</td>
			</tr>
			<%while(true){%>
			<tr>
				<td class="thinborder"><%=rs.getString(3)%></td>
				<td class="thinborder"><%=ConversionTable.convertMMDDYYYY(rs.getDate(1), true)%></td>
				<td class="thinborder"><%=CommonUtil.formatFloat(rs.getDouble(2), true)%></td>
			</tr>
			<%
			if(!rs.next())
				break;
			++iRowPrinted;
			}%>
		</table>
	  
	  
	  </td>
    </tr>
<%}
rs.close();
if(iRowPrinted == 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" class="thinborderNONE" style="font-size:11px; color:#FF0000; font-weight:bold">Diploma or Vistas Fee Not posted to Ledger. Please post these Fee to Last attended SY-Term. </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">Certification</td>
      <td><input style="text-align:right" type="text" class="textbox_noborder" name="input1" onKeyUp="AllowOnlyIntegerExtn('form_','input1','.');" onBlur="updateTotal();"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">Transcript of Records </td>
      <td><input type="text" style="text-align:right" class="textbox_noborder" name="input2" onKeyUp="AllowOnlyIntegerExtn('form_','input2','.');" onBlur="updateTotal();"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">Sepcial Order </td>
      <td><input type="text" style="text-align:right" class="textbox_noborder" name="input3" onKeyUp="AllowOnlyIntegerExtn('form_','input3','.');" onBlur="updateTotal();"></td>
    </tr>
    <tr>
      <td height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">Honorable Dismissal </td>
      <td class="thinborderBOTTOM"><input type="text" style="text-align:right" class="textbox_noborder" name="input4" onKeyUp="AllowOnlyIntegerExtn('form_','input4','.');" onBlur="updateTotal();"></td>
    </tr>
    <tr>
      <td height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">TOTAL BALANCE </td>
      <td class="thinborderBOTTOM">
	  <input type="hidden" name="total_hidden" value="<%=strTemp%>">
	  <input type="text" style="text-align:right" class="textbox_noborder" name="total_" value="<%=CommonUtil.formatFloat(strTemp, true)%>">	  </td>
    </tr>
  </table>

<input type="hidden" name="user_index" value="<%=(String)vBasicInfo.elementAt(0)%>">

<%} //only if basic info is not null -- the biggest and outer loop.;
%>

<input type="hidden" name="update_balance">
<input type="hidden" name="ledg_hist_index">
<input type="hidden" name="excess_amt">
<input type="hidden" name="sf_update">
<input type="hidden" name="term_update">
<input type="hidden" name="show_coursecode" value="1">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
