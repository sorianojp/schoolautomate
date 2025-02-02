<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Medicine Load Hours Rate</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.fm_variable.page_action.value = "";
	document.fm_variable.submit();
}
function PageAction(strInfoIndex,iAction)
{
	document.fm_variable.page_action.value = iAction ;
	if(strInfoIndex.length > 0)
		document.fm_variable.info_index.value = strInfoIndex;
	document.fm_variable.submit();
}
function ShowHideLoadHrTo()
{
	if(document.fm_variable.load_hour_con.selectedIndex == 3)
		showLayer('rangeTo_');		
	else
		hideLayer('rangeTo_');
document.fm_variable.load_range_to.value ="";			
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceVairable,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	
	String strDegreeType = null;
	String strPrepareToEdit  ="0";//by default edit is not available.
		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Fee Assessment & Payments-medicine load hour rate","variable_load_unit_rate.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"variable_load_unit_rate.jsp");
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
FAFeeMaintenanceVairable fmVariable = new FAFeeMaintenanceVairable();
Vector vRetResult = null;
Vector vEditInfo  = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(fmVariable.operateOnMedicineTuitionFeeCharges(dbOP,request,Integer.parseInt(strTemp)) == null)
		strErrMsg = fmVariable.getErrMsg();
	else
	{
		strErrMsg = "Operation successful.";
		strPrepareToEdit = "0";
	}
}
//get all information from table for the current sem. 

if(WI.fillTextValue("sy_from").length() > 0)
{
	vRetResult = fmVariable.operateOnMedicineTuitionFeeCharges(dbOP,request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = fmVariable.getErrMsg();
}

if(WI.fillTextValue("course_index").length() > 0) {
	strDegreeType = dbOP.mapOneToOther("course_offered","course_index",WI.fillTextValue("course_index"),"degree_type",null);
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 	
	strSchCode = "";

%>

<form name="fm_variable" action="./variable_load_unit_rate.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          VARIABLE LOAD UNIT RATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="12%" height="25">SY/TERM</td>
      <td width="40%" height="25"> 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("fm_variable","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> 
        &nbsp; <select name="offering_sem" >
          <option value="">ALL</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
if(request.getParameter("offering_sem") == null) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="41%" height="25"><input type="image" src="../../../images/refresh.gif"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">COURSE</td>
      <td height="25" colspan="2"><select name="course_index" onChange="ReloadPage();">
          <option value="">Select a Course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", 
		  						WI.fillTextValue("course_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">MAJOR</td>
      <td height="25" colspan="2"><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
if(WI.fillTextValue("course_index").length() > 0)
{
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where is_del=0 and course_index="+WI.fillTextValue("course_index"),
		  			 WI.fillTextValue("major_index"), false)%> 
          <%}%>
        </select></td>
    </tr>
<%
if(strDegreeType != null && strDegreeType.compareTo("1") != 0 && strDegreeType.compareTo("4") != 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">YEAR LEVEL</td>
      <td height="25" colspan="2">
<%
strTemp = WI.fillTextValue("year_level");
%>	  
	  <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>All</option>
          <%}else{%>
          <option value="0">All</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0){%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}%>
        </select> </td>
    </tr>
<%}//only if yearleve is valid for the course selected
%>
    <tr> 
      <td height="18" colspan="4"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 <%if(strSchCode.startsWith("UI")){%>
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="20%" height="25">FLAT RATE </td>
      <td width="73%" height="25"><input name="rate_percent" type="text" size="12" maxlength="12" 
	  value="<%=WI.fillTextValue("rate_percent")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">RULE : * <br>
        1. Less than 14 units -&gt; rate per unit = Flat Rate / 14<br>
        2. Between 14 to 18 -&gt; Flat Rate<br>
        3. Above 14 units -&gt; Flat Rate + Rate per unit * (units taken - 18)<br> 
        <br> <font color="#0000FF"><strong>NOTE: Is there any change in rule(s) 
        in future, contact schoolbliz</strong></font></td>
    </tr>
 <%}else if(strSchCode.startsWith("AUF")){%>
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="20%" height="25"> PER UNIT RATE </td>
      <td width="73%" height="25"><input name="rate_percent" type="text" size="12" maxlength="12" 
	  value="<%=WI.fillTextValue("rate_percent")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><font color="#0000FF"><strong>NOTE:</strong></font> Tuition 
        fee with load less than 18 units is computed based on per unit rate.</td>
    </tr>
<%}//show only if AUF%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4"> <%
	  if(strPrepareToEdit.compareTo("1") != 0 && iAccessLevel > 1){%> <a href='javascript:PageAction("",1);'><img src="../../../images/save.gif" border="0"></a><font size="1">click 
        to add a new entry </font> <%}else if(strPrepareToEdit.compareTo("1") ==0 && iAccessLevel > 1){%> <a href='javascript:PageAction("",2);'><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel &amp; clear entries</font> <%}%> </td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="6">&nbsp;</td>
    </tr>
    <%
if(WI.fillTextValue("sy_from").length() > 0){
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = "ALL SEM";
else if(strTemp.compareTo("0") == 0)
	strTemp = "SUMMER";
else if(strTemp.compareTo("1") == 0)
	strTemp = "1ST SEM";
else if(strTemp.compareTo("2") == 0)
	strTemp = "2ND SEM";
else if(strTemp.compareTo("3") == 0)
	strTemp = "3RD SEM";
else
	strTemp = "UNDEFINED";
%>
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6"><div align="center">LIST OF EXISTING LOAD HOURS 
          &amp; RATE PERCENTAGE FOR SY <%=request.getParameter("sy_from")+" - "+request.getParameter("sy_to")%>, <%=strTemp%></div></td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
String[] astrConvertToLoadCon = {" Equals to ","Less than ","Greater than ","Between "};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="21%" height="25">&nbsp;</td>
      <td width="39%" height="25"><font size="1"><strong>FLAT RATE</strong></font></td>
      <td width="16%"><font size="1"><strong>YEAR LEVEL</strong></font></td>
      <td height="25">&nbsp;</td>
    </tr>
    <%
String[] astrConvertYrLevel = {"ALL","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};
for(int i = 0 ; i< vRetResult.size(); i +=5)
{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td height="25"><%=astrConvertYrLevel[Integer.parseInt((String)vRetResult.elementAt(i+4))]%></td>
      <td width="24%"> <%if(iAccessLevel > 1){%> 
        <!--<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        &nbsp;&nbsp; &nbsp; -->
        <%}if(iAccessLevel ==2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        N/A 
        <%}%> </td>
      <%}%>
    </tr>
  </table>
<%}//if vRetResult is not null;

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>

    <tr bgcolor="#B8CDD1"> 
      <td height="25"bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
 <input type="hidden" name="page_action" value="">
 <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>"> 
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

<input type="hidden" name="called_from_var_unit" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>