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
<title>Additional month pay generation</title>
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
function ReloadPage()
{	
	this.SubmitOnce('form_');
}
function SearchEmployee(){
	document.form_.searchEmployee.value = "1";
	this.SubmitOnce('form_');
}
function PrintPg() {
	var obj = document.getElementById('myADTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	alert("Click OK to print this report.");
	window.print();
}

//all about ajax - to display student list with same name.
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PRAddlPay"%>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
//add security here.

try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Additional Month List","addl_month_projection_uph.jsp");

	} catch(Exception exp){
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
														"PAYROLL","DTR",request.getRemoteAddr(),
														"addl_month_projection_uph.jsp");
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

//end of authenticaion code.

PRAddlPay prAddl = new PRAddlPay();
Vector vRetResult = null;
int i = 0;

if(WI.fillTextValue("searchEmployee").equals("1")){
	vRetResult = prAddl.getAddlMonthPayProjectionUPH(dbOP,request);
  	if(vRetResult == null)
		strErrMsg = prAddl.getErrMsg();
	
}
  
if(strErrMsg == null) 
	strErrMsg = "";


String strSchName  = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddr1    = SchoolInformation.getAddressLine1(dbOP,false,false);
String strAddr2    = SchoolInformation.getAddressLine2(dbOP,false,false);
String strTitle    = "13th Month Projection for January - November "+WI.fillTextValue("year_of");
String strDateTime = WI.getTodaysDateTime();

%>

<body bgcolor="#FFFFFF">
<form name="form_" method="post" action="./addl_month_projection_uph.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr > 
      <td height="25" colspan="4" align="center"><font color="#000000" ><strong>:::: PAYROLL: ADDITIONAL MONTH PAY PROJECTION ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="4"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%">Year</td>
      <td width="31%"><select name="year_of" onChange="ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> </select></td>
      <td width="50%" style="font-size:9px;">&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <%
		strTemp = WI.fillTextValue("pt_ft");
		strTemp= WI.getStrValue(strTemp);
	  %>
      <td colspan="2"><select name="pt_ft" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strTemp.equals("0")){%>
          <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if (strTemp.equals("1")){%>
          <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
          <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>
    
    <%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <%
	 	strTemp = WI.fillTextValue("employee_category");
		strTemp= WI.getStrValue(strTemp);
	  %>
      <td colspan="2"> <select name="employee_category" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strTemp.equals("0")){%>
          <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}else if (strTemp.equals("1")){%>
          <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>
          <%}else{%>
          <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}%>
        </select> </td>
    </tr>
    <%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee ID </td>
      <td colspan="2"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> 
        <label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();"></td>
      <td style="font-size:9px;" align="right"> Number of Employees / rows Per Page :
        <select name="num_rec_page">
		   <option value="1000000">All in one page</option>
          <% int iRowsPerPg = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=45 ; i++) {
				if ( i == iRowsPerPg) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
        <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> click to print</td>
    </tr>
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>		
  </table>
<% if(vRetResult != null && vRetResult.size() > 0  ) {
int iRowCount    = 0;
int iCurRowCount = 0;
int iPageNo = 0;

	while(vRetResult.size() > 0) {
		iCurRowCount = 0;
		if(iPageNo > 0) {%>
			<DIV style="page-break-before:always" >&nbsp;</DIV>
		<%}%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td align="center"><font size="2"><strong><%=strSchName%></strong></font><br>
		   <font size="1">
				<%=strAddr1%><br><%=strAddr2%><br><strong><%=strTitle%></strong>
				<div align="right">
					Date and Time Printed: <%=strDateTime%> &nbsp;&nbsp; &nbsp; &nbsp; Page# <%=++iPageNo%> <!--of <%//=iTotalPages%>-->
				</div>
		   </font></td>
	  </tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr align="center" style="font-weight:bold">
		  <td width="4%" class="thinborder" style="font-size:9px;">Count</td> 
		  <td width="11%" class="thinborder" height="20" style="font-size:9px;">Employee ID </td>
		  <td width="25%" class="thinborder" style="font-size:9px;">Employee Name </td>
		  <td width="10%" class="thinborder" style="font-size:9px;">Account No.</td>
		  <td width="10%" class="thinborder" style="font-size:9px;">Basic Pay </td>
		  <td width="10%" class="thinborder" style="font-size:9px;">Salary Adj. </td>
		  <td width="10%" class="thinborder" style="font-size:9px;">Overload Adj </td>
		  <td width="10%" class="thinborder" style="font-size:9px;">Overload(hs/gs)</td>
		  <td width="10%" class="thinborder" style="font-size:9px;">Tutorial</td>
		  <td width="10%" class="thinborder" style="font-size:9px;">Total</td>
		</tr>
		<%while(vRetResult.size() > 0) {%>
			<tr>
			  <td class="thinborder" style="font-size:9px;"><%=++iRowCount%></td>
			  <td class="thinborder" height="20" style="font-size:9px;"><%=vRetResult.elementAt(0)%></td>
			  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(1)%></td>
			  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(2)%></td>
			  <td class="thinborder" style="font-size:9px;" align="right"><%=vRetResult.elementAt(3)%></td>
			  <td class="thinborder" style="font-size:9px;" align="right"><%=vRetResult.elementAt(4)%></td>
			  <td class="thinborder" style="font-size:9px;" align="right"><%=vRetResult.elementAt(5)%></td>
			  <td class="thinborder" style="font-size:9px;" align="right"><%=vRetResult.elementAt(6)%></td>
			  <td class="thinborder" style="font-size:9px;" align="right"><%=vRetResult.elementAt(7)%></td>
			  <td class="thinborder" style="font-size:9px;" align="right"><%=vRetResult.elementAt(8)%></td>
			</tr>
		<%vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
			++iCurRowCount;
		   if(iCurRowCount >= iRowsPerPg) 
				break;//create page break;
		}%>
  </table>  
  <%}//end of outer while -- for page break%>
  
<%} // end if vRetResult != null && vRetResult.size() %>

  <input type="hidden" name="searchEmployee">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>