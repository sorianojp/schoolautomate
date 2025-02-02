<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction,
																payroll.ReportPayroll, payroll.PRTaxReport" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Previous Salary Encoding</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
.formatNumberField{
	text-align:right;
	
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function DeleteRecord(){
	document.form_.page_action.value = "0";
	this.SubmitOnce("form_");
}
function AddRecord(){
	document.form_.page_action.value = "1";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	this.SubmitOnce("form_");
}
function CancelRecord(){
	location = "emp_prev_salary.jsp?emp_id="+document.form_.emp_id.value+
						"&year_of="+document.form_.year_of.value+
						"&user_index="+document.form_.user_index.value+
						"&encoding_type="+document.form_.encoding_type.value;
}

function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function checkKeyPress(strFormName, strFieldName, strExtn, strKeyCode){
	/*
		strKeyCodes
			35 = end, 36 = home, 37 = left, 38 = up, 39 = right, 40 = down
			8 = backspace, 46 = delete
			96 - 105 - numpad
			48 - 57 - kanang sa taas na numbers
			110 - period sa main
			190 - period sa numpad
	*/
	// alert("strKeyCode - " + strKeyCode);
 	if((strKeyCode >= 35 && strKeyCode <= 40)		
		|| (strKeyCode >= 48	&& strKeyCode <= 57)
		|| (strKeyCode >= 96	&& strKeyCode <= 105)
		|| strKeyCode == 8	|| strKeyCode == 46
		|| strKeyCode == 110	|| strKeyCode == 190)
		return;
	
	AllowOnlyIntegerExtn(strFormName,strFieldName, strExtn);
}
-->
</script>

<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","emp_prev_salary.jsp");

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
														"emp_prev_salary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vEditInfo = null;
String strCheck2316 = null;

ReportPayroll rptPrevSal = new ReportPayroll(request);
PRTaxReport prTax = new PRTaxReport();

strCheck2316 = prTax.getEmployee2316ForYear(dbOP, request, null);

if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}	
}

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strTDColor = null;
if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (rptPrevSal.operateOnPrevSalDetail(dbOP,0) != null){
			strErrMsg = " Record removed successfully ";
		}else{
			strErrMsg = rptPrevSal.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (rptPrevSal.operateOnPrevSalDetail(dbOP,1) != null){
			strErrMsg = " Record posted successfully ";
		}else{
			strErrMsg = rptPrevSal.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (rptPrevSal.operateOnPrevSalDetail(dbOP,2) != null){
			strErrMsg = " Record updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = rptPrevSal.getErrMsg();
		}
	}
}

vEditInfo = rptPrevSal.operateOnPrevSalDetail(dbOP,4);
if(vEditInfo != null && vEditInfo.size() > 0){
	strPrepareToEdit = "1";
	
}

//if (strPrepareToEdit.length() > 0){
//	vEditInfo = rptPrevSal.operateOnPrevSalDetail(dbOP,3);
//	if (vEditInfo == null)
//		strErrMsg = rptPrevSal.getErrMsg();
//}

//	System.out.println("vRetResult " + vRetResult);
%>
<body bgcolor="#D2AE72" onUnload="ReloadMain();" class="bgDynamic">
<form action="emp_prev_salary.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : PREVIOUS SALARY DETAILS PAGE ::::</strong></font></td>
    </tr>
