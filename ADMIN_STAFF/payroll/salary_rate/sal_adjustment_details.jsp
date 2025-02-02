<%@ page language="java" import="utility.*,payroll.PRSalaryRate, java.util.Vector, 
																 payroll.PRMiscDeduction, payroll.PRConfidential" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

boolean bolHasAUFStyle = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Rate</title>
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
<script language="JavaScript">
function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function ReloadPage() {
	document.form_.print_page.value="";
	this.SubmitOnce('form_');
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

	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./sal_adjustment_details_print.jsp" />
	<%return;}	

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-SALARY RATE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-SALARY RATE-SALARY RATE","sal_adjustment_details.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		bolHasAUFStyle = (readPropFile.getImageFileExtn("HAS_AUF_STYLE","0")).equals("1");
 
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
//			dbOP.cleanUP();
//			throw new Exception();
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

 	PRConfidential prCon = new PRConfidential();
	Vector vRetResult = null;
	Vector vEmpRec    = null;
	String strSchCode = dbOP.getSchoolIndex();
	String strCheck = null;
	boolean bolCheckAllowed = false;
  
if(WI.fillTextValue("emp_id").length() > 0) {	
	bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);
 	if(bolCheckAllowed){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
		if(vEmpRec == null)
			strErrMsg = "Employee has no profile.";
	}else
		strErrMsg = prCon.getErrMsg();
}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./sal_adjustment_details.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      NOTICE OF SALARY ADJUSTMENT ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="200%" height="23" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="21%">Notice Date </td>
      <td>
			<%
				strTemp = WI.fillTextValue("notice_date");
				if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);				
			%>
        <input name="notice_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.notice_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    
  
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23">Name of Office </td>
			<%
				strTemp = (String)request.getSession(false).getAttribute("sal_adjust_office_session");
				if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("sal_adjust_office"),strTemp)) ) {
					strTemp = WI.fillTextValue("sal_adjust_office");
					request.getSession(false).setAttribute("sal_adjust_office_session",strTemp);
				}
			%>					
      <td height="23"><input name="sal_adjust_office" type="text" maxlength="64" size="32" value="<%=strTemp%>"
	class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
	onBlur="style.backgroundColor='white';"></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23">Signatory</td>
			<%
				strTemp = (String)request.getSession(false).getAttribute("step_inc_signatory");
				if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("signatory"),strTemp)) ) {
					strTemp = WI.fillTextValue("signatory");
					request.getSession(false).setAttribute("step_inc_signatory",strTemp);
				}
			%>			
      <td height="23"><input name="signatory" type="text" maxlength="64" size="32" value="<%=strTemp%>"
	class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
	onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td height="22">Position of Signatory </td>
			<%
				strTemp = (String)request.getSession(false).getAttribute("step_inc_position");
				if(strTemp == null || !strTemp.equals(WI.getStrValue(WI.fillTextValue("position"),strTemp)) ) {
					strTemp = WI.fillTextValue("position");
					request.getSession(false).setAttribute("step_inc_position",strTemp);
				}
			%>				
      <td height="22"><input name="position" type="text" maxlength="64" size="32" value="<%=strTemp%>"
	class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
	onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="11">&nbsp;</td>
      <td height="11">&nbsp;</td>
      <td height="11"></td>
    </tr>
     <tr>
       <td height="28">&nbsp;</td>
       <td>&nbsp;</td>
       <td valign="bottom"><a href="javascript:ReloadPage();">Save Values to Session</a></td>
     </tr>
     <tr>
      <td height="28">&nbsp;</td>
      <td >&nbsp;</td>
      <td width="75%" valign="bottom"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font> </font></td>
    </tr>
     <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
 	<input type="hidden" name="print_page" value="">
	<input type="hidden" name="month_of" value="<%=WI.fillTextValue("month_of")%>">
	<input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>">
	<input type="hidden" name="salary_index" value="<%=WI.fillTextValue("salary_index")%>"> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
