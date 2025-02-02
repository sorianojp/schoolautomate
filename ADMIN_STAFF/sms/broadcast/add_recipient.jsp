<%
if(request.getSession(false).getAttribute("userIndex") == null) {%>
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
	document.form_.page_action.value = '';
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.submit();
}
function SelALL() {
	var iMaxRow = document.form_.max_disp.value;
	var bolCheck = document.form_.sel_all.checked;
	for(var i = 0; i < iMaxRow; ++i)
		eval('document.form_.user_'+i+'.checked = bolCheck');
}
function AddUser(strAction) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to remove these recipients.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.submit();
}
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length > 0)
		return;

	if(document.form_.close_wnd_called.value == "0") 
		window.opener.ReloadPage();
}

</script>

<body bgcolor="#D2AE72" onUnload="ReloadParentWnd()">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-SMS-SMSuser list","add_recipient.jsp");
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
	sms.BroadCast bCast = new sms.BroadCast();
	if(bCast.operateOnAddUserToBroadCast(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = bCast.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
if(WI.fillTextValue("search_").length() > 0) {
	vRetResult = searchStud.searchToReceiveBroadcast(dbOP, request);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}

String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strSem    = (String)request.getSession(false).getAttribute("cur_sem");

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

//I have to find total number of users already registered for this broadcast.. 
      String strTotalRecipient = "select count(*) from SMS_BROADCAST_USER_LIST where BROADCAST_INDEX = "+WI.fillTextValue("broadcast_ref");
      strTotalRecipient = dbOP.getResultOfAQuery(strTotalRecipient, 0);

boolean bolShowRecipient = false;
if(WI.fillTextValue("show_recipient").length() > 0) 
	bolShowRecipient = true;

%>
<form action="./add_recipient.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<input type="hidden" name="sy_from"  value="<%=strSYFrom%>">
<input type="hidden" name="sy_to"    value="<%=strSYTo%>">
<input type="hidden" name="semester" value="<%=strSem%>">

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          <%if(bolShowRecipient){%> Show Recipient to Receive Broadcast<%}else{%>Add Recipient to Broadcast<%}%> ::::</strong></font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr style="font-size:11px; font-weight:bold;">
      <td height="25">&nbsp;</td>
      <td>Total Recipient Added :<%=strTotalRecipient%> 
	  <%if(!strTotalRecipient.equals("0")){%>
	  	<!--<a href="javascript:ViewList('<%=WI.fillTextValue("broadcast_ref")%>')">Click to view list</a>-->
		<input type="checkbox" value="checked" name="show_recipient" <%=WI.fillTextValue("show_recipient")%> onClick="document.form_.page_action.value='';document.form_.search_.value='1';document.form_.submit()"> Show Recipient (uncheck to add recipient)
	  <%}%>
	  </td>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="97%">
<%
String strSearchType = WI.fillTextValue("search_type");
if(strSearchType.length() == 0)
	strSearchType = "0";

if(strSearchType.equals("0"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
        <input name="search_type" type="radio" value="0" <%=strErrMsg%> onClick="ReloadPage();"> Search Student (College)
<%
if(strSearchType.equals("1"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
<input name="search_type" type="radio" value="1" <%=strErrMsg%> onClick="ReloadPage();"> Search Student (Grade School)
<%
if(strSearchType.equals("2"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>
<input name="search_type" type="radio" value="2" <%=strErrMsg%> onClick="ReloadPage();"> Search Employee</td></tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    </tr>
<%if(strSearchType.equals("0")){//college.%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Current SY-Term</td>
      <td><%=strSYFrom%> - <%=strSYTo%>, <%=astrConvertTerm[Integer.parseInt(strSem)]%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
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
<%}else if(strSearchType.equals("1")){//hs%>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>Current SY : </td>
	  <td colspan="3"><%=strSYFrom%>, <%=strSYTo%></td>
    </tr>
	<tr> 
		  <td width="3%" height="25">&nbsp;</td>
		  <td width="15%">Grade : </td>
		  <td colspan="3">
	  	  <select name="g_level">
			  <option value="">ALL</option>
			  <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("g_level"),false)%> 
		  </select>		  </td>
    </tr>
<%}else{//employees.%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
	  	  <select name="c_index" onChange="ReloadPage();">
			  <option value=""></option>
			  <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index"), false)%> 
		  </select>  (OR)	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
		  <select name="d_index">
	          <option value=""></option>
          	  <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index=0 or c_index is null) order by d_name asc",WI.fillTextValue("d_index"), false)%>			  
		  </select>	  </td>
    </tr>
<%}%>
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
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="27%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="34%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  	<input type="submit" name="1" value="&nbsp;&nbsp;Search&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.search_.value='1';document.form_.page_action.value='';">	  </td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" <%if(!bolShowRecipient) {%>bgcolor="#CCCC99"<%}else{%>bgcolor="#99CCCC"<%}%>><tr><td>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
		
		<tr> 
		  <td height="25" colspan="3" bgcolor="#B9B292" class="thinborderALL"><div align="center"><strong><font color="#FFFFFF">SEARCH 
			  RESULT</font></strong></div></td>
		</tr>
		<tr> 
		  <td width="64%" height="22" class="thinborderLEFT"><b> Total <%if(!bolShowRecipient) {%>Search Result<%}else{%> Recipient<%}%>: <%=iSearchResult%> - Showing(<%=searchStud.getDisplayRange()%>)</b></td>
		  <td width="36%" colspan="2" class="thinborderRIGHT"> &nbsp;<%
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
				<%
						}
				}
				%>
			  </select>
			  <%}%>
			</div></td>
		</tr>
	  </table>
	  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
		<tr align="center" style="font-weight:bold"> 
		  <td width="15%" height="25" class="thinborder" style="font-size:9px;">ID Number  </td>
		  <td width="15%" class="thinborder" style="font-size:9px;">Name</td>
		  <td width="15%" class="thinborder" style="font-size:9px;">User's Mobile </td>
		  <td width="15%" style="font-size:9px;" class="thinborder">Guardian/Parnet Mobile </td>
		  <td width="5%" class="thinborder"><strong><font size="1">Select</font></strong>
		  <br><input type="checkbox" name="sel_all" onClick="SelALL();">	  </td>
		</tr>
	<%//System.out.println(vRetResult);
	int j = 0;
	for(int i=0; i<vRetResult.size(); i+=9,++j){%>
		<tr <%=strTemp%>> 
		  <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
		  <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),(String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
		  <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 5)%></td>
		  <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7), "&nbsp;")%></td>
		  <td align="center" class="thinborder"><input type="checkbox" name="user_<%=j%>" value="<%=vRetResult.elementAt(i)%>"></td>
		</tr>
	<%}%>
	<input type="hidden" name="max_disp" value="<%=j%>">
	  </table>
	  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
		  <td width="23%" height="25"><div align="right"> </div></td>
		  <td colspan="3">&nbsp;</td>
		</tr>
	<%if(!bolShowRecipient) {%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td width="31%" style="font-size:9px;">&nbsp;<a href="javascript:AddUser('1');">
				<img src="../../../images/add.gif" border="0"></a> Add selected users</td>
		  <td width="25%" style="font-size:9px;">&nbsp;</td>
		  <td width="21%" style="font-size:9px;">&nbsp;</td>
		</tr>
	<%}else{%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td width="31%" style="font-size:9px;">&nbsp;<a href="javascript:AddUser('0');"><img src="../../../images/delete.gif" border="0"></a> Delete selected users</td>
		  <td width="25%" style="font-size:9px;">&nbsp;</td>
		  <td width="21%" style="font-size:9px;">&nbsp;</td>
		</tr>
	<%}%>
  	  </table>
  </td></tr></table>
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

	<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="broadcast_ref" value="<%=WI.fillTextValue("broadcast_ref")%>">
	
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>