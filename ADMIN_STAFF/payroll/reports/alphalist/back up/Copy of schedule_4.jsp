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
function CancelRecord(){
	location = "schedule_4.jsp?emp_id="+document.form_.emp_id.value+"&year_of="+document.form_.year_of.value+"&user_index="+document.form_.user_index.value;
}
function CreateEntry(){
	location = "create_schedule4_entries.jsp?year_of="+document.form_.year_of.value;
}
function reloadPage(){
	this.SubmitOnce("form_");
}

function CopyRecords(){
	document.form_.copy.value = "1";
	document.form_.proceedClicked.value = "1";
	document.form_.prepareToCopy.value = "1";
	this.SubmitOnce("form_");
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}

function PrepareToCopy(){
	document.form_.prepareToCopy.value = "1";
	this.SubmitOnce("form_");
}

function UpdateToZero(strTextName){
	if(eval('document.form_.'+strTextName+'.value.length') == 0){		
		eval('document.form_.'+strTextName+'.value= "0"');
	}	
}
function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
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
	<jsp:forward page="./report_schedule4_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","schedule_4.jsp");

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
														"schedule_4.jsp");
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
	Vector vRetResult  = null;
	int iSearchResult  = 0;
	String strPrepareToCopy = null;

  if (WI.fillTextValue("proceedClicked").length() > 0)	{  
	vRetResult = AtcCode.operateOnExpPayment(dbOP, 4);
	if (vRetResult != null)
		iSearchResult = AtcCode.getSearchCount();
	else if (vRetResult == null && strErrMsg == null )
		strErrMsg = AtcCode.getErrMsg();
	if (WI.fillTextValue("copy").equals("1")){
		if(AtcCode.copyTaxPayees(dbOP,4)){
			strErrMsg = "Copying Success";
		}else{
			strErrMsg = AtcCode.getErrMsg();
		}
	}
  }
%>
<body bgcolor="#D2AE72">
<form action="schedule_4.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="770" height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: REPORTS : ALPHALIST OF PAYEES SUBJECT TO EXPANDED WITHHOLDING 
          TAX ::::</strong></font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="4"><font size="1"><a href="./alphalist_main.htm"><img src="../../../../images/go_back.gif"  border="0"></a></font><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="17%">Taxable Year</td>
      <td width="9%"><select name="year_of" onChange="reloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> </select> </td>
      <td width="71%"><font size="1"><a href="javascript:ProceedClicked();"><img src="../../../../images/form_proceed.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="3"><font size="1"><a href='javascript:CreateEntry();'> <img src="../../../../images/update.gif" width="60" height="26" border="0" ></a> 
        click to UPDATE entries for the specified Taxable Year </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3"><font size="1"><a href="javascript:PrepareToCopy()"><img src="../../../../images/copy.gif" border="0"></a> 
        click to COPY some entries for the specified Taxable Year</font></td>
    </tr>
    <tr> 
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <%if(WI.fillTextValue("prepareToCopy").equals("1")){%>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">New Taxable Year : </td>
      <%
	  	strTemp = WI.fillTextValue("new_year_of");
	  %>
      <td height="27" colspan="2"><input name="new_year_of" type="text" size="4" maxlength="4" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=WI.getStrValue(strTemp,"")%>" onKeyUp="AllowOnlyFloat('form_','new_year_of');"	 
       	onBlur="AllowOnlyFloat('form_','new_year_of');style.backgroundColor='white';UpdateToZero('new_year_of')"></td>
    </tr>
    <%}%>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="28"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a> 
          click to print list</font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#666666"> 
      <td height="24" colspan="11"><div align="center"><strong><font color="#FFFFFF">:: 
          ALPHALIST ::</font></strong></div></td>
    </tr>
    <tr> 
      <td height="28" colspan="11"><strong><font size="1">TOTAL PAYEE(S) : </font></strong></td>
    </tr>
    <tr> 
      <td width="5%" rowspan="2"><div align="center"><font size="1"><strong>COUNT</strong></font></div></td>
      <td width="9%" rowspan="2"><div align="center"><font size="1"><strong>TIN 
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
      <%if(WI.fillTextValue("prepareToCopy").equals("1")){%>
      <td width="5%" rowspan="2"><div align="center"><font size="1"><strong>SELECT</strong></font></div></td>
      <%}%>
    </tr>
    <tr> 
      <td width="18%" height="22"><strong><font size="1">Last Name</font></strong></td>
      <td width="14%"><strong><font size="1">First Name</font></strong></td>
      <td width="15%"><strong><font size="1">Middle Name</font></strong></td>
    </tr>
    <% int iCount = 1;
	for(int i = 0;i < vRetResult.size(); i+=12,iCount++){%>
    <tr> 
      <td height="20"><font size="1"><%=iCount%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font> <input type="hidden" name="tin<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>"> 
      </td>
      <%if(((String)vRetResult.elementAt(i+2)).equals("0")){%>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font> <input type="hidden" name="classification<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+2)%>"> 
        <input type="hidden" name="lname<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+3)%>"> 
      </td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font> <input type="hidden" name="fname<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+4)%>">	
      </td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font> <input type="hidden" name="mname<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+5)%>">	
      </td>
      <%}else{%>
      <td colspan="3"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <input type="hidden" name="classification<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+2)%>">
      <input type="hidden" name="lname<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+3)%>">
      <%}%>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font> <input type="hidden" name="atc_index<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+6)%>">	
      </td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></td>
      <td><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%></font></div></td>
      <td height="20"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"","%","")%></font></div></td>
      <td><div align="right"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+11),true)%></font></div></td>
      <%if(WI.fillTextValue("prepareToCopy").equals("1")){%>
      <td><div align="center"><font size="1"> 
          <input type="checkbox" name="checkbox<%=iCount%>" value="1">
          </font></div></td>
      <%}%>
    </tr>
    <%}// end for loop%>
    <input type="hidden" name="max_disp" value="<%=iCount%>">
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
	<%if(WI.fillTextValue("prepareToCopy").equals("1")){%>	
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="center"><font size="1"><a href="javascript:CopyRecords();"><img src="../../../../images/save.gif" width="48" height="28" border="0"></a> 
          click to SAVE entries for the above specified Taxable year</font></div></td>
    </tr>
	<%}%>
  </table>
  <%}// end if vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="copy">
	<input type="hidden" name="print_page">
    <input type="hidden" name="prepareToCopy" value="<%=strPrepareToCopy%>">
    <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>