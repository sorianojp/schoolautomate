<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
WebInterface WI = new WebInterface(request);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Monthly Remmitance Report</title>
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
 
  TD.thinborderTOP {
    border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 13px;
  }
	TD.thinborderBOTTOMRIGHT {
    border-bottom: solid 1px #000000;
		border-RIGHT: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }
	
  TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }	
	
  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  }
	
	TD.thinborderBOTTOMTOP {
    border-bottom: solid 1px #000000;
		border-top: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  }

	TD.thinborderBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  }
  TD.thinborderBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
  }
	
	TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;    
    border-left: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 11px;
  }
  
	TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 11px;
  }
	
	TD.thinborder {
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;	
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: <%=WI.fillTextValue("font_size")%>.px;
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
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
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
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance,hr.HRInfoPersonalExtn" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	int iSearchResult = 0;
	String strPayrollPeriod  = null;
	boolean bolHasTeam = false;	
	boolean bolHasInternal = false;
	
//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./pagibig_monthly_remittance_wup_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
										"Admin/staff-Payroll-Reports-Remittances-SSS Premium","pagibig_monthly_remittance_wup.jsp");
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
														"pagibig_monthly_remittance_wup.jsp");
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
Vector vPersonalInfo = null;//has bday
Vector vPersonalInfoExtn = null;//has pag-ibig num
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
double dEmpTotal = 0d;

boolean bolPtFtHeader = true;
boolean bolShowHeader = true;

boolean bolPtFtTotal = false;
boolean bolOfficeTotal = false;

String strCurColl = "";
String strNextColl = "";
String strCurDept = "";
String strNextDept = "";
String strEmployer = "";

String strPagibigNo = "";
String strDateOfBirth = "";

HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
enrollment.Authentication authentication = new enrollment.Authentication();


int i = 0;

