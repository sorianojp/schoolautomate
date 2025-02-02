<%@ page language="java" import="utility.*,Accounting.JvCD,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	String strTemp   = null;
	String strErrMsg = null;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) 
		strSchCode = "";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Transaction","journal_voucher_entry.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

///if called to update payee name, change it here. 
String strJVType = WI.fillTextValue("jv_type");

String strJVNumber = WI.fillTextValue("jv_number");/////I must get when i save / edit.
if(WI.fillTextValue("update_payee_name").length() > 0) {
	strTemp = WI.fillTextValue("payee_name");
	if(strTemp.length() == 0) 
		strErrMsg = "Must enter payee name";
	else {
		dbOP.executeUpdateWithTrans("update ac_jv set payee_name="+
			WI.getInsertValueForDB(strTemp, true, null)+" where jv_number='"+strJVNumber+"'", 
			null, null , false);
	}
}
Vector vRetResult = null;
JvCD jvCD = new JvCD();
boolean bolMustStop  = false;
boolean bolNewCreate = false;

strErrMsg = null;

if(WI.fillTextValue("page_action_2").length() > 0) {

	if(strJVType.equals("8")) {
		if(jvCD.updateRefundDebitCreditInfo(dbOP, request, dbOP.getResultOfAQuery("select jv_index from ac_jv where jv_number = '"+strJVNumber+"'",0), Integer.parseInt(WI.fillTextValue("page_action_2"))) == null)
			strErrMsg= jvCD.getErrMsg();
	}

	if(strErrMsg == null) {
		if(jvCD.modifyJVInfo(dbOP, request) == null) 
			strErrMsg = jvCD.getErrMsg();
		else {
			if(WI.fillTextValue("page_action_2").equals("1"))
				strErrMsg = "Voucher date changed successfully.";
			else {
				strErrMsg = "Voucher Number changed successfully.";
				strJVNumber = WI.fillTextValue("new_jv_num");
			}
		}
	}
	//System.out.println(strErrMsg);
}

if(strJVNumber.length() == 0 && (strJVType.equals("2") || strJVType.equals("1")) ){//add /drop - or scholarship.. 
	//I must save jv number automatically.. 
	if(strJVType.equals("1"))
		vRetResult = jvCD.createJVAddlJVType(dbOP, request, 2);
	else
		vRetResult = jvCD.createJVAddlJVType(dbOP, request, 1);
		
	if(vRetResult == null || vRetResult.size() == 0)  {
		bolMustStop = true;
		strErrMsg = jvCD.getErrMsg();
	}	
	else
		strJVNumber = (String)vRetResult.elementAt(0);
		
}

boolean bolIsJVLocked = false;
Vector vJVInfo = null;////[0]=jv_index, [1] = jv_date [2]=is_locked,[3]=explanation,[4]=remark.

Vector vEditInfo  = null; Vector vJVDetail = null; //to show detail at bottom of page. 

int iJVType = Integer.parseInt(strJVType);

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
//System.out.println("strTemp : "+strTemp);

if(strTemp.length() > 0 && (strTemp.equals("20") || strTemp.equals("30") || strTemp.equals("40"))) {
	String strJVIndex = "select jv_index from ac_jv where jv_number = '"+strJVNumber+"' ";
	strJVIndex = dbOP.getResultOfAQuery(strJVIndex, 0);
	if(strTemp.equals("20")) {//called for student refund debit-credit. - update.
		if(jvCD.operateOnRefundDebitCredit(dbOP, request, strJVIndex, 2) == null)
			strErrMsg = jvCD.getErrMsg();
		else	
			strErrMsg = "Information successfully updated.";
	}
	else if(strTemp.equals("30")) {//called for student refund debit-credit. - delete
		if(jvCD.operateOnRefundDebitCredit(dbOP, request, strJVIndex, 0) == null)
			strErrMsg = jvCD.getErrMsg();
		else	
			strErrMsg = "Information successfully deleted.";
	}
	else if(strTemp.equals("40")) {//called for student refund debit-credit. - create.
		if(jvCD.operateOnRefundDebitCredit(dbOP, request, strJVIndex, 1) == null)
			strErrMsg = jvCD.getErrMsg();
		else	
			strErrMsg = "Information successfully created.";
	}
	strTemp = "";
}

if(strTemp.length() > 0) {
	request.setAttribute("jv_number",strJVNumber);
	Vector vTemp = jvCD.createJV(dbOP, request, Integer.parseInt(strTemp));
	if(vTemp == null) {
		dbOP.rollbackOP();
		dbOP.forceAutoCommitToTrue();
		strErrMsg = jvCD.getErrMsg();
		if(jvCD.strJVNum != null)
			strJVNumber = jvCD.strJVNum;
	}
	else {
		//System.out.println(strJVType);
		strErrMsg = null;
		
		if(strJVType.equals("12")) {//called from AP
			String strJVIndex = "select jv_index from ac_jv where jv_number = '"+strJVNumber+"' ";
			strJVIndex = dbOP.getResultOfAQuery(strJVIndex, 0);
			
			Accounting.AccountPayable AP = new Accounting.AccountPayable();
			if(AP.editAPVAccountInfo(dbOP, request, strJVIndex, Integer.parseInt(strTemp))) {
				dbOP.commitOP();
				dbOP.forceAutoCommitToTrue();
			}
			else {
				dbOP.rollbackOP();
				dbOP.forceAutoCommitToTrue();
				strErrMsg = AP.getErrMsg();
				
				System.out.println(strErrMsg);
			}
		}
		else {
			dbOP.commitOP();
			dbOP.forceAutoCommitToTrue();
		}
		
		if(strErrMsg == null) {
			
			if(strTemp.equals("1") || strTemp.equals("2"))
				strJVNumber = (String)vTemp.elementAt(0);
			strPreparedToEdit = "0";
			//move all Debit information of this Petty cash to this Voucher.
	/**		if(iJVType == 11) {
				if(jvCD.createPCEntryFirstTime(dbOP, (String)vTemp.elementAt(1), WI.fillTextValue("pc_select"),request) > -1)
					strErrMsg = "Operation successful.";
				else 
					strErrMsg = "Failed to move PC Debit Information to Disbursement Voucher.";
			}
			else
	**/			strErrMsg = "Operation successful.";
			
			
			
			//update here the address. 
			strTemp = "update ac_jv set payee_addr = "+WI.getInsertValueForDB(WI.fillTextValue("payee_addr"), true, null)+
			" where jv_number = '"+strJVNumber+"'";
			//System.out.println(strTemp);
			dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		}
	}
	
}
	//to display running balance.. 
	double dTotalDebit = 0d;
	double dTotalCredit = 0d;

if(strJVNumber != null && strJVNumber.length() > 0 && !strJVNumber.equals("Enter Voucher Number")) {
	request.setAttribute("jv_number",strJVNumber);
	vRetResult = jvCD.createJV(dbOP, request, 4);
	if(vRetResult == null) {
		dbOP.rollbackOP();
		dbOP.forceAutoCommitToTrue();
		if(strErrMsg == null) 
			strErrMsg = jvCD.getErrMsg();
	}	
	else {
		dbOP.commitOP();
		dbOP.forceAutoCommitToTrue();
		vJVInfo    = (Vector)vRetResult.remove(0);
		vRetResult = (Vector)vRetResult.remove(0);
		if(vJVInfo.elementAt(2).equals("1")) {
			if(!strSchCode.startsWith("UDMC") && !strSchCode.startsWith("AUF"))//saci does not want to lock voucher.. 
				bolIsJVLocked = true;
			strErrMsg = "Voucher is locked. It is for viewing purpose only. Can't be modified anymore.";
		}
	}
	
	if(vRetResult != null && vRetResult.size() > 0) {
		for(int i = 0; i < vRetResult.size(); i += 5) {
			if(((String)vRetResult.elementAt(i + 4)).equals("1"))
				dTotalDebit += Double.parseDouble((String)vRetResult.elementAt(i + 3));
			else
				dTotalCredit += Double.parseDouble((String)vRetResult.elementAt(i + 3));
			
		}
	}	
		
}
//System.out.println("vJVInfo : "+ vJVInfo);
//System.out.println("strErrMsg : "+ strErrMsg);
	
