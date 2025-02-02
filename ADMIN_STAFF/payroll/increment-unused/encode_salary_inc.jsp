<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
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
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
    TD.noBorder {
	font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
	font-size: 10px;
    }
.style2 {font-family: Verdana, Arial, Helvetica, sans-serif}
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_reloaded.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function SearchEmployee() {
	var pgLoc = "./emplist_salary_inc.jsp?emp_id="+document.form_.emp_id.value+				
				"&pt_ft="+document.form_.pt_ft.value;
	if(document.form_.employee_category)
		pgLoc += "&employee_category="+document.form_.employee_category.value;
	var win=window.open(pgLoc,"SearchEmployee",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strAction, strInfoIndex) {
	document.form_.print_page.value="";
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;		
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function CancelRecord(){
	location = "encode_salary_inc.jsp";	
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchEmployee",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateToZero(strTextName){
	if(eval('document.form_.'+strTextName+'.value.length') == 0){		
		eval('document.form_.'+strTextName+'.value= "0"');
	}	
}

function ComputeTotalIncr(){
  if(document.form_.regular_incr.value.length == 0)
  	return;
  if(document.form_.jesa_incr.value.length == 0)
  	return;
  if(document.form_.other_incr.value.length == 0)
  	return;
  document.form_.total_increment.value = eval(document.form_.regular_incr.value) +
										eval(document.form_.jesa_incr.value) +																								 		  										
										eval(document.form_.other_incr.value);
}

function CheckAll()
{
	document.form_.print_page.value = "";
	var iMaxDisp = document.form_.max_display.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i < eval(iMaxDisp);++i)
			eval('document.form_.user_'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i < eval(iMaxDisp);++i)
			eval('document.form_.user_'+i+'.checked=false');
		
}

function PrepareToEdit(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function VerifyIncrement(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.verify.value = "1";
	this.SubmitOnce("form_");
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" 	method="post" action="./encode_salary_inc.jsp">
<%  WebInterface WI = new WebInterface(request);

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./encode_salary_inc_print.jsp" />
<% return;}
	
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-SALARY RATE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","encode_salary_inc.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}
//end of authenticaion code.
	
	ReportPayroll RptPay = new ReportPayroll(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;
	String[] astrPTFT = {"Part-Time", "Full-time",""};
	String[] astrType = {"Staff", "Faculty","Staff with Teaching Load",""};
	String strPageAction = WI.fillTextValue("page_action");
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	if(WI.fillTextValue("verify").length() > 0){
		if(RptPay.operateOnIncrement(dbOP,6) == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			strErrMsg = "Verified Salary Increment";
		}		
	}
	
	if(strPageAction.length() > 0){
		if(RptPay.operateOnIncrement(dbOP,Integer.parseInt(strPageAction)) == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			strErrMsg = "Success!";
			if(strPageAction.equals("2")){
			  strPrepareToEdit = "";
			}
			strPageAction = "";						
		}		
	}
	
	if(strPrepareToEdit.length() > 0){
		vEditInfo = RptPay.operateOnIncrement(dbOP,3);
	}	
	
	vRetResult = RptPay.operateOnIncrement(dbOP,4);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			iSearchResult = RptPay.getSearchCount();
		}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><strong><font color="#FFFFFF">:::: 
        PAYROLL: SALARY INCREMENT ENCODING PAGE ::::</font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="10" colspan="2"><strong>Implementation Parameter</strong></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Specific Employee </td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(3);
			else
				strTemp = WI.fillTextValue("emp_id");
		%>
      <td height="10"><input name="emp_id" type="text" size="16" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>	
	<%if(bolIsSchool){%>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">Employee Category</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("page_reloaded").equals("1"))
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(1),"2");
			else
				strTemp = WI.fillTextValue("employee_category");
		%>
      <td height="27">
	    <select name="employee_category" onChange="ReloadPage();">
		  <option value="">All Employees</option>
		  <%if(strTemp.equals("0")){%>
          <option value="0" selected>All Staff</option>
		  <option value="1">All Faculties</option>
          <%}else if(strTemp.equals("1")){%>
          <option value="0">All Staff</option>
		  <option value="1" selected>All Faculties</option>
		  <%}else{%>
          <option value="0">All Staff</option>
		  <option value="1">All Faculties</option>		  
		  <%}%>
        </select>
	  </td>
    </tr>
	<%}%>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="19%" height="10">Employee Status</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !WI.fillTextValue("page_reloaded").equals("1"))
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(2),"2");
			else
				strTemp = WI.fillTextValue("pt_ft");
		%>
      <td width="77%" height="10"> <select name="pt_ft" onChange="ReloadPage();">
          <option value="">All Employees</option>
          <%if(strTemp.equals("0")){%>
          <option value="0" selected>All Part-time</option>
		  <option value="1">All Full-time</option>          
          <%}else if(strTemp.equals("1")){%>
          <option value="0">All Part-time</option>
		  <option value="1" selected>All Full-time</option>          
          <%}else{%>
          <option value="0">All Part-time</option>
		  <option value="1">All Full-time</option>          
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="33">&nbsp;</td>
      <td height="33">&nbsp;</td>
      <td height="33"><font size="1"><a href='javascript:SearchEmployee();'><img src="../../../images/view.gif" width="40" height="31" border="0"></a> 
        View Employees to be affected </font><br>
        <font size="1">(Note: Displays only the employees with 
        salary rate encoded in the salary rate page)</font></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%" height="25">Increment Effectivity </td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(4);
			else
				strTemp = WI.fillTextValue("effective_date");
		%>
      <td width="77%" height="25"><input name="effective_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.effective_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Regular Increment</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(5);
			else
				strTemp = WI.fillTextValue("regular_incr");
		%>
      <td height="25"><font size="1"> 
        <input name="regular_incr" type="text" class="textbox " 
			  style="text-align : right"
			  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','regular_incr');
			  UpdateToZero('regular_incr'); style.backgroundColor='white';ComputeTotalIncr();"
			  onKeyUp="AllowOnlyFloat('form_','regular_incr');ComputeTotalIncr();" value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10" >
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Reranking Incr.</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(6);
			else
				strTemp = WI.fillTextValue("jesa_incr");
		%>
      <td height="25"><font size="1"> 
        <input name="jesa_incr" type="text" class="textbox " 
			  style="text-align : right"
			  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','jesa_incr');
			  UpdateToZero('jesa_incr'); style.backgroundColor='white';ComputeTotalIncr();"
			  onKeyUp="AllowOnlyFloat('form_','jesa_incr');ComputeTotalIncr();" value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10">
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Other Increment.</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(7);
			else
				strTemp = WI.fillTextValue("other_incr");
		%>
      <td height="25"><font size="1"> 
        <input name="other_incr" type="text" class="textbox " 
			  style="text-align : right"
			  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','other_incr');
			  UpdateToZero('other_incr'); style.backgroundColor='white';ComputeTotalIncr();"
			  onKeyUp="AllowOnlyFloat('form_','other_incr');ComputeTotalIncr();" value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10">
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">TOTAL INCREMENT :</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(8);
			else
				strTemp = WI.fillTextValue("total_increment");
		%>
      <td height="25"><font size="1"> 
        <input name="total_increment" type="text" class="style2" style="text-align : right; border: 0;"
		 value="<%=WI.getStrValue(strTemp,"0")%>" size="10" maxlength="10">
        </font></td>
    </tr>
    <tr> 
      <td height="40" colspan="3" align="center" class="noBorder">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>  
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(1, '');">
        click to save entries					
        <%}else{%>
	      <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
		  click to save changes
		  <%}%>                   
        <input type="button" name="cancel" value=" Cancel " onClick="javascript:CancelRecord();"
				style="font-size:11px; height:26px;border: 1px solid #FF0000;">
      click to cancel or go previous</td>
    </tr>
    <tr>
      <td height="23" colspan="3"><div align="center">(
          <%if(WI.fillTextValue("show_verified").length() > 0)
		  	  strTemp = " checked";
			else
			  strTemp = "";
		  %>
          <input name="show_verified" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
click to include verified increments)</div></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print result</font></td>
    </tr>
        <%
		int iPageCount = iSearchResult/RptPay.defSearchSize;		
		if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
    <tr> 
      <td colspan="3" align="right">Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
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
      </td>
    </tr>
	<%}%>	
    <tr> 
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">LIST 
          OF INCREMENTS</font></strong>      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="11%" height="25" align="center" class="noBorder" ><strong>EMPLOYEE 
        CATEGORY</strong></td>
      <td width="10%" align="center" class="noBorder"><strong>EMPLOYEE STATUS</strong></td>
      <td width="7%" align="center" class="noBorder"><strong>ID NUMBER</strong></td>
      <td width="8%" align="center" class="noBorder"><strong>EFFECTIVE DATE</strong></td>
      <td width="10%" align="center" class="noBorder"><strong>REGULAR INCREMENT</strong></td>
      <td width="9%" align="center" class="noBorder"><strong>RERANKING</strong></td>
      <td width="11%" align="center" class="noBorder"><strong>OTHER INCREMENT</strong></td>
      <td width="11%" align="center" class="noBorder"><strong>TOTAL INCREMENT</strong></td>
      <td width="23%">&nbsp;</td>
      <!--
      <td width="10%"><div align="center"><strong><font size="1">SELECT ALL</font><br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
          </strong></div></td>
	-->
    </tr>
    <% 
	for(i = 0 ; i < vRetResult.size(); i +=10){%>
    <tr> 
      <%
	  	if(vRetResult.elementAt(i + 1) != null){
			strTemp = (String) vRetResult.elementAt(i + 1);
			strTemp = astrType[Integer.parseInt(strTemp)];
		}else{
			strTemp = "";
		}
		if(vRetResult.elementAt(i + 3) != null)
			strTemp = "&nbsp;";
	  %>
      <td height="25" class="noBorder">&nbsp;<%=WI.getStrValue(strTemp,"All Employees")%></td>
      <%
	  	if(vRetResult.elementAt(i + 2) != null){
			strTemp = (String) vRetResult.elementAt(i + 2);
			strTemp = astrPTFT[Integer.parseInt(strTemp)];
		}else{
			strTemp = "";
		}

		if(vRetResult.elementAt(i + 3) != null)
			strTemp = "&nbsp;";		
	  %>
      <td height="25" class="noBorder">&nbsp;<%=WI.getStrValue(strTemp,"All Employees")%></td>
      <td class="noBorder">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td align="right" class="noBorder"><%=WI.getStrValue((String) vRetResult.elementAt(i + 4),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="noBorder"><%=WI.getStrValue(CommonUtil.formatFloat((String) vRetResult.elementAt(i + 5),true),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="noBorder"><%=WI.getStrValue(CommonUtil.formatFloat((String) vRetResult.elementAt(i + 6),true),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="noBorder"><%=WI.getStrValue(CommonUtil.formatFloat((String) vRetResult.elementAt(i + 7),true),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="noBorder"><%=WI.getStrValue(CommonUtil.formatFloat((String) vRetResult.elementAt(i + 8),true),"&nbsp;")%>&nbsp;</td>
      <td align="center" class="noBorder">  
        <%if(((String)vRetResult.elementAt(i + 9)).equals("0")){%>
        <a href="javascript:VerifyIncrement('<%=(String)vRetResult.elementAt(i)%>')"> 
        <img src="../../../images/verify.gif" width="54" height="20" border=0></a> 
        <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"> 
        <img src="../../../images/edit.gif" border=0 ></a> <a href='javascript:PageAction(0, "<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../../images/delete.gif" border=0></a> 
        <%}else{%>
        Verified 
        <%}%>      </td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>  
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>  
  <input type="hidden" name="verify" value="<%=WI.fillTextValue("verify")%>">	
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">	
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page">
  <input type="hidden" name="page_reloaded">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>