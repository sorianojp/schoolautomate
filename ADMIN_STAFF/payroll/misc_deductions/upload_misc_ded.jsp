<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRUploadDeductions,payroll.PRMiscDeduction" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

	ReadPropertyFile readPropFile = new ReadPropertyFile();
	boolean bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Existing Loans</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!-- 
function ReloadPage(){
	this.SubmitOnce("form_");
}

function uploadLoan(){
	document.form_.upload_deduction.value = "1";
	this.SubmitOnce("form_");
}

function ClearFields(){
	document.form_.terms.value = "";
	document.form_.loan_amount.value = "";
	document.form_.release_date.value = "";
	document.form_.start_date.value = "";
} 
function CancelRecord(){
	location = "./upload_misc_ded.jsp?";
} 
function updatePreload(){	
	var loadPg = "./post_ded_preload_mgmt.jsp?opner_form_name=form_&opner_form_field=deduct_index"+
				 "&opner_form_field_value="+document.form_.deduct_index.value;
	var win=window.open(loadPg,"updatePreload",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
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
								"Admin/staff-Payroll-LOANS-Reports-Upload Existing Loans","upload_misc_ded.jsp");
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

	//end of authenticaion code.
	Vector vRetResult = null;
	Vector vLoanInfo = null;
	PRUploadDeductions prUpload = new PRUploadDeductions();
	String strLoanType = WI.getStrValue(WI.fillTextValue("loan_type"), "2");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";	

	if(WI.fillTextValue("upload_deduction").length() > 0){
		if(prUpload.uploadMiscDeductions(dbOP, request) == -1)
			strErrMsg = prUpload.getErrMsg();
		else
			strErrMsg = "Operation Successful";
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./upload_misc_ded.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
      PAYROLL : MISCELLANEOUS DEDUCTION UPLOAD PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;<font size="2" color="#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="15%" height="26">Deduction name </td>
			<%
				strTemp = WI.fillTextValue("deduct_index");
			%>
      <td width="26%"><select name="deduct_index" id="deduct_index">
        <option value="">Select Deduction Name</option>
        <%=dbOP.loadCombo("PRE_DEDUCT_INDEX","PRE_DEDUCT_NAME", " from preload_deduction order by pre_deduct_name",strTemp,false)%>
      </select></td>
      <td width="55%" height="26" colspan="2"><%if(iAccessLevel > 1){%>
        <a href='javascript:updatePreload();'><img src="../../../images/update.gif" border="0" ></a>
			<font size="1">click to add to the list miscellaneous deductions</font>
				<%}%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="26">Date to deduct </td>
			<%
				strTemp = WI.fillTextValue("date_deduct");
			%>
      <td><input name="date_deduct" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_deduct');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td height="26" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="17" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    
    <tr>
      <td height="27">&nbsp;</td>
      <td>Format</td>
      <td><p>1. Emp ID - Employee ID <br>
        2. Miscellaneous deduction amount (no comma)<br>
        3. Remarks </p></td>
    </tr>
    <tr>
      <td width="3%" height="27">&nbsp;</td>
      <td width="12%">Deduction</td>
      <td width="85%"><font size="1">
        <textarea name="misc_ded_csv" cols="56" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("misc_ded_csv")%></textarea>
      </font></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="30" align="center">
        <input type="button" name="save" value="UPLOAD" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:uploadLoan();">
        <font size="1"> click to upload entries</font>
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">        <font size="1">click to cancel/clear entries </font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="upload_deduction">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>