if(strPreparedToEdit.equals("1")) {
	vEditInfo = jvCD.createJV(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = jvCD.getErrMsg();
}

if(strJVNumber != null)
	vJVDetail = jvCD.viewDetailJV(dbOP, strJVNumber);

String strIsCD = WI.fillTextValue("is_cd");
if(vJVDetail != null) {
	strIsCD = (String)((Vector)vJVDetail.elementAt(0)).elementAt(3);
	if(strIsCD == null)
		strIsCD = "0";
	strTemp = (String)((Vector)vJVDetail.elementAt(0)).elementAt(2);//jv type.
	if(!strTemp.equals(strJVType)) {
		strErrMsg = "Jv number does not belong to this jv type.";
		bolMustStop = true;
	}
	
}
else
	bolNewCreate = true;


if(strIsCD.length() == 0) 
	strIsCD = "0";

///I have to check if jv type clicked is correct. 
//for scholarship = get account number.. 
if(iJVType > 9 && iJVType != 12) {//must be strIsCD  = 1
	if(strIsCD.equals("0")) {
		strErrMsg = "Wrong re-direct. It must not be called from JV Page.";
		vRetResult = null;
	}//change vRetResult - null so that i return form this page.
}

Vector vPettyCashCDPending = null;
if(iJVType == 11) {//Petty cash
	//System.out.println(" I am here.");
	vPettyCashCDPending = jvCD.operateOnCDPettyCash(dbOP, request, 5);
	
	
}

/**
boolean bolAFormatToggleAllowed = false;
int iAccountFormat = 0; int iAccountLen = 0;
java.sql.ResultSet rs = dbOP.executeQuery("select ACC_NO_FORMAT,LENGTH from AC_COA_AC_LEN");
rs.next();
iAccountFormat = rs.getInt(1);
iAccountLen    = rs.getInt(2);
rs.close();

if(dbOP.getResultOfAQuery("select COA_INDEX from AC_COA WHERE IS_VALID = 1", 0) == null)
	bolAFormatToggleAllowed = true;
if(WI.fillTextValue("toggle").length() > 0) {
	if(WI.fillTextValue("toggle").equals("1")) {///update account code length.
		if(dbOP.executeUpdateWithTrans("update AC_COA_AC_LEN set LENGTH = "+
			WI.fillTextValue("coa_len"), null, null, false) != -1)
			iAccountLen = Integer.parseInt(WI.fillTextValue("coa_len"));
	}
	else {
		if(iAccountFormat == 1)
			iAccountFormat = 0;
		else		
			iAccountFormat = 1;
		dbOP.executeUpdateWithTrans("update AC_COA_AC_LEN set ACC_NO_FORMAT = "+
			Integer.toString(iAccountFormat), null, null, false);
	}
}


**/
boolean bolRemoveAllowed = false;

if(strSchCode.startsWith("UDMC") && vJVInfo != null){
	request.setAttribute("del_jv_index", vJVInfo.elementAt(0));
	
	if(jvCD.removeJVCDAllowed(dbOP, request))
		bolRemoveAllowed = true;
	
	//bolIsJVLocked = false;
	if(WI.fillTextValue("remove_all").equals("1")) {
		request.setAttribute("del_jv_index", vJVInfo.elementAt(0)) ;
		if(jvCD.removeJVCD(dbOP, request))
			strErrMsg = "Voucher information removed successfully.";
		else	
			strErrMsg = jvCD.getErrMsg();
	}
}

Vector vRefundDCInfo = null;
if(iJVType == 8 && vJVInfo != null && vJVInfo.size() > 0) {
	vRefundDCInfo = jvCD.operateOnRefundDebitCredit(dbOP, request, (String)vJVInfo.elementAt(0), 3);
	if(vRefundDCInfo == null)
		strErrMsg = jvCD.getErrMsg();
}

boolean bolJVForLiquidation = false;
if(WI.fillTextValue("jv_liquidation").length() > 0)
	bolJVForLiquidation = true;

boolean bolIsJVCRJ = false;
if(WI.fillTextValue("jv_crj").length() > 0)
	bolIsJVCRJ = true;


Vector vPrevNextVoucher = null;
if(vJVInfo != null && vJVInfo.size() > 0 && strSchCode.startsWith("AUF")) {
	vPrevNextVoucher = jvCD.getPrevNextVoucher(dbOP, (String)vJVInfo.elementAt(0));
}

boolean bolHideDebit = false;

	String strSQLQuery        = null;
	java.sql.ResultSet rs     = null;

Vector vCRJPending  = new Vector();
Vector vCRJSelected = new Vector();
double dTotalCRJAmt = 0d;
boolean bolAllowEditCreditEntry = true;
boolean bolIsCreditCreated = false;

String strJVCRJNumberIndex = WI.fillTextValue("jv_crj_number_i");//all those selected -- for the first time.. if jv already created and jv number is entered in create page, then get the numbers from db.

//if called for JVCRJ and CRJ is not selected, hide Debit entry.
//additional Code added to handle if JV Number is encoded.. 
if(vJVInfo != null &&  vJVInfo.size() > 0) {
	//I have to check if this is supposed to be bolIsJVCRJ
	String strJVIndex = (String)vJVInfo.elementAt(0);
	if(!bolIsJVCRJ) {
		strSQLQuery = "select jv_index, jv_number, jv_type from ac_jv where jv_link_index = "+strJVIndex+" and jv_type = 4";//type crj..
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null) {//it must be crj -> GJV type .. 
			dbOP.cleanUP();
			response.sendRedirect("./journal_voucher_entry.jsp?jv_number="+WI.fillTextValue("jv_number")+"&jv_type=0&jv_crj=1");
			return;
		}
	}
	else {//if selected as jvCRJ.
		if(strJVCRJNumberIndex.length() == 0) {
			strSQLQuery = "select jv_index, jv_number from ac_jv where jv_link_index = "+strJVIndex+" and jv_type = 4";//type crj..
			rs = dbOP.executeQuery(strSQLQuery);
			while(rs.next()) {
				if(strJVCRJNumberIndex.length() == 0) 
					strJVCRJNumberIndex = rs.getString(1)+","+rs.getString(2);
				else	
					strJVCRJNumberIndex = strJVCRJNumberIndex+","+rs.getString(1)+","+rs.getString(2);
			}
			rs.close();
		}
		if(strJVCRJNumberIndex.length() == 0) {//this is not supposed to be GJV=-> CRJ.. 
			dbOP.cleanUP();
			response.sendRedirect("./journal_voucher_entry.jsp?jv_number="+WI.fillTextValue("jv_number")+"&jv_type=0");
			return;
		}
	}
	
}



if(bolIsJVCRJ) {
	bolAllowEditCreditEntry = false;
	
	String strCashOnHandIndex = null;
	
	strSQLQuery = "select CR_COA_DEBIT from FA_COLLEGE_CASHRECEIPT";
	strCashOnHandIndex = dbOP.getResultOfAQuery(strSQLQuery, 0);
	
	if(strCashOnHandIndex == null) 
		strErrMsg = "Cash on Hand is not mapped.";
		
	strSQLQuery = null;
	if(strJVCRJNumberIndex.length() > 0 && strCashOnHandIndex != null) {//crj already selected... 
		vCRJSelected = CommonUtil.convertCSVToVector(strJVCRJNumberIndex,",", true);
		while(vCRJSelected.size() > 0) {
			if(strSQLQuery == null) 
				strSQLQuery = (String)vCRJSelected.remove(0);
			else
				strSQLQuery = strSQLQuery +","+(String)vCRJSelected.remove(0);
			vCRJSelected.remove(0);
		}
		strSQLQuery = "select jv_number, jv_date, amount from ac_jv join ac_jv_dc on (ac_jv_dc.jv_index = ac_jv.jv_index) where coa_index = "+strCashOnHandIndex+
					" and ac_jv.jv_index in ("+strSQLQuery+") order by jv_date desc"; //System.out.println(strSQLQuery);
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vCRJSelected.addElement(rs.getString(1));//[0] jv_number
			vCRJSelected.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(2)));//[1] jv_date			
			vCRJSelected.addElement(CommonUtil.formatFloat(rs.getDouble(3), true));//[2] jv_amount
			
			dTotalCRJAmt += rs.getDouble(3);
		}
		rs.close();
	}		
	else if(strJVCRJNumberIndex.length() == 0 && strCashOnHandIndex != null) {
		bolHideDebit = true;
		strSQLQuery = "select ac_jv.jv_index, jv_number, jv_date, amount from ac_jv "+
							"join ac_jv_dc on (ac_jv_dc.jv_index = ac_jv.jv_index) "+
							"where jv_type = 4 and is_locked = 1 and coa_index = "+strCashOnHandIndex+" and jv_link_index is null order by jv_date desc";
		rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
		while(rs.next()) {
			vCRJPending.addElement(rs.getString(1));//[0] jv_index
			vCRJPending.addElement(rs.getString(2));//[1] jv_number
			vCRJPending.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(3)));//[2] jv_date			
			vCRJPending.addElement(CommonUtil.formatFloat(rs.getDouble(4), true));//[3] jv_amount
		}
		rs.close();
	}
}


%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

