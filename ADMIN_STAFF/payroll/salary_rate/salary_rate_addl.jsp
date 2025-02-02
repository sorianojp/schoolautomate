<%@ page language="java" import="utility.*,payroll.PRSalaryRate,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Additional Responsibility</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript">
//called for add or edit.
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0 )
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.emp_id.focus();
}
function ComputeRates(){
	var iDivVal = document.form_.days_per_month[document.form_.days_per_month.selectedIndex].value;
	if (document.form_.basic_salary.value.length > 0){
		if (eval(document.form_.basic_salary.value) !=0){
			document.form_.daily_sal.value = eval(document.form_.basic_salary.value)/iDivVal;
			document.form_.daily_sal.value = truncateFloat(document.form_.daily_sal.value,1,false);

			iDivVal = document.form_.hrs_per_day[document.form_.hrs_per_day.selectedIndex].value;
			document.form_.hourly_sal.value = eval(document.form_.daily_sal.value)/iDivVal;
			document.form_.hourly_sal.value = truncateFloat(document.form_.hourly_sal.value,1,false);
		}
	 }else{
		 document.form_.daily_sal.value ="0";
		 document.form_.hourly_sal.value ="0";
	 }

}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll - Tax Status","salary_rate.jsp");
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
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","SALARY_RATE",request.getRemoteAddr(),
														"salary_rate.jsp");
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

	PRSalaryRate prSalRate = new PRSalaryRate();
	Vector vRetResult = null; 
	Vector vEmpRec    = null;
	Vector vTaxStat   = null;
	Vector vEditInfo  = null;
	

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prSalRate.operateOnSalaryAddl(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prSalRate.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.equals("1"))
				strErrMsg = "Salary Rate Information successfully added.";
			if(strTemp.equals("2"))
				strErrMsg = "Salary Rate Information successfully edited.";
			if(strTemp.equals("0"))
				strErrMsg = "Salary Rate Information successfully removed.";
		}//System.out.println(strErrMsg);
	}

if(WI.fillTextValue("emp_id").length() > 0) {
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null)
		strErrMsg = "Employee has no profile.";
}
if(vEmpRec != null && vEmpRec.size() > 0) {
	if(strPrepareToEdit.equals("1")) 
		vEditInfo = prSalRate.operateOnSalaryAddl(dbOP, request, 3);
		
	vRetResult = prSalRate.operateOnSalaryAddl(dbOP, request, 4);	
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = prSalRate.getErrMsg();
	
	vTaxStat = 	new payroll.PRTaxStatus().operateOnTaxStatus(dbOP, request,4);
}

String[] astrConvertCivilStat = {"","Single","Married","Divorced/Separated","Widow/Widower"};
String[] astrConvertTaxStat   = {"Z (No Exemption)","Single","Head of Family","Married Employed"};
%>
<body bgcolor="#D2AE72" onLoad="FocusID()" class="bgDynamic">
<form action="./salary_rate_addl.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : SALARY INFORMATION PAGE ::::</strong></font></td>
    </tr>
	</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">Employee ID</td>
      <td width="19%"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="65%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%if(vEmpRec != null && vEmpRec.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="25%" height="18">&nbsp; </td>
      <td> 
        <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id")+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=1>";%>
        <%=WI.getStrValue(strTemp)%> <br> <br>
        <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
        <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
        <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
        <%=new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
        <br></td>
      <td width="25%">&nbsp;</td>
    </tr>
<%
if(vTaxStat != null && vTaxStat.size() > 1){%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30" colspan="2" valign="bottom"> Civil Status :<strong> <%=astrConvertCivilStat[Integer.parseInt((String)vTaxStat.elementAt(0))]%></strong><strong></strong></td>
    </tr>
<%}%>
    <tr> 
      <td height="18" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Effectivity Date</td>
      <td> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("valid_fr");
%> <input name="valid_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.valid_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("valid_to");
%> <input name="valid_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2">Salary Period Type</td>
      <td><select name="salary_period">
          <option value="0">Daily</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("salary_period");
if(strTemp == null) 
	strTemp = "";
		  if(strTemp.equals("1")){%>
          <option value="1" selected>Weekly</option>
          <%}else{%>
          <option value="1">Weekly</option>
          <%}if(strTemp.equals("2")) {%>
          <option value="2" selected>Bi-monthly</option>
          <%}else{%>
          <option value="2">Bi-monthly</option>
          <%}if(strTemp.equals("3")) {%>
          <option value="3" selected>Monthly</option>
          <%}else{%>
          <option value="3">Monthly</option>
          <%}%>
        </select> <font size="1"> * this indictates when salary is given to employee</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Responsibility Name</td>
      <td height="25">
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("res_name");
%>
        <input name="res_name" type="text" size="32" maxlength="32" value="<%=strTemp%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Responsibility Description</td>
      <td height="25">
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("res_desc");
%>
        <input name="res_desc" type="text" size="64" value="<%=strTemp%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><u>Basic Rate</u></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Monthly</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("basic_salary");
