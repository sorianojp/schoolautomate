<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
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
<title>Faculty Term Type</title>
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
function ReloadPage(){
	document.form_.is_reloaded.value = "";
	document.form_.submit();
}

//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.is_reloaded.value = 1;	
	if(strInfoIndex.length > 0){
		document.form_.info_index.value = strInfoIndex;
	}
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
} 

function PrintPg()
{
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./term_inc_dates.jsp";
}

</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
 
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./tax_override_print.jsp" />
	<% 
return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Term Inclusive Dates","term_inc_dates.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"term_inc_dates.jsp");
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
	Vector vEditInfo	= null;//detail of salary period.
	PayrollConfig prConfig = new PayrollConfig();
	int iSearchResult = 0;
	int i = 0;
	boolean bolIsReloaded = WI.fillTextValue("is_reloaded").equals("1");
 	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
	
	String[] astrTerm1   = {"Summer", "1st Semester", "2nd Semester"};
	String[] astrTerm2   = {"", "1st Trimester", "2nd Trimester","3rd Trimester"};
	String[] astrTerm3   = {"Summer", "","Yearly Semester"};
	
	String strPageAction = WI.fillTextValue("page_action");
	String strTermType = WI.getStrValue(WI.fillTextValue("term_type"), "1");
 	if(strPageAction.length() > 0){
		if(prConfig.operateOnSemInclusiveDates(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = prConfig.getErrMsg();
		} else {
			if(strPageAction.equals("1"))
				strErrMsg = "Setting successfully posted.";

			else if(strPageAction.equals("0"))
				strErrMsg = "Setting successfully removed.";		

			else if(strPageAction.equals("2")){
				strErrMsg = "Setting successfully updated";		
				strPrepareToEdit = "0";
			}
		}
	}
	
	if(strPrepareToEdit.equals("1")){
		vEditInfo = prConfig.operateOnSemInclusiveDates(dbOP,request, 3);
	}
	
	vRetResult = prConfig.operateOnSemInclusiveDates(dbOP,request, 4);
	if(vRetResult == null)
		strErrMsg = prConfig.getErrMsg();
	else
		iSearchResult = prConfig.getSearchCount();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="term_inc_dates.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL:  TERM INCLUSIVE DATES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Term Type</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded) 
					strTermType = (String)vEditInfo.elementAt(1);
			%>
      <td><strong><font size="1">
        <select name="term_type" onChange="ReloadPage();">
			<option value="1" <%=strTermType.equals("1")?"selected":"" %> >Semester</option>
			<option value="2" <%=strTermType.equals("2")?"selected":"" %> >Trimester</option>
			<option value="3" <%=strTermType.equals("3")?"selected":"" %> >Yearly</option>      
        </select>
      </font></strong></td>
    </tr>
    <tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="19%">School Year </td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded) 
					strTemp = (String)vEditInfo.elementAt(2);
				else
					strTemp = WI.fillTextValue("term");
			%>
      <td width="78%"><strong><font size="1">
      <%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded) 
				strTemp = (String)vEditInfo.elementAt(6);
			else
				strTemp = WI.fillTextValue("sy_from");
				
			if(strTemp == null || strTemp.length() ==0)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
			%> 
		<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to')">
        -
    <%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded) 
				strTemp = (String)vEditInfo.elementAt(7);
			else
				strTemp = WI.fillTextValue("sy_to");

			if(strTemp == null || strTemp.length() ==0)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		%> 
		<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
-        
    <%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded) 
				strTemp = (String)vEditInfo.elementAt(2);
			else
				strTemp = WI.fillTextValue("term");
		%> 	
