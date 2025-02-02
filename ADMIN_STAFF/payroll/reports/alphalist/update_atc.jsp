<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update ATC</title>
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
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
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
	location = "update_atc.jsp";
}

function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
		document.form_.opner_form_field_value.value;
<% }%>	
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}

function UpdateToZero(strTextName){
	if(eval('document.form_.'+strTextName+'.value.length') == 0){		
		eval('document.form_.'+strTextName+'.value= "0"');
	}	
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
								"Admin/staff-Payroll-REPORTS-Post Deductions","update_atc.jsp");

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
															"PAYROLL","REPORTS",request.getRemoteAddr(),
															"update_atc.jsp");
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
Vector vInfoEdit = null;
Vector vRetResult  = null;

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strLastEntry = WI.getStrValue(WI.fillTextValue("opner_form_field_value"),"0");
		
if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (AtcCode.operateOnATCCode(dbOP,0) != null){
			strErrMsg = " Record removed successfully ";
		}else{
			strErrMsg = AtcCode.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (AtcCode.operateOnATCCode(dbOP,1) != null){
			strErrMsg = " Record posted successfully ";
		}else{
			strErrMsg = AtcCode.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (AtcCode.operateOnATCCode(dbOP,2) != null){
			strErrMsg = " Record updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = AtcCode.getErrMsg();
		}
	}
}

if (strPrepareToEdit.length() > 0){
	vInfoEdit = AtcCode.operateOnATCCode(dbOP,3);
	if (vInfoEdit == null)
		strErrMsg = AtcCode.getErrMsg();
}
	vRetResult = AtcCode.operateOnATCCode(dbOP,4);
//	System.out.println("vRetResult " + vRetResult);

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="update_atc.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: UPDATE ATC CODE LIST ::::</strong></font></div></td>
    </tr>
	<tr> 
      <td width="770" height="10"><%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="2"><font size="3"><strong><a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></strong></font></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="8%" height="29">&nbsp;</td>
      <%
	  	if (vInfoEdit != null && vInfoEdit.size() > 0){
			strTemp = (String) vInfoEdit.elementAt(1);
		}else{
			strTemp = WI.fillTextValue("atc_code");
		}		
	  %>
      <td width="92%">ATC Code : 
        <input name="atc_code" type="text" size="16" maxlength="16" value="<%=WI.getStrValue(strTemp,"0")%>"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';">
	  </td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <%
	  	if (vInfoEdit != null && vInfoEdit.size() > 0){
			strTemp = (String) vInfoEdit.elementAt(2);
		}else{
			strTemp = WI.fillTextValue("inc_nature_index");
		}		
	  %>
      <td height="27">Nature of Income Payment : 
        <select name="inc_nature_index">
          <option value="">Select unit</option>
          <%=dbOP.loadCombo("INCOME_NAT_INDEX","INCOME_NATURE"," from PR_PRELOAD_INC_NATURE order by INCOME_NATURE", strTemp, false)%> </select> <font size="1"><a href='javascript:viewList("PR_PRELOAD_INC_NATURE","INCOME_NAT_INDEX","INCOME_NATURE","NATURE OF INCOME",
		"PR_ATC_LIST","INCOME_NAT_INDEX","","","inc_nature_index")'><img src="../../../../images/update.gif" border="0"></a> 
        click to update list of Nature of Income</font></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <%
	  	if (vInfoEdit != null && vInfoEdit.size() > 0){
			strTemp = (String) vInfoEdit.elementAt(3);
		}else{
			strTemp = WI.fillTextValue("tax_rate");
		}		
	  %>
      <td height="27">Tax Rate(%) : 
        <input name="tax_rate" type="text" size="8" maxlength="8" onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=WI.getStrValue(strTemp,"0")%>" onKeyUp="AllowOnlyFloat('form_','tax_rate');"	 
       	onBlur="AllowOnlyFloat('form_','tax_rate');style.backgroundColor='white';UpdateToZero('tax_rate')"> 
      </td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td height="27">&nbsp;</td>
    </tr>
    <tr> 
      <td height="48" colspan="2"> <div align="center">
          <% if (iAccessLevel > 1) { 
		if (vInfoEdit == null) {%>
          <a href="javascript:AddRecord();"><img src="../../../../images/save.gif" width="48" height="28" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
          to add</font> 
          <%}else{%>
          <a href="javascript:EditRecord();"><img src="../../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
          to save changes</font> 
          <%}%>
          <a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" border="0"></a> 
          <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to 
          cancel or go previous</font> 
          <%} //end iAccessLevel > 1%>
        </div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%" height="28">&nbsp;</td>
      <td width="96%" height="28">&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult!= null && vRetResult.size() > 0){ %>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr bgcolor="#666666"> 
      <td height="24" colspan="5"><div align="center"><strong><font color="#FFFFFF">:: 
          LIST OF EXISTING ATC CODE ::</font></strong></div></td>
    </tr>
    <tr> 
      <td width="14%" height="30"><div align="center"><font size="1"><strong>ATC 
      CODE </strong></font></div></td>
      <td width="49%"><div align="center"><font size="1"><strong>NATURE OF INCOME 
      PAYMENT</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>TAX RATE </strong></font></div></td>
      <td colspan="2"><div align="center"><font size="1"><strong>OPTION</strong></font></div></td>
    </tr>
    <%	
	  for(int i = 0; i < vRetResult.size(); i+=5){
    %>
    <tr> 
      <td>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
      <td height="30">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"","%","&nbsp;")%></td>
      <td width="11%"><div align="center"><font size="1"><a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/edit.gif" border=0 ></a> 
          </font></div></td>
      <td width="11%"><div align="center"><a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/delete.gif" border=0></a></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr> 
      <td height="24" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
  <input type="hidden" name="prepareToEdit" value="<%=WI.fillTextValue("prepareToEdit")%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
    <!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <input type="hidden" name="opner_form_field" value="<%=WI.fillTextValue("opner_form_field")%>">
  <input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">
  <input type="hidden" name="opner_form_field" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_field"),"")%>">
  <input type="hidden" name="opner_form_field_value" value="<%=strLastEntry%>">
  <!-- this is very important - onUnload do not call close window -->

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>