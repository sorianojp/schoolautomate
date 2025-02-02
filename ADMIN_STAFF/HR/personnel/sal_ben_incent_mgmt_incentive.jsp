<%@ page language="java" import="utility.*,java.util.Vector,hr.HRSalaryGrade"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.

boolean bolIsSchool = false;

if ((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle_small.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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
	var loadPg = "./sal_ben_incent_type_update.jsp?label=INCENTIVE&opner_form_name=form_&is_incentive=1";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.consider_vedit.value = "1";//take edit info.
	document.form_.submit();
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
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-salary grade","sal_ben_incent_mgmt_incentive.jsp");
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

int iAccessLevel = -1;

if (!strSchCode.startsWith("AUF")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"sal_ben_incent_mgmt_incentive.jsp");
}else{
    iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"sal_ben_incent_mgmt_incentive.jsp");
}
														
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home",
						"../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vEditInfo  = null;
HRSalaryGrade hrSG = new HRSalaryGrade();

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
	vEditInfo = hrSG.operateOnBenefit(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = hrSG.getErrMsg();
}//System.out.println("Before 2 : "+strErrMsg);
//get the list. 
vRetResult = hrSG.operateOnBenefit(dbOP, request, 4);
%>

<body bgcolor="#663300" class="bgDynamic">
<form action="./sal_ben_incent_mgmt_incentive.jsp" method="post" name="form_">
  <table width="100%"  bgcolor="#FFFFFF"cellpadding="0" cellspacing="0">
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INCENTIVE MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" align="right" ><a href='./sal_ben_incent_mgmt_main.jsp'><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td width="3%" rowspan="11" align="center" valign="middle"><img src="../../../images/sidebar.gif" width="11" height="270"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="22%">Incentive Type</td>
      <td width="73%"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("benefit_type_index");
%> <select name="benefit_type_index">
          <option value="">Select a Incentive type</option>
          <%=dbOP.loadCombo("BENEFIT_TYPE_INDEX","BENEFIT_NAME",
		  	" FROM HR_PRELOAD_BENEFIT_TYPE where is_incentive = 1 order by BENEFIT_NAME",strTemp,false)%> </select> 
<%if(iAccessLevel > 1){%>
			<a href='javascript:viewList();'> <img src="../../../images/update.gif" border="0"></a>      
<%}%>
			</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Sub-Type</td>
      <td> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("sub_type");
%> <input name="sub_type" type= "text" class="textbox" value="<%=strTemp%>" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Coverage</td>
      <td> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("converage");
%> <input name="converage" type= "text" class="textbox" value="<%=strTemp%>" size="10" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('form_', 'converage')"			
			onKeypUp="AllowOnlyFloat('form_', 'converage')"> 

 <select name="coverage_unit">
          <option value="0">Day(s)</option>
          <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("coverage_unit");		  
		   if(strTemp.equals("1")){%>
          <option value="1" selected>%</option>
          <%}else{%>
          <option value="1">%</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>Cash (php)</option>
          <%}else{%>
          <option value="2">Cash (php)</option>
          <%}
		  
		  if (bolIsSchool) {
		  	if(strTemp.equals("3")){%>
          <option value="3" selected>Teaching load unit</option>
          <%}else{%>
          <option value="3">Teaching load unit</option>
          <%}if(strTemp.equals("4")){%>
          <option value="4" selected>Teaching load hour</option>
          <%}else{%>
          <option value="4">Teaching load hour</option>
          <%}
		   if (strSchCode.startsWith("UDMC")) {
		  
		  if(strTemp.equals("5")){%>
          <option value="5" selected>Employee Current Load Hour</option>
          <%}else{%>
          <option value="5">Employee Current Load Hour</option>
          <%}
		   } // end if UDMC
		  } // bol is School
		  %>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">Plan Description</td>
      <td> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("plan_desc");
strTemp = WI.getStrValue(strTemp);
%> <textarea name="plan_desc" cols="50" rows="3" class="textbox" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">Remarks</td>
      <td> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("remarks");
strTemp = WI.getStrValue(strTemp);
%> <textarea name="remarks" cols="50" rows="3" class="textbox" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Eligibility Period/Schedule</td>
      <td> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("eligibility");
strTemp = WI.getStrValue(strTemp);
%> <input name="eligibility" type= "text" class="textbox" value="<%=strTemp%>" size="10" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"			
			onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <%
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
      <td>
<%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(12);
else	
	strTemp = WI.fillTextValue("auto_apply");
strTemp = WI.getStrValue(strTemp,"0");

if(strTemp.compareTo("1") == 0) 
	strTemp = " selected";
else	
	strTemp = "";
%>	  <input type="radio" name="auto_apply" value="1"<%=strTemp%>>
        Apply when eligible(based on eligibility period) &nbsp;&nbsp;
