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
a{
	text-decoration:none;
}
.style3 {font-size: 9px}
.textbox_noborder2 {
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;
	text-align:right;
	border: 0; 
}

</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
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

function EditRecord(strInfoIndex,strICounter){
	document.fa_payment.info_index.value=strInfoIndex;
	document.fa_payment.i_ctr.value=strICounter;
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

//  not needed for now.. staff may simply save without setting any item to ready for JV.. 
//	if (!bolOneSelected){
//		alert('Please select at least 1 student before moving');
//		return;
//	}
	document.fa_payment.show_all.value="1";

	document.fa_payment.page_action.value="5";
	this.SubmitOnce("fa_payment");	
}

function UpdateTotal(strCtrIndex){
	
	var dTotalValue = 0;
	
	dTotalValue = Number(eval('document.fa_payment.tuition_add'+strCtrIndex+'.value')) -
	Number(eval('document.fa_payment.tuition_drp'+strCtrIndex+'.value')) +
	Number(eval('document.fa_payment.misc_add'+strCtrIndex+'.value')) -
	Number(eval('document.fa_payment.misc_drp'+strCtrIndex+'.value')) +
	Number(eval('document.fa_payment.oth_add'+strCtrIndex+'.value')) -
	Number(eval('document.fa_payment.oth_drp'+strCtrIndex+'.value')) -
	Number(eval('document.fa_payment.disc_add'+strCtrIndex+'.value')) +
	Number(eval('document.fa_payment.disc_drp'+strCtrIndex+'.value')) ;
	
	eval('document.fa_payment.adjust_amt'+strCtrIndex+'.value = ' + truncateFloat(dTotalValue,2,false));
	
}


</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeAdjustmentCPU,java.util.Vector" %>
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
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","add_drop_entry.jsp");
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
														"add_drop_entry.jsp");
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

//Vector vAdjustmentDtls = new Vector();



float fTotalTutionFee = 0;
float fDeduction = 0;
float fDiscount = 0;
float fTutionFee = 0;
float fMiscFee = 0;
boolean bolIsTempStud = false;

//float fTotalAdjustment = 0f;

String strFaFaIndex = null;String strDiscount = null;

int iCtr = 0;
FAFeeAdjustmentCPU fAdjust = new FAFeeAdjustmentCPU();
Vector vRetResult  = null;

String strPageAction = WI.fillTextValue("page_action");
if (strPageAction.equals("5")){ // update student data

	if (fAdjust.operateOnTempAddDrop(dbOP,request,5) != null)
		strErrMsg = " Student adjustment record(s) updated successfully";
	else
		strErrMsg = fAdjust.getErrMsg();
}


if (WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0) {
//	System.out.println(" here");
	vRetResult =  fAdjust.operateOnTempAddDrop(dbOP,request,4);
}