</style>
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
/** All about the supplier here.. **/
function ShowSupplier() {
	<%if(WI.fillTextValue("show_supplier_list").length() > 0) {%>
		document.form_.show_supplier_list.value = '';
	<%}else{%>
		document.form_.show_supplier_list.value = '1';
	<%}%>	
	document.form_.page_action.value = '';
	document.form_.submit();
}
function UpdatePayeeInfo(strPayeeName, strIndex) {//I have to determine payee name and total payment amount.. 
	document.form_.payee_name.value = strPayeeName;
	var iMaxDisp = document.form_.sup_ref_max_count.value;
	var dAmount = 0; var dTemp = 0; var objChkbox;
	
	var isChecked = false;
	for(i = 0; i < iMaxDisp; ++i) {
		eval('objChkbox=document.form_.sup_ref'+i);
		if(!objChkbox)
			break;
		if(!objChkbox.checked)
			continue;
		isChecked = true;
		dTemp = eval('document.form_.pmt_amount'+i+'.value');
		dAmount = eval(dAmount) + eval(dTemp);
	}
	document.form_.amount.value = dAmount;
	
	if(isChecked)
		document.form_.page_action_supplier.value = '1';
	else	
		document.form_.page_action_supplier.value = '';
}
function UpdateSupplierPmtInfo(strPageAction) {
	document.form_.page_action_supplier.value = strPageAction;
	document.form_.page_action.value = '';
	document.form_.submit();
}

/** end of supplier reference ***/

function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		//cancell is called.
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
		
		document.form_.particular.value = "";
		document.form_.coa_index.value = "";
		document.form_.amount.value = "";
		
		if(document.form_.particular_c) {
			document.form_.particular_c.value = "";
			document.form_.coa_index_c.value = "";
			document.form_.amount_c.value = "";
		}
	}
	if(strAction == "0")
		document.form_.submit();
}
function PreparedToEdit(strInfoIndex, strDebitInfo) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.is_debit.value = strDebitInfo;
	
	if(strDebitInfo == "1") 
		document.form_.set_focus.value='1';
	else
		document.form_.set_focus.value='2';
	
	document.form_.submit();
}
function AddCOA(strCOACF) {
	location = "./chart_of_account.jsp?coa_cf="+strCOACF;
}
function ConfirmDel(strInfoIndex) {
	if(confirm("Do you want to delete."))
		return this.PageAction('0',strInfoIndex);
}
function focusID() {
	if(!document.form_.set_focus)
		return;
	var strSetFocus = document.form_.set_focus.value;
	if(strSetFocus == "1")
		document.form_.focus_debit.focus();
	else if(strSetFocus == "2")
		document.form_.focus_credit.focus();
}	
function AddDetail(strInfoIndex) {
	var pgLoc = "";
	var strJVType = document.form_.jv_type.value;
	//1 = scholarship, 2 = add/drop, 3 = enrollment -- more on JV
	
	
	//10 = CD others, 11 = cd Petty cash  -- more on cd.
	
	///go here if jv_type = 0
	pgLoc = "./jv_ar_student.jsp?credit_index="+strInfoIndex+
	"&jv_number="+document.form_.jv_number.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
}

////print called here.. 
function PrintJV() {
	strJVNumber = document.form_.jv_number.value;
	if(strJVNumber.length == 0) {
		alert("JV Number not found.");
		return;
	}
	var pgLoc = "./print_jv.jsp?jv_number="+strJVNumber;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
}
function PrintSupportingDoc() {
	strJVNumber = document.form_.jv_number.value;
	if(strJVNumber.length == 0) {
		alert("JV Number not found.");
		return;
	}	
	
	var pgLoc = "";
	var strJVType = document.form_.jv_type.value;
	if(strJVType == "2") {//add drop.. print supporting doc of add/drop.. 
		strJVType = document.form_.jv_index.value;//jv_index
		pgLoc = "../../../fee_assess_pay/fee_adjustments/add_drop_entry.jsp?jv_index="+strJVType+"&add_drop_stat=0";
	}
	else if(strJVType == "1") {//scholarship.. print supporting doc of scholarship .. to come..
		strJVType = document.form_.jv_index.value;//jv_index
		pgLoc = "../../../fee_assess_pay/fee_adjustments/add_drop_entry.jsp?jv_index="+strJVType+"&add_drop_stat=0";
	}
	else
		pgLoc = "./print_jv_detail.jsp?jv_number="+strJVNumber;
	
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
}

///
function UpatePCAmt() {
	var vSelIndex = document.form_.pc_select.selectedIndex;
	var dAmount = "";
	eval('dAmount = document.form_.pc_amount'+vSelIndex+'.value');
	document.form_.amount.value = dAmount;
}


///for searching COA
		var objCOA;
function MapCOAAjax(strIsBlur,strCoaFieldName, strParticularFieldName) {
		if(strCoaFieldName == 'coa_index')
			objCOA=document.getElementById("coa_info");
		else	
			objCOA=document.getElementById("coa_info_c");
		
		var objCOAInput;
		eval('objCOAInput=document.form_.'+strCoaFieldName);
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strCoaFieldName+"&coa_particular="+
			strParticularFieldName+"&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "End of Processing..";
	if(objParticular != null) {
		objParticular.value = strAccountName;
	}
}

///use ajax to update voucher date and voucher number.
function UpdateInfo(strIndex) {
	if(strIndex == '1') {//update voucher date
		if(!confirm("Are you sure you want to change voucher date?"))
			return;
		if(document.form_.voucher_date_prev.value == document.form_.jv_date.value) {
			alert("Please enter new voucher date and click update.");
			return;
		}
		document.form_.page_action_2.value = "1";
	}
	else {//update voucher number
		var strJVNumber = prompt("Please enter voucher Number : ", "");
		if(strJVNumber == null)
			return;
		if(strJVNumber.length == 0) {
			alert("Please enter new voucher number.");
			return;
		}
		if(strJVNumber == document.form_.jv_number.value) {
			alert("Please enter new voucher number.");
			return;
		}
		document.form_.new_jv_num.value = strJVNumber;
		document.form_.page_action_2.value = "2";
	}

	document.form_.submit();
}
function RemoveAllInfo() {
	if(!confirm("Are you sure you want to remove all information of this voucher? Click cancel to return, Ok to remove"))
		return;
	document.form_.remove_all.value = '1';
	document.form_.submit();	
}

function UpdateExplanation(strGroupNo) {
	if(true)
		return;
		
	if(!confirm("Are you sure you want to Edit Explanation."))
		return;
	
	strJVNumber = document.form_.jv_number.value;
	if(strJVNumber.length == 0) {
		alert("JV Number not found.");
		return;
	}	
	pgLoc = "./edit_explanation.jsp?group_no="+strGroupNo+"&jv_number="+strJVNumber;	
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	//// not implemented.. 	
}


/** called to create new voucher.. **/
function EncodeNewVoucher() {
	strJVNumber = prompt('To edit or view detail, enter voucher number.','');
	if(strJVNumber == null)
		strJVNumber = "";
	location = "./journal_voucher_entry.jsp?jv_number="+escape(strJVNumber)+"&jv_type="+
				document.form_.jv_type.value+"&is_cd="+document.form_.is_cd.value;
}
/** end **/

function JumpToVoucher(strVoucher) {
	if(strVoucher.length == 0) {
		alert("Reached end.");
		return;
	}
	location = "./journal_voucher_entry.jsp?jv_number="+escape(strVoucher)+"&jv_type="+
	document.form_.jv_type.value;
}



function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


//update ajax for liquidation and payment type info.. 
function AjaxUpdate(strUpdateType) {
	<%if(strJVNumber == null || strJVNumber.length() == 0) {%>
		return;
	<%}%>
	
	var strJVNumber = "<%=strJVNumber%>";
	var strNewVal;
	var objCOA = document.getElementById("coa_liquidation");
	
	if(strUpdateType == '2') {
		strNewVal = document.form_.pmt_type[document.form_.pmt_type.selectedIndex].value;
		objCOA = document.getElementById("coa_pmttype");
	}
	else {
		if(document.form_.for_liquidation.checked)
			strNewVal = "1";
		else
			strNewVal = "0";
	}
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=502&type_="+strUpdateType+"&jv_="+escape(strJVNumber)+"&new_val="+strNewVal;
	//alert(strURL);
	this.processRequest(strURL);
}



function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2) {
			document.getElementById("coa_info_refund").innerHTML = "";
			return;
		}
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info_refund");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
}
function UpdateName(strFName, strMName, strLName) {
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info_refund").innerHTML = "";
}


//process CRJ selected.. 
function ProcessCRJ() {
	var strCRJSelected = "";
	var iMaxCRJ = document.form_.crj_max_disp.value;
	if(iMaxCRJ == '') {
		alert("No CRJ found in list.");
		return;
	}
	var obj;
	for(i = 0; i < iMaxCRJ; ++i) {
		eval('obj=document.form_.crj_ref'+i);
		if(!obj)
			continue;
		if(!obj.checked)
			continue;
		if(strCRJSelected == '')
			strCRJSelected += obj.value;
		else	
			strCRJSelected = strCRJSelected +","+obj.value;
	}
	if(strCRJSelected == '') {
		alert("Please select at least one CRJ to process GJV");
		return ;
	}
	document.form_.jv_crj_number_i.value = strCRJSelected;
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<form action="./journal_voucher_entry.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          <%if(strIsCD.equals("2")){%>PETTY CASH<%}else if(strIsCD.equals("1")){%>
          DISBURSEMENT VOUCHER 
           <%}else{%>
           GENERAL JOURNAL
           <%}%> ENTRY - DETAILS ENCODING PAGE ::::</strong></font></div></td>
    </tr>