<select name="term">
					<%if(strTermType.equals("1")){%>
						<% for(i = 0; i < astrTerm1.length;i++){%>
							<%if(strTemp.equals(Integer.toString(i))){%>
							<option value="<%=i%>" selected><%=astrTerm1[i]%></option>
							<%}else{%>
							<option value="<%=i%>"><%=astrTerm1[i]%></option>
							<%}%>
						<%}%>
					<%}else if(strTermType.equals("2")){%>
						<% for(i = 1; i < astrTerm2.length;i++){%>
							<%if(strTemp.equals(Integer.toString(i))){%>
							<option value="<%=i%>" selected><%=astrTerm2[i]%></option>
							<%}else{%>
							<option value="<%=i%>"><%=astrTerm2[i]%></option>
							<%}%>
						<%}%>					
					<%}else{%>
							<option value="2" <%=strTemp.equals("2")?"selected":"" %> ><%=astrTerm3[2]%></option>
							<option value="0" <%=strTemp.equals("0")?"selected":"" %> ><%=astrTerm3[0]%></option>
					<%}%>
        </select>
      </font></strong> </td>
    </tr>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Date Range  </td>
      <td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded) 
					strTemp = (String)vEditInfo.elementAt(3);
				else
					strTemp = WI.fillTextValue("date_from");
			%>
        <input name="date_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a> 
				<%
				if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded) 
					strTemp = (String)vEditInfo.elementAt(4);
				else	
					strTemp = WI.fillTextValue("date_to");
				%>
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Basic Units Load </td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolIsReloaded) 
				strTemp = (String)vEditInfo.elementAt(5);
			else	
				strTemp = WI.fillTextValue("max_units");
			strTemp = WI.getStrValue(strTemp);
			%>
      <td><input name="max_units" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','max_units')"
		onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyInteger('form_','max_units')"  ></td>
    </tr>
    
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18" colspan="3" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="98%" height="35" colspan="3" align="center" valign="bottom">
			<%if(iAccessLevel > 1){%>
			<font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        Click to save entries 
        <%}else{%>
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '');">				
        Click to edit event 
        <%}%>
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">Click to clear 
			</font>
			<%}%>
			</td>
    </tr>
  </table>	
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF" ><strong>TERM INCLUSIVE DATES</strong></font> </td>
    </tr>
    
    <tr>
      <td height="26" align="center" class="thinborder"><font size="1"><strong>TERM TYPE</strong></font></td>
      <td align="center" class="thinborder"><strong><font size="1">SCHOOL YEAR </font></strong></td>
      <td align="center" class="thinborder"><font size="1"><strong>TERM</strong></font></td>
      <td align="center" class="thinborder"><strong><font size="1">DATE RANGE</font></strong></td>
      <td align="center" class="thinborder"><strong><font size="1">MAX UNITS </font></strong></td>
      <td align="center" class="thinborder"><strong><font size="1"><strong>OPTION</strong></font></strong></td>
    </tr>
    
    <% for(i =0; i < vRetResult.size(); i += 8){%>
    <tr> 
			<%
				strTermType = (String)vRetResult.elementAt(i+1);
				if(strTermType.equals("1"))
					strTemp = "Semester";
				else if(strTermType.equals("2"))	
					strTemp = "Trimester";
				else
					strTemp = "Yearly";	
			%>
      <td width="12%" height="25" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+6) + " - " + (String)vRetResult.elementAt(i+7);
			%>				
			<td width="23%" align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
				if(strTermType.equals("1"))
					strTemp = astrTerm1[Integer.parseInt(strTemp)];
				else if(strTermType.equals("2")) 
					strTemp = astrTerm2[Integer.parseInt(strTemp)];		
				else
					strTemp = astrTerm3[Integer.parseInt(strTemp)];	 	
			%>
      <td width="24%" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3) + " to " + (String)vRetResult.elementAt(i+4);
			%>
      <td width="21%" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
			<% strTemp= (String)vRetResult.elementAt(i+5); %>
      <td width="9%" align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
      <td width="11%" height="25" align="center" class="thinborder"> 
			<%if(iAccessLevel > 1){%>
			<input type="button" name="edit2" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
			<%}else{%>
				n/a
			<%}%>		
			</td>
    </tr>
    <%}%>
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
  <input type="hidden" name="is_reloaded" value="<%=WI.fillTextValue("is_reloaded")%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="page_action">	
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">		
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>