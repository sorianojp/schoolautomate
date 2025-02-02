
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRSalaryGrade"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
 TD{
 	font-size: 11px;
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
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function viewList(){
	var loadPg = "./sal_ben_incent_type_update.jsp?label=BENEFIT&opner_form_name=form_&is_incentive=0";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.consider_vedit.value = "1";//take edit info.
	document.form_.submit();
}

function ShowUpdate(){//alert((document.form_.benefit_type_index[document.form_.benefit_type_index.selectedIndex].text).toUpperCase());
	var vBenefitName = document.form_.benefit_type_index[document.form_.benefit_type_index.selectedIndex].text;
	document.form_.benefit_type_name.value = vBenefitName;
	if ((vBenefitName).toUpperCase() == "LEAVE"){
		//document.getElementById("update_button").style.display="block";
		//document.getElementById("update_text").style.display = "block";
		showLayer('update_button');
		showLayer('update_text');
		if(document.getElementById("for_leave_"))
			showLayer('for_leave_');		
		if(document.getElementById("leave_stat"))
			showLayer('leave_stat');		
 	}else{
		//document.getElementById("update_button").style.display="none";
		//document.getElementById("update_text").style.display ="none";
		hideLayer('update_button');
		hideLayer('update_text');
		if(document.getElementById("for_leave_"))
			hideLayer('for_leave_');		
		if(document.getElementById("leave_stat"))
			hideLayer('leave_stat');					
 	}
	LoadCoverageUnit();
}
//all about ajax - to display student list with same name.
function LoadCoverageUnit() {
		var objCOAInput = document.getElementById("c_unit_");
		var strBenTypeName =document.form_.benefit_type_name.value;
		var strCUnit = document.form_.coverage_unit.value;
		

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=3000&b_type_name="+strBenTypeName+
								 "&c_unit="+strCUnit;

		this.processRequest(strURL);
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	String strUserID = (String)request.getSession(false).getAttribute("userId");
	boolean bolShowAll = false;
	if(strUserID != null && strUserID.equals("bricks"))
		bolShowAll = true;
	boolean bolHasInterval = false;
	boolean boIsGovernment = false;
	
//add security hehol.
	try	{
		
		dbOP = new DBOperation(strUserID,"Admin/staff-PERSONNEL-salary grade","sal_ben_incent_mgmt_benefits.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasInterval = (readPropFile.getImageFileExtn("HAS_LEAVE_INTERVAL","0").equals("1"));		
		boIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0").equals("1"));		
		
	}	catch(Exception exp) {
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

int iAccessLevel = -1;

if (!strSchCode.startsWith("AUF")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"sal_ben_incent_mgmt_benefits.jsp");
}else{
    iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"sal_ben_incent_mgmt_benefits.jsp");
}


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
if(strSchCode.startsWith("TAMIYA") || strSchCode.startsWith("AUF"))
	bolHasInterval = true;

Vector vRetResult = null;
Vector vEditInfo  = null;
HRSalaryGrade hrSG = new HRSalaryGrade();
String[] astrCoverageUnit = {"Day(s)", "%","Cash (php)", "Teaching load unit",
                             "Teaching load hour", "Hour(s)"};
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//add,edit,delete
	if(hrSG.operateOnBenefit(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = hrSG.getErrMsg();
	else {	
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}
//System.out.println("Before 1 : "+strErrMsg);
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = hrSG.operateOnBenefit(dbOP, request,3, true);
	if(vEditInfo == null)
		strErrMsg = hrSG.getErrMsg();
}//System.out.println("Before 2 : "+strErrMsg);
//get the list. 
vRetResult = hrSG.operateOnBenefit(dbOP, request, 4, true);
%>

<body bgcolor="#663300" class="bgDynamic">
<form action="./sal_ben_incent_mgmt_benefits.jsp" method="post" name="form_">
  <table width="100%"  bgcolor="#FFFFFF"cellpadding="0" cellspacing="0">
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="6" align="center" bgcolor="#999966"><font color="#FFFFFF" ><strong>:::: 
        BENEFITS MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" align="right"><a href='./sal_ben_incent_mgmt_main.jsp'><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td width="3%" rowspan="16" align="center" valign="middle"><img src="../../../images/sidebar.gif" width="11" height="270"></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="13%">Benefit Type</td>
      <td colspan="2"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("benefit_type_index");
%> <select name="benefit_type_index" onChange="ShowUpdate();">
          <option value="">Select a benefit type</option>
          <%=dbOP.loadCombo("BENEFIT_TYPE_INDEX","BENEFIT_NAME",
		  	" FROM HR_PRELOAD_BENEFIT_TYPE where is_incentive = 0 order by BENEFIT_NAME",strTemp,false)%> </select> <a href='javascript:viewList();'><img src="../../../images/update.gif" border="0"></a>      </td>
      <td><div id="leave_stat" style="width:225px;height:auto; border:double;border-color:#FF0000" >			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr>
					<%
					if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
						strTemp = (String)vEditInfo.elementAt(23);
					else	
						strTemp = WI.fillTextValue("is_without_pay");
					strTemp = WI.getStrValue(strTemp);
					if(strTemp.equals("0"))
						strTemp = "checked";
					else
						strTemp = "";
					%> 
				  <td width="62%"><input type="checkbox" name="is_without_pay" value="0" <%=strTemp%>>
				    leave is without pay </td>
				</tr>
			</table>
			</div></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Sub-Type</td>
      <td colspan="3"> 
			<%
			if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
				strTemp = (String)vEditInfo.elementAt(3);
			else	
				strTemp = WI.fillTextValue("sub_type");
			%> 		
				<input name="sub_type" type= "text" class="textbox" value="<%=strTemp%>" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <%if(WI.fillTextValue("IS_BENEFIT").compareTo("0") == 0) {//show only %> <font size="1"> (Create SSS, Pag-ibig and Philhealth subtype 
        for benefit type Govt Mandated)</font> <%}%> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Benefit Nature</td>
      <td colspan="3"> <select name="benefit_nature">
          <option value="0">Accumulated</option>
          <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("benefit_nature");

if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Convertible to Cash</option>
          <%}else {%>
          <option value="1">Convertible to Cash</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>Non accumulated</option>
          <%}else{%>
          <option value="2">Non accumulated</option>
          <%}%>
        </select>
			<%
			if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
				strTemp = (String)vEditInfo.elementAt(21);
			else	
				strTemp = WI.fillTextValue("benefit_code");
			strTemp = WI.getStrValue(strTemp);
			%> 		
        Benefit Code
        <input name="benefit_code" type= "text" class="textbox" value="<%=strTemp%>" maxlength="16"
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="8">
				<%if(boIsGovernment){
					strTemp = WI.fillTextValue("gov_leave_type");
				%>
				<select name="gov_leave_type">
          <option value="1">Vacation Leave</option>
          <% if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>Sick Leave</option>
          <%}else {%>
          <option value="2">Sick Leave</option>
          <%}%>
        </select>
				<%}%>			</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Coverage</td>
      <td width="33%"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("converage");
