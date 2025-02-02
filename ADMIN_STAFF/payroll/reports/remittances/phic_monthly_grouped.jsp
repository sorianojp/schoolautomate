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
<title>PhilHealth Monthly Remmitance</title>
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

function ForwardTo(){
//	document.form_.forward_ungrouped.value = "1";
//	document.form_.print_pg.value = "";
//	this.SubmitOnce('form_');
location = "./sss_monthly_unsort.jsp?month_of="+document.form_.month_of.value+
					 "&year_of="+document.form_.year_of.value+
					 "&pt_ft="+document.form_.pt_ft.value+
					 "&employee_category="+document.form_.employee_category.value+
					 "&employer_index="+document.form_.employer_index.value+
					 "&c_index="+document.form_.c_index.value+
					 "&d_index="+document.form_.d_index.value+
					 "&searchEmployee=1&grouped=0";
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
	boolean bolHasTeam = false;	
	boolean bolHasInternal = false;
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./sss_monthly_print.jsp" />
<% return;}
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
										"Admin/staff-Payroll-Reports-Remittances-SSS Premium","sss_monthly.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");		
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
														"sss_monthly.jsp");
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
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};

double dTemp = 0d;
double dLineTotal = 0d;
double dOfficeTotal = 0d;
double dStatusTotal = 0d;
double dGrandTotal = 0d;

double dEEOfficeTotal = 0d;
double dEROfficeTotal = 0d;
double dECOfficeTotal = 0d;

double dEEStatusTotal = 0d;
double dERStatusTotal = 0d;
double dECStatusTotal = 0d;

double dEEGrandTotal = 0d;
double dERGrandTotal = 0d;
double dECGrandTotal = 0d;


boolean bolPtFtHeader = true;
boolean bolShowHeader = true;

boolean bolPtFtTotal = false;
boolean bolOfficeTotal = false;

String strCurColl = "";
String strNextColl = "";
String strCurDept = "";
String strNextDept = "";
String strEmployer = "";


int i = 0;

if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.SSSMonthlyPremium(dbOP);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		iSearchResult = PRRemit.getSearchCount();
	}
}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./phic_monthly_grouped.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL: PHILHEALTH PREMIUM MONTHLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td> <select name="month_of">
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
      <td><select name="pt_ft" onChange="ReloadPage();">
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
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td><select name="employee_category" onChange="ReloadPage();">                    
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
		<%}else{%>
		<input type="hidden" name="employee_category" value="">
    <%}%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employer name </td>
      <td>
			<select name="employer_index" onChange="ReloadPage();">
<%
strEmployer = WI.fillTextValue("employer_index");
boolean bolIsDefEmployer = false;
java.sql.ResultSet rs = null;
strTemp = "select employer_index,employer_name,is_default from pr_employer_profile where is_del = 0 order by is_default desc";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	strTemp = rs.getString(1);
	if(strEmployer.length() == 0 || strEmployer.equals(strTemp)) {
		strErrMsg = " selected";
		if(rs.getInt(3) == 1)
			bolIsDefEmployer = true;
		if(strEmployer.length() == 0)
			strEmployer = strTemp;
	}
	else	
		strErrMsg = "";
		
%>			<option value="<%=strTemp%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
<%}
rs.close();
%>      </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> 
			<!--
			<select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%//=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
			</select> 
			-->
			<select name="c_index" onChange="ReloadPage();">
        <option value="">N/A</option>
<% 
	String strCollegeIndex = WI.fillTextValue("c_index");	

if(bolIsDefEmployer)
	strTemp = " from college where is_del= 0 and not exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index <>"+strEmployer+")";
else
	strTemp = " from college where is_del= 0 and exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index ="+strEmployer+")";
%>
        <%=dbOP.loadCombo("c_index","c_name", strTemp,strCollegeIndex,false)%>
      </select>			</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td><!-- <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%//if ((strCollegeIndex.length() == 0)){%>
          <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%> 
          <%//}else if (strCollegeIndex.length() > 0){%>
          <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%//}%>
        </select> 
				-->
			<select name="d_index" onChange="ReloadPage();">
        <option value="">N/A</option>
				<% 
				if(bolIsDefEmployer)
					strTemp = " from department where is_del= 0 " +
										" and not exists(select * from pr_employer_mapping " +
										"   where pr_employer_mapping.d_index = department.d_index " +
										"   and employer_index <> " + strEmployer + ")";
				else
					strTemp = " from department where is_del= 0 " +
										" and exists(select * from pr_employer_mapping " +
										"   where pr_employer_mapping.d_index = department.d_index " +
										"   and employer_index = " + strEmployer + ")";
				if ((strCollegeIndex.length() == 0))
					strTemp += " and (c_index = 0 or c_index is null) ";
				else
					strTemp += " and c_index = " + strCollegeIndex;
				%>
        <%=dbOP.loadCombo("d_index","d_name", strTemp,WI.fillTextValue("d_index"),false)%>
      </select>			</td>
    </tr>
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>      </td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("inc_resigned").length() > 0)
					strTemp = " checked";
			%>
      <td colspan="2"><input type="checkbox" name="inc_resigned" value="1" <%=strTemp%>>
include resigned employees in report</td>
    </tr>    
		<tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("show_adjusted").length() > 0)
					strTemp = " checked";
			%>			
      <td colspan="2"><input type="checkbox" name="show_adjusted" value="1" <%=strTemp%> onChange="SearchEmployee();">
