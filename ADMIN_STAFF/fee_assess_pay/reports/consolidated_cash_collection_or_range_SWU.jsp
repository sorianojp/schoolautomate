<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Consolidated Daily Collection</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
	TD.thinborderTOP{
		border-top: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 12px;	
	}
</style>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>



<script language='javascript'>

function PrintPg() {
	
	if(document.daily_cash.date_of_col.value.length ==0) {
		alert("Please enter date of collection.");
		return;
	}
	//I have to call here the print page.
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	document.getElementById('myADTable5').deleteRow(0);
	document.getElementById('myADTable5').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.


}
function ViewReport() {
	document.daily_cash.view_report.value = 1;
}



</script>
<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0" bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;String strTemp = null;
	java.sql.ResultSet rs = null;
	Vector vTuitionFee       = null;
	Vector vSchFacDeposit   = null;
	Vector vRemittance      = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cashier_report_orprooflist.jsp");
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
														"cashier_report_orprooflist.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														"cashier_report_summary.jsp");
}
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
Vector vEmployeeInfo     = null;
Vector vCollectionSWU    = null;
Vector vCollectionUStore = null;
Vector vOtherIncome      = null;


if(WI.fillTextValue("date_of_col").length() > 0 && WI.fillTextValue("view_report").length() > 0)
{
	String strDatePaid = ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_of_col"));
	if (strDatePaid == null)
   	strErrMsg = "Please enter date in mm/dd/yyyy format.";
	else{
	
		strTemp = "select distinct id_number from user_table join fa_stud_payment on (user_table.user_index = fa_stud_payment.created_by) "+
			" where fa_stud_payment.is_valid = 1 and date_paid = '"+strDatePaid+"' and or_number is not null "+
			" and is_bank_post = 0 and is_sponsored=0 and fa_stud_payment.AMOUNT > 0"+
			" and not exists( "+
			" 		select * from fa_teller_no where is_valid = 1 "+
			" 		and FA_TELLER_NO.VALID_FROM <= '"+strDatePaid+"' and FA_TELLER_NO.VALID_TO >= '"+strDatePaid+"' "+
			"		and user_index = fa_stud_payment.created_by "+
			" ) ";
		strErrMsg = null;
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			if(strErrMsg == null)
				strErrMsg = rs.getString(1);
			else
				strErrMsg += "<br>" + rs.getString(1);
		}rs.close();
		if(strErrMsg != null){
			strErrMsg = "Please map this teller id(s) to teller no<br> "+ strErrMsg;
		}else{
			CreateTable CT = new CreateTable();
			String strTempTable = CT.createUniqueTable(dbOP,"(or_number nvarchar(32))");
			
			strTemp = " insert into "+strTempTable+" select or_number "+
				" from fa_stud_payment "+
				" join fa_oth_sch_fee on (fa_oth_sch_fee.othsch_fee_index = fa_stud_payment.othsch_fee_index) "+
				" where fa_stud_payment.is_valid = 1 and date_paid ='"+strDatePaid+"' and or_number is not null "+
				" and is_bank_post = 0 and is_sponsored=0 and fa_stud_payment.AMOUNT > 0 and ( fee_name like 'u-store%' or is_ustore = 1 "+
				" or fee_name like 'azent%' or fee_name like 'swu%' or fee_name like 'azbro%') ";
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
			
			
			
			vCollectionSWU = new Vector();	
			strTemp = " select min(or_number), max(or_number), sum(fa_stud_payment.amount), TELLER_NO "+
				" from fa_stud_payment "+
				" join user_table on (user_table.user_index = fa_stud_payment.created_by) "+
				" left join FA_TELLER_NO on (FA_TELLER_NO.user_index = fa_stud_payment.created_by) "+
				" where fa_stud_payment.is_valid = 1 and date_paid = '"+strDatePaid+"' and or_number is not null "+
				" and is_bank_post = 0 and is_sponsored=0 and fa_stud_payment.AMOUNT > 0 "+
				" and not exists(select * from "+strTempTable+" where or_number = fa_stud_payment.or_number)"+
				" and FA_TELLER_NO.VALID_FROM <= '"+strDatePaid+"' and FA_TELLER_NO.VALID_TO >= '"+strDatePaid+"' "+
				" group by TELLER_NO order by TELLER_NO ";
			
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
				vCollectionSWU.addElement(rs.getString(1));
				vCollectionSWU.addElement(rs.getString(2));
				vCollectionSWU.addElement(rs.getString(3));
				vCollectionSWU.addElement(rs.getString(4));
			}rs.close();
	
	
			vCollectionUStore = new Vector();
			strTemp = 
				 " select min(or_number), max(or_number), sum(fa_stud_payment.amount), TELLER_NO "+
				 " from fa_stud_payment "+
				 " join fa_oth_sch_fee on (fa_oth_sch_fee.othsch_fee_index = fa_stud_payment.othsch_fee_index) "+
				 " join user_table on (user_table.user_index = fa_stud_payment.created_by) "+
				 " left join FA_TELLER_NO on (FA_TELLER_NO.user_index = fa_stud_payment.created_by) "+
				 " where fa_stud_payment.is_valid = 1 and date_paid = '"+strDatePaid+"' and or_number is not null "+
				 " and is_bank_post = 0 and is_sponsored=0 and fa_stud_payment.AMOUNT > 0 and ( fee_name like 'u-store%' or is_ustore = 1 ) "+
				 " and FA_TELLER_NO.VALID_FROM <= '"+strDatePaid+"' and FA_TELLER_NO.VALID_TO >= '"+strDatePaid+"' "+
				 " group by TELLER_NO order by TELLER_NO ";
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
				vCollectionUStore.addElement(rs.getString(1));
				vCollectionUStore.addElement(rs.getString(2));
				vCollectionUStore.addElement(rs.getString(3));
				vCollectionUStore.addElement(rs.getString(4));
			}rs.close();
				
				
			vOtherIncome = new Vector();
			strTemp = 
				 " select fee_name, or_number, fa_stud_payment.amount, PAYMENT_FOR_DTLS, cancelIndex "+
				 " from fa_stud_payment "+
				 " join fa_oth_sch_fee on (fa_oth_sch_fee.othsch_fee_index = fa_stud_payment.othsch_fee_index) "+				 
				 " left join( "+
				 " 	select cancel_or_index as cancelIndex, OR_NUMBER as ORNumber "+
				 " 	from FA_CANCEL_OR where IS_VALID = 1 and IS_DEL = 0 "+
				 " )as CANCEL_OR on (CANCEL_OR.ORNumber = fa_stud_payment.OR_NUMBER) "+
				 " where fa_stud_payment.is_valid = 1 and date_paid = '"+strDatePaid+"' and or_number is not null "+
				 " and is_bank_post = 0 and is_sponsored=0 and fa_stud_payment.AMOUNT >= 0 and is_ustore = 0 "+
				 " and ( fee_name like '%azent%' or fee_name like 'swu%' or fee_name like 'azbro%' ) "+
				 " order by fee_name, or_number ";
			rs = dbOP.executeQuery(strTemp);
			while(rs.next()){
				vOtherIncome.addElement(rs.getString(1));//[0]fee_name
				vOtherIncome.addElement(rs.getString(2));//[1]or_number
				vOtherIncome.addElement(rs.getString(3));//[2]amount		
				vOtherIncome.addElement(rs.getString(4));//[3]PAYMENT_FOR_DTLS		
				vOtherIncome.addElement(rs.getString(5));//[4]cancelIndex			
			}rs.close();	
				
				
			CT.dropUniqueTable(dbOP, strTempTable);
			
			if(vCollectionSWU.size() == 0 && vCollectionUStore.size() == 0 && vOtherIncome.size() == 0)
				strErrMsg = "No Collection found.";	
		}
	}
}



