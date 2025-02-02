<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,sms.SMSUser,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.searchStudent.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce("form_");
}
function SearchStudent() {
	document.form_.searchStudent.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce("form_");
}
function SelALL() {
	var iMaxRow = document.form_.max_row.value;
	var bolCheck = document.form_.sel_all.checked;
	for(var i = 0; i < iMaxRow; ++i)
		eval('document.form_.user_'+i+'.checked = bolCheck');
}
function CopyRelation() {
	var iMaxRow = document.form_.max_row.value;
	if(!document.form_.guest_rel_copy.checked)
		return;
	var objRel; var lastSelIndex; var iTemp;
	for(var i = 0; i < iMaxRow; ++i) {
		eval('iTemp=document.form_.mobile_parent_rel'+i+'.selectedIndex');
		if(iTemp == 0) 
			eval('document.form_.mobile_parent_rel'+i+'.selectedIndex=lastSelIndex');
		else
			lastSelIndex = iTemp;
	} 	
}
function PageAction(strAction) {
	var strVerifyMsg = "";
	if(strAction == '0')
		strVerifyMsg = "Are you sure you want to delete mobile registration of selected users.";
	else if(strAction == '5')
		strVerifyMsg = "Are you sure you want to block the selected user mobile access.";
	 
	if(strVerifyMsg != '') {
		if(!confirm(strVerifyMsg))
			return;
	}

	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function SearchEmp() {
	document.form_.consider_sy.checked = false;
	document.form_.course_index.selectedIndex = 0;
	document.form_.year_level.selectedIndex   = 0;
}
</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-SMS-SMSuser list","register_stud.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

int iSearchResult = 0;

SMSUser searchStud = new SMSUser(request);
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(searchStud.operateOnSMSUserList(dbOP, Integer.parseInt(strTemp)) == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
if(WI.fillTextValue("search_").length() > 0) {
	vRetResult = searchStud.operateOnSMSUserList(dbOP, 4);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}
String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSem    = (String)request.getSession(false).getAttribute("cur_sem");

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>
<form action="./register_stud.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          MOBILE REGISTRATION PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4">
<%
strTemp = WI.fillTextValue("consider_sy");
if(request.getParameter("search_") == null || strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="consider_sy" value="1" <%=strTemp%>>
	  Search studentd enrolled in  SY/Term : <%=strSYFrom%> - <%=strSYTo%>, 
	  <%=astrConvertTerm[Integer.parseInt(strSem)]%>
	  <input type="hidden" name="sy_from" value="<%=strSYFrom%>">
	  <input type="hidden" name="semester" value="<%=strSem%>">
	  
	  
	  &nbsp;&nbsp;<font size="1">(Uncheck to dis-regard current sy/term)</font>	  </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">Course</td>
      <td width="28%">&nbsp;</td>
      <td width="10%">Year Level</td>
      <td width="44%">
	  <select name="year_level">
        <option value=""></option>
        <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
        <option value="1" selected>1st</option>
        <%}else{%>
        <option value="1">1st</option>
        <%}if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>2nd</option>
        <%}else{%>
        <option value="2">2nd</option>
        <%}if(strTemp.compareTo("3") ==0)
{%>
        <option value="3" selected>3rd</option>
        <%}else{%>
        <option value="3">3rd</option>
        <%}if(strTemp.compareTo("4") ==0)
{%>
        <option value="4" selected>4th</option>
        <%}else{%>
        <option value="4">4th</option>
        <%}if(strTemp.compareTo("5") ==0)
{%>
        <option value="5" selected>5th</option>
        <%}else{%>
        <option value="5">5th</option>
        <%}if(strTemp.compareTo("6") ==0)
{%>
        <option value="6" selected>6th</option>
        <%}else{%>
        <option value="6">6th</option>
        <%}%>
      </select></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4"><select name="course_index" style="font-size:10px;">
	  <option></option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 										" order by course_name asc", request.getParameter("course_index"), false)%> 
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">Filter for 
<%
strTemp = request.getParameter("con");
if(strTemp == null)
	strTemp = "";
