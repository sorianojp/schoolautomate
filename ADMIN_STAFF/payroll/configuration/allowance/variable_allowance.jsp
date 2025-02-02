<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Allowances Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./variable_allowance.jsp?is_cola=0";
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function UpdateNote(){
	var vSelected = document.form_.deduct_absent.value;

	if(vSelected == '0'){		
		document.form_.note.value= "Fixed allowance. Not dependent on the days present or absent";		
		document.form_.release_sched.disabled = false;
	}else{	
		document.form_.release_sched.disabled = true;
		if(vSelected == '1')
			document.form_.note.value= "Allowance depends on the number of days and hours present";
		else if(vSelected == '2')
			document.form_.note.value= "Allowance depends on the number of days/hours absent. Works only with edtr records.";
		else if(vSelected == '3')
			document.form_.note.value= "Allowance depends on the number of hours present";		
	}

}

function Test() {
	alert("value " + document.form_.myfile.value);
	alert("title " + document.form_.myfile.title);
	document.form_.file_path.value  = document.form_.myfile.value;	
	alert("dir " + document.form_.file_path.dir);
}

function ComputeRates(){
	
	var strMonthly = document.form_.cola_month.value;
	var strDaily   = document.form_.cola_daily.value;
	var strHourly  = document.form_.cola_hourly.value;
	if (strMonthly.length > 0){
		if (eval(strMonthly) != 0){
			var strMonthlyAmount = eval(strMonthly);
			strDaily  = (strMonthlyAmount * 12)/313; //12mnths and 313 days per year acc. to EAC
			strHourly =  strDaily/8;			
			strDaily = truncateFloat(strDaily,1,false);
			strHourly = truncateFloat(strHourly,1,false);
		}
	}
	
	document.form_.cola_daily.value = strDaily;
	document.form_.cola_hourly.value = strHourly; 

}




-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="variable_allowance_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION--Variable Allowance-Variable Allowances List","variable_allowance.jsp");
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
Vector vRetResult = null;
Vector vEditInfo = null;

PayrollConfig pr = new PayrollConfig();

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strTemp2 = null;
String strEmpCatg = null;
String strSchCode = dbOP.getSchoolIndex();
String[] astrCategory = {"All Staff","All Faculty","All Employees"};
String[] astrStatus = {"All Staff","All Faculty","All Employees"};
String[] astrTaxable={"../../../../images/x.gif","../../../../images/tick.gif"};
String[] astrBasis={"Fixed Allowance","Present","Absences", "Hours Present"};

String[] astrSchedName  ={"Every Salary Period","Monthly (Every First Period)",
											"Monthly (Every Last Period of the Month)", 
											"Quarterly (Every Last Period of the Quarter)",
											"Bi-annual (June &amp; December)"};
String[] astrSchedVal  ={"0","4","1", "2", "3"};


String[] astrActualName  ={"Every Salary Period","Monthly (Every Last Period of the Month)", 
											"Quarterly (Every Last Period of the Quarter)",
											"Bi-annual (June &amp; December)","Monthly (Every First Period)"};

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};

String strCheck = null;
String strNote = null;
//System.out.println("file_path -- "+ WI.fillTextValue("file_path"));

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (pr.operateOnColaEcola(dbOP,request,0) != null){
			strErrMsg = " Allowance removed successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (pr.operateOnColaEcola(dbOP,request,1) != null){
			strErrMsg = " Allowance posted successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (pr.operateOnColaEcola(dbOP,request,2) != null){
			strErrMsg = " Allowance updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}
}
if (strPrepareToEdit.length() > 0){
	vEditInfo = pr.operateOnColaEcola(dbOP, request, 3);
	if (vEditInfo == null)
		strErrMsg = pr.getErrMsg();
}

