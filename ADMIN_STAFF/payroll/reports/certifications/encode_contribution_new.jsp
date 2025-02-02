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
	document.form_.submit();
}

function CleanUP(){
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();
}

function checkAllSaveItems() {
	var maxDisp = document.form_.contribution_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =0; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="document.form_.emp_id.focus();">
<form name="form_" 	method="post" action="encode_contribution_new.jsp">
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
payroll.PRSalaryExtn salaryExtn = new payroll.PRSalaryExtn();	
payroll.PRContributionReport PRContribute = new payroll.PRContributionReport();	

Vector vRetResult = null;
Vector vUserDetail = null;
String strEmpID = WI.fillTextValue("emp_id");
String strEmployeeIndex = null;
int iDOEYear = 0;
int iElemCount = 0;


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(PRContribute.operateOnContributionEncoding(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg =PRContribute.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Information successfully removed.";
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully saved.";
	} 
}


if(strEmpID.length() > 0){
	strEmployeeIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));	
	
	vUserDetail = salaryExtn.getEmployeeInfo(dbOP, strEmployeeIndex);	
	if(vUserDetail == null)
		strErrMsg = salaryExtn.getErrMsg();
	else{
		strTemp = "select DOE from info_faculty_basic where IS_VALID =1 "+
					" and USER_INDEX = "+strEmployeeIndex;
		rs = dbOP.executeQuery(strTemp);
		Calendar cal = Calendar.getInstance();
		if(rs.next()) {
			cal.setTime(rs.getDate(1));
			iDOEYear = cal.get(Calendar.YEAR);
		}rs.close();	
		
		cal = Calendar.getInstance();
		iDOEYear = cal.get(Calendar.YEAR) - iDOEYear;
		if(iDOEYear <= 0)
			iDOEYear = 2;
			
		//vRetResult =  PRContribute.operateOnContributionEncoding(dbOP,request,4);
		vRetResult =  PRContribute.getEmployeeMonthlyContribution(dbOP,request,strEmployeeIndex);
		if(vRetResult != null && vRetResult.size() > 0)
			iElemCount = PRContribute.getElemCount();
	}
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
        <td width="45%">
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
        <td width="34%"><a href="encode_contribution.jsp">Go to other encoding format</a></td>
	</tr>
<!--    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="18%">Year</td>
      <td width="79%"> 
        		</td>
    </tr>-->
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%">Employee ID</td>
      <td colspan="2"><input name="emp_id" type="text" size="16" value="<%=strEmpID%>" class="textbox" onKeyUp="AjaxMapName(event);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a>	
				<label id="coa_info" style="position:absolute; width:400px;"></label>			</td>
    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2"><input type="image" name="_1" src="../../../../images/form_proceed.gif" border="0"></td>
	    </tr>
</table>
<%
if(vUserDetail != null && vUserDetail.size() > 0){
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
	<tr>
	    <td height="22">&nbsp;</td>
	    <td>Year</td>
	    <td>
		<select name="year_of" onChange="CleanUP();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),iDOEYear,1)%> 
        </select>
		</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    </tr>
	<tr>
      <td width="3%" height="22">&nbsp;</td>
      <td width="22%"> Name</td>
      <% 
			strTemp =WI.formatName((String)vUserDetail.elementAt(2),(String)vUserDetail.elementAt(3),(String)vUserDetail.elementAt(4),4); 
			%>
      <td><strong><%=WI.getStrValue(strTemp," ")%></strong></td>
      <td width="14%">Emp. Status</td>
      <%if(vUserDetail != null && vUserDetail.size() > 0 ){
	     	strTemp =(String)vUserDetail.elementAt(5);
			}else{
			  strTemp = "1";
			}
			if(strTemp.equals("1"))
				strTemp = "Full Time";
			else
				strTemp = "Part Time";				
	  %>
      <td width="35%">&nbsp;<strong><%=WI.getStrValue(strTemp," ")%></strong></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td> <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office</td>
      <%if((String)vUserDetail.elementAt(7) == null || (String)vUserDetail.elementAt(8) == null){
	    	 strTemp = " ";
			}else{
				strTemp = "-";
			}
			%>
      <td><strong><%=WI.getStrValue(vUserDetail.elementAt(7),"")%><%=strTemp%><%=WI.getStrValue(vUserDetail.elementAt(8),"")%></strong></td>
      <td>Emp. Type</td>
      <td>&nbsp;<strong	><%=WI.getStrValue((String)vUserDetail.elementAt(9),"")%></strong></td>
    </tr>
    <tr >
      <td height="7" colspan="7"><hr size="1" color="#0000FF"></td>
    </tr>
	</table>



  
  
<%
if(vRetResult != null && vRetResult.size() > 0){
%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center" height="25"><strong>LIST OF EMPLOYEE'S <%=astrTrasanctionType[Integer.parseInt(WI.fillTextValue("transaction_type"))]%> 
		CONTRIBUTION FOR <%=WI.fillTextValue("year_of")%></strong></td></tr>
</table>    

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="23" class="thinborder"><strong>MONTH</strong></td>
		<td width="18%" class="thinborder"><strong>EMPLOYEE</strong></td>
		<td width="18%" class="thinborder"><strong>EMPLOYER</strong></td>
		<td width="18%" class="thinborder"><strong>OR NUMBER</strong></td>
		<td width="18%" class="thinborder"><strong>DATE PAID</strong></td>		
		<td width="6%" class="thinborder" align="center"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
	</tr>
	<%
	String strInfoIndex = null;
	int iCount =0;
	for(int i = 0; i < vRetResult.size(); i += iElemCount, ++iCount){
	
	strInfoIndex = WI.getStrValue((String)vRetResult.elementAt(i));
	%>
	<tr>
		<input type="hidden" name="month_of_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+3)%>">
		<input type="hidden" name="contribution_index_<%=iCount%>" value="<%=strInfoIndex%>">
		<td class="thinborder" height="20"><%=astrMonth[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+1);
		%>
		<td class="thinborder">
		<input name="ee_share_<%=iCount%>" type="text" size="16" maxlength="32" style="text-align:right" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" 
		  onKeyUp="AllowOnlyFloat('form_','ee_share_<%=iCount%>')"
		  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','ee_share_<%=iCount%>')">
		</td>
		<%
		strTemp = (String)vRetResult.elementAt(i+2);
		%>
		<td class="thinborder">		
		<input name="er_share_<%=iCount%>" type="text" size="16" maxlength="32" style="text-align:right" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" 
		  onKeyUp="AllowOnlyFloat('form_','er_share_<%=iCount%>')"
		  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','er_share_<%=iCount%>')"></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+4));
		%>
		<td class="thinborder">
		<input name="or_number_<%=iCount%>" type="text" size="16" maxlength="32"  value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'"
		  onBlur="style.backgroundColor='white';">
		</td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+5));
		%>
		<td class="thinborder">
		<input name="date_paid_<%=iCount%>" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_paid_<%=iCount%>');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
		</td>
		<td class="thinborder" align="center">				
				<input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1"></td>
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

}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
<tr><td height="25" colspan="2">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25" colspan="2" class="footerDynamic">&nbsp;</td></tr>
</table>  
  
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>