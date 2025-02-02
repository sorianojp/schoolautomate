<%@ page language="java" import="utility.*,java.util.Vector,payroll.OvertimeMgmt" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Create OT Type</title>
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
<script>
<!--
function ReloadPage(){
	this.SubmitOnce('form_');
}

function PageAction(strAction, strInfoIndex, strCode) {
	if(strAction== 0){
		var vProceed = confirm('Delete '+strCode+' ?');
		if(!vProceed){			
			return;
		}
	}
	
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.submit();
}

function PrepareToEdit(strIndex){
	document.form_.print_page.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}

function CancelRecord(){
	location = "./overtime_type_create_with_group?ot_type="+document.form_.ot_type.value;
}

function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

function ShowHideLabel(strLabel){
	if(strLabel == "" || strLabel == null)
		return;
	

 	for(var i = 1;i <= 2; i++){
		if(strLabel == i){
			if(!document.getElementById(strLabel))
				continue;
			
			var layer = document.getElementById(strLabel);
			layer.style.display = 'block';
			layer.style.visibility = "visible";
			
			//iframe.style.visibility = 'visible';				
			//iframe.style.display = 'block';
			//iframe.style.width = layer.offsetWidth-5;
			//iframe.style.height = layer.offsetHeight-5;
			//iframe.style.left = layer.offsetLeft;
			//iframe.style.top = layer.offsetTop;					
		}else{
			if(!document.getElementById(i))
				continue;
			document.getElementById(i).style.visibility = "hidden";
		}
	}

//	if(strLabel == 0){
//		iframe.style.display = 'none';
//		iframe.style.visibility = 'hidden';
//	}
	
}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./overtime_type_print.jsp" />
	<% 
return;}

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
								"Admin/staff-Payroll-CONFIGURATION-OT Type Management","overtime_type_create_with_group.jsp");
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
	
Vector vRetResult = null;
Vector vEditInfo = null;
OvertimeMgmt OTMgmt = new OvertimeMgmt();
String[] astrRateType = {"%","Flat","Specific Rate"};
String[] astrRateTypeTop = {"Percentage","Flat Rate","Specific Rate"};

String[] astrOption = {"Regular","Rest Day"};
String[] astrNightDiff = {"","Night Differential"};
String[] astrAdjType = {"Deduct from salary","Add to salary"};
String[] astrTaxable = {"Non Taxable","Taxable"};
String[] astrAddToBasic = {"Not added to basic","Added to basic"};

String strPageAction = WI.fillTextValue("page_action");
strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strCheck = null;
String strOTType = WI.getStrValue(WI.fillTextValue("ot_type"),"0");
String strLabel = "ADJUSTMENT TYPE";
int i = 0;
int iSearchResult = 0;
if(strOTType.equals("0"))
	strLabel = "ADJUSTMENT TYPE";
else
	strLabel = "OVERTIME TYPE";

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (OTMgmt.operateOnOvertimeType(dbOP,request,0) != null){
			strErrMsg = "Type removed successfully ";
		}else{
			strErrMsg = OTMgmt.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (OTMgmt.operateOnOvertimeType(dbOP,request,1) != null){
			strErrMsg = "Type posted successfully ";
		}else{
			strErrMsg = OTMgmt.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (OTMgmt.operateOnOvertimeType(dbOP,request,2) != null){
			strErrMsg = "Type updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = OTMgmt.getErrMsg();
		}
	}
}

	if (strPrepareToEdit.compareTo("1") == 0){
		vEditInfo = OTMgmt.operateOnOvertimeType(dbOP,request,3);
	
		if (vEditInfo == null)
			strErrMsg = OTMgmt.getErrMsg();	
	}

	vRetResult  = OTMgmt.operateOnOvertimeType(dbOP,request,4);
		if(vRetResult == null)
			strErrMsg = OTMgmt.getErrMsg();