if(strTemp.length() == 0 || strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="con" value="2"<%=strErrMsg%>> ID Number 
<%
if(strTemp.equals("3"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="con" value="3"<%=strErrMsg%>> Last Name 
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="con" value="1"<%=strErrMsg%>> Mobile Number </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4"><input type="text" name="con_val" value="<%=WI.fillTextValue("con_val")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4">
<%
strTemp = request.getParameter("search_type");
if(strTemp == null)
	strTemp = "";
	
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input name="search_type" type="radio" value="0" <%=strErrMsg%>> 
	  Search Student (includes Grade and Higher education)
      <%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
      <input name="search_type" type="radio" value="2" <%=strErrMsg%> onClick="SearchEmp();"> Search Employee </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" class="thinborderALL" bgcolor="#DDDDDD"> 
<%
strTemp = WI.fillTextValue("show_registered");
if(strTemp.equals("0") || request.getParameter("page_action") == null)
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input type="radio" name="show_registered" value="0"<%=strErrMsg%>> Show All
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input type="radio" name="show_registered" value="1"<%=strErrMsg%>> Show only if Registered
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input type="radio" name="show_registered" value="2"<%=strErrMsg%>> Show if not Registered
<%
if(strTemp.equals("3"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
	  <input type="radio" name="show_registered" value="3"<%=strErrMsg%>> Show only Blocked
	  
	  
	  
	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="27%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="34%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  	<input type="submit" name="1" value="&nbsp;&nbsp;Search&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.search_.value='1';document.form_.page_action.value='';">	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="64%" ><b> Total Result : <%=iSearchResult%> - Showing(<%=searchStud.getDisplayRange()%>)</b></td>
      <td width="36%" colspan="2"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchStud.defSearchSize;
		if(iSearchResult % searchStud.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="document.form_.page_action.value='';document.form_.submit();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            		<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            	<%}else{%>
            		<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            	<%}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="15%" height="25" class="thinborder"><div align="center"><strong><font size="1">ID NUMBER </font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">Name</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">Mobile Number </font></strong></div></td>
	  <td width="15%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Mobile Number of Guardian </td>
      <td width="15%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Guardian Relation 
	  <br>
	  <input type="checkbox" name="guest_rel_copy" onClick="CopyRelation();"> Copy All</td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">Select</font></strong>
	  <br><input type="checkbox" name="sel_all" onClick="SelALL();">
	  </td>
    </tr>
<%//System.out.println(vRetResult);
int j = 0;
for(int i=0; i<vRetResult.size(); i+=11,++j){
strTemp = WI.getStrValue(vRetResult.elementAt(i + 10), "0");
if(strTemp.equals("0"))
	strTemp = "";
else	
	strTemp = " bgcolor='#cccccc'";
%>
    <tr <%=strTemp%>> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%></font></td>
      <td class="thinborder">
<%
strTemp = (String)vRetResult.elementAt(i + 6);
%>
	  <select name="mobile_main_prefix<%=j%>" style="font-size:11px;" onChange="javascript:document.form_.user_<%=j%>.checked=true">
	  <%=dbOP.loadCombo("PREFIX_INDEX","PREFIX_INDEX"," from SMS_GSM_PROVIDER_PREFIX order by PREFIX_INDEX", strTemp, false)%>
	  </select>
<%//System.out.println(strTemp);
if(vRetResult.elementAt(i + 5) != null) {
	strTemp = ((String)vRetResult.elementAt(i + 5)).substring(strTemp.length());
	strErrMsg = " style='font-weight:bold'";
}
else {
	strTemp = "";
	strErrMsg = "";
}
%>
	  <input type="text" name="mobile_main<%=j%>" class="textbox"<%=strErrMsg%> onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'; javascript:document.form_.user_<%=j%>.checked=true" size="8" value="<%=strTemp%>"></td>
      <td class="thinborder">
<%
strTemp = (String)vRetResult.elementAt(i + 8);
%>
	  <select name="mobile_parent_prefix<%=j%>" style="font-size:11px;" onChange="javascript:document.form_.user_<%=j%>.checked=true">
	  <%=dbOP.loadCombo("PREFIX_INDEX","PREFIX_INDEX"," from SMS_GSM_PROVIDER_PREFIX order by PREFIX_INDEX", strTemp, false)%>
	  </select>
<%//System.out.println(strTemp);
if(vRetResult.elementAt(i + 7) != null) {
	strTemp = ((String)vRetResult.elementAt(i + 7)).substring(strTemp.length());
	strErrMsg = " style='font-weight:bold'";
}
else {
	strTemp = "";
	strErrMsg = "";
}
%>
	  <input type="text" name="mobile_parent<%=j%>" class="textbox"<%=strErrMsg%> onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'; javascript:document.form_.user_<%=j%>.checked=true" size="8" value="<%=strTemp%>"></td>
      <td align="center" class="thinborder"><select name="mobile_parent_rel<%=j%>">
        <option value=""></option>
<%
strTemp = (String)vRetResult.elementAt(i + 9);
if(strTemp == null)
	strTemp = "";
if(strTemp.equals("Father"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="Father">Father</option>
<%
if(strTemp.equals("Mother"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="Mother"<%=strErrMsg%>>Mother</option>
<%
if(strTemp.equals("Guardian"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="Guardian"<%=strErrMsg%>>Guardian</option>
      </select></td>
      <td align="center" class="thinborder"><input type="checkbox" name="user_<%=j%>" value="<%=vRetResult.elementAt(i)%>"></td>
    </tr>
<%}%>
<input type="hidden" name="max_row" value="<%=j%>">
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="23%" height="25"><div align="right"> </div></td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="31%" style="font-size:9px;">
	  <a href="javascript:PageAction('1');"><img src="../../../images/update.gif" border="0"></a> Update user/mobile number information</td>
      <td width="25%" style="font-size:9px;">
	  <%
	  strTemp = WI.fillTextValue("show_registered");
	  if(!strTemp.equals("2") && !strTemp.equals("0")){%>
	  	<a href="javascript:PageAction('0');"><img src="../../../images/delete.gif" border="0"></a> Delete User/Mobile Registration.
	  <%}%>
	  </td>
      <td width="21%" style="font-size:9px;">
	  <%if(strTemp.equals("3")) {//show un-block button..%>
	  	<a href="javascript:PageAction('6');">Unblock selected Mobile User</a>
	  <%}else if(strTemp.equals("1")){%>
	  	<a href="javascript:PageAction('5');">Block selected Mobile User</a>
	  <%}%>
	  </td>
    </tr>
  </table>
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
<input type="hidden" name="page_action">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>