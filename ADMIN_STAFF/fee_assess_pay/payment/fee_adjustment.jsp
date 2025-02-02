<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment.jsp");
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
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"fee_adjustment.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT-FEE ADJUSTMENT",request.getRemoteAddr(),
														"fee_adjustment.jsp");
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

Vector vAdjustmentDtls = new Vector();
Vector vStudInfo = new Vector();
float fTotalTutionFee = 0;
float fDeduction = 0;
float fDiscount = 0;float fTutionFee=0;float fMiscFee=0;

//float fTotalAdjustment = 0f;

String strFAFAIndex = null;String strDiscount = null;
String[] astrCovnertDiscUnit={"Peso","%","unit"};
String[] astrConvertDisOn = {"Tuition Fee", "Misc Fee", "Free all", "Other Tuition Fee", "TUITION + MISC FEE","MISC FEE + OTH CHARGES",
								"OTH CHARGES","Tuition+Misc+Oth"};
String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
String[] astrConvertProper  = {""," (Preparatory)"," (Proper)"};
FAPmtMaintenance pmtMaintenance = new FAPmtMaintenance();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
FAFeeOperation fOperation = new FAFeeOperation();
FAPayment faPayment = new FAPayment();

boolean bolIsBasic = false;

boolean bolIsHavingDiscount = false;
String strSQLQuery = null;

String strStudID = WI.fillTextValue("stud_id");


if(WI.fillTextValue("sy_from").length() > 0) {
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP, (String)request.getSession(false).getAttribute("userId"),
												strStudID,WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
												WI.fillTextValue("semester"));
	//check if rfid is scanned.. 
	if(dbOP.strBarcodeID != null)
		strStudID = dbOP.strBarcodeID;

	if(vStudInfo == null) 
		strErrMsg = enrlAddDropSub.getErrMsg();
}
if(vStudInfo != null && vStudInfo.size() > 0){
	//check if this is called from basic.. 
	if(vStudInfo.elementAt(5).equals("0"))
		bolIsBasic = true;
	pmtMaintenance.setIsBasic(bolIsBasic); // set isBolbasic to true
	fOperation.setIsBasic(bolIsBasic); 
	fOperation.setIsCalledToComputeDiscount(true);

	//if auto apply, do not remove the subject from discount computation.
	vAdjustmentDtls = pmtMaintenance.viewOneFeeAdjustment(dbOP,request);//System.out.println(vAdjustmentDtls);
	if(vAdjustmentDtls != null && vAdjustmentDtls.size() > 0) {
		strSQLQuery = "select AUTO_APPLY_INDEX from FA_FEE_ADJUSTMENT_AUTOAPPLY where sy_from = "+WI.fillTextValue("sy_from")+
							" and semester = "+WI.fillTextValue("semester")+" and fa_fa_index_ = "+vAdjustmentDtls.elementAt(0)+" and is_valid = 1";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null) 
			fOperation.setIsCalledToComputeDiscount(false);
	}
	
	
	//get total tution fee for this student here.
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),false,WI.fillTextValue("sy_from"),
					WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	fMiscFee = 0;float fCompLabFee = 0;
	if(fTutionFee > 0)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),false,WI.fillTextValue("sy_from"),
					WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),false,WI.fillTextValue("sy_from"),
					WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),WI.fillTextValue("semester"));
	}
	fTotalTutionFee = fTutionFee+fMiscFee+fCompLabFee;	
	///calculate deduction here.
	if(vAdjustmentDtls != null)
	{
		
		strFAFAIndex = (String)vAdjustmentDtls.elementAt(0);
		strDiscount = (String)vAdjustmentDtls.elementAt(1);

fDeduction = fOperation.calAdjustmentRebate(dbOP,
			(String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"),
			WI.fillTextValue("sy_to"), (String)vStudInfo.elementAt(4),
			WI.fillTextValue("semester"), strFAFAIndex,false);//computes discount.
		//System.out.println(fDeduction);

/**
		if( vAdjustmentDtls.elementAt(3) != null && ((String)vAdjustmentDtls.elementAt(3)).compareTo("2") ==0) //free all.
			fDeduction = fTotalTutionFee;
		else if(strDiscount != null && strDiscount.trim().length() > 0)
		{
			fDiscount = Float.parseFloat(strDiscount);
			strTemp = (String)vAdjustmentDtls.elementAt(2);
			if(strTemp.compareTo("0") ==0)//amount.
				fDeduction = fDiscount;
			else//check what the discount is on == misc or tution fee.
			{
				if( ((String)vAdjustmentDtls.elementAt(3)).compareTo("0") ==0) { //on tution fee.
					//may be unit or may be percent.
					if(strTemp.compareTo("1") ==0)
						fDeduction = fTutionFee*fDiscount/100;
					else {
						fDeduction = fDiscount * fOperation.getRatePerUnit();
						//if deduction is more than tuition fee, i have to limit it to tuition fee.
						if(fDeduction > fTutionFee)
							fDeduction = fTutionFee;
					}
				}
				else if( ((String)vAdjustmentDtls.elementAt(3)).compareTo("1") ==0) //on Misc fee.
					fDeduction = fMiscFee*fDiscount/100;
			}
		}**/
	}
}

strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") ==0)
{
	if(!faPayment.saveAdjustment(dbOP,request))
		strErrMsg = faPayment.getErrMsg();
	else
		strErrMsg = "Adjustment added successfully.";
}
if(vStudInfo != null && vStudInfo.size() > 0) {	//check if already having discount.
	strTemp = "select adj_index from FA_STUD_PMT_ADJUSTMENT where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+
				WI.fillTextValue("semester")+" and is_valid = 1";
	if(dbOP.getResultOfAQuery(strTemp, 0) != null) 
		bolIsHavingDiscount = true;
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";


/**
Added Nov'07 to check if Discount application date already expired.. If so, do not allow application.
**/
boolean bolIsAllowedToApplyDiscount = false;
if(vStudInfo != null && vStudInfo.size() > 0){
	enrollment.SetParameter sP = new enrollment.SetParameter();
	if(!sP.isLockedGeneric(dbOP, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"), "2", (String)vStudInfo.elementAt(0), "0"))
		bolIsAllowedToApplyDiscount = true;
	else
		strErrMsg = "Scholarship Application is not open. Please contact System admin.";

	/**
	java.sql.ResultSet rs = null;
	//if nothing is set,, i have to move on. 
	strSQLQuery = "select count(*) from FA_STUD_PMT_ADJ_LAST_DATE where is_valid = 1";
	rs = dbOP.executeQuery(strSQLQuery);
	rs.next();
	int iCount = rs.getInt(1);
	if(iCount == 0)
		bolIsAllowedToApplyDiscount = true;
	else {
		strSQLQuery = "select ADJ_LD_INDEX from FA_STUD_PMT_ADJ_LAST_DATE where is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
				" and semester = "+WI.fillTextValue("semester")+" and LAST_DATE >='"+WI.getTodaysDate()+
				"' and (user_index is null or user_index = "+(String)vStudInfo.elementAt(0)+")";
	
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null)
			strErrMsg = "Please create last date of encoding scholarship/grant, Or create exception for this student ID. Contact System admin to Apply exception.";
		else	
			bolIsAllowedToApplyDiscount = true;
	}
	**/
	
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function FocusID() {
	document.fa_payment.stud_id.focus();
}
function AddRecord()
{
	document.fa_payment.addRecord.value = "1";
	document.fa_payment.hide_save.src = "../../../images/blank.gif";
	this.ReloadPage();
}
function ReloadPage()
{
	this.SubmitOnce("fa_payment");
}
function ShowFeeAdjDetail()
{
	var strStudId = document.fa_payment.stud_id.value;
	var strIsBasic = "&is_basic=0";
	<%if(bolIsBasic){%>
		strIsBasic = "&is_basic=1";
	<%}%>
	if(strStudId.length ==0)
		alert("Please enter student's id.");
	else {
		if(document.fa_payment.show_prev.checked)
			location = "./fee_adjustment_show_adjustment.jsp?stud_id="+escape(strStudId)+"&sy_from="+
				document.fa_payment.sy_from.value+"&sy_to="+document.fa_payment.sy_to.value+"&semester="+
				document.fa_payment.semester[document.fa_payment.semester.selectedIndex].value+strIsBasic;
		else
			location = "./fee_adjustment_show_adjustment.jsp?stud_id="+escape(strStudId)+strIsBasic;
	}
}
function ShowFeeAdjDetail2()
{
	var strStudId = document.fa_payment.stud_id.value;
	var strIsBasic = "&is_basic=0";
	<%if(bolIsBasic){%>
		strIsBasic = "&is_basic=1";
	<%}%>
	if(strStudId.length ==0)
		alert("Please enter student's id.");
	else {
		location = "./fee_adjustment_show_adjustment.jsp?stud_id="+escape(strStudId)+"&sy_from="+
			document.fa_payment.sy_from.value+"&sy_to="+document.fa_payment.sy_to.value+"&semester="+
			document.fa_payment.semester[document.fa_payment.semester.selectedIndex].value+strIsBasic;
	}
}
/*function ChangeAdjustmentLevel(strLevel)
{
	//check what level the adjustment is .
	var strTestLevel = 0;
	if(document.fa_payment.assistance0.selectedIndex > 0)
		strTestLevel = document.fa_payment.adjustment0.selectedIndex;
	else
		strTestLevel = -1;
	if(document.fa_payment.assistance0.selectedIndex > 0)
		strTestLevel = document.fa_payment.adjustment0.selectedIndex;
	if(document.fa_payment.assistance0.selectedIndex > 0)
		strTestLevel = document.fa_payment.adjustment0.selectedIndex;
	if(document.fa_payment.assistance0.selectedIndex > 0)
		strTestLevel = document.fa_payment.adjustment0.selectedIndex;


	document.fa_payment.adjustment_level.value=strTestLevel;
	ReloadPage();
}*/
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.fa_payment.stud_id.value;
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
	document.fa_payment.stud_id.value = strID;
	document.fa_payment.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.fa_payment.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<form name="fa_payment" action="./fee_adjustment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          FEE ADJUSTMENTS PAGE <%if(bolIsBasic){%> - FOR BASIC <%}%>::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="78%"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
      <td width="20%" align="right"><%if(strSchCode.startsWith("SPC")){%>
		<a href="./fee_adjustment_enrolling.jsp">
		  Student is enrolling
		</a>  
		<%}%>
	  </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Enter Student ID</td>
      <td width="11%" height="25"><input name="stud_id" type="text" size="16" value="<%=strStudID%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="7%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="61%">
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  
	  <%if(bolIsHavingDiscount) {%>
		  <div align="right" style="font-size:18px; font-weight:bold; color:#FF0000">
				Student is already having discount. <a href="javascript:ShowFeeAdjDetail2();">Click here</a> to view	
		  </div>
	      <%}%>
	  
	  </td>
    </tr>
    <tr >
      <td></td>
	  <td></td>
      <td colspan="3"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%" height="25">School Year/Sem</td>
      <td height="25" colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom"><input type="checkbox" name="show_prev" value="1">
        Show Previous Adjustment (NOTE: In view Previous adjustment, if any adjustment
        is removed, please adjust the outstanding balance in &lt;view all student
        ledger link&gt;</td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="43%" height="25">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%>
  	  <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
	  <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>">

	  </strong></td>
      <td  colspan="4" height="25">Course / Major:<strong> 
	  <%if(bolIsBasic){%>
	  	<%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(4)), false)%>
	  <%}else{%>
	  	<%=(String)vStudInfo.elementAt(2)%>/ <%=WI.getStrValue(vStudInfo.elementAt(3))%>
	  <%}%>
	  </strong></td>
    </tr>
<%if(!bolIsBasic){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year :<strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0"))]%>
	  <%=astrConvertProper[Integer.parseInt((String)vStudInfo.elementAt(14))]%></strong>
      </td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
<%}%>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td><font size="1">&nbsp;&nbsp;&nbsp;<a href="javascript:ShowFeeAdjDetail();"><img src="../../../images/show_list.gif" width="57" height="34" border="0"></a>click
        to show Fee Adjustments implemented for this student</font></td>
    </tr>
    <tr>
      <td colspan="2" height="25"><hr size="1"></td>
    </tr>
</table>
<%//applied to check if application is still allowed to process.. 
if(bolIsAllowedToApplyDiscount) {%>

	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="20%">Educational Assistance</td>
		  <td><strong>
	<%
	String strIsValid = "1";
	if(bolIsBasic)
		strIsValid = "2";
	%>
			<select name="assistance0" onChange="ReloadPage();">
			<option value="0">Select</option>
			  <%=dbOP.loadCombo("distinct FA_FEE_ADJUSTMENT.MAIN_TYPE_NAME","FA_FEE_ADJUSTMENT.MAIN_TYPE_NAME"," from FA_FEE_ADJUSTMENT where is_del=0 and is_valid="+strIsValid+" and "+
			  "tree_level=0 and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
			  " and (semester = "+WI.fillTextValue("semester")+" or semester is null) order by FA_FEE_ADJUSTMENT.MAIN_TYPE_NAME asc",
			  request.getParameter("assistance0"), false)%>
			</select>
			</strong></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Sub-assistance</td>
		  <td>
	<%
	strTemp = request.getParameter("assistance0");
	if(strTemp != null && strTemp.compareTo("0") != 0){
	strTemp = ConversionTable.replaceString(strTemp,"'","''");
	strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid="+strIsValid+" and tree_level=1 and MAIN_TYPE_NAME='"+strTemp+
	"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
	" and (semester = "+WI.fillTextValue("semester")+" or semester is null) order by FA_FEE_ADJUSTMENT.SUB_TYPE_NAME1 asc";
	%>
			<select name="assistance1" onChange="ReloadPage();">
			<option value="0">Select</option>
	<%=dbOP.loadCombo("FA_FEE_ADJUSTMENT.SUB_TYPE_NAME1","FA_FEE_ADJUSTMENT.SUB_TYPE_NAME1",strTemp,
		request.getParameter("assistance1"), false)%>
			</select>
	
			<%
			strTemp = request.getParameter("assistance1");
			if(strTemp != null && strTemp.compareTo("0") != 0){
			strTemp = ConversionTable.replaceString(strTemp,"'","''");
			strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid="+strIsValid+" and tree_level=2 and MAIN_TYPE_NAME='"+
			ConversionTable.replaceString(request.getParameter("assistance0"),"'","''")+"' and SUB_TYPE_NAME1='"+
			strTemp+"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
			  " and semester = "+WI.fillTextValue("semester")+" order by FA_FEE_ADJUSTMENT.SUB_TYPE_NAME2 asc";
			%>
					<select name="assistance2" onChange="ReloadPage();">
					<option value="0">Select</option>
					<%=dbOP.loadCombo("FA_FEE_ADJUSTMENT.SUB_TYPE_NAME2","FA_FEE_ADJUSTMENT.SUB_TYPE_NAME2",strTemp, request.getParameter("assistance2"), false)%>
					</select>
			<%}
	
			strTemp = request.getParameter("assistance2");
			if(strTemp != null && strTemp.compareTo("0") != 0){
			strTemp = ConversionTable.replaceString(strTemp,"'","''");
			strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid="+strIsValid+" and tree_level=3 and MAIN_TYPE_NAME='"+
			ConversionTable.replaceString(request.getParameter("assistance0"),"'","''")+"' and SUB_TYPE_NAME1='"+
			ConversionTable.replaceString(request.getParameter("assistance1"),"'","''")+"' and SUB_TYPE_NAME2='"+strTemp+
			"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
			  " and semester = "+WI.fillTextValue("semester")+" order by FA_FEE_ADJUSTMENT.SUB_TYPE_NAME3 asc";
			%>
	
			<select name="assistance3" onChange="ReloadPage();">
			<option value="0">Select</option>
			<%=dbOP.loadCombo("FA_FEE_ADJUSTMENT.SUB_TYPE_NAME3","FA_FEE_ADJUSTMENT.SUB_TYPE_NAME3",strTemp, request.getParameter("assistance3"), false)%>
			</select>
	<%}//for last condition.
	}%>
		  </td>
		</tr>
	  </table>

	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td width="2%" height="24">&nbsp;</td>
		  <td width="56%" height="24">&nbsp; </td>
		  <td width="23%" height="24">&nbsp;</td>
		  <td width="17%">&nbsp;</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td height="25">
			<%
		  if(vAdjustmentDtls != null && vAdjustmentDtls.size() > 0){%>
			Description : <strong><%=WI.getStrValue(vAdjustmentDtls.elementAt(6))%>/<%=WI.getStrValue(vAdjustmentDtls.elementAt(5))%></strong>
			<%}%>
		  </td>
		  <td height="24"><font size="1"><strong>TUITION FEE</strong></font></td>
		  <td><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTutionFee,true)%> </strong></font></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td height="25" class="thinborderALL">
			<%
		  if(vAdjustmentDtls != null && vAdjustmentDtls.size() > 0 && vAdjustmentDtls.elementAt(3) != null){
		  //check if there is anyother discounts. 
				Vector vTemp = pmtMaintenance.operateOnMultipleFeeAdjustment(dbOP, request, 4, strFAFAIndex);
				if(vTemp != null)
					strTemp = "<br>"+(String)vTemp.elementAt(0);
				else	
					strTemp = "&nbsp;";%>
				Exemptions/Discounts (AMOUNT / %) :<br>
				<%=strDiscount%> <%=astrCovnertDiscUnit[Integer.parseInt((String)vAdjustmentDtls.elementAt(2))]%>
				(<%=astrConvertDisOn[Integer.parseInt((String)vAdjustmentDtls.elementAt(3))]%>)
				<%
				///I have to get here addl misc and other charge discount.
				if(vAdjustmentDtls.elementAt(7) != null){%>
				<%=(String)vAdjustmentDtls.elementAt(7) +astrCovnertDiscUnit[Integer.parseInt((String)vAdjustmentDtls.elementAt(8))]%> (Misc)
				
				<%}if(vAdjustmentDtls.elementAt(9) != null){%>
				<%=(String)vAdjustmentDtls.elementAt(9) +astrCovnertDiscUnit[Integer.parseInt((String)vAdjustmentDtls.elementAt(10))]%> (Oth Charge) 
			<%}%>
				<%=strTemp%>
		<%}%>
		  </td>
		  <td height="25"><font size="1"><strong>MISCELLANEOUS FEE</strong></font></td>
		  <td height="25"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fMiscFee,true)%></strong></font></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td height="25">
			<%
		  if(fDeduction > 0f){%>
			Date Approved: <font size="1">
			<input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_of_payment")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('fa_payment.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
			</font>
			<%}%>
		  </td>
		  <td height="25"><font size="1"><strong>TOTAL TUITION FEE</strong></font></td>
		  <td height="25"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTotalTutionFee,true)%></strong></font></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td height="25">
			<%
		  if(fDeduction > 0f){%>
			Approval No. :&nbsp;&nbsp;
			<input name="approval_number" type="text" size="16" value="<%=WI.fillTextValue("approval_number")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<%}%>
		  </td>
		  <td height="25"><font size="1"><strong>DISCOUNT</strong></font></td>
		  <td height="25"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fDeduction,true)%></strong></font>
			<input type="hidden" name="fdeduction" value="<%=fDeduction%>"></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td height="25"><%
		  if(fDeduction > 0f){%>
		  Note: <br>
		  <textarea name="adjustment_note" class="textbox" rows="3" cols="50"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("adjustment_note")%></textarea>
		  <%}%>
		  </td>
		  <td height="25" colspan="2"><font size="1">&nbsp;</font><font size="1">-----------------------------------------------------
			</font></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td height="25">&nbsp;</td>
		  <td height="25"><font size="1"><strong>TOTAL AMOUNT PAYABLE</strong></font></td>
		  <td height="25"><font size="1"><strong>Php <%=CommonUtil.formatFloat(fTotalTutionFee-fDeduction,true)%></strong></font></td>
		</tr>
	  </table>
 
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	 <%if(iAccessLevel > 1){%>
		<tr>
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="18%" height="25"><div align="left"></div></td>
		  <td width="80%" height="25">
		  <%
		  if(fDeduction > 0 && fDeduction > 0){%>
		  <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
			<font size="1">click to save entries</font>
			<%}%></td>
		</tr>
	<%}//if iAccessLevel > 1%>
	  </table>
	  
<%}//if bolIsAllowedToApplyDiscount is true.. 

}//if vstudInfo is not null%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="adjustment_level" value="0">
<input type="hidden" name="fa_fa_index" value="<%=strFAFAIndex%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
