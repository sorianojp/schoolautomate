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
<script language="JavaScript">
function printHere() {
	document.bgColor = "#FFFFFF";
    document.getElementById('myADTable').deleteRow(0);
    document.getElementById('myADTable').deleteRow(0);
	
    document.getElementById('myADTable22').deleteRow(0);
    document.getElementById('myADTable22').deleteRow(0);    
	document.getElementById('myADTable22').deleteRow(0);
	
	alert("Click to print this page.");
	window.print();
	
}
</script>
<body bgcolor="#8C9AAA">
<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = {"(Summer)","","",""};

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
Vector vCurHistInfo = null;//records curriculum hist detail.

Vector vLedgerInfo = null;
Vector vOldLedgerInfo = null;

FAPaymentUtil paymentUtil = new FAPaymentUtil();
paymentUtil.setIsBasic(true);

FAStudentLedger faStudLedg = new FAStudentLedger();
student.ChangeCriticalInfo changeInfo = new student.ChangeCriticalInfo();
changeInfo.setIsBasic(true);
enrollment.FAStudentLedgerExtn faStudLedgExtn = new enrollment.FAStudentLedgerExtn();

	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strStudID);
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
if(vBasicInfo != null) {
	//i have to update the outstanding balance if update is clicked.
	if(WI.fillTextValue("update_balance").equals("1")) {
		if(!faStudLedgExtn.updateOutstandingBalance(dbOP, (String)vBasicInfo.elementAt(0),
			WI.fillTextValue("ledg_hist_index"),WI.fillTextValue("excess_amt"), 
			WI.fillTextValue("sf_update"),WI.fillTextValue("term_update")) )
			strErrMsg = faStudLedgExtn.getErrMsg();
	}

	vCurHistInfo = changeInfo.operateOnStudCurriculumHist(dbOP,request,(String)vBasicInfo.elementAt(0),4);
	if(vCurHistInfo == null){
		strErrMsg = changeInfo.getErrMsg();
	}
	vOldLedgerInfo = faStudLedg.viewOldStudLedgerComplete(dbOP, (String)vBasicInfo.elementAt(0));
}


%>
<form name="stud_ledg" action="./student_ledger_viewall.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#697A8F"><font color="#FFFFFF"><strong>::::
        STUDENT'S COMPLETE LEDGER PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%
if(vBasicInfo != null && vBasicInfo.size() > 0 && vCurHistInfo != null && vCurHistInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><div align="center"><u>STUDENT COMPLETE LEDGER</u></div>
      <div align="right"><font size="1">Date and time printed: <%=WI.getTodaysDateTime()%></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="47%" height="25">Student ID : <strong><%=strStudID%></strong></td>
      <td width="51%" height="25">Student Name :<strong> <%=(String)vBasicInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Current School Year  :<strong> <%=(String)vBasicInfo.elementAt(8) + " - " +(String)vBasicInfo.elementAt(9)%><%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Educational Level  :<strong><%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue(vBasicInfo.elementAt(4),"0")))%></strong></td>
    </tr>
  </table>

<%
//to update the ledger hist balance information
double dNewBalance  = 0f;
double dPrevBalance = 0f;
boolean bolShowUpdate  = false;//show updated only if there is atleast one
String strLedgHistIndex = null;
String[] astrSemester = {"(Summer)","","",""}; 
//ledger information thru' normal enrollment.

if(vOldLedgerInfo != null && vOldLedgerInfo.size() > 0) {%>
  <table   width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#808080" class="thinborder">
    <tr bgcolor="#3366FF"> 
      <td height="25" colspan="6" class="thinborder">&nbsp;&nbsp;&nbsp;<strong><font color="#FFFFFF">OLD 
        ACCOUNT</font></strong></td>
    </tr>
    <tr bgcolor="#EAF2FD">
      <td width="16%" align="center" class="thinborder"><font size="1"><strong>AY - TERM</strong></font></td>
      <td width="10%" height="25" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="37%" align="center" class="thinborder" ><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <%String strAYToDisp = null;
for(int i = 0 ; i < vOldLedgerInfo.size(); i += 10) {
	strTemp = (String)vOldLedgerInfo.elementAt(i)+" - "+(String)vOldLedgerInfo.elementAt(i+1)+"<br>"+
				astrSemester[Integer.parseInt((String)vOldLedgerInfo.elementAt(i+2))];
	if(strTemp2 == null || strTemp.compareTo(strTemp2) != 0) {
		strAYToDisp = strTemp;
		strTemp2 = strTemp;
	}
	else	
		strAYToDisp = " - do - ";
		
	  %>
    <tr bgcolor="#FFFFFF">
      <td align="center" class="thinborder"><%=strAYToDisp%></td>
      <td height="25" align="center" class="thinborder">&nbsp;<%=(String)vOldLedgerInfo.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vOldLedgerInfo.elementAt(i+5))%> <%
	  //if or number existing -- show it.
	  if(vOldLedgerInfo.elementAt(i+3) != null){%>
      /OR No. <%=(String)vOldLedgerInfo.elementAt(i+3)%> <%}%></td>
      <td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vOldLedgerInfo.elementAt(i+6))%>&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vOldLedgerInfo.elementAt(i+7))%>&nbsp;</td>
      <td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vOldLedgerInfo.elementAt(i+9))%>&nbsp;</td>
    </tr>
<%
	}//end of for loop.
