<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRCOAMapping" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
boolean bolIsGovernment = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Mapping</title>
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
	this.SubmitOnce('form_');
}
 
function SaveRecord(){
	document.form_.save_record.value = "1";
	this.SubmitOnce('form_');	
}

function DeleteRecord (strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "0";	
	this.SubmitOnce('form_');	
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	 var strCompleteName = document.form_.emp_id.value;
	 var objCOAInput = document.getElementById("search_");
	
	//var strCompleteName = eval('document.form_.'+strTextName+'.value');	
	//var objCOAInput = eval('document.getElementById("'+strLabelName+'")');
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
	document.getElementById("search_").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){
//	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
//	"&opner_form_name=form_";
	document.form_.donot_call_close_wnd.value="0";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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

function goToMain(){
	location = "./coa_main.jsp";
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
		
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-COA Config-Salary Data Mapping","coa_data_setting.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");	
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
														"PAYROLL","CONFIGURATION",request.getRemoteAddr(),
														"coa_data_setting.jsp");
															
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


	Vector vSalaryPeriod 		= null;//detail of salary period.
	Vector vRetResult = null;
	PRCOAMapping prCOA = new PRCOAMapping();
	int iSearchResult = 0;
	int iCount = 0;
	Vector vFieldNames = new Vector();
	
	String[] astrFieldNames = {"Overtime", "Additional Pay", "Ad Hoc Bonuses", 
														 "Night Premium", "Holiday Pay", "Addl. Responsibility", 
												 		 "COLA", "Transportation Allowance (extra)", "Board and Lodging",
														 "Tax Refund", "Leave deductions", "SSS Remittance", 
														 "Philhealth", "PAG-IBIG", "Additional Deductions",
														 "Adjustment", "Tax Deductions", "Absences", 
														 "Late/Undertime", "Faculty Salary", "Faculty absences",
														 "PERAA", "Faculty Allowances", "GSIS"}; 

														 	
	String[] astrFieldVal = {"ot_amt", "addl_payment_amt", "adhoc_bonus", 
													 "night_diff_amt", "holiday_pay_amt", "addl_resp_amt", 
													 "cola_amt", "trans_allow_extra", "board_lodging", 
													 "tax_refund", "leave_deduction_amt", "sss_amt", 
													 "philhealth_amt", "pag_ibig", "misc_deduction", 
													 "adjustment_amt", "tax_deduction", "awol_amt", 
													 "late_under_amt", "faculty_salary", "faculty_absence", 
													 "peraa", "fac_allowance", "gsis_ps"};

	String strStatus = null;
	String strPageAction = WI.fillTextValue("page_action");
	
	if(WI.fillTextValue("save_record").equals("1")){	
		if(prCOA.operateOnCOAData(dbOP,request,1) == null)
			strErrMsg = prCOA.getErrMsg();
	}
	
	if(strPageAction.length() > 0){
		vRetResult = prCOA.operateOnCOAData(dbOP,request,Integer.parseInt(strPageAction));
		if(vRetResult == null)	
			strErrMsg = prCOA.getErrMsg();	
	}
	
	strErrMsg = WI.getStrValue(strErrMsg);	
	vRetResult = prCOA.operateOnCOAData(dbOP,request,4);
	if(vRetResult == null){
		strErrMsg += WI.getStrValue(prCOA.getErrMsg(),"<br>","","");
	}else{
		iSearchResult = prCOA.getSearchCount();	
	}
	
	if(strErrMsg == null) 
	strErrMsg = "";
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./coa_data_setting.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        PAYROLL : SALARY DATA MAPPING ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="27"><strong><a href="javascript:goToMain();">MAIN</a>&nbsp;&nbsp;<%=strErrMsg%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="100%" height="12" colspan="3"><hr size="1"></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		
    <tr>
      <td height="25">&nbsp;</td>
      <td>Mapping Header : </td>
			<%
				strTemp = WI.fillTextValue("coa_map_main_index");
			%>
      <td><select name="coa_map_main_index">
        <option value="">Select mapping header</option>
        <%=dbOP.loadCombo("coa_map_main_index","map_header_name", " from pr_coa_map_main order by order_no",strTemp,false)%>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Data source :</td>
			<%
				strTemp = WI.fillTextValue("field_name");
			%>
      <td width="77%">
			<select name="field_name">
				<option value="">Select Field Name</option>
				<%for(int i = 0; i < astrFieldNames.length; i++){
					vFieldNames.addElement(astrFieldVal[i]);
					vFieldNames.addElement(astrFieldNames[i]);
				%>
				<%if(i >= 19 && i <= 22 && !bolIsSchool) 
						continue; 
					else if(i == 23 && !bolIsGovernment)
						continue;
					%>
				 <%if(strTemp.equals(astrFieldVal[i])){%>
				 		<option value="<%=astrFieldVal[i]%>" selected><%=astrFieldNames[i]%></option>
				 <%}else{%>
						<option value="<%=astrFieldVal[i]%>"><%=astrFieldNames[i]%></option>
				 <%}%>
				<%}%>
      </select></td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="3%" height="10">&nbsp;</td>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td width="11%" height="10">&nbsp;</td>
      <td height="10" colspan="3">
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:SaveRecord();" />
      	<font size="1">click to save</font></td>
    </tr>
  </table>	
  <% //System.out.println("vRetResult " + vRetResult);
  if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td align="right">&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    	
    <tr bgcolor="#B9B292" class="thinborder"> 
      <td height="23" colspan="4" align="center"><b>LIST OF EMPLOYEES</b></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" align="center">&nbsp;</td>
      <td class="thinborder" width="41%" align="center"><strong>HEADER</strong></td>
      <td class="thinborder" width="43%" align="center"><strong>DATA SOURCE </strong></td>
      <td width="10%" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <% 	//System.out.println("size " +vRetResult.size());
		int iIndexOf = 0;
		for(int i = 0; i < vRetResult.size(); i += 8,++iCount){		
			strStatus = "";		
		%>
    <tr bgcolor="#FFFFFF"> 						
       <td width="6%" height="25" class="thinborder">&nbsp;<%=iCount+1%>.</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+1);
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
				iIndexOf = vFieldNames.indexOf(strTemp);
				if(iIndexOf != -1)
					strTemp = (String)vFieldNames.remove(iIndexOf + 1);				
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td align="center" class="thinborder" ><input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord('<%=vRetResult.elementAt(i)%>');">      </td>
    </tr>
	<%} // end for loop%>
	<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
  <%} // end if vRetResult != null && vRetResult.size() %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="save_record">
  <input type="hidden" name="page_action"> 
	<input type="hidden" name="info_index"> 

	<!-- this is used to reload parent if Close window is not clicked. -->
		<input type="hidden" name="close_wnd_called" value="0">
		<input type="hidden" name="donot_call_close_wnd">
	<!-- this is very important - onUnload do not call close window -->
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>