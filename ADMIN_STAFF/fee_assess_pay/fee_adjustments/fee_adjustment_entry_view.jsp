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
.style3 {font-size: 9px}
</style>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage()
{
	document.fa_payment.page_action.value="";	
	document.fa_payment.show_all.value="";
	this.SubmitOnce("fa_payment");
}

function ShowAll(){
	document.fa_payment.page_action.value="";
	document.fa_payment.show_all.value="1";
	this.SubmitOnce("fa_payment");
	
}

function ReloadType(){
	document.fa_payment.page_action.value="";
	document.fa_payment.fa_fa_index.value="";
	this.SubmitOnce("fa_payment");
}

function MoveToVoucher(){
	var iMaxDisplay = Number(document.fa_payment.max_display.value);
	var bolOneSelected  = false;
	for (var  i = 0; i < iMaxDisplay; ++i){
		if (eval('document.fa_payment.checkbox'+i+'.checked')) {
			bolOneSelected = true;
			break;
		}
	}

	if (!bolOneSelected){
		alert('Please select at least 1 student before moving');
		return;
	}
	

	document.fa_payment.page_action.value="8";
	this.SubmitOnce("fa_payment");	
}

function DeleteRecord(strInfoIndex){
	document.fa_payment.page_action.value="5";
	document.fa_payment.info_index.value=strInfoIndex;
	this.SubmitOnce("fa_payment");	
}

function ViewUpdate(strInfoIndex,strStudID){
	
	var pgLoc = "./fee_adjustment_entry_temp.jsp?stud_id=" + strStudID+
	"&sy_from=" +document.fa_payment.sy_from.value+"&sy_to="+document.fa_payment.sy_to.value+
	"&semester="+document.fa_payment.semester[document.fa_payment.semester.selectedIndex].value +
	"&info_index=" + strInfoIndex+"&prepareToEdit=1";
	
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAFeeOperation,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	WebInterface WI = new WebInterface(request);

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
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
														"fee_adjustment.jsp");
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


float fTotalTutionFee = 0;
float fDeduction = 0;
float fDiscount = 0;
float fTutionFee = 0;
float fMiscFee = 0;
boolean bolIsTempStud = false;

int iCtr = 0;

//float fTotalAdjustment = 0f;

String strFaFaIndex = null;String strDiscount = null;
String[] astrCovnertDiscUnit={"Peso","%","unit"};
String[] astrConvertDisOn = {"Tuition Fee", "Misc Fee", "Free all", "Other Tuition Fee", 
							  "TUITION + MISC FEE","MISC FEE + OTH CHARGES", "OTH CHARGES","Tuition+Misc+Oth"};
								
String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
String[] astrConvertProper  = {""," (Preparatory)"," (Proper)"};


FAPmtMaintenance pmtMaintenance = new FAPmtMaintenance();

vAdjustmentDtls = pmtMaintenance.viewOneFeeAdjustment(dbOP,request);

if (vAdjustmentDtls != null && vAdjustmentDtls.size() > 0) {
	strDiscount = (String)vAdjustmentDtls.elementAt(1);
	strFaFaIndex = (String)vAdjustmentDtls.elementAt(0);
}

enrollment.FAFeeAdjustmentCPU fAdjust = new enrollment.FAFeeAdjustmentCPU();
Vector vRetResult  = null;

String strPageAction = WI.fillTextValue("page_action");
if (strPageAction.equals("5")){ // reject student
	if (fAdjust.operateOnTempAdjustment(dbOP,request,5) != null)
		strErrMsg = " Student removed from the list";
	else
		strErrMsg = fAdjust.getErrMsg();
}else if(strPageAction.equals("8")) { // set amount for voucher
	if (fAdjust.operateOnTempAdjustment(dbOP,request,8) != null)
		strErrMsg = " Student(s) moved to list for voucher";
	else
		strErrMsg = fAdjust.getErrMsg();
}


if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0) {
	vRetResult =  fAdjust.operateOnTempAdjustment(dbOP,request,4);
}