%> <input name="basic_salary" type="text" size="15" value="<%=strTemp%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','basic_salary');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','basic_salary');ComputeRates();">
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Daily</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("daily_sal");
if(strTemp == null || strTemp.equals("0.0")) 
	strTemp = "";
	
%> <input name="daily_sal" type="text" size="15" value="<%=strTemp%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','daily_sal');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','daily_sal');">
        <select name="days_per_month" onChange="ComputeRates();">
          <%
		strTemp = (String)request.getSession(false).getAttribute("days_pm");
		if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("days_per_month"),strTemp)) ) {
			strTemp = WI.fillTextValue("days_per_month");
			if(strTemp.length() == 0)
				strTemp = "30";
			request.getSession(false).setAttribute("days_pm",strTemp);
		}
		int iDefVal = Integer.parseInt(strTemp);
		for(int i = 20; i < 32; ++i) {
			if(i == iDefVal)
				strTemp = "selected";
			else	
				strTemp = "";
	%>
          <option value="<%=i%>" <%=strTemp%>><%=i%></option>
          <%}%>
        </select>
        (number of days per month) </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Hourly</td>
      <td height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("hourly_sal");
if(strTemp == null || strTemp.equals("0.0")) 
	strTemp = "";
%> <input name="hourly_sal" type="text" size="15" value="<%=strTemp%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','hourly_sal');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','hourly_sal');">
        <select name="hrs_per_day" onChange="ComputeRates();">
          <%
		strTemp = (String)request.getSession(false).getAttribute("hrs_pd");
		if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("hrs_per_day"),strTemp))) {
			strTemp = WI.fillTextValue("hrs_per_day");
			if(strTemp.length() == 0)
				strTemp = "30";
			request.getSession(false).setAttribute("hrs_pd",strTemp);
		}
		iDefVal = Integer.parseInt(strTemp);
		for(int i = 7; i < 11; ++i) {
			if(i == iDefVal)
				strTemp = "selected";
			else	
				strTemp = "";
	%>
          <option value="<%=i%>" <%=strTemp%>><%=i%></option>
          <%}%>
        </select>
        (number of hours per day)</td>
    </tr>
    <%if(iAccessLevel > 1) {%>
    <tr> 
      <td height="40">&nbsp;</td>
      <td height="40" colspan="2">&nbsp;</td>
      <td width="75%" height="40" valign="bottom"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./salary_rate_addl.jsp?emp_id=<%=WI.fillTextValue("emp_id")%>"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear </font></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>  
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">    
    <tr bgcolor="#666666"> 
      <td height="30" colspan="9"><div align="center"><font color="#FFFFFF"><strong>::: 
          ADDITIONAL SALARY DETAIL ::: </strong></font></div></td>
    </tr>
    <tr> 
      <td width="7%" class="thinborder"><strong><font size="1">INCLUSIVE DATES</font></strong></td>
      <td width="7%" class="thinborder"><font size="1"><strong>RESPONSIBILITY</strong></font></td>
      <td width="7%" class="thinborder"><strong><font size="1">RESPONSIBILITY 
        DESC </font></strong></td>
      <td width="7%" class="thinborder"><strong><font size="1">MONTHLY RATE</font></strong></td>
      <td width="7%" class="thinborder"><strong><font size="1">DAILY RATE</font></strong></td>
      <td width="7%" class="thinborder"><strong><font size="1">HOURLY RATE</font></strong></td>
      <td width="7%" class="thinborder"><strong><font size="1">SAL PERIOD</font></strong></td>
      <td width="5%" class="thinborder"><font size="1"><b>EDIT</b></font></td>
      <td width="5%" class="thinborder"><font size="1"><b>DELETE</b></font></td>
    </tr>
    <%
  String[] astrConvertUnit = {"Per hr","Per unit","Per session"};
  String[] astrConvertSalPeriod = {"Daily","Weekly","Bi-monthly","Monthly"};
  for (int i = 0; i < vRetResult.size(); i +=9){%>
    <tr> 
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i + 7)%> <%=WI.getStrValue((String)vRetResult.elementAt(i + 8)," - <br>",""," - present")%></div></td> 
	  <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"","","&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","","&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"","","&nbsp;")%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"","","&nbsp;")%></td>
      <td align="center" class="thinborder"><%=astrConvertSalPeriod[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%></td>

      <td class="thinborder"> <% if (iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/edit.gif" border="0"></a> <%}%> </td>
      <td class="thinborder"> <% if (iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
    </tr>
    <% } // end for loop %>
  </table>

<%}//if vRetResult.size() > 0

}//only if(vEmpRec != null && vEmpRec.size() > 0) %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>