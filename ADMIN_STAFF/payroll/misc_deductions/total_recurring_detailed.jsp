<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction, payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print recurring deduction payments</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}
  

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function ViewDetail(strPostIndex){
	var loadPg = "recurring_details.jsp?post_deduct_index="+strPostIndex+
							 "&deduction_name="+document.form_.deduction_name.value;	
	var win=window.open(loadPg,"recurring_details",'dependent=yes,width=550,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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

function loadSalPeriods(strMonthField, strYearField, strPeriod, strLabelName) {
		var strMonth = eval('document.form_.'+strMonthField+'.value');
		var strYear =  eval('document.form_.'+strYearField+'.value');
		var strPeriodType =  document.form_.period_index.value;
		
		var strWeekly = null;		
		if(document.form_.is_weekly){
			if(document.form_.is_weekly.checked)
				strWeekly = "1";
			else
				strWeekly = "";
		}
		
		var objCOAInput = document.getElementById(strLabelName);
		
		if(strPeriodType == '' || strPeriodType.length == 0){			
			alert("Select period type.");
			objCOAInput.innerHTML = "";
			return;
		}
		
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
								 "&year_of="+strYear+"&is_weekly="+strWeekly+"&select_name="+strPeriod+
								 "&period_index="+strPeriodType;

		this.processRequest(strURL);
}

function CopyName(){
	if (document.form_.deduct_index.selectedIndex != 0) 
		document.form_.deduction_name.value= 
			document.form_.deduct_index[document.form_.deduct_index.selectedIndex].text;
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./total_recurring_detailed_print.jsp"/>
	<% 
return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Recurring Deductions","total_recurring_detailed.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
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
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"total_recurring_detailed.jsp");
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

	Vector vRetResult = null;
	Vector vSalaryPeriod = null;//detail of salary period.
	Vector vEmpDetail = null;
	PRMiscDeduction prMiscDed = new PRMiscDeduction(request);
	PReDTRME  prEdtrME = new PReDTRME();
	int iSearchResult = 0;
	int i = 0;
	int iMonth = 0;
	String strPayrollPeriod  = null;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	double dTemp = 0d;
	double dEmpTotal = 0d;
		
	String[] astrSortByName = {"Employee ID","Firstname",strTemp,"Department"};
	String[] astrSortByVal  = {"id_number","user_table.fname","c_name","d_name"};
	String[] astrMonth = {"January","February","March","April","May","June","July",
					"August", "September","October","November","December"};	
	String[] astrUserStat  = {"Show only for resigned employees", "Show only valid employees"};
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = prMiscDed.getEmpDetailedRecurring(dbOP,request);
		if(vRetResult == null)
			strErrMsg = prMiscDed.getErrMsg();
		else
			iSearchResult = prMiscDed.getSearchCount();
	}		
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="CopyName();">
<form action="total_recurring_detailed.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        RECURRING MISCELLANEOUS DEDUCTIONS  PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Year</td>
      <td><select name="year_of" onChange="ReloadPage();">
						<%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
					</select>      </td>
    </tr>
    

    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Deduction name </td>
			<%
				strTemp = WI.fillTextValue("deduct_index");
			%>
      <td width="77%"><select name="deduct_index" onChange="CopyName();ReloadPage();">
        <option value="">Select Deduction Name</option>
        <%=dbOP.loadCombo("PRE_DEDUCT_INDEX","PRE_DEDUCT_NAME", " from preload_deduction " +
													" where exists(select * from pr_post_deduct where is_valid = 1 " +
													"   and (is_deducted = 2 or is_deducted = 3) " +
													"   and pr_post_deduct.pre_deduct_index = preload_deduction.pre_deduct_index) " +
													" order by pre_deduct_name",strTemp,false)%>
      </select></td>
    </tr>    
    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
        <option value="">All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part-time</option>
        <%}else{%>
        <option value="0">Part-time</option>
        <%}if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="1" selected>Full-time</option>
        <%}else{%>
        <option value="1">Full-time</option>
        <%}%>
      </select></td>
    </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td>
	   <select name="employee_category" onChange="ReloadPage();">          
        <option value="">All</option>
				<%if (WI.fillTextValue("employee_category").equals("0")){%>
				  <option value="0" selected>Non-Teaching</option>
        <%}else{%>
          <option value="0">Non-Teaching</option>				
        <%}if (WI.fillTextValue("employee_category").equals("1")){%>
          <option value="1" selected>Teaching</option>
        <%}else{%>
          <option value="1">Teaching</option>
        <%}%>
       </select></td>
    </tr>
		<%}%>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td>
			<label id="load_dept">
	  	<select name="d_index">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>	  
			</label></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Office/Dept filter</td>
      <td height="10"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
