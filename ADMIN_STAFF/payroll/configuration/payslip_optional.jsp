<%@ page language="java" import="utility.*,payroll.PRPayslip,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payslip/Payroll Sheet Setting</title>
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
.style1 {font-size: 9px}
</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
//called for add or edit.
function SaveData() {
	document.form_.page_action.value = 1;
	document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
 
function DeleteRecord(strItemName) {
	document.form_.page_action.value = 0;
	document.form_.item_name.value = strItemName;
	document.form_.submit();
}
 
function ReloadPage() {
	document.form_.reloaded.value = "";
	document.form_.submit();
}
function CancelRecord(){
	location = "./payslip_optional.jsp";
}
 
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Payslip Setting","payslip_optional.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"payslip_optional.jsp");
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

	PRPayslip prPay = new PRPayslip();
	Vector vRetResult = null;

	int i = 0;
	String[] astrPayslipItems = {"MONTHLY_RATE", "DAILY_HOURLY", "COLA/ECOLA", "OVERTIME",
															 "NIGHT_DIFF","HOLIDAYS", "ADDL_BONUS", "ADDL_PAY", 
															 "ADJUSTMENT", "INCENTIVES", 
															 "SUBSTITUTION", "OVERLOAD","FACULTY_PAY"};

	String[] astrPayslipTable = {"Monthly rate", "Daily/Hourly rate", "COLA/ECOLA", "Overtime Pay",
																"Night Differential","Holiday Pay", "Additional Bonus", "Additional Pay", 
																"Adjustments", "Incentives",
																"Substitute teaching", "Overload", "Faculty Pay"};

	int iItems = astrPayslipTable.length;
	if(bolIsSchool)
		iItems = 10;
	int iIndexOf = 0;
	
	String strPageAction = WI.fillTextValue("page_action");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	if(strPageAction.length() > 0){
		if(prPay.operateOnOptionalPayslipItems(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg =  prPay.getErrMsg();
	}
	
	vRetResult  = prPay.operateOnOptionalPayslipItems(dbOP, request, 4);

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="payslip_optional.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: PAYROLL: PAYSLIP SETTING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2">Item in payslip to make optional : 
        <select name="payslip_item">
        <%for (i = 0; i < iItems; i++){
					if(vRetResult != null){
						iIndexOf = vRetResult.indexOf(astrPayslipItems[i]);						
						if(iIndexOf != -1)
							continue;
					}
				%>
        <%if (Integer.parseInt(WI.getStrValue(WI.fillTextValue("deduct_gross"),"0")) == i){ %>
        <option value="<%=astrPayslipItems[i]%>" selected><%=astrPayslipTable[i]%></option>
        <%}else{%>
        <option value="<%=astrPayslipItems[i]%>"><%=astrPayslipTable[i]%></option>
        <%}}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Setting will only work on Payslip setting 3</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="21%" height="25">&nbsp;</td>
      <td width="75%" height="25">
				<%if(iAccessLevel > 1){%>
				<font size="1">        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Add " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:SaveData();">
        Click to set as optional
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
      Click to clear </font>
				<%}%>			</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td width="20%">&nbsp;</td>
    <td width="60%"><table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="24" colspan="2" align="center" bgcolor="#B9B292" class="thinborder"><strong><font color="#FFFFFF">LIST OF 
          ITEM MAPPINGS </font></strong></td>
    </tr>
    <tr>
      <td width="74%" height="25" align="center" class="thinborder style1">OPTIONAL ITEM IN PAYSLIP </td>
      <td width="26%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
		<%for(i = 0; i < vRetResult.size();i+=5){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder" align="center"><input type="button" name="edit2" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>');"></td>
    </tr>
		<%}%>
  </table></td>
    <td width="20%">&nbsp;</td>
  </tr>
</table>

	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
   <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="item_name" value="<%=WI.fillTextValue("item_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