<%if(WI.fillTextValue("view_only").length() == 0) {%>
    <tr bgcolor="#FFFFFF">
      <td width="85%" height="25" style="font-size:14px; color:#0000FF; font-weight:bold"><a href="<%if(strIsCD.equals("2")){%>../petty_cash/petty_cash.jsp<%}else if(strIsCD.equals("1")){%>../cash_disbursement/cash_disbursement.jsp<%}else{%>./journal_voucher.jsp<%}%>"><img src="../../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%>	  </td>
      <td width="15%" style="font-size:12px; color:#FF0000; font-weight:bold">
	  	<a href="javascript:EncodeNewVoucher()">Create New </a>	  </td>
    </tr>
<%}
if(vPrevNextVoucher != null) {%>
    <tr bgcolor="#FFFFFF">
      <td height="25" align="right" colspan="2" style="font-size:14px; color:#0000FF; font-weight:bold">
	  <a href="javascript:JumpToVoucher('<%=WI.getStrValue((String)vPrevNextVoucher.remove(0))%>')"><< Previous </a>&nbsp;&nbsp;&nbsp;
	  
	  <a href="javascript:JumpToVoucher('<%=WI.getStrValue((String)vPrevNextVoucher.remove(0))%>')">>> Next</a>
	  </td>
    </tr>
<%}%>
  </table>