vRetResult = pr.operateOnColaEcola(dbOP, request, 4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="UpdateNote();">
<form action="./variable_allowance.jsp" name="form_" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL: VARIABLE ALLOWANCE PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;<font size="1"><a href="./variable_allowance_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Allowance Name</td>
      <%if(vEditInfo!=null) 
	  		strTemp= WI.getStrValue((String)vEditInfo.elementAt(6));		
		else 
			strTemp = WI.fillTextValue("allowance_name");
	  %>
      <td> <input name="allowance_name" type="text" size="32" maxlength="32" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Sub-Name</td>
      <%if(vEditInfo!=null) 
	  		strTemp= WI.getStrValue((String)vEditInfo.elementAt(7));		
		else 
			strTemp = WI.fillTextValue("sub_type");
	  %>
      <td> <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" 
	  name="sub_type" type="text" size="32" maxlength="32" class="textbox"></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Allowance Amount </td>
      <td width="76%"> <%	if(vEditInfo!=null) strTemp= WI.getStrValue((String)vEditInfo.elementAt(3));
			else strTemp= WI.fillTextValue("cola_month");%> <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" 
	  name="cola_month" type="text" id="cola_month" size="8" maxlength="8" class="textbox" onKeyUp="AllowOnlyFloat('form_','cola_month');ComputeRates()"></td>
    </tr>
    <tr> 
      <td width="5%" height="30">&nbsp;</td>
      <td width="19%" height="30">Amount per Day</td>
      <td height="30"> <%	if(vEditInfo!=null) strTemp= WI.getStrValue((String)vEditInfo.elementAt(4));
			else strTemp= WI.fillTextValue("cola_daily");%> <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" 
	  name="cola_daily" type="text" id="cola_daily" size="8" maxlength="8" class="textbox" onKeyUp="AllowOnlyFloat('form_','cola_daily')"></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Amount per hour </td>
      <td height="25">
	  <%if(vEditInfo!=null) 
	  		strTemp= WI.getStrValue((String)vEditInfo.elementAt(10));
		else 
			strTemp= WI.fillTextValue("cola_hourly");
	  %>
      <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" 
	  name="cola_hourly" type="text" size="8" maxlength="8" class="textbox" onKeyUp="AllowOnlyFloat('form_','cola_hourly')"> 
   <font size="1">(Set to zero if per hour present/absent will not be included in computation)</font> </td>
    </tr>


    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Allowance Basis</td>
      <td height="25">
    <select name="deduct_absent" onChange="UpdateNote();">
			<option value="0">Fixed Allowance</option>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(5);
				else	
					strTemp = WI.fillTextValue("deduct_absent");
			
			if(strTemp == null)
				strTemp = "";
			if(strTemp.equals("1")){%>
			<option value="1" selected>Days Present</option>
			<%}else{%>
			<option value="1">Days Present</option>
			<%}if(strTemp.equals("2")) {%>
			<option value="2" selected>Days Absent</option>
			<%}else{%>
			<option value="2">Days Absent</option>
			<%}if(strTemp.equals("3")) {%>
			<option value="3" selected>Hours worked</option>
			<%}else{%>
			<option value="3">Hours worked</option>
			<%}%>
		</select> 
    <br>
   <input name="note" type="text" class="textbox_noborder" style="font-size:9px" size="90" readonly></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Release schedule</td>
      <td height="25">
				<select name="release_sched">
        <option value="0">Every Salary Period</option>
        <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(12);
				else	
					strTemp = WI.fillTextValue("release_sched");
									
				if(strTemp == null)
					strTemp = "";
				for(int i = 1; i < astrSchedName.length;i++){
        if(strTemp.equals(astrSchedVal[i])) {%>
        <option value="<%=astrSchedVal[i]%>" selected><%=astrSchedName[i]%></option>
        <%}else{%>
        <option value="<%=astrSchedVal[i]%>"><%=astrSchedName[i]%></option>				
				<%}
				}%>
      </select>
      <strong><font size="1">For fixed allowance only</font></strong></td>
    </tr>    
		<%//if(strSchCode.startsWith("CGH")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Required Hours work</td>
	    <%if(vEditInfo!=null) 
	  		strTemp= WI.getStrValue((String)vEditInfo.elementAt(11));
		else 
				strTemp= WI.fillTextValue("hours_required");
	  %>			
      <td height="25"><input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" 
	  name="hours_required" type="text" size="8" maxlength="8" class="textbox" onKeyUp="AllowOnlyFloat('form_','hour_required')">
      <font size="1">(No. of hours work required in order to get allowance. Leave blank or set to zero if not applicable)</font></td>
    </tr>
		<%//}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Taxable setting</td>
      <td height="25">
        <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(9);
			else	
				strTemp = WI.fillTextValue("is_taxable");
			strTemp = WI.getStrValue(strTemp,"1");
			if(strTemp.compareTo("1") == 0) 
				strTemp = " checked";
			else	
				strTemp = "";	
			%>
        <input type="radio" name="is_taxable" value="1"<%=strTemp%>>
        Taxable 
        <%
				if(strTemp.length() == 0) 
					strTemp = " checked";
				else
					strTemp = "";
				%>
        <input type="radio" name="is_taxable" value="0"<%=strTemp%>>
        Non Taxable</td>
    </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>&nbsp;</td>
        <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(14);
			else	
				strTemp = WI.fillTextValue("less_from_gross");
			strTemp = WI.getStrValue(strTemp,"0");
			if(strTemp.compareTo("1") == 0) 
				strTemp = " checked";
			else	
				strTemp = "";					
			%>			
		  <td><input type="checkbox" name="less_from_gross" value="1"<%=strTemp%>>
        <font size="1">Check if the allowance will be removed from computed gross during computation of contributions </font></td>
	  </tr>
		<%if(strSchCode.startsWith("AUF")){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
        <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(13);
			else	
				strTemp = WI.fillTextValue("add_to_basic");
			strTemp = WI.getStrValue(strTemp,"0");
			if(strTemp.compareTo("1") == 0) 
				strTemp = " checked";
			else	
				strTemp = "";	
			%>
      <td height="25"><input type="checkbox" name="add_to_basic" value="1"<%=strTemp%>>
      <font size="1">Check if the allowance will be added to basic for computation of contribution</font></td>
    </tr>
		<%}%>
    <tr>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td height="35" colspan="2" align="center" valign="bottom"> 
        <% if (iAccessLevel > 1) {
	  if (vEditInfo == null) {%>
        <!--<a href="javascript:AddRecord()"><img src="../../../../images/save.gif" width="48" height="28"  border="0"></a>-->
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
        <font size="1">click to save entries </font> 
        <%}else{%>
        <!--<a href="javascript:EditRecord()"><img src="../../../../images/edit.gif" width="40" height="26"  border="0"></a>-->					
        <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:EditRecord();">
        <font size="1">click to change entries </font> 
        <%} // end else if vEditInfo == null %>
        <!--<a href="javascript:CancelRecord()"><img src="../../../../images/cancel.gif" border="0"></a>-->
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
        <font size="1">click to cancel/clear entries</font> 
        <%} // end iAccessLevel > 1%>      </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		
		<tr>
			<td width="3%">&nbsp;</td>
			<td colspan="2"><strong>Show Options </strong></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td width="19%">Allowance name </td>
		  <td width="78%"><select name="allow_name_con">
        <%=pr.constructGenericDropList(WI.fillTextValue("allow_name_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
	    <input type="text" name="search_allow_name" value="<%=WI.fillTextValue("search_allow_name")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>Sub-Name</td>
			<td><select name="allow_code_con">
        <%=pr.constructGenericDropList(WI.fillTextValue("allow_code_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
        <input type="text" name="search_allow_code" value="<%=WI.fillTextValue("search_allow_code")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>Allowance Basis</td>
			<%
				strTemp = WI.fillTextValue("search_basis");
			%>
		  <td>
			<select name="search_basis">
        <option value="">ALL</option>
      <%
			for(int i = 0;i < astrBasis.length; i++){
			if(strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrBasis[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrBasis[i]%></option>
        <%}
			}%>
      </select></td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>Taxable setting</td>
			<%
				strTemp = WI.fillTextValue("search_taxable");
			%>
		  <td> <select name="search_taxable">
        <option value="">ALL</option>
        <%if(strTemp.equals("0")){%>
        <option value="0" selected>Non Taxable</option>
        <%}else{%>
        <option value="0">Non Taxable</option>
        <%}if(strTemp.equals("1")) {%>
        <option value="1" selected>Taxable</option>
        <%}else{%>
        <option value="1">Taxable</option>        
        <%}%>
      </select></td>
	  </tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td><input type="button" name="reload" value=" Reload " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:ReloadPage();"></td>
	  </tr>
  </table>	
 <% if (vRetResult != null) { %> 
	 
  <table width="100%" border="1" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="9" align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0" ></a>click 
        to print table</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="9" align="center" bgcolor="#B9B292"><strong>LIST 
        OF ALLOWANCES IMPLEMENTED</strong></td>
    </tr>
    <tr> 
      <td width="27%" rowspan="2" align="center"><strong><font size="1">ALLOWANCE 
        NAME</font></strong></td>
      <td height="18" colspan="3" align="center"><font size="1"><strong>AMOUNT</strong></font></td>
       <td width="9%" rowspan="2" align="center"><strong><font size="1">HOURS REQUIRED </font></strong></td>
       <td width="26%" rowspan="2" align="center"><strong><font size="1">ALLOWANCE BASIS</font></strong></td>
       <!--
			<td width="6%" rowspan="2" align="center"><strong><font size="1">TAXABLE</font></strong></td>
			-->
      <td colspan="2" rowspan="2" align="center"><strong><font size="1">OPTIONS</font></strong></td>
    </tr>
    <tr> 
      <td width="8%" height="18" align="center"><font size="1"><strong>Allowance</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>Per Day</strong></font></td>
      <td width="8%" align="center"><font size="1"><strong>Per hour </strong></font></td>
    </tr>
    <%for (int i = 0; i< vRetResult.size() ; i+=20) {%>
    <tr> 
	  <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6))%><%=WI.getStrValue((String)vRetResult.elementAt(i+7)," - ","","&nbsp;")%></font></td>
      <td height="28" align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%>&nbsp;</font></td>
      <td align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%>&nbsp;</font></td>
      <td align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+10))%>&nbsp;</font></td>
       <td align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"0")%>&nbsp;</font></td>
 			<%strTemp2 = "";
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");	
				if(strTemp.equals("0")){
					strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+12),"0");
					strTemp2 = astrActualName[Integer.parseInt(strTemp2)];									
				}
				strTemp2 = WI.getStrValue(strTemp2,"<br>- ","","");
				if(((String)vRetResult.elementAt(i+9)).equals("1"))
					strTemp2 += "<br>- Taxable";
				else					
					strTemp2 += "<br>- Non Taxable";
				
				if(((String)vRetResult.elementAt(i+13)).equals("1"))
					strTemp2 += "<br>- Added to Basic";					
				
				if((WI.getStrValue((String)vRetResult.elementAt(i+14),"0")).equals("1")) 
					strTemp2 += "<br>- Remove from gross during computation of contributions ";
				else	
					strTemp2 += "<br>- Include in gross during computation of contributions ";
					
			%>
      <td><font size="1">&nbsp;<%=astrBasis[Integer.parseInt(strTemp)]%><%=strTemp2%></font></td>      
      <!--
			<td align="center">
			<img src="<%=astrTaxable[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+9),"0"))]%>" >
			</td>
			-->
      <td width="7%" align="center">  
        <% if (iAccessLevel > 1) {%>
        <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a> 
        <%}else{%>
        NA 
        <%}%>      </td>
      <td width="7%" align="center">  
        <% if (iAccessLevel == 2) {%>
        <a href='javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%>
        NA 
        <%}%></td>
    </tr>
    <%}// end for loop%>
  </table>
<%}//end vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
<input type="hidden" name="is_cola" value="<%=WI.fillTextValue("is_cola")%>">
<input type="hidden" name="file_path" >
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
