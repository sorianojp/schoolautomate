<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRSalaryRate, payroll.PRAllowances" %>
<%
	//added code for HR/companies.
	boolean bolIsSchool = false;
	WebInterface WI = new WebInterface(request);
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasConfidential = false;
	boolean bolHasTeam = false;
	String[] strColorScheme = {};
	
	if(WI.fillTextValue("from_pr").equals("1"))
		strColorScheme = CommonUtil.getColorScheme(6);
	else
		strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary Rate Searching</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.show_result.value="";
	document.form_.submit();
}
//  about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		
		var layer_ = document.getElementById("processing_");
		var objCOAInput = document.getElementById("coa_info");
		 
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		layer_.style.display = 'block';

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
						 		 "&name_format=4&complete_name="+escape(strCompleteName);

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

</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-SALARY RATE-Salary Rate Days-Yr","salary_rate_eac_daysyr.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"PAYROLL","SALARY RATE",
											request.getRemoteAddr(),"salary_rate_eac_daysyr.jsp");
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
Vector vRetResult  = null;
int iRowsDisplayed = 0;
PRSalaryRate prsal = new PRSalaryRate();

boolean bolShowWithNoRecord = false;
if(WI.fillTextValue("show_with_noinfo").length() > 0) 
	bolShowWithNoRecord = true;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(prsal.operateOnSalaryRateDaysPerYr(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = prsal.getErrMsg();
	else	
		strErrMsg = "Information successfully updated.";
}

if(WI.fillTextValue("show_result").length() > 0) {
	vRetResult = prsal.operateOnSalaryRateDaysPerYr(dbOP, request, 4);
	if(strErrMsg == null && vRetResult == null)
		strErrMsg = prsal.getErrMsg();
}	

%>
<form action="./salary_rate_eac_daysyr.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" class="footerDynamic"><font color="#FFFFFF"><strong>:::: SALARY RATE DAYS-YR INFORMATION ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td height="18" colspan="2" style="font-size:14px; font-weight:bold; color:#FF0000">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10" width="16%">&nbsp;Employee ID </td>
      <td width="38%"><input name="emp_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=WI.fillTextValue("emp_id")%>" size="16"></td>
      <td width="46%">&nbsp; 
				<div style="position:absolute; overflow:auto; width:300px; height:225px; display:none;" id="processing_">
				<label id="coa_info"></label>
				</div>			</td>
    </tr>
    
    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td colspan="2"><select name="d_index">
        <option value=""> &nbsp;</option>
        <%
			if (WI.fillTextValue("c_index").length() > 0) 
				strTemp = "  c_index = " + WI.fillTextValue("c_index");
			else 
				strTemp = "  (c_index is null or c_index  = 0)";

		%>
        <%=dbOP.loadCombo("d_index", "d_name"," from department where "+ strTemp  +" and is_del = 0 order by d_name",WI.fillTextValue("d_index"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25" colspan="3" class="fontsize10">&nbsp; 
	  <input type="checkbox" name="show_with_noinfo" value="checked" <%=WI.fillTextValue("show_with_noinfo")%>> 
	  Show Employee Without Days-Yr Information</td>
    </tr>
    <tr>
      <td height="25" colspan="3" class="fontsize10" align="center">
  	  <a href="#"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0" onClick="document.form_.show_result.value='1';document.form_.submit()"></a></td>
    </tr>
    <tr> 
      <td height="14" colspan="3" class="fontsize10"><hr size="1" noshade></td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292" align="center">
	  	<strong><font color="#FFFFFF">SEARCH RESULT</font></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="6%" height="25" class="thinborder">Count</td>
      <td width="27%" class="thinborder">Employee ID </td>
      <td width="41%" class="thinborder">Employee Name </td>
      <td width="21%" class="thinborder">Days-Year Set </td>
      <td width="5%" class="thinborder">Select</td>
    </tr>
<%for(int i =0; i < vRetResult.size(); i += 4) {%>
    <tr>
      <td height="25" class="thinborder"><%=iRowsDisplayed + 1%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "Not yet Set")%></td>
      <td class="thinborder"><input type="checkbox" name="user_index_<%=iRowsDisplayed++%>" value="<%=vRetResult.elementAt(i)%>" checked="checked"></td>
    </tr>
<%}%>

    
  </table>
<%if(bolShowWithNoRecord){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center" style="font-size:11px;">
	  Number of Days/Year
	    <input name="days_yr" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("days_yr")%>" size="16">
	  &nbsp;&nbsp;&nbsp;&nbsp;
	    <input type="submit" name="1" value="&nbsp;&nbsp; Set Days-Yr and update Salalry Information &nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'; document.form_.page_action.value='1'">
	  </td>
    </tr>
 </table>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center">
	  <input type="submit" name="1" value="&nbsp;&nbsp;Remove Days-Yr Information &nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'; document.form_.page_action.value='0'">
	 </td>
    </tr>
 </table>
<%}%>

<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="show_result" value="<%=WI.fillTextValue("show_result")%>">
<input type="hidden" name="rows_display" value="<%=iRowsDisplayed%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>