%>
<form name="fa_payment" action="./add_drop_entry_view.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          FEE ADJUSTMENTS PAGE ( ADD/ DROP SUBJECTS)::::</strong></font></div></td>
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
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  
<% 
	String strTotalAmount = null;
	if (vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("show_all").equals("1")) { 
%>   

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="12%" rowspan="2" class="thinborder"><strong><font size="1">&nbsp;STUD ID</font></strong></td>
      <td width="30%" rowspan="2" class="thinborder"><strong><font size="1">&nbsp;STUDENT NAME</font></strong></td>
      <td width="9%" rowspan="2" class="thinborder"><strong><font size="1">COURSE &amp; YR</font></strong></td>
      <td height="12" colspan="2" class="thinborder"><div align="center"><strong><font size="1">TUITION</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong><font size="1">MISC</font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong><font size="1">OTH CHAR </font></strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong><font size="1">DISC</font></strong></div></td>
      <td width="7%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
      <td rowspan="2" class="thinborder"><strong><font size="1">SEL</font></strong></td>
    </tr>
    <tr>
      <td width="5%" height="12" class="thinborder"><strong><font size="1">ADD</font></strong></td>
      <td width="6%" class="thinborder"><strong><font size="1">DROP</font></strong></td>
      <td width="5%" height="12" class="thinborder"><strong><font size="1">ADD</font></strong></td>
      <td width="5%" class="thinborder"><strong><font size="1">DROP</font></strong></td>
      <td width="5%" height="12" class="thinborder"><strong><font size="1">ADD</font></strong></td>
      <td width="5%" class="thinborder"><strong><font size="1">DROP</font></strong></td>
      <td width="4%" height="12" class="thinborder"><strong><font size="1">ADD</font></strong></td>
      <td width="4%" class="thinborder"><strong><font size="1">DROP</font></strong></td>
    </tr>
	
<% 	String strTRBGColor = "";
	for(int i = 0; i < vRetResult.size(); i+=20, ++iCtr){
		strTRBGColor = "";
		if (((String)vRetResult.elementAt(i+18)).equals("1")){
			strTRBGColor =  "bgcolor=\"#EFEFEF\"";
		}
%>
    <tr <%=strTRBGColor%>>
      <td height="25" class="thinborder">
	  <font size="1"><%=(String)vRetResult.elementAt(i+19)%></font>
	  <input type="hidden" name="fee_hist_adj_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i)%>">
	  <input type="hidden" name="is_locked<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+18)%>">	  
	  
	        </td>
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3) + 
	  		WI.getStrValue((String)vRetResult.elementAt(i+4), "(",")","") + 
			WI.getStrValue((String)vRetResult.elementAt(i+5), " ","","")%></font></td>

      <td height="25" class="thinborder">
	  <input type="hidden" name="tuition_add_o<%=iCtr%>"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+9),",","")%>">

	  <input name="tuition_add<%=iCtr%>" type="text" class="textbox_noborder2" 
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+9),",","")%>" size="6"
	  onKeyUp="AllowOnlyFloat('fa_payment','tuition_add<%=iCtr%>');UpdateTotal(<%=iCtr%>)"
	  onBlur="AllowOnlyFloat('fa_payment','tuition_add<%=iCtr%>');style.backgroundColor='white'">
	  </td>

      <td height="25" class="thinborder">
	  <input type="hidden" name="tuition_drp_o<%=iCtr%>"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+10),",","")%>">

	  <input name="tuition_drp<%=iCtr%>" type="text" class="textbox_noborder2"
	  onFocus="style.backgroundColor='#D3EBFF'" size="6"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+10),",","")%>" 
	  onKeyUp="AllowOnlyFloat('fa_payment','tuition_drp<%=iCtr%>');UpdateTotal(<%=iCtr%>)"
	  onBlur="AllowOnlyFloat('fa_payment','tuition_drp<%=iCtr%>');style.backgroundColor='white'">
	  </td>

      <td height="25" class="thinborder">
	  <input type="hidden" name="misc_add_o<%=iCtr%>"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+15),",","")%>">

	  <input name="misc_add<%=iCtr%>" type="text" class="textbox_noborder2" 
	  onFocus="style.backgroundColor='#D3EBFF'" size="6"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+15),",","")%>" 
 	  onKeyUp="AllowOnlyFloat('fa_payment','misc_add<%=iCtr%>');UpdateTotal(<%=iCtr%>)"	
	  onBlur="AllowOnlyFloat('fa_payment','misc_add<%=iCtr%>');style.backgroundColor='white'" >
	  </td>

      <td height="25" class="thinborder">
	  <input type="hidden" name="misc_drp_o<%=iCtr%>"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+16),",","")%>">	  

	  <input name="misc_drp<%=iCtr%>" type="text" class="textbox_noborder2" 
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+16),",","")%>" size="6"
 	  onKeyUp="AllowOnlyFloat('fa_payment','misc_drp<%=iCtr%>');UpdateTotal(<%=iCtr%>)"	
	  onBlur="AllowOnlyFloat('fa_payment','misc_drp<%=iCtr%>');style.backgroundColor='white'">
	  </td>

      <td height="25" class="thinborder">
	  <input type="hidden" name="oth_add_o<%=iCtr%>"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+13),",","")%>">	  

	  <input name="oth_add<%=iCtr%>" type="text" class="textbox_noborder2" 
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+13),",","")%>" size="6"
 	  onKeyUp="AllowOnlyFloat('fa_payment','oth_add<%=iCtr%>');UpdateTotal(<%=iCtr%>)"
	  onBlur="AllowOnlyFloat('fa_payment','oth_add<%=iCtr%>');style.backgroundColor='white'" >
	  </td>
	  
      <td height="25" class="thinborder">
	  <input type="hidden" name="oth_drp_o<%=iCtr%>"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+14),",","")%>">	  

	  <input name="oth_drp<%=iCtr%>" type="text" class="textbox_noborder2" 
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+14),",","")%>" size="6"
 	  onKeyUp="AllowOnlyFloat('fa_payment','oth_drp<%=iCtr%>');UpdateTotal(<%=iCtr%>)"
	  onBlur="AllowOnlyFloat('fa_payment','oth_drp<%=iCtr%>');style.backgroundColor='white'" >
	  </td>

      <td height="25" class="thinborder">
	  <input type="hidden" name="disc_add_o<%=iCtr%>"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+11),",","")%>">	  

	  <input name="disc_add<%=iCtr%>" type="text" class="textbox_noborder2"
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+11),",","")%>" size="5"
 	  onKeyUp="AllowOnlyFloat('fa_payment','disc_add<%=iCtr%>');UpdateTotal(<%=iCtr%>)"
	  onBlur="AllowOnlyFloat('fa_payment','disc_add<%=iCtr%>');style.backgroundColor='white'">
	  </td>

      <td height="25" class="thinborder">
	  <input type="hidden" name="disc_drp_o<%=iCtr%>"
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+12),",","")%>">	  

	  <input name="disc_drp<%=iCtr%>" type="text" class="textbox_noborder2" 
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  value="<%=ConversionTable.replaceString((String)vRetResult.elementAt(i+12),",","")%>" size="5"
 	  onKeyUp="AllowOnlyFloat('fa_payment','disc_drp<%=iCtr%>');UpdateTotal(<%=iCtr%>)"
	  onBlur="AllowOnlyFloat('fa_payment','disc_drp<%=iCtr%>');style.backgroundColor='white'" ></td>

      <td width="7%" height="25" class="thinborder">
	<%   
		double dTotal = (double)(Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+9),",","")) -  //tuition 
						Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+10),",","")) - 
						Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+11),",","")) + // disc
						Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+12),",","")) +  
						Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+13),",","")) - // other
						Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+14),",","")) +
						Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+15),",","")) -  // misc
						Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+16),",","")));

	%>

	  <input name="adjust_amt<%=iCtr%>" type="text" class="textbox_noborder2" 
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  value="<%=ConversionTable.replaceString(CommonUtil.formatFloat(dTotal,true),",","")%>" readonly="yes"
	  size="8" onBlur="style.backgroundColor='white'" ></td>
      <td width="3%" height="25" class="thinborder">
	  <% if (!((String)vRetResult.elementAt(i+18)).equals("2")) {%> 	  
	  	<input type="checkbox" name="checkbox<%=iCtr%>" value="1">
	  <%}%>&nbsp;
	  </td>
    </tr>
<%
	} // end for loop
%>
  </table>
<%}%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="13" align="center">&nbsp;</td>
    </tr>
<% if (vRetResult  != null && vRetResult.size() > 0) {%> 
    <tr>
      <td height="25" colspan="13" align="center"><a href="javascript:MoveToVoucher();"><img src="../../../images/save.gif" alt="Save For Voucher" width="48" height="28" border="0"></a><font size="1">save items for voucher </font></td>
    </tr>
<%}%>
    <tr>
      <td height="18" colspan="13">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="max_display" value="<%=iCtr%>">
<input type="hidden" name="page_action">
<input type="hidden" name="show_all" value="">
<input type="hidden" name="i_ctr">
<input type="hidden" name="show_only_for_jv" value="<%=WI.fillTextValue("show_only_for_jv")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
