<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.proceedClicked.value = "1";
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function reloadPage(){
	document.form_.proceedClicked.value = "1";
	document.form_.pageReloaded.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce('form_');
}

function UpdateATC(){	
	var loadPg = "update_atc.jsp?opner_form_name=form_&opner_form_field=atc_index";
	var win=window.open(loadPg,"UpdateCity",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce('form_');
}
function Cancel(strYearOf) {
	location = "create_schedule5_entries.jsp?year_of="+strYearOf;
}

function UpdateToZero(strTextName){
	if(eval('document.form_.'+strTextName+'.value.length') == 0){		
		eval('document.form_.'+strTextName+'.value= "0"');
	}	
}

function goback(strYearOf){
	location = "schedule_4.jsp?year_of="+strYearOf;
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function ClearFields(){
	document.form_.last_name.value = "";
	document.form_.first_name.value = "";
	document.form_.middle_name.value = "";
	document.form_.tin.value = "";
	document.form_.payment.value = "";
}
-->
</script>

<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./report_schedule5_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","create_schedule5_entries.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"create_schedule5_entries.jsp");
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

ReportPayroll AtcCode = new ReportPayroll(request);
Vector vAtcDetails = null;
Vector vEditInfo = null;
Vector vRetResult = null;

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strClassification = null;
String strAtcIndex = WI.fillTextValue("atc_index");
int iSearchResult  = 0;

  if (WI.fillTextValue("proceedClicked").length() > 0)	{
	if(strPageAction.length() > 0) {
	  if(AtcCode.operateOnFinalTaxPayees(dbOP, Integer.parseInt(strPageAction)) != null ) 
		{
		  strErrMsg = "Operation successful.";
		  strPrepareToEdit = "0";
		}
	  else
		strErrMsg = AtcCode.getErrMsg();
	}
		
	if(strPrepareToEdit.compareTo("1") == 0) {
  	  vEditInfo = AtcCode.operateOnFinalTaxPayees(dbOP, 3);			
	  if(vEditInfo == null && strErrMsg == null ) 
		strErrMsg = AtcCode.getErrMsg();
	  else
	  	strAtcIndex = (String) vEditInfo.elementAt(6);
	}else{
	  if (WI.fillTextValue("tin").length() > 0 && strPageAction.length() == 0){
		vEditInfo = AtcCode.operateOnFinalTaxPayees(dbOP, 5);		
		if(vEditInfo != null && vEditInfo.size() > 0){
			strPrepareToEdit = "1";
			strAtcIndex = (String) vEditInfo.elementAt(6);
		}
	  }
	}
	if (strAtcIndex.length() > 0){
		vAtcDetails = AtcCode.operateOnATCCode(dbOP,5);
	//	System.out.println("vAtcDetails " + vAtcDetails);
	}	
	vRetResult = AtcCode.operateOnFinalTaxPayees(dbOP, 4);
	if (vRetResult != null)
		iSearchResult = AtcCode.getSearchCount();
	else if (vRetResult == null && strErrMsg == null )
		strErrMsg = AtcCode.getErrMsg();
  }
%>
<body bgcolor="#D2AE72">
<form action="create_schedule5_entries.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: ALPHALIST OF PAYEES SUBJECT TO FINAL WITHHOLDING TAX ::::</strong></font></div></td>
    </tr>
	<tr> 
      <td width="770" height="10"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="4"><font size="1"><a href="javascript:goback('<%=WI.fillTextValue("year_of")%>')"><img src="../../../../images/go_back.gif"  border="0"></a></font></td>
    </tr>
    <tr> 
      <td width="4%" height="29">&nbsp;</td>
      <td width="15%">TIN #</td>
	  <%if (vEditInfo != null && vEditInfo.size() > 0){
	  	 	strTemp = (String)vEditInfo.elementAt(1);
		}else{
	  		strTemp = WI.fillTextValue("tin");
		}
	  %>
      <td width="15%"><input name="tin" type="text" size="16" maxlength="16" value="<%=strTemp%>"></td>
      <td width="66%"><font size="1"><a href="javascript:ProceedClicked();">&nbsp;<img src="../../../../images/form_proceed.gif" border="0"></a> 
        </font></td>
    </tr>
	</table>
	<%if (WI.fillTextValue("proceedClicked").length() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="27" width="4%">&nbsp;</td>
      <td height="27" colspan="3"><u>PAYEE INFO</u></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td width="23%" height="27">Classification :</td>
      <% if (vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("pageReloaded").equals("1")){
	  	 	strClassification = (String)vEditInfo.elementAt(2);
		 }else{
			strClassification = WI.fillTextValue("classification"); 
			strClassification = WI.getStrValue(strClassification,"0");
		 }	  	
	  %>
      <td width="73%" height="27" colspan="2"> <select name="classification" onChange="reloadPage();">
          <%if(strClassification.equals("0")){%>
          <option value="0" selected>Personal</option>
          <option value="1">Company</option>
          <%}else if(strClassification.equals("1")){%>
          <option value="0">Personal</option>
          <option value="1" selected>Company</option>
          <%}%>
        </select></td>
    </tr>
	<%if (strClassification.length() > 0){%>
    <%if (strClassification.equals("0")){%>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">Last name</td>
      <% if (vEditInfo != null && vEditInfo.size() > 0){
	  	 	strTemp = (String)vEditInfo.elementAt(3);
		 }else{
			strTemp = WI.fillTextValue("last_name"); 
		 }	  	
	  %>	  
      <td height="27" colspan="2"><input name="last_name" type="text" size="32" maxlength="32" value="<%=WI.getStrValue(strTemp,"")%>">
      </td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">First name</td>
      <% if (vEditInfo != null && vEditInfo.size() > 0){
	  	 	strTemp = (String)vEditInfo.elementAt(4);
		 }else{
			strTemp = WI.fillTextValue("first_name"); 
		 }	  	
	  %>
      <td height="27" colspan="2"> <input name="first_name" type="text" size="32" maxlength="32" value="<%=WI.getStrValue(strTemp,"")%>">
      </td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">Middle name</td>
      <% if (vEditInfo != null && vEditInfo.size() > 0){
	  	 	strTemp = (String)vEditInfo.elementAt(5);
		 }else{
			strTemp = WI.fillTextValue("middle_name"); 
		 }	  	
	  %>	  
      <td height="27" colspan="2"> <input name="middle_name" type="text" size="32" maxlength="32" value="<%=WI.getStrValue(strTemp,"")%>"> 
      </td>
    </tr>
    <%}else {%>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">Company Name</td>
      <% if (vEditInfo != null && vEditInfo.size() > 0){
	  	 	strTemp = (String)vEditInfo.elementAt(3);
		 }else{
			strTemp = WI.fillTextValue("last_name"); 
		 }	  	
	  %>
      <td height="27" colspan="2"> 
	  <input name="last_name" type="text" size="64" maxlength="128" value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <%}%>    
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">ATC Code</td>
      <% if (vEditInfo != null && vEditInfo.size() > 0){
	  	 	strTemp = (String)vEditInfo.elementAt(6);
		 }else{
			strTemp = WI.fillTextValue("atc_index");
		 }	  	
	  %>
      <td height="27" colspan="2"><select name="atc_index" onChange="reloadPage();">
          <option value="">Select code</option>
          <%=dbOP.loadCombo("ATC_INDEX","ATC_CODE"," from PR_ATC_LIST where is_valid = 1 and is_del = 0 order by ATC_CODE", strTemp, false)%> </select> <font size="1"><a href="javascript:UpdateATC()";><img src="../../../../images/update.gif" width="60" height="25" border="0"></a></font> 
        click to update list of ATC Code</td>
    </tr>
	<%if (strAtcIndex.length() > 0){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <%if (vAtcDetails != null && vAtcDetails.size() > 0){
	  	strTemp = (String) vAtcDetails.elementAt(4);  		
	   }
		if (vEditInfo != null && vEditInfo.size() > 0){
	  	   strTemp = (String)vEditInfo.elementAt(8);
		}
	  %>
      <td height="26" colspan="3">Nature of Income Payment : <strong><%=WI.getStrValue(strTemp,"")%></strong></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <%if (vAtcDetails != null && vAtcDetails.size() > 0){
	  	strTemp = (String) vAtcDetails.elementAt(3);
	  }
	  if (vEditInfo != null && vEditInfo.size() > 0){
	   strTemp = (String)vEditInfo.elementAt(10);
	  }	  
	  %>
      <td height="27" colspan="3">Tax Rate : <strong><%=WI.getStrValue(strTemp,"","%","")%></strong> <input type="hidden" name="tax_rate" value="<%=WI.getStrValue(strTemp,"0")%>"> 
      </td>
    </tr>
	<%}%>
    <tr> 
      <td height="27">&nbsp;</td>
      <% if (vEditInfo != null && vEditInfo.size() > 0){
	  	 	strTemp = (String)vEditInfo.elementAt(9);
		 }else{
			strTemp = WI.fillTextValue("payment");
		 }	  	
	  %>
      <td height="27" colspan="3">Amount of Income Payment : 
        <input name="payment" type="text" size="8" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=WI.getStrValue(strTemp,"0")%>" onKeyUp="AllowOnlyFloat('form_','payment');"	 
       	onBlur="AllowOnlyFloat('form_','payment');style.backgroundColor='white';UpdateToZero('payment')"></td>
    </tr>
    <tr> 
      <td height="34" colspan="4"><div align="center"><font size="1"> 
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1,"");ClearFields();'><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
          Click to add entry 
          <%}else{%>
          <a href='javascript:PageAction(2, "");ClearFields();'><img src="../../../../images/edit.gif" border="0"></a> 
          Click to edit entry
          <%}%>
          <a href="javascript:Cancel('<%=WI.fillTextValue("year_of")%>');"><img src="../../../../images/cancel.gif" border="0"></a> 
          Click to cancel </font></div></td>
    </tr>
    <%}%>
  </table>
  <%}// end proceedClicked > 0%>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="28"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a> 
          click to print list</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#666666"> 
      <td height="24" colspan="12"><div align="center"><strong><font color="#FFFFFF">:: 
          ALPHALIST ::</font></strong></div></td>
    </tr>
    <tr> 
      <td height="28" colspan="12"><strong><font size="1">TOTAL PAYEE(S) : </font></strong></td>
    </tr>
    <tr> 
      <td width="4%" rowspan="2"><div align="center"><font size="1"><strong>COUNT</strong></font></div></td>
      <td width="12%" rowspan="2"><div align="center"><font size="1"><strong>TIN 
          #</strong></font></div></td>
      <td height="21" colspan="3"><div align="center"><font size="1"><strong>NAME 
          OF PAYEES</strong></font></div></td>
      <td width="4%" rowspan="2"><div align="center"><font size="1"><strong>ATC 
          CODE </strong></font></div></td>
      <td width="11%" rowspan="2"><div align="center"><font size="1"><strong>NATURE 
          OF INCOME PAYMENT</strong></font></div></td>
      <td width="8%" rowspan="2"><div align="center"><font color="#000000" size="1"><strong>AMOUNT 
          OF INCOME PAYMENT</strong></font></div></td>
      <td width="4%" rowspan="2"><div align="center"><font size="1"><strong>TAX 
          RATE </strong></font></div></td>
      <td width="7%" rowspan="2"><div align="center"><font size="1"><strong>AMOUNT 
          OF TAX WITHHELD</strong></font></div></td>
      <td width="6%" rowspan="2" colspan="2"> <div align="center"><font size="1"><strong>OPTION</strong></font></div></td>
    </tr>
    <tr> 
      <td width="15%" height="22"><strong><font size="1">Last Name</font></strong></td>
      <td width="14%"><strong><font size="1">First Name</font></strong></td>
      <td width="15%"><strong><font size="1">Middle Name</font></strong></td>
    </tr>
    <% int iCount = 1;
	for(int i = 0;i < vRetResult.size(); i+=12,iCount++){%>
    <tr> 
      <td height="33"><font size="1">&nbsp;&nbsp;<%=iCount%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <%if(((String)vRetResult.elementAt(i+2)).equals("0")){%>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
	  <%}else{%>
      <td colspan="3"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <%}%>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
      <td><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%></font></div></td>
      <td><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"","%","")%></font></div></td>
      <td><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+11),true)%></font></div></td>
      <td><div align="center"><font size="1"><a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/edit.gif" border=0 ></a> 
          </font></div></td>
      <td><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
  <%}// end if vRetResult != null%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr> 
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>">
  <input type="hidden" name="print_page">
  <input type="hidden" name="pageReloaded">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>