show adjusted contribution </td>
    </tr>		
		<%
 		if(bolHasInternal){
			strTemp = WI.fillTextValue("show_internal");
			if(strTemp.length() > 0)
				strTemp = "checked";
			else	
				strTemp = "";
		%>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_internal");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td colspan="2"><input type="checkbox" name="show_internal" value="1" <%=strTemp%>>show internal</td>
    </tr>
		<%}%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
    </tr>
    
  </table>
	<%if (vRetResult != null && vRetResult.size() > 0 ){
	%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"></td>
  </tr>
    <tr> 
      <td height="18"></td>
      <td align="right"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="6"><div align="center"><strong>PhilHealth Premiums - <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;Records found : <%=iSearchResult%></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="1%">&nbsp;</td>
    <td width="37%">&nbsp;</td>
    <td width="16%" align="center"><strong>EE</strong></td>
    <td width="16%" align="center"><strong>ER</strong></td>
    <td width="14%" align="center"><strong>EC</strong></td>
    <td width="16%" align="center"><strong>TOTAL</strong></td>
  </tr>
  <%
  for(i = 3; i < vRetResult.size();){%>
  <%
  	dEEOfficeTotal = 0d;
  	dEROfficeTotal = 0d;
  	dECOfficeTotal = 0d;
	dOfficeTotal = 0d;
			
  if(bolPtFtHeader){
  	bolPtFtHeader = false;
  %>
  <tr>
    <td>&nbsp;</td>
    <td><strong>&nbsp;<%=astrPtFt[Integer.parseInt((String)vRetResult.elementAt(i+9))]%> EMPLOYEES </strong></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>  
  <%}%>
  <%
 	if(bolShowHeader){
  	bolShowHeader = false;
  %>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;<strong><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","",(String)vRetResult.elementAt(i+8))%></strong></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr> 
  <%}%>
  <%for(; i < vRetResult.size();){
 	dLineTotal = 0d;			
	
	if(i+20 < vRetResult.size()){
		if(i == 3){
			strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+7),"");		
			strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+8),"");	
		}
		strNextColl = WI.getStrValue((String)vRetResult.elementAt(i+26),"");		
		strNextDept = WI.getStrValue((String)vRetResult.elementAt(i+27),"");		
		// i+9 is for pt ft status
		if(!((String)vRetResult.elementAt(i+9)).equals((String)vRetResult.elementAt(i+28))){
			bolPtFtHeader = true;
			bolShowHeader = true;
			bolOfficeTotal = true;
		}
		if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
			bolShowHeader = true;
			bolOfficeTotal = true;
		}
	}
  %>
  
  <tr>
    <td>&nbsp;</td>
    <td><font size="1">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></font> </td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dEEOfficeTotal+=dTemp;
		dEEStatusTotal+=dTemp;
		dEEGrandTotal += dTemp;
	%>
    <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dEROfficeTotal+= dTemp;
		dERStatusTotal+= dTemp;
		dERGrandTotal += dTemp;
	%>	
    <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dECOfficeTotal+=dTemp;		
		dECStatusTotal+=dTemp;
		dECGrandTotal += dTemp;
	%>	
    <td><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<%
		dOfficeTotal +=dLineTotal;
		dStatusTotal +=dLineTotal;
		dGrandTotal+= dLineTotal;
	%>
    <td><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</font></div></td>
  </tr>
  <% 
  i = i + 19;  	
	 if(i < vRetResult.size()){
		 strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+7),"");
		 strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+8),"");
	 }	 
  	if(bolPtFtHeader || bolShowHeader){
		if(bolPtFtHeader){
			bolPtFtTotal = true;
			bolOfficeTotal = true;
		}
		break;
	}

  }%>
  
  <%if(bolOfficeTotal || (!bolOfficeTotal && i >= vRetResult.size())){
  	bolOfficeTotal = false;
  %>
  <tr>
    <td height="24">&nbsp; </td>
    <td align="right"><strong>TOTAL</strong></td>
    <td align="right" class="thinborderTOP"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dEEOfficeTotal,true),"")%>&nbsp;</font></td>
    <td align="right" class="thinborderTOP">
      <font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dEROfficeTotal,true),"")%>&nbsp;</font></td>
    <td align="right" class="thinborderTOP">
      <font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dECOfficeTotal,true),"")%>&nbsp;</font></td>
    <td align="right" class="thinborderTOP">
      <font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dOfficeTotal,true),"")%>&nbsp;</font></td>
  </tr>
  <%}%>
  <%if(bolPtFtTotal || (!bolPtFtTotal && i >= vRetResult.size())){
  	bolPtFtTotal = false;
  %>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="right"><strong>TOTAL <%=astrPtFt[Integer.parseInt((String)vRetResult.elementAt(i-10))]%></strong></div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dEEStatusTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dERStatusTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dECStatusTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dStatusTotal,true),"")%>&nbsp;</div></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>   
  <%
  dEEStatusTotal = 0d;
  dERStatusTotal = 0d;
  dECStatusTotal = 0d;
  dStatusTotal = 0d;
  }%>
  
  <%}// first For loop%>  
  
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><div align="right"><strong>GRAND TOTAL </strong></div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dEEGrandTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dERGrandTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dECGrandTotal,true),"")%>&nbsp;</div></td>
    <td><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dGrandTotal,true),"")%>&nbsp;</div></td>
  </tr>
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
  <input type="hidden" name="grouped" value="1">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>