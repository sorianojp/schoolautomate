<%@ page language="java" import="utility.*,payroll.Priority,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>DEDUCTION PRIORITY SETTING</title>
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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
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
function ReloadPage() {
	document.form_.reloaded.value = "";
	document.form_.submit();
}
function CancelRecord(){
	location = "./deduction_priority.jsp";
}


</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Deduction Priority","deduction_priority.jsp");
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
														"deduction_priority.jsp");
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

	Priority prPriority = new Priority();
	Vector vRetResult = null;
	String strCodeIndex  = null;
	String strType = null;
	String strFieldType = null;
	int i = 0;
	String strPageAction = WI.fillTextValue("page_action");
	String strChecked = null;
	
	String[] astrConvertItemSource = {"","Miscellaneous Deduction", "Loans", "Contribution"};
	
	if(strPageAction.length() > 0){
		if(prPriority.operateOnDedPriority(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg =  prPriority.getErrMsg();
	}
	
	vRetResult  = prPriority.operateOnDedPriority(dbOP, request, 4);

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="deduction_priority.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: DEDUCTION PRIORITY SETTING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
   <!--
		<input type="hidden" name="item_type" value="0">
		 -->
		<%
			strFieldType = WI.fillTextValue("item_type");
			strFieldType = WI.getStrValue(strFieldType,"0");
		%>
		<%
		strType = WI.fillTextValue("dType");
		if(!strFieldType.equals("2")){%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%">Item Source </td>
      <td><font size="1">
        <select name="dType" onChange="ReloadPage();">
					<option value="">Select field</option>
 					<%if(strType.compareTo("1") == 0) {%>
          <option value="1" selected>Miscellaneous Deductions</option>
          <%}else{%>
					<option value="1">Miscellaneous Deductions</option>
          <%}%>
					<%if(strType.compareTo("2") == 0) {%>
          <option value="2" selected>Loans</option>
          <%}else{%>
          <option value="2">Loans</option>
          <%}%>
					<%if(strType.compareTo("3") == 0){%>
          <option value="3" selected>Contribution</option>
          <%}else{%>
          <option value="3">Contribution</option>
          <%}%>         
        </select>
      </font></td>
    </tr>
		<%}else{%>
			<input type="hidden" name="dType" value="4">
		<%}%>
		
		<%if(strType.equals("1")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Miscellaneous Deduction </td>
      <td><select name="deduct_index">
        <%strTemp= WI.fillTextValue("deduct_index");%>
        <option value="">Select Deduction Name</option>
        <%=dbOP.loadCombo("pre_deduct_index","pre_deduct_name", " from preload_deduction " +
				" where not exists(select * from pr_priority where misc_ded_index = pre_deduct_index)" +
				" order by pre_deduct_name", strTemp, false)%>
      </select></td>
    </tr>
		<%}else if(strType.equals("2")){%>		
    <tr>
      <td height="25">&nbsp;</td>
      <td>Loan</td>
			<%
				strCodeIndex = WI.fillTextValue("code_index");
			%>
	    <td>
			<select name="code_index">
          <option value="">Select Loan</option>
          <%=dbOP.loadCombo("code_index","loan_name, loan_code",
		                    " from ret_loan_code where is_valid = 1 and loan_type > 1 " +
												" and not exists(select * from pr_priority where loan_index = code_index)" +
												" order by loan_code", strCodeIndex ,false)%>
        </select>			</td>
    </tr>
		<%}else if(strType.equals("3")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Contribution</td>
      <td><select name="cont_index">
        <%=dbOP.loadCombo("BENEFIT_INDEX","BENEFIT_NAME,SUB_TYPE", " from HR_BENEFIT_INCENTIVE " +
			 " join HR_PRELOAD_BENEFIT_TYPE on (HR_PRELOAD_BENEFIT_TYPE.BENEFIT_TYPE_INDEX = "+
    	 " HR_BENEFIT_INCENTIVE.BENEFIT_TYPE_INDEX) where IS_INCENTIVE = 0 and COVERAGE_UNIT = 2 "+
       " and IS_BENEFIT = 0 and BENEFIT_NAME not in ('loans','loan') and is_valid = 1 " +
			 " and is_del = 0 and not exists(select * from pr_priority " +
			 "     where cont_index = BENEFIT_INDEX )" +
			 " order by benefit_name",WI.fillTextValue("b_index"),false)%>
      </select></td>
    </tr>		
		<%}%>
 
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Order Number </td>
      <td><select name="order_no">
				<%for(i = 1;i < 81; i++){%>
				<%if(WI.fillTextValue("order_no").equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=i%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%></option>
				<%}%>
				<%}%>
      </select>			</td>
    </tr>
   <!-- <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Note: <br>
      1. Items that were not included in the prioritization will be given the highest priority.</td>
    </tr>-->
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td width="77%" height="25">
			<%if(iAccessLevel > 1){%>
			<font size="1">
        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        Click to save entries 
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
      Click to clear </font>
			<%}%>			</td>
    </tr>
	<tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    
    <tr>
      <td width="10%" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold"> Count </span></td> 
      <td width="20%" align="center" class="thinborder" style="font-size:9px; font-weight:bold;">Item Source </td>
      <td width="55%" height="25" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Deduction name</span></td>
      <%if(WI.fillTextValue("is_for_sheet").equals("0")){%>
			<%}%>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
		<%for(i = 0; i < vRetResult.size();i+=7){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td> 
      <td class="thinborder">&nbsp;<%=astrConvertItemSource[Integer.parseInt((String)vRetResult.elementAt(i + 3))]%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
       <td class="thinborder" align="center">&nbsp;
			 <%if(iAccessLevel == 2){%>
	  		<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>	  
			 <%}%>		</td>
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
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="reloaded" value="<%=WI.fillTextValue("reloaded")%>">
<input type="hidden" name="is_for_sheet" value="<%=WI.fillTextValue("is_for_sheet")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