(enter office/dept's first few characters)</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>Employee ID </td>
      <td>
			<input name="emp_id" type="text" size="16"maxlength="128" value="<%=WI.fillTextValue("emp_id")%>"
											onKeyUp="AjaxMapName(1);" class="textbox"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>Show Option </td>
			<%
				strTemp = request.getParameter("account_stat");
				if(strTemp == null)
					strTemp = "1";
				else			
					strTemp = WI.fillTextValue("account_stat");
			%>				
      <td><select name="account_stat" onChange="ReloadPage()">
        <option value="">ALL</option>
        <%
				for(i = 0; i < astrUserStat.length; i++){
					if(strTemp.equals(Integer.toString(i))){
				%>
        <option value="<%=i%>" selected><%=astrUserStat[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrUserStat[i]%></option>
        <%}				
				}%>
      </select></td>
    </tr>

    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="3">OPTION:</td>
    </tr>
    
    <%if(WI.fillTextValue("with_schedule").equals("1")){%>
		<tr>
      <td height="10">&nbsp;</td>
      <%
				strTemp = WI.fillTextValue("show_stopped");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
			<td height="10" colspan="2"><input name="show_stopped" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();"> 
			  show only stopped deductions</td>
    </tr>
		<%}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">
			<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        
        View result in single page </td>
    </tr>		
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="3%" height="10">&nbsp;</td>
      <td width="11%" height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
				<!--
				<input type="image" onClick="SearchEmployee()" src="../../../images/form_proceed.gif"> 
				-->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
      <font size="1">click to display employee list to print</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>    
	<% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td align="right"><font size="2">Number of  rows Per 
        Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
      <font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" ></a> click to print</font></td>
    </tr>
  <%if(WI.fillTextValue("view_all").length() == 0){
		int iPageCount = iSearchResult/prMiscDed.defSearchSize;		
		if(iSearchResult % prMiscDed.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%>    
    <tr>
      <td><div align="right"><font size="2">Jump To page:
            <select name="jumpto" onChange="SearchEmployee();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
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
      </font></div></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    
    <tr>
      <td width="7%" rowspan="2" class="thinborder">&nbsp;</td>
      <td width="18%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE ID </strong></font></td> 
      <td width="35%" height="23" rowspan="2" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <%for(iMonth = 0;iMonth < astrMonth.length; iMonth++){%>
			<td colspan="2" align="center" class="thinborder"><%=astrMonth[iMonth]%></td>
			<%}%>
      <td width="18%" rowspan="2" align="center" class="thinborder"><strong><font size="1">TOTAL PAID</font></strong></td>
    </tr>
    <tr>
		<%for(iMonth = 0;iMonth < 12; iMonth++){%>
      <td width="11%" align="center" class="thinborder">1st</td>
      <td width="11%" align="center" class="thinborder">2nd</td>
		  <%}%>
    </tr>
    
    <%int iCount = 1;
		int iIndexOf = 0;
		Integer iObjMonth = null;
	   for (i = 0; i < vRetResult.size(); i+=15,iCount++){
			 vEmpDetail = (Vector)vRetResult.elementAt(i+12);
	  	 dEmpTotal = 0d;
		 %>
    <tr>
      <td class="thinborder">&nbsp;<%=iCount%></td>
      <td align="center" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td> 
			<%for(iMonth = 0;iMonth < 12; iMonth++){
				strTemp = null;
				iObjMonth = new Integer(iMonth + "0001");
				iIndexOf = vEmpDetail.indexOf(iObjMonth);
				if(iIndexOf != -1){
					vEmpDetail.remove(iIndexOf);
					strTemp = (String)vEmpDetail.remove(iIndexOf);
					vEmpDetail.remove(iIndexOf);
					vEmpDetail.remove(iIndexOf);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));  
					dEmpTotal += dTemp;
				}else
					strTemp = "";
			%>
			<td align="right" class="thinborder">&nbsp;<%=strTemp%>&nbsp;</td>
			<%
				strTemp = null;
				iObjMonth = new Integer(iMonth + "0002");
				iIndexOf = vEmpDetail.indexOf(iObjMonth);
				if(iIndexOf != -1){
					vEmpDetail.remove(iIndexOf);
					strTemp = (String)vEmpDetail.remove(iIndexOf);
					vEmpDetail.remove(iIndexOf);
					vEmpDetail.remove(iIndexOf);
					strTemp = CommonUtil.formatFloat(strTemp, true);
					dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));  
					dEmpTotal += dTemp;					
				}else
					strTemp = "";			
			%>
			<td align="right" class="thinborder">&nbsp;&nbsp;<%=strTemp%>&nbsp;</td>
			<%}%>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dEmpTotal, true)%>&nbsp;</td>
		</tr>
    <%} //end for loop%>
    
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
  
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee" > 
  <input type="hidden" name="page_action">	
	<input type="hidden" name="copy_all">	
	<input type="hidden" name="copy_note">	
	<input type="hidden" name="deduction_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>