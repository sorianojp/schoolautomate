<%@ page language="java" import="utility.*,java.util.Vector" %>
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
function AjaxMapName() {
	
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
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function ReloadPage(){
	document.form_.search_employee.value = "";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function SearchEmployee(){
	document.form_.search_employee.value = "1";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function PrintPage(strID){
	document.form_.employee_to_print.value = strID;
	document.form_.print_page.value = "1";
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" 	method="post" action="contribution_certificate.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	if(WI.fillTextValue("print_page").length()  >0){%>
	<jsp:forward page="./contribution_certificate_print.jsp"></jsp:forward>
	<%return;}
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Certificate of Contribution","contribution_certificate.jsp");
								
		
		
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
														"contribution_certificate.jsp");
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

request.getSession(false).removeAttribute("contribution_emp_list");

String strContributionEmpList = null;

payroll.PRContributionReport PRContribute = new payroll.PRContributionReport();	


int iElemCount = 0;
Vector vRetResult = null;

if(WI.fillTextValue("search_employee").length() > 0){
	vRetResult = PRContribute.getEmployeeListForCertification(dbOP, request);
	if(vRetResult == null)
		strErrMsg = PRContribute.getErrMsg();
	else
		iElemCount = PRContribute.getElemCount();
}



%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PAYROLL -  REPORTS - CONTRIBUTION CERTIFICATE PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;<font size="1"><a href="../remittances/remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	
    
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="22%" height="25"><strong><u>Print by :</u></strong></td>
      <td width="75%" height="25">&nbsp;</td>
    </tr>
	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr>
        <td height="25">&nbsp;</td>
        <td height="25">Transaction Type</td>
		<%
		String[] astrTrasanctionType = {"Select Transaction Type","PHILHEALTH","PAGIBIG PREMIUM",
					"PAGIBIG LOAN","SSS PREMIUM","SSS LOAN"};
		%>
        <td height="25">
		<select name="transaction_type" onChange="ReloadPage();">
		<%
		strTemp = WI.fillTextValue("transaction_type");
		for(int i =1 ; i < astrTrasanctionType.length; ++i){
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
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="25"><select name="c_index" onChange="ReloadPage();" style="width:400px;">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 order by c_name", strCollegeIndex,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Office</td>
      <td height="26"><select name="d_index" onChange="ReloadPage();" style="width:400px;">
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
      <td height="25">Employee ID </td>
      <td height="25"><input name="emp_id" type="text" size="16"maxlength="128" value="<%=WI.fillTextValue("emp_id")%>"
											onKeyUp="AjaxMapName();">
											&nbsp;
											<label id="coa_info" style="position:absolute; width:400px;"></label>	</td>
    </tr>
	<tr>
        <td height="26">&nbsp;</td>
        <td height="26">Month & Year from</td>
        <td height="26">
		        	
		<select name="month_of_from" onChange="ReloadPage();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of_from"))%> 
        </select>
        - 
        <input name="year_of_from" type="text" size="4" maxlength="4" class="textbox" value="<%=WI.fillTextValue("year_of_from")%>" 
		 onKeyUp="AllowOnlyInteger('form_','year_of_from')"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'; AllowOnlyInteger('form_','year_of_from')">		
		</td>
    </tr>
	<tr>
        <td height="26">&nbsp;</td>
        <td height="26">Month & Year to</td>
        <td height="26">
		        	
		<select name="month_of_from" onChange="ReloadPage();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of_to"))%> 
        </select>
        - 
        <input name="year_of_to" type="text" size="4" maxlength="4" class="textbox" value="<%=WI.fillTextValue("year_of_to")%>" 
		 onKeyUp="AllowOnlyInteger('form_','year_of_to')"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'; AllowOnlyInteger('form_','year_of_to')">		
		</td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26"><font size="1">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000; width:100px;" onClick="javascript:SearchEmployee();">
        click 
      to display employee list to print.</font></td>
    </tr>
    
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	<tr><td align="right">
	<a href="javascript:PrintPage('');"><img src="../../../../images/print.gif" border="0"></a>
	<font size="1">Click to print batch</font>
	</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    							
    <tr bgcolor="#B9B292" class="thinborder"> 
      <td height="23" colspan="5" align="center"><b>LIST OF EMPLOYEES FOR PRINTING</b></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" colspan="2" align="center"><strong>EMPLOYEE ID</strong></td>
      <td class="thinborder" width="29%" align="center"><strong>EMPLOYEE NAME</strong></td>			
      <td class="thinborder" width="43%" align="center"><strong>DEPARTMENT/OFFICE</strong></td>
      <td class="thinborder" width="8%" align="center">&nbsp;</td>
    </tr>
    <%
	int i =0 ;
	int iCount = 0;
	for(i = 0, iCount = 0; i < vRetResult.size(); i += iElemCount){	
	
	if(strContributionEmpList == null)
		strContributionEmpList = (String)vRetResult.elementAt(i);
	else
		strContributionEmpList += "," +(String)vRetResult.elementAt(i);
				
	%>
	
    <tr bgcolor="#FFFFFF" class="thinborder"> 
      <td class="thinborder" width="4%">&nbsp;<%=++iCount%>.</td>
      <td class="thinborder" width="16%" height="25">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
	  <%
	  strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),5);
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp).toUpperCase()%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6), WI.getStrValue((String)vRetResult.elementAt(i + 5))).toUpperCase()%></td>
      <td class="thinborder" align="center"><a href="javascript:PrintPage('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/print.gif" border="0"></a></td>
    </tr>
    <%} // end for loop%>	
		<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>

<%}
if(strContributionEmpList != null && strContributionEmpList.length() > 0)
	request.getSession(false).setAttribute("contribution_emp_list", strContributionEmpList);
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
<tr><td height="25" colspan="2">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25" colspan="2" class="footerDynamic">&nbsp;</td></tr>
</table>  
  
<input type="hidden" name="print_page">
<input type="hidden" name="employee_to_print" value="<%=WI.fillTextValue("employee_to_print")%>">
<input type="hidden" name="search_employee">  
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>