<%
if(bolMustStop) {
	dbOP.cleanUP();
	return;
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="18%" valign="top">Voucher No.</td>
      <td width="79%" style="font-size:11px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strJVNumber,"<label onClick=UpdateInfo('2');>","</label>","To be auto generated")%>
	  <%
	  strTemp = strJVType;
	  if(strTemp.length() > 0) {
	  	int iJvType = Integer.parseInt(strTemp);
		if(iJVType == 0 || iJVType == 10) {
			strTemp = "Others";
			if(bolJVForLiquidation) 
				strTemp = "For Liquidation";
		}
		else if(iJVType == 1)
			strTemp = "Scholarship";
		else if(iJVType == 2)
			strTemp = "Add/Drop";
		else if(iJVType == 3)
			strTemp = "Enrollment";
		else if(iJVType == 11)
			strTemp = "Petty Cash";
		else
			strTemp = "";
		if(bolIsJVCRJ)
			strTemp = "GJV for CRJ";
		%><div align="right" style="font-size:11px; color:#0000FF; font-weight:bold"><%=strTemp%></div>
	 <%}%>	  </td>
    </tr>
<%
//if(strJVNumber != null && strJVNumber.length() > 0 && vRetResult == null) {
//dbOP.cleanUP();
//return;
//}	
if(bolRemoveAllowed){%>
    <tr> 
      <td height="9" colspan="3"><a href="javascript:RemoveAllInfo();"><font color="#333333">Remove All Voucher Information</font></a></td>
    </tr>
<%}%>
    <tr> 
      <td height="9" colspan="3"><hr size="1"></td>
    </tr>
<%if(!bolIsJVLocked){//if locked, do not edit information. or show input boxes.. 
if(strIsCD.equals("1") || strIsCD.equals("2")){%>   

<%//show here if paid to supplier.. 
if(strIsCD.equals("1") && strJVType.equals("10")){
Accounting.AccountPayable AP = new Accounting.AccountPayable();

strErrMsg = null;
strTemp = WI.fillTextValue("page_action_supplier");
//I have to find out if check boxes are checked.. 
if(strTemp.length() == 0) {
	int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("sup_ref_max_count"), "0"));
	for(int i = 0; i < iMaxDisp; ++i) {
		if(WI.fillTextValue("sup_ref"+i).length() > 0) {
			strTemp = "1";
			break;
		}
	}
}
if(vJVInfo != null)
	request.setAttribute("cd_ref",vJVInfo.elementAt(0));


if(strTemp.length() > 0 ) { 
	if(AP.payDues(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = AP.getErrMsg();	
}
//System.out.println("strTemp : "+strTemp+" ;; strErrMsg : "+strErrMsg);
if(strErrMsg != null){%>
	<script>
		alert("<%=strErrMsg%>");
	</script>
<%}
	

Vector vSupplierPayable = null;//supplier list having payable. 
Vector vSupplierPaid    = null;//already saved for this CD.. 
if(vJVInfo != null) {
	request.setAttribute("cd_ref",vJVInfo.elementAt(0));
	vSupplierPaid = AP.payDues(dbOP, request, 5);
}
	if(vSupplierPaid == null)
		vSupplierPayable = AP.payDues(dbOP, request, 3);
String strTemp2 = null;

if(vSupplierPaid != null && vSupplierPaid.size() > 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:10px; color:#0000FF"> Payable To Supplier - <a href="javascript:UpdateSupplierPmtInfo('50');">Delete Record </a> 
		<table width="70%" cellpadding="0" cellspacing="0" class="thinborder">
			<tr bgcolor="#DDDDDD">
				<td class="thinborder" width="35%">Supplier</td>
				<td class="thinborder" width="12%">Payment Due Date</td>
				<td class="thinborder" width="35%">Payee Name</td>
				<td class="thinborder" width="13%">Amount Payable</td>
			</tr>
			<%
			int iCount= 0;
			while(vSupplierPaid.size() > 0) {
			strTemp   = (String)vSupplierPaid.elementAt(5);
			strTemp2 = ConversionTable.replaceString((String)vSupplierPaid.elementAt(4),"'","String.fromCharCode(39)");
			%>
			<tr bgcolor="#FFFF99">
				<td class="thinborder"><%=vSupplierPaid.elementAt(0)%> : <%=vSupplierPaid.elementAt(1)%></td>
				<td class="thinborder"><%=vSupplierPaid.elementAt(3)%></td>
				<td class="thinborder"><%=WI.getStrValue(strTemp2,"not set")%></td>
				<td class="thinborder" align="right"><%=CommonUtil.formatFloat(strTemp, true)%> &nbsp;</td>
			</tr>
			<%++iCount;
			vSupplierPaid.remove(0);vSupplierPaid.remove(0);vSupplierPaid.remove(0);
			vSupplierPaid.remove(0);vSupplierPaid.remove(0);vSupplierPaid.remove(0);
			}%>
		</table>	  </td>
    </tr>
<%}else if (vSupplierPayable != null && vSupplierPayable.size() > 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:10px; color:#0000FF"> <a href="javascript:ShowSupplier();"><%if(WI.fillTextValue("show_supplier_list").length() > 0){%>Remove Supplier List<%}else{%>Select Supplier for payment<%}%></a>
	  <%if(WI.fillTextValue("show_supplier_list").length() > 0){%>
	  	<br>
		<table width="70%" cellpadding="0" cellspacing="0" class="thinborder">
			<tr bgcolor="#DDDDDD">
				<td class="thinborder" width="35%">Supplier</td>
				<td class="thinborder" width="12%">Payment Due Date</td>
				<td class="thinborder" width="35%">Payee Name</td>
				<td class="thinborder" width="13%">Amount Payable</td>
				<td class="thinborder" width="5%">Select</td>
			</tr>
			<%
			int iCount= 0;
			while(vSupplierPayable.size() > 0) {
			strTemp   = (String)vSupplierPayable.elementAt(5);
			strTemp2 = ConversionTable.replaceString((String)vSupplierPayable.elementAt(4),"'","String.fromCharCode(39)");
			%>
			<tr bgcolor="#CCFF66">
				<td class="thinborder"><%=vSupplierPayable.elementAt(0)%> : <%=vSupplierPayable.elementAt(1)%></td>
				<td class="thinborder"><%=vSupplierPayable.elementAt(3)%></td>
				<td class="thinborder"><%=WI.getStrValue(strTemp2,"not set")%></td>
				<td class="thinborder" align="right"><%=CommonUtil.formatFloat(strTemp, true)%> &nbsp;</td>
				<td class="thinborder" align="center"><input type="checkbox" name="sup_ref<%=iCount%>" value="<%=vSupplierPayable.elementAt(2)%>" onClick="UpdatePayeeInfo('<%=strTemp2%>','<%=iCount%>');">
				
				<input type="hidden" name="pmt_date<%=iCount%>" value="<%=vSupplierPayable.elementAt(3)%>">
				<input type="hidden" name="pmt_amount<%=iCount%>" value="<%=strTemp%>">				</td>
			</tr>
			<%++iCount;
			vSupplierPayable.remove(0);vSupplierPayable.remove(0);vSupplierPayable.remove(0);
			vSupplierPayable.remove(0);vSupplierPayable.remove(0);vSupplierPayable.remove(0);
			}if(vJVInfo != null) {%>
			<tr>
				<td class="thinborder" colspan="5" align="center"><input type="button" name="_" value="Save" onClick="UpdateSupplierPmtInfo('1')"></td>
			</tr>
			<%}%>
		</table>
		<input type="hidden" name="sup_ref_max_count" value="<%=iCount%>">
		<%}%>	  </td>
    </tr>
	
<%}//end of display supplier related Information.. %>
	
<%}//end of if paid to supplier.. %>

	<tr>
	  <td height="25">&nbsp;</td>
	  <td style="font-size:9px;">Payee Name Reference </td>
	  <td>
	    <select name="copy_pn" style=" width:500px; font-size:10px;" onChange="document.form_.payee_name.value=document.form_.copy_pn[document.form_.copy_pn.selectedIndex].value">
          <option value="">Select any name to copy to "Payee Name"</option>
<%
strTemp = "";
if(strSchCode.startsWith("CGH"))
	strTemp = " encoded_date > '2014-01-01'";
%>

<%=dbOP.loadCombo("distinct payee_name","PAYEE_NAME"," from AC_JV where IS_CD = "+strIsCD+strTemp+" order by AC_JV.payee_name", null, false)%>
        </select>	  </td>
	</tr>
     <tr>
	  <td height="25">&nbsp;</td>
      <td>Payee Name </td>
      <td style="font-size:9px;">
<%
//i have to get voucher date here if created already.
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("payee_name");
%>
	  <input name="payee_name" type="text" size="45" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">(one payee per voucher) 
<%if(vJVInfo != null) {%>
<input type="submit" name="122" value=" Update Payee Name " style="font-size:10px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.update_payee_name.value='1';PageAction('','');">
<%}%>	  </td>
    </tr>
<%if(strSchCode.startsWith("PHILCST")){%>
     <tr>
       <td height="25">&nbsp;</td>
       <td>Payee Address </td>
       <td style="font-size:9px;">
<%
//I have to get the payee address.
if(vJVInfo != null) {
	strTemp = "select PAYEE_ADDR from AC_JV where jv_index = "+(String)vJVInfo.elementAt(0);
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
}
else	
	strTemp = WI.fillTextValue("payee_addr");
%>	   
	   <input name="payee_addr" type="text" size="75" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
     </tr>
<%}//show address only to philcst.. 

}//show payee name if this is for CD.. 

if(iJVType == 8) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  	<table width="64%" cellpadding="0" cellspacing="0" border="0" bgcolor="#CCCCCC" class="thinborderALL">
			<tr>
				<td colspan="2" style="font-size:11px; font-weight:bold"><u>Student Information: </u></td>
			</tr>
<%
if(vRefundDCInfo != null && vRefundDCInfo.size() > 0) 
	strTemp = (String)vRefundDCInfo.elementAt(0);
else	
	strTemp = WI.fillTextValue("stud_id");
%>
			<tr>
				<td width="29%">Student ID</td>
			    <td width="71%"><input name="stud_id" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
					<label id="coa_info_refund" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute"></label>			  </td>
			</tr>
			<tr>
			  <td>SY-Term</td>
			  <td>
<%
if(vRefundDCInfo != null && vRefundDCInfo.size() > 0) 
	strTemp = (String)vRefundDCInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("sy_from");
%>
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
	  
	  - 

<%
if(vRefundDCInfo != null && vRefundDCInfo.size() > 0) 
	strTemp = (String)vRefundDCInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("sy_to");
%>
	  <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
	  
	  <select name="semester">
<%
if(vRefundDCInfo != null && vRefundDCInfo.size() > 0) 
	strTemp = (String)vRefundDCInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("semester");

if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="0" <%=strErrMsg%>>Summer</option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
        </select>			  </td>
		  </tr>
<%
if(vRefundDCInfo != null && vRefundDCInfo.size() > 0) {
	strTemp = (String)vRefundDCInfo.elementAt(4);
	if(strTemp.startsWith("-"))
		strTemp = "0";
	else		
		strTemp = "1";
}
else {	
	strTemp = WI.fillTextValue("is_credit");
	if(strIsCD.equals("1"))
		strTemp = "0";
}
%>
			<tr>
			  <td>Refund Type</td>
			  <td>
				<%
					if(strTemp.length() == 0)
						strTemp = " checked";
					else
						strTemp = "";
				%> 
				<input type="radio" name="is_credit" value="0"<%=strTemp%>> Debit
				<%if(strIsCD.equals("0")){
					if(strTemp.length() == 0)
						strTemp = " checked";
					else
						strTemp = "";
					%> 
					<input type="radio" name="is_credit" value="1" <%=strTemp%>> Credit			  
				<%}//do not show this option if Cash disbursement.. %>				</td>
		  </tr>
<%
if(vRefundDCInfo != null && vRefundDCInfo.size() > 0) 
	strTemp = (String)vRefundDCInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("refund_type");
%>
			<tr>
			  <td>Debit/Credit Type</td>
			  <td>
				<select name="refund_type" style="background-color:#CCCCCC; font-weight:bold; font-size:11px; border:double; width:350px;">
    	      		<%=dbOP.loadCombo("REFUND_TYPE_INDEX","REFUND_TYPE_NAME,IS_TUITION_TYPE_NAME"," from FA_STUD_REFUND_TYPE where is_valid = 1 order by refund_type_name", strTemp, false)%>
		  		</select>		  </td>
		  </tr>
<%
if(vRefundDCInfo != null && vRefundDCInfo.size() > 0) {
	strTemp = (String)vRefundDCInfo.elementAt(4);
	if(strTemp.startsWith("-"))
		strTemp = strTemp.substring(1);
}
else	
	strTemp = WI.fillTextValue("refund_amt");
%>
			<tr>
			  <td>Amount</td>
			  <td><input name="refund_amt" type="text" size="12" maxlength="32" value="<%=strTemp%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','refund_amt');style.backgroundColor='white'"
	   		onKeyUp="AllowOnlyFloat('form_','refund_amt');"></td>
		  </tr>
<%
if(vRefundDCInfo != null && vRefundDCInfo.size() > 0) 
	strTemp = (String)vRefundDCInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("refund_note");
%>
			<tr>
			  <td>Remarks</td>
			  <td>
				<input type="text" name="refund_note" value="<%=strTemp%>" maxlength="128" size="65" class="textbox"
				    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">			  </td>
		  </tr>
<%if(vRefundDCInfo != null && vRefundDCInfo.size() > 0) {%>
			<tr>
			  <td align="center">
			    <input type="submit" name="12225" value=" Update Information " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 		onClick="PageAction('20','');">			  </td>
			  <td align="center">
			    <input type="submit" name="12225" value=" Delete Information " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 		onClick="PageAction('30','');">			  </td>
		  </tr>
<%}else if(vJVInfo != null && vJVInfo.size() > 0){%>
			<tr>
			  <td align="center">&nbsp;</td>
			  <td><input type="submit" name="122252" value=" Create Information " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 		onClick="PageAction('40','');"></td>
		  </tr>
<%}%>		  
		</table>	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Voucher Date</td>
      <td>
<%
//i have to get voucher date here if created already.
strTemp = "";
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(1);
else {
	if(strJVNumber != null && strJVNumber.length() > 4 && strIsCD.equals("0") && strSchCode.startsWith("CLDH")) {
		strTemp = strJVNumber.substring(2,4)+"/01/20"+strJVNumber.substring(0,2);//mm/dd/yyyy	
	}
	if(strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);

}
%>
        <input name="jv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.jv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
		
		&nbsp;&nbsp;&nbsp;&nbsp;
<%if(vJVInfo != null){%>
		<a href="javascript:UpdateInfo('1');">Update Voucher Date</a>
<%}%>	  </td>
    </tr>
<%if(bolJVForLiquidation){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Voucher to Liquidate </td>
      <td><input name="vourcher_to_liquidate" type="text" size="18" maxlength="128" value="<%=WI.fillTextValue("vourcher_to_liquidate")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<%}

if(strIsCD.equals("1")) {
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("for_liquidation");
if(strTemp == null)
	strTemp = "0";
if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-weight:bold; font-size:11px; color:#FF0000">
	  <input type="checkbox" name="for_liquidation" value="1" <%=strTemp%> onClick="AjaxUpdate('1');"> For Liquidation 
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <label id="coa_liquidation" style="color:#0000FF"></label>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment Type </td>
      <td>
<%
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("pmt_type");
%>
	  <select name="pmt_type" onChange="AjaxUpdate('2');">
		<%=dbOP.loadCombo("PMT_TYPE","PMT_TYPE_NAME"," from AC_JV_CD_PMTTYPE order by PMT_TYPE asc",strTemp, false)%>
       </select>
	  <font size="1">Note: Check required for Check pmt type. System will not allow making check for other pmt type</font>	  
	  &nbsp;&nbsp;&nbsp;
	  <label id="coa_pmttype" style="color:#0000FF; font-weight:bold; font-size:9px;"></label>	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Group Number </td>
      <td>
<%if(bolNewCreate) {%><b style="font-size:11px;">1 - Fixed</b>
<%}else{%>
	  <select name="group_number" onChange="document.form_.submit();">
<%
strTemp = WI.fillTextValue("group_number");
int iGroupNo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("group_number"), "1"));
	for(int i =1; i < 6; ++i){
		if(iGroupNo == i)
			strTemp = " selected";
		else
			strTemp = "";
	%><option value="<%=i%>"<%=strTemp%>><%=i%></option> 
<%}%></select>
<%}%>&nbsp;&nbsp;&nbsp;
	  <input type="submit" name="122" value=" Refresh " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');"></td>
    </tr>
<%if(strSchCode.startsWith("PIT") && !strIsCD.equals("2")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><u><strong>Other Informations</strong></u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fund Group </td>
      <td>
<%
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("fund_group");
%>
	  <select name="fund_group">
	<option></option>
	<%=dbOP.loadCombo("FG_INDEX","FG_NAME"," from AC_COA_FG order by fg_name asc",strTemp, false)%>
        </select>
		<a href='javascript:viewList("AC_COA_FG","FG_INDEX","FG_NAME","Fund Group Name",
		"AC_COA_BANKCODE,AC_JV","FUND_GROUP_INDEX,FUND_INDEX_", 
		" and AC_COA_BANKCODE.is_valid = 1,AC_JV.JV_INDEX is not null","","fund_group")'><img src="../../../../images/update.gif" border="0"></a><font size="1">click to update list of FUND Group</font>	  </td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>GL Entry Type </td>
      <td>
<%
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(7);
else
	strTemp = WI.fillTextValue("fund_group");
%>
	  <select name="gl_type">
        <%=dbOP.loadCombo("GL_TYPE_REF","GL_TYPE_NAME"," from AC_JV_GL_TYPE where is_cd_ = "+strIsCD+" order by GL_TYPE_NAME asc",strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><u>Responsibility Center :</u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Title: &nbsp;
<%
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(8);
else
	strTemp = WI.fillTextValue("fund_group");
%>
        <input name="responsibility_title" type="text" size="45" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Code: 
<%
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(9);
else
	strTemp = WI.fillTextValue("fund_group");
%>
        <input name="responsibility_code" type="text" size="45" maxlength="128" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
<input type="hidden" name="auto_gen_pit">	
<%}


//}//show only if bolHideDebit is false.. %>
  </table>
  
<!-- show here CRJ Pending for user to select what CRJ to create GJV.. -->
<%
if(vCRJPending != null && vCRJPending.size() > 0) {%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr><td align="center">
			<table width="70%" cellpadding="0" cellspacing="0" class="thinborder">
				<tr bgcolor="#DDDDDD" align="center" style="font-weight:bold">
					<td class="thinborder" width="35%">CRJ Number</td>
					<td class="thinborder" width="15%">Voucher Date</td>
					<td class="thinborder" width="35%">Cash On Hand</td>
					<td class="thinborder" width="15%">Select</td>
				</tr>
				<%
				int iCount= 0;
				while(vCRJPending.size() > 0) {%>
				<tr bgcolor="#CCFF66">
					<td class="thinborder"><%=vCRJPending.elementAt(1)%></td>
					<td class="thinborder"><%=vCRJPending.elementAt(2)%></td>
					<td class="thinborder"><%=vCRJPending.elementAt(3)%></td>
					<td class="thinborder" align="center"><input type="checkbox" name="crj_ref<%=iCount%>" value="<%=vCRJPending.elementAt(0)+","+vCRJPending.elementAt(1)%>">
					</td>
				</tr>
				<%++iCount;
				vCRJPending.remove(0);vCRJPending.remove(0);vCRJPending.remove(0);
				vCRJPending.remove(0);
				}%>
			</table>
			<input type="hidden" name="crj_max_disp" value="<%=iCount%>">
		</td></tr>
		<tr><td align="center" height="45">
			<input type="button" name="__X122" value=" Process CRJ Selected " style="font-size:14px; font-weight:bold; color:#CC0000; height:32px;border: 1px solid #FF0000;"
		 onClick="ProcessCRJ();">
		</td></tr>
	</table>
<%}
if(vCRJSelected != null && vCRJSelected.size() > 0) {%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		<td align="center" width="70%">
			<table width="80%" cellpadding="0" cellspacing="0" class="thinborder">
				<tr bgcolor="#DDDDDD" align="center" style="font-weight:bold">
					<td class="thinborder" width="35%">CRJ Number</td>
					<td class="thinborder" width="15%">Voucher Date</td>
					<td class="thinborder" width="35%">Cash On Hand</td>
				</tr>
				<%
				while(vCRJSelected.size() > 0) {%>
				<tr bgcolor="#CCFF66">
					<td class="thinborder"><%=vCRJSelected.elementAt(0)%></td>
					<td class="thinborder"><%=vCRJSelected.elementAt(1)%></td>
					<td class="thinborder"><%=vCRJSelected.elementAt(2)%></td>
					</td>
				</tr>
				<%
				vCRJSelected.remove(0);vCRJSelected.remove(0);vCRJSelected.remove(0);
				}%>
			</table>
		</td>
		<td align="center" style="font-size:24px; font-weight:bold">Total: <%=CommonUtil.formatFloat(dTotalCRJAmt, true)%></td>
		</tr>
	</table>

<%}%>

<%if(!bolHideDebit){//do not show debit entry also.. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFCCFF"> 
      <td height="28">&nbsp;</td>
      <td><strong><u><font size="3">DEBIT</font></u></strong></td>
      <td colspan="2" align="right" style="font-size:18px; font-weight:bold;">Total Debit: <%=CommonUtil.formatFloat(dTotalDebit, true)%>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Particular</td>
      <td colspan="2"><%
if(vEditInfo != null && WI.fillTextValue("is_debit").equals("1")) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("particular");
%>
      <textarea name="particular" rows="2" cols="70" class="textbox" style="font-size:11px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
<%
if(strPreparedToEdit.equals("1") && false){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Show when edit is clicked. </td>
      <td colspan="2"><input type="checkbox" name="checkbox3" value="checkbox">
        A/R FS &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <input type="checkbox" name="checkbox23" value="checkbox">
        A/R Student &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <input type="checkbox" name="checkbox222" value="checkbox">
        A/R Others</td>
    </tr>
<%}//show only if edit is clicked.%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td valign="top">Charged to </td>
      <td width="28%" valign="top">
<%
if(vEditInfo != null && WI.fillTextValue("is_debit").equals("1")) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("coa_index");

//I have to copy from ac_jv_pc directly.. 
//if(iJVType == 11 && strPreparedToEdit.equals("0"))
//	strErrMsg = " readonly";
//else	
//	strErrMsg = "";
%>	  <input name="coa_index" type="text" size="26" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('0','coa_index','document.form_.particular');"></td>
      <td width="51%"><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
<%
//charge to a project if this expense if for a project -- AUF ONLY.
//System.out.println(strJVType);
if(strIsCD.equals("1") && (!bolIsSchool || strSchCode.startsWith("AUF") || strSchCode.startsWith("DBTC")) && strJVType.equals("10")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:10px; color:#0000FF">
	  Charge to Project? 
<%
if(vEditInfo != null && WI.fillTextValue("is_debit").equals("1")) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("project_index");
%>	
	  <select name="project_index" style=" width:500px; font-size:10px;">
	  <option value="">xxxxxxxxxx Do not charge to Project xxxxxxxxxx</option>
<%=dbOP.loadCombo("PROJECT_MGMT_INDEX","PROJECT_CODE+' :: '+PROJECT_NAME"," from AC_PROJ_MGMT where is_valid = 1 and PROJECT_STATUS=1 order by project_code asc", strTemp, false)%>
	  </select>
	  </td>
    </tr>
    
<%}if(iJVType != 11){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Amount </td>
      <td colspan="2">
	<%
	if(vEditInfo != null && WI.fillTextValue("is_debit").equals("1")) 
		strTemp = (String)vEditInfo.elementAt(3);
	else	
		strTemp = WI.fillTextValue("amount");
	%>	  
		<input name="amount" type="text" size="12" maxlength="32" value="<%=strTemp%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'"
	   		onKeyUp="AllowOnlyFloat('form_','amount');"></td>
    </tr>
<%}else{
	if(iJVType == 11){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Petty Cash Reference #</td>
      <td colspan="2">
	  	<%if(vPettyCashCDPending != null){%>
			<select name="pc_select" onChange="UpatePCAmt();" style="font-size:11px;">
				<%strErrMsg = ""; String strIsSelected = "";
				strTemp = WI.fillTextValue("pc_select");
				for(int i =0; i < vPettyCashCDPending.size(); i += 2) {
					if(strTemp.equals(vPettyCashCDPending.elementAt(i))) {
						strErrMsg = (String)vPettyCashCDPending.elementAt(i+1);
						strIsSelected = " selected";
					}else
						strIsSelected = "";%>
						<option value="<%=vPettyCashCDPending.elementAt(i)%>"<%=strIsSelected%>><%=vPettyCashCDPending.elementAt(i)%></option>
				<%}if(strErrMsg.length() == 0)
					strErrMsg = (String)vPettyCashCDPending.elementAt(1);%>
			</select>
			<%for(int i =0; i < vPettyCashCDPending.size(); i += 2) {%>
			<input type="hidden" name="pc_amount<%=i/2%>" value="<%=vPettyCashCDPending.elementAt(i + 1)%>">
			<%}%>
	  <%}//only if vPettyCashCDPending is not null
	  else
	  	strErrMsg = "";%>
	  <input type="textbox" name="amount" value="<%=WI.getStrValue(strErrMsg)%>" class="textbox_noborder" readonly size="16" style="font-size:11px;">  	  
	  &nbsp;
	  <font size="1">Note: Click Save button to move all debit account of this PC-Reference to this Voucher</font>	  </td>
    </tr>

<%strErrMsg = "";}//show for iJVType == 11
}%>

    <tr> 
      <td height="10">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td colspan="2"><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');document.form_.is_debit.value='1';document.form_.set_focus.value='1'">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else if(WI.fillTextValue("is_debit").equals("1")){%>
<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3">
<%if(vRetResult != null && vRetResult.size() > 0) {%>	  
	  	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#CCDDDD">
<%for(int i = 0; i < vRetResult.size() && vRetResult.elementAt(4).equals("1");){%>
          <tr> 
            <td width="50%" height="20" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
            <td width="15%" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
            <td width="15%" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), true)%></td>
            <td width="6%" class="thinborder" align="center"><a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>','1');" style="font-size:11px; color:#0000aa">Edit</a></td>
            <td width="7%" class="thinborder" align="center"><a href="javascript:ConfirmDel('<%=vRetResult.elementAt(i)%>');" style="font-size:11px; color:#0000aa">Delete</a></td>
            <td width="7%" class="thinborder" align="center">
			<%if( iJVType == 11 || strIsCD.equals("2") || strJVType.equals("2") || strJVType.equals("3") ){%>&nbsp;<%}else{%>
				<a href="javascript:AddDetail('<%=vRetResult.elementAt(i)%>');" style="font-size:11px; color:#0000aa">Add Detail</a>
			<%}%></td>
          </tr>
<%
vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);

}//end of showing particular.
if(vRetResult.size() > 0 && vRetResult.elementAt(4).equals("0"))
	bolIsCreditCreated = true;
%>
        </table>
<%}else{%><font style="font-size:11px; font-weight:bold; color:#FF0000">No particular created yet</font><%}%>	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3"><input name="focus_debit" type="text" class="textbox_noborder" style="background-color:#FFFFFF" size="1" readonly=""></td>
    </tr>
