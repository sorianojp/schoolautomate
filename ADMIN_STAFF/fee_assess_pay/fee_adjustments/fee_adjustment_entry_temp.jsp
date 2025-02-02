<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
td{
	font-size:11px;
}

</style>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
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

function EditRecord(){
	document.fa_payment.addRecord.value ="2";
	document.fa_payment.hide_save.src = "../../../images/blank.gif";
	this.ReloadPage();	
}

function DeleteRecord(strInfoIndex){
	document.fa_payment.addRecord.value ="0";
	document.fa_payment.info_index.value= strInfoIndex;
	this.ReloadPage();	
}

function ReloadPage()
{
	this.SubmitOnce("fa_payment");
}


function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAFeeOperation,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	WebInterface WI = new WebInterface(request);

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	boolean bolAllowChange = WI.fillTextValue("allow_change").equals("1");
	
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment_entry_cpu.jsp");
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
														"fee_adjustment_entry_cpu.jsp");
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

String[] astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)//db error
{
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=dbOP.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}


//end of authenticaion code.

Vector vAdjustmentDtls = new Vector();
Vector vStudInfo = null;
Vector vRetResult = null;

float fTotalTutionFee = 0;
float fDeduction = 0;
float fDiscount = 0;
float fTutionFee = 0;
float fMiscFee = 0;
boolean bolIsTempStud = false;

//float fTotalAdjustment = 0f;

String strFAFAIndex = null;String strDiscount = null;
String[] astrCovnertDiscUnit={"Peso","%","unit"};
String[] astrConvertDisOn = {"Tuition Fee", "Misc Fee", "Free all", "Other Tuition Fee", 
							  "TUITION + MISC FEE","MISC FEE + OTH CHARGES", "OTH CHARGES","Tuition+Misc+Oth"};
								
String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
String[] astrConvertProper  = {""," (Preparatory)"," (Proper)"};

FAPmtMaintenance pmtMaintenance = new FAPmtMaintenance();
enrollment.Advising advising = new enrollment.Advising();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
FAFeeOperation fOperation = new FAFeeOperation();
enrollment.FAFeeAdjustmentCPU fAdjust = new enrollment.FAFeeAdjustmentCPU();
//FAPayment faPayment = new FAPayment();
String strYearLevel  = null;
boolean bolForceTempStudFalse = false; // set to true in case student is officially enrolled

if(WI.fillTextValue("sy_from").length() > 0 && 
	WI.fillTextValue("stud_id").length() > 0) {
	
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP, 
											(String)request.getSession(false).getAttribute("userId"),
											request.getParameter("stud_id"),
											WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
											WI.fillTextValue("semester"));
	
	if (vStudInfo == null) { // check if student is enrolling
		vStudInfo = advising.getStudInfo(dbOP,WI.fillTextValue("stud_id")); 

		if(vStudInfo == null) {
			strErrMsg = advising.getErrMsg();
		}
	}else{
		bolForceTempStudFalse = true;
	}
	
// put checking here.. in case CPU will ask that scholarship office be allowed
// to encode student even if advising is not yet available
}

