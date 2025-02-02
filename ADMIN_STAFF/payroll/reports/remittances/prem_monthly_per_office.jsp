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
<title>Monthly remittance per office</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;

//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./prem_monthly_per_office_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Remittances-Premium Per Office","prem_monthly_per_office.jsp");

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
														"prem_monthly_per_office.jsp");
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

Vector vRetResult = null;
PRRemittance PRRemit = new PRRemittance(request);

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};

double dTemp = 0d;
int i = 0;
int j = 0;
int iRecord = 0;
double dShare = 0d;
Vector vRows = null;
Vector vColumns = null;
Vector vRowCol = null;
int iRowCount = 0;
int iColCount = 0;
String strPremiumType = WI.getStrValue(WI.fillTextValue("premium_type"),"0");
String strPremiumName = "";
if(strPremiumType.equals("1")){
	strPremiumName = "SSS";
}else{
	strPremiumName = "Philhealth";
}

if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.generateRemitancesPerOffice(dbOP);
  if(vRetResult != null){
	vRows = (Vector)vRetResult.elementAt(0);
	vColumns = (Vector)vRetResult.elementAt(1);  
  }
}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./prem_monthly_per_office.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: <%=(strPremiumName).toUpperCase()%> PREMIUM MONTHLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="5"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="5"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td colspan="3"> <select name="month_of">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
    </tr>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3"><select name="employee_category" onChange="ReloadPage();">                    
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("employee_category").equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>          
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}%>
        </select> </td>
    </tr>
	<%}%>
    <!--
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> </td>
    </tr>    
		-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>Remittance for : </td>
	  <%
	  	strTemp = WI.fillTextValue("premium_type");
	  %>
      <td colspan="3"><select name="premium_type" onChange="ReloadPage();">
        <option value="0">Philhealth</option>
		<%if(strTemp.equals("1")){%>
		<option value="1" selected>SSS</option>
		<%}else{%>
		<option value="1">SSS</option>
		<%}%>
      </select></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font>			
			</td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
	<%if (vColumns != null && vColumns.size() > 0 && vRows != null && vRows.size() > 0 ){%>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td><hr size="1" color="#000000"></td>
      </tr>
      <tr>
        <td height="18"><div align="right"><font><a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      </tr>
    </table>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td colspan="4"><div align="center"><strong><%=strPremiumName%> Premiums - <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
      </tr>
      <tr>
        <td colspan="4" class="thinborderBOTTOM">&nbsp;</td>
      </tr>
    </table>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">      
      <tr>
        <td width="7%" class="thinborderBOTTOMLEFT">&nbsp;</td>
        <td width="11%" align="center" class="thinborderBOTTOMLEFT"><strong>Number of Employees </strong></td>
		<%for(j = 0;j < vColumns.size(); j ++){%>
        <td width="73%" align="center" class="thinborderBOTTOMLEFT"><strong><%=CommonUtil.formatFloat((String)vColumns.elementAt(j),true)%></strong></td>
		<%}%>
        <td width="9%" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong>AMOUNT</strong></td>
      </tr>
	  <%
	  for(i = 0; i < vRows.size();i+=8){
	  vRowCol = (Vector)vRows.elementAt(i+6);
	  dShare = 0d;		  
	  %>
      <tr>
	  	<%
			strTemp = (String)vRows.elementAt(i+2);
			if(strTemp != null && strTemp.equals("null"))
				strTemp = null;
			if(strTemp == null)
				strTemp = (String)vRows.elementAt(i+3);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRows.elementAt(i+4);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRows.elementAt(i+5);				
		%>
        <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
        <td height="18" class="thinborderBOTTOMLEFT"><div align="right"><%=(String)vRows.elementAt(i+7)%>&nbsp;</div></td>
		<%for(j = 0;j < vRowCol.size(); j+=2){
			strTemp = (String)vRowCol.elementAt(j);
			dShare += Integer.parseInt(strTemp) * Double.parseDouble((String)vRowCol.elementAt(j+1));
			if(strTemp.equals("0"))
				strTemp = "";
			
		%>
        <td class="thinborderBOTTOMLEFT"><div align="right"><%=strTemp%>&nbsp;</div></td>
		<%}%>
        <td class="thinborderBOTTOMLEFTRIGHT"><div align="right"><%=CommonUtil.formatFloat(dShare,true)%>&nbsp;</div></td>
      </tr>
	  <%}%>
    </table>
    <%} // if (vRetResult != null && vRetResult.size() > 0 )%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>