<%
if(strTemp.length() == 0) 
	strTemp = " selected";
else
	strTemp = "";
%>        <input type="radio" name="auto_apply" value="0"<%=strTemp%>>
        Apply Manually.</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Taxable setting</td>
      <td>
<%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("is_taxable");
strTemp = WI.getStrValue(strTemp,"1");
if(strTemp.compareTo("1") == 0) 
	strTemp = " selected";
else	
	strTemp = "";
%>	  <input type="radio" name="is_taxable" value="1"<%=strTemp%>>
        Taxable 
<%
if(strTemp.length() == 0) 
	strTemp = " selected";
else
	strTemp = "";
%>        <input type="radio" name="is_taxable" value="0"<%=strTemp%>>
        Non Taxable</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Applicable Duration</td>
      <td>
	  <select name="applicable_dur">
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
<%}%>	  </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Is Added to Payroll</td>
      <td>
	  <select name="is_added_pr">
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
<%}%>	  </select>	  </td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" valign="top">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">&nbsp;</td>
      <td> <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0){%> <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to save entries</font> <%}else{ %> <a href='javascript:PageAction("","2");'><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> <%}
}%>
        <a href="./sal_ben_incent_mgmt_incentive.jsp?IS_BENEFIT=<%=WI.fillTextValue("IS_BENEFIT")%>"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel and clear entries</font> </td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" valign="top">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>	  
  <table width="100%"  bgcolor="#FFFFFF"cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" bgcolor="#666666"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF INCENTIVES</strong></font></div></td>
    </tr>
  </table>
	  
  <table width="100%"  bgcolor="#000000" cellpadding="0" cellspacing="1">
    <tr bgcolor="#FFFFFF"> 
      <td width="10%" height="25"><div align="center"><font size="1"><strong>BENEFIT 
          TYPE:: SUB TYPE</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>COVERAGE</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>ELIGIBILITY PERIOD/SCHED</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>APPLY SETTING</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>IS TAXABLE</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>APPLICABLE DUR</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>IS ADDED IN PAYROLL</strong></font></div></td>
      <td width="5%" height="25"><font size="1">&nbsp;</font></td>
      <td width="5%"><font size="1">&nbsp;</font></td>
    </tr>
    <%
String[] astrConvertToCoverageUnit    = {"DAYS","%","CASH","TEACHING LOAD UNIT","TEACHING HOUR UNIT","EMPLOYEE CURRENT LOAD HOUR"};
String[] astrConvertToEligibilityUnit = {"day(s)","week(s)","month(s)","year(s)"};
String[] astrConvertToBenefitNature   = {"Accumulated","Convertible to Cash","Non accumulated"};
String[] astrApplySetting             = {"Manual","Auto"};
String[] astrApplicableDur            = {"","Every salary period","Every month","Quarterly","Bi-annual","Yearly"};
String[] astrAddedInPayroll           = {"N/A","Added","Subtracted"};
for(int i = 0; i < vRetResult.size(); i += 18){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25"><font size="1"><%=(String)vRetResult.elementAt(i + 1)%>::: <%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td><font size="1"> 
        <%if( ((String)vRetResult.elementAt(i + 5)).compareTo("0.0") != 0){%>
        <%=(String)vRetResult.elementAt(i + 5) + " " +
	  	astrConvertToCoverageUnit[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%> 
        <%}%>
        </font></td>
      <td><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i + 7))%></font></td>
      <td><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i + 8))%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 9) + " " +
	  	astrConvertToEligibilityUnit[Integer.parseInt((String)vRetResult.elementAt(i + 10))]%> of work</font></td>
      <td align="center"><font size="1"><%=astrApplySetting[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 12), "0"))]%></font></td>
      <td align="center"><font size="1">&nbsp; 
        <%if(vRetResult.elementAt(i + 11) != null && ((String)vRetResult.elementAt(i + 11)).compareTo("1") == 0){%>
        <img src="../../../images/tick.gif"> 
        <%}%>
        </font></td>
      <td align="center"><font size="1">&nbsp;<%=astrApplicableDur[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 13), "0"))]%></font></td>
      <td align="center"><font size="1">&nbsp;<%=astrAddedInPayroll[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 14), "0"))]%></font></td>
      <td>&nbsp;<% if (iAccessLevel > 1){%> <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);"> 
        <img src="../../../images/edit.gif" border="0"></a> <%}%></td>
      <td>&nbsp;<% if (iAccessLevel == 2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'> 
        <img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
    </tr>
    <%}%>
  </table>
<%}//only if vRetResult != null
%>
  <table width="100%"  bgcolor="#FFFFFF"cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="consider_vedit">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="IS_BENEFIT" value="1">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>