if(vStudInfo != null && vStudInfo.size() > 0){

	vAdjustmentDtls = pmtMaintenance.viewOneFeeAdjustment(dbOP,request);

	
	//System.out.println(vAdjustmentDtls);
	
	//get total tution fee for this student here.
	if (bolForceTempStudFalse) {
		bolIsTempStud = false;
		strYearLevel = (String)vStudInfo.elementAt(4);
	}else{
		bolIsTempStud =  ((String)vStudInfo.elementAt(10)).equals("1");
		strYearLevel = (String)vStudInfo.elementAt(6);
	}
	
	fTutionFee = fOperation.calTutionFee(dbOP, (String)vStudInfo.elementAt(0),bolIsTempStud,
								WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), 
								strYearLevel,WI.fillTextValue("semester"));
					
	fMiscFee = 0;
	float fCompLabFee = 0;
	
	if(fTutionFee > 0)
	{
		fMiscFee 	= fOperation.calMiscFee(dbOP, (String)vStudInfo.elementAt(0),bolIsTempStud,
								WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), 
								strYearLevel,WI.fillTextValue("semester"));
								
		fCompLabFee = fOperation.calHandsOn(dbOP, (String)vStudInfo.elementAt(0),bolIsTempStud,
								WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), 
								strYearLevel,WI.fillTextValue("semester"));
	}
		
		fTotalTutionFee = fTutionFee+fMiscFee+fCompLabFee;	
	///calculate deduction here.
	if(vAdjustmentDtls != null)
	{
		
		strFAFAIndex = (String)vAdjustmentDtls.elementAt(0);
		strDiscount = (String)vAdjustmentDtls.elementAt(1);

		// update May 1, 2007 force fDeduction to 0 if Tuition = 0
		if (fTotalTutionFee < 1f) { 
			fDeduction = 0f;
		}else{ 
			fDeduction = fOperation.calAdjustmentRebate(dbOP,
				(String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"),
				WI.fillTextValue("sy_to"), strYearLevel,
				WI.fillTextValue("semester"), strFAFAIndex,false,bolIsTempStud);//computes discount.
		}
//		System.out.println(fDeduction);

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


strTemp = WI.fillTextValue("addRecord");
if(strTemp.equals("1"))
{
	if(fAdjust.operateOnTempAdjustment(dbOP,request,1) == null)
		strErrMsg = fAdjust.getErrMsg();
	else
		strErrMsg = "Adjustment added successfully.";
}else if (strTemp.equals("2")) 
{
	if(fAdjust.operateOnTempAdjustment(dbOP,request,2) == null)
		strErrMsg = fAdjust.getErrMsg();
	else
		strErrMsg = "Adjustment edited successfully.";
}else if (strTemp.equals("0"))
{
	if(fAdjust.operateOnTempAdjustment(dbOP,request,0) == null)
		strErrMsg = fAdjust.getErrMsg();
	else
		strErrMsg = "Adjustment removed successfully.";
}

Vector vRetEdit = null;
if (WI.fillTextValue("prepareToEdit").equals("1")){
	vRetEdit = fAdjust.operateOnTempAdjustment(dbOP,request,3);
}

if (vStudInfo != null) {
	vRetResult = fAdjust.operateOnTempAdjustment(dbOP,request,7);
}



%>
<form name="fa_payment" action="./fee_adjustment_entry_temp.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          FEE ADJUSTMENTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td height="25">Student/ Temporary ID</td>
      <td width="16%" height="25">
	 <% if (strPrepareToEdit.equals("1"))
		 	strTemp = "readonly";
		else
			strTemp = "";
	 %>
	  <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strTemp%>></td>
      <td width="5%" height="25">
<%if (!strPrepareToEdit.equals("1")) {%> 
	  <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
<%}%> 
	  </td>
      <td width="58%">
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="20%" height="25">School Year/Sem</td>
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
		  if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) {
		     if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <% }else{%>
          <option value="3">3rd Sem</option>
          <% }		  
		  } 
			if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%} %>
        </select> </td>
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
	  <input type="hidden" name="year_level" value="<%=strYearLevel%>">

	  </strong></td>
      <td  colspan="4" height="25">Course / Major:<strong> 
	  <% if (bolForceTempStudFalse){%>
		  <%=(String)vStudInfo.elementAt(2)%>
        <%=WI.getStrValue((String)vStudInfo.elementAt(3)," / ","","")%>	  	 
	  <%}else{%> 
	  <%=(String)vStudInfo.elementAt(7)%>
        <%=WI.getStrValue((String)vStudInfo.elementAt(8)," / ","","")%>
	  <%}%> 	
		
		</strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year :<strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue(strYearLevel,"0"))]%>
	  <%//=astrConvertProper[Integer.parseInt((String)vStudInfo.elementAt(14))]%></strong>
      </td>
      <td  colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2" height="25"><hr size="1"></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Educational Assistance</td>
      <td><strong>
<% strTemp = request.getParameter("assistance0");
	if (vRetEdit != null && !bolAllowChange) {
		strTemp = (String)vRetEdit.elementAt(0);
	}
%>
        <select name="assistance0" onChange="ReloadPage();">
		<option value="0">Select</option>
          <%=dbOP.loadCombo("distinct MAIN_TYPE_NAME","MAIN_TYPE_NAME",
		  		" from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and "+
				"tree_level=0 and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
				" and (semester = "+WI.fillTextValue("semester")+" or semester is null) order by FA_FEE_ADJUSTMENT.MAIN_TYPE_NAME asc",
		  strTemp, false)%>
        </select>
        </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Sub-assistance</td>
      <td>
<%
//strTemp = request.getParameter("assistance0");

