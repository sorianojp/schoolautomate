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
<title>MONTHLY MISCELLANEOUS DEDUCTIONS</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
	font-size: 11px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TABLE.thinborder {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

function SetToZero(){
	var vReason = document.form_.reason.value;
	if(vReason.length == 0){
		alert("Enter reason for setting deduction to zero.");
		return;
	}
		
  var vProceed = confirm('Set payable of selected records to zero?');
  if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod = null;
	String strHasWeekly = null;
	boolean bolHasConfidential = false;
	boolean bolHasTeam = false;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./misc_ded_payable_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payable Misc. Deductions","misc_ded_payable.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");	
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"misc_ded_payable.jsp");
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
	PReDTRME prEdtrME = new PReDTRME();
	Vector vRetResult = null;
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	String strDedName = null;					  
	String strPrevID = "";
	int i = 0;
	if(WI.fillTextValue("page_action").equals("0")){
		vRetResult = RptPay.getMiscPostingWithBalance(dbOP, 0);
		if(vRetResult == null)
			strErrMsg = RptPay.getErrMsg();
	}
	
	if(WI.fillTextValue("searchEmployee").equals("1")){
		vRetResult = RptPay.getMiscPostingWithBalance(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{	
			iSearchResult = RptPay.getSearchCount();
		}
		if(WI.fillTextValue("deduct_index").length() > 0){
			strDedName = dbOP.mapOneToOther("preload_deduction","pre_deduct_index",
						 WI.fillTextValue("deduct_index"),"pre_deduct_name","");
		}
	}
	
	if(strErrMsg == null) 
	strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./misc_ded_payable.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr  bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : SUMMARY MISCELLANEOUS BALANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="23" colspan="5"><strong><%=strErrMsg%></strong></td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Deduction Name </td>
			<%
				strTemp = WI.fillTextValue("deduct_index");
			%>			
      <td colspan="3"><select name="deduct_index">
        <option value="">Select Deduction Name</option>
        <%=dbOP.loadCombo("PRE_DEDUCT_INDEX","PRE_DEDUCT_NAME", " from preload_deduction order by pre_deduct_name",strTemp,false)%>
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
          <option value="" selected>ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> </td>
    </tr>
    
    <%if(bolHasConfidential){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Process Option</td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";
			%>				
      <td colspan="3"><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>
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
      <td colspan="4"><input type="checkbox" name="inc_resigned" value="1" <%=strTemp%>>
      include resigned employees in report</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("view_adjusted").length() > 0)
					strTemp = " checked";
			%>
      <td colspan="4"><input type="checkbox" name="view_adjusted" value="1" <%=strTemp%> onClick="SearchEmployee();">
      view with adjustments </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 10; i <=30 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
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
	<%}%>
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
		<%
		if(WI.fillTextValue("view_adjusted").length() > 0)
			strTemp = " ADJUSTMENTS ";
		else
			strTemp = " BALANCES ";		
		%>	
    <td height="32" colspan="6" align="center" class="thinborderBOTTOMLEFT"><strong><%=(WI.getStrValue(strDedName,"")).toUpperCase()%> <%=strTemp%> as of <%=WI.getTodaysDateTime()%><br>
        </strong></td>
  </tr>
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">    
  <tr>
    <td align="center" class="thinborderBOTTOMLEFT">EMPLOYEE ID </td>
    <td height="21" align="center" class="thinborderBOTTOMLEFT">EMPLOYEE NAME </td>
    <td align="center" class="thinborderBOTTOMLEFT">AMOUNT</td>
    <td align="center" class="thinborderBOTTOMLEFT">PERIOD</td>
    <%if(WI.fillTextValue("view_adjusted").length() > 0){%>
		<td align="center" class="thinborderBOTTOMLEFT">REASON</td>
		<%}else{%>
    <td align="center" class="thinborderBOTTOMLEFTRIGHT">SELECT</td>
		<%}%>
    </tr>
  <%int iCount = 1;
  for(i = 0; i < vRetResult.size();i+=15,iCount++){
  %>  
  <tr>
		<input type="hidden" name="post_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+6)%>">		
		<%
			if(((String)vRetResult.elementAt(i)).equals(strPrevID)){
				strTemp = "&nbsp;";
				strTemp2 = "&nbsp;";
			}else{
				strTemp = (String)vRetResult.elementAt(i);
				strTemp2 = WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), 
									(String)vRetResult.elementAt(i+3), 4).toUpperCase();
			}
			
			strPrevID = (String)vRetResult.elementAt(i);
		%>
    <td width="12%" class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp%></td>
    <td width="35%" height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp2%></td>
		<%
		if(WI.fillTextValue("view_adjusted").length() > 0)
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+10),true);
		else
			strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);		
		%>
    <td width="11%" align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
    <td width="22%" align="right" class="thinborderBOTTOMLEFT"><%=(String)vRetResult.elementAt(i+7)%>-<%=(String)vRetResult.elementAt(i+8)%></td>
    <%if(WI.fillTextValue("view_adjusted").length() > 0){%>
		<td width="20%" class="thinborderBOTTOMLEFT"><%=(String)vRetResult.elementAt(i+9)%></td>
		<%}else{%>
    <td width="5%" align="center" class="thinborderBOTTOMLEFTRIGHT"><input type="checkbox" name="save_<%=iCount%>" value="1"></td>
		<%}%>
    </tr>
  <%}// end for loop%>
  
		<input type="hidden" name="emp_count" value="<%=iCount%>">
</table>
<%if(WI.fillTextValue("view_adjusted").length() == 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="center">&nbsp;</td>
    <td>Reason for update </td>
		<%
			strTemp = WI.fillTextValue("reason");
		%>
    <td><input name="reason" type="text" size="48" maxlength="128" 
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			value="<%=strTemp%>" class="textbox"></td>
  </tr>
  <tr>
    <td width="3%" align="center">&nbsp;</td>
    <td width="20%" align="center">&nbsp;</td>
    <td width="77%" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3" align="center"><%if(iAccessLevel == 2){%>
 
      <input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SetToZero();">
      <font size="1">Click to set selected deductions to zero </font>
       <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
      <font size="1"> click to cancel</font>
      <%}%></td>
    </tr>
</table>
<%}%>
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
	<input type="hidden" name="page_action" value="">
  <input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>