%> <input name="converage" type= "text" class="textbox" value="<%=strTemp%>" size="10" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"			
			onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("coverage_unit");
	strTemp = WI.getStrValue(strTemp);
	%> 
			<label id="c_unit_">
			<select name="coverage_unit">
				<%for(int i = 0;i < astrCoverageUnit.length; i++){
						if(!bolIsSchool && (i == 3 || i == 4))
			        continue;      

						if(WI.fillTextValue("benefit_type_name").toUpperCase().equals("LEAVE")){
							if(!(i == 0 || i == 5))
								continue;							
						}
						
					if(strTemp.equals(Integer.toString(i))){%>
					<option value="<%=i%>" selected><%=astrCoverageUnit[i]%></option>
					<%}else{%>
					<option value="<%=i%>"><%=astrCoverageUnit[i]%></option>
				<%}
				 }%>
        </select> 
				</label>				</td>
      <td width="9%" >&nbsp;<label id="update_button">
	  <%if(bolIsSchool){%><a href="sal_ben_incent_mgmt_benefits_divide_term.jsp"><img src="../../../images/update.gif" border="0"></a>
	  <%}%>	  </label></td>
      <td width="42%" valign="bottom">&nbsp;<label id="update_text">
	  <%if(bolIsSchool){%><font size="1">click to set leave per term (ONLY FOR LEAVE)</font><%}%>	  </label></td>
    </tr>
    <tr> 
      <td height="23">&nbsp;</td>
      <td height="23">Premium</td>
      <td colspan="2"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(15);