<%//if(!strIsCD.equals("0") || !bolNewCreate) { //before CD was allowing mis matching.. now it is not.
if(!bolNewCreate) {
if(bolAllowEditCreditEntry) {%>
			<tr bgcolor="#99CCFF"> 
			  <td height="28">&nbsp;</td>
			  <td><strong><u><font size="3">CREDIT</font></u></strong></td>
			  <td colspan="2" align="right" style="font-size:18px; font-weight:bold;">Total Credit: <%=CommonUtil.formatFloat(dTotalCredit, true)%>&nbsp;</td>
			</tr>
			<tr> 
			  <td height="26">&nbsp;</td>
			  <td>Particular</td>
			  <td colspan="2">
		<%
		
		String strPrevParticular = null;
		String strRrevCOA = null;//for lighthouse, they are getting lazy, they want to load the previous debit info.. 
		
		if(vEditInfo != null && WI.fillTextValue("is_debit").equals("0")) 
			strTemp = (String)vEditInfo.elementAt(2);
		else	
			strTemp = WI.fillTextValue("particular_c");
		
		if((strTemp == null || strTemp.length() == 0) && strSchCode.startsWith("LHS") && strIsCD.equals("1") ) {
			//I need to find out the date one month prior to today's date.. 
			java.util.Calendar cal = java.util.Calendar.getInstance();
			cal.add(java.util.Calendar.MONTH, -1);
			strTemp = ConversionTable.convertTOSQLDateFormat(cal.getTime());
			strSQLQuery = "select particular, complete_code from AC_JV_DC "+
									" join ac_coa on (ac_coa.coa_index = ac_jv_dc.coa_index) "+ 
									" where is_debit = 0 and exists ( "+
											" select * from ac_jv where ac_jv.jv_index = ac_jv_dc.jv_index and is_cd = 1 "+
											" and jv_date > '"+strTemp+
									"') order by jv_index desc";
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) {
				strPrevParticular = rs.getString(1);
				strRrevCOA        = rs.getString(2);
			}
			rs.close();
			strTemp = strPrevParticular;
		}
		%>
			  <textarea name="particular_c" rows="2" cols="70" class="textbox" style="font-size:11px;"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
			</tr>
		<%
		if(false && strPreparedToEdit.equals("1")){%>
			<tr>
			  <td height="26">&nbsp;</td>
			  <td>Show when edit is clicked. </td>
			  <td colspan="2"><input type="checkbox" name="checkbox3" value="checkbox">
				A/R FS &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <input type="checkbox" name="checkbox23" value="checkbox">
				A/R Student &nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <input type="checkbox" name="checkbox222" value="checkbox">
				A/R Others</td>
			</tr>
		<%}//show only if edit is clicked.%>
			<tr> 
			  <td height="26">&nbsp;</td>
			  <td valign="top">Charged to </td>
			  <td valign="top">
		<%
		if(vEditInfo != null && WI.fillTextValue("is_debit").equals("0")) 
			strTemp = (String)vEditInfo.elementAt(1);
		else	
			strTemp = WI.fillTextValue("coa_index_c");
		if(strTemp.length() == 0 && strRrevCOA != null)
			strTemp = strRrevCOA;
			
		%>	  <input name="coa_index_c" type="text" size="22" maxlength="32" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			  onkeyUP="MapCOAAjax('0','coa_index_c','document.form_.particular_c');"></td>
			  <td><label id="coa_info_c" style="font-size:11px;"></label></td>
			</tr>
			
			<tr> 
			  <td height="25">&nbsp;</td>
			  <td>Amount </td>
			  <td colspan="2">
		<%
		if(vEditInfo != null && WI.fillTextValue("is_debit").equals("0")) 
			strTemp = (String)vEditInfo.elementAt(3);
		else if(!strIsCD.equals("0") && vJVDetail != null && vJVDetail.elementAt(0) != null)
			strTemp = (String)((Vector)vJVDetail.elementAt(0)).elementAt(7);
		else	
			strTemp = WI.fillTextValue("amount_c");
		double dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));
		if(dTemp < 0.001d && dTemp > -001d)
			strTemp = "";
		%>	  <input name="amount_c" type="text" size="12" maxlength="32" value="<%=strTemp%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','amount_c');style.backgroundColor='white'"
			   onKeyUp="AllowOnlyFloat('form_','amount_c');"></td>
			</tr>
			<tr> 
			  <td height="10">&nbsp;</td>
			  <td valign="bottom">&nbsp;</td>
			  <td colspan="2"><%if(iAccessLevel > 1) {
			if(strPreparedToEdit.equals("0")){%>
				<input type="submit" name="12" value=" Save Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
				 onClick="PageAction('1','');document.form_.is_debit.value='0';document.form_.set_focus.value='2'">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<%}else if(WI.fillTextValue("is_debit").equals("0")){%>
		<input type="submit" name="124" value=" Edit Info " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
				 onClick="PageAction('2','');">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<%}
		}%>
		<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
				 onClick="PageAction('','');"></td>
			</tr>
			<tr> 
			  <td>&nbsp;</td>
			  <td colspan="3">
		<%if(vRetResult != null && vRetResult.size() > 0) {%>	  
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#BFBFBF">
		<%for(int i = 0; i < vRetResult.size();){%>
				  <tr> 
					<td width="50%" height="20" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
					<td width="15%" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
					<td width="15%" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), true)%></td>
					<td width="6%" class="thinborder" align="center"><a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>','0');" style="font-size:11px; color:#0000aa">Edit</a></td>
					<td width="7%" class="thinborder" align="center"><a href="javascript:ConfirmDel('<%=vRetResult.elementAt(i)%>');" style="font-size:11px; color:#0000aa">Delete</a></td>
					<td width="7%" class="thinborder" align="center">
					<%if(strIsCD.equals("2") || strJVType.equals("2") || strJVType.equals("3") ){%>&nbsp;<%}else{%><a href="javascript:AddDetail('<%=vRetResult.elementAt(i)%>');" style="font-size:11px; color:#0000aa">Add Detail</a><%}%>			</td>
				  </tr>
		<%
		vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
		vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
		
		}//end of showing particular.%>
				</table>
		<%}else{%><font style="font-size:11px; font-weight:bold; color:#FF0000">No particular created yet</font><%}%></td>
			</tr>