</table>
  <%if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" colspan="2"><%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
    <tr> 
      <td width="5%" height="22">&nbsp;</td>
      <td height="22">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> </td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td height="22">Employee ID :<strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr> 
      <td height="18" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" colspan="4" bgcolor="#CCCCCC"><strong>&nbsp;&nbsp;&nbsp;&nbsp;PREVIOUS 
        SALARY FOR THE YEAR&nbsp; <%=WI.fillTextValue("year_of")%></strong></td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="25" colspan="2" bgcolor="#FFFFFF"><strong>NON TAXABLE</strong></td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">Basic/ SMW </td>
      <td bgcolor="#FFFFFF"><strong>
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(12);
		 else
		  	strTemp = WI.fillTextValue("non_tax_basic");
	  %>
        <input name="non_tax_basic" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
	  onKeyUp="checkKeyPress('form_','non_tax_basic', '.', event.keyCode);"
	  onBlur="AllowOnlyIntegerExtn('form_','non_tax_basic', '.');style.backgroundColor='white';"
		 style="text-align:right;">
      </strong></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">Holiday Pay </td>
      <td bgcolor="#FFFFFF"><strong>
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(13);
		 else
		  	strTemp = WI.fillTextValue("non_tax_holiday");
	  %>
        <input name="non_tax_holiday" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
	  onKeyUp="checkKeyPress('form_','non_tax_holiday', '.', event.keyCode);"
	  onBlur="AllowOnlyIntegerExtn('form_','non_tax_holiday', '.');style.backgroundColor='white';"
		 style="text-align:right;">
      </strong></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">Overtime Pay </td>
      <td bgcolor="#FFFFFF"><strong>
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(14);
		 else
		  	strTemp = WI.fillTextValue("non_tax_OT");
	  %>
        <input name="non_tax_OT" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
	  onKeyUp="checkKeyPress('form_','non_tax_OT', '.', event.keyCode);"
	  onBlur="AllowOnlyIntegerExtn('form_','non_tax_OT', '.');style.backgroundColor='white';"
		 style="text-align:right;">
      </strong></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">Night Shift Differential </td>
      <td bgcolor="#FFFFFF"><strong>
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(15);
		 else
		  	strTemp = WI.fillTextValue("non_tax_np");
	  %>
        <input name="non_tax_np" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
	  onKeyUp="checkKeyPress('form_','non_tax_np', '.', event.keyCode);"
	  onBlur="AllowOnlyIntegerExtn('form_','non_tax_np', '.');style.backgroundColor='white';"
		 style="text-align:right;">
      </strong></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">Hazard Pay </td>
      <td bgcolor="#FFFFFF"><strong>
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(16);
		 else
		  	strTemp = WI.fillTextValue("non_tax_hazard");
	  %>
        <input name="non_tax_hazard" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
	  onKeyUp="checkKeyPress('form_','non_tax_hazard', '.', event.keyCode);"
	  onBlur="AllowOnlyIntegerExtn('form_','non_tax_hazard', '.');style.backgroundColor='white';"
		 style="text-align:right;">
      </strong></td>
    </tr>
    <tr>
      <td width="4%" bgcolor="#FFFFFF">&nbsp;</td> 
      <td width="4%" height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="36%" height="24" bgcolor="#FFFFFF">13th month &amp; Other Benefits</td>
      <td width="60%" bgcolor="#FFFFFF"><strong> 
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(1);
		 else
		  	strTemp = WI.fillTextValue("non_tax_bonus");
	  %>
        <input name="non_tax_bonus" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
	  onKeyUp="checkKeyPress('form_','non_tax_bonus', '.', event.keyCode);"
	  onBlur="AllowOnlyIntegerExtn('form_','non_tax_bonus', '.');style.backgroundColor='white';"
		 style="text-align:right;">
        </strong></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">De Minimis </td>
      <td bgcolor="#FFFFFF"><strong>
        <%
				 if (vEditInfo != null && vEditInfo.size() > 0)
	  				strTemp = (String) vEditInfo.elementAt(11);
				 else
						strTemp = WI.fillTextValue("de_minimis");
				%>
        <input name="de_minimis" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
		onKeyUp="checkKeyPress('form_','de_minimis', '.', event.keyCode);"
	  onBlur="AllowOnlyFloat('form_','de_minimis');style.backgroundColor='white';"
		 style="text-align:right;">
      </strong></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td> 
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">Salaries &amp; Other Compensation</td>
      <td bgcolor="#FFFFFF"><strong> 
        <%if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(2);
		 else
	  		strTemp = WI.fillTextValue("non_tax_sal");
	  %>
        <input name="non_tax_sal" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
		onKeyUp="checkKeyPress('form_','non_tax_sal', '.', event.keyCode);"
	  onBlur="AllowOnlyFloat('form_','non_tax_sal');style.backgroundColor='white';"
		style="text-align:right;">
        </strong></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td> 
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">SSS, PHIC, Pag Ibig &amp; Union Dues</td>
      <td bgcolor="#FFFFFF"><strong> 
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(3);
		 else
		  	strTemp = WI.fillTextValue("contributions");
	  %>
        <input name="contributions" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
		onKeyUp="checkKeyPress('form_','contributions', '.', event.keyCode);"
	  onBlur="AllowOnlyFloat('form_','contributions');style.backgroundColor='white';"
		style="text-align:right;">
        </strong></td>
    </tr>
    <tr> 
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" colspan="2" bgcolor="#FFFFFF"><strong>TAXABLE</strong></td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="24" bgcolor="#FFFFFF">Basic Salary</td>
      <td bgcolor="#FFFFFF"><strong>
     <% if (vEditInfo != null && vEditInfo.size() > 0)
			  	strTemp = (String) vEditInfo.elementAt(7);			
			 else
					strTemp = WI.fillTextValue("basic_salary");
	  %>
        <input name="basic_salary" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
		onKeyUp="checkKeyPress('form_','basic_salary', '.', event.keyCode);"
	  onBlur="AllowOnlyFloat('form_','basic_salary');style.backgroundColor='white';"
		style="text-align:right;">
      </strong></td>
    </tr>
    <tr>
      <td width="4%" bgcolor="#FFFFFF">&nbsp;</td> 
      <td width="4%" height="24" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="36%" height="24" bgcolor="#FFFFFF">13th month &amp; Other Benefits</td>
      <td width="60%" bgcolor="#FFFFFF"><strong> 
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(4);
		 else
	  		strTemp = WI.fillTextValue("taxable_bonus");
	  %>
        <input name="taxable_bonus" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
		onKeyUp="checkKeyPress('form_','taxable_bonus', '.', event.keyCode);" 
	  onBlur="AllowOnlyFloat('form_','taxable_bonus');style.backgroundColor='white';"
		style="text-align:right;">
        </strong></td>
    </tr>
    <tr>
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td> 
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Salaries &amp; Other Compensation</td>
      <td bgcolor="#FFFFFF"><strong> 
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(5);
		 else
	  		strTemp = WI.fillTextValue("taxable_salary");
	  %>
        <input name="taxable_salary" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
		onKeyUp="checkKeyPress('form_','taxable_salary', '.', event.keyCode);" 
	  onBlur="AllowOnlyFloat('form_','taxable_salary');style.backgroundColor='white';"
		style="text-align:right;">
        </strong></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td> 
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="18" colspan="2" bgcolor="#FFFFFF">Tax Withheld(from Jan. - Nov. <%=WI.fillTextValue("year_of")%>) </td>
      <td bgcolor="#FFFFFF"><strong>
        <% if (vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String) vEditInfo.elementAt(6);
		 else
	  		strTemp = WI.fillTextValue("tax_withheld");
	  %>
        <input name="tax_withheld" type="text" size="10" maxlength="10"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.getStrValue(strTemp,"0")%>"		
		onKeyUp="checkKeyPress('form_','tax_withheld', '.', event.keyCode);" 
	  onBlur="AllowOnlyFloat('form_','tax_withheld');style.backgroundColor='white';"
		style="text-align:right;">
        </strong></td>
    </tr>
    <tr>
      <td height="18" colspan="4" bgcolor="#FFFFFF">&nbsp;</td> 
    </tr>
  </table>

  <% 
}// end if Employee ID is null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<%if(strCheck2316 == null || strCheck2316.length() == 0){%>
    <tr> 
      <td width="100%" height="25" align="center" bgcolor="#FFFFFF"> 
        <% if (iAccessLevel > 1) { 
					if (vEditInfo == null) {%>
        <a href="javascript:AddRecord();">
				<img src="../../../../images/save.gif" width="48" height="28" border="0"></a>
				<font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to add</font> 
        <%}else{%>
        <font size="1" face="Verdana, Arial, Helvetica, sans-serif">
				<a href="javascript:EditRecord();"><img src="../../../../images/edit.gif" border="0"></a>
				click to save changes
				<a href="javascript:DeleteRecord()"><img src="../../../../images/delete.gif" border=0></a>
				click to delete </font> 
        <%}%>
				
        <a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" border="0"></a> 
        <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to 
          cancel or go previous</font> 
        <%} //end iAccessLevel > 1%>      </td>
    </tr>
		<%}else{%>
		<tr> 
      <td width="100%" height="25" align="center" bgcolor="#FFFFFF">Employee already has a saved form 2316 data</td>
    </tr>
		<%}%>
  </table>
   <!--
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <%if (vRetResult!= null && vRetResult.size() > 0){ %>
    <tr> 
      <td height="25" colspan="3" align="center" class="thinborderNONE"><strong>NON 
          TAXABLE</strong> </td>
      <td colspan="2" align="center" class="thinborderNONE" ><strong>TAXABLE</strong></td>
      <td width="11%" rowspan="2" align="center" class="thinborderNONE"><strong>TAX WITHHELD</strong></td>
      <td colspan="2" rowspan="2" align="center" class="thinborderNONE"><strong>OPTION</strong></td>
    </tr>
    <tr> 
      <td width="14%" height="25" class="thinborderNONE">13th month &amp; Other Benefits</td>
      <td width="14%" class="thinborderNONE">Salaries &amp; Other Compensation</td>
      <td width="16%" class="thinborderNONE">SSS, PHIC, Pag Ibig &amp; Union Dues</td>
      <td width="14%" class="thinborderNONE">13th month &amp; Other Benefits</td>
      <td width="15%" class="thinborderNONE">Salaries &amp; Other Compensation</td>
    </tr>
    <%	
	  for(int i = 0; i < vRetResult.size(); i+=7){
    %>
    <tr> 
      <td height="30" align="right">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%>&nbsp;</td>
      <td align="right">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%>&nbsp;</td>
      <td align="right">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%>&nbsp;</td>
      <td align="right">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%>&nbsp;</td>
      <td align="right">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%>&nbsp;</td>
      <td align="right">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%>&nbsp;</td>
      <td width="7%"><div align="center"><a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/edit.gif" border=0 ></a></div></td>
      <td width="9%"><div align="center"><a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/delete.gif" border=0></a></div></td>
    </tr>
    <%}// end for
	}//end if%>
  </table>
	-->
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18" colspan="7" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="7" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	
	<input type="hidden" name="save_sal" value="">
	<input type="hidden" name="page_action">
	<%if(vEditInfo != null && vEditInfo.size() > 0){%>
	<input type="hidden" name="info_index" value="<%=(String)vEditInfo.elementAt(0)%>">
	<%}%>
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input name="emp_id" type="hidden" value="<%=WI.fillTextValue("emp_id")%>"> 
	<input type="hidden" name="user_index" value="<%=WI.fillTextValue("user_index")%>">
	<input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>"> 
	<input type="hidden" name="encoding_type" value="<%=WI.fillTextValue("encoding_type")%>"> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>