else	
	strTemp = WI.fillTextValue("tot_premium");
%> <input name="tot_premium" type= "text" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="12" 
	  		onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="AllowOnlyFloat('form_','tot_premium');style.backgroundColor='white'"
			 onKeyUp="AllowOnlyFloat('form_','tot_premium')">
        (Fill up if applicable)</td>
      <td>
			<%if(bolHasInterval || bolShowAll){%>
			<div id="for_leave_" style="position:absolute;width:225px;height:auto; border:double;border-color:#FF0000" >			
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr>
					<td width="38%">&nbsp;Interval</td>
					<%
					if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
						strTemp = (String)vEditInfo.elementAt(18);
					else	
						strTemp = WI.fillTextValue("interval");
					strTemp = WI.getStrValue(strTemp);
					%> 
				  <td width="62%">
					<input name="interval" type= "text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4" 
		  		onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','interval')"			
					onKeyUp="AllowOnlyInteger('form_','interval')" style="text-align:right">
					year(s)</td>
				</tr>
				<tr>
					<td>&nbsp;Increment</td>
					<%
					if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
						strTemp = (String)vEditInfo.elementAt(19);
					else	
						strTemp = WI.fillTextValue("increment");
					strTemp = WI.getStrValue(strTemp);
					%> 					
				  <td><input name="increment" type= "text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	  			onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','interval')"			
					onKeyUp="AllowOnlyInteger('form_','increment')" style="text-align:right">
				    units</td>
				</tr>
				<tr>
				  <td>&nbsp;Maximum</td>
					<%
					if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
						strTemp = (String)vEditInfo.elementAt(20);
					else	
						strTemp = WI.fillTextValue("max_value");
					strTemp = WI.getStrValue(strTemp);
					%> 						
				  <td><input name="max_value" type= "text" class="textbox" value="<%=strTemp%>" size="4" 
	  		onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','interval')"			
				onKeyUp="AllowOnlyInteger('form_','max_value')" style="text-align:right">
				    units</td>
				  </tr>
			</table>
			</div>
			<%}%>			</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employeer Share</td>
      <td colspan="3"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(16);
else	
	strTemp = WI.fillTextValue("employer_share");
%> <input name="employer_share" type= "text" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="12" 
	  		onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="AllowOnlyFloat('form_','employer_share');style.backgroundColor='white'"
			 onKeyUp="AllowOnlyFloat('form_','employer_share')">
        (Fill up if applicable)</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employees Share</td>
      <td colspan="3"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(17);
else	
	strTemp = WI.fillTextValue("employee_share");
%> <input name="employee_share" type= "text" class="textbox" value="<%=WI.getStrValue(strTemp)%>" size="12" 
	  		onFocus="style.backgroundColor='#D3EBFF'"
			onBlur="AllowOnlyFloat('form_','employee_share');style.backgroundColor='white'"
			 onKeyUp="AllowOnlyFloat('form_','employee_share')">
        (Fill up if applicable)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="middle">Plan Description</td>
      <td colspan="3"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("plan_desc");
strTemp = WI.getStrValue(strTemp);
%> <textarea name="plan_desc" cols="60" rows="3" class="textbox" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="middle">Remarks</td>
      <td colspan="3"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("remarks");
strTemp = WI.getStrValue(strTemp);
%> <textarea name="remarks" cols="60" rows="3" class="textbox" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Eligibility Period/Schedule</td>
      <td colspan="3"> 
			<%
			if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
				strTemp = (String)vEditInfo.elementAt(9);
			else	
				strTemp = WI.fillTextValue("eligibility");
			strTemp = WI.getStrValue(strTemp);
			%> 
		<input name="eligibility" type= "text" class="textbox" value="<%=strTemp%>" size="10" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','eligibility');style.backgroundColor='white'"
			 onKeyUp="AllowOnlyFloat('form_','tot_premium')"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("eligibility_unit");