<%}//do not show if bolAllowEditCreditEntry%>

    <tr> 
      <td height="26" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td valign="top"><br>Explanation</td>
      <td colspan="2">
<%
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("explanation");
%>
	  <textarea name="explanation" rows="6" cols="90" class="textbox" style="font-size:10px;"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td  width="3%"height="34">&nbsp;</td>
      <td width="18%" valign="top"><br>
      Remark</td>
      <td colspan="2">
<%
if(vJVInfo != null)
	strTemp = (String)vJVInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("remark");
%>
	  <textarea name="remark" rows="4" cols="90" class="textbox" style="font-size:10px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" valign="bottom">
	  <%if(iAccessLevel > 1) {%>
        <input type="submit" name="123" value=" Update Information " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="PageAction('5','');">
	  <%}%>	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><input name="focus_credit" type="text" class="textbox_noborder" style="background-color:#FFFFFF" size="1" readonly></td>
      <td colspan="2" style="font-size:14px; color:#0000FF; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>

<%	}//show the credit only after jv is created..
else if(!bolHideDebit && bolIsJVCRJ ) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><input name="focus_credit" type="text" class="textbox_noborder" style="background-color:#FFFFFF" size="1" readonly></td>
      <td colspan="2"style="font-size:24px; font-weight:bold; color:#FF3333">
	  <%if(bolIsCreditCreated){%>
	  	&nbsp;
	  <%}else{%>
	  	Note: Credit entry will automatically be created as CASH ON HAND</td>
	  <%}%>
    </tr>