%>
<form action="overtime_type_create_with_group.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL - CONFIGURATION - <%=strLabel%> MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25"><font size=3><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Code</td>
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(1);
					else 
						strTemp = WI.fillTextValue("code"); 				
			%>
      <td height="26" valign="bottom"> 
			<input name="code" type="text" size="16" maxlength="16" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td width="33" height="26">&nbsp;&nbsp;<div align="center"></div></td>
      <td width="151">Name / Description</td>
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(2);
					else 
						strTemp = WI.fillTextValue("name"); 				
			%>			
      <td width="564" height="26">
			<input name="name" type="text" size="64" maxlength="64" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Rate</td>
			<%
					if (vEditInfo != null) 
						strTemp = (String)vEditInfo.elementAt(3);
					else 
						strTemp = WI.fillTextValue("rate"); 				
			%>			
      <td height="26">
			<input name="rate" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyFloat('form_','rate')" value="<%=strTemp%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','rate')">
			<select name="rate_type">
				<option value="0">Percentage</option>
				<%
				if (vEditInfo != null) 
					strTemp = (String)vEditInfo.elementAt(4);
				else 
					strTemp = WI.fillTextValue("rate_type"); 
				
				for(i = 1; i  < astrRateTypeTop.length; i++){					
					if (strTemp.equals(Integer.toString(i))) {
				%>
				<option value="<%=i%>" selected><%=astrRateTypeTop[i]%></option>
				<%}else{%>
				<option value="<%=i%>"><%=astrRateTypeTop[i]%></option>
				<%}
				}
				%>
			</select><font size="1">of daily rate/hourly rate</font></td>
    </tr>
		<%
		// strOTType.equals("1") for over time jud
		// else for adjustments
		if(strOTType.equals("1")){%>
	  <tr>
	    <td height="26">&nbsp;</td>
	    <td>Rate(<font size="1">Excess of 8 hours</font>)</td>
			<%
				if (vEditInfo != null) 
					strTemp = (String)vEditInfo.elementAt(12);
				else 
					strTemp = WI.fillTextValue("excess_rate"); 				
			%>	
	    <td height="26"><input name="excess_rate" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyFloat('form_','excess_rate')" value="<%=WI.getStrValue(strTemp)%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','excess_rate')">
			<select name="excess_rate_type">
				<option value="0">Percentage</option>
				<%
				if (vEditInfo != null) 
					strTemp = (String)vEditInfo.elementAt(13);
				else 
					strTemp = WI.fillTextValue("excess_rate_type"); 
				strTemp = WI.getStrValue(strTemp);
				for(i = 1; i  < astrRateTypeTop.length; i++){					
					if (strTemp.equals(Integer.toString(i))) {
				%>
				<option value="<%=i%>" selected><%=astrRateTypeTop[i]%></option>
				<%}else{%>
				<option value="<%=i%>"><%=astrRateTypeTop[i]%></option>
				<%}
				}
				%>
			</select>				
      <font size="1">of hourly rate (if blank, excess  will be same as regular rate) </font></td>
    </tr>
	  <tr>
      <td height="26">&nbsp;</td>
      <td>Option</td>
      <td height="26">
			<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		else	
			strTemp = WI.fillTextValue("is_restday");
		strTemp = WI.getStrValue(strTemp,"0");
		if(strTemp.compareTo("0") == 0) 
			strCheck = " checked";
		else	
			strCheck = "";	
	  %>
        <input type="radio" name="is_restday" value="0"<%=strCheck%>>
        For Regular days 
	<%
		if(strTemp.compareTo("1") == 0) 
			strCheck = " checked";
		else
			strCheck = "";
		%>        
		<input type="radio" name="is_restday" value="1"<%=strCheck%>>
For Rest Days</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>&nbsp;</td>
			<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		else	
			strTemp = WI.fillTextValue("night_diff");
		strTemp = WI.getStrValue(strTemp,"0");
		
		if(strTemp.compareTo("1") == 0) 
			strCheck = " checked";
		else	
			strCheck = "";	
	  %>			
      <td height="26"><input type="checkbox" name="night_diff" value="1"<%=strCheck%>>
        Night Differential </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Auto select for holiday</td>
			<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(14);
		else	
			strTemp = WI.fillTextValue("holiday_type");
		strTemp = WI.getStrValue(strTemp,"0");
	  %>		
      <td height="26">
			<select name="holiday_type">
				<option value="">N/a</option>
				<%=dbOP.loadCombo("holiday_type_index","type"," from edtr_holiday_type where is_del=0  order by TYPE asc",strTemp, false)%> 
			</select> 
			(optional)</td>
    </tr>	
      <td height="26">&nbsp;</td>
      <td>Overtime Group</td>
			<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(14);
		else	
			strTemp = WI.fillTextValue("ot_group");
		strTemp = WI.getStrValue(strTemp,"0");
	  %>		
      <td height="26">
			<select name="ot_group">
				<option value="0">None</option>
				<%=dbOP.loadCombo("ot_group_index","ot_group_name"," from EDTR_OT_GROUP order by ot_group_name asc",strTemp, false)%> 
			</select> 
			</td>
    </tr>
		
		<!--
		<tr>
      <td height="26">&nbsp;</td>
      <td> Rate for Holiday </td>
			<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
		else	
			strTemp = WI.fillTextValue("holiday_rate");
		strTemp = WI.getStrValue(strTemp,"0");
	  %>		
      <td height="26"><input name="holiday_rate" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyFloat('form_','holiday_rate')" value="<%=strTemp%>" size="6" maxlength="6" 
			onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','holiday_rate')">
      <a href='javascript:ShowHideLabel("1")'><img src="../../../../images/online_help.gif" width="34" height="26" border="0"></a>
		<div id="1" style="position:absolute; visibility:hidden; width:400px;">
				<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
				<tr>
					<td width="90%"><font size="1"><strong>Ex. Set OT Rate Above = 130%</strong><br>
					Breakdown desired : 100% for Reg OT, 30% Holiday pay<br>
					<strong>Set here 30</strong><br>
					This setting will only work if the date of overtime is also a holiday. In case the date of
					overtime is not a holiday, the full amount will be included in the Reg OT amount.
					</font></td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
				</tr>
				</table>
		</div>			
			</td>
    </tr>				
		-->
		<%} else{ //strOTType.equals("1")  %>
		<tr>
      <td height="26">&nbsp;</td>
      <td>Option</td>
      <td height="26">
			<%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(9);
		else	
			strTemp = WI.fillTextValue("is_add");
		strTemp = WI.getStrValue(strTemp,"1");
		if(strTemp.compareTo("1") == 0) 
			strCheck = " checked";
		else	
			strCheck = "";	
	  %>
        <input type="radio" name="is_add" value="1"<%=strCheck%>>
        Add to Salary
        <%
		if(strTemp.compareTo("0") == 0) 
			strCheck = " checked";
		else
			strCheck = "";
		%>
<input type="radio" name="is_add" value="0"<%=strCheck%>> 
Deduct from Salary</td>
    </tr>
		<tr>
		  <td height="26">&nbsp;</td>
		  <td>&nbsp;</td>
		  <td height="26"><%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(10);
		else	
			strTemp = WI.fillTextValue("is_taxable");
		strTemp = WI.getStrValue(strTemp,"1");
		if(strTemp.compareTo("1") == 0) 
			strCheck = " checked";
		else	
			strCheck = "";	
	  %>
        <input type="radio" name="is_taxable" value="1"<%=strCheck%>>
Taxable
<%
		if(strTemp.compareTo("0") == 0) 
			strCheck = " checked";
		else
			strCheck = "";
		%>
<input type="radio" name="is_taxable" value="0"<%=strCheck%>> 
Non Taxable</td>
	  </tr>
		<tr>
		  <td height="26">&nbsp;</td>
		  <td>&nbsp;</td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(11);
			else	
				strTemp = WI.fillTextValue("add_to_basic");
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(strTemp.compareTo("1") == 0) 
				strCheck = " checked";
			else	
				strCheck = "";	
			%>				
		  <td height="26"><input type="checkbox" name="add_to_basic" value="1"<%=strCheck%>>
		    Add to basic(for use in computation of bonuses)</td>
	  </tr>
		<%}%>		
    <tr> 
      <td height="36" colspan="3" align="center">  
			<%if(iAccessLevel > 1){%>
        <% if(vEditInfo != null) {%>
        <!--
				<a href='javascript:PageAction(2,<%=WI.fillTextValue("info_index")%>,"");'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a>
				-->
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2','<%=WI.fillTextValue("info_index")%>','');">
				<font size="1">click to save changes</font>
        <%}else{%>
        <!--
				<a href='javascript:PageAction(1,"","");'><img src="../../../../images/save.gif" border="0" name="hide_save"></a>
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','','');">
				<font size="1">click to add</font> 
        <%}%>
          <!--<a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" width="51" height="26" border="0"></a> -->					
					<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
					<font size="1">click to cancel</font>					
				<%}%>				</td>
    </tr>
    <tr> 
      <td height="2" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if (vRetResult!=null && vRetResult.size()>0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>   
      <td height="10"><div align="right"><font><a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><strong><font color="#FFFFFF">:: 
      LIST OF EXISTING <strong><%=strLabel%></strong> IN RECORD ::</font></strong></td>
    </tr>
    <tr>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>CODE</strong></font></td>
      <td width="32%" height="25" align="center" class="thinborder"><strong>NAME</strong></td>
      <td width="25%" align="center" class="thinborder"><strong>RATE</strong></td>
      <td width="18%" align="center" class="thinborder"><strong>OPTION</strong></td>
      <td colspan="2" align="center" class="thinborder"><strong>OPTIONS</strong></td>
    </tr>
    <%
		//System.out.println("vRetResult " +vRetResult);
	for(i = 0; i < vRetResult.size();i +=19){%>
    <tr> 
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td valign="top" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
				strTemp += "&nbsp;" +(String)vRetResult.elementAt(i+5);
				
				if(strOTType.equals("1") && vRetResult.elementAt(i+12) != null){
					strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+13),"0");
					strTemp2 = astrRateType[Integer.parseInt(strTemp2)];
					strTemp += WI.getStrValue((String)vRetResult.elementAt(i+12), "<br>Excess : <br>&nbsp;", "&nbsp;" +strTemp2,"");
				}
			%>
      <td valign="top" class="thinborder"><%=strTemp%></td>
			<%
				if(strOTType.equals("1")){
					strTemp = astrOption[Integer.parseInt((String)vRetResult.elementAt(i+6))] + "<br>";
					strTemp += astrNightDiff[Integer.parseInt((String)vRetResult.elementAt(i+7))];
				}else{
					strTemp = astrAdjType[Integer.parseInt((String)vRetResult.elementAt(i+9))];
					strTemp += "<br>" + astrTaxable[Integer.parseInt((String)vRetResult.elementAt(i+10))];
					strTemp += "<br>" + astrAddToBasic[Integer.parseInt((String)vRetResult.elementAt(i+11))];
				}			
			%>
      <td valign="top" class="thinborder"><%=strTemp%></td>
      <td width="6%" align="center" class="thinborder"> 
			<% if (iAccessLevel > 1) {%> 
				<a href='javascript:PrepareToEdit("<%=vRetResult.elementAt(i)%>");'>
				<img src="../../../../images/edit.gif" border="0"></a> 
      <%}else{%> &nbsp; <%}%> </td>
      <td width="8%" align="center" class="thinborder"> 
				<% if (iAccessLevel ==2) {%> 
					<a href='javascript:PageAction(0,"<%=vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+1)%>")'>
					<img src="../../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        	N/A 
      	<%}%>			</td>
    </tr>
		<%}%>		
  </table>
<%} // if vRetResult != null%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="24"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="ot_type" value="<%=WI.fillTextValue("ot_type")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>