strTemp = WI.getStrValue(strTemp);
%> <select name="eligibility_unit">
          <option value="0">day(s)</option>
          <%
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>week(s)</option>
          <%}else{%>
          <option value="1">week(s)</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>month(s)</option>
          <%}else{%>
          <option value="2">month(s)</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>year(s)</option>
          <%}else{%>
          <option value="3">year(s)</option>
          <%}%>
        </select>
        of work</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Apply setting</td>
      <td colspan="3"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(12);
else	
	strTemp = WI.fillTextValue("auto_apply");
strTemp = WI.getStrValue(strTemp,"0");

if(strTemp.compareTo("1") == 0) 
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="radio" name="auto_apply" value="1"<%=strTemp%>>
        Apply when eligible(based on eligibility period) &nbsp;&nbsp; <%
if(strTemp.length() == 0) 
	strTemp = " checked";
else
	strTemp = "";
%> <input type="radio" name="auto_apply" value="0"<%=strTemp%>>
        Apply Manually</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Taxable setting</td>
      <td colspan="3"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("is_taxable");
strTemp = WI.getStrValue(strTemp,"1");
if(strTemp.compareTo("1") == 0) 
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="radio" name="is_taxable" value="1"<%=strTemp%>>
        Taxable 
        <%
if(strTemp.length() == 0) 
	strTemp = " checked";
else
	strTemp = "";
%> <input type="radio" name="is_taxable" value="0"<%=strTemp%>>
        Non Taxable</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Applicable Duration</td>
      <td colspan="3"> <select name="applicable_dur">
          <option value="1">Every Salary period</option>
          <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(13);
else	
	strTemp = WI.fillTextValue("applicable_dur");
strTemp = WI.getStrValue(strTemp);
if(strTemp.compareTo("2") == 0) {%>
          <option value="2" selected>Every Month</option>
          <%}else{%>
          <option value="2">Every Month</option>
          <%}if(strTemp.compareTo("3") ==0) {%>
          <option value="3" selected>Quarterly</option>
          <%}else{%>
          <option value="3">Quarterly</option>
          <%}if(strTemp.compareTo("4") ==0) {%>
          <option value="4" selected>Bi-annually</option>
          <%}else{%>
          <option value="4">Bi-annually</option>
          <%}if(strTemp.compareTo("5") ==0) {%>
          <option value="5" selected>Yearly</option>
          <%}else{%>
          <option value="5">Yearly</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Is Applied to Payroll</td>
      <td colspan="3"> <select name="is_added_pr">
          <option value="0">N/A (Prior approval needed. Ex. Loans or Leaves)</option>
          <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(14);
else	
	strTemp = WI.fillTextValue("is_added_pr");
strTemp = WI.getStrValue(strTemp);
if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Added</option>
          <%}else{%>
          <option value="1">Added</option>
          <%}if(strTemp.compareTo("2") == 0) {%>
          <option value="2" selected>Subtracted</option>
          <%}else{%>
          <option value="2">Subtracted</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>Gender</td>
			<%
			if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
				strTemp = (String)vEditInfo.elementAt(22);
			else
				strTemp = WI.fillTextValue("for_gender");
			strTemp = WI.getStrValue(strTemp);
			%> 			
      <td colspan="3">
			<select name="for_gender">
				<option value="">ALL</option>
        <% if (strTemp.equals("0")) {%>
        <option value="0" selected>Male</option>
        <%}else{%>
				<option value="0">Male</option>
				<%}%>
				<%if (strTemp.equals("1")) {%>
        <option value="1" selected>Female</option>
        <%}else{%>
        <option value="1">Female</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">&nbsp;</td>
      <td colspan="3"> <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0){%> <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to save entries</font> <%}else{ %> <a href='javascript:PageAction("","2");'><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> <%}
}%> <a href="./sal_ben_incent_mgmt_benefits.jsp?IS_BENEFIT=<%=WI.fillTextValue("IS_BENEFIT")%>"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel and clear entries</font> </td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" valign="top">&nbsp;</td>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>	  
  <table width="100%"  bgcolor="#FFFFFF"cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" align="center" bgcolor="#666666"><font color="#FFFFFF"><strong>LIST 
      OF BENEFIT</strong></font></td>
    </tr>
  </table>
	  
  <table width="100%"  bgcolor="#000000" cellpadding="0" cellspacing="1">
    <tr bgcolor="#FFFFFF"> 
      <td width="9%" height="25" align="center" bgcolor="#FFFFFF"><font size="1"><strong>BENEFIT 
      TYPE:: SUB TYPE</strong></font></td>
      <td width="9%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>COVERAGE</strong></font></td>
      <td width="9%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>DESCRIPTION</strong></font></td>
      <td width="9%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>REMARKS</strong></font></td>
      <td width="9%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>ELIGIBILITY PERIOD/SCHED</strong></font></td>
      <td width="9%" align="center" bgcolor="#FFFFFF"><strong><font size="1">PREMIUM ::: EMP 
      SHARE, EMP'ER SHARE</font></strong></td>
      <td width="9%" align="center" bgcolor="#FFFFFF"><strong><font size="1">APPLY SETTING</font></strong></td>
      <td width="9%" align="center" bgcolor="#FFFFFF"><font size="1"><strong>IS TAXABLE</strong></font></td>
      <td width="9%" align="center" bgcolor="#FFFFFF"><strong><font size="1">APPLICABLE DUR</font></strong></td>
      <td width="9%" align="center" bgcolor="#FFFFFF"><strong><font size="1">IS ADDED IN PAYROLL</font></strong></td>
      <td width="5%" height="25">&nbsp;</td>
      <td width="5%">&nbsp;</td>
    </tr>
    <%