if(strErrMsg == null) 
	strErrMsg = "";
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";


boolean bolShowTotal = false;

%>

<form name="daily_cash" method="post" action="./consolidated_cash_collection_or_range_SWU.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
         CONSOLIDATED CASH COLLECTION REPORT::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=strErrMsg%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
	
   <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2" height="25">Date of collection:
<%
strTemp = WI.fillTextValue("date_of_col");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>        <input name="date_of_col" type="text" size="12" maxlength="12" readonly value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('daily_cash.date_of_col');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>		</td>
      <td width="72%"><input type="image" src="../../../images/form_proceed.gif" onClick="ViewReport();">
		<label id="encode_test"></label>
		</td>
   </tr>

    
	<tr>
      <td colspan="5" height="19"><hr size="1"></td>
    </tr>
  </table>


  
<%
if( (vCollectionSWU != null && vCollectionSWU.size() > 0) || 
	(vCollectionUStore != null && vCollectionUStore.size() > 0) ||
	(vOtherIncome != null && vOtherIncome.size() > 0)){


bolShowTotal = true;
/*
int iRowCount = 0;
int iMaxRowCount = 34;	
	
int iPageCount = 1;
int iTotalStud = (vCollectionSWU.size()/12);
int iTotalPageCount = iTotalStud/iMaxRowCount;
if(iTotalStud % iMaxRowCount > 0)
	++iTotalPageCount;	


boolean bolPageBreak = false;

double dPageTotalSWU = 0d;
double dPageTotalUStore = 0d;

double dGrandTotalSWU = 0d;
double dGrandTotalUStore = 0d;*/
double dSubTotal = 0d;
double dGrandTotal = 0d;

if(vCollectionSWU != null && vCollectionSWU.size() > 0){

%>
	
   <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
   	<tr><td align="center" height="20"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td></tr>
      <tr><td align="center" height="20"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td></tr>
      <tr><td align="center" height="25">&nbsp;</td></tr>
      <tr><td height="20">CONSOLIDATED REPORT AS OF <%=WI.formatDate(WI.fillTextValue("date_of_col"), 6)%></td></tr>
      <tr><td height="20">STUDENT RECEIPTS</td></tr>
       <tr><td align="center" height="25">&nbsp;</td></tr>
   </table>
  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%for(int i = 0; i < vCollectionSWU.size(); i+=4){%>   	
      <tr>
			<td height="20" width="12%">SWU</td>
         <td width="21%"> - TELLER NO : <%=vCollectionSWU.elementAt(i+3)%></td>
         <td width="7%">O.R.#</td>
         <td width="15%"><%=vCollectionSWU.elementAt(i)%></td>
         <td width="4%">TO</td>
         <td width="17%"><%=vCollectionSWU.elementAt(i+1)%></td>
         <%
			dSubTotal += Double.parseDouble(WI.getStrValue((String)vCollectionSWU.elementAt(i+2),"0"));
			%>
         <td width="24%" align="right"><%=CommonUtil.formatFloat((String)vCollectionSWU.elementAt(i+2),true)%></td>
      </tr>
<%}%>
		<tr>
      	<td colspan="6" height="20" align="right">SUB TOTAL ====></td>
         <td align="right"><div style="border-top:dotted 1px #000000; width:60%;"><%=CommonUtil.formatFloat(dSubTotal,true)%></div></td>
      </tr>
  </table>
<%
}


dGrandTotal += dSubTotal;

if(vCollectionUStore != null && vCollectionUStore.size() > 0){%>  
  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  		<tr><td height="30">&nbsp;</td></tr>
<%
dSubTotal = 0d;
for(int i = 0; i < vCollectionUStore.size(); i+=4){%>   	
      <tr>
			<td height="20" width="12%">U STORE</td>
         <td width="21%"> - TELLER NO : <%=vCollectionUStore.elementAt(i+3)%></td>
         <td width="7%">O.R.#</td>
         <td width="15%"><%=vCollectionUStore.elementAt(i)%></td>
         <td width="4%">TO</td>
         <td width="17%"><%=vCollectionUStore.elementAt(i+1)%></td>
         <%
			dSubTotal += Double.parseDouble(WI.getStrValue((String)vCollectionUStore.elementAt(i+2),"0"));
			%>
         <td width="24%" align="right"><%=CommonUtil.formatFloat((String)vCollectionUStore.elementAt(i+2),true)%></td>
      </tr>
<%}%>
		<tr>
      	<td colspan="6" height="20" align="right">SUB TOTAL ====></td>
         <td align="right"><div style="border-top:dotted 1px #000000; width:60%;"><%=CommonUtil.formatFloat(dSubTotal,true)%></div></td>
      </tr>
  </table>
  
<%
	dGrandTotal += dSubTotal;
}//end if(vCollectionUStore != null && vCollectionUStore.size() > 0)

if(vOtherIncome != null && vOtherIncome.size() > 0){

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 <tr>
	<td height="20">&nbsp;</td>
	<td width="24%" align="right">&nbsp;</td>
</tr>
<%if(bolShowTotal){%> 
<tr>
	<td height="20" align="right">TOTAL . . . . . .  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</td>
	<td align="right"><div style="border-top:dotted 1px #000000; width:60%;"><%=CommonUtil.formatFloat(dGrandTotal,true)%></div></td>
</tr>	
<%}%>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="20" colspan="4" style="padding-left:20px;">OTHER RECEIPTS:</td></tr>
<%
dSubTotal = 0d;

String strCurrFeeName = null;
String strPrevFeeName = "";
boolean bolShowSubTotal = false;

String strDecor = "";

for(int i = 0; i < vOtherIncome.size(); ){

dSubTotal = 0d;

for( ; i < vOtherIncome.size(); i+=5){
	
	strCurrFeeName = (String)vOtherIncome.elementAt(i);
	if( !strPrevFeeName.equals(strCurrFeeName) && (strCurrFeeName.indexOf(strPrevFeeName) == -1)){
		strPrevFeeName = strCurrFeeName;		
		break;		
	}
	
	dSubTotal += Double.parseDouble(WI.getStrValue((String)vOtherIncome.elementAt(i+2),"0"));
	
	if(vOtherIncome.elementAt(i+4) != null)
		strDecor = "style='text-decoration:line-through;'";
	else
		strDecor = "";
%>
	<tr <%=strDecor%>>
		<td width="18%" height="20"><%=vOtherIncome.elementAt(i)%></td>
	   <td width="16%">O.R. #<%=vOtherIncome.elementAt(i+1)%></td>
	   <td width="42%"><%=WI.getStrValue(vOtherIncome.elementAt(i+3))%></td>
	   <td width="24%" align="right"><%=CommonUtil.formatFloat((String)vOtherIncome.elementAt(i+2),true)%></td>
	</tr>		
<%}
if(i > 0){
%>
	<tr>
		<td colspan="3" height="20" align="right">SUB TOTAL ====></td>
		<td align="right"><div style="border-top:dotted 1px #000000; width:60%;"><%=CommonUtil.formatFloat(dSubTotal,true)%></div></td>
	</tr>
<%}
dGrandTotal += dSubTotal;
}//outer loop%>
	
	
	
</table>
<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   	 <tr>
			<td height="20" width="12%">&nbsp;</td>
         <td width="16%">&nbsp;</td>
         <td width="7%">&nbsp;</td>
         <td width="15%">&nbsp;</td>
         <td width="4%">&nbsp;</td>
         <td width="22%">&nbsp;</td>
         <td width="24%" align="right">&nbsp;</td>
      </tr> 
      <tr>
      	<td colspan="6" height="20" align="right">GRAND TOTAL ====></td>
         <td align="right"><div style="border-top:dotted 1px #000000; width:60%;"><%=CommonUtil.formatFloat(dGrandTotal,true)%></div></td>
      </tr>	
   </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
   	 <td width="4%">&nbsp;</td>
      <td width="17%" height="60" valign="bottom" align="right">Prepared by &nbsp; &nbsp;</td>
      <td width="1%" valign="bottom" align="center">:</td>
      <td width="23%" valign="bottom"><div style="border-bottom:dotted 1px #000000;"></div></td>
      <td colspan="5">&nbsp;</td>      
   </tr>
   <tr>
   	<td colspan="3"></td>
      <td valign="top" align="center" style="letter-spacing:20px;">CASHIER</td>
   </tr>
   <tr>
   	 <td height="60" colspan="5">&nbsp;</td>
      <td width="12%" valign="bottom" align="right">Noted by &nbsp; &nbsp;</td>
      <td width="2%" valign="bottom">:</td>
      <td width="24%" valign="bottom"><div style="border-bottom:dotted 1px #000000;"></div></td>
      <td width="12%">&nbsp;</td>
   </tr>
   
   <tr>
   	<td colspan="7"></td>
      <td valign="top" align="center" style="letter-spacing:15px;">TREASURER</td>
   </tr>
  </table>  
    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td colspan="4" height="25"><div align="left">
	  
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print daily cash collection report</font></div></td>
      <td width="40%" height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%}%> 

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="view_report">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>