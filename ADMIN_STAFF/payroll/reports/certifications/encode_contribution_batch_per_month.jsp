<%@ page language="java" import="utility.*,java.util.Vector, java.util.Calendar" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function AjaxMapName(e) {
	if(e.KeyCode == '13'){
		document.form_.submit();
	}
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");	
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";	
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");		
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+escape(strCompleteName);

	this.processRequest(strURL);
	
}

function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this information?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.searchEmployee.value = "1";
	document.form_.submit();
}

function CleanUP(){
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.searchEmployee.value = "";
	document.form_.submit();
}

function checkAllSaveItems() {
	var maxDisp = document.form_.contribution_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i<= maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function SearchEmployee(){
	document.form_.searchEmployee.value = "1";
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" 	method="post" action="encode_contribution_batch_per_month.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Certificate of Contribution","phic_certificate_contribution.jsp");
								
		
		
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"phic_certificate_contribution.jsp");
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

java.sql.ResultSet rs = null;
payroll.PRContributionReport PRContribute = new payroll.PRContributionReport();	

Vector vRetResult = null;

int iElemCount = 0;


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(!PRContribute.encodeContributionBatch(dbOP, request))
		strErrMsg =PRContribute.getErrMsg();
	else
		strErrMsg = "Employee contribution successfully saved.";
	
}


if(WI.fillTextValue("searchEmployee").length() > 0){			
		
	vRetResult =  PRContribute.getMonthlyContributionBatch(dbOP,request);
	if(vRetResult == null)
		strErrMsg = PRContribute.getErrMsg();
	else	
		iElemCount = PRContribute.getElemCount();
	
}
String[] astrMonth = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PAYROLL - ENCODING OF CONTRIBUTION PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;<font size="1"><a href="../remittances/remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
	<tr>
        <td height="25">&nbsp;</td>
        <td>Transaction Type</td>
		<%
		String[] astrTrasanctionType = {"Select Transaction Type","PHILHEALTH","PAGIBIG PREMIUM",
					"PAGIBIG LOAN","SSS PREMIUM","SSS LOAN"};
		%>
        <td>
		<select name="transaction_type" onChange="CleanUP();">
		<%
		strTemp = WI.fillTextValue("transaction_type");
		for(int i =0 ; i < astrTrasanctionType.length; ++i){
			if(strTemp.equals(Integer.toString(i)))
				strErrMsg = "selected";
			else
				strErrMsg = "";
		%>
		<option value="<%=i%>" <%=strErrMsg%>><%=astrTrasanctionType[i]%></option>
		<%}%>
		</select>		</td>
    </tr>
<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="18%">Month and Year</td>
      <td width="79%">        	
		<select name="month_of" onChange="CleanUP();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <input name="year_of" type="text" size="4" maxlength="4" class="textbox" value="<%=WI.fillTextValue("year_of")%>" 
		 onKeyUp="AllowOnlyInteger('form_','year_of')"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'; AllowOnlyInteger('form_','year_of')">		</td>
    </tr>
	<%
	String strCollegeIndex = WI.fillTextValue("c_index");
	%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="25"><select name="c_index" onChange="CleanUP();" style="width:400px;">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 order by c_name", strCollegeIndex,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Office</td>
      <td height="26"><select name="d_index" onChange="CleanUP();" style="width:400px;">
          <option value="">ALL</option>
		  <%
		  strTemp = " from department where is_del= 0 ";
		  if(strCollegeIndex.length() > 0)
		  	strTemp += " and c_index = " + strCollegeIndex;
		  else
		  	strTemp += " and (c_index is null or c_index = 0) ";
			strTemp += " order by d_name";
		  %>
          
          <%=dbOP.loadCombo("d_index","d_name", strTemp , WI.fillTextValue("d_index"),false)%> 
          
        </select></td>
    </tr>	
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td><input type="image" name="_1" src="../../../../images/form_proceed.gif" border="0" onClick="SearchEmployee()"></td>
	    </tr>
</table>
<%



if(vRetResult != null && vRetResult.size() > 0){
%> 

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="18%">OR Number</td>
		<td>
		<input name="or_number" type="text" size="16" maxlength="32"  value="<%=WI.fillTextValue("or_number")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'"
		  onBlur="style.backgroundColor='white';">		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Date Paid</td>
	    <td><input name="date_paid" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_paid")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_paid');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
	    </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center" height="25"><strong>LIST OF EMPLOYEE'S <%=astrTrasanctionType[Integer.parseInt(WI.fillTextValue("transaction_type"))]%> 
		CONTRIBUTION FOR <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></td></tr>
</table>    

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
	    <td width="5%" align="center" class="thinborder"><strong>COUNT</strong></td>
		<td width="33%" height="23" class="thinborder"><strong>EMPLOYEE NAME/ID</strong></td>
		<td width="30%" class="thinborder"><strong>DEPARTMENT</strong></td>
		<td width="13%" class="thinborder"><strong>EMPLOYEE</strong></td>
		<td width="13%" class="thinborder"><strong>EMPLOYER</strong></td>
		<td width="6%" class="thinborder" align="center"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
	</tr>
	<%
	String strInfoIndex = null;
	int iCount =0;
	for(int i = 0; i < vRetResult.size(); i += iElemCount){
	
	strInfoIndex = WI.getStrValue((String)vRetResult.elementAt(i));
	%>
	<tr>
	    <td class="thinborder" align="right"><%=++iCount%>.</td>		
		<input type="hidden" name="contribution_index_<%=iCount%>" value="<%=strInfoIndex%>">
		<input type="hidden" name="emp_index_<%=iCount%>" value="<%=WI.getStrValue((String)vRetResult.elementAt(i+1))%>">
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),5);
		%>
		<td height="20" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp).toUpperCase()%></td>
		<td height="20" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),(String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+8));
		%>
		<td class="thinborder">
		<input name="ee_share_<%=iCount%>" type="text" size="16" maxlength="32" style="text-align:right" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" 
		  onKeyUp="AllowOnlyFloat('form_','ee_share_<%=iCount%>')"
		  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','ee_share_<%=iCount%>')">		</td>
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+9));
		%>
		<td class="thinborder">		
		<input name="er_share_<%=iCount%>" type="text" size="16" maxlength="32" style="text-align:right" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" 
		  onKeyUp="AllowOnlyFloat('form_','er_share_<%=iCount%>')"
		  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','er_share_<%=iCount%>')"></td>		
		<td class="thinborder" align="center"><input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1"></td>
	</tr>
	<%}%>
	<input type="hidden" name="contribution_count" value="<%=iCount%>">
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center">
		<a href="javascript:PageAction(1,'')"><img src="../../../../images/update.gif" border="0"></a>
		<font size="1">Click to update contribution payments</font>
	</td></tr>
</table>
<%}

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
<tr><td height="25" colspan="2">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25" colspan="2" class="footerDynamic">&nbsp;</td></tr>
</table>  
  
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  
  <input type="hidden" name="batch_encoding" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>