if(strTemp != null && strTemp.trim().length() > 0  && !strTemp.equals("0")){
	strTemp = ConversionTable.replaceString(strTemp,"'","''");

	strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and tree_level=1 and MAIN_TYPE_NAME='"+strTemp+
	"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
	" and (semester = "+WI.fillTextValue("semester")+" or semester is null) order by SUB_TYPE_NAME1 asc";

	strTemp2 = request.getParameter("assistance1");
	
	if (vRetEdit != null && !bolAllowChange) 
		strTemp2 = (String)vRetEdit.elementAt(1);

	strTemp = dbOP.loadCombo("SUB_TYPE_NAME1","SUB_TYPE_NAME1",strTemp, strTemp2, false);

	if (strTemp != null && strTemp.length() > 0) { 
%>
        <select name="assistance1" onChange="ReloadPage();">
        <option value="0">Select</option>
		<%=strTemp%>
		</select>

		<%
	}
		strTemp = strTemp2;
		if(strTemp != null && strTemp.compareTo("0") != 0){
			strTemp = ConversionTable.replaceString(strTemp,"'","''");
			
			strTemp2 = request.getParameter("assistance0");
			if (vRetEdit != null)
				strTemp2 = (String)vRetEdit.elementAt(0);
	
	
		strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and tree_level=2 and MAIN_TYPE_NAME='"+
		ConversionTable.replaceString(strTemp2,"'","''")+"' and SUB_TYPE_NAME1='"+
		strTemp+"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
		  " and semester = "+WI.fillTextValue("semester")+" order by SUB_TYPE_NAME2 asc";
		  
		  	strTemp3 = request.getParameter("assistance2");
			if (vRetEdit != null)
				strTemp3 = (String)vRetEdit.elementAt(2);
		  
		 strTemp =  dbOP.loadCombo("SUB_TYPE_NAME2","SUB_TYPE_NAME2",strTemp, strTemp3, false);
		 
		 if (strTemp.length() > 0) { 
		  
		%>
				<select name="assistance2" onChange="ReloadPage();">
				<option value="0">Select</option>
				<%=strTemp%>
				</select>
		<%
		  } 		
		}

		strTemp = request.getParameter("assistance2");
		if(strTemp != null && strTemp.trim().length() > 0 && !strTemp.equals("0")){
			strTemp = ConversionTable.replaceString(strTemp,"'","''");
		
		strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and tree_level=3 and MAIN_TYPE_NAME='"+
		ConversionTable.replaceString(request.getParameter("assistance0"),"'","''")+"' and SUB_TYPE_NAME1='"+
		ConversionTable.replaceString(request.getParameter("assistance1"),"'","''")+"' and SUB_TYPE_NAME2='"+strTemp+
		"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
		  " and semester = "+WI.fillTextValue("semester")+" order by SUB_TYPE_NAME3 asc";
		  
		strTemp = dbOP.loadCombo("SUB_TYPE_NAME3","SUB_TYPE_NAME3",strTemp, request.getParameter("assistance3"), false);
		
		if (strTemp.length() > 0) { 
		%>

        <select name="assistance3" onChange="ReloadPage();">
    	<option value="0">Select</option>
		<%=strTemp%>
		</select>
<%    } // show only if there is a value;
   }//for last condition.
}%>
      </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="24">&nbsp;</td>
      <td width="56%" height="24">&nbsp; </td>
      <td width="5%">&nbsp;</td>
      <td width="18%" height="24">&nbsp;</td>
      <td width="17%">&nbsp;</td>
      <td width="3%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
        <%
	  if(vAdjustmentDtls != null && vAdjustmentDtls.size() > 0){%>
        Description : <strong><%=WI.getStrValue(vAdjustmentDtls.elementAt(6))%>
								<%=WI.getStrValue((String)vAdjustmentDtls.elementAt(5),"/","","")%></strong>
        <%}%>      </td>
      <td>&nbsp;</td>
      <td height="25"><strong><font size="1">TUITION FEE</font></strong></td>
      <td align="right"><strong>Php <%=CommonUtil.formatFloat(fTutionFee,true)%> </strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td rowspan="2" class="thinborderALL">
        <%Vector vTemp = null;
	  if(vAdjustmentDtls != null && vAdjustmentDtls.size() > 0 && vAdjustmentDtls.elementAt(3) != null){
	  //check if there is anyother discounts. 
		  	vTemp = pmtMaintenance.operateOnMultipleFeeAdjustment(dbOP, request, 4, strFAFAIndex);
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
	<%}%>      </td>
      <td>&nbsp;</td>
      <td height="25"><font size="1"><strong>MISCELLANEOUS FEE</strong></font></td>
      <td height="25" align="right"><strong>Php <%=CommonUtil.formatFloat(fMiscFee,true)%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25"><font size="1"><strong>TOTAL TUITION FEE</strong></font></td>
      <td height="25" align="right"><strong>Php <%=CommonUtil.formatFloat(fTotalTutionFee,true)%></strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25"><font size="1"><strong>ADJUSTMENTS</strong></font></td>
      <td height="25" align="right"><strong>Php <%=CommonUtil.formatFloat(fDeduction,true)%></strong>
        <input type="hidden" name="fdeduction" value="<%=fDeduction%>"></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" align="right"><font size="1">&nbsp;</font><font size="1">-----------------------------------------------------
        </font></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25"><font size="1"><strong>TOTAL AMOUNT PAYABLE</strong></font></td>
      <td height="25" align="right"><strong>Php <%=CommonUtil.formatFloat(fTotalTutionFee-fDeduction,true)%></strong></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 <%if(iAccessLevel > 1 && strDiscount != null && strDiscount.length() > 0){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%" height="25"><div align="left"></div></td>
      <td width="80%" height="25">
<% if (!strPrepareToEdit.equals("1")) {%>
	  <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
        <font size="1">click to save entries</font>
<%}else{%> 
        <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" alt="Edit Record" name="hide_save" width="40" height="26" border="0"></a> <font size="1">click to edit </font>
<%}%>	  </td>
    </tr>
<%}//if iAccessLevel > 1%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%

 if (vRetResult != null && vRetResult.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	  <tr>
  			<td height="25" colspan="4" bgcolor="#D6E0FE" class="thinborder"><div align="center"><strong>LIST OF APPLIED SCHOLARSHIPS</strong> </div></td>
	  </tr>
	  <tr>
	    <td width="54%" height="25" class="thinborder"><strong>&nbsp;SCHOLARSHIP TYPE</strong></td>
        <td width="17%" class="thinborder"><div align="center"><strong>AMOUNT </strong></div></td>
        <td width="22%" class="thinborder"><strong>&nbsp;STATUS</strong></td>
        <td width="7%" class="thinborder"> <strong>OPTION </strong></td>
    </tr>
<% 	boolean bolShowJVLine =true;
	boolean bolShowCancelLine = true;
	for (int j = 0; j < vRetResult.size() ; j += 12) {
		
	if (WI.getStrValue((String)vRetResult.elementAt(j+10)).equals("100") 
		 && bolShowJVLine ){  
		 
		bolShowJVLine =false;
	%> 
    <tr bgcolor="#F7F7F7">
      <td height="25" colspan="4" bgcolor="#F0F0F0" class="thinborder">&nbsp; <strong><font color="#FF0000">ADJUSTMENTS WITH JOURNAL VOUCHER</font></strong></td>
    </tr>
	<%}	if (WI.getStrValue((String)vRetResult.elementAt(j+10)).equals("101") 
		 && bolShowCancelLine ){
		 	bolShowCancelLine = false;
	%> 
    <tr bgcolor="#F7F7F7">
      <td height="25" colspan="4" bgcolor="#F0F0F0" class="thinborder">&nbsp; <strong><font color="#FF0000">CANCELLED ADJUSTMENTS</font></strong></td>
    </tr>
	<%}%>

    <tr>
	    <td height="25" class="thinborder">&nbsp;
		<%=(String)vRetResult.elementAt(j) + 
			WI.getStrValue((String)vRetResult.elementAt(j+1)," - " ,"","") +
			WI.getStrValue((String)vRetResult.elementAt(j+2)," - " ,"","") +
			WI.getStrValue((String)vRetResult.elementAt(j+3)," - " ,"","") +
			WI.getStrValue((String)vRetResult.elementAt(j+4)," - " ,"","") +
			WI.getStrValue((String)vRetResult.elementAt(j+5)," - " ,"","")%></td>
	    <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vRetResult.elementAt(j+6),"-")%>&nbsp;</div></td>
		<% 
			strTemp = "";
			if ((String)vRetResult.elementAt(j+10) != null)
					strTemp = " FOR JOURNAL VOUCHER";
								
			if ((String)vRetResult.elementAt(j+9) != null)
					strTemp = " ISSUED  WITH JV NO. " + (String)vRetResult.elementAt(j+9);

			if (WI.getStrValue((String)vRetResult.elementAt(j+7)).equals("1"))
					strTemp = " REJECTED";
		
			if (WI.getStrValue((String)vRetResult.elementAt(j+10)).equals("100") ||
				WI.getStrValue((String)vRetResult.elementAt(j+10)).equals("101"))
					strTemp = " JV NO : " + (String)vRetResult.elementAt(j+9);

			if (strTemp.length() == 0){
				strTemp = "NEW ";
			}
		%>
	    <td class="thinborder">&nbsp;<%=strTemp%></td>
	    <td class="thinborder">
<% if (iAccessLevel == 2 &&  (String)vRetResult.elementAt(j+8) != null) {%> 
		<a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(j+8)%>')">
			<img src="../../../images/delete.gif" border="0"></a>				
<%}else{%>NA<%}%>		</td>
    </tr>
<%}%> 
  </table>
  
<% } // list of adjustments set for student
} // vStudInfo  != null%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="">
<input type="hidden" name="adjustment_level" value="0">
<input type="hidden" name="fa_fa_index" value="<%=strFAFAIndex%>">
<input type="hidden" name="prepareToEdit" value="<%=WI.fillTextValue("prepareToEdit")%>">
<input type="hidden" name="view_only_voucher" value="<%=WI.fillTextValue("view_only_voucher")%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="allow_change" value = "1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