String[] astrConvertToEligibilityUnit = {"day(s)","week(s)","month(s)","year(s)"};
String[] astrConvertToBenefitNature   = {"Accumulated","Convertible to Cash","Non accumulated"};
String[] astrApplySetting             = {"Manual","Auto"};
String[] astrApplicableDur            = {"","Every salary period","Every month","Quarterly","Bi-annual","Yearly"};
String[] astrAddedInPayroll           = {"N/A","Added","Subtracted"};
for(int i = 0; i < vRetResult.size(); i += 30){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%>::: <%=ConversionTable.replaceString((String)vRetResult.elementAt(i + 3), ",", ", ")%></td>
      <td><%if( ((String)vRetResult.elementAt(i + 5)).compareTo("0.0") != 0){%>
	  <%=(String)vRetResult.elementAt(i + 5) + " " +
	  	astrCoverageUnit[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%><%}%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 7))%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i + 8))%></td>
      <td><%=(String)vRetResult.elementAt(i + 9) + " " +
	  	astrConvertToEligibilityUnit[Integer.parseInt((String)vRetResult.elementAt(i + 10))]%> of work</td>
      <td>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 15),"",":::","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 16),"",",","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 17),"")%>	  </td>
      <td align="center"><%=astrApplySetting[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 12), "0"))]%></td>
      <td align="center">&nbsp;
	  <%if(vRetResult.elementAt(i + 11) != null && ((String)vRetResult.elementAt(i + 11)).compareTo("1") == 0){%>
	  <img src="../../../images/tick.gif"><%}%></td>
      <td align="center">&nbsp;<%=astrApplicableDur[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 13), "0"))]%></td>
      <td align="center">&nbsp;<%=astrAddedInPayroll[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 14), "0"))]%></td>
      <td> <% if (iAccessLevel > 1){%> <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);"> 
        <img src="../../../images/edit.gif" border="0"></a> <%}%></td>
      <td> <% if (iAccessLevel == 2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'> 
        <img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
    </tr>
    <%}%>
  </table>
<%}//only if vRetResult != null
%>
  <table width="100%"  bgcolor="#FFFFFF"cellpadding="0" cellspacing="0">
    <tr> 
      <td height="20" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="20" colspan="4">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="consider_vedit">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="IS_BENEFIT" value="0">
<input type="hidden" name="benefit_type_name" value="<%=WI.fillTextValue("benefit_type_name")%>">
</form>
<script language="javascript">
<!--
ShowUpdate();
		//document.getElementById("update_button").style.display="none";
		//document.getElementById("update_text").style.display ="none";
-->
</script>
</body>
</html>

<%
dbOP.cleanUP();
%>