if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.getAllMonthlyPremium(dbOP,false);
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
<form name="form_" method="post" action="./pagibig_monthly_remittance_wup.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL: SSS PREMIUM MONTHLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="table2">
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
String strEmployerSSSNo = "";
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
		
     
		<!--
	  <tr>
      <td height="25">&nbsp;</td>
	  <td>
			<% if (WI.fillTextValue("view_all").equals("1"))
					strTemp = "checked";
				else
					strTemp = "";
			%>
		
	  		<input type="checkbox" name="view_all" value="1" <%=strTemp%>> 
			view all employees	
		</td>
    <tr> -->
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
	<%if (vRetResult != null && vRetResult.size() > 0 ){	%>
   
 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	  	
  <!--	<tr>
      <td width="3%" height="10">&nbsp;</td>
      <td width="13%" height="10">Prepared By</td>
			<%
				strTemp = WI.fillTextValue("prepared_by");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll/HR Personnel",7);
				if( strTemp == null || strTemp.length() == 0)
					strTemp = (String)request.getSession(false).getAttribute("first_name");
			%>			
      <td width="84%" height="10">
	  <input type="text" name="prepared_by" maxlength="128" size="32" 
			value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="20%">Certified Correct by :</td>
			<%
				strTemp = WI.fillTextValue("certified_by");								
			%>			
      <td width="78%"><input type="text" name="certified_by" class="textbox" value="<%=strTemp%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	
	 <tr>
      <td width="2%" height="18">&nbsp;</td>
      <td width="20%">Noted by :</td>
			<%
				strTemp = WI.fillTextValue("noted_by");								
			%>			
      <td width="78%"><input type="text" name="noted_by" class="textbox" value="<%=strTemp%>" size="32"
				 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	-->
	
  	 <tr> 
      <td height="18" colspan="3"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=50 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
		  
    </tr>
  
    <tr> 
      <td height="24" colspan="23"> <%
		int iPageCount = iSearchResult/PRRemit.defSearchSize;
		if(iSearchResult % PRRemit.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
 
  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
  <tr>
  	<td colspan="6">
		<table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" style="display:none" id="table_header">
			<tr>
				<td colspan="3" align="right">&nbsp;</td>				
			</td>	
			<tr>
				<td width="25%" align="right">&nbsp;				</td>
				<td width="50%"  align="center">
					<div style=" width:500px">
					  <div style="text-align: left; position: relative; display: block; width: 70px; height: 70px; margin-left: -360px;"> <img src="../../../../images/logo/<%=strSchCode%>.gif" width="100%" height="100%" style="text-align:left"> </div>
					  <div style=" width: 500px; margin-top: -70px; padding-bottom: 30px;">
							<strong><font size ="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong> <br>
							<font size ="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
							<font size ="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> <br>
							<font size ="1">HUMAN RESOURCE DEVELOPMENT DEPARTMENT</font> <br>			
					  </div>
				  </div>				</td>
				<td width="25%" valign="bottom">					
					<font size ="1"><%=WI.getTodaysDate(6)%></font><br /></td>
			</tr>
		</table>
  	</td>
  </tr>
  <tr>
    <td colspan="9"><div align="center"><strong>PAG-IBIG PREMIUM REMITTANCE <BR/>
		</strong>for the month of <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></div></td>
  </tr>
  <tr>   
	<td width="3%">&nbsp;</td>
	<td width="12%">&nbsp;</td>
    <td width="14%">&nbsp;</td>
    <td width="14%">&nbsp;</td>
    <td width="11%">&nbsp;</td>	
    <td width="10%">&nbsp;</td>	
    <td width="13%">&nbsp;</td>
	 <td width="9%">&nbsp;</td>
	  <td width="14%">&nbsp;</td>
  </tr>
  
  <tr>  	
	<td align="center" class="thinborderRIGHT">&nbsp;</td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT" height="30"><strong>&nbsp;LNAME</strong></td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>&nbsp;FNAME</strong></td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>&nbsp;MIDNAME</strong></td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>EE SHARE </strong></td>
	<td width="10%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>ER SHARE </strong></td>	
	<td width="8%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>TOTAL </strong></td>	
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>TIN</strong></td>
	<td width="9%" align="center" class="thinborderTOPBOTTOMRIGHT"><strong>BDATE</strong></td>
	<td align="center" class="thinborderTOPBOTTOMRIGHT"><strong>Pag-IBIG Number</strong></td>
		
	<!--<td width="13%" align="center" class="thinborderBOTTOMRIGHT"><strong>TOTAL</strong></td>-->
	
  </tr>   
  
  <%
  int iCtr = 1;
  for(i = 3; i < vRetResult.size();){
 
  	dEEOfficeTotal = 0d;
  	dEROfficeTotal = 0d;
  	dECOfficeTotal = 0d;
	dOfficeTotal = 0d;
			
  if(bolPtFtHeader){
  	bolPtFtHeader = false;
  }
  
  for(; i < vRetResult.size();){
 	dLineTotal = 0d;
	dEmpTotal = 0d;
	
	//get personal info
	vPersonalInfo = authentication.getBasicInfo(dbOP, (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i), request);	
	vPersonalInfoExtn = hrPx.viewPersonalExtn(dbOP, (String)vRetResult.elementAt(i));	
	
	
  %>
  
  <tr>   
	<td  class="thinborderRIGHT" align="right" width="4%" height="20"><%=iCtr++%>&nbsp;&nbsp;</td>
	<td  class="thinborderBOTTOMRIGHT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%>&nbsp;</td>
	<td  class="thinborderBOTTOMRIGHT"  >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%>&nbsp;</td>
	<td  class="thinborderBOTTOMRIGHT">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+5)," "))%>&nbsp;</td>    
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dEEOfficeTotal+=dTemp;
		dEEStatusTotal+=dTemp;
		dEEGrandTotal += dTemp;
		dEmpTotal = dTemp;
	%>
    <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>	
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;
		dERGrandTotal += dTemp;
		dEmpTotal += dTemp;		
	%>		
    <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	<td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dEmpTotal,true)%>&nbsp;</font></div></td>
	<%	dTemp = 0d;
		strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = ConversionTable.replaceString(CommonUtil.formatFloat(strTemp,true),",","");

		dTemp = Double.parseDouble(strTemp);		
		dLineTotal += dTemp;		
		dECGrandTotal += dTemp;		
	%>	
    <!--
	<td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>	
	<%		
		dGrandTotal+= dLineTotal;
	%>
    <td  class="thinborderRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(CommonUtil.formatFloat(dLineTotal,true),"")%>&nbsp;</font></div></td>-->
  
  	<%
	   //TIN
	   strTemp = "";
	   if(vPersonalInfoExtn != null || vPersonalInfoExtn.size() > 0)
	   		strTemp = WI.getStrValue(vPersonalInfoExtn.elementAt(5), "");
			
   %>
   <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
   <%
	   //DOB
	   strTemp = "";
	   if(vPersonalInfo != null || vPersonalInfo.size() > 0)
	   		strTemp = WI.getStrValue(vPersonalInfo.elementAt(5), "");
			
   %>
   <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
   <td  class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%>&nbsp;</font></div></td>
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
   
  
  <%}// first For loop%>  
  
  <tr>  
  	 <td class="thinborderNONE">&nbsp;</td>   
    <td colspan="7">&nbsp;</td>   
  </tr>  
</table>
<%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table4">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="grouped" value=""> 
  <input type="hidden" name="remittance_type" value="2">  
 
 
 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>