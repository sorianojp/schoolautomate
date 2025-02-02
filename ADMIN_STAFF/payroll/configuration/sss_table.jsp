<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>SSS Contribution Management</title>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ComputeContribution() {
	var Range1 = document.form_.range_1.value;
	var Range2 = document.form_.range_2.value;
	if(eval(Range2) > eval(Range1)) {
		var SalCr  = eval(Range2) - 250;
		var ESS    = eval(SalCr) * 607;
		var EEC    = 10;
		var ESS_   = eval(SalCr) * 333;
		
		document.form_.sal_credit.value = SalCr;
		document.form_.e_ss.value  = eval(ESS)/10000;
		document.form_.e_ec.value  = EEC;
		document.form_.e_ss_.value = eval(ESS_)/10000;
	}

}
function PrintPg()
{
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./sss_table.jsp";
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./sss_table_print.jsp" />
<% return;	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-SSS Table","sss_table.jsp");
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
														"Payroll","CONFIGURATION-SSS",request.getRemoteAddr(),
														"sss_table.jsp");
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"sss_table.jsp");
}
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prConfig.operateOnSSSTable(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prConfig.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "SSS table information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "SSS table information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "SSS table information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prConfig.operateOnSSSTable(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = prConfig.getErrMsg();
}

	vRetResult  = prConfig.operateOnSSSTable(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prConfig.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./sss_table.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: SSS TABLE PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Effectivity Date</td>
      <td> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(0);
else	
	strTemp = WI.fillTextValue("imp_date");
if(strTemp.length() == 0 && vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(0);
%>
 <input name="imp_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.imp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Range of Compensation</td>
      <td width="60%">Above or equal to 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("range_1");
%>        <input name="range_1" type="text" size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        and less than 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("range_2");
%>        <input name="range_2" type="text" size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp="ComputeContribution()"></td>
      <td width="19%">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="31">&nbsp;</td>
      <td height="31" colspan="2"> Salary Credit</td>
      <td height="31"  colspan="2"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("sal_credit");
%>	  
	<input name="sal_credit" type="text"  size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Monthly Contribution</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td width="4%" height="24">&nbsp;</td>
      <td width="15%">Employer SS (ER)</td>
      <td height="24"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("e_ss");
%>	  <input name="e_ss" type="text"  size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">      </td>
      <td height="24">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Employer EC</td>
      <td height="25"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("e_ec");
%>	  <input name="e_ec" type="text"  size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">      </td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Employee SS (EE) </td>
      <td height="25"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("e_ss_");
%>	  <input name="e_ss_" type="text"  size="6" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">      </td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="35" colspan="3" valign="bottom"><font size="1">
				<%if(iAccessLevel > 1){%>
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        Click to save entries 
        <%}else{%>
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '');">				
        Click to edit event 
        <%}%>
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">				
        Click to clear </font>
				<%}%>
				</td>
      <td height="25" valign="bottom">&nbsp;</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
      to print result</font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="8" bgcolor="#B9B292" class="thinborder"><div align="center">SSS 
          SCHEDULE OF CONTRIBUTIONS FOR EMPLOYED MEMBERS EFFECTIVE <%=(String)vRetResult.elementAt(9)%></div></td>
    </tr>
    <tr> 
      <td height="26" rowspan="3" class="thinborder"><div align="center"><font size="1"><strong>RANGE 
          OF COMPENSATION</strong></font></div></td>
      <td rowspan="3" class="thinborder"><div align="center"><font size="1"><strong>MONTHLY 
          SALARY CREDIT </strong></font></div></td>
      <td height="27" colspan="4" class="thinborder"><div align="center"><strong><font size="1">MONTHLY 
          CONTRIBUTION</font></strong></div></td>
      <td colspan="2" rowspan="3" class="thinborder"><div align="center"><strong><font size="1"><strong>OPTIONS</strong></font></strong></div></td>
    </tr>
    <tr> 
      <td height="26" colspan="2" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYER</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE</strong></font></div></td>
      <td rowspan="2" class="thinborder"><div align="center"><strong><font size="1">TOTAL(ER+EC+EE)</font></strong></div></td>
    </tr>
    <tr> 
      <td height="28" class="thinborder"><div align="center"><font size="1"><strong>ER</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>EC</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>EE</strong></font></div></td>
    </tr>
    <% for(int i =1; i < vRetResult.size(); i += 10){%>
    <tr> 
      <td width="23%" height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i + 9)%></font></div></td>
      <td width="24%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3),true)%></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 4),true)%></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 5),true)%></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 6),true)%></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 7),true)%></font></div></td>
      <td width="6%" height="25" class="thinborder"> <div align="center">
	  <%if(iAccessLevel > 1){%>
		<input type="button" name="edit2" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
	  <%}%> &nbsp;
        </div></td>
      <td width="6%" class="thinborder"> <div align="center">
	  <%if(iAccessLevel == 2){%>
		<input type="button" name="delete" value="Delete" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">		
	  <%}%>&nbsp;
        </div></td>
    </tr>
    <%}%>
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
<input type="hidden" name="print_page">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