//I have to now get the outstanding balance of old account encoding.
strTemp = ConversionTable.replaceString((String)vOldLedgerInfo.elementAt(vOldLedgerInfo.size() - 1),",","");
if(strTemp.startsWith("(")) {
	strTemp = strTemp.substring(1);
	strTemp = strTemp.substring(0,strTemp.length() - 2);
	strTemp = "-" + strTemp;
}
dPrevBalance = 
	Double.parseDouble(strTemp);
%>
  </table>


<%}//end of displaying old ledger info

//start of new ledger info display.

for(int i = 0 ; i < vCurHistInfo.size(); i += 16) {
	vLedgerInfo = faStudLedgExtn.viewLedgerTuitionDetail(dbOP,(String)vBasicInfo.elementAt(0),(String)vCurHistInfo.elementAt(i + 1),
										(String)vCurHistInfo.elementAt(i + 2),(String)vCurHistInfo.elementAt(i + 3));
										
//	System.out.println("vLedgerInfo : " + vLedgerInfo);
	
	if(vLedgerInfo == null)
		continue;
		//strErrMsg = faStudLedgExtn.getErrMsg();
	else
		strErrMsg = null;
	%>
  <table   width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#808080" class="thinborder">
    <tr bgcolor="#3366FF">
      <td height="25" colspan="6" class="thinborder">&nbsp;&nbsp;&nbsp; <strong><font color="#FFFFFF">
        <%=(String)vCurHistInfo.elementAt(i + 1)+ " - "+(String)vCurHistInfo.elementAt(i + 2)%> <%=astrConvertTerm[Integer.parseInt((String)vCurHistInfo.elementAt(i + 3))]%> <%=WI.getStrValue((String)vCurHistInfo.elementAt(i + 7)," :: ","","")%> </font></strong></td>
    </tr>
    <%
if(strErrMsg != null){%>
    <tr bgcolor="#FFFFAF">
      <td height="25" colspan="6" class="thinborder"><strong><font size="1">ERROR IN GETTING LEDGER
        INFO : <%=strErrMsg%></font></strong></td>
    </tr>
    <%}else if(vLedgerInfo	!= null && vLedgerInfo.size() > 1){%>
    <tr bgcolor="#EAF2FD">
      <td width="10%" height="25" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
      <td width="43%" align="center" class="thinborder" ><font size="1"><strong>PARTICULARS</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>COLLECTED BY ID</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>DEBIT</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>CREDIT</strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>BALANCE</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="center" class="thinborder">&nbsp; </td>
      <td colspan="3" align="right" class="thinborder">Previous outstanding balance
        <%
	  if(((String)vLedgerInfo.elementAt(0)).startsWith("-")){%>
        (Excess)
      <%}%></td>
      <td align="center" class="thinborder">&nbsp;
        <%
		dNewBalance = Double.parseDouble(ConversionTable.replaceString(
										WI.getStrValue((String)vLedgerInfo.elementAt(0),"0"), ",","") );	
		if(bolShowUpdate && (dNewBalance - dPrevBalance) !=0d && strLedgHistIndex != null ){%>
        <a href='javascript:UpdateBalance("<%=strLedgHistIndex%>","<%=(dNewBalance-dPrevBalance)%>",
		"<%=(String)vCurHistInfo.elementAt(i + 1)%>","<%=(String)vCurHistInfo.elementAt(i + 3)%>");'></a>
        <%}%>
      </td>
      <td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloatToLedger((String)vLedgerInfo.elementAt(0))%></td>
    </tr>
    <%bolShowUpdate = true;strLedgHistIndex = (String)vLedgerInfo.elementAt(1);
for(int p = 2; p< vLedgerInfo.size() ; p += 6)
{%>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="center" class="thinborder">&nbsp;<%=WI.getStrValue(vLedgerInfo.elementAt(p))%></td>
      <td class="thinborder"><%=WI.getStrValue(vLedgerInfo.elementAt(p + 1))%> </td>
      <td align="center" class="thinborder"><%=WI.getStrValue(vLedgerInfo.elementAt(p + 2),"&nbsp")%></td>
      <td align="right" class="thinborder"><%if(vLedgerInfo.elementAt(p + 4) != null && 
	  ((String)vLedgerInfo.elementAt(p + 4)).startsWith("-")){%><%=((String)vLedgerInfo.elementAt(p + 4)).substring(1)%><%}%>
      <%=WI.getStrValue(vLedgerInfo.elementAt(p + 3),"&nbsp;")%></td>
      <td align="right" class="thinborder"><%if(vLedgerInfo.elementAt(p + 4) != null && 
	  !((String)vLedgerInfo.elementAt(p + 4)).startsWith("-")){%><%=WI.getStrValue(vLedgerInfo.elementAt(p + 4))%>
	  <%}else{%>&nbsp;<%}%></td>
      <td align="right" class="thinborder"><%=WI.getStrValue(vLedgerInfo.elementAt(p + 5),"&nbsp;")%></td>
    </tr>
    <%dPrevBalance =
		Double.parseDouble( ConversionTable.replaceString(
			WI.getStrValue((String)vLedgerInfo.elementAt(p + 5),"0"), ",","") );
		}//end of for loop.
}//end of vLedgerInfo%>
  </table>


<%}//end of displaying new ledger info.%>










  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable22">
    <tr>
      <td height="25" colspan="8">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <a href="javascript:printHere();"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
        to print ledger</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#697A8F">&nbsp;</td>
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