<%} 

}//if (!bolIsJVLocked)%>
  </table>

<%}//bolHideDebit is false -- do not show debit block if CRJ is not selected and JV is for CRJ. %>

<%if(vJVDetail != null && vJVDetail.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="5" class="thinborder" style="font-size:10px; font-weight:bold" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td class="thinborder" style="font-size:10px; font-weight:bold">Print <%if(strIsCD.equals("2")){%>PC<%}else if(strIsCD.equals("1")){%>CD<%}else{%>JV<%}%> 
	    <%boolean bolPrint = true;
		//System.out.println("vJVInfo.elementAt(2) : "+vJVInfo.elementAt(2));
		//System.out.println("strIsCD : "+strIsCD);
		
		if(strSchCode.startsWith("CLDH") && !vJVInfo.elementAt(2).equals("1") && !strIsCD.equals("1"))
			bolPrint = false;
		if(bolPrint){%>		
		<a href="javascript:PrintJV();"><img src="../../../../images/print.gif" border="0"></a><%}else{%> - Disabled (Verify to Print)<%}%></td>
      <td height="25" colspan="4" align="right" class="thinborder" style="font-size:10px; font-weight:bold;">
	  <%if(strIsCD.equals("2")){%>&nbsp;<%}else{%>Print supporting Document
	  <a href="javascript:PrintSupportingDoc();"><img src="../../../../images/print.gif" border="0"></a><%}%></td>
    </tr>
    <tr bgcolor="#D9DFE1"> 
      <td height="27" colspan="5" class="thinborder" align="center" style="font-size:10px; font-weight:bold; color:#FF0000">
	  ::  VOUCHER FOR -:  <%=WI.getStrValue(strJVNumber)%> ::</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#99CCFF" class="thinborder" width="32%"><div align="center"><strong>DEBIT </strong></div></td>
      <td bgcolor="#FFCC99" class="thinborder" width="32%"><div align="center"><strong>CREDIT</strong></div></td>
      <td class="thinborder" width="15%" align="center">Explanation</td>
      <td class="thinborder" width="15%" align="center">Remarks</td>
      <td class="thinborder" width="6%" align="center">Edit</td>
    </tr>
<%
    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE
    Vector vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
String strBGRed = null;//must be red if credit/debit not matching.	
%><input type="hidden" name="jv_index" value="<%=vJVInfo.elementAt(0)%>">
<%//System.out.println(vJVDetail);
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") )///&& strIsCD.equals("0"))
		strBGRed = " bgcolor=red";
	else	
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;%>
     <tr<%=strBGRed%>>
      <td height="25" bgcolor="#99CCFF" class="thinborder" valign="top">
	  	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			<tr>
				<td width="60%" class="thinborder"><strong>Particular</strong></td>
				<td width="25%" class="thinborder"><strong>Account #</strong></td>
				<td width="15%" class="thinborder"><strong>Amount</strong></td>
			</tr>
			<%while(vJVDetail.size() > 0) {
				if(!vJVDetail.elementAt(3).equals(strTemp) || vJVDetail.elementAt(4).equals("0"))//if not debit or if not belong to same group.. break.
					break;%>
				<tr>
					<td width="60%" class="thinborder"><%=vJVDetail.elementAt(1)%></td>
					<td width="25%" class="thinborder"><%=vJVDetail.elementAt(0)%></td>
					<td width="15%" class="thinborder"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%></td>
				</tr>
			<%
			vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
			vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
		   }//System.out.println(vJVDetail);%>
		</table>	  </td>
      <td bgcolor="#FFCC99" class="thinborder" valign="top">
	  	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			<tr>
				<td width="60%" class="thinborder"><strong>Particular</strong></td>
				<td width="25%" class="thinborder"><strong>Account #</strong></td>
				<td width="15%" class="thinborder"><strong>Amount</strong></td>
			</tr>
			<%for(int q = 0; q < vJVDetail.size(); q += 5) {//while(vJVDetail.size() > 0) {
				if(!vJVDetail.elementAt(q + 3).equals(strTemp) || vJVDetail.elementAt(q + 4).equals("1"))//if not debit or if not belong to same group.. break.
					continue;%>
				<tr>
					<td width="60%" class="thinborder"><%=vJVDetail.elementAt(q + 1)%></td>
					<td width="25%" class="thinborder"><%=vJVDetail.elementAt(q)%></td>
					<td width="15%" class="thinborder"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(q + 2), true)%></td>
				</tr>
			<%
			vJVDetail.removeElementAt(q);vJVDetail.removeElementAt(q);vJVDetail.removeElementAt(q);
			vJVDetail.removeElementAt(q);vJVDetail.removeElementAt(q);
			q -= 5;}%>
		</table>	  </td>
      <td class="thinborder" valign="top" onDblClick="UpdateExplanation('<%=vGroupInfo.elementAt(i)%>');"><%=vGroupInfo.elementAt(i + 1)%></td>
      <td class="thinborder" valign="top"><%=WI.getStrValue(vGroupInfo.elementAt(i + 2),"&nbsp;")%></td>
      <td class="thinborder" align="center" valign="top"><%if(!bolIsJVLocked){%>
	  <br>
	  <a href="./journal_voucher_entry.jsp?jv_number=<%=strJVNumber%>&group_number=<%=vGroupInfo.elementAt(i)%>&jv_type=<%=strJVType%>&is_cd=<%=WI.fillTextValue("is_cd")%>">Edit</a>
	  <%}else{%>&nbsp;<%}%></td>
    </tr>
<%}//end of vGroupInfo%>
</table>


  <%}//end if vJVDetail display.. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="page_action_2">
<input type="hidden" name="new_jv_num">

<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<!-- Indicates debit info .. if debit is clicked is_debit = 1, if credit is clicked it is 0 -->
<input type="hidden" name="is_debit" value="<%=WI.fillTextValue("is_debit")%>">

<input type="hidden" name="jv_number" value="<%=strJVNumber%>">
<input type="hidden" name="set_focus" value="<%=WI.fillTextValue("set_focus")%>">

<%if(vJVInfo != null){%>
<input type="hidden" name="voucher_date_prev" value="<%=(String)vJVInfo.elementAt(1)%>">
<%}%>


<%

/*******************************this is jv type **********************************
 0 = others, 1 = scholarship, 2 = add/drop, 3 = enrollment, 4 = more to come. 8 = refund/debit/credit.
 10 = others - cd, 11 = Petty cash - cd.
**********************************************************************************/
%>
<input type="hidden" name="jv_type" value="<%=strJVType%>">
<input type="hidden" name="is_cd" value="<%=strIsCD%>">
<input type="hidden" name="update_payee_name">

<%if(strSchCode.startsWith("UDMC")){%>
<input type="hidden" name="remove_all">
<%}%>

<input type="hidden" name="show_supplier_list">
<input type="hidden" name="info_index_supplier">
<input type="hidden" name="page_action_supplier">
<input type="hidden" name="jv_liquidation" value="<%=WI.fillTextValue("jv_liquidation")%>">
<input type="hidden" name="jv_crj" value="<%=WI.fillTextValue("jv_crj")%>">
<input type="hidden" name="jv_crj_number_i" value="<%=strJVCRJNumberIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>