%>
<form name="fa_payment" action="./fee_adjustment_entry_view.jsp" method="post">
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
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%" height="25">School Year/Sem</td>
      <td width="30%" height="25"><%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fa_payment","sy_from","sy_to")'>
-
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
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
</select></td>
      <td width="48%">
	  <a href="javascript:ShowAll();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  
<% if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Educational Assistance</td>
      <td><strong>
        <select name="assistance0" onChange="ReloadPage();">
		<option value="0">Select</option>
          <%=dbOP.loadCombo("distinct MAIN_TYPE_NAME","MAIN_TYPE_NAME"," from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and "+
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

if(strTemp != null && strTemp.trim().length() > 0  && strTemp.compareTo("0") != 0){
strTemp = ConversionTable.replaceString(strTemp,"'","''");

strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and tree_level=1 and MAIN_TYPE_NAME='"+strTemp+
"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
" and (semester = "+WI.fillTextValue("semester")+" or semester is null) order by SUB_TYPE_NAME1 asc";

	strTemp = dbOP.loadCombo("SUB_TYPE_NAME1","SUB_TYPE_NAME1",strTemp,
	request.getParameter("assistance1"), false);

	if (strTemp != null && strTemp.length() > 0) { 
%>
        <select name="assistance1" onChange="ReloadPage();">
        <option value="0">Select</option>
		<%=strTemp%>
		</select>

		<%
	}
		strTemp = request.getParameter("assistance1");
		if(strTemp != null && strTemp.compareTo("0") != 0){
		strTemp = ConversionTable.replaceString(strTemp,"'","''");
		strTemp = " from FA_FEE_ADJUSTMENT where is_del=0 and is_valid=1 and tree_level=2 and MAIN_TYPE_NAME='"+
		ConversionTable.replaceString(request.getParameter("assistance0"),"'","''")+"' and SUB_TYPE_NAME1='"+
		strTemp+"' and sy_from="+WI.fillTextValue("sy_from")+" and sy_to = "+WI.fillTextValue("sy_to")+
		  " and semester = "+WI.fillTextValue("semester")+" order by SUB_TYPE_NAME2 asc";
		  
		 strTemp =  dbOP.loadCombo("SUB_TYPE_NAME2","SUB_TYPE_NAME2",strTemp, request.getParameter("assistance2"), false);
		 
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
      <td width="11%" height="25">&nbsp;</td>
      <td width="74%" height="25">
        <% if(vAdjustmentDtls != null && vAdjustmentDtls.size() > 0){%>
        Description : <strong><%=WI.getStrValue(vAdjustmentDtls.elementAt(6))%>
								<%=WI.getStrValue((String)vAdjustmentDtls.elementAt(5),"/","","")%></strong>
        <%}%>	  </td>
      <td width="15%">&nbsp;</td>
    </tr>
    <tr>
      <td height="50">&nbsp;</td>
      <td class="thinborderALL">
   &nbsp;
   <%Vector vTemp = null;
	  if(vAdjustmentDtls != null && vAdjustmentDtls.size() > 0 && vAdjustmentDtls.elementAt(3) != null){
	  
	  //check if there is anyother discounts. 
		  	vTemp = pmtMaintenance.operateOnMultipleFeeAdjustment(dbOP, request, 4, strFaFaIndex);
			if(vTemp != null)
				strTemp = (String)vTemp.elementAt(0);
			else	
				strTemp = "&nbsp;";%>
			Exemptions/Discounts (AMOUNT / %) :<br>
			&nbsp;<%=strDiscount%> <%=astrCovnertDiscUnit[Integer.parseInt((String)vAdjustmentDtls.elementAt(2))]%>
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
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  
<%} // if WI.fillTextValue ("sy_from").length() > 0 

	String strTotalAmount = null;
	if (vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("show_all").equals("1")) { 
	strTotalAmount = (String)vRetResult.elementAt(0);	
%>   

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="11%" height="25">Account No : </td>
      <td width="89%" height="25"><input name="account_no" type="text" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("account_no")%>" size="16">	  </td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="13%" height="25"><strong>&nbsp;STUDENT ID</strong></td>
      <td width="30%"><strong>&nbsp;STUDENT NAME</strong></td>
      <td width="18%"><strong>COURSE &amp; YEAR</strong></td>
      <td width="20%"><strong>ACTUAL AMOUNT </strong></td>
      <td width="4%"><strong>SEL</strong></td>
      <td colspan="2"><div align="center"><strong>OPTIONS</strong></div></td>
    </tr>
	
<% 	
	String strReadyForJV = "0";	
	for(int i = 1; i < vRetResult.size(); i+=12, ++iCtr){ 
	
	if (!strReadyForJV.equals(WI.getStrValue((String)vRetResult.elementAt(i+11),"0"))) {
		strReadyForJV =(String)vRetResult.elementAt(i+11); 
%>
    <tr>
      <td height="25" colspan="7" bgcolor="#EFEFF8"><strong>  FOR JOURNAL VOUCHER : </strong></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;<%=(String)vRetResult.elementAt(i+2)%>
	  <input type="hidden" name="tmp_adjust_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+10)%>">	  </td>
      <td height="25">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td height="25">&nbsp;
	  <%=(String)vRetResult.elementAt(i+3) + 
	  		WI.getStrValue((String)vRetResult.elementAt(i+4), " ","","") + 
			WI.getStrValue((String)vRetResult.elementAt(i+5), " ","","")%></td>
      <td height="25">&nbsp;
	  <input name="amount<%=iCtr%>" type="text" value="<%=(String)vRetResult.elementAt(i+6)%>" 
	  	size="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyFloat('fa_payment','amount<%=iCtr%>');" 
		onKeyUp="AllowOnlyFloat('fa_payment','amount<%=iCtr%>')">	  </td>

      <td height="25"><input type="checkbox" name="checkbox<%=iCtr%>" value="1">      </td>
      <td width="8%" height="25">
	 <a href="javascript:ViewUpdate('<%=(String)vRetResult.elementAt(i+10)%>',
	 									'<%=(String)vRetResult.elementAt(i+2)%>')">
	  <img src="../../../images/update.gif" alt="Update the Scholarship Record" 
	  	width="60" height="26" border="0"></a></td>
      <td width="7%">
	 <% if (iAccessLevel == 2) {%>
	    <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i+10)%>')">
	  	<img src="../../../images/delete.gif" alt="Delete Scholarship Record" 
			width="55" height="28" border="0"></a>
	 <%}else{%>NA<%}%>		</td>
    </tr>
<%
	} // end for loop
%>

<% if (Float.parseFloat(WI.getStrValue(ConversionTable.replaceString(strTotalAmount,",",""),"0"))  > 0f) { %>
    <tr>
      <td height="25" align="center" bgcolor="#F4F4F4">&nbsp;</td>
      <td height="25" colspan="2" align="right" bgcolor="#F4F4F4"><strong>TOTAL AMOUNT FOR JOURNAL VOUCHER:</strong></td>
      <td height="25" align="center" bgcolor="#F4F4F4">&nbsp;<font color="#FF0000" size="2"><strong><%=strTotalAmount%></strong></font></td>
      <td height="25" align="center" bgcolor="#F4F4F4">&nbsp;</td>
      <td height="25" align="center" bgcolor="#F4F4F4">&nbsp;</td>
      <td height="25" align="center" bgcolor="#F4F4F4">&nbsp;</td>
    </tr>
<%
	}
%> 
    <tr>
      <td height="25" colspan="7" align="center"><a href="javascript:MoveToVoucher();"><img src="../../../images/save.gif" alt="Save For Voucher" width="48" height="28" border="0"></a><span class="style3">save items for voucher </span></td>
    </tr>
    <tr>
      <td height="18" colspan="7">&nbsp;</td>
    </tr>
  </table>
<%}%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="fa_fa_index" value="<%=strFaFaIndex%>">
<input type="hidden" name="info_index">
<input type="hidden" name="max_display" value="<%=iCtr%>">
<input type="hidden" name="page_action">
<input type="hidden" name="show_all" value="">
<input type="hidden" name="show_only_for_jv" value="<%=WI.fillTextValue